/*-------------------------------------------------------------------------
 *
 * contrib/ddsf_fdw/ddsf_fdw_aggregate.c
 *
 *
 *-------------------------------------------------------------------------
 */
#include <stdio.h>
#include <ctype.h>
#include "ddsf_fdw_aggregate.h"
#include "utils/int8.h"
#include "fmgr.h"
#include "utils/bytea.h"
#include "string.h"
#include "utils/memutils.h"
#include <ctype.h>
#include <limits.h>
#include <math.h>
#include "utils/numeric.h"
#include "catalog/pg_type.h"
#include "catalog/pg_collation.h"
#include "utils/varbit.h"
#include "utils/cash.h"
#include "utils/date.h"
#include "ddsf_util.h"
#include <float.h>
#include "executor/spi.h"

#include "access/printtup.h"

/*
 * find_and_replicate
 * Finds and replicates data between 2 patterns and split them using delimiter
 */
void
find_and_replicate(char *o_string, char *start_string, char *end_string, char *delim_string)
{
	char	   *buffer;
	char	   *ch_start = NULL;
	char	   *ch_end = NULL;
	int			len;

	if (!(ch_start = strcasestr(o_string, start_string)))
		return;

	if (!(ch_end = strcasestr(ch_start + strlen(start_string), end_string)))
		return;
	len = ((ch_end - o_string) + 1) + strlen(delim_string) + 1 + (ch_end - ch_start) + 1 + strlen(ch_end) + 1;
	buffer = palloc(len);
	memset(buffer, 0, len);
	strncpy(buffer, o_string, ch_end - o_string);

	strcat(buffer, delim_string);
	strncat(buffer, ch_start, ch_end - ch_start);
	strcat(buffer, ch_end);

	o_string[0] = 0;
	strcpy(o_string, buffer);
}

/*
 * replace
 * Find and replace
 */
void
replace(char *o_string, char *s_string, char *r_string, bool recursive)
{
	/* a buffer variable to do all replace things */
	char	   *buffer;
	int			len;

	/* to store the pointer returned from strstr */
	char	   *ch;

	/* first exit condition */
	if (!(ch = strcasestr(o_string, s_string)))
		return;

	len = strlen(r_string) + strlen(o_string) + (ch - o_string) + strlen(s_string);
	buffer = (char *) palloc(sizeof(char) * len);
	memset(buffer, 0, len);

	/*
	 * copy all the content to buffer before the first occurrence of the
	 * search string
	 */
	strncpy(buffer, o_string, ch - o_string);

	/* prepare the buffer for appending by adding a null to the end of it */
	buffer[ch - o_string] = 0;

	/* append using sprintf function */
	sprintf(buffer + (ch - o_string), "%s%s", r_string, ch + strlen(s_string));

	/* empty o_string for copying */
	o_string[0] = 0;
	strcpy(o_string, buffer);
	pfree(buffer);
	/* pass recursively to replace other occurrences */
	if (recursive)
		return replace(o_string, s_string, r_string, recursive);
	else
		return;
}

/*
 * ddsf_get_node_list
 * read Node conf file and create a node list
 */

/*
 * Get from 
 */
#if 1
int
ddsf_get_node_num(ForeignScanState *node){
	int i;
	char query[512];
	if ((i = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", i);

	sprintf(query,"select relname,oid from pg_class where relname LIKE '%s_\%%';",RelationGetRelationName(node->ss.ss_currentRelation));

	i = SPI_execute(query, true, 0);
	if(i != SPI_OK_SELECT)
		fprintf(stderr,"error\n");
	for (i = 0; i < SPI_processed; i++)
	{
	}
	SPI_finish();
	fprintf(stderr,"ddsf_get_node_nu = %d\n",i);
	return i;
}


int
ddsf_get_node_list(char **list)
{
	int i;
	int ret;
	int			node_count = 0;
	char query[256];

	if ((ret = SPI_connect()) < 0)
		elog(ERROR, "SPI connect failure - returned %d", i);

	sprintf(query,"select foreign_server_name from information_schema._pg_foreign_servers;");
	printf("ddsf_get_node_list %s\n",query);

	i = SPI_execute(query, true, 0);
	if(i != SPI_OK_SELECT)
		printf("%d\n",i);
	for (i = 0; i < SPI_processed; i++)
	{
		char * buffer=NULL;
		if(i==0){
			continue;
		}
		buffer = SPI_getvalue(SPI_tuptable->vals[i],
							  SPI_tuptable->tupdesc,
							  1
			);
		if(buffer !=NULL){
			list[node_count] = buffer;
		}
	}
	SPI_finish();
	return i;
}
#else
int
ddsf_get_node_list(char **list)
{
	/* Case is not considered */
	int			size = NODE_NAME_LEN,
				pos;
	int			c;
	char	   *buffer = NULL;
	int			node_count = 0;

	FILE	   *f = fopen(DDSF_CONF_PATH, "r");

	if (f)
	{
		do
		{
			/* read all lines in file */
			buffer = (char *) palloc(size);
			pos = 0;
			do
			{
				/* read one line */
				c = fgetc(f);
				/* skip the line if it is commented with # */
				if (c == '#')
				{
					while (c != EOF && c != '\n')
					{
						c = fgetc(f);
					}
					break;
				}
				if (c != EOF && c != '\n')
				{
					buffer[pos++] = (char) c;
				}
				if (pos >= size - 1)
				{
					/* increase buffer length - leave room for 0 */
					size *= 2;
					buffer = (char *) repalloc(buffer, size);
				}
			} while (c != EOF && c != '\n');
			/* line is now in buffer */
			if (pos > 0)
			{
				buffer[pos] = 0;
				list[node_count] = buffer;
				node_count++;
			}
			else
			{
				/* if node name is commented with # */
				pfree(buffer);
			}
		} while (c != EOF);
		fclose(f);
	}
	return node_count;

}
#endif
/*
 * ddsf_create_self_node_conn_rel_ID
 * get connections optiosn for the local server and establis connection
 */
PGconn *
ddsf_create_self_scannode_conn_rel_ID(Oid frgnrelID)
{
	const char **keywords;
	const char **values;
	int			n = 0;
	PGconn	   *volatile conn;

	/*
	 * Get foreign Relation ID and associated server options and conenct to
	 * self
	 */
	Oid			relID = frgnrelID;
	ForeignServer *frgn_server = GetForeignServer(GetForeignServerIdByRelId(relID));

	n = list_length(frgn_server->options) + 1;

	/*
	 * n = list_length(server->options) + list_length(user->options) +
	 * 3; Incase usermap are to be used
	 */

	keywords = (const char **) palloc(n * sizeof(char *));
	values = (const char **) palloc(n * sizeof(char *));

	n = 0;
	n += ExtractConnectionOptions(frgn_server->options,
								  keywords + n, values + n);

	keywords[n] = values[n] = NULL;

	/*
	 * n += ExtractConnectionOptions(user->options, keywords + n, values + n);
	 */
	conn = PQconnectdbParams(keywords, values, false);

	if (conn && PQstatus(conn) != CONNECTION_BAD)
	{
		pfree(keywords);
		pfree(values);
		return conn;
	}
	else
		pfree(keywords);
	pfree(values);
	return NULL;
}

/*
 * ddsf_create_self_node_conn
 * get connections optiosn for the local server and establis connection
 */
PGconn *
ddsf_create_self_scannode_conn(ForeignScanState *node)
{
	const char **keywords;
	const char **values;
	int			n = 0;
	PGconn	   *volatile conn;

	/*
	 * Get foreign Relation ID and associated server options and conenct to
	 * self
	 */
	ForeignScanState *frgn_scan_node = ((ForeignScanState *)node);
	Oid			relID = ((RelationData *) (frgn_scan_node->ss.ss_currentRelation))->rd_node.relNode;
	ForeignServer *frgn_server = GetForeignServer(GetForeignServerIdByRelId(relID));

	n = list_length(frgn_server->options) + 1;

	/*
	 * n = list_length(server->options) + list_length(user->options) +
	 * 3;//Incase usermap are to be used
	 */

	keywords = (const char **) palloc(n * sizeof(char *));
	values = (const char **) palloc(n * sizeof(char *));

	n = 0;
	n += ExtractConnectionOptions(frgn_server->options,
								  keywords + n, values + n);

	keywords[n] = values[n] = NULL;

	/*
	 * n += ExtractConnectionOptions(user->options, keywords + n, values + n);
	 */
	conn = PQconnectdbParams(keywords, values, false);

	if (conn && PQstatus(conn) != CONNECTION_BAD)
	{
		pfree(keywords);
		pfree(values);
		return conn;
	}
	else
		pfree(keywords);
	pfree(values);
	return NULL;
}

/*
 * ddsf_create_self_node_conn
 * get connections options for the local server and establis connection
 */
PGconn *
ddsf_create_self_node_conn(AggState *aggnode)
{
	const char **keywords;
	const char **values;
	int			n = 0;
	PGconn	   *volatile conn;

	/*
	 * Get foreign Relation ID and associated server options and conenct to
	 * self
	 */
	ForeignScanState *frgn_scan_node = ((ForeignScanState *) outerPlanState(aggnode));
	Oid			relID = ((RelationData *) (frgn_scan_node->ss.ss_currentRelation))->rd_node.relNode;
	ForeignServer *frgn_server = GetForeignServer(GetForeignServerIdByRelId(relID));

	n = list_length(frgn_server->options) + 1;

	/*
	 * n = list_length(server->options) + list_length(user->options) + 3;
	 * Incase usermap are to be used
	 */

	keywords = (const char **) palloc(n * sizeof(char *));
	values = (const char **) palloc(n * sizeof(char *));

	n = 0;
	n += ExtractConnectionOptions(frgn_server->options,
								  keywords + n, values + n);

	keywords[n] = values[n] = NULL;

	/*
	 * n += ExtractConnectionOptions(user->options, keywords + n, values + n);
	 */
	conn = PQconnectdbParams(keywords, values, false);

	if (conn && PQstatus(conn) != CONNECTION_BAD)
	{
		pfree(keywords);
		pfree(values);
		return conn;
	}
	else
	{
		pfree(keywords);
		pfree(values);
		return NULL;
	}
}

/*
 * ddsf_stop_self_node_conn
 * disconnect from local server
 */
void
ddsf_stop_self_node_conn(PGconn *self_conn)
{
	PQfinish(self_conn);
}

/*
 * ddsf_get_node_options
 * Get Server and User Mapping options for the server node
 */
int
ddsf_get_node_options(const char *node_name, PGconn *self_conn, char *options)
{
	/*
	 * OPTIONS retrieval done in real time Can support caching as well --TODO
	 */
	PGconn	   *conn = NULL;
	int			ncols,
				ntpls,
				i,
				j;
	PGresult   *res;
	char		query[BUFFER_SIZE] = {0};
	int			ret = 0;

	conn = self_conn;


	/* Get Server Options */
	sprintf(query, SRVOPT_QRY, node_name);
	res = PQexec(conn, query);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		/* Query Execution failed */
		return ret;
	}
	ntpls = PQntuples(res);
	ncols = PQnfields(res);
	if (ntpls == 0 || ncols == 0)
	{
		return ret;
	}
	for (i = 0; i < ntpls; i++)
	{
		for (j = 0; j < ncols; j++)
			strcpy(options, PQgetvalue(res, i, j));
	}

	/* Get UserMapping Options */
	memset(query, 0, BUFFER_SIZE);
	sprintf(query, UMOPT_QRY, node_name);
    fprintf(stdout,"query is %s\n",query);
	res = PQexec(conn, query);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		/* Query Execution failed */
		return ret;
	}
	ntpls = PQntuples(res);
	ncols = PQnfields(res);
	if (ntpls == 0 || ncols == 0)
	{
		return ret;
	}
	for (i = 0; i < ntpls; i++)
	{
		for (j = 0; j < ncols; j++)
			strcat(options, PQgetvalue(res, i, j));
	}
	ret = 1;

	/* Format Options recieved */
	replace(options, "{", " ", true);
	replace(options, "}", " ", true);
	replace(options, ",", " ", true);

	return ret;

}

