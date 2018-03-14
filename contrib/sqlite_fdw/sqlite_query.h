/*-------------------------------------------------------------------------
 *
 * sqlite_query.h
 * 		Foreign-data wrapper for remote Sqlite servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 		sqlite_query.h
 *
 *-------------------------------------------------------------------------
 */

#ifndef SQLITE_QUERY_H
#define SQLITE_QUERY_H

#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/relation.h"
#include "utils/rel.h"


//Datum sqlite_convert_to_pg(Oid pgtyp, int pgtypmod, sqlite_column *column);
void sqlite_bind_sql_var(Oid type, int attnum, Datum value, sqlite3_stmt *stmt, bool *isnull);
//void sqlite_bind_result(Oid pgtyp, int pgtypmod, SQLITE_FIELD *field, sqlite_column *column);

#endif /* SQLITE_QUERY_H */
