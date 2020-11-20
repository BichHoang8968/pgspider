PROGRAM = setup_cluster
PG_CPPFLAGS = -I$(libpq_srcdir) -I$(top_builddir)/src/include -O0 -g3 
SHLIB_LINK = $(libpq) 
OBJS = install_main.o pgspider_node.o install_util.o

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

setup_cluster: install_main.c pgspider_node.c install_util.c
	gcc -o setup_cluster install_main.c pgspider_node.c install_util.c $(PG_CPPFLAGS) $(SHLIB_LINK)  -ljansson

