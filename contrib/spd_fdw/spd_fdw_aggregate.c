/*-------------------------------------------------------------------------
 *
 * contrib/spd_fdw/spd_fdw_aggregate.c
 *
 *
 *-------------------------------------------------------------------------
 */
#include <stdio.h>
#include <ctype.h>
#include <float.h>
#include <ctype.h>
#include <limits.h>
#include <math.h>
#include "spd_fdw_aggregate.h"
#include "fmgr.h"
#include "string.h"
#include "catalog/pg_type.h"
#include "catalog/pg_collation.h"
#include "utils/int8.h"
#include "utils/bytea.h"
#include "utils/varbit.h"
#include "utils/cash.h"
#include "utils/date.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/numeric.h"
#include "spd_util.h"
#include "executor/spi.h"
#include "access/htup_details.h"
#include "access/printtup.h"

static char* cutAtQuery(char *query, int pos, char *delim);
static void trim(char * s);
static int strcmpi(char* s1, char* s2);
/**
 * spd_combine_agg_variance
 * used to calculate the variance and stddev for SPD Data sources
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
/**
 * spd_agg_sum
 * Combine the aggs and return the sum
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
Datum
spd_agg_sum(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		sum = 0;
	float4		fsum = 0;
	float8		dsum = 0;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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

/**
 * spd_agg_count
 * Combine the aggs and return the count
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
Datum
spd_agg_count(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	long		count = 0;

	for (i = 0; i < num_aggs; i++)
	{
		/* Consider a result only if operation be FDW was Successful */
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)
		{
			count += agginfodata[i].result[attr].aggdata.count.value;
		}
	}
	agginfodata[0].result[attr].finalResult = Int64GetDatumFast(count);
	
	return (Datum)0;
}
/**
 * spd_agg_avg
 * Combine the aggs and return the avg
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_avg(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		sum = 0;
	float4		fsum = 0;
	float8		dsum = 0;

	int count = 0;
	Datum		sm,
				cnt;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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

/**
 * spd_agg_max
 * Combine the aggs and return the max
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_max(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		Max = PG_INT64_MIN,
	Value = 0;
	char	   *strMinMax = NULL;
	Datum		TMinMax = 0,
				StrDatum;
	float4		fmax = FLT_MIN;
	float8		dpmax = DBL_MIN;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[0].status != SPD_FRG_ERROR)		/* Consider a result
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

/**
 * spd_agg_min
 * Combine the aggs and return the min
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_min(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	int64		Min = PG_INT64_MAX,
	Value = 0;
	char	   *strMinMax = NULL;
	Datum		TMinMax = 0,
				StrDatum;
	float4		fmin = FLT_MAX;
	float8		dpmin = DBL_MAX;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[0].status != SPD_FRG_ERROR)
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

/**
 * spd_agg_bit_or
 * Combine the aggs and return the result of the bit_or
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_bit_or(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i,
				j;
	int64		bitor = 0;
	Datum		ret;
	StringInfo	state = makeStringInfo();

	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_or ")));
		return;
	}
	if (!state->data)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_or ")));
		return;
	}
	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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

/**
 * spd_agg_bit_or
 * Combine the aggs and return the result of the bit_or
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_bit_and(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i,
				j;
	Datum		ret;
	int64		bitand = PG_INT64_MAX;
	StringInfo	state = makeStringInfo();

	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_and in spd_server ")));
		return ;
	}
	if (!state->data)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for bit_and in spd_server ")));
		return ;
	}

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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

/**
 * spd_agg_bool_and
 * Combine the aggs and return the result of the bool_and
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_bool_and(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	bool		bland = false;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			bland = (bland && agginfodata[i].result[attr].aggdata.boolvar.boolall);
		}
	}
	agginfodata[0].result[attr].finalResult = bland;
}

/**
 * spd_agg_bool_or
 * Combine the aggs and return the result of the bool_and
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_bool_or(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	bool		blor = false;

	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
																 * only if operation be
																 * FDW was Successful */
		{
			blor = (blor || agginfodata[i].result[attr].aggdata.boolvar.boolall);
		}
	}
	agginfodata[0].result[attr].finalResult = blor;
}

