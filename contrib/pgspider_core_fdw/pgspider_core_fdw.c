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
#include "access/table.h"	/* postgres 12*/
#include "catalog/pg_type.h"
#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "foreign/foreign.h"
#include "executor/tuptable.h"
#include "executor/execdesc.h"
#include "executor/executor.h"
#include "executor/spi.h"
#include "executor/nodeAgg.h"
#include "miscadmin.h"
#include "nodes/execnodes.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "nodes/pg_list.h"
#include "nodes/plannodes.h"
#include "nodes/relation.h"
#include "nodes/makefuncs.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/plancat.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/var.h"
#include "optimizer/tlist.h"
#include "optimizer/cost.h"
#include "optimizer/clauses.h"
#include "optimizer/optimizer.h"	/* postgres 12 */
#include "parser/parsetree.h"
#include "utils/guc.h"
#include "utils/memutils.h"
#include "utils/palloc.h"
#include "utils/lsyscache.h"
#include "utils/builtins.h"
#include "utils/float.h"	/* postgres 12 */
#include "utils/datum.h"
#include "utils/rel.h"
#include "utils/elog.h"
#include "utils/selfuncs.h"
#include "utils/numeric.h"
#include "utils/hsearch.h"
#include "utils/syscache.h"
#include "utils/lsyscache.h"
#include "utils/resowner.h"
#include "libpq-fe.h"
#include "pgspider_core_fdw_defs.h"
#include "funcapi.h"
#include "postgres_fdw/postgres_fdw.h"
#include "pgspider_keepalive/pgspider_keepalive.h"

/* #define GETPROGRESS_ENABLED */
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

#define OPEXPER_OID 514
#define OPEXPER_FUNCID 141
#define FLOAT8MUL_OID 594
#define FLOAT8MUL_FUNID 216
#define DOUBLE_LENGTH 8
#define MAXDIVNUM 3				/* STDDEV and VARIANCE div sum,count,sum(x^2),
								 * so currentrly MAX is 3 */

#define PGSPIDER_FDW_NAME "pgspider_fdw"
#define MYSQL_FDW_NAME "mysql_fdw"
#define AVRO_FDW_NAME "avro_fdw"

#define SPDURL "__spd_url"
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
const char *AggtypeStr[] = {"non agg", "non split", "avg", "var", "dev"};
enum Aggtype
{
	NONAGGFLAG,
	NON_SPLIT_AGGFLAG,
	AVGFLAG,
	VARFLAG,
	DEVFLAG,
};

enum SpdServerstatus
{
	ServerStatusAlive,
	ServerStatusIn,
	ServerStatusDead,
};

/* For EXPLAIN */
static const char *SpdServerstatusStr[] = {
	"Alive",
	"Not specified by IN",
	"Dead"
};

typedef struct Mappingcell
{
	/*
	 * store attribute number. mapping[0]:agg or non-split agg like sum(x),
	 * mapping[1]:SUM(x), mapping[2]:SUM(x*sx)
	 */
	int			mapping[MAXDIVNUM];

}			Mappingcell;

typedef struct Mappingcells
{
	Mappingcell mapping_tlist;	/* pgspider target list */
	enum Aggtype aggtype;
	StringInfo	agg_command;
	int			original_attnum;	/* original attribute */
}			Mappingcells;


typedef struct ChildInfo
{
	/* Planning */
	RelOptInfo *baserel;
	PlannerInfo *grouped_root_local;
	RelOptInfo *grouped_rel_local;
	int			scan_relid;
	bool		in_flag;		/* using IN clause or NOT */
	List	   *url_list;
	AggPath    *aggpath;

	/* Using in both Planning and Execution */
	PlannerInfo *root;
	Plan	   *plan;
	enum SpdServerstatus child_node_status;
	Oid			server_oid;		/* child table's server oid */
	Oid			oid;			/* child table's table oid */
	Agg		   *pAgg;			/* "Aggref" for Disable of aggregation push
								 * down servers */
	bool		can_pushdown_agg;	/* support agg pushdown */
	/* Use in Execution */
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
	bool		groupby_has_spdurl; /* groupby has spdurl flag */
	bool		is_pushdown_tlist;	/* pushed down target list or not. For
									 * aggregation, always false */

	List	   *pPseudoAggList; /* Disable of aggregation push down server
								 * list */
	List	   *child_comp_tlist;	/* child complite target list */
	List	   *child_tlist;	/* child target list without spdurl */
	List	   *mapping_tlist;	/* mapping list orig and pgspider */

	List	   *groupby_target; /* group target tlist number */

	TupleTableSlot *child_comp_slot;	/* temporary slot */
	StringInfo	groupby_string; /* GROUP BY string for aggregation temp table */

	ChildInfo  *childinfo;		/* ChildInfo List */

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
	MemoryContext tmp_cxt;		/* temporary context */
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

static List *spd_add_to_flat_tlist(List *tlist, Expr *exprs, List **mapping_tlist, List **compress_tlist, Index sgref, List **upper_targets);
static void spd_spi_exec_child_ip(char *serverName, char *ip);
static bool spd_can_pushdown_tlist(char *fdwname);
static bool spd_can_skip_deepcopy(char *fdwname);

/* Queue functions */
static bool spd_queue_add(SpdTupleQueue * que, TupleTableSlot *slot, bool deepcopy);
static TupleTableSlot *spd_queue_get(SpdTupleQueue * que, bool *is_finished);
static void spd_queue_reset(SpdTupleQueue * que);
static void spd_queue_init(SpdTupleQueue * que, TupleDesc tupledesc, bool skipLast);
static void spd_queue_notify_finish(SpdTupleQueue * que);


/* postgresql.conf paramater */
static bool throwErrorIfDead;
static bool isPrintError;

/* We write lock SPI function and read lock child fdw routines */
pthread_rwlock_t scan_mutex = PTHREAD_RWLOCK_INITIALIZER;
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;
static MemoryContext thread_top_contexts[NODES_MAX] = {NULL};
static int64 temp_table_id = 0;

static bool
is_foreign_expr2(PlannerInfo *root, RelOptInfo *baserel, Expr *expr)
{
	return true;
}

#define is_foreign_expr is_foreign_expr2

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

/* Return true if this fdw can pushdown target list */
static bool
spd_can_pushdown_tlist(char *fdwname)
{
	if (strcmp(fdwname, MYSQL_FDW_NAME) == 0)
		return true;
	return false;
}

/* Return true if this fdw can skip deepcopy when adding tuple to a queue.
 * Returning true means that fdw allocates tuples in CurrentMemoryContext.
 */
static bool
spd_can_skip_deepcopy(char *fdwname)
{
	if (strcmp(fdwname, AVRO_FDW_NAME) == 0)
		return true;
	return false;
}

/*
 * spd_queue_notify_finish
 *
 * Notify parent thread that child fdw scan is finished
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
 * Return immediately if queue is full.
 * Deepcopy each column value of slot If 'deepcopy' is true.
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

	ExecClearTuple(que->tuples[idx]);

	/* Not minimal tuple */
	Assert(!slot->tts_mintuple);

	if (TTS_HAS_PHYSICAL_TUPLE(slot))
	{
		/*
		 * TODO: we can probably skip heap_copytuple as in virtual tuple case
		 * for some fdws
		 */
		ExecStoreTuple(heap_copytuple(slot->tts_tuple),
					   que->tuples[idx],
					   InvalidBuffer,
					   false);
	}
	else
	{
		/* Virtual tuple */

		natts = que->tuples[idx]->tts_tupleDescriptor->natts;
		memcpy(que->tuples[idx]->tts_isnull, slot->tts_isnull, natts * sizeof(bool));

		/*
		 * Skip copy of spdurl at the last of tuple descriptor because it's
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
 * is_finished is true if queue is empty and child foreign scan is finished.
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
 */
static void
spd_queue_init(SpdTupleQueue * que, TupleDesc tupledesc, bool skip_last)
{
	int			j;

	que->skipLast = skip_last;
	/* Create tuple descriptor for queue */
	for (j = 0; j < SPD_TUPLE_QUEUE_LEN; j++)
	{
		TupleTableSlot *slot = MakeSingleTupleTableSlot(tupledesc);

		que->tuples[j] = slot;
		slot->tts_values = palloc(tupledesc->natts * sizeof(Datum));
		slot->tts_isnull = palloc(tupledesc->natts * sizeof(bool));
	}
	spd_queue_reset(que);
	pthread_mutex_init(&que->qmutex, NULL);
}

static void
print_mapping_tlist(List *mapping_tlist, int loglevel)
{
	ListCell   *lc;

	foreach(lc, mapping_tlist)
	{
		Mappingcells *cells = lfirst(lc);
		Mappingcell clist = cells->mapping_tlist;

		elog(loglevel, "mapping_tlist (%d %d %d)/ original_attnum=%d  orig_tlist aggtype=\"%s\"",
			 clist.mapping[0], clist.mapping[1], clist.mapping[2],
			 cells->original_attnum, AggtypeStr[cells->aggtype]);
	}
}

static int
strcmpi(char *s1, char *s2)
{
	int			i;

	if (strlen(s1) != strlen(s2))
		return -1;
	for (i = 0; i < strlen(s1); i++)
	{
		if (toupper(s1[i]) != toupper(s2[i]))
			return s1[i] - s2[i];
	}
	return 0;
}


/*
 * tlist_member
 *	  Finds the (first) member of the given tlist whose expression is
 *	  equal() to the given expression.  Result is NULL if no such member.
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

static void
spd_spi_exec_proname(Oid aggoid, StringInfo aggname)
{
	char		query[QUERY_LENGTH];
	char	   *temp;
	int			ret;

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/* get child server name from child's foreign table id */
	sprintf(query, "select proname from pg_proc where oid=%d;", (int) aggoid);


	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
		elog(ERROR, "error %d", ret);
	if (SPI_processed != 1)
	{
		SPI_finish();
		elog(ERROR, "error SPIexecute can not find datasource");
	}
	temp = SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1);


	appendStringInfoString(aggname, temp);
	SPI_finish();
	return;
}

/* Serialize fdw_private as a list */
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
			Mappingcells *cells = lfirst(lc);
			Mappingcell clist = cells->mapping_tlist;

			lfdw_private = lappend(lfdw_private, makeInteger(clist.mapping[0]));
			lfdw_private = lappend(lfdw_private, makeInteger(clist.mapping[1]));
			lfdw_private = lappend(lfdw_private, makeInteger(clist.mapping[2]));
			lfdw_private = lappend(lfdw_private, makeInteger(cells->aggtype));
			lfdw_private = lappend(lfdw_private, makeString(cells->agg_command ? cells->agg_command->data : ""));
			lfdw_private = lappend(lfdw_private, makeInteger(cells->original_attnum));
		}

		lfdw_private = lappend(lfdw_private, copyObject(fdw_private->child_comp_slot));
		lfdw_private = lappend(lfdw_private, makeString(fdw_private->groupby_string ? fdw_private->groupby_string->data : ""));
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

