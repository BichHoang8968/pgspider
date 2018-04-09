/*-------------------------------------------------------------------------
 *
 * contrib/ddsf_fdw/ddsf_fdw.c
 *
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

#include "executor/tuptable.h"
#include "executor/execdesc.h"
#include "executor/executor.h"
#include "foreign/fdwapi.h"
#include "catalog/pg_type.h"
#include "miscadmin.h"
#include "nodes/execnodes.h"
#include "parser/parsetree.h"
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
#include "utils/palloc.h"
#include "foreign/foreign.h"
#include "utils/builtins.h"
#include <pthread.h>
#include "utils/rel.h"
#include "utils/elog.h"
#include "utils/selfuncs.h"
#include "libpq-fe.h"
#include "utils/memutils.h"
#include "ddsf_fdw_defs.h"
#include "ddsf_fdw_aggregate.h"
#include <sys/time.h>
#include "utils/resowner.h"
#include <unistd.h>
#include "../postgres_fdw/postgres_fdw.h"


#define DDSF_FRGN_SCAN_ENABLED 
#define BUFFERSIZE			1024
#define QUERY_LENGTH 512
#define DEFAULT_FDW_SORT_MULTIPLIER 1.2
#define ENABLE_MERGE_RESULT


/* local function forward declarations */
static void ddsf_GetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel,
					   Oid foreigntableid);
static void ddsf_GetForeignPaths(PlannerInfo *root, RelOptInfo *baserel,
					 Oid foreigntableid);
#if (PG_VERSION_NUM >= 90300 && PG_VERSION_NUM < 90500)
static ForeignScan *ddsf_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel,
					Oid foreigntableid, ForeignPath *best_path,
					List *tlist, List *scan_clauses);
#else
static ForeignScan *ddsf_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel,
					Oid foreigntableid, ForeignPath *best_path,
					List *tlist, List *scan_clauses,
					Plan *outer_plan);
#endif
static void ddsf_BeginForeignScan(ForeignScanState *node, int eflags, Oid srvID);
static TupleTableSlot * ddsf_IterateForeignScan(ForeignScanState *node);
static void ddsf_ReScanForeignScan(ForeignScanState *node);
static void ddsf_EndForeignScan(ForeignScanState *node);
static Datum ddsf_ForeignAgg(AggState *aggnode, void *state);
static void ddsf_GetForeignUpperPaths(PlannerInfo *root,
							 UpperRelationKind stage,
							 RelOptInfo *input_rel,
							 RelOptInfo *output_rel);
/*
 * Helper functions
 */
static void estimate_path_cost_size(PlannerInfo *root,
						RelOptInfo *baserel,
						List *join_conds,
						List *pathkeys,
						double *p_rows, int *p_width,
						Cost *p_startup_cost, Cost *p_total_cost);
static void get_remote_estimate(const char *sql,
					PGconn *conn,
					double *rows,
					int *width,
					Cost *startup_cost,
					Cost *total_cost);
static bool foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel);
static void add_foreign_grouping_paths(PlannerInfo *root,
						   RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel);


/* TODO Grobal value into fdw_private  */
typedef struct DdsfFdwPrivate{
	int thrdsCreated;
	int node_num;
	int under_flag;
	List *base_rel_list;	
	List *dummy_root_list;
	List *dummy_plan_list;
	List *dummy_list_enable;
	List *dummy_output_rel_list; 
	List *list_parse;
	List *ft_oid_list;
	pthread_t 	foreign_scan_threads[NODES_MAX];
	ResourceOwner thread_resource_owner;
	PgFdwRelationInfo rinfo;
	char *base_relation_name;	
	List *pPseudoAggPushList;
	List *pPseudoAggList;
	List *pPseudoAggTypeList;
	List *tList;
	bool agg_query;
	Agg *pAgg;
}DdsfFdwPrivate;

static void merge_fdw_options(DdsfFdwPrivate *fpinfo,
				  const DdsfFdwPrivate *fpinfo_o,
				  const DdsfFdwPrivate *fpinfo_i);

pthread_mutex_t scan_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;




static bool is_foreign_expr2(PlannerInfo *root, RelOptInfo *baserel, Expr *expr){
	/* @todo check expression can be executed in remote datasource side */
	return true;
}
#define is_foreign_expr is_foreign_expr2

DdsfFdwPrivate *ddsf_AllocatePrivate(){
	// Take from TopTransactionContext
	DdsfFdwPrivate *p = (DdsfFdwPrivate*)
		MemoryContextAlloc(
			TopTransactionContext,
			sizeof(*p));
	memset(p, 0, sizeof(*p));
	p->thread_resource_owner = ResourceOwnerCreate(
		NULL, "DDS fdw resource owner"
	);
	return p;
}

void ddsf_ReleasePrivate(DdsfFdwPrivate *p){
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_BEFORE_LOCKS, false, false);
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_LOCKS, false, false);
	ResourceOwnerRelease(p->thread_resource_owner,
						 RESOURCE_RELEASE_AFTER_LOCKS, false, false);
}


/* declarations for dynamic loading */
PG_FUNCTION_INFO_V1(ddsf_fdw_handler);

/*
 * ddsf_fdw_handler populates an FdwRoutine with pointers to the functions
 * implemented within this file.
 */
Datum
ddsf_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *fdwroutine = makeNode(FdwRoutine);

	fdwroutine->GetForeignRelSize = ddsf_GetForeignRelSize;
	fdwroutine->GetForeignPaths = ddsf_GetForeignPaths;
	fdwroutine->GetForeignPlan = ddsf_GetForeignPlan;
	fdwroutine->BeginForeignScan = ddsf_BeginForeignScan;
	fdwroutine->IterateForeignScan = ddsf_IterateForeignScan;
	fdwroutine->ForeignAgg = ddsf_ForeignAgg;
	fdwroutine->ReScanForeignScan = ddsf_ReScanForeignScan;
	fdwroutine->EndForeignScan = ddsf_EndForeignScan;
	fdwroutine->GetForeignUpperPaths = ddsf_GetForeignUpperPaths;

	PG_RETURN_POINTER(fdwroutine);
}

/**
 * Get chiled nodes oid and nums using parent node oid.
 *
 * @param[in] foreigntableid 
 * @param[out] nums 
 * @param[out] oid 
 */
