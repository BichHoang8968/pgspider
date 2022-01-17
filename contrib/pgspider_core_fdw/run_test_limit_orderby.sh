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

#---------------------Model-1-----------------------------------------------------------------------------------
#Single node model with 1 node sqlite
cd $DIR_INIT_LIMIT
./setup_model_1.sh
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model1 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/sqlite_fdw /' Makefile

make_test
#---------------------Model-2-----------------------------------------------------------------------------------
#Single node model with 1 node influx
cd $DIR_INIT_LIMIT
./setup_model_2.sh
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model2 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/influxdb_fdw /' Makefile
mkdir -p results/limit || true

make_test
#---------------------Model-3-----------------------------------------------------------------------------------
#Single node model with 1 node file
cd $DIR_INIT_LIMIT
./setup_model_3.sh
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model3 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/file_fdw /' Makefile

make_test
#---------------------Model-4-----------------------------------------------------------------------------------
#Single node model with 1 node griddb
cd $DIR_INIT_LIMIT
./setup_model_4.sh --start
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model4 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/griddb_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/tinybrace_fdw contrib\/sqlite_fdw contrib\/mysql_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/influxdb_fdw contrib\/dblink contrib\/griddb_fdw /' Makefile

make_test
#---------------------Model-5-----------------------------------------------------------------------------------
#Multi node model with 2 nodes griddb
cd $DIR_INIT_LIMIT
./setup_model_5.sh --start
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model5 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/griddb_fdw /' Makefile

make_test
#---------------------Model-6-----------------------------------------------------------------------------------
#Multi node model with 2 nodes postgres
cd $DIR_INIT_LIMIT
./setup_model_6.sh --start
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model6 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/postgres_fdw /' Makefile

make_test
#---------------------Model-7-----------------------------------------------------------------------------------
#Multi node model with 5 nodes postgres, influxdb, file, mysql, tinybrace
cd $DIR_INIT_LIMIT
./setup_model_7.sh --start
cd ../..
sed -i 's/REGRESS =.*/REGRESS = limit\/model7 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/postgres_fdw contrib\/influxdb_fdw contrib\/file_fdw contrib\/mysql_fdw contrib\/tinybrace_fdw /' Makefile

make_test
#Revert Makefile to original
ORIGIN_REGRESS=$(echo "${ORIGIN_REGRESS}" | sed -e 's/\//\\\//g')
ORIGIN_TMP_INSTALL=$(echo "${ORIGIN_TMP_INSTALL}" | sed -e 's/\//\\\//g')
ORIGIN_CHECKPREP=$(echo "${ORIGIN_CHECKPREP}" | sed -e 's/\//\\\//g')
sed -i -e "s/REGRESS =.*/${ORIGIN_REGRESS}/" Makefile
sed -i -e "s/temp-install:.*/${ORIGIN_TMP_INSTALL}/" Makefile
sed -i -e "s/checkprep:.*/${ORIGIN_CHECKPREP}/" Makefile
