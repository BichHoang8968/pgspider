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
#include "parser/parsetree.h"
#include "utils/guc.h"
#include "utils/memutils.h"
#include "utils/palloc.h"
#include "utils/lsyscache.h"
#include "utils/builtins.h"
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
#define SPDURL "__spd_url"
#define AGGTEMPTABLE "__spd__temptable"

#define OIDCHECK(aggfnoid) ((aggfnoid >= AVG_MIN_OID && aggfnoid <= AVG_MAX_OID) ||(aggfnoid >= VAR_MIN_OID && aggfnoid <= VAR_MAX_OID) ||(aggfnoid >= STD_MIN_OID && aggfnoid <= STD_MAX_OID))


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
						 RelOptInfo *output_rel);

/*
 * Helper functions
 */
static bool foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel);
static void add_foreign_grouping_paths(PlannerInfo *root,
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

static List *spd_add_to_flat_tlist(List *tlist, List *exprs, List **mapping_tlist, List **mapping_orig_tlist, List **temp_tlist, int *child_uninum, Index sgref);
static void spd_spi_exec_child_ip(char *serverName, char *ip);

enum SpdFdwScanPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwScanPrivateSelectSql,
	/* List of restriction clauses that can be executed remotely */
	FdwScanPrivateRemoteConds,
	/* Integer list of attribute numbers retrieved by the SELECT */
	FdwScanPrivateRetrievedAttrs,
	/* Integer representing UPDATE/DELETE target */
	FdwScanPrivateForUpdate,
};
enum SpdFdwModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	ForeignFdwPrivate,
	/* Integer list of target attribute numbers for INSERT/UPDATE */
	ServerOid
};

enum Aggtype
{
	NOFLAG,
	AVGFLAG,
	VARFLAG,
	DEVFLAG,
};

enum SpdServerstatus
{
	ServerStatusAlive,
	ServerStatusUnder,
	ServerStatusDead,
};

typedef struct Mappingcell
{
	int			mapping[MAXDIVNUM];
	enum Aggtype aggtype;
}			Mappingcell;

typedef struct Mappingcells
{
	Mappingcell mapping_tlist;	/* pgspider target list */
	Mappingcell mapping_orig_tlist; /* original target list */
}			Mappingcells;



typedef struct ChildInfo
{
	PlannerInfo *root;
	RelOptInfo *baserel;
	Plan	   *plan;
	enum SpdServerstatus child_node_status;
	Oid			server_oid;		/* child table's server oid */
	Oid			oid;			/* child table's table oid */
	AggPath    *aggpath;
	PlannerInfo *grouped_root_local;
	RelOptInfo *grouped_rel_local;
	Agg		   *pAgg;			/* "Aggref" for Disable of aggregation push
								 * down servers */
}			ChildInfo;

/*
 * SpdFdwPrivate keep child node plan information for each child tables belonging to the parent table.
 * Spd create child table node plan from each spd_GetForeignRelSize(),spd_GetForeignPaths(),spd_GetForeignPlan().
 * SpdFdwPrivate is created at spd_GetForeignSize() using spd_AllocatePrivate().
 * SpdFdwPrivate is free at spd_EndForeignScan() using spd_ReleasePrivate().
 *
 */
typedef struct SpdFdwPrivate
{
	int			thrdsCreated;	/* child node thread is created or not */
	int			node_num;		/* number of child tables */
	bool		under_flag;		/* using UNDER clause or NOT */
	ChildInfo  *childinfo;		/* ChildInfo List */
	List	   *url_parse_list; /* lieteral of parse UNDER clause */
	pthread_t	foreign_scan_threads[NODES_MAX];	/* child node thread  */
	PgFdwRelationInfo rinfo;	/* pgspider reration info */
	List	   *pPseudoAggPushList; /* Enable of aggregation push down server
									 * list */
	List	   *pPseudoAggList; /* Disable of aggregation push down server
								 * list */
	List	   *pPseudoAggTypeList; /* Push down type list */
	List	   *tList;			/* target list */
	bool		agg_query;		/* aggregation flag */
	bool		isFirst;		/* First time of iteration foreign scan with
								 * aggregation query */
	Datum	  **agg_values;		/* aggregation temp table result set */
	bool	  **agg_nulls;		/* aggregation temp table result set */
	int			agg_tuples;		/* Number of aggregation tuples from temp
								 * table */
	int			agg_num;		/* agg_values cursor */
	int		   *agg_value_type; /* aggregation parameters */
	List	   *split_tlist;	/* child div(not compressd) target list */
	List	   *child_comp_tlist;	/* child complite target list */
	List	   *mapping_tlist;	/* mapping list orig and pgspider */
	struct PathTarget *child_tlist[UPPERREL_FINAL + 1]; /* */
	int			child_num;		/* number of push down child column */
	int			child_uninum;	/* number of NOT push down child column */
	List	   *groupby_target; /* group target tlist number */
	PlannerInfo *spd_root;		/* Copyt of root planner info. This is used by
								 * aggregation pushdown. */
	StringInfo	groupby_string; /* GROUP BY string for aggregation temp table */
	int			nThreads;		/* Number of alive threads */
	List	   *baserestrictinfo;	/* root node base strict info */
	Datum	   *ret_agg_values; /* result for groupby */
	bool		is_drop_temp_table; /* drop temp table flag in aggregation */
}			SpdFdwPrivate;

/* postgresql.conf paramater */
static bool throwErrorIfDead;
static bool isPrintError;

typedef struct SpdFdwModifyState
{
	Oid			modify_server_oid;
}			SpdFdwModifyState;

pthread_mutex_t scan_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;

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
 * @param[out] child_uninum - number of child list
 */

