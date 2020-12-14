#!/bin/bash
# Script to set up PGSpider
#
PGSPIDER=$1
PORT=$2
DESTPGSPIDER=$3

setup_pgspider(){
  FOLDER="PGS$PORT"
  echo "--------$FOLDER----------"
  cd $DESTPGSPIDER
  if [ -d "$DESTPGSPIDER/$FOLDER" ]; then
    $DESTPGSPIDER/$FOLDER/bin/pg_ctl -D $DESTPGSPIDER/$FOLDER/databases stop
  fi
  mkdir $DESTPGSPIDER/$FOLDER
  #mkdir -p $DESTPGSPIDER/$FOLDER/PGSpider/
  cd $PGSPIDER
  chmod +x ./configure
  ./configure --prefix=$DESTPGSPIDER/$FOLDER > /dev/null
  make install > /dev/null
  setup_fdw
  # rm -R $DESTPGSPIDER/$FOLDER/PGSpider/PGS 2> /dev/null
  # mkdir $DESTPGSPIDER/$FOLDER/PGSpider/PGS
  # cd $DESTPGSPIDER/$FOLDER/PGSpider
  # $DESTPGSPIDER/$FOLDER/PGSpider/configure --prefix=$DESTPGSPIDER/$FOLDER/PGSpider/PGS > /dev/null 2>&1
  # cd $DESTPGSPIDER/$FOLDER/PGSpider
  # make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  
  cd $DESTPGSPIDER/$FOLDER/bin
  rm -Rf ../databases
  ./initdb ../databases
  cd $DESTPGSPIDER/$FOLDER/databases
  sed -i "s/#port = 4813.*/port = $PORT/" postgresql.conf
  sed -i 's/max_connections = .*/max_connections = 1000/' postgresql.conf
  
  cd $DESTPGSPIDER/$FOLDER/bin
  export LD_LIBRARY_PATH=":$DESTPGSPIDER/$FOLDER/lib:/usr/lib64/mysql/:$PGSPIDER/contrib/griddb_fdw/griddb/bin:/usr/local/tinybrace/lib"
  $DESTPGSPIDER/$FOLDER/bin/pg_ctl -D  $DESTPGSPIDER/$FOLDER/databases -l /dev/null start
  $DESTPGSPIDER/$FOLDER/bin/createdb -p "$PORT" pgspider
}

setup_fdw(){
  cd $PGSPIDER/contrib/pgspider_fdw	
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/pgspider_core_fdw/
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/postgres_fdw/
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/file_fdw/
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/sqlite_fdw
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/mysql_fdw
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/griddb_fdw
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/tinybrace_fdw
  make clean > /dev/null && make > /dev/null && make install > /dev/null
  
  cd $PGSPIDER/contrib/influxdb_fdw
  make clean > /dev/null && make > /dev/null && make install > /dev/null
}

setup_pgspider