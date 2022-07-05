#!/bin/sh
DIR_INIT_LIMIT=$(pwd)/init/limit
#Function to run make check
make_test () {
  mkdir -p results/limit || true
  make check | tee make_check.out
}
#Save original values regress, temp-install, checkprep before change
ORIGIN_REGRESS=$(grep 'REGRESS = \([^\n]\+\)' Makefile)
ORIGIN_TMP_INSTALL=$(grep 'temp-install: \([^\n]\+\)' Makefile)
ORIGIN_CHECKPREP=$(grep 'checkprep: \([^\n]\+\)' Makefile)

#Make clean and make
make clean
make

#Test for model 5
#Multi node model with 2 nodes griddb
cd $DIR_INIT_LIMIT
./setup_model_5.sh --start
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model5 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/griddb_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/influxdb_fdw contrib\/dblink contrib\/griddb_fdw /' Makefile
#Make check
make_test
#Save regression result for model5
mv regression.diffs regression_model5.diffs
mv regression.out regression_model5.out
#Test for other models of limit
cd $DIR_INIT_LIMIT
./setup_model_1.sh
./setup_model_2.sh
./setup_model_3.sh
./setup_model_4.sh --start
./setup_model_6.sh --start
./setup_model_7.sh --start
./setup_join_limit_postgres.sh --start
./setup_join_limit_mysql.sh --start
./setup_join_limit_influx.sh
./setup_join_limit_file.sh

cd ../../
sed -i 's/REGRESS =.*/REGRESS = limit\/model1 limit\/model2 limit\/model3 limit\/model4 limit\/model6 limit\/model7 limit\/join_limit_postgres_fdw limit\/join_limit_mysql_fdw limit\/join_limit_influxdb_fdw limit\/join_limit_file_fdw limit\/join_limit_multi_node/' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/postgres_fdw contrib\/influxdb_fdw contrib\/file_fdw contrib\/mysql_fdw contrib\/tinybrace_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/influxdb_fdw contrib\/dblink contrib\/griddb_fdw /' Makefile

make_test
#Revert Makefile to original
ORIGIN_REGRESS=$(echo "${ORIGIN_REGRESS}" | sed -e 's/\//\\\//g')
ORIGIN_TMP_INSTALL=$(echo "${ORIGIN_TMP_INSTALL}" | sed -e 's/\//\\\//g')
ORIGIN_CHECKPREP=$(echo "${ORIGIN_CHECKPREP}" | sed -e 's/\//\\\//g')
sed -i -e "s/REGRESS =.*/${ORIGIN_REGRESS}/" Makefile
sed -i -e "s/temp-install:.*/${ORIGIN_TMP_INSTALL}/" Makefile
sed -i -e "s/checkprep:.*/${ORIGIN_CHECKPREP}/" Makefile