#!/bin/sh

sed -i 's/REGRESS =.*/REGRESS = pgspidermodify\/pgspider_modify_multi_postgres1 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/odbc_fdw contrib\/jdbc_fdw contrib\/griddb_fdw contrib\/dynamodb_fdw contrib\/oracle_fdw contrib\/mongo_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/dblink contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/odbc_fdw contrib\/jdbc_fdw contrib\/griddb_fdw contrib\/dynamodb_fdw contrib\/oracle_fdw contrib\/mongo_fdw /' Makefile

# run setup script
cd init/pgspidermodify
# ./setup_pgspider_modify.sh --start
./setup_pgspider_modify_multi.sh --start
cd ../..
make clean
make
mkdir -p results/pgspidermodify
make check | tee make_check.out
