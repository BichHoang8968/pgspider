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
#include "utils/resowner.h"
#include "foreign/fdwapi.h"
#include "foreign/foreign.h"
#include "executor/tuptable.h"
#include "executor/execdesc.h"
#include "executor/executor.h"
#include "catalog/pg_type.h"
#include "miscadmin.h"
#include "nodes/execnodes.h"
#include "nodes/nodes.h"
#include "nodes/pg_list.h"
#include "nodes/plannodes.h"
#include "nodes/relation.h"
#include "nodes/makefuncs.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/var.h"
#include "optimizer/tlist.h"
#include "optimizer/cost.h"
#include "optimizer/clauses.h"
#include "executor/spi.h"
#include "executor/nodeAgg.h"
#include "utils/memutils.h"
#include "utils/palloc.h"
#include "utils/lsyscache.h"
#include "utils/builtins.h"
#include "utils/rel.h"
#include "utils/elog.h"
#include "utils/selfuncs.h"
#include "parser/parsetree.h"
#include "libpq-fe.h"
#include "spd_fdw_defs.h"
#include "spd_fdw_aggregate.h"
#include "funcapi.h"
#include "postgres_fdw/postgres_fdw.h"

#define BUFFERSIZE 1024
#define QUERY_LENGTH 512
#define ENABLE_MERGE_RESULT
#define MAX_TABLE_NUM 1024
#define MAX_URL_LENGTH	256

#define COUNT_OID 2108
#define SUM_OID 2803
#define STD_OID 2148
#define VER_OID 2159
#define AVG_MIN_OID 2100
#define AVG_MAX_OID 2106
#define VAR_MIN_OID 2718
#define VAR_MAX_OID 2729
#define STD_MIN_OID 2153
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

#define POSTGRES_FDW_NAME "postgres_fdw"

/* local function forward declarations */
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
	Agg		   *pAgg;			/* "Aggref" for Disable of aggregation push
								 * down server */
}			SpdFdwPrivate;

Oid			tempoid;
pthread_mutex_t scan_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;


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
    MemoryContextAllocZero(TopTransactionContext,sizeof(*p));
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
	elog(DEBUG1, "execute spi exec %s", query);

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
		elog(DEBUG1, "spd child foreign table oid = %d", (int) (*oid)[i]);
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
	elog(DEBUG1, "%s: execute sql = %s", __FUNCTION__, query);
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
	elog(DEBUG1, "spd child datasource oid = %d", (int) oid);
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
	int         ret;

	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	/* get child server name from child's foreign table id */
	sprintf(query, "SELECT foreign_server_name FROM information_schema._pg_foreign_tables WHERE foreign_table_name = (SELECT relname FROM pg_class WHERE oid = %d) ORDER BY foreign_server_name;", (int) foreigntableid);

	elog(DEBUG1, "%s: execute sql = %s", __FUNCTION__, query);

	ret = SPI_execute(query, true, 0);
	if (ret != SPI_OK_SELECT)
		elog(DEBUG1, "error %d", ret);

	temp = SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1);

	strcpy(srvname, temp);
	elog(DEBUG1, "spd child datasource srvname = %s", srvname);

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
	elog(DEBUG1, "underflag = %d", fdw_private->under_flag);

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
	elog(DEBUG1, "relation name = %s", parentTableName);
	elog(DEBUG1, "sql = %s", query);

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
		elog(DEBUG1, "fdw_private->node_num = %d", fdw_private->node_num);
	}
	fdw_private->node_num = SPI_processed;
	SPI_finish();

	if (fdw_private->dummy_base_rel_list != NIL)
	{
		fdw_private->node_num = fdw_private->dummy_base_rel_list->length;
	}
	elog(DEBUG1, "fdw_private->node_num = %d", fdw_private->node_num);
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
	int			lock_taken = 0;
	int			errflag = 0;
#ifdef MEASURE_TIME
	struct timeval s,
				e,
				e1;
