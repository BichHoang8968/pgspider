#!/bin/sh
sed -i 's/REGRESS =.*/REGRESS = redmine\/pgspider_core_redmine /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/redmine_fdw contrib\/pgspider_keepalive /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/postgres_fdw contrib\/pgspider_core_fdw contrib\/pgspider_keepalive contrib\/redmine_fdw /' Makefile

make clean
mkdir -p results/redmine
make
make check | tee make_check.out
