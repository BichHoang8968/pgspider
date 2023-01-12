/*-------------------------------------------------------------------------
 *
 * pgspider_core_routing.h
 *		  Header file of pgspider_core_routing
 *
 * Portions Copyright (c) 2022, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/pgspider_core_fdw/pgspider_core_routing.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef OMIT_INSERT_ROUNDROBIN

#ifndef PGSPIDER_CORE_ROUTING_H
#define PGSPIDER_CORE_ROUTING
#include "pgspider_core_fdw.h"

void spd_instgt_init_shm(void);
void spd_inscand_get(ChildInfo *pChildInfo, int node_num);
void spd_inscand_spdurl(TupleTableSlot *slot, Relation rel,
						ChildInfo *pChildInfo, int node_num);
int spd_instst_get_target(Oid parent, ChildInfo *pChildInfo,
						  int node_num);

#endif  /* PGSPIDER_CORE_ROUTING */
#endif  /* OMIT_INSERT_ROUNDROBIN */
