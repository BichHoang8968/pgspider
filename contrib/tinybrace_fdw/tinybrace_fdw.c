/*-------------------------------------------------------------------------
 *
 * mysql_fdw.c
 * 		Foreign-data wrapper for remote MySQL servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 		mysql_fdw.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "tinybrace_fdw.h"
#include "tinybrace_query.h"

#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dlfcn.h>

#include <tinybrace.h>
#include "catalog/pg_collation.h"

#include "access/reloptions.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_foreign_table.h"
#include "catalog/pg_user_mapping.h"
#include "catalog/pg_type.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "commands/vacuum.h"
#include "foreign/fdwapi.h"
#include "foreign/foreign.h"
#include "nodes/makefuncs.h"
#include "optimizer/cost.h"
#include "optimizer/pathnode.h"
#include "optimizer/plancat.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "storage/ipc.h"
#include "utils/array.h"
#include "utils/builtins.h"
#include "utils/date.h"
#include "utils/hsearch.h"
#include "utils/lsyscache.h"
#include "utils/rel.h"
#include "utils/timestamp.h"
#include "utils/formatting.h"
#include "utils/memutils.h"
#include "access/htup_details.h"
#include "access/sysattr.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "commands/vacuum.h"
#include "foreign/fdwapi.h"
#include "funcapi.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/nodeFuncs.h"
#include "optimizer/cost.h"
#include "optimizer/pathnode.h"
#include "optimizer/paths.h"
#include "optimizer/planmain.h"
#include "optimizer/prep.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/var.h"
#include "parser/parsetree.h"
#include "utils/builtins.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "optimizer/pathnode.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/planmain.h"

#define DEFAULTE_NUM_ROWS    1000

PG_MODULE_MAGIC;


extern Datum tinybrace_fdw_handler(PG_FUNCTION_ARGS);
extern PGDLLEXPORT void _PG_init(void);

bool tinybrace_load_library(void);
static void tinybrace_fdw_exit(int code, Datum arg);

PG_FUNCTION_INFO_V1(tinybrace_fdw_handler);

/*
 * FDW callback routines
 */
static void tinybraceExplainForeignScan(ForeignScanState *node, ExplainState *es);
static void tinybraceBeginForeignScan(ForeignScanState *node, int eflags);
static TupleTableSlot *tinybraceIterateForeignScan(ForeignScanState *node);
static void tinybraceReScanForeignScan(ForeignScanState *node);
static void tinybraceEndForeignScan(ForeignScanState *node);

static List *tinybracePlanForeignModify(PlannerInfo *root, ModifyTable *plan, Index resultRelation,
									int subplan_index);
static void tinybraceBeginForeignModify(ModifyTableState *mtstate, ResultRelInfo *resultRelInfo,
									List *fdw_private, int subplan_index, int eflags);
static TupleTableSlot *tinybraceExecForeignInsert(EState *estate, ResultRelInfo *resultRelInfo,
											  TupleTableSlot *slot, TupleTableSlot *planSlot);
static void tinybraceAddForeignUpdateTargets(Query *parsetree, RangeTblEntry *target_rte,
										 Relation target_relation);
static TupleTableSlot * tinybraceExecForeignUpdate(EState *estate, ResultRelInfo *resultRelInfo,
											   TupleTableSlot *slot,TupleTableSlot *planSlot);
static TupleTableSlot *tinybraceExecForeignDelete(EState *estate, ResultRelInfo *resultRelInfo,
											  TupleTableSlot *slot, TupleTableSlot *planSlot);
static void tinybraceEndForeignModify(EState *estate, ResultRelInfo *resultRelInfo);

static void tinybraceGetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid);
static void tinybraceGetForeignPaths(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid);
static bool tinybraceAnalyzeForeignTable(Relation relation, AcquireSampleRowsFunc *func, BlockNumber *totalpages);
static ForeignScan *tinybraceGetForeignPlan(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid,
										ForeignPath *best_path, List * tlist, List *scan_clauses
#if PG_VERSION_NUM >= 90500
		                                ,Plan * outer_plan
#endif
);
static void tinybraceEstimateCosts(PlannerInfo *root, RelOptInfo *baserel, Cost *startup_cost, Cost *total_cost,
							   Oid foreigntableid);

#if PG_VERSION_NUM >= 90500
static List *tinybraceImportForeignSchema(ImportForeignSchemaStmt *stmt, Oid serverOid);
#endif

static bool tinybrace_is_column_unique(Oid foreigntableid);

static void prepare_query_params(PlanState *node,
					 List *fdw_exprs,
					 int numParams,
					 FmgrInfo **param_flinfo,
					 List **param_exprs,
					 const char ***param_values,
					 Oid **param_types);

static void
tinybraceGetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							  RelOptInfo *input_rel, RelOptInfo *output_rel);
static void
add_foreign_grouping_paths(PlannerInfo *root, RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel);

static void
merge_fdw_options(TinyBraceFdwRelationInfo *fpinfo,
				  const TinyBraceFdwRelationInfo *fpinfo_o,
				  const TinyBraceFdwRelationInfo *fpinfo_i);

static void
estimate_path_cost_size(PlannerInfo *root,
						RelOptInfo *baserel,
						List *join_conds,
						List *pathkeys,
						double *p_rows, int *p_width,
						Cost *p_startup_cost, Cost *p_total_cost);
static bool
foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel);

static void process_query_params(ExprContext *econtext,
					 FmgrInfo *param_flinfo,
					 List *param_exprs,
					 const char **param_values,
					 TBC_QUERY_HANDLE qHandle,
					 TBC_CONNECT_HANDLE connect,
					 Oid *param_types);
static void create_cursor(ForeignScanState *node);

void* tinybrace_dll_handle = NULL;
static int wait_timeout = WAIT_TIMEOUT;
static int interactive_timeout = INTERACTIVE_TIMEOUT;

/*
 * tinybrace_load_library function dynamically load the tinybrace's library
 * libtinybraceclient.so. The only reason to load the library using dlopen
 * is that, tinybrace and postgres both have function with same name like
 * "list_delete", "list_delete" and "list_free" which cause compiler
 * error "duplicate function name" and erroneously linking with a function.
 * This port of the code is used to avoid the compiler error.
 *
 * #define list_delete tinybrace_list_delete
 * #include <tinybrace.h>
 * #undef list_delete
 *
 * But system crashed on function tinybrace_stmt_close function because
 * tinybrace_stmt_close internally calling "list_delete" function which
 * wrongly binds to postgres' "list_delete" function.
 *
 * The dlopen function provides a parameter "RTLD_DEEPBIND" which
 * solved the binding issue.
 *
 * RTLD_DEEPBIND:
 * Place the lookup scope of the symbols in this library ahead of the
 * global scope. This means that a self-contained library will use its
 * own symbols in preference to global symbols with the same name contained
 * in libraries that have already been loaded.
 */
#if 0
bool
tinybrace_load_library(void)
{
#if defined(__APPLE__)
	/*
	 * Mac OS/BSD does not support RTLD_DEEPBIND, but it still
	 * works without the RTLD_DEEPBIND
	 */
	tinybrace_dll_handle = dlopen(_TINYBRACE_LIBNAME, RTLD_LAZY);
#else
	tinybrace_dll_handle = dlopen(_TINYBRACE_LIBNAME, RTLD_LAZY | RTLD_DEEPBIND);
#endif
	if(tinybrace_dll_handle == NULL)
		return false;

	_tinybrace_stmt_bind_param = dlsym(tinybrace_dll_handle, "tinybrace_stmt_bind_param");
	_tinybrace_stmt_bind_result = dlsym(tinybrace_dll_handle, "tinybrace_stmt_bind_result");
	_tinybrace_stmt_init = dlsym(tinybrace_dll_handle, "tinybrace_stmt_init");
	_tinybrace_stmt_prepare = dlsym(tinybrace_dll_handle, "tinybrace_stmt_prepare");
	_tinybrace_stmt_execute = dlsym(tinybrace_dll_handle, "tinybrace_stmt_execute");
	_tinybrace_stmt_fetch = dlsym(tinybrace_dll_handle, "tinybrace_stmt_fetch");
	_tinybrace_query = dlsym(tinybrace_dll_handle, "tinybrace_query");
	_tinybrace_stmt_result_metadata = dlsym(tinybrace_dll_handle, "tinybrace_stmt_result_metadata");
	_tinybrace_stmt_store_result = dlsym(tinybrace_dll_handle, "tinybrace_stmt_store_result");
	_tinybrace_fetch_row = dlsym(tinybrace_dll_handle, "tinybrace_fetch_row");
	_tinybrace_fetch_field = dlsym(tinybrace_dll_handle, "tinybrace_fetch_field");
	_tinybrace_fetch_fields = dlsym(tinybrace_dll_handle, "tinybrace_fetch_fields");
	_tinybrace_stmt_close = dlsym(tinybrace_dll_handle, "tinybrace_stmt_close");
	_tinybrace_stmt_reset = dlsym(tinybrace_dll_handle, "tinybrace_stmt_reset");
	_tinybrace_free_result = dlsym(tinybrace_dll_handle, "tinybrace_free_result");
	_tinybrace_error = dlsym(tinybrace_dll_handle, "tinybrace_error");
	_tinybrace_options = dlsym(tinybrace_dll_handle, "tinybrace_options");
	_tinybrace_ssl_set = dlsym(tinybrace_dll_handle, "tinybrace_ssl_set");
	_tinybrace_real_connect = dlsym(tinybrace_dll_handle, "tinybrace_real_connect");
	_tinybrace_close = dlsym(tinybrace_dll_handle, "tinybrace_close");
	_tinybrace_init = dlsym(tinybrace_dll_handle, "tinybrace_init");
	_tinybrace_stmt_attr_set = dlsym(tinybrace_dll_handle, "tinybrace_stmt_attr_set");
	_tinybrace_store_result = dlsym(tinybrace_dll_handle, "tinybrace_store_result");
	_tinybrace_stmt_errno = dlsym(tinybrace_dll_handle, "tinybrace_stmt_errno");
	_tinybrace_errno = dlsym(tinybrace_dll_handle, "tinybrace_errno");
	_tinybrace_num_fields = dlsym(tinybrace_dll_handle, "tinybrace_num_fields");
	_tinybrace_num_rows = dlsym(tinybrace_dll_handle, "tinybrace_num_rows");
	_tinybrace_get_host_info = dlsym(tinybrace_dll_handle, "tinybrace_get_host_info");
	_tinybrace_get_server_info = dlsym(tinybrace_dll_handle, "tinybrace_get_server_info");
	_tinybrace_get_proto_info = dlsym(tinybrace_dll_handle, "tinybrace_get_proto_info");

	if (_tinybrace_stmt_bind_param == NULL ||
		_tinybrace_stmt_bind_result == NULL ||
		_tinybrace_stmt_init == NULL ||
		_tinybrace_stmt_prepare == NULL ||
		_tinybrace_stmt_execute == NULL ||
		_tinybrace_stmt_fetch == NULL ||
		_tinybrace_query == NULL ||
		_tinybrace_stmt_result_metadata == NULL ||
		_tinybrace_stmt_store_result == NULL ||
		_tinybrace_fetch_row == NULL ||
		_tinybrace_fetch_field == NULL ||
		_tinybrace_fetch_fields == NULL ||
		_tinybrace_stmt_close == NULL ||
		_tinybrace_stmt_reset == NULL ||
		_tinybrace_free_result == NULL ||
		_tinybrace_error == NULL ||
		_tinybrace_options == NULL ||
		_tinybrace_ssl_set == NULL ||
		_tinybrace_real_connect == NULL ||
		_tinybrace_close == NULL ||
		_tinybrace_init == NULL ||
		_tinybrace_stmt_attr_set == NULL ||
		_tinybrace_store_result == NULL ||
		_tinybrace_stmt_errno == NULL ||
		_tinybrace_errno == NULL ||
		_tinybrace_num_fields == NULL ||
		_tinybrace_num_rows == NULL ||
		_tinybrace_get_host_info == NULL ||
		_tinybrace_get_server_info == NULL ||
		_tinybrace_get_proto_info == NULL)
			return false;
	return true;
}
#endif
/*
 * Library load-time initialization, sets on_proc_exit() callback for
 * backend shutdown.
 */
