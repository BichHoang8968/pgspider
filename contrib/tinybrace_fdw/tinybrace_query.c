/*-------------------------------------------------------------------------
 *
 * tinybrace_query.c
 * 		Foreign-data wrapper for remote Tinybrace servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * Portions Copyright (c) 2017-2018, Toshiba Corporation.
 *
 * IDENTIFICATION
 * 		tinybrace_query.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"

#include "tinybrace_fdw.h"
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

#include <tinybrace.h>

#include "access/reloptions.h"
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
#include "utils/numeric.h"
#include "utils/date.h"
#include "utils/hsearch.h"
#include "utils/syscache.h"
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
#include "catalog/pg_type.h"
#include "funcapi.h"

#include "miscadmin.h"
#include "postmaster/syslogger.h"
#include "storage/fd.h"
#include "utils/builtins.h"
#include "utils/datetime.h"


#include "tinybrace_fdw.h"
#include "tinybrace_query.h"


#define DATE_TINYBRACE_PG(x, y) \
do { \
x->year = y.tm_year; \
x->month = y.tm_mon; \
x->day= y.tm_mday; \
x->hour = y.tm_hour; \
x->minute = y.tm_min; \
x->second = y.tm_sec; \
} while(0);


static int32 tinybrace_from_pgtyp(Oid type);
static int	dec_bin(int n);
static int	bin_dec(int n);


/*
 * convert_tinybrace_to_pg: Convert Tinybrace data into PostgreSQL's compatible data types
 */
Datum
tinybrace_convert_to_pg(Oid pgtyp, int pgtypmod, TBC_DATA * column)
{
	Datum		value_datum = 0;
	Datum		valueDatum = 0;
	regproc		typeinput;
	HeapTuple	tuple;
	int			typemod;
	char	   *str;
	int			rtn;

	str = palloc(sizeof(char) * MAXDATELEN);

	/* get the type's output function */
	tuple = SearchSysCache1(TYPEOID, ObjectIdGetDatum(pgtyp));
	if (!HeapTupleIsValid(tuple))
		elog(ERROR, "cache lookup failed for type%u", pgtyp);

	typeinput = ((Form_pg_type) GETSTRUCT(tuple))->typinput;
	typemod = ((Form_pg_type) GETSTRUCT(tuple))->typtypmod;
	ReleaseSysCache(tuple);

	rtn = tinybrace_from_pgtyp(pgtyp);
	switch (pgtyp)
	{
			/*
			 * Tinybrace gives BIT / BIT(n) data type as decimal value. The
			 * only way to retrieve this value is to use BIN, OCT or HEX
			 * function in Tinybrace, otherwise tinybrace client shows the
			 * actual decimal value, which could be a non - printable
			 * character. For exmple in Tinybrace
			 *
			 * CREATE TABLE t (b BIT(8)); INSERT INTO t SET b = b'1001';
			 * SELECT BIN(b) FROM t; +--------+ | BIN(b) | +--------+ | 1001
			 * | +--------+
			 *
			 * PostgreSQL expacts all binary data to be composed of either '0'
			 * or '1'. Tinybrace gives value 9 hence PostgreSQL reports error.
			 * The solution is to convert the decimal number into equivalent
			 * binary string.
			 */
		case BYTEAOID:
			{
				int			blobsize = *(int *) column->value;

				value_datum = (Datum) palloc0(blobsize + VARHDRSZ);
				memcpy(VARDATA(value_datum), column->value + INTVAL_LEN, blobsize);
				SET_VARSIZE(value_datum, blobsize + VARHDRSZ);
				return PointerGetDatum(value_datum);
			}
		case VARBITOID:
		case BITOID:
			sprintf(str, "%d", dec_bin(column->value));
			valueDatum = CStringGetDatum((char *) str);
			break;
		case INT2OID:
		case INT4OID:
		case INT8OID:
			valueDatum = Int8GetDatum(*(long long int *) column->value);
			return valueDatum;
		case FLOAT4OID:
		case FLOAT8OID:
			valueDatum = Float8GetDatum(*(double *) column->value);
			return valueDatum;
		case TEXTOID:
			sprintf(str, "%s", (char *) column->value);
			valueDatum = CStringGetDatum((char *) str);
			break;
		default:
			sprintf(str, "%s", (char *) column->value);
			valueDatum = CStringGetDatum(str);
	}
	elog(DEBUG3, "get column %s typeinput = %d\n", (char *) valueDatum, typeinput);
	value_datum = OidFunctionCall3(typeinput, valueDatum, ObjectIdGetDatum(InvalidOid), Int32GetDatum(typemod));
	return value_datum;
}


/*
 * tinybrace_from_pgtyp: Give Tinybrace data type for PG type
 */
