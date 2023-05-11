#!/bin/sh
sed -i 's/REGRESS =.*/REGRESS = data_compression_transfer /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/pgspider_fdw contrib\/pgspider_keepalive contrib\/postgres_fdw contrib\/mysql_fdw contrib\/griddb_fdw contrib\/oracle_fdw contrib\/influxdb_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/file_fdw contrib\/pgspider_keepalive contrib\/pgspider_fdw contrib\/postgres_fdw contrib\/mysql_fdw contrib\/griddb_fdw contrib\/oracle_fdw contrib\/influxdb_fdw /' Makefile

# run setup script
cd init/datacompressiontransfer
./setup_data_compress.sh --start
cd ../..

make clean
make
make install
make check | tee make_check.out
