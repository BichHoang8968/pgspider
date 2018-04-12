/*-------------------------------------------------------------------------
 *
 * spd_fdw.h
 *		  Foreign-data wrapper for remote PostgreSQL servers
 *
 * Portions Copyright (c) 2012-2015, PostgreSQL Global Development Group
 *
 * IDENTIFICATION
 *		  contrib/spd_fdw/spd_fdw.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef SPD_FDW_H
#define SPD_FDW_H

#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/relation.h"
#include "utils/relcache.h"

#include "libpq-fe.h"

/* in spd_fdw.c */
extern int	spd_set_transmission_modes(void);
extern void spd_reset_transmission_modes(int nestlevel);

/* in connection.c */
extern PGconn *GetConnection(ForeignServer *server, UserMapping *user,
			  bool will_prep_stmt);
extern void ReleaseConnection(PGconn *conn);
extern unsigned int GetCursorNumber(PGconn *conn);
extern unsigned int GetPrepStmtNumber(PGconn *conn);
extern void pgfdw_report_error(int elevel, PGresult *res, PGconn *conn,
				   bool clear, const char *sql);

/* in option.c */
extern int ExtractConnectionOptions(List *defelems,
						 const char **keywords,
						 const char **values);

/* in deparse.c */
extern void spd_classifyConditions(PlannerInfo *root,
				   RelOptInfo *baserel,
				   List *input_conds,
				   List **remote_conds,
				   List **local_conds);
extern bool spd_is_foreign_expr(PlannerInfo *root,
				RelOptInfo *baserel,
				Expr *expr);
extern void spd_deparseSelectSql(StringInfo buf,
				 PlannerInfo *root,
				 RelOptInfo *baserel,
				 Bitmapset *attrs_used,
				 List **retrieved_attrs);
extern void spd_appendWhereClause(StringInfo buf,
				  PlannerInfo *root,
				  RelOptInfo *baserel,
				  List *exprs,
				  bool is_first,
				  List **params);
extern void spd_deparseInsertSql(StringInfo buf, PlannerInfo *root,
				 Index rtindex, Relation rel,
				 List *targetAttrs, bool doNothing, List *returningList,
				 List **retrieved_attrs);
extern void spd_deparseUpdateSql(StringInfo buf, PlannerInfo *root,
				 Index rtindex, Relation rel,
				 List *targetAttrs, List *returningList,
				 List **retrieved_attrs);
extern void spd_deparseDeleteSql(StringInfo buf, PlannerInfo *root,
				 Index rtindex, Relation rel,
				 List *returningList,
				 List **retrieved_attrs);
extern void spd_deparseAnalyzeSizeSql(StringInfo buf, Relation rel);
extern void spd_deparseAnalyzeSql(StringInfo buf, Relation rel,
				  List **retrieved_attrs);
extern void spd_deparseStringLiteral(StringInfo buf, const char *val);

#endif   /* SPD_FDW_H */
