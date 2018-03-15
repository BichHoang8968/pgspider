/*-------------------------------------------------------------------------
 *
 * mysql_query.h
 * 		Foreign-data wrapper for remote MySQL servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 		mysql_query.h
 *
 *-------------------------------------------------------------------------
 */

#ifndef MYSQL_QUERY_H
#define MYSQL_QUERY_H

#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/relation.h"
#include "utils/rel.h"


//Datum mysql_convert_to_pg(Oid pgtyp, int pgtypmod, mysql_column *column);
//void mysql_bind_sql_var(Oid type, int attnum, Datum value, MYSQL_BIND *binds, bool *isnull);
//void tinybrace_bind_result(Oid pgtyp, int pgtypmod, MYSQL_FIELD *field, mysql_column *column);
Datum tinybrace_convert_to_pg(Oid pgtyp, int pgtypmod, TBC_DATA *column);

#endif /* MYSQL_QUERY_H */