void
_PG_init(void)
{
  /*	if (!tinybrace_load_library())
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				errmsg("failed to load the tinybrace query: \n%s", dlerror()),
				errhint("export LD_LIBRARY_PATH to locate the library")));

	DefineCustomIntVariable("tinybrace_fdw.wait_timeout",
							"Server-side wait_timeout",
							"Set the maximum wait_timeout"
							"use to set the Tinybrace session timeout",
							&wait_timeout,
							WAIT_TIMEOUT,
							0,
							INT_MAX,
							PGC_USERSET,
							0,
							NULL,
							NULL,
							NULL);

	DefineCustomIntVariable("tinybrace_fdw.interactive_timeout",
							"Server-side interactive timeout",
							"Set the maximum interactive timeout"
							"use to set the Tinybrace session timeout",
							&interactive_timeout,
							INTERACTIVE_TIMEOUT,
							0,
							INT_MAX,
							PGC_USERSET,
							0,
							NULL,
							NULL,
							NULL);
	on_proc_exit(&tinybrace_fdw_exit, PointerGetDatum(NULL));
  */
}

/*
 * tinybrace_fdw_exit: Exit callback function.
 */
static void
tinybrace_fdw_exit(int code, Datum arg)
{
	tinybrace_cleanup_connection();
}

/*
 * Foreign-data wrapper handler function: return
 * a struct with pointers to my callback routines.
 */
Datum
tinybrace_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *fdwroutine = makeNode(FdwRoutine);

	/* Callback functions for readable FDW */
	fdwroutine->GetForeignRelSize = tinybraceGetForeignRelSize;
	fdwroutine->GetForeignPaths = tinybraceGetForeignPaths;
	fdwroutine->AnalyzeForeignTable = tinybraceAnalyzeForeignTable;
	fdwroutine->GetForeignPlan = tinybraceGetForeignPlan;
	fdwroutine->ExplainForeignScan = tinybraceExplainForeignScan;
	fdwroutine->BeginForeignScan = tinybraceBeginForeignScan;
	fdwroutine->IterateForeignScan = tinybraceIterateForeignScan;
	fdwroutine->ReScanForeignScan = tinybraceReScanForeignScan;
	fdwroutine->EndForeignScan = tinybraceEndForeignScan;

#if PG_VERSION_NUM >= 90500
	fdwroutine->ImportForeignSchema = tinybraceImportForeignSchema;
#endif

	/* Callback functions for writeable FDW */
	fdwroutine->ExecForeignInsert = tinybraceExecForeignInsert;
	fdwroutine->BeginForeignModify = tinybraceBeginForeignModify;
	fdwroutine->PlanForeignModify = tinybracePlanForeignModify;
	fdwroutine->AddForeignUpdateTargets = tinybraceAddForeignUpdateTargets;
	fdwroutine->ExecForeignUpdate = tinybraceExecForeignUpdate;
	fdwroutine->ExecForeignDelete = tinybraceExecForeignDelete;
	fdwroutine->EndForeignModify = tinybraceEndForeignModify;

	fdwroutine->GetForeignUpperPaths = tinybraceGetForeignUpperPaths;

	PG_RETURN_POINTER(fdwroutine);
}

static void
tinybraceGetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							 RelOptInfo *input_rel, RelOptInfo *output_rel)
{
	TinyBraceFdwRelationInfo *fpinfo;
	elog(INFO,"tinybraceGetForeignUpperPaths");

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((TinyBraceFdwRelationInfo *) input_rel->fdw_private)->pushdown_safe)
		return;

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if (stage != UPPERREL_GROUP_AGG || output_rel->fdw_private)
		return;

	fpinfo = (TinyBraceFdwRelationInfo *) palloc0(sizeof(TinyBraceFdwRelationInfo));
	fpinfo->pushdown_safe = false;
	output_rel->fdw_private = fpinfo;

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
    TinyBraceFdwRelationInfo *ifpinfo = input_rel->fdw_private;
	TinyBraceFdwRelationInfo *fpinfo = grouped_rel->fdw_private;
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
	fpinfo->outerrel = input_rel;

	/*
	 * Copy foreign table, foreign server, user mapping, FDW options etc.
	 * details from the input relation's fpinfo.
	 */
	fpinfo->table = ifpinfo->table;
	fpinfo->server = ifpinfo->server;
	fpinfo->user = ifpinfo->user;
	merge_fdw_options(fpinfo, ifpinfo, NULL);

	/* Assess if it is safe to push down aggregation and grouping. */
	if (!foreign_grouping_ok(root, grouped_rel))
		return;

	/* Estimate the cost of push down */
	//estimate_path_cost_size(root, grouped_rel, NIL, NIL, &rows,
	//						&width, &startup_cost, &total_cost);
	rows = width = startup_cost = total_cost = 1;


	/* Now update this information in the fpinfo */
	//fpinfo->rows = rows;
	fpinfo->rows = rows;
	fpinfo->width = width;
	fpinfo->startup_cost = startup_cost;
	fpinfo->total_cost = total_cost;

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

static void
merge_fdw_options(TinyBraceFdwRelationInfo *fpinfo,
				  const TinyBraceFdwRelationInfo *fpinfo_o,
				  const TinyBraceFdwRelationInfo *fpinfo_i)
{
	/* We must always have fpinfo_o. */
	Assert(fpinfo_o);

	/* fpinfo_i may be NULL, but if present the servers must both match. */
	Assert(!fpinfo_i ||
		   fpinfo_i->server->serverid == fpinfo_o->server->serverid);

	/*
	 * Copy the server specific FDW options.  (For a join, both relations come
	 * from the same server, so the server options should have the same value
	 * for both relations.)
	 */
	fpinfo->fdw_startup_cost = fpinfo_o->fdw_startup_cost;
	fpinfo->fdw_tuple_cost = fpinfo_o->fdw_tuple_cost;
	fpinfo->shippable_extensions = fpinfo_o->shippable_extensions;
	fpinfo->use_remote_estimate = fpinfo_o->use_remote_estimate;
	fpinfo->fetch_size = fpinfo_o->fetch_size;

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
		fpinfo->use_remote_estimate = fpinfo_o->use_remote_estimate ||
			fpinfo_i->use_remote_estimate;

		/*
		 * Set fetch size to maximum of the joining sides, since we are
		 * expecting the rows returned by the join to be proportional to the
		 * relation sizes.
		 */
		fpinfo->fetch_size = Max(fpinfo_o->fetch_size, fpinfo_i->fetch_size);
	}
}

static bool
foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel)
{
	Query	   *query = root->parse;
	PathTarget *grouping_target;
    TinyBraceFdwRelationInfo *fpinfo = (TinyBraceFdwRelationInfo *) grouped_rel->fdw_private;
	TinyBraceFdwRelationInfo *ofpinfo;
	List	   *aggvars;
	ListCell   *lc;
	int			i;
	List	   *tlist = NIL;

	/* Grouping Sets are not pushable */
	if (query->groupingSets)
		return false;

	/* Get the fpinfo of the underlying scan relation. */
	ofpinfo = (TinyBraceFdwRelationInfo *) fpinfo->outerrel->fdw_private;

	/*
	 * If underneath input relation has any local conditions, those conditions
	 * are required to be applied before performing aggregation.  Hence the
	 * aggregate cannot be pushed down.
	 */
	if (ofpinfo->local_conds)
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
				fpinfo->remote_conds = lappend(fpinfo->remote_conds, rinfo);
			else
				fpinfo->local_conds = lappend(fpinfo->local_conds, rinfo);
		}
	}

	/*
	 * If there are any local conditions, pull Vars and aggregates from it and
	 * check whether they are safe to pushdown or not.
	 */
	if (fpinfo->local_conds)
	{
		List	   *aggvars = NIL;
		ListCell   *lc;

		foreach(lc, fpinfo->local_conds)
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
	fpinfo->grouped_tlist = tlist;

	/* Safe to pushdown */
	fpinfo->pushdown_safe = true;

	/*
	 * Set cached relation costs to some negative value, so that we can detect
	 * when they are set to some sensible costs, during one (usually the
	 * first) of the calls to estimate_path_cost_size().
	 */
	fpinfo->rel_startup_cost = -1;
	fpinfo->rel_total_cost = -1;

	/*
	 * Set the string describing this grouped relation to be used in EXPLAIN
	 * output of corresponding ForeignScan.
	 */
	fpinfo->relation_name = makeStringInfo();
	//appendStringInfo(fpinfo->relation_name, "Aggregate on (%s)",
	//				 ofpinfo->relation_name->data);

	return true;
}


