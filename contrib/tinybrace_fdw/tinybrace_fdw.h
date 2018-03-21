/*-------------------------------------------------------------------------
 *
 * mysql_fdw.h
 * 		Foreign-data wrapper for remote MySQL servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 		mysql_fdw.h
 *
 *-------------------------------------------------------------------------
 */

#ifndef TINYBRACE_FDW_H
#define TINYBRACE_FDW_H

#define list_length tinybrace_list_length
#define list_delete tinybrace_list_delete
#define list_free tinybrace_list_free

#include <tinybrace.h>
#undef list_length
#undef list_delete
#undef list_free

#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/relation.h"
#include "utils/rel.h"

#define TINYBRACE_PREFETCH_ROWS	100
#define TINYBRACE_BLKSIZ		(1024 * 4) * 8
#define TINYBRACE_PORT		  5100
#define MAXDATALEN			1024 * 64

#define WAIT_TIMEOUT		0
#define INTERACTIVE_TIMEOUT 0


#define CR_NO_ERROR 0
/*
 * Options structure to store the MySQL
 * server information
 */
typedef struct tinybrace_opt
{
	int           svr_port;               /* MySQL port number */
	char          *svr_address;           /* MySQL server ip address */
	char          *svr_username;          /* MySQL user name */
	char          *svr_password;          /* MySQL password */
	char          *svr_database;          /* MySQL database name */
	char          *svr_table;             /* MySQL table name */
	bool          svr_sa;                 /* MySQL secure authentication */
	char          *svr_init_command;      /* MySQL SQL statement to execute when connecting to the MySQL server. */
	unsigned long max_blob_size;          /* Max blob size to read without truncation */
	bool          use_remote_estimate;    /* use remote estimate for rows */
} tinybrace_opt;

/*
typedef struct mysql_column
{
	Datum         value;
	unsigned long length;
	bool          is_null;
	bool          error;
	MYSQL_BIND    *_mysql_bind;
} mysql_column;
*/
  /*
typedef struct mysql_table
{
	MYSQL_RES *_mysql_res;
	MYSQL_FIELD *_mysql_fields;

	mysql_column *column;
	MYSQL_BIND *_mysql_bind;
} mysql_table;
*/

typedef struct tinybrace_column
{
	Datum         value;
	unsigned long length;
	bool          is_null;
	bool          error;
} tinybrace_column;
typedef struct tinybrace_table
{
	TBC_RESULT_SET *result_set;
	TBC_FIELD_INFO *filed_info;
	int filed_num;
	tinybrace_column *column;
  /*
	mysql_column *column;
	MYSQL_BIND *_mysql_bind;
  */
} tinybrace_table;


/*
 * FDW-specific information for ForeignScanState 
 * fdw_state.
 */
typedef struct TinyBraceFdwExecState
{
	TBC_CLIENT_HANDLE *conn;              /* TinyBrace connection handle */
	TBC_QUERY_HANDLE qHandle;              /* MySQL prepared stament handle */
	TBC_QUERY_HANDLE uqHandle;              /* MySQL prepared stament handle */
	tinybrace_table *table;
	int current_row;
	char            *query;             /* Query string */
	Relation        rel;                /* relcache entry for the foreign table */
	List            *retrieved_attrs;   /* list of target attribute numbers */

	bool		cursor_exists;	    /* have we created the cursor? */
	int		numParams;	    /* number of parameters passed to query */
	FmgrInfo	*param_flinfo;	    /* output conversion functions for them */
	List		*param_exprs;	    /* executable expressions for param values */
	const char	**param_values;	    /* textual values of query parameters */
	Oid		*param_types;	    /* type of query parameters */

	int             p_nums;             /* number of parameters to transmit */
	FmgrInfo        *p_flinfo;          /* output conversion functions for them */

  tinybrace_opt       *tinybraceFdwOptions;   /* MySQL FDW options */

	List            *attr_list;         /* query attribute list */
	List            *column_list;       /* Column list of MySQL Column structures */
	int64			row_nums;			/* number of rows */
	Datum			**rows;				/* all rows of scan */
	bool			**rows_isnull;		/* is null */

	int64			rowidx;				/* current index of rows */
	bool 			for_update;			/* true if this scan is update target */

	/* working memory context */
	MemoryContext   temp_cxt;           /* context for per-tuple temporary data */
	AttrNumber 			*junk_idx;
} TinyBraceFdwExecState;