/* De-serialize a list to as fdw_private */
static SpdFdwPrivate *
spd_DeserializeSpdFdwPrivate(List *lfdw_private)
{
	int			i = 0;
	int			mapping_tlist_len = 0;
	ListCell   *lc = list_head(lfdw_private);
	SpdFdwPrivate *fdw_private = palloc0(sizeof(SpdFdwPrivate));

	fdw_private->node_num = intVal(lfirst(lc));
	lc = lnext(lc);

	fdw_private->nThreads = intVal(lfirst(lc));
	lc = lnext(lc);

	fdw_private->idx_url_tlist = intVal(lfirst(lc));
	lc = lnext(lc);

	fdw_private->agg_query = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lc);

	fdw_private->isFirst = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lc);

	fdw_private->groupby_has_spdurl = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lc);

	fdw_private->is_pushdown_tlist = intVal(lfirst(lc)) ? true : false;
	lc = lnext(lc);

	if (fdw_private->agg_query)
	{
		fdw_private->groupby_target = (List *) lfirst(lc);
		lc = lnext(lc);

		fdw_private->pPseudoAggList = (List *) lfirst(lc);
		lc = lnext(lc);

		fdw_private->child_comp_tlist = (List *) lfirst(lc);
		lc = lnext(lc);

		fdw_private->child_tlist = (List *) lfirst(lc);
		lc = lnext(lc);

		/* Get length of mapping_tlist */
		mapping_tlist_len = intVal(lfirst(lc));
		lc = lnext(lc);

		fdw_private->mapping_tlist = NIL;
		for (i = 0; i < mapping_tlist_len; i++)
		{
			Mappingcells *cells = (Mappingcells *) palloc0(sizeof(Mappingcells));

			cells->mapping_tlist.mapping[0] = intVal(lfirst(lc));
			lc = lnext(lc);
			cells->mapping_tlist.mapping[1] = intVal(lfirst(lc));
			lc = lnext(lc);
			cells->mapping_tlist.mapping[2] = intVal(lfirst(lc));
			lc = lnext(lc);
			cells->aggtype = intVal(lfirst(lc));
			lc = lnext(lc);
			cells->agg_command = makeStringInfo();
			appendStringInfoString(cells->agg_command, strVal(lfirst(lc)));
			lc = lnext(lc);
			cells->original_attnum = intVal(lfirst(lc));
			lc = lnext(lc);
			fdw_private->mapping_tlist = lappend(fdw_private->mapping_tlist, cells);
		}

		fdw_private->child_comp_slot = (TupleTableSlot *) (lfirst(lc));
		lc = lnext(lc);

		fdw_private->groupby_string = makeStringInfo();
		appendStringInfoString(fdw_private->groupby_string, strVal(lfirst(lc)));
		lc = lnext(lc);
	}

	fdw_private->childinfo = (ChildInfo *) palloc0(sizeof(ChildInfo) * fdw_private->node_num);
	for (i = 0; i < fdw_private->node_num; i++)
	{
		fdw_private->childinfo[i].can_pushdown_agg = intVal(lfirst(lc));
		lc = lnext(lc);

		fdw_private->childinfo[i].child_node_status = intVal(lfirst(lc));
		lc = lnext(lc);

		fdw_private->childinfo[i].server_oid = intVal(lfirst(lc));
		lc = lnext(lc);

		fdw_private->childinfo[i].oid = intVal(lfirst(lc));
		lc = lnext(lc);

		/* Plan */
		fdw_private->childinfo[i].plan = (Plan *) lfirst(lc);
		lc = lnext(lc);

		/* Agg plan */
		if (list_member_oid(fdw_private->pPseudoAggList, fdw_private->childinfo[i].server_oid))
		{
			fdw_private->childinfo[i].pAgg = (Agg *) lfirst(lc);
			lc = lnext(lc);
		}

		/* Root */
		fdw_private->childinfo[i].root = (PlannerInfo *) palloc0(sizeof(PlannerInfo));
		fdw_private->childinfo[i].root->parse = (Query *) lfirst(lc);
		lc = lnext(lc);
	}

	return fdw_private;
}

/**
 * spd_add_to_flat_tlist
 *	Add more items to a flattened tlist (if they're not already in it) and
 *  Create Original(parent) target's mapping list and child's.
 * 'tlist' is the flattened tlist
 * 'exprs' is a list of expressions (usually, but not necessarily, Vars)
 *
 * Returns the extended tlist, child tlist, Original mapping list, Child mapping list.
 *
 * @param[in,out] tlist - flattened tlist
 * @param[in] exprs - exprs
 * @param[out] mapping_tlist - target mapping list for child node
 * @param[out] mapping_orig_tlist - target mapping list
 * @param[out] compress_tlist  target - compress list for child node
 */

