#!/bin/bash
make maintainer-clean
# remove install tool
rm -rf ./contrib/setup_cluster
rm -rf dep/jansson-2.12
# remove keepalive
rm -rf ./contrib/pgspider_keepalive
unifdef -m -DWITHOUT_KEEPALIVE ./contrib/pgspider_core_fdw/pgspider_core_fdw.c
sed -i "s/shared_preload_libraries = 'pgspider_keepalive'//g" src/backend/utils/misc/postgresql.conf.sample
sed -ie "/pgspider_keepalive/d" ./src/Makefile
# remove Docker file
rm Dockerfile
rm docker.txt
rm build.sh
# remove git
rm -rf .git
rm .gitignore
rm .gitattributes
rm .dir-locals.el
