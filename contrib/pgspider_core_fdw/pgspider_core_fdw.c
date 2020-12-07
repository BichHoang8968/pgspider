/*-------------------------------------------------------------------------
 *
 * pgspd
 * contrib/pgspider_core_fdw/pgspider_core_fdw.c
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPERATION
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "c.h"
#include "fmgr.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif


#include <stddef.h>
#include <sys/time.h>
#include <unistd.h>
#include <pthread.h>
#include <math.h>
#include "access/htup_details.h"
#include "access/transam.h"
#include "access/sysattr.h"
#include "access/table.h"
#include "access/xact.h"
#include "catalog/pg_type.h"
#include "commands/explain.h"
#include "catalog/pg_proc.h"
#include "foreign/fdwapi.h"
#include "foreign/foreign.h"
#include "executor/tuptable.h"
#include "executor/execdesc.h"
#include "executor/executor.h"
#include "executor/spi.h"
#include "executor/nodeAgg.h"
#include "executor/nodeSubplan.h"
#include "miscadmin.h"
#include "nodes/execnodes.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "nodes/pg_list.h"
#include "nodes/plannodes.h"
#include "nodes/pathnodes.h"
#include "nodes/makefuncs.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/plancat.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/optimizer.h"
#include "optimizer/tlist.h"
#include "optimizer/cost.h"
#include "optimizer/clauses.h"
#include "parser/parsetree.h"
#include "utils/guc.h"
#include "utils/memutils.h"
#include "utils/palloc.h"
#include "utils/lsyscache.h"
#include "utils/builtins.h"
#include "utils/float.h"
#include "utils/datum.h"
#include "utils/rel.h"
#include "utils/elog.h"
#include "utils/selfuncs.h"
#include "utils/numeric.h"
#include "utils/hsearch.h"
#include "utils/syscache.h"
#include "utils/lsyscache.h"
#include "utils/resowner.h"
#include "storage/lmgr.h"
#include "libpq-fe.h"
#include "pgspider_core_fdw_defs.h"
#include "funcapi.h"
#include "postgres_fdw/postgres_fdw.h"
#include "catalog/pg_operator.h"
#include "parser/parse_agg.h"
#ifndef WITHOUT_KEEPALIVE
#include "pgspider_keepalive/pgspider_keepalive.h"
#endif

#define BUFFERSIZE 1024
#define QUERY_LENGTH 512
#define MAX_URL_LENGTH	256

/* See pg_proc.h or pg_aggregate.h */
#define COUNT_OID 2147
#define SUM_OID 2108
#define STD_OID 2155
#define VAR_OID 2148

#define AVG_MIN_OID 2100
#define AVG_MAX_OID 2106
#define VAR_MIN_OID 2148
#define VAR_MAX_OID 2153
#define STD_MIN_OID 2154
#define STD_MAX_OID 2159

#define SUM_BIGINT_OID 2107
#define SUM_INT4_OID 2108
#define SUM_INT2_OID 2109
#define SUM_FLOAT4_OID 2110
#define SUM_FLOAT8_OID 2111
#define SUM_NUMERI_OID 2114

#define MIN_BIGINT_OID 2131
#define MIN_INT4_OID  2132
#define MIN_INT2_OID  2133
#define MIN_FLOAT4_OID 2135
#define MIN_FLOAT8_OID 2136
#define MIN_NUMERI_OID 2146

#define MAX_BIGINT_OID 2115
#define MAX_INT4_OID  2116
#define MAX_INT2_OID  2117
#define MAX_FLOAT4_OID 2119
#define MAX_FLOAT8_OID 2120
#define MAX_NUMERI_OID 2130

#define OPEXPER_INT4_OID 514
#define OPEXPER_INT4_FUNCID 141
#define OPEXPER_INT2_OID 526
#define OPEXPER_INT2_FUNCID 152
#define OPEXPER_INT8_OID 686
#define OPEXPER_INT8_FUNCID 465
#define OPEXPER_NUMERI_OID 1760
#define OPEXPER_NUMERI_FUNCID 1726
#define FLOAT8MUL_OID 594
#define FLOAT8MUL_FUNID 216
#define DOUBLE_LENGTH 8
#define MAX_SPLIT_NUM 3			/* STDDEV and VARIANCE div sum,count,sum(x^2),
								 * so currentrly MAX is 3 */

#define PGSPIDER_FDW_NAME "pgspider_fdw"
#define MYSQL_FDW_NAME "mysql_fdw"
#define FILE_FDW_NAME "file_fdw"
#define AVRO_FDW_NAME "avro_fdw"
#define POSTGRES_FDW_NAME "postgres_fdw"

#define AGGTEMPTABLE "__spd__temptable"

/* Return true if avg, var, stddev */
#define IS_SPLIT_AGG(aggfnoid) ((aggfnoid >= AVG_MIN_OID && aggfnoid <= AVG_MAX_OID) ||(aggfnoid >= VAR_MIN_OID && aggfnoid <= VAR_MAX_OID) ||(aggfnoid >= STD_MIN_OID && aggfnoid <= STD_MAX_OID))
/* Affect memory and BeginForeignScan time */
#define SPD_TUPLE_QUEUE_LEN 5000
/* Index of the last element removed */
#define SPD_LAST_GET_IDX(QUEUE) ((QUEUE)->start - 1)

typedef enum
{
	SPD_FS_STATE_INIT,
	SPD_FS_STATE_BEGIN,
	SPD_FS_STATE_ITERATE,
	SPD_FS_STATE_END,
	SPD_FS_STATE_FINISH,
	SPD_FS_STATE_ERROR,
}			SpdForeignScanThreadState;


/* Allocate TupleQueue for each thread and child thread use this queue
 * to pass tuples to parent
 */
typedef struct SpdTupleQueue
{
	struct TupleTableSlot *tuples[SPD_TUPLE_QUEUE_LEN];
	int			start;			/* index of the first element */
	int			len;			/* number of the elements */
	int			isFinished;		/* true if scan is finished */
	bool		skipLast;		/* true if skip last value copy */
	pthread_mutex_t qmutex;		/* mutex */
}			SpdTupleQueue;


typedef struct ForeignScanThreadInfo
{
	struct FdwRoutine *fdwroutine;	/* Foreign Data wrapper  routine */
	struct ForeignScanState *fsstate;	/* ForeignScan state data */
	int			eflags;			/* it used to set on Plan nodes(bitwise OR of
								 * the flag bits ) */
	Oid			serverId;		/* use it for server id */
	ForeignServer *foreignServer;	/* cache this for performance */
	ForeignDataWrapper *fdw;	/* cache this for performance */
	bool		requestEndScan; /* main thread request endForeingScan to child
								 * thread */
	bool		requestRescan;	/* main thread request rescan to child thread */
	bool		requestStartScan; /* main thread request startscan to child thread */
	SpdTupleQueue tupleQueue;	/* queue for passing tuples from child to
								 * parent */
	int			childInfoIndex; /* index of child info array */
	MemoryContext threadMemoryContext;
	MemoryContext threadTopMemoryContext;
	pthread_mutex_t nodeMutex;	/* Use for ReScan call */
	SpdForeignScanThreadState state;
	pthread_t	me;
	ResourceOwner thrd_ResourceOwner;
	void	   *private;

}			ForeignScanThreadInfo;

enum SpdFdwModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	ForeignFdwPrivate,
	/* Integer list of target attribute numbers for INSERT/UPDATE */
	ServerOid
};

/* For EXPLAIN */
static const char *SpdServerstatusStr[] = {
	"Alive",
	"Not specified by IN",
	"Dead"
};

enum SpdServerstatus
{
	ServerStatusAlive,
	ServerStatusIn,
	ServerStatusDead,
};

/* For debug */
const char *AggtypeStr[] = {"NON-AGG", "NON-SPLIT", "AVG", "VARIANCE", "STDDEV"};

enum Aggtype
{
	NON_AGG_FLAG,
	NON_SPLIT_AGG_FLAG,
	AVG_FLAG,
	VAR_FLAG,
	DEV_FLAG,
	SPREAD_FLAG,
};

/* split agg names for searching on catalog (last must be "") */
const char *CatalogSplitAggStr[] = {"SPREAD",
									""};

const enum Aggtype CatalogSplitAggType[] = {SPREAD_FLAG,
											NON_AGG_FLAG};



/* 'mapping' store index of compressed tlist when splitting one agg into multiple agg.
 * mapping[0]:COUNT(x)
 * mapping[1]:SUM(x)
 * mapping[2]:SUM(x*sx)
 *
 * mapping[0] is also used for non-agg target or non-split agg such as sum and count.
 * Please see spd_add_to_flat_tlist about how we use this struct.
 */
typedef struct Mappingcells
{

	int			mapping[MAX_SPLIT_NUM]; /* pgspider target list */
	enum Aggtype aggtype;		/* agg type */
	StringInfo	agg_command;	/* agg function name */
	int			original_attnum;	/* original attribute */
	StringInfo	agg_const;		/* constant argument of function */
}			Mappingcells;

/* 
 * This struct is used to store a list of mapping cells and the entire expression.
 * It is added to support combination of aggregate functions and operators.
 */
typedef struct Extractcells
{
	List 		*cells;			/* List of mapping cells */
	Expr		*expr;			/* Original expression. It is used for extraction (when create plan) 
								 * and for rebuilding query on temp table */
	int			ext_num;		/* Number of extracted cells */
	bool		is_truncated;	/* True if value needs to be truncated. */
	bool		is_having_qual;	/* True if expression is a qualification applied to HAVING. */
}			Extractcells;

typedef struct ChildInfo
{
	/* USE ONLY IN PLANNING */
	RelOptInfo *baserel;
	PlannerInfo *grouped_root_local;
	RelOptInfo *grouped_rel_local;
	int			scan_relid;
	bool		in_flag;		/* using IN clause or NOT */
	List	   *url_list;
	AggPath    *aggpath;

	/* USE IN BOTH PLANNING AND EXECUTION */
	PlannerInfo *root;
	Plan	   *plan;
	enum SpdServerstatus child_node_status;
	Oid			server_oid;		/* child table's server oid */
	Oid			oid;			/* child table's table oid */
	Agg		   *pAgg;			/* "Aggref" for Disable of aggregation push
								 * down servers */
	bool		can_pushdown_agg;	/* support agg pushdown */

	/* USE ONLY IN EXECUTION */
	int			index_threadinfo;	/* index for ForeignScanThreadInfo array */
}			ChildInfo;

/*
 * SpdFdwPrivate keep child node plan information for each child tables belonging to the parent table.
 * Spd create child table node plan from each spd_GetForeignRelSize(),spd_GetForeignPaths(),spd_GetForeignPlan().
 * SpdFdwPrivate is created at spd_GetForeignSize() using spd_AllocatePrivate().
 * SpdFdwPrivate is free at spd_EndForeignScan() using spd_ReleasePrivate().
 *
 * We classify SpdFdwPrivate member into the following categories
 *  a) necessary only in planning routines(before getForeignPlan)
 *  b) necessary only in execution routines(after beginForeignScan)
 *  c) necessary both in planning and execution routines.
 * We should pass only c) members from getForeignPlan to beginForeignScan for speedup.
 * We use serialization and de-serialization method for passing c) members.
 */
typedef struct SpdFdwPrivate
{
	/* USE ONLY IN PLANNING */
	List	   *baserestrictinfo;	/* root node base strict info */
	List	   *upper_targets;
	List	   *url_list;		/* IN clause for SELECT */

	PlannerInfo *spd_root;		/* Copy of root planner info. This is used by
								 * aggregation pushdown. */
	PgFdwRelationInfo rinfo;	/* pgspider relation info */
	TupleDesc	child_comp_tupdesc; /* temporary tuple desc */

	/* USE IN BOTH PLANNING AND EXECUTION */
	int			node_num;		/* number of child tables */
	int			nThreads;		/* Number of alive threads */
	int			idx_url_tlist;	/* index of __spd_url in tlist. -1 if not used */

	bool		in_flag;		/* using IN clause or NOT */
	bool		agg_query;		/* aggregation flag */
	bool		isFirst;		/* First time of iteration foreign scan with
								 * aggregation query */
	bool		groupby_has_spdurl; /* flag to check if __spd_url is in group clause */
	bool		is_pushdown_tlist;	/* pushed down target list or not. For
									 * aggregation, always false */

	List	   *pPseudoAggList; /* Disable of aggregation push down server
								 * list */
	List	   *child_comp_tlist;	/* child complite target list */
	List	   *child_tlist;	/* child target list without __spd_url */
	List	   *mapping_tlist;	/* mapping list orig and pgspider */

	List	   *groupby_target; /* group target tlist number */

	TupleTableSlot *child_comp_slot;	/* temporary slot */
	StringInfo	groupby_string; /* GROUP BY string for aggregation temp table */

	ChildInfo  *childinfo;		/* ChildInfo List */

	List	   *having_quals;	/* qualitifications for HAVING which are passed to childs */
	bool		has_having_quals;	/* Root plan has qualification applied for HAVING */

	/* USE ONLY IN EXECUTION */
	pthread_t	foreign_scan_threads[NODES_MAX];	/* child node thread  */
	Datum	  **agg_values;		/* aggregation temp table result set */
	bool	  **agg_nulls;		/* aggregation temp table result set */
	int			agg_tuples;		/* Number of aggregation tuples from temp
								 * table */
	int			agg_num;		/* agg_values cursor */
	Oid		   *agg_value_type; /* aggregation parameters */
	Datum	   *ret_agg_values; /* result for groupby */
	bool		is_drop_temp_table; /* drop temp table flag in aggregation */
	int			temp_num_cols;	/* number of columns of temp table */
	char	   *temp_table_name;	/* name of temp table */
	bool		is_explain;		/* explain or not */
	MemoryContext es_query_cxt; /* temporary context */
	pthread_rwlock_t scan_mutex;
}			SpdFdwPrivate;

typedef struct SpdFdwModifyState
{
	Oid			modify_server_oid;
}			SpdFdwModifyState;

/* local function forward declarations */
bool		spd_is_builtin(Oid objectId);
void		_PG_init(void);
static void spd_GetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel,
					  Oid foreigntableid);
static void spd_GetForeignPaths(PlannerInfo *root, RelOptInfo *baserel,
					Oid foreigntableid);
static ForeignScan *spd_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel,
				   Oid foreigntableid, ForeignPath *best_path,
				   List *tlist, List *scan_clauses,
				   Plan *outer_plan);
static void spd_BeginForeignScan(ForeignScanState *node, int eflags);
static TupleTableSlot *spd_IterateForeignScan(ForeignScanState *node);
static void spd_ReScanForeignScan(ForeignScanState *node);
static void spd_EndForeignScan(ForeignScanState *node);
static void spd_GetForeignUpperPaths(PlannerInfo *root,
						 UpperRelationKind stage,
						 RelOptInfo *input_rel,
						 RelOptInfo *output_rel, void *extra);

/*
 * Helper functions
 */
static bool foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel);
static Path *get_foreign_grouping_paths(PlannerInfo *root,
						   RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel);

static void spd_AddForeignUpdateTargets(Query *parsetree,
							RangeTblEntry *target_rte,
							Relation target_relation);

static List *spd_PlanForeignModify(PlannerInfo *root,
					  ModifyTable *plan,
					  Index resultRelation,
					  int subplan_index);

static void spd_BeginForeignModify(ModifyTableState *mtstate,
					   ResultRelInfo *rinfo,
					   List *fdw_private,
					   int subplan_index,
					   int eflags);

static void spd_ExplainForeignScan(ForeignScanState *node, ExplainState *es);

static TupleTableSlot *spd_ExecForeignInsert(EState *estate,
					  ResultRelInfo *rinfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot);

static TupleTableSlot *spd_ExecForeignUpdate(EState *estate,
					  ResultRelInfo *rinfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot);

static TupleTableSlot *spd_ExecForeignDelete(EState *estate,
					  ResultRelInfo *rinfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot);

static void spd_EndForeignModify(EState *estate,
					 ResultRelInfo *rinfo);

static TargetEntry *spd_tlist_member(Expr *node, List *targetlist, int *target_num);

static List *spd_add_to_flat_tlist(List *tlist, Expr *exprs,
						List **mapping_tlist, List **compress_tlist_tle, Index sgref,
						List **upper_targets, bool allow_duplicate, bool is_having_qual);
static void spd_spi_exec_child_ip(char *serverName, char *ip);
static bool spd_can_skip_deepcopy(char *fdwname);
static bool spd_checkurl_clauses(PlannerInfo *root, List *baserestrictinfo);

/* Queue functions */
static bool spd_queue_add(SpdTupleQueue * que, TupleTableSlot *slot, bool deepcopy);
static TupleTableSlot *spd_queue_get(SpdTupleQueue * que, bool *is_finished);
static void spd_queue_reset(SpdTupleQueue * que);
static void spd_queue_init(SpdTupleQueue * que, TupleDesc tupledesc, const TupleTableSlotOps *tts_ops, bool skipLast);
static void spd_queue_notify_finish(SpdTupleQueue * que);
static void spd_spi_ddl_table(char *query, SpdFdwPrivate *fdw_private);

static List *spd_catalog_makedivtlist(Aggref *aggref, List *newList, enum Aggtype aggtype);

/* postgresql.conf paramater */
static bool throwErrorIfDead;
static bool isPrintError;

/* We need to make postgres_fdw_options variable initial one time */
static bool isPostgresFdwInit = false;
pthread_mutex_t postgres_fdw_mutex = PTHREAD_MUTEX_INITIALIZER;

/* We write lock SPI function and read lock child fdw routines */
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;
static MemoryContext thread_top_contexts[NODES_MAX] = {NULL};
static int64 temp_table_id = 0;
static bool registered_reset_callback = false;

extern void deparseStringLiteral(StringInfo buf, const char *val);
extern bool is_foreign_expr2(PlannerInfo *root, RelOptInfo *baserel, Expr *expr);
#define is_foreign_expr is_foreign_expr2
extern bool is_having_safe(Node *node);
extern bool is_sorted(Node *node);
extern void spd_deparse_const(Const *node, StringInfo buf, int showtype);
extern char *spd_deparse_type_name(Oid type_oid, int32 typemod);
static bool check_spdurl_walker(Node *node, PlannerInfo *root);

static SpdFdwPrivate *
spd_AllocatePrivate()
{
	/*
	 * Take from TopTransactionContext
	 */
	SpdFdwPrivate *p = (SpdFdwPrivate *)
	MemoryContextAllocZero(TopTransactionContext, sizeof(*p));

	return p;
}


bool
spd_is_builtin(Oid objectId)
{
	return (objectId < FirstBootstrapObjectId);
}

/* declarations for dynamic loading */
PG_FUNCTION_INFO_V1(pgspider_core_fdw_handler);

/*
 * pgspider_fdw_handler populates an FdwRoutine with pointers to the functions
 * implemented within this file.
 */
Datum
pgspider_core_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *fdwroutine = makeNode(FdwRoutine);

	fdwroutine->GetForeignRelSize = spd_GetForeignRelSize;
	fdwroutine->GetForeignPaths = spd_GetForeignPaths;
	fdwroutine->GetForeignPlan = spd_GetForeignPlan;
	fdwroutine->BeginForeignScan = spd_BeginForeignScan;
	fdwroutine->IterateForeignScan = spd_IterateForeignScan;
	fdwroutine->ReScanForeignScan = spd_ReScanForeignScan;
	fdwroutine->EndForeignScan = spd_EndForeignScan;
	fdwroutine->GetForeignUpperPaths = spd_GetForeignUpperPaths;
	fdwroutine->ExplainForeignScan = spd_ExplainForeignScan;

	fdwroutine->AddForeignUpdateTargets = spd_AddForeignUpdateTargets;
	fdwroutine->PlanForeignModify = spd_PlanForeignModify;
	fdwroutine->BeginForeignModify = spd_BeginForeignModify;
	fdwroutine->ExecForeignInsert = spd_ExecForeignInsert;
	fdwroutine->ExecForeignUpdate = spd_ExecForeignUpdate;
	fdwroutine->ExecForeignDelete = spd_ExecForeignDelete;
	fdwroutine->EndForeignModify = spd_EndForeignModify;

	PG_RETURN_POINTER(fdwroutine);
}

/**
 * Return true if the oid is for split agg functions except avg, var and stddev
 */
static bool
is_catalog_split_agg(Oid oid, enum Aggtype *type)
{
	HeapTuple	proctup;
	Form_pg_proc procform;
	const char *proname;
	int i;
	bool result = false;

	proctup = SearchSysCache1(PROCOID, ObjectIdGetDatum(oid));
	if (!HeapTupleIsValid(proctup))
		elog(ERROR, "cache lookup failed for function %u", oid);
	procform = (Form_pg_proc) GETSTRUCT(proctup);
	proname = NameStr(procform->proname);

	for (i = 0; CatalogSplitAggStr[i][0] != '\0'; i++)
	{
		if (!pg_strcasecmp(proname, CatalogSplitAggStr[i]))
		{
			result = true;

			if (type)
				*type = CatalogSplitAggType[i];
			break;
		}
	}

	ReleaseSysCache(proctup);

	return result;
}


/*
 * spd_can_skip_deepcopy
 *
 * Return true if this fdw can skip deepcopy when adding tuple to a queue.
 * Returning true means that fdw allocates tuples in CurrentMemoryContext.
 *
 * @param[in] fdwname
 */
static bool
spd_can_skip_deepcopy(char *fdwname)
{
	if (strcmp(fdwname, AVRO_FDW_NAME) == 0)
		return true;
	return false;
}

/**
 * spd_queue_notify_finish
 *
 * Notify parent thread that child fdw scan is finished.
 *
 * @param[in,out] que
 */
static void
spd_queue_notify_finish(SpdTupleQueue * que)
{
	pthread_mutex_lock(&que->qmutex);
	que->isFinished = true;
	pthread_mutex_unlock(&que->qmutex);
}

/*
 * spd_queue_add
 *
 * Add 'slot' to queue.
 * Return false immediately if queue is full.
 * Deepcopy each column value of slot If 'deepcopy' is true.
 *
 * @param[in,out] que
 * @param[in] slot
 * @param[in] deepcopy
 */
static bool
spd_queue_add(SpdTupleQueue * que, TupleTableSlot *slot, bool deepcopy)
{
	int			natts;
	int			idx;
	int			i;

	pthread_mutex_lock(&que->qmutex);

	if (que->len >= SPD_TUPLE_QUEUE_LEN)
	{
		/* queue is full */
		pthread_mutex_unlock(&que->qmutex);
		return false;
	}

	idx = (que->start + que->len) % SPD_TUPLE_QUEUE_LEN;

	if (idx == SPD_LAST_GET_IDX(que))
	{
		/* This tuple slot may be being used by core */
		pthread_mutex_unlock(&que->qmutex);
		return false;
	}

	/* Clear slot before storing new data */
	ExecClearTuple(que->tuples[idx]);

	/* Not minimal tuple */
	Assert(!TTS_IS_MINIMALTUPLE(slot));

	/*
	 * Note: In some fdws, for instance, file_fdw, we need to check whether the heap tuple is not null or not.
	 * If it is NULL, we cannot use copy_heap_tuple() because __spd_url column attribute is not valid;
	 */
	if (TTS_IS_HEAPTUPLE(slot) && ((HeapTupleTableSlot*) slot)->tuple)
	{
		/*
		 * TODO: we can probably skip heap_copytuple as in virtual tuple case
		 * for some fdws
		 */
		ExecStoreHeapTuple(slot->tts_ops->copy_heap_tuple(slot),
					que->tuples[idx],
					false);
	}
	else
	{
		/* Virtual tuple */
		natts = que->tuples[idx]->tts_tupleDescriptor->natts;
		memcpy(que->tuples[idx]->tts_isnull, slot->tts_isnull, natts * sizeof(bool));

		/*
		 * Skip copy of __spd_url at the last of tuple descriptor because it's
		 * invalid
		 */
		if (que->skipLast)
			natts--;

		/*
		 * Deep copy tts_values[i] if necessary
		 */
		if (deepcopy)
		{
			FormData_pg_attribute *attrs = slot->tts_tupleDescriptor->attrs;

			for (i = 0; i < natts; i++)
			{
				if (slot->tts_isnull[i])
					continue;
				que->tuples[idx]->tts_values[i] = datumCopy(slot->tts_values[i],
															attrs[i].attbyval, attrs[i].attlen);
			}
		}
		else

			/*
			 * Even if deep copy is not necessary, tts_values array cannot be
			 * reused because it is overwritten by child fdw
			 */
			memcpy(que->tuples[idx]->tts_values, slot->tts_values, (natts * sizeof(Datum)));

		ExecStoreVirtualTuple(que->tuples[idx]);
	}

	que->len++;
	pthread_mutex_unlock(&que->qmutex);
	return true;
}

/*
 * spd_queue_get
 *
 * Return NULL immediately if queue is empty.
 * 'is_finished' is set to true if queue is empty and child foreign scan is finished.
 *
 * @param[in,out] que
 * @param[out] is_finished
 */
static TupleTableSlot *
spd_queue_get(SpdTupleQueue * que, bool *is_finished)
{
	TupleTableSlot *temp;

	pthread_mutex_lock(&que->qmutex);
	if (que->len == 0)
	{
		/* Update only when queue is empty */
		*is_finished = que->isFinished;
		pthread_mutex_unlock(&que->qmutex);
		return NULL;
	}

	temp = que->tuples[que->start];
	que->start = (que->start + 1) % SPD_TUPLE_QUEUE_LEN;
	que->len--;

	pthread_mutex_unlock(&que->qmutex);


	return temp;
}

/*
 * spd_queue_get
 *
 * Reset queue.
 *
 * @param[in,out] que
 */
static void
spd_queue_reset(SpdTupleQueue * que)
{
	que->len = 0;
	que->start = 0;
	que->isFinished = false;
}

/*
 * spd_queue_init
 *
 * Init queue.
 *
 * @param[in,out] que
 * @param[in] tupledesc
 * @param[in] tts_ops
 * @param[in] skip_last
 */
static void
spd_queue_init(SpdTupleQueue * que, TupleDesc tupledesc, const TupleTableSlotOps *tts_ops, bool skip_last)
{
	int			j;

	que->skipLast = skip_last;
	/* Create tuple descriptor for queue */
	for (j = 0; j < SPD_TUPLE_QUEUE_LEN; j++)
	{
		TupleTableSlot *slot = MakeSingleTupleTableSlot(tupledesc, tts_ops);

		que->tuples[j] = slot;
		slot->tts_values = palloc(tupledesc->natts * sizeof(Datum));
		slot->tts_isnull = palloc(tupledesc->natts * sizeof(bool));
	}
	spd_queue_reset(que);
	pthread_mutex_init(&que->qmutex, NULL);
}

/**
 * Print mapping_tlist for debug.
 *
 * @param[in] mapping_tlist
 * @param[in] loglevel
 */
static void
print_mapping_tlist(List *mapping_tlist, int loglevel)
{
	ListCell   *lc;

	foreach(lc, mapping_tlist)
	{
		Extractcells	*extcells = lfirst(lc);
		ListCell		*extlc;
		foreach(extlc, extcells->cells)
		{
			Mappingcells *cells = lfirst(extlc);

			elog(loglevel, "mapping_tlist (%d %d %d)/ original_attnum=%d  aggtype=\"%s\"",
				cells->mapping[0], cells->mapping[1], cells->mapping[2],
				cells->original_attnum, AggtypeStr[cells->aggtype]);
		}
	}
}


/*
 * spd_tlist_member
 *
 * Modified version of tlist_member with a new parameter 'target_num'.
 *
 * Finds the (first) member of the given tlist whose expression is
 * equal() to the given expression.  Result is NULL if no such member.
 *
 * @param[in] node
 * @param[in] targetlist
 * @param[out] target_num
 */
static TargetEntry *
spd_tlist_member(Expr *node, List *targetlist, int *target_num)
{
	ListCell   *temp;

	*target_num = 0;
	foreach(temp, targetlist)
	{
		TargetEntry *tlentry = (TargetEntry *) lfirst(temp);

		if (equal(node, tlentry->expr))
			return tlentry;
		*target_num += 1;
	}
	return NULL;
}

/**
 * spd_spi_exec_proname
 *
 * Add a aggregate function name of 'aggoid' to 'aggname'
 * by fetching from pg_proc system catalog.
 *
 * @param[in] aggoid
 * @param[out] aggname
 */
static void
spd_spi_exec_proname(Oid aggoid, StringInfo aggname)
{
	HeapTuple	proctup;
	Form_pg_proc procform;
	const char *proname;

	proctup = SearchSysCache1(PROCOID, ObjectIdGetDatum(aggoid));
	if (!HeapTupleIsValid(proctup))
		elog(ERROR, "cache lookup failed for function %u", aggoid);
	procform = (Form_pg_proc) GETSTRUCT(proctup);

	/* Always print the function name */
	proname = NameStr(procform->proname);
	appendStringInfoString(aggname, proname);

	ReleaseSysCache(proctup);
}


/*
 * spd_SerializeSpdFdwPrivate
 *
 * Serialize fdw_private as a list to be copied using copyObject.
 * Each element of list in serialize and deserialize functions should be the same order.
 *
 * @param[in] fdw_private
 * @return List - serialized list
 */
