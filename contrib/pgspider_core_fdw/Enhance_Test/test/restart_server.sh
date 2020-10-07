#!/bin/bash
# Script to set up PGSpider
#
PGSPIDER=$1
PORT=$2
DESTPGSPIDER=$3

FOLDER="PGS$PORT"

cd $DESTPGSPIDER/$FOLDER/bin

export LD_LIBRARY_PATH=":$DESTPGSPIDER/$FOLDER/lib:/usr/lib64/mysql/:$PGSPIDER/contrib/griddb_fdw/griddb/bin:/usr/local/tinybrace/lib"

$DESTPGSPIDER/$FOLDER/bin/pg_ctl -D  $DESTPGSPIDER/$FOLDER/databases -l /dev/null restart