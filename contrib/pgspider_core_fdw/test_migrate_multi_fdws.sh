#!/bin/sh
DIR_INIT=$(pwd)/init
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${GRIDDB_LIB}:${MYSQL_LIB}:${TINYBRACE_LIB}:${ORACLE_LIB}:${LOCAL_LIB}:${LOCAL_LIB64}

#Function to run make check
make_test () {
  mkdir -p results/migrate || true
  make check | tee make_check.out
}
#Save original values regress, temp-install, checkprep before change
ORIGIN_REGRESS=$(grep 'REGRESS = \([^\n]\+\)' Makefile)
ORIGIN_TMP_INSTALL=$(grep 'temp-install: \([^\n]\+\)' Makefile)
ORIGIN_CHECKPREP=$(grep 'checkprep: \([^\n]\+\)' Makefile)

#Make clean and make
make clean
make

cd $DIR_INIT
chmod +x setup_migrate_multi_fdws.sh
./setup_migrate_multi_fdws.sh

cd ..
sed -i 's/REGRESS =.*/REGRESS = migrate\/migrate_postgres migrate\/migrate_griddb migrate\/migrate_influxdb migrate\/migrate_mysql migrate\/migrate_parquet_s3_server migrate\/migrate_oracle migrate\/migrate_griddb_to_postgres migrate\/migrate_mysql_to_postgres migrate\/migrate_parquet_s3_to_postgres migrate\/migrate_oracle_to_postgres migrate\/migrate_postgres_to_griddb migrate\/migrate_postgres_to_mysql migrate\/migrate_postgres_to_parquet_s3 migrate\/migrate_postgres_to_oracle migrate\/migrate_postgres_to_influxdb migrate\/migrate_influxdb_to_postgres migrate\/migrate_multi_sources /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/griddb_fdw contrib\/influxdb_fdw contrib\/mysql_fdw contrib\/oracle_fdw contrib\/parquet_s3_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/griddb_fdw contrib\/influxdb_fdw contrib\/mysql_fdw contrib\/oracle_fdw contrib\/parquet_s3_fdw /' Makefile

make_test

#Revert Makefile to original
ORIGIN_REGRESS=$(echo "${ORIGIN_REGRESS}" | sed -e 's/\//\\\//g')
ORIGIN_TMP_INSTALL=$(echo "${ORIGIN_TMP_INSTALL}" | sed -e 's/\//\\\//g')
ORIGIN_CHECKPREP=$(echo "${ORIGIN_CHECKPREP}" | sed -e 's/\//\\\//g')
sed -i -e "s/REGRESS =.*/${ORIGIN_REGRESS}/" Makefile
sed -i -e "s/temp-install:.*/${ORIGIN_TMP_INSTALL}/" Makefile
sed -i -e "s/checkprep:.*/${ORIGIN_CHECKPREP}/" Makefile