static List *
spd_add_to_flat_tlist(List *tlist, List *exprs, List **mapping_tlist, List **mapping_orig_tlist, List **compress_tlist, int *child_uninum, Index sgref)
{
	int			next_resno = list_length(tlist) + 1;
	int			next_resno_temp = list_length(*compress_tlist) + 1;
	int			target_num = 0;
	ListCell   *lc;

	foreach(lc, exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc);
		TargetEntry *tle_temp;
		TargetEntry *tle;
		Aggref	   *aggref;
		Mappingcells *mapcells = (struct Mappingcells *) palloc0(sizeof(struct Mappingcells));

		aggref = (Aggref *) expr;
		if (OIDCHECK(aggref->aggfnoid))
		{
			/* Prepare COUNT Query */
			Aggref	   *tempCount = copyObject((Aggref *) expr);
			Aggref	   *tempSum;
			Aggref	   *tempVar;

			tempVar = copyObject(tempCount);
			tempCount->aggfnoid = COUNT_OID;
			tempSum = copyObject(tempCount);
			tempSum->aggfnoid = SUM_OID;
			if (FLOAT4OID <= tempCount->aggtype || tempCount->aggtype <= FLOAT8OID)
			{
				tempSum->aggfnoid = SUM_FLOAT8_OID;
				tempSum->aggtype = FLOAT8OID;
				tempSum->aggtranstype = FLOAT8OID;
			}
			else
			{
				tempSum->aggtype = INT8OID;
				tempSum->aggtranstype = INT8OID;
			}
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
			mapcells->mapping_orig_tlist.mapping[0] = target_num;
			/* set avg flag */
			if (aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID)
				mapcells->mapping_orig_tlist.aggtype = AVGFLAG;
			else if (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
				mapcells->mapping_orig_tlist.aggtype = VARFLAG;
			else if (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)
				mapcells->mapping_orig_tlist.aggtype = DEVFLAG;

			/* count */
			if (!spd_tlist_member((Expr *) tempCount, *compress_tlist, &target_num))
			{
				tle_temp = makeTargetEntry((Expr *) tempCount,
										   next_resno_temp++,
										   NULL,
										   false);
				*compress_tlist = lappend(*compress_tlist, tle_temp);
				*child_uninum += 1;
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
				*child_uninum += 1;
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
					OpExpr	   *opexpr = copyObject((OpExpr *) opvar);
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
					*child_uninum += 1;
				}
			}
			mapcells->mapping_tlist.mapping[2] = target_num;
			*mapping_tlist = lappend(*mapping_tlist, mapcells);
		}
		else
		{
			Expr	   *expr = (Expr *) lfirst(lc);
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
			mapcells->mapping_orig_tlist.aggtype = NOFLAG;
			mapcells->mapping_orig_tlist.mapping[0] = target_num;
			/* div tlist */
			if (!spd_tlist_member(expr, *compress_tlist, &target_num))
			{
				tle_temp = makeTargetEntry(copyObject(expr),
										   next_resno_temp++,
										   NULL,
										   false);
				tle_temp->ressortgroupref = sgref;
				*compress_tlist = lappend(*compress_tlist, tle_temp);
				*child_uninum += 1;
			}
			mapcells->mapping_tlist.aggtype = NOFLAG;
			mapcells->mapping_tlist.mapping[0] = target_num;
			*mapping_tlist = lappend(*mapping_tlist, mapcells);
		}
	}
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

	if (fdw_private->url_parse_list != NIL)
	{
		entry = (char *) list_nth(fdw_private->url_parse_list, 0);
	}

	/* get child server name from child's foreign table id */
	if (fdw_private->under_flag == 0)
	{
		sprintf(query, "SELECT oid from pg_class WHERE relname LIKE \
                '%s\\_\\_\%%' ORDER BY relname;", parentTableName);
	}
	else
	{
		/* if UNDER clause is used, then return UNDER child tables only, */
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
	pthread_mutex_lock(&error_mutex);
	EmitErrorReport();
	pthread_mutex_unlock(&error_mutex);
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
	MemoryContext oldcontext = MemoryContextSwitchTo(
													 fssthrdInfo->threadMemoryContext);
	PGcancel   *cancel;
	char		errbuf[BUFFERSIZE];
	int			errflag = 0;
#ifdef MEASURE_TIME
	struct timeval s,
				e,
				e1;
#endif
	ErrorContextCallback errcallback;
	SpdFdwPrivate *fdw_private = fssthrdInfo->private;
	AggState   *aggState = NULL;

	CurrentResourceOwner = fssthrdInfo->thrd_ResourceOwner;
#ifdef MEASURE_TIME
	gettimeofday(&s, NULL);
#endif
	/* Declare ereport/elog jump is not available. */
	PG_exception_stack = NULL;
	errcallback.callback = spd_ErrorCb;
	errcallback.arg = NULL;
	errcallback.previous = NULL;
	error_context_stack = &errcallback;

	/* Begin Foreign Scan */
	fssthrdInfo->state = SPD_FS_STATE_BEGIN;
	pthread_mutex_init((pthread_mutex_t *) &fssthrdInfo->nodeMutex, NULL);
	PG_TRY();
	{
		pthread_mutex_lock(&scan_mutex);
		fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
												  fssthrdInfo->eflags);
		pthread_mutex_unlock(&scan_mutex);

#ifdef MEASURE_TIME
		gettimeofday(&e, NULL);
		elog(DEBUG1, "thread%d begin foreign scan time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	}
	PG_CATCH();
	{
		errflag = 1;
		pthread_mutex_unlock(&scan_mutex);
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
	}
	PG_END_TRY();

	if (errflag)
	{
		goto THREAD_EXIT;
	}

RESCAN:

	/*
	 * Do rescan after return .. If Rescan is queried before iteration, just
	 * continue operation
	 *
	 * Rescan is executed about join, union and some operation. If Rescan need
	 * to in operation, then fssthrdInfo->queryRescan flag is TRUE. But first
	 * time rescan is not need.(fssthrdInfo->state = SPD_FS_STATE_BEGIN) Then
	 * skip to rescan sequence.
	 */
	if (fssthrdInfo->queryRescan &&
		fssthrdInfo->state != SPD_FS_STATE_BEGIN)
	{
		fssthrdInfo->fdwroutine->ReScanForeignScan(fssthrdInfo->fsstate);
		fssthrdInfo->iFlag = true;
		fssthrdInfo->tuple = NULL;
		fssthrdInfo->queryRescan = false;
	}
	fssthrdInfo->state = SPD_FS_STATE_ITERATE;

	if (list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
	{
		aggState = SPI_execIntiAgg(
								   fdw_private->childinfo[fssthrdInfo->childInfoIndex].pAgg,
								   fssthrdInfo->fsstate->ss.ps.state, 0);
	}
	PG_TRY();
	{
		while (1)
		{
			/* when get result request recieved ,then break */
#ifdef GETPROGRESS_ENABLED
			if (getResultFlag)
			{
				fssthrdInfo->iFlag = false;
				fssthrdInfo->tuple = NULL;
				break;
			}
#endif
			if (fssthrdInfo->iFlag && !fssthrdInfo->tuple)
			{
				TupleTableSlot *slot;

				if (list_member_oid(fdw_private->pPseudoAggList,
									fssthrdInfo->serverId))
				{
					/*
					 * Retreives aggregated value tuple from underlying non
					 * pushdown source
					 */
					slot = SPI_execAgg(aggState);
				}
				else
				{
					pthread_mutex_lock(&scan_mutex);
					PG_TRY();
					{
						slot = fssthrdInfo->fdwroutine->IterateForeignScan(fssthrdInfo->fsstate);
					}
					PG_CATCH();
					{
						pthread_mutex_unlock(&scan_mutex);
						PG_RE_THROW();
					} PG_END_TRY();
					pthread_mutex_unlock(&scan_mutex);
				}

				if (slot == NULL)
				{
					fssthrdInfo->iFlag = false;
					fssthrdInfo->tuple = NULL;
					break;
				}
				if (slot->tts_isempty)
				{
					fssthrdInfo->iFlag = false;
					fssthrdInfo->tuple = NULL;
					break;
				}

				/* when get result request recieved */
#ifdef GETPROGRESS_ENABLED
				if (!slot->tts_isempty && getResultFlag)
				{
					fssthrdInfo->iFlag = false;

					cancel = PQgetCancel((PGconn *) fssthrdInfo->fsstate->conn);
					if (!PQcancel(cancel, errbuf, BUFFERSIZE))
						elog(WARNING, " Failed to PQgetCancel");
					PQfreeCancel(cancel);
					break;
				}
#endif
				fssthrdInfo->tuple = slot;
			}
			else
			{
				usleep(1);
			}
			/* If Rescan is queried here, do rescan after break */
			if (fssthrdInfo->queryRescan || fssthrdInfo->EndFlag)
			{
				break;
			}
		}
	}
	PG_CATCH();
	{
		errflag = 1;
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
		fssthrdInfo->iFlag = false;
		if (fssthrdInfo->fsstate->conn)
		{
			cancel = PQgetCancel((PGconn *) fssthrdInfo->fsstate->conn);
			if (!PQcancel(cancel, errbuf, BUFFERSIZE))
				elog(WARNING, " Failed to PQgetCancel");
			PQfreeCancel(cancel);
		}
		elog(DEBUG1, "Thread error occurred during IterateForeignScan(). %s:%d",
			 __FILE__, __LINE__);
	}
	PG_END_TRY();
	if (errflag)
	{
		goto THREAD_EXIT;
	}
	if (fssthrdInfo->queryRescan)
	{
		Assert(!fssthrdInfo->EndFlag);
		goto RESCAN;
	}
#ifdef MEASURE_TIME
	gettimeofday(&e1, NULL);
	elog(DEBUG1, "thread%d end ite time = %lf", fssthrdInfo->serverId, (e1.tv_sec - e.tv_sec) + (e1.tv_usec - e.tv_usec) * 1.0E-6);
#endif
	/* End of the ForeignScan */
	fssthrdInfo->state = SPD_FS_STATE_END;
	PG_TRY();
	{
		while (1)
		{
			if (fssthrdInfo->EndFlag || errflag)
			{
				fssthrdInfo->fdwroutine->EndForeignScan(fssthrdInfo->fsstate);
				fssthrdInfo->EndFlag = false;
				break;
			}
			else
			{
				usleep(1);
				/* If Rescan is queried here, do rescan after break */
				if (fssthrdInfo->queryRescan)
				{
					break;
				}
			}
		}
	}
	PG_CATCH();
	{
		elog(DEBUG1, "Thread error occurred during EndForeignScan(). %s:%d",
			 __FILE__, __LINE__);
	}
	PG_END_TRY();

	if (fssthrdInfo->queryRescan)
	{
		Assert(!fssthrdInfo->EndFlag);
		goto RESCAN;
	}
	fssthrdInfo->state = SPD_FS_STATE_FINISH;
THREAD_EXIT:
	fssthrdInfo->iFlag = false;
	fssthrdInfo->tuple = NULL;
#ifdef MEASURE_TIME
	gettimeofday(&e, NULL);
	elog(DEBUG1, "thread%d all time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	MemoryContextSwitchTo(oldcontext);
	pthread_exit(NULL);
}

/**
 * Parse UNDER url name.
 * parse list is 3 pattern.
 * Pattern1 Url = /sample/test/code/
 *  Original URL "sample" First URL "test"  Throwing URL "/test/code/"
 * Pattern2 Url = /sample/test/
 *  Original URL "sample" First URL "test"  Throwing URL "/test/"
 * Pattern3 Url = /sample/
 *  Original URL "sample" First URL NULL  Throwing URL NULL
 * Pattern4 Url = "/"
 *  Original URL NULL First URL NULL  Throwing URL NULL
 *
 * @param[in] url_str - URL
 * @param[out] fdw_private - store to parsing URL
 */
static void
spd_ParseUrl(char *url_str, SpdFdwPrivate * fdw_private)
{
	char	   *tp;
	char	   *url_option;
	char	   *next = NULL;
	char	   *throwing_url = NULL;
	int			original_len;

	url_option = pstrdup(url_str);
	if (url_option[0] != '/')
		elog(ERROR, "URL first character should set '/' ");
	url_option++;
	tp = strtok_r(url_option, "/", &next);
	if (tp != NULL)
		fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, tp); /* Original URL */
	else
		return;					/* Pattern4 */

	/*
	 * url_option = /sample\ntest/code ^ *tp position url_str =
	 * /sample/test/code/ |---------| <-Throwing URL * <- This pointer is
	 * url_str[strlen(tp)+ 1]
	 */
	original_len = strlen(tp) + 1;
	throwing_url = pstrdup(&url_str[original_len]);
	tp = strtok_r(url_option, "/", &next);	/* First URL */
	fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, tp);
	if (strlen(throwing_url) != 1)
		fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, throwing_url);
}