typedef struct TinyBraceFdwRelationInfo
{
	/* baserestrictinfo clauses, broken down into safe and unsafe subsets. */
	List	   *remote_conds;
	List	   *local_conds;
    /*
	 * True means that the relation can be pushed down. Always true for simple
	 * foreign scan.
	 */
	bool		pushdown_safe;

	/* Actual remote restriction clauses for scan (sans RestrictInfos) */
	List	   *final_remote_exprs;

	/* Bitmap of attr numbers we need to fetch from the remote server. */
	Bitmapset  *attrs_used;

	/* Cost and selectivity of local_conds. */
	QualCost	local_conds_cost;
	Selectivity local_conds_sel;

	/* Selectivity of join conditions */
	Selectivity joinclause_sel;

	/* Estimated size and cost for a scan or join. */
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	/* Costs excluding costs for transferring data from the foreign server */
	Cost		rel_startup_cost;
	Cost		rel_total_cost;

	/* Options extracted from catalogs. */
	bool		use_remote_estimate;
	Cost		fdw_startup_cost;
	Cost		fdw_tuple_cost;
	List	   *shippable_extensions;	/* OIDs of whitelisted extensions */

	/* Cached catalog information. */
	ForeignTable *table;
	ForeignServer *server;
	UserMapping *user;			/* only set in use_remote_estimate mode */

	int			fetch_size;		/* fetch size for this remote table */

	/*
	 * Name of the relation while EXPLAINing ForeignScan. It is used for join
	 * relations but is set for all relations. For join relation, the name
	 * indicates which foreign tables are being joined and the join type used.
	 */
	StringInfo	relation_name;

	/* Join information */
	RelOptInfo *outerrel;
	RelOptInfo *innerrel;
	JoinType	jointype;
	/* joinclauses contains only JOIN/ON conditions for an outer join */
	List	   *joinclauses;	/* List of RestrictInfo */

	/* Grouping information */
	List	   *grouped_tlist;

	/* Subquery information */
	bool		make_outerrel_subquery; /* do we deparse outerrel as a
										 * subquery? */
	bool		make_innerrel_subquery; /* do we deparse innerrel as a
										 * subquery? */
	Relids		lower_subquery_rels;	/* all relids appearing in lower
										 * subqueries */
	/*
	 * Index of the relation.  It is used to create an alias to a subquery
	 * representing the relation.
	 */
	int			relation_index;

} TinyBraceFdwRelationInfo;

/* MySQL Column List */
typedef struct TinyBraceColumn
{
	int   attnum;          /* Attribute number */
	char  *attname;        /* Attribute name */
	int   atttype;         /* Attribute type */
} TinyBraceColumn;

extern bool is_foreign_expr(PlannerInfo *root,
                                RelOptInfo *baserel,
                                Expr *expr);

