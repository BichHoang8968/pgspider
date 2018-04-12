# contrib/spd_fdw/Makefile

MODULE_big = spd_fdw
OBJS = spd_fdw.o spd_option.o spd_fdw_aggregate.o spd_util.o $(WIN32RES)
PGFILEDESC = "spd_fdw - foreign data wrapper for PostgreSQL"

PG_CPPFLAGS = -I$(libpq_srcdir)  -lpostgres_fdw -lpthread -lpq -lm -z defs -std=c99
SHLIB_LINK = $(libpq) 

#LIBS = -lpostgres_fdw

EXTENSION = spd_fdw
DATA = spd_fdw--1.0.sql

REGRESS = spd_fdw

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/spd_fdw/
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

