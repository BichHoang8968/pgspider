/*-------------------------------------------------------------------------
 *
 * pgspider_core_fdw.h
 *		  Header file of pgspider_core_fdw
 *
 * Portions Copyright (c) 2018-2021, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/pgspider_core_fdw/pgspider_core_fdw.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef PGSPIDER_CORE_FDW_H
#define PGSPIDER_CORE_FDW_H

#include "foreign/fdwapi.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/pathnodes.h"
#include "utils/relcache.h"
#include "utils/resowner.h"
#include "catalog/pg_operator.h"
#include "optimizer/planner.h"

/* For checking single node or multiple node */
#define SPD_SINGLE_NODE	1
#define IS_SPD_MULTI_NODES(nodenum) (nodenum > SPD_SINGLE_NODE)

enum SpdServerstatus
{
	ServerStatusAlive,
	ServerStatusIn,
	ServerStatusDead,
	ServerStatusNotTarget,
};

/* This structure stores child pushdown information about child path. */
typedef struct ChildPushdownInfo
{
	RelOptKind	relkind;			/* Child relation kind. */
	Path		*path;				/* The best child path for child GetForeignPlan. */

	bool		orderby_pushdown;	/* True if child node can pushdown ORDER BY to remote server. */
	bool		limit_pushdown;		/* True if child node can pushdown LIMIT/OFFSET to remote server. */
}			ChildPushdownInfo;

/* This structure stores child information about plan. */
typedef struct ChildInfo
{
	/* USE ONLY IN PLANNING */
	RelOptInfo *baserel;
	RelOptInfo *input_rel_local;	/* Child input relation for creating child upper paths. */
	List	   *url_list;
	AggPath    *aggpath;
#ifdef ENABLE_PARALLEL_S3
	Value	   *s3file;
#endif
	RelOptInfo *joinrel;		/* Child relation info for join pushdown */
	FdwRoutine *fdwroutine;

	ChildPushdownInfo pushdown_info;	/* Child pushdown information */

	/* USE IN BOTH PLANNING AND EXECUTION */
	PlannerInfo *root;
	Plan	   *plan;
	enum SpdServerstatus child_node_status;
	Oid			server_oid;		/* child table's server oid */
	Oid			oid;			/* child table's table oid */
	Agg		   *pAgg;			/* "Aggref" for Disable of aggregation push
								 * down servers */
	bool		pseudo_agg;		/* True if aggregate function is calcuated on
								 * pgspider_core. It mean that it is not
								 * pushed down. This is a cache for searching
								 * pPseudoAggList by server oid. */
	List	   *fdw_private;	/* Private information of child fdw */

	/* USE ONLY IN EXECUTION */
	int			index_threadinfo;	/* index for ForeignScanThreadInfo array */
}			ChildInfo;

typedef enum
{
	SPD_MDF_STATE_INIT,
	SPD_MDF_STATE_BEGIN,
	SPD_MDF_STATE_EXEC,
	SPD_MDF_STATE_PRE_END,
	SPD_MDF_STATE_END,
	SPD_MDF_STATE_FINISH,
	SPD_MDF_STATE_ERROR
}			SpdModifyThreadState;

typedef struct ModifyThreadInfo
{
	struct FdwRoutine *fdwroutine;	/* Foreign Data wrapper  routine */
	struct ModifyTableState *mtstate;	/* ModifyTable state data */
	int			eflags;			/* it used to set on Plan nodes(bitwise OR of
								 * the flag bits ) */
	Oid			serverId;		/* use it for server id */
	ForeignServer *foreignServer;	/* cache this for performance */
	ForeignDataWrapper *fdw;	/* cache this for performance */
	bool		requestExecModify; /* main thread request ExecForeignModify to
									* child thread */
	bool		requestEndModify; /* main thread request EndForeignModify to child
								 * thread */
	TupleTableSlot *slot;
	TupleTableSlot *planSlot;
	int			childInfoIndex; /* index of child info array */
	MemoryContext threadMemoryContext;
	MemoryContext threadTopMemoryContext;
	SpdModifyThreadState state;
	pthread_t	me;
	ResourceOwner thrd_ResourceOwner;
	void	   *private;
	int			transaction_level;
	bool		is_joined;
	int			subplan_index;
}			ModifyThreadInfo;

 /* in pgspider_core_deparse.c */
extern bool spd_is_foreign_expr(PlannerInfo *, RelOptInfo *, Expr *);
extern bool spd_is_having_safe(Node *node);
extern bool spd_is_sorted(Node *node);
extern void spd_deparse_const(Const *node, StringInfo buf, int showtype);
extern char *spd_deparse_type_name(Oid type_oid, int32 typemod);
extern void spd_deparse_string_literal(StringInfo buf, const char *val);
extern void spd_deparse_operator_name(StringInfo buf, Form_pg_operator opform);
extern bool spd_is_stub_star_regex_function(Expr *expr);
extern bool spd_is_record_func(List *tlist);
extern void spd_classifyConditions(PlannerInfo *root,
									RelOptInfo *baserel,
									List *input_conds,
									List **remote_conds,
									List **local_conds);
extern bool spd_expr_has_spdurl(PlannerInfo *root, Node *expr, List **target_exprs);
extern const char *spd_get_jointype_name(JoinType jointype);
extern bool exist_in_string_list(char *funcname, const char **funclist);

 /* in pgspider_core_option.c */
extern int	spdExtractConnectionOptions(List *defelems,
										const char **keywords,
										const char **values);

/* in pgspider_core_option.c */
extern int	spd_get_node_num(RelOptInfo *baserel);

/* in pgspider_core_fdw.c */
Oid spd_serverid_of_relation(Oid foreigntableid);
void spd_calculate_datasouce_count(Oid foreigntableid, int *nums, Oid **oid);
void spd_servername_from_tableoid(Oid foreigntableid, char *srvname);
void spd_ip_from_server_name(char *serverName, char *ip);
List *spd_ParseUrl(List *spd_url_list);
List *spd_create_child_url(List *spd_url_list, ChildInfo *pChildInfo,
						   int node_num, bool status_is_set);

#endif							/* PGSPIDER_CORE_FDW_H */
