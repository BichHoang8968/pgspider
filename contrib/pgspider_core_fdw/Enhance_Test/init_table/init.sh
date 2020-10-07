#!/bin/bash
# Script to initialize data for PGSpider enhance test
#
POSTGRES_PORT=15432
TINYBRACE_HOST=127.0.0.1
TINYBRACE_PORT=5100
GRIDDB_HOST=239.0.0.1
GRIDDB_PORT=31999
TINYBRACE_HOME=/usr/local/tinybrace
GRIDDB_CLIENT=/home/tsdv/workplace/griddb
GRIDDB_HOME=/home/tsdv/workplace/griddb_nosql
POSTGRES_HOME=/home/tsdv/workplace/postgresql-12.0/install

#GRIDDB_CORE=/home/tsdv/workplace/PGSpider/contrib/pgspider_core_fdw/init
#GRIDDB_CORE=/home/tsdv/PGSpider_port12_test/PGSpider/contrib/pgspider_core_fdw/init

HOME_PATH=$(pwd)

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${POSTGRES_HOME}/lib:

if [[ "--start" == $1 ]]
then
  echo "--------Start PostgreSQL-----------"
  # Start PostgreSQL
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../databases" ];
  then
    ./initdb ../databases
    sed -i 's/#port = 5432.*/port = 15432/' ../databases/postgresql.conf
    ./pg_ctl -D ../databases start
    sleep 2
  fi
  if ! ./pg_isready -p $POSTGRES_PORT
  then
    ./pg_ctl -D ../databases stop
    ./pg_ctl -D ../databases start
    sleep 2
  fi  
  ./dropdb -p $POSTGRES_PORT enhance_post_db1 > /dev/null 2>&1
  ./dropdb -p $POSTGRES_PORT enhance_post_db2 > /dev/null 2>&1
  ./createdb -p $POSTGRES_PORT enhance_post_db1 > /dev/null 2>&1
  ./createdb -p $POSTGRES_PORT enhance_post_db2 > /dev/null 2>&1
  cd $HOME_PATH
  # Start MySQL
  echo "--------Start MySQL-----------"
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    #systemctl start mysqld.service
    systemctl start mysqld
    sleep 2
  fi
  # Start InfluxDB server
  echo "--------Start InfluxDB-----------"
  if ! [[ $(systemctl status influxdb) == *"active (running)"* ]]
  then
    systemctl start influxdb
    sleep 2
  fi
  # Start GridDB server
  echo "--------Start GridDB-----------"
  if [[ ! -d "${GRIDDB_HOME}" ]];
  then
    echo "GRIDDB_HOME environment variable not set"
    exit 1
  fi
  export GS_HOME=${GRIDDB_HOME}
  export GS_LOG=${GRIDDB_HOME}/log
  export no_proxy=127.0.0.1
  if pgrep -x "gsserver" > /dev/null
  then
    ${GRIDDB_HOME}/bin/gs_leavecluster -w -f -u admin/testadmin
    ${GRIDDB_HOME}/bin/gs_stopnode -w -u admin/testadmin
    sleep 1
  fi
  rm -rf ${GS_HOME}/data/* ${GS_LOG}/*
  sed -i 's/\"clusterName\":.*/\"clusterName\":\"griddbfdwTestCluster\",/' ${GRIDDB_HOME}/conf/gs_cluster.json
  echo "Start GridDB server..."
  ${GRIDDB_HOME}/bin/gs_startnode -w -u admin/testadmin
  ${GRIDDB_HOME}/bin/gs_joincluster -w -c griddbfdwTestCluster -u admin/testadmin
  
  # Stop TinyBrace Server
  if pgrep -x "tbserver" > /dev/null
  then
    pkill -9 tbserver
    sleep 2
  fi
  echo  "Initialize data for TinyBrace Server"
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/tinybrace_enhance_1.db < ./tinybrace/tinybrace1.data
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/tinybrace_enhance_2.db < ./tinybrace/tinybrace2.data
  # Start TinyBrace Server
  echo "--------Start TinyBrace-----------"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3
else
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbcshell -id=user -pwd=testuser -server=$TINYBRACE_HOST -port=$TINYBRACE_PORT -db=tinybrace_enhance_1.db < ./tinybrace/tinybrace1.data
  $TINYBRACE_HOME/bin/tbcshell -id=user -pwd=testuser -server=$TINYBRACE_HOST -port=$TINYBRACE_PORT -db=tinybrace_enhance_2.db < ./tinybrace/tinybrace2.data
fi
cd $HOME_PATH

# Initialize data for GridDB

echo "--------Initialize data for GridDB-----------"
cd ./griddb
cp -a ./griddb*.data /tmp/
cp -a $GRIDDB_CLIENT ./
#cp -a $GRIDDB_CORE/griddb*.data /tmp/
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:./griddb/bin
gcc griddb_init.c -o griddb_init -Igriddb/client/c/include -Lgriddb/bin -lgridstore
./griddb_init $GRIDDB_HOST $GRIDDB_PORT griddbfdwTestCluster admin testadmin
cd $HOME_PATH

## Setup CSV
echo "--------Initialize File data-----------"
rm -rf /tmp/t11 || true
mkdir /tmp/t11 && cp ./file_fdw/t11_*.csv /tmp/t11
rm -rf /tmp/t12 || true
mkdir /tmp/t12 && cp ./file_fdw/t12_*.csv /tmp/t12
rm -rf /tmp/file_max_range || true
mkdir /tmp/file_max_range && cp ./file_fdw/file_max_range*.csv /tmp/file_max_range
rm -rf /tmp/t15 || true
mkdir /tmp/t15 && cp ./file_fdw/t15*.csv /tmp/t15
# Setup SQLite
echo "--------Initialize data for SQLite-----------"
rm /tmp/sqlite_enhance_1.db /tmp/sqlite_enhance_2.db || true
sqlite3 /tmp/sqlite_enhance_1.db < ./sqlite/sqlite1.data
sqlite3 /tmp/sqlite_enhance_2.db < ./sqlite/sqlite2.data

# Setup MySQL

echo "--------Initialize data for MySQL-----------"
mysql -uroot -pMysql_1234 < ./mysql/mysql.data

# Setup InfluxDB
echo "--------Initialize data for InfluxDB-----------"
influx -import -path=./influx/influx.data -precision=ns

# Setup PostgreSQL
# PostgreSQL should be running with port=15432
echo "--------Initialize data for PostgreSQL-----------"
$POSTGRES_HOME/bin/dropdb -p $POSTGRES_PORT enhance_post_db1 > /dev/null 2>&1
$POSTGRES_HOME/bin/dropdb -p $POSTGRES_PORT enhance_post_db2 > /dev/null 2>&1
$POSTGRES_HOME/bin/createdb -p $POSTGRES_PORT enhance_post_db1 > /dev/null 2>&1
$POSTGRES_HOME/bin/createdb -p $POSTGRES_PORT enhance_post_db2 > /dev/null 2>&1
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT postgres -c "create user postgres with encrypted password 'postgres';" > /dev/null 2>&1
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT postgres -c "grant all privileges on database enhance_post_db1 to postgres;" > /dev/null 2>&1
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT postgres -c "grant all privileges on database enhance_post_db2 to postgres;" > /dev/null 2>&1
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;" > /dev/null 2>&1
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT  -U postgres -d enhance_post_db1 < ./postgres/postgres_1.data > /dev/null
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT  -U postgres -d enhance_post_db2 < ./postgres/postgres_2.data > /dev/null