static void
estimate_path_cost_size(PlannerInfo *root,
						RelOptInfo *foreignrel,
						List *param_join_conds,
						List *pathkeys,
						double *p_rows, int *p_width,
						Cost *p_startup_cost, Cost *p_total_cost)
{
#if 0
	PgFdwRelationInfo *fpinfo = (PgFdwRelationInfo *) foreignrel->fdw_private;
	double		rows;
	double		retrieved_rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	Cost		cpu_per_tuple;

	/*
	 * If the table or the server is configured to use remote estimates,
	 * connect to the foreign server and execute EXPLAIN to estimate the
	 * number of rows selected by the restriction+join clauses.  Otherwise,
	 * estimate rows using whatever statistics we have locally, in a way
	 * similar to ordinary tables.
	 */
	if (fpinfo->use_remote_estimate)
	{
		List	   *remote_param_join_conds;
		List	   *local_param_join_conds;
		StringInfoData sql;
		PGconn	   *conn;
		Selectivity local_sel;
		QualCost	local_cost;
		List	   *fdw_scan_tlist = NIL;
		List	   *remote_conds;

		/* Required only to be passed to deparseSelectStmtForRel */
		List	   *retrieved_attrs;

		/*
		 * param_join_conds might contain both clauses that are safe to send
		 * across, and clauses that aren't.
		 */
		classifyConditions(root, foreignrel, param_join_conds,
						   &remote_param_join_conds, &local_param_join_conds);

		/* Build the list of columns to be fetched from the foreign server. */
		if (IS_JOIN_REL(foreignrel) || IS_UPPER_REL(foreignrel))
			fdw_scan_tlist = build_tlist_to_deparse(foreignrel);
		else
			fdw_scan_tlist = NIL;

		/*
		 * The complete list of remote conditions includes everything from
		 * baserestrictinfo plus any extra join_conds relevant to this
		 * particular path.
		 */
		remote_conds = list_concat(list_copy(remote_param_join_conds),
								   fpinfo->remote_conds);

		/*
		 * Construct EXPLAIN query including the desired SELECT, FROM, and
		 * WHERE clauses. Params and other-relation Vars are replaced by dummy
		 * values, so don't request params_list.
		 */
		initStringInfo(&sql);
		appendStringInfoString(&sql, "EXPLAIN ");
		deparseSelectStmtForRel(&sql, root, foreignrel, fdw_scan_tlist,
								remote_conds, pathkeys, false,
								&retrieved_attrs, NULL);

		/* Get the remote estimate */
		conn = GetConnection(fpinfo->user, false);
		get_remote_estimate(sql.data, conn, &rows, &width,
							&startup_cost, &total_cost);
		ReleaseConnection(conn);

		retrieved_rows = rows;

		/* Factor in the selectivity of the locally-checked quals */
		local_sel = clauselist_selectivity(root,
										   local_param_join_conds,
										   foreignrel->relid,
										   JOIN_INNER,
										   NULL);
		local_sel *= fpinfo->local_conds_sel;

		rows = clamp_row_est(rows * local_sel);

		/* Add in the eval cost of the locally-checked quals */
		startup_cost += fpinfo->local_conds_cost.startup;
		total_cost += fpinfo->local_conds_cost.per_tuple * retrieved_rows;
		cost_qual_eval(&local_cost, local_param_join_conds, root);
		startup_cost += local_cost.startup;
		total_cost += local_cost.per_tuple * retrieved_rows;
	}
	else
	{
		Cost		run_cost = 0;

		/*
		 * We don't support join conditions in this mode (hence, no
		 * parameterized paths can be made).
		 */
		Assert(param_join_conds == NIL);

		/*
		 * Use rows/width estimates made by set_baserel_size_estimates() for
		 * base foreign relations and set_joinrel_size_estimates() for join
		 * between foreign relations.
		 */
		rows = foreignrel->rows;
		width = foreignrel->reltarget->width;

		/* Back into an estimate of the number of retrieved rows. */
		retrieved_rows = clamp_row_est(rows / fpinfo->local_conds_sel);

		/*
		 * We will come here again and again with different set of pathkeys
		 * that caller wants to cost. We don't need to calculate the cost of
		 * bare scan each time. Instead, use the costs if we have cached them
		 * already.
		 */
		if (fpinfo->rel_startup_cost > 0 && fpinfo->rel_total_cost > 0)
		{
			startup_cost = fpinfo->rel_startup_cost;
			run_cost = fpinfo->rel_total_cost - fpinfo->rel_startup_cost;
		}
		else if (IS_JOIN_REL(foreignrel))
		{
			PgFdwRelationInfo *fpinfo_i;
			PgFdwRelationInfo *fpinfo_o;
			QualCost	join_cost;
			QualCost	remote_conds_cost;
			double		nrows;

			/* For join we expect inner and outer relations set */
			Assert(fpinfo->innerrel && fpinfo->outerrel);

			fpinfo_i = (PgFdwRelationInfo *) fpinfo->innerrel->fdw_private;
			fpinfo_o = (PgFdwRelationInfo *) fpinfo->outerrel->fdw_private;

			/* Estimate of number of rows in cross product */
			nrows = fpinfo_i->rows * fpinfo_o->rows;
			/* Clamp retrieved rows estimate to at most size of cross product */
			retrieved_rows = Min(retrieved_rows, nrows);

			/*
			 * The cost of foreign join is estimated as cost of generating
			 * rows for the joining relations + cost for applying quals on the
			 * rows.
			 */

			/*
			 * Calculate the cost of clauses pushed down to the foreign server
			 */
			cost_qual_eval(&remote_conds_cost, fpinfo->remote_conds, root);
			/* Calculate the cost of applying join clauses */
			cost_qual_eval(&join_cost, fpinfo->joinclauses, root);

			/*
			 * Startup cost includes startup cost of joining relations and the
			 * startup cost for join and other clauses. We do not include the
			 * startup cost specific to join strategy (e.g. setting up hash
			 * tables) since we do not know what strategy the foreign server
			 * is going to use.
			 */
			startup_cost = fpinfo_i->rel_startup_cost + fpinfo_o->rel_startup_cost;
			startup_cost += join_cost.startup;
			startup_cost += remote_conds_cost.startup;
			startup_cost += fpinfo->local_conds_cost.startup;

			/*
			 * Run time cost includes:
			 *
			 * 1. Run time cost (total_cost - startup_cost) of relations being
			 * joined
			 *
			 * 2. Run time cost of applying join clauses on the cross product
			 * of the joining relations.
			 *
			 * 3. Run time cost of applying pushed down other clauses on the
			 * result of join
			 *
			 * 4. Run time cost of applying nonpushable other clauses locally
			 * on the result fetched from the foreign server.
			 */
			run_cost = fpinfo_i->rel_total_cost - fpinfo_i->rel_startup_cost;
			run_cost += fpinfo_o->rel_total_cost - fpinfo_o->rel_startup_cost;
			run_cost += nrows * join_cost.per_tuple;
			nrows = clamp_row_est(nrows * fpinfo->joinclause_sel);
			run_cost += nrows * remote_conds_cost.per_tuple;
			run_cost += fpinfo->local_conds_cost.per_tuple * retrieved_rows;
		}
		else if (IS_UPPER_REL(foreignrel))
		{
			PgFdwRelationInfo *ofpinfo;
			PathTarget *ptarget = root->upper_targets[UPPERREL_GROUP_AGG];
			AggClauseCosts aggcosts;
			double		input_rows;
			int			numGroupCols;
			double		numGroups = 1;

			/*
			 * This cost model is mixture of costing done for sorted and
			 * hashed aggregates in cost_agg().  We are not sure which
			 * strategy will be considered at remote side, thus for
			 * simplicity, we put all startup related costs in startup_cost
			 * and all finalization and run cost are added in total_cost.
			 *
			 * Also, core does not care about costing HAVING expressions and
			 * adding that to the costs.  So similarly, here too we are not
			 * considering remote and local conditions for costing.
			 */

			ofpinfo = (PgFdwRelationInfo *) fpinfo->outerrel->fdw_private;

			/* Get rows and width from input rel */
			input_rows = ofpinfo->rows;
			width = ofpinfo->width;

			/* Collect statistics about aggregates for estimating costs. */
			MemSet(&aggcosts, 0, sizeof(AggClauseCosts));
			if (root->parse->hasAggs)
			{
				get_agg_clause_costs(root, (Node *) fpinfo->grouped_tlist,
									 AGGSPLIT_SIMPLE, &aggcosts);
				get_agg_clause_costs(root, (Node *) root->parse->havingQual,
									 AGGSPLIT_SIMPLE, &aggcosts);
			}

			/* Get number of grouping columns and possible number of groups */
			numGroupCols = list_length(root->parse->groupClause);
			numGroups = estimate_num_groups(root,
											get_sortgrouplist_exprs(root->parse->groupClause,
																	fpinfo->grouped_tlist),
											input_rows, NULL);

			/*
			 * Number of rows expected from foreign server will be same as
			 * that of number of groups.
			 */
			rows = retrieved_rows = numGroups;

			/*-----
			 * Startup cost includes:
			 *	  1. Startup cost for underneath input * relation
			 *	  2. Cost of performing aggregation, per cost_agg()
			 *	  3. Startup cost for PathTarget eval
			 *-----
			 */
			startup_cost = ofpinfo->rel_startup_cost;
			startup_cost += aggcosts.transCost.startup;
			startup_cost += aggcosts.transCost.per_tuple * input_rows;
			startup_cost += (cpu_operator_cost * numGroupCols) * input_rows;
			startup_cost += ptarget->cost.startup;

			/*-----
			 * Run time cost includes:
			 *	  1. Run time cost of underneath input relation
			 *	  2. Run time cost of performing aggregation, per cost_agg()
			 *	  3. PathTarget eval cost for each output row
			 *-----
			 */
			run_cost = ofpinfo->rel_total_cost - ofpinfo->rel_startup_cost;
			run_cost += aggcosts.finalCost * numGroups;
			run_cost += cpu_tuple_cost * numGroups;
			run_cost += ptarget->cost.per_tuple * numGroups;
		}
		else
		{
			/* Clamp retrieved rows estimates to at most foreignrel->tuples. */
			retrieved_rows = Min(retrieved_rows, foreignrel->tuples);

			/*
			 * Cost as though this were a seqscan, which is pessimistic.  We
			 * effectively imagine the local_conds are being evaluated
			 * remotely, too.
			 */
			startup_cost = 0;
			run_cost = 0;
			run_cost += seq_page_cost * foreignrel->pages;

			startup_cost += foreignrel->baserestrictcost.startup;
			cpu_per_tuple = cpu_tuple_cost + foreignrel->baserestrictcost.per_tuple;
			run_cost += cpu_per_tuple * foreignrel->tuples;
		}

		/*
		 * Without remote estimates, we have no real way to estimate the cost
		 * of generating sorted output.  It could be free if the query plan
		 * the remote side would have chosen generates properly-sorted output
		 * anyway, but in most cases it will cost something.  Estimate a value
		 * high enough that we won't pick the sorted path when the ordering
		 * isn't locally useful, but low enough that we'll err on the side of
		 * pushing down the ORDER BY clause when it's useful to do so.
		 */
		if (pathkeys != NIL)
		{
			startup_cost *= DEFAULT_FDW_SORT_MULTIPLIER;
			run_cost *= DEFAULT_FDW_SORT_MULTIPLIER;
		}

		total_cost = startup_cost + run_cost;
	}

	/*
	 * Cache the costs for scans without any pathkeys or parameterization
	 * before adding the costs for transferring data from the foreign server.
	 * These costs are useful for costing the join between this relation and
	 * another foreign relation or to calculate the costs of paths with
	 * pathkeys for this relation, when the costs can not be obtained from the
	 * foreign server. This function will be called at least once for every
	 * foreign relation without pathkeys and parameterization.
	 */
	if (pathkeys == NIL && param_join_conds == NIL)
	{
		fpinfo->rel_startup_cost = startup_cost;
		fpinfo->rel_total_cost = total_cost;
	}

	/*
	 * Add some additional cost factors to account for connection overhead
	 * (fdw_startup_cost), transferring data across the network
	 * (fdw_tuple_cost per retrieved row), and local manipulation of the data
	 * (cpu_tuple_cost per retrieved row).
	 */
	startup_cost += fpinfo->fdw_startup_cost;
	total_cost += fpinfo->fdw_startup_cost;
	total_cost += fpinfo->fdw_tuple_cost * retrieved_rows;
	total_cost += cpu_tuple_cost * retrieved_rows;

	/* Return results. */
	*p_rows = rows;
	*p_width = width;
	*p_startup_cost = startup_cost;
	*p_total_cost = total_cost;
#endif
}


/*
 * tinybraceBeginForeignScan: Initiate access to the database
 */
static void
tinybraceBeginForeignScan(ForeignScanState *node, int eflags)
{
	TupleTableSlot    *tupleSlot = node->ss.ss_ScanTupleSlot;
	TupleDesc         tupleDescriptor = tupleSlot->tts_tupleDescriptor;
	TBC_CLIENT_HANDLE *conn = NULL;
	RangeTblEntry     *rte;
	TinyBraceFdwExecState *festate = NULL;
	EState            *estate = node->ss.ps.state;
	ForeignScan       *fsplan = (ForeignScan *) node->ss.ps.plan;
	tinybrace_opt         *options;
	ListCell          *lc = NULL;
	int               atindex = 0;
	//unsigned long     prefetch_rows = TINYBRACE_PREFETCH_ROWS;
	//unsigned long     type = (unsigned long) CURSOR_TYPE_READ_ONLY;
	Oid               userid;
	ForeignServer     *server;
	UserMapping       *user;
	ForeignTable      *table;
	char              timeout[255];
	int               numParams;
	TBC_RTNCODE rtn;

	/*
	 * We'll save private state in node->fdw_state.
	 */
	festate = (TinyBraceFdwExecState *) palloc(sizeof(TinyBraceFdwExecState));
	node->fdw_state = (void *) festate;

	/*
	 * Identify which user to do the remote access as.  This should match what
	 * ExecCheckRTEPerms() does.
	 */
	rte = rt_fetch(fsplan->scan.scanrelid, estate->es_range_table);
	userid = rte->checkAsUser ? rte->checkAsUser : GetUserId();

	/* Get info about foreign table. */
	festate->rel = node->ss.ss_currentRelation;
	table = GetForeignTable(RelationGetRelid(festate->rel));
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(userid, server->serverid);

	/* Fetch the options */
	options = tinybrace_get_options(RelationGetRelid(node->ss.ss_currentRelation));

	/*
	 * Get the already connected connection, otherwise connect
	 * and get the connection handle.
	 */
	conn = tinybrace_get_connection(server, user, options);

	/* Stash away the state info we have already */
	festate->query = strVal(list_nth(fsplan->fdw_private, 0));
	festate->retrieved_attrs = list_nth(fsplan->fdw_private, 1);
	festate->conn = conn;
	festate->cursor_exists = false;

	festate->temp_cxt = AllocSetContextCreate(estate->es_query_cxt,
											  "tinybrace_fdw temporary data",
											  ALLOCSET_SMALL_MINSIZE,
											  ALLOCSET_SMALL_INITSIZE,
											  ALLOCSET_SMALL_MAXSIZE);
	festate-> table = (tinybrace_table *)palloc0(sizeof(tinybrace_table));

	if (wait_timeout > 0)
	{
	}

	if (interactive_timeout > 0)
	{
	}


	/* Prepare TinyBrace statement */
	fprintf(stderr,"tinybrace begin foreign scan query = %s\n",festate->query);
  rtn = TBC_prepare_stmt(festate->conn->connect, festate->query, &festate->qHandle);
  if(rtn != TBC_OK){
    ereport(ERROR,
            (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
             errmsg("tiny brace error stmt. %d\n sql is %s\n",rtn, festate->query)));
  }
	/* Prepare for output conversion of parameters used in remote query. */
	numParams = list_length(fsplan->fdw_exprs);
	festate->numParams = numParams;
	if (numParams > 0)
		prepare_query_params((PlanState *) node,
							 fsplan->fdw_exprs,
							 numParams,
							 &festate->param_flinfo,
							 &festate->param_exprs,
							 &festate->param_values,
							 &festate->param_types);

#if 0
	rtn = TBC_execute(festate->conn->connect, festate->qHandle);
	if (rtn != TBC_OK)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("failed to tbc_execute %d\n",rtn)));
	}
	festate-> table ->result_set = (TBC_RESULT_SET *)palloc0(sizeof(TBC_RESULT_SET));

	rtn = TBC_store_result(festate->conn->connect,festate->qHandle, festate->table->result_set);
	if(rtn != TBC_OK){
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("failed to tbc_store_result %d\n",rtn)));
	}
#endif
	festate->current_row = 0;
}

/*
 * mysqlIterateForeignScan: Iterate and get the rows one by one from
 * MySQL and placed in tuple slot
 */
