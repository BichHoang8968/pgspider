

PROGRAM = spd_node_get spd_node_set spd_node_del spd_table_get spd_table_set spd_table_del spd_mapping_set spd_mapping_del
PG_CPPFLAGS = -I$(libpq_srcdir) -I$(top_builddir)/src/include -O0 -g3
SHLIB_LINK = $(libpq)

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/postgres_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

spd_node_get: main.c
	gcc -o spd_node_get main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D GET_NODE
spd_node_set: main.c
	gcc -o spd_node_set main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D SET_NODE
spd_node_del: main.c
	gcc -o spd_node_del main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D DEL_NODE
spd_table_get: main.c
	gcc -o spd_table_get main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D GET_TABLE
spd_table_set: main.c
	gcc -o spd_table_set main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D SET_TABLE
spd_table_del: main.c
	gcc -o spd_table_del main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D DEL_TABLE
spd_mapping_set: main.c
	gcc -o spd_mapping_set main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D SET_MAPPING 
spd_mapping_del: main.c
	gcc -o spd_mapping_del main.c $(PG_CPPFLAGS) $(SHLIB_LINK) -D DEL_MAPPING