/*
 * ddsf_free_node_list
 * Free the node list
 */
void
ddsf_free_node_list(char **list)
{
	int			node_count = 0;

	while (NULL != list[node_count])
	{
		free(list[node_count++]);
	}

}

/*
 * ddsf_combine_agg_variance
 * used to calculate the variance and stddev for DDSF Data sources
 */
static long double
ddsf_combine_agg_varsdv(const ForeignAggInfo * agginfodata, const int num_aggs)
{
	int			i;
	long double sum = 0;
	long double var = 0;
	long double count = 0;
	long double tmp = 0;
	float8		sumValue = 0;
	long double varVal = 0;
	int64		countVal = 0;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[0].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			sumValue = agginfodata[i].result[0].aggdata.var.sum.value;
			countVal = agginfodata[i].result[0].aggdata.var.count.value;
			varVal = agginfodata[i].result[0].aggdata.var.var.value;
			if (count > 1)
			{
				/* For 2nd and onwards DSs */
				tmp = ((count *

				/*
				 * convert sample variance to population variance for variance
				 * cumulated till now
				 */
						var * ((count - 1) / count)) +

				/*
				 * Get deviation square from total mean for values till now in
				 * the iteration
				 */
					   (count * pow((((sum + sumValue) / (count + countVal)) -
									 (sum / count)), 2)) +
				/* Sum to next DS variation square in the iteration */
					   (countVal *

				/*
				 * convert sample variance to population variance for the new
				 * variance
				 */
						varVal * (((long double) countVal - 1) / countVal)) +

				/*
				 * Get deviation square from total mean for values in the
				 * current iterator
				 */
					   (countVal * pow((((sum + sumValue) / (count + countVal)) - (sumValue / countVal)), 2))) /
				/* divide by Total records till now */
					(count + countVal);
				sum += sumValue;
				count += countVal;

				/* convert population variance back to sample variance */
				var = tmp * (count / (count - 1));
			}
			else
			{
				/* For 1st DS with acceptable variance -- can be 0 */
				sum = sumValue;
				count = countVal;
				var = varVal;
			}
		}
	}
	return var;
}

/*
 * ddsf_agg_sum
 * Combine the aggs and return the sum
 */
Datum
ddsf_agg_sum(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		sum = 0;
	float4		fsum = 0;
	float8		dsum = 0;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum += agginfodata[i].result[attr].aggdata.sum.realType;
			}
			else if (agginfodata[i].result[attr].typid == FLOAT8OID)
			{
				dsum += agginfodata[i].result[attr].aggdata.sum.value;
			}
			else
			{
				sum += agginfodata[i].result[attr].aggdata.sum.bigint_val;
			}
		}
	}
	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		agginfodata[0].result[attr].finalResult = Float4GetDatumFast(fsum);
	}
	else if (agginfodata[0].result[attr].typid == FLOAT8OID)
	{
		agginfodata[0].result[attr].finalResult = Float8GetDatumFast(dsum);
	}
	else if (agginfodata[0].typid == CASHOID)
	{
		agginfodata[0].result[attr].finalResult = CashGetDatum(sum);
	}
	else if (agginfodata[0].typid == NUMERICOID)
	{
		agginfodata[0].result[attr].finalResult = 
			    NumericGetDatum(DatumGetNumeric(DirectFunctionCall1(int8_numeric, Int64GetDatumFast(sum))));
	}
	else
	{
		/* For all the other type like small int and integer type */
		agginfodata[0].result[attr].finalResult = Int64GetDatumFast(sum);
	}
	return (Datum)0;
}

/*
 * ddsf_agg_count
 * Combine the aggs and return the count
 */
Datum
ddsf_agg_count(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	long		count = 0;

	for (i = 0; i < num_aggs; i++)
	{
		/* Consider a result only if operation be FDW was Successful */
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)
		{
			count += agginfodata[i].result[attr].aggdata.count.value;
		}
	}
	agginfodata[0].result[attr].finalResult = Int64GetDatumFast(count);
	
	return (Datum)0;
}

/*
 * ddsf_agg_avg
 * Combine the aggs and return the avg
 */
void
ddsf_agg_avg(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
#if 0
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	Datum		sm=0;
	Datum		cnt=0;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum += agginfodata[i].result[attr].aggdata.avg.sum.realType;
			}
			else
			{
				dsum += agginfodata[i].result[attr].aggdata.avg.sum.bigint_val;
			}
			count +=agginfodata[i].result[attr].aggdata.avg.count.value;
		}
	}
	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm += DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
	}
	else
	{
		sm += DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	}

	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));

	agginfodata[0].result[attr].finalResult = DirectFunctionCall2(numeric_div, sm, cnt);