static TupleTableSlot *
tinybraceIterateForeignScan(ForeignScanState *node)
{
	TinyBraceFdwExecState   *festate = (TinyBraceFdwExecState *) node->fdw_state;
	TupleTableSlot      *tupleSlot = node->ss.ss_ScanTupleSlot;
	TupleDesc           tupleDescriptor = tupleSlot->tts_tupleDescriptor;
	int                 attid = 0;
	ListCell            *lc = NULL;
	int                 rc = 0;
	TBC_RTNCODE rtn;

	if (!festate->cursor_exists)
	{
		create_cursor(node);
		rtn = TBC_execute(festate->conn->connect, festate->qHandle);
		if (rtn != TBC_OK)
		{
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
					 errmsg("failed to tbc_execute %d\n",rtn)));
		}
		festate-> table ->result_set = (TBC_RESULT_SET *)palloc0(sizeof(TBC_RESULT_SET));

		rtn = TBC_store_result(festate->conn->connect,festate->qHandle, festate->table->result_set);
		if(rtn != TBC_OK){
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
					 errmsg("failed to tbc_store_result %d\n",rtn)));
		}
	}
	memset (tupleSlot->tts_values, 0, sizeof(Datum) * tupleDescriptor->natts);
	memset (tupleSlot->tts_isnull, true, sizeof(bool) * tupleDescriptor->natts);

	ExecClearTuple(tupleSlot);

	attid = 0;
	rtn = TBC_OK;

	if(festate->table->result_set == NULL){
	    elog(ERROR,"TinyBrace ResultSet is NULL");
	}
	fprintf(stderr,"festate->current_row = %d\n",festate->current_row);
	if (festate->table->result_set->nRow > festate->current_row)
	{
		foreach(lc, festate->retrieved_attrs)
		{
			int attnum = lfirst_int(lc) - 1;
			Oid pgtype = tupleDescriptor->attrs[attnum]->atttypid;
			int32 pgtypmod = tupleDescriptor->attrs[attnum]->atttypmod;
			if(festate->table->result_set->arData[festate->current_row][attid].type != TBC_NULL){
				tupleSlot->tts_values[attnum] = tinybrace_convert_to_pg(pgtype, pgtypmod,
																		(TBC_DATA*)&festate->table->result_set->arData[festate->current_row][attid]);
				tupleSlot->tts_isnull[attnum] = false;
			}
			else{
			}
			attid++;
		}
		festate->current_row++;
		ExecStoreVirtualTuple(tupleSlot);
	}
	else if (1 == rc)
	{
			/*
			  Error occurred. Error code and message can be obtained
			  by calling mysql_stmt_errno() and mysql_stmt_error().
			*/
	}
	else if (TBC_NO_DATA == rc)
	{
            /*
              No more rows/data exists
            */
	}
	return tupleSlot;
}


/*
 * mysqlExplainForeignScan: Produce extra output for EXPLAIN
 */
static void
tinybraceExplainForeignScan(ForeignScanState *node, ExplainState *es)
{
	TinyBraceFdwExecState *festate = (TinyBraceFdwExecState *) node->fdw_state;
	tinybrace_opt *options;

	/* Fetch options */
	options = tinybrace_get_options(RelationGetRelid(node->ss.ss_currentRelation));

	/* Give some possibly useful info about startup costs */
	if (es->verbose)
	{
		if (strcmp(options->svr_address, "127.0.0.1") == 0 || strcmp(options->svr_address, "localhost") == 0)
			ExplainPropertyLong("Local server startup cost", 10, es);
		else
			ExplainPropertyLong("Remote server startup cost", 25, es);

		ExplainPropertyText("Remote query", festate->query, es);
	}

}

/*
 * mysqlEndForeignScan: Finish scanning foreign table and dispose
 * objects used for this scan
 */
static void
tinybraceEndForeignScan(ForeignScanState *node)
{
	TinyBraceFdwExecState *festate = (TinyBraceFdwExecState *) node->fdw_state;

    if (festate->table)
    {
         if (festate->table->result_set != NULL ) {
           TBC_free_result(festate->conn->connect, 0, festate->table->result_set);
           festate->table->result_set = NULL;
         }
       }

	if (festate->qHandle != 0)
	{
		TBC_finalize_stmt(festate->conn->connect,festate->qHandle);
		festate->qHandle = 0;
	}
}

/*
 * mysqlReScanForeignScan: Rescan table, possibly with new parameters
 */
static void
tinybraceReScanForeignScan(ForeignScanState *node)
{
	/* TODO: Need to implement rescan */
	
	TinyBraceFdwExecState   *festate = (TinyBraceFdwExecState *) node->fdw_state;

	fprintf(stderr,"rescan is occurred.\n");
	festate->current_row = 0;
}
#if 0
static int
GetEstimatedRows(Oid foreigntableid,TBC_connect conn)
{
	char		   *svr_database = NULL;
	char		   *svr_table = NULL;
	char		   *query;
	size_t			len;
	const char	   *pzTail;
	sqlite_opt *opt;
	int rows = 0;
	ForeignTable      *table;
	ForeignServer     *server;
	TBC_RTNCODE rc = TBC_OK;
	TBC_QUERY_HANDLE qHandle = 0;
	TBC_RESULT_SET result;
	int state = -1;
	int cnt=0;

	/* Fetch options  */
	opt = sqlite_get_options(foreigntableid);
	svr_database = opt->svr_database;
	svr_table = opt->svr_table;
	
	table = GetForeignTable(foreigntableid);
	server = GetForeignServer(table->serverid);

	/* Check that the sqlite_stat1 table exists */
	rc = TBC_query(connect, "SELECT 1 FROM sqlite_master WHERE name='sqlite_stat1'", &qHandle);
    if (rc != TBC_OK) {
		elog(ERROR, "can not connect to tinybrace.");
    }
    rc = TBC_store_result(connect, qHandle, &result);
    if (rc != TBC_OK) {
		elog(ERROR, "can not connect to tinybrace.");
    }
	{
		ereport(DEBUG1,
			(errcode(ERRCODE_FDW_TABLE_NOT_FOUND),
			errmsg("The sqlite3 database has not been analyzed."),
			errhint("Run ANALYZE on table \"%s\", database \"%s\".", svr_table, svr_database)
			));
		/* Free the query results */
	    
		TBC_free_result( conn , qHandle , &result );
		rows = 10;
	} else {		
		/* sqlite_stat1 exists */
		rc = TBC_query(connect, "SELECT 1 FROM sqlite_master WHERE name='sqlite_stat1'", &qHandle);
		if (rc != TBC_OK) {
			elog(ERROR, "can not connect to tinybrace.");
		}
		rc = TBC_store_result(connect, qHandle, &result);
		if (rc != TBC_OK) {
			elog(ERROR, "can not connect to tinybrace.");
		}		
		/* Free the query results */
		TBC_free_result( conn , qHandle , &result );
		
		/* Build the query */
	    len = strlen(svr_table) + 60;
	    query = (char *)palloc(len);
	    snprintf(query, len, "SELECT stat FROM sqlite_stat1 WHERE tbl='%s' AND idx IS NULL", svr_table);
	    elog(LOG, "query:%s", query);

	    /* Execute the query */
		sqlitePrepare(db, query, &result, &pzTail);

		/* get the next record, if any, and fill in the slot */
		if (sqlite3_step(result) == SQLITE_ROW)
			rows = sqlite3_column_int(result, 0);
		else
			rows = DEFAULT_ESTIMATED_LINES;

		/* Free the query results */
		sqlite3_finalize(result);
	}

	return rows;
}
#endif

/*
 * mysqlGetForeignRelSize: Create a FdwPlan for a scan on the foreign table
 */
static void
tinybraceGetForeignRelSize(PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
	StringInfoData       sql;
	double               rows = 0;
	double               filtered = 0;
	TBC_CLIENT_HANDLE   *hdl = NULL;
	TBC_RESULT_SET            *result = NULL;
	Bitmapset            *attrs_used = NULL;
	List                 *retrieved_attrs = NULL;
	tinybrace_opt            *options = NULL;
	Oid                  userid =  GetUserId();
	ForeignServer        *server;
	UserMapping          *user;
	ForeignTable         *table;
	TinyBraceFdwRelationInfo *fpinfo;
	ListCell             *lc;
	TBC_FIELD_INFO          *field;
	int                  i;
	int                  num_fields;
	List                *params_list = NULL;
	TBC_QUERY_HANDLE qHandle;
	TBC_RTNCODE rtn;

	fpinfo = (TinyBraceFdwRelationInfo *) palloc0(sizeof(TinyBraceFdwRelationInfo));
	baserel->fdw_private = (void *) fpinfo;

	/* Base foreign tables need to be pushed down always. */
	fpinfo->pushdown_safe = true;

	table = GetForeignTable(foreigntableid);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(userid, server->serverid);

	/* Fetch options */
	options = tinybrace_get_options(foreigntableid);

	/* Connect to the server */
	hdl = tinybrace_get_connection(server, user, options);

	//_mysql_query(conn, "SET sql_mode='ANSI_QUOTES'");

	pull_varattnos((Node *) baserel->reltarget->exprs, baserel->relid, &attrs_used);

	foreach(lc, baserel->baserestrictinfo)
	{
		RestrictInfo *ri = (RestrictInfo *) lfirst(lc);

		if (is_foreign_expr(root, baserel, ri->clause))
			fpinfo->remote_conds = lappend(fpinfo->remote_conds, ri);
		else
			fpinfo->local_conds = lappend(fpinfo->local_conds, ri);
	}

	pull_varattnos((Node *) baserel->reltarget->exprs, baserel->relid, &fpinfo->attrs_used);
	foreach(lc, fpinfo->local_conds)
	{
		RestrictInfo *rinfo = (RestrictInfo *) lfirst(lc);
		pull_varattnos((Node *) rinfo->clause, baserel->relid, &fpinfo->attrs_used);
	}
#if 0
	if (options->use_remote_estimate)
	{
		initStringInfo(&sql);
		appendStringInfo(&sql, "Select * from sqlite_master;");
		tinybrace_deparse_select(&sql, root, baserel, fpinfo->attrs_used, options->svr_table, &retrieved_attrs);
		if (fpinfo->remote_conds)
			tinybrace_append_where_clause(&sql, root, baserel, fpinfo->remote_conds,
										  true, &params_list);
		rtn = TBC_query(hdl->connect, sql.data,qHandle);
		if (rtn != 0)
		{
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
					 errmsg("failed to execute the tinybrace query: \n%s", rtn)));
		}
		rtn = TBC_store_result(hdl->connect, &qHandle, result);
	}
#endif
	rows = 10000;
	baserel->rows = rows;
	baserel->tuples = rows;
}


static bool
tinybrace_is_column_unique(Oid foreigntableid)
{
	StringInfoData       sql;
	TBC_CLIENT_HANDLE    *hdl;
	TBC_RESULT_SET        result;
	tinybrace_opt            *options = NULL;
	Oid                  userid =  GetUserId();
	ForeignServer        *server;
	UserMapping          *user;
	ForeignTable         *table;
	TBC_RTNCODE rtn;
	TBC_QUERY_HANDLE qHandle;
	int is_pk;

	table = GetForeignTable(foreigntableid);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(userid, server->serverid);

	/* Fetch the options */
	options = tinybrace_get_options(foreigntableid);

	/* Connect to the server */
	hdl = tinybrace_get_connection(server, user, options);

	/* Build the query */
	initStringInfo(&sql);

	appendStringInfo(&sql, "PRAGMA table_info(%s)", options->svr_table);
	rtn = TBC_query(hdl->connect, sql.data, &qHandle);
	if (rtn != TBC_OK)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("failed to execute the tinybrace query: %d\n",rtn)));
	}
	rtn = TBC_store_result(hdl->connect,qHandle,&result);
	if (rtn != TBC_OK)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("failed to execute the tinybrace store result: %d\n",rtn)));
	}
	if (result.nRow!=0)
	{
		is_pk = result.arData[0][5].value;
	    TBC_free_result(hdl->connect, qHandle, &result);
	}

	//TBC_free_result(result);
	if (is_pk)
		return true;
	return false;
}

/*
 * mysqlEstimateCosts: Estimate the remote query cost
 */
static void
tinybraceEstimateCosts(PlannerInfo *root, RelOptInfo *baserel, Cost *startup_cost, Cost *total_cost, Oid foreigntableid)
{
	tinybrace_opt *options;

	/* Fetch options */
	options = tinybrace_get_options(foreigntableid);

	/* Local databases are probably faster */
	if (strcmp(options->svr_address, "127.0.0.1") == 0 || strcmp(options->svr_address, "localhost") == 0)
		*startup_cost = 10;
	else
		*startup_cost = 25;

	*total_cost = baserel->rows + *startup_cost;
}