#endif
	ErrorContextCallback errcallback;
	SpdFdwPrivate *fdw_private = fssthrdInfo->private;
	AggState   *aggState = NULL;

	elog(DEBUG1, "entering function %s", __func__);

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
	PG_TRY();
	{
		pthread_mutex_lock(&scan_mutex);
		pthread_mutex_lock(&fssthrdInfo->nodeMutex);
		lock_taken = 1;
		fssthrdInfo->fdwroutine->BeginForeignScan(fssthrdInfo->fsstate,
												  fssthrdInfo->eflags);
		pthread_mutex_unlock(&scan_mutex);
		pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
		lock_taken = 0;
#ifdef MEASURE_TIME
		gettimeofday(&e, NULL);
		elog(DEBUG1, "thread%d begin foreign scan time = %lf", fssthrdInfo->serverId, (e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec) * 1.0E-6);
#endif
	}
	PG_CATCH();
	{
		errflag = 1;
		fssthrdInfo->state = SPD_FS_STATE_ERROR;
		if (lock_taken)
		{
			pthread_mutex_unlock(&scan_mutex);
			pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
		}
		elog(DEBUG1, "Thread error occurred during BeginForeignScan(). %s:%d",
			 __FILE__, __LINE__);
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
		elog(DEBUG1, "Rescan is queried");
		pthread_mutex_lock(&scan_mutex);
		lock_taken = 1;
		fssthrdInfo->fdwroutine->ReScanForeignScan(fssthrdInfo->fsstate);
		pthread_mutex_unlock(&scan_mutex);
		lock_taken = 0;
		fssthrdInfo->iFlag = true;
		fssthrdInfo->tuple = NULL;
		fssthrdInfo->queryRescan = false;
	}
	fssthrdInfo->state = SPD_FS_STATE_ITERATE;

	if (list_member_oid(fdw_private->pPseudoAggList, fssthrdInfo->serverId))
	{

		aggState = SPI_execIntiAgg(
								   fdw_private->pAgg,
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

				pthread_mutex_lock(&fssthrdInfo->nodeMutex);
				if (list_member_oid(fdw_private->pPseudoAggList,
									fssthrdInfo->serverId))
				{
					/*
					 * Retreives aggregated value tuple from underlying non
					 * pushdown source
					 */
					slot = SPI_execRetreiveDirect(aggState);
				}
				else
				{
					slot = fssthrdInfo->fdwroutine->IterateForeignScan(fssthrdInfo->fsstate);
				}
				pthread_mutex_unlock(&fssthrdInfo->nodeMutex);

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
		if (lock_taken)
		{
			pthread_mutex_unlock(&scan_mutex);
		}
		fssthrdInfo->iFlag = false;
		fssthrdInfo->tuple = NULL;
		pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
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
				pthread_mutex_lock(&fssthrdInfo->nodeMutex);
				fssthrdInfo->fdwroutine->EndForeignScan(fssthrdInfo->fsstate);
				pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
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
		pthread_mutex_unlock(&scan_mutex);
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
	pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
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

	if (url_option == NULL)
		return;
	tp = strtok_r(url_option, "/", &next);
	elog(DEBUG1, "fist parse = %s", tp);
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
		elog(DEBUG1, "first = %s,throwing = %s, orig = %s", first_url, throwing_url, tp);
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
	char *original_url;
	char *throwing_url;
	char *first_url;

	elog(DEBUG1, "spd_create_child_url");
	if (r_entry->url == NULL)
	{
		/* DO NOTHING */
		elog(DEBUG1, "NO URL is detected");
		for (int i = 0; i < childnums; i++)
		{
			/* UNDER clause does not use. all child table is alive now. */
			elog(DEBUG1, "set alive_node is true");
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);
		}
		return;
	}
	/*
	 * entry is first parsing word(/foo/bar/, then entry is "foo",entry2
	 * is "bar")
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
			elog(DEBUG1, "set alive_node is true");
			fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, TRUE);
		}
		return;
	}
	
	original_url = (char *) list_nth(fdw_private->url_parse_list, 0);
	if (fdw_private->url_parse_list->length > 2)
	{
		first_url = (char *) list_nth(fdw_private->url_parse_list, 1);
		elog(DEBUG1, "first_url = %s", first_url);
		throwing_url = (char *) list_nth(fdw_private->url_parse_list, 2);
		elog(DEBUG1, "throwing_url = %s", throwing_url);
	}
	/* If UNDER Clause is used, then store to parsing url */
	for (int i = 0; i < childnums; i++)
	{
		char		srvname[NAMEDATALEN];
		Datum		temp_oid = list_nth_oid(fdw_private->ft_oid_list, i);
		Oid			temp_tableid;
		ForeignServer *temp_server;
		ForeignDataWrapper *temp_fdw;

		spd_spi_exec_datasource_name(temp_oid, srvname);
		elog(DEBUG1, "srv_name = %s, original_url = %s %s %s", srvname, original_url, first_url, throwing_url);
		if (strcmp(original_url, srvname) != 0)
		{
			elog(DEBUG1, "srvname is not same. set alive_node is false");
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
			if(strcmp(temp_fdw->fdwname, POSTGRES_FDW_NAME) != 0)
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
			elog(DEBUG1, "new under url = %s", *new_underurl);
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

			rel_oid = list_nth_oid(fdw_private->ft_oid_list, i);
			if (rel_oid == 0)
			{
				continue;
			}

			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			fdwroutine = GetFdwRoutineByServerId(oid_server);

			/*
			 * Set up mostly-dummy planner state PlannerInfo can not
			 * deep copy with copyObject(). BUt It should create dummy
			 * PlannerInfo for each child tables. Following code is
			 * copy from plan_cluster_use_sort(), it create simple
			 * PlannerInfo.
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
			 * if child node is spd and UNDER clause is used, then
			 * should set new UNDER clause URL at child node planner
			 * URL.
			 */
			if (new_underurl != NULL)
			{
				rte->url = palloc(sizeof(char) * strlen(new_underurl));
				strcpy(rte->url, new_underurl);
				elog(DEBUG1, "rte->url = %s", new_underurl);
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
			 * Build RelOptInfo Build simple relation and copy target
			 * list and strict info from root information.
			 */
			entry_baserel = build_simple_rel(dummy_root, baserel->relid, RELOPT_BASEREL);
			entry_baserel->reltarget->exprs = copyObject(baserel->reltarget->exprs);
			entry_baserel->baserestrictinfo = copyObject(baserel->baserestrictinfo);
			PG_TRY();
			{
				fdwroutine->GetForeignRelSize(dummy_root, entry_baserel, DatumGetObjectId(rel_oid));
				elog(DEBUG1, "base add");
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
				 * spd_beginForeignScan() get information of child tables
				 * from system table and compare it with
				 * fdw_private->dummy_base_rel_list. That's why, the
				 * length of fdw_private->dummy_base_rel_list should match
				 * the number of all of the child tables belong to parent
				 * table.
				 */
				fdw_private->dummy_base_rel_list = lappend(fdw_private->dummy_base_rel_list, entry_baserel);
				fdw_private->dummy_root_list = lappend(fdw_private->dummy_root_list, dummy_root);
				l = list_nth_cell(fdw_private->child_table_alive, i);
				l->data.int_value = FALSE;
				elog(DEBUG1, "base NOT add");
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
				elog(DEBUG1, "base add");
				i++;
			}
			PG_CATCH();
			{
				fdw_private->child_table_alive = lappend_int(fdw_private->child_table_alive, FALSE);
				elog(DEBUG1, "base NOT add");
			}
			PG_END_TRY();
		}
	}
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

	elog(DEBUG1, "entering function %s", __func__);

	baserel->rows = 0;
	fdw_private = spd_AllocatePrivate();
	fdw_private->base_relation_name = get_rel_name(foreigntableid);
	fdw_private->rinfo.pushdown_safe = true;
	baserel->fdw_private = (void *) fdw_private;

	oldcontext = MemoryContextSwitchTo(CurrentMemoryContext);
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
		elog(DEBUG1, "append ");
	}
	pfree(oid);
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
			elog(DEBUG1, "set alive_node is false");
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

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((SpdFdwPrivate *) input_rel->fdw_private)->rinfo.pushdown_safe)
		return;
	in_fdw_private = (SpdFdwPrivate *) input_rel->fdw_private;

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

			oid_server = spd_spi_exec_datasource_oid(rel_oid);
			/* pthread_mutex_lock(&scan_mutex); */
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			RelOptInfo *dummy_output_rel;
			PathTarget *grouping_target;
			ListCell   *lc;
			int			listn = 0;
			
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
			dummy_root->upper_targets[UPPERREL_GROUP_AGG] =
				copy_pathtarget(root->upper_targets[UPPERREL_GROUP_AGG]);
			dummy_root->upper_targets[UPPERREL_WINDOW] =
				copy_pathtarget(root->upper_targets[UPPERREL_WINDOW]);
			dummy_root->upper_targets[UPPERREL_FINAL] =
				copy_pathtarget(root->upper_targets[UPPERREL_FINAL]);
			grouping_target = root->upper_targets[UPPERREL_GROUP_AGG];
			foreach(lc, grouping_target->exprs)
			{
				Expr	   *expr = (Expr *) lfirst(lc);
				Aggref	   *aggref;
				Expr	   *temp_expr;
				
				aggref = (Aggref *) expr;
				temp_expr = list_nth(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, listn);
				listn++;
				if ((aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID) ||
					(aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID) ||
					(aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID))
				{
					/* Prepare SUM Query */
						/*
						 * TODO: Appropriate aggfnoid should be choosen based
						 * on type
						 */
					Aggref	   *tempSUM = copyObject(aggref);
					Aggref	   *temp;
					
					tempSUM->aggfnoid = COUNT_OID;
					tempSUM->aggtype = BIGINT_OID;
					tempSUM->aggtranstype = BIGINT_OID;
					
					/* Prepare Count Query */
					temp = copyObject(tempSUM);
					temp->aggfnoid = SUM_OID;
					temp->aggargtypes = NULL;
					elog(DEBUG1, "insert avg expr");
					newList = lappend(newList, tempSUM);
					newList = lappend(newList, temp);
				}
				else
				{
					dummy_root->upper_targets[UPPERREL_WINDOW] = copy_pathtarget(root->upper_targets[UPPERREL_WINDOW]);
					elog(DEBUG1, "insert orign expr");
					newList = lappend(newList, temp_expr);
				}
			}
			foreach(lc, dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs)
			{
				dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
					list_delete_first(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs);
			}
			foreach(lc, newList)
			{
				Expr	   *expr = (Expr *) lfirst(lc);
				elog(DEBUG1, "insert expr");
				dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
					lappend(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, expr);
			}
			if(fdwroutine->GetForeignUpperPaths!=NULL){
				fdwroutine->GetForeignUpperPaths(
					dummy_root,
					stage, entry, dummy_output_rel);
				fdw_private->dummy_base_rel_list =
					lappend(fdw_private->dummy_base_rel_list,
							dummy_output_rel);
				fdw_private->pPseudoAggPushList = lappend_oid(fdw_private->pPseudoAggPushList, oid_server);
			}else{
				/* Not Push Down case */
				fdw_private->dummy_base_rel_list = lappend(fdw_private->dummy_base_rel_list, entry);
				fdw_private->pPseudoAggList = lappend_oid(fdw_private->pPseudoAggList, oid_server);
			}
			/* pthread_mutex_unlock(&scan_mutex); */
			elog(DEBUG1, "upperpath add");
			i++;
		}
	}
	fdw_private->rinfo.pushdown_safe = false;
	output_rel->fdw_private = fdw_private;
	output_rel->relid = input_rel->relid;

	add_foreign_grouping_paths(root, input_rel, output_rel);
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
	List	   *tlist = NIL;

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
			tlist = add_to_flat_tlist(tlist, list_make1(expr));
		}
		else
		{
			/* Check entire expression whether it is pushable or not */
			if (is_foreign_expr(root, grouped_rel, expr))
			{
				/* Pushable, add to tlist */
				tlist = add_to_flat_tlist(tlist, list_make1(expr));
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
						tlist = add_to_flat_tlist(tlist, list_make1(expr));
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
	if (fpinfo->rinfo.local_conds)
	{
		List	   *aggvars = NIL;
		ListCell   *lc;

		foreach(lc, fpinfo->rinfo.local_conds)
		{
			RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

			aggvars = list_concat(aggvars,
								  pull_var_clause((Node *) rinfo->clause,
												  PVC_INCLUDE_AGGREGATES));
		}

		foreach(lc, aggvars)
		{
			Expr	   *expr = (Expr *) lfirst(lc);

			/*
			 * If aggregates within local conditions are not safe to push
			 * down, then we cannot push down the query.  Vars are already
			 * part of GROUP BY clause which are checked above, so no need to
			 * access them again here.
			 */
			if (IsA(expr, Aggref))
			{
				if (!is_foreign_expr(root, grouped_rel, expr))
					return false;

				tlist = add_to_flat_tlist(tlist, list_make1(expr));
			}
		}
	}

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

	oldcontext = MemoryContextSwitchTo(CurrentMemoryContext);

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
		elog(DEBUG1, "spd_GetForeignPaths %d", i);
		/* skip to can not access child table at spd_GetForeignRelSize. */
		if (alive_l->data.int_value != TRUE)
		{
			elog(DEBUG1, "skip spd_GetForeignPaths %d", i);
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
		PG_TRY();
		{
			fdwroutine->GetForeignPaths((PlannerInfo *) root_l->data.ptr_value, (RelOptInfo *) base_l->data.ptr_value, DatumGetObjectId(oid[i]));

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
 * spd_createPushDownPlan
 *
 * build aggregation plan for each push down cases.
 * saving each foreign plan into base rel list
 *
 * @param[in] tlist               - target list
 * @param[out] agg_query          - aggregation flag
 * @param[out] pPseudoAggTypeList - Push down type list
 *
 */
static void
spd_createPushDownPlan(List *tlist, bool *agg_query, List *pPseudoAggTypeList)
{

	/*
	 * Temporary create TargetEntry: @todo make correct targetenrty, as if it
	 * is the correct aggregation. (count, max, etc..)
	 */
	TargetEntry *tle;
	Var		   *var;
	Aggref	   *aggref;
	ListCell   *lc;
	int			att = 0;
	List	   *dummy_tlist = NIL;
	List	   *dummy_tlist2 = NIL;

	dummy_tlist2 = copyObject(tlist);
	foreach(lc, dummy_tlist2)
	{
		tle = lfirst_node(TargetEntry, lc);
		if (IsA(tle->expr, Aggref))
		{
			aggref = (Aggref *) tle->expr;
			if (aggref->args &&((aggref->aggfnoid >= AVG_MIN_OID && aggref->aggfnoid <= AVG_MAX_OID)	/* AVG Query */
								|| (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
								|| (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)) /* STDDEV, VARIANCE */
				)
			{
				/* Prepare SUM Query */
				/*
				 * TODO: Appropriate aggfnoid should be choosen based on
				 * type
				 */
				TargetEntry *tle_var;
				TargetEntry *tleTemp;
				TargetEntry *tempCount;
				Aggref	   *tempSUM;
				Aggref	   *temp;

				*agg_query = true;

				tle_var = (TargetEntry *) lfirst_node(Var, aggref->args->head);
				var = (Var *) tle_var->expr;

				tleTemp = copyObject(tle);
				tempSUM = copyObject(aggref);
				tempSUM->aggtype = var->vartype;
				dummy_tlist2 = list_delete_first(dummy_tlist2);
				switch (tempSUM->aggtype)
				{
				case BIGINT_OID:	/* int8 big int */
					tempSUM->aggfnoid = SUM_BIGINT_OID;
					break;
				case SMALLINT_OID:	/* int2 small int */
					tempSUM->aggfnoid = SUM_INT2_OID;
					break;
				case INT_OID:	/* int4 */
					tempSUM->aggfnoid = SUM_INT4_OID;
					break;
				case FLOAT_OID: /* float 4 - real */
					tempSUM->aggfnoid = SUM_FLOAT4_OID;
					break;
				case FLOAT8_OID:	/* float 8 - double precision */
					tempSUM->aggfnoid = SUM_FLOAT8_OID;
					break;
				case NUMERIC_OID:	/* numeric */
					tempSUM->aggfnoid = SUM_NUMERI_OID;
					break;
				}
				tempSUM->aggtranstype = var->vartype;
				tleTemp->expr = (Expr *) copyObject(tempSUM);

				/* Prepare Count Query */
				tempCount = copyObject(tleTemp);
				temp = copyObject(tempSUM);
				temp->aggfnoid = SUM_OID;
				temp->aggargtypes = NULL;
				temp->args = NULL;
				tempCount->expr = (Expr *) copyObject(temp);
				/* set command oid */
				if (aggref->aggfnoid >= VAR_MIN_OID && aggref->aggfnoid <= VAR_MAX_OID)
				{
					pPseudoAggTypeList = lappend_oid(pPseudoAggTypeList, VAR_MIN_OID);
				}
				else if (aggref->aggfnoid >= STD_MIN_OID && aggref->aggfnoid <= STD_MAX_OID)
				{
					pPseudoAggTypeList = lappend_oid(pPseudoAggTypeList, STD_MIN_OID);
				}
				else
				{
					pPseudoAggTypeList = lappend_oid(pPseudoAggTypeList, AVG_MIN_OID);
				}
				/* Add Count Query to the Pushdown Plan */
				dummy_tlist2 = lappend(dummy_tlist2, tempCount);
				/* Add SUM Query to the Pushdown Plan */
				dummy_tlist2 = lappend(dummy_tlist2, tleTemp);
				/* Query Segregation needed */
				break;
			}
		}
	}
	foreach(lc, dummy_tlist2)
	{
		tle = lfirst_node(TargetEntry, lc);
		if (IsA(tle->expr, Aggref))
		{
			aggref = (Aggref *) tle->expr;
			if (aggref->args)
			{
				tle = (TargetEntry *) lfirst_node(Var, aggref->args->head);
				if (!list_member(dummy_tlist, tle))
				{
					TargetEntry *copy_tle = copyObject(tle);

					att++;
					copy_tle->resno = att;
					dummy_tlist = lappend(dummy_tlist, copy_tle);
				}
				/* Modify VAR of dummy_tlist2 for OUTER_VAR */
				var = (Var *) tle->expr;
				var->varno = OUTER_VAR;
				var->varattno = att;
			}
		}
		else if (IsA(tle->expr, Var))
		{
			if (!list_member(dummy_tlist, tle))
			{
				TargetEntry *copy_tle = copyObject(tle);

				att++;
				copy_tle->resno = att;
				dummy_tlist = lappend(dummy_tlist, copy_tle);
			}
			/* Modify VAR of dummy_tlist2 for OUTER_VAR */
			var = (Var *) tle->expr;
			var->varno = OUTER_VAR;
			var->varattno = att;
		}
	}
}

/**
 * spd_GetForeignPlan
 *
 * build foreign plan for each child tables using fdws.
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

	oldcontext = MemoryContextSwitchTo(CurrentMemoryContext);

    spd_spi_exec_datasouce_num(foreigntableid, &nums, &oid);

	if (fdw_private->dummy_base_rel_list->length != fdw_private->ft_oid_list->length || fdw_private->dummy_base_rel_list->length != fdw_private->child_table_alive->length)
	{
		elog(ERROR, "Missmatch of number of child table informations.");
	}
	base_l = list_nth_cell(fdw_private->dummy_base_rel_list, 0);
	root_l = list_nth_cell(fdw_private->dummy_root_list, 0);
	oid_l = list_nth_cell(fdw_private->ft_oid_list, 0);
	alive_l = list_nth_cell(fdw_private->child_table_alive, 0);

	if (IS_UPPER_REL(baserel))
	{
		/**
		 * Possibly aggregation pushdown case, so need to make
		 * dummy tlist for pushdown case
		 */
		fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	}
	fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	fdw_private->tList = list_copy(tlist);

	/* Create Foreign Plans using base_rel_list to each child. */
	for (i = 0; i < fdw_private->dummy_base_rel_list->length; i++)
	{
		ForeignScan *temp_obj;
		RelOptInfo *entry;
		List	   *dummy_tlist = NIL;
		List	   *dummy_tlist2 = NIL;

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
			elog(DEBUG1, "skip spd_GetForeignPlan %d", i);
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
			spd_createPushDownPlan(tlist, &fdw_private->agg_query, fdw_private->pPseudoAggTypeList);
		} else {
			dummy_tlist = tlist;
			dummy_tlist2 = tlist;

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
			temp_obj = fdwroutine->GetForeignPlan(
												  (PlannerInfo *) root_l->data.ptr_value,
												  (RelOptInfo *) base_l->data.ptr_value,
												  DatumGetObjectId(oid[i]),
												  best_path,
												  dummy_tlist,
												  scan_clauses,
												  outer_plan);
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
		if (list_member_oid(fdw_private->pPseudoAggList,
							server_oid))
		{
			/* Create aggregation plan with foreign table scan. */
			fdw_private->pAgg = make_agg(
										 dummy_tlist2,
										 NULL,
										 AGG_SORTED, AGGSPLIT_SIMPLE,
										 list_length(root->parse->groupClause),
										 extract_grouping_cols(root->parse->groupClause, tlist),
										 extract_grouping_ops(root->parse->groupClause),
										 root->parse->groupingSets, NIL,
										 best_path->path.rows,
										 (Plan *) temp_obj);
		}
		fdw_private->dummy_plan_list = lappend(fdw_private->dummy_plan_list,
											   temp_obj);
		elog(DEBUG1, "append dummy plan list %d", (int) oid[i]);
		base_l = base_l->next;
		root_l = root_l->next;
		oid_l = oid_l->next;
		alive_l = alive_l->next;
	}

	if (root->parse->hasAggs)
	{
#if 0
		scan_relid = 0;			/* when aggregation pushdown... */
		if (root->parse->groupClause == NULL)
		{
			fdw_private->agg_query = true;
		}
#endif
		scan_relid = baserel->relid;
	}
	else
	{
		scan_relid = baserel->relid;	/* Not aggregation pushdown... */
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
	return make_foreignscan(tlist,
							NIL, /* scan_clauses,*/
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
 * Firstly, get all child table.
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
	int			pushlist_count = 0;
	elog(DEBUG1, "entering function %s", __func__);

	oldcontext = MemoryContextSwitchTo(CurrentMemoryContext);
	node->spd_fsstate = NULL;
	fdw_private = (SpdFdwPrivate *)
		((Value *) list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql))->val.ival;
	/* get child nodes server oid */

	spd_spi_exec_child_relname(RelationGetRelationName(node->ss.ss_currentRelation), fdw_private, &oid);
	elog(DEBUG1, "agg query %d", node->ss.ps.state->agg_query);

	/* Type of Query to be used for computing intermediate results */
	if (fdw_private->agg_query)
	{
		node->ss.ps.state->es_progressState->ps_aggQuery = true;
	}
	else
	{
		node->ss.ps.state->es_progressState->ps_aggQuery = false;
	}

	elog(DEBUG1, "agg query%d", node->ss.ps.state->agg_query);
	node->ss.ps.state->agg_query = 0;
	if (!node->ss.ps.state->agg_query)
	{
		if (getResultFlag)
		{
			elog(DEBUG1, "get result flag");
			return;
		}
		/* Get all the foreign nodes from conf file */
		fssThrdInfo = (ForeignScanThreadInfo *) palloc0(
													   sizeof(ForeignScanThreadInfo) * fdw_private->node_num);
		node->spd_fsstate = fssThrdInfo;
		/* Supporting for Progress */
		node->ss.ps.state->es_progressState->ps_totalRows = 0;
		node->ss.ps.state->es_progressState->ps_fetchedRows = 0;

		//pthread_mutex_lock(&scan_mutex);
		elog(DEBUG1, "main thread lock scan mutex ");

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
				elog(DEBUG1, "fdw_private->dummy_plan_list list nothing %d", private_incr);
				private_incr++;
				continue;
			}
			else
			{
				elog(DEBUG1, "fdw_private->dummy_plan_list list found %d", private_incr);
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

			/* Modify child plan */
			natts = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts;
			if (IS_UPPER_REL((RelOptInfo*)l))
			{
				Datum	   *aggoid = list_nth(fdw_private->pPseudoAggTypeList, pushlist_count);
				int  org_attrincr=0;
				int org_natts = natts;
				/*
				 * Extract attribute details. The tupledesc made here is just
				 * transient.
				 */
				attrs = palloc(natts * sizeof(Form_pg_attribute));
				for (i = 0; i < org_natts; i++)
				{
					elog(DEBUG1, "natts %d", natts);

					attrs[i] = palloc(sizeof(FormData_pg_attribute));
					memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
						   sizeof(FormData_pg_attribute));
					elog(DEBUG1, "attrs[i]->atttypid = %d", attrs[i]->atttypid);
					/*
					 * Extend tuple desc when AVG,STD,VAR operation is occurred.
					 *
					 */
					if ((attrs[org_attrincr]->atttypid >= AVG_MIN_OID &&
						 attrs[org_attrincr]->atttypid <= AVG_MAX_OID) ||
						(attrs[org_attrincr]->atttypid >= VAR_MIN_OID &&
						 attrs[org_attrincr]->atttypid <= VAR_MAX_OID) ||
						(attrs[org_attrincr]->atttypid >= STD_MIN_OID &&
						 attrs[org_attrincr]->atttypid <= STD_MIN_OID))
					{
						natts += 1;
						i++;
						attrs = palloc_extended(natts * sizeof(Form_pg_attribute),
												MCXT_ALLOC_NO_OOM | MCXT_ALLOC_ZERO);
						attrs[i] = palloc(sizeof(FormData_pg_attribute));
						memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[org_attrincr],
							   sizeof(FormData_pg_attribute));
					}
					org_attrincr++;
				}
				/* Construct TupleDesc, and assign a local typmod. */
				tupledesc = CreateTupleDesc(natts, true, attrs);
				tupledesc = BlessTupleDesc(tupledesc);

				fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(
						CreateTupleDescCopy(
							tupledesc));
			}
			else
			{
				fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(
						CreateTupleDescCopy(
							node->ss.ss_ScanTupleSlot->tts_tupleDescriptor));
			}
			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_mcxt = node->ss.ss_ScanTupleSlot->tts_mcxt;

			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_values = (Datum *)
				MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts * sizeof(Datum));
			fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot->tts_isnull = (bool *)
				MemoryContextAlloc(node->ss.ss_ScanTupleSlot->tts_mcxt, node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts * sizeof(bool));

			/*
			 * current relation ID gets from current server oid, it means
			 * private_incr
			 */
			rd = RelationIdGetRelation(DatumGetObjectId(oid[private_incr]));
			fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;
			elog(DEBUG1, "oid = %d", fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation->rd_node.relNode);

			fssThrdInfo[node_incr].iFlag = true;
			fssThrdInfo[node_incr].EndFlag = false;
			fssThrdInfo[node_incr].tuple = NULL;
			fssThrdInfo[node_incr].nodeIndex = node_incr;

			serverId = server_oid;
			elog(DEBUG1, "serveroid %d", serverId);

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
		//pthread_mutex_unlock(&scan_mutex);
		elog(DEBUG1, "main thread unlock scan mutex ");

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

static void spd_spi_ddl_table(char *query){
	int			ret;
	int			i;
	int			spi_temp;
	MemoryContext oldcontext;
	MemoryContext spicontext;

	oldcontext = CurrentMemoryContext;
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	elog(DEBUG1, "execute spi exec %s", query);

	ret = SPI_exec(query, 1);
	if(ret != SPI_OK_UTILITY) {
		elog(ERROR,"execute spi CREATE TEMP TABLE failed ");
	}
	SPI_finish();
}

static void spd_spi_insert_table(TupleTableSlot *slot){
	int			ret;
	int			i;
	int			spi_temp;
	bool isnull = false;
	MemoryContext oldcontext;
	MemoryContext spicontext;
	StringInfo  sql = makeStringInfo();

	oldcontext = CurrentMemoryContext;
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	appendStringInfo(sql, "INSERT INTO __spd__temptable VALUES( ");
	for(i=0;i <slot->tts_tupleDescriptor->natts;i ){
		if(i != 0){
			appendStringInfo(sql, ",");
		}
		if(slot->tts_isnull){
			appendStringInfo(sql, " ");
		}
		else{
			Datum		attr;
			char	   *value;
			bool		isnull;
			Oid			typoutput;
			bool		typisvarlena;

			attr = slot_getattr(slot, i + 1, &isnull);
			if (isnull)
				continue;

			getTypeOutputInfo(slot->tts_tupleDescriptor->attrs[i]->atttypid,
							  &typoutput, &typisvarlena);
			value = OidOutputFunctionCall(typoutput, attr);
			appendStringInfo(sql, "%s",value);
		}
	}
	appendStringInfo(sql, ")");

	ret = SPI_exec(sql, 1);
	if(ret != SPI_OK_INSERT) {
		elog(ERROR,"execute spi INSERT TEMP TABLE failed ");
	}
	SPI_finish();
}

static void spd_spi_select_table(TupleTableSlot *slot,ForeignScanState *node){
	int			ret;
	int			i;
	int			spi_temp;
	bool isnull = false;
	MemoryContext oldcontext;
	MemoryContext spicontext;
	StringInfo  sql = makeStringInfo();

	oldcontext = CurrentMemoryContext;
	ret = SPI_connect();
	if (ret < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	appendStringInfo(sql, "SELECT ");
	for(i = 0; i < slot->tts_tupleDescriptor->natts; i++){
		if(i != 0) {
			appendStringInfo(sql, ",");
		}
		if(slot->tts_isnull){
			appendStringInfo(sql, " ");
		}
		else{
			TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, attNum);
			char	   *agg_command = test->resname;

			Datum		attr;
			char	   *value;
			bool		isnull;
			Oid			typoutput;
			bool		typisvarlena;

			attr = slot_getattr(slot, i + 1, &isnull);
			if (isnull)
				continue;
			if (!strcmpi(agg_command, "SUM")||!strcmpi(agg_command, "COUNT"))
				appendStringInfo(sql, "SUM(");
			else if (!strcmpi(agg_command, "MAX") || !strcmpi(agg_command, "MIN") ||!strcmpi(agg_command, "BIT_OR")||!strcmpi(agg_command, "BIT_AND") || !strcmpi(agg_command, "BOOL_AND") || !strcmpi(agg_command, "BOOL_OR") ||!strcmpi(agg_command, "EVERY")||!strcmpi(agg_command, "STRING_AGG"))
				appendStringInfo(sql, "%s(",);
			else if (!strcmpi(agg_command, "AVG")||!strcmpi(agg_command, "VARIANCE")||!strcmpi(agg_command, "STDDEV"))
				appendStringInfo(sql, "SUM(%s),COUNT(");
			appendStringInfo(sql, "%s)",i);
			getTypeOutputInfo(slot->tts_tupleDescriptor->attrs[i]->atttypid,
							  &typoutput, &typisvarlena);
			value = OidOutputFunctionCall(typoutput, attr);
			appendStringInfo(sql, "%s",value);
		}
	}
	appendStringInfo(sql, " FROM __spd__temptable");

	/* group by clause */
	if(ret != 0){
		// appendStringInfo(sql, " GROUP BY ");
	}
	/* execute select */
	ret = SPI_exec(sql, 1);
	if(ret != SPI_OK_SELECT) {
		elog(ERROR,"execute spi SELECT TEMP TABLE failed ");
	}
	SPI_finish();
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
	static int	count = 0;
	int			node_incr;
	int			nThreads;
	StringInfo	create_sql = makeStringInfo();

	ForeignScanThreadInfo *fssThrdInfo = node->spd_fsstate;
	bool		icheck = false;
	TupleTableSlot *slot = NULL,
			   *tempSlot = NULL;
	ForeignAggInfo *agginfodata;
	SpdFdwPrivate *fdw_private;
	int	run;
	int i;
	int *fin_flag;
	int fin_count;

	fdw_private = fssThrdInfo->private;

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

	/*
	 * run aggregation query for all data source threads and combine results
	 */
	if(fdw_private->agg_query) {
		run = nThreads;
		fin_flag = palloc0(sizeof(int)*nThreads);
		node->ss.ps.state->es_progressState->dest = (void *) ((QueryDesc *) node->ss.ps.spdAggQry)->dest;
		strcpy(agginfodata[0].transquery, ((QueryDesc *) node->ss.ps.spdAggQry)->sourceText);
		/* Create temp table */
		appendStringInfo(create_sql, "CREATE TEMP TABLE __spd__temptable( ");
		for(i=0;i < node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts ;i++) {
			TargetEntry *target = (TargetEntry *) list_nth(node->ss.ps.plan->targetlist, i);
			if(i != 0) {
				appendStringInfo(create_sql, ",");
			}
			/* append aggregate string */
			appendStringInfo(create_sql, target->resname);
			/* append column name and column type */
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == NUMERICOID) {
				appendStringInfo(create_sql, " numeric");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == TEXTOID) {
				appendStringInfo(create_sql, " text");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == FLOAT4OID) {
				appendStringInfo(create_sql, " float");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == FLOAT8OID) {
				appendStringInfo(create_sql, " double");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == INT2OID) {
				appendStringInfo(create_sql, " smallint");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == INT4OID) {
				appendStringInfo(create_sql, " int");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == INT8OID) {
				appendStringInfo(create_sql, " bigint");
			}
			if(node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[i]->atttypid == BITOID) {
				appendStringInfo(create_sql, " bit");
			}
		}
		appendStringInfo(create_sql, ")");
		spd_spi_ddl_table(create_sql->data);
	}
    for(;;)
	{
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
		if (fssThrdInfo[count - 1].tuple != NULL && fdw_private->agg_query)
		{
			/* if this child node finished, update finish flag */
			spd_spi_insert_table(fssThrdInfo[count - 1].tuple);
		}
		else if(fssThrdInfo[count - 1].tuple == NULL && fdw_private->agg_query) {
			/* if this child node finished, update finish flag */
			if(fin_flag[count-1] == 0) {
				fin_count++;
				fin_flag[count-1]=1;
			}
		}
		tempSlot = fssThrdInfo[count - 1].tuple;
		fssThrdInfo[count - 1].tuple = NULL;
        /* Intermediate results for aggregation query requested */
		if (getAggResultFlag && fin_count == nThreads || getResultFlag )
		{
			/*
			 * Aggregation Query Cancellation : Return existing intermediate
			 * result
			 */
			break;
		}
		count++;
		if (count >= nThreads)
		{
			/* if NOT agg query */
			if(!fdw_private->agg_query){
				break;
			}
			count = 0;
		}
	}
	slot = node->ss.ss_ScanTupleSlot;
	if (fdw_private->agg_query)
	{
		spd_combine_agg_new(agginfodata, nThreads, tempSlot->tts_tupleDescriptor->natts);
		slot = spd_get_agg_tuple(agginfodata, slot);
	}
	else
	{
		ExecCopySlot(slot, tempSlot);
	}
	if(fdw_private->agg_query){
		resetStringInfo(create_sql);
		appendStringInfo(create_sql, "DROP TABLE __spd__temptable");
		spd_spi_ddl_table(create_sql->data);
	}
	pfree(agginfodata);
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
	int			nThreads;
	ListCell   *l;

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
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR && fssThrdInfo[node_incr].state != SPD_FS_STATE_END && fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH)
		{
			fssThrdInfo[node_incr].queryRescan = true;
		}
	}
	/* 10us sleep for thread switch */
	usleep(10);

	for (node_incr = 0; node_incr < nThreads; node_incr++)
	{
		if (fssThrdInfo[node_incr].state != SPD_FS_STATE_ERROR && fssThrdInfo[node_incr].state != SPD_FS_STATE_END && fssThrdInfo[node_incr].state != SPD_FS_STATE_FINISH)
		{
			while (fssThrdInfo[node_incr].queryRescan)
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
	int rtn;
	int			nThreads = 0;
	ForeignScanThreadInfo *fssThrdInfo;
	SpdFdwPrivate *fdw_private;
	ListCell   *l;

	if (!node->ss.ps.state->agg_query)
	{
		fssThrdInfo = node->spd_fsstate;
		fdw_private = (SpdFdwPrivate *) fssThrdInfo->private;
		foreach(l, fdw_private->child_table_alive)
		{
			if (l->data.int_value == TRUE)
				nThreads += 1;
		}
		if (!fssThrdInfo)
		{
			return;
		}
		elog(DEBUG1, "EndForeignScan");
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			fssThrdInfo[node_incr].EndFlag = true;
		}

		/* wait until all the remote connections get closed. */
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			/* Cleanup the thread-local structures */
			rtn = pthread_join(fdw_private->foreign_scan_threads[node_incr], NULL);
			if(rtn != 0)
				elog(WARNING,"error is occurred, pthread_join fail in EndForeignScan. ");
			ExecDropSingleTupleTableSlot(fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot);
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
	Datum		oid_server;

	elog(DEBUG1, "entering function %s", __func__);

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();
	/* Checking UNDER clause. */
	if (target_rte->url != NULL)
	{
		elog(DEBUG1, "URL is %s", target_rte->url);
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
			fdw_private->under_flag = 1;

			/*
			 * if child - child is exist, then create child - child UNDER
			 * phrase
			 */
			if (target_url != NULL)
			{
				char		temp[QUERY_LENGTH];

				sprintf(temp, "/%s/", target_url);
				elog(DEBUG1, "temp new under url = %s", temp);
				new_underurl = palloc(sizeof(char) * (QUERY_LENGTH));
				strcpy(new_underurl, throwing_url);
				elog(DEBUG1, "new under url = %s", new_underurl);
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
		ereport(DEBUG1, (errmsg("%d ", (int) oid[0])));
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
	Datum		oid_server;
	List	   *child_list;

	elog(DEBUG1, "entering function %s", __func__);

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);
	fdw_private = spd_AllocatePrivate();

	if (rte->url != NULL)
	{
		elog(DEBUG1, "URL is %s", rte->url);
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
				elog(DEBUG1, "temp new under url = %s", temp);
				new_underurl = palloc(sizeof(char) * (QUERY_LENGTH));
				strcpy(new_underurl, throwing_url);
				elog(DEBUG1, "new under url = %s", new_underurl);
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
		ereport(DEBUG1, (errmsg("%d", (int) oid[0])));
	}
	tempoid = oid_server;
	ereport(DEBUG1, (errmsg("%s ", RelationGetRelationName(rel))));
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

	elog(DEBUG1, "entering function %s", __func__);
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

	elog(DEBUG1, "entering function %s", __func__);

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

	elog(DEBUG1, "entering function %s", __func__);
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

	elog(DEBUG1, "entering function %s", __func__);
	fdwroutine = GetFdwRoutineByServerId(oid_server);
	return fdwroutine->ExecForeignDelete(estate, resultRelInfo, slot, planSlot);

}

static void
spd_EndForeignModify(EState *estate,
					 ResultRelInfo *resultRelInfo)
{
	Oid			oid_server = tempoid;
	FdwRoutine *fdwroutine;

	elog(DEBUG1, "entering function %s", __func__);
	fdwroutine = GetFdwRoutineByServerId(oid_server);
	fdwroutine->EndForeignModify(estate, resultRelInfo);
}
