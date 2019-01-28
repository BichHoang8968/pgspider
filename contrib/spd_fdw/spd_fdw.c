/*-------------------------------------------------------------------------
 *
 * pgspd
 * contrib/spd_fdw/spd_fdw.c
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

#if (PG_VERSION_NUM < 100000)
#error
#endif

#include <stddef.h>
#include <sys/time.h>
#include <unistd.h>
#include <pthread.h>
#include <math.h>
#include "access/htup_details.h"
#include "access/transam.h"
#include "catalog/pg_type.h"
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
#include "utils/memutils.h"
#include "utils/palloc.h"
#include "utils/lsyscache.h"
#include "utils/builtins.h"
#include "utils/rel.h"
#include "utils/elog.h"
#include "utils/selfuncs.h"
#include "utils/numeric.h"
#include "utils/hsearch.h"
#include "utils/syscache.h"
#include "utils/lsyscache.h"
#include "utils/resowner.h"
#include "libpq-fe.h"
#include "spd_fdw_defs.h"
#include "funcapi.h"
#include "postgres_fdw/postgres_fdw.h"

#define BUFFERSIZE 1024
#define QUERY_LENGTH 512
#define ENABLE_MERGE_RESULT
#define MAX_TABLE_NUM 1024
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

#define BIGINT_OID 20
#define SMALLINT_OID 21
#define INT_OID 23
#define FLOAT_OID 700
#define FLOAT8_OID 701
#define NUMERIC_OID 1700
#define BOOL_OID 16
#define TEXT_OID 25
#define DATE_OID 1082
#define TIMESTAMP_OID 1114
#define OPEXPER_OID 514
#define OPEXPER_FUNCID 141
#define FLOAT8MUL_OID 594
#define FLOAT8MUL_FUNID 216
#define DOUBLE_LENGTH 8

#define AVGFLAG 1
#define VARFLAG 2
#define DEVFLAG 3

#define POSTGRES_FDW_NAME "postgres_fdw"
#define SPDFRONT_FDW_NAME "spdfront_fdw"
#define COLNAME "__spd_url"

/* local function forward declarations */
bool		spd_is_builtin(Oid objectId);
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

/*
 * SpdFdwPrivate keep child node plan information for each child tables belonging to the parent table.
 * Spd create child table node plan from each spd_GetForeignRelSize(),spd_GetForeignPaths(),spd_GetForeignPlan().
 * SpdFdwPrivate is created at spd_GetForeignSize() using spd_AllocatePrivate().
 * SpdFdwPrivate is free at spd_EndForeignScan() using spd_ReleasePrivate().
 *
 */
typedef struct childtlist
{
	List	   *mapping;
	int			avgflag;
}			childtlist;

typedef struct SpdFdwPrivate
{
	int			thrdsCreated;
	int			node_num;		/* number of child tables */
	bool		under_flag;		/* using UNDER clause or NOT */
	List	   *dummy_base_rel_list;	/* child node base rel list */
	List	   *dummy_root_list;	/* child node dummy root list */
	List	   *dummy_plan_list;	/* child node dummy plan list */
	List	   *child_table_alive;	/* alive child nodes list. alive is TRUE,
									 * dead is FALSE */
	List	   *dummy_output_rel_list;
	List	   *url_parse_list; /* lieteral of parse UNDER clause */
	List	   *ft_oid_list;	/* list of child table oids */
	pthread_t	foreign_scan_threads[NODES_MAX];
	ResourceOwner thread_resource_owner;
	PgFdwRelationInfo rinfo;
	char	   *base_relation_name;
	List	   *pPseudoAggPushList; /* Enable of aggregation push down server
									 * list */
	List	   *pPseudoAggList; /* Disable of aggregation push down server
								 * list */
	List	   *pPseudoAggTypeList; /* Push down type list */
	List	   *tList;
	bool		agg_query;
	bool		agg_query_ft;	/* First time of iteration foreign scan with
								 * aggregation query */
	bool		agg_segrigation;
	Datum	  **agg_values;
	bool	   *agg_nulls;
	int			agg_tuples;
	int			agg_num;
	Agg		   *pAgg[NODES_MAX];	/* "Aggref" for Disable of aggregation
									 * push down servers */
	List	   *div_tlist;
	List	   *mapping_tlist;
	List	   *mapping_orig_tlist;
	List	   *child_comp_tlist;
	List	   *parent_mapping_tlist;
	struct PathTarget *child_tlist[UPPERREL_FINAL + 1];
	int			child_num;
	int			child_uninum;
	PlannerInfo *spd_root;
	RelOptInfo *spd_baserel;
	StringInfo	groupby_string;
}			SpdFdwPrivate;

Oid			tempoid;
pthread_mutex_t scan_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;
AggPath    *aggpath;
List	   *baserestrictinfo;
PlannerInfo *grouped_root_local;
RelOptInfo *grouped_rel_local;

static bool
is_foreign_expr2(PlannerInfo *root, RelOptInfo *baserel, Expr *expr)
{
	/* @todo check expression can be executed in remote datasource side */
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

	p->thread_resource_owner = ResourceOwnerCreate(
												   NULL, "SPD fdw resource owner"
		);
	return p;
}

static void
spd_ReleasePrivate(SpdFdwPrivate * p)
{
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_BEFORE_LOCKS, false, false);
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_LOCKS, false, false);
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_AFTER_LOCKS, false, false);
}

bool
spd_is_builtin(Oid objectId)
{
	return (objectId < FirstBootstrapObjectId);
}

/* declarations for dynamic loading */
PG_FUNCTION_INFO_V1(spd_fdw_handler);

/*
 * spd_fdw_handler populates an FdwRoutine with pointers to the functions
 * implemented within this file.
 */
Datum
spd_fdw_handler(PG_FUNCTION_ARGS)
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
 * @param[out] temp_tlist  target - flattened list for child node
 * @param[out] child_uninum - number of child list
 */