/**
 * Get URL from RangeTableEntry and create new URL with deleting first URL.
 *
 * @param[in] nums - num of child tables
 * @param[in] url_str - old URL
 * @param[in] fdw_private - store to parsing URL
 * @param[out] new_underurl - new URL
 *
 */
static void
spd_create_child_url(int childnums, RangeTblEntry *r_entry, SpdFdwPrivate * fdw_private, char **new_underurl)
{
	char	   *original_url = NULL;
	char	   *throwing_url = NULL;
	char	   *first_url = NULL;

	if (r_entry->url == NULL)
	{
		/* UNDER clause does not use. all child table is alive now. */
		for (int i = 0; i < childnums; i++)
		{
			fdw_private->childinfo[i].child_node_status = ServerStatusAlive;
		}
		return;
	}

	/*
	 * entry is first parsing word(/foo/bar/, then entry is "foo",entry2 is
	 * "bar")
	 */
	spd_ParseUrl(r_entry->url, fdw_private);
	if (fdw_private->url_parse_list == NULL)
		elog(ERROR, "UNDER Clause use but can not find url. Please set UNDER string.");
	if (fdw_private->url_parse_list->length == 0)
	{
		for (int i = 0; i < childnums; i++)
			fdw_private->childinfo[i].child_node_status = ServerStatusAlive;
		return;
	}
	original_url = (char *) list_nth(fdw_private->url_parse_list, 0);
	if (fdw_private->url_parse_list->length > 2)
	{
		first_url = (char *) list_nth(fdw_private->url_parse_list, 1);
		throwing_url = (char *) list_nth(fdw_private->url_parse_list, 2);
	}
	/* If UNDER Clause is used, then store to parsing url */
	for (int i = 0; i < childnums; i++)
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
			fdw_private->childinfo[i].child_node_status = ServerStatusUnder;
			continue;
		}
		fdw_private->childinfo[i].child_node_status = ServerStatusAlive;

		/*
		 * if child-child node is exist, then create New UNDER clause. New
		 * UNDER clause is used by child spd server.
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
			fdw_private->under_flag = 1;
			*new_underurl = pstrdup(first_url);
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
				colname = get_relid_attribute_name(rte->relid, expr->varattno);
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
		case T_ArrayRef:
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

		if (spd_basestrictinfo_tree_walker((Node *) expr, root) != TRUE)
		{
			entry_baserel->reltarget->exprs = lappend(entry_baserel->reltarget->exprs, expr);
		}
	}
}

/* Remove __spd_url from target lists */
static List *
remove_spdurl_from_targets(List *exprs, PlannerInfo *root)
{
	ListCell   *lc;

	/* Cannot use foreach because we modify exprs in the loop */
	for ((lc) = list_head(exprs); (lc) != NULL;)
	{
		RangeTblEntry *rte;
		char	   *colname;
		Node	   *node = (Node *) lfirst(lc);

		if (IsA(node, Var))
		{
			Var		   *var = (Var *) node;

			rte = planner_rt_fetch(var->varno, root);
			colname = get_relid_attribute_name(rte->relid, var->varattno);

			if (strcmp(colname, SPDURL) == 0)
			{
				ListCell   *temp = lc;

				lc = lnext(lc);
				exprs = list_delete_ptr(exprs, lfirst(temp));
				continue;
			}
		}
		lc = lnext(lc);
	}
	return exprs;
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
 * @param[in] new_underurl - new UNDER clause url
 * @param[in] oid_server - Parent table oid
 * @param[inout] fdw_private - child table's base plan is saved
 */
static void
spd_CreateDummyRoot(PlannerInfo *root, RelOptInfo *baserel, Oid *oid, int oid_nums, RangeTblEntry *r_entry,
					char *new_underurl, SpdFdwPrivate * fdw_private)
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
		 * if child node is spd and UNDER clause is used, then should set new
		 * UNDER clause URL at child node planner URL.
		 */
		if (new_underurl != NULL)
		{
			rte->url = palloc0(sizeof(char) * strlen(new_underurl));
			strcpy(rte->url, new_underurl);
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
			entry_baserel->reltarget->exprs = remove_spdurl_from_targets(entry_baserel->reltarget->exprs, root);
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
				if (throwErrorIfDead)
					spd_aliveError(fs);
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
 * @param[in] new_underurl - new UNDER clause url
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
	fdw_private->isFirst = TRUE;
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
 * 2. Check UNDER clause and create next UNDER clause (delete head of URL)
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
	MemoryContext oldcontext;
	SpdFdwPrivate *fdw_private;
	Oid		   *oid = NULL;
	int			nums;
	char	   *new_underurl = NULL;
	RangeTblEntry *r_entry;
	char	   *namespace = NULL;
	char	   *relname = NULL;
	char	   *refname = NULL;
	RangeTblEntry *rte;

	baserel->rows = 1000;
	fdw_private = spd_AllocatePrivate();
	fdw_private->rinfo.pushdown_safe = true;
	baserel->fdw_private = (void *) fdw_private;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	/* get child datasouce oid and nums */
	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);
	if (nums == 0)
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));

	fdw_private->node_num = nums;
	fdw_private->childinfo = (ChildInfo *) palloc0(sizeof(ChildInfo) * nums);

	for (int i = 0; i < nums; i++)
		fdw_private->childinfo[i].oid = oid[i];
	Assert(baserel->reloptkind == RELOPT_BASEREL);
	r_entry = root->simple_rte_array[baserel->relid];
	Assert(r_entry != NULL);

	/* Check to UNDER clause and execute only UNDER URL server */
	if (r_entry->url != NULL)
		spd_create_child_url(nums, r_entry, fdw_private, &new_underurl);
	else
	{
		for (int i = 0; i < nums; i++)
		{
			fdw_private->childinfo[i].child_node_status = ServerStatusAlive;
		}
	}

	/* Create base plan for each child tables and exec GetForeignRelSize */
	spd_CreateDummyRoot(root, baserel, oid, nums, r_entry, new_underurl, fdw_private);

	MemoryContextSwitchTo(oldcontext);

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
		OpExpr	   *opexpr = copyObject((OpExpr *) opvar);
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
	elog(DEBUG1, "div tlist");
	/* add original mapping list */
	fdw_private->split_tlist = lappend_int(fdw_private->split_tlist, 1);
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
						 RelOptInfo *input_rel, RelOptInfo *output_rel)
{
	SpdFdwPrivate *fdw_private,
			   *in_fdw_private;
	List	   *split_tlist = NIL;
	List	   *newList = NIL;
	ListCell   *lc;
	MemoryContext oldcontext;
	RelOptInfo *output_rel_tmp = (RelOptInfo *) palloc0(sizeof(RelOptInfo));
	PlannerInfo *spd_root;
	int			i;
	int			listn = 0;
	RelOptInfo *dummy_output_rel;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	output_rel_tmp = (RelOptInfo *) palloc0(sizeof(RelOptInfo));

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
	output_rel_tmp->fdw_private = (SpdFdwPrivate *) palloc0(sizeof(SpdFdwPrivate));

	/* Prepare SpdFdwPrivate for output RelOptInfo */
	fdw_private = spd_AllocatePrivate();
	fdw_private->thrdsCreated = in_fdw_private->thrdsCreated;
	fdw_private->node_num = in_fdw_private->node_num;
	fdw_private->under_flag = in_fdw_private->under_flag;
	fdw_private->pPseudoAggPushList = NIL;
	fdw_private->pPseudoAggList = NIL;
	fdw_private->pPseudoAggTypeList = NIL;
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

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
	for (i = 0; i < UPPERREL_FINAL + 1; i++)
	{
		fdw_private->child_tlist[i] = (struct PathTarget *) palloc0(sizeof(struct PathTarget));
		if (root->upper_targets[i] != NULL)
			fdw_private->child_tlist[i] = copy_pathtarget(root->upper_targets[i]);
	}
	foreach(lc, spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
	{
		Aggref	   *aggref;
		Expr	   *temp_expr;

		temp_expr = list_nth(fdw_private->child_tlist[UPPERREL_GROUP_AGG]->exprs, listn);
		aggref = (Aggref *) temp_expr;
		listn++;
		if (OIDCHECK(aggref->aggfnoid))
		{
			newList = spd_makedivtlist(aggref, newList, fdw_private);
		}
		else
		{
			newList = lappend(newList, temp_expr);
			fdw_private->split_tlist = lappend(fdw_private->split_tlist, 0);
		}
		newList = lappend(newList, temp_expr);
		fdw_private->split_tlist = lappend(fdw_private->split_tlist, 0);
	}
	spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs = NIL;
	foreach(lc, newList)
	{
		Expr	   *expr = (Expr *) lfirst(lc);

		elog(DEBUG1, "insert expr");
		spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
			lappend(spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, expr);
	}
	/* pthread_mutex_unlock(&scan_mutex); */
	elog(DEBUG1, "main upperpath add");
	fdw_private->split_tlist = split_tlist;
	fdw_private->childinfo = in_fdw_private->childinfo;
	fdw_private->rinfo.pushdown_safe = false;
	output_rel->fdw_private = fdw_private;
	output_rel->relid = input_rel->relid;
	add_foreign_grouping_paths(root, input_rel, output_rel);

	/* Call the below FDW's GetForeignUpperPaths */
	if (in_fdw_private->childinfo != NULL)
	{
		Oid			oid_server;
		FdwRoutine *fdwroutine;
		int			i = 0;
		ChildInfo  *childinfo = in_fdw_private->childinfo;

		for (i = 0; i < fdw_private->node_num; i++)
		{
			List	   *newList = NIL;
			Oid			rel_oid = childinfo[i].oid;
			RelOptInfo *entry = childinfo[i].baserel;
			PlannerInfo *dummy_root = childinfo[i].root;
			RelOptInfo *dummy_output_rel;

			int			listn = 0;

			dummy_root->parse->groupClause = root->parse->groupClause;
			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			/* pthread_mutex_lock(&scan_mutex); */
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			/* Currently dummy. @todo more better parsed object. */
			dummy_root->parse->hasAggs = true;
			/* Call below FDW to check it is OK to pushdown or not. */
			/* refer relnode.c fetch_upper_rel() */
			dummy_output_rel = makeNode(RelOptInfo);
			dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
			dummy_output_rel->relids = bms_copy(entry->relids);
			dummy_output_rel->reltarget = create_empty_pathtarget();

			dummy_root->upper_rels[UPPERREL_GROUP_AGG] =
				lappend(dummy_root->upper_rels[UPPERREL_GROUP_AGG],
						dummy_output_rel);
			/* make pathtarget */

			MemoryContextSwitchTo(TopTransactionContext);
			dummy_root->upper_targets[UPPERREL_GROUP_AGG] =
				copy_pathtarget(spd_root->upper_targets[UPPERREL_GROUP_AGG]);
			dummy_root->upper_targets[UPPERREL_WINDOW] =
				copy_pathtarget(spd_root->upper_targets[UPPERREL_WINDOW]);
			dummy_root->upper_targets[UPPERREL_FINAL] =
				copy_pathtarget(spd_root->upper_targets[UPPERREL_FINAL]);
			oldcontext = MemoryContextSwitchTo(MessageContext);

			foreach(lc, root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
			{
				Expr	   *expr = (Expr *) lfirst(lc);
				Aggref	   *aggref;

				aggref = (Aggref *) expr;
				listn++;
				if (OIDCHECK(aggref->aggfnoid))
				{
					newList = spd_makedivtlist(aggref, newList, fdw_private);
				}
				else
				{
					elog(DEBUG1, "insert orign expr");
					newList = lappend(newList, expr);
				}
			}
			dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs = NIL;
			foreach(lc, newList)
			{
				Expr	   *expr = (Expr *) lfirst(lc);

				dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
					lappend(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, expr);
			}
			if (fdwroutine->GetForeignUpperPaths != NULL)
			{
				fdwroutine->GetForeignUpperPaths(
												 dummy_root,
												 stage, entry,
												 dummy_output_rel);
			}
			if (dummy_output_rel->pathlist != NULL)
			{
				/* Push down aggregate case */
				childinfo[i].grouped_root_local = dummy_root;
				childinfo[i].grouped_rel_local = dummy_output_rel;
				fdw_private->pPseudoAggPushList = lappend_oid(fdw_private->pPseudoAggPushList, oid_server);
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
				childinfo[i].aggpath = (AggPath *) create_agg_path((PlannerInfo *) dummy_root,
																   dummy_output_rel,
																   tmp_path,
																   dummy_root->upper_targets[UPPERREL_GROUP_AGG],
																   query->groupClause ? AGG_SORTED : AGG_PLAIN, AGGSPLIT_SIMPLE,
																   query->groupClause, NULL, &dummy_aggcosts,
																   1);
				fdw_private->pPseudoAggList = lappend_oid(fdw_private->pPseudoAggList, oid_server);
			}
		}
	}
	MemoryContextSwitchTo(oldcontext);
}

/**
 * add_foreign_grouping_paths
 *		Add foreign path for grouping and/or aggregation.
 *
 * Given input_rel represents the underlying scan.  The paths are added to the
 * given grouped_rel.
 *
 * @param[in] root - base planner information
 * @param[in] input_rel - input RelOptInfo
 * @param[in] grouped_rel - grouped relation RelOptInfo
 */
static void
add_foreign_grouping_paths(PlannerInfo *root, RelOptInfo *input_rel,
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
		return;

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
		return;

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

	/* Add generated path into grouped_rel by add_path(). */
	add_path(grouped_rel, (Path *) grouppath);
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
	int			child_uninum = 0;
	int			groupby_cursor = 0;
	List	   *tlist = NIL;
	List	   *mapping_tlist = NIL;
	List	   *mapping_orig_tlist = NIL;
	List	   *temp_tlist = NIL;

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
			before_listnum = child_uninum;
			tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);
			if (child_uninum - before_listnum > 0)
				groupby_cursor += child_uninum - before_listnum;
			fpinfo->groupby_target = lappend_int(fpinfo->groupby_target, groupby_cursor - 1);
		}
		else
		{
			/* Check entire expression whether it is pushable or not */
			if (is_foreign_expr(root, grouped_rel, expr))
			{
				/* Pushable, add to tlist */
				int			before_listnum = child_uninum;

				tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);
				if (child_uninum - before_listnum > 0)
					groupby_cursor += child_uninum - before_listnum;
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
						int			before_listnum = child_uninum;

						tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);
						i += child_uninum - before_listnum;
						if (child_uninum - before_listnum > 0)
							groupby_cursor += child_uninum - before_listnum;
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
	fpinfo->child_num = (temp_tlist)->length;
	fpinfo->mapping_tlist = mapping_tlist;
	fpinfo->child_uninum = child_uninum;
	fpinfo->child_comp_tlist = temp_tlist;

	return true;
}