/**
 * spd_agg_string_agg
 * Combine the aggs and return the result of the string_agg
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_string_agg(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	char	   *delimptr;

	StringInfo	state;

	state = makeStringInfo();
	if (!state)
	{
		ereport(NOTICE, (errmsg("Memory Allocation failed for string_agg in spd_server ")));
		return ;
	}
	if (!state->data)
	{
		pfree(state);
		ereport(NOTICE, (errmsg("Memory Allocation failed for string_agg in spd_server ")));
		return ;
	}
	delimptr = getDelimiter(agginfodata[0].transquery);
	if (!delimptr)
	{
		pfree(state->data);
		pfree(state);
		return ;
	}
	for (i = 0; i < num_aggs; i++)
	{
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR) 
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
	agginfodata[0].result[attr].finalResult = CStringGetDatum(cstring_to_text_with_len(state->data, state->len));

	pfree(state->data);
	pfree(state);
	pfree(delimptr);
}

/**
 * spd_agg_stddev
 * Combine the aggs and return the result of the stddev
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_stddev(ForeignAggInfo * agginfodata, int num_aggs, int attr)
{
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	float8 left=0;
	float8 right=0;

	for (i = 0; i < num_aggs; i++)
	{
		float8 nume=0;
		float8 deno=0;
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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
	DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(float8_numeric, Float8GetDatumFast(sqrt((left+right)/count)));
}

/**
 * spd_agg_variance
 * Combine the aggs and return the result of the stddev
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
void
spd_agg_variance(ForeignAggInfo * agginfodata, int num_aggs,int attr)
{
	int			i;
	float8		dsum = 0;
	float4		fsum = 0;
	int count = 0;
	float8 left=0;
	float8 right=0;

	for (i = 0; i < num_aggs; i++)
	{
		float8 nume=0;
		float8 deno=0;
		if (agginfodata[i].result[attr].status != SPD_FRG_ERROR)		/* Consider a result
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
	DirectFunctionCall1(float8_numeric, Float8GetDatumFast(dsum));
	agginfodata[0].result[attr].finalResult = DirectFunctionCall1(float8_numeric, Float8GetDatumFast((left+right)/count));
}


/**
 * spd_get_node_connection_PG
 * Establish conenction to remote PG servers
 *
 * @param[in,out] agginfodata - All child table agg result
 * @param[in] num_aggs - number of aggs
 * @param[in] attr - number of attribute
 *
 */
PGconn *
spd_get_node_connection_PG(const char *options)
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
 * Spd_FDW_thread
 * Create a new thread and execute foreign agg
 */
void *
Spd_FDW_thread(void *arg)
{
	SpdFDWThreadData *thrdata = (SpdFDWThreadData *) arg;
	thrdata->fdwroutine->ForeignAgg(thrdata->aggnode, (void *) thrdata->agginfodata);
	return NULL;
}

static void trim(char * s) {
    char * p = s;
    int l = strlen(p);

    while(isspace(p[l - 1])) p[--l] = 0;
    while(* p && isspace(* p)) ++p, --l;

    memmove(s, p, l + 1);
}


static int strcmpi(char* s1, char* s2){
    int i;
    if(strlen(s1)!=strlen(s2))
        return -1;
    for(i=0;i<strlen(s1);i++){
        if(toupper(s1[i])!=toupper(s2[i]))
            return s1[i]-s2[i];
    }
    return 0;
}

static char* cutAtQuery(char *query, int pos, char *delim)
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
/**
 * spd_get_agg_type_new_push
 * returns the typeid of the enum the spd server
 *
 * @param[out] node - All child table agg result
 * @param[in] attNum - number of attribute
 *
 */