static List *
spd_add_to_flat_tlist(List *tlist, List *exprs, List **mapping_tlist, List **mapping_orig_tlist, List **temp_tlist, int *child_uninum, Index sgref)
{
	int			next_resno = list_length(tlist) + 1;
	int			next_resno_temp = list_length(*temp_tlist) + 1;
	int			target_num = 0;
	childtlist *ctlist = NULL;
	ListCell   *lc;

	ctlist = (childtlist *) palloc(sizeof(childtlist));

	foreach(lc, exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc);
		TargetEntry *tle_temp;
		TargetEntry *tle;
		Aggref	   *aggref;
		childtlist *ctlist_orig = (struct childtlist *) palloc(sizeof(struct childtlist));

		aggref = (Aggref *) expr;
		if ((aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID) ||
			(aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID) ||
			(aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
		{
			/* Prepare COUNT Query */
			Aggref	   *tempCount = copyObject((Aggref *) expr);
			Aggref	   *tempSum;
			Aggref	   *tempVar;

			tempVar = copyObject(tempCount);
			tempCount->aggfnoid = COUNT_OID;
			tempSum = copyObject(tempCount);
			tempSum->aggfnoid = SUM_OID;
			if (tempCount->aggtype <= BIGINT_OID || tempSum->aggtype == NUMERIC_OID)
			{
				tempSum->aggtype = BIGINT_OID;
				tempSum->aggtranstype = BIGINT_OID;
			}
			else
			{
				tempSum->aggfnoid = SUM_FLOAT8_OID;
				tempSum->aggtype = FLOAT8_OID;
				tempSum->aggtranstype = FLOAT8_OID;
			}
			tempCount->aggtype = BIGINT_OID;
			tempCount->aggtranstype = BIGINT_OID;
			/* Prepare SUM Query */

			tempVar->aggfnoid = VAR_OID;

			/* add original mapping list to avg,var,stddev */
			if (!spd_tlist_member(expr, tlist, &target_num))
			{
				tle = makeTargetEntry(copyObject(expr), /* copy needed?? */
									  next_resno++,
									  NULL,
									  false);
				tlist = lappend(tlist, tle);

			}
			ctlist_orig->mapping = list_make1_int(target_num);
			ctlist_orig->mapping = lappend_int(ctlist_orig->mapping, target_num);
			*mapping_orig_tlist = lappend(*mapping_orig_tlist, ctlist_orig);
			/* set avg flag */
			if (aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID)
			{
				ctlist_orig->avgflag = AVGFLAG;
			}
			else if (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
			{
				ctlist_orig->avgflag = VARFLAG;
			}
			else if (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)
			{
				ctlist_orig->avgflag = DEVFLAG;
			}
			/* count */
			if (!spd_tlist_member((Expr *) tempCount, *temp_tlist, &target_num))
			{
				tle_temp = makeTargetEntry((Expr *) tempCount,	/* copy needed?? */
										   next_resno_temp++,
										   NULL,
										   false);
				*temp_tlist = lappend(*temp_tlist, tle_temp);
				*child_uninum += 1;
			}
			ctlist->mapping = list_make1_int(target_num);
			/* sum */
			if (!spd_tlist_member((Expr *) tempSum, *temp_tlist, &target_num))
			{
				tle_temp = makeTargetEntry((Expr *) tempSum,	/* copy needed?? */
										   next_resno_temp++,
										   NULL,
										   false);
				*temp_tlist = lappend(*temp_tlist, tle_temp);
				*child_uninum += 1;
			}
			ctlist->mapping = lappend_int(ctlist->mapping, target_num);
			/* variance(SUM(x*x)) */
			if ((aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
				|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
			{
				if (!spd_tlist_member((Expr *) tempVar, *temp_tlist, &target_num))
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
					if (tempVar->aggtype <= INT_OID || tempVar->aggtype == NUMERIC_OID)
					{
						tempVar->aggtype = BIGINT_OID;
						tempVar->aggtranstype = BIGINT_OID;
						tempVar->aggfnoid = SUM_OID;
						opexpr->opno = OPEXPER_OID;
						opexpr->opfuncid = OPEXPER_FUNCID;
						opexpr->opresulttype = BIGINT_OID;
					}
					else
					{
						tempVar->aggtype = FLOAT8_OID;
						tempVar->aggtranstype = FLOAT8_OID;
						tempVar->aggfnoid = SUM_FLOAT8_OID;
						opexpr->opresulttype = FLOAT8_OID;
						opexpr->opno = FLOAT8MUL_OID;
						opexpr->opfuncid = FLOAT8MUL_FUNID;
						opexpr->opresulttype = FLOAT8_OID;
					}
					opexpr->args = lappend(opexpr->args, opvar);
					opexpr->args = lappend(opexpr->args, opvar);
					/* Create var targetentry */
					tarexpr = makeTargetEntry((Expr *) opexpr,	/* copy needed?? */
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
					tle_temp = makeTargetEntry((Expr *) tempVar,	/* copy needed?? */
											   next_resno_temp++,
											   NULL,
											   false);
					*temp_tlist = lappend(*temp_tlist, tle_temp);
					*child_uninum += 1;
				}
			}
			ctlist->mapping = lappend_int(ctlist->mapping, target_num);
			*mapping_tlist = lappend(*mapping_tlist, ctlist);
		}
		else
		{
			Expr	   *expr = (Expr *) lfirst(lc);
			TargetEntry *tle_temp;
			TargetEntry *tle;

			/* original */
			if (!spd_tlist_member(expr, tlist, &target_num))
			{
				tle = makeTargetEntry(copyObject(expr), /* copy needed?? */
									  next_resno++,
									  NULL,
									  false);
				tle->ressortgroupref = sgref;
				tlist = lappend(tlist, tle);
			}
			/* append original target list */
			ctlist_orig->mapping = list_make1_int(target_num);
			ctlist_orig->mapping = lappend_int(ctlist_orig->mapping, target_num);
			ctlist_orig->avgflag = 0;
			*mapping_orig_tlist = lappend(*mapping_orig_tlist, ctlist_orig);

			/* div tlist */
			if (!spd_tlist_member(expr, *temp_tlist, &target_num))
			{
				tle_temp = makeTargetEntry(copyObject(expr),	/* copy needed?? */
										   next_resno_temp++,
										   NULL,
										   false);
				tle_temp->ressortgroupref = sgref;
				*temp_tlist = lappend(*temp_tlist, tle_temp);
				*child_uninum += 1;
			}
			ctlist->avgflag = 0;
			ctlist->mapping = list_make1_int(target_num);
			*mapping_tlist = lappend(*mapping_tlist, ctlist);
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
spd_spi_exec_datasouce_num(Oid foreigntableid, int *nums, Datum **oid)
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
		elog(ERROR, "spi exec is failed. sql is %s", query);
		SPI_finish();
	}
	spi_temp = SPI_processed;
	spicontext = MemoryContextSwitchTo(oldcontext);
	*oid = (Datum *) palloc(sizeof(Datum) * spi_temp);
	MemoryContextSwitchTo(spicontext);
	for (i = 0; i < SPI_processed; i++)
	{
		bool		isnull;

		oid[0][i] = SPI_getbinval(SPI_tuptable->vals[i], SPI_tuptable->tupdesc, 1, &isnull);
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
spd_spi_exec_datasource_oid(Datum foreigntableid)
{
	char		query[QUERY_LENGTH];
	int			ret;
	bool		isnull;
	Datum		oid = 0;

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
	oid = SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &isnull);
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
spd_spi_exec_datasource_name(Datum foreigntableid, char *srvname)
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
		elog(DEBUG1, "error %d", ret);

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
spd_spi_exec_child_relname(char *parentTableName, SpdFdwPrivate * fdw_private, Datum **oid)
{
	char		query[QUERY_LENGTH];
	char	   *entry = NULL;
	int			i;
	int			ret;
	MemoryContext oldcontext;
	MemoryContext spicontext;

	oldcontext = CurrentMemoryContext;
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
	spicontext = MemoryContextSwitchTo(oldcontext);
	*oid = (Datum *) palloc(sizeof(Datum) * SPI_processed);
	MemoryContextSwitchTo(spicontext);
	for (i = 0; i < SPI_processed; i++)
	{
		bool		isnull;

		(*oid)[i] = SPI_getbinval(SPI_tuptable->vals[i],
								  SPI_tuptable->tupdesc,
								  1,
								  &isnull);
	}
	fdw_private->node_num = SPI_processed;
	SPI_finish();

	if (fdw_private->dummy_base_rel_list != NIL)
	{
		fdw_private->node_num = fdw_private->dummy_base_rel_list->length;
	}
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

	CurrentResourceOwner = fdw_private->thread_resource_owner;

	fssthrdInfo->me = pthread_self();
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
		fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
												  fssthrdInfo->eflags);
#ifdef MEASURE_TIME
		gettimeofday(&e, NULL);
		elog(DEBUG1, "thread%d begin foreign scan time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	}
	PG_CATCH();
	{
		errflag = 1;
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
								   fdw_private->pAgg[fssthrdInfo->nodeIndex],
								   fssthrdInfo->fsstate->ss.ps.state, 0);
	}
	PG_TRY();
	{
		while (1)
		{
			/* when get result request recieved ,then break */
			if (getResultFlag)
			{
				fssthrdInfo->iFlag = false;
				fssthrdInfo->tuple = NULL;
				break;
			}
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
					slot = fssthrdInfo->fdwroutine->IterateForeignScan(fssthrdInfo->fsstate);
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
				if (!slot->tts_isempty && getResultFlag)
				{
					fssthrdInfo->iFlag = false;
					fssthrdInfo->tuple = NULL;

					cancel = PQgetCancel((PGconn *) fssthrdInfo->fsstate->conn);
					if (!PQcancel(cancel, errbuf, BUFFERSIZE))
						elog(WARNING, " Failed to PQgetCancel");
					PQfreeCancel(cancel);
					break;
				}
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
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
		errflag = 1;
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
		fssthrdInfo->iFlag = false;
		fssthrdInfo->tuple = NULL;
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
 *  List head "sample" List tail = "/test/code/"
 * Pattern1 Url = /sample/test/
 *  List head "sample" List tail = "/test/"
 * Pattern2 Url = /sample/
 *  List head "sample" List tail = NULL
 * Pattern3 Url = ""
 *  List head NULL List tail = NULL
 *
 * @param[in] url_str - URL
 * @param[out] fdw_private - store to parsing URL
 */
static void
spd_ParseUrl(char *url_str, SpdFdwPrivate * fdw_private)
{
	char	   *tp;
	char	   *url_option = palloc(sizeof(char) * strlen(url_str));
	char	   *next = NULL;
	char	   *first_url = NULL;
	char	   *throwing_url = NULL;
	int			p;

	strcpy(url_option, url_str);

	tp = strtok_r(url_option, "/", &next);
	if (tp == NULL)
	{
		return;
	}
	p = strlen(url_option);
	fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, tp);
	if (p + 1 != strlen(url_str))
	{
		throwing_url = pstrdup(&url_str[p]);
		first_url = strtok_r(NULL, "/", &next);
		fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, first_url);
		fdw_private->url_parse_list = lappend(fdw_private->url_parse_list, throwing_url);
	}
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
		/* DO NOTHING */
		for (int i = 0; i < childnums; i++)
		{
			/* UNDER clause does not use. all child table is alive now. */
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);
		}
		return;
	}

	/*
	 * entry is first parsing word(/foo/bar/, then entry is "foo",entry2 is
	 * "bar")
	 */
	spd_ParseUrl(r_entry->url, fdw_private);
	if (fdw_private->url_parse_list == NULL)
	{
		elog(ERROR, "UNDER Clause use but can not find url. Please set UNDER string.");
	}
	if (fdw_private->url_parse_list->length == 0)
	{
		for (int i = 0; i < childnums; i++)
		{
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);
		}
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
		Datum		temp_oid = list_nth_oid(fdw_private->ft_oid_list, i);
		Oid			temp_tableid;
		ForeignServer *temp_server;
		ForeignDataWrapper *temp_fdw = NULL;

		spd_spi_exec_datasource_name(temp_oid, srvname);

		if (strcmp(original_url, srvname) != 0)
		{
			elog(DEBUG1, "Can not find URL");
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, FALSE);
			continue;
		}
		fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);

		/*
		 * if child-child node is exist, then create New UNDER clause. New
		 * UNDER clause is used by child spd server.
		 */

		if (throwing_url != NULL)
		{
			if (strcmp(temp_fdw->fdwname, POSTGRES_FDW_NAME) != 0)
			{
				elog(ERROR, "Child node is not spd");
			}
			/* check child table fdw is spd or not */
			temp_tableid = GetForeignServerIdByRelId(temp_oid);
			temp_server = GetForeignServer(temp_tableid);
			temp_fdw = GetForeignDataWrapper(temp_server->fdwid);
			/* if child table fdw is spd, then execute operation */
			fdw_private->under_flag = 1;
			*new_underurl = pstrdup(first_url);
		}
	}
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
spd_CreateDummyRoot(PlannerInfo *root, RelOptInfo *baserel, Datum *oid, int oid_nums, RangeTblEntry *r_entry,
					char *new_underurl, SpdFdwPrivate * fdw_private)
{
	RelOptInfo *entry_baserel;
	FdwRoutine *fdwroutine;
	ListCell   *l;
	Datum		oid_server;
	int			i = 0;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	
	if (fdw_private->dummy_base_rel_list == NIL)
	{
		for (i = 0; i < oid_nums; i++)
		{
			Oid			rel_oid = 0;
			PlannerInfo *dummy_root = NULL;
			Query	   *query;
			PlannerGlobal *glob;
			RangeTblEntry *rte;
			int			k;
			ListCell   *lc;

			rel_oid = list_nth_oid(fdw_private->ft_oid_list, i);
			if (rel_oid == 0)
			{
				continue;
			}

			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			fdwroutine = GetFdwRoutineByServerId(oid_server);

			/*
			 * Set up mostly-dummy planner state PlannerInfo can not deep copy
			 * with copyObject(). BUt It should create dummy PlannerInfo for
			 * each child tables. Following code is copy from
			 * plan_cluster_use_sort(), it create simple PlannerInfo.
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
			 * if child node is spd and UNDER clause is used, then should set
			 * new UNDER clause URL at child node planner URL.
			 */
			if (new_underurl != NULL)
			{
				rte->url = palloc(sizeof(char) * strlen(new_underurl));
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

			/*
			 * For File FDW. File FDW check column type and num with
			 * basestrictinfo. Delete spd_url column info from child node
			 * baserel's basestrictinfo. (PGSpider FDW use parent
			 * basestrictinfo)
			 *
			 */
			fs = GetForeignServer(oid_server);
			fdw = GetForeignDataWrapper(fs->fdwid);

			if (strcmp(fdw->fdwname, SPDFRONT_FDW_NAME) == 0){
				foreach(lc, entry_baserel->baserestrictinfo)
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
							if (strcmp(colname, COLNAME) == 0)
							{
								elog(DEBUG1, "find colname");
								entry_baserel->baserestrictinfo = NULL;
							}
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
							if (strcmp(colname, COLNAME) == 0)
							{
								elog(DEBUG1, "find colname");
								entry_baserel->baserestrictinfo = NULL;
							}
						}
					}
				}
			}
			PG_TRY();
			{
				fdwroutine->GetForeignRelSize(dummy_root, entry_baserel, DatumGetObjectId(rel_oid));
				fdw_private->dummy_base_rel_list = lappend(fdw_private->dummy_base_rel_list, entry_baserel);
				fdw_private->dummy_root_list = lappend(fdw_private->dummy_root_list, dummy_root);
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
				fdw_private->dummy_base_rel_list = lappend(fdw_private->dummy_base_rel_list, entry_baserel);
				fdw_private->dummy_root_list = lappend(fdw_private->dummy_root_list, dummy_root);
				l = list_nth_cell(fdw_private->child_table_alive, i);
				l->data.int_value = FALSE;
			}
			PG_END_TRY();
		}
		/* If child node can not find */
		if (fdw_private->dummy_base_rel_list == NIL && r_entry->url != NULL && strcmp(r_entry->url, "/") != 0)
		{
			ereport(ERROR, (errmsg("Cannot find the URL")));
		}
	}
	else
	{
		int			i = 0;

		foreach(l, fdw_private->dummy_base_rel_list)
		{
			PG_TRY();
			{
				Oid			rel_oid = list_nth_oid(fdw_private->ft_oid_list, i);
				RelOptInfo *entry = (RelOptInfo *) lfirst(l);

				oid_server = spd_spi_exec_datasource_oid(rel_oid);
				fdwroutine = GetFdwRoutineByServerId(oid_server);
				fdwroutine->GetForeignRelSize(root, entry, DatumGetObjectId(rel_oid));
				i++;
			}
			PG_CATCH();
			{
				fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, FALSE);
			}
			PG_END_TRY();
		}
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
	fdw_private->spd_baserel = build_simple_rel(fdw_private->spd_root, baserel->relid, RELOPT_BASEREL);
	fdw_private->spd_baserel->reltarget->exprs = copyObject(baserel->reltarget->exprs);
	fdw_private->spd_baserel->baserestrictinfo = copyObject(baserel->baserestrictinfo);
	baserestrictinfo = copyObject(baserel->baserestrictinfo);
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
	Datum	   *oid = NULL;
	int			nums;
	char	   *new_underurl = NULL;
	RangeTblEntry *r_entry;
	char	   *namespace = NULL;
	char	   *relname = NULL;
	char	   *refname = NULL;
	RangeTblEntry *rte;

	baserel->rows = 0;
	fdw_private = spd_AllocatePrivate();
	fdw_private->base_relation_name = get_rel_name(foreigntableid);
	fdw_private->rinfo.pushdown_safe = true;
	baserel->fdw_private = (void *) fdw_private;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	/* get child datasouce oid and nums */
	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);
	if (nums == 0)
	{
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));
	}

	for (int i = 0; i < nums; i++)
	{
		fdw_private->ft_oid_list = lappend_int(fdw_private->ft_oid_list,
											   oid[i]);
	}
	Assert(baserel->reloptkind == RELOPT_BASEREL);
	r_entry = root->simple_rte_array[baserel->relid];
	Assert(r_entry != NULL);

	/* Check to UNDER clause and execute only UNDER URL server */
	if (r_entry->url != NULL)
	{
		spd_create_child_url(nums, r_entry, fdw_private, &new_underurl);
	}
	else
	{
		for (int i = 0; i < nums; i++)
		{
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);
		}
	}
	/* Create base plan for each child tables and exec GetForeignRelSize */
	spd_CreateDummyRoot(root, baserel, oid, nums, r_entry, new_underurl, fdw_private);

	MemoryContextSwitchTo(oldcontext);
	if (fdw_private->dummy_base_rel_list == NIL)
	{
		elog(DEBUG1, "Can not connect to child node");
	}

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
	List	   *div_tlist = NIL;
	MemoryContext oldcontext;
	RelOptInfo *output_rel_tmp = (RelOptInfo *) palloc(sizeof(RelOptInfo));
	PlannerInfo *spd_root;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	output_rel_tmp = (RelOptInfo *) palloc(sizeof(RelOptInfo));

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((SpdFdwPrivate *) input_rel->fdw_private)->rinfo.pushdown_safe)
		return;
	in_fdw_private = (SpdFdwPrivate *) input_rel->fdw_private;
	output_rel_tmp->fdw_private = (SpdFdwPrivate *) palloc(sizeof(SpdFdwPrivate));

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if (stage != UPPERREL_GROUP_AGG || output_rel->fdw_private)
		return;
	/* Prepare SpdFdwPrivate for output RelOptInfo */
	fdw_private = spd_AllocatePrivate();
	fdw_private->base_relation_name = pstrdup(in_fdw_private->base_relation_name);
	fdw_private->thrdsCreated = in_fdw_private->thrdsCreated;
	fdw_private->node_num = in_fdw_private->node_num;
	fdw_private->under_flag = in_fdw_private->under_flag;
	fdw_private->dummy_root_list = list_copy(in_fdw_private->dummy_root_list);
	fdw_private->dummy_plan_list = list_copy(in_fdw_private->dummy_plan_list);
	fdw_private->child_table_alive = list_copy(in_fdw_private->child_table_alive);
	fdw_private->url_parse_list = list_copy(in_fdw_private->url_parse_list);
	fdw_private->ft_oid_list = list_copy(in_fdw_private->ft_oid_list);
	fdw_private->pPseudoAggPushList = NIL;
	fdw_private->pPseudoAggList = NIL;
	fdw_private->pPseudoAggTypeList = NIL;
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	spd_root = in_fdw_private->spd_root;

	/* Create child tlist */
	{
		int			i;
		List	   *newList = NIL;
		ListCell   *lc;
		int			listn = 0;

		{
			RelOptInfo *dummy_output_rel;

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
		}
		for (i = 0; i < UPPERREL_FINAL + 1; i++)
		{
			fdw_private->child_tlist[i] = (struct PathTarget *) palloc(sizeof(struct PathTarget));
			if (root->upper_targets[i] != NULL)
				fdw_private->child_tlist[i] = copy_pathtarget(root->upper_targets[i]);
		}
		foreach(lc, spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
		{
			Aggref	   *aggref;
			Expr	   *temp_expr;
			TargetEntry *tle_temp;

			temp_expr = list_nth(fdw_private->child_tlist[UPPERREL_GROUP_AGG]->exprs, listn);
			aggref = (Aggref *) temp_expr;
			listn++;
#if 1
			if ((aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID) ||
				(aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID) ||
				(aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
			{
				/* Prepare SUM Query */
				Aggref	   *tempCount = copyObject((Aggref *) temp_expr);
				Aggref	   *tempSum;
				Aggref	   *tempVar;

				tempCount->aggfnoid = COUNT_OID;
				tempSum = copyObject(tempCount);
				tempSum->aggfnoid = SUM_OID;
				if (tempSum->aggtype <= BIGINT_OID || tempSum->aggtype == NUMERIC_OID)
				{
					tempSum->aggtype = BIGINT_OID;
					tempSum->aggtranstype = BIGINT_OID;
				}
				else
				{
					tempSum->aggfnoid = SUM_FLOAT8_OID;
					tempSum->aggtype = FLOAT8_OID;
					tempSum->aggtranstype = FLOAT8_OID;
				}
				tempCount->aggtype = BIGINT_OID;
				tempCount->aggtranstype = BIGINT_OID;
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
					if (tempVar->aggtype <= INT_OID || tempVar->aggtype == NUMERIC_OID)
					{
						tempVar->aggtype = BIGINT_OID;
						tempVar->aggtranstype = BIGINT_OID;
						tempVar->aggfnoid = SUM_OID;
						opexpr->opno = OPEXPER_OID;
						opexpr->opfuncid = OPEXPER_FUNCID;
						opexpr->opresulttype = BIGINT_OID;
					}
					else
					{
						tempVar->aggtype = FLOAT8_OID;
						tempVar->aggtranstype = FLOAT8_OID;
						tempVar->aggfnoid = SUM_FLOAT8_OID;
						opexpr->opresulttype = FLOAT8_OID;
						opexpr->opno = 594;
						opexpr->opfuncid = 216;
						opexpr->opresulttype = FLOAT8_OID;
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
				fdw_private->div_tlist = lappend_int(fdw_private->div_tlist, 1);
			}
			else
			{
				newList = lappend(newList, temp_expr);
				fdw_private->div_tlist = lappend(fdw_private->div_tlist, 0);
			}
#endif
			newList = lappend(newList, temp_expr);
			fdw_private->div_tlist = lappend(fdw_private->div_tlist, 0);
		}
		foreach(lc, spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
		{
			spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
				list_delete_first(spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs);
		}
		foreach(lc, newList)
		{
			Expr	   *expr = (Expr *) lfirst(lc);

			elog(DEBUG1, "insert expr");
			spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
				lappend(spd_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, expr);
		}
		/* pthread_mutex_unlock(&scan_mutex); */
		elog(DEBUG1, "main upperpath add");
	}
	fdw_private->div_tlist = div_tlist;
	fdw_private->rinfo.pushdown_safe = false;
	output_rel->fdw_private = fdw_private;
	output_rel->relid = input_rel->relid;
	add_foreign_grouping_paths(root, input_rel, output_rel);

	/* Call the below FDW's GetForeignUpperPaths */
	if (in_fdw_private->dummy_base_rel_list != NIL)
	{
		ListCell   *l;
		Datum		oid_server;
		FdwRoutine *fdwroutine;
		int			i = 0;

		foreach(l, in_fdw_private->dummy_base_rel_list)
		{
			List	   *newList = NIL;
			Oid			rel_oid = list_nth_oid(fdw_private->ft_oid_list, i);
			RelOptInfo *entry = (RelOptInfo *) lfirst(l);
			PlannerInfo *dummy_root =
			(PlannerInfo *) list_nth(fdw_private->dummy_root_list, i);
			RelOptInfo *dummy_output_rel;

			ListCell   *lc;
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
				TargetEntry *tle_temp;

				aggref = (Aggref *) expr;
				listn++;
#if 1
				if ((aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID) ||
					(aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID) ||
					(aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
				{
					/* Prepare SUM Query */
					Aggref	   *tempCount = copyObject((Aggref *) aggref);
					Aggref	   *tempSum;
					Aggref	   *tempVar;

					tempCount->aggfnoid = COUNT_OID;
					tempSum = copyObject(tempCount);
					tempSum->aggfnoid = SUM_OID;
					if (tempCount->aggtype <= FLOAT8_OID || tempCount->aggtype == NUMERIC_OID)
					{
						tempSum->aggtype = BIGINT_OID;
						tempSum->aggtranstype = BIGINT_OID;
					}
					else
					{
						tempSum->aggtype = FLOAT8_OID;
						tempSum->aggtranstype = FLOAT8_OID;
						tempSum->aggfnoid = SUM_FLOAT8_OID;
					}
					tempCount->aggtype = BIGINT_OID;
					tempCount->aggtranstype = BIGINT_OID;
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
						opexpr->opno = OPEXPER_OID;
						opexpr->opfuncid = OPEXPER_FUNCID;
						opexpr->opresulttype = INT_OID;
						opexpr->opretset = false;
						opexpr->opcollid = 0;
						opexpr->inputcollid = 0;
						opexpr->location = 0;
						opexpr->args = NULL;

						/* Create top targetentry */
						if (tempVar->aggtype <= INT_OID ||
							tempVar->aggtype == NUMERIC_OID)
						{
							tempVar->aggtype = BIGINT_OID;
							tempVar->aggtranstype = BIGINT_OID;
						}
						else
						{
							tempVar->aggtype = FLOAT8_OID;
							tempVar->aggtranstype = FLOAT8_OID;
							tempSum->aggfnoid = SUM_FLOAT8_OID;
						}
						opexpr->args = lappend(opexpr->args, opvar);
						opexpr->args = lappend(opexpr->args, opvar);

						/* Create var targetentry */
						tarexpr = makeTargetEntry((Expr *) opexpr,	/* copy needed?? */
												  listn,
												  NULL,
												  false);
						opexpr2 = (OpExpr *) tarexpr->expr;
						opexpr->opfuncid = OPEXPER_FUNCID;
						opexpr->opresulttype = INT_OID;
						opexpr2->opretset = false;
						opexpr2->opcollid = 0;
						opexpr2->inputcollid = 0;
						opexpr2->location = 0;
						tarexpr->resno = 1;
						if (tempVar->aggtype <= INT_OID)
						{
							tempVar->aggtype = BIGINT_OID;
							tempVar->aggtranstype = BIGINT_OID;
						}
						else
						{
							tempVar->aggtype = FLOAT8_OID;
							tempVar->aggtranstype = FLOAT8_OID;
						}
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
					fdw_private->div_tlist = lappend_int(fdw_private->div_tlist, 1);
					elog(DEBUG1, "insert avg expr");
				}
				else
				{
					elog(DEBUG1, "insert orign expr");
					newList = lappend(newList, expr);
				}
#endif
			}
			foreach(lc, dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
			{
				dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
					list_delete_first(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs);
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
				fdw_private->dummy_base_rel_list =
					lappend(fdw_private->dummy_base_rel_list,
							output_rel);

				grouped_root_local = dummy_root;
				grouped_rel_local = dummy_output_rel;
				fdw_private->pPseudoAggPushList = lappend_oid(fdw_private->pPseudoAggPushList, oid_server);
			}
			else
			{
				/* Not Push Down case */
				RelOptInfo *tmp = l->data.ptr_value;
				struct Path *tmp_path;
				Query	   *query = root->parse;

				tmp_path = tmp->pathlist->head->data.ptr_value;
				aggpath = (AggPath *) create_agg_path((PlannerInfo *) dummy_root,
													  dummy_output_rel,
													  tmp_path,
													  dummy_root->upper_targets[UPPERREL_GROUP_AGG],
													  query->groupClause ? AGG_SORTED : AGG_PLAIN, AGGSPLIT_SIMPLE,
													  query->groupClause, NULL, NULL,
													  1);
				fdw_private->dummy_base_rel_list = lappend(fdw_private->dummy_base_rel_list, entry);
				fdw_private->pPseudoAggList = lappend_oid(fdw_private->pPseudoAggList, oid_server);
			}
			i++;
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
	foreach(lc, grouping_target->exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc);
		Index		sgref = get_pathtarget_sortgroupref(grouping_target, i);
		ListCell   *l;

		elog(DEBUG1, "sgref = %d", sgref);
		/* Check whether this expression is part of GROUP BY clause */
		if (sgref && get_sortgroupref_clause_noerr(sgref, query->groupClause))
		{
			/*
			 * If any of the GROUP BY expression is not shippable we can not
			 * push down aggregation to the foreign server.
			 */
			if (!is_foreign_expr(root, grouped_rel, expr))
				return false;
			/* Pushable, add to tlist */
			tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);
		}
		else
		{
			/* Check entire expression whether it is pushable or not */
			if (is_foreign_expr(root, grouped_rel, expr))
			{
				/* Pushable, add to tlist */
				tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);

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
						tlist = spd_add_to_flat_tlist(tlist, list_make1(expr), &mapping_tlist, &mapping_orig_tlist, &temp_tlist, &child_uninum, sgref);
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
	fpinfo->parent_mapping_tlist = tlist;
	fpinfo->mapping_orig_tlist = mapping_orig_tlist;
	fpinfo->child_uninum = child_uninum;
	fpinfo->child_comp_tlist = temp_tlist;

	return true;
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
	Datum	   *oid;
	Datum		server_oid;
	int			nums;
	int			i;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Cost		startup_cost;
	Cost		total_cost;
	ListCell   *base_l;
	ListCell   *root_l;
	ListCell   *oid_l;
	ListCell   *alive_l;
	RelOptInfo *brel;
	ListCell   *lc;

	if (fdw_private == NULL)
	{
		elog(ERROR, "fdw_private is NULL");
	}
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);

	/*
	 * check dummy base rel list length, oid list length and alive list length
	 * are same.
	 */
	if (fdw_private->dummy_base_rel_list->length != fdw_private->ft_oid_list->length || fdw_private->dummy_base_rel_list->length != fdw_private->child_table_alive->length)
	{
		elog(ERROR, "Mismatch of number of child table informations. %d %d %d", fdw_private->dummy_base_rel_list->length, fdw_private->ft_oid_list->length, fdw_private->child_table_alive->length);
	}

	/*
	 * load first dummy_base_rel_lists
	 */
	base_l = list_nth_cell(fdw_private->dummy_base_rel_list, 0);
	root_l = list_nth_cell(fdw_private->dummy_root_list, 0);
	oid_l = list_nth_cell(fdw_private->ft_oid_list, 0);
	alive_l = list_nth_cell(fdw_private->child_table_alive, 0);

	/* Create Foreign paths using base_rel_list to each child node. */
	for (i = 0; i < fdw_private->dummy_base_rel_list->length; i++)
	{
		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (alive_l->data.int_value != TRUE)
		{
			base_l = base_l->next;
			root_l = root_l->next;
			oid_l = oid_l->next;
			alive_l = alive_l->next;
			continue;
		}
		server_oid = spd_spi_exec_datasource_oid(list_nth_oid(fdw_private->ft_oid_list, i));
		if (fdw_private->dummy_base_rel_list == NIL)
		{
			break;
		}
		server_oid = spd_spi_exec_datasource_oid(oid_l->data.oid_value);
		fdwroutine = GetFdwRoutineByServerId(server_oid);

		brel = (RelOptInfo *) lfirst(base_l);
		foreach(lc, brel->reltarget->exprs)
		{
			RangeTblEntry *rte;
			char	   *colname;
			Node	   *node = (Node *) lfirst(lc);

			if (IsA(node, Var))
			{
				Var		   *var = (Var *) node;

				rte = planner_rt_fetch(var->varno, root);
				colname = get_relid_attribute_name(rte->relid, var->varattno);
				if (strcmp(colname, COLNAME) == 0)
				{
					list_delete_ptr(brel->reltarget->exprs, lfirst(lc));
				}
			}
		}
		PG_TRY();
		{
			fdwroutine->GetForeignPaths((PlannerInfo *) root_l->data.ptr_value,
										(RelOptInfo *) base_l->data.ptr_value,
										DatumGetObjectId(oid[i]));
		}
		PG_CATCH();
		{
			/*
			 * If fail to create foreign paths, then set
			 * fdw_private->child_table_alive to FALSE
			 */
			alive_l->data.int_value = FALSE;
			elog(WARNING, "fdw GetForeignPaths error is occurred");
		}
		PG_END_TRY();
		base_l = base_l->next;
		root_l = root_l->next;
		oid_l = oid_l->next;
		alive_l = alive_l->next;
	}
	MemoryContextSwitchTo(oldcontext);

	startup_cost = 0;
	total_cost = startup_cost + baserel->rows;
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
	Datum	   *oid = NULL;
	Datum		server_oid;
	MemoryContext oldcontext;
	SpdFdwPrivate *fdw_private = (SpdFdwPrivate *) baserel->fdw_private;
	Index		scan_relid;
	List	   *fdw_scan_tlist = NIL;	/* Need dummy tlist for pushdown case. */
	ListCell   *base_l;
	ListCell   *root_l;
	ListCell   *oid_l;
	ListCell   *alive_l;
	List	   *child_tlist;
	ListCell   *lc;
	List	   *push_scan_clauses = scan_clauses;
	int			colname_tlist_length = 0;
	TargetEntry *tle;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	if (fdw_private == NULL)
	{
		elog(ERROR, "fdw_private is NULL");
	}
	/* check column is Not Only "column_name" */
	foreach(lc, tlist)
	{
		tle = lfirst_node(TargetEntry, lc);
		if (IsA(tle->expr, Var))
		{
			Var		   *var = (Var *) tle->expr;
			RangeTblEntry *rte;
			char	   *colname;

			rte = planner_rt_fetch(var->varno, root);
			colname = get_relid_attribute_name(rte->relid, var->varattno);
			if (strcmp(colname, COLNAME) == 0)
			{
				colname_tlist_length++;
			}
		}
	}
	if (tlist != NULL)
	{
		if (tlist->length == colname_tlist_length)
		{
			elog(ERROR, "SELECT column name attribute ONLY");
		}
	}

	spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);

	if (fdw_private->dummy_base_rel_list->length != fdw_private->ft_oid_list->length || fdw_private->dummy_base_rel_list->length != fdw_private->child_table_alive->length)
	{
		elog(ERROR, "Missmatch of number of child table informations.");
	}
	base_l = list_nth_cell(fdw_private->dummy_base_rel_list, 0);
	root_l = list_nth_cell(fdw_private->dummy_root_list, 0);
	oid_l = list_nth_cell(fdw_private->ft_oid_list, 0);
	alive_l = list_nth_cell(fdw_private->child_table_alive, 0);

	fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	fdw_private->tList = list_copy(tlist);


	/* Create "GROUP BY" string */
	if (root->parse->groupClause != NULL)
	{
		Query	   *query = root->parse;
		bool		first = true;
		ListCell   *lc;

		fdw_private->groupby_string = makeStringInfo();
		appendStringInfo(fdw_private->groupby_string, "GROUP BY ");
		foreach(lc, query->groupClause)
		{
			char	   *colname = NULL;

			if (!first)
				appendStringInfoString(fdw_private->groupby_string, ", ");
			first = false;

			appendStringInfoString(fdw_private->groupby_string, "(");

			colname = psprintf("col%d", fdw_private->child_uninum - 1);
			appendStringInfoString(fdw_private->groupby_string, colname);
			appendStringInfoString(fdw_private->groupby_string, ")");
		}
	}
	/* Create Foreign Plans using base_rel_list to each child. */
	for (i = 0; i < fdw_private->dummy_base_rel_list->length; i++)
	{
		ForeignScan *temp_obj;
		RelOptInfo *entry;
		List	   *temptlist;

		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (fdw_private->dummy_base_rel_list == NIL)
		{
			break;
		}
		if (alive_l->data.int_value != TRUE)
		{
			base_l = base_l->next;
			root_l = root_l->next;
			oid_l = oid_l->next;
			alive_l = alive_l->next;
			continue;
		}
		/* get child node's oid. */
		server_oid = spd_spi_exec_datasource_oid(list_nth_oid(fdw_private->ft_oid_list, i));
		entry = (RelOptInfo *) list_nth(fdw_private->dummy_base_rel_list, i);
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
			if (root->parse->groupClause != NULL)
			{
				((PlannerInfo *) list_nth(fdw_private->dummy_root_list, i))->parse->groupClause =
					lappend(((PlannerInfo *) list_nth(fdw_private->dummy_root_list, i))->parse->groupClause,
							root->parse->groupClause);
			}
		}
		PG_TRY();
		{
			RelOptInfo *tmp = base_l->data.ptr_value;
			struct Path *tmp_path;

			if (grouped_rel_local != NULL)
			{
				tmp = grouped_rel_local;
			}
			if (tmp->pathlist != NULL)
			{
				tmp_path = tmp->pathlist->head->data.ptr_value;
				temptlist = build_path_tlist((PlannerInfo *) root_l, tmp_path);
			}
			else
			{
				tmp_path = (Path *) best_path;
			}

			/*
			 * For can not aggregation pushdown FDW's. push down quals when
			 * aggregation is occurred
			 */
			if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
			{
				push_scan_clauses = baserestrictinfo;
			}

			/*
			 * check scan_clauses include "__spd_url" If include "__spd_url"
			 * in WHERE clauses, then NOT pushdown all caluses.
			 */
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
						if (strcmp(colname, COLNAME) == 0)
						{
							push_scan_clauses = NULL;
						}
						else
						{
							push_scan_clauses = baserestrictinfo;
						}
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
						if (strcmp(colname, COLNAME) == 0)
						{
							push_scan_clauses = NULL;
						}
					}
				}
			}
			/* create plan */
			if (grouped_rel_local != NULL)
			{
				if (root->parse->groupClause != NULL)
				{
					bool		first = true;
					int			i = 0;
					ListCell   *ttemp;

					fdw_private->groupby_string = makeStringInfo();
					appendStringInfo(fdw_private->groupby_string, "GROUP BY ");
					foreach(ttemp, child_tlist)
					{
						TargetEntry *tlentry = (TargetEntry *) lfirst(ttemp);

						if (tlentry->ressortgroupref == 1)
						{
							char	   *colname = NULL;

							if (first == false)
								appendStringInfoString(fdw_private->groupby_string, ", ");

							appendStringInfoString(fdw_private->groupby_string, "(");
							colname = psprintf("col%d", i);
							appendStringInfoString(fdw_private->groupby_string, colname);
							appendStringInfoString(fdw_private->groupby_string, ")");
							first = false;
						}
						i++;
					}
				}
				temp_obj = fdwroutine->GetForeignPlan(
													  grouped_root_local,
													  grouped_rel_local,
													  DatumGetObjectId(oid[i]),
													  (ForeignPath *) tmp_path,
													  temptlist,
													  push_scan_clauses,
													  outer_plan);
			}
			else
			{
				temptlist = (List *) build_physical_tlist(root_l->data.ptr_value, base_l->data.ptr_value);
				if (root->parse->groupClause != NULL)
				{
					bool		first = true;
					ListCell   *ttemp;
					int			i = 0;

					fdw_private->groupby_string = makeStringInfo();
					appendStringInfo(fdw_private->groupby_string, "GROUP BY ");
					foreach(ttemp, child_tlist)
					{
						TargetEntry *tlentry = (TargetEntry *) lfirst(ttemp);

						if (tlentry->ressortgroupref == 1)
						{
							char	   *colname = NULL;

							if (first == false)
								appendStringInfoString(fdw_private->groupby_string, ", ");

							appendStringInfoString(fdw_private->groupby_string, "(");
							colname = psprintf("col%d", i);
							appendStringInfoString(fdw_private->groupby_string, colname);
							appendStringInfoString(fdw_private->groupby_string, ")");
							first = false;
						}
						i++;
					}
				}
				temp_obj = fdwroutine->GetForeignPlan(
													  (PlannerInfo *) root_l->data.ptr_value,
													  (RelOptInfo *) base_l->data.ptr_value,
													  DatumGetObjectId(oid[i]),
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
			alive_l->data.int_value = FALSE;
			elog(WARNING, "dummy plan list failed ");
		}
		PG_END_TRY();
		/* For aggregation and can not pushdown fdw's */
		if (list_member_oid(fdw_private->pPseudoAggList, server_oid))
		{
			/* Create aggregation plan with foreign table scan. */
			fdw_private->pAgg[i] = make_agg(
											child_tlist,
											NULL,
											aggpath->aggstrategy,
											aggpath->aggsplit,
											list_length(aggpath->groupClause),
											extract_grouping_cols(aggpath->groupClause, fdw_private->child_comp_tlist),
											extract_grouping_ops(aggpath->groupClause),
											root->parse->groupingSets,
											NIL,
											aggpath->path.rows,
											(Plan *) temp_obj);
			fdw_private->dummy_plan_list = lappend(fdw_private->dummy_plan_list, temp_obj);
		}
		else
		{
			fdw_private->dummy_plan_list = lappend(fdw_private->dummy_plan_list, temp_obj);
		}
		/* fetch next list */
		base_l = base_l->next;
		root_l = root_l->next;
		oid_l = oid_l->next;
		alive_l = alive_l->next;
	}
	if (root->parse->hasAggs)
	{
		scan_relid = 0;			/* when aggregation pushdown... */
		if (root->parse->groupClause == NULL)
		{
			fdw_private->agg_query = true;
		}
		scan_relid = baserel->relid;
	}
	else
	{
		scan_relid = baserel->relid;	/* Not aggregation pushdown... */
	}
	grouped_rel_local = NULL;
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
							scan_relid,
							NIL,
							list_make1(makeInteger((long) fdw_private)),
							fdw_scan_tlist,
							NIL,
							outer_plan);
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
 * @param[in] eflags - not use
 */

static void
spd_BeginForeignScan(ForeignScanState *node, int eflags)
{
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	FdwRoutine *fdwroutine;
	Oid			serverId;
	ForeignScanThreadInfo *fssThrdInfo;
	char		contextStr[BUFFERSIZE];
	int			thread_create_err;
	int			nThreads;
	Datum	   *oid = NULL;
	Datum		server_oid;
	SpdFdwPrivate *fdw_private;
	ListCell   *l;
	MemoryContext oldcontext;
	int			node_incr;		/* node_incr is variable of number of
								 * fssThrdInfo. */
	int			private_incr;	/* private_incr is variable of number of
								 * fdw_private */

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	node->spd_fsstate = NULL;
	fdw_private = (SpdFdwPrivate *)
		((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;
	/* get child nodes server oid */

	spd_spi_exec_child_relname(RelationGetRelationName(node->ss.ss_currentRelation), fdw_private, &oid);

	/* Type of Query to be used for computing intermediate results */
	if (fdw_private->agg_query)
	{
		node->ss.ps.state->es_progressState->ps_aggQuery = true;
	}
	else
	{
		node->ss.ps.state->es_progressState->ps_aggQuery = false;
	}

	node->ss.ps.state->agg_query = 0;
	if (!node->ss.ps.state->agg_query)
	{
		if (getResultFlag)
		{
			return;
		}
		/* Get all the foreign nodes from conf file */
		fssThrdInfo = (ForeignScanThreadInfo *) palloc0(
														sizeof(ForeignScanThreadInfo) * fdw_private->node_num);
		node->spd_fsstate = fssThrdInfo;
		/* Supporting for Progress */
		node->ss.ps.state->es_progressState->ps_totalRows = 0;
		node->ss.ps.state->es_progressState->ps_fetchedRows = 0;

		node_incr = 0;
		private_incr = 0;
		foreach(l, fdw_private->dummy_base_rel_list)
		{
			Relation	rd;
			int			natts;
			Form_pg_attribute *attrs;
			TupleDesc	tupledesc;
			int			i;

			/*
			 * check child table node is dead or alive. Execute(Create child
			 * thread) alive table node only.
			 */
			if (list_nth_int(fdw_private->child_table_alive, private_incr) != TRUE)
			{
				private_incr++;
				continue;
			}
			else
			{
			}
			server_oid = spd_spi_exec_datasource_oid(DatumGetObjectId(oid[private_incr]));
			if (getResultFlag)
			{
				break;
			}
			fssThrdInfo[node_incr].fsstate = makeNode(ForeignScanState);
			memcpy(&fssThrdInfo[node_incr].fsstate->ss, &node->ss,
				   sizeof(ScanState));
			/* copy Agg plan when psuedo aggregation case. */
			if (list_member_oid(fdw_private->pPseudoAggList,
								server_oid))
			{
				Plan	   *plan = ((Plan *) list_nth(fdw_private->dummy_plan_list,
													  node_incr));

				fssThrdInfo[node_incr].fsstate->ss.ps.plan =
					copyObject(plan);
			}
			else
			{
				fssThrdInfo[node_incr].fsstate->ss = node->ss;
				fssThrdInfo[node_incr].fsstate->ss.ps.plan =
					copyObject(node->ss.ps.plan);
			}
			fsplan = (ForeignScan *) fssThrdInfo[node_incr].fsstate->ss.ps.plan;
			fsplan->fdw_private = ((ForeignScan *) list_nth(fdw_private->dummy_plan_list, node_incr))->fdw_private;
			fssThrdInfo[node_incr].fsstate->ss.ps.state = CreateExecutorState();
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_top_eflags = eflags;
			fsplan->scan.scanrelid = 0;

			/* This should be a new RTE list. coming from dummy rtable */
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_range_table =
				((PlannerInfo *) list_nth(fdw_private->dummy_root_list, private_incr))
				->parse->rtable;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_plannedstmt =
				copyObject(node->ss.ps.state->es_plannedstmt);
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_tupleTable = NIL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_tuple_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_oldtup_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_newtup_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_query_cxt = node->ss.ps.state->es_query_cxt;
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
				attrs = palloc(child_natts * sizeof(Form_pg_attribute));
				org_attrincr = 0;
				for (i = 0; i < fdw_private->child_uninum; i++)
				{
					TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, org_attrincr);
					char	   *agg_command = target->resname;

					attrs[i] = palloc(sizeof(FormData_pg_attribute));
					memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
						   sizeof(FormData_pg_attribute));

					/*
					 * Extend tuple desc when avg,var,stddev operation is
					 * occurred. AVG is divided SUM and COUNT, VAR and STDDEV
					 * are divided SUM,COUNT,SUM(i*i)
					 */
					if (agg_command == NULL)
						continue;
					if (!strcmpi(agg_command, "AVG") || !strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
					{
						i++;
						attrs[i] = palloc(sizeof(FormData_pg_attribute));
						memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
							   sizeof(FormData_pg_attribute));
#if 1
						if (attrs[i]->atttypid <= BIGINT_OID || attrs[i]->atttypid == NUMERIC_OID)
						{
							attrs[i - 1]->atttypid = BIGINT_OID;
							attrs[i]->atttypid = BIGINT_OID;
							attrs[i - 1]->attalign = 'd';
							attrs[i]->attalign = 'd';
							attrs[i - 1]->attlen = DOUBLE_LENGTH;
							attrs[i]->attlen = DOUBLE_LENGTH;
							attrs[i - 1]->attbyval = 1;
							attrs[i]->attbyval = 1;
						}
						else
						{
							attrs[i - 1]->atttypid = INT_OID;
							attrs[i]->attlen = DOUBLE_LENGTH;
							attrs[i]->attalign = 'd';
							attrs[i]->atttypid = FLOAT8_OID;
						}
#else
						attrs[i - 1]->atttypid = 23;
						attrs[i]->atttypid = 23;
#endif
						if (!strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
						{
							i++;
							attrs[i] = palloc(sizeof(FormData_pg_attribute));
							memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
								   sizeof(FormData_pg_attribute));
							if (attrs[i]->atttypid <= BIGINT_OID || attrs[i]->atttypid == NUMERIC_OID)
							{
								attrs[i]->atttypid = BIGINT_OID;
							}
							else
							{
								attrs[i]->atttypid = FLOAT8_OID;
							}
							attrs[i]->attlen = DOUBLE_LENGTH;
							attrs[i]->attalign = 'd';
							attrs[i]->attbyval = 1;
							org_attrincr++;
							natts++;
						}
						org_attrincr++;
						natts++;
					}
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
			 * private_incr
			 */
			rd = RelationIdGetRelation(DatumGetObjectId(oid[private_incr]));
			fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;

			fssThrdInfo[node_incr].iFlag = true;
			fssThrdInfo[node_incr].EndFlag = false;
			fssThrdInfo[node_incr].tuple = NULL;
			fssThrdInfo[node_incr].nodeIndex = node_incr;

			serverId = server_oid;

			fssThrdInfo[node_incr].serverId = serverId;
			fdwroutine = GetFdwRoutineByServerId(server_oid);
			fssThrdInfo[node_incr].fdwroutine = fdwroutine;
			memset(contextStr, 0, BUFFERSIZE);
			fssThrdInfo[node_incr].threadMemoryContext =
				AllocSetContextCreate(TopMemoryContext,
									  contextStr,
									  ALLOCSET_DEFAULT_MINSIZE,
									  ALLOCSET_DEFAULT_INITSIZE,
									  ALLOCSET_DEFAULT_MAXSIZE);
			fssThrdInfo[node_incr].private = fdw_private;
			pthread_mutex_init((pthread_mutex_t *) &fdw_private->foreign_scan_threads[node_incr], NULL);

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
			private_incr++;
			node_incr++;
		}

		nThreads = node_incr;
		Assert(fdw_private->dummy_base_rel_list->length == nThreads);

		/* Wait for state change */
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			if (fssThrdInfo[node_incr].state == SPD_FS_STATE_INIT)
			{
				pthread_yield();
				node_incr--;
				continue;
			}
		}
	}
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

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	ret = SPI_exec(query, 1);
	if (ret != SPI_OK_UTILITY)
	{
		elog(ERROR, "execute spi CREATE TEMP TABLE failed ");
	}
	SPI_finish();
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
	int			i,
				j;
	int			colid = 0;
	StringInfo	sql = makeStringInfo();
	List	   *mapping_tlist;
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);
	appendStringInfo(sql, "INSERT INTO __spd__temptable VALUES( ");
	colid = 0;
	mapping_tlist = fdw_private->mapping_tlist;
	for (i = 0; i < mapping_tlist->length; i++)
	{
		childtlist *clist = (childtlist *) list_nth(mapping_tlist, i);

		for (j = 0; j < clist->mapping->length; j++)
		{
			int			mapping = list_nth_int(clist->mapping, j);
			Datum		attr;
			char	   *value;
			bool		isnull;
			Oid			typoutput;
			bool		typisvarlena;

			if (colid == mapping)
			{
				if (i != 0 || j != 0)
				{
					appendStringInfo(sql, ",");
				}
				attr = slot_getattr(slot, mapping + 1, &isnull);
				if (isnull)
				{
					appendStringInfo(sql, "0");
					continue;
				}
				getTypeOutputInfo(slot->tts_tupleDescriptor->attrs[colid]->atttypid,
								  &typoutput, &typisvarlena);
				value = OidOutputFunctionCall(typoutput, attr);
				if (value != NULL)
				{
					if (fssThrdInfo[0].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == DATEOID)
					{
						appendStringInfo(sql, "'");
					}
					appendStringInfo(sql, "%s", value);
				}
				if (fssThrdInfo[0].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == DATEOID)
				{
					appendStringInfo(sql, "'");
				}
				colid++;
			}
		}
	}
	appendStringInfo(sql, ")");
	elog(DEBUG1, "insert  = %s", sql->data);

	ret = SPI_exec(sql->data, 1);
	if (ret != SPI_OK_INSERT)
	{
		elog(ERROR, "execute spi INSERT TEMP TABLE failed ");
	}
	SPI_finish();
}

/**
 * spd_spi_select_table
 *
 * This is called by Push-down case.
 * 1. Get All record from child node result
 * 2. Set All getting record to fdw_private->agg_values
 * 3. Create first record and return it.
 *
 * @param[in,out] slot
 * @param[in] node
 * @param[in] fdw_private
 */

static TupleTableSlot *
spd_spi_select_table(TupleTableSlot *slot, ForeignScanState *node, SpdFdwPrivate * fdw_private)
{
	int			ret;
	int			i,
				k;
	bool		isnull = false;
	StringInfo	sql = makeStringInfo();
	int			max_col = 0;

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/* Create Select query */
	appendStringInfo(sql, "SELECT ");

	for (i = 0; i < fdw_private->mapping_tlist->length; i++)
	{
		TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, i);
		char	   *agg_command = target->resname;
		childtlist *clist = (childtlist *) list_nth(fdw_private->mapping_tlist, i);
		int			j = 0;

		for (j = 0; j < clist->mapping->length; j++)
		{
			int			mapping = list_nth_int(clist->mapping, j);

			if (max_col == mapping)
			{
				if (i != 0 || j != 0)
				{
					appendStringInfo(sql, ",");
				}
				if (agg_command == NULL)
				{
					appendStringInfo(sql, "col%d", max_col);
					continue;
				}
				if (!strcmpi(agg_command, "SUM") || !strcmpi(agg_command, "COUNT"))
					appendStringInfo(sql, "SUM(col%d)", max_col);
				else if (!strcmpi(agg_command, "MAX") || !strcmpi(agg_command, "MIN") || !strcmpi(agg_command, "BIT_OR") || !strcmpi(agg_command, "BIT_AND") || !strcmpi(agg_command, "BOOL_AND") || !strcmpi(agg_command, "BOOL_OR") || !strcmpi(agg_command, "EVERY") || !strcmpi(agg_command, "STRING_AGG"))
					appendStringInfo(sql, "%s(col%d)", agg_command, max_col);
				else if (!strcmpi(agg_command, "AVG") || !strcmpi(agg_command, "VARIANCE") || !strcmpi(agg_command, "STDDEV"))
				{
					appendStringInfo(sql, "SUM(col%d)", max_col);
				}
				else
					appendStringInfo(sql, "col%d", max_col);
				max_col++;
			}
		}
	}
	appendStringInfo(sql, " FROM __spd__temptable ");

	/* group by clause */
	if (fdw_private->groupby_string != 0)
	{
		appendStringInfo(sql, "%s", fdw_private->groupby_string->data);
	}
	elog(DEBUG1, "execute spi exec %s", sql->data);

	/* execute select */
	ret = SPI_exec(sql->data, 0);
	if (ret != SPI_OK_SELECT)
	{
		elog(ERROR, "execute spi SELECT TEMP TABLE failed ");
	}
	if (SPI_processed == 0)
	{
		SPI_finish();
		return NULL;
	}
	{
		int			j;
		int			colid;
		int			mapping;
		int			target_column;
		HeapTuple	tuple;
		bool	   *nulls;
		MemoryContext oldcontext;
		childtlist *clist;
		Datum	   *ret_agg_values;
		float8		temp;
		int		   *agg_value_type = NULL;

		target_column = 0;
		oldcontext = MemoryContextSwitchTo(TopTransactionContext);
		fdw_private->agg_values = (Datum **) palloc0(SPI_processed * sizeof(Datum *));
		agg_value_type = (int *) palloc0(SPI_processed * sizeof(int));
		for (i = 0; i < SPI_processed; i++)
		{
			fdw_private->agg_values[i] = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
		}
		fdw_private->agg_tuples = SPI_processed;
		nulls = (bool *) palloc(slot->tts_tupleDescriptor->natts * sizeof(bool));
		MemoryContextSwitchTo(oldcontext);
		/* Initialize to nulls for any columns not present in result */
		memset(nulls, 0, slot->tts_tupleDescriptor->natts * sizeof(bool));
		for (k = 0; k < SPI_processed; k++)
		{
			colid = 0;
			for (i = 0; i < fdw_private->mapping_tlist->length; i++)
			{
				clist = (childtlist *) list_nth(fdw_private->mapping_tlist, i);
				for (j = 0; j < clist->mapping->length; j++)
				{
					mapping = list_nth_int(clist->mapping, j);
					if (colid == mapping)
					{
						agg_value_type[colid] = SPI_tuptable->tupdesc->attrs[colid]->atttypid;
						switch (SPI_tuptable->tupdesc->attrs[colid]->atttypid)
						{
							case NUMERIC_OID:

								fdw_private->agg_values[k][colid] = DirectFunctionCall1(numeric_int8, SPI_getbinval(SPI_tuptable->vals[k],
																													SPI_tuptable->tupdesc,
																													colid + 1,
																													&isnull));
								break;
							case INT_OID:
								fdw_private->agg_values[k][colid] = Int32GetDatum(DatumGetInt32(SPI_getbinval(SPI_tuptable->vals[k],
																											  SPI_tuptable->tupdesc,
																											  colid + 1,
																											  &isnull)));
								break;
							case BIGINT_OID:
								fdw_private->agg_values[k][colid] = Int64GetDatum(DatumGetInt64(SPI_getbinval(SPI_tuptable->vals[k],
																											  SPI_tuptable->tupdesc,
																											  colid + 1,
																											  &isnull)));
								break;
							case SMALLINT_OID:
								fdw_private->agg_values[k][colid] = Int16GetDatum(DatumGetInt16(SPI_getbinval(SPI_tuptable->vals[k],
																											  SPI_tuptable->tupdesc,
																											  colid + 1,
																											  &isnull)));
								break;
							case FLOAT_OID:
								fdw_private->agg_values[k][colid] = Float4GetDatum(DatumGetFloat4(SPI_getbinval(SPI_tuptable->vals[k],
																												SPI_tuptable->tupdesc,
																												colid + 1,
																												&isnull)));
								break;
							case FLOAT8_OID:
								temp = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[k], SPI_tuptable->tupdesc, colid + 1, &isnull));
								fdw_private->agg_values[k][colid] = Float8GetDatum(temp);
								break;
							case BOOL_OID:
								fdw_private->agg_values[k][colid] = BoolGetDatum(DatumGetBool(SPI_getbinval(SPI_tuptable->vals[k],
																											SPI_tuptable->tupdesc,
																											colid + 1,
																											&isnull)));
							case TIMESTAMP_OID:
							case DATE_OID:
								fdw_private->agg_values[k][colid] = CStringGetDatum(DatumGetCString(SPI_getbinval(SPI_tuptable->vals[k],
																												  SPI_tuptable->tupdesc,
																												  colid + 1,
																												  &isnull)));
								break;
							default:
								break;
						}
						colid++;
					}
				}
			}
		}
		ret_agg_values = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
		i = 0;
		target_column = 0;
		for (i = 0; i < fdw_private->mapping_tlist->length; i++)
		{
			childtlist *clist = (childtlist *) list_nth(fdw_private->mapping_tlist, i);
			childtlist *clist_parent = (childtlist *) list_nth(fdw_private->mapping_orig_tlist, i);

			if (clist_parent->avgflag != 0)
			{
				int			mapping_parent = list_nth_int(clist_parent->mapping, 0);

				if (target_column == mapping_parent)
				{
					int			count_mapping = list_nth_int(clist->mapping, 0);
					int			sum_mapping = list_nth_int(clist->mapping, 1);

					float8		result = 0.0;
					float8		sum = 0.0;
					float8		cnt = 0.0;

					switch (agg_value_type[sum_mapping])
					{
						case NUMERIC_OID:
						case INT_OID:
							sum = (float8) DatumGetInt32(fdw_private->agg_values[0][sum_mapping]);
							break;
						case BIGINT_OID:
							sum = (float8) DatumGetInt64(fdw_private->agg_values[0][sum_mapping]);
							break;
						case SMALLINT_OID:
							sum = (float8) DatumGetInt16(fdw_private->agg_values[0][sum_mapping]);
							break;
						case FLOAT_OID:
							sum = (float8) DatumGetFloat4(fdw_private->agg_values[0][sum_mapping]);
							break;
						case FLOAT8_OID:
							sum = (float8) DatumGetFloat8(fdw_private->agg_values[0][sum_mapping]);
							break;
						case BOOL_OID:
						case TIMESTAMP_OID:
						case DATE_OID:
						default:
							break;
					}
					cnt = (float8) DatumGetInt32(fdw_private->agg_values[0][count_mapping]);
					if (clist_parent->avgflag == 1)
					{
						result = sum / cnt;
					}
					else
					{
						int			vardev_mapping = list_nth_int(clist->mapping, 2);
						float8		sum2 = 0.0;
						float8		right = 0.0;
						float8		left = 0.0;

						switch (agg_value_type[vardev_mapping])
						{
							case NUMERIC_OID:
							case INT_OID:
								sum2 = (float8) DatumGetInt32(fdw_private->agg_values[0][vardev_mapping]);
								break;
							case BIGINT_OID:
								sum2 = (float8) DatumGetInt64(fdw_private->agg_values[0][vardev_mapping]);
								break;
							case SMALLINT_OID:
								sum2 = (float8) DatumGetInt16(fdw_private->agg_values[0][vardev_mapping]);
								break;
							case FLOAT_OID:
								sum2 = (float8) DatumGetFloat4(fdw_private->agg_values[0][vardev_mapping]);
								break;
							case FLOAT8_OID:
								sum2 = (float8) DatumGetFloat8(fdw_private->agg_values[0][vardev_mapping]);
								break;
							case BOOL_OID:
							case TIMESTAMP_OID:
							case DATE_OID:
							default:
								break;
						}
						right = sum2;
						left = pow(sum, 2) / cnt;
						result = (float8) (right - left) / (float8) (cnt - 1);
						if (clist_parent->avgflag == 3)
						{
							float		var = 0.0;

							var = (float8) (right - left) / (float8) (cnt - 1);
							result = sqrt(var);
						}
					}

					if (agg_value_type[sum_mapping] == FLOAT8_OID || agg_value_type[sum_mapping] == FLOAT_OID)
					{
						ret_agg_values[target_column] = Float8GetDatumFast(result);
					}
					else
					{
						ret_agg_values[target_column] = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(result));
					}
					target_column++;
				}
			}
			else
			{
				int			mapping = list_nth_int(clist->mapping, 0);
				int			mapping_parent = list_nth_int(clist_parent->mapping, 0);

				if (target_column == mapping_parent)
				{
					ret_agg_values[target_column] = fdw_private->agg_values[0][mapping];
					target_column++;
				}
			}
		}
		tuple = heap_form_tuple(slot->tts_tupleDescriptor, ret_agg_values, nulls);
		ExecStoreTuple(tuple, slot, InvalidBuffer, false);
		fdw_private->agg_num++;
	}
	SPI_finish();
	return slot;
}

