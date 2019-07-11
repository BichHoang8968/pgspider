#!/bin/sh
# run setup script
cd init
./setup.sh
cd ..
make clean
make
make check | tee make_check.out