#endif
	int			i;
	int64		sum = 0;
	float4		fsum = 0;
	float8		dsum = 0;

	int count = 0;
	Datum		sm,
				cnt;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum += agginfodata[i].result[attr].aggdata.avg.sum.realType;
			}
			else if(agginfodata[i].result[attr].typid == FLOAT8OID)
			{
				dsum += agginfodata[i].result[attr].aggdata.avg.sum.value;
			}
			else
			{
				sum += agginfodata[i].result[attr].aggdata.avg.sum.bigint_val;
			}
		}
		count += agginfodata[i].result[attr].aggdata.avg.count.value;
	}
	
	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));

	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm = DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
		agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_float8,DirectFunctionCall2(numeric_div, sm, cnt));
	}
	else if(agginfodata[0].result[attr].typid == FLOAT8OID)
	{
    	sm = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
		agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_float8,DirectFunctionCall2(numeric_div, sm, cnt));
	}
	else
	{
		sm = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(sum));
		agginfodata[0].result[attr].finalResult = DirectFunctionCall2(numeric_div, sm, cnt);
	}
}

/*
 * ddsf_agg_max
 * Combine the aggs and return the max
 */
void
ddsf_agg_max(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		Max = PG_INT64_MIN,
	Value = 0;
	char	   *strMinMax = NULL;
	Datum		TMinMax = 0,
				StrDatum;
	Oid			MinMaxOid = -1;
	float4		fmax = FLT_MIN;
	float8		dpmax = DBL_MIN;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[0].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == DATEOID)
			{
				Value = DatumGetInt64(DirectFunctionCall3(make_date, Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.year),
						  Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.mon),
						  Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.mday)));

				if (Value>Max)
				{
					Max = Value;
				}
			}
			else if (agginfodata[i].result[attr].typid == TEXTOID)
			{
				if (strMinMax == NULL)
				{
					strMinMax = agginfodata[i].result[attr].aggdata.maxmin.strMinMax;
					TMinMax = CStringGetDatum(strMinMax);
				}
				else
				{
					StrDatum = CStringGetDatum(agginfodata[i].result[attr].aggdata.maxmin.strMinMax);
					TMinMax = DirectFunctionCall2Coll(text_larger, DEFAULT_COLLATION_OID, TMinMax, StrDatum);
				}
			}
			else if (agginfodata[i].result[attr].typid == ANYENUMOID)
			{
#if 0
				if (strMinMax == NULL)
				{
					strMinMax = agginfodata[i].result[0].aggdata.maxmin.strMinMax;
					StrDatum = CStringGetDatum(strMinMax);
					MinMaxOid = DatumGetObjectId(DirectFunctionCall2(enum_in, StrDatum, ObjectIdGetDatum(enumtypeId)));
				}
				else
				{
					StrDatum = CStringGetDatum(agginfodata[i].result[0].aggdata.maxmin.strMinMax);
					TMinMax = DirectFunctionCall2(enum_in, StrDatum, ObjectIdGetDatum(enumtypeId));
					if ((DatumGetObjectId(TMinMax) > MinMaxOid))
					{
						MinMaxOid = DatumGetObjectId(TMinMax);
						strMinMax = agginfodata[i].result[0].aggdata.maxmin.strMinMax;
					}

				}
#endif
			}
			else if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fmax = (fmax < agginfodata[i].result[attr].aggdata.maxmin.realVal) ?
					agginfodata[i].result[attr].aggdata.maxmin.realVal : fmax;
			}
			else if (agginfodata[i].result[attr].typid == FLOAT8OID)
			{
				dpmax = (dpmax < agginfodata[i].result[attr].aggdata.maxmin.dpVal) ?
					agginfodata[i].result[attr].aggdata.maxmin.dpVal : dpmax;
			}
			else
			{
				Value = agginfodata[i].result[attr].aggdata.maxmin.value;

				if (Value >Max)
				{
					Max = Value;
				}
			}
		}
	}
	if (agginfodata[0].result[attr].typid == TEXTOID)
	{
		strMinMax = DatumGetCString(TMinMax);
		agginfodata[0].result[attr].finalResult = PointerGetDatum(cstring_to_text(strMinMax));
	}
	else if (agginfodata[0].result[attr].typid == ANYENUMOID)
	{
#if 0
		PG_RETURN_OID(DirectFunctionCall2(enum_in, CStringGetDatum(strMinMax), ObjectIdGetDatum(enumtypeId)));
#endif
	}
	else if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		agginfodata[0].result[attr].finalResult =  Float4GetDatumFast(fmax);
	}
	else if (agginfodata[0].result[attr].typid == FLOAT8OID)
	{
		agginfodata[0].result[attr].finalResult = Float8GetDatumFast(dpmax);
	}
	else
	{
		if (agginfodata[0].result[attr].typid == DATEOID)
		{
			agginfodata[0].result[attr].finalResult = DateADTGetDatum(Int64GetDatumFast(Max));
		}
        else if(agginfodata[0].result[attr].typid == CASHOID)
        {
                agginfodata[0].result[attr].finalResult = CashGetDatum(Max);
        }
		else
		{
			agginfodata[0].result[attr].finalResult = Int64GetDatumFast(Max);
		}
	}

}

/*
 * ddsf_agg_min
 * Combine the aggs and return the min
 */
void
ddsf_agg_min(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		Min = PG_INT64_MAX,
	Value = 0;
	char	   *strMinMax = NULL;
	Datum		TMinMax = 0,
				StrDatum;
	Oid			MinMaxOid = -1;
	float4		fmin = FLT_MAX;
	float8		dpmin = DBL_MAX;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[0].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == DATEOID)
			{
				Value = DatumGetInt64(DirectFunctionCall3(make_date, Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.year),
				Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.mon),Int64GetDatum(agginfodata[i].result[attr].aggdata.maxmin.fDate.mday)));

				if (Min > Value)
				{
					Min = Value;
				}
			}
			else if (agginfodata[i].result[attr].typid == TEXTOID)
			{
				if (strMinMax == NULL)
				{
					strMinMax = agginfodata[i].result[attr].aggdata.maxmin.strMinMax;
					TMinMax = CStringGetDatum(strMinMax);
				}
				else
				{
					StrDatum = CStringGetDatum(agginfodata[i].result[attr].aggdata.maxmin.strMinMax);
					TMinMax = DirectFunctionCall2Coll(text_smaller, DEFAULT_COLLATION_OID, TMinMax, StrDatum);
				}
			}
			else if (agginfodata[i].result[attr].typid == ANYENUMOID)
			{
#if 0
				if (strMinMax == NULL)
				{
					strMinMax = agginfodata[i].result[attr].aggdata.maxmin.strMinMax;
					StrDatum = CStringGetDatum(strMinMax);
					MinMaxOid = DatumGetObjectId(DirectFunctionCall2(enum_in, StrDatum, ObjectIdGetDatum(enumtypeId)));
				}
				else
				{
					StrDatum = CStringGetDatum(agginfodata[i].result[attr].aggdata.maxmin.strMinMax);
					TMinMax = DirectFunctionCall2(enum_in, StrDatum, ObjectIdGetDatum(enumtypeId));
					if ((DatumGetObjectId(TMinMax) < MinMaxOid))
					{
						MinMaxOid = DatumGetObjectId(TMinMax);
						strMinMax = agginfodata[i].result[attr].aggdata.maxmin.strMinMax;
					}

				}
#endif
			}
			else if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fmin = (fmin > agginfodata[i].result[attr].aggdata.maxmin.realVal) ?
					agginfodata[i].result[attr].aggdata.maxmin.realVal : fmin;
			}
			else if (agginfodata[i].result[attr].typid== FLOAT8OID)
			{
				dpmin = (dpmin > agginfodata[i].result[attr].aggdata.maxmin.dpVal) ?
					agginfodata[i].result[attr].aggdata.maxmin.dpVal : dpmin;
			}
			else
			{
				Value = agginfodata[i].result[attr].aggdata.maxmin.value;

				if (Min > Value)
				{
					Min = Value;
				}
			}
		}
	}
	if (agginfodata[0].result[attr].typid == TEXTOID)
	{
		strMinMax = DatumGetCString(TMinMax);
		agginfodata[0].result[attr].finalResult = PointerGetDatum(cstring_to_text(strMinMax)); 
	}
	else if (agginfodata[0].result[attr].typid == ANYENUMOID)
	{
#if 0
		PG_RETURN_OID(DirectFunctionCall2(enum_in, CStringGetDatum(strMinMax), ObjectIdGetDatum(enumtypeId)));
#endif
	}
	else if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		 agginfodata[0].result[attr].finalResult = Float4GetDatumFast(fmin) ;
	}
	else if (agginfodata[0].result[attr].typid == FLOAT8OID)
	{
		agginfodata[0].result[attr].finalResult = Float8GetDatumFast(dpmin);
	}
	else
	{
		if (agginfodata[0].result[attr].typid == DATEOID)
		{
			agginfodata[0].result[attr].finalResult = DateADTGetDatum(Int64GetDatumFast(Min));
		}
		else if(agginfodata[0].result[attr].typid == CASHOID)
		{
			agginfodata[0].result[attr].finalResult = CashGetDatum(Min);
		}
		else
		{
			agginfodata[0].result[attr].finalResult = Int64GetDatumFast(Min);
		}
	}
}