/**
 * spd_spi_select_tablecp\
 * Copy from fdw_private->agg_values to returning slot
 * This is used in "GROUP BY" clause
 *
 * @param[in,out] slot
 * @param[in] node
 * @param[in] fdw_private
 */

static TupleTableSlot *
spd_spi_select_tablecp(TupleTableSlot *slot, ForeignScanState *node, SpdFdwPrivate * fdw_private)
{
	HeapTuple	tuple;
	bool	   *nulls;
	MemoryContext oldcontext;
	int			i;
	int			target_column = 0;
	Datum	   *ret_agg_values;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	ret_agg_values = (Datum *) palloc0(slot->tts_tupleDescriptor->natts * sizeof(Datum));
	MemoryContextSwitchTo(oldcontext);

	if (fdw_private->agg_num < fdw_private->agg_tuples)
	{
		for (i = 0; i < fdw_private->mapping_tlist->length; i++)
		{
			childtlist *clist = (childtlist *) list_nth(fdw_private->mapping_tlist, i);
			childtlist *clist_parent = (childtlist *) list_nth(fdw_private->mapping_orig_tlist, i);

			if (clist_parent->avgflag == 1)
			{
				int			mapping_parent = list_nth_int(clist_parent->mapping, 0);

				if (target_column == mapping_parent)
				{
					int			count_mapping = list_nth_int(clist->mapping, 0);
					int			sum_mapping = list_nth_int(clist->mapping, 1);
					float8		result = 0;

					/* calculate AVG */
					if (clist_parent->avgflag == AVGFLAG)
					{
						result = (float8) fdw_private->agg_values[fdw_private->agg_num][sum_mapping] / (float8) fdw_private->agg_values[0][count_mapping];
					}
					/* calculate VARIANCE */
					else if (clist_parent->avgflag == VARFLAG)
					{
						float8		sum = (float8) fdw_private->agg_values[fdw_private->agg_num][sum_mapping];
						float8		cnt = (float8) fdw_private->agg_values[fdw_private->agg_num][count_mapping];
						float8		right = pow(sum / cnt - sum / cnt, 2);
						float8		left = cnt * sum;

						result = sqrt((left + right) / cnt);
					}
					/* calculate STDDEV */
					else if (clist_parent->avgflag == DEVFLAG)
					{
						float8		sum = (float8) fdw_private->agg_values[fdw_private->agg_num][sum_mapping];
						float8		cnt = (float8) fdw_private->agg_values[fdw_private->agg_num][count_mapping];
						float8		right = pow(sum / cnt - sum / cnt, 2);
						float8		left = cnt * sum;

						result = sqrt((left + right) / cnt);
					}
					ret_agg_values[target_column] = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(result));
					target_column++;
				}
			}
			else
			{
				/* set returing slot */
				int			mapping = list_nth_int(clist->mapping, 0);
				int			mapping_parent = list_nth_int(clist_parent->mapping, 0);

				if (target_column == mapping_parent)
				{
					ret_agg_values[target_column] = fdw_private->agg_values[fdw_private->agg_num][mapping];
					target_column++;
				}
			}
		}
		nulls = (bool *) palloc(slot->tts_tupleDescriptor->natts * sizeof(bool));
		for (i = 0; i < slot->tts_tupleDescriptor->natts; i++)
		{
			nulls[i] = false;
		}
		tuple = heap_form_tuple(slot->tts_tupleDescriptor, ret_agg_values, nulls);
		ExecStoreTuple(tuple, slot, InvalidBuffer, false);
		fdw_private->agg_num++;
		return slot;
	}
	else
	{
		return NULL;
	}
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
	int			nThreads;
	int			colid = 0;

	StringInfo	create_sql = makeStringInfo();
	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	bool		icheck = false;
	TupleTableSlot *slot = NULL,
			   *tempSlot = NULL;
	ForeignAggInfo *agginfodata;
	SpdFdwPrivate *fdw_private;
	List	   *mapping_tlist;
	int			i,
				j;
	int		   *fin_flag;
	int			fin_count = 0;
	MemoryContext oldcontext;

	TupleTableSlot *node_slot;
	char	   *value;
	Datum		value_datum = 0;
	Datum		valueDatum = 0;
	HeapTuple	temp_tuple;
	regproc		typeinput;
	int			typemod;
	HeapTuple	newtuple;
	Datum	   *values;
	bool	   *nulls;
	bool	   *replaces;
	ForeignServer *fs;
	ForeignDataWrapper *fdw;
	int			tnum = 0;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = (SpdFdwPrivate *)
		((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;

	if (fdw_private == NULL)
	{
		return NULL;
	}
	mapping_tlist = fdw_private->mapping_tlist;

	if (getResultFlag)
	{
		return NULL;
	}
	/* Get all the foreign nodes from conf file */
	if (fdw_private == NULL)
	{
		elog(ERROR, "can't find node in iterateforeignscan");
	}
	nThreads = fdw_private->dummy_base_rel_list->length;
	agginfodata = palloc0(sizeof(ForeignAggInfo) * nThreads);

	/* CREATE TEMP TABLE */
	if (fdw_private->agg_query)
	{
		if (!fdw_private->agg_query_ft)
		{
			fin_flag = palloc0(sizeof(int) * nThreads);

			appendStringInfo(create_sql, "CREATE TEMP TABLE __spd__temptable(");
			colid = 0;
			for (i = 0; i < mapping_tlist->length; i++)
			{
				childtlist *clist = (childtlist *) list_nth(mapping_tlist, i);

				for (j = 0; j < clist->mapping->length; j++)
				{
					int			mapping = list_nth_int(clist->mapping, j);

					/* append aggregate string */
					if (colid == mapping)
					{
						if (colid != 0)
						{
							appendStringInfo(create_sql, ",");
						}
						appendStringInfo(create_sql, "col%d ", colid);
						/* append column name and column type */
						if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == NUMERICOID)
						{
							appendStringInfo(create_sql, " numeric");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == TEXTOID)
						{
							appendStringInfo(create_sql, " text");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == FLOAT4OID)
						{
							appendStringInfo(create_sql, " float");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == FLOAT8OID)
						{
							appendStringInfo(create_sql, " float8");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == INT2OID)
						{
							appendStringInfo(create_sql, " smallint");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == INT4OID)
						{
							appendStringInfo(create_sql, " int");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == INT8OID)
						{
							appendStringInfo(create_sql, " bigint");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == BITOID)
						{
							appendStringInfo(create_sql, " bit");
						}
						else if (fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[colid]->atttypid == DATEOID)
						{
							appendStringInfo(create_sql, " date");
						}
						else
						{
							appendStringInfo(create_sql, " numeric");
						}
						colid++;
					}
				}
			}
			appendStringInfo(create_sql, ")");
			elog(DEBUG1, "create table  = %s", create_sql->data);
			spd_spi_ddl_table(create_sql->data);
		}

		/*
		 * run aggregation query for all data source threads and combine
		 * results
		 */
		if (!fdw_private->agg_query_ft)
		{
			for (;;)
			{
				int			temp_count = 0;

				for (; fssThrdInfo[temp_count].tuple == NULL;)
				{
					if (fssThrdInfo[temp_count].iFlag)
					{
						icheck = true;
					}
					if (!icheck)
					{
						/* There is no iterating thread. */
						if (fin_flag[temp_count] == 0)
						{
							fin_count++;
							fin_flag[temp_count] = TRUE;
						}
						if (fin_count >= nThreads)
						{
							break;
						}
					}
					temp_count++;
					if (temp_count >= nThreads)
						temp_count = 0;
					icheck = false;
					usleep(1);
				}
				count = temp_count;
				if (fdw_private->agg_query)
				{
					if (fssThrdInfo[count].tuple != NULL)
					{
						/* if this child node finished, update finish flag */
						spd_spi_insert_table(fssThrdInfo[count].tuple, node, fdw_private);
					}
					else
					{
						/* if this child node finished, update finish flag */
						if (fin_flag[count] == 0)
						{
							fin_count++;
							fin_flag[count] = 1;
						}
					}
				}
				tempSlot = fssThrdInfo[count].tuple;
				fssThrdInfo[count].tuple = NULL;
				/* Intermediate results for aggregation query requested */
				if ((fdw_private->agg_query && fin_count >= nThreads) || getResultFlag)
				{
					/*
					 * Aggregation Query Cancellation : Return existing
					 * intermediate result
					 */
					break;
				}
				count++;
				if (count >= nThreads)
				{
					/* if NOT agg query */
					if (!fdw_private->agg_query)
					{
						break;
					}
					count = 0;
				}
			}
		}
		/* First time getting with pushdown from temp table */
		if (fdw_private->agg_query && !fdw_private->agg_query_ft)
		{
			tempSlot = node->ss.ss_ScanTupleSlot;
			tempSlot = spd_spi_select_table(tempSlot, node, fdw_private);
			fdw_private->agg_query_ft = TRUE;
		}
		/* Second time getting from temporary result set */
		else if (fdw_private->agg_query)
		{
			tempSlot = node->ss.ss_ScanTupleSlot;
			tempSlot = spd_spi_select_tablecp(tempSlot, node, fdw_private);
		}
		if (tempSlot != NULL)
		{
			fssThrdInfo[count - 1].tuple = NULL;
			slot = node->ss.ss_ScanTupleSlot;
			ExecCopySlot(slot, tempSlot);
		}
		/* If all tupple getting is finished, then return NULL and drop table */
		if (fdw_private->agg_query && tempSlot == NULL)
		{
			resetStringInfo(create_sql);
			appendStringInfo(create_sql, "DROP TABLE __spd__temptable");
			spd_spi_ddl_table(create_sql->data);
			fdw_private->agg_query_ft = FALSE;
		}
		pfree(agginfodata);
	}
	else
	{
		/* tuple getting is finished */
		for (; fssThrdInfo[count++].tuple == NULL;)
		{
			if (count >= nThreads)
			{
				count = 0;
				for (node_incr = 0; node_incr < nThreads; node_incr++)
				{
					if (fssThrdInfo[node_incr].iFlag)
					{
						icheck = true;
						break;
					}
				}
				if (!icheck)
				{
					/* There is no iterating thread. */
					return NULL;
				}
				icheck = false;
				usleep(1);
			}
		}
		if (nThreads < count)
		{
			return NULL;
		}

		/*
		 * Following is adding node name sequence.
		 */
		fs = GetForeignServer(fssThrdInfo[count - 1].serverId);
		fdw = GetForeignDataWrapper(fs->fdwid);
		node_slot = fssThrdInfo[count - 1].tuple;

		/* Initialize new tuple buffer */
		value = palloc0(sizeof(char) * BUFFERSIZE);
		values = palloc(sizeof(Datum) * node_slot->tts_tupleDescriptor->natts);
		nulls = palloc(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);
		replaces = palloc(sizeof(bool) * node_slot->tts_tupleDescriptor->natts);

		slot = node->ss.ss_ScanTupleSlot;

		MemSet(values, 0, sizeof(values));
		MemSet(value, 0, sizeof(value));
		MemSet(nulls, false, sizeof(nulls));
		MemSet(replaces, false, sizeof(replaces));

		tnum = 0;
		slot_getallattrs(node_slot);
		for (i = 0; i < node_slot->tts_tupleDescriptor->natts; i++)
		{
			/*
			 * Check column include __column_name attribute is exist or not.
			 * If it is include, then create column name attribute.
			 */
			if (strcmp(node_slot->tts_tupleDescriptor->attrs[i]->attname.data, COLNAME) == 0)
			{
				bool		isnull;

				/* Check child node is pgspider or not */
				if (strcmp(fdw->fdwname, SPDFRONT_FDW_NAME) == 0 && node_slot->tts_isnull[i] == FALSE)
				{
					Datum		col = slot_getattr(node_slot, i + 1, &isnull);
					char	   *s;

					if (isnull == TRUE)
					{
						elog(ERROR, "PGSpider column name error. Child node Name is nothing.");
					}
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
					sprintf(value, "/%s/", fs->servername);
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
			ExecStoreVirtualTuple(node_slot);
		}
		ExecCopySlot(slot, node_slot);
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
	int			nThreads = 0;
	ListCell   *l;
	MemoryContext oldcontext;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fssThrdInfo = node->spd_fsstate;
	fdw_private = fssThrdInfo->private;

	/*
	 * Number of child threads is only alive threads. firstly, check to number
	 * of alive child threads.
	 */
	foreach(l, fdw_private->child_table_alive)
	{
		if (l->data.int_value == TRUE)
			nThreads += 1;
	}
	for (node_incr = 0; node_incr < nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR && fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH && fssThrdInfo[node_incr].state != SPD_FS_STATE_ITERATE)
		{
			fssThrdInfo[node_incr].queryRescan = true;
		}
	}
	/* 10us sleep for thread switch */
	pthread_yield();

	for (node_incr = 0; node_incr < nThreads; node_incr++)
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
	int			nThreads = 0;
	ForeignScanThreadInfo *fssThrdInfo;
	SpdFdwPrivate *fdw_private;
	ListCell   *l;

	if (!node->ss.ps.state->agg_query)
	{
		if (node->spd_fsstate == NULL)
		{
			return;
		}
		fssThrdInfo = node->spd_fsstate;
		fdw_private = (SpdFdwPrivate *) fssThrdInfo->private;
		if (fdw_private == NULL)
		{
			return;
		}
		foreach(l, fdw_private->child_table_alive)
		{
			if (l->data.int_value == TRUE)
				nThreads += 1;
		}
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			fssThrdInfo[node_incr].EndFlag = true;
		}

		/* wait until all the remote connections get closed. */
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			/* Cleanup the thread-local structures */
			rtn = pthread_join(fdw_private->foreign_scan_threads[node_incr], NULL);
			if (rtn != 0)
				elog(WARNING, "error is occurred, pthread_join fail in EndForeignScan. ");
			if (fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation)
			{
				RelationClose(
							  fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation);
			}
			spd_ReleasePrivate(fdw_private);
			pfree(fssThrdInfo[node_incr].fsstate->ss.ps.state);
			pfree(fssThrdInfo[node_incr].fsstate);
			MemoryContextDelete(fssThrdInfo[node_incr].threadMemoryContext);
		}
		if (fdw_private->thrdsCreated)
		{
			pfree(node->spd_fsstate);
		}
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
	char	   *new_underurl = NULL;
	Datum	   *oid = NULL;
	Datum		oid_server = 0;


	fdw_private = spd_AllocatePrivate();
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	/* Checking UNDER clause. */
	if (target_rte->url != NULL)
	{
		spd_ParseUrl(target_rte->url, fdw_private);
		if (fdw_private->url_parse_list == NIL ||
			fdw_private->url_parse_list->length < 1)
		{
			/* DO NOTHING */
			elog(ERROR, "NO URL is detected, INSERT/UPDATE/DELETE need to set URL");
		}
		else
		{
			char	   *srvname = palloc(sizeof(char) * (MAX_TABLE_NUM));

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
			 * if child - child is exist, then create child - child UNDER
			 * phrase
			 */
			if (target_url != NULL)
			{
				char		temp[QUERY_LENGTH];

				sprintf(temp, "/%s/", target_url);
				new_underurl = palloc(sizeof(char) * (QUERY_LENGTH));
				strcpy(new_underurl, throwing_url);
			}
			pfree(srvname);
		}
	}
	else
	{
		elog(ERROR, "NO URL is detected, INSERT/UPDATE/DELETE need to set URL");
	}
	spd_spi_exec_child_relname(RelationGetRelationName(target_relation), fdw_private, &oid);
	if (fdw_private->node_num == 0)
	{
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));
	}
	MemoryContextSwitchTo(oldcontext);
	if (oid[0] != 0)
	{
		oid_server = spd_spi_exec_datasource_oid(oid[0]);
		fdwroutine = GetFdwRoutineByServerId(oid_server);
		fdwroutine->AddForeignUpdateTargets(parsetree, target_rte, target_relation);
	}
	tempoid = oid_server;

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
	char	   *new_underurl = NULL;
	Relation	rel;
	Datum	   *oid = NULL;
	Datum		oid_server = 0;
	List	   *child_list = NULL;


	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();

	if (rte->url != NULL)
	{
		spd_ParseUrl(rte->url, fdw_private);
		if (fdw_private->url_parse_list == NIL ||
			fdw_private->url_parse_list->length < 1)
		{
			/* DO NOTHING */
			elog(ERROR, "NO URL is detected, INSERT/UPDATE/DELETE need to set URL");
		}
		else
		{
			char	   *srvname = palloc(sizeof(char) * (MAX_TABLE_NUM));

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
			fdw_private->under_flag = 1;

			/*
			 * if child - child is exist, then create child - child UNDER
			 * phrase
			 */
			if (target_url != NULL)
			{
				char		temp[QUERY_LENGTH];

				sprintf(temp, "/%s/", target_url);
				new_underurl = palloc(sizeof(char) * (QUERY_LENGTH));
				strcpy(new_underurl, throwing_url);
			}
			pfree(srvname);
		}
	}
	else
	{
		elog(ERROR, "NO URL is detected, INSERT/UPDATE/DELETE need to set URL");
	}
	rel = heap_open(rte->relid, NoLock);

	spd_spi_exec_child_relname(RelationGetRelationName(rel), fdw_private, &oid);
	if (fdw_private->node_num == 0)
	{
		ereport(ERROR, (errmsg("Cannot Find child datasources. ")));
	}
	MemoryContextSwitchTo(oldcontext);
	if (oid[0] != 0)
	{
		oid_server = spd_spi_exec_datasource_oid(oid[0]);
		fdwroutine = GetFdwRoutineByServerId(oid_server);
		child_list = fdwroutine->PlanForeignModify(root, plan, resultRelation, subplan_index);
	}
	tempoid = oid_server;
	heap_close(rel, NoLock);
	return child_list;
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
	Oid			oid_server = tempoid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	fdwroutine->BeginForeignModify(mtstate, resultRelInfo, fdw_private, subplan_index, eflags);
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

	Oid			oid_server = tempoid;
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
	Oid			oid_server = tempoid;
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
	Oid			oid_server = tempoid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	return fdwroutine->ExecForeignDelete(estate, resultRelInfo, slot, planSlot);

}

static void
spd_EndForeignModify(EState *estate,
					 ResultRelInfo *resultRelInfo)
{
	Oid			oid_server = tempoid;
	FdwRoutine *fdwroutine;

	fdwroutine = GetFdwRoutineByServerId(oid_server);
	fdwroutine->EndForeignModify(estate, resultRelInfo);
}