static List *
get_useful_ecs_for_relation(PlannerInfo *root, RelOptInfo *rel)
{
	List	   *useful_eclass_list = NIL;
	ListCell   *lc;
	Relids		relids;

	/*
	 * First, consider whether any active EC is potentially useful for a merge
	 * join against this relation.
	 */
	if (rel->has_eclass_joins)
	{
		foreach(lc, root->eq_classes)
		{
			EquivalenceClass *cur_ec = (EquivalenceClass *) lfirst(lc);

			if (eclass_useful_for_merging(root, cur_ec, rel))
				useful_eclass_list = lappend(useful_eclass_list, cur_ec);
		}
	}

	/*
	 * Next, consider whether there are any non-EC derivable join clauses that
	 * are merge-joinable.  If the joininfo list is empty, we can exit
	 * quickly.
	 */
	if (rel->joininfo == NIL)
		return useful_eclass_list;

	/* If this is a child rel, we must use the topmost parent rel to search. */
	if (IS_OTHER_REL(rel))
	{
		Assert(!bms_is_empty(rel->top_parent_relids));
		relids = rel->top_parent_relids;
	}
	else
		relids = rel->relids;

#if 0
	/* Check each join clause in turn. */
	foreach(lc, rel->joininfo)
	{
		RestrictInfo *restrictinfo = (RestrictInfo *) lfirst(lc);

		/* Consider only mergejoinable clauses */
		if (restrictinfo->mergeopfamilies == NIL)
			continue;

		/* Make sure we've got canonical ECs. */
		update_mergeclause_eclasses(root, restrictinfo);

		/*
		 * restrictinfo->mergeopfamilies != NIL is sufficient to guarantee
		 * that left_ec and right_ec will be initialized, per comments in
		 * distribute_qual_to_rels.
		 *
		 * We want to identify which side of this merge-joinable clause
		 * contains columns from the relation produced by this RelOptInfo. We
		 * test for overlap, not containment, because there could be extra
		 * relations on either side.  For example, suppose we've got something
		 * like ((A JOIN B ON A.x = B.x) JOIN C ON A.y = C.y) LEFT JOIN D ON
		 * A.y = D.y.  The input rel might be the joinrel between A and B, and
		 * we'll consider the join clause A.y = D.y. relids contains a
		 * relation not involved in the join class (B) and the equivalence
		 * class for the left-hand side of the clause contains a relation not
		 * involved in the input rel (C).  Despite the fact that we have only
		 * overlap and not containment in either direction, A.y is potentially
		 * useful as a sort column.
		 *
		 * Note that it's even possible that relids overlaps neither side of
		 * the join clause.  For example, consider A LEFT JOIN B ON A.x = B.x
		 * AND A.x = 1.  The clause A.x = 1 will appear in B's joininfo list,
		 * but overlaps neither side of B.  In that case, we just skip this
		 * join clause, since it doesn't suggest a useful sort order for this
		 * relation.
		 */
		if (bms_overlap(relids, restrictinfo->right_ec->ec_relids))
			useful_eclass_list = list_append_unique_ptr(useful_eclass_list,
														restrictinfo->right_ec);
		else if (bms_overlap(relids, restrictinfo->left_ec->ec_relids))
			useful_eclass_list = list_append_unique_ptr(useful_eclass_list,
														restrictinfo->left_ec);
	}
#endif
	return useful_eclass_list;
}

extern Expr *
find_em_expr_for_rel(EquivalenceClass *ec, RelOptInfo *rel)
{
	ListCell   *lc_em;

	foreach(lc_em, ec->ec_members)
	{
		EquivalenceMember *em = lfirst(lc_em);

		if (bms_is_subset(em->em_relids, rel->relids))
		{
			/*
			 * If there is more than one equivalence member whose Vars are
			 * taken entirely from this relation, we'll be content to choose
			 * any one of those.
			 */
			return em->em_expr;
		}
	}

	/* We didn't find any suitable equivalence class expression */
	return NULL;
}


/*
 * get_useful_pathkeys_for_relation
 *		Determine which orderings of a relation might be useful.
 *
 * Getting data in sorted order can be useful either because the requested
 * order matches the final output ordering for the overall query we're
 * planning, or because it enables an efficient merge join.  Here, we try
 * to figure out which pathkeys to consider.
 */
static List *
get_useful_pathkeys_for_relation(PlannerInfo *root, RelOptInfo *rel)
{
	List	   *useful_pathkeys_list = NIL;
	List	   *useful_eclass_list;
    TinyBraceFdwRelationInfo *fpinfo = (TinyBraceFdwRelationInfo *) rel->fdw_private;
	EquivalenceClass *query_ec = NULL;
	ListCell   *lc;

	/*
	 * Pushing the query_pathkeys to the remote server is always worth
	 * considering, because it might let us avoid a local sort.
	 */
	if (root->query_pathkeys)
	{
		bool		query_pathkeys_ok = true;

		foreach(lc, root->query_pathkeys)
		{
			PathKey    *pathkey = (PathKey *) lfirst(lc);
			EquivalenceClass *pathkey_ec = pathkey->pk_eclass;
			Expr	   *em_expr;

			/*
			 * The planner and executor don't have any clever strategy for
			 * taking data sorted by a prefix of the query's pathkeys and
			 * getting it to be sorted by all of those pathkeys. We'll just
			 * end up resorting the entire data set.  So, unless we can push
			 * down all of the query pathkeys, forget it.
			 *
			 * is_foreign_expr would detect volatile expressions as well, but
			 * checking ec_has_volatile here saves some cycles.
			 */
			if (pathkey_ec->ec_has_volatile ||
				!(em_expr = find_em_expr_for_rel(pathkey_ec, rel)) ||
				!is_foreign_expr(root, rel, em_expr))
			{
				query_pathkeys_ok = false;
				break;
			}
		}

		if (query_pathkeys_ok)
			useful_pathkeys_list = list_make1(list_copy(root->query_pathkeys));
	}

	/*
	 * Even if we're not using remote estimates, having the remote side do the
	 * sort generally won't be any worse than doing it locally, and it might
	 * be much better if the remote side can generate data in the right order
	 * without needing a sort at all.  However, what we're going to do next is
	 * try to generate pathkeys that seem promising for possible merge joins,
	 * and that's more speculative.  A wrong choice might hurt quite a bit, so
	 * bail out if we can't use remote estimates.
	 */
	if (!fpinfo->use_remote_estimate)
		return useful_pathkeys_list;

	/* Get the list of interesting EquivalenceClasses. */
	useful_eclass_list = get_useful_ecs_for_relation(root, rel);

	/* Extract unique EC for query, if any, so we don't consider it again. */
	if (list_length(root->query_pathkeys) == 1)
	{
		PathKey    *query_pathkey = linitial(root->query_pathkeys);

		query_ec = query_pathkey->pk_eclass;
	}

	/*
	 * As a heuristic, the only pathkeys we consider here are those of length
	 * one.  It's surely possible to consider more, but since each one we
	 * choose to consider will generate a round-trip to the remote side, we
	 * need to be a bit cautious here.  It would sure be nice to have a local
	 * cache of information about remote index definitions...
	 */
	foreach(lc, useful_eclass_list)
	{
		EquivalenceClass *cur_ec = lfirst(lc);
		Expr	   *em_expr;
		PathKey    *pathkey;

		/* If redundant with what we did above, skip it. */
		if (cur_ec == query_ec)
			continue;

		/* If no pushable expression for this rel, skip it. */
		em_expr = find_em_expr_for_rel(cur_ec, rel);
		if (em_expr == NULL || !is_foreign_expr(root, rel, em_expr))
			continue;

		/* Looks like we can generate a pathkey, so let's do it. */
		pathkey = make_canonical_pathkey(root, cur_ec,
										 linitial_oid(cur_ec->ec_opfamilies),
										 BTLessStrategyNumber,
										 false);
		useful_pathkeys_list = lappend(useful_pathkeys_list,
									   list_make1(pathkey));
	}

	return useful_pathkeys_list;
}


static void
add_paths_with_pathkeys_for_rel(PlannerInfo *root, RelOptInfo *rel,
								Path *epq_path)
{
	List	   *useful_pathkeys_list = NIL; /* List of all pathkeys */
	ListCell   *lc;

	useful_pathkeys_list = get_useful_pathkeys_for_relation(root, rel);

	/* Create one path for each set of pathkeys we found above. */
	foreach(lc, useful_pathkeys_list)
	{
		double		rows;
		int			width;
		Cost		startup_cost;
		Cost		total_cost;
		List	   *useful_pathkeys = lfirst(lc);

		estimate_path_cost_size(root, rel, NIL, useful_pathkeys,
								&rows, &width, &startup_cost, &total_cost);

		add_path(rel, (Path *)
				 create_foreignscan_path(root, rel,
										 NULL,
										 rows,
										 startup_cost,
										 total_cost,
										 useful_pathkeys,
										 NULL,
										 epq_path,
										 NIL));
	}
}

/*
 * mysqlGetForeignPaths: Get the foreign paths
 */
static void
tinybraceGetForeignPaths(PlannerInfo *root,RelOptInfo *baserel,Oid foreigntableid)
{
	Cost startup_cost;
	Cost total_cost;
	
	elog(INFO,"tinybraceGetForeignPaths");
	/* Estimate costs */
	tinybraceEstimateCosts(root, baserel, &startup_cost, &total_cost, foreigntableid);

	/* Create a ForeignPath node and add it as only possible path */
	add_path(baserel, (Path *)
			 create_foreignscan_path(root, baserel,
									 NULL,		/* default pathtarget */
									 baserel->rows,
									 startup_cost,
									 total_cost,
									 NIL,	/* no pathkeys */
									 NULL,	/* no outer rel either */
									 NULL,	/* no extra plan */
									 NULL));	/* no fdw_private data */
	add_paths_with_pathkeys_for_rel(root, baserel, NULL);

}


List *
build_tlist_to_deparse(RelOptInfo *foreignrel)
{
	List	   *tlist = NIL;
    TinyBraceFdwRelationInfo *fpinfo = (TinyBraceFdwRelationInfo *) foreignrel->fdw_private;
	ListCell   *lc;

	/*
	 * For an upper relation, we have already built the target list while
	 * checking shippability, so just return that.
	 */
	if (IS_UPPER_REL(foreignrel))
		return fpinfo->grouped_tlist;

	/*
	 * We require columns specified in foreignrel->reltarget->exprs and those
	 * required for evaluating the local conditions.
	 */
	tlist = add_to_flat_tlist(tlist,
							  pull_var_clause((Node *) foreignrel->reltarget->exprs,
											  PVC_RECURSE_PLACEHOLDERS));
	foreach(lc, fpinfo->local_conds)
	{
		RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

		tlist = add_to_flat_tlist(tlist,
								  pull_var_clause((Node *) rinfo->clause,
												  PVC_RECURSE_PLACEHOLDERS));
	}
	return tlist;
}


/*
 * mysqlGetForeignPlan: Get a foreign scan plan node
 */
