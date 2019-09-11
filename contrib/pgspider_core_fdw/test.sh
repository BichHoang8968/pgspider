#!/bin/sh
# run setup script
cd init
./setup.sh --start
cd ..
make clean
make
make check | tee make_check.out
