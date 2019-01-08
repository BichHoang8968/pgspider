# contrib/postgres_fdw/Makefile

MODULE_big = spdfront_fdw
OBJS = spdfront_fdw.o option.o deparse.o connection.o shippable.o $(WIN32RES)
PGFILEDESC = "spdfront_fdw - foreign data wrapper for PostgreSQL"

PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)

EXTENSION = spdfront_fdw
DATA = spdfront_fdw--1.0.sql

REGRESS = spdfront_fdw

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/spdfront_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
