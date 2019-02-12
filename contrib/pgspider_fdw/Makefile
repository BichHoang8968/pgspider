# contrib/postgres_fdw/Makefile

MODULE_big = pgspider_fdw
OBJS = pgspider_fdw.o option.o deparse.o connection.o shippable.o $(WIN32RES)
PGFILEDESC = "pgspider_fdw - foreign data wrapper for PostgreSQL"

PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)

EXTENSION = pgspider_fdw
DATA = pgspider_fdw--1.0.sql

REGRESS = pgspider_fdw

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/pgspider_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