/*
 * ddsf_agg_bit_or
 * Combine the aggs and return the result of the bit_or
 */
void
ddsf_agg_bit_or(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i,
				j;
	int64		bitor = 0;
	Datum		ret;
	StringInfo	state = makeStringInfo();

	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_or ")));
		return (Datum) 0;
	}
	if (!state->data)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_or ")));
		return (Datum) 0;
	}
	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].typid == BITOID)
			{
				if (state->data[0] == '\0')
				{
					appendBinaryStringInfo(state, agginfodata[i].result[attr].aggdata.bit_op.state->data,
							agginfodata[i].result[attr].aggdata.bit_op.state->len);
				}
				else
				{
					for (j = 0; j < agginfodata[i].result[attr].aggdata.bit_op.state->len; j++)
					{
						if (state->data[j] != agginfodata[i].result[attr].aggdata.bit_op.state->data[j])
							state->data[j] = '1';		
					}
				}
			}
			else
			{
				bitor |= agginfodata[i].result[attr].aggdata.bitvar.bitall;
			}
		}
	}
	if (agginfodata[0].typid == BITOID)
	{
		ret = DirectFunctionCall3(bit_in, CStringGetDatum(state->data), (Datum) (-1), Int32GetDatum(state->len));
		pfree(state->data);
		pfree(state);
		agginfodata[0].result[attr].finalResult = VarBitPGetDatum(ret);
	}
	else
	{
		agginfodata[0].result[attr].finalResult = Int64GetDatum(bitor);
	}

}

/*
 * ddsf_agg_bit_and
 * Combine the aggs and return the result of the bit_and
 */
void
ddsf_agg_bit_and(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i,
				j;
	Datum		ret;
	int64		bitand = PG_INT64_MAX;
	StringInfo	state = makeStringInfo();

	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_and in ddsf_server ")));
		return (Datum) 0;
	}
	if (!state->data)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_and in ddsf_server ")));
		return (Datum) 0;
	}

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].typid == BITOID)
			{
				if (state->data[0] == '\0')
				{
					appendBinaryStringInfo(state, agginfodata[i].result[attr].aggdata.bit_op.state->data,
							agginfodata[i].result[attr].aggdata.bit_op.state->len);
				}
				else
				{
					for (j = 0; j < agginfodata[i].result[attr].aggdata.bit_op.state->len; j++)
					{
						if (state->data[j] != agginfodata[i].result[attr].aggdata.bit_op.state->data[j])
							state->data[j] = '0';		
					}
				}
			}
			else
			{
				bitand &= agginfodata[i].result[attr].aggdata.bitvar.bitall;
			}
		}
	}

	if (agginfodata[0].typid == BITOID)
	{
		ret = DirectFunctionCall3(bit_in, CStringGetDatum(state->data), (Datum) (-1), Int32GetDatum(state->len));
		pfree(state->data);
		pfree(state);
		agginfodata[0].result[attr].finalResult = VarBitPGetDatum(ret);
	}
	else
	{
		agginfodata[0].result[attr].finalResult = Int64GetDatum(bitand);
	}

}

/*
 * ddsf_agg_bool_and
 * Combine the aggs and return the result of the bool_and
 */
void
ddsf_agg_bool_and(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	bool		bland = false;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			bland = (bland && agginfodata[i].result[attr].aggdata.boolvar.boolall);
		}
	}
	agginfodata[0].result[attr].finalResult = bland;
}

/*
 * ddsf_agg_bool_or
 * Combine the aggs and return the result of the bool_and
 */
void
ddsf_agg_bool_or(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	bool		blor = false;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			blor = (blor || agginfodata[i].result[attr].aggdata.boolvar.boolall);
		}
	}
	agginfodata[0].result[attr].finalResult = blor;
}

/*
 * ddsf_agg_string_agg
 * Combine the aggs and return the result of the string_agg
 */
void
ddsf_agg_string_agg(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	char	   *delimptr;

	StringInfo	state;

	state = makeStringInfo();
	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for string_agg in ddsf_server ")));
		return (Datum) 0;
	}
	if (!state->data)
	{
		pfree(state);
		ereport(NOTICE, (errmsg("Memory Allocation failed for string_agg in ddsf_server ")));
		return (Datum) 0;
	}
	delimptr = getDelimiter(agginfodata[0].transquery);
	if (!delimptr)
	{
		pfree(state->data);
		pfree(state);
		return (Datum) 0;
	}
	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR) 
			/*
			 * Consider a result only if operation be FDW was Successful
			 */
		{
			if (state->data[0] == '\0')
			{
			}
			else
			{
				appendBinaryStringInfo(state, delimptr, strlen(delimptr));
			}
			appendBinaryStringInfo(state, agginfodata[i].result[attr].aggdata.stringagg.state->data,
						 agginfodata[i].result[attr].aggdata.stringagg.state->len);
		}
	}
	agginfodata[0].result[attr].finalResult = cstring_to_text_with_len(state->data, state->len);

	pfree(state->data);
	pfree(state);
	pfree(delimptr);
}

/*
 * ddsf_agg_stddev
 * Combine the aggs and return the result of the stddev
 */
void
ddsf_agg_stddev(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
#if 0
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	Datum		sm=0;
	Datum		cnt=0;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum += agginfodata[i].result[attr].aggdata.stddev.sum.realType * agginfodata[i].result[attr].aggdata.stddev.sum.realType;
			}
			else
			{
				dsum += agginfodata[i].result[attr].aggdata.stddev.sum.value * agginfodata[i].result[attr].aggdata.stddev.sum.value;
			}
		}
	}
	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm = DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
	}
	else
	{
    	sm = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	}
	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_sqrt,
	                                          DirectFunctionCall2(numeric_div, sm, cnt));
#else
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	Datum		sm=0;
	Datum		cnt=0;
	float8 left=0;
	float8 right=0;

	for (i = 0; i < num_aggs; i++)
	{
		float8 nume=0;
		float8 deno=0;
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum = fsum + (agginfodata[i].result[attr].aggdata.stddev.sum.realType *
					           agginfodata[i].result[attr].aggdata.stddev.sum.realType);
			}
			else
			{
				dsum = dsum + (agginfodata[i].result[attr].aggdata.stddev.sum.value *
					           agginfodata[i].result[attr].aggdata.stddev.sum.value);
			}
			count += agginfodata[i].result[attr].aggdata.stddev.count.value;
			left += agginfodata[i].result[attr].aggdata.stddev.count.value * agginfodata[i].result[attr].aggdata.stddev.stddev.value;
			for(int j=0;j<num_aggs;j++){
				nume += agginfodata[j].result[attr].aggdata.stddev.sum.value;
				deno += agginfodata[j].result[attr].aggdata.stddev.count.value;
			}
			right += pow(nume/deno - agginfodata[i].result[attr].aggdata.stddev.sum.value/agginfodata[i].result[attr].aggdata.stddev.count.value,2);
		}
	}
	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));
	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm = DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
	}
	else
	{
    	sm = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	}
	/*
	  agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_sqrt,
	                                          DirectFunctionCall2(numeric_div, sm, cnt));
	*/
	elog(INFO, "left rigth %lf",count);
	DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(sqrt((left+right)/count)));
#endif
}