static List *
spd_SerializeSpdFdwPrivate(SpdFdwPrivate * fdw_private)
{
	ListCell   *lc;
	List	   *lfdw_private = NIL;
	int			i = 0;

	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->node_num));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->nThreads));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->idx_url_tlist));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->agg_query));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->isFirst));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->groupby_has_spdurl));
	lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->is_pushdown_tlist));

	if (fdw_private->agg_query)
	{
		lfdw_private = lappend(lfdw_private, fdw_private->groupby_target);
		lfdw_private = lappend(lfdw_private, fdw_private->pPseudoAggList);
		lfdw_private = lappend(lfdw_private, fdw_private->child_comp_tlist);
		lfdw_private = lappend(lfdw_private, fdw_private->child_tlist);

		/* Save length of mapping tlist */
		lfdw_private = lappend(lfdw_private, makeInteger(list_length(fdw_private->mapping_tlist)));

		foreach(lc, fdw_private->mapping_tlist)
		{
			Extractcells	*extcells = (Extractcells *) lfirst(lc);
			ListCell		*tmplc;

			/* Save length of extracted list */
			lfdw_private = lappend(lfdw_private, makeInteger(list_length(extcells->cells)));

			foreach(tmplc, extcells->cells)
			{
				Mappingcells *cells = lfirst(tmplc);

				lfdw_private = lappend(lfdw_private, makeInteger(cells->mapping[0]));
				lfdw_private = lappend(lfdw_private, makeInteger(cells->mapping[1]));
				lfdw_private = lappend(lfdw_private, makeInteger(cells->mapping[2]));
				lfdw_private = lappend(lfdw_private, makeInteger(cells->aggtype));
				lfdw_private = lappend(lfdw_private, makeString(cells->agg_command ? cells->agg_command->data : ""));
				lfdw_private = lappend(lfdw_private, makeString(cells->agg_const ? cells->agg_const->data : ""));
				lfdw_private = lappend(lfdw_private, makeInteger(cells->original_attnum));
			}
			lfdw_private = lappend(lfdw_private, extcells->expr);
			lfdw_private = lappend(lfdw_private, makeInteger(extcells->ext_num));
			lfdw_private = lappend(lfdw_private, makeInteger((extcells->is_truncated)?1:0));
			lfdw_private = lappend(lfdw_private, makeInteger((extcells->is_having_qual)?1:0));
		}
		lfdw_private = lappend(lfdw_private, makeString(fdw_private->groupby_string ? fdw_private->groupby_string->data : ""));
		lfdw_private = lappend(lfdw_private, makeInteger((fdw_private->has_having_quals)?1:0));
	}

	for (i = 0; i < fdw_private->node_num; i++)
	{
		fdw_private->childinfo[i].can_pushdown_agg = fdw_private->childinfo[i].aggpath ? false : true;
		lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->childinfo[i].can_pushdown_agg));

		lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->childinfo[i].child_node_status));
		lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->childinfo[i].server_oid));
		lfdw_private = lappend(lfdw_private, makeInteger(fdw_private->childinfo[i].oid));

		/* Plan */
		lfdw_private = lappend(lfdw_private, copyObject(fdw_private->childinfo[i].plan));

		/* Agg plan */
		if (list_member_oid(fdw_private->pPseudoAggList, fdw_private->childinfo[i].server_oid))
			lfdw_private = lappend(lfdw_private, copyObject(fdw_private->childinfo[i].pAgg));

		/* Root */
		lfdw_private = lappend(lfdw_private, copyObject(fdw_private->childinfo[i].root->parse));

	}

	return lfdw_private;
}

/*
 * spd_DeserializeSpdFdwPrivate
 *
 * De-serialize a list to as fdw_private.
 * Each element of list in serialize and deserialize functions should be the same order.
 *
 * @param[in] serialized list
 * @return SpdFdwPrivate* deserialized fdw_private
 */
static SpdFdwPrivate *
spd_DeserializeSpdFdwPrivate(List *lfdw_private)
{
	int			i = 0;
	int			j = 0;
	int			mapping_tlist_len = 0;
	ListCell   *lc = list_head(lfdw_private);
	SpdFdwPrivate *fdw_private = palloc0(sizeof(SpdFdwPrivate));

	fdw_private->node_num = intVal(lfirst(lc));
	lc = lnext(lfdw_private, lc);

	fdw_private->nThreads = intVal(lfirst(lc));
	lc = lnext(lfdw_private, lc);

	fdw_private->idx_url_tlist = intVal(lfirst(lc));
	lc = lnext(lfdw_private, lc);

	fdw_private->agg_query = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lfdw_private, lc);

	fdw_private->isFirst = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lfdw_private, lc);

	fdw_private->groupby_has_spdurl = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lfdw_private, lc);

	fdw_private->is_pushdown_tlist = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lfdw_private, lc);

	if (fdw_private->agg_query)
	{
		fdw_private->groupby_target = (List *) lfirst(lc);
		lc = lnext(lfdw_private, lc);

		fdw_private->pPseudoAggList = (List *) lfirst(lc);
		lc = lnext(lfdw_private, lc);

		fdw_private->child_comp_tlist = (List *) lfirst(lc);
		lc = lnext(lfdw_private, lc);

		fdw_private->child_tlist = (List *) lfirst(lc);
		lc = lnext(lfdw_private, lc);

		/* Get length of mapping_tlist */
		mapping_tlist_len = intVal(lfirst(lc));
		lc = lnext(lfdw_private, lc);

		fdw_private->mapping_tlist = NIL;
		for (i = 0; i < mapping_tlist_len; i++)
		{
			int 			ext_tlist_num = 0;
			Extractcells	*extcells = (Extractcells *) palloc0(sizeof(Extractcells));

			ext_tlist_num = intVal(lfirst(lc));
			lc = lnext(lfdw_private, lc);

			for (j = 0; j < ext_tlist_num; j++)
			{
				Mappingcells *cells = (Mappingcells *) palloc0(sizeof(Mappingcells));

				cells->mapping[0] = intVal(lfirst(lc));
				lc = lnext(lfdw_private, lc);
				cells->mapping[1] = intVal(lfirst(lc));
				lc = lnext(lfdw_private, lc);
				cells->mapping[2] = intVal(lfirst(lc));
				lc = lnext(lfdw_private, lc);
				cells->aggtype = intVal(lfirst(lc));
				lc = lnext(lfdw_private, lc);
				cells->agg_command = makeStringInfo();
				appendStringInfoString(cells->agg_command, strVal(lfirst(lc)));
				lc = lnext(lfdw_private, lc);
				cells->agg_const = makeStringInfo();
				appendStringInfoString(cells->agg_const, strVal(lfirst(lc)));
				lc = lnext(lfdw_private, lc);
				cells->original_attnum = intVal(lfirst(lc));
				lc = lnext(lfdw_private, lc);
				extcells->cells = lappend(extcells->cells, cells);
			}
			extcells->expr = lfirst(lc);
			lc = lnext(lfdw_private, lc);
			extcells->ext_num = intVal(lfirst(lc));
			lc = lnext(lfdw_private, lc);
			extcells->is_truncated = (intVal(lfirst(lc))?true:false);
			lc = lnext(lfdw_private, lc);
			extcells->is_having_qual = (intVal(lfirst(lc))?true:false);
			lc = lnext(lfdw_private, lc);
			fdw_private->mapping_tlist = lappend(fdw_private->mapping_tlist, extcells);
		}

		fdw_private->groupby_string = makeStringInfo();
		appendStringInfoString(fdw_private->groupby_string, strVal(lfirst(lc)));
		lc = lnext(lfdw_private, lc);

		fdw_private->has_having_quals =(intVal(lfirst(lc))?true:false);
		lc = lnext(lfdw_private, lc);
	}

	fdw_private->childinfo = (ChildInfo *) palloc0(sizeof(ChildInfo) * fdw_private->node_num);
	for (i = 0; i < fdw_private->node_num; i++)
	{
		fdw_private->childinfo[i].can_pushdown_agg = intVal(lfirst(lc));
		lc = lnext(lfdw_private, lc);

		fdw_private->childinfo[i].child_node_status = intVal(lfirst(lc));
		lc = lnext(lfdw_private, lc);

		fdw_private->childinfo[i].server_oid = intVal(lfirst(lc));
		lc = lnext(lfdw_private, lc);

		fdw_private->childinfo[i].oid = intVal(lfirst(lc));
		lc = lnext(lfdw_private, lc);

		/* Plan */
		fdw_private->childinfo[i].plan = (Plan *) lfirst(lc);
		lc = lnext(lfdw_private, lc);

		/* Agg plan */
		if (list_member_oid(fdw_private->pPseudoAggList, fdw_private->childinfo[i].server_oid))
		{
			fdw_private->childinfo[i].pAgg = (Agg *) lfirst(lc);
			lc = lnext(lfdw_private, lc);
		}

		/* Root */
		fdw_private->childinfo[i].root = (PlannerInfo *) palloc0(sizeof(PlannerInfo));
		fdw_private->childinfo[i].root->parse = (Query *) lfirst(lc);
		lc = lnext(lfdw_private, lc);
	}

	return fdw_private;
}

/**
 * extract_expr_walker
 * Use expression_tree_walker to alk through the expression,
 * return true if detect any node which is not Var or Const.
 *
 * @param[in] node - the expression
 * @param[in] param - context argument
 */
static bool
extract_expr_walker(Node *node, void *param)
{
	if (node == NULL)
		return false;

	if (!(IsA(node, Var)) && !(IsA(node, Const)))
		return true;

	return expression_tree_walker(node, extract_expr_walker, (void *) param);
}
/**
 * is_need_extract
 * Check if it is necessary to extract the expression.
 * When expression contains only const and var, no need to extract 
 * 
 * @param[in] node - the expression
 */
static bool
is_need_extract(Node *node)
{
	return expression_tree_walker(node, extract_expr_walker, NULL);
}

/**
 * init_mappingcell
 *
 * Initialize value for a mapping cell
 * @param[in,out] mapcells - the mapping cells that needs to be initialized
 */
static void
init_mappingcell(Mappingcells **mapcells)
{
	int i;

	*mapcells = (struct Mappingcells *) palloc0(sizeof(struct Mappingcells));

	/* Initialize mapcells */
	for (i = 0; i < MAX_SPLIT_NUM; i++)
	{
		/* these store 0-index, so initialize with -1 */
		(*mapcells)->mapping[i] = -1;
	}
	(*mapcells)->original_attnum = -1;
	(*mapcells)->agg_command = makeStringInfo();
	(*mapcells)->agg_const = makeStringInfo();
}

/**
 * add_node_to_list
 *
 * This function is used to add node to tlist, compress_tlist_tle and compress_tlist.
 * It also set data for mapcell.
 *
 * @param[in] expr - the expression
 * @param[in,out] tlist - flattened tlist
 * @param[in,out] mapcells - the mapping cell which is corresponding to the expr
 * @param[in,out] compress_tlist_tle - compressed child tlist with target entry
 * @param[in,out] compress_tlist - compressed child tlist without target entry
 * @param[in] sgref - sort group reference for target entry
 * @param[in] is_agg_ope - true if combination of aggregate function and operators
 * @param[in] allow_duplicate - allow or not allow a target can be duplicated in grouping target list
 */
static void
add_node_to_list(Expr *expr, List **tlist, Mappingcells **mapcells, List **compress_tlist_tle, List **compress_tlist, Index sgref, bool is_agg_ope, bool allow_duplicate)
{
	/* Non-agg group by target or non-split agg such as sum or count */
	TargetEntry	*tle_temp;
	TargetEntry	*tle;
	int			target_num = 0;
	int			next_resno = list_length(*tlist) + 1;
	int			next_resno_temp = list_length(*compress_tlist_tle) + 1;

	tle = spd_tlist_member(expr, *tlist, &target_num);
	/* original */
	if (allow_duplicate || !tle)
	{
		if (allow_duplicate)
			target_num = list_length(*tlist);

		/* When expression is a combination of operator and aggregate function,
		 * no need to add to tlist because the whole expression has been added in spd_add_to_flat_tlist
		 */
		if (is_agg_ope == false)
		{
			tle = makeTargetEntry(copyObject(expr),
								next_resno++,
								NULL,
								false);
			tle->ressortgroupref = sgref;
			*tlist = lappend(*tlist, tle);
		}
		else
			target_num = list_length(*tlist) - 1;
	}
	else if (tle)
	{
		target_num = list_length(*tlist) - 1;
	}
	(*mapcells)->aggtype = NON_AGG_FLAG;
	(*mapcells)->original_attnum = target_num;
	/* div tlist */
	tle_temp = spd_tlist_member(expr, *compress_tlist_tle, &target_num);
	if (allow_duplicate || !tle_temp)
	{
		tle_temp = makeTargetEntry(copyObject(expr),
									next_resno_temp++,
									NULL,
									false);
		tle_temp->ressortgroupref = sgref;
		*compress_tlist_tle = lappend(*compress_tlist_tle, tle_temp);
		*compress_tlist = lappend(*compress_tlist, expr);
	}
	else if (tle_temp)
	{
		/*
		 * if var was added inside extract_expr, ressortgroupref was not set.
		 * we need to set it at this place
		 */
		if (sgref > 0)
			tle_temp->ressortgroupref = sgref;
	}
	/* If allow duplicate, so need to change mapping to the last of compress_tlist */
	if (allow_duplicate)
	{
		(*mapcells)->mapping[0] = list_length(*compress_tlist) - 1;
	}
	else
	{
		(*mapcells)->mapping[0] = target_num;
	}
}

/**
 * set_split_agg_info
 * Set aggfnoid, aggtype, aggtranstype
 *
 * @param[in,out] tempAgg - temporary aggregate
 */
static void
set_split_agg_info(Aggref *tempAgg, Oid aggfnoid, Oid aggtype, Oid aggtranstype)
{
	tempAgg->aggfnoid = aggfnoid;
	tempAgg->aggtype = aggtype;
	tempAgg->aggtranstype = aggtranstype;
}
/**
 * set_split_op_info
 * Set aggfnoid, aggtype, aggtranstype
 *
 * @param[in,out] opexpr - temporary expression
 */
static void
set_split_op_info(OpExpr *opexpr, Oid opno, Oid opfuncid, Oid opresulttype)
{
	opexpr->opno = opno;
	opexpr->opfuncid = opfuncid;
	opexpr->opresulttype = opresulttype;
}
/**
 * set_split_numeric_info
 * Set information for splitted SUM(x) and SUM(x*x) when aggtype is NUMERICOID
 *
 * @param[in,out] tempAgg - temporary aggregate
 * @param[in,out] opexpr - temporary expression
 */
static void
set_split_numeric_info(Aggref *tempAgg, OpExpr *opexpr)
{
	Oid argoid = linitial_oid(tempAgg->aggargtypes);

	/*
	 * SUM will return bigint (INT8) for smallint (INT2) or int (INT4) arguments,
	 * numeric for bigint (INT8) arguments.
	 * For numeric type and bigint, aggtranstype is INTERNALOID.
	 * For int and smallint, aggtranstype is INT8OID.
	 * For x*x, the multiply operator will return the same type as input.
	 */
	switch (argoid)
	{
		case NUMERICOID:
		{
			set_split_agg_info(tempAgg, SUM_NUMERI_OID, NUMERICOID, INTERNALOID);
			if(opexpr)
				set_split_op_info(opexpr, OPEXPER_NUMERI_OID, OPEXPER_NUMERI_FUNCID, NUMERICOID);
			break;
		}
		case INT8OID:
		{
			set_split_agg_info(tempAgg, SUM_BIGINT_OID, NUMERICOID, INTERNALOID);
			if(opexpr)
				set_split_op_info(opexpr, OPEXPER_INT8_OID, OPEXPER_INT8_FUNCID, INT8OID);
			break;
		}
		case INT4OID:
		{
			set_split_agg_info(tempAgg, SUM_INT4_OID, INT8OID, INT8OID);
			if(opexpr)
				set_split_op_info(opexpr, OPEXPER_INT4_OID, OPEXPER_INT4_FUNCID, INT4OID);
			break;
		}
		case INT2OID:
		{
			set_split_agg_info(tempAgg, SUM_INT2_OID, INT8OID, INT8OID);
			if(opexpr)
				set_split_op_info(opexpr, OPEXPER_INT2_OID, OPEXPER_INT2_FUNCID, INT2OID);
			break;
		}
		default:
			Assert(false);
			break;
	}
}

/*
 * add_nodes_to_list
 *
 * This function is used to add multiple nodes to tlist, compress_tlist_tle and compress_tlist.
 * It also set data for mapcell.
 *
 * @param[in] expr - the original expression
 * @param[in] exprs - the expression list to add
 * @param[in,out] tlist - flattened tlist
 * @param[in,out] mapcells - the mapping cell which is corresponding to the expr
 * @param[in,out] compress_tlist_tle - compressed child tlist with target entry
 * @param[in,out] compress_tlist - compressed child tlist without target entry
 * @param[in] is_agg_ope - true if combination of aggregate function and operators
 * @param[in] allow_duplicate - allow or not allow a target can be duplicated in grouping target list
 */
static void
add_nodes_to_list(Expr *aggref, List *exprs, List **tlist, Mappingcells **mapcells, List **compress_tlist_tle, List **compress_tlist, bool is_agg_ope, bool allow_duplicate)
{
	/* Non-agg group by target or non-split agg such as sum or count */
	TargetEntry	*tle_temp;
	TargetEntry	*tle;
	int			target_num = 0;
	int			next_resno = list_length(*tlist) + 1;
	int			next_resno_temp = list_length(*compress_tlist_tle) + 1;
	ListCell	*lc;
	int         i = 0;

	tle = spd_tlist_member(aggref, *tlist, &target_num);
	/* original */
	if (allow_duplicate || !tle)
	{
		if (allow_duplicate)
			target_num = list_length(*tlist);

		/* When expression is a combination of operator and aggregate function,
		 * no need to add to tlist because the whole expression has been added in spd_add_to_flat_tlist
		 */
		if (is_agg_ope == false)
		{
			tle = makeTargetEntry(copyObject(aggref),
								  next_resno++,
								  NULL,
								  false);
			*tlist = lappend(*tlist, tle);
		}
		else
			target_num = list_length(*tlist) - 1;
	}
	else if (tle)
	{
		target_num = list_length(*tlist) - 1;
	}

	(*mapcells)->original_attnum = target_num;

	foreach(lc, exprs)
	{
		Expr *expr = (Expr *) lfirst(lc);
		
		tle_temp = spd_tlist_member(expr, *compress_tlist_tle, &target_num);
		if (allow_duplicate || !tle_temp)
		{
			tle_temp = makeTargetEntry(copyObject(expr),
									   next_resno_temp++,
									   NULL,
									   false);
			*compress_tlist_tle = lappend(*compress_tlist_tle, tle_temp);
			*compress_tlist = lappend(*compress_tlist, expr);
		}
		/* If allow duplicate, so need to change mapping to the last of compress_tlist */
		if (allow_duplicate)
		{
			(*mapcells)->mapping[i] = list_length(*compress_tlist) - 1;
		}
		else
		{
			(*mapcells)->mapping[i] = target_num;
		}
		i++;
	}
}

/**
 * extract_expr
 * Extract an expression.
 * 
 * @param[in] node - the expression
 * @param[in,out] extcells - the target mapping list
 * @param[in,out] tlist - flattened tlist
 * @param[in,out] compress_tlist_tle - compressed child tlist with target entry
 * @param[in,out] compress_tlist - compressed child tlist without target entry
 * @param[in] sgref - sort group reference for target entry
 * @param[in] is_agg_ope - true if combination of aggregate function and operators
 * 
 */
static void
extract_expr(Node *node, Extractcells **extcells, List **tlist, List **compress_tlist_tle, List **compress_tlist, int sgref, bool is_agg_ope)
{
	if (node == NULL)
		return;

	switch(nodeTag(node))
	{
		case T_OpExpr:
		case T_BoolExpr:
		{
			List		*args;
			bool		is_extract_expr;

			if (IsA(node, OpExpr))
				args = ((OpExpr *)node)->args;
			else
				args = ((BoolExpr *)node)->args;

			if ((*extcells)->is_having_qual)
				is_extract_expr = true;
			else
				is_extract_expr = is_need_extract(node);

			if (is_extract_expr)
				extract_expr((Node *)args, extcells, tlist, compress_tlist_tle, compress_tlist, sgref, is_agg_ope);
			else
			{
				/* When no need to extract, add the node to the compress_tlist and compress_tlist_tle directly */
				Mappingcells	*mapcells;
				
				init_mappingcell(&mapcells);
				add_node_to_list((Expr *) node, tlist, &mapcells, compress_tlist_tle, compress_tlist, sgref, false, false);
				(*extcells)->ext_num++;
				(*extcells)->cells = lappend((*extcells)->cells, mapcells);
			}
			break;
		}
		case T_List:
		{
			List		*l = (List *) node;
			ListCell	*lc;

			foreach(lc, l)
			{
				extract_expr((Node *)lfirst(lc), extcells, tlist, compress_tlist_tle, compress_tlist, sgref, is_agg_ope);
			}
			break;
		}
		case T_FuncExpr:
		{
			FuncExpr	*func = (FuncExpr *) node;

			if(func->args)
				extract_expr((Node *)func->args, extcells, tlist, compress_tlist_tle, compress_tlist, sgref, is_agg_ope);
			break;
		}
		case T_Aggref:
		case T_Var:
		{
			Aggref 			*aggref = (Aggref*) node;
			int 			target_num = 0;
			TargetEntry 	*tle;
			TargetEntry 	*tle_temp;
			int				next_resno = list_length(*tlist) + 1;
			int				next_resno_temp = list_length(*compress_tlist_tle) + 1;
			Mappingcells 	*mapcells;
			enum Aggtype    aggtype;

			/* Initialize mapcells */
			init_mappingcell(&mapcells);

			/* When aggref is avg, variance or stddev, split it */
			if (IsA(node, Aggref) && IS_SPLIT_AGG(aggref->aggfnoid))
			{
				/* Prepare COUNT Query */
				Aggref	   *tempCount = copyObject(aggref);
				Aggref	   *tempSum;
				Aggref	   *tempVar;

				tempVar = copyObject(aggref);
				tempSum = copyObject(aggref);

				if (aggref->aggtype == FLOAT4OID || aggref->aggtype == FLOAT8OID)
				{
					set_split_agg_info(tempSum, SUM_FLOAT8_OID, FLOAT8OID, FLOAT8OID);
				}
				else if (aggref->aggtype == NUMERICOID)
				{
					set_split_numeric_info(tempSum, NULL);
				}
				else
				{
					set_split_agg_info(tempSum, SUM_INT4_OID, INT8OID, INT8OID);
				}
				set_split_agg_info(tempCount, COUNT_OID, INT8OID, INT8OID);

				/* Prepare SUM Query */
				tempVar->aggfnoid = VAR_OID;

				/* add original mapping list to avg,var,stddev */
				if (!spd_tlist_member((Expr*) aggref, *tlist, &target_num))
				{
					if (is_agg_ope == false)
					{
						tle = makeTargetEntry(copyObject((Expr*) aggref),
											next_resno++,
											NULL,
											false);
						*tlist = lappend(*tlist, tle);
						mapcells->original_attnum = target_num;
					}
					else
						mapcells->original_attnum = list_length(*tlist) - 1;
				}
				else
					mapcells->original_attnum = list_length(*tlist) - 1;

				/* set avg flag */
				if (aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID)
					mapcells->aggtype = AVG_FLAG;
				else if (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
					mapcells->aggtype = VAR_FLAG;
				else if (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)
					mapcells->aggtype = DEV_FLAG;

				spd_spi_exec_proname(aggref->aggfnoid, mapcells->agg_command);

				/* count */
				if (!spd_tlist_member((Expr *) tempCount, *compress_tlist_tle, &target_num))
				{
					tle_temp = makeTargetEntry((Expr *) tempCount,
											next_resno_temp++,
											NULL,
											false);
					*compress_tlist_tle = lappend(*compress_tlist_tle, tle_temp);
					*compress_tlist = lappend(*compress_tlist, tempCount);
				}
				mapcells->mapping[0] = target_num;
				/* sum */
				if (!spd_tlist_member((Expr *) tempSum, *compress_tlist_tle, &target_num))
				{
					tle_temp = makeTargetEntry((Expr *) tempSum,
											next_resno_temp++,
											NULL,
											false);
					*compress_tlist_tle = lappend(*compress_tlist_tle, tle_temp);
					*compress_tlist = lappend(*compress_tlist, tempSum);
				}
				mapcells->mapping[1] = target_num;
				(*extcells)->ext_num = (*extcells)->ext_num + 2;
				/* variance(SUM(x*x)) */
				if ((aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
					|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
				{
					TargetEntry *tarexpr;
					TargetEntry *oparg = (TargetEntry *) linitial(tempVar->args);
					Var		   *opvar = (Var *) oparg->expr;
					OpExpr	   *opexpr = (OpExpr *) makeNode(OpExpr);
					OpExpr	   *opexpr2 = copyObject(opexpr);

					opexpr->xpr.type = T_OpExpr;
					opexpr->opretset = false;
					opexpr->opcollid = 0;
					opexpr->inputcollid = 0;
					opexpr->location = 0;
					opexpr->args = NULL;

					/* Create top targetentry */
					if (tempVar->aggtype == NUMERICOID)
					{
						set_split_numeric_info(tempVar, opexpr);
					}
					else
					{
						set_split_agg_info(tempVar, SUM_FLOAT8_OID, FLOAT8OID, FLOAT8OID);
						set_split_op_info(opexpr, FLOAT8MUL_OID, FLOAT8MUL_FUNID, FLOAT8OID);
					}
					opexpr->args = lappend(opexpr->args, opvar);
					opexpr->args = lappend(opexpr->args, opvar);
					/* Create var targetentry */
					tarexpr = makeTargetEntry((Expr *) opexpr,
											next_resno_temp,
											NULL,
											false);
					tarexpr->ressortgroupref = oparg->ressortgroupref;
					opexpr2 = (OpExpr *) tarexpr->expr;
					opexpr2->opretset = false;
					opexpr2->opcollid = 0;
					opexpr2->inputcollid = 0;
					opexpr2->location = 0;
					tarexpr->resno = 1;
					tempVar->args = lappend(tempVar->args, tarexpr);
					tempVar->args = list_delete_first(tempVar->args);
					if (!spd_tlist_member((Expr *) tempVar, *compress_tlist_tle, &target_num))
					{
						tle_temp = makeTargetEntry((Expr *) tempVar,
												next_resno_temp++,
												NULL,
												false);
						*compress_tlist_tle = lappend(*compress_tlist_tle, tle_temp);
						*compress_tlist = lappend(*compress_tlist, tle_temp);
					}
					mapcells->mapping[2] = target_num;
					(*extcells)->ext_num++;
				}
			}
			else if (IsA(node, Aggref) && is_catalog_split_agg(aggref->aggfnoid, &aggtype))
			{
				List   *exprs = NULL;

				exprs = spd_catalog_makedivtlist(aggref, exprs, aggtype);
				if (exprs != NULL)
				{
					add_nodes_to_list((Expr *) node, exprs, tlist, &mapcells, compress_tlist_tle, compress_tlist, is_agg_ope, false);
					mapcells->aggtype = aggtype;
					appendStringInfoString(mapcells->agg_command, CatalogSplitAggStr[aggtype]);
					(*extcells)->ext_num += list_length(exprs);
				}
			}
			else
			{
				/* append original target list */
				if (IsA(node, Aggref))
				{
					mapcells->aggtype = NON_SPLIT_AGG_FLAG;
					spd_spi_exec_proname(aggref->aggfnoid, mapcells->agg_command);

					/*
					 * If aggregate functions is string_agg(expression, delimiter)
					 * check the delimiter exist or not, if exist save the delimiter
					 * to mapcells->agg_const.
					 */
					if (!pg_strcasecmp(mapcells->agg_command->data, "STRING_AGG"))
					{
						ListCell   *arg;
						/* Check all the arguments */
						foreach(arg, aggref->args)
						{
							TargetEntry *tle = (TargetEntry *) lfirst(arg);
							Node	   *node = (Node *) tle->expr;

							switch (nodeTag(node))
							{
								case T_Const:
									{
										Const *const_tmp = (Const *) node;

										if (const_tmp->constisnull)
										{
											continue;
										}

										spd_deparse_const(const_tmp, mapcells->agg_const, -1);
									}
									break;
								default:
									break;
							}
						}
					}
				}
				else
					mapcells->aggtype = NON_AGG_FLAG;
				
				add_node_to_list((Expr *) node, tlist, &mapcells, compress_tlist_tle, compress_tlist, sgref, is_agg_ope, false);
				(*extcells)->ext_num++;
			}
			(*extcells)->cells = lappend((*extcells)->cells, mapcells);
			break;
		}
		default:
			break;
	}
}

/**
 * spd_add_to_flat_tlist
 *
 * Modified version of add_to_flat_tlist.
 * Add more items to a flattened tlist (if they're not already in it).
 * Split-agg is divided into multiple aggref. For example, if 'expr' is avg,
 * then count and sum is added to 'compress_tlist_tle' and 'compress_tlist'.
 * 'compress_tlist_tle' and 'compress_tlist' are almost the same except for target entry.
 *
 * Example of mapping_tlist by print_mapping_tlist():

 * postgres=# explain verbose SELECT sum(i),t, avg(i), sum(i)  FROM t1 GROUP BY t;
 * DEBUG:  mapping_tlist (0 -1 -1)/ original_attnum=0  aggtype="NON-SPLIT"
 * DEBUG:  mapping_tlist (1 -1 -1)/ original_attnum=1 aggtype="NON-AGG"
 * DEBUG:  mapping_tlist (2 0 -1)/ original_attnum=2  aggtype="AVG"
 * DEBUG:  mapping_tlist (0 -1 -1)/ original_attnum=0 aggtype="NON-SPLIT"
 *                               QUERY PLAN
 * ----------------------------------------------------------------------
 * Foreign Scan
 *   Output: (sum(i)), t, (avg(i)), (sum(i))
 *      Remote SQL: SELECT sum(i), t, count(i) FROM public.t1 GROUP BY 2
 *
 * As Remote SQL shows, compress_tlist is sum(i), t, count(i).
 * mapping_tlist (2 0 -1) of avg() means count is mapped to 2nd of compress_tlist
 * and sum is mapped to 0th of compress_tlist.
 *
 * @param[in,out] tlist - flattened tlist
 * @param[in] expr - expression(usually, but not necessarily, Vars)
 * @param[out] mapping_tlist - target mapping list for child node
 * @param[out] compress_tlist_tle - compressed child tlist with target entry
 * @param[in] sgref - sort group reference for target entry
 * @param[out] compress_tlist - compressed child tlist without target entry
 * @param[in] allow_duplicate - allow or not allow a target can be duplicated in grouping target list
 */

static List *
spd_add_to_flat_tlist(List *tlist, Expr *expr, List **mapping_tlist,
					  List **compress_tlist_tle, Index sgref,
					  List **compress_tlist, bool allow_duplicate,
					  bool is_having_qual)
{
	int			next_resno = list_length(tlist) + 1;
	int			target_num = 0;
	TargetEntry *tle;
	Extractcells* extcells = (struct Extractcells *) palloc0(sizeof(struct Extractcells)); 

	extcells->cells = NIL;
	extcells->expr = copyObject(expr);
	extcells->is_truncated = false;
	extcells->is_having_qual = is_having_qual;
	if(IsA(expr, OpExpr) || IsA(expr, BoolExpr))
	{
		/* add original mapping list */
		if (!spd_tlist_member(expr, tlist, &target_num) && !is_having_qual)
		{
			tle = makeTargetEntry(copyObject(expr),
								  next_resno++,
								  NULL,
								  false);
			tlist = lappend(tlist, tle);

		}
		extract_expr((Node *) expr, &extcells, &tlist, compress_tlist_tle, compress_tlist, sgref, true);
	}
	else if (IsA(expr, Aggref))
	{
		extract_expr((Node *) expr, &extcells, &tlist, compress_tlist_tle, compress_tlist, sgref, false);
	}
	else
	{
		Mappingcells *mapcells;

		init_mappingcell(&mapcells);
		add_node_to_list(expr, &tlist, &mapcells, compress_tlist_tle, compress_tlist, sgref, false, allow_duplicate);

		extcells->cells = lappend(extcells->cells, mapcells);
	}
	*mapping_tlist = lappend(*mapping_tlist, extcells);
	return tlist;
}


/*
 * spd_spi_exec_xxx is used by main thread.
 * main thread create child table foreign plan.
 * Child table name format is "ParentTableName__NodeName__sequenceNum",
 * Main thread can get some child table information using ParentTableName only.
 *
 * SPI_exec is used by main thread,  it is not need for lock.
 *
 * 1. spd_spi_exec_datasouce_num() - get child table nums and oids from foreigntableid
 * 2. spd_spi_exec_datasource_oid() - Get parent node oid from child node oid.
 * 3. spd_spi_exec_datasource_name() - Get child table's foreign server name from foreign table id(child table oid)
 * 4. spd_spi_exec_child_relname() - Get child Table oid's using parentTableName
 */

/**
 * Get a list of child nodes oid and the number of child using parent node oid.
 *
 * @param[in] foreigntableid
 * @param[out] nums
 * @param[out] oid
 */
static void
spd_spi_exec_datasouce_num(Oid foreigntableid, int *nums, Oid **oid)
{
	char		query[QUERY_LENGTH];
	int			ret;
	int			i;
	int			spi_temp;
	MemoryContext oldcontext;
	MemoryContext spicontext;

	oldcontext = CurrentMemoryContext;
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/*
	 * child table name is "ParentTableName_NodeName_sequenceNum". This SQL
	 * searches child tables whose name is like "ParentTableName_...".
	 * Foreigntableid is parent table oid.
	 *
	 * Remove a name like "<tablename>_<columnname>_seq", because this is a variable name is generated as relname
	 * if using function pg_catalog.setval, for example, pg_catalog.setval('<table>_<column>_seq', 10, false).
	 * This is not table name even postgres display it as relname.
	 */
	sprintf(query, "SELECT oid,relname FROM pg_class WHERE (relname LIKE (SELECT relname FROM pg_class WHERE oid = %d)||"
			"'\\_\\_%%') AND (relname NOT LIKE '%%\\_%%\\_seq') ORDER BY relname;", foreigntableid);

	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
	{
		SPI_finish();
		elog(ERROR, "spi exec is failed. sql is %s", query);
	}
	spi_temp = SPI_processed;
	spicontext = MemoryContextSwitchTo(oldcontext);
	*oid = (Oid *) palloc0(sizeof(Oid) * spi_temp);
	MemoryContextSwitchTo(spicontext);
	if (SPI_processed == 0)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute can not find datasource");
	}
	for (i = 0; i < SPI_processed; i++)
	{
		bool		isnull;

		oid[0][i] = DatumGetObjectId(SPI_getbinval(SPI_tuptable->vals[i], SPI_tuptable->tupdesc, 1, &isnull));
	}
	*nums = SPI_processed;
	SPI_finish();
}

/**
 * Get parent node oid using child node oid.
 *
 * @param[in] Child node's foreigntableid
 *
 * @return Parent node's foreigntableid
 */
static Oid
spd_spi_exec_datasource_oid(Oid foreigntableid)
{
	char		query[QUERY_LENGTH];
	int			ret;
	bool		isnull;
	Oid			oid = 0;

	/*
	 * child table name is "ParentTableName_NodeName_sequenceNum". This SQL
	 * search child tables which name is "ParentTableName_xxx".
	 */
	sprintf(query, "SELECT oid,srvname FROM pg_foreign_server WHERE srvname=(SELECT foreign_server_name FROM information_schema._pg_foreign_tables WHERE foreign_table_name = (SELECT relname FROM pg_class WHERE oid = %d)) ORDER BY srvname;", (int) foreigntableid);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute failure -returned - %d", ret);
	}
	if (SPI_processed != 1)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute can not find datasource");
	}
	oid = DatumGetObjectId(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &isnull));
	SPI_finish();
	return oid;
}