static void 
ddsf_spi_exec(Oid foreigntableid,int *nums,Datum *oid){
	char query[QUERY_LENGTH];
	int ret;
	int i;

	if ((ret = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", ret);

	sprintf(query,"select oid,relname from pg_class where relname like (select relname from pg_class where oid = %d)||'\\_\\_%%' order by relname;",foreigntableid);
	elog(DEBUG1,"execute spi exec %s ",query);

	ret = SPI_execute(query, true, 0);
	if(ret != SPI_OK_SELECT)
		elog(ERROR,"spi exec is failed. sql is %s ",query);

	for (i = 0; i < SPI_processed; i++)
	{
		bool		isnull;
	    oid[i] = SPI_getbinval(SPI_tuptable->vals[i],SPI_tuptable->tupdesc,1,&isnull);
		elog(DEBUG1,"ddsf chiled foreign tabe oid = %d",(int)oid[i]);
	}
	SPI_finish();
	*nums = i;
}

/**
 * Get parent node oid using child node oid.
 *
 * @param[in] Child node's foreigntableid 
 *
 * @return Parent node's foreigntableid
 */

static Datum
ddsf_spi_exec_datasource_oid(Datum foreigntableid){
	char query[QUERY_LENGTH];
	int i;
    bool isnull;
    Datum oid;

    /* get relation name */

	sprintf(query,"select oid,srvname from pg_foreign_server where srvname=(select foreign_server_name from information_schema._pg_foreign_tables where foreign_table_name = (select relname from pg_class where oid = %d)) order by srvname;",(int)foreigntableid);
	elog(DEBUG1,"%s: execute sql = %s\n",__FUNCTION__, query);

	if ((i = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", i);
	i = SPI_execute(query, true, 0);
	if(i != SPI_OK_SELECT)
		elog(ERROR,"error SPIexecute filure -returned - %d\n", i);

	oid = SPI_getbinval(SPI_tuptable->vals[0],SPI_tuptable->tupdesc,1, &isnull);
	elog(DEBUG1,"ddsf child datasource oid = %d",(int)oid);

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
ddsf_spi_exec_datasource_name(Datum foreigntableid, char *srvname){
	char query[QUERY_LENGTH];
	char *temp;
	
	int i;

    /* get relation name */
	if ((i = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", i);

	sprintf(query,"select foreign_server_name from information_schema._pg_foreign_tables where foreign_table_name = (select relname from pg_class where oid = %d) order by foreign_server_name;",(int)foreigntableid);

	elog(DEBUG1,"%s: execute sql = %s",__FUNCTION__, query);

	i = SPI_execute(query, true, 0);
	if(i != SPI_OK_SELECT)
		elog(DEBUG1,"error %d\n", i);

	temp = SPI_getvalue(SPI_tuptable->vals[0],SPI_tuptable->tupdesc, 1);

	strcpy(srvname,temp);
	elog(DEBUG1,"ddsf child datasource srvname = %s", srvname);

	SPI_finish();
	return ;
}

static void
ddsf_ErrorCb(void *arg){
	pthread_mutex_lock(&error_mutex);
	errcontext("DDSF error");
	EmitErrorReport();
	pthread_mutex_unlock(&error_mutex);
}

/*
 * ddsf_ForeignScan_thread it does the following operations for each thread. 
 * BeginForeignScan 
 * IterateForeignScan
 * EndForeignScan
 */

static void *
ddsf_ForeignScan_thread(void *arg)
{
	ForeignScanThreadInfo *fssthrdInfo = (ForeignScanThreadInfo*)arg;
    MemoryContext oldcontext = MemoryContextSwitchTo(
		fssthrdInfo->threadMemoryContext);
	PGcancel   *cancel;
	char            errbuf[256];
	int                     res = 0;
	int lock_taken = 0;
	int errflag = 0;
#ifdef MEASURE_TIME
    struct timeval s, e, e1;
#endif
	ErrorContextCallback errcallback;
	DdsfFdwPrivate *fdw_private = fssthrdInfo->private;

	CurrentResourceOwner = fdw_private->thread_resource_owner;
	
	fssthrdInfo->me = pthread_self();
#ifdef MEASURE_TIME
	gettimeofday(&s, NULL);
#endif
	/* Declare ereport/elog jump is not available. */
	PG_exception_stack = NULL;
	errcallback.callback = ddsf_ErrorCb;
	errcallback.arg = NULL;
	errcallback.previous = NULL;
	error_context_stack = &errcallback;

	AggState *aggState = NULL;

	/* Begin Foreign Scan */
	fssthrdInfo->state = DDSF_FS_STATE_BEGIN;
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
		elog(DEBUG1,"thread%d begin foreign scan time = %lf\n",fssthrdInfo->serverId ,(e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec)*1.0E-6);
#endif
	}
	PG_CATCH();
	{
		errflag = 1;
		fssthrdInfo->state = DDSF_FS_STATE_ERROR;
		if(lock_taken){
			pthread_mutex_unlock(&scan_mutex);
			pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
		}
		elog(DEBUG1, "Thread error occurred during BeginForeignScan(). %s:%d\n",
				__FILE__, __LINE__);
	}
	PG_END_TRY();

	if(errflag){
		goto THREAD_EXIT;
	}

RESCAN:
	/*
	 *  Do rescan after return ..
	 *  If Rescan is queried before iteration, just continue operation
     */
	if(fssthrdInfo->queryRescan &&
	   fssthrdInfo->state != DDSF_FS_STATE_BEGIN){
		elog(DEBUG1, "Rescan is queried\n");
		pthread_mutex_lock(&scan_mutex);
		lock_taken = 1;
		fssthrdInfo->fdwroutine->ReScanForeignScan(fssthrdInfo->fsstate);
		pthread_mutex_unlock(&scan_mutex);
		lock_taken = 0;
		fssthrdInfo->iFlag = true;
		fssthrdInfo->tuple = NULL;
		fssthrdInfo->queryRescan = false;
	}
	fssthrdInfo->state = DDSF_FS_STATE_ITERATE;

	if(list_member_oid(fdw_private->pPseudoAggList,fssthrdInfo->serverId))
	{

		aggState = SPI_execIntiAgg(
			fdw_private->pAgg,
			fssthrdInfo->fsstate->ss.ps.state, 0);

	}

	PG_TRY();
	{
		while (1)
		{
			/* when get result request recieved */
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
				if(list_member_oid(fdw_private->pPseudoAggList,
								   fssthrdInfo->serverId))
				{
				    /* Retreives aggregated value tuple from underlying FILE source */
					slot = SPI_execRetreiveDirect(aggState);
				}
				else
				{
					slot = fssthrdInfo->fdwroutine->IterateForeignScan(
						fssthrdInfo->fsstate);
				}
				pthread_mutex_unlock(&fssthrdInfo->nodeMutex);

				if(slot == NULL){
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

					cancel = PQgetCancel(fssthrdInfo->fsstate->conn);
					res = PQcancel(cancel, errbuf, 256);
					PQfreeCancel(cancel);	
					break;
				}
				fssthrdInfo->tuple = slot;
			}
			else
			{
				usleep(1);
			}
			// If Rescan is queried here, do rescan after break
			if(fssthrdInfo->queryRescan || fssthrdInfo->EndFlag){
				break;
			}
		}
	}
	PG_CATCH();
	{
		fssthrdInfo->state = DDSF_FS_STATE_ERROR;
		errflag = 1;
		fssthrdInfo->state = DDSF_FS_STATE_ERROR;
		if(lock_taken){
			pthread_mutex_unlock(&scan_mutex);
		}
		fssthrdInfo->iFlag = false;
		fssthrdInfo->tuple = NULL;
		pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
		if(fssthrdInfo->fsstate->conn){
			cancel = PQgetCancel(fssthrdInfo->fsstate->conn);
			res = PQcancel(cancel, errbuf, 256);
			PQfreeCancel(cancel);
		}
		elog(DEBUG1, "Thread error occurred during IterateForeignScan(). %s:%d\n",
				__FILE__, __LINE__);
	}
	PG_END_TRY();
	if(errflag){
		goto THREAD_EXIT;
	}
	if(fssthrdInfo->queryRescan){
		Assert(!fssthrdInfo->EndFlag);
		goto RESCAN;
	}
#ifdef MEASURE_TIME
	gettimeofday(&e1, NULL);
	elog(DEBUG1,"thread%d end ite time = %lf\n",fssthrdInfo->serverId ,(e1.tv_sec - e.tv_sec) + (e1.tv_usec - e.tv_usec)*1.0E-6);
#endif
	/* End of the ForeignScan */
	fssthrdInfo->state = DDSF_FS_STATE_END;
	PG_TRY();
	{
		while (1)
        {
			if (fssthrdInfo->EndFlag || errflag )
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
				// If Rescan is queried here, do rescan after break
				if(fssthrdInfo->queryRescan){
					break;
				}
			}
        }
	}
	PG_CATCH();
	{
		elog(DEBUG1, "Thread error occurred during EndForeignScan(). %s:%d\n",
				__FILE__, __LINE__);
		pthread_mutex_unlock(&scan_mutex);
	}
	PG_END_TRY();

	if(fssthrdInfo->queryRescan){
		Assert(!fssthrdInfo->EndFlag);
		goto RESCAN;
	}
	fssthrdInfo->state = DDSF_FS_STATE_FINISH;
THREAD_EXIT:
	fssthrdInfo->iFlag = false;
	fssthrdInfo->tuple = NULL;
	pthread_mutex_unlock(&fssthrdInfo->nodeMutex);
#ifdef MEASURE_TIME
	gettimeofday(&e, NULL);
	elog(DEBUG1,"thread%d all time = %lf\n",fssthrdInfo->serverId ,(e.tv_sec - s.tv_sec) + (e.tv_usec - s.tv_usec)*1.0E-6);
#endif
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
 * @param[in] url_str - url
 * @param[out] fdw_private - store to parsing url
 */
/*  */
static void
ddsf_ParseUrl(char *url_str, DdsfFdwPrivate *fdw_private){
	char *tp;
	char *url_option = palloc(sizeof(char)*strlen(url_str));
	char *next = NULL;
	
	strcpy(url_option,url_str);

	if (url_option == NULL )
		return;
#if 1
	tp = strtok_r(url_option,"/", &next);
	elog(DEBUG1,"fist parse = %s\n",tp);
	if(tp == NULL )
		return;
	else{
#endif
		char *entry_parse1 = NULL;
		char *entry_parse2 = NULL;
		int p = strlen(url_option);
	    fdw_private->list_parse = lappend(fdw_private->list_parse, tp);
		if(p+1 != strlen(url_str)){
			entry_parse2 = palloc(sizeof(char) * strlen(url_str)+1);
			elog(DEBUG1,"entry parse3 length = %d\n",(int)strlen(url_str));
			strcpy(entry_parse2, &url_str[p]);
			entry_parse1 = strtok_r(NULL,"/", &next);
			elog(DEBUG1,"e1 = %s,e2 = %s, e3 = %s \n",tp, entry_parse1, entry_parse2);
			fdw_private->list_parse = lappend(fdw_private->list_parse, entry_parse1);
			fdw_private->list_parse = lappend(fdw_private->list_parse, entry_parse2);
		}
	}
}

/*
 * ddsf_GetForeignRelSize populates baserel with a ddsf relation size.
 * This function called at first using fdw.
 */

static void
ddsf_GetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
#ifndef DDSF_FRGN_SCAN_ENABLED
	baserel->rows = 0;
	baserel->fdw_private = (void *) palloc0(1);
#else
	RelOptInfo	   *entry_baserel;
	MemoryContext oldcontext;
	DdsfFdwPrivate *fdw_private;
	FdwRoutine *fdwroutine;
	Datum		*oid;
	Datum		oid_server;
	int nums;
	ListCell   *l;
	char *new_underurl = NULL;
	RangeTblEntry* r_entry;

	baserel->rows = 0;
	fdw_private = ddsf_AllocatePrivate();
	fdw_private->base_relation_name = get_rel_name(foreigntableid);
	fdw_private->rinfo.pushdown_safe = true;
	baserel->fdw_private = (void*)fdw_private;
	
    /* TODO:Memory context is changed in ddsf_BeginForeignScan.
	 * Set to TopTransaction when shared dummy List update.
	 * Reserch to who is switch to context.
	 */
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	oid = (Datum *)palloc (sizeof(Datum) * 256);

    /* get child datasouce oid and nums*/
	ddsf_spi_exec(foreigntableid, &nums, oid);
	if(nums == 0){
	  ereport(ERROR, (errmsg("Cannot Find child datasources. \n")));
    }

	for(int i=0;i<nums;i++){
		fdw_private->ft_oid_list = lappend_int(fdw_private->ft_oid_list,
											   oid[i]);
		elog(DEBUG1,"append \n");
	}

   /* Check to UNDER phrase and execute only UNDER URL server */
	Assert(baserel->reloptkind == RELOPT_BASEREL);

    r_entry = root->simple_rte_array[baserel->relid];
	Assert(r_entry != NULL);
	if(r_entry->url != NULL){
		ddsf_ParseUrl(r_entry->url, fdw_private);
		if(fdw_private->list_parse == NIL ||
		   fdw_private->list_parse->length < 1){
			/* DO NOTHING */
			elog(DEBUG1, "NO URL is detected");
		}else{
			char *srvname = palloc(sizeof(char)*(512));
			/* entry is first parsing word(/foo/bar/, then entry is "foo",entry2 is "bar") */

			char *entry = (char *) list_nth(fdw_private->list_parse, 0);
			char *entry2 = NULL;
			char *entry3 = NULL;
			int num = nums;
			int d_count=0;
			if(fdw_private->list_parse->length >2){
				entry2 = (char *) list_nth(fdw_private->list_parse, 1);
				entry3 = (char *) list_nth(fdw_private->list_parse, 2);
			}
			/* If UNDER phrase is used, then store to parsing url */
			for(int i = 0; i < num; i++){
				Datum temp_oid = list_nth_oid(fdw_private->ft_oid_list,
											  i-d_count);
				ddsf_spi_exec_datasource_name(temp_oid, srvname);
				elog(DEBUG1,"srv_name = %s, entry1 = %s\n",srvname,entry);
				if(entry == NULL){
					break;
				}
				else{
					/* If UNDER clause is used, then store to parsing url */
					if(strcmp(entry, srvname) != 0){
						nums = nums - 1;
						elog(DEBUG1,"delete \n");
						list_delete_int(fdw_private->ft_oid_list,temp_oid);
						d_count++;
					}
					else{
						fdw_private->under_flag=1;
						/* if child - child is exist, then create child - child UNDER phrase*/
						if(entry2 !=NULL){
							char temp[QUERY_LENGTH];
							sprintf(temp,"/%s/",entry2);
							elog(DEBUG1,"temp new under url = %s\n",temp);
							new_underurl = palloc(sizeof(char)*(QUERY_LENGTH));
							strcpy(new_underurl,entry3);
							elog(DEBUG1,"new under url = %s\n",new_underurl);
						}
						else{
						}
					}
				}
			}
			pfree(srvname);
		}
	}

/*
 * TODO: Creating dummy root function move to new another function 
 * Research to dummy root execute
 * This routine create dummy base_rel list.
 */
	if(fdw_private->base_rel_list == NIL){
		for(int i = 0; i < nums;i++){
			Oid rel_oid = list_nth_oid(fdw_private->ft_oid_list,i);
			if(rel_oid != 0){
				PlannerInfo *dummy_root;
				oid_server = ddsf_spi_exec_datasource_oid(rel_oid);
				fdwroutine = GetFdwRoutineByServerId(oid_server);
				{
					Query	   *query;
					PlannerGlobal *glob;
					RangeTblEntry *rte;
					int k;
					/* Set up mostly-dummy planner state */
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
					if(new_underurl != NULL){
						rte->url = palloc(sizeof(char)*strlen(new_underurl));
						strcpy(rte->url,new_underurl);
						elog(DEBUG1,"rte->url = %s\n",new_underurl);
					}
					query->rtable = list_make1(rte);
					for(k=1; k<baserel->relid; k++){
						query->rtable = lappend(query->rtable, rte);
					}
					/* Set up RTE/RelOptInfo arrays */
					setup_simple_rel_arrays(dummy_root);
					/* Build RelOptInfo */
					entry_baserel = build_simple_rel(dummy_root, baserel->relid, RELOPT_BASEREL);
					entry_baserel->reltarget->exprs = copyObject(baserel->reltarget->exprs);
					entry_baserel->baserestrictinfo = copyObject(baserel->baserestrictinfo);
				}
				PG_TRY();{
					pthread_mutex_lock(&scan_mutex);
					fdwroutine->GetForeignRelSize(dummy_root, entry_baserel, DatumGetObjectId(rel_oid));
					pthread_mutex_unlock(&scan_mutex);
					elog(DEBUG1,"base add");
					fdw_private->base_rel_list = lappend( fdw_private->base_rel_list, entry_baserel);
					fdw_private->dummy_root_list = lappend( fdw_private->dummy_root_list, dummy_root);
					fdw_private->dummy_list_enable = lappend_int( fdw_private->dummy_list_enable, TRUE);
				}
				PG_CATCH();
				{
					pthread_mutex_unlock(&scan_mutex);
					fdw_private->dummy_list_enable = lappend_int( fdw_private->dummy_list_enable,FALSE);
					elog(DEBUG1,"base NOT add");
				}
				PG_END_TRY();
				}
		}
		if(fdw_private->base_rel_list == NIL &&
		   r_entry->url != NULL &&
		   strcmp(r_entry->url, "/") != 0){
			ereport(ERROR, (errmsg("Cannot find the URL")));
		}

	} else {
		int i=0;
		foreach(l,fdw_private->base_rel_list){
			Oid rel_oid = list_nth_oid(fdw_private->ft_oid_list,i);
			RelOptInfo *entry = (RelOptInfo *) lfirst(l);
			oid_server = ddsf_spi_exec_datasource_oid(rel_oid);
			//pthread_mutex_lock(&scan_mutex);
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			fdwroutine->GetForeignRelSize(root, entry,  DatumGetObjectId(rel_oid));
			//pthread_mutex_unlock(&scan_mutex);
			elog(DEBUG1,"base add\n");
			i++;
		}
	}
	MemoryContextSwitchTo(oldcontext);
	if(fdw_private->base_rel_list == NIL){
		elog(DEBUG1,"Can not connect to child node");
	}


	/*
	 * Set the name of relation in fpinfo, while we are constructing it here.
	 * It will be used to build the string describing the join relation in
	 * EXPLAIN output. We can't know whether VERBOSE option is specified or
	 * not, so always schema-qualify the foreign table name.
	 */
	char *namespace = NULL;
	char *relname = NULL;
	char *refname = NULL;
	RangeTblEntry *rte = planner_rt_fetch(baserel->relid, root);
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
#endif
}

/*
 * ddsf_GetForeignUpperPaths
 *		Add paths for post-join operations like aggregation, grouping etc. if
 *		corresponding operations are safe to push down.
 *
 * Right now, we only support aggregate, grouping and having clause pushdown.
 */

static void
ddsf_GetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							 RelOptInfo *input_rel, RelOptInfo *output_rel)
{
	DdsfFdwPrivate *fdw_private, *in_fdw_private;
	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((DdsfFdwPrivate *) input_rel->fdw_private)->rinfo.pushdown_safe)
		return;
	in_fdw_private = (DdsfFdwPrivate *)input_rel->fdw_private;
	
	/* Ignore stages we don't support; and skip any duplicate calls. */
	if (stage != UPPERREL_GROUP_AGG || output_rel->fdw_private)
		return;

	/* Prepare DdsfFdwPrivate for output RelOptInfo */
	fdw_private = ddsf_AllocatePrivate();
	fdw_private->base_relation_name = pstrdup(in_fdw_private->base_relation_name);
	fdw_private->thrdsCreated = in_fdw_private->thrdsCreated;
	fdw_private->node_num = in_fdw_private->node_num;
	fdw_private->under_flag = in_fdw_private->under_flag;
	fdw_private->dummy_root_list = list_copy(in_fdw_private->dummy_root_list);
	fdw_private->dummy_plan_list = list_copy(in_fdw_private->dummy_plan_list);
	fdw_private->dummy_list_enable = list_copy(in_fdw_private->dummy_list_enable);
	fdw_private->list_parse = list_copy(in_fdw_private->list_parse);
	fdw_private->ft_oid_list = list_copy(in_fdw_private->ft_oid_list);
	fdw_private->pPseudoAggPushList = NIL;
	fdw_private->pPseudoAggList = NIL;
	fdw_private->pPseudoAggTypeList = NIL;
	fdw_private->agg_query = true;
	
	/* Call the below FDW's GetForeignUpperPaths */
	if(in_fdw_private->base_rel_list != NIL){
		ListCell *l;
		Datum	oid_server;
		FdwRoutine *fdwroutine;
		int i=0;
		
		foreach(l,in_fdw_private->base_rel_list){
			List *newList=NIL;
			Oid rel_oid = list_nth_oid(fdw_private->ft_oid_list,i);
			RelOptInfo *entry = (RelOptInfo *) lfirst(l);
			PlannerInfo *dummy_root =
				(PlannerInfo*)list_nth(fdw_private->dummy_root_list, i);
			oid_server = ddsf_spi_exec_datasource_oid(rel_oid);
			//pthread_mutex_lock(&scan_mutex);
			fdwroutine = GetFdwRoutineByServerId(oid_server);
			if(fdwroutine->GetForeignUpperPaths){
				/* Currently dummy. @todo more better parsed object. */
				dummy_root->parse->hasAggs = true;
				
				/* Call below FDW to check it is OK to pushdown or not. */
				/* refer relnode.c fetch_upper_rel() */
				RelOptInfo *dummy_output_rel;
				PathTarget *grouping_target;
				ListCell *lc;
				dummy_output_rel = makeNode(RelOptInfo);
				dummy_output_rel->reloptkind = RELOPT_UPPER_REL;
				dummy_output_rel->relids = bms_copy(entry->relids);
				dummy_output_rel->reltarget = create_empty_pathtarget();
				dummy_root->upper_rels[UPPERREL_GROUP_AGG] =
					lappend(dummy_root->upper_rels[UPPERREL_GROUP_AGG],
							dummy_output_rel);
				/* @todo make correct pathtarget */
				dummy_root->upper_targets[UPPERREL_GROUP_AGG]=
					copy_pathtarget(root->upper_targets[UPPERREL_GROUP_AGG]);
				dummy_root->upper_targets[UPPERREL_WINDOW]=
					copy_pathtarget(root->upper_targets[UPPERREL_WINDOW]);
				dummy_root->upper_targets[UPPERREL_FINAL]=
					copy_pathtarget(root->upper_targets[UPPERREL_FINAL]);
                /* @todo make correct targetlist */
				grouping_target = root->upper_targets[UPPERREL_GROUP_AGG];
				int listn=0;
				foreach(lc, grouping_target->exprs)
				{
					Expr	   *expr = (Expr *) lfirst(lc);
					Index		sgref = get_pathtarget_sortgroupref(grouping_target, i);
					ListCell   *l;
					Aggref *aggref;
					aggref = (Aggref*)expr;
					Expr *hoge = list_nth(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, listn);
					listn++;
					if ((aggref->aggfnoid >= 2100 && aggref->aggfnoid <=2106 ) )
					{
						/*Prepare SUM Query */
						/* TODO: Appropriate aggfnoid should be choosen based on type */
						Aggref* tempSUM = copyObject(aggref);
						tempSUM->aggfnoid = 2108;
						tempSUM->aggtype = 20;
						tempSUM->aggtranstype= 20;

						/*Prepare Count Query */
						/* TODO: Appropriate aggfnoid should be choosen based on type */
						Aggref* temp = copyObject(tempSUM);
						temp->aggfnoid = 2803;
						temp->aggargtypes = NULL;
						elog(DEBUG1,"insert avg expr");
						newList = lappend(newList, tempSUM);
						newList = lappend(newList, temp);
					}
					else if((aggref->aggfnoid >= 2154 && aggref->aggfnoid <=2159) ||
							(aggref->aggfnoid >= 2148 && aggref->aggfnoid <=2153))
					{
						Aggref* tempSUM = copyObject(aggref);
						tempSUM->aggfnoid = 2108;
						tempSUM->aggtype = 20;
						tempSUM->aggtranstype= 20;

						/*Prepare Count Query */
						/* TODO: Appropriate aggfnoid should be choosen based on type */
						Aggref* temp = copyObject(tempSUM);
						temp->aggfnoid = 2803;
						temp->aggargtypes = NULL;

						Aggref* tempvar = copyObject(tempSUM);
						tempvar->aggfnoid = 2148;
						tempvar->aggargtypes = NULL;

						dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
							list_delete_first(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs);
						/* Add SUM Query to the Pushdown Plan */
						newList = lappend(newList, tempSUM);
						/* Add Count Query to the Pushdown Plan */
						newList = lappend(newList, temp);
					}
					else{
						dummy_root = copy_pathtarget(root->upper_targets[UPPERREL_WINDOW]);
						elog(DEBUG1,"insert orign expr");
						newList = lappend(newList, hoge);
					}
				}
				
				foreach(lc,dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs){
					dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
						list_delete_first(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs);
				}
				foreach(lc,newList){
					Expr	   *expr = (Expr *) lfirst(lc);
					elog(DEBUG1,"insert expr");
					dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs =
						lappend(dummy_root->upper_targets[UPPERREL_GROUP_AGG]->exprs, expr);
				}

				fdwroutine->GetForeignUpperPaths(
					dummy_root,
					stage, entry, dummy_output_rel);
				fdw_private->base_rel_list =
					lappend(fdw_private->base_rel_list,
							dummy_output_rel);
				fdw_private->pPseudoAggPushList = lappend_oid(fdw_private->pPseudoAggPushList, oid_server);
			}else{
                /*
				fdwroutine->GetForeignPaths(
					dummy_root, entry, rel_oid);
				*/
				fdw_private->base_rel_list =
					lappend(fdw_private->base_rel_list,
							entry);
 				fdw_private->pPseudoAggList = lappend_oid(fdw_private->pPseudoAggList, oid_server);
			}
			//pthread_mutex_unlock(&scan_mutex);
			elog(DEBUG1,"upperpath add\n");
			i++;
		}
	}
	fdw_private->rinfo.pushdown_safe = false;
	output_rel->fdw_private = fdw_private;
	output_rel->relid = input_rel->relid;
	
	add_foreign_grouping_paths(root, input_rel, output_rel);
}

/*
 * add_foreign_grouping_paths
 *		Add foreign path for grouping and/or aggregation.
 *
 * Given input_rel represents the underlying scan.  The paths are added to the
 * given grouped_rel.
 */
static void
add_foreign_grouping_paths(PlannerInfo *root, RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel)
{
	Query	   *parse = root->parse;
	DdsfFdwPrivate *ifpinfo = input_rel->fdw_private;
	DdsfFdwPrivate *fpinfo = grouped_rel->fdw_private;
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
	// merge_fdw_options(fpinfo, ifpinfo, NULL);

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

/*
 * Merge FDW options from input relations into a new set of options for a join
 * or an upper rel.
 *
 * For a join relation, FDW-specific information about the inner and outer
 * relations is provided using fpinfo_i and fpinfo_o.  For an upper relation,
 * fpinfo_o provides the information for the input relation; fpinfo_i is
 * expected to NULL.
 */
static void
merge_fdw_options(DdsfFdwPrivate *fpinfo,
				  const DdsfFdwPrivate *fpinfo_o,
				  const DdsfFdwPrivate *fpinfo_i)
{
	/* We must always have fpinfo_o. */
	Assert(fpinfo_o);

	/* fpinfo_i may be NULL, but if present the servers must both match. */
	Assert(!fpinfo_i ||
		   fpinfo_i->rinfo.server->serverid == fpinfo_o->rinfo.server->serverid);

	/*
	 * Copy the server specific FDW options.  (For a join, both relations come
	 * from the same server, so the server options should have the same value
	 * for both relations.)
	 */
	fpinfo->rinfo.fdw_startup_cost = fpinfo_o->rinfo.fdw_startup_cost;
	fpinfo->rinfo.fdw_tuple_cost = fpinfo_o->rinfo.fdw_tuple_cost;
	fpinfo->rinfo.shippable_extensions = fpinfo_o->rinfo.shippable_extensions;
	fpinfo->rinfo.use_remote_estimate = fpinfo_o->rinfo.use_remote_estimate;
	fpinfo->rinfo.fetch_size = fpinfo_o->rinfo.fetch_size;

	/* Merge the table level options from either side of the join. */
	if (fpinfo_i)
	{
		/*
		 * We'll prefer to use remote estimates for this join if any table
		 * from either side of the join is using remote estimates.  This is
		 * most likely going to be preferred since they're already willing to
		 * pay the price of a round trip to get the remote EXPLAIN.  In any
		 * case it's not entirely clear how we might otherwise handle this
		 * best.
		 */
		fpinfo->rinfo.use_remote_estimate = fpinfo_o->rinfo.use_remote_estimate ||
			fpinfo_i->rinfo.use_remote_estimate;

		/*
		 * Set fetch size to maximum of the joining sides, since we are
		 * expecting the rows returned by the join to be proportional to the
		 * relation sizes.
		 */
		fpinfo->rinfo.fetch_size = Max(fpinfo_o->rinfo.fetch_size,
									   fpinfo_i->rinfo.fetch_size);
	}
}

/*
 * Assess whether the aggregation, grouping and having operations can be pushed
 * down to the foreign server.  As a side effect, save information we obtain in
 * this function to DdsfFdwPrivate of the input relation.
 */
static bool
foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel)
{
	Query	   *query = root->parse;
	PathTarget *grouping_target;
	DdsfFdwPrivate *fpinfo = (DdsfFdwPrivate *) grouped_rel->fdw_private;
	DdsfFdwPrivate *ofpinfo;
	List	   *aggvars;
	ListCell   *lc;
	int			i;
	List	   *tlist = NIL;

	/* Grouping Sets are not pushable */
	if (query->groupingSets)
		return false;

	/* Get the fpinfo of the underlying scan relation. */
	ofpinfo = (DdsfFdwPrivate *) fpinfo->rinfo.outerrel->fdw_private;

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


/*
 * ddsf_GetForeignPaths adds a single ddsf foreign path to baserel.
 */
static void
ddsf_GetForeignPaths(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
#if 1
#ifdef DDSF_FRGN_SCAN_ENABLED

	MemoryContext oldcontext;
	FdwRoutine *fdwroutine;
	Datum		*oid;
	Datum	    server_oid;
	int nums;
	int i;
	DdsfFdwPrivate *fdw_private = (DdsfFdwPrivate*)baserel->fdw_private;
	Cost startup_cost;
	Cost total_cost;
	ListCell *lc;
	
	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	oid = (Datum *)palloc (sizeof(Datum) * 256);

	ddsf_spi_exec(foreigntableid, &nums,oid);

    /* Create Foreign paths using base_rel_list to each child node.*/
	for(i=0;i<fdw_private->base_rel_list->length;i++){
		elog(DEBUG1,"ddsf_GetForeignPaths %d",i);
		RelOptInfo *entry;
		if(list_nth_int(fdw_private->dummy_list_enable,i) != TRUE){
			continue;
		}
		server_oid = ddsf_spi_exec_datasource_oid(list_nth_oid(fdw_private->ft_oid_list,i));
		if(fdw_private->base_rel_list !=NULL){
			entry = (RelOptInfo *) list_nth(fdw_private->base_rel_list, i);
			if(entry == NULL){
				break;
			}
		}
		else{
			break;
		}
		
		PlannerInfo *dummy_root =(PlannerInfo*)list_nth(fdw_private->dummy_root_list, i);
		List *dummy_tlist2 = NIL;
		dummy_tlist2 = dummy_root->processed_tlist;
		foreach(lc,dummy_tlist2){
			lappend(dummy_root->processed_tlist,lc);
		}
		fdwroutine = GetFdwRoutineByServerId(server_oid);

		PG_TRY();{
			fdwroutine->GetForeignPaths(dummy_root, entry,  DatumGetObjectId(oid[i]));
		}
		PG_CATCH();
		{
			ListCell *l;
			l = list_nth_cell(fdw_private->dummy_root_list, i);
			l->data.int_value = FALSE;
			elog(DEBUG1,"fdw GetForeignPaths error is occurred\n");
		}
		PG_END_TRY();
	}
	MemoryContextSwitchTo(oldcontext);

#else
	Cost startup_cost = 0;
	Cost total_cost = startup_cost + baserel->rows;

#if (PG_VERSION_NUM >= 90300 && PG_VERSION_NUM < 90500)
	add_path(baserel, (Path *) create_foreignscan_path(root, baserel, baserel->rows,
											   startup_cost, total_cost, NIL,
													   NULL, NIL));
#else
	PlannerInfo *dummy_root =(PlannerInfo*)list_nth(root, i);
	List *dummy_tlist2 = NIL;
	dummy_tlist2 = root->processed_tlist;
	lfirst_node(dummy_tlist2,lc);
	lappend(dummy_root->processed_tlist,lc);
	add_path(baserel, (Path *) create_foreignscan_path(dummy_root, baserel, NULL, baserel->rows,
													   startup_cost, total_cost, NIL,
													   NULL, NULL, NIL));

#endif
#endif
#endif
#if 1
    startup_cost = 0;
	total_cost = startup_cost + baserel->rows;
	PlannerInfo *dummy_root = root;
	List *dummy_tlist2 = NIL;
	dummy_tlist2 = copyObject(root->processed_tlist);
	//lappend(dummy_root->processed_tlist,dummy_tlist2->head);
	add_path(baserel, (Path *) create_foreignscan_path(root, baserel, NULL, baserel->rows,
													   startup_cost, total_cost, NIL,
													   NULL, NULL, NIL));
#endif
}


/*
 * ddsf_GetForeignPlan builds a ddsf foreign plan.
 */
#if (PG_VERSION_NUM >= 90300 && PG_VERSION_NUM < 90500)
static ForeignScan *
ddsf_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid,
					ForeignPath *best_path, List *tlist, List *scan_clauses)
#else
static ForeignScan *
ddsf_GetForeignPlan(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid,
					ForeignPath *best_path, List *tlist, List *scan_clauses,
					Plan *outer_plan)
#endif
{

#if 1
#ifdef DDSF_FRGN_SCAN_ENABLED

	//FdwRoutine *fdwroutine[NODES_MAX];
	FdwRoutine *fdwroutine;
	int nums;
	int i;
	Datum		*oid;
	Datum		server_oid;
	MemoryContext oldcontext;
	DdsfFdwPrivate *fdw_private = (DdsfFdwPrivate*)baserel->fdw_private;
	Index scan_relid;
	List	   *fdw_scan_tlist = NIL; /* Need dummy tlist for pushdown case. */
	List	   *remote_exprs = NIL;
	List	   *local_exprs = NIL;

	oldcontext = MemoryContextSwitchTo(TopTransactionContext);

	oid = (Datum *)palloc (sizeof(Datum) * 256);
	ddsf_spi_exec(foreigntableid, &nums,oid);
	if(IS_UPPER_REL(baserel)){
		/**
		 * Possibly aggregation pushdown case, so need to make 
		 * dummy tlist for pushdown case 
		 */
		fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	}
	fdw_scan_tlist = fdw_private->rinfo.grouped_tlist;
	fdw_private->tList = list_copy(tlist);

    /* Create Foreign Plans using base_rel_list to each child. */
	for(i=0;i<fdw_private->base_rel_list->length;i++) {
		ForeignScan *temp_obj;
		RelOptInfo *entry;
		List *dummy_tlist = NIL;
		List *dummy_tlist2 = NIL;
		Var *varp = NULL;
		
		server_oid = ddsf_spi_exec_datasource_oid(list_nth_oid(fdw_private->ft_oid_list,i));
		if(fdw_private->base_rel_list !=NULL){
		    entry = (RelOptInfo *) list_nth(fdw_private->base_rel_list, i);
			if(entry == NULL){
				continue;
			}
			if(list_nth_int(fdw_private->dummy_list_enable,i) != TRUE){
				continue;
			}
		}
		else{
			break;
		}
		fdwroutine = GetFdwRoutineByServerId(server_oid);
		if(list_member_oid(fdw_private->pPseudoAggPushList,server_oid)) {
			/*
			 * Temporary create TargetEntry: 
			 * @todo make correct targetenrty, as if it is 
			 * the correct aggregation. (count, max, etc..)
			 */
			TargetEntry *tle;
			Var *var;
			Aggref *aggref;
			ListCell *lc;
			int att = 0;
			
			dummy_tlist2 = copyObject(tlist);
			foreach(lc, dummy_tlist2) {
				tle = lfirst_node(TargetEntry, lc);
				if(IsA(tle->expr, Aggref)){
					aggref = (Aggref*)tle->expr;
					if(aggref->args) {
						if((aggref->aggfnoid >= 2100 && aggref->aggfnoid <=2106) /*AVG Query */
						   ||  (aggref->aggfnoid >= 2718 && aggref->aggfnoid <=2729) /*VARIANCE,STDDEV HISTORICAL & POPULAR Query */
						   ||  (aggref->aggfnoid >= 2148 && aggref->aggfnoid <=2159) /*STDDEV, VARIANCE Historical & POPULAR Query */
							)
						{
							/*Prepare SUM Query */
							/* TODO: Appropriate aggfnoid should be choosen based on type */
							fdw_private->agg_query = true;
	
							TargetEntry *tle_var;
							tle_var =  lfirst_node(Var, aggref->args->head);
							var = (Var*)tle_var->expr;
							
							TargetEntry *tleTemp = copyObject(tle);
							Aggref* tempSUM = copyObject(aggref);
							tempSUM->aggtype = var->vartype;
							dummy_tlist2 = list_delete_first(dummy_tlist2);
							switch(tempSUM->aggtype)
							{
							case 20: /*int8 big int*/
								tempSUM->aggfnoid = 2107;
								break;							
							case 21: /*int2 small int*/
								tempSUM->aggfnoid = 2109;
								break;
							case 23: /*	int4 */
								tempSUM->aggfnoid = 2108;
								break;
							case 700: /*float 4 - real*/
								tempSUM->aggfnoid = 2110;
								break;
							case 701: /*float 8 - double precision*/
								tempSUM->aggfnoid = 2111;
								break;							
							case 1700: /*numeric*/
								tempSUM->aggfnoid = 2114;
								break;
							}
							tempSUM->aggtranstype= var->vartype;
							tleTemp->expr = copyObject(tempSUM);
							
							/*Prepare Count Query */
							TargetEntry *tempCount = copyObject(tleTemp);
							Aggref* temp = copyObject(tempSUM);
							temp->aggfnoid = 2803;
							temp->aggargtypes = NULL;
							temp->args = NULL;
							//temp->aggstar = 1;
							tempCount->expr = copyObject(temp);
							if(aggref->aggfnoid >= 2148 && aggref->aggfnoid <=2153 || 
							   aggref->aggfnoid >= 2718 && aggref->aggfnoid <=2723)
							{
								TargetEntry *tempVar = copyObject(tleTemp);
								Aggref* tempVariance = copyObject(aggref);
								tempVar->expr = copyObject(tempVariance);
								
								/* Add VARIANCE Query to the Pushdown Plan */							
								dummy_tlist2 = lappend(dummy_tlist2, tempVar);
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2154);
							}
							else if(aggref->aggfnoid >= 2154 && aggref->aggfnoid <=2159 ||
									aggref->aggfnoid >= 2724 && aggref->aggfnoid <=2729)
							{
								TargetEntry *tempVar = copyObject(tleTemp);
								Aggref* tempVariance = copyObject(aggref);
								tempVariance->aggfnoid -= 6;
								tempVar->expr = copyObject(tempVariance);
								/* Add STDDEV Query to the Pushdown Plan */							
								dummy_tlist2 = lappend(dummy_tlist2, tempVar);
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2154);
							}
							else{
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2100);
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
			}
			foreach(lc, dummy_tlist2){
				tle = lfirst_node(TargetEntry, lc);
				if(IsA(tle->expr, Aggref)){
					aggref = (Aggref*)tle->expr;
					if(aggref->args){
						tle = lfirst_node(Var, aggref->args->head);
						if(!list_member(dummy_tlist, tle)){
							TargetEntry *copy_tle = copyObject(tle);
							att++;
							copy_tle->resno = att;
							dummy_tlist = lappend(dummy_tlist, copy_tle);
						}
						/* Modify VAR of dummy_tlist2 for OUTER_VAR */
						var = (Var*)tle->expr;
						var->varno = OUTER_VAR;
						var->varattno = att;
					}
				}
				else if(IsA(tle->expr, Var))
				{
						if(!list_member(dummy_tlist, tle)){
							TargetEntry *copy_tle = copyObject(tle);
							att++;
							copy_tle->resno = att;
							dummy_tlist = lappend(dummy_tlist, copy_tle);
						}
						/* Modify VAR of dummy_tlist2 for OUTER_VAR */
						var = (Var*)tle->expr;
						var->varno = OUTER_VAR;
						var->varattno = att;
				}
			}
		}
		else if(list_member_oid(fdw_private->pPseudoAggList,server_oid)) {
			/*
			 * Temporary create TargetEntry: 
			 * @todo make correct targetenrty, as if it is 
			 * the correct aggregation. (count, max, etc..)
			 */
			TargetEntry *tle;
			Var *var;
			Aggref *aggref;
			ListCell *lc;
			int att = 0;
			
			dummy_tlist2 = copyObject(tlist);
			foreach(lc, dummy_tlist2) {
				tle = lfirst_node(TargetEntry, lc);
				if(IsA(tle->expr, Aggref)){
					aggref = (Aggref*)tle->expr;
					if(aggref->args) {
						if((aggref->aggfnoid >= 2100 && aggref->aggfnoid <=2106) /*AVG Query */
						   ||  (aggref->aggfnoid >= 2718 && aggref->aggfnoid <=2729) /*VARIANCE,STDDEV HISTORICAL & POPULAR Query */
						   ||  (aggref->aggfnoid >= 2148 && aggref->aggfnoid <=2159) /*STDDEV, VARIANCE Historical & POPULAR Query */
							)
						{
							/*Prepare SUM Query */
							/* TODO: Appropriate aggfnoid should be choosen based on type */
							fdw_private->agg_query = true;
	
							TargetEntry *tle_var;
							tle_var =  lfirst_node(Var, aggref->args->head);
							var = (Var*)tle_var->expr;
							
							TargetEntry *tleTemp = copyObject(tle);
							Aggref* tempSUM = copyObject(aggref);
							tempSUM->aggtype = var->vartype;
							dummy_tlist2 = list_delete_first(dummy_tlist2);
#if 0
							switch(tempSUM->aggtype)
							{
							case 20: /*int8 big int*/
								tempSUM->aggfnoid = 2107;
								break;							
							case 21: /*int2 small int*/
								tempSUM->aggfnoid = 2109;
								break;
							case 23: /*	int4 */
								tempSUM->aggfnoid = 2108;
								break;
							case 700: /*float 4 - real*/
								tempSUM->aggfnoid = 2110;
								break;
							case 701: /*float 8 - double precision*/
								tempSUM->aggfnoid = 2111;
								break;							
							case 1700: /*numeric*/
								tempSUM->aggfnoid = 2114;
								break;
							}
#endif
							tempSUM->aggfnoid = 2108;
							tempSUM->aggtranstype= var->vartype;
							tleTemp->expr = copyObject(tempSUM);
							
							/*Prepare Count Query */
							TargetEntry *tempCount = copyObject(tleTemp);
							Aggref* temp = copyObject(tempSUM);
							temp->aggtranstype = 20;
							temp->aggtype = 20;
                            temp->aggfnoid = 2147;
							//temp->aggargtypes = NULL;
							//temp->args = NULL;
							temp->location = temp->location*2;
							//temp->aggstar = 1;
							tempCount->expr = copyObject(temp);
							if(aggref->aggfnoid >= 2148 && aggref->aggfnoid <=2153 || 
							   aggref->aggfnoid >= 2718 && aggref->aggfnoid <=2723)
							{
								TargetEntry *tempVar = copyObject(tleTemp);
								Aggref* tempVariance = copyObject(aggref);
								tempVar->expr = copyObject(tempVariance);
								
								/* Add VARIANCE Query to the Pushdown Plan */							
								dummy_tlist2 = lappend(dummy_tlist2, tempVar);
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2154);
							}
							else if(aggref->aggfnoid >= 2154 && aggref->aggfnoid <=2159 ||
									aggref->aggfnoid >= 2724 && aggref->aggfnoid <=2729)
							{
								TargetEntry *tempVar = copyObject(tleTemp);
								Aggref* tempVariance = copyObject(aggref);
								tempVariance->aggfnoid -= 6;
								tempVar->expr = copyObject(tempVariance);
								/* Add STDDEV Query to the Pushdown Plan */							
								dummy_tlist2 = lappend(dummy_tlist2, tempVar);
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2154);
							}
							else{
								fdw_private->pPseudoAggTypeList = lappend_oid(fdw_private->pPseudoAggTypeList, 2100);
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
			}
			foreach(lc, dummy_tlist2){
				tle = lfirst_node(TargetEntry, lc);
				if(IsA(tle->expr, Aggref)){
					aggref = (Aggref*)tle->expr;
					if(aggref->args){
						tle = lfirst_node(Var, aggref->args->head);
						if(!list_member(dummy_tlist, tle)){
							TargetEntry *copy_tle = copyObject(tle);
							att++;
							copy_tle->resno = att;
							dummy_tlist = lappend(dummy_tlist, copy_tle);
						}
						/* Modify VAR of dummy_tlist2 for OUTER_VAR */
						var = (Var*)tle->expr;
						var->varno = OUTER_VAR;
						var->varattno = att;
					}
				}
				else if(IsA(tle->expr, Var))
				{
						if(!list_member(dummy_tlist, tle)){
							TargetEntry *copy_tle = copyObject(tle);
							att++;
							copy_tle->resno = att;
							dummy_tlist = lappend(dummy_tlist, copy_tle);
						}
						/* Modify VAR of dummy_tlist2 for OUTER_VAR */
						var = (Var*)tle->expr;
						var->varno = OUTER_VAR;
						var->varattno = att;
				}
			}
		}
		else{
			dummy_tlist = tlist;
			dummy_tlist2 = tlist;
			/* Group by clause for Pushdown case need to be added in dummy_root_list
			    check for any other better way then this in future */
			if(root->parse->groupClause != NULL)
			{
			    ((PlannerInfo*)list_nth(fdw_private->dummy_root_list,i))->parse->groupClause = 
				                        lappend(((PlannerInfo*)list_nth(fdw_private->dummy_root_list,i))->parse->groupClause,
				                        root->parse->groupClause);
		    }
		}
		PG_TRY();{
			PlannerInfo *dummy_root = (PlannerInfo*)list_nth(fdw_private->dummy_root_list,i);
			List *dummy_tlist2 = NIL;
			dummy_tlist2 = copyObject(root->processed_tlist);
			lappend(dummy_root->processed_tlist,dummy_tlist2->head);
			temp_obj = fdwroutine->GetForeignPlan(
				//(PlannerInfo*)list_nth(fdw_private->dummy_root_list,i),
				dummy_root,
				entry,  DatumGetObjectId(oid[i]),
				best_path, dummy_tlist, scan_clauses, outer_plan);
		}
		PG_CATCH();{
			ListCell *l;
			l = list_nth_cell(fdw_private->dummy_root_list, i);
			l->data.int_value = FALSE;
			elog(DEBUG1,"dummy plan list failed \n");
		}
		PG_END_TRY();
		if(list_member_oid(fdw_private->pPseudoAggList,
						   server_oid)){
			/* Create aggregation plan with foreign table scan. */
			fdw_private->pAgg = make_agg(
				dummy_tlist2,
				NULL,
				AGG_SORTED, AGGSPLIT_SIMPLE,
				list_length(root->parse->groupClause), 
				extract_grouping_cols(root->parse->groupClause,	tlist), 
				extract_grouping_ops(root->parse->groupClause), 
				root->parse->groupingSets, NIL,
				best_path->path.rows,
				temp_obj);
		}
		fdw_private->dummy_plan_list = lappend(fdw_private->dummy_plan_list,
											   temp_obj);
		elog(DEBUG1,"append dummy plan list %d\n",(int)oid[i]);
		elog(DEBUG1,
			 "fdw_private->dummy_plan_list list head = %d context=%s 525\n",
			 fdw_private->dummy_plan_list->length,
			 CurrentMemoryContext->name);
	}
#else
	Index scan_relid = baserel->relid;
	scan_clauses = extract_actual_clauses(scan_clauses, false);

	/* make_foreignscan has a different signature in 9.3 and 9.4 than in 9.5 */
#if (PG_VERSION_NUM >= 90300 && PG_VERSION_NUM < 90500)
	return make_foreignscan(tlist, scan_clauses, scan_relid, NIL, NIL);
#else
	return make_foreignscan(tlist, scan_clauses, scan_relid, NIL, NIL, NIL, NIL,
							outer_plan);
#endif
#endif
#endif

	if(root->parse->hasAggs)
	{
		scan_relid = 0; /* when aggregation pushdown...*/
		if(root->parse->groupClause == NULL)
		{
#ifdef ENABLE_MERGE_RESULT
			fdw_private->agg_query = true;
#endif
		}
	}
	else
	{
		scan_relid = baserel->relid; /* Not aggregation pushdown...*/
	}

	MemoryContextSwitchTo(oldcontext);
	
	return make_foreignscan(tlist,
							scan_clauses, //scan_clauses,
							scan_relid,
							NIL, // param list
							list_make1(makeInteger((long)fdw_private)),
							fdw_scan_tlist,
							NIL, // recheck qual
							outer_plan);
}


/*
 * ddsf_BeginForeignScan begins the ddsf plan (i.e. does nothing).
 */
static void
ddsf_BeginForeignScan(ForeignScanState *node, int eflags, Oid srvID) { 
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	FdwRoutine *fdwroutine;
	int         node_incr;
	Oid 		serverId;
	ForeignScanThreadInfo *fssThrdInfo;
	char		contextStr[BUFFERSIZE];
	char query[QUERY_LENGTH];
	char *entry;
	int			i;
	int thread_create_err;
	int nThreads;
	Datum		*oid;
	Datum		server_oid;
	DdsfFdwPrivate *fdw_private;
	ListCell   *l;
	
	node->ddsf_fsstate = NULL;
	fdw_private = (DdsfFdwPrivate*)
		((Value*)list_nth(fsplan->fdw_private, 0))->val.ival;

  /* get oids mapped relation  */
	oid = (Datum *)palloc (sizeof(Datum) * 256);
	
	if(fdw_private->list_parse != NIL ){
		entry = (char *) list_nth(fdw_private->list_parse, 0);
	}
	elog(DEBUG1,"underflag = %d\n",fdw_private->under_flag);

	if(fdw_private->under_flag == 0){
		sprintf(query,"select relname,oid from pg_class where relname LIKE \\
                '%s\\_\\_\%%' order by relname;",
				fdw_private->base_relation_name);
	}
	else{
		sprintf(query,"select relname,oid from pg_class where relname LIKE \\
                '%s\\_\\_%s\\_\\_\%%' order by relname;",
				fdw_private->base_relation_name,entry);
	}
	elog(DEBUG1,"relation name = %s\n", fdw_private->base_relation_name);
	elog(DEBUG1,"sql = %s\n",query);


	pthread_mutex_lock(&scan_mutex);
	if ((i = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", i);
	
	i = SPI_execute(query, true, 0);
	if(i != SPI_OK_SELECT)
		elog(DEBUG1,"error\n");

	for (i = 0; i < SPI_processed; i++)
	{
		char *text;
		bool		isnull;

		text =SPI_getvalue(SPI_tuptable->vals[i],
						   SPI_tuptable->tupdesc,
						   1);
		oid[i] = SPI_getbinval(SPI_tuptable->vals[i],
							SPI_tuptable->tupdesc,
							2,
							&isnull);
		pfree(text);
	}
	SPI_finish();
	pthread_mutex_unlock(&scan_mutex);

	fdw_private->node_num = i;
	if(fdw_private->base_rel_list != NIL){
		fdw_private->node_num = fdw_private->base_rel_list->length;
	}
	else{
		fdw_private->node_num = 0;
	}
	/*Type of Query to be used for computing intermediate results */
	if(fdw_private->agg_query) {
		node->ss.ps.state->es_progressState->ps_aggQuery = true;
	}
	else{
		node->ss.ps.state->es_progressState->ps_aggQuery = false;
	}

	elog(DEBUG1,"agg query%d\n",node->ss.ps.state->agg_query);
	node->ss.ps.state->agg_query = 0;
	if (!node->ss.ps.state->agg_query)
	{
		if (getResultFlag)
		{
			elog(DEBUG1,"get result flag\n");
			return;
		}
		/*Get all the foreign nodes from conf file*/
		fssThrdInfo = (ForeignScanThreadInfo*)palloc(
			sizeof(ForeignScanThreadInfo)*fdw_private->node_num);
		memset(fssThrdInfo, 0, sizeof(*fssThrdInfo)*fdw_private->node_num);
		node->ddsf_fsstate = fssThrdInfo;
		/* Supporting for Progress */
		node->ss.ps.state->es_progressState->ps_totalRows = 0;
		node->ss.ps.state->es_progressState->ps_fetchedRows = 0;

		pthread_mutex_lock(&scan_mutex);
		elog(DEBUG1,"main thread lock scan mutex \n");

		node_incr = 0;


		foreach(l,fdw_private->base_rel_list){
			Relation	rd;
			server_oid = ddsf_spi_exec_datasource_oid(DatumGetObjectId(oid[node_incr]));
			if (getResultFlag)
			{
				break;
			}
			fssThrdInfo[node_incr].fsstate = makeNode(ForeignScanState);
			memcpy(&fssThrdInfo[node_incr].fsstate->ss, &node->ss,
				   sizeof(ScanState));
			/* @todo copy Agg plan when psuedo aggregation case. */
			if(list_member_oid(fdw_private->pPseudoAggList,
							   server_oid)){
				Plan *plan = ((Plan *)list_nth(fdw_private->dummy_plan_list,
											   node_incr));
				fssThrdInfo[node_incr].fsstate->ss.ps.plan =
					copyObject(plan);
			}else{
				fssThrdInfo[node_incr].fsstate->ss = node->ss;
				fssThrdInfo[node_incr].fsstate->ss.ps.plan =
					copyObject(node->ss.ps.plan);
			}

			fsplan = (ForeignScan *) fssThrdInfo[node_incr].fsstate->ss.ps.plan;
			if(list_nth_int(fdw_private->dummy_list_enable,node_incr) != TRUE){
				elog(DEBUG1,"fdw_private->dummy_plan_list list nothing %d",node_incr);
				node_incr++;
				continue;
			}
			else{
				elog(DEBUG1,"fdw_private->dummy_plan_list list found %d",node_incr);
			}

			fsplan->fdw_private = ((ForeignScan *)list_nth(fdw_private->dummy_plan_list, node_incr))->fdw_private;

			fssThrdInfo[node_incr].fsstate->ss.ps.state = CreateExecutorState();

			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_top_eflags = eflags;

			/* This should be a new RTE list. coming from dummy rtable */
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_range_table =
				((PlannerInfo*)list_nth(fdw_private->dummy_root_list,node_incr))
				->parse->rtable;

			
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_plannedstmt =
				copyObject(node->ss.ps.state->es_plannedstmt);

			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_tupleTable = NIL; 
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_tuple_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_oldtup_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_trig_newtup_slot = NULL;
			fssThrdInfo[node_incr].fsstate->ss.ps.state->es_query_cxt = node->ss.ps.state->es_query_cxt;
			ExecAssignExprContext((EState*)fssThrdInfo[node_incr].fsstate->ss.ps.state, &fssThrdInfo[node_incr].fsstate->ss.ps);

			fssThrdInfo[node_incr].eflags = eflags;

/* Modify child plan */
			int 		natts;
			bool		hasoid;
			Form_pg_attribute *attrs;
			TupleDesc	tupledesc;
			int 		i;
			Datum		server_type;
			natts = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->natts;
			if(list_member_oid(fdw_private->pPseudoAggPushList,server_oid)||list_member_oid(fdw_private->pPseudoAggList,server_oid)){
			    if(list_member_oid(fdw_private->pPseudoAggTypeList,2100)){
					natts += 1;
				}
				elog(DEBUG1,"natts %d",natts);
				/* Extract attribute details. The tupledesc made here is just transient. */
				attrs = palloc(natts * sizeof(Form_pg_attribute));
				for (i = 0; i < natts; i++)
				{
					attrs[i] = palloc(sizeof(FormData_pg_attribute));
					memcpy(attrs[i], node->ss.ss_ScanTupleSlot->tts_tupleDescriptor->attrs[0], sizeof(FormData_pg_attribute));
					elog(DEBUG1,"attrs[i]->atttypid = %d",attrs[i]->atttypid);
					attrs[i]->atttypid=20;
					attrs[i]->attlen=8;
					attrs[i]->attnum=i;
					attrs[i]->attbyval=1;
					attrs[i]->attstorage=112;
					attrs[i]->attalign=100;
				}
				/* Construct TupleDesc, and assign a local typmod. */
				tupledesc = CreateTupleDesc(natts, true, attrs);
				tupledesc = BlessTupleDesc(tupledesc);

				fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot =
					MakeSingleTupleTableSlot(
						CreateTupleDescCopy(
							tupledesc));
			}
			else{
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
		    rd = RelationIdGetRelation(DatumGetObjectId(oid[node_incr]));
			fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation = rd;
			elog(DEBUG1,"oid = %d",fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation->rd_node.relNode);

			fssThrdInfo[node_incr].iFlag = true;
			fssThrdInfo[node_incr].EndFlag = false;
			fssThrdInfo[node_incr].tuple = NULL;
			fssThrdInfo[node_incr].nodeIndex = node_incr;

			serverId = server_oid;
			elog(DEBUG1,"serveroid %d\n",serverId);

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
		    pthread_mutex_init((pthread_mutex_t *)&fdw_private->foreign_scan_threads[node_incr], NULL);

			thread_create_err =
				pthread_create(&fdw_private->foreign_scan_threads[node_incr],
							   NULL,
							   &ddsf_ForeignScan_thread,
							   (void*)&fssThrdInfo[node_incr]);
			if(thread_create_err != 0){
				ereport(ERROR, (errmsg("Cannot create thread! error=%d",
									   thread_create_err)));
			}
			node_incr++;
		}
		pthread_mutex_unlock(&scan_mutex);
		elog(DEBUG1,"main thread unlock scan mutex \n");

	    nThreads = node_incr;
		Assert(fdw_private->base_rel_list->length == nThreads);

		/* Wait for state change */
		for(node_incr = 0; node_incr < nThreads; node_incr++){
			if(fssThrdInfo[node_incr].state == DDSF_FS_STATE_INIT){
				usleep(1);
				node_incr--;
				continue;
			}
		}
	}


	
 	return;
}


/*
 * ddsf_IterateForeignScan iterate on each DS and return the tuple table slot
 * in a round robin fashion.
 */
static TupleTableSlot *
ddsf_IterateForeignScan(ForeignScanState *node)
{

	static int count = 0;
	int 	   node_incr;
	int nThreads;
	ForeignScanThreadInfo *fssThrdInfo = node->ddsf_fsstate;
	bool 			icheck = false;
	TupleTableSlot *slot = NULL, *tempSlot = NULL;
	ForeignAggInfo *agginfodata;
	int aggflag=false;


	agginfodata = palloc(sizeof(ForeignAggInfo) * NODES_MAX);
	memset(agginfodata, 0, sizeof(ForeignAggInfo) * NODES_MAX);
	DdsfFdwPrivate *fdw_private = fssThrdInfo->private;
	int run = 1; /* '1' is for no aggregation query */
	if (getResultFlag && !fdw_private->agg_query)
	{
		return NULL;
	}

	if (!node->ss.ps.state->agg_query)
	{
		/*Get all the foreign nodes from conf file*/
		if(fdw_private == NULL ){
			elog(ERROR,"can't find node in iterateforeignscan");
		}
		nThreads = fdw_private->base_rel_list->length;

		/* run aggregation query for all data source threads and combine results */
#ifdef ENABLE_MERGE_RESULT
		if(fdw_private->agg_query) {
			run = nThreads;
			node->ss.ps.state->es_progressState->dest = (void*)((QueryDesc *)node->ss.ps.ddsfAggQry)->dest;
			strcpy(agginfodata[0].transquery, ((QueryDesc *)node->ss.ps.ddsfAggQry)->sourceText);
		}
#endif
		while(run)
		{
			for (;fssThrdInfo[count++].tuple == NULL;)
			{
				if (count >= nThreads)
				{
					count = 0;
					for ( node_incr = 0; node_incr < nThreads; node_incr++)
					{   
						if (fssThrdInfo[node_incr].iFlag)
						{   
							icheck = true;
							break;
						}   
					}    
					if (!icheck)
					{
						// There is no iterating thread.
						return NULL;
					}
					icheck = false;
					usleep(1);
				}
			}
			if(fssThrdInfo[count-1].tuple != NULL && fdw_private->agg_query)
			{
				if(list_member_oid(fdw_private->pPseudoAggList,fssThrdInfo[count-1].serverId)){
#if 0
					ddsf_get_agg_Info(fssThrdInfo[count-1].tuple, node, count, agginfodata);
#else
					ddsf_get_agg_Info(fssThrdInfo[count-1], node, count, agginfodata);
					run++;
					aggflag=true;
#endif
				}
				else if(list_member_oid(fdw_private->pPseudoAggPushList,fssThrdInfo[count-1].serverId)){
					ddsf_get_agg_Info_push(fssThrdInfo[count-1].tuple, node, count, agginfodata);
				}
			}
			tempSlot = fssThrdInfo[count-1].tuple;
			fssThrdInfo[count-1].tuple = NULL;
			if (count >= nThreads)
			{
				count = 0;
			}
			if(getResultFlag) 
			/* Aggregation Query Cancellation : Return existing intermediate result*/
			{
				run = 0;
			}
			else
			{
				run--;
			}
			/*Intermediate results for aggregation query requested */
			if(getAggResultFlag)
			{
				slot = node->ss.ss_ScanTupleSlot;
				if(ddsf_combine_agg_new(agginfodata, nThreads, tempSlot->tts_tupleDescriptor->natts))
				{
					node->ss.ps.state->es_progressState->ps_aggResult = ddsf_get_agg_tuple(agginfodata,slot);
				}
				node->ss.ps.state->es_progressState->ps_aggResult = NULL;
				getAggResultFlag = false;
			}
		}
		slot = node->ss.ss_ScanTupleSlot;
		if(fdw_private->agg_query)
		{
			ddsf_combine_agg_new(agginfodata, nThreads, tempSlot->tts_tupleDescriptor->natts);
			slot = ddsf_get_agg_tuple(agginfodata,slot);
		}
		else
		{
			ExecCopySlot(slot, tempSlot);
		}
	}
	else
	{
		slot = node->ss.ss_ScanTupleSlot;
		ExecClearTuple(slot);
	}
	pfree(agginfodata);
	return slot;	
}

static void 
FreeNodes(char **nodeList, int num_nodes)
{
        int             i;  
        for ( i=0; i < num_nodes; i++ )
        {   
                pfree(nodeList[i]);
        }   
        return;
}

/*
 * ddsf_ReScanForeignScan restarts the ddsf plan (i.e. does nothing).
 */
static void
ddsf_ReScanForeignScan(ForeignScanState *node) { 
#ifdef DDSF_FRGN_SCAN_ENABLED

	DdsfFdwPrivate *fdw_private;
	int node_incr;
	ForeignScanThreadInfo *fssThrdInfo;
	int nThreads;

	fssThrdInfo = node->ddsf_fsstate;
	fdw_private = fssThrdInfo->private;
	nThreads = fdw_private->base_rel_list->length;
	
	for(node_incr = 0; node_incr < nThreads ; node_incr++)
	{
		// @todo handle if there are error nodes.
		fssThrdInfo[node_incr].queryRescan = true;
	}
	// 10us sleep for thread switch
	usleep(10);
	
	for(node_incr = 0; node_incr < nThreads ; node_incr++)
	{
		// @todo handle if there are error nodes.
		while(fssThrdInfo[node_incr].queryRescan){
			pthread_yield();
		}
	}
#endif
	return;

}


/*
 * ddsf_EndForeignScan ends the ddsf plan (i.e. does nothing).
 */
static void
ddsf_EndForeignScan(ForeignScanState *node) { 
	int    node_incr;
	ForeignScanThreadInfo *fssThrdInfo;
	DdsfFdwPrivate *fdw_private;
	int nThreads;
	
	if (!node->ss.ps.state->agg_query)
	{
	    fssThrdInfo = node->ddsf_fsstate;
		fdw_private = (DdsfFdwPrivate*)fssThrdInfo->private;
		nThreads = fdw_private->base_rel_list->length;
		if (!fssThrdInfo)
		{
			return;
		}
	    elog(DEBUG1, "EndForeignScan\n");
		for (node_incr = 0; node_incr < nThreads; node_incr++)
		{
			fssThrdInfo[node_incr].EndFlag = true;
		}

		/* wait until all the remote connections get closed. */
		for (node_incr = 0; node_incr < nThreads ; node_incr++)
		{
			/* Cleanup the thread-local structures */
			pthread_join(fdw_private->foreign_scan_threads[node_incr],NULL);
			//ExecDropSingleTupleTableSlot(fssThrdInfo[node_incr].fsstate->ss.ss_ScanTupleSlot);
			if(fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation){
				RelationClose(
					fssThrdInfo[node_incr].fsstate->ss.ss_currentRelation);
			}
			ddsf_ReleasePrivate(fdw_private);
			pfree(fssThrdInfo[node_incr].fsstate->ss.ps.state);
			pfree(fssThrdInfo[node_incr].fsstate);
			MemoryContextDelete(fssThrdInfo[node_incr].threadMemoryContext);
		}
		if (fdw_private->thrdsCreated)
		{
			pfree(node->ddsf_fsstate); 
		}
	}
}

/* ddsf_ForeignAgg starts Foreign Agg simultaneously for all the foreign servers
 * returns Datum for the caller to set tabletupleSlot
 */
static Datum
ddsf_ForeignAgg(AggState *aggnode, void *state)
{
}