/*
 * ddsf_agg_variance
 * Combine the aggs and return the result of the stddev
 */
void
ddsf_agg_variance(ForeignAggInfo * agginfodata, int num_aggs,int attr)
{
#if 0
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	Datum		sm,
				cnt;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum = fsum + (agginfodata[i].result[attr].aggdata.var.sum.realType *
					           agginfodata[i].result[attr].aggdata.var.sum.realType);
			}
			else
			{
				dsum = dsum + (agginfodata[i].result[attr].aggdata.var.sum.value *
					           agginfodata[i].result[attr].aggdata.var.sum.value);
			}
			count ++;
		}
	}
	/*count = count-1;  Bessels correction to calculate sample variance*/
	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));

	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm = DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
	}
	else
	{
    	sm = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	}
	
	/* TODO: Need better solution to calculate the average of standard deviation */
	/* current formula used is 
	   sqrt( sqr(sdn)+sqr(sd(n+1)).....+sqr(sd(k))/Total number of data sources(count-1))
   	   Using this formula there is around 9% of deviation with actual value
	  */
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_sqrt, 
	                                          DirectFunctionCall2(numeric_div, sm, cnt));
#endif
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	Datum		sm=0;
	Datum		cnt=0;
	float8 left=0;
	float8 right=0;

	for (i = 0; i < num_aggs; i++)
	{
		float8 nume=0;
		float8 deno=0;
		if (agginfodata[i].result[attr].status != DDSF_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			if (agginfodata[i].result[attr].typid == FLOAT4OID)
			{
				fsum = fsum + (agginfodata[i].result[attr].aggdata.var.sum.realType *
					           agginfodata[i].result[attr].aggdata.var.sum.realType);
			}
			else
			{
				dsum = dsum + (agginfodata[i].result[attr].aggdata.var.sum.value *
					           agginfodata[i].result[attr].aggdata.var.sum.value);
			}
			count += agginfodata[i].result[attr].aggdata.var.count.value;
			left += agginfodata[i].result[attr].aggdata.var.count.value * agginfodata[i].result[attr].aggdata.var.var.value;
			for(int j=0;j<num_aggs;j++){
				nume += agginfodata[j].result[attr].aggdata.var.sum.value;
				deno += agginfodata[j].result[attr].aggdata.var.count.value;
			}
			right += pow(nume/deno - agginfodata[i].result[attr].aggdata.var.sum.value/agginfodata[i].result[attr].aggdata.var.count.value,2);
		}
	}
	cnt = DirectFunctionCall1(int8_numeric, Int64GetDatumFast(count));
	if (agginfodata[0].result[attr].typid == FLOAT4OID)
	{
		sm = DirectFunctionCall1(float8_numeric, Float4GetDatumFast(fsum));
	}
	else
	{
    	sm = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	}
	/*
	  agginfodata[0].result[attr].finalResult = DirectFunctionCall1(numeric_sqrt,
	                                          DirectFunctionCall2(numeric_div, sm, cnt));
	*/
	elog(INFO, "left rigth %lf",count);
	DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(float8_numeric, Float8GetDatumFast((left+right)/count));
}

/*
 * get_enumtypeid
 * returns the typeid of the enum the ddsf server
 */
static Oid
get_enumtypeid(PGconn *conn, char *qry)
{
	PGresult   *res = NULL;
	char		query[BUFFER_SIZE] = {0};
	char	   *udt_name;
	int			ntpls,
				ncols,
				i = 0,
				j = 0;
	Oid			enumtypeOid;

	/* Max length of the table name and column name is 64 */
	char		colum_Name[64] = {0},
				table_Name[64] = {0};

	/* getting the column name from the query */
	{
		while (qry[i] != '(')
		{
			i++;
		}
		i++;
		while (qry[i] != ')')
		{
			/* avoiding spaces */
			if (qry[i] != ' ')
			{
				colum_Name[j++] = (char)tolower(qry[i]);
			}
			i++;
		}

	}
	colum_Name[j] = '\0';
	/* getting table name */
	{
		j = 0;
		i++;
		while (qry[i] != ';')
		{
			if (qry[i] == ' ')
			{
				j = 0;
			}
			else
			{
				table_Name[j++] = (char)tolower(qry[i]);
			}
			i++;
		}

	}
	table_Name[j] = '\0';

	sprintf(query, UDTNAME_QRY, table_Name, colum_Name);
	res = PQexec(conn, query);
	ntpls = PQntuples(res);
	ncols = PQnfields(res);
	if (ntpls == 0 || ncols == 0)
	{
		return 0;
	}
	udt_name = pstrdup(PQgetvalue(res, 0, 0));
	memset(query, 0, BUFFER_SIZE);
	PQclear(res);
	/* getting enumoid using the udtname */
	sprintf(query, ENUMOID_QRY, udt_name);

	res = PQexec(conn, query);
	ntpls = PQntuples(res);
	ncols = PQnfields(res);
	if (ntpls == 0 || ncols == 0)
	{
		return 0;
	}
	enumtypeOid = strtol(PQgetvalue(res, 0, 0), NULL, BASE_TEN);

	pfree(udt_name);
	PQclear(res);
	return (enumtypeOid);
}

/*
 * ddsf_get_node_connection_PG
 * Establish conenction to remote PG servers
 */
PGconn *
ddsf_get_node_connection_PG(const char *options)
{
	PGconn	   *conn;

	conn = PQconnectdb(options);
	if (PQstatus(conn) != CONNECTION_OK)
	{
		ereport(NOTICE, (errmsg("No connection ")));
		return NULL;
	}
	return conn;
}

/*
 * Ddsf_FDW_thread
 * Create a new thread and execute foreign agg
 */
void *
Ddsf_FDW_thread(void *arg)
{
	DdsfFDWThreadData *thrdata = (DdsfFDWThreadData *) arg;
   	MemoryContext oldcontext = MemoryContextSwitchTo(thrdata->threadMemoryContext);
	thrdata->fdwroutine->ForeignAgg(thrdata->aggnode, (void *) thrdata->agginfodata);
	return NULL;
}

void trim(char * s) {
    char * p = s;
    int l = strlen(p);

    while(isspace(p[l - 1])) p[--l] = 0;
    while(* p && isspace(* p)) ++p, --l;

    memmove(s, p, l + 1);
}   


int strcmpi(char* s1, char* s2){
    int i;
     
    if(strlen(s1)!=strlen(s2))
        return -1;
         
    for(i=0;i<strlen(s1);i++){
        if(toupper(s1[i])!=toupper(s2[i]))
            return s1[i]-s2[i];
    }
    return 0;
}

char* cutAtQuery(char *query, int pos, char *delim)
{
   char *token;
   token = strtok( query, delim);

   if(pos == 1)
     return token;

   while( token != NULL && --pos)  
   {  
      // Get next token:   
      token = strtok( NULL, delim );
   }
   return token;
}

#if 1
DdsfAggType
ddsf_get_agg_type_new_push(const ForeignScanState *node, const int attNum)
{
	DdsfAggType ret;

	/**
	 * @todo We must analyze plan tree for aggregation type.
	 * Currently analyzing sourceText is VERY fragile because
	 * it needs complete parser of SQL queries if we support
	 * complex queries such as subquery, join, etc..
	 *
	 * and, query is already parsed by PostgreSQL engine.
	 * Therefore we think it is better to check plan tree than
	 * parsing SQL query "by hand" again.
	 *
	 * The following code is just PoC to check behavior.
	 * Check target list for Aggref.
	 */
	
	char *query_org = ((QueryDesc *)node->ss.ps.ddsfAggQry)->sourceText;
	int length = strlen(query_org);

	char *query = malloc(length+1);
	memcpy(query,query_org,length);

	/* Pass the query to get the aggregation query token string */
	char *sql = cutAtQuery(query, attNum, ",");
	if(sql == NULL){
		return AGG_DEFAULT;
	}

	/* Pass the token to get the exact aggregation query string */
	sql = cutAtQuery(sql, 1, "(");

	char *sql2 = cutAtQuery(sql, 2, " ");
	if(sql2)
		sql = sql2;
	
	trim(sql);

	if (!strcmpi(sql, "AVG"))
		ret = AGG_AVG;
	else if (!strcmpi(sql, "SUM"))
		ret = AGG_SUM;
	else if (!strcmpi(sql, "COUNT"))
		ret = AGG_COUNT;
	else if (!strcmpi(sql, "MAX"))
		ret = AGG_MAX;
	else if (!strcmpi(sql, "MIN"))
		ret = AGG_MIN;
	else if (!strcmpi(sql, "BIT_OR"))
		ret = AGG_BIT_OR;
	else if (!strcmpi(sql, "BIT_AND"))
		ret = AGG_BIT_AND;
	else if (!strcmpi(sql, "BOOL_AND"))
		ret = AGG_BOOL_AND;
	else if (!strcmpi(sql, "BOOL_OR"))
		ret = AGG_BOOL_OR;
	else if (!strcmpi(sql, "EVERY"))
		ret = AGG_EVERY;
	else if (!strcmpi(sql, "STRING_AGG"))
		ret = AGG_STRING_AGG;
	else if (!strcmpi(sql, "VARIANCE"))
		ret = AGG_VAR;
	else if (!strcmpi(sql, "STDDEV"))
		ret = AGG_STDDEV;
	else
		ret = AGG_DEFAULT;

	return ret;
}
#endif