SpdAggType
spd_get_agg_type_new_push(const ForeignScanState *node, const int attNum)
{
	SpdAggType ret;
	char *sql2;
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
	
	const char *query_org = ((QueryDesc *)node->ss.ps.spdAggQry)->sourceText;
	int length = strlen(query_org);
	char *query = malloc(length+1);
	char *sql;
	memcpy(query,query_org,length);

	/* Pass the query to get the aggregation query token string */
	sql = cutAtQuery(query, attNum, ",");
	if(sql == NULL){
		return AGG_DEFAULT;
	}

	/* Pass the token to get the exact aggregation query string */
	sql = cutAtQuery(sql, 1, "(");

    sql2 = cutAtQuery(sql, 2, " ");
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

/**
 * spd_get_agg_type_new_push
 * returns the typeid of the enum the spd server
 *
 * @param[out] node - All child table agg result
 * @param[in] attNum - number of attribute
 *
 */

void
spd_get_agg_type_new(const ForeignScanState *node, const int nTotalAtts, SpdAggType *aggType)
{
    const char *query_org = ((QueryDesc *)node->ss.ps.spdAggQry)->sourceText;
	int length = strlen(query_org);
	char *query = palloc(length+1);
	int nAtt = 0;
	SpdAggType ret;
	char *token;
	char *save;

	memcpy(query,query_org,length);

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

Datum
spd_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs, int natts)
{

	for(int i=0; i<natts; i++)
	{

		switch (agginfodata[0].result[i].type)
		{
			case AGG_AVG:
				spd_agg_avg(agginfodata, num_aggs, i);
				break;
			case AGG_SUM:
				spd_agg_sum(agginfodata, num_aggs, i);
				break;
			case AGG_COUNT:
				spd_agg_count(agginfodata, num_aggs,i);
				break;
			case AGG_MAX:
				 spd_agg_max(agginfodata, num_aggs, i);
				 break;
			case AGG_MIN:
				 spd_agg_min(agginfodata, num_aggs, i);
				 break;
			case AGG_BIT_OR:
				spd_agg_bit_or(agginfodata, num_aggs, i);
				break;
			case AGG_BIT_AND:
				spd_agg_bit_and(agginfodata, num_aggs, i);
				break;
			case AGG_BOOL_AND:
			case AGG_EVERY:
				spd_agg_bool_and(agginfodata, num_aggs, i);
				break;
			case AGG_BOOL_OR:
				spd_agg_bool_or(agginfodata, num_aggs, i);
				break;
			case AGG_STRING_AGG:
				spd_agg_string_agg(agginfodata, num_aggs,i);
				break;
			case AGG_VAR:
				spd_agg_variance(agginfodata, num_aggs, i);
				break;
			case AGG_STDDEV:
				spd_agg_stddev(agginfodata, num_aggs, i);
				break;
			default:
				return (Datum) 0;
				break;
		}
	}

	return (Datum) 1;
}

/**
 * Set result of one datasource's aggregation into agginfodata.
 * All datasources set into agginfodata, calc final result at spd_combine_agg_new().
 * This is push down datasouce cases.
 *
 * @param[in] thrdInfo -
 * @param[in] node -
 * @param[in] count - count of datasources.
 * @param[out] agginfodata - All datasources result.
 *
 */
void spd_get_agg_Info_push(TupleTableSlot *aggSlot, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata)
{
	int natts;
	int natts_real=0;
	bool isnull = false;
	Datum datum;
	
	for(natts=0;natts < aggSlot->tts_tupleDescriptor->natts; natts++)
	{
		/**
		 * @todo must analyze plan tree for aggregation type and
		 * value types.
		 */
		SpdAggType type = spd_get_agg_type_new_push(node, natts_real);
		natts_real++;
		agginfodata[count-1].result[natts].type = type;
		agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
		datum = slot_getattr(aggSlot, natts+1, &isnull);
		switch(agginfodata[count-1].result[natts].type)
		{
		case AGG_DEFAULT:
			break;
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
			char	   *outputstr;	
			FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.spdAggQry)->dest, natts);
			agginfodata[count-1].result[natts].aggdata.avg.count.value = DatumGetInt64(slot_getattr(aggSlot, natts_real+1, &isnull));
			outputstr = DatumGetCString(slot_getattr(aggSlot, natts_real, &isnull));
			switch(agginfodata[count-1].result[natts].typid)
			{
			case FLOAT4OID:
				agginfodata[count-1].result[natts].aggdata.avg.sum.realType = strtof(outputstr, NULL);
				elog(DEBUG1,"float sum=%f",agginfodata[count-1].result[natts].aggdata.avg.sum.realType);
				break;
			case FLOAT8OID:
				agginfodata[count-1].result[natts].aggdata.avg.sum.value = strtod(outputstr, NULL);
				elog(DEBUG1,"float8 sum=%f",agginfodata[count-1].result[natts].aggdata.avg.sum.realType);
				break;
			default:
				agginfodata[count-1].result[natts].aggdata.avg.sum.bigint_val = strtod(outputstr, NULL);
				elog(DEBUG1,"defo sum=%s",outputstr);
				break;
			}
			natts_real++;
		}
		break;

		case AGG_COUNT:
		{
			agginfodata[count-1].result[natts].aggdata.count.value = DatumGetInt64(datum);
		}
		break;
				
		case AGG_VAR:
		{
			Numeric a;
			char	   *outputstr;	
			FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.spdAggQry)->dest, natts);				
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
		    a = DatumGetNumeric(slot_getattr(aggSlot, natts, &isnull));
			agginfodata[count-1].result[natts].aggdata.var.var.value=DatumGetFloat8(DirectFunctionCall1(numeric_float8, a));
		}
		break;
		case AGG_STDDEV:
		{
			char	   *outputstr;	
			Numeric a;
			FinalizeTup(aggSlot, ((QueryDesc *)node->ss.ps.spdAggQry)->dest, natts);				
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
			a = DatumGetNumeric(slot_getattr(aggSlot, natts, &isnull));
			agginfodata[count-1].result[natts].aggdata.stddev.stddev.value=DatumGetFloat8(DirectFunctionCall1(numeric_float8, a));;
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
				agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
				agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
					agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
					ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
					return;
				}
				agginfodata[count-1].result[natts].aggdata.bit_op.state = state;

				agginfodata[count-1].result[natts].aggdata.bit_op.state->len = string_len;
				agginfodata[count-1].result[natts].aggdata.bit_op.state->data = (char *) palloc(sizeof(char) * string_len + 1);
				if (!agginfodata[count-1].result[natts].aggdata.bit_op.state->data)
				{
					agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
					agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
					agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
		agginfodata[count-1].result[natts].status = SPD_FRG_OK;
	}
}