static ForeignScan *
tinybraceGetForeignPlan(
		PlannerInfo *root
		,RelOptInfo *baserel
		,Oid foreigntableid
		,ForeignPath *best_path
		,List * tlist
		,List *scan_clauses
#if PG_VERSION_NUM >= 90500
		,Plan * outer_plan
#endif
)
{
	TinyBraceFdwRelationInfo *fpinfo = (TinyBraceFdwRelationInfo *) baserel->fdw_private;
	Index          scan_relid = baserel->relid;
	List           *fdw_private;
	List           *local_exprs = NULL;
	List           *remote_exprs = NULL;
	List           *params_list = NULL;
	List           *remote_conds = NIL;
	List	   *fdw_scan_tlist = NIL;
	List	   *fdw_recheck_quals = NIL;


	StringInfoData sql;
	tinybrace_opt      *options;
	List           *retrieved_attrs;
	ListCell       *lc;
	int 			for_update;

	elog(INFO,"tinybraceGetForeignPlan");

	/* Fetch options */
	options = tinybrace_get_options(foreigntableid);

	/*
	 * Build the query string to be sent for execution, and identify
	 * expressions to be sent as parameters.
	 */

	/* Build the query */
	initStringInfo(&sql);

	/*
	 * Separate the scan_clauses into those that can be executed remotely and
	 * those that can't.  baserestrictinfo clauses that were previously
	 * determined to be safe or unsafe by classifyConditions are shown in
	 * fpinfo->remote_conds and fpinfo->local_conds.  Anything else in the
	 * scan_clauses list will be a join clause, which we have to check for
	 * remote-safety.
	 *
	 * Note: the join clauses we see here should be the exact same ones
	 * previously examined by postgresGetForeignPaths.  Possibly it'd be worth
	 * passing forward the classification work done then, rather than
	 * repeating it here.
	 *
	 * This code must match "extract_actual_clauses(scan_clauses, false)"
	 * except for the additional decision about remote versus local execution.
	 * Note however that we only strip the RestrictInfo nodes from the
	 * local_exprs list, since appendWhereClause expects a list of
	 * RestrictInfos.
	 */
	if (IS_SIMPLE_REL(baserel))
	{
		foreach(lc, scan_clauses)
		{
			RestrictInfo *rinfo = (RestrictInfo *) lfirst(lc);

			Assert(IsA(rinfo, RestrictInfo));

			/* Ignore any pseudoconstants, they're dealt with elsewhere */
			if (rinfo->pseudoconstant)
				continue;

			if (list_member_ptr(fpinfo->remote_conds, rinfo))
			{
				remote_conds = lappend(remote_conds, rinfo);
				remote_exprs = lappend(remote_exprs, rinfo->clause);
			}
			else if (list_member_ptr(fpinfo->local_conds, rinfo))
				local_exprs = lappend(local_exprs, rinfo->clause);
			else if (is_foreign_expr(root, baserel, rinfo->clause))
			{
				remote_conds = lappend(remote_conds, rinfo);
				remote_exprs = lappend(remote_exprs, rinfo->clause);
			}
			else
				local_exprs = lappend(local_exprs, rinfo->clause);

			fdw_recheck_quals = remote_exprs;
		}
	} else {
		scan_relid = 0;
		/*
		 * For a join rel, baserestrictinfo is NIL and we are not considering
		 * parameterization right now, so there should be no scan_clauses for
		 * a joinrel or an upper rel either.
		 */
		Assert(!scan_clauses);

		/*
		 * Instead we get the conditions to apply from the fdw_private
		 * structure.
		 */
		remote_exprs = extract_actual_clauses(fpinfo->remote_conds, false);
		local_exprs = extract_actual_clauses(fpinfo->local_conds, false);

		/*
		 * We leave fdw_recheck_quals empty in this case, since we never need
		 * to apply EPQ recheck clauses.  In the case of a joinrel, EPQ
		 * recheck is handled elsewhere --- see postgresGetForeignJoinPaths().
		 * If we're planning an upperrel (ie, remote grouping or aggregation)
		 * then there's no EPQ to do because SELECT FOR UPDATE wouldn't be
		 * allowed, and indeed we *can't* put the remote clauses into
		 * fdw_recheck_quals because the unaggregated Vars won't be available
		 * locally.
		 */

		/* Build the list of columns to be fetched from the foreign server. */
		fdw_scan_tlist = build_tlist_to_deparse(baserel);

		/*
		 * Ensure that the outer plan produces a tuple whose descriptor
		 * matches our scan tuple slot. This is safe because all scans and
		 * joins support projection, so we never need to insert a Result node.
		 * Also, remove the local conditions from outer plan's quals, lest
		 * they will be evaluated twice, once by the local plan and once by
		 * the scan.
		 */
		if (outer_plan)
		{
			ListCell   *lc;

			/*
			 * Right now, we only consider grouping and aggregation beyond
			 * joins. Queries involving aggregates or grouping do not require
			 * EPQ mechanism, hence should not have an outer plan here.
			 */
			Assert(!IS_UPPER_REL(baserel));

			outer_plan->targetlist = fdw_scan_tlist;
#if 0
			foreach(lc, local_exprs)
			{
				Join	   *join_plan = (Join *) outer_plan;
				Node	   *qual = lfirst(lc);

				outer_plan->qual = list_delete(outer_plan->qual, qual);

				/*
				 * For an inner join the local conditions of foreign scan plan
				 * can be part of the joinquals as well.
				 */
				if (join_plan->jointype == JOIN_INNER)
					join_plan->joinqual = list_delete(join_plan->joinqual,
													  qual);
			}
#endif
		}
	}

	//tinybrace_deparse_select(&sql, root, baserel, fpinfo->attrs_used, options->svr_table, &retrieved_attrs, fdw_scan_tlist);
	deparseSelectStmtForRel(&sql, root, baserel, fdw_scan_tlist,
							remote_exprs, best_path->path.pathkeys,
							false, &retrieved_attrs, &params_list);
/*
	if (remote_conds)
	  tinybrace_append_where_clause(&sql, root, baserel, remote_conds,
						  true, &params_list);
*/
	for_update = false;
	if (baserel->relid == root->parse->resultRelation &&
		(root->parse->commandType == CMD_UPDATE ||
		root->parse->commandType == CMD_DELETE))
	{
		/* Relation is UPDATE/DELETE target, so use FOR UPDATE */
		for_update = true;
	}

	/*
	 * Build the fdw_private list that will be available to the executor.
	 * Items in the list must match enum FdwScanPrivateIndex, above.
	 */

	fdw_private = list_make3(makeString(sql.data), retrieved_attrs, makeInteger(for_update));

	/*
	 * Create the ForeignScan node from target list, local filtering
	 * expressions, remote parameter expressions, and FDW private information.
	 *
	 * Note that the remote parameter expressions are stored in the fdw_exprs
	 * field of the finished plan node; we can't keep them in private state
	 * because then they wouldn't be subject to later planner processing.
	 */
	return make_foreignscan(tlist
	                       ,local_exprs
	                       ,scan_relid
	                       ,params_list
	                       ,fdw_private
#if PG_VERSION_NUM >= 90500
	                       ,fdw_scan_tlist
	                       ,fdw_recheck_quals
	                       ,outer_plan
#endif
	                       );
}

/*
 * mysqlAnalyzeForeignTable: Implement stats collection
 */
static bool
tinybraceAnalyzeForeignTable(Relation relation, AcquireSampleRowsFunc *func, BlockNumber *totalpages)
{
#if 0
	StringInfoData sql;
	double         table_size = 0;
	TBC_CLIENT_HANDLE          *hdl;
	Oid            foreignTableId = RelationGetRelid(relation);
	tinybrace_opt      *options;
	char           *relname;
	ForeignServer  *server;
	UserMapping    *user;
	ForeignTable   *table;
	TBC_RTNCODE rtn;
	int qHandle;

	table = GetForeignTable(foreignTableId);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(relation->rd_rel->relowner, server->serverid);

	/* Fetch options */
	options = tinybrace_get_options(foreignTableId);

	/* Connect to the server */
  hdl = tinybrace_get_connection(server, user, options);

	/* Build the query */
	initStringInfo(&sql);

	/* If no table name specified, use the foreign table name */
	relname = options->svr_table;
	if ( relname == NULL)
			relname = RelationGetRelationName(relation);

	tinybrace_deparse_analyze(&sql, options->svr_database, relname);
	rtn = TBC_query(hdl->connect, sql.data, &qHandle);
	if (rtn != 0)
	{
    /*
		switch(_mysql_errno(conn))
		{
			case CR_NO_ERROR:
				break;

			case CR_OUT_OF_MEMORY:
			case CR_SERVER_GONE_ERROR:
			case CR_SERVER_LOST:
			{
				char *err = pstrdup(_mysql_error(conn));
				mysql_rel_connection(conn);
				ereport(ERROR,
							(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
							errmsg("failed to execute the MySQL query: \n%s", err)));
			}
			break;
			case CR_COMMANDS_OUT_OF_SYNC:
			case CR_UNKNOWN_ERROR:
			default:
			{
				char *err = pstrdup(_mysql_error(conn));
				ereport(ERROR,
							(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
							errmsg("failed to execute the MySQL query: \n%s", err)));
			}
		}
    */
    ereport(ERROR,
            (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
             errmsg("failed to execute the TinyBrace query: \n")));
	}
	//result = _mysql_store_result(conn);
  /*
  ret = _mysql_store_result(conn,result);
	if (ret == TBC_OK)
	{
		row = _mysql_fetch_row(result);
		table_size = atof(row[0]);
		tinybrace_free_result(result);
    }
  */
  table_size = 100;
	*totalpages = table_size / TINYBRACE_BLKSIZ;
	return false;
#endif
}

static List *
tinybracePlanForeignModify(PlannerInfo *root,
                           ModifyTable *plan,
                           Index resultRelation,
                           int subplan_index)
{

	CmdType         operation = plan->operation;
	RangeTblEntry   *rte = planner_rt_fetch(resultRelation, root);
	Relation        rel;
	List            *targetAttrs = NULL;
	List			*condAttr = NULL;
	StringInfoData  sql;
	char            *attname;
	Oid             foreignTableId;
	int i;
	TupleDesc 		tupdesc;


	initStringInfo(&sql);
	elog(INFO,"%s",__func__);

	/*
	 * Core code already has some lock on each rel being planned, so we can
	 * use NoLock here.
	 */
	rel = heap_open(rte->relid, NoLock);

	foreignTableId = RelationGetRelid(rel);

	if (!tinybrace_is_column_unique(foreignTableId))
		elog(ERROR, "first column of remote table must be unique for INSERT/UPDATE/DELETE operation");

	if (operation == CMD_INSERT)
	{
		TupleDesc tupdesc = RelationGetDescr(rel);
		int attnum;

		for (attnum = 1; attnum <= tupdesc->natts; attnum++)
		{
			Form_pg_attribute attr = tupdesc->attrs[attnum - 1];

			if (!attr->attisdropped)
				targetAttrs = lappend_int(targetAttrs, attnum);
		}
	}
	else if (operation == CMD_UPDATE)
	{
		Bitmapset *tmpset = bms_copy(rte->updatedCols);
		AttrNumber	col;

		while ((col = bms_first_member(tmpset)) >= 0)
		{
			col += FirstLowInvalidHeapAttributeNumber;
			if (col <= InvalidAttrNumber)		/* shouldn't happen */
				elog(ERROR, "system-column update is not supported");
			/*
			 * We also disallow updates to the first column
			 */
			if (col == 1)	/* shouldn't happen */
				elog(ERROR, "row identifier column update is not supported");

			targetAttrs = lappend_int(targetAttrs, col);
		}
		/* We also want the rowid column to be available for the update */
		targetAttrs = lcons_int(1, targetAttrs);
	}
	else
	{
		targetAttrs = lcons_int(1, targetAttrs);
	}

//	attname = get_relid_attribute_name(foreignTableId, 1);


	if (plan->returningLists)
		elog(ERROR, "RETURNING is not supported by this FDW");

	if (plan->onConflictAction != ONCONFLICT_NONE)
		elog(ERROR, "not suport ON CONFLICT: %d",
			 (int) plan->onConflictAction);

	/* Add all primary key attribute names to condAttr used in where clause of update */
	for (i = 0; i < tupdesc->natts; ++i)
	{
		Form_pg_attribute att = TupleDescAttr(tupdesc, i);
		AttrNumber attrno = att->attnum;
		List *options;
		ListCell *option;

		/* look for the "key" option on this column */
		options = GetForeignColumnOptions(foreignTableId, attrno);
		foreach (option, options)
		{
			DefElem *def = (DefElem *)lfirst(option);

			if (strcmp(def->defname, "key") == 0 &&
				strcmp(((Value *)(def->arg))->val.str, "true") == 0)
			{
				attname = get_relid_attribute_name(foreignTableId, attrno);
				condAttr = lappend(condAttr, attname);
			}
		}
	}



	/*
	 * Construct the SQL command string.
	 */
	switch (operation)
	{
		case CMD_INSERT:
			tinybrace_deparse_insert(&sql, root, resultRelation, rel, targetAttrs);
			break;
		case CMD_UPDATE:
			tinybrace_deparse_update(&sql, root, resultRelation, rel, targetAttrs, attname);
			break;
		case CMD_DELETE:
		  tinybrace_deparse_delete(&sql, root, resultRelation, rel, condAttr);
			break;
		default:
			elog(ERROR, "unexpected operation: %d", (int) operation);
			break;
	}

	if (plan->returningLists)
		elog(ERROR, "RETURNING is not supported by this FDW");

	heap_close(rel, NoLock);
	return list_make2(makeString(sql.data), targetAttrs);
}


/*
 * tinybraceBeginForeignModify: Begin an insert/update/delete operation
 * on a foreign table
 */
