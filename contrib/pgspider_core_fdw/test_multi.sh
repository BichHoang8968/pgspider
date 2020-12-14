#!/bin/sh

sed -i 's/REGRESS =.*/REGRESS = pgspider_core_fdw_multi /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/pgspider_fdw contrib\/pgspider_keepalive /' Makefile

# run setup script
cd init
./setup_multi.sh --start
cd ..
make clean
make
make check | tee make_check.out
