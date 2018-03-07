/*-------------------------------------------------------------------------
 *
 * contrib/ddsf_fdw/ddsf_fdw_aggregate.h
 *
 *
 *-------------------------------------------------------------------------
 */
#ifndef DDSF_FDW_AGGREGATE_H
#define DDSF_FDW_AGGREGATE_H


#include "postgres.h"
#include "c.h"
#include "fmgr.h"
#include <stddef.h>
#include "executor/tuptable.h"
#include "executor/execdesc.h"
#include "foreign/fdwapi.h"
#include "nodes/execnodes.h"
#include "nodes/nodes.h"
#include "nodes/pg_list.h"
#include "nodes/plannodes.h"
#include "nodes/relation.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "utils/palloc.h"
#include "foreign/foreign.h"
#include "utils/builtins.h"
#include <pthread.h>
#include "utils/rel.h"
#include "libpq-fe.h"
#include "ddsf_fdw_defs.h"

#include "ddsf_fdw_api.h"

typedef struct DdsfFDWThreadData
{
	FdwRoutine *fdwroutine;
	ForeignAggInfo *agginfodata;
	AggState   *aggnode;
	MemoryContext threadMemoryContext;
}	DdsfFDWThreadData;


void		ddsf_maxmin_merge(ForeignDdsfMaxMin a[], int i1, int j1, int i2, int j2);
PGconn	   *ddsf_get_node_connection_PG(const char *options);
void		ddsf_mergesort(ForeignDdsfMaxMin a[], int i, int j);
void		find_and_replicate(char *o_string, char *start_string, char *end_string, char *delim_string);
void		replace(char *o_string, char *s_string, char *r_string, bool recursive);
int			ddsf_get_node_list(char **list);
PGconn	   *ddsf_create_self_node_conn(AggState *aggnode);
PGconn * ddsf_create_self_scannode_conn_rel_ID(Oid frgnrelID);
PGconn * ddsf_create_self_scannode_conn(ForeignScanState *node);
void		ddsf_stop_self_node_conn(PGconn *self_conn);
int			ddsf_get_node_options(const char *node_name, PGconn *self_conn, char *options);
void		ddsf_free_node_list(char **list);
void		ddsf_mergesort(ForeignDdsfMaxMin a[], int i, int j);
void		ddsf_maxmin_merge(ForeignDdsfMaxMin a[], int i1, int j1, int i2, int j2);
Datum		ddsf_combine_agg(ForeignAggInfo * agginfodata, int num_aggs, void *self_conn);
#if 0
Datum	    ddsf_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs);
void 	    ddsf_get_agg_Info(TupleTableSlot *aggSlot, const ForeignScanState *node, 
	                                                   int count, ForeignAggInfo *agginfodata);
#else
Datum	    ddsf_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs, int natts);
void        ddsf_get_agg_Info(ForeignScanThreadInfo thrdInfo, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata);
#endif
TupleTableSlot* ddsf_get_agg_tuple(ForeignAggInfo * agginfodata, TupleTableSlot *dest);
DdsfAggType ddsf_get_agg_type(AggState *aggnode);
void	   *Ddsf_FDW_thread(void *arg);

Datum		ddsf_agg_sum(ForeignAggInfo * agginfodata, int num_aggs, int attr);
Datum		ddsf_agg_count(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_avg(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_max(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_min(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_bit_or(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_bit_and(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_bool_and(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_bool_or(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_string_agg(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_stddev(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		ddsf_agg_variance(ForeignAggInfo * agginfodata, int num_aggs, int attr);

#endif   /* DDSF_FDW_AGGREGATE_H */