static List *
spd_add_to_flat_tlist(List *tlist, Expr *expr, List **mapping_tlist,
					  List **compress_tlist, Index sgref, List **upper_targets)
{
	int			next_resno = list_length(tlist) + 1;
	int			next_resno_temp = list_length(*compress_tlist) + 1;
	int			target_num = 0;
	TargetEntry *tle_temp;
	TargetEntry *tle;
	Aggref	   *aggref;
	Mappingcells *mapcells = (struct Mappingcells *) palloc0(sizeof(struct Mappingcells));
	int			i;

	for (i = 0; i < MAXDIVNUM; i++)
	{
		/* these store 0-index, so initialize with -1 */
		mapcells->mapping_tlist.mapping[i] = -1;
		mapcells->original_attnum = -1;
		mapcells->agg_command = makeStringInfo();
	}
	aggref = (Aggref *) expr;
	if (IsA(expr, Aggref) &&IS_SPLIT_AGG(aggref->aggfnoid))
	{
		/* Prepare COUNT Query */
		Aggref	   *tempCount = copyObject(aggref);
		Aggref	   *tempSum;
		Aggref	   *tempVar;

		tempVar = copyObject(aggref);
		tempSum = copyObject(aggref);

		if (aggref->aggtype == FLOAT4OID || aggref->aggtype == FLOAT8OID)
		{
			tempSum->aggfnoid = SUM_FLOAT8_OID;
			tempSum->aggtype = FLOAT8OID;
			tempSum->aggtranstype = FLOAT8OID;
		}
		else
		{
			tempSum->aggfnoid = SUM_INT4_OID;
			tempSum->aggtype = INT8OID;
			tempSum->aggtranstype = INT8OID;
		}
		tempCount->aggfnoid = COUNT_OID;
		tempCount->aggtype = INT8OID;
		tempCount->aggtranstype = INT8OID;

		/* Prepare SUM Query */

		tempVar->aggfnoid = VAR_OID;

		/* add original mapping list to avg,var,stddev */
		if (!spd_tlist_member(expr, tlist, &target_num))
		{
			tle = makeTargetEntry(copyObject(expr),
								  next_resno++,
								  NULL,
								  false);
			tlist = lappend(tlist, tle);

		}
		mapcells->original_attnum = target_num;
		/* set avg flag */
		if (aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID)
			mapcells->aggtype = AVGFLAG;
		else if (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
			mapcells->aggtype = VARFLAG;
		else if (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)
			mapcells->aggtype = DEVFLAG;

		spd_spi_exec_proname(aggref->aggfnoid, mapcells->agg_command);

		/* count */
		if (!spd_tlist_member((Expr *) tempCount, *compress_tlist, &target_num))
		{
			tle_temp = makeTargetEntry((Expr *) tempCount,
									   next_resno_temp++,
									   NULL,
									   false);
			*compress_tlist = lappend(*compress_tlist, tle_temp);
			*upper_targets = lappend(*upper_targets, tempCount);
		}
		mapcells->mapping_tlist.mapping[0] = target_num;
		/* sum */
		if (!spd_tlist_member((Expr *) tempSum, *compress_tlist, &target_num))
		{
			tle_temp = makeTargetEntry((Expr *) tempSum,
									   next_resno_temp++,
									   NULL,
									   false);
			*compress_tlist = lappend(*compress_tlist, tle_temp);
			*upper_targets = lappend(*upper_targets, tempSum);
		}
		mapcells->mapping_tlist.mapping[1] = target_num;
		/* variance(SUM(x*x)) */
		if ((aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
			|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
		{
			if (!spd_tlist_member((Expr *) tempVar, *compress_tlist, &target_num))
			{
				TargetEntry *tarexpr;
				TargetEntry *oparg = (TargetEntry *) tempVar->args->head->data.ptr_value;
				Var		   *opvar = (Var *) oparg->expr;
				OpExpr	   *opexpr = (OpExpr *) &oparg->xpr;
				OpExpr	   *opexpr2 = copyObject(opexpr);

				opexpr->xpr.type = T_OpExpr;
				opexpr->opretset = false;
				opexpr->opcollid = 0;
				opexpr->inputcollid = 0;
				opexpr->location = 0;
				opexpr->args = NULL;

				/* Create top targetentry */
				if (tempVar->aggtype <= INT4OID || tempVar->aggtype == NUMERICOID)
				{
					tempVar->aggtype = INT8OID;
					tempVar->aggtranstype = INT8OID;
					tempVar->aggfnoid = SUM_OID;
					opexpr->opno = OPEXPER_OID;
					opexpr->opfuncid = OPEXPER_FUNCID;
					opexpr->opresulttype = INT8OID;
				}
				else
				{
					tempVar->aggtype = FLOAT8OID;
					tempVar->aggtranstype = FLOAT8OID;
					tempVar->aggfnoid = SUM_FLOAT8_OID;
					opexpr->opresulttype = FLOAT8OID;
					opexpr->opno = FLOAT8MUL_OID;
					opexpr->opfuncid = FLOAT8MUL_FUNID;
					opexpr->opresulttype = FLOAT8OID;
				}
				opexpr->args = lappend(opexpr->args, opvar);
				opexpr->args = lappend(opexpr->args, opvar);
				/* Create var targetentry */
				tarexpr = makeTargetEntry((Expr *) opexpr,
										  next_resno_temp,
										  NULL,
										  false);
				opexpr2 = (OpExpr *) tarexpr->expr;
				opexpr2->opretset = false;
				opexpr2->opcollid = 0;
				opexpr2->inputcollid = 0;
				opexpr2->location = 0;
				tarexpr->resno = 1;
				tempVar->args = lappend(tempVar->args, tarexpr);
				tempVar->args = list_delete_first(tempVar->args);
				tle_temp = makeTargetEntry((Expr *) tempVar,
										   next_resno_temp++,
										   NULL,
										   false);
				*compress_tlist = lappend(*compress_tlist, tle_temp);
				*upper_targets = lappend(*upper_targets, tempSum);
			}
			mapcells->mapping_tlist.mapping[2] = target_num;
		}
	}
	else
	{
		/* Non agg or non split agg such as sum or count */
		TargetEntry *tle_temp;
		TargetEntry *tle;

		/* original */
		if (!spd_tlist_member(expr, tlist, &target_num))
		{
			tle = makeTargetEntry(copyObject(expr),
								  next_resno++,
								  NULL,
								  false);
			tle->ressortgroupref = sgref;
			tlist = lappend(tlist, tle);
		}
		/* append original target list */
		if (IsA(expr, Aggref))
		{
			mapcells->aggtype = NON_SPLIT_AGGFLAG;
			spd_spi_exec_proname(aggref->aggfnoid, mapcells->agg_command);
		}
		else
			mapcells->aggtype = NONAGGFLAG;

		mapcells->original_attnum = target_num;
		/* div tlist */
		if (!spd_tlist_member(expr, *compress_tlist, &target_num))
		{
			tle_temp = makeTargetEntry(copyObject(expr),
									   next_resno_temp++,
									   NULL,
									   false);
			tle_temp->ressortgroupref = sgref;
			*compress_tlist = lappend(*compress_tlist, tle_temp);
			*upper_targets = lappend(*upper_targets, expr);
		}
		mapcells->mapping_tlist.mapping[0] = target_num;
	}
	*mapping_tlist = lappend(*mapping_tlist, mapcells);
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
 * Get chiled nodes oid and nums using parent node oid.
 *
 * @param[in] foreigntableid
 * @param[in] context
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
	 */

	sprintf(query, "SELECT oid,relname FROM pg_class WHERE relname LIKE (SELECT relname FROM pg_class WHERE oid = %d)||'\\_\\_%%' ORDER BY relname;", foreigntableid);

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

static Datum
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

static void
spd_aliveError(ForeignServer *fs)
{
	elog(ERROR, "PGSpider can not get data from child node : %s", fs->servername);
}

static void
spd_ErrorCb(void *arg)
{
	if (throwErrorIfDead)
		EmitErrorReport();
}

/**
 * spd_ForeignScan_thread
 *
 * Child threads execute this routine, NOT main thread.
 * spd_ForeignScan_thread execute the following operations for each child threads.
 *
 * Child threads execute BeginForeignScan, IterateForeignScan, EndForeignScan in this routine.
 * There operation is child table FDW operation. It does not spd_xxx.
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
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) fssthrdInfo[0].private;
	PlanState  *result = NULL;

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

	tuplectx[0] = AllocSetContextCreate(fssthrdInfo->threadMemoryContext,
										"thread tuple contxt1",
										ALLOCSET_DEFAULT_MINSIZE,
										ALLOCSET_DEFAULT_INITSIZE,
										ALLOCSET_DEFAULT_MAXSIZE);
	tuplectx[1] = AllocSetContextCreate(fssthrdInfo->threadMemoryContext,
										"thread tuple contxt2",
										ALLOCSET_DEFAULT_MINSIZE,
										ALLOCSET_DEFAULT_INITSIZE,
										ALLOCSET_DEFAULT_MAXSIZE);

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
		SPD_READ_LOCK_TRY(&scan_mutex);

		/*
		 * If Aggregation does not push down, then BeginForeignScan execute in
		 * ExecInitNode
		 */
		if (!list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
		{
			fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
													  fssthrdInfo->eflags);
		}
		SPD_RWUNLOCK_CATCH(&scan_mutex);

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
		SPD_READ_LOCK_TRY(&scan_mutex);
		fssthrdInfo->fdwroutine->ReScanForeignScan(fssthrdInfo->fsstate);
		SPD_RWUNLOCK_CATCH(&scan_mutex);

		fssthrdInfo->requestRescan = false;
	}
	fssthrdInfo->state = SPD_FS_STATE_ITERATE;

	if (list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
	{
		SPD_WRITE_LOCK_TRY(&scan_mutex);
		result = ExecInitNode((Plan *) fdw_private->childinfo[fssthrdInfo->childInfoIndex].pAgg, fssthrdInfo->fsstate->ss.ps.state, 0);
		SPD_RWUNLOCK_CATCH(&scan_mutex);
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
				SPD_READ_LOCK_TRY(&scan_mutex);
				slot = SPI_execAgg((AggState *) result);
				SPD_RWUNLOCK_CATCH(&scan_mutex);

				/*
				 * need deep copy when adding slot to queue because
				 * CurrentMemoryContext do not affect SPI_execAgg, and hence
				 * tuples are not allocated by tuplectx[ctx_idx]
				 */
				deepcopy = true;
			}
			else
			{
				SPD_READ_LOCK_TRY(&scan_mutex);
				slot = fssthrdInfo->fdwroutine->IterateForeignScan(fssthrdInfo->fsstate);
				SPD_RWUNLOCK_CATCH(&scan_mutex);

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

			if (slot == NULL || slot->tts_isempty)
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

	PG_TRY();
	{
		while (1)
		{
			if (fssthrdInfo->requestEndScan)
			{
				/* End of the ForeignScan */
				fssthrdInfo->state = SPD_FS_STATE_END;
				SPD_READ_LOCK_TRY(&scan_mutex);
				if (!list_member_oid(fdw_private->pPseudoAggList,
									 fssthrdInfo->serverId))
					fssthrdInfo->fdwroutine->EndForeignScan(fssthrdInfo->fsstate);
				SPD_RWUNLOCK_CATCH(&scan_mutex);
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
 * @param[in] url_str - URL
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
 * @param[in] nums - num of child tables
 * @param[in] url_str - old URL
 * @param[in] fdw_private - store to parsing URL
 * @param[out] new_inurl - new URL
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
 * @param[in] fs - child table's server
 * @param[in] fdw - child table's fdw
 * @param[inout] entry_baserel - child table's base plan is saved
 */

static void
check_basestrictinfo(PlannerInfo *root, ForeignDataWrapper *fdw, RelOptInfo *entry_baserel)
{
	ListCell   *lc;

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
		}
	}
}


/**
 * remove_spdurl_from_targets
 *
 * Remove __spd_url from target lists and if spd_url found,
 * save index to "url_idx".
 */
static List *
remove_spdurl_from_targets(List *exprs, PlannerInfo *root,
						   bool is_target_entry, int *url_idx)
{
	ListCell   *lc;
	int			i = 0;

	*url_idx = -1;
	/* Cannot use foreach because we modify exprs in the loop */
	for ((lc) = list_head(exprs); (lc) != NULL;)
	{
		RangeTblEntry *rte;
		char	   *colname;
		Node	   *node = (Node *) lfirst(lc);
		Node	   *varnode;

		if (is_target_entry)
		{
			Assert(IsA(node, TargetEntry));
			varnode = (Node *) (((TargetEntry *) node)->expr);
		}
		else
		{
			Assert(!IsA(node, TargetEntry));
			varnode = node;
		}
		if (IsA(varnode, Var))
		{
			Var		   *var = (Var *) varnode;

			/* check whole row reference */
			if (var->varattno == 0)
			{
				lc = lnext(lc);
				continue;
			}
			else
			{
				rte = planner_rt_fetch(var->varno, root);
				colname = get_attname(rte->relid, var->varattno, false);
			}

			if (strcmp(colname, SPDURL) == 0)
			{
				/* TODO: Allow multiple __spd_url */
				if (*url_idx != -1)
					elog(ERROR, "Using __spd_url multiple times is not allowed");

				*url_idx = i;
				lc = lnext(lc);
				exprs = list_delete_ptr(exprs, node);

				continue;
			}
		}
		lc = lnext(lc);
		i++;
	}
	return exprs;
}

/* Remove __spd_url from group clause lists */
static List *
remove_spdurl_from_group_clause(List *tlist, List *groupClause, PlannerInfo *root)
{
	ListCell   *lc;

	if (groupClause == NULL)
		return NULL;

	for ((lc) = list_head(groupClause); (lc) != NULL;)
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
				lc = lnext(lc);
				groupClause = list_delete_ptr(groupClause, sgc);
				continue;
			}
		}
		lc = lnext(lc);
	}
	return groupClause;
}

/**
 * groupby_has_spdurl
 *
 * Check whether SPDURL existing in GROUP BY
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
		/* Check SPDURL in the target entry */
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
 * @param[in] nums - oid nums
 * @param[in] r_entry - Root entry
 * @param[in] new_inurl - new IN clause url
 * @param[in] oid_server - Parent table oid
 * @param[inout] fdw_private - child table's base plan is saved
 */
static void
spd_CreateDummyRoot(PlannerInfo *root, RelOptInfo *baserel, Oid *oid, int oid_nums, RangeTblEntry *r_entry,
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
			entry_baserel->reltarget->exprs = remove_spdurl_from_targets(entry_baserel->reltarget->exprs,
																		 root, false, &fdw_private->idx_url_tlist);
		}

		/*
		 * For File FDW. File FDW check column type and num with
		 * basestrictinfo. Delete spd_url column info from child node
		 * baserel's basestrictinfo. (PGSpider FDW use parent basestrictinfo)
		 *
		 */
		check_basestrictinfo(root, fdw, entry_baserel);
		childinfo[i].server_oid = oid_server;
		spd_spi_exec_child_ip(fs->servername, ip);
		/* Check server name and ip */
		if (check_server_ipname(fs->servername, ip))
		{
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
		}
		else
		{
			childinfo[i].root = root;
			childinfo[i].child_node_status = ServerStatusDead;
			if (throwErrorIfDead)
				spd_aliveError(fs);
		}
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
 * @param[in] oid - child table's oids
 * @param[in] nums - oid nums
 * @param[in] r_entry - Root entry
 * @param[in] new_inurl - new IN clause url
 * @param[in] oid_server - Parent table oid
 * @param[inout] fdw_private - child table's base plan is saved
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
 * @param[out] fdw_private - store to parsing URL
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

	baserel->rows = 1000;
	fdw_private = spd_AllocatePrivate();
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
	fdw_private->rinfo.relation_name = makeStringInfo();
	namespace = get_namespace_name(get_rel_namespace(foreigntableid));
	relname = get_rel_name(foreigntableid);
	refname = rte->eref->aliasname;
	appendStringInfo(fdw_private->rinfo.relation_name, "%s.%s",
					 quote_identifier(namespace),
					 quote_identifier(relname));
	if (*refname && strcmp(refname, relname) != 0)
		appendStringInfo(fdw_private->rinfo.relation_name, " %s",
						 quote_identifier(rte->eref->aliasname));
	spd_CopyRoot(root, baserel, fdw_private, foreigntableid);
	/* No outer and inner relations. */
	fdw_private->rinfo.make_outerrel_subquery = false;
	fdw_private->rinfo.make_innerrel_subquery = false;
	fdw_private->rinfo.lower_subquery_rels = NULL;
	/* Set the relation index. */
	fdw_private->rinfo.relation_index = baserel->relid;
}

/**
 * spd_makedivtlist
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

	tempCount->aggfnoid = COUNT_OID;
	tempSum = copyObject(tempCount);
	tempSum->aggfnoid = SUM_OID;
	if (tempSum->aggtype <= INT8OID || tempSum->aggtype == NUMERICOID)
	{
		tempSum->aggtype = INT8OID;
		tempSum->aggtranstype = INT8OID;
	}
	else
	{
		tempSum->aggfnoid = SUM_FLOAT8_OID;
		tempSum->aggtype = FLOAT8OID;
		tempSum->aggtranstype = FLOAT8OID;
	}
	tempCount->aggtype = INT8OID;
	tempCount->aggtranstype = INT8OID;
	/* Prepare SUM Query */
	tempVar = copyObject(tempCount);
	tempVar->aggfnoid = VAR_OID;

	newList = lappend(newList, tempCount);
	newList = lappend(newList, tempSum);
	if ((aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
		|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
	{
		TargetEntry *tarexpr;
		TargetEntry *oparg = (TargetEntry *) tempVar->args->head->data.ptr_value;
		Var		   *opvar = (Var *) oparg->expr;
		OpExpr	   *opexpr = (OpExpr *) &oparg->xpr;
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
			tempVar->aggtype = FLOAT8OID;
			tempVar->aggtranstype = FLOAT8OID;
			tempVar->aggfnoid = SUM_FLOAT8_OID;
			opexpr->opresulttype = FLOAT8OID;
			opexpr->opno = FLOAT8MUL_OID;
			opexpr->opfuncid = FLOAT8MUL_FUNID;
			opexpr->opresulttype = FLOAT8OID;
		}
		else
		{
			tempVar->aggtype = INT8OID;
			tempVar->aggtranstype = INT8OID;
			tempVar->aggfnoid = SUM_OID;
			opexpr->opno = OPEXPER_OID;
			opexpr->opfuncid = OPEXPER_FUNCID;
			opexpr->opresulttype = INT8OID;
		}
		opexpr->args = lappend(opexpr->args, opvar);
		opexpr->args = lappend(opexpr->args, opvar);
		/* Create var targetentry */
		tarexpr = makeTargetEntry((Expr *) opexpr,	/* copy needed?? */
								  listn,
								  NULL,
								  false);
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
 * spd_GetForeignUpperPaths
 * Add paths for post-join operations like aggregation, grouping etc. if
 * corresponding operations are safe to push down.
 *
 * Right now, we only support aggregate, grouping and having clause pushdown.
 *
 * @param[in] root - base planner infromation
 * @param[in] stage - not use
 * @param[in] input_rel - input RelOptInfo
 * @param[out] output_rel - output RelOptInfo
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
	fdw_private->node_num = in_fdw_private->node_num;
	fdw_private->in_flag = in_fdw_private->in_flag;
	fdw_private->agg_query = true;
	fdw_private->baserestrictinfo = copyObject(in_fdw_private->baserestrictinfo);
	spd_root = in_fdw_private->spd_root;

	/* Create child tlist */

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

	/* Devide split agg */
	foreach(lc, spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
	{
		Aggref	   *aggref;
		Expr	   *temp_expr;

		temp_expr = lfirst(lc);
		aggref = (Aggref *) temp_expr;
		listn++;
		if (IS_SPLIT_AGG(aggref->aggfnoid))
		{
			newList = spd_makedivtlist(aggref, newList, fdw_private);
		}
		else
		{
			newList = lappend(newList, temp_expr);
		}
	}
	spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs = list_copy(newList);
	fdw_private->childinfo = in_fdw_private->childinfo;
	fdw_private->rinfo.pushdown_safe = false;
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

		/* set flag if group by has spdurl */
		fdw_private->groupby_has_spdurl = groupby_has_spdurl(root);

		/* child_tlist will be used instead of child_comp_tlist */
		fdw_private->child_tlist = list_copy(fdw_private->child_comp_tlist);

		/* Remove spdurl from target list if groupby has spdurl */
		if (fdw_private->groupby_has_spdurl)
		{
			TupleDesc	tupledesc;

			/*
			 * Modify child tlist and save index of spdurl column. We use
			 * child tlist for fetching data from child node. And use index of
			 * spdurl to add data of spdurl back to parent node
			 */
			fdw_private->child_tlist = remove_spdurl_from_targets(fdw_private->child_tlist, root, true, &fdw_private->idx_url_tlist);

			/*
			 * When we add spdurl back to parent node, we need to create tuple
			 * descriptor for parent slot according to child comp tlist. We
			 * save to fdw_private->child_comp_tupdesc for later use.
			 */
			tupledesc = CreateTemplateTupleDesc(list_length(fdw_private->child_comp_tlist), false);
			foreach(lc, fdw_private->child_comp_tlist)
			{
				TargetEntry *ent = (TargetEntry *) lfirst(lc);

				TupleDescInitEntry(tupledesc, i + 1, NULL, exprType((Node *) ent->expr), -1, 0);
				i++;

			}
			/* Construct TupleDesc, and assign a local typmod. */
			tupledesc = BlessTupleDesc(tupledesc);
			fdw_private->child_comp_tupdesc = CreateTupleDescCopy(tupledesc);

			/* Init temporary slot for adding spdurl back */
			fdw_private->child_comp_slot = MakeSingleTupleTableSlot(CreateTupleDescCopy(fdw_private->child_comp_tupdesc));
		}

		/* Create path for each child node */
		for (i = 0; i < fdw_private->node_num; i++)
		{
			Oid			rel_oid = childinfo[i].oid;
			RelOptInfo *entry = childinfo[i].baserel;
			PlannerInfo *dummy_root_child = childinfo[i].root;
			RelOptInfo *dummy_output_rel;
			Index	   *sortgrouprefs;

			if (childinfo[i].child_node_status != ServerStatusAlive)
				continue;
			dummy_root_child->parse->groupClause = list_copy(root->parse->groupClause);
			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			if (fdwroutine->GetForeignUpperPaths != NULL)
			{

				if (childinfo[i].child_node_status != ServerStatusAlive)
					continue;
				dummy_root_child->parse->groupClause = root->parse->groupClause;
				/* Currently dummy. @todo more better parsed object. */
				dummy_root_child->parse->hasAggs = true;
				/* Call below FDW to check it is OK to pushdown or not. */

				/* refer relnode.c fetch_upper_rel() */
				dummy_output_rel = makeNode(RelOptInfo);
				dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
				dummy_output_rel->relids = bms_copy(entry->relids);
				/* dummy_output_rel->reltarget = create_empty_pathtarget(); */
				dummy_output_rel->reltarget = copy_pathtarget(output_rel->reltarget);
				dummy_output_rel->reltarget->exprs = list_copy(fdw_private->upper_targets);

				dummy_root_child->upper_rels[UPPERREL_GROUP_AGG] =
					lappend(dummy_root_child->upper_rels[UPPERREL_GROUP_AGG],
							dummy_output_rel);

				dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] =
					make_pathtarget_from_tlist(fdw_private->child_comp_tlist);
				dummy_root_child->upper_targets[UPPERREL_WINDOW] =
					copy_pathtarget(spd_root->upper_targets[UPPERREL_WINDOW]);
				dummy_root_child->upper_targets[UPPERREL_FINAL] =
					copy_pathtarget(spd_root->upper_targets[UPPERREL_FINAL]);
				fs = GetForeignServer(oid_server);
				fdw = GetForeignDataWrapper(fs->fdwid);

				/*
				 * Remove __spd_url from target lists and group clause if a
				 * child is not pgspider_fdw
				 */
				if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0 && fdw_private->groupby_has_spdurl)
				{
					/* Remove __spd_url from group clause */
					dummy_root_child->parse->groupClause = remove_spdurl_from_group_clause(fdw_private->child_comp_tlist, dummy_root_child->parse->groupClause, root);

					/*
					 * Update path target from new target list without
					 * __spd_url
					 */
					dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] = make_pathtarget_from_tlist(fdw_private->child_tlist);
				}
				/* Fill sortgrouprefs for child using child target entry list */
				sortgrouprefs = palloc(sizeof(Index) * list_length(fdw_private->child_comp_tlist));
				listn = 0;
				foreach(lc, fdw_private->child_comp_tlist)
				{
					TargetEntry *tmp_entry = (TargetEntry *) lfirst(lc);

					sortgrouprefs[listn++] = tmp_entry->ressortgroupref;
				}
				dummy_root_child->upper_targets[UPPERREL_GROUP_AGG]->sortgrouprefs = sortgrouprefs;
				dummy_output_rel->reltarget->sortgrouprefs = sortgrouprefs;
				fdwroutine->GetForeignUpperPaths(dummy_root_child,
												 stage, entry,
												 dummy_output_rel, extra);
			}
			else
			{

				if (childinfo[i].child_node_status != ServerStatusAlive)
					continue;
				dummy_root_child->parse->groupClause = root->parse->groupClause;
				/* Currently dummy. @todo more better parsed object. */
				dummy_root_child->parse->hasAggs = true;
				/* Call below FDW to check it is OK to pushdown or not. */
				/* refer relnode.c fetch_upper_rel() */
				dummy_output_rel = makeNode(RelOptInfo);
				dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
				dummy_output_rel->relids = bms_copy(entry->relids);
				dummy_output_rel->reltarget = create_empty_pathtarget();

				dummy_root_child->upper_rels[UPPERREL_GROUP_AGG] =
					lappend(dummy_root_child->upper_rels[UPPERREL_GROUP_AGG],
							dummy_output_rel);
				/* make pathtarget */
				dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] =
					make_pathtarget_from_tlist(fdw_private->child_comp_tlist);
				dummy_root_child->upper_targets[UPPERREL_WINDOW] =
					copy_pathtarget(spd_root->upper_targets[UPPERREL_WINDOW]);
				dummy_root_child->upper_targets[UPPERREL_FINAL] =
					copy_pathtarget(spd_root->upper_targets[UPPERREL_FINAL]);
				fs = GetForeignServer(oid_server);
				fdw = GetForeignDataWrapper(fs->fdwid);

				if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0 && fdw_private->groupby_has_spdurl)
				{
					/* Remove __spd_url from group clause */
					dummy_root_child->parse->groupClause = remove_spdurl_from_group_clause(fdw_private->child_comp_tlist, dummy_root_child->parse->groupClause, root);

					/*
					 * Update path target from new target list without
					 * __spd_url
					 */
					dummy_root_child->upper_targets[UPPERREL_GROUP_AGG] = make_pathtarget_from_tlist(fdw_private->child_tlist);
				}
				dummy_output_rel->reltarget->sortgrouprefs = sortgrouprefs;
			}
			if (dummy_output_rel->pathlist != NULL)
			{
				/* Push down aggregate case */
				childinfo[i].grouped_root_local = dummy_root_child;
				childinfo[i].grouped_rel_local = dummy_output_rel;

				/*
				 * if at least one child fdw pushdown aggregate, parent push
				 * down
				 */
				pushdown = true;
			}
			else
			{
				/* Not Push Down case */
				struct Path *tmp_path;
				Query	   *query = root->parse;
				AggClauseCosts dummy_aggcosts;

				MemSet(&dummy_aggcosts, 0, sizeof(AggClauseCosts));
				tmp_path = entry->pathlist->head->data.ptr_value;

				/*
				 * Pass dummy_aggcosts because create_agg_path requires
				 * aggcosts in cases other than AGG_HASH
				 */
				childinfo[i].aggpath = (AggPath *) create_agg_path((PlannerInfo *) dummy_root_child,
																   dummy_output_rel,
																   tmp_path,
																   dummy_root_child->upper_targets[UPPERREL_GROUP_AGG],
																   query->groupClause ? AGG_HASHED : AGG_PLAIN, AGGSPLIT_SIMPLE,
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
 *		Get foreign path for grouping and/or aggregation.
 *
 * Given input_rel represents the inlying scan.  The paths are added to the
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
	PathTarget *grouping_target;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;

	/* Nothing to be done, if there is no grouping or aggregation required. */
	if (!parse->groupClause && !parse->groupingSets && !parse->hasAggs &&
		!root->hasHavingQual)
		return NULL;

	grouping_target = root->upper_targets[UPPERREL_GROUP_AGG];

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

	rows = 0;
	width = 0;
	startup_cost = 0;
	total_cost = 0;

	/* Now update this information in the fpinfo */
	fpinfo->rinfo.rows = rows;
	fpinfo->rinfo.width = width;
	fpinfo->rinfo.startup_cost = startup_cost;
	fpinfo->rinfo.total_cost = total_cost;

	/* Create and add foreign path to the grouping relation. */
	grouppath = create_foreignscan_path(root,
										grouped_rel,
										grouping_target,
										rows,
										startup_cost,
										total_cost,
										NIL,	/* no pathkeys */
										NULL,	/* no required_outer */
										NULL,
										NIL);	/* no fdw_private */
	return (Path *) grouppath;
}

/**
 * foreign_grouping_ok
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
	Query	   *query = root->parse;
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

	/* We don't push down GROUP BY and Aggregate function if having SPDURL */
	if (groupby_has_spdurl(root))
		return false;

	/* Grouping Sets are not pushable */
	if (query->groupingSets)
		return false;

	/* Get the fpinfo of the underlying scan relation. */
	ofpinfo = (SpdFdwPrivate *) fpinfo->rinfo.outerrel->fdw_private;

	/*
	 * If inneath input relation has any local conditions, those conditions
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

		/* Check whether this expression is part of GROUP BY clause */
		if (sgref && get_sortgroupref_clause_noerr(sgref, query->groupClause))
		{
			int			before_listnum;

			/*
			 * If any of the GROUP BY expression is not shippable we can not
			 * push down aggregation to the foreign server.
			 */
			if (!is_foreign_expr(root, grouped_rel, expr))
				return false;
			/* Pushable, add to tlist */
			before_listnum = list_length(compress_child_tlist);
			tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets);
			groupby_cursor += list_length(compress_child_tlist) - before_listnum;
			fpinfo->groupby_target = lappend_int(fpinfo->groupby_target, groupby_cursor - 1);
		}
		else
		{
			/* Check entire expression whether it is pushable or not */
			if (is_foreign_expr(root, grouped_rel, expr))
			{
				/* Pushable, add to tlist */
				int			before_listnum = list_length(compress_child_tlist);

				tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets);
				groupby_cursor += list_length(compress_child_tlist) - before_listnum;
			}
			else
			{
				/*
				 * If we have sortgroupref set, then it means that we have an
				 * ORDER BY entry pointing to this expression.  Since we are
				 * not pushing ORDER BY with GROUP BY, clear it.
				 */
				if (sgref)
					grouping_target->sortgrouprefs[i] = 0;

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

						tlist = spd_add_to_flat_tlist(tlist, expr, &mapping_tlist, &compress_child_tlist, sgref, &upper_targets);
						i += list_length(compress_child_tlist) - before_listnum;
						groupby_cursor += list_length(compress_child_tlist) - before_listnum;
					}
				}
			}
		}
		i++;
	}

	/*
	 * Classify the pushable and non-pushable having clauses and save them in
	 * remote_conds and local_conds of the grouped rel's fpinfo.
	 */
	if (root->hasHavingQual && query->havingQual)
	{
		ListCell   *lc;

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
			if (is_foreign_expr(root, grouped_rel, expr))
				fpinfo->rinfo.remote_conds = lappend(fpinfo->rinfo.remote_conds, rinfo);
			else
				fpinfo->rinfo.local_conds = lappend(fpinfo->rinfo.local_conds, rinfo);
		}
	}

	/*
	 * If there are any local conditions, pull Vars and aggregates from it and
	 * check whether they are safe to pushdown or not.
	 */
	/* Transfer any sortgroupref data to the replacement tlist */
	apply_pathtarget_labeling_to_tlist(tlist, grouping_target);

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
	fpinfo->rinfo.relation_name = makeStringInfo();
	appendStringInfo(fpinfo->rinfo.relation_name, "Aggregate on (%s)",
					 ofpinfo->rinfo.relation_name->data);
	fpinfo->mapping_tlist = mapping_tlist;
	fpinfo->child_comp_tlist = compress_child_tlist;
	fpinfo->upper_targets = upper_targets;

	return true;
}



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
				childpath = (Path *) lfirst_node(ForeignPath, childinfo[i].baserel->pathlist->head);
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

	add_path(baserel, (Path *) create_foreignscan_path(root, baserel, NULL, baserel->rows,
													   startup_cost, total_cost, NIL,
													   NULL, NULL, NIL));
}