/*
int ((*_tinybrace_options)(TBC_CLIENTHANDLE *tinybrace,enum tinybrace_option option, const void *arg));
int ((*_tinybrace_stmt_prepare)(MYSQL_STMT *stmt, const char *query, unsigned long length));
int ((*_mysql_stmt_execute)(MYSQL_STMT *stmt));
int ((*_mysql_stmt_fetch)(MYSQL_STMT *stmt));
int ((*_mysql_query)(MYSQL *mysql, const char *q));
bool ((*_mysql_stmt_attr_set)(MYSQL_STMT *stmt, enum enum_stmt_attr_type attr_type, const void *attr));
bool ((*_mysql_stmt_close)(MYSQL_STMT * stmt));
bool ((*_mysql_stmt_reset)(MYSQL_STMT * stmt));
bool ((*_mysql_free_result)(MYSQL_RES *result));
bool ((*_mysql_stmt_bind_param)(MYSQL_STMT *stmt, MYSQL_BIND * bnd));
bool ((*_mysql_stmt_bind_result)(MYSQL_STMT *stmt, MYSQL_BIND * bnd));

MYSQL_STMT	*((*_mysql_stmt_init)(MYSQL *mysql));
MYSQL_RES	*((*_mysql_stmt_result_metadata)(MYSQL_STMT *stmt));
int ((*_mysql_stmt_store_result)(MYSQL *mysql));
MYSQL_ROW	((*_mysql_fetch_row)(MYSQL_RES *result));
MYSQL_FIELD	*((*_mysql_fetch_field)(MYSQL_RES *result));
MYSQL_FIELD	*((*_mysql_fetch_fields)(MYSQL_RES *result));
const char	*((*_mysql_error)(MYSQL *mysql));
void	((*_mysql_close)(MYSQL *sock));
MYSQL_RES* ((*_mysql_store_result)(MYSQL *mysql));

MYSQL	*((*_mysql_init)(MYSQL *mysql));
bool ((*_mysql_ssl_set)(MYSQL *mysql, const char *key, const char *cert, const char *ca, const char *capath, const char *cipher));
MYSQL	*((*_mysql_real_connect)(MYSQL *mysql,
								const char *host,
								const char *user,
								const char *passwd,
								const char *db,
								unsigned int port,
								const char *unix_socket,
								unsigned long clientflag));

const char *((*_mysql_get_host_info)(MYSQL *mysql));
const char *((*_mysql_get_server_info)(MYSQL *mysql));
int ((*_mysql_get_proto_info)(MYSQL *mysql));

unsigned int ((*_mysql_stmt_errno)(MYSQL_STMT *stmt));
unsigned int ((*_mysql_errno)(MYSQL *mysql));
unsigned int ((*_mysql_num_fields)(MYSQL_RES *result));
unsigned int ((*_mysql_num_rows)(MYSQL_RES *result));
*/


void reset_transmission_modes(int nestlevel);
int set_transmission_modes(void);

/* option.c headers */
extern bool tinybrace_is_valid_option(const char *option, Oid context);
extern tinybrace_opt *tinybrace_get_options(Oid foreigntableid);

/* depare.c headers */
extern void tinybrace_deparse_insert(StringInfo buf, PlannerInfo *root, Index rtindex, Relation rel, List *targetAttrs);
extern void tinybrace_deparse_update(StringInfo buf, PlannerInfo *root, Index rtindex, Relation rel, List *targetAttrs, List *attname);
extern void tinybrace_deparse_delete(StringInfo buf, PlannerInfo *root,
				 Index rtindex, Relation rel,
									 List *name);
extern void tinybrace_append_where_clause(StringInfo buf, PlannerInfo *root, RelOptInfo *baserel, List *exprs,
							 bool is_first,List **params);
extern void tinybrace_deparse_analyze(StringInfo buf, char *dbname, char *relname);

extern void
tinybrace_deparseSelectStmtForRel(StringInfo buf, PlannerInfo *root, RelOptInfo *rel,
						List *tlist, List *remote_conds, List *pathkeys,
						bool is_subquery, List **retrieved_attrs,
						List **params_list);

/* connection.c headers */
TBC_CLIENT_HANDLE *tinybrace_get_connection(ForeignServer *server, UserMapping *user, tinybrace_opt *opt);
TBC_CLIENT_HANDLE *tinybrace_connect(char *svr_address, char *svr_username, char *svr_password, char *svr_database,
							 int svr_port, bool svr_sa, char *svr_init_command,
							 char *ssl_key, char *ssl_cert, char *ssl_ca, char *ssl_capath,
							 char *ssl_cipher);
void  tinybrace_cleanup_connection(void);
void tinybrace_rel_connection(TBC_CLIENT_HANDLE *conn);
#endif /* MYSQL_FDW_H */