static void
tinybraceBeginForeignModify(ModifyTableState *mtstate,
						ResultRelInfo *resultRelInfo,
						List *fdw_private,
						int subplan_index,
						int eflags)
{
	TinyBraceFdwExecState   *fmstate = NULL;
	EState              *estate = mtstate->ps.state;
	Relation            rel = resultRelInfo->ri_RelationDesc;
	AttrNumber          n_params = 0;
	Oid                 typefnoid = InvalidOid;
	bool                isvarlena = false;
	ListCell            *lc = NULL;
	Oid                 foreignTableId = InvalidOid;
	RangeTblEntry       *rte;
	Oid                 userid;
	ForeignServer       *server;
	UserMapping         *user;
	ForeignTable        *table;
	TBC_RTNCODE rtn;
	Plan *subplan = mtstate->mt_plans[subplan_index]->plan;
	int i;

	rte = rt_fetch(resultRelInfo->ri_RangeTableIndex, estate->es_range_table);
	userid = rte->checkAsUser ? rte->checkAsUser : GetUserId();

	foreignTableId = RelationGetRelid(rel);

	table = GetForeignTable(foreignTableId);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(userid, server->serverid);

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case. resultRelInfo->ri_FdwState
	 * stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	/* Begin constructing MongoFdwModifyState. */
	fmstate = (TinyBraceFdwExecState *) palloc0(sizeof(TinyBraceFdwExecState));

	fmstate->rel = rel;
	fmstate->tinybraceFdwOptions = tinybrace_get_options(foreignTableId);
	fmstate->conn = tinybrace_get_connection(server, user, fmstate->tinybraceFdwOptions);

	fmstate->query = strVal(list_nth(fdw_private, 0));
	fmstate->retrieved_attrs = (List *) list_nth(fdw_private, 1);

	n_params = list_length(fmstate->retrieved_attrs) + 1;
	fmstate->p_flinfo = (FmgrInfo *) palloc0(sizeof(FmgrInfo) * n_params);
	fmstate->p_nums = 0;
	fmstate->temp_cxt = AllocSetContextCreate(estate->es_query_cxt,
											  "tinybrace_fdw temporary data",
											  ALLOCSET_SMALL_MINSIZE,
											  ALLOCSET_SMALL_INITSIZE,
											  ALLOCSET_SMALL_MAXSIZE);

	/* Set up for remaining transmittable parameters */
	foreach(lc, fmstate->retrieved_attrs)
	{
		int attnum = lfirst_int(lc);
		Form_pg_attribute attr = RelationGetDescr(rel)->attrs[attnum - 1];

		Assert(!attr->attisdropped);

		getTypeOutputInfo(attr->atttypid, &typefnoid, &isvarlena);
		fmgr_info(typefnoid, &fmstate->p_flinfo[fmstate->p_nums]);
		fmstate->p_nums++;
	}
	Assert(fmstate->p_nums <= n_params);

	n_params = list_length(fmstate->retrieved_attrs);

	/* Prepare tinybrace statment */
#if 1
	rtn = TBC_prepare_stmt(fmstate->conn->connect, fmstate->query, &fmstate->qHandle);
	if ( rtn != 0)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("failed to prepare the TinyBrace query: \n")));
	}
#endif
	resultRelInfo->ri_FdwState = fmstate;
	fmstate->junk_idx = palloc0(RelationGetDescr(rel)->natts * sizeof(AttrNumber));
	/* loop through table columns */
	for (i=0; i<RelationGetDescr(rel)->natts; ++i)
	{
		/* for primary key columns, get the resjunk attribute number and store it */
		fmstate->junk_idx[i] =
			ExecFindJunkAttributeInTlist(subplan->targetlist, get_relid_attribute_name(foreignTableId, i+1));
	}

}


/*
 * tinybraceExecForeignInsert: Insert one row into a foreign table
 */
static TupleTableSlot *
tinybraceExecForeignInsert(EState *estate,
					   ResultRelInfo *resultRelInfo,
					   TupleTableSlot *slot,
					   TupleTableSlot *planSlot)
{
	TinyBraceFdwExecState   *fmstate;
	ListCell            *lc;
	Datum               value = 0;
	int                 n_params = 0;
	MemoryContext       oldcontext;
	TBC_RTNCODE rtn;
	int					nestlevel;

	elog(INFO," %s",__func__);

	fmstate = (TinyBraceFdwExecState *) resultRelInfo->ri_FdwState;
	n_params = list_length(fmstate->retrieved_attrs);

	oldcontext = MemoryContextSwitchTo(fmstate->temp_cxt);
	nestlevel = set_transmission_modes();

	/* Bind values */
	foreach(lc, fmstate->retrieved_attrs)
	{
		int attnum = lfirst_int(lc) - 1;

		bool *isnull = (bool*) palloc0(sizeof(bool) * n_params);
		Oid type = slot->tts_tupleDescriptor->attrs[attnum]->atttypid;
		value = slot_getattr(slot, attnum + 1, &isnull[attnum]);
	    rtn = tinybrace_bind_sql_var(type, attnum, value, fmstate->qHandle, &isnull[attnum], fmstate->qHandle, fmstate->conn->connect);
		if(rtn != TBC_OK){
			elog(ERROR,"TBC bind failed");
		}
	}
	/* Execute the query */
	rtn = TBC_execute( fmstate->conn->connect, fmstate->qHandle );
	if(rtn != TBC_OK){
		elog(ERROR,"TBC_execute INSERT failed");
	}
	MemoryContextSwitchTo(oldcontext);
	MemoryContextReset(fmstate->temp_cxt);
	return slot;
}

static TupleTableSlot *
tinybraceExecForeignUpdate(EState *estate,
					   ResultRelInfo *resultRelInfo,
					   TupleTableSlot *slot,
					   TupleTableSlot *planSlot)
{
	TinyBraceFdwExecState *fmstate = (TinyBraceFdwExecState *) resultRelInfo->ri_FdwState;
	Relation          rel = resultRelInfo->ri_RelationDesc;
	Oid               foreignTableId = RelationGetRelid(rel);
	bool              is_null = false;
	ListCell          *lc = NULL;
	int               bindnum = 0;
	Oid               typeoid;
	Datum             value = 0;
	int               n_params = 0;
	bool              *isnull = NULL;
	int               i = 0;
	TBC_RTNCODE rtn;

	elog(INFO," %s",__func__);

	n_params = list_length(fmstate->retrieved_attrs);

	isnull = palloc0(sizeof(bool) * n_params);

	/* Bind the values */
	foreach(lc, fmstate->retrieved_attrs)
	{
		int attnum = lfirst_int(lc);
		Oid type;

		/* first attribute cannot be in target list attribute */
		if (attnum == 1)
			continue;

		type = slot->tts_tupleDescriptor->attrs[attnum - 1]->atttypid;
		value = slot_getattr(slot, attnum, (bool*)(&isnull[i]));
	    tinybrace_bind_sql_var(type, bindnum, value, fmstate->qHandle, &isnull[i],fmstate->conn->connect);
		bindnum++;
		i++;
	}

	/* Get the id that was passed up as a resjunk column */
	value = ExecGetJunkAttribute(planSlot, 1, &is_null);
	typeoid = get_atttype(foreignTableId, 1);

	/* Bind qual */
	for (i = 0; i < slot->tts_tupleDescriptor->natts; ++i)
	{
				Form_pg_attribute att = TupleDescAttr(slot->tts_tupleDescriptor, i);
		AttrNumber attrno = att->attnum;// - slot->tts_tupleDescriptor->natts;
		List *options;
		ListCell *option;
		/* look for the "key" option on this column */
		if (fmstate->junk_idx[i] == InvalidAttrNumber)
			continue;
		options = GetForeignColumnOptions(foreignTableId, attrno);
		foreach (option, options)
		{
			DefElem *def = (DefElem *)lfirst(option);

			if (strcmp(def->defname, "key") == 0 &&
				strcmp(((Value *)(def->arg))->val.str, "true") == 0)
			{
				/* Get the id that was passed up as a resjunk column */
				value = ExecGetJunkAttribute(planSlot, fmstate->junk_idx[i], &is_null);
				typeoid = att->atttypid;//get_atttype(foreignTableId, attrno + 1);
				
				/* Bind qual */
				rtn = tinybrace_bind_sql_var(typeoid, bindnum, value, fmstate->qHandle, &isnull, fmstate->conn->connect);
				if(rtn != TBC_OK){
					elog(ERROR,"TBC bind failed");
				}
				bindnum++;
			}
		}
	}
	/* Execute the query */
	rtn = TBC_execute( fmstate->conn->connect, fmstate->qHandle );
	if(rtn != TBC_OK){
		elog(ERROR,"TBC_execute UPDATE failed");
	}
	/* Return NULL if nothing was updated on the remote end */
	return slot;
}


/*
 * tinybraceAddForeignUpdateTargets: Add column(s) needed for update/delete on a foreign table,
 * we are using first column as row identification column, so we are adding that into target
 * list.
 */
static void
tinybraceAddForeignUpdateTargets(Query *parsetree,
							 RangeTblEntry *target_rte,
							 Relation target_relation)
{
	Var         *var = NULL;
	const char  *attrname = NULL;
	TargetEntry *tle = NULL;

	/*
	 * What we need is the rowid which is the first column
	 */
	Form_pg_attribute attr =
	RelationGetDescr(target_relation)->attrs[0];

	/* Make a Var representing the desired value */
	var = makeVar(parsetree->resultRelation,
				  1,
				  attr->atttypid,
				  attr->atttypmod,
				  InvalidOid,
				  0);

	/* Wrap it in a TLE with the right name ... */
	attrname = NameStr(attr->attname);

	tle = makeTargetEntry((Expr *) var,
						  list_length(parsetree->targetList) + 1,
						  pstrdup(attrname),
						  true);

	/* ... and add it to the query's targetlist */
	parsetree->targetList = lappend(parsetree->targetList, tle);
}


/*
 * MongoExecForeignDelete: Delete one row from a foreign table
 */
static TupleTableSlot *
tinybraceExecForeignDelete(EState *estate,
					   ResultRelInfo *resultRelInfo,
					   TupleTableSlot *slot,
					   TupleTableSlot *planSlot)
{
	TinyBraceFdwExecState    *fmstate = (TinyBraceFdwExecState *) resultRelInfo->ri_FdwState;
	Relation             rel = resultRelInfo->ri_RelationDesc;
	Oid                  foreignTableId = RelationGetRelid(rel);
	bool                 is_null = false;
	int                  bindnum = 0;
	Oid                  typeoid;
	Datum                value = 0;
	int i;
	TBC_RTNCODE rtn;

	elog(INFO," %s",__func__);

	for (i = 0; i < slot->tts_tupleDescriptor->natts; ++i)
	{
		Form_pg_attribute att = TupleDescAttr(slot->tts_tupleDescriptor, i);
		AttrNumber attrno = att->attnum;// - slot->tts_tupleDescriptor->natts;
		List *options;
		ListCell *option;
		/* look for the "key" option on this column */
		if (fmstate->junk_idx[i] == InvalidAttrNumber)
			continue;
		
		options = GetForeignColumnOptions(foreignTableId, attrno);
		foreach (option, options)
		{
			DefElem *def = (DefElem *)lfirst(option);
			/* TODO move to functions */
			if (strcmp(def->defname, "key") == 0 &&
				strcmp(((Value *)(def->arg))->val.str, "true") == 0)
			{
				/* Get the id that was passed up as a resjunk column */
				value = ExecGetJunkAttribute(planSlot, fmstate->junk_idx[i], &is_null);
				typeoid = att->atttypid;//get_atttype(foreignTableId, attrno + 1);
				
				/* Bind qual */
				rtn = tinybrace_bind_sql_var(typeoid, bindnum, value, fmstate->qHandle, &is_null, fmstate->qHandle, fmstate->conn->connect);
				if(rtn != TBC_OK){
					elog(ERROR,"TBC bind failed");
				}
				bindnum++;
			}
		}
	}
	/* Execute the query */
	rtn = TBC_execute( fmstate->conn->connect, fmstate->qHandle );
	if(rtn != TBC_OK){
		elog(ERROR,"TBC_execute INSERT failed");
	}
	/* Return NULL if nothing was updated on the remote end */
	return slot;
}

static void
tinybraceEndForeignModify(EState *estate, ResultRelInfo *resultRelInfo)
{

	TinyBraceFdwExecState *festate = (TinyBraceFdwExecState *) resultRelInfo->ri_FdwState;

	elog(INFO," %s",__func__);

    if (festate->table)
    {
         if (festate->table->result_set != NULL ) {
           TBC_free_result(festate->conn->connect, 0, festate->table->result_set);
           festate->table->result_set = NULL;
         }
       }

	if (festate->qHandle != 0)
	{
		TBC_finalize_stmt(festate->conn->connect,festate->qHandle);
		festate->qHandle = 0;
	}
}