/**
 * spd_expression_tree_walker
 *
 * Change expr Var node type to OUTER VAR recursively.
 *
 * @param[in,out] node - plan tree node
 * @param[in,out] att  - attribute number
 *
 */

static bool
spd_expression_tree_walker(Node *node, int att)
{
	ListCell   *temp;

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

				expr->varno = OUTER_VAR;
				if (att != 0)
				{
					expr->varattno = att;
					att++;
				}
				else
				{
					expr->varattno = expr->varoattno;
				}
				return true;
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

				if (spd_expression_tree_walker((Node *) expr->args,
											   att))
					return true;
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
					spd_expression_tree_walker((Node *) lfirst(temp), att);
				}
				return true;
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
			return spd_expression_tree_walker((Node *) ((TargetEntry *) node)->expr, att);
		case T_Query:
		case T_WindowClause:
		case T_CommonTableExpr:
		case T_List:
			foreach(temp, (List *) node)
			{
				if (spd_expression_tree_walker((Node *) lfirst(temp), att))
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
 * spd_createPushDownPlan
 *
 * Build aggregation plan for each push down cases.
 * saving each foreign plan into base rel list
 *
 * @param[in] tlist               - target list
 * @param[out] agg_query          - aggregation flag
 * @param[out] fdw_private        - Push down type list
 *
 */
static List *
spd_createPushDownPlan(List *tlist, bool isUnPushdown, SpdFdwPrivate * fdw_private)
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
		if (isUnPushdown)
			spd_expression_tree_walker((Node *) aggref, 0);
		else
			spd_expression_tree_walker((Node *) aggref, 1);
	}
	return dummy_tlist;
}

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
 * spd_checkurl_clauses
 *
 * search for spd_url
 */