/**
 * Get child node foreign server name
 *
 * @param[in] foreigntableid - child foreigntableid
 * @param[out] srvname - child foreign server name
 *
 * @return none
 */

static void
spd_spi_exec_datasource_name(Oid foreigntableid, char *srvname)
{
	char		query[QUERY_LENGTH];
	char	   *temp;
	int			ret;

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/* get child server name from child's foreign table id */
	sprintf(query, "SELECT foreign_server_name FROM information_schema._pg_foreign_tables WHERE foreign_table_name = (SELECT relname FROM pg_class WHERE oid = %d) ORDER BY foreign_server_name;", (int) foreigntableid);


	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
		elog(ERROR, "error %d", ret);
	if (SPI_processed != 1)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute can not find datasource");
	}
	temp = SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1);

	strcpy(srvname, temp);
	SPI_finish();
	return;
}

/**
 * Get child Table oid's using parentTableName
 *
 * @param[in] parentTableName - child foreigntableid
 * @param[in] fdw_private - child table plan information
 * @param[out] oid - child table oids
 *
 * @return none
 */

static void
spd_spi_exec_child_relname(char *parentTableName, SpdFdwPrivate * fdw_private, Oid **oid)
{
	char		query[QUERY_LENGTH];
	char	   *entry = NULL;
	int			i;
	int			ret;
	MemoryContext oldcontext = CurrentMemoryContext;

	/* get child server name from child's foreign table id */
	if (fdw_private->in_flag == 0)
	{
		sprintf(query, "SELECT oid from pg_class WHERE relname LIKE \
                '%s\\_\\_\%%' ORDER BY relname;", parentTableName);
	}
	else
	{
		/* if IN clause is used, then return IN child tables only, */
		sprintf(query, "SELECT oid from pg_class WHERE relname LIKE \
                '%s\\_\\_%s\\_\\_\%%' ORDER BY relname;", parentTableName, entry);
	}
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute failure - returned - %d", ret);
	}
	if (SPI_processed < 1)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute failure child table not found");
	}
	*oid = MemoryContextAlloc(oldcontext, sizeof(Oid) * SPI_processed);
	for (i = 0; i < SPI_processed; i++)
	{
		bool		isnull;

		(*oid)[i] = DatumGetObjectId(SPI_getbinval(SPI_tuptable->vals[i],
												   SPI_tuptable->tupdesc,
												   1,
												   &isnull));
	}
	fdw_private->node_num = SPI_processed;
	SPI_finish();
}

/**
 * spd_spi_exec_child_ip
 *
 * Get child node ip from child server name using pg_spd_node_info
 *
 * @param[in] serverName - server name of child
 * @param[out] ip - ip address
 */
static void
spd_spi_exec_child_ip(char *serverName, char *ip)
{
	char		sql[NAMEDATALEN * 2] = {};
	char	   *ipstr;
	int			rtn;

	sprintf(sql, "SELECT ip FROM pg_spd_node_info WHERE servername = '%s';", serverName);
	SPI_connect();
	PG_TRY();
	{
		rtn = SPI_execute(sql, false, 0);
	}
	PG_CATCH();
	{
		SPI_finish();
		return;
	}
	PG_END_TRY();
	/* Searching server ip from __spd_node_info */
	if (rtn != SPI_OK_SELECT || SPI_processed != 1)
	{
		SPI_finish();
		return;
	}
	ipstr = SPI_getvalue(SPI_tuptable->vals[0],
						 SPI_tuptable->tupdesc,
						 1);
	strcpy(ip, ipstr);
	SPI_finish();
	return;
}

/**
 * spd_aliveError
 *
 * Emit error with server name information.
 *
 * @param[in] fs
 */
static void
spd_aliveError(ForeignServer *fs)
{
	elog(ERROR, "PGSpider can not get data from child node : %s", fs->servername);
}

/**
 * spd_ErrorCb
 *
 * Error callback for child thread.
 *
 * @param[in] arg
 */
static void
spd_ErrorCb(void *arg)
{
	if (throwErrorIfDead)
	{
		pthread_mutex_lock(&error_mutex);
		EmitErrorReport();
		pthread_mutex_unlock(&error_mutex);
	}
}

/**
 * spd_ForeignScan_thread
 *
 * Child threads execute this routine, NOT main thread.
 * spd_ForeignScan_thread execute the following operations for each child threads.
 *
 * Child threads execute BeginForeignScan, IterateForeignScan, EndForeignScan
 * of child fdws in this routine.
 *
 * @param[in] ForeignScanThreadInfo arg
 *
 */
static void *
spd_ForeignScan_thread(void *arg)
{
	ForeignScanThreadInfo *fssthrdInfo = (ForeignScanThreadInfo *) arg;
	MemoryContext tuplectx[2];
	int			tuple_cnt = 0;

	ErrorContextCallback errcallback;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) fssthrdInfo->private;
	PlanState  *result = NULL;
	/* Flag use for check whether mysql_fdw called BeginForeignScan or not */
	bool		is_first = true;

#ifdef GETPROGRESS_ENABLED
	PGcancel   *cancel;
	char		errbuf[BUFFERSIZE];
#endif
#ifdef MEASURE_TIME
	struct timeval s,
				e,
				e1;

	gettimeofday(&s, NULL);
#endif

	CurrentResourceOwner = fssthrdInfo->thrd_ResourceOwner;
	TopMemoryContext = fssthrdInfo->threadTopMemoryContext;

	MemoryContextSwitchTo(fssthrdInfo->threadMemoryContext);
	
	/* Init ErrorContext for each child thread */
	ErrorContext = AllocSetContextCreate(fssthrdInfo->threadMemoryContext,
										"Thread ErrorContext",
										ALLOCSET_DEFAULT_SIZES);
	MemoryContextAllowInCriticalSection(ErrorContext, true);

	tuplectx[0] = AllocSetContextCreate(fssthrdInfo->threadMemoryContext,
										"thread tuple contxt1",
										ALLOCSET_DEFAULT_SIZES);
	tuplectx[1] = AllocSetContextCreate(fssthrdInfo->threadMemoryContext,
										"thread tuple contxt2",
										ALLOCSET_DEFAULT_SIZES);

	/* Declare ereport/elog jump is not available. */
	PG_exception_stack = NULL;
	errcallback.callback = spd_ErrorCb;
	errcallback.arg = NULL;
	errcallback.previous = NULL;
	error_context_stack = &errcallback;

	/* Begin Foreign Scan */
	fssthrdInfo->state = SPD_FS_STATE_BEGIN;
	PG_TRY();
	{
		SPD_READ_LOCK_TRY(&fdw_private->scan_mutex);

		/*
		 * If Aggregation does not push down, then BeginForeignScan execute in
		 * ExecInitNode
		 */
		if (!list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
		{
			if (strcmp(fssthrdInfo->fdw->fdwname, POSTGRES_FDW_NAME) == 0 && !isPostgresFdwInit)
			{
				/* We need to make postgres_fdw_options variable initial one time */
				SPD_LOCK_TRY(&postgres_fdw_mutex);
				fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
														  fssthrdInfo->eflags);
				isPostgresFdwInit = true;
				SPD_UNLOCK_CATCH(&postgres_fdw_mutex);
			}
			else if (strcmp(fssthrdInfo->fdw->fdwname, MYSQL_FDW_NAME) == 0)
			{
				/*
				 * In case child node is mysql_fdw, the main query need to wait
				 * sub-query finished before call BeginForeignScan.
				 * If main query: requestStartScan flag is true.
				 * If sub query: requestStartScan flag is false.
				 * In case subquery, we will call BeginForeignScan immediately.
				 * In case main query, we will wait subquery finished before call BeginForeignScan.
				 */
				if(is_first && fssthrdInfo->requestStartScan)
				{
					is_first = false;
					fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
															fssthrdInfo->eflags);
				}
			}
			else
			{
				fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
														  fssthrdInfo->eflags);
			}
		}
		SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);

#ifdef MEASURE_TIME
		gettimeofday(&e, NULL);
		elog(DEBUG1, "thread%d begin foreign scan time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	}
	PG_CATCH();
	{
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
	}
	PG_END_TRY();
	if (fssthrdInfo->state == SPD_FS_STATE_ERROR)
	{
		goto THREAD_EXIT;
	}
RESCAN:

	/*
	 * Do rescan after return .. If Rescan is queried before iteration, just
	 * continue operation
	 *
	 * Rescan is executed about join, union and some operation. If Rescan need
	 * to in operation, then fssthrdInfo->requestRescan flag is TRUE. But
	 * first time rescan is not need.(fssthrdInfo->state = SPD_FS_STATE_BEGIN)
	 * Then skip to rescan sequence.
	 */
	if (fssthrdInfo->requestRescan &&
		fssthrdInfo->state != SPD_FS_STATE_BEGIN)
	{
		SPD_READ_LOCK_TRY(&fdw_private->scan_mutex);
		fssthrdInfo->fdwroutine->ReScanForeignScan(fssthrdInfo->fsstate);
		SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);

		fssthrdInfo->requestRescan = false;
		fssthrdInfo->state = SPD_FS_STATE_BEGIN;
	}

	/*
	 * requestStartScan is used in case a query has parameter.
	 *
	 * Main query and sub query is executed in two thread parallel.
	 * For main query, it need to wait for sub-plan is initialized by the core engine.
	 * After sub-plan is initialized, the core engine start Portal Run and call spd_IterateForeignScan.
	 * requestStartScan will be enabled in this routine.
	 *
	 * During wait to start scan, if it receives request to re-scan, go back to RESCAN
	 * If it receives request to end scan if error occurs, exit the transaction.
	 */
	while (!fssthrdInfo->requestStartScan &&
			fssthrdInfo->state == SPD_FS_STATE_BEGIN)
	{
		usleep(1);
		if (fssthrdInfo->requestEndScan)
		{
			goto THREAD_END;
		}
		if (fssthrdInfo->requestRescan)
		{
			fssthrdInfo->state = SPD_FS_STATE_ITERATE;
			goto RESCAN;
		}
	}

	/*
	 * In case child node is mysql_fdw, the main query need to wait
	 * sub-query finished before call BeginForeignScan.
	 * If main query: requestStartScan flag is true.
	 * If sub query: requestStartScan flag is false.
	 * In case subquery, we will call BeginForeignScan immediately.
	 * In case main query, we will wait subquery finished before call BeginForeignScan.
	 */
	if (!list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
	{
		if (strcmp(fssthrdInfo->fdw->fdwname, MYSQL_FDW_NAME) == 0 &&
					is_first && fssthrdInfo->requestStartScan)
		{
			is_first = false;
			fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
														fssthrdInfo->eflags);
		}
	}

	/* In case re-scan, the main query needs to repeat waiting */
	fssthrdInfo->requestStartScan = false;

	fssthrdInfo->state = SPD_FS_STATE_ITERATE;

	if (list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
	{
		SPD_WRITE_LOCK_TRY(&fdw_private->scan_mutex);
		fssthrdInfo->fsstate->ss.ps.state->es_param_exec_vals = fssthrdInfo->fsstate->ss.ps.ps_ExprContext->ecxt_param_exec_vals;
		if (strcmp(fssthrdInfo->fdw->fdwname, POSTGRES_FDW_NAME) == 0 && !isPostgresFdwInit)
		{
			/* We need to make postgres_fdw_options variable initial one time */
			SPD_LOCK_TRY(&postgres_fdw_mutex);
			result = ExecInitNode((Plan *) fdw_private->childinfo[fssthrdInfo->childInfoIndex].pAgg, fssthrdInfo->fsstate->ss.ps.state, 0);
			isPostgresFdwInit = true;
			SPD_UNLOCK_CATCH(&postgres_fdw_mutex);
		} else
		{
			result = ExecInitNode((Plan *) fdw_private->childinfo[fssthrdInfo->childInfoIndex].pAgg, fssthrdInfo->fsstate->ss.ps.state, 0);
		}
		SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);
	}
	PG_TRY();
	{
		while (1)
		{
			bool		success;
			bool		deepcopy;
			TupleTableSlot *slot;

			/* when get result request recieved ,then break */
#ifdef GETPROGRESS_ENABLED
			if (getResultFlag)
			{
				spd_queue_notify_finish(&fssthrdInfo->tupleQueue);
				break;
			}
#endif


			/*
			 * Call child fdw iterateForeignScan using two memory contexts
			 * alternately. We switch contexts and reset old one every
			 * SPD_TUPLE_QUEUE_LEN tuples to minimize memory usage. This
			 * number guareantee tuples allocated by these contexts are alive
			 * until parent thread finishes processing and we can skip
			 * deepcopy when passing to parent thread. We could use query
			 * memory context and make parent thread free tuples, but it's
			 * slower than current code.
			 */

			/*----------
    		 * Example:
    		 * +----------------+-------+-------+-------+
		     * | memory context | slot0 | slot1 | slot2 |
		     * +----------------+-------+-------+-------+
		     * | tuplectx[0]    |     0 |     1 |     2 |
		     * | tuplectx[1]    |     3 |     4 |     5 |
		     * | tuplectx[0]    |     6 |     7 |     8 |
		     * | ...            |   ... |   ... |   ... |
		     *----------
		     */

			/*
			 * Above tables represent cases where queue length is 3. Tuple
			 * 0,1,2 (tuples generated when tuple_cnt is 0,1,2) are allocated
			 * by tuplectx[0]. Tuple 3,4,5 are allocated by tuplectx[1] and so
			 * on. When child thread succeeded in adding tuple 5, which use
			 * the same slot as tuple 2, parent thread finishes using tuple 2.
			 * So it's safe to reset tuplectx[0] before adding tuple 6.
			 */

			int			len = SPD_TUPLE_QUEUE_LEN;
			int			ctx_idx = (tuple_cnt / len) % 2;

			if (tuple_cnt % len == 0)
			{
				MemoryContextReset(tuplectx[ctx_idx]);
				MemoryContextSwitchTo(tuplectx[ctx_idx]);
			}
			if (list_member_oid(fdw_private->pPseudoAggList,
								fssthrdInfo->serverId))
			{
				/*
				 * Retreives aggregated value tuple from inlying non pushdown
				 * source
				 */
				SPD_READ_LOCK_TRY(&fdw_private->scan_mutex);
				slot = SPI_execAgg((AggState *) result);
				SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);

				/*
				 * need deep copy when adding slot to queue because
				 * CurrentMemoryContext do not affect SPI_execAgg, and hence
				 * tuples are not allocated by tuplectx[ctx_idx]
				 */
				deepcopy = true;
			}
			else
			{
				SPD_READ_LOCK_TRY(&fdw_private->scan_mutex);
				/*
				 * Make child node use per-tuple memory context created by pgspider_core_fdw
				 * instead of using per-tuple memory context from core backend.
				 */
				fssthrdInfo->fsstate->ss.ps.ps_ExprContext->ecxt_per_tuple_memory = tuplectx[ctx_idx];
				slot = fssthrdInfo->fdwroutine->IterateForeignScan(fssthrdInfo->fsstate);
				SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);

				deepcopy = true;

				/*
				 * Deep copy can be skipped if that fdw allocate tuples in
				 * CurrentMemoryContext. postgres_fdw needs deep copy because
				 * it creates new contexts and allocate tuples on it, which
				 * may be shorter life than above tuplectx[ctx_idx].
				 */
				if (spd_can_skip_deepcopy(fssthrdInfo->fdw->fdwname))
					deepcopy = false;


			}

			if (TupIsNull(slot))
			{
				spd_queue_notify_finish(&fssthrdInfo->tupleQueue);
				break;
			}
			while (1)
			{

				success = spd_queue_add(&fssthrdInfo->tupleQueue, slot, deepcopy);
				if (success)
					break;
				/* If rescan or endscan is requested, break immediately */
				if (fssthrdInfo->requestRescan || fssthrdInfo->requestEndScan)
					break;

				/*
				 * TODO: Now that queue is introduced, using usleep(1) or
				 * condition variable may be better than pthread_yield for
				 * reducing cpu usage
				 */
				pthread_yield();
			}
			tuple_cnt++;
			if (fssthrdInfo->requestRescan || fssthrdInfo->requestEndScan)
				break;

			/* when get result request recieved */
#ifdef GETPROGRESS_ENABLED
			if (!slot->tts_isempty && getResultFlag)
			{
				spd_queue_notify_finish(&fssthrdInfo->tupleQueue);
				cancel = PQgetCancel((PGconn *) fssthrdInfo->fsstate->conn);
				if (!PQcancel(cancel, errbuf, BUFFERSIZE))
					elog(WARNING, " Failed to PQgetCancel");
				PQfreeCancel(cancel);
				break;
			}
#endif

		}
	}
	PG_CATCH();
	{
		fssthrdInfo->state = SPD_FS_STATE_ERROR;


#ifdef GETPROGRESS_ENABLED
		if (fssthrdInfo->fsstate->conn)
		{
			cancel = PQgetCancel((PGconn *) fssthrdInfo->fsstate->conn);
			if (!PQcancel(cancel, errbuf, BUFFERSIZE))
				elog(WARNING, " Failed to PQgetCancel");
			PQfreeCancel(cancel);
		}
#endif
		elog(DEBUG1, "Thread error occurred during IterateForeignScan(). %s:%d",
			 __FILE__, __LINE__);
	}
	PG_END_TRY();


#ifdef MEASURE_TIME
	gettimeofday(&e1, NULL);
	elog(DEBUG1, "thread%d end ite time = %lf", fssthrdInfo->serverId, (e1.tv_sec - e.tv_sec) + (e1.tv_usec - e.tv_usec) * 1.0E-6);
#endif

	if (fssthrdInfo->state == SPD_FS_STATE_ERROR)
		goto THREAD_EXIT;

THREAD_END:
	PG_TRY();
	{
		while (1)
		{
			if (fssthrdInfo->requestEndScan)
			{
				/* End of the ForeignScan */
				fssthrdInfo->state = SPD_FS_STATE_END;
				SPD_READ_LOCK_TRY(&fdw_private->scan_mutex);
				if (!list_member_oid(fdw_private->pPseudoAggList,
									 fssthrdInfo->serverId))
				{
					fssthrdInfo->fdwroutine->EndForeignScan(fssthrdInfo->fsstate);
				}
				else
				{
					ExecEndNode(result);
				}


				SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);
				fssthrdInfo->requestEndScan = false;
				break;
			}
			else if (fssthrdInfo->requestRescan)
			{

				/*
				 * Initialize queue. In LIMIT query, queue may have remaining
				 * tuples which should be discarded.
				 */
				spd_queue_reset(&fssthrdInfo->tupleQueue);

				MemoryContextReset(tuplectx[0]);
				MemoryContextReset(tuplectx[1]);
				tuple_cnt = 0;

				MemoryContextSwitchTo(fssthrdInfo->threadMemoryContext);

				/* can't goto RESCAN directly due to PG_TRY  */
				break;
			}
			/* Wait for a request from main thread */
			usleep(1);

		}
	}
	PG_CATCH();
	{
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
		elog(DEBUG1, "Thread error occurred during EndForeignScan(). %s:%d",
			 __FILE__, __LINE__);
	}
	PG_END_TRY();

	if (fssthrdInfo->state == SPD_FS_STATE_ERROR)
		goto THREAD_EXIT;
	else if (fssthrdInfo->requestRescan)
		goto RESCAN;


	fssthrdInfo->state = SPD_FS_STATE_FINISH;
THREAD_EXIT:
	spd_queue_notify_finish(&fssthrdInfo->tupleQueue);

#ifdef MEASURE_TIME
	gettimeofday(&e, NULL);
	elog(DEBUG1, "thread%d all time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	pthread_exit(NULL);
}

/**
 * spd_ParseUrl
 *
 * Parse IN url name.
 * parse list is 5 pattern.
 * Pattern1 Url = /sample/test/
 *  First URL "sample"  Throwing URL "/test/"
 * Pattern2 Url = /sample/
 *  First URL "sample"  Throwing URL NULL
 * Pattern4 Url = "/"
 *  First URL NULL  Throwing URL NULL
 * Pattern5 Url = "/sample"
 *  First URL "sample"  Throwing URL NULL
 *
 * @param[in] spd_url_list - URL
 * @param[out] fdw_private - store to parsing URL
 */
static void
spd_ParseUrl(List *spd_url_list, SpdFdwPrivate * fdw_private)
{
	char	   *tp;
	char	   *throw_tp;
	char	   *url_option;
	char	   *next = NULL;
	char	   *throwing_url = NULL;
	int			original_len;
	ListCell   *lc;

	foreach(lc, spd_url_list)
	{
		char	   *url_str = (char *) lfirst(lc);
		List	   *url_parse_list = NULL;

		url_option = pstrdup(url_str);
		if (url_option[0] != '/')
			elog(ERROR, "URL first character should set '/' ");
		url_option++;
		tp = strtok_r(url_option, "/", &next);
		if (tp != NULL)
			url_parse_list = lappend(url_parse_list, tp);	/* Original URL */
		else
			return;

		throw_tp = strtok_r(NULL, "/", &next);
		if (throw_tp != NULL)
		{
			original_len = strlen(tp) + 1;
			throwing_url = pstrdup(&url_str[original_len]); /* Throwing URL */
			if (strlen(throwing_url) != 1)
				url_parse_list = lappend(url_parse_list, throwing_url);
		}
		fdw_private->url_list = lappend(fdw_private->url_list, url_parse_list);
	}
}


/**
 * Get URL from RangeTableEntry and create new URL with deleting first URL.
 *
 * @param[in] childnums - num of child tables
 * @param[in] r_entry - old URL
 * @param[out] fdw_private - store to parsing URL
 *
 */
static void
spd_create_child_url(int childnums, RangeTblEntry *r_entry, SpdFdwPrivate * fdw_private)
{
	char	   *original_url = NULL;
	char	   *throwing_url = NULL;
	ListCell   *lc;
	int i;
	/*
	 * entry is first parsing word(/foo/bar/, then entry is "foo",entry2 is
	 * "bar")
	 */
	spd_ParseUrl(r_entry->spd_url_list, fdw_private);
	if (fdw_private->url_list == NULL)
		elog(ERROR, "IN Clause use but can not find url. Please set IN string.");

	foreach(lc, fdw_private->url_list)
	{
		List	   *url_parse_list = (List *) lfirst(lc);

		original_url = (char *) list_nth(url_parse_list, 0);
		if (url_parse_list->length > 1)
		{
			throwing_url = (char *) list_nth(url_parse_list, 1);
		}
		/* If IN Clause is used, then store to parsing url */
		for (i=0; i < childnums; i++)
		{
			char		srvname[NAMEDATALEN];
			Oid			temp_oid = fdw_private->childinfo[i].oid;
			Oid			temp_tableid;
			ForeignServer *temp_server;
			ForeignDataWrapper *temp_fdw = NULL;

			spd_spi_exec_datasource_name(temp_oid, srvname);

			if (strcmp(original_url, srvname) != 0)
			{
				elog(DEBUG1, "Can not find URL");
				/* for multi in node */
				if (fdw_private->childinfo[i].child_node_status != ServerStatusAlive)
					fdw_private->childinfo[i].child_node_status = ServerStatusIn;
				continue;
			}
			fdw_private->childinfo[i].child_node_status = ServerStatusAlive;

			/*
			 * if child-child node is exist, then create New IN clause. New IN
			 * clause is used by child spd server.
			 */

			if (throwing_url != NULL)
			{

				/* check child table fdw is spd or not */
				temp_tableid = GetForeignServerIdByRelId(temp_oid);
				temp_server = GetForeignServer(temp_tableid);
				temp_fdw = GetForeignDataWrapper(temp_server->fdwid);
				if (strcmp(temp_fdw->fdwname, PGSPIDER_FDW_NAME) != 0)
				{
					elog(ERROR, "Child node is not spd");
				}
				/* if child table fdw is spd, then execute operation */
				fdw_private->in_flag = 1;
				fdw_private->childinfo[i].url_list = lappend(fdw_private->childinfo[i].url_list, throwing_url);
			}
		}
	}
}

/**
 * spd_basestrictinfo_tree_walker
 *
 * Get URL from RangeTableEntry and create new URL with deleting first URL.
 *
 * @param[in,out] node - node information
 * @param[in] root - root node planer info
 *
 */
