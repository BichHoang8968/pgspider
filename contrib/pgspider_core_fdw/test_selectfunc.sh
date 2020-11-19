#!/bin/sh

sed -i 's/REGRESS =.*/REGRESS = pgspider_core_selectfunc1 pgspider_core_selectfunc2 pgspider_core_selectfunc3 pgspider_core_selectfunc4 /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/pgspider_fdw contrib\/pgspider_keepalive /' Makefile

# run setup script
cd init
./setup_selectfunc.sh --start
cd ..
make clean
make
make check | tee make_check.out