static void
spd_checkurl_clauses(List *scan_clauses, PlannerInfo *root, List *baserestrictinfo, List **push_scan_clauses)
{
	ListCell   *lc;

	foreach(lc, scan_clauses)
	{
		RestrictInfo *clause = (RestrictInfo *) lfirst(lc);
		Expr	   *expr = (Expr *) clause->clause;

		if (expression_tree_walker((Node *) expr, check_spdurl_walker, root))
		{
			/* don't pushdown *all* where caluses if spd_url is found */
			*push_scan_clauses = NULL;
			return;
		}
	}
	*push_scan_clauses = baserestrictinfo;
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
 *
 */
static ForeignScan *
spd_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid,
				   ForeignPath *best_path, List *tlist, List *scan_clauses,
				   Plan *outer_plan)
{
	FdwRoutine *fdwroutine;
	int			nums;
	int			i;
	Oid		   *oid = NULL;
	Oid			server_oid;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Index		scan_relid;
	List	   *fdw_scan_tlist = NIL;	/* Need dummy tlist for pushdown case. */
	List	   *push_scan_clauses = scan_clauses;
	ListCell   *lc;
	ChildInfo  *childinfo;
	ForeignServer *fs;
	bool		pushdown_all_tlist;
	ForeignDataWrapper *fdw;
	List	   *lfdw_private = NIL;
	ForeignPath *child_path;

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

	/*
	 * We enable target list pushdown if all nodes are able to push down
	 * tlist. This is temporary solution
	 */
	if (IS_SIMPLE_REL(baserel))
	{
		pushdown_all_tlist = true;
		for (i = 0; i < fdw_private->node_num; i++)
		{
			if (childinfo[i].child_node_status != ServerStatusAlive)
				continue;
			fs = GetForeignServer(childinfo[i].server_oid);
			fdw = GetForeignDataWrapper(fs->fdwid);

			if (!spd_can_pushdown_tlist(fdw->fdwname))
				pushdown_all_tlist = false;
		}
	}
	else
	{
		pushdown_all_tlist = false;
	}

	/* Create Foreign Plans using base_rel_list to each child. */
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


				Assert(childinfo[i].grouped_rel_local->pathlist);
				/* FDWs expect NULL scan clauses for UPPER REL */
				push_scan_clauses = NULL;
				/* Pick any agg path */

				child_path = lfirst(list_head(childinfo[i].grouped_rel_local->pathlist));
				temptlist = PG_build_path_tlist((PlannerInfo *) childinfo[i].root, (Path *) child_path);
				fsplan = fdwroutine->GetForeignPlan(childinfo[i].grouped_root_local,
													childinfo[i].grouped_rel_local,
													oid[i],
													(ForeignPath *) child_path,
													temptlist,
													push_scan_clauses,
													outer_plan);
			}
			else
			{
				/*
				 * For non agg query or not push down agg case, do same thing
				 * as create_scan_plan() to generate target list
				 */

				/* Add all columns of the table */
				temptlist = (List *) build_physical_tlist(childinfo[i].root, childinfo[i].baserel);

				/*
				 * Fill sortgrouprefs to temptlist. temptlist is non aggref
				 * target list, we should use non aggref pathtarget to apply.
				 */
				if (!IS_SIMPLE_REL(baserel) && root->parse->groupClause != NULL)
					apply_pathtarget_labeling_to_tlist(temptlist, fdw_private->rinfo.outerrel->reltarget);

				/*
				 * Remove __spd_url from target lists if a child is not
				 * pgspider_fdw
				 */
				if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0 && IS_SIMPLE_REL(baserel))
				{
					temptlist = remove_spdurl_from_targets(list_copy(tlist), root,
														   true, &fdw_private->idx_url_tlist);
				}
				/* mysql-fdw decide push down tlist or not based on this */
				childinfo[i].baserel->is_tlist_pushdown = pushdown_all_tlist;

				/*
				 * For can not aggregation pushdown FDW's. push down quals
				 * when aggregation is occurred
				 */
				if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
					push_scan_clauses = fdw_private->baserestrictinfo;

				/*
				 * We pass "best_path" to child GetForeignPlan. This is the
				 * path for parent fdw and not for child fdws We should pass
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
				spd_checkurl_clauses(scan_clauses, root, fdw_private->baserestrictinfo, &push_scan_clauses);
				fsplan = fdwroutine->GetForeignPlan((PlannerInfo *) childinfo[i].root,
													(RelOptInfo *) childinfo[i].baserel,
													oid[i],
													(ForeignPath *) best_path,
													temptlist,
													push_scan_clauses,
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

			/*
			 * If groupby has spdurl, spdurl will be removed from the target
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

			child_tlist = spd_createPushDownPlan(fdw_private->child_tlist,
												 list_member_oid(fdw_private->pPseudoAggList, server_oid),
												 fdw_private);

			/*
			 * Create aggregation plan with foreign table scan.
			 * extract_grouping_cols() requires targetlist of subplan.
			 */
			childinfo[i].pAgg = make_agg(child_tlist,
										 NULL,
										 childinfo[i].aggpath->aggstrategy,
										 childinfo[i].aggpath->aggsplit,
										 list_length(childinfo[i].aggpath->groupClause),
										 extract_grouping_cols(childinfo[i].aggpath->groupClause,
															   fsplan->scan.plan.targetlist),
										 extract_grouping_ops(childinfo[i].aggpath->groupClause),
										 /* fix port 12 - adding grouping collations */
										 extract_grouping_collations(childinfo[i].aggpath->groupClause,
												 fsplan->scan.plan.targetlist),
										 root->parse->groupingSets,
										 NIL,
										 childinfo[i].aggpath->path.rows,
										 (Plan *) fsplan);

		}
		childinfo[i].plan = (Plan *) fsplan;
	}

	fdw_private->is_pushdown_tlist = pushdown_all_tlist;

	if (IS_SIMPLE_REL(baserel))
	{
		/*
		 * Core expects fdw returns fdw_scan_tlist whch is parameter of
		 * make_foreignscan. So we will assign tlist to fdw_scan_tlist for
		 * target list pushdown. Also, core create tuple descriptor based on
		 * fdw_scan_tlist
		 */
		if (pushdown_all_tlist)
			fdw_scan_tlist = tlist;
		else
			fdw_scan_tlist = NIL;
		scan_relid = baserel->relid;
	}
	else
	{
		/* Aggregate push down */
		scan_relid = 0;
	}

	/* For simple rel, calculate which condition should be filtered in core */
	if (IS_SIMPLE_REL(baserel))
	{
		scan_clauses = NIL;
		if (fdw_private->baserestrictinfo && !push_scan_clauses)
		{
			/*
			 * In this case, PGSpider should filter baserestrictinfo because
			 * these are not passed to child fdw because of __spd_url
			 */
			foreach(lc, fdw_private->baserestrictinfo)
			{
				RestrictInfo *ri = lfirst_node(RestrictInfo, lc);

				scan_clauses = lappend(scan_clauses, ri->clause);
			}
		}

		/*
		 * We collect local conditions each fdw did not push down to make
		 * postgresql core execute that filter
		 */
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

	/*
	 * list_make2(makeInteger((unsigned long long) fdw_private >> 32),
	 * makeInteger((unsigned long long) fdw_private)),
	 */
							fdw_scan_tlist,
							NIL,
							outer_plan);
}

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
 * spd_BeginForeignScan
 * Main thread create iterate foreing scan information
 * for each child tables using previous operation
 * (spd_GetForeignRelSize, spd_GetForeignPaths, spd_GetForeignPlan).
 * It is mean creating child node's tupledescripter.
 * Firstly, get all child table information.
 * Next, Set information and create child thread.
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

	/* Create temporary context */
	fdw_private->tmp_cxt = AllocSetContextCreate(estate->es_query_cxt,
												 "temporary data",
												 ALLOCSET_SMALL_SIZES);

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
		fsplan->fdw_private = ((ForeignScan *) childinfo[i].plan)->fdw_private;

		/* Create and initialize EState */
		fssThrdInfo[node_incr].fsstate->ss.ps.state = CreateExecutorState();
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_top_eflags = eflags;

		/* This should be a new RTE list. coming from dummy rtable */
		query = ((PlannerInfo *) childinfo[i].root)->parse;

		rte = lfirst_node(RangeTblEntry, query->rtable->head);

		if (query->rtable->length != estate->es_range_table->length)
		{
			for (k = query->rtable->length; k < estate->es_range_table->length; k++)
			{
				query->rtable = lappend(query->rtable, rte);
			}
		}
		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_range_table = ((PlannerInfo *) childinfo[i].root)->parse->rtable;
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

		ExecAssignExprContext((EState *) fssThrdInfo[node_incr].fsstate->ss.ps.state, &fssThrdInfo[node_incr].fsstate->ss.ps);
		fssThrdInfo[node_incr].eflags = eflags;

		/*
		 * current relation ID gets from current server oid, it means
		 * childinfo[i].oid
		 */
		rd = RelationIdGetRelation(childinfo[i].oid);
		fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;

		fssThrdInfo[node_incr].requestEndScan = false;
		fssThrdInfo[node_incr].requestRescan = false;
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

			tupledesc = CreateTemplateTupleDesc(list_length(fdw_private->child_tlist), false);

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
					MakeSingleTupleTableSlot(ExecTypeFromTL(fssThrdInfo[node_incr].fsstate->ss.ps.plan->targetlist, true));
			}
			else
			{
				fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(CreateTupleDescCopy(tupledesc));
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
				MakeSingleTupleTableSlot(tupledesc);
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

		spd_queue_init(&fssThrdInfo[node_incr].tupleQueue, tupledesc, skiplast);

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
			fssThrdInfo[node_incr].fdwroutine->BeginForeignScan(fssThrdInfo[node_incr].fsstate,
																eflags);
		node_incr++;
	}

	fdw_private->nThreads = node_incr;

	/* Skip thread creation in explain case */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
	{
		return;
	}

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
 * This is called by Push-down case. Execute DDL query(especially CREATE temp table)
 *
 * @param[in] slot
 * @param[in] node
 * @param[in,out] fdw_private
 */