static void tinybraceTranslateType(StringInfo str, char *typname)
{
	char *type;

	/*
	 * get lowercase typname. We use C collation since the original type name
	 * should not contain exotic character.
	 */
	type = str_tolower(typname, strlen(typname), C_COLLATION_OID);

	/* try some easy conversion, from https://www.sqlite.org/datatype3.html */
	if (strcmp(type, "tinyint") == 0)
		appendStringInfoString(str, "smallint");

	else if (strcmp(type, "mediumint") == 0)
		appendStringInfoString(str, "integer");

	else if (strcmp(type, "unsigned big int") == 0)
		appendStringInfoString(str, "bigint");

	else if (strcmp(type, "double") == 0)
		appendStringInfoString(str, "double precision");

	else if (strcmp(type, "datetime") == 0)
		appendStringInfoString(str, "timestamp");

	else if (strcmp(type, "nvarchar text") == 0)
		appendStringInfoString(str, "text");

	else if (strcmp(type, "longvarchar") == 0)
	     appendStringInfoString(str, "text");

	else if (strncmp(type, "text", 4) == 0)
	     appendStringInfoString(str, "text");

	else if (strcmp(type, "blob") == 0)
	     appendStringInfoString(str, "bytea");

	else if (strcmp(type, "integer") == 0)
	     /* Type "integer" appears dynamically sized between 1 and 8
	      * bytes.  Need to assume worst case. */
	     appendStringInfoString(str, "bigint");

	/* XXX try harder handling sqlite datatype */

	/* if original type is compatible, return lowercase value */
	else
		appendStringInfoString(str, type);

	pfree(type);
}
/*
 * Import a foreign schema (9.5+)
 */
static List *
tinybraceImportForeignSchema(ImportForeignSchemaStmt *stmt,
							 Oid serverOid)
{
    StringInfoData buf;
    ForeignServer  *server;
    UserMapping    *user;
    TBC_CLIENT_HANDLE   *conn = NULL;
	tinybrace_opt            *options = NULL;
	StringInfoData	query_tbl;
    TBC_QUERY_HANDLE qHandle = 0;
    TBC_QUERY_HANDLE qHandle_tbl_schema = 0;
	TBC_RESULT_SET result = { 0 };
	TBC_RESULT_SET result_tbl_schema = { 0 };
	int j,k;
    ListCell       *lc;
    bool           import_default = false;
    bool           import_not_null = true;
	TBC_RTNCODE rc;
	List		   *commands = NIL;

	if (strcmp(stmt->remote_schema, "public") != 0 &&
		strcmp(stmt->remote_schema, "main") != 0)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_SCHEMA_NOT_FOUND),
				 errmsg("Foreign schema \"%s\" is invalid", stmt->remote_schema)
					));
	}

    server = GetForeignServer(serverOid);
    user = GetUserMapping(GetUserId(), server->serverid);
	options = tinybrace_get_options(serverOid);
	conn = tinybrace_get_connection(server, user, options);

    initStringInfo(&buf);

	/* Parse statement options */
	foreach(lc, stmt->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, "import_default") == 0)
			import_default = defGetBoolean(def);
		else if (strcmp(def->defname, "import_not_null") == 0)
			import_not_null = defGetBoolean(def);
		else
			ereport(ERROR,
					(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
					 errmsg("invalid option \"%s\"", def->defname)));
	}
		/* You want all tables, except system tables */
	initStringInfo(&query_tbl);
	appendStringInfo(&query_tbl, "SELECT name FROM sqlite_master WHERE type = 'table'");
	appendStringInfo(&query_tbl, " AND name NOT LIKE 'sqlite_%%' AND name NOT LIKE 'tbe_%%'");
	if (stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO ||
		stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)
	{
		bool		first_item = true;

		appendStringInfoString(&query_tbl, " AND name ");
		if (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)
			appendStringInfoString(&query_tbl, "NOT ");
		appendStringInfoString(&query_tbl, "IN (");

		foreach(lc, stmt->table_list)
		{
			RangeVar *rv = (RangeVar *) lfirst(lc);

			if (first_item)
				first_item = false;
			else
				appendStringInfoString(&query_tbl, ", ");

			appendStringInfoString(&query_tbl, quote_literal_cstr(rv->relname));
		}
		appendStringInfoChar(&query_tbl, ')');
	}
	rc = TBC_query(conn->connect ,query_tbl.data,&qHandle); 
	if(rc != TBC_OK){
		elog(ERROR,"Tinybrace query error : %s",query_tbl.data);
	}
	rc = TBC_store_result(conn->connect, qHandle, &result);
	if ( rc != TBC_OK )
	{
		elog(ERROR,"Tinybrace store result error : %s",query_tbl.data);
	}
	for (k = 0; k < result.nRow && k < result.nRow; k++) {
		StringInfoData	cft_stmt;
		char		   *tbl_name;
		int				i = 0;
		char		   *query_cols;

		tbl_name = result.arData[k][0].value;

		initStringInfo(&cft_stmt);
		appendStringInfo(&cft_stmt, "CREATE FOREIGN TABLE %s.%s (\n",
						 stmt->local_schema, quote_identifier(tbl_name));

		query_cols = palloc0(strlen(tbl_name) + 19 + 1);
		sprintf(query_cols, "PRAGMA table_info(%s)",tbl_name);
		rc = TBC_query(conn->connect, query_cols,&qHandle_tbl_schema);
		if(rc != TBC_OK){
			elog(ERROR,"Tinybrace query error : %s",query_cols);
		}
		rc = TBC_store_result(conn->connect, qHandle_tbl_schema, &result_tbl_schema);
		if ( rc != TBC_OK )
		{
			elog(ERROR,"Tinybrace store result error : %s",query_cols);
		}
		for (j = 0; j < result_tbl_schema.nRow && j < result_tbl_schema.nRow; j++) {
			char   *col_name;
			char   *typ_name;
			bool	not_null;
			char   *default_val;

			col_name = result_tbl_schema.arData[j][1].value;
			typ_name = result_tbl_schema.arData[j][2].value;
			not_null = (result_tbl_schema.arData[j][3].value == 1);
			default_val = result_tbl_schema.arData[j][4].value;

			if (i != 0)
				appendStringInfo(&cft_stmt, ",\n");

			/* table name */
			appendStringInfo(&cft_stmt, "%s ",
							 quote_identifier(col_name));

			/* translated datatype */
			tinybraceTranslateType(&cft_stmt, typ_name);

			if (not_null && import_not_null)
				appendStringInfo(&cft_stmt, " NOT NULL");

			if (default_val && import_default)
				appendStringInfo(&cft_stmt, " DEFAULT %s", default_val);
			i++;
		}
		appendStringInfo(&cft_stmt, "\n) SERVER %s\n"
						 "OPTIONS (table_name '%s')",
						 quote_identifier(stmt->server_name),
						 quote_identifier(tbl_name));
		commands = lappend(commands,pstrdup(cft_stmt.data));
    	/* free per-table allocated data */
        pfree(query_cols);
		pfree(cft_stmt.data);
		rc = TBC_free_result(conn->connect,qHandle_tbl_schema, &result_tbl_schema);
	}

   	/* Free all needed data and close connection*/
	pfree(query_tbl.data);
	rc = TBC_free_result(conn->connect,qHandle, &result);
	return commands;
}




/*
 * Force assorted GUC parameters to settings that ensure that we'll output
 * data values in a form that is unambiguous to the remote server.
 *
 * This is rather expensive and annoying to do once per row, but there's
 * little choice if we want to be sure values are transmitted accurately;
 * we can't leave the settings in place between rows for fear of affecting
 * user-visible computations.
 *
 * We use the equivalent of a function SET option to allow the settings to
 * persist only until the caller calls reset_transmission_modes().  If an
 * error is thrown in between, guc.c will take care of undoing the settings.
 *
 * The return value is the nestlevel that must be passed to
 * reset_transmission_modes() to undo things.
 */
int
set_transmission_modes(void)
{
	int			nestlevel = NewGUCNestLevel();

	/*
	 * The values set here should match what pg_dump does.  See also
	 * configure_remote_session in connection.c.
	 */
	if (DateStyle != USE_ISO_DATES)
		(void) set_config_option("datestyle", "ISO",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);

	if (IntervalStyle != INTSTYLE_POSTGRES)
		(void) set_config_option("intervalstyle", "postgres",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);
	if (extra_float_digits < 3)
		(void) set_config_option("extra_float_digits", "3",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);

	return nestlevel;
}

/*
 * Undo the effects of set_transmission_modes().
 */
void
reset_transmission_modes(int nestlevel)
{
	AtEOXact_GUC(true, nestlevel);
}

/*
 * Prepare for processing of parameters used in remote query.
 */
static void
prepare_query_params(PlanState *node,
					 List *fdw_exprs,
					 int numParams,
					 FmgrInfo **param_flinfo,
					 List **param_exprs,
					 const char ***param_values,
					 Oid **param_types)
{
	int			i;
	ListCell   *lc;

	Assert(numParams > 0);

	/* Prepare for output conversion of parameters used in remote query. */
	*param_flinfo = (FmgrInfo *) palloc0(sizeof(FmgrInfo) * numParams);

	*param_types = (Oid *) palloc0(sizeof(Oid) * numParams);

	i = 0;
	foreach(lc, fdw_exprs)
	{
		Node	   *param_expr = (Node *) lfirst(lc);
		Oid			typefnoid;
		bool		isvarlena;

		*param_types[i] = exprType(param_expr);

		getTypeOutputInfo(exprType(param_expr), &typefnoid, &isvarlena);
		fmgr_info(typefnoid, &(*param_flinfo)[i]);
		i++;
	}

	/*
	 * Prepare remote-parameter expressions for evaluation.  (Note: in
	 * practice, we expect that all these expressions will be just Params, so
	 * we could possibly do something more efficient than using the full
	 * expression-eval machinery for this.  But probably there would be little
	 * benefit, and it'd require postgres_fdw to know more than is desirable
	 * about Param evaluation.)
	 */
	*param_exprs = (List *) ExecInitExpr((Expr *) fdw_exprs, node);

	/* Allocate buffer for text form of query parameters. */
	*param_values = (const char **) palloc0(numParams * sizeof(char *));
}

/*
 * Construct array of query parameter values in text format.
 */
static void
process_query_params(ExprContext *econtext,
					 FmgrInfo *param_flinfo,
					 List *param_exprs,
					 const char **param_values,
					 TBC_QUERY_HANDLE qHandle,
					 TBC_CONNECT_HANDLE connect,
					 Oid *param_types)
{
	int			nestlevel;
	int			i;
	ListCell   *lc;

	nestlevel = set_transmission_modes();

	i = 0;
	foreach(lc, param_exprs)
	{
		ExprState  *expr_state = (ExprState *) lfirst(lc);
		Datum		expr_value;
		bool		isNull;

		/* Evaluate the parameter expression */
		//expr_value = ExecEvalExpr(expr_state, econtext, &isNull, NULL);
		expr_value = ExecEvalExpr(expr_state, econtext, &isNull);
        tinybrace_bind_sql_var(param_types[i], i, expr_value, qHandle, &isNull, connect);

		/*
		 * Get string representation of each parameter value by invoking
		 * type-specific output function, unless the value is null.
		 */
		if (isNull)
			param_values[i] = NULL;
		else
			param_values[i] = OutputFunctionCall(&param_flinfo[i], expr_value);
		i++;
	}

	reset_transmission_modes(nestlevel);
}

/*
 * Create cursor for node's query with current parameter values.
 */
static void
create_cursor(ForeignScanState *node)
{
	TinyBraceFdwExecState   *festate = (TinyBraceFdwExecState *) node->fdw_state;
	ExprContext *econtext = node->ss.ps.ps_ExprContext;
	int			numParams = festate->numParams;
	const char **values = festate->param_values;
	//MYSQL_BIND *mysql_bind_buffer = NULL;

	/*
	 * Construct array of query parameter values in text format.  We do the
	 * conversions in the short-lived per-tuple context, so as not to cause a
	 * memory leak over repeated scans.
	 */
	if (numParams > 0)
	{
		MemoryContext oldcontext;

		oldcontext = MemoryContextSwitchTo(econtext->ecxt_per_tuple_memory);

		process_query_params(econtext,
							 festate->param_flinfo,
							 festate->param_exprs,
							 values,
							 festate->qHandle,
							 festate->conn->connect,
							 festate->param_types);

		//_mysql_stmt_bind_param(festate->stmt, mysql_bind_buffer);
		/* Mark the cursor as created, and show no tuples have been retrieved */
		festate->cursor_exists = true;

		MemoryContextSwitchTo(oldcontext);
	}
}

