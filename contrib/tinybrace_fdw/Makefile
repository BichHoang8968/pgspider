######################################################################-------------------------------------------------------------------------
#
# mysql_fdw.c
# 		Foreign-data wrapper for remote MySQL servers
#
# Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
#
# Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
#
# IDENTIFICATION
# 		tinybrace_fdw.c
#
##########################################################################

MODULE_big = tinybrace_fdw
OBJS = connection.o option.o deparse.o tinybrace_query.o tinybrace_fdw.o

EXTENSION = tinybrace_fdw
DATA = tinybrace_fdw--1.0.sql

REGRESS = tinybrace_fdw

PG_CPPFLAGS := -I/usr/local/tinybrace/include -L/usr/local/tinybrace/lib -ltbclient -lpthread -lpq -lm -z defs -std=c99

#LIB := $(shell $(TINYBRACE_CONFIG) --libs)

# In Debian based distros, libmariadbclient-dev provides mariadbclient (rather than tinybraceclient)
#TINYBRACE_LIB = tinybraceclient

UNAME = uname
OS := $(shell $(UNAME))
ifeq ($(OS), Darwin)
DLSUFFIX = .dylib
else
DLSUFFIX = .so
endif

SHLIB_LINK += -ltbclient

PG_CPPFLAGS += -D _TINYBRACE_LIBNAME=\"lib$(TINYBRACE_LIB)$(DLSUFFIX)\"

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
ifndef MAJORVERSION
MAJORVERSION := $(basename $(VERSION))
endif
ifeq (,$(findstring $(MAJORVERSION), 9.3 9.4 9.5 9.6))
$(error PostgreSQL 9.3, 9.4, 9.5 or 9.6 is required to compile this extension)
endif

else
subdir = contrib/tinybrace_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