static void
spd_spi_ddl_table(char *query)
{
	int			ret;

	SPD_WRITE_LOCK_TRY(&scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	ret = SPI_exec(query, 1);
	elog(DEBUG1, "execute temp table DDL %s", query);
	if (ret != SPI_OK_UTILITY)
	{
		elog(ERROR, "execute spi CREATE TEMP TABLE failed %d", ret);
	}
	SPI_finish();
	SPD_RWUNLOCK_CATCH(&scan_mutex);
}

/**
 * spd_spi_insert_table
 *
 * This is called by Push-down case. Insert child node data into temp table.
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

	SPD_WRITE_LOCK_TRY(&scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	appendStringInfo(sql, "INSERT INTO %s VALUES( ", fdw_private->temp_table_name);
	colid = 0;
	mapping_tlist = fdw_private->mapping_tlist;
	foreach(lc, mapping_tlist)
	{
		Mappingcells *mapcels = (Mappingcells *) lfirst(lc);
		Datum		attr;
		char	   *value;
		bool		isnull;
		Oid			typoutput;
		bool		typisvarlena;
		int			child_typid;

		for (i = 0; i < MAXDIVNUM; i++)
		{
			Form_pg_attribute sattr = TupleDescAttr(slot->tts_tupleDescriptor, colid);

			if (colid != mapcels->mapping_tlist.mapping[i])
				continue;

			if (isfirst)
				isfirst = false;
			else
				appendStringInfo(sql, ",");
			attr = slot_getattr(slot, mapcels->mapping_tlist.mapping[i] + 1, &isnull);
			if (isnull)
			{
				appendStringInfo(sql, "NULL");
				colid++;
				continue;
			}
			getTypeOutputInfo(sattr->atttypid, &typoutput, &typisvarlena);
			value = OidOutputFunctionCall(typoutput, attr);
			child_typid = exprType((Node *) ((TargetEntry *) list_nth(fdw_private->child_comp_tlist, colid))->expr);

			if (value != NULL)
			{
				if (child_typid == BOOLOID)
				{
					if (strcmp(value, "t") == 0)
						value = "true";
					else
						value = "false";
				}
				if (child_typid == DATEOID || child_typid == TEXTOID || child_typid == TIMESTAMPOID || child_typid == TIMESTAMPTZOID)
					appendStringInfo(sql, "'");
				appendStringInfo(sql, "%s", value);
				if (child_typid == DATEOID || child_typid == TEXTOID || child_typid == TIMESTAMPOID || child_typid == TIMESTAMPTZOID)
					appendStringInfo(sql, "'");
			}
			colid++;
		}
	}
	appendStringInfo(sql, ")");
	ret = SPI_exec(sql->data, 1);
	if (ret != SPI_OK_INSERT)
		elog(ERROR, "execute spi INSERT TEMP TABLE failed ");
	SPI_finish();

	SPD_RWUNLOCK_CATCH(&scan_mutex);

}

/**
 * spd_exec_select
 *
 * This is called by Push-down case. Execute SELECT query(especially CREATE temp table)
 *
 * @param[in] slot
 * @param[in] sql
 * @param[in,out] fdw_private
 */


static void
spd_spi_exec_select(SpdFdwPrivate * fdw_private, StringInfo sql, TupleTableSlot *slot)
{
	int			ret;
	int			i,
				k;
	int			colid = 0;
	int			mapping;
	bool		isnull = false;
	MemoryContext oldcontext;
	Mappingcells *mapcells;
	ListCell   *lc;

	SPD_WRITE_LOCK_TRY(&scan_mutex);
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	/* execute select */
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
	oldcontext = MemoryContextSwitchTo(fdw_private->tmp_cxt);

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
	fdw_private->agg_tuples = SPI_processed;
	for (k = 0; k < SPI_processed; k++)
	{
		colid = 0;
		foreach(lc, fdw_private->mapping_tlist)
		{
			mapcells = (Mappingcells *) lfirst(lc);
			for (i = 0; i < MAXDIVNUM; i++)
			{
				Datum		datum;
				Form_pg_attribute attr = TupleDescAttr(SPI_tuptable->tupdesc, colid);

				mapping = mapcells->mapping_tlist.mapping[i];
				if (colid != mapping)
					continue;

				fdw_private->agg_value_type[colid] = attr->atttypid;

				datum = SPI_getbinval(SPI_tuptable->vals[k],
									  SPI_tuptable->tupdesc,
									  colid + 1,
									  &isnull);
				if (isnull)
					fdw_private->agg_nulls[k][colid] = true;
				else
				{
					/* We need to deep copy datum from SPI memory context */
					if (fdw_private->agg_value_type[colid] == NUMERICOID)
					{
						/* Convert from numeric to int8 */
						fdw_private->agg_values[k][colid] = DirectFunctionCall1(numeric_int8, datum);
						fdw_private->agg_value_type[colid] = INT8OID;
					}
					else
					{
						fdw_private->agg_values[k][colid] = datumCopy(datum,
																	  attr->attbyval,
																	  attr->attlen);
					}
				}
				colid++;
			}
		}
	}
	Assert(colid == fdw_private->temp_num_cols);

	MemoryContextSwitchTo(oldcontext);
	SPI_finish();
end:;
	SPD_RWUNLOCK_CATCH(&scan_mutex);
}

static float8
datum_to_float8(Oid type, Datum value)
{
	double		sum = 0;

	switch (type)
	{
		case INT4OID:
			sum = (float8) DatumGetInt32(value);
			break;
		case INT8OID:
			sum = (float8) DatumGetInt64(value);
			break;
		case INT2OID:
			sum = (float8) DatumGetInt16(value);
			break;
		case FLOAT4OID:
			sum = (float8) DatumGetFloat4(value);
			break;
		case FLOAT8OID:
			sum = (float8) DatumGetFloat8(value);
			break;
		case NUMERICOID:
		case BOOLOID:
		case TIMESTAMPOID:
		case DATEOID:
		default:
			Assert(false);
			break;
	}
	return sum;
}

/**
 * spd_calc_aggvalues
 *
 * This is called by Push-down case. calc result and set result.
 *
 * @param[in] slot
 * @param[in] rowid
 * @param[in,out] fdw_private
 */

static TupleTableSlot *
spd_calc_aggvalues(SpdFdwPrivate * fdw_private, int rowid, TupleTableSlot *slot)
{
	Datum	   *ret_agg_values = fdw_private->ret_agg_values;
	HeapTuple	tuple;
	bool	   *nulls;
	int			target_column;
	ListCell   *lc;
	Mappingcells *mapcells;

	target_column = 0;
	ret_agg_values = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
	nulls = (bool *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(bool));

	foreach(lc, fdw_private->mapping_tlist)
	{
		Mappingcell clist;
		int			mapping;

		mapcells = (Mappingcells *) lfirst(lc);
		clist = mapcells->mapping_tlist;

		mapping = clist.mapping[0];
		if (target_column != mapcells->original_attnum)
			continue;
		if (mapcells->aggtype != NON_SPLIT_AGGFLAG &&
			mapcells->aggtype != NONAGGFLAG)
		{
			int			count_mapping = clist.mapping[0];
			int			sum_mapping = clist.mapping[1];
			float8		result = 0.0;
			float8		sum = 0.0;
			float8		cnt = 0.0;

			if (fdw_private->agg_nulls[rowid][count_mapping])
				elog(ERROR, "COUNT() column is NULL.");

			if (fdw_private->agg_nulls[rowid][sum_mapping])
				nulls[target_column] = true;
			else
			{

				sum = datum_to_float8(fdw_private->agg_value_type[sum_mapping],
									  fdw_private->agg_values[rowid][sum_mapping]);

				/* Result of count should be INT8OID */
				Assert(fdw_private->agg_value_type[count_mapping] == INT8OID);
				cnt = (float8) DatumGetInt64(fdw_private->agg_values[rowid][count_mapping]);

				if (cnt == 0)
					elog(ERROR, "Record count is 0. Divide by zero error encountered.");

				if (mapcells->aggtype == AVGFLAG)
					result = sum / cnt;
				else
				{
					int			vardev_mapping = clist.mapping[2];
					float8		sum2 = 0.0;
					float8		right = 0.0;
					float8		left = 0.0;

					if (cnt == 1)
						elog(ERROR, "Record count is 1. Divide by zero error encountered.");

					sum2 = datum_to_float8(fdw_private->agg_value_type[vardev_mapping],
										   fdw_private->agg_values[rowid][vardev_mapping]);

					right = sum2;
					left = pow(sum, 2) / cnt;
					result = (float8) (right - left) / (float8) (cnt - 1);
					if (mapcells->aggtype == DEVFLAG)
					{
						float		var = 0.0;

						var = (float8) (right - left) / (float8) (cnt - 1);
						result = sqrt(var);
					}
				}

				if (fdw_private->agg_value_type[sum_mapping] == FLOAT8OID ||
					fdw_private->agg_value_type[sum_mapping] == FLOAT4OID)
					ret_agg_values[target_column] = Float8GetDatumFast(result);
				else
					ret_agg_values[target_column] = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(result));
			}
		}
		else
		{
			Assert(mapping < fdw_private->temp_num_cols);
			if (fdw_private->agg_nulls[rowid][mapping])
				nulls[target_column] = true;
			ret_agg_values[target_column] = fdw_private->agg_values[rowid][mapping];

		}
		target_column++;
	}
	Assert(target_column == slot->tts_tupleDescriptor->natts);
	tuple = heap_form_tuple(slot->tts_tupleDescriptor, ret_agg_values, nulls);
	ExecStoreTuple(tuple, slot, InvalidBuffer, false);
	fdw_private->agg_num++;
	return slot;
}

