# contrib/ddsf_fdw/Makefile

MODULE_big = ddsf_fdw
OBJS = ddsf_fdw.o ddsf_option.o ddsf_fdw_aggregate.o ddsf_util.o $(WIN32RES)
PGFILEDESC = "ddsf_fdw - foreign data wrapper for PostgreSQL"

PG_CPPFLAGS = -I$(libpq_srcdir)  -lpostgres_fdw -lpthread -lpq -lm -z defs -std=c99
SHLIB_LINK = $(libpq) 

#LIBS = -lpostgres_fdw

EXTENSION = ddsf_fdw
DATA = ddsf_fdw--1.0.sql

REGRESS = ddsf_fdw

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/ddsf_fdw/
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

