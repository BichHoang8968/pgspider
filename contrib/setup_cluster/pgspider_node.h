#ifndef PGSPIDER_FDW_H
#define PGSPIDER_FDW_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libpq-fe.h>
#include "install_util.h"

typedef struct {
    const char *name;
    void (*func)(nodes*, PGconn*);
} spd_function;

extern const int extension_size;
extern const spd_function spd_func[];

void		node_set(nodes * option, PGconn *conn);
void			node_set_spdcore(nodes * option, PGconn *conn);
void			mapping_set_file(nodes * node_data, PGconn *conn, char *table_name);

#endif							/* PGSPIDER_FDW_H */