/**
 * Set result of one datasource's aggregation into agginfodata.
 * All datasources set into agginfodata, calc final result at spd_combine_agg_new().
 * This is NOT push down datasouce cases.
 *
 * @param[in] thrdInfo -
 * @param[in] node -
 * @param[in] count - count of datasources.
 * @param[out] agginfodata - All datasources result.
 *
 */
void spd_get_agg_Info(ForeignScanThreadInfo thrdInfo, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata)
{
	TupleTableSlot *aggSlot = thrdInfo.tuple;
	int natts;
	int nTotalAtts=aggSlot->tts_tupleDescriptor->natts;
	int avg_count=0;
	bool isnull = false;
	Datum datum;
	SpdAggType type[nTotalAtts];

    spd_get_agg_type_new(node, nTotalAtts, type);
	for(natts=0;natts < nTotalAtts; natts++)
	{
		avg_count++;
		/**
		 * @todo must analyze plan tree for aggregation type and
		 * value types.
		 */
		agginfodata[count-1].result[natts].type = type[natts];
		switch(agginfodata[count-1].result[natts].type)
		{
		case AGG_DEFAULT:break;
			
		case AGG_SUM:
		{
			datum = slot_getattr(aggSlot, avg_count, &isnull);
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
					datum = slot_getattr(aggSlot, avg_count, &isnull);
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					switch(agginfodata[count-1].result[natts].typid)
					{						
					case FLOAT4OID:
						agginfodata[count-1].result[natts].aggdata.avg.sum.realType = 
							DatumGetFloat4(datum);
						break;
					case FLOAT8OID:
						agginfodata[count-1].result[natts].aggdata.avg.sum.value = 
							DatumGetFloat8(datum);
						break;
					default:								
						agginfodata[count-1].result[natts].aggdata.avg.sum.bigint_val = 
							DatumGetInt64(datum);
						break;
					}
					avg_count++;
					datum = slot_getattr(aggSlot, avg_count, &isnull);
					agginfodata[count-1].result[natts].aggdata.avg.count.value = DatumGetInt64(datum);
					agginfodata[count-1].result[natts].status = SPD_FRG_OK;
				}
				break;

				case AGG_COUNT:
				{
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, avg_count, &isnull);
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
						agginfodata[count-1].result[natts].status = SPD_FRG_OK;
						
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
					datum = slot_getattr(aggSlot, avg_count, &isnull);
					state = (StringInfo) palloc(sizeof(StringInfoData));
					if (!state)
					{
						agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
						agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
					datum = slot_getattr(aggSlot, avg_count, &isnull);

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
						datum = slot_getattr(aggSlot, avg_count, &isnull);

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
								agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
								ereport(NOTICE, (errmsg("Memory Allocation Failed ")));
								return;
							}
							agginfodata[count-1].result[natts].aggdata.bit_op.state = state;

							agginfodata[count-1].result[natts].aggdata.bit_op.state->len = string_len;
							agginfodata[count-1].result[natts].aggdata.bit_op.state->data = (char *) palloc(sizeof(char) * string_len + 1);
							if (!agginfodata[count-1].result[natts].aggdata.bit_op.state->data)
							{
								agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
								agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
								ereport(NOTICE, (errmsg("Out of Range ")));
							}
						}
					}
				break;
				case AGG_MAX:
				case AGG_MIN:
				{
					agginfodata[count-1].result[natts].typid= aggSlot->tts_tupleDescriptor->attrs[natts]->atttypid;
					datum = slot_getattr(aggSlot, avg_count, &isnull);
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
								agginfodata[count-1].result[natts].status = SPD_FRG_ERROR;
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
		agginfodata[count-1].result[natts].status = SPD_FRG_OK;
	}
}

/**
 * Set finalresult to returning slot.
 *
 * @param[in] agginfodata - Store finalresult
 * @param[out] dest - Returingslot.
 *
 */

TupleTableSlot* spd_get_agg_tuple(ForeignAggInfo * agginfodata, TupleTableSlot *dest)
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