void
ddsf_get_agg_type_new(const ForeignScanState *node, const int nTotalAtts, DdsfAggType *aggType)
{
	char *query_org = ((QueryDesc *)node->ss.ps.ddsfAggQry)->sourceText;
	int length = strlen(query_org);

	char *query = palloc(length+1);
	memcpy(query,query_org,length);
	
	int nAtt = 0;
	
	DdsfAggType ret;
	char *token;
	char *save;

	token = strtok_r(query, ",", &save);

	while( token != NULL && nAtt != nTotalAtts)	
	{
		if (strcasestr(token, "AVG"))
			ret = AGG_AVG;
		else if (strcasestr(token, "SUM"))
			ret = AGG_SUM;
		else if (strcasestr(token, "COUNT"))
			ret = AGG_COUNT;
		else if (strcasestr(token, "MAX"))
			ret = AGG_MAX;
		else if (strcasestr(token, "MIN"))
			ret = AGG_MIN;
		else if (strcasestr(token, "BIT_OR"))
			ret = AGG_BIT_OR;
		else if (strcasestr(token, "BIT_AND"))
			ret = AGG_BIT_AND;
		else if (strcasestr(token, "BOOL_AND"))
			ret = AGG_BOOL_AND;
		else if (strcasestr(token, "BOOL_OR"))
			ret = AGG_BOOL_OR;
		else if (strcasestr(token, "EVERY"))
			ret = AGG_EVERY;
		else if (strcasestr(token, "STRING_AGG"))
			ret = AGG_STRING_AGG;
		else if (strcasestr(token, "VARIANCE"))
			ret = AGG_VAR;
		else if (strcasestr(token, "STDDEV"))
			ret = AGG_STDDEV;
		else
			ret = AGG_DEFAULT;
		if(ret!= AGG_DEFAULT)
		{
			aggType[nAtt] = ret;
			nAtt++;
		}
		token = strtok_r(NULL, ",", &save);
	}
	pfree(query);	
}
/*
 * ddsf_get_agg_type
 * get Agg Type for the the agg function
 */
DdsfAggType
ddsf_get_agg_type(AggState *aggnode)
/*char *query, int attnum)*/
{
	return AGG_SUM;
}
Datum
ddsf_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs, int natts)
{

	for(int i=0; i<natts; i++)
	{

		switch (agginfodata[0].result[i].type)
		{
			case AGG_AVG:
				ddsf_agg_avg(agginfodata, num_aggs, i);
				break;
			case AGG_SUM:
				ddsf_agg_sum(agginfodata, num_aggs, i);
				break;
			case AGG_COUNT:
				ddsf_agg_count(agginfodata, num_aggs,i);
				break;
			case AGG_MAX:
				 ddsf_agg_max(agginfodata, num_aggs, i);
				 break;
			case AGG_MIN:
				 ddsf_agg_min(agginfodata, num_aggs, i);
				 break;
			case AGG_BIT_OR:
				ddsf_agg_bit_or(agginfodata, num_aggs, i);
				break;
			case AGG_BIT_AND:
				ddsf_agg_bit_and(agginfodata, num_aggs, i);
				break;
			case AGG_BOOL_AND:
			case AGG_EVERY:
				ddsf_agg_bool_and(agginfodata, num_aggs, i);
				break;
			case AGG_BOOL_OR:
				ddsf_agg_bool_or(agginfodata, num_aggs, i);
				break;
			case AGG_STRING_AGG:
				ddsf_agg_string_agg(agginfodata, num_aggs,i);
				break;
			case AGG_VAR:
				ddsf_agg_variance(agginfodata, num_aggs, i);
				break;
			case AGG_STDDEV:
				ddsf_agg_stddev(agginfodata, num_aggs, i);
				break;
			default:
				return (Datum) 0;
				break;
		}
	}

	return (Datum) 1;
}