static void
spd_ExplainForeignScan(ForeignScanState *node,
					   ExplainState *es)
{
	MemoryContext oldcontext;
	FdwRoutine *fdwroutine;
	int			i;
	ChildInfo  *childinfo;
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *)
	((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;

	if (fdw_private == NULL)
		elog(ERROR, "fdw_private is NULL");

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	/* Create Foreign paths using base_rel_list to each child node. */
	childinfo = fdw_private->childinfo;
	for (i = 0; i < fdw_private->node_num; i++)
	{
		ForeignServer *fs;

		fs = GetForeignServer(childinfo[i].server_oid);
		fdwroutine = GetFdwRoutineByServerId(childinfo[i].server_oid);
		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (childinfo[i].child_node_status != ServerStatusAlive)
			continue;

		if (fdwroutine->ExplainForeignScan == NULL)
			continue;

		/* create node info */
		PG_TRY();
		{
			fsplan->fdw_private = ((ForeignScan *) childinfo[i].plan)->fdw_private;

			/*
			 * TODO: Call ExplainForeignScan. Now it cause crash because node
			 * is not child plan
			 */
			/* fdwroutine->ExplainForeignScan(node, es); */
			if (es->verbose)
			{
				char	   *buf = "NodeName";

				if (fdw_private->agg_query)
				{
					buf = psprintf("Agg push-down: %s / NodeName", childinfo[i].aggpath ? "no" : "yes");
				}
				ExplainPropertyText(buf, fs->servername, es);
			}

		}
		PG_CATCH();
		{
			/*
			 * If fail to create foreign paths, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			childinfo[i].child_node_status = ServerStatusDead;
			elog(WARNING, "fdw ExplainForeignScan error is occurred.");
		}
		PG_END_TRY();
	}
	MemoryContextSwitchTo(oldcontext);
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
	MemoryContext oldcontext;
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
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

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
			if (throwErrorIfDead)
				spd_aliveError(fs);
		}
		PG_END_TRY();
	}
	baserel->rows = rows;
	MemoryContextSwitchTo(oldcontext);
	/* elog(WARNING,"totalcost = %f %f %f",startup_cost,rows,total_cost); */
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
				expr->varattno = att;
				att++;
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
		case T_ArrayRef:
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
spd_createPushDownPlan(List *tlist, bool *agg_query, SpdFdwPrivate * fdw_private)
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
		spd_expression_tree_walker((Node *) aggref, 1);
	}
	return dummy_tlist;
}

/**
 * spd_checkurl_clauses
 *
 * Build aggregation plan for each push down cases.
 * saving each foreign plan into base rel list
 *
 * @param[in] scan_clauses -
 * @param[in] root
 * @param[in] baserestrictinfo -
 * @param[out] agg_query          - aggregation flag
 * @param[out] fdw_private        - Push down type list
 *
 */

static void
spd_checkurl_clauses(List *scan_clauses, List **push_scan_clauses, PlannerInfo *root, List *baserestrictinfo)
{
	ListCell   *lc;

	foreach(lc, scan_clauses)
	{
		RestrictInfo *clause = (RestrictInfo *) lfirst(lc);
		Expr	   *expr = (Expr *) clause->clause;
		ListCell   *arg;

		if (nodeTag(expr) == T_OpExpr)
		{
			OpExpr	   *node = (OpExpr *) clause->clause;
			Expr	   *expr2;

			/* Deparse left operand. */
			arg = list_head(node->args);
			expr2 = (Expr *) lfirst(arg);
			if (nodeTag(expr2) == T_Var)
			{
				Var		   *var = (Var *) expr2;
				char	   *colname;
				RangeTblEntry *rte;

				rte = planner_rt_fetch(var->varno, root);
				colname = get_relid_attribute_name(rte->relid, var->varattno);

				if (strcmp(colname, SPDURL) == 0)
					*push_scan_clauses = NULL;

				else
					*push_scan_clauses = baserestrictinfo;
			}
			/* Deparse right operand */
			arg = list_tail(node->args);
			expr2 = (Expr *) lfirst(arg);
			if (nodeTag(expr2) == T_Var)
			{
				Var		   *var = (Var *) expr2;
				char	   *colname;
				RangeTblEntry *rte;

				rte = planner_rt_fetch(var->varno, root);
				colname = get_relid_attribute_name(rte->relid, var->varattno);

				if (strcmp(colname, SPDURL) == 0)
				{
					*push_scan_clauses = NULL;
				}
			}
		}
	}
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
	MemoryContext oldcontext;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Index		scan_relid;
	List	   *fdw_scan_tlist = NIL;	/* Need dummy tlist for pushdown case. */
	List	   *child_tlist;
	List	   *push_scan_clauses = scan_clauses;
	ListCell   *lc;
	int			colname_tlist_length = 0;
	TargetEntry *tle;
	ChildInfo  *childinfo;
	ForeignServer *fs;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	if (fdw_private == NULL)
		elog(ERROR, "fdw_private is NULL");
	/* check column is Not Only "__spd_url" */
	if (tlist)
	{
		if (tlist->length == 1)
		{
			tle = lfirst_node(TargetEntry, tlist->head);
			if (IsA(tle->expr, Var))
			{
				Var		   *var = (Var *) tle->expr;
				RangeTblEntry *rte;
				char	   *colname;

				rte = planner_rt_fetch(var->varno, root);
				colname = get_relid_attribute_name(rte->relid, var->varattno);
				if (strcmp(colname, SPDURL) == 0)
				{
					colname_tlist_length++;
				}
			}
		}
		if (tlist->length == colname_tlist_length)
			elog(ERROR, "SELECT column name attribute ONLY");
	}

	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);

	fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	fdw_private->tList = list_copy(tlist);

	/* Create "GROUP BY" string */
	if (root->parse->groupClause != NULL)
	{
		bool		first = true;

		fdw_private->groupby_string = makeStringInfo();
		appendStringInfo(fdw_private->groupby_string, "GROUP BY ");
		foreach(lc, fdw_private->groupby_target)
		{
			int			cl = lfirst_int(lc);
			char	   *colname = NULL;

			if (!first)
				appendStringInfoString(fdw_private->groupby_string, ", ");
			first = false;

			appendStringInfoString(fdw_private->groupby_string, "(");

			colname = psprintf("col%d", cl);
			appendStringInfoString(fdw_private->groupby_string, colname);
			appendStringInfoString(fdw_private->groupby_string, ")");
		}
	}
	childinfo = fdw_private->childinfo;
	/* Create Foreign Plans using base_rel_list to each child. */
	for (i = 0; i < fdw_private->node_num; i++)
	{
		ForeignScan *temp_obj;
		RelOptInfo *entry;
		List	   *temptlist;

		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (childinfo[i].baserel == NULL)
			break;
		if (childinfo[i].child_node_status != ServerStatusAlive)
		{
			continue;
		}
		/* get child node's oid. */
		server_oid = childinfo[i].server_oid;
		entry = (RelOptInfo *) childinfo[i].baserel;
		if (entry == NULL)
		{
			continue;
		}
		fdwroutine = GetFdwRoutineByServerId(server_oid);
		if (list_member_oid(fdw_private->pPseudoAggPushList, server_oid) ||
			list_member_oid(fdw_private->pPseudoAggList, server_oid))
		{
			fdw_private->agg_query = 1;
			child_tlist = spd_createPushDownPlan(fdw_private->child_comp_tlist, &fdw_private->agg_query, fdw_private);
		}
		else
		{
			/*
			 * Group by clause for Pushdown case need to be added in
			 * dummy_root_list check for any other better way then this in
			 * future
			 */
			fdw_private->agg_query = 0;
			if (root->parse->groupClause != NULL)
			{
				((PlannerInfo *) childinfo[i].root)->parse->groupClause =
					lappend(((PlannerInfo *) childinfo[i].root)->parse->groupClause,
							root->parse->groupClause);
			}
		}
		PG_TRY();
		{
			RelOptInfo *tmp = childinfo[i].baserel;
			struct Path *tmp_path;

			if (childinfo[i].grouped_rel_local != NULL)
				tmp = childinfo[i].grouped_rel_local;
			if (tmp->pathlist != NULL)
			{
				tmp_path = tmp->pathlist->head->data.ptr_value;
				temptlist = PG_build_path_tlist((PlannerInfo *) childinfo[i].root, tmp_path);
			}
			else
				tmp_path = (Path *) best_path;

			/*
			 * For can not aggregation pushdown FDW's. push down quals when
			 * aggregation is occurred
			 */
			if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
				push_scan_clauses = fdw_private->baserestrictinfo;

			/*
			 * check scan_clauses include "__spd_url" If include "__spd_url"
			 * in WHERE clauses, then NOT pushdown all caluses.
			 */
			spd_checkurl_clauses(scan_clauses, &push_scan_clauses, root, fdw_private->baserestrictinfo);

			/* create plan */
			if (childinfo[i].grouped_rel_local != NULL)
			{
				temp_obj = fdwroutine->GetForeignPlan(
													  childinfo[i].grouped_root_local,
													  childinfo[i].grouped_rel_local,
													  oid[i],
													  (ForeignPath *) tmp_path,
													  temptlist,
													  push_scan_clauses,
													  outer_plan);
			}
			else
			{
				temptlist = (List *) build_physical_tlist(childinfo[i].root, childinfo[i].baserel);
				childinfo[i].baserel->reltarget->exprs = temptlist;
				temp_obj = fdwroutine->GetForeignPlan(
													  (PlannerInfo *) childinfo[i].root,
													  (RelOptInfo *) childinfo[i].baserel,
													  oid[i],
													  (ForeignPath *) tmp_path,
													  temptlist,
													  push_scan_clauses,
													  outer_plan);
			}
		}
		PG_CATCH();
		{
			/*
			 * If fail to get foreign plan, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			childinfo[i].child_node_status = ServerStatusDead;
			elog(WARNING, "dummy plan list failed ");
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
			/* Create aggregation plan with foreign table scan. */
			childinfo[i].pAgg = make_agg(
										 child_tlist,
										 NULL,
										 childinfo[i].aggpath->aggstrategy,
										 childinfo[i].aggpath->aggsplit,
										 list_length(childinfo[i].aggpath->groupClause),
										 extract_grouping_cols(childinfo[i].aggpath->groupClause, fdw_private->child_comp_tlist),
										 extract_grouping_ops(childinfo[i].aggpath->groupClause),
										 root->parse->groupingSets,
										 NIL,
										 childinfo[i].aggpath->path.rows,
										 (Plan *) temp_obj);

		}
		childinfo[i].plan = (Plan *) temp_obj;
	}

	if (IS_SIMPLE_REL(baserel))
	{
		scan_relid = baserel->relid;
	}
	else
	{
		/* Aggregate push down */
		scan_relid = 0;
	}
	MemoryContextSwitchTo(oldcontext);
/*
 * TODO: Following is main thread's foreign plan.
 * If all FDW use where clauses, scan_clauses is OK.
 * But FileFDW, SqliteFDW and some FDW can not use where clauses.
 * If it is not NIL, then can not get record from there.
 *
 * Following is resolution plan.
 * 1. change NIL
 * 2. Add filter for can not use where clauses FDW.
 *
 * 1. is redundancy operation for where clauses avaiable FDW.
 * 2. is change iterate foreign scan and check to remote expars.
 * Modify cost is so big, currently solution is 1.
 */
	scan_clauses = extract_actual_clauses(scan_clauses, false);
	return make_foreignscan(tlist,
							scan_clauses,	/* scan_clauses, */
	/* NULL, */
							scan_relid,
							NIL,
							list_make1(makeInteger((long) fdw_private)),
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
	MemoryContext oldcontext;
	int			node_incr;		/* node_incr is variable of number of
								 * fssThrdInfo. */
	ChildInfo  *childinfo;
	int			i,
				j = 0;
	Query	   *query;
	RangeTblEntry *rte;
	int			k;

	/*
	 * Register callback to query memory context to reset normalize id hash
	 * table at the end of the query
	 */
	hash_register_reset_callback(node->ss.ps.state->es_query_cxt);

	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	node->spd_fsstate = NULL;
	fdw_private = (SpdFdwPrivate *)
		((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;
	/* Type of Query to be used for computing intermediate results */
#ifdef GETPROGRESS_ENABLED
	if (fdw_private->agg_query)
		node->ss.ps.state->es_progressState->ps_aggQuery = true;
	else
		node->ss.ps.state->es_progressState->ps_aggQuery = false;
#endif
	node->ss.ps.state->agg_query = 0;
#ifdef GETPROGRESS_ENABLED
	if (getResultFlag)
		return;
#endif
	/* Get all the foreign nodes from conf file */
	fssThrdInfo = (ForeignScanThreadInfo *) palloc0(
													sizeof(ForeignScanThreadInfo) * fdw_private->node_num);
	node->spd_fsstate = fssThrdInfo;
	/* Supporting for Progress */

#ifdef GETPROGRESS_ENABLED
	node->ss.ps.state->es_progressState->ps_totalRows = 0;
	node->ss.ps.state->es_progressState->ps_fetchedRows = 0;
#endif

	node_incr = 0;
	childinfo = fdw_private->childinfo;

	for (i = 0; i < fdw_private->node_num; i++)
	{
		Relation	rd;
		int			natts;
		Form_pg_attribute *attrs;
		TupleDesc	tupledesc;

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
		memcpy(&fssThrdInfo[node_incr].fsstate->ss, &node->ss,
			   sizeof(ScanState));
		/* copy Agg plan when psuedo aggregation case. */
		if (list_member_oid(fdw_private->pPseudoAggList,
							server_oid))
		{
			/* Not push down aggregate to child fdw */
			fssThrdInfo[node_incr].fsstate->ss.ps.plan =
				copyObject(childinfo[i].plan);
		}
		else
		{
			/* Push down case */
			fssThrdInfo[node_incr].fsstate->ss = node->ss;
			fssThrdInfo[node_incr].fsstate->ss.ps.plan =
				copyObject(node->ss.ps.plan);
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

		fssThrdInfo[node_incr].fsstate->ss.ps.state->es_query_cxt = AllocSetContextCreate(estate->es_query_cxt,
																						  "thread es_query_cxt",
																						  ALLOCSET_DEFAULT_MINSIZE,
																						  ALLOCSET_DEFAULT_INITSIZE,
																						  ALLOCSET_DEFAULT_MAXSIZE);
		ExecAssignExprContext((EState *) fssThrdInfo[node_incr].fsstate->ss.ps.state, &fssThrdInfo[node_incr].fsstate->ss.ps);
		fssThrdInfo[node_incr].eflags = eflags;

		/* Modify child tuple descripter */
		natts = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts;
		if (fdw_private->pPseudoAggPushList || fdw_private->pPseudoAggList)
		{
			int			org_attrincr = 0;
			int			child_natts = natts;

			/*
			 * Extract attribute details. The tupledesc made here is just
			 * transient.
			 */
			attrs = palloc0(child_natts * sizeof(Form_pg_attribute));
			org_attrincr = 0;
			for (j = 0; j < node->ss.ps.plan->targetlist->length; j++)
			{
				TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, org_attrincr);
				char	   *agg_command = target->resname;

				attrs[j] = palloc(sizeof(FormData_pg_attribute));
				memcpy(attrs[j], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
					   sizeof(FormData_pg_attribute));

				/*
				 * Extend tuple desc when avg,var,stddev operation is
				 * occurred. AVG is divided SUM and COUNT, VAR and STDDEV are
				 * divided SUM,COUNT,SUM(i*i)
				 */
				if (agg_command == NULL)
					continue;
				if (!strcmpi(agg_command, "AVG") || !strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
				{
					j++;
					attrs[j] = palloc(sizeof(FormData_pg_attribute));
					memcpy(attrs[j], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
						   sizeof(FormData_pg_attribute));
					if (attrs[j]->atttypid <= INT8OID || attrs[j]->atttypid == NUMERICOID)
					{
						attrs[j - 1]->atttypid = INT8OID;
						attrs[j]->atttypid = INT8OID;
						attrs[j - 1]->attalign = 'd';
						attrs[j]->attalign = 'd';
						attrs[j - 1]->attlen = DOUBLE_LENGTH;
						attrs[j]->attlen = DOUBLE_LENGTH;
						attrs[j - 1]->attbyval = 1;
						attrs[j]->attbyval = 1;
					}
					else
					{
						attrs[j - 1]->atttypid = INT4OID;
						attrs[j]->attlen = DOUBLE_LENGTH;
						attrs[j]->attalign = 'd';
						attrs[j]->atttypid = FLOAT8OID;
					}
					if (!strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
					{
						j++;
						attrs[j] = palloc(sizeof(FormData_pg_attribute));
						memcpy(attrs[j], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
							   sizeof(FormData_pg_attribute));
						if (attrs[j]->atttypid <= INT8OID || attrs[j]->atttypid == NUMERICOID)
						{
							attrs[j]->atttypid = INT8OID;
						}
						else
						{
							attrs[j]->atttypid = FLOAT8OID;
						}
						attrs[j]->attlen = DOUBLE_LENGTH;
						attrs[j]->attalign = 'd';
						attrs[j]->attbyval = 1;
						org_attrincr++;
						natts++;
					}
				}
				org_attrincr++;
				natts++;
			}
			/* Construct TupleDesc, and assign a local typmod. */
			tupledesc = CreateTupleDesc(fdw_private->child_uninum, true, attrs);
			tupledesc = BlessTupleDesc(tupledesc);
			natts = fdw_private->child_uninum;
			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
				MakeSingleTupleTableSlot(CreateTupleDescCopy(tupledesc));
		}
		else
		{
			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
				MakeSingleTupleTableSlot(CreateTupleDescCopy(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor));
		}

		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_mcxt = node->ss.ss_ScanTupleSlot->tts_mcxt;
		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_values = (Datum *)
			MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, natts * sizeof(Datum));
		fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_isnull = (bool *)
			MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, natts * sizeof(bool));

		/*
		 * current relation ID gets from current server oid, it means
		 * childinfo[i].oid
		 */
		rd = RelationIdGetRelation(childinfo[i].oid);
		fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;

		fssThrdInfo[node_incr].iFlag = true;
		fssThrdInfo[node_incr].EndFlag = false;
		fssThrdInfo[node_incr].tuple = NULL;
		/* We set index of child info, not set node_incr */
		fssThrdInfo[node_incr].childInfoIndex = i;

		fssThrdInfo[node_incr].serverId = server_oid;
		fssThrdInfo[node_incr].fdwroutine = GetFdwRoutineByServerId(server_oid);
		fssThrdInfo[node_incr].threadMemoryContext =
			AllocSetContextCreate(TopMemoryContext,
								  "thread memory context",
								  ALLOCSET_DEFAULT_MINSIZE,
								  ALLOCSET_DEFAULT_INITSIZE,
								  ALLOCSET_DEFAULT_MAXSIZE);
		fssThrdInfo[node_incr].thrd_ResourceOwner =
			ResourceOwnerCreate(CurrentResourceOwner, "thread resource owner");

		fssThrdInfo[node_incr].private = fdw_private;
		thread_create_err =
			pthread_create(&fdw_private->foreign_scan_threads[node_incr],
						   NULL,
						   &spd_ForeignScan_thread,
						   (void *) &fssThrdInfo[node_incr]);
		if (thread_create_err != 0)
		{
			ereport(ERROR, (errmsg("Cannot create thread! error=%d",
								   thread_create_err)));
		}
		node_incr++;
	}
	fdw_private->nThreads = node_incr;

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
	fdw_private->isFirst = TRUE;
	MemoryContextSwitchTo(oldcontext);
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

	PG_TRY();
	{
		pthread_mutex_lock(&scan_mutex);
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
		pthread_mutex_unlock(&scan_mutex);
	}
	PG_CATCH();
	{
		pthread_mutex_unlock(&scan_mutex);
		PG_RE_THROW();
	}
	PG_END_TRY();
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
	bool		isfirst = TRUE;
	StringInfo	sql = makeStringInfo();
	List	   *mapping_tlist;
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	ListCell   *lc;

	PG_TRY();
	{
		pthread_mutex_lock(&scan_mutex);
		ret = SPI_connect();
		if (ret < 0)
			elog(ERROR, "SPI connect failure - returned %d", ret);
		appendStringInfo(sql, "INSERT INTO %s VALUES( ", AGGTEMPTABLE);
		colid = 0;
		mapping_tlist = fdw_private->mapping_tlist;
		foreach(lc, mapping_tlist)
		{
			Mappingcells *mapcels = (Mappingcells *) lfirst(lc);
			int			mapping;
			Datum		attr;
			char	   *value;
			bool		isnull;
			Oid			typoutput;
			bool		typisvarlena;
			int			child_typid;

			for (i = 0; i < MAXDIVNUM; i++)
			{
				mapping = mapcels->mapping_tlist.mapping[i];
				if (colid != mapping)
					continue;

				if (isfirst)
					isfirst = FALSE;
				else
					appendStringInfo(sql, ",");
				attr = slot_getattr(slot, mapcels->mapping_tlist.mapping[i] + 1, &isnull);
				if (isnull)
				{
					appendStringInfo(sql, "NULL");
					colid++;
					continue;
				}
				getTypeOutputInfo(slot->tts_tupleDescriptor->attrs[colid]->atttypid,
								  &typoutput, &typisvarlena);
				value = OidOutputFunctionCall(typoutput, attr);
				child_typid = fssThrdInfo[0].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid;
				if (value != NULL)
				{
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
		elog(DEBUG1, "insert  = %s", sql->data);
		ret = SPI_exec(sql->data, 1);
		if (ret != SPI_OK_INSERT)
			elog(ERROR, "execute spi INSERT TEMP TABLE failed ");
		SPI_finish();
		pthread_mutex_unlock(&scan_mutex);
	}
	PG_CATCH();
	{
		pthread_mutex_unlock(&scan_mutex);
		PG_RE_THROW();
	}
	PG_END_TRY();
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
	int			colid;
	int			mapping;
	bool		isnull = false;
	MemoryContext oldcontext;
	Mappingcells *mapcells;
	ListCell   *lc;

	oldcontext = CurrentMemoryContext;
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
		return;
	}

	MemoryContextSwitchTo(oldcontext);
	fdw_private->agg_values = (Datum **) palloc0(SPI_processed * sizeof(Datum *));
	fdw_private->agg_nulls = (bool **) palloc0(SPI_processed * sizeof(bool *));
	fdw_private->agg_value_type = (int *) palloc0(SPI_processed * sizeof(int));
	for (i = 0; i < SPI_processed; i++)
	{
		fdw_private->agg_values[i] = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
		fdw_private->agg_nulls[i] = (bool *) palloc0(SPI_processed * sizeof(bool));
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

				mapping = mapcells->mapping_tlist.mapping[i];
				if (colid != mapping)
					continue;
				fdw_private->agg_value_type[colid] = SPI_tuptable->tupdesc->attrs[colid]->atttypid;

				datum = DatumGetObjectId(SPI_getbinval(SPI_tuptable->vals[k],
													   SPI_tuptable->tupdesc,
													   colid + 1,
													   &isnull));

				/* We need to deep copy datum from SPI memory context */
				if (fdw_private->agg_value_type[colid] == NUMERICOID)
				{
					/* Convert from numeric to int8 */
					fdw_private->agg_values[k][colid] = DirectFunctionCall1(numeric_int8, datum);
				}
				else
				{
					fdw_private->agg_values[k][colid] = datumCopy(datum,
																  SPI_tuptable->tupdesc->attrs[colid]->attbyval,
																  SPI_tuptable->tupdesc->attrs[colid]->attlen);
				}
				if (isnull)
					fdw_private->agg_nulls[k][colid] = TRUE;
				colid++;
			}
		}
	}
	SPI_finish();
}

static float8
datum_to_float8(Oid type, Datum value)
{
	double		sum = 0;

	switch (type)
	{
		case NUMERICOID:
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
		case BOOLOID:
		case TIMESTAMPOID:
		case DATEOID:
		default:
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
		Mappingcell clist_parent;
		int			mapping;
		int			mapping_parent;

		mapcells = (Mappingcells *) lfirst(lc);
		clist = mapcells->mapping_tlist;
		clist_parent = mapcells->mapping_orig_tlist;
		mapping = clist.mapping[0];
		mapping_parent = clist_parent.mapping[0];
		if (clist_parent.aggtype != NOFLAG)
		{
			int			count_mapping = clist.mapping[0];
			int			sum_mapping = clist.mapping[1];
			float8		result = 0.0;
			float8		sum = 0.0;
			float8		cnt = 0.0;

			if (fdw_private->agg_nulls[rowid][count_mapping])
			{
				elog(ERROR, "COUNT() column is NULL.");
			}
			if (fdw_private->agg_nulls[rowid][sum_mapping])
				nulls[target_column] = TRUE;
			else
			{
				if (target_column != mapping_parent)
					continue;

				sum = datum_to_float8(fdw_private->agg_value_type[sum_mapping], fdw_private->agg_values[rowid][sum_mapping]);

				cnt = (float8) DatumGetInt32(fdw_private->agg_values[rowid][count_mapping]);
				if (cnt == 0)
					elog(ERROR, "Record count is 0. Divide by zero error encountered.");
				if (clist_parent.aggtype == AVGFLAG)
					result = sum / cnt;
				else
				{
					int			vardev_mapping = clist.mapping[2];
					float8		sum2 = 0.0;
					float8		right = 0.0;
					float8		left = 0.0;

					sum2 = datum_to_float8(fdw_private->agg_value_type[vardev_mapping], fdw_private->agg_values[rowid][vardev_mapping]);

					if (cnt == 1)
						elog(ERROR, "Record count is 1. Divide by zero error encountered.");
					right = sum2;
					left = pow(sum, 2) / cnt;
					result = (float8) (right - left) / (float8) (cnt - 1);
					if (clist_parent.aggtype == DEVFLAG)
					{
						float		var = 0.0;

						var = (float8) (right - left) / (float8) (cnt - 1);
						result = sqrt(var);
					}
				}
				if (fdw_private->agg_value_type[sum_mapping] == FLOAT8OID || fdw_private->agg_value_type[sum_mapping] == FLOAT4OID)
					ret_agg_values[target_column] = Float8GetDatumFast(result);
				else
					ret_agg_values[target_column] = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(result));
			}
		}
		else if (target_column == mapping_parent)
		{
			if (fdw_private->agg_nulls[rowid][mapping])
				nulls[target_column] = TRUE;
			ret_agg_values[target_column] = fdw_private->agg_values[rowid][mapping];
			target_column++;
		}
	}
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
	bool		isfirst = TRUE;

	/* Create Select query */
	appendStringInfo(sql, "SELECT ");

	i = 0;
	foreach(lc, fdw_private->mapping_tlist)
	{
		TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, j);
		Mappingcells *cells = (Mappingcells *) lfirst(lc);
		char	   *agg_command = target->resname;
		Mappingcell clist = cells->mapping_tlist;

		for (i = 0; i < MAXDIVNUM; i++)
		{
			int			mapping = clist.mapping[i];

			if (max_col == mapping)
			{
				if (isfirst)
					isfirst = FALSE;
				else
					appendStringInfo(sql, ",");
				if (agg_command == NULL)
				{
					appendStringInfo(sql, "col%d", max_col);
					continue;
				}
				elog(DEBUG1, "resname %s", agg_command);
				if (!strcmpi(agg_command, "SUM") || !strcmpi(agg_command, "COUNT") || !strcmpi(agg_command, "AVG") || !strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
					appendStringInfo(sql, "SUM(col%d)", max_col);
				else if (!strcmpi(agg_command, "MAX") || !strcmpi(agg_command, "MIN") || !strcmpi(agg_command, "BIT_OR") || !strcmpi(agg_command, "BIT_AND") || !strcmpi(agg_command, "BOOL_AND") || !strcmpi(agg_command, "BOOL_OR") || !strcmpi(agg_command, "EVERY") || !strcmpi(agg_command, "STRING_AGG"))
					appendStringInfo(sql, "%s(col%d)", agg_command, max_col);

				/*
				 * This is for influx db functions. MAX has not effect to
				 * result. We have to consider multi-tenant.
				 */
				else if (!strcmpi(agg_command, "INFLUX_TIME") || !strcmpi(agg_command, "LAST"))
					appendStringInfo(sql, "MAX(col%d)", max_col);
				else
					appendStringInfo(sql, "col%d", max_col);
				max_col++;
			}
		}
		j++;
	}
	appendStringInfo(sql, " FROM __spd__temptable ");
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
spd_createtable_sql(StringInfo create_sql, List *mapping_tlist, ForeignScanThreadInfo * fssThrdInfo)
{
	ListCell   *lc;
	int			colid = 0;
	int			i;
	int			typeid;

	appendStringInfo(create_sql, "CREATE TEMP TABLE __spd__temptable(");
	foreach(lc, mapping_tlist)
	{
		Mappingcells *cells = lfirst(lc);

		for (i = 0; i < MAXDIVNUM; i++)
		{
			Mappingcell clist = cells->mapping_tlist;
			int			mapping = clist.mapping[i];

			/* append aggregate string */
			if (colid == mapping)
			{
				if (colid != 0)
					appendStringInfo(create_sql, ",");
				appendStringInfo(create_sql, "col%d ", colid);
				typeid = fssThrdInfo[0].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid;
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
 * spd_AddNodeColumn
 * Adding node name column.
 * If child node is pgspider, then concatinate node name.
 *
 * @param[in] fssThrdInfo
 * @param[in] node
 */
static TupleTableSlot *
spd_AddNodeColumn(ForeignScanThreadInfo * fssThrdInfo, TupleTableSlot *child_slot, int count)
{
	Datum	   *values;
	bool	   *nulls;
	bool	   *replaces;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	TupleTableSlot *slot = NULL;
	TupleTableSlot *node_slot;
	Datum		value_datum = 0;
	Datum		valueDatum = 0;
	HeapTuple	temp_tuple;
	regproc		typeinput;
	int			i;
	int			typemod;
	int			tnum = 0;
	HeapTuple	newtuple;

	if (count == 0)
	{
		count = 1;
	}

	fs = GetForeignServer(fssThrdInfo[count - 1].serverId);
	fdw = GetForeignDataWrapper(fs->fdwid);
	node_slot = fssThrdInfo[count - 1].tuple;

	/* Initialize new tuple buffer */
	values = palloc0(sizeof(Datum) * node_slot->tts_tupleDescriptor->natts);
	nulls = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
	replaces = palloc0(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);

	slot = child_slot;
	tnum = 0;
	slot_getallattrs(node_slot);
	for (i = 0; i < node_slot->tts_tupleDescriptor->natts; i++)
	{
		char	   *value;

		/*
		 * Check column include __column_name attribute is exist or not. If it
		 * is include, then create column name attribute.
		 */
		if (strcmp(node_slot->tts_tupleDescriptor->attrs[i]->attname.data, SPDURL) == 0)
		{
			bool		isnull;

			/* Check child node is pgspider or not */
			if (strcmp(fdw->fdwname, PGSPIDER_FDW_NAME) == 0 && node_slot->tts_isnull[i] == FALSE)
			{
				Datum		col = slot_getattr(node_slot, i + 1, &isnull);
				char	   *s;

				if (isnull)
				{
					elog(ERROR, "PGSpider column name error. Child node Name is nothing.");
				}
				s = TextDatumGetCString(col);

				/*
				 * if child node is pgspider, concatinate child node name and
				 * child child node name
				 */
				value = psprintf("/%s%s", fs->servername, s);
			}
			else
			{
				/*
				 * child node is NOT pgspider, create column name attribute
				 */
				value = psprintf("/%s/", fs->servername);
			}
			/* Check tuple's column type */
			temp_tuple = SearchSysCache1(TYPEOID, ObjectIdGetDatum(node_slot->tts_tupleDescriptor->attrs[i]->atttypid));
			if (!HeapTupleIsValid(temp_tuple))
				elog(ERROR, "cache lookup failed for type%u", node_slot->tts_tupleDescriptor->attrs[i]->atttypid);
			typeinput = ((Form_pg_type) GETSTRUCT(temp_tuple))->typinput;
			typemod = ((Form_pg_type) GETSTRUCT(temp_tuple))->typtypmod;
			ReleaseSysCache(temp_tuple);

			valueDatum = CStringGetDatum((char *) value);
			value_datum = OidFunctionCall3(typeinput,
										   valueDatum, ObjectIdGetDatum(InvalidOid),
										   Int32GetDatum(typemod));
			replaces[i] = true;
			nulls[i] = false;
			values[i] = value_datum;
			tnum = i;
		}
	}
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
	ExecCopySlot(slot, node_slot);
	return slot;
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

	int			count = 0;
	int			node_incr = 0;

	StringInfo	create_sql = makeStringInfo();
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	TupleTableSlot *slot = NULL,
			   *tempSlot = NULL;
	SpdFdwPrivate *fdw_private;
	List	   *mapping_tlist;
	int		   *fin_flag;
	int			fin_count = 0;
	MemoryContext oldcontext;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = (SpdFdwPrivate *)
		((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;

	if (fdw_private == NULL)
		elog(ERROR, "can't find node in iterateforeignscan");
#ifdef GETPROGRESS_ENABLED
	if (getResultFlag)
		return NULL;
#endif
	if (fdw_private->nThreads == 0)
		return NULL;
	/* Get all the foreign nodes from conf file */
	mapping_tlist = fdw_private->mapping_tlist;

	/* CREATE TEMP TABLE SQL */
	fdw_private->is_drop_temp_table = TRUE;
	if (fdw_private->agg_query)
	{
		if (fdw_private->isFirst)
		{
			/* TODO create* */
			fin_flag = palloc0(sizeof(int) * fdw_private->nThreads);
			spd_createtable_sql(create_sql, mapping_tlist, fssThrdInfo);
			spd_spi_ddl_table(create_sql->data);
			fdw_private->is_drop_temp_table = FALSE;

			/*
			 * run aggregation query for all data source threads and combine
			 * results
			 */
			for (;;)
			{
				int			temp_count = 0;

				for (; fssThrdInfo[temp_count].tuple == NULL;)
				{
					if (!fssThrdInfo[temp_count].iFlag)
					{
						/* There is no iterating thread. */
						if (fin_flag[temp_count] == 0 && fssThrdInfo[temp_count].tuple == NULL)
						{
							fin_count++;
							fin_flag[temp_count] = 1;
						}
						if (fin_count >= fdw_private->nThreads)
							break;
					}
					temp_count++;
					if (temp_count >= fdw_private->nThreads)
						temp_count = 0;
					usleep(1);
				}
				count = temp_count;
				if (fssThrdInfo[count].tuple != NULL)
					/* if this child node finished, update finish flag */
					spd_spi_insert_table(fssThrdInfo[count].tuple, node, fdw_private);
				fssThrdInfo[count].tuple = NULL;
				/* Intermediate results for aggregation query requested */
				if (fin_count >= fdw_private->nThreads)
				{
					/*
					 * Aggregation Query Cancellation : Return existing
					 * intermediate result
					 */
					break;
				}
#ifdef GETPROGRESS_ENABLED
				if (getResultFlag)
					break;
#endif
			}
			/* First time getting with pushdown from temp table */
			tempSlot = node->ss.ss_ScanTupleSlot;
			tempSlot = spd_spi_select_table(tempSlot, node, fdw_private);
			fdw_private->isFirst = FALSE;
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
			 * If all tupple getting is finished, then return NULL and drop
			 * table
			 */
			spd_spi_ddl_table("DROP TABLE __spd__temptable");
			fdw_private->isFirst = TRUE;
			fdw_private->is_drop_temp_table = TRUE;
		}
	}							/* if (fdw_private->agg_query) */
	else
	{
		/* tuple getting is finished */
		for (; fssThrdInfo[count++].tuple == NULL;)
		{
			int			iFlagNum = 0;

			if (count >= fdw_private->nThreads)
			{
				count = 0;
				for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
				{
					if (fssThrdInfo[node_incr].iFlag == false && fssThrdInfo[node_incr].tuple == NULL)
					{
						iFlagNum++;
					}
				}
				if (iFlagNum == fdw_private->nThreads)
					return NULL;	/* There is no iterating thread. */
				usleep(1);
			}
		}
		slot = spd_AddNodeColumn(fssThrdInfo, node->ss.ss_ScanTupleSlot, count);
		/* clear tuple buffer */
		fssThrdInfo[count - 1].tuple = NULL;
	}
	MemoryContextSwitchTo(oldcontext);
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
	MemoryContext oldcontext;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fssThrdInfo = node->spd_fsstate;
	fdw_private = fssThrdInfo->private;

	/*
	 * Number of child threads is only alive threads. firstly, check to number
	 * of alive child threads.
	 */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR && fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH && fssThrdInfo[node_incr].state != SPD_FS_STATE_ITERATE)
		{
			fssThrdInfo[node_incr].queryRescan = true;
		}
	}
	/* 10us sleep for thread switch */
	pthread_yield();

	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR && fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH)
		{
			while (fssThrdInfo[node_incr].queryRescan)
			{
				pthread_yield();
			}
		}
	}
	MemoryContextSwitchTo(oldcontext);
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

	fdw_private = fssThrdInfo->private;
	if (!fdw_private)
		return;

	/* print error nodes */
	if (isPrintError)
		spd_PrintError(fdw_private->node_num, fdw_private->childinfo);

	if (fdw_private->is_drop_temp_table == FALSE)
	{
		spd_spi_ddl_table("DROP TABLE IF EXISTS __spd__temptable;");
	}
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		fssThrdInfo[node_incr].EndFlag = true;
	}

	/* wait until all the remote connections get closed. */
	for (node_incr = 0; node_incr < fdw_private->nThreads; node_incr++)
	{
		/* Cleanup the thread-local structures */
		rtn = pthread_join(fdw_private->foreign_scan_threads[node_incr], NULL);
		if (rtn != 0)
			elog(WARNING, "error is occurred, pthread_join fail in EndForeignScan. ");
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

		MemoryContextDelete(fssThrdInfo[node_incr].threadMemoryContext);
	}
	if (fdw_private->thrdsCreated)
		pfree(node->spd_fsstate);

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
	char	   *new_underurl = NULL;

	spd_ParseUrl(target_rte->url, fdw_private);
	if (fdw_private->url_parse_list == NIL ||
		fdw_private->url_parse_list->length < 1)
	{
		/* DO NOTHING */
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");
	}
	else
	{
		char	   *srvname = palloc0(sizeof(char) * (MAX_URL_LENGTH));

		/*
		 * entry is first parsing word(/foo/bar/, then entry is
		 * "foo",target_url is "bar")
		 */
		char	   *target_url = NULL;
		char	   *throwing_url = NULL;

		if (fdw_private->url_parse_list->length > 2)
		{
			target_url = (char *) list_nth(fdw_private->url_parse_list, 1);
			throwing_url = (char *) list_nth(fdw_private->url_parse_list, 2);
		}
		fdw_private->under_flag = true;

		/*
		 * if child - child is exist, then create child - child UNDER phrase
		 */
		if (target_url != NULL)
		{
			char		temp[QUERY_LENGTH];

			sprintf(temp, "/%s/", target_url);
			new_underurl = palloc0(sizeof(char) * (QUERY_LENGTH));
			strcpy(new_underurl, throwing_url);
		}
		pfree(srvname);
	}
}

/**
 * spd_AddForeignUpdateTargets
 * Add column(s) needed for update/delete on a foreign table,
 * we are using first column as row identification column, so we are adding that into target
 * list.
 * Checking UNDER clause. In currently, must use UNDER.
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
	/* Checking UNDER clause. */
	if (target_rte->url != NULL)
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
 * Checking UNDER clause. In currently, must use UNDER.
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


	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();

	if (rte->url != NULL)
		spd_check_url_update(fdw_private, rte);
	else
		elog(ERROR, "no URL is specified, INSERT/UPDATE/DELETE need to set URL");
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
							 FALSE,
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
							 FALSE,
							 PGC_USERSET,
							 0,
							 NULL,
							 NULL,
							 NULL);
}