static bool
spd_basestrictinfo_tree_walker(Node *node, PlannerInfo *root)
{
	ListCell   *temp;
	bool		rtn;

	/*
	 * The walker has already visited the current node, and so we need only
	 * recurse into any sub-nodes it has.
	 *
	 * We assume that the walker is not interested in List nodes per se, so
	 * when we expect a List we just recurse directly to self without
	 * bothering to call the walker.
	 */
	if (node == NULL)
		return false;

	/* Guard against stack overflow due to overly complex expressions */
	check_stack_depth();
	switch (nodeTag(node))
	{
		case T_Var:
			{
				Var		   *expr = (Var *) node;

				char	   *colname;
				RangeTblEntry *rte;

				rte = planner_rt_fetch(expr->varno, root);
				colname = get_attname(rte->relid, expr->varattno, false);
				if (strcmp(colname, SPDURL) == 0)
				{
					elog(DEBUG1, "find colname");
					return true;
				}
			}
		case T_Const:
		case T_Param:
		case T_CaseTestExpr:
		case T_SQLValueFunction:
		case T_CoerceToDomainValue:
		case T_SetToDefault:
		case T_CurrentOfExpr:
		case T_NextValueExpr:
		case T_RangeTblRef:
		case T_SortGroupClause:
		case T_WithCheckOption:
			break;
		case T_Aggref:
			{
				Aggref	   *expr = (Aggref *) node;

				return spd_basestrictinfo_tree_walker((Node *) expr->args, root);
			}
			break;
		case T_GroupingFunc:
		case T_WindowFunc:
		case T_SubscriptingRef:
		case T_FuncExpr:
		case T_NamedArgExpr:
			break;
		case T_OpExpr:
			{
				OpExpr	   *expr = (OpExpr *) node;

				foreach(temp, (List *) expr->args)
				{
					rtn = spd_basestrictinfo_tree_walker((Node *) lfirst(temp), root);
					if (rtn == true)
					{
						return true;
					}
				}
				return false;
			}
		case T_DistinctExpr:	/* struct-equivalent to OpExpr */
		case T_NullIfExpr:		/* struct-equivalent to OpExpr */
		case T_ScalarArrayOpExpr:
		case T_BoolExpr:
		case T_SubLink:
		case T_SubPlan:
		case T_AlternativeSubPlan:
		case T_FieldSelect:
		case T_FieldStore:
		case T_RelabelType:
		case T_CoerceViaIO:
		case T_ArrayCoerceExpr:
		case T_ConvertRowtypeExpr:
		case T_CollateExpr:
		case T_CaseExpr:
		case T_ArrayExpr:
		case T_RowExpr:
		case T_RowCompareExpr:
		case T_CoalesceExpr:
		case T_MinMaxExpr:
		case T_XmlExpr:
		case T_NullTest:
		case T_BooleanTest:
		case T_CoerceToDomain:
			break;
		case T_TargetEntry:
			return spd_basestrictinfo_tree_walker((Node *) ((TargetEntry *) node)->expr, root);
		case T_Query:
		case T_WindowClause:
		case T_CommonTableExpr:
		case T_List:
			foreach(temp, (List *) node)
			{
				if (spd_basestrictinfo_tree_walker((Node *) lfirst(temp), root))
					return true;
			}
			break;
		case T_FromExpr:
		case T_OnConflictExpr:
		case T_JoinExpr:
		case T_SetOperationStmt:
		case T_PlaceHolderVar:
		case T_InferenceElem:
		case T_AppendRelInfo:
		case T_PlaceHolderInfo:
		case T_RangeTblFunction:
		case T_TableSampleClause:
		case T_TableFunc:
			break;
		default:
			elog(ERROR, "unrecognized node type: %d",
				 (int) nodeTag(node));
			break;
	}
	return false;
}

/**
 * check_basestrictinfo
 *
 * Create base plan for each child tables and save into fdw_private.
 *
 * @param[in] root - planner info
 * @param[in] fdw - child table's fdw
 * @param[inout] entry_baserel - child table's base plan is saved
 */

static void
check_basestrictinfo(PlannerInfo *root, ForeignDataWrapper *fdw, RelOptInfo *entry_baserel)
{
	ListCell   *lc;
	List *restrictinfo = NIL; /* new restrictinfo after remove __spd_url */

	if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) == 0)
	{
		foreach(lc, entry_baserel->baserestrictinfo)
		{
			RestrictInfo *clause = (RestrictInfo *) lfirst(lc);
			Expr	   *expr = (Expr *) clause->clause;

			if (spd_basestrictinfo_tree_walker((Node *) expr, root))
				entry_baserel->baserestrictinfo = NULL;
		}
	}
	/* add to reltarget->exprs */
	foreach(lc, entry_baserel->baserestrictinfo)
	{
		RestrictInfo *clause = (RestrictInfo *) lfirst(lc);
		Expr	   *expr = (Expr *) clause->clause;

		if (spd_basestrictinfo_tree_walker((Node *) expr, root) != true)
		{
			entry_baserel->reltarget->exprs = lappend(entry_baserel->reltarget->exprs, expr);
			/* If not __spd_url, we append clause to new restrictinfo list */
			restrictinfo = lappend(restrictinfo, clause);
		}
	}
	entry_baserel->baserestrictinfo = restrictinfo;
}


/**
 * remove_spdurl_from_targets
 *
 * Remove all __spd_url from target list 'exprs'
 * 
 * @param[in,out] exprs - target list
 * @param[in] root
  */
static List *
remove_spdurl_from_targets(List *exprs, PlannerInfo *root)
{
	ListCell   *lc;

	foreach (lc, exprs)
	{
		RangeTblEntry *rte;
		char	   *colname;
		Node	   *node = (Node *) lfirst(lc);
		Node	   *varnode;

		if (IsA(node, TargetEntry))
		{
			varnode = (Node *) (((TargetEntry *) node)->expr);
		}
		else
		{
			varnode = node;
		}
		if (IsA(varnode, Var))
		{
			Var		   *var = (Var *) varnode;

			/* check whole row reference */
			if (var->varattno == 0)
			{
				continue;
			}
			else
			{
				rte = planner_rt_fetch(var->varno, root);
				colname = get_attname(rte->relid, var->varattno, false);
			}

			if (strcmp(colname, SPDURL) == 0)
			{
				exprs = foreach_delete_current(exprs, lc);
			}
		}
	}

	return exprs;
}

/**
 * get_index_spdurl_from_targets
 *
 * Find __spd_url from target list 'exprs' and if the first __spd_url is found,
 * return the index as 'url_idx'.
 *
 * @param[in] exprs - target list
 * @param[in] root
 */
static int
get_index_spdurl_from_targets(List *exprs, PlannerInfo *root)
{
	ListCell   *lc;
	int			i = 0;

	int url_idx = -1;
	foreach (lc, exprs)
	{
		RangeTblEntry *rte;
		char	   *colname;
		Node	   *node = (Node *) lfirst(lc);
		Node	   *varnode;

		if (IsA(node, TargetEntry))
		{
			varnode = (Node *) (((TargetEntry *) node)->expr);
		}
		else
		{
			varnode = node;
		}
		if (IsA(varnode, Var))
		{
			Var		   *var = (Var *) varnode;

			/* check whole row reference */
			if (var->varattno == 0)
			{
				continue;
			}
			else
			{
				rte = planner_rt_fetch(var->varno, root);
				colname = get_attname(rte->relid, var->varattno, false);
			}

			if (strcmp(colname, SPDURL) == 0)
			{
				url_idx = i;
				return url_idx;
			}
		}
		i++;
	}

	return url_idx;
}

/**
 * remove_spdurl_from_group_clause
 *
 * Remove __spd_url from 'groupClause' lists
 *
 * @param[in] root
 * @param[in] tlist
 * @param[in,out] groupClause
 */
static List *
remove_spdurl_from_group_clause(PlannerInfo *root, List *tlist, List *groupClause)
{
	ListCell   *lc;

	if (groupClause == NULL)
		return NULL;

	foreach (lc, groupClause)
	{
		SortGroupClause *sgc = (SortGroupClause *) lfirst(lc);
		TargetEntry *tle = get_sortgroupclause_tle(sgc, tlist);

		if (IsA(tle->expr, Var))
		{
			Var		   *var = (Var *) tle->expr;
			RangeTblEntry *rte;
			char	   *colname;

			rte = planner_rt_fetch(var->varno, root);
			colname = get_attname(rte->relid, var->varattno, false);
			if (strcmp(colname, SPDURL) == 0)
			{
				groupClause = foreach_delete_current(groupClause, lc);
			}
		}
	}
	return groupClause;
}

/**
 * groupby_has_spdurl
 *
 * Check whether __spd_url existing in GROUP BY
 *
 * @param[in] root - Root planner info
 *
 */
static bool
groupby_has_spdurl(PlannerInfo *root)
{
	List	   *target_list = root->parse->targetList;
	List	   *group_clause = root->parse->groupClause;
	ListCell   *lc;
	char	   *colname;
	RangeTblEntry *rte;

	foreach(lc, group_clause)
	{
		SortGroupClause *sgc = (SortGroupClause *) lfirst(lc);
		TargetEntry *te = get_sortgroupclause_tle(sgc, target_list);

		if (te == NULL)
			return false;
		/* Check __spd_url in the target entry */
		if (IsA(te->expr, Var))
		{
			Var		   *var = (Var *) te->expr;

			rte = planner_rt_fetch(var->varno, root);
			colname = get_attname(rte->relid, var->varattno, false);
			if (strcmp(colname, SPDURL) == 0)
				return true;
		}
	}
	return false;
}


/**
 * spd_CreateDummyRoot
 *
 * Create base plan for each child tables and save into fdw_private.
 *
 * @param[in] root - Root base planner infromation
 * @param[in] baserel - Root base relation option
 * @param[in] oid - child table's oids
 * @param[in] oid_nums - oid nums
 * @param[in] r_entry - Root entry
 * @param[in] new_inurl - new IN clause url
 * @param[inout] fdw_private - child table's base plan is saved
 */
static void
spd_CreateDummyRoot(PlannerInfo *root, RelOptInfo *baserel,
					Oid *oid, int oid_nums,
					RangeTblEntry *r_entry,
					List *new_inurl, SpdFdwPrivate * fdw_private)
{
	RelOptInfo *entry_baserel;
	FdwRoutine *fdwroutine;
	Oid			oid_server;
	int			i = 0;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	ChildInfo  *childinfo = fdw_private->childinfo;

	for (i = 0; i < oid_nums; i++)
	{
		Oid			rel_oid = 0;
		PlannerInfo *dummy_root = NULL;
		Query	   *query;
		PlannerGlobal *glob;
		RangeTblEntry *rte;
		int			k;
		char		ip[NAMEDATALEN] = {0};

		rel_oid = childinfo[i].oid;
		if (rel_oid == 0)
			continue;

		oid_server = spd_spi_exec_datasource_oid(rel_oid);
		fdwroutine = GetFdwRoutineByServerId(oid_server);

		/*
		 * Set up mostly-dummy planner state PlannerInfo can not deep copy
		 * with copyObject(). BUt It should create dummy PlannerInfo for each
		 * child tables. Following code is copy from plan_cluster_use_sort(),
		 * it create simple PlannerInfo.
		 */
		query = makeNode(Query);
		query->commandType = CMD_SELECT;
		glob = makeNode(PlannerGlobal);

		dummy_root = makeNode(PlannerInfo);
		dummy_root->parse = query;
		dummy_root->glob = glob;
		dummy_root->query_level = 1;
		dummy_root->planner_cxt = CurrentMemoryContext;
		dummy_root->wt_param_id = -1;
		/*
		 * Use placeholder list only for child node's GetForeignRelSize in this routine.
		 * PlaceHolderVar in relation target list will be checked against PlaceHolder List
		 * in root planner info.
		 */
		dummy_root->placeholder_list = copyObject(root->placeholder_list);

		/* Build a minimal RTE for the rel */
		rte = makeNode(RangeTblEntry);
		rte->rtekind = RTE_RELATION;
		rte->relid = rel_oid;
		rte->relkind = RELKIND_RELATION;	/* Don't be too picky. */
		rte->eref = makeNode(Alias);
		rte->eref->aliasname = pstrdup("");
		rte->lateral = false;
		rte->inh = false;
		rte->inFromCl = true;
		rte->eref = makeAlias(pstrdup(""), NIL);
		rte->rellockmode = AccessShareLock;	/* For SELECT query */

		/*
		 * if child node is spd and IN clause is used, then should set new IN
		 * clause URL at child node planner URL.
		 */
		if (childinfo[i].url_list != NULL)
		{
			rte->spd_url_list = list_copy(childinfo[i].url_list);
		}

		/*
		 * Create child range table
		 */
		query->rtable = list_make1(rte);
		for (k = 1; k < baserel->relid; k++)
		{
			query->rtable = lappend(query->rtable, rte);
		}
		/* Set up RTE/RelOptInfo arrays */
		setup_simple_rel_arrays(dummy_root);

		/*
		 * Because in build_simple_rel() function, it assumes that a relation was already locked before open.
		 * So, we need to lock relation by id in dummy root in advance.
		 */
		LockRelationOid(rte->relid, rte->rellockmode);

		/*
		 * Build RelOptInfo Build simple relation and copy target list and
		 * strict info from root information.
		 */
		entry_baserel = build_simple_rel(dummy_root, baserel->relid, RELOPT_BASEREL);
		entry_baserel->reltarget->exprs = copyObject(baserel->reltarget->exprs);
		entry_baserel->baserestrictinfo = copyObject(baserel->baserestrictinfo);

		fs = GetForeignServer(oid_server);
		fdw = GetForeignDataWrapper(fs->fdwid);

		/* Remove __spd_url from target lists if a child is not pgspider_fdw */
		if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0)
		{
			entry_baserel->reltarget->exprs = remove_spdurl_from_targets(entry_baserel->reltarget->exprs, root);
		}

		/*
		 * FDW use basestrictinfo to check column type and num.
		 * Delete spd_url column info from child node
		 * baserel's basestrictinfo. (PGSpider FDW use parent basestrictinfo)
		 *
		 */
		check_basestrictinfo(root, fdw, entry_baserel);
		childinfo[i].server_oid = oid_server;
		spd_spi_exec_child_ip(fs->servername, ip);
		/* Check server name and ip */
#ifndef WITHOUT_KEEPALIVE
		if (check_server_ipname(fs->servername, ip))
		{
#endif
			/* Do child node's GetForeignRelSize */
			PG_TRY();
			{
				fdwroutine->GetForeignRelSize(dummy_root, entry_baserel, rel_oid);
				childinfo[i].root = dummy_root;
			}
			PG_CATCH();
			{
				/*
				 * Even If fail to create dummy_root_list, then append
				 * dummy_base_rel_list and dummy_root_list success to
				 * creating. But spd should stop following step for failed
				 * child table, so, set fdw_private->child_table_alive to
				 * FALSE
				 *
				 * spd_beginForeignScan() get information of child tables from
				 * system table and compare it with
				 * fdw_private->dummy_base_rel_list. That's why, the length of
				 * fdw_private->dummy_base_rel_list should match the number of
				 * all of the child tables belong to parent table.
				 */
				childinfo[i].root = root;
				childinfo[i].child_node_status = ServerStatusDead;

				/*
				 * If error is occurred, child node fdw does not output Error.
				 * It should be clear Error stack.
				 */
				elog(WARNING, "GetForeignRelSize failed");
				if (throwErrorIfDead)
				{
					spd_aliveError(fs);
				}
				FlushErrorState();
			}
			PG_END_TRY();
#ifndef WITHOUT_KEEPALIVE
		}
		else
		{
			childinfo[i].root = root;
			childinfo[i].child_node_status = ServerStatusDead;
			if (throwErrorIfDead)
				spd_aliveError(fs);
		}
#endif
		childinfo[i].baserel = entry_baserel;
	}
}

/**
 * spd_CopyRoot
 *
 * Create base plan for each child tables and save into fdw_private.
 *
 * @param[in] root - Root base planner infromation
 * @param[in] baserel - Root base relation option
 * @param[inout] fdw_private - child table's base plan is saved
 * @param[in] relid - relation id
 */
static void
spd_CopyRoot(PlannerInfo *root, RelOptInfo *baserel, SpdFdwPrivate * fdw_private, Oid relid)
{
	Query	   *query;
	PlannerGlobal *glob;
	RangeTblEntry *rte;
	int			k;

	query = makeNode(Query);
	query->commandType = CMD_SELECT;
	glob = makeNode(PlannerGlobal);
	fdw_private->isFirst = true;
	fdw_private->spd_root = makeNode(PlannerInfo);
	fdw_private->spd_root->parse = query;
	fdw_private->spd_root->glob = glob;
	fdw_private->spd_root->query_level = 1;
	fdw_private->spd_root->planner_cxt = CurrentMemoryContext;
	fdw_private->spd_root->wt_param_id = -1;

	/* Build a minimal RTE for the rel */
	rte = makeNode(RangeTblEntry);
	rte->rtekind = RTE_RELATION;
	rte->relkind = RELKIND_RELATION;	/* Don't be too picky. */
	rte->eref = makeNode(Alias);
	rte->relid = relid;
	rte->eref->aliasname = pstrdup("");
	rte->lateral = false;
	rte->inh = false;
	rte->inFromCl = true;
	rte->eref = makeAlias(pstrdup(""), NIL);

	/*
	 * Create child range table
	 */
	query->rtable = list_make1(rte);
	for (k = 1; k < baserel->relid; k++)
	{
		query->rtable = lappend(query->rtable, rte);
	}
	/* Set up RTE/RelOptInfo arrays */
	setup_simple_rel_arrays(fdw_private->spd_root);

	/*
	 * Build RelOptInfo Build simple relation and copy target list and strict
	 * info from root information.
	 */
	fdw_private->baserestrictinfo = copyObject(baserel->baserestrictinfo);
}


/**
 * spd_GetForeignRelSize
 *
 * 1. Check number of child tables and oid.
 * 2. Check IN clause and create next IN clause (delete head of URL)
 * 3. Create base plan for each child tables and save into fdw_private.
 *
 * Original FDW create fdw's using by root and baserel.
 * SPD should create child node plan information, main thread create it using this function.
 *
 *
 * @param[in] root - base planner information
 * @param[in] baserel - base relation option
 * @param[in] foreigntableid - Parent foreing table id
 */

static void
spd_GetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
	SpdFdwPrivate *fdw_private;
	Oid		   *oid = NULL;
	int			nums;
	List	   *new_inurl = NULL;
	RangeTblEntry *r_entry;
	char	   *namespace = NULL;
	char	   *relname = NULL;
	char	   *refname = NULL;
	RangeTblEntry *rte;
	int i;
	int rtn = 0;
	StringInfo relation_name = makeStringInfo();

	baserel->rows = 1000;
	fdw_private = spd_AllocatePrivate();
	fdw_private->idx_url_tlist = -1;	/* -1: not have __spd_url */
	fdw_private->rinfo.pushdown_safe = true;
	baserel->fdw_private = (void *) fdw_private;

	/* get child datasouce oid and nums */
	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);
	if (nums == 0)
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));

	fdw_private->node_num = nums;
	fdw_private->childinfo = (ChildInfo *) palloc0(sizeof(ChildInfo) * nums);

	for (i = 0; i < nums; i++)
		fdw_private->childinfo[i].oid = oid[i];
	/* Initialize all servers */
	for (i = 0; i < nums; i++)
		fdw_private->childinfo[i].child_node_status = ServerStatusDead;

	Assert(IS_SIMPLE_REL(baserel));
	r_entry = root->simple_rte_array[baserel->relid];
	Assert(r_entry != NULL);

	/* Check to IN clause and execute only IN URL server */
	if (r_entry->spd_url_list != NULL)
		spd_create_child_url(nums, r_entry, fdw_private);
	else
	{
		for (i = 0; i < nums; i++)
		{
			fdw_private->childinfo[i].child_node_status = ServerStatusAlive;
		}
	}

	/* Create base plan for each child tables and exec GetForeignRelSize */
	spd_CreateDummyRoot(root, baserel, oid, nums, r_entry, new_inurl, fdw_private);

	/*
	 * Set the name of relation in fpinfo, while we are constructing it here.
	 * It will be used to build the string describing the join relation in
	 * EXPLAIN output. We can't know whether VERBOSE option is specified or
	 * not, so always schema-qualify the foreign table name.
	 */
	rte = planner_rt_fetch(baserel->relid, root);
	namespace = get_namespace_name(get_rel_namespace(foreigntableid));
	relname = get_rel_name(foreigntableid);
	refname = rte->eref->aliasname;
	appendStringInfo(relation_name, "%s.%s",
					 quote_identifier(namespace),
					 quote_identifier(relname));
	if (*refname && strcmp(refname, relname) != 0)
		appendStringInfo(relation_name, " %s",
						 quote_identifier(rte->eref->aliasname));

	fdw_private->rinfo.relation_name = pstrdup(relation_name->data);
	spd_CopyRoot(root, baserel, fdw_private, foreigntableid);
	/* No outer and inner relations. */
	fdw_private->rinfo.make_outerrel_subquery = false;
	fdw_private->rinfo.make_innerrel_subquery = false;
	fdw_private->rinfo.lower_subquery_rels = NULL;
	/* Set the relation index. */
	fdw_private->rinfo.relation_index = baserel->relid;
	/* Init mutex.*/
	SPD_RWLOCK_INIT(&fdw_private->scan_mutex, &rtn);
	if (rtn != SPD_RWLOCK_INIT_OK)
		elog(ERROR, "%s read-write lock object initialization error, error code %d", __func__, rtn);
}

/**
 * spd_makedivtlist
 *
 * Splitting one aggref into multiple aggref
 *
 * @param[in] aggref - aggregation entry
 * @param[in,out] newList - list of new exprs
 * @param[in,out] fdw_private - fdw global data
 */

static List *
spd_makedivtlist(Aggref *aggref, List *newList, SpdFdwPrivate * fdw_private)
{
	/* Prepare SUM Query */
	Aggref	   *tempCount = copyObject((Aggref *) aggref);
	Aggref	   *tempSum;
	Aggref	   *tempVar;
	int			listn = 0;
	TargetEntry *tle_temp;

	tempSum = copyObject(tempCount);
	if (tempSum->aggtype <= INT8OID)
	{
		set_split_agg_info(tempSum, SUM_OID, INT8OID, INT8OID);
	}
	else if (tempSum->aggtype == NUMERICOID)
	{
		set_split_numeric_info(tempSum, NULL);
	}
	else
	{
		set_split_agg_info(tempSum, SUM_FLOAT8_OID, FLOAT8OID, FLOAT8OID);
	}
	set_split_agg_info(tempCount, COUNT_OID, INT8OID, INT8OID);

	/* Prepare SUM Query */
	tempVar = copyObject(tempCount);
	tempVar->aggfnoid = VAR_OID;

	newList = lappend(newList, tempCount);
	newList = lappend(newList, tempSum);
	if ((aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
		|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
	{
		TargetEntry *tarexpr;
		TargetEntry *oparg = (TargetEntry *) linitial(tempVar->args);
		Var		   *opvar = (Var *) oparg->expr;
		OpExpr	   *opexpr = (OpExpr *) makeNode(OpExpr);
		OpExpr	   *opexpr2 = copyObject(opexpr);

		opexpr->xpr.type = T_OpExpr;
		opexpr->opretset = false;
		opexpr->opcollid = 0;
		opexpr->inputcollid = 0;
		opexpr->location = 0;
		opexpr->args = NULL;

		/* Create top targetentry */
		if (tempVar->aggtype <= FLOAT8OID || tempVar->aggtype >= FLOAT4OID)
		{
			set_split_agg_info(tempVar, SUM_FLOAT8_OID, FLOAT8OID, FLOAT8OID);
			set_split_op_info(opexpr, FLOAT8MUL_OID, FLOAT8MUL_FUNID, FLOAT8OID);
		}
		else if (tempVar->aggtype == NUMERICOID)
		{
			set_split_numeric_info(tempVar, opexpr);
		}

		opexpr->args = lappend(opexpr->args, opvar);
		opexpr->args = lappend(opexpr->args, opvar);
		/* Create var targetentry */
		tarexpr = makeTargetEntry((Expr *) opexpr,	/* copy needed?? */
								  listn,
								  NULL,
								  false);
		tarexpr->ressortgroupref = oparg->ressortgroupref;
		opexpr2 = (OpExpr *) tarexpr->expr;
		opexpr2->opretset = false;
		opexpr2->opcollid = 0;
		opexpr2->inputcollid = 0;
		opexpr2->location = 0;
		tarexpr->resno = 1;
		tempVar->args = lappend(tempVar->args, tarexpr);
		tempVar->args = list_delete_first(tempVar->args);
		tle_temp = makeTargetEntry((Expr *) tempVar,	/* copy needed?? */
								   listn++,
								   NULL,
								   false);
		newList = lappend(newList, tle_temp);
	}

	return newList;

}

/**
 * spd_catalog_makedivtlist
 *
 * Splitting one aggref into multiple aggref (catalogue version)
 *
 * @param[in] aggref - aggregation entry
 * @param[in,out] list - list of new exprs
 * @param[in] type - agg type in CatalogSplitAggType
 */

static List *
spd_catalog_makedivtlist(Aggref *aggref, List *newList, enum Aggtype aggtype)
{
	switch (aggtype)
	{
	case SPREAD_FLAG:
	{
		Aggref *tempMin = copyObject(aggref);
		Aggref *tempMax;
		Oid    maxoid;

		if (aggref->aggtype == FLOAT4OID || aggref->aggtype == FLOAT8OID)
		{
			tempMin->aggfnoid = MIN_FLOAT8_OID;
			tempMin->aggtype = FLOAT8OID;
			tempMin->aggtranstype = FLOAT8OID;
			maxoid = MAX_FLOAT8_OID;
		}
		else
		{
			tempMin->aggfnoid = MIN_BIGINT_OID;
			tempMin->aggtype = INT8OID;
			tempMin->aggtranstype = INT8OID;
			maxoid = MAX_BIGINT_OID;
		}
		tempMax = copyObject(tempMin);
		tempMax->aggfnoid = maxoid;

		newList = lappend(newList, tempMin);
		newList = lappend(newList, tempMax);
		break;
	}
	default:
		break;
	}

	return newList;
}


/**
 * spd_make_tlist_for_baserel
 *
 * Making tlist for basrel with some checking
 *
 * @param[in,out] original tlits - list of target exprs
 * @param[in] root - base planner information
 */

static List *
spd_make_tlist_for_baserel(List *tlist, PlannerInfo *root)
{
	ListCell	*lc;
	List		*new_tlist = NIL;
	Var			*spdurl_var = NULL;

	foreach(lc, tlist)
	{
		TargetEntry *ent = (TargetEntry *) lfirst(lc);
		Node *node = (Node *)ent->expr;

		if (IsA(node, FuncExpr))
		{
			FuncExpr	*func = (FuncExpr *) node;
			char		*opername = NULL;
			HeapTuple 	tuple;

			/* Get function name and schema */
			tuple = SearchSysCache1(PROCOID, ObjectIdGetDatum(func->funcid));
			if (!HeapTupleIsValid(tuple))
			{
				elog(ERROR, "cache lookup failed for function %u", func->funcid);
			}
			opername = pstrdup(((Form_pg_proc) GETSTRUCT(tuple))->proname.data);
			ReleaseSysCache(tuple);

			/* influx_time() should be used with group by, so it is removed from tlist in baserel. */
			if (strcmp(opername, "influx_time") == 0)
				continue;

			/* If there is __spd_url in function's argument, remove the function and add vars instead. */
			if (expression_tree_walker((Node *) func->args, check_spdurl_walker, root))
			{
				ListCell *vars_lc;

				foreach(vars_lc, pull_var_clause((Node *) func->args, PVC_RECURSE_PLACEHOLDERS))
				{
					Var	*var = (Var *) lfirst(vars_lc);
					RangeTblEntry *rte;
					char	   *colname;

					rte = planner_rt_fetch(var->varno, root);
					colname = get_attname(rte->relid, var->varattno, false);
					if (strcmp(colname, SPDURL) == 0)
						spdurl_var = var;
					else
						new_tlist = add_to_flat_tlist(new_tlist, list_make1(var));
				}
				continue;
			}
		}

		new_tlist = add_to_flat_tlist(new_tlist, list_make1(node));
	}

	/* Place __spd_url into the last of tlist */
	if (spdurl_var)
		new_tlist = add_to_flat_tlist(new_tlist, list_make1(spdurl_var));

	return new_tlist;
}

/**
 * spd_merge_tlist
 *
 * Merge tlist into base tlist
 *
 * @param[in,out] base tlits - list of target exprs
 * @param[in] tlits to be merged - list of target exprs
 * @param[in] root - base planner infromation
 */

static List *
spd_merge_tlist(List *base_tlist, List *tlist, PlannerInfo *root)
{
	ListCell	*lc;
	Var			*spdurl_var = NULL;

	foreach(lc, tlist)
	{
		TargetEntry *tle = (TargetEntry *) lfirst(lc);
		Node *node = (Node *)tle->expr;
		Var	*var = (Var *) tle->expr;
		RangeTblEntry *rte;
		char	   *colname;

		if (IsA(node, Var))
		{
			rte = planner_rt_fetch(var->varno, root);
			colname = get_attname(rte->relid, var->varattno, false);
			if (strcmp(colname, SPDURL) == 0)
			{
				spdurl_var = var;
				continue;
			}
		}
		base_tlist = add_to_flat_tlist(base_tlist, list_make1(node));
	}

	/* Place __spd_url into the last of tlist */
	if (spdurl_var)
		base_tlist = add_to_flat_tlist(base_tlist, list_make1(spdurl_var));

	return base_tlist;
}

/**
 * spd_GetForeignUpperPaths
 *
 * Add paths for post-join operations like aggregation, grouping etc. if
 * corresponding operations are safe to push down.
 *
 * Right now, we only support aggregate, grouping and having clause pushdown.
 *
 * @param[in] root - base planner infromation
 * @param[in] stage - not use
 * @param[in] input_rel - input RelOptInfo
 * @param[out] output_rel - output RelOptInfo
 * @param[in] extra - extra parameter
 */
static void
spd_GetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
						 RelOptInfo *input_rel, RelOptInfo *output_rel, void *extra)
{
	SpdFdwPrivate *fdw_private,
			   *in_fdw_private;
	List	   *newList = NIL;
	ListCell   *lc;
	PlannerInfo *spd_root;
	int			listn = 0;
	RelOptInfo *dummy_output_rel;
	Path	   *path;
	bool		pushdown = false;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((SpdFdwPrivate *) input_rel->fdw_private)->rinfo.pushdown_safe)
		return;
	/* Ignore stages we don't support; and skip any duplicate calls. */
	if (stage != UPPERREL_GROUP_AGG || output_rel->fdw_private)
		return;
	in_fdw_private = (SpdFdwPrivate *) input_rel->fdw_private;

	/*
	 * Prepare SpdFdwPrivate for output RelOptInfo. spd_AllocatePrivate do
	 * zero clear
	 */
	fdw_private = spd_AllocatePrivate();
	fdw_private->idx_url_tlist = -1;	/* -1: not have __spd_url */
	fdw_private->node_num = in_fdw_private->node_num;
	fdw_private->in_flag = in_fdw_private->in_flag;
	fdw_private->agg_query = true;
	fdw_private->baserestrictinfo = copyObject(in_fdw_private->baserestrictinfo);
	spd_root = in_fdw_private->spd_root;

	/* Currently dummy. @todo more better parsed object. */
	spd_root->parse->hasAggs = true;
	/* Call below FDW to check it is OK to pushdown or not. */
	/* refer relnode.c fetch_upper_rel() */
	dummy_output_rel = makeNode(RelOptInfo);
	dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
	dummy_output_rel->reltarget = create_empty_pathtarget();
	spd_root->upper_rels[UPPERREL_GROUP_AGG] =
		lappend(spd_root->upper_rels[UPPERREL_GROUP_AGG],
				dummy_output_rel);
	/* make pathtarget */
	spd_root->upper_targets[UPPERREL_GROUP_AGG] =
		copy_pathtarget(root->upper_targets[UPPERREL_GROUP_AGG]);
	spd_root->upper_targets[UPPERREL_WINDOW] =
		copy_pathtarget(root->upper_targets[UPPERREL_WINDOW]);
	spd_root->upper_targets[UPPERREL_FINAL] =
		copy_pathtarget(root->upper_targets[UPPERREL_FINAL]);

	/* Divide split-agg into multiple non-split agg */
	foreach(lc, spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
	{
		Aggref	   *aggref;
		Expr	   *temp_expr;
		enum Aggtype    aggtype;

		temp_expr = lfirst(lc);
		aggref = (Aggref *) temp_expr;
		listn++;
		if (IS_SPLIT_AGG(aggref->aggfnoid))
			newList = spd_makedivtlist(aggref, newList, fdw_private);
		else if (IsA(temp_expr, Aggref) && is_catalog_split_agg(aggref->aggfnoid, &aggtype))
			newList = spd_catalog_makedivtlist(aggref, newList, aggtype);
		else
			newList = lappend(newList, temp_expr);
	}
	spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs = list_copy(newList);
	fdw_private->childinfo = in_fdw_private->childinfo;
	fdw_private->rinfo.pushdown_safe = false;
	fdw_private->having_quals = NIL;
	fdw_private->has_having_quals = false;
	output_rel->fdw_private = fdw_private;
	output_rel->relid = input_rel->relid;

	/* Get parent agg path and create mapping_tlist */
	path = get_foreign_grouping_paths(root, input_rel, output_rel);
	if (path == NULL)
		return;

	spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs = list_copy(newList);
	/* Call the child FDW's GetForeignUpperPaths */
	if (in_fdw_private->childinfo != NULL)
	{
		Oid			oid_server;
		FdwRoutine *fdwroutine;
		int			i = 0;
		ChildInfo  *childinfo = in_fdw_private->childinfo;

		/* set flag if group by has __spd_url */
		fdw_private->groupby_has_spdurl = groupby_has_spdurl(root);

		/* 
		 * get index of __spd_url in the target list 
		 */
		if (fdw_private->groupby_has_spdurl)
		{
			fdw_private->idx_url_tlist = get_index_spdurl_from_targets(fdw_private->child_comp_tlist, root);
		}

		/* child_tlist will be used instead of child_comp_tlist, because we will remove __spd_url from child_tlist. */
		fdw_private->child_tlist = list_copy(fdw_private->child_comp_tlist);

		/* Create path for each child node */
		for (i = 0; i < fdw_private->node_num; i++)
		{
			Oid			rel_oid = childinfo[i].oid;
			RelOptInfo *entry = childinfo[i].baserel;
			PlannerInfo *dummy_root_child = childinfo[i].root;
			RelOptInfo *dummy_output_rel;
			Index	   *sortgrouprefs=NULL;
			Node	   *extra_having_quals = NULL;

			if (childinfo[i].child_node_status != ServerStatusAlive)
			{
				continue;
			}

			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			fs = GetForeignServer(oid_server);
			fdw = GetForeignDataWrapper(fs->fdwid);
			
			/* If child node is not pgspider_fdw, don't pushdown aggregation if scan clauses have __spd_url */
			if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0)
			{
				if (spd_checkurl_clauses(root, fdw_private->baserestrictinfo))
					return;
			}

			/* 
			 * Update dummy child root 
			 */
			dummy_root_child->parse->groupClause = list_copy(root->parse->groupClause);

			if (fdw_private->having_quals != NIL)
			{
				/*
				 * Set information about HAVING clause from pgspider_core_fdw
				 * to GroupPathExtraData and dummy_root.
				 */
				dummy_root_child->parse->havingQual = (Node *)copyObject(fdw_private->having_quals);
				dummy_root_child->hasHavingQual = true;
			}
			else
			{
				/* Does not let child node execute HAVING .*/
				dummy_root_child->parse->havingQual = NULL;
				dummy_root_child->hasHavingQual = false;
			}

			/* Currently dummy. @todo more better parsed object. */
			dummy_root_child->parse->hasAggs = true;
			
			/* Call below FDW to check it is OK to pushdown or not. */
			/* refer relnode.c fetch_upper_rel() */
			dummy_output_rel = makeNode(RelOptInfo);
			dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
			dummy_output_rel->relids = bms_copy(entry->relids);

			if (fdwroutine->GetForeignUpperPaths != NULL)
			{
				extra_having_quals = (Node *)copyObject(((GroupPathExtraData *)extra)->havingQual);

				if (fdw_private->having_quals != NIL)
				{
					((GroupPathExtraData *)extra)->havingQual = (Node *)copyObject(fdw_private->having_quals);
				}
				else
				{
					((GroupPathExtraData *)extra)->havingQual = NULL;
				}

				dummy_output_rel->reltarget = copy_pathtarget(output_rel->reltarget);
				dummy_output_rel->reltarget->exprs = list_copy(fdw_private->upper_targets);
			}else
			{
				dummy_output_rel->reltarget = create_empty_pathtarget();
			}

			dummy_root_child->upper_rels[UPPERREL_GROUP_AGG] =
				lappend(dummy_root_child->upper_rels[UPPERREL_GROUP_AGG],
						dummy_output_rel);

			dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] =
				make_pathtarget_from_tlist(fdw_private->child_comp_tlist);
			dummy_root_child->upper_targets[UPPERREL_WINDOW] =
				copy_pathtarget(spd_root->upper_targets[UPPERREL_WINDOW]);
			dummy_root_child->upper_targets[UPPERREL_FINAL] =
				copy_pathtarget(spd_root->upper_targets[UPPERREL_FINAL]);

			/*
			 * Remove __spd_url from target lists and group clause if a child is not pgspider_fdw
			 */
			if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0 && fdw_private->groupby_has_spdurl)
			{
				/* Remove __spd_url from group clause */
				dummy_root_child->parse->groupClause = remove_spdurl_from_group_clause(root, fdw_private->child_comp_tlist, dummy_root_child->parse->groupClause);

				/* Modify child tlist. We use child tlist for fetching data from child node. */
				fdw_private->child_tlist = remove_spdurl_from_targets(fdw_private->child_tlist, root);

				/* Update path target from new target list without __spd_url */
				dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] = make_pathtarget_from_tlist(fdw_private->child_tlist);

				if (fdwroutine->GetForeignUpperPaths != NULL)
				{
					/* Remove __spd_url from target list*/
					dummy_output_rel->reltarget->exprs = remove_spdurl_from_targets(dummy_output_rel->reltarget->exprs, root);
				}
				else
				{
					List * tempList;

					/* Make tlist from path target */
					tempList = make_tlist_from_pathtarget(fdw_private->rinfo.outerrel->reltarget);
					/* Remove __spd_url */
					tempList = remove_spdurl_from_targets(tempList, root);
					/* Update path target */
					fdw_private->rinfo.outerrel->reltarget = make_pathtarget_from_tlist(tempList);
				}
			}

			/* Fill sortgrouprefs for child using child target entry list */
			sortgrouprefs = palloc0(sizeof(Index) * list_length(fdw_private->child_tlist));
			listn = 0;
			foreach (lc, fdw_private->child_tlist)
			{
				TargetEntry *tmp_entry = (TargetEntry *)lfirst(lc);

				sortgrouprefs[listn++] = tmp_entry->ressortgroupref;
			}
			dummy_root_child->upper_targets[UPPERREL_GROUP_AGG]->sortgrouprefs = sortgrouprefs;
			dummy_output_rel->reltarget->sortgrouprefs = sortgrouprefs;
			
			if (fdwroutine->GetForeignUpperPaths != NULL)
			{
				fdwroutine->GetForeignUpperPaths(dummy_root_child,
												 stage, entry,
												 dummy_output_rel, extra);
				/*
				 * Give original HAVING qualifications for GroupPathExtra->havingQual.
				 */
				((GroupPathExtraData *)extra)->havingQual = extra_having_quals;
			}

			if (dummy_output_rel->pathlist != NULL)
			{
				/* Push down aggregate case */
				childinfo[i].grouped_root_local = dummy_root_child;
				childinfo[i].grouped_rel_local = dummy_output_rel;

				/*
				 * if at least one child fdw pushdown aggregate, parent push down
				 */
				pushdown = true;
			}
			else
			{
				/* Not Push Down case */
				struct Path *tmp_path;
				Query	   *query = root->parse;
				AggClauseCosts dummy_aggcosts;
				PathTarget *grouping_target = output_rel->reltarget;
				AggStrategy aggStrategy = AGG_PLAIN;

				MemSet(&dummy_aggcosts, 0, sizeof(AggClauseCosts));
				tmp_path = linitial(entry->pathlist);

				if (query->groupClause)
				{
					aggStrategy = AGG_HASHED;
					foreach(lc, grouping_target->exprs)
					{
						Node * node = lfirst(lc);

						/* If there is ORDER BY inside aggregate function, set AggStrategy to AGG_SORTED */
						if (is_sorted(node))
						{
							aggStrategy = AGG_SORTED;
							break;
						}
					}
				}
				/*
				 * Pass dummy_aggcosts because create_agg_path requires
				 * aggcosts in cases other than AGG_HASH
				 */
				childinfo[i].aggpath = (AggPath *) create_agg_path((PlannerInfo *) dummy_root_child,
																   dummy_output_rel,
																   tmp_path,
																   dummy_root_child->upper_targets[UPPERREL_GROUP_AGG],
																   aggStrategy, AGGSPLIT_SIMPLE,
																   dummy_root_child->parse->groupClause, NULL, &dummy_aggcosts,
																   1);

				fdw_private->pPseudoAggList = lappend_oid(fdw_private->pPseudoAggList, oid_server);

			}
		}
	}
	/* Add generated path into grouped_rel by add_path(). */
	if (pushdown)
		add_path(output_rel, path);
}