/**
 * spd_spi_select_table
 *
 * This is called by Push-down case.
 * If GROUP BY is used, spd_IterateForeignScan is called this fundction in firsttime.
 * After first time, spd_IterateForeignScan call spd_spi_setagg_result()
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
	int			max_col = 0;
	int			i;
	ListCell   *lc;
	int			j = 0;
	bool		isfirst = true;

	/* Create Select query */
	appendStringInfo(sql, "SELECT ");

	i = 0;
	foreach(lc, fdw_private->mapping_tlist)
	{
		TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, j);
		Mappingcells *cells = (Mappingcells *) lfirst(lc);
		char	   *agg_command = cells->agg_command->data;
		Mappingcell clist = cells->mapping_tlist;
		int			agg_type = cells->aggtype;

		for (i = 0; i < MAXDIVNUM; i++)
		{
			int			mapping = clist.mapping[i];

			if (max_col == mapping)
			{
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
					appendStringInfo(sql, "col%d", max_col);
					max_col++;
					continue;
				}
				else if (agg_type != NONAGGFLAG)
				{
					/*
					 * This is for aggregate functions
					 */
					if (!strcmpi(agg_command, "SUM") || !strcmpi(agg_command, "COUNT") ||
						!strcmpi(agg_command, "AVG") || !strcmpi(agg_command, "VARIANCE") ||
						!strcmpi(agg_command, "STDDEV"))
						appendStringInfo(sql, "SUM(col%d)", max_col);

					else if (!strcmpi(agg_command, "MAX") || !strcmpi(agg_command, "MIN") ||
							 !strcmpi(agg_command, "BIT_OR") || !strcmpi(agg_command, "BIT_AND") ||
							 !strcmpi(agg_command, "BOOL_AND") || !strcmpi(agg_command, "BOOL_OR") ||
							 !strcmpi(agg_command, "EVERY") || !strcmpi(agg_command, "STRING_AGG"))
						appendStringInfo(sql, "%s(col%d)", agg_command, max_col);

					/*
					 * This is for influx db functions. MAX has not effect to
					 * result. We have to consider multi-tenant.
					 */
					else if (!strcmpi(agg_command, "INFLUX_TIME") || !strcmpi(agg_command, "LAST"))
						appendStringInfo(sql, "MAX(col%d)", max_col);

					/*
					 * This is for aggregate function alias, for example,
					 * SELECT AVG(i) as bb, SUM(i) as aa.
					 *
					 * TODO: Maybe another cases are not supported now, we
					 * will continue to maintain later.
					 */
					else
						appendStringInfo(sql, "SUM(col%d)", max_col);
				}
				else			/* non agg */
				{
					/*
					 * This is for non aggregate without alias, the default
					 * column name always be "?column?".
					 */
					if (strcmp(agg_command, "?column?") == 0)
					{
						appendStringInfo(sql, "SUM(col%d)", max_col);
					}

					/*
					 * This is for non aggregate with alias not existed in
					 * groupby target
					 *
					 */
					else if (!list_member_int(fdw_private->groupby_target, max_col))
					{
						appendStringInfo(sql, "SUM(col%d)", max_col);
					}

					/*
					 * This is for non aggregate existing in both target list
					 * and groupby target.
					 *
					 * TODO: Maybe another cases are not supported now, we
					 * will continue to maintain later.
					 */
					else
					{
						appendStringInfo(sql, "col%d", max_col);
					}
				}
				max_col++;
			}
		}
		j++;
	}

	fdw_private->temp_num_cols = max_col;
	appendStringInfo(sql, " FROM %s ", fdw_private->temp_table_name);
	/* group by clause */
	if (fdw_private->groupby_string != 0)
		appendStringInfo(sql, "%s", fdw_private->groupby_string->data);
	elog(DEBUG1, "execute spi exec %s", sql->data);
	/* Execute aggregate query to temp table */
	spd_spi_exec_select(fdw_private, sql, slot);
	/* calc and set agg values */
	slot = spd_calc_aggvalues(fdw_private, 0, slot);
	return slot;
}

