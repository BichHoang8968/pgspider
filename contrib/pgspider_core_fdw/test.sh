#!/bin/sh
# run setup script
cd init
./setup.sh --start
cd ..
sed -i 's/REGRESS =.*/REGRESS = pgspider_core_fdw /' Makefile

make clean
make
make check | tee make_check.out