/**
 * get_foreign_grouping_paths
 *
 * Get foreign path for grouping and/or aggregation.
 *
 * Given input_rel represents the underlying scan.  The paths are added to the
 * given grouped_rel.
 *
 * @param[in] root - base planner information
 * @param[in] input_rel - input RelOptInfo
 * @param[in] grouped_rel - grouped relation RelOptInfo
 */
static Path *
get_foreign_grouping_paths(PlannerInfo *root, RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel)
{
	Query	   *parse = root->parse;
	SpdFdwPrivate *ifpinfo = input_rel->fdw_private;
	SpdFdwPrivate *fpinfo = grouped_rel->fdw_private;
	ForeignPath *grouppath;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;

	/* Nothing to be done, if there is no grouping or aggregation required. */
	if (!parse->groupClause && !parse->groupingSets && !parse->hasAggs &&
		!root->hasHavingQual)
		return NULL;

	/* save the input_rel as outerrel in fpinfo */
	fpinfo->rinfo.outerrel = input_rel;

	/*
	 * Copy foreign table, foreign server, user mapping, FDW options etc.
	 * details from the input relation's fpinfo.
	 */
	fpinfo->rinfo.table = ifpinfo->rinfo.table;
	fpinfo->rinfo.server = ifpinfo->rinfo.server;
	fpinfo->rinfo.user = ifpinfo->rinfo.user;

	/* Assess if it is safe to push down aggregation and grouping. */
	if (!foreign_grouping_ok(root, grouped_rel))
		return NULL;

	/*
	 * If no grouping, numGroups should be set 1.
	 * When creating upper path, rows is passed to pathnode->path.rows.
	 * When creating aggregation plan, somehow path.rows is passed to dNumGroups.
	 */
	if (!parse->groupClause)
	{
		/* Not grouping */
		rows = 1;
	}
	else if (parse->groupingSets)
	{
		/* Empty grouping sets ... one result row for each one */
		rows = list_length(parse->groupingSets);
	}
	else if (parse->hasAggs || root->hasHavingQual)
	{
		/* Plain aggregation, one result row */
		rows = 1;
	}
	else
	{
		rows = 0;
	}

	width = 0;
	startup_cost = 0;
	total_cost = 0;

	/* Now update this information in the fpinfo */
	fpinfo->rinfo.rows = rows;
	fpinfo->rinfo.width = width;
	fpinfo->rinfo.startup_cost = startup_cost;
	fpinfo->rinfo.total_cost = total_cost;

	/* Create and add foreign path to the grouping relation. */
	grouppath = create_foreign_upper_path(root,
										grouped_rel,
										root->upper_targets[UPPERREL_GROUP_AGG],
										rows,
										startup_cost,
										total_cost,
										NIL,	/* no pathkeys */
										NULL,	/* no fdw_outerpath */
										NIL);	/* no fdw_private */
	return (Path *) grouppath;
}

/**
 * foreign_grouping_ok
 *
 * Assess whether the aggregation, grouping and having operations can be pushed
 * down to the foreign server.  As a side effect, save information we obtain in
 * this function to SpdFdwPrivate of the input relation.
 *
 * @param[in] root - base planner information
 * @param[in] grouped_rel - grouped relation RelOptInfo
 */
static bool
foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel)
{
	Query	   *query = copyObject(root->parse);
	PathTarget *grouping_target;
	SpdFdwPrivate *fpinfo = (SpdFdwPrivate *) grouped_rel->fdw_private;
	SpdFdwPrivate *ofpinfo;
	List	   *aggvars;
	ListCell   *lc;
	int			i;
	int			groupby_cursor = 0;
	List	   *tlist = NIL;
	List	   *mapping_tlist = NIL;
	List	   *compress_child_tlist = NIL;
	List	   *upper_targets = NIL;

	/* Grouping Sets are not pushable */
	if (query->groupingSets)
		return false;

	/* Get the fpinfo of the underlying scan relation. */
	ofpinfo = (SpdFdwPrivate *) fpinfo->rinfo.outerrel->fdw_private;

	/*
	 * If underneath input relation has any local conditions, those conditions
	 * are required to be applied before performing aggregation.  Hence the
	 * aggregate cannot be pushed down.
	 */
	if (ofpinfo->rinfo.local_conds)
		return false;

	/*
	 * The targetlist expected from this node and the targetlist pushed down
	 * to the foreign server may be different. The latter requires
	 * sortgrouprefs to be set to push down GROUP BY clause, but should not
	 * have those arising from ORDER BY clause. These sortgrouprefs may be
	 * different from those in the plan's targetlist. Use a copy of path
	 * target to record the new sortgrouprefs.
	 */
	grouping_target = copy_pathtarget(root->upper_targets[UPPERREL_GROUP_AGG]);

	/*
	 * Evaluate grouping targets and check whether they are safe to push down
	 * to the foreign side.  All GROUP BY expressions will be part of the
	 * grouping target and thus there is no need to evaluate it separately.
	 * While doing so, add required expressions into target list which can
	 * then be used to pass to foreign server.
	 */
	i = 0;
	fpinfo->groupby_target = NULL;

	foreach(lc, grouping_target->exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc);
		Index		sgref = get_pathtarget_sortgroupref(grouping_target, i);
		ListCell   *l;
		SortGroupClause *sgc = get_sortgroupref_clause_noerr(sgref, query->groupClause);

		/* Check whether this expression is constant column */
		if (IsA(expr, Const))
		{
			/* Not pushable Constant column */
			grouping_target->exprs = foreach_delete_current(grouping_target->exprs, lc);
			if (sgref && sgc)
			{
				query->groupClause = list_delete_ptr(query->groupClause, sgc);
			}

			i++;
			continue;
		}

		/* Check whether this expression is part of GROUP BY clause */
		if (sgref && sgc)
		{
			int			before_listnum;
			bool		allow_duplicate = true;
			int			target_num = 0;
			/*
			 * If any of the GROUP BY expression is not shippable we can not
			 * push down aggregation to the foreign server.
			 */
			if (!is_foreign_expr(root, grouped_rel, expr))
				return false;
			/* Pushable, add to tlist */
			before_listnum = list_length(compress_child_tlist);
			/* 
			 * When expr is already in compress_child_tlist, add as duplicated will cause 
			 * wrong query when rebuilding query on temp table. No need to add as duplicated.
			 */
			if (!spd_tlist_member(expr, mapping_tlist, &target_num) && spd_tlist_member(expr, compress_child_tlist, &target_num))
				allow_duplicate = false;
			tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets, allow_duplicate, false);
			groupby_cursor += list_length(compress_child_tlist) - before_listnum;
			/*
			 * When Operator expression contains group by column, the column will be added
			 * into compress_child_tlist when extracting the expression. Because of that, 
			 * the groupby_cursor will be equal to before_listnum. We need to find the index of 
			 * column in compress_child_tlist to set groupby_target.
			 */
			if (groupby_cursor == before_listnum)	
			{
				int target_num;

				if(spd_tlist_member(expr, compress_child_tlist, &target_num))
					fpinfo->groupby_target = lappend_int(fpinfo->groupby_target, target_num);
			}
			else
				fpinfo->groupby_target = lappend_int(fpinfo->groupby_target, groupby_cursor - 1);
		}
		else
		{
			/* Check entire expression whether it is pushable or not */
			if (is_foreign_expr(root, grouped_rel, expr))
			{
				/* Pushable, add to tlist */
				int			before_listnum = list_length(compress_child_tlist);

				tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets, false, false);
				groupby_cursor += list_length(compress_child_tlist) - before_listnum;
			}
			else
			{
				/* Not matched exactly, pull the var with aggregates then */
				aggvars = pull_var_clause((Node *) expr,
										  PVC_INCLUDE_AGGREGATES);

				if (!is_foreign_expr(root, grouped_rel, (Expr *) aggvars))
					return false;

				/*
				 * Add aggregates, if any, into the targetlist.  Plain var
				 * nodes should be either same as some GROUP BY expression or
				 * part of some GROUP BY expression. In later case, the query
				 * cannot refer plain var nodes without the surrounding
				 * expression.  In both the cases, they are already part of
				 * the targetlist and thus no need to add them again.  In fact
				 * adding pulled plain var nodes in SELECT clause will cause
				 * an error on the foreign server if they are not same as some
				 * GROUP BY expression.
				 */
				foreach(l, aggvars)
				{
					Expr	   *expr = (Expr *) lfirst(l);

					if (IsA(expr, Aggref))
					{
						int			before_listnum = list_length(compress_child_tlist);

						tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets, false, false);
						groupby_cursor += list_length(compress_child_tlist) - before_listnum;
					}
				}
			}
		}

		/* Save the push down target list */
		i++;
	}

	/* mapping_tlist = NIL whether all target list is constant column, so not pushed down this query */
	if (mapping_tlist == NIL)
		return false;

	/*
	 * Classify the pushable and non-pushable having clauses and save them in
	 * remote_conds and local_conds of the grouped rel's fpinfo.
	 */
	if (root->hasHavingQual && query->havingQual)
	{
		ListCell   *lc;

		/* Mark root plan has qualification applied to HAVING */
		fpinfo->has_having_quals = true;

		foreach(lc, (List *) query->havingQual)
		{
			Expr	   *expr = (Expr *) lfirst(lc);
			RestrictInfo *rinfo;

			/*
			 * Currently, the core code doesn't wrap havingQuals in
			 * RestrictInfos, so we must make our own.
			 */
			Assert(!IsA(expr, RestrictInfo));
			rinfo = make_restrictinfo(expr,
									  true,
									  false,
									  false,
									  root->qual_security_level,
									  grouped_rel->relids,
									  NULL,
									  NULL);
			if (!is_foreign_expr(root, grouped_rel, expr))
				return false;

			fpinfo->rinfo.remote_conds = lappend(fpinfo->rinfo.remote_conds, rinfo);

			/* Check qualifications whether can be passed to child nodes. */
			if(is_having_safe((Node *) rinfo->clause))
				fpinfo->having_quals = lappend(fpinfo->having_quals, rinfo->clause);

			/*
			 * Filter operation for HAVING clause will be executed by SELECT query
			 * for temptable with full root HAVING query.
			 *
			 * Extract qualification to mapping list.
			 */
			tlist = spd_add_to_flat_tlist(tlist,  rinfo->clause, &mapping_tlist,
											&compress_child_tlist, 0, &upper_targets, false, true);
		}
	}

	/* Set root->parse */
	root->parse = query;

	/* Store generated targetlist */
	fpinfo->rinfo.grouped_tlist = tlist;

	/* Safe to pushdown */
	fpinfo->rinfo.pushdown_safe = true;

	/*
	 * Set cached relation costs to some negative value, so that we can detect
	 * when they are set to some sensible costs, during one (usually the
	 * first) of the calls to estimate_path_cost_size().
	 */
	fpinfo->rinfo.rel_startup_cost = -1;
	fpinfo->rinfo.rel_total_cost = -1;

	/*
	 * Set the string describing this grouped relation to be used in EXPLAIN
	 * output of corresponding ForeignScan.
	 */
	fpinfo->rinfo.relation_name = psprintf("Aggregate on (%s)", ofpinfo->rinfo.relation_name);
	fpinfo->mapping_tlist = mapping_tlist;
	fpinfo->child_comp_tlist = compress_child_tlist;
	fpinfo->upper_targets = upper_targets;

	return true;
}


/**
 * Produce extra output for EXPLAIN of a ForeignScan on a foreign table
 *
 * @param[in] node
 * @param[in] es
 */
