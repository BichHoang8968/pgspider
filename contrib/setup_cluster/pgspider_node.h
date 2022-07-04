#ifndef PGSPIDER_FDW_H
#define PGSPIDER_FDW_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>
#include "install_util.h"

typedef struct
{
	const char *name;
				ReturnCode(*func) (nodes *, PGconn *);
}			spd_function;

extern const int extension_size;
extern const spd_function spd_func[];

ReturnCode	node_set(nodes * option, PGconn *conn);
ReturnCode	node_set_spdcore(nodes * option, PGconn *conn);
ReturnCode	mapping_set_file(nodes * node_data, PGconn *conn, char *table_name, int seqnum);

#endif							/* PGSPIDER_FDW_H */