static int32
tinybrace_from_pgtyp(Oid type)
{
	switch (type)
	{
		case INT2OID:
			return TBC_INT;
		case INT4OID:
			return TBC_INT;
		case INT8OID:
			return TBC_INT64;
		case FLOAT4OID:
			return TBC_FLOAT;
		case FLOAT8OID:
			return TBC_DOUBLE;
		case NUMERICOID:
			return TBC_DOUBLE;
		case BOOLOID:
			return TBC_INT;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
		case JSONOID:
			return TBC_STRING;

		case NAMEOID:
			return TBC_STRING;

		case DATEOID:
			return TBC_STRING;

		case TIMEOID:
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
			return TBC_STRING;

		case BITOID:
			return TBC_INT;

		case BYTEAOID:
			return TBC_BLOB;

		default:
			{
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("cannot convert constant value to TinyBrace value"),
								errhint("Constant value data type: %u", type)));
				break;
			}
	}
}

/*
 * bind_sql_var:
 * Bind the values provided as DatumBind the values and nulls to modify the target table (INSERT/UPDATE)
 */
void
tinybrace_bind_sql_var(Oid type, int attnum, Datum value, TBC_QUERY_HANDLE qHandle, bool *isnull, TBC_CONNECT_HANDLE connect)
{

	TBC_RTNCODE ret = TBC_OK;

	attnum++;
	elog(DEBUG1, "bind %d", attnum);
	/* Avoid to bind buffer in case value is NULL */
	if (*isnull)
	{
		ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_NULL, 0, NULL);
		return;
	}

	switch (type)
	{
		case INT2OID:
			{
				int32		dat = DatumGetInt32(value);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_INT, 0, (void *) &dat);
				break;
			}
		case INT4OID:
			{
				int32		dat = DatumGetInt32(value);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_INT, 0, (void *) &dat);
				break;
			}
		case INT8OID:
			{
				int64		dat = DatumGetInt64(value);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_INT64, 0, (void *) &dat);
				break;
			}

		case FLOAT4OID:

			{
				float4		dat = DatumGetFloat4(value);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_FLOAT, 0, (void *) &dat);
				break;
			}
		case FLOAT8OID:
			{
				float8		dat = DatumGetFloat8(value);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_DOUBLE, 0, (void *) &dat);
				break;
			}

		case NUMERICOID:
			{
				Datum		valueDatum = DirectFunctionCall1(numeric_float8, value);
				float8		dat = DatumGetFloat8(valueDatum);

				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_DOUBLE, 0, (void *) &dat);
				break;
			}
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
		case JSONOID:
		case NAMEOID:
		case TIMEOID:
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
			{
				/* Bind as text because SQLite does not have these types */
				char	   *outputString = NULL;
				Oid			outputFunctionId = InvalidOid;
				bool		typeVarLength = false;

				getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
				outputString = OidOutputFunctionCall(outputFunctionId, value);
				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_STRING, 0, (void *) outputString);
				break;
			}


		case VARBITOID:
		case BITOID:
			{
				int32		dat;
				char	   *outputString = NULL;
				Oid			outputFunctionId = InvalidOid;
				bool		typeVarLength = false;

				getTypeOutputInfo(type, &outputFunctionId, &typeVarLength);
				outputString = OidOutputFunctionCall(outputFunctionId, value);
				dat = bin_dec(atoi(outputString));
				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_INT, 0, (void *) &dat);
				break;
			}

		case BYTEAOID:
			{
				int			len;
				char	   *dat = NULL;
				char	   *result = DatumGetPointer(value);

				if (VARATT_IS_1B(result))
				{
					len = VARSIZE_1B(result) - VARHDRSZ_SHORT;
					dat = VARDATA_1B(result);
				}
				else
				{
					len = VARSIZE_4B(result) - VARHDRSZ;
					dat = VARDATA_4B(result);
				}
				ret = TBC_bind_stmt(connect, qHandle, attnum, TBC_BLOB, len, (void *) &dat);
				break;
			}

		default:
			{
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
								errmsg("cannot convert constant value to tinybrace value %u", type),
								errhint("Constant value data type: %u", type)));
				break;
			}
	}
	if (ret != TBC_OK)
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
						errmsg("Can't convert constant value to tinybrace:"),
						errhint("Constant value data type: %u", type)));

}

static
int
dec_bin(int n)
{
	int			rem,
				i = 1;
	int			bin = 0;

	while (n != 0)
	{
		rem = n % 2;
		n /= 2;
		bin += rem * i;
		i *= 10;
	}
	return bin;
}

static int
bin_dec(int n)
{
	int			dec = 0;
	int			i = 0;
	int			rem;

	while (n != 0)
	{
		rem = n % 10;
		n /= 10;
		dec += rem * pow(2, i);
		++i;
	}
	return dec;
}