static void
spd_ExplainForeignScan(ForeignScanState *node,
					   ExplainState *es)
{
	FdwRoutine *fdwroutine;
	int			i;
	ChildInfo  *childinfo;
	SpdFdwPrivate *fdw_private;
	ForeignScanThreadInfo *fssThrdinfo = node->spd_fsstate;

	fdw_private = (SpdFdwPrivate *) fssThrdinfo[0].private;

	if (fdw_private == NULL)
		elog(ERROR, "fdw_private is NULL");

	/* Create Foreign paths using base_rel_list to each child node. */
	childinfo = fdw_private->childinfo;
	for (i = 0; i < fdw_private->node_num; i++)
	{
		ForeignServer *fs;

		fs = GetForeignServer(childinfo[i].server_oid);
		fdwroutine = GetFdwRoutineByServerId(childinfo[i].server_oid);

		if (fdwroutine->ExplainForeignScan == NULL)
			continue;

		/* create node info */
		PG_TRY();
		{
			int			idx;

			ExplainPropertyText(psprintf("Node: %s / Status", fs->servername),
								SpdServerstatusStr[childinfo[i].child_node_status], es);
			es->indent++;

			if (childinfo[i].child_node_status != ServerStatusAlive)
				continue;

			if (es->verbose)
			{

				if (fdw_private->agg_query)
				{
					ExplainPropertyText("Agg push-down", !childinfo[i].can_pushdown_agg ? "no" : "yes", es);
				}
			}
			idx = childinfo[i].index_threadinfo;
			fdwroutine->ExplainForeignScan(((ForeignScanThreadInfo *) node->spd_fsstate)[idx].fsstate, es);
			es->indent--;

		}
		PG_CATCH();
		{
			/*
			 * If fail to create foreign paths, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			childinfo[i].child_node_status = ServerStatusDead;
			elog(WARNING, "fdw ExplainForeignScan error is occurred.");
			FlushErrorState();
		}
		PG_END_TRY();
	}
}

/**
 * spd_GetForeignPaths
 *
 * get foreign paths for each child tables using fdws
 * saving each foreign paths into base rel list
 *
 * spd_GetForeignRelSize() save alive baserel list into fdw_private.
 * GetForeignPaths execute only alive baserel list member.
 *
 * @param[in] root - base planner infromation
 * @param[in] baserel - base relation option
 * @param[in] foreigntableid - Parent foreing table id
 */
static void
spd_GetForeignPaths(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
	FdwRoutine *fdwroutine;
	Oid			server_oid;
	int			i;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Cost		startup_cost = 0;
	Cost		total_cost = 0;
	Cost		rows = 0;
	ChildInfo  *childinfo;

	if (fdw_private == NULL)
	{
		elog(ERROR, "fdw_private is NULL");
	}
	/* Create Foreign paths using base_rel_list to each child node. */
	childinfo = fdw_private->childinfo;
	for (i = 0; i < fdw_private->node_num; i++)
	{
		ForeignServer *fs;

		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (childinfo[i].child_node_status != ServerStatusAlive)
		{
			continue;
		}
		server_oid = spd_spi_exec_datasource_oid(childinfo[i].oid);
		fdwroutine = GetFdwRoutineByServerId(server_oid);
		childinfo[i].server_oid = server_oid;
		fs = GetForeignServer(server_oid);


		PG_TRY();
		{
			Path	   *childpath;

			fdwroutine->GetForeignPaths((PlannerInfo *) childinfo[i].root,
										(RelOptInfo *) childinfo[i].baserel,
										childinfo[i].oid);
			/* Agg child node costs */
			if (childinfo[i].baserel->pathlist != NULL)
			{
				childpath = (Path *) lfirst_node(ForeignPath, list_head(childinfo[i].baserel->pathlist));
				startup_cost += childpath->startup_cost;
				total_cost += childpath->total_cost;
				rows += childpath->rows;
			}
		}
		PG_CATCH();
		{
			/*
			 * If fail to create foreign paths, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			childinfo[i].child_node_status = ServerStatusDead;

			elog(WARNING, "Fdw GetForeignPaths error is occurred.");
			FlushErrorState();
			if (throwErrorIfDead)
				spd_aliveError(fs);
		}
		PG_END_TRY();
	}
	baserel->rows = rows;

	add_path(baserel, (Path *) create_foreignscan_path(root, baserel,
											NULL,
											baserel->rows,
											startup_cost,
											total_cost,
											NIL,	/* no pathkeys*/
											baserel->lateral_relids,
											NULL,	/* no outerpath*/
											NULL));
}


/**
 * outer_var_walker
 *
 * Change expr Var node type to OUTER VAR recursively.
 *
 * @param[in,out] node - plan tree node
 * @param[in,out] param  - attribute number
 *
 */
static bool
outer_var_walker(Node *node, void *param)
{
	if (node == NULL)
		return false;

	if (IsA(node, Var))
	{
		Var		   *expr = (Var *) node;

		expr->varno = OUTER_VAR;
		return false;
	}
	return expression_tree_walker(node, outer_var_walker, (void *) param);
}

/**
 * spd_createPushDownPlan
 *
 * Build aggregation plan for each push down cases.
 * saving each foreign plan into base rel list
 *
 * @param[in] tlist               - target list
 *
 */
static List *
spd_createPushDownPlan(List *tlist)
{

	/*
	 * Temporary create TargetEntry: @todo make correct targetenrty, as if it
	 * is the correct aggregation. (count, max, etc..)
	 */
	TargetEntry *tle;
	Aggref	   *aggref;
	ListCell   *lc;
	List	   *dummy_tlist = NIL;

	dummy_tlist = copyObject(tlist);
	foreach(lc, dummy_tlist)
	{
		tle = lfirst_node(TargetEntry, lc);
		aggref = (Aggref *) tle->expr;

		outer_var_walker((Node *) aggref, NULL);
	}
	return dummy_tlist;
}

/**
 * Return true if __spd_url is found in 'node'.
 *
 * @param[in] node - expression
 * @param[in] root - PlannerInfo root
 */
static bool
check_spdurl_walker(Node *node, PlannerInfo *root)
{
	if (node == NULL)
		return false;

	if (IsA(node, Var))
	{
		Var		   *var = (Var *) node;
		char	   *colname;
		RangeTblEntry *rte;

		rte = planner_rt_fetch(var->varno, root);
		colname = get_attname(rte->relid, var->varattno, false);
		if (strcmp(colname, SPDURL) == 0)
		{
			/* stop search and return true */
			return true;
		}
		else
			return false;
	}
	return expression_tree_walker(node, check_spdurl_walker, (void *) root);
}

/**
 * Search each clause of 'scan_clauses' for __spd_url to decide
 * whether it can be pushed down or not.
 * If found, store 'baserestrictinfo' to 'push_scan_clauses'
 * If not found, store NULL to 'push_scan_clauses'
 *
 * @param[in] scan_clauses
 * @param[in] root
 * @param[in] baserestrictinfo
 */
static bool
spd_checkurl_clauses(PlannerInfo *root, List *baserestrictinfo)
{
	ListCell   *lc;

	foreach(lc, baserestrictinfo)
	{
		RestrictInfo *clause = (RestrictInfo *) lfirst(lc);
		Expr	   *expr = (Expr *) clause->clause;

		if (expression_tree_walker((Node *) expr, check_spdurl_walker, root))
		{
			/* don't pushdown *all* where caluses if spd_url is found */
			return true;
		}
	}
	return false;
}

static Sort *
spd_make_sort(Plan *lefttree, int numCols,
		  AttrNumber *sortColIdx, Oid *sortOperators,
		  Oid *collations, bool *nullsFirst)
{
	Sort	   *node = makeNode(Sort);
	Plan	   *plan = &node->plan;

	plan->targetlist = lefttree->targetlist;
	plan->qual = NIL;
	plan->lefttree = lefttree;
	plan->righttree = NULL;
	node->numCols = numCols;
	node->sortColIdx = sortColIdx;
	node->sortOperators = sortOperators;
	node->collations = collations;
	node->nullsFirst = nullsFirst;

	return node;
}

static Sort *
spd_make_sort_from_groupcols(List *groupcls,
						 AttrNumber *grpColIdx,
						 Plan *lefttree)
{
	List	   *sub_tlist = lefttree->targetlist;
	ListCell   *l;
	int			numsortkeys;
	AttrNumber *sortColIdx;
	Oid		   *sortOperators;
	Oid		   *collations;
	bool	   *nullsFirst;

	/* Convert list-ish representation to arrays wanted by executor */
	numsortkeys = list_length(groupcls);
	sortColIdx = (AttrNumber *) palloc(numsortkeys * sizeof(AttrNumber));
	sortOperators = (Oid *) palloc(numsortkeys * sizeof(Oid));
	collations = (Oid *) palloc(numsortkeys * sizeof(Oid));
	nullsFirst = (bool *) palloc(numsortkeys * sizeof(bool));

	numsortkeys = 0;
	foreach(l, groupcls)
	{
		SortGroupClause *grpcl = (SortGroupClause *) lfirst(l);
		TargetEntry *tle = get_tle_by_resno(sub_tlist, grpColIdx[numsortkeys]);

		if (!tle)
			elog(ERROR, "could not retrieve tle for sort-from-groupcols");

		sortColIdx[numsortkeys] = tle->resno;
		sortOperators[numsortkeys] = grpcl->sortop;
		collations[numsortkeys] = exprCollation((Node *) tle->expr);
		nullsFirst[numsortkeys] = grpcl->nulls_first;
		numsortkeys++;
	}

	return spd_make_sort(lefttree, numsortkeys,
					 sortColIdx, sortOperators,
					 collations, nullsFirst);
}

/**
 * spd_GetForeignChildPlans
 *
 * Build foreign plan for each child tables using fdws.
 * saving each foreign plan into  base rel list
 *
 * @param[in] root - base planner infromation
 * @param[in] baserel - base relation option
 * @param[in] foreigntableid - Parent foreing table id
 * @param[in] ForeignPath *best_path - path of
 * @param[in] List *ptemptlist - target_list of pgspider core
 * @param[in] List **push_scan_clauses - where scan clauses
 * @param[in] Plan *outer_plan - outer plan
 * @param[in] ChildInfo *childinfo - each child information
 * @param[in] Oid *oid - oid array of each foreign table
 *
 */
static void
spd_GetForeignChildPlans(PlannerInfo *root, RelOptInfo *baserel,
						 ForeignPath *best_path, List *ptemptlist, List **push_scan_clauses,
						 Plan *outer_plan, ChildInfo *childinfo, Oid *oid)
{
	int			i;
	FdwRoutine *fdwroutine;
	Oid			server_oid;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	ForeignPath *child_path;

	/* Create Foreign plans for each child. */
	for (i = 0; i < fdw_private->node_num; i++)
	{
		ForeignScan *fsplan = NULL;
		List	   *temptlist;

		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (childinfo[i].baserel == NULL)
			break;
		if (childinfo[i].child_node_status != ServerStatusAlive)
			continue;

		/* get child node's oid. */
		server_oid = childinfo[i].server_oid;

		fdwroutine = GetFdwRoutineByServerId(server_oid);
		fs = GetForeignServer(server_oid);
		fdw = GetForeignDataWrapper(fs->fdwid);

		PG_TRY();
		{
			/* create plan */
			if (childinfo[i].grouped_rel_local != NULL)
			{
				/* agg push down path */
				if (!childinfo[i].grouped_rel_local->pathlist)
					elog(ERROR, "Agg path is not found");

				/* FDWs expect NULL scan clauses for UPPER REL */
				*push_scan_clauses = NULL;
				/* Pick any agg path */

				/* Pick any agg path */
				child_path = lfirst(list_head(childinfo[i].grouped_rel_local->pathlist));
				temptlist = PG_build_path_tlist((PlannerInfo *) childinfo[i].root, (Path *) child_path);

				fsplan = fdwroutine->GetForeignPlan(childinfo[i].grouped_root_local,
													childinfo[i].grouped_rel_local,
													oid[i],
													(ForeignPath *) child_path,
													temptlist,
													*push_scan_clauses,
													outer_plan);
			}
			else
			{
				/*
				 * For non agg query or not push down agg case, do same thing
				 * as create_scan_plan() to generate target list
				 */

				/* Add all columns of the table */
				if (IS_SIMPLE_REL(baserel) && ptemptlist != NULL)
					temptlist = list_copy(ptemptlist);
				else
					temptlist = (List *) build_physical_tlist(childinfo[i].root, childinfo[i].baserel);

				/*
				 * Fill sortgrouprefs to temptlist. temptlist is non aggref
				 * target list, we should use non aggref pathtarget to apply.
				 */
				if (!IS_SIMPLE_REL(baserel) && root->parse->groupClause != NULL)
				{
					apply_pathtarget_labeling_to_tlist(temptlist, fdw_private->rinfo.outerrel->reltarget);
				}

				/* Remove __spd_url from target lists if a child is not pgspider_fdw */
				if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0 && IS_SIMPLE_REL(baserel))
				{
					temptlist = remove_spdurl_from_targets(temptlist, root);
					// fixme: update fdw_private->idx_url_tlist
				}

				/*
				 * For can not aggregation pushdown FDW's. push down quals
				 * when aggregation is occurred
				 */
				if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
					*push_scan_clauses = fdw_private->baserestrictinfo;

				/*
				 * We pass "best_path" to child GetForeignPlan. This is the
				 * path for parent fdw and not for child fdws. We should pass
				 * correct child path, but now we pass at least fdw_private of
				 * child path.
				 */
				child_path = lfirst(list_head(childinfo[i].baserel->pathlist));
				best_path->fdw_private = child_path->fdw_private;

				/*
				 * check scan_clauses include "__spd_url" If include
				 * "__spd_url" in WHERE clauses, then NOT pushdown all
				 * caluses.
				 */
				if (spd_checkurl_clauses(root, fdw_private->baserestrictinfo))
				{
					*push_scan_clauses = NULL;
				}
				else
				{
					*push_scan_clauses = fdw_private->baserestrictinfo;
				}

				fsplan = fdwroutine->GetForeignPlan((PlannerInfo *) childinfo[i].root,
													(RelOptInfo *) childinfo[i].baserel,
													oid[i],
													(ForeignPath *) best_path,
													temptlist,
													*push_scan_clauses,
													outer_plan);
			}
			childinfo[i].scan_relid = childinfo[i].baserel->relid;

		}
		PG_CATCH();
		{
			/*
			 * If fail to get foreign plan, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			childinfo[i].child_node_status = ServerStatusDead;
			elog(WARNING, "GetForeignPlan failed ");
			FlushErrorState();
			if (throwErrorIfDead)
			{
				fs = GetForeignServer(childinfo[i].server_oid);
				spd_aliveError(fs);
			}
		}
		PG_END_TRY();
		/* For aggregation and can not pushdown fdw's */
		if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
		{
			List	   *child_tlist;
			ListCell   *lc;
			int			idx = 0;
			Plan	   *sort_plan = NULL;

			/*
			 * If groupby has __spd_url, __spd_url will be removed from the target
			 * list. Before creating aggregation plan, re-indexing item by
			 * resno for child target list. This helps SPI_execAgg puts data
			 * to right position after calculation.
			 */
			if (fdw_private->groupby_has_spdurl)
			{
				foreach(lc, fdw_private->child_tlist)
				{
					TargetEntry *ent = (TargetEntry *) lfirst(lc);

					idx++;
					ent->resno = idx;
				}
			}

			child_tlist = spd_createPushDownPlan(fdw_private->child_tlist);

			/*
			 * Create aggregation plan with foreign table scan.
			 * extract_grouping_cols() requires targetlist of subplan.
			 */
			if (childinfo[i].aggpath->aggstrategy == AGG_SORTED)
			{
				AttrNumber *new_grpColIdx;

				new_grpColIdx = extract_grouping_cols(childinfo[i].aggpath->groupClause,
													  fsplan->scan.plan.targetlist);

				sort_plan = (Plan *)
					spd_make_sort_from_groupcols(childinfo[i].aggpath->groupClause,
												 new_grpColIdx,
												 (Plan *) fsplan);
			}
			childinfo[i].pAgg = make_agg(child_tlist,
										 NULL,
										 childinfo[i].aggpath->aggstrategy,
										 childinfo[i].aggpath->aggsplit,
										 list_length(childinfo[i].aggpath->groupClause),
										 extract_grouping_cols(childinfo[i].aggpath->groupClause, fsplan->scan.plan.targetlist),
										 extract_grouping_ops(childinfo[i].aggpath->groupClause),
										 extract_grouping_collations(childinfo[i].aggpath->groupClause, fsplan->scan.plan.targetlist),
										 root->parse->groupingSets,
										 NIL,
										 childinfo[i].aggpath->path.rows,
										 childinfo[i].aggpath->transitionSpace,
										 sort_plan!=NULL?sort_plan:(Plan *) fsplan);
		}
		childinfo[i].plan = (Plan *) fsplan;
	}
}

/**
 * spd_CompareTargetList
 *
 * Compare two given target lists.
 * Return true if it is same list.
 *
 * @param[in] List *tlist1 - target_list
 * @param[in] List *tlist2 - target_list
 *
 */
static bool
spd_CompareTargetList(List *tlist1, List *tlist2)
{
	ListCell   *lc1;
	ListCell   *lc2;

	if (list_length(tlist1) != list_length(tlist2))
		return false;

	forboth(lc1, tlist1, lc2, tlist2)
	{
		TargetEntry *ent1 = (TargetEntry *) lfirst(lc1);
		TargetEntry *ent2 = (TargetEntry *) lfirst(lc2);

		if (!equal(ent1->expr, ent2->expr))
			return false;
	}

	return true;
}

/**
 * spd_GetForeignPlan
 *
 * Build foreign plan for each child tables using fdws.
 * saving each foreign plan into  base rel list
 *
 * @param[in] root - base planner infromation
 * @param[in] baserel - base relation option
 * @param[in] foreigntableid - Parent foreing table id
 * @param[in] ForeignPath *best_path - path of
 * @param[in] List *tlist - target_list
 * @param[in] List *scan_clauses where
 * @param[in] Plan *outer_plan outer_plan
 *
 */
static ForeignScan *
spd_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid,
				   ForeignPath *best_path, List *tlist, List *scan_clauses,
				   Plan *outer_plan)
{
	int			nums;
	int			i;
	Oid		   *oid = NULL;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Index		scan_relid;
	List	   *fdw_scan_tlist = NIL;	/* Need dummy tlist for pushdown case. */
	List	   *push_scan_clauses = scan_clauses;
	ListCell   *lc;
	ChildInfo  *childinfo;
	List	   *lfdw_private = NIL;
	List	   *ptemptlist;

	if (fdw_private == NULL)
		elog(ERROR, "fdw_private is NULL");

	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);

	fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;

	/* Create "GROUP BY" string */
	if (root->parse->groupClause != NULL)
	{
		bool		first = true;

		fdw_private->groupby_string = makeStringInfo();
		appendStringInfo(fdw_private->groupby_string, "GROUP BY ");
		foreach(lc, fdw_private->groupby_target)
		{
			int			cl = lfirst_int(lc);

			if (!first)
				appendStringInfoString(fdw_private->groupby_string, ", ");
			first = false;

			appendStringInfo(fdw_private->groupby_string, "col%d", cl);
		}
	}
	childinfo = fdw_private->childinfo;

	/* Prepare parent temp tlist */
	ptemptlist = spd_make_tlist_for_baserel(tlist, root);

	/* Create Foreign plans for each child with function pushdown. */
	spd_GetForeignChildPlans(root, baserel, best_path, ptemptlist, &push_scan_clauses,
							 outer_plan, childinfo, oid);

	fdw_private->is_pushdown_tlist = false;
	if (IS_SIMPLE_REL(baserel))
	{
		ForeignScan *fsplan = NULL;
		bool exist_pushdown_child = false;
		bool exist_non_pushdown_child = false;
		bool different_pushdown = false;
		List *child_fdw_scan_tlist = NIL;

		for (i = 0; i < fdw_private->node_num; i++)
		{
			fsplan = (ForeignScan *) childinfo[i].plan;

			/* By IN clause, childinfo has NULL fsplan, ignore it. */
			if (fsplan != NULL)
			{
				if (fsplan->fdw_scan_tlist == NULL)
					exist_non_pushdown_child = true;
				else if (exist_pushdown_child == false)
				{
					exist_pushdown_child = true;
					child_fdw_scan_tlist = fsplan->fdw_scan_tlist;
				}
				else if (child_fdw_scan_tlist != NULL)
				{
					if (!spd_CompareTargetList(child_fdw_scan_tlist, fsplan->fdw_scan_tlist))
						different_pushdown = true;
				}

				/* Check mix use of pushdown / non-pushdown */
				if (different_pushdown ||
					(fsplan->fdw_scan_tlist == NULL && exist_pushdown_child) ||
					(fsplan->fdw_scan_tlist != NULL && exist_non_pushdown_child))
				{
					/* Create Foreign plans for each child without function pushdown. */
					spd_GetForeignChildPlans(root, baserel, best_path, NULL, &push_scan_clauses,
											 outer_plan, childinfo, oid);
					exist_pushdown_child = false;
					break;
				}
			}
		}
		if (exist_pushdown_child)
		{
			fdw_scan_tlist = spd_merge_tlist(child_fdw_scan_tlist, ptemptlist, root);
			fdw_private->idx_url_tlist = get_index_spdurl_from_targets(fdw_scan_tlist, root);
			fdw_private->is_pushdown_tlist = true;
		}
		else
		{
			fdw_scan_tlist = NULL;
		}
		scan_relid = baserel->relid;
	}
	else
	{
		/* Aggregate push down */
		scan_relid = 0;
	}

	/* Calculate which condition should be filtered in core: when baserel is simple rel or when there is pseudoconstant (Example: WHERE false) */
	scan_clauses = NIL;
	if (fdw_private->baserestrictinfo )
	{
		/*
		 * In this case, PGSpider should filter baserestrictinfo because
		 * these are not passed to child fdw because of __spd_url
		 */
		foreach(lc, fdw_private->baserestrictinfo)
		{
			RestrictInfo *ri = lfirst_node(RestrictInfo, lc);

			/* When there is pseudoconstant, need to filter in core (Example: WHERE false) */
			if ((IS_SIMPLE_REL(baserel) && !push_scan_clauses) || ri->pseudoconstant)
				scan_clauses = lappend(scan_clauses, ri->clause);
		}
	}

	/*
	 * We collect local conditions each fdw did not push down to make
	 * postgresql core execute that filter
	 */
	if (IS_SIMPLE_REL(baserel))
	{
		for (i = 0; i < fdw_private->node_num; i++)
		{
			if (!childinfo[i].plan)
				continue;

			foreach(lc, childinfo[i].plan->qual)
			{
				Expr	   *expr = (Expr *) lfirst(lc);

				scan_clauses = list_append_unique_ptr(scan_clauses, expr);
			}
		}
	}
	/* for debug */
	if (log_min_messages <= DEBUG1 || client_min_messages <= DEBUG1)
		print_mapping_tlist(fdw_private->mapping_tlist, DEBUG1);

	/*
	 * Serialize fdw_private's members to a list. The list to be placed in the
	 * ForeignScan plan node, where they will be available to be deserialized
	 * at execution time The list must be represented in a form that
	 * copyObject knows how to copy.
	 */
	lfdw_private = spd_SerializeSpdFdwPrivate(fdw_private);

	return make_foreignscan(tlist,
							scan_clauses,	/* scan_clauses, */
							/* NULL, */
							scan_relid,
							NIL,
							lfdw_private,
							fdw_scan_tlist,
							NIL,
							outer_plan);
}

/**
 * Print error if any child is dead.
 *
 * @param[in] childnums
 * @param[in] childinfo
 */
static void
spd_PrintError(int childnums, ChildInfo * childinfo)
{
	int			i;
	ForeignServer *fs;

	for (i = 0; i < childnums; i++)
	{
		if (childinfo[i].child_node_status == ServerStatusDead)
		{
			fs = GetForeignServer(childinfo[i].server_oid);
			elog(WARNING, "Can not get data from %s", fs->servername);
		}
	}
}

/**
 * End all child node thread.
 *
 * @param[in] node
 */
static void
spd_end_child_node_thread(ForeignScanState *node, bool is_abort)
{
	int						node_incr;
	int						rtn;
	ForeignScanThreadInfo	*fssThrdInfo = node->spd_fsstate;
	SpdFdwPrivate 			*fdw_private;

	if (!fssThrdInfo)
		return;

	fdw_private = (SpdFdwPrivate *) fssThrdInfo[0].private;
	if (!fdw_private)
		return;

	/* print error nodes */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state == SPD_FS_STATE_ERROR)
		{
			fdw_private->childinfo[fssThrdInfo[node_incr].childInfoIndex].child_node_status = ServerStatusDead;
		}
	}
	if (isPrintError)
		spd_PrintError(fdw_private->node_num, fdw_private->childinfo);

	if (!fdw_private->is_explain)
	{
		/* Incase abort transaction, we no need to drop temp table, it will control by spi module */
		if (fdw_private->is_drop_temp_table == false && fdw_private->temp_table_name != NULL && !is_abort)
		{
			spd_spi_ddl_table(psprintf("DROP TABLE IF EXISTS %s", fdw_private->temp_table_name), fdw_private);
		}
		for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
		{
			fssThrdInfo[node_incr].requestEndScan = true;
			/* Cleanup the thread-local structures */
			rtn = pthread_join(fdw_private->foreign_scan_threads[node_incr], NULL);
			if (rtn != 0)
				elog(WARNING, "error is occurred, pthread_join fail in EndForeignScan. ");
		}
	}
}

/**
 * Callback function to be called before Abort Transaction.
 *
 * @param[in] arg ForeignScanState
 */
static void
spd_abort_transaction_callback(void *arg)
{
	AssertArg(arg);

	if (IsA(arg, ForeignScanState))
		spd_end_child_node_thread((ForeignScanState *)arg, true);
}

/**
 * Callback function to be called when context reset/delete.
 * Reset error context stack and re-enable register reset
 * callback flag and unregister all abort callback.
 *
 * @param[in] arg
 */
static void
spd_reset_callback(void *arg)
{
	registered_reset_callback = false;
	AtFinishTransaction();
}

/**
 * Register a function to be called when context reset/delete.
 *
 * @param[in] query_context MemoryContext
 */
static void
spd_register_reset_callback(MemoryContext query_context)
{
	if (!registered_reset_callback)
	{
		MemoryContextCallback *cb = MemoryContextAlloc(query_context, sizeof(MemoryContextCallback));

		registered_reset_callback = true;

		cb->arg = NULL;
		cb->func = spd_reset_callback;
		MemoryContextRegisterResetCallback(query_context, cb);
	}
}

/**
 *
 * Main thread setup ForeignScanState for child fdw, including
 * tuple descriptor.
 * First, get all child's table information.
 * Next, set information and create child's thread.
 *
 * @param[in] node - main thread foreign scan state
 * @param[in] eflags
 */

static void
spd_BeginForeignScan(ForeignScanState *node, int eflags)
{
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	ForeignScanThreadInfo *fssThrdInfo;
	EState	   *estate = node->ss.ps.state;
	int			thread_create_err;
	Oid			server_oid;
	SpdFdwPrivate *fdw_private;
	int			node_incr;		/* node_incr is variable of number of
								 * fssThrdInfo. */
	ChildInfo  *childinfo;
	int			i,
				k;
	Query	   *query;
	RangeTblEntry *rte;

	/*
	 * Register callback to query memory context to reset normalize id hash
	 * table at the end of the query
	 */
	hash_register_reset_callback(estate->es_query_cxt);
	node->spd_fsstate = NULL;

	/* Deserialize fdw_private list to SpdFdwPrivate object */
	fdw_private = spd_DeserializeSpdFdwPrivate(fsplan->fdw_private);

	/*
	 * In case of Aggregation, a temptable will be created according to the child compress list.
	 * Init an empty slot, it will be used to add __spd_url to temp table.
	 */
	if (fdw_private->groupby_has_spdurl)
	{
		TupleDesc	tupledesc;
		ListCell 	*lc;
		int 		i = 0;

		/*
		 * When we add __spd_url back to parent node, we need to create tuple
		 * descriptor for parent slot according to child comp tlist.
		 */
		tupledesc = CreateTemplateTupleDesc(list_length(fdw_private->child_comp_tlist));
		foreach(lc, fdw_private->child_comp_tlist)
		{
			TargetEntry *ent = (TargetEntry *) lfirst(lc);

			TupleDescInitEntry(tupledesc, i + 1, NULL, exprType((Node *) ent->expr), -1, 0);
			i++;

		}

		/* Construct TupleDesc, and assign a local typmod. */
		tupledesc = BlessTupleDesc(tupledesc);
		fdw_private->child_comp_tupdesc = CreateTupleDescCopy(tupledesc);

		/* Init temporary slot for adding __spd_url back */
		fdw_private->child_comp_slot = MakeSingleTupleTableSlot(CreateTupleDescCopy(fdw_private->child_comp_tupdesc), &TTSOpsHeapTuple);
	}

	/* Create temporary context */
	fdw_private->es_query_cxt = estate->es_query_cxt;

	/*
	 * Not return from this function unlike usual fdw BeginForeignScan
	 * implementation because we need to create ForeignScanState for child
	 * fdws. It is assigned to fssThrdInfo[node_incr].fsstate.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		fdw_private->is_explain = true;

	/* Type of Query to be used for computing intermediate results */
#ifdef GETPROGRESS_ENABLED
	if (fdw_private->agg_query)
		node->ss.ps.state->es_progressState->ps_aggQuery = true;
	else
		node->ss.ps.state->es_progressState->ps_aggQuery = false;
	if (getResultFlag)
		return;
	/* Supporting for Progress */
	node->ss.ps.state->es_progressState->ps_totalRows = 0;
	node->ss.ps.state->es_progressState->ps_fetchedRows = 0;
#endif

	node->ss.ps.state->agg_query = 0;
	/* Get all the foreign nodes from conf file */
	fssThrdInfo = (ForeignScanThreadInfo *) palloc0(sizeof(ForeignScanThreadInfo) * fdw_private->node_num);
	node->spd_fsstate = fssThrdInfo;

	node_incr = 0;
	childinfo = fdw_private->childinfo;

	for (i = 0; i < fdw_private->node_num; i++)
	{
		Relation	rd;
		int			natts;
		TupleDesc	tupledesc;
		bool		skiplast;

		/*
		 * check child table node is dead or alive. Execute(Create child
		 * thread) alive table node only. So, childinfo[i] and fssThrdInfo[i]
		 * do not corresponds
		 */
		if (childinfo[i].child_node_status != ServerStatusAlive)
		{
			/* Not increment node_incr in this case */
			continue;
		}
		server_oid = childinfo[i].server_oid;
#ifdef GETPROGRESS_ENABLED
		if (getResultFlag)
			break;
#endif
		fssThrdInfo[node_incr].fsstate = makeNode(ForeignScanState);
		memcpy(&fssThrdInfo[node_incr].fsstate->ss, &node->ss, sizeof(ScanState));
		/* copy Agg plan when psuedo aggregation case. */
		if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
		{
			/* Not push down aggregate to child fdw */
			fssThrdInfo[node_incr].fsstate->ss.ps.plan = copyObject(childinfo[i].plan);
		}
		else
		{
			/* Push down case */
			fssThrdInfo[node_incr].fsstate->ss = node->ss;
			fssThrdInfo[node_incr].fsstate->ss.ps.plan = copyObject(node->ss.ps.plan);
		}
		fsplan = (ForeignScan *) fssThrdInfo[node_incr].fsstate->ss.ps.plan;
		fsplan->scan.scanrelid = ((ForeignScan *)childinfo[i].plan)->scan.scanrelid;
		fsplan->fdw_private = ((ForeignScan *) childinfo[i].plan)->fdw_private;
		fsplan->fdw_exprs = ((ForeignScan *) childinfo[i].plan)->fdw_exprs;

		/* Create and initialize EState */
		fssThrdInfo[node_incr].fsstate->ss.ps.state = CreateExecutorState();
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_top_eflags = eflags;
		fssThrdInfo[node_incr].fsstate->ss.ps.ps_ExprContext = CreateExprContext(estate);

		/* Init external params */
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_param_list_info =
				copyParamList(estate->es_param_list_info);

		/* This should be a new RTE list. coming from dummy rtable */
		query = ((PlannerInfo *) childinfo[i].root)->parse;

		rte = lfirst_node(RangeTblEntry, list_head(query->rtable));

		if (query->rtable->length != estate->es_range_table->length)
			for (k = query->rtable->length; k < estate->es_range_table->length; k++)
				query->rtable = lappend(query->rtable, rte);

		/*
		 * Init range table, in which we use range table array for exec_rt_fetch() because it is faster than rt_fetch().
		 */
		ExecInitRangeTable(fssThrdInfo[node_incr].fsstate->ss.ps.state, query->rtable);
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_plannedstmt = copyObject(node->ss.ps.state->es_plannedstmt);
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_plannedstmt->planTree = copyObject(fssThrdInfo[node_incr].fsstate->ss.ps.plan);
		/* Allocate top memory context for each thread to avoid race condtion */
		if (thread_top_contexts[node_incr] == NULL)
		{
			thread_top_contexts[node_incr] = AllocSetContextCreate(TopMemoryContext,
																   "thread top memory context",
																   ALLOCSET_DEFAULT_MINSIZE,
																   ALLOCSET_DEFAULT_INITSIZE,
																   ALLOCSET_DEFAULT_MAXSIZE);
		}
		fssThrdInfo[node_incr].threadTopMemoryContext = thread_top_contexts[node_incr];

		/*
		 * memory context tree: paraent es_query_cxt -> threadMemoryContext ->
		 * child es_query_cxt -> child expr context
		 */
		fssThrdInfo[node_incr].threadMemoryContext =
			AllocSetContextCreate(estate->es_query_cxt,
								  "thread memory context",
								  ALLOCSET_DEFAULT_MINSIZE,
								  ALLOCSET_DEFAULT_INITSIZE,
								  ALLOCSET_DEFAULT_MAXSIZE);

		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_query_cxt =
			AllocSetContextCreate(fssThrdInfo[node_incr].threadMemoryContext,
								  "thread es_query_cxt",
								  ALLOCSET_DEFAULT_MINSIZE,
								  ALLOCSET_DEFAULT_INITSIZE,
								  ALLOCSET_DEFAULT_MAXSIZE);

		fssThrdInfo[node_incr].eflags = eflags;

		/*
		 * current relation ID gets from current server oid, it means
		 * childinfo[i].oid
		 */
		rd = RelationIdGetRelation(childinfo[i].oid);

		/*
		 * For prepared statement, dummy root is not created at the next execution, so we need to lock relation again.
		 * We don't need unlock relation because lock will be released at transaction end.
		 * https://www.postgresql.org/docs/12/sql-lock.html
		 */
		if (!CheckRelationLockedByMe(rd, AccessShareLock, true))
		{
			LockRelationOid(childinfo[i].oid, AccessShareLock);
		}

		fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;

		fssThrdInfo[node_incr].requestEndScan = false;
		fssThrdInfo[node_incr].requestRescan = false;
		/*
		 * If query has no parameter, to improve performance, it can be executed immediately.
		 * If query has parameter, sub-plan needs to be initialized, so it needs to wait the core engine
		 * initializes the sub-plan.
		 */
		if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
		{
			/* Not push down aggregate to child fdw */
			fssThrdInfo[node_incr].requestStartScan = (node->ss.ps.state->es_subplanstates == NIL);
		}
		else
		{
			/* Push down case */
			fssThrdInfo[node_incr].requestStartScan = (fsplan->fdw_exprs == NIL);
		}

		/* We save correspondence between fssThrdInfo and childinfo */
		fssThrdInfo[node_incr].childInfoIndex = i;
		childinfo[i].index_threadinfo = node_incr;

		fssThrdInfo[node_incr].serverId = server_oid;
		fssThrdInfo[node_incr].fdwroutine = GetFdwRoutineByServerId(server_oid);

		/*
		 * GetForeignServer and GetForeignDataWrapper are slow. So we will
		 * cache here
		 */
		fssThrdInfo[node_incr].foreignServer = GetForeignServer(server_oid);
		fssThrdInfo[node_incr].fdw = GetForeignDataWrapper(fssThrdInfo[node_incr].foreignServer->fdwid);

		fssThrdInfo[node_incr].thrd_ResourceOwner =
			ResourceOwnerCreate(CurrentResourceOwner, "thread resource owner");
		fssThrdInfo[node_incr].private = fdw_private;

		if (fdw_private->agg_query)
		{
			/*
			 * Create child descriptor using child_tlist
			 */
			int			child_attr = 0; /* attribute number of child */
			ListCell   *lc;

			tupledesc = CreateTemplateTupleDesc(list_length(fdw_private->child_tlist));

			foreach(lc, fdw_private->child_tlist)
			{
				TargetEntry *ent = (TargetEntry *) lfirst(lc);

				TupleDescInitEntry(tupledesc, child_attr + 1, NULL, exprType((Node *) ent->expr), -1, 0);
				child_attr++;
			}
			/* Construct TupleDesc, and assign a local typmod. */
			tupledesc = BlessTupleDesc(tupledesc);
			if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
			{
				/*
				 * Create tuple slot based on *child* ForeignScan plan target
				 * list. This tuple is for ExecAgg and different from one used
				 * in queue.
				 */
				fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(ExecCleanTypeFromTL(fssThrdInfo[node_incr].fsstate->ss.ps.plan->targetlist), node->ss.ss_ScanTupleSlot->tts_ops);
			}
			else
			{
				/*
				 * If child plan has local conditions that applied for HAVING clause,
				 * then we need to create more child slots for aggreate targets that
				 * extracted from these local conditions.
				 */
				if (childinfo[i].plan->qual)
				{
					List *child_tlist = list_copy(fdw_private->child_tlist);
					List *aggvars = NIL;

					foreach(lc, childinfo[i].plan->qual)
					{
						Expr *clause = (Expr *) lfirst(lc);

						aggvars = list_concat(aggvars, pull_var_clause((Node *) clause, PVC_INCLUDE_AGGREGATES));
					}
					foreach(lc, aggvars)
					{
						Expr *expr = (Expr *) lfirst(lc);

						/*
						 * If aggregates within local conditions are not safe to push down by child FDW,
						 * then we add aggregates to child target list.
						 */
						if (IsA(expr, Aggref))
						{
							child_tlist = add_to_flat_tlist(child_tlist, list_make1(expr));
						}
					}

					/* Create child slots based on child target list. */
					fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(ExecCleanTypeFromTL(child_tlist), node->ss.ss_ScanTupleSlot->tts_ops);
				}
				else
					fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
						MakeSingleTupleTableSlot(CreateTupleDescCopy(tupledesc), node->ss.ss_ScanTupleSlot->tts_ops);
			}

		}
		else
		{
			/*
			 * Create tuple slot based on *parent* ForeignScan tuple
			 * descriptor
			 */

			tupledesc = CreateTupleDescCopy(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor);

			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
				MakeSingleTupleTableSlot(tupledesc, node->ss.ss_ScanTupleSlot->tts_ops);
		}

		/*
		 * For non-aggregate query, tupledesc we use for a queue has __spd_url
		 * column at the last because it has all table columns. This is
		 * inconsistent with the child tuple except for pgspider_fdw and cause
		 * problems when copying to a queue. To avoid it, we will skip copy of
		 * the last element of tuple. Execeptions are target list pushdown
		 * case where as in aggregate query case, tuple descriptor corresponds
		 * to a target list from which spd_url is removed.
		 */
		skiplast = false;
		if (!fdw_private->agg_query &&
			!fdw_private->is_pushdown_tlist &&
			strcmp(fssThrdInfo[node_incr].fdw->fdwname, PGSPIDER_FDW_NAME) != 0)
			skiplast = true;

		spd_queue_init(&fssThrdInfo[node_incr].tupleQueue, tupledesc, node->ss.ss_ScanTupleSlot->tts_ops, skiplast);

		natts = fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts;

		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_mcxt = node->ss.ss_ScanTupleSlot->tts_mcxt;
		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_values = (Datum *)
			MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, natts * sizeof(Datum));
		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_isnull = (bool *)
			MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, natts * sizeof(bool));


		/*
		 * For explain case, call BeginForeignScan because some
		 * fdws(ex:mysql_fdw) requires BeginForeignScan is already called when
		 * ExplainForeignScan is called . For non explain case, child threads
		 * call BeginForeignScan
		 */
		if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		{
			fssThrdInfo[node_incr].fdwroutine->BeginForeignScan(fssThrdInfo[node_incr].fsstate,
																eflags);
		}

		node_incr++;
	}

	fdw_private->nThreads = node_incr;

	/* Skip thread creation in explain case */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
	{
		return;
	}

	/*
	 * PGSpider need to notify all childs node thread to quit
	 * before memory context of thread is release and avoid child
	 * node thread access to Transaction State. We register abort
	 * transaction call back for each node. In case error, backend
	 * call AbortTransaction, we will call abort transaction callback
	 * to quit all threads avoid thread access to free memory zone
	 * and Transaction State.
	 */
	RegisterAbortTransactionCallback(spd_abort_transaction_callback, (void *)node);

	/*
	 * We register ResetCallback for es_query_cxt to unregister
	 * abort transaction call back when finish transaction.
	 */
	spd_register_reset_callback(estate->es_query_cxt);

	for (i = 0; i < fdw_private->nThreads; i++)
	{
		thread_create_err =
			pthread_create(&fdw_private->foreign_scan_threads[i],
						   NULL,
						   &spd_ForeignScan_thread,
						   (void *) &fssThrdInfo[i]);
		if (thread_create_err != 0)
		{
			ereport(ERROR, (errmsg("Cannot create thread! error=%d",
								   thread_create_err)));
		}
	}


	/* Wait for state change */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state == SPD_FS_STATE_INIT)
		{
			pthread_yield();
			node_incr--;
			continue;
		}
	}
	fdw_private->isFirst = true;
	return;
}

