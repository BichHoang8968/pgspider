#!/bin/sh

sed -i 's/REGRESS =.*/REGRESS = pgspidermodify\/pgspider_modify pgspidermodify\/pgspider_modify_dynamodb1 pgspidermodify\/pgspider_modify_dynamodb2 pgspidermodify\/pgspider_modify_file_fdw pgspidermodify\/pgspider_modify_griddb1 pgspidermodify\/pgspider_modify_griddb2 pgspidermodify\/pgspider_modify_jdbc1 pgspidermodify\/pgspider_modify_jdbc2 pgspidermodify\/pgspider_modify_mongo1 pgspidermodify\/pgspider_modify_mongo2 pgspidermodify\/pgspider_modify_mysql1 pgspidermodify\/pgspider_modify_mysql2 pgspidermodify\/pgspider_modify_odbc1 pgspidermodify\/pgspider_modify_odbc2 pgspidermodify\/pgspider_modify_oracle1 pgspidermodify\/pgspider_modify_oracle2 pgspidermodify\/pgspider_modify_postgres1 pgspidermodify\/pgspider_modify_postgres2 pgspidermodify\/pgspider_modify_sqlite1 pgspidermodify\/pgspider_modify_sqlite2 pgspidermodify\/pgspider_modify_tinybrace1 pgspidermodify\/pgspider_modify_tinybrace2 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/odbc_fdw contrib\/jdbc_fdw contrib\/griddb_fdw contrib\/oracle_fdw contrib\/mongo_fdw contrib\/dynamodb_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/dblink contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/odbc_fdw contrib\/jdbc_fdw contrib\/griddb_fdw contrib\/oracle_fdw contrib\/mongo_fdw contrib\/dynamodb_fdw /' Makefile

# run setup script
cd init/pgspidermodify
./setup_pgspider_modify.sh --start
cd ../..
make clean
make
mkdir -p results/pgspidermodify
make check | tee make_check.out
