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
#include "nodes/pathnodes.h"
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

#endif							/* SPD_FDW_H */