/**
 * spd_spi_ddl_table
 *
 * This is called by aggregate Push-down case. Execute DDL query(especially CREATE temp table)
 *
 * @param[in] query
 */

static void
spd_spi_ddl_table(char *query, SpdFdwPrivate *fdw_private)
{
	int			ret;

	SPD_WRITE_LOCK_TRY(&fdw_private->scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	ret = SPI_exec(query, 1);
	elog(DEBUG1, "execute temp table DDL: %s", query);
	if (ret != SPI_OK_UTILITY)
	{
		elog(ERROR, "execute spi CREATE TEMP TABLE failed %d", ret);
	}
	SPI_finish();
	SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);
}
/**
 * spd_spi_insert_table
 *
 * This is called by aggregate Push-down case. Insert results of child node into temp table.
 *
 * @param[in] slot
 * @param[in] node
 * @param[in,out] fdw_private
 */
static void
spd_spi_insert_table(TupleTableSlot *slot, ForeignScanState *node, SpdFdwPrivate * fdw_private)
{
	int			ret;
	int			i;
	int			colid = 0;
	bool		isfirst = true;
	StringInfo	sql = makeStringInfo();
	List	   *mapping_tlist;
	ListCell   *lc;
	StringInfo	debugValues = makeStringInfo();

	/* For execute query */
	Oid* argtypes = palloc0(sizeof(Oid));
	Datum* values = palloc0(sizeof(Datum));
	char* nulls = palloc0(sizeof(char));

	SPD_WRITE_LOCK_TRY(&fdw_private->scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	appendStringInfo(sql, "INSERT INTO %s VALUES( ", fdw_private->temp_table_name);
	colid = 0;
	mapping_tlist = fdw_private->mapping_tlist;
	foreach(lc, mapping_tlist)
	{
		Extractcells *extcells = (Extractcells *) lfirst(lc);
		ListCell	 *extlc;

		foreach(extlc, extcells->cells)
		{
			Mappingcells *mapcels = (Mappingcells *) lfirst(extlc);
			Datum		attr;
			char		*value;
			bool		isnull;
			Oid			typoutput;
			bool		typisvarlena;
			int			child_typid;

			for (i = 0; i < MAX_SPLIT_NUM; i++)
			{
				Form_pg_attribute sattr = TupleDescAttr(slot->tts_tupleDescriptor, colid);

				if (colid != mapcels->mapping[i])
					continue;

				/* Realloc memory when there are more than 1 column */
				if (colid > 0)
				{
					argtypes = repalloc(argtypes, (colid + 1) * sizeof(Oid));
					values = repalloc(values, (colid + 1) * sizeof(Datum));
					nulls = repalloc(nulls, (colid + 1) * sizeof(char));
				}
				if (isfirst)
					isfirst = false;
				else
					appendStringInfo(sql, ",");
				/* Append place holder */
				appendStringInfo(sql, "$%d", colid + 1);

				getTypeOutputInfo(sattr->atttypid, &typoutput, &typisvarlena);
				child_typid = exprType((Node *) ((TargetEntry *) list_nth(fdw_private->child_comp_tlist, colid))->expr);

				/* 
				* SPI_execute_with_args receives a nulls array.
				* If the value is not null, value of entry will be ' '.
				* If the value is null, value of entry will be 'n'.
				*/
				nulls[colid] = ' ';

				/* Set data type */
				argtypes[colid] = child_typid;

				/* Set value */
				attr = slot_getattr(slot, mapcels->mapping[i] + 1, &isnull);
				if (isnull)
				{
					nulls[colid] = 'n';
					colid++;
					continue;
				}
				value = OidOutputFunctionCall(typoutput, attr);
				appendStringInfo(debugValues, "%s, ", value != NULL?value:"");
				/* Not null */
				values[colid] = attr;
				/* Set data for special data */
				if (sattr->atttypid == UNKNOWNOID) 
				{
					argtypes[colid] = TEXTOID;
					if (!isnull)
						values[colid] = CStringGetTextDatum(DatumGetCString(values[colid]));
				}
				else if (!isnull) 
				{
					int16 typLen;
					bool  typByVal;

					/* Copy datum to current context */
					get_typlenbyval(sattr->atttypid, &typLen, &typByVal);
					if (!typByVal) {
						if (typisvarlena) {
							/* Need to copy data to */
							values[colid] = PointerGetDatum(PG_DETOAST_DATUM_COPY(values[colid]));
						} 
						else 
						{
							values[colid] = datumCopy(values[colid], typByVal, typLen);
						}
					}
				}
				colid++;
			}
		}
	}
	appendStringInfo(sql, ")");
	elog(DEBUG1, "insert into temp table: %s, values: %s", sql->data, debugValues->data);
	ret = SPI_execute_with_args(sql->data, colid, argtypes, values, nulls, false, 1);
	if (ret != SPI_OK_INSERT)
		elog(ERROR, "execute spi INSERT TEMP TABLE failed ");
	SPI_finish();

	SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);

}

/**
 * datum_is_converted
 * 
 * This function is used to convert datum value to expected data type (data type of column of temp table)
 * when data type of column of temp table is different from returned data type of query.
 * If this function cannot convert or no need to convert, return false.
 * 
 * @param[in] original_type
 * @param[in] original_value
 * @param[in] expected_type
 * @param[in,out] expected_value
 */
static bool
datum_is_converted(Oid original_type, Datum original_value, Oid expected_type, Datum *expected_value, bool is_truncated)
{
	Datum value;
	PGFunction conversion_func = NULL;
	bool unexpected = false;
	bool rounded_up = false;

	switch (original_type)
	{
		case NUMERICOID:
			if (expected_type == INT8OID)
			{
				conversion_func = numeric_int8;

				if (is_truncated)
				{
					/* Check if the value will be rounded up by numeric_int8 */
					char *tmp;
					double tmp_dbl_val;

					tmp = DatumGetCString(DirectFunctionCall1(numeric_out, original_value));
					tmp_dbl_val = strtod(tmp, NULL);
					if ((tmp_dbl_val - trunc(tmp_dbl_val)) >= 0.5)
					{
						rounded_up = true;
					}
				}
			}
			else
				unexpected = true;
			break;
		case FLOAT8OID:
			if (expected_type == FLOAT4OID)
				conversion_func = dtof;
			else if (expected_type == NUMERICOID)
				conversion_func = float8_numeric;
			else
				unexpected = true;
			break;
		case INT8OID:
			if (expected_type == INT4OID)
				conversion_func = int84;
			else
				unexpected = true;
			break;
		case TEXTARRAYOID:
			if (expected_type == TIMESTAMPARRAYOID)
				break;	/* No need to convert */
			else
				unexpected = true;
			break;
		case TEXTOID:
			if (expected_type == VARCHAROID)
				break;	/* No need to convert */
			else
				unexpected = true;
			break;
		default:
			unexpected = true;
			break;
	}

	if (conversion_func != NULL)
	{
		value = DirectFunctionCall1(conversion_func, original_value);
		/* 
		 * When need to truncated but value is rounded up by numeric_int8 function,
		 * decrease value by 1 to get expected value
		 */
		if (is_truncated == true && rounded_up == true)
			value--;
		*expected_value = value;
		return true;
	}
	else
	{
		/* Display a warning message when there is unexpected case */
		if (unexpected == true)
			elog(WARNING, "Found an unexpected case when converting data to expected data of temp table. The value will be copied without conversion.");
		return false;
	}
}

/**
 * emit_context_error
 *
 * This callback function is used to display error message without context
 */
static void
emit_context_error(void* context)
{
	ErrorData *err;
	MemoryContext oldcontext;

	oldcontext = MemoryContextSwitchTo(context);
	err = CopyErrorData();
	MemoryContextSwitchTo(oldcontext);

	/* Display error without displaying context */
	if (strcmp(err->message, "cannot take square root of a negative number") == 0)
		elog(ERROR, "%s", "Can not return value because of rounding problem from child node");
	else
		elog(err->elevel, "%s", err->message);
}

/**
 * spd_exec_select
 *
 * This is called by aggregate Push-down case.
 * Execute SELECT query and store result to fdw_private->agg_values.
 *
 * @param[in,out] fdw_private
 * @param[in] sql
 */
static void
spd_spi_exec_select(SpdFdwPrivate * fdw_private, StringInfo sql)
{
	int			ret;
	int			i,
				k;
	int			colid = 0;
	MemoryContext oldcontext;
	ListCell   *lc;
	ErrorContextCallback errcallback;

	SPD_WRITE_LOCK_TRY(&fdw_private->scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/* Set up callback to display error without CONTEXT information */
	errcallback.callback = emit_context_error;
	errcallback.arg = fdw_private->es_query_cxt;
	errcallback.previous = NULL;
	error_context_stack = &errcallback;

	ret = SPI_exec(sql->data, 0);

	if (ret != SPI_OK_SELECT)
		elog(ERROR, "execute spi SELECT TEMP TABLE failed ");
	if (SPI_processed == 0)
	{
		SPI_finish();
		goto end;
	}

	/*
	 * Store memory of new agg tuple. It will be used in next iterate foreign
	 * scan in spd_select_return_aggslot.
	 */
	oldcontext = MemoryContextSwitchTo(fdw_private->es_query_cxt);

	fdw_private->agg_values = (Datum **) palloc0(SPI_processed * sizeof(Datum *));
	fdw_private->agg_nulls = (bool **) palloc0(SPI_processed * sizeof(bool *));

	/*
	 * Length of agg_value_type, agg_values[i] and agg_nulls[i] are the number
	 * of columns of the temp table
	 */
	fdw_private->agg_value_type = (Oid *) palloc0(fdw_private->temp_num_cols * sizeof(Oid));
	for (i = 0; i < SPI_processed; i++)
	{
		fdw_private->agg_values[i] = (Datum *) palloc0(fdw_private->temp_num_cols * sizeof(Datum));
		fdw_private->agg_nulls[i] = (bool *) palloc0(fdw_private->temp_num_cols * sizeof(bool));
	}
	/* In case Rescan, we need to reinitial agg_num variable */
	fdw_private->agg_num = 0;
	fdw_private->agg_tuples = SPI_processed;
	for (k = 0; k < SPI_processed; k++)
	{
		colid = 0;
		foreach(lc, fdw_private->mapping_tlist)
		{
			Extractcells		*extcells = (Extractcells *) lfirst(lc);
			Oid					expected_type = exprType((Node *) extcells->expr);
			Datum				datum;
			Form_pg_attribute	attr = TupleDescAttr(SPI_tuptable->tupdesc, colid);
			bool				isnull = false;

			if (extcells->is_having_qual)
				continue;

			fdw_private->agg_value_type[colid] = attr->atttypid;

			datum = SPI_getbinval(SPI_tuptable->vals[k],
								SPI_tuptable->tupdesc,
								colid + 1,
								&isnull);
			
			if (isnull)
				fdw_private->agg_nulls[k][colid] = true;
			else if (fdw_private->agg_value_type[colid] != expected_type)	/* Only convert when data type of column of temp table is different from returned data */
			{
				if (datum_is_converted(fdw_private->agg_value_type[colid], datum, expected_type, 
											&fdw_private->agg_values[k][colid], extcells->is_truncated))
				{
					fdw_private->agg_value_type[colid] = expected_type;
				}
				else
				{
					/* Copy datum */
					fdw_private->agg_values[k][colid] = datumCopy(datum,
															attr->attbyval,
															attr->attlen);
				}
			}
			else
			{
				/* We need to deep copy datum from SPI memory context */
				fdw_private->agg_values[k][colid] = datumCopy(datum,
															attr->attbyval,
															attr->attlen);
			}

			colid++;
		}
	}
	Assert(colid == fdw_private->temp_num_cols);

	MemoryContextSwitchTo(oldcontext);
	SPI_finish();
end:;
	SPD_RWUNLOCK_CATCH(&fdw_private->scan_mutex);
}

/**
 * spd_calc_aggvalues
 *
 * This is called by aggregate Push-down case.
 * Calculate one result row specified by 'rowid' and store it to 'slot'.
 *
 * @param[in] fdw_private
 * @param[in] rowid - index of fdw_private->agg_values
 * @param[out] slot
 */

static void
spd_calc_aggvalues(SpdFdwPrivate * fdw_private, int rowid, TupleTableSlot *slot)
{
	Datum	   		*ret_agg_values;
	HeapTuple		tuple;
	bool	   		*nulls;
	int				target_column;	/* Number of target in slot */
	int				map_column;		/* Number of target in query */
	ListCell		*lc;
	Mappingcells	*mapcells;

	/* Clear Tuple if agg results is empty */
	if (!fdw_private->agg_values)
	{
		ExecClearTuple(slot);
		fdw_private->agg_num++;
		return;
	}

	target_column = 0;
	map_column = 0;
	ret_agg_values = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
	nulls = (bool *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(bool));

	foreach(lc, fdw_private->mapping_tlist)
	{
		Extractcells	*extcells = lfirst(lc);
		ListCell		*extlc;
		
		extlc = list_head(extcells->cells);
		mapcells = (Mappingcells *) lfirst(extlc);
		
		if (target_column != mapcells->original_attnum)
		{
			map_column++;
			continue;
		}
		
		if (fdw_private->agg_nulls[rowid][map_column])
			nulls[target_column] = true;
		ret_agg_values[target_column] = fdw_private->agg_values[rowid][map_column];
		
		target_column++;
		map_column++;
	}

	if ((TTS_IS_HEAPTUPLE(slot) && ((HeapTupleTableSlot*) slot)->tuple)){
		tuple = heap_form_tuple(slot->tts_tupleDescriptor, ret_agg_values, nulls);
		ExecStoreHeapTuple(tuple, slot, false);
	}else{
		slot->tts_values = ret_agg_values;
		slot->tts_isnull = nulls;
		/* to avoid assert failure in ExecStoreVirtualTuple, set tts_flags empty */
		slot->tts_flags |= TTS_FLAG_EMPTY;
		ExecStoreVirtualTuple(slot);
	}

	fdw_private->agg_num++;
}

/**
 * rebuild_target_expr
 * 
 * This function rebuilds the target expression which will be used on temp table.
 * It is based on the original expression and the mapping data.
 * 
 * @param[in] node - Original expression
 * @param[in,out] buf - Target expression
 * @param[in] extcells - Extracted cells which contains mapping data
 * @param[in] cellid -  The cell id which will be mapped
 * @param[in] isfirst - True if this expression is the first expression in query
 */
static void
rebuild_target_expr(Node* node, StringInfo buf, Extractcells *extcells, int *cellid, List *groupby_target, bool isfirst)
{
	if (node == NULL)
		return;

	switch(nodeTag(node))
	{
		case T_OpExpr:
		{
			OpExpr				*ope = (OpExpr *) node;
			HeapTuple			tuple;
			Form_pg_operator	form;
			char				oprkind;
			char				*opname;
			ListCell			*arg;
			bool				is_extract_expr;

			/* Retrieve information about the operator from system catalog. */
			tuple = SearchSysCache1(OPEROID, ObjectIdGetDatum(ope->opno));
			if (!HeapTupleIsValid(tuple))
				elog(ERROR, "cache lookup failed for operator %u", ope->opno);
			form = (Form_pg_operator) GETSTRUCT(tuple);
			oprkind = form->oprkind;

			/* Always parenthesize the expression. */
			appendStringInfoChar(buf, '(');

			if (extcells->is_having_qual)
				is_extract_expr = true;
			else
				is_extract_expr = is_need_extract((Node *)ope);

			if (!is_extract_expr)
			{
				ListCell *extlc;
				int id = 0;

				foreach(extlc, extcells->cells)
				{
					/* Find the mapping cell */
					Mappingcells *cell = (Mappingcells *) lfirst(extlc);
					int mapping;
					if (id != (*cellid))
					{
						id++;
						continue;
					}

					mapping = cell->mapping[0];
					/*
					 * Ex: SUM(i)/2
					 */
					if (!list_member_int(groupby_target, mapping))
					{
						appendStringInfo(buf, "SUM(col%d)", mapping);
					}

					/*
					 * This is GROUP BY target. Ex: 't' in select sum(i),t
					 * from t1 group by t
					 */
					else
					{
						appendStringInfo(buf, "col%d", mapping);
					}
					break;
				}
				(*cellid)++;
			}
			else
			{
				/* Deparse left operand. */
				if (oprkind == 'r' || oprkind == 'b')
				{
					arg = list_head(ope->args);
					rebuild_target_expr(lfirst(arg), buf, extcells, cellid, groupby_target, isfirst);
					appendStringInfoChar(buf, ' ');
				}

				/* Set operator name. */
				opname = NameStr(form->oprname);
				appendStringInfoString(buf, opname);

				/* If operator is division, need to truncate. Set is_truncate to true */
				if (strcmp(opname, "/") == 0)
					extcells->is_truncated = true;

				/* Deparse right operand. */
				if (oprkind == 'l' || oprkind == 'b')
				{
					arg = list_tail(ope->args);
					appendStringInfoChar(buf, ' ');
					rebuild_target_expr(lfirst(arg), buf, extcells, cellid, groupby_target, isfirst);
				}
			}
			appendStringInfoChar(buf, ')');

			ReleaseSysCache(tuple);
			break;
		}
		case T_Aggref:
		{
			ListCell	*extlc;
			int			id = 0;
			Aggref *	aggref = (Aggref *) node;
			bool		has_Order_by = aggref->aggorder?true:false;

			foreach(extlc, extcells->cells)
			{
				/* Find the mapping cell */
				Mappingcells *cell = (Mappingcells *) lfirst(extlc);
				int mapping;
				if (id != (*cellid))
				{
					id++;
					continue;
				}

				switch (cell->aggtype)
				{
					case AVG_FLAG:
					{
						/* Use CASE WHEN to avoid division by zero error */
						if (has_Order_by)
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 THEN NULL ELSE (SUM(col%d ORDER BY col%d)/SUM(col%d))::float8 END)", cell->mapping[0], cell->mapping[1], cell->mapping[1], cell->mapping[0]);
						else
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 THEN NULL ELSE (SUM(col%d)/SUM(col%d))::float8 END)", cell->mapping[0], cell->mapping[1], cell->mapping[0]);
						break;
					}
					case VAR_FLAG:
					{
						/* Use CASE WHEN to avoid division by zero error */
						if (has_Order_by)
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 OR SUM(col%d) = 1 THEN NULL ELSE ((SUM(col%d ORDER BY col%d) - POWER(SUM(col%d ORDER BY col%d), 2)/SUM(col%d))/(SUM(col%d) - 1))::float8 END)", 
									cell->mapping[0], cell->mapping[0], cell->mapping[2], cell->mapping[2], cell->mapping[1], cell->mapping[1], cell->mapping[0], cell->mapping[0]);
						else
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 OR SUM(col%d) = 1 THEN NULL ELSE ((SUM(col%d) - POWER(SUM(col%d), 2)/SUM(col%d))/(SUM(col%d) - 1))::float8 END)", 
									cell->mapping[0], cell->mapping[0], cell->mapping[2], cell->mapping[1], cell->mapping[0], cell->mapping[0]);
						break;
					}
					case DEV_FLAG:
					{
						/* Use CASE WHEN to avoid division by zero error */
						if (has_Order_by)
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 OR SUM(col%d) = 1 THEN NULL ELSE (sqrt((SUM(col%d ORDER BY col%d) - POWER(SUM(col%d ORDER BY col%d), 2)/SUM(col%d))/(SUM(col%d) - 1)))::float8 END)", 
								cell->mapping[0], cell->mapping[0], cell->mapping[2], cell->mapping[2], cell->mapping[1], cell->mapping[1], cell->mapping[0], cell->mapping[0]);
						else
							appendStringInfo(buf, "(CASE WHEN SUM(col%d) = 0 OR SUM(col%d) = 1 THEN NULL ELSE (sqrt((SUM(col%d) - POWER(SUM(col%d), 2)/SUM(col%d))/(SUM(col%d) - 1)))::float8 END)", 
									cell->mapping[0], cell->mapping[0], cell->mapping[2], cell->mapping[1], cell->mapping[0], cell->mapping[0]);
						break;
					}
					case SPREAD_FLAG:
					{
						appendStringInfo(buf, "MAX(col%d) - MIN(col%d)", cell->mapping[1], cell->mapping[0]);
						break;
					}
					default:
					{
						char	   *agg_command = cell->agg_command->data;
						char		*agg_const = cell->agg_const->data;		/* constant argument of function */
						mapping = cell->mapping[0];

						/* If original aggregate function is count, change to sum to count all data from multiple nodes */
						if (!pg_strcasecmp(agg_command, "SUM") || !pg_strcasecmp(agg_command, "COUNT"))
							if (has_Order_by)
								appendStringInfo(buf, "SUM(col%d ORDER BY col%d)", mapping, mapping);
							else
								appendStringInfo(buf, "SUM(col%d)", mapping);
						else if (!pg_strcasecmp(agg_command, "MAX") || !pg_strcasecmp(agg_command, "MIN") ||
								!pg_strcasecmp(agg_command, "BIT_OR") || !pg_strcasecmp(agg_command, "BIT_AND") ||
								!pg_strcasecmp(agg_command, "BOOL_AND") || !pg_strcasecmp(agg_command, "BOOL_OR") ||
								!pg_strcasecmp(agg_command, "EVERY") || !pg_strcasecmp(agg_command, "XMLAGG"))
							appendStringInfo(buf, "%s(col%d)", agg_command, mapping);

						/*
						 * This is for string_agg function. This function require delimiter to work
						 */
						else if (!pg_strcasecmp(agg_command, "STRING_AGG"))
						{
							appendStringInfo(buf, "%s(col%d, %s)", agg_command, mapping, agg_const);
						}
						/*
						 * This is for influx db functions. MAX has not effect to
						 * result. We have to consider multi-tenant.
						 */
						else if (!pg_strcasecmp(agg_command, "INFLUX_TIME") || !pg_strcasecmp(agg_command, "LAST"))
							appendStringInfo(buf, "MAX(col%d)", mapping);

						/*
						 * Other aggregation not listed above. TODO: SUM may be
						 * incorrect for multi-tenant table.
						 */
						else
							appendStringInfo(buf, "SUM(col%d)", mapping);

						break;

					}
				}	
				(*cellid)++;
				break;
			}
			break;
		}
		case T_FuncExpr:
		{
			FuncExpr		*func = (FuncExpr *) node;
			Oid				rettype = func->funcresulttype;
			int32			coercedTypmod;
			HeapTuple		proctup;
			Form_pg_proc	procform;

			/* To handle case user cast data type using "::" */
			if (func->funcformat == COERCE_EXPLICIT_CAST)
				appendStringInfoChar(buf, '(');

			/* Get function name */
			proctup = SearchSysCache1(PROCOID, ObjectIdGetDatum(func->funcid));
			if (!HeapTupleIsValid(proctup))
				elog(ERROR, "cache lookup failed for function %u", func->funcid);
			procform = (Form_pg_proc) GETSTRUCT(proctup);

			if(func->args)
			{
				/* Append function name when function is called directly */
				if (func->funcformat == COERCE_EXPLICIT_CALL)
					appendStringInfo(buf, "%s(", NameStr(procform->proname));

				rebuild_target_expr((Node *)func->args, buf, extcells, cellid, groupby_target, isfirst);

				if (func->funcformat == COERCE_EXPLICIT_CALL)
					appendStringInfoChar(buf, ')');
			}
			else
			{
				/* When there is no arguments, only need to append function name and "()" */
				appendStringInfo(buf, "%s()", NameStr(procform->proname));
			}

			/* To handle case user cast data type using "::" */
			if (func->funcformat == COERCE_EXPLICIT_CAST)
			{
				/* Get the typmod if this is a length-coercion function */
				(void) exprIsLengthCoercion((Node *) node, &coercedTypmod);

				appendStringInfo(buf, ")::%s",
						 spd_deparse_type_name(rettype, coercedTypmod));
			}

			ReleaseSysCache(proctup);
			break;
		}
		case T_List:
		{
			List	   *l = (List *) node;
			ListCell   *lc;

			foreach(lc, l)
			{
				rebuild_target_expr((Node *)lfirst(lc), buf, extcells, cellid, groupby_target, isfirst);
			}
			break;
		}
		case T_Const:
		{
			spd_deparse_const((Const *) node, buf, 0);
			break;
		}
		case T_Var:
		{
			ListCell *extlc;
			int id = 0;

			foreach(extlc, extcells->cells)
			{
				/* Find the mapping cell */
				Mappingcells *cell = (Mappingcells *) lfirst(extlc);
				int mapping;
				if (id != (*cellid))
				{
					id++;
					continue;
				}

				mapping = cell->mapping[0];
				/* Append var name */
				appendStringInfo(buf, "col%d", mapping);
				break;
			}
			(*cellid)++;
			break;
		}
		case T_BoolExpr:
		{
			BoolExpr	*b = (BoolExpr *) node;
			const char	*op = NULL;		/* keep compiler quiet */
			bool		first;
			ListCell	*lc;

			switch (b->boolop)
			{
				case AND_EXPR:
					op = "AND";
					break;
				case OR_EXPR:
					op = "OR";
					break;
				case NOT_EXPR:
					appendStringInfoString(buf, "(NOT ");
					rebuild_target_expr((Node*) linitial(b->args), buf, extcells, cellid, groupby_target, true);
					appendStringInfoChar(buf, ')');
					return;
			}

			appendStringInfoChar(buf, '(');
			first = true;
			foreach(lc, b->args)
			{
				if (!first)
					appendStringInfo(buf, " %s ", op);
				rebuild_target_expr((Node *) lfirst(lc), buf, extcells, cellid, groupby_target, true);
				first = false;
			}
			appendStringInfoChar(buf, ')');

			break;
		}
		default:
			break;
	}
}

/**
 * spd_spi_select_table
 *
 * This is called by aggregate Push-down case.
 * If GROUP BY is used, spd_IterateForeignScan called this fundction in firsttime.
 * From second time, spd_IterateForeignScan call spd_select_return_aggslot()
 *
 * 1. Get all record from child node result
 * 2. Set all getting record to fdw_private->agg_values
 * 3. Create first record and return it.
 *
 *
 * @param[in,out] slot
 * @param[in] node
 * @param[in] fdw_private
 */

