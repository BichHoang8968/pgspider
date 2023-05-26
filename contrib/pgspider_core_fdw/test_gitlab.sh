#!/bin/bash

sed -i 's/REGRESS =.*/REGRESS = gitlab_fdw\/pgspider_core_gitlab /' Makefile
sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/pgspider_core_fdw contrib\/pgspider_keepalive contrib\/gitlab_fdw /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/pgspider_core_fdw contrib\/pgspider_keepalive contrib\/gitlab_fdw /' Makefile

make clean
mkdir -p results/gitlab_fdw
make
make check | tee make_check.out