/**
 * spd_select_return_aggslot\
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
		slot = spd_calc_aggvalues(fdw_private, fdw_private->agg_num, slot);
		return slot;
	}
	else
		return NULL;
}

static void
spd_createtable_sql(StringInfo create_sql, List *mapping_tlist,
					ForeignScanThreadInfo * fssThrdInfo, char *temp_table,
					SpdFdwPrivate * fdw_private)
{
	ListCell   *lc;
	int			colid = 0;
	int			i;
	int			typeid;

	colid = 0;
	appendStringInfo(create_sql, "CREATE TEMP TABLE %s(", temp_table);
	foreach(lc, mapping_tlist)
	{
		Mappingcells *cells = lfirst(lc);

		for (i = 0; i < MAXDIVNUM; i++)
		{
			/* append aggregate string */
			if (colid == cells->mapping_tlist.mapping[i])
			{
				if (colid != 0)
					appendStringInfo(create_sql, ",");
				appendStringInfo(create_sql, "col%d ", colid);
				typeid = exprType((Node *) ((TargetEntry *) list_nth(fdw_private->child_comp_tlist, colid))->expr);
				/* append column name and column type */
				if (typeid == NUMERICOID)
					appendStringInfo(create_sql, " numeric");
				else if (typeid == TEXTOID)
					appendStringInfo(create_sql, " text");
				else if (typeid == FLOAT4OID)
					appendStringInfo(create_sql, " float");
				else if (typeid == FLOAT8OID)
					appendStringInfo(create_sql, " float8");
				else if (typeid == INT2OID)
					appendStringInfo(create_sql, " smallint");
				else if (typeid == INT4OID)
					appendStringInfo(create_sql, " int");
				else if (typeid == INT8OID)
					appendStringInfo(create_sql, " bigint");
				else if (typeid == BITOID)
					appendStringInfo(create_sql, " bit");
				else if (typeid == DATEOID)
					appendStringInfo(create_sql, " date");
				else if (typeid == TIMESTAMPOID)
					appendStringInfo(create_sql, " timestamp");
				else if (typeid == TIMESTAMPTZOID)
					appendStringInfo(create_sql, " timestamp with time zone");
				else if (typeid == BOOLOID)
					appendStringInfo(create_sql, " boolean");
				else
					appendStringInfo(create_sql, " numeric");
				colid++;
			}
		}
	}
	appendStringInfo(create_sql, ")");
	elog(DEBUG1, "create table  = %s", create_sql->data);
}

/**
 * spd_AddSpdUrl
 *
 * Add __spd_url column.
 * If child node is pgspider, then concatinate node name.
 * We don't convert heap tuple to virtual tuple because for update
 * using postgres_fdw and pgspider_fdw, ctid which virtual tuples
 * don't have is necessary.
 */
static TupleTableSlot *
spd_AddSpdUrl(ForeignScanThreadInfo * fssThrdInfo, TupleTableSlot *parent_slot,
			  int count, TupleTableSlot *node_slot, SpdFdwPrivate * fdw_private)
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
	 * Length of parent should be greater than or equal to length of child
	 * slot If spdurl is not specified, length is same
	 */
	Assert(parent_slot->tts_tupleDescriptor->natts >=
		   node_slot->tts_tupleDescriptor->natts);
	fs = fssThrdInfo[count].foreignServer;
	fdw = fssThrdInfo[count].fdw;

	/* Make tts_values and tts_nulls valid */
	slot_getallattrs(node_slot);

	/*
	 * Insert spdurl column to slot. heap_modify_tuple will replace the
	 * existing column. To insert new column and its data, we also follow the
	 * similar steps like heap_modify_tuple. First, deform tuple to get data
	 * values, Second, modify data values (insert new columm). Then, form
	 * tuple with new data values. Finally, copy identification info (if any)
	 */
	if (fdw_private->groupby_has_spdurl && (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) != 0))
	{
		char	   *spdurl;
		int			natts = parent_slot->tts_tupleDescriptor->natts;

		/* Initialize new tuple buffer */
		values = (Datum *) palloc0(sizeof(Datum) * natts);
		nulls = (bool *) palloc0(sizeof(bool) * natts);

		if (node_slot->tts_tuple != NULL)
		{
			/* Extract data to values/isnulls */
			heap_deform_tuple(node_slot->tts_tuple, node_slot->tts_tupleDescriptor, values, nulls);

			/* Insert spdurl to the array */
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

			/*
			 * copy the identification info of the old tuple: t_ctid, t_self,
			 * and OID (if any)
			 */
			newtuple->t_data->t_ctid = node_slot->tts_tuple->t_data->t_ctid;
			newtuple->t_self = node_slot->tts_tuple->t_self;
			newtuple->t_tableOid = node_slot->tts_tuple->t_tableOid;

			parent_slot->tts_tuple = newtuple;

			pfree(values);
			pfree(nulls);
		}
		else
		{
			/* tuple mode is VIRTUAL */
			for (i = 0; i < natts; i++)
			{
				if (i == fdw_private->idx_url_tlist)
				{
					spdurl = psprintf("/%s/", fs->servername);
					values[i] = CStringGetTextDatum(spdurl);
					nulls[i] = false;
				}
				else if (i < fdw_private->idx_url_tlist)
				{
					values[i] = node_slot->tts_values[i];
					nulls[i] = node_slot->tts_isnull[i];
				}
				else
				{
					values[i] = node_slot->tts_values[i - 1];
					nulls[i] = node_slot->tts_isnull[i - 1];
				}
			}
			parent_slot->tts_values = values;
			parent_slot->tts_isnull = nulls;
			/* to avoid assert failure in ExecStoreVirtualTuple */
			parent_slot->tts_isempty = true;
			ExecStoreVirtualTuple(parent_slot);
		}
	}
	else						/* Modify spdurl column */
	{
		/* Initialize new tuple buffer */
		values = palloc0(sizeof(Datum) * node_slot->tts_tupleDescriptor->natts);
		nulls = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
		replaces = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
		tnum = -1;

		for (i = 0; i < node_slot->tts_tupleDescriptor->natts; i++)
		{
			char	   *value;
			Form_pg_attribute attr = TupleDescAttr(node_slot->tts_tupleDescriptor, i);

			/*
			 * Check if i th attribute is __spd_url or not. If so, fill
			 * __spd_url slot. In target list push down case,
			 * tts_tupleDescriptor->attrs[i]->attname.data is NULL in some
			 * cases such as UNION. So we will use idx_url instead.
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
			if (node_slot->tts_tuple != NULL)
			{
				/* tuple mode is HEAP */
				newtuple = heap_modify_tuple(node_slot->tts_tuple, node_slot->tts_tupleDescriptor,
											 values, nulls, replaces);
				node_slot->tts_tuple = newtuple;
			}
			else
			{
				/* tuple mode is VIRTUAL */
				node_slot->tts_values[tnum] = values[tnum];
				node_slot->tts_isnull[tnum] = false;
				/* to avoid assert failure in ExecStoreVirtualTuple */
				node_slot->tts_isempty = true;
				ExecStoreVirtualTuple(node_slot);
			}
		}

		/*
		 * We need copy here because node_slot is shorter memory life than
		 * parent_slot
		 */
		ExecCopySlot(parent_slot, node_slot);
	}
	return parent_slot;


}

/*
  Return slot and nodeId of child which returns the slot if available.
  Return NULL if all threads are finished.
 */
static TupleTableSlot *
nextChildTuple(ForeignScanThreadInfo * fssThrdInfo, int nThreads, int *nodeId)
{
	int			count = 0;
	bool		all_thread_finished = true;
	TupleTableSlot *slot;

	for (count = 0;; count++)
	{
		bool		is_finished;

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
			oldcontext = MemoryContextSwitchTo(fdw_private->tmp_cxt);

			/*
			 * Use temp table name like __spd__temptable_(NUMBER) to avoid
			 * using the same table in different foreign scan
			 */
			fdw_private->temp_table_name = psprintf(AGGTEMPTABLE "_" INT64_FORMAT,
													temp_table_id++);
			/* Switch to CurrentMemoryContext */
			MemoryContextSwitchTo(oldcontext);

			spd_createtable_sql(create_sql, mapping_tlist, fssThrdInfo,
								fdw_private->temp_table_name, fdw_private);
			spd_spi_ddl_table(create_sql->data);
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
					 * If groupby has spdurl, we need to add spdurl back after
					 * removing from target list
					 */
					if (fdw_private->groupby_has_spdurl)
					{
						/* Clear tuple slot */
						ExecClearTuple(fdw_private->child_comp_slot);
						/* Add spdurl */
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

		if (tempSlot != NULL)
		{
			slot = node->ss.ss_ScanTupleSlot;
			ExecCopySlot(slot, tempSlot);
		}
		else
		{
			/*
			 * If all tuple getting is finished, then return NULL and drop
			 * table
			 */
			spd_spi_ddl_table(psprintf("DROP TABLE %s", fdw_private->temp_table_name));
			fdw_private->isFirst = true;
			fdw_private->is_drop_temp_table = true;
		}
	}
	else
	{
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
			fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH &&
			fssThrdInfo[node_incr].state != SPD_FS_STATE_ITERATE)
		{
			fssThrdInfo[node_incr].requestRescan = true;
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
	int			rtn;
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	SpdFdwPrivate *fdw_private;

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
		if (fdw_private->is_drop_temp_table == false && fdw_private->temp_table_name != NULL)
		{
			spd_spi_ddl_table(psprintf("DROP TABLE IF EXISTS %s", fdw_private->temp_table_name));
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

	/* wait until all the remote connections get closed. */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation)
			RelationClose(fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation);
		pfree(fssThrdInfo[node_incr].fsstate);

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

	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (throwErrorIfDead && fssThrdInfo[node_incr].state == SPD_FS_STATE_ERROR)
		{
			ForeignServer *fs;

			fs = GetForeignServer(fdw_private->childinfo[node_incr].server_oid);
			spd_aliveError(fs);
		}
	}
	pfree(fssThrdInfo);
}

/**
 * spd_check_url_update
 * Check and create url. If URL is nothing or can not find server
 * then return error.
 *
 * @param[in,out] fdw_private
 * @param[in] planSlot
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
	int			nums;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();

	if (rte->spd_url_list != NULL)
		spd_check_url_update(fdw_private, rte);
	else
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");

	spd_create_child_url(nums, rte, fdw_private);
	rel = heap_open(rte->relid, NoLock);

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
	heap_close(rel, NoLock);
	return list_make2(child_list, makeInteger(oid_server));
}

/**
 * spd_BeginForeignModify
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
 *		Update one row in a foreign table
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
 *		Delete one row in a foreign table, call child table.
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