void ddsf_get_agg_Info_push(TupleTableSlot *aggSlot, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata)
{
	int natts;
	bool isnull = false;
	Datum datum;
	
	for(natts=0;natts < aggSlot->tts_tupleDescriptor->natts; natts++)
	{
		/**
		 * @todo must analyze plan tree for aggregation type and
		 * value types.
		 */
		DdsfAggType type = ddsf_get_agg_type_new_push(node, natts+1);
		if(type != AGG_DEFAULT)
		{
			agginfodata[count-1].result[natts].type = type;
			agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
			datum = slot_getattr(aggSlot, natts+1, &isnull);
			switch(agginfodata[count-1].result[natts].type)
			{
				case AGG_SUM:
				{					
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.sum.realType = DatumGetFloat4(datum);
							break;
						case FLOAT8OID:
							agginfodata[count-1].result[natts].aggdata.sum.value = DatumGetFloat8(datum);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.sum.bigint_val = DatumGetInt64(datum);
						break;
					}
				}
				break;
				
				case AGG_AVG:
				{
					FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.ddsfAggQry)->dest, natts);				
					char	   *outputstr;	
					//datum = slot_getattr(aggSlot, natts+2, &isnull);
/*
					outputstr = DatumGetCString(slot_getattr(aggSlot, natts+2, &isnull));
					agginfodata[count-1].result[natts].aggdata.avg.count.value = strtof(outputstr, NULL);
*/
//					agginfodata[count-1].result[natts].aggdata.count.value = DatumGetInt64(datum);

					//outputstr = DatumGetCString(slot_getattr(aggSlot, natts+1, &isnull));
					//agginfodata[count-1].result[natts].aggdata.avg.count.value = strtod(outputstr, NULL);
					agginfodata[count-1].result[natts].aggdata.avg.count.value = DatumGetInt64(slot_getattr(aggSlot, natts+2, &isnull));
					outputstr = DatumGetCString(slot_getattr(aggSlot, natts+1, &isnull));
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.avg.sum.realType = strtof(outputstr, NULL);
							elog(INFO,"float sum=%f",agginfodata[count-1].result[natts].aggdata.avg.sum.realType);
						break;
						case FLOAT8OID:
							agginfodata[count-1].result[natts].aggdata.avg.sum.value = strtod(outputstr, NULL);
							elog(INFO,"float8 sum=%f",agginfodata[count-1].result[natts].aggdata.avg.sum.realType);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.avg.sum.bigint_val = strtod(outputstr, NULL);
							elog(INFO,"defo sum=%s",outputstr);
						break;
					}
					elog(INFO,"count=%lld",agginfodata[count-1].result[natts].aggdata.avg.count.value);
				}
				break;

				case AGG_COUNT:
				{
					agginfodata[count-1].result[natts].aggdata.count.value = DatumGetInt64(datum);
				}
				break;
				
				case AGG_VAR:
				{
					FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.ddsfAggQry)->dest, natts);				
					char	   *outputstr;	
					agginfodata[count-1].result[natts].aggdata.var.count.value = DatumGetInt64(slot_getattr(aggSlot, natts+2, &isnull));
					outputstr = DatumGetCString(slot_getattr(aggSlot, natts+1, &isnull));
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.var.sum.realType = strtof(outputstr, NULL);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.var.sum.value = strtod(outputstr, NULL);
						break;
					}
					Numeric a = DatumGetNumeric(slot_getattr(aggSlot, natts+3, &isnull));
					float8 hoge=0.0;
					hoge = DatumGetFloat8(DirectFunctionCall1(numeric_float8, a));
					agginfodata[count-1].result[natts].aggdata.var.var.value=hoge;
					elog(INFO, "varval %llf ",agginfodata[count-1].result[natts].aggdata.var.var.value);
					elog(INFO, "varval %lf ",hoge);
				}
				break;
				case AGG_STDDEV:
				{
/*					
					FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.ddsfAggQry)->dest, natts);

					char	   *outputstr;	
					outputstr = DatumGetCString(slot_getattr(aggSlot, natts+1, &isnull));
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.stddev.sum.realType = strtof(outputstr, NULL);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.stddev.sum.value = strtod(outputstr, NULL);
						break;
					}
*/
					FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.ddsfAggQry)->dest, natts);				
					char	   *outputstr;	
					agginfodata[count-1].result[natts].aggdata.stddev.count.value = DatumGetInt64(slot_getattr(aggSlot, natts+2, &isnull));
					outputstr = DatumGetCString(slot_getattr(aggSlot, natts+1, &isnull));
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.stddev.sum.realType = strtof(outputstr, NULL);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.stddev.sum.value = strtod(outputstr, NULL);
						break;
					}
					Numeric a = DatumGetNumeric(slot_getattr(aggSlot, natts+3, &isnull));
					float8 hoge=0.0;
					hoge = DatumGetFloat8(DirectFunctionCall1(numeric_float8, a));
					agginfodata[count-1].result[natts].aggdata.stddev.stddev.value=hoge;
					elog(INFO, "varval %llf ",agginfodata[count-1].result[natts].aggdata.stddev.stddev.value);
					elog(INFO, "varval %lf ",hoge);
				}
				break;

				case AGG_STRING_AGG:
				{
					int			string_len;
					StringInfo	state;
					char	   *value;
					Oid			typoutput;
					bool		typisvarlena;

					state = (StringInfo) palloc(sizeof(StringInfoData));
					if (!state)
					{
						agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
						ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
						return;
					}
					agginfodata[count-1].result[natts].aggdata.stringagg.state = state;
					
					getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
									  &typoutput, &typisvarlena);

					value = OidOutputFunctionCall(typoutput, datum);
					string_len = strlen(value);
					
					agginfodata[count-1].result[natts].aggdata.stringagg.state->len = string_len;
					agginfodata[count-1].result[natts].aggdata.stringagg.state->data = (char *) palloc(sizeof(char) * string_len + 1);
					if (!agginfodata[count-1].result[natts].aggdata.stringagg.state->data)
					{
						agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
						ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
						return;
					}
					memset(agginfodata[count-1].result[natts].aggdata.stringagg.state->data, 0, string_len + 1);
					if (string_len >= 0)
					{
						strncpy(agginfodata[count-1].result[natts].aggdata.stringagg.state->data, value, string_len);
					}
				}
				break;

				case AGG_BOOL_AND:
				case AGG_BOOL_OR:
				case AGG_EVERY:
				{
					char	   *value;
					Oid			typoutput;
					bool		typisvarlena;

					getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
									  &typoutput, &typisvarlena);

					value = OidOutputFunctionCall(typoutput, datum);
					
					switch (*value)
					{
						case 'T':
						case 't':
						case 'Y':
						case 'y':
						case '1':				
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = true;
						break;
						case 'F':
						case 'f':
						case 'N':
						case 'n':
						case '0':				
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = false;
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = false;
					}
				}
				break;
				case AGG_BIT_AND:
				case AGG_BIT_OR:
					{
						int 	string_len;					
						char	   *value;
						Oid 		typoutput;
						bool		typisvarlena;

						getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
																	  &typoutput, &typisvarlena);
													
						value = OidOutputFunctionCall(typoutput, datum);
						string_len = strlen(value);

						if (agginfodata[count-1].result[natts].typid == BITOID)
						{
							StringInfo	state;

							state = (StringInfo) palloc(sizeof(StringInfoData));
							if (!state)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
								return;
							}
							agginfodata[count-1].result[natts].aggdata.bit_op.state = state;

							agginfodata[count-1].result[natts].aggdata.bit_op.state->len = string_len;
							agginfodata[count-1].result[natts].aggdata.bit_op.state->data = (char *) palloc(sizeof(char) * string_len + 1);
							if (!agginfodata[count-1].result[natts].aggdata.bit_op.state->data)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
								return;
							}
							memset(agginfodata[count-1].result[natts].aggdata.bit_op.state->data, 0, string_len + 1);
							if (string_len >= 0)
							{
								strncpy(agginfodata[count-1].result[natts].aggdata.bit_op.state->data, value, string_len);
							}
							agginfodata[count-1].typid = BITOID;
						}
						else
						{
							agginfodata[count-1].result[natts].aggdata.bitvar.bitall = strtol(value, NULL, BASE_TEN);

							/* Checking for the range of the value after the conversion */
							if ((errno == ERANGE && (agginfodata[count-1].result[natts].aggdata.bitvar.bitall == LONG_MAX ||
										  agginfodata[count-1].result[natts].aggdata.bitvar.bitall == LONG_MIN)))
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Out of Range ")));
							}
						}
					}
				break;
				case AGG_MAX:
				case AGG_MIN:
				{
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.maxmin.realVal = DatumGetFloat4(datum);
						break;
						case FLOAT8OID:
							agginfodata[count-1].result[natts].aggdata.maxmin.dpVal = DatumGetFloat8(datum);
						break;
						case DATEOID:
						{
							char	   *dateStr,
									   *dateTok,
									   *save;
							Oid			typoutput;
							bool		typisvarlena;

							getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
											  &typoutput, &typisvarlena);

							dateStr = OidOutputFunctionCall(typoutput, datum);

							if (!dateStr)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory allocation is failed: ")));
								return;
							}
							dateTok = strtok_r(dateStr, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.year = atoi(dateTok);
							dateTok = strtok_r(NULL, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.mon = atoi(dateTok);
							dateTok = strtok_r(NULL, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.mday = atoi(dateTok);
						}
						break;
						
						case TEXTOID:
						{
							char	   *value;
							Oid			typoutput;
							bool		typisvarlena;

							getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
											  &typoutput, &typisvarlena);

							value = OidOutputFunctionCall(typoutput, datum);

							StrNCpy(agginfodata[count-1].result[natts].aggdata.maxmin.strMinMax,value,strlen(value)+1);
						}
						break;
						
						case ANYENUMOID:
						break;
			
						default:
							agginfodata[count-1].result[natts].aggdata.maxmin.value = DatumGetInt64(datum);				
						break;
					}
					break;
				}

			}
			agginfodata[count-1].result[natts].status = DDSF_FRG_OK;
		}
	}
}

