#!/bin/bash
# script to checkout and install needed fdw

PROXY="http://bichht:bichht@proxy.tsdv.com.vn:3128"

SQLITE_FDW_URL=" -b master https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/sqlite_fdw.git"

MYSQL_FDW_URL=" -b master https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/mysql_fdw.git"

GRIDDB_FDW_URL=" -b master https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/griddb_fdw.git"

GRIDDB_CLIENT_DIR="/home/tsdv/workplace/griddb"

INFLUXDB_FDW_URL=" -b master https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/influxdb_fdw.git"

TINYBRACE_FDW_URL=" -b master https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/tinybrace_fdw.git"

PGSPIDER_URL=" -b port12 https://minh1.leanh:Rin%401234@tccloud2.toshiba.co.jp/swc/gitlab/db/PGSpider.git"

cd /home/tsdv/GIT/
rm -rf port12 || true
mkdir port12
cd port12
git clone $PGSPIDER_URL
cd PGSpider
./configure --prefix=$(pwd)/install
make clean && make && echo "1" | sudo -S make install

cd contrib
CONTRIB_DIR=$(pwd)

git config --global http.sslVerify false
git config --global --unset http.proxy
git config --global --unset https.proxy

rm -rf tinybrace_fdw || true
git clone $TINYBRACE_FDW_URL
cd tinybrace_fdw
make clean && make
cd $CONTRIB_DIR

rm -rf mysql_fdw mysql-fdw || true
git clone $MYSQL_FDW_URL
mv mysql-fdw mysql_fdw
cd mysql_fdw
make clean && make
cd $CONTRIB_DIR

rm -rf sqlite_fdw || true
git clone $SQLITE_FDW_URL
cd sqlite_fdw
make clean && make
cd $CONTRIB_DIR

rm -rf griddb_fdw || true
git clone $GRIDDB_FDW_URL
cd griddb_fdw
cp -a $GRIDDB_CLIENT_DIR ./
make clean && make
cd $CONTRIB_DIR

rm -rf influxdb_fdw || true
git clone $INFLUXDB_FDW_URL
cd influxdb_fdw
make clean && make
cd $CONTRIB_DIR

cd /home/tsdv/SVN/20A/tests/
svn update createview.sql
svn update restart_server.sh
svn update setupcluster.sh
svn update setuppgspider.sh
svn update pgspider_test.c
gcc -o test pgspider_test.c -lpq
chmod +x ./test
./test
