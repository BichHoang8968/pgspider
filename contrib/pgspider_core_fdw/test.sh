#!/bin/sh
# run setup script
cd init
./setup.sh --start
cd ..
sed -i 's/REGRESS =.*/REGRESS = pgspider_core_fdw ported_import_s3 ported_parquet_s3_fdw ported_parquet_s3_fdw2 /' Makefile

make clean
make
make check | tee make_check.out
