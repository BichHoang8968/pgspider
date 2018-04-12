/*-------------------------------------------------------------------------
 *
 * contrib/spd_fdw/spd_fdw_aggregate.h
 *
 *
 *-------------------------------------------------------------------------
 */
#ifndef SPD_FDW_AGGREGATE_H
#define SPD_FDW_AGGREGATE_H


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
#include "spd_fdw_defs.h"

#include "spd_fdw_api.h"

typedef struct SpdFDWThreadData
{
	FdwRoutine *fdwroutine;
	ForeignAggInfo *agginfodata;
	AggState   *aggnode;
	MemoryContext threadMemoryContext;
}	SpdFDWThreadData;


void		spd_maxmin_merge(ForeignSpdMaxMin a[], int i1, int j1, int i2, int j2);
PGconn	   *spd_get_node_connection_PG(const char *options);
void		spd_mergesort(ForeignSpdMaxMin a[], int i, int j);
void		find_and_replicate(char *o_string, char *start_string, char *end_string, char *delim_string);
void		replace(char *o_string, char *s_string, char *r_string, bool recursive);
int			spd_get_node_list(char **list);
PGconn	   *spd_create_self_node_conn(AggState *aggnode);
PGconn * spd_create_self_scannode_conn_rel_ID(Oid frgnrelID);
PGconn * spd_create_self_scannode_conn(ForeignScanState *node);
void		spd_stop_self_node_conn(PGconn *self_conn);
int			spd_get_node_options(const char *node_name, PGconn *self_conn, char *options);
void		spd_free_node_list(char **list);
void		spd_mergesort(ForeignSpdMaxMin a[], int i, int j);
void		spd_maxmin_merge(ForeignSpdMaxMin a[], int i1, int j1, int i2, int j2);
Datum		spd_combine_agg(ForeignAggInfo * agginfodata, int num_aggs, void *self_conn);
#if 0
Datum	    spd_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs);
void 	    spd_get_agg_Info(TupleTableSlot *aggSlot, const ForeignScanState *node, 
	                                                   int count, ForeignAggInfo *agginfodata);
#else

Datum	    spd_combine_agg_new(ForeignAggInfo * agginfodata, int num_aggs, int natts);
void        spd_get_agg_Info(ForeignScanThreadInfo thrdInfo, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata);
void spd_get_agg_Info_push(TupleTableSlot *aggSlot, const ForeignScanState *node, int count, ForeignAggInfo *agginfodata);
#endif
TupleTableSlot* spd_get_agg_tuple(ForeignAggInfo * agginfodata, TupleTableSlot *dest);
SpdAggType spd_get_agg_type(AggState *aggnode);
void	   *Spd_FDW_thread(void *arg);

Datum		spd_agg_sum(ForeignAggInfo * agginfodata, int num_aggs, int attr);
Datum		spd_agg_count(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_avg(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_max(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_min(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_bit_or(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_bit_and(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_bool_and(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_bool_or(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_string_agg(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_stddev(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void		spd_agg_variance(ForeignAggInfo * agginfodata, int num_aggs, int attr);
void        spd_get_agg_type_new(const ForeignScanState *node, const int nTotalAtts, SpdAggType *aggType);
SpdAggType
spd_get_agg_type_new_push(const ForeignScanState *node, const int attNum);
	
#endif   /* SPD_FDW_AGGREGATE_H */