void ddsf_get_agg_Info(ForeignScanThreadInfo thrdInfo, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata)
{
	int natts, nTotalAtts;
	bool isnull = false;
	Datum datum;
	TupleTableSlot *aggSlot = thrdInfo.tuple;

	//nTotalAtts = aggSlot->tts_tupleDescriptor->natts - 2; /*AVG Query*/
    nTotalAtts = aggSlot->tts_tupleDescriptor->natts; /*AVG Query*/
	
	DdsfAggType type[nTotalAtts];
	//ddsf_get_agg_type_new(node, nTotalAtts, &type);
    ddsf_get_agg_type_new(node, nTotalAtts, &type);

	for(natts=0;natts < nTotalAtts; natts++)
	{
		/**
		 * @todo must analyze plan tree for aggregation type and
		 * value types.
		 */
		agginfodata[count-1].result[natts].type = type[natts];
		if(agginfodata[count-1].result[natts].type != AGG_DEFAULT)
		{
			switch(agginfodata[count-1].result[natts].type)
			{
				case AGG_SUM:
				{
					datum = slot_getattr(aggSlot, natts+1, &isnull);
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.sum.realType = DatumGetFloat4(datum);
							break;
						case FLOAT8OID:
							agginfodata[count-1].result[natts].aggdata.sum.value = DatumGetFloat8(datum);
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.sum.bigint_val = DatumGetInt64(datum);				
						break;
					}
				}
				break;
				
				case AGG_AVG:
				{
						agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
						switch(agginfodata[count-1].result[natts].typid)
						{						
							case FLOAT4OID:
								agginfodata[count-1].result[natts].aggdata.avg.sum.realType = 
									DatumGetFloat4(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
							case FLOAT8OID:
								agginfodata[count-1].result[natts].aggdata.avg.sum.value = 
									DatumGetFloat8(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
							default:								
								agginfodata[count-1].result[natts].aggdata.var.sum.bigint_val = 
									DatumGetInt64(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
						}
						agginfodata[count-1].result[natts].aggdata.avg.count.value = 
																thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[1];
					agginfodata[count-1].result[natts].status = DDSF_FRG_OK;
				}
				break;

				case AGG_COUNT:
				{
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, natts+1, &isnull);
					agginfodata[count-1].result[natts].aggdata.count.value = DatumGetInt64(datum);
				}
				break;
				
				case AGG_VAR:
				case AGG_STDDEV:
				{
						char	   *value;
						Oid			typoutput;
						bool		typisvarlena;
						
						agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
						switch(agginfodata[count-1].result[natts].typid)
						{						
							case FLOAT4OID:
								agginfodata[count-1].result[natts].aggdata.var.sum.value = 
									DatumGetFloat4(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
							case FLOAT8OID:
								agginfodata[count-1].result[natts].aggdata.var.sum.value = 
									DatumGetFloat8(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
							default:								
								agginfodata[count-1].result[natts].aggdata.var.sum.value = 
									DatumGetInt64(thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[0]);
							break;
						}

						agginfodata[count-1].result[natts].aggdata.var.count.value = 
							thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[1];

						datum = 
							thrdInfo.fsstate->ss.ps.state->es_progressState->ps_aggvalues[2];
						
						getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
										  &typoutput, &typisvarlena);

						value = OidOutputFunctionCall(typoutput, datum);
						agginfodata[count-1].result[natts].aggdata.var.var.value= strtold(value, NULL);
						agginfodata[count-1].result[natts].status = DDSF_FRG_OK;
						
						pfree(value);
				}
				break;
				case AGG_STRING_AGG:
				{
					int			string_len;
					StringInfo	state;
					char	   *value;
					Oid			typoutput;
					bool		typisvarlena;

					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, natts+1, &isnull);
					state = (StringInfo) palloc(sizeof(StringInfoData));
					if (!state)
					{
						agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
						ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
						return;
					}
					agginfodata[count-1].result[natts].aggdata.stringagg.state = state;
					
					getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
									  &typoutput, &typisvarlena);

					value = OidOutputFunctionCall(typoutput, datum);
					string_len = strlen(value);
					
					agginfodata[count-1].result[natts].aggdata.stringagg.state->len = string_len;
					agginfodata[count-1].result[natts].aggdata.stringagg.state->data = (char *) palloc(sizeof(char) * string_len + 1);
					if (!agginfodata[count-1].result[natts].aggdata.stringagg.state->data)
					{
						agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
						ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
						return;
					}
					memset(agginfodata[count-1].result[natts].aggdata.stringagg.state->data, 0, string_len + 1);
					if (string_len >= 0)
					{
						strncpy(agginfodata[count-1].result[natts].aggdata.stringagg.state->data, value, string_len);
					}
					pfree(value);
				}
				break;

				case AGG_BOOL_AND:
				case AGG_BOOL_OR:
				case AGG_EVERY:
				{
					char	   *value;
					Oid			typoutput;
					bool		typisvarlena;
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, natts+1, &isnull);

					getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
									  &typoutput, &typisvarlena);

					value = OidOutputFunctionCall(typoutput, datum);
					
					switch (*value)
					{
						case 'T':
						case 't':
						case 'Y':
						case 'y':
						case '1':				
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = true;
						break;
						case 'F':
						case 'f':
						case 'N':
						case 'n':
						case '0':				
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = false;
						break;
						default:
							agginfodata[count-1].result[natts].aggdata.boolvar.boolall = false;
					}
				}
				break;
				case AGG_BIT_AND:
				case AGG_BIT_OR:
					{
						int 	string_len;					
						char	   *value;
						Oid 		typoutput;
						bool		typisvarlena;
						agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
						datum = slot_getattr(aggSlot, natts+1, &isnull);

						getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
																	  &typoutput, &typisvarlena);
													
						value = OidOutputFunctionCall(typoutput, datum);
						string_len = strlen(value);

						if (agginfodata[count-1].result[natts].typid == BITOID)
						{
							StringInfo	state;

							state = (StringInfo) palloc(sizeof(StringInfoData));
							if (!state)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
								return;
							}
							agginfodata[count-1].result[natts].aggdata.bit_op.state = state;

							agginfodata[count-1].result[natts].aggdata.bit_op.state->len = string_len;
							agginfodata[count-1].result[natts].aggdata.bit_op.state->data = (char *) palloc(sizeof(char) * string_len + 1);
							if (!agginfodata[count-1].result[natts].aggdata.bit_op.state->data)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
								return;
							}
							memset(agginfodata[count-1].result[natts].aggdata.bit_op.state->data, 0, string_len + 1);
							if (string_len >= 0)
							{
								strncpy(agginfodata[count-1].result[natts].aggdata.bit_op.state->data, value, string_len);
							}
							agginfodata[count-1].typid = BITOID;
						}
						else
						{
							agginfodata[count-1].result[natts].aggdata.bitvar.bitall = strtol(value, NULL, BASE_TEN);

							/* Checking for the range of the value after the conversion */
							if ((errno == ERANGE && (agginfodata[count-1].result[natts].aggdata.bitvar.bitall == LONG_MAX ||
										  agginfodata[count-1].result[natts].aggdata.bitvar.bitall == LONG_MIN)))
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Out of Range ")));
							}
						}
					}
				break;
				case AGG_MAX:
				case AGG_MIN:
				{
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, natts+1, &isnull);
					switch(agginfodata[count-1].result[natts].typid)
					{
						case FLOAT4OID:
							agginfodata[count-1].result[natts].aggdata.maxmin.realVal = DatumGetFloat4(datum);
						break;
						case FLOAT8OID:
							agginfodata[count-1].result[natts].aggdata.maxmin.dpVal = DatumGetFloat8(datum);
						break;
						case DATEOID:
						{
							char	   *dateStr,
									   *dateTok,
									   *save;
							Oid			typoutput;
							bool		typisvarlena;

							getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
											  &typoutput, &typisvarlena);

							dateStr = OidOutputFunctionCall(typoutput, datum);

							if (!dateStr)
							{
								agginfodata[count-1].result[natts].status = DDSF_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory allocation is failed: ")));
								return;
							}
							dateTok = strtok_r(dateStr, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.year = atoi(dateTok);
							dateTok = strtok_r(NULL, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.mon = atoi(dateTok);
							dateTok = strtok_r(NULL, "-", &save);
							agginfodata[count-1].result[natts].aggdata.maxmin.fDate.mday = atoi(dateTok);
						}
						break;
						
						case TEXTOID:
						{
							char	   *value;
							Oid			typoutput;
							bool		typisvarlena;

							getTypeOutputInfo(agginfodata[count-1].result[natts].typid,
											  &typoutput, &typisvarlena);

							value = OidOutputFunctionCall(typoutput, datum);
							StrNCpy(agginfodata[count-1].result[natts].aggdata.maxmin.strMinMax,value,strlen(value)+1);
							pfree(value);
						}
						break;
						
						case ANYENUMOID:
						break;
			
						default:
							agginfodata[count-1].result[natts].aggdata.maxmin.value = DatumGetInt64(datum);				
						break;
					}
					break;
				}

			}
			agginfodata[count-1].result[natts].status = DDSF_FRG_OK;
		}
	}
}


TupleTableSlot* ddsf_get_agg_tuple(ForeignAggInfo * agginfodata, TupleTableSlot *dest)
{
	HeapTuple tuple;
	Datum	   *values;
	bool	   *nulls;

	values = (Datum *) palloc0(dest->tts_tupleDescriptor->natts * sizeof(Datum));
	nulls = (bool *) palloc(dest->tts_tupleDescriptor->natts * sizeof(bool));
	/* Initialize to nulls for any columns not present in result */
	memset(nulls, 0, dest->tts_tupleDescriptor->natts * sizeof(bool));

	for(int i=0; i<dest->tts_tupleDescriptor->natts; i++)
	{
		values[i] = agginfodata[0].result[i].finalResult;
	}
	tuple = heap_form_tuple(dest->tts_tupleDescriptor, values, nulls);

	ExecStoreTuple(tuple, dest, InvalidBuffer, false);
	
	return dest;
}