static TupleTableSlot *
spd_spi_select_table(TupleTableSlot *slot, ForeignScanState *node, SpdFdwPrivate * fdw_private)
{
	StringInfo	sql = makeStringInfo();
	ListCell	*lc;
	int			j = 0;
	bool		isfirst = true;
	int			target_num = 0;		/* Number of target in query */
	/* Create Select query */
	appendStringInfo(sql, "SELECT ");

	foreach(lc, fdw_private->mapping_tlist)
	{
		Extractcells *extcells = (Extractcells *) lfirst(lc);
		ListCell *extlc;

		if (extcells->is_having_qual)
			continue;

		/* No extract case */
		if (extcells->ext_num == 0)
		{	
			Mappingcells	*cells;
			char			*agg_command;
			int				agg_type;
			char			*agg_const;
			int				mapping;

			extlc = list_head(extcells->cells);
			cells = (Mappingcells *) lfirst(extlc);
			agg_command = cells->agg_command->data;
			agg_type = cells->aggtype;
			agg_const = cells->agg_const->data;

			mapping = cells->mapping[0];

			if (isfirst)
				isfirst = false;
			else
				appendStringInfo(sql, ",");

			/*
			 * For those columns listed in the grouping target but not
			 * listed in the target list. For example, SELECT avg(i) FROM
			 * t1 GROUP BY i,t. column name i and column name t not listed
			 * in the target list, so agg_command is NULL.
			 */
			if (agg_command == NULL)
			{
				appendStringInfo(sql, "col%d", mapping);
				continue;
			}
			else if (agg_type != NON_AGG_FLAG)
			{
				/*
				 * This is for aggregate functions
				 */
				if (!pg_strcasecmp(agg_command, "SUM") || !pg_strcasecmp(agg_command, "COUNT") ||
					!pg_strcasecmp(agg_command, "AVG") || !pg_strcasecmp(agg_command, "VARIANCE") ||
					!pg_strcasecmp(agg_command, "STDDEV"))
					appendStringInfo(sql, "SUM(col%d)", mapping);

				else if (!pg_strcasecmp(agg_command, "MAX") || !pg_strcasecmp(agg_command, "MIN") ||
						!pg_strcasecmp(agg_command, "BIT_OR") || !pg_strcasecmp(agg_command, "BIT_AND") ||
						!pg_strcasecmp(agg_command, "BOOL_AND") || !pg_strcasecmp(agg_command, "BOOL_OR") ||
						!pg_strcasecmp(agg_command, "EVERY") || !pg_strcasecmp(agg_command, "XMLAGG"))
					appendStringInfo(sql, "%s(col%d)", agg_command, mapping);
				/*
				 * This is for string_agg function. This function require delimiter to work
				 */
				else if (!pg_strcasecmp(agg_command, "STRING_AGG"))
				{
					appendStringInfo(sql, "%s(col%d, %s)", agg_command, mapping, agg_const);
				}
				/*
				 * This is for influx db functions. MAX has not effect to
				 * result. We have to consider multi-tenant.
				 */
				else if (!pg_strcasecmp(agg_command, "INFLUX_TIME") || !pg_strcasecmp(agg_command, "LAST"))
					appendStringInfo(sql, "MAX(col%d)", mapping);

				/*
				 * Other aggregation not listed above. TODO: SUM may be
				 * incorrect for multi-tenant table.
				 */
				else
					appendStringInfo(sql, "SUM(col%d)", mapping);
			}
			else			/* non agg */
			{

				/*
				 * Ex: SUM(i)/2
				 */
				if (!list_member_int(fdw_private->groupby_target, mapping))
				{
					appendStringInfo(sql, "SUM(col%d)", mapping);
				}

				/*
				 * This is GROUP BY target. Ex: 't' in select sum(i),t
				 * from t1 group by t
				 */
				else
				{
					appendStringInfo(sql, "col%d", mapping);
				}
			}
			target_num++;
			j++;
		}
		/* Extract case */
		else
		{
			Expr	*expr = copyObject(extcells->expr);
			int		cellid = 0;
			if (isfirst)
				isfirst = false;
			else
				appendStringInfo(sql, ",");
			rebuild_target_expr((Node *) expr, sql, extcells, &cellid, fdw_private->groupby_target, isfirst);
			target_num++;
		}
	}

	fdw_private->temp_num_cols = target_num;
	appendStringInfo(sql, " FROM %s ", fdw_private->temp_table_name);
	/* group by clause */
	if (fdw_private->groupby_string != 0)
		appendStringInfo(sql, "%s", fdw_private->groupby_string->data);

	/* Append HAVING clause */
	if (fdw_private->has_having_quals)
	{
		Expr	*expr;
		bool	is_first = true;
		appendStringInfo(sql, " HAVING ");
		foreach(lc, fdw_private->mapping_tlist)
		{
			Extractcells *extcells = (Extractcells *) lfirst(lc);
			int		cellid = 0;

			if (!extcells->is_having_qual)
				continue;

			/* Extract case */
			expr = copyObject(extcells->expr);

			if (!is_first)
				appendStringInfoString(sql, " AND ");

			rebuild_target_expr((Node *) expr, sql, extcells, &cellid, fdw_private->groupby_target, true);
			is_first = false;
		}
	}

	elog(DEBUG1, "select from temp table: %s", sql->data);
	/* Execute aggregate query to temp table */
	spd_spi_exec_select(fdw_private, sql);
	/* calc and set agg values */
	spd_calc_aggvalues(fdw_private, 0, slot);
	return slot;
}

/**
 * spd_select_return_aggslot
 *
 * Copy from fdw_private->agg_values to returning slot
 * This is used in "GROUP BY" clause
 *
 * @param[in,out] slot
 * @param[in] node
 * @param[in] fdw_private
 */
static TupleTableSlot *
spd_select_return_aggslot(TupleTableSlot *slot, ForeignScanState *node, SpdFdwPrivate * fdw_private)
{
	if (fdw_private->agg_num < fdw_private->agg_tuples)
	{
		spd_calc_aggvalues(fdw_private, fdw_private->agg_num, slot);
		return slot;
	}
	else
		return NULL;
}

/**
 * spd_createtable_sql
 *
 * Create a SQL query of creating temp table for executing GROUP BY.
 *
 * @param[out] create_sql
 * @param[in] mapping_tlist
 * @param[in] temp_table
 * @param[in] fdw_private
 */
static void
spd_createtable_sql(StringInfo create_sql, List *mapping_tlist,
					char *temp_table, SpdFdwPrivate * fdw_private)
{
	ListCell   *lc;
	int			colid = 0;
	int			i;
	int			typeid;
	int			typmod;

	colid = 0;
	appendStringInfo(create_sql, "CREATE TEMP TABLE %s(", temp_table);
	foreach(lc, mapping_tlist)
	{
		Extractcells	*extcells = lfirst(lc);
		ListCell		*extlc;

		foreach(extlc, extcells->cells)
		{
			Mappingcells *cells = lfirst(extlc);

			for (i = 0; i < MAX_SPLIT_NUM; i++)
			{
				/* append aggregate string */
				if (colid == cells->mapping[i])
				{
					if (colid != 0)
						appendStringInfo(create_sql, ",");
					appendStringInfo(create_sql, "col%d ", colid);
					typeid = exprType((Node *) ((TargetEntry *) list_nth(fdw_private->child_comp_tlist, colid))->expr);
					typmod = exprTypmod((Node *) ((TargetEntry *) list_nth(fdw_private->child_comp_tlist, colid))->expr);

					/* append column name and column type */
					appendStringInfo(create_sql, " %s", spd_deparse_type_name(typeid, typmod));

					colid++;
				}
			}
		}
	}
	appendStringInfo(create_sql, ")");
	elog(DEBUG1, "create temp table: %s", create_sql->data);
}

/**
 * spd_AddSpdUrl
 *
 * Add __spd_url column.
 * If child node is pgspider, then concatinate node name.
 * We don't convert heap tuple to virtual tuple because for update
 * using postgres_fdw and pgspider_fdw, ctid which virtual tuples
 * don't have is necessary.
 *
 * @param[in] fssThrdInfo - thread info
 * @param[in,out] parent_slot - parent tuple table slot
 * @param[in] node_id - id of node which return the slot
 * @param[in,out] node_slot - child tuple table slot
 * @param[in] fdw_private - private info
 */
static TupleTableSlot *
spd_AddSpdUrl(ForeignScanThreadInfo * fssThrdInfo, TupleTableSlot *parent_slot,
			  int node_id, TupleTableSlot *node_slot, SpdFdwPrivate * fdw_private)
{
	Datum	   *values;
	bool	   *nulls;
	bool	   *replaces;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	int			i;
	int			tnum = 0;
	HeapTuple	newtuple;

	/*
	 * Length of parent should be greater than or equal to length of 
	 * child slot. If __spd_url is not specified, length is same
	 */
	Assert(parent_slot->tts_tupleDescriptor->natts >=
		   node_slot->tts_tupleDescriptor->natts);
	fs = fssThrdInfo[node_id].foreignServer;
	fdw = fssThrdInfo[node_id].fdw;

	/* Make tts_values and tts_nulls valid */
	slot_getallattrs(node_slot);

	/*
	 * Insert __spd_url column to slot. heap_modify_tuple will replace the
	 * existing column. To insert new column and its data, we also follow the
	 * similar steps like heap_modify_tuple. First, deform tuple to get data
	 * values, Second, modify data values (insert new columm). Then, form
	 * tuple with new data values. Finally, copy identification info (if any)
	 */
	if (fdw_private->groupby_has_spdurl)
	{
		char	   *spdurl;
		int			natts = parent_slot->tts_tupleDescriptor->natts;

		/* Initialize new tuple buffer */
		values = (Datum *) palloc0(sizeof(Datum) * natts);
		nulls = (bool *) palloc0(sizeof(bool) * natts);
		replaces = (bool *) palloc0(sizeof(bool) * natts);

		if (TTS_IS_HEAPTUPLE(node_slot))
		{
			/* Extract data to values/isnulls */
			heap_deform_tuple(node_slot->tts_ops->get_heap_tuple(node_slot), node_slot->tts_tupleDescriptor, values, nulls);

			/* Insert __spd_url to the array */
			if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0)
			{
				spdurl = psprintf("/%s/", fs->servername);
				for (i = natts - 2; i >= fdw_private->idx_url_tlist; i--)
				{
					values[i + 1] = values[i];
					nulls[i + 1] = nulls[i];
				}
				values[fdw_private->idx_url_tlist] = CStringGetTextDatum(spdurl);
				nulls[fdw_private->idx_url_tlist] = false;
				/* Form new tuple with new values */
				newtuple = heap_form_tuple(parent_slot->tts_tupleDescriptor,
									   values,
									   nulls);
			}
			else
			{
				spdurl = psprintf("/%s%s", fs->servername, TextDatumGetCString(values[fdw_private->idx_url_tlist]));
				values[fdw_private->idx_url_tlist] = CStringGetTextDatum(spdurl);
				nulls[fdw_private->idx_url_tlist] = false;
				replaces[fdw_private->idx_url_tlist] = true;
				/* Modify tuple with new values */
				newtuple = heap_modify_tuple(node_slot->tts_ops->get_heap_tuple(node_slot), node_slot->tts_tupleDescriptor,
											 values, nulls, replaces);
			}

			/*
			 * copy the identification info of the old tuple: t_ctid, t_self,
			 * and OID (if any)
			 */
			newtuple->t_data->t_ctid = node_slot->tts_ops->get_heap_tuple(node_slot)->t_data->t_ctid;
			newtuple->t_self = node_slot->tts_ops->get_heap_tuple(node_slot)->t_self;
			newtuple->t_tableOid = node_slot->tts_ops->get_heap_tuple(node_slot)->t_tableOid;

			ExecStoreHeapTuple(newtuple, parent_slot, false);

			pfree(values);
			pfree(nulls);
		}
		else
		{
			/* tuple mode is VIRTUAL */
			int			offset = 0;

			for (i = 0; i < natts; i++)
			{
				if (i == fdw_private->idx_url_tlist)
				{
					spdurl = psprintf("/%s/", fs->servername);
					values[i] = CStringGetTextDatum(spdurl);
					nulls[i] = false;
					offset = -1;
				}
				else
				{
					values[i] = node_slot->tts_values[i + offset];
					nulls[i] = node_slot->tts_isnull[i + offset];
				}
			}
			parent_slot->tts_values = values;
			parent_slot->tts_isnull = nulls;
			/* to avoid assert failure in ExecStoreVirtualTuple, set tts_flags empty */
			parent_slot->tts_flags |= TTS_FLAG_EMPTY;
			ExecStoreVirtualTuple(parent_slot);
		}
		return parent_slot;
	}
	else						/* Modify __spd_url column */
	{
		int natts = node_slot->tts_tupleDescriptor->natts;

		/* Initialize new tuple buffer */
		values = palloc0(sizeof(Datum) * node_slot->tts_tupleDescriptor->natts);
		nulls = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
		replaces = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
		tnum = -1;

		for (i = 0; i < natts; i++)
		{
			char	   *value;
			Form_pg_attribute attr = TupleDescAttr(node_slot->tts_tupleDescriptor, i);

			/*
			 * Check if i th attribute is __spd_url or not. If so, fill
			 * __spd_url slot. In target list push down case,
			 * tts_tupleDescriptor->attrs[i]->attname.data is NULL in some
			 * cases such as UNION. So we will use idx_url_tlist instead.
			 */
			if ((fdw_private->is_pushdown_tlist && i == fdw_private->idx_url_tlist) ||
				strcmp(attr->attname.data, SPDURL) == 0)
			{
				bool		isnull;

				/* Check child node is pgspider or not */
				if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) == 0 && node_slot->tts_isnull[i] == false)
				{

					Datum		col = slot_getattr(node_slot, i + 1, &isnull);
					char	   *s;

					if (isnull)
						elog(ERROR, "PGSpider column name error. Child node Name is nothing.");

					s = TextDatumGetCString(col);

					/*
					 * if child node is pgspider, concatinate child node name
					 * and child child node name
					 */
					value = psprintf("/%s%s", fs->servername, s);
				}
				else
				{
					/*
					 * child node is NOT pgspider, create column name
					 * attribute
					 */
					value = psprintf("/%s/", fs->servername);
				}

				if (attr->atttypid != TEXTOID)
					elog(ERROR, "__spd_url column is not text type");
				replaces[i] = true;
				nulls[i] = false;
				values[i] = CStringGetTextDatum(value);
				tnum = i;
			}
		}

		if (tnum != -1)
		{
			if (TTS_IS_HEAPTUPLE(node_slot) && ((HeapTupleTableSlot*) node_slot)->tuple)
			{
				/* tuple mode is HEAP */
				newtuple = heap_modify_tuple(node_slot->tts_ops->get_heap_tuple(node_slot), node_slot->tts_tupleDescriptor,
											 values, nulls, replaces);
				ExecStoreHeapTuple(newtuple, node_slot, false);
			}
			else
			{
				/* tuple mode is VIRTUAL */
				node_slot->tts_values[tnum] = values[tnum];
				node_slot->tts_isnull[tnum] = false;
				/* to avoid assert failure in ExecStoreVirtualTuple */
				node_slot->tts_flags |= TTS_FLAG_EMPTY;
				ExecStoreVirtualTuple(node_slot);
			}
		}
		return node_slot;

	}
	Assert(false);

}


/**
 * nextChildTuple
 *
 * Return slot and nodeId of child fdw which returns the slot if available.
 * Return NULL if all threads are finished.
 *
 * @param[in] fssThrdInfo
 * @param[in] nThreads
 * @param[out] nodeId
 */
static TupleTableSlot *
nextChildTuple(ForeignScanThreadInfo * fssThrdInfo, int nThreads, int *nodeId)
{
	int			count = 0;
	bool		all_thread_finished = true;
	TupleTableSlot *slot;

	for (count = 0;; count++)
	{
		bool		is_finished=false;

		if (count >= nThreads)
		{
			if (all_thread_finished)
			{
				return NULL;	/* There is no iterating thread. */
			}
			all_thread_finished = true;
			count = 0;
			pthread_yield();
		}
		slot = spd_queue_get(&fssThrdInfo[count].tupleQueue, &is_finished);
		if (slot)
		{
			/* tuple found */
			*nodeId = count;
			return slot;
		}
		else if (!is_finished)
		{
			/* no tuple yet, but the thread is running */
			all_thread_finished = false;
		}
	}
	Assert(false);
}

/**
 * spd_IterateForeignScan
 *
 * spd_IterateForeignScan iterate on each child node and return the tuple table slot
 * in a round robin fashion.
 *
 * @param[in] node
 */
static TupleTableSlot *
spd_IterateForeignScan(ForeignScanState *node)
{
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	int			count = 0;
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	TupleTableSlot *slot = NULL,
			   *tempSlot = NULL;
	SpdFdwPrivate *fdw_private;
	List	   *mapping_tlist;
	MemoryContext oldcontext;
	int node_incr;

	fdw_private = (SpdFdwPrivate *) fssThrdInfo[0].private;

	if (fdw_private == NULL)
		fdw_private = spd_DeserializeSpdFdwPrivate(fsplan->fdw_private);

	fdw_private->is_drop_temp_table = true;
#ifdef GETPROGRESS_ENABLED
	if (getResultFlag)
		return NULL;
#endif
	if (fdw_private->nThreads == 0)
		return NULL;

	mapping_tlist = fdw_private->mapping_tlist;

	/*
	 * After the core engine initialize stuff for query, it jump to spd_IterateForeingScan,
	 * in this routine, we need to send request for the each child node start scan.
	 */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (!fssThrdInfo[node_incr].requestStartScan && fdw_private->isFirst)
		{
			/* Request to continue the each query transaction */
			fssThrdInfo[node_incr].requestStartScan = true;
		}
	}

	/* CREATE TEMP TABLE SQL */
	if (fdw_private->agg_query)
	{
		if (fdw_private->isFirst)
		{
			StringInfo	create_sql = makeStringInfo();

			/*
			 * Store temp table name, it will be used to drop table in next
			 * iterate foreign scan
			 */
			oldcontext = MemoryContextSwitchTo(fdw_private->es_query_cxt);

			/*
			 * Use temp table name like __spd__temptable_(NUMBER) to avoid
			 * using the same table in different foreign scan
			 */
			fdw_private->temp_table_name = psprintf(AGGTEMPTABLE "_" INT64_FORMAT,
													temp_table_id++);
			/* Switch to CurrentMemoryContext */
			MemoryContextSwitchTo(oldcontext);

			spd_createtable_sql(create_sql, mapping_tlist,
								fdw_private->temp_table_name, fdw_private);
			spd_spi_ddl_table(create_sql->data, fdw_private);
			fdw_private->is_drop_temp_table = false;

			/*
			 * run aggregation query for all data source threads and combine
			 * results
			 */
			for (;;)
			{
				slot = nextChildTuple(fssThrdInfo, fdw_private->nThreads, &count);
				if (slot != NULL)
				{
					/*
					 * If groupby has __spd_url, we need to add __spd_url back after
					 * removing from target list
					 */
					if (fdw_private->groupby_has_spdurl)
					{
						/* Clear tuple slot */
						ExecClearTuple(fdw_private->child_comp_slot);
						/* Add __spd_url */
						slot = spd_AddSpdUrl(fssThrdInfo, fdw_private->child_comp_slot, count, slot, fdw_private);
					}
					spd_spi_insert_table(slot, node, fdw_private);
				}
				else
					break;

#ifdef GETPROGRESS_ENABLED
				if (getResultFlag)
					break;
#endif
			}
			/* First time getting with pushdown from temp table */
			tempSlot = node->ss.ss_ScanTupleSlot;
			tempSlot = spd_spi_select_table(tempSlot, node, fdw_private);
			fdw_private->isFirst = false;
		}
		else
		{
			/* Second time getting from temporary result set */
			tempSlot = node->ss.ss_ScanTupleSlot;
			tempSlot = spd_select_return_aggslot(tempSlot, node, fdw_private);
		}

		/* Check tempSlot is empty or not */
		if (TupIsNull(tempSlot))
		{
			/*
			 * If all tuple getting is finished, then return NULL and drop
			 * table
			 */
			spd_spi_ddl_table(psprintf("DROP TABLE %s", fdw_private->temp_table_name), fdw_private);
			fdw_private->isFirst = true;
			fdw_private->is_drop_temp_table = true;
		}
		return tempSlot;
	}
	else
	{
		/* Utilize isFirst to mark this processing is implemented one time only */
		fdw_private->isFirst = false;

		slot = nextChildTuple(fssThrdInfo, fdw_private->nThreads, &count);
		if (slot != NULL)
			slot = spd_AddSpdUrl(fssThrdInfo, node->ss.ss_ScanTupleSlot,
								 count, slot, fdw_private);
	}

	return slot;
}

/**
 * spd_ReScanForeignScan
 *
 * spd_ReScanForeignScan restarts the spd plan
 *
 * @param[in] node
 */
static void
spd_ReScanForeignScan(ForeignScanState *node)
{

	SpdFdwPrivate *fdw_private;
	int			node_incr;
	ForeignScanThreadInfo *fssThrdInfo;

	fssThrdInfo = node->spd_fsstate;
	fdw_private = (SpdFdwPrivate *) fssThrdInfo[0].private;

	if (fdw_private == NULL)
		return;

	/*
	 * Number of child threads is only alive threads. firstly, check to number
	 * of alive child threads.
	 */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR &&
			fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH )
		{
			/*
			 * In case Rescan, need to update chgParam variable from
			 * core engine. Postgres FDW need chgParam to determine
			 * clear cursor or not.
			 */
			fssThrdInfo[node_incr].fsstate->ss.ps.chgParam = bms_copy(node->ss.ps.chgParam);
			fssThrdInfo[node_incr].requestRescan = true;
			fdw_private->isFirst = true;
		}
	}

	pthread_yield();

	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR &&
			fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH)
		{
			/* Break this loop when child thread start scan again */
			while (fssThrdInfo[node_incr].requestRescan)
			{
				pthread_yield();
			}
		}
	}

	return;
}

/**
 * spd_EndForeignScan
 *
 * spd_EndForeignScan ends the spd plan (i.e. does nothing).
 *
 * @param[in] node
 */
static void
spd_EndForeignScan(ForeignScanState *node)
{
	int			node_incr;
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	SpdFdwPrivate *fdw_private;

	if (!fssThrdInfo)
		return;

	fdw_private = (SpdFdwPrivate *) fssThrdInfo[0].private;
	if (!fdw_private)
		return;

	spd_end_child_node_thread((ForeignScanState *)node, false);

	/* wait until all the remote connections get closed. */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		/* In case AbortTransaction, the ss_currentRelation was closed by backend */
		if (fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation)
			RelationClose(fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation);

		/* Free ResouceOwner before MemoryContextDelete */
		ResourceOwnerRelease(fssThrdInfo[node_incr].thrd_ResourceOwner,
							 RESOURCE_RELEASE_BEFORE_LOCKS, false, false);
		ResourceOwnerRelease(fssThrdInfo[node_incr].thrd_ResourceOwner,
							 RESOURCE_RELEASE_LOCKS, false, false);
		ResourceOwnerRelease(fssThrdInfo[node_incr].thrd_ResourceOwner,
							 RESOURCE_RELEASE_AFTER_LOCKS, false, false);
		ResourceOwnerDelete(fssThrdInfo[node_incr].thrd_ResourceOwner);
		MemoryContextDeleteNodes(fssThrdInfo[node_incr].threadMemoryContext);
	}

	if (fdw_private->is_explain)
	{
		for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
		{
			fssThrdInfo[node_incr].fdwroutine->EndForeignScan(fssThrdInfo[node_incr].fsstate);
			return;
		}
	}

	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		pfree(fssThrdInfo[node_incr].fsstate);

		/*
		 * In case AbortTransaction, no need to call spd_aliveError
		 * because this function will call elog ERROR, it will raise
		 * abort event again.
		 */
		if (throwErrorIfDead && fssThrdInfo[node_incr].state == SPD_FS_STATE_ERROR)
		{
			ForeignServer *fs;

			fs = GetForeignServer(fdw_private->childinfo[node_incr].server_oid);

			/*
			 * If not free memory before calling spd_aliveError,
			 * this function will raise abort event, and function
			 * spd_EndForeignScan return immediately not reach to
			 * end cause leak memory. We free memory before call
			 * spd_aliveError to avoid memory leak.
			 */
			pfree(fssThrdInfo);
			node->spd_fsstate = NULL;
			spd_aliveError(fs);
		}
	}
	pfree(fssThrdInfo);
	node->spd_fsstate = NULL;
}

/**
 * spd_check_url_update
 *
 * Check and create url. If URL is nothing or can not find server
 * then return error.
 *
 * @param[in,out] fdw_private
 * @param[in] target_rte
 */
static void
spd_check_url_update(SpdFdwPrivate * fdw_private, RangeTblEntry *target_rte)
{

	spd_ParseUrl(target_rte->spd_url_list, fdw_private);
	if (fdw_private->url_list == NIL ||
		fdw_private->url_list->length < 1)
	{
		/* DO NOTHING */
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");
	}
	else
	{
		char	   *srvname = palloc0(sizeof(char) * (MAX_URL_LENGTH));

		fdw_private->in_flag = true;
		pfree(srvname);
	}
}

/**
 * spd_AddForeignUpdateTargets
 *
 * Add column(s) needed for update/delete on a foreign table,
 * we are using first column as row identification column, so we are adding that into target
 * list.
 * Checking IN clause. In currently, must use IN.
 *
 * @param[in] Query *parsetree,
 * @param[in] RangeTblEntry *target_rte
 * @param[in] Relation target_relation
 */
static void
spd_AddForeignUpdateTargets(Query *parsetree,
							RangeTblEntry *target_rte,
							Relation target_relation)
{
	MemoryContext oldcontext;
	FdwRoutine *fdwroutine;
	SpdFdwPrivate *fdw_private;
	Oid		   *oid = NULL;
	Oid			oid_server = 0;

	fdw_private = spd_AllocatePrivate();
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	/* Checking IN clause. */
	if (target_rte->spd_url_list != NULL)
		spd_check_url_update(fdw_private, target_rte);
	else
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");
	spd_spi_exec_child_relname(RelationGetRelationName(target_relation), fdw_private, &oid);
	if (fdw_private->node_num == 0)
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));
	MemoryContextSwitchTo(oldcontext);
	if (oid[0] != 0)
	{
		oid_server = spd_spi_exec_datasource_oid(oid[0]);
		fdwroutine = GetFdwRoutineByServerId(oid_server);
		fdwroutine->AddForeignUpdateTargets(parsetree, target_rte, target_relation);
	}
	return;
}

/**
 * spd_PlanForeignModify
 *
 * Add column(s) needed for update/delete on a foreign table,
 * we are using first column as row identification column, so we are adding that into target
 * list.
 * Checking IN clause. In currently, must use IN.
 *
 * @param[in] root
 * @param[in] plan
 * @param[in] resultRelation
 * @param[in] subplan_index
 */
static List *
spd_PlanForeignModify(PlannerInfo *root,
					  ModifyTable *plan,
					  Index resultRelation,
					  int subplan_index)
{
	RangeTblEntry *rte = planner_rt_fetch(resultRelation, root);
	MemoryContext oldcontext;
	FdwRoutine *fdwroutine;
	SpdFdwPrivate *fdw_private;
	Relation	rel;
	Oid		   *oid = NULL;
	Oid			oid_server = 0;
	List	   *child_list = NULL;
	int			nums=0;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();

	if (rte->spd_url_list != NULL)
		spd_check_url_update(fdw_private, rte);
	else
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");

	spd_create_child_url(nums, rte, fdw_private);
	rel = table_open(rte->relid, NoLock);

	spd_spi_exec_child_relname(RelationGetRelationName(rel), fdw_private, &oid);
	if (fdw_private->node_num == 0)
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));
	MemoryContextSwitchTo(oldcontext);
	if (oid[0] != 0)
	{
		oid_server = spd_spi_exec_datasource_oid(oid[0]);
		fdwroutine = GetFdwRoutineByServerId(oid_server);
		child_list = fdwroutine->PlanForeignModify(root, plan, resultRelation, subplan_index);
	}
	table_close(rel, NoLock);
	return list_make2(child_list, makeInteger(oid_server));
}

/**
 * spd_BeginForeignModify
 *
 * Add column(s) needed for update/delete on a foreign table,
 * we are using first column as row identification column, so we are adding that into target
 * list.
 *
 * @param[in] mtstate
 * @param[in] resultRelInfo
 * @param[in] fdw_private
 * @param[in] subplan_index
 * @param[in] eflags
 */

static void
spd_BeginForeignModify(ModifyTableState *mtstate,
					   ResultRelInfo *resultRelInfo,
					   List *fdw_private,
					   int subplan_index,
					   int eflags)
{

	Oid			oid_server = intVal(list_nth(fdw_private, ServerOid));
	List	   *child_fdw_private = (List *) list_nth(fdw_private, ForeignFdwPrivate);
	FdwRoutine *fdwroutine;
	SpdFdwModifyState *fmstate = (SpdFdwModifyState *) palloc0(sizeof(SpdFdwModifyState));

	fmstate->modify_server_oid = oid_server;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	fdwroutine->BeginForeignModify(mtstate, resultRelInfo, child_fdw_private, subplan_index, eflags);
	resultRelInfo->ri_FdwState = fmstate;
	return;
}

/**
 * spd_ExecForeignInsert
 *
 * Insert one row into a foreign table.
 *
 * @param[in] estate
 * @param[in] resultRelInfo
 * @param[in] slot
 * @param[in] planSlot
 */
static TupleTableSlot *
spd_ExecForeignInsert(EState *estate,
					  ResultRelInfo *resultRelInfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot)
{
	SpdFdwModifyState *fmstate = (SpdFdwModifyState *) resultRelInfo->ri_FdwState;
	Oid			oid_server = fmstate->modify_server_oid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	return fdwroutine->ExecForeignInsert(estate, resultRelInfo, slot, planSlot);
}


/**
 * spd_ExecForeignUpdate
 *
 * Update one row in a foreign table
 *
 * @param[in] estate
 * @param[in] resultRelInfo
 * @param[in] slot
 * @param[in] planSlot
 */
static TupleTableSlot *
spd_ExecForeignUpdate(EState *estate,
					  ResultRelInfo *resultRelInfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot)
{
	SpdFdwModifyState *fmstate = (SpdFdwModifyState *) resultRelInfo->ri_FdwState;
	Oid			oid_server = fmstate->modify_server_oid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	return fdwroutine->ExecForeignUpdate(estate, resultRelInfo, slot, planSlot);
}

/**
 * spd_ExecForeignDelete
 *
 * Delete one row in a foreign table, call child table.
 *
 * @param[in] estate
 * @param[in] resultRelInfo
 * @param[in] slot
 * @param[in] planSlot
 */
static TupleTableSlot *
spd_ExecForeignDelete(EState *estate,
					  ResultRelInfo *resultRelInfo,
					  TupleTableSlot *slot,
					  TupleTableSlot *planSlot)
{
	SpdFdwModifyState *fmstate = (SpdFdwModifyState *) resultRelInfo->ri_FdwState;
	Oid			oid_server = fmstate->modify_server_oid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	return fdwroutine->ExecForeignDelete(estate, resultRelInfo, slot, planSlot);

}

/**
 * spd_EndForeignModify
 *
 * Call EndForeignModify of child fdw.
 *
 * @param[in] estate
 * @param[in] resultRelInfo
 */
static void
spd_EndForeignModify(EState *estate,
					 ResultRelInfo *resultRelInfo)
{
	SpdFdwModifyState *fmstate = (SpdFdwModifyState *) resultRelInfo->ri_FdwState;
	Oid			oid_server = fmstate->modify_server_oid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	fdwroutine->EndForeignModify(estate, resultRelInfo);
}



void
_PG_init(void)
{
	/* get the configuration */
	DefineCustomBoolVariable("pgspider_core_fdw.throw_error_ifdead",
							 "set alive error",
							 NULL,
							 &throwErrorIfDead,
							 true,
							 PGC_USERSET,
							 0,
							 NULL,
							 NULL,
							 NULL);

/* get the configuration */
	DefineCustomBoolVariable("pgspider_core_fdw.print_error_nodes",
							 "print error nodes",
							 NULL,
							 &isPrintError,
							 false,
							 PGC_USERSET,
							 0,
							 NULL,
							 NULL,
							 NULL);
}
