PGS1_DIR=/home/jenkins/PGSpider/PGS/
PGS1_PORT=5433
PGS1_DB=pg1db
PGS2_DIR=/home/jenkins/PGSpider/PGS/
PGS2_PORT=5434
PGS2_DB=pg2db
DB_NAME=postgres
TINYBRACE_HOME=/usr/local/tinybrace
POSTGRES_HOME=/home/jenkins/Postgres/postgresql-13.0/pgbuild
GRIDDB_CLIENT=/home/jenkins/GridDB/griddb
GRIDDB_HOME=/home/jenkins/GridDB/griddb-4.5.0
CURR_PATH=$(pwd)

if [[ "--start" == $1 ]]
then
  # Start PostgreSQL
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../databases" ];
  then
    ./initdb ../databases
    sed -i 's/#port = 5432.*/port = 15432/' ../databases/postgresql.conf
    ./pg_ctl -D ../databases start
    sleep 2
    ./createdb -p 15432 postgres
  fi
  if ! ./pg_isready -p 15432
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../databases start
    sleep 2
  fi
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = 4813.*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS1_PORT postgres
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PGS2
  if ! [ -d "../${PGS2_DB}" ];
  then
    ./initdb ../${PGS2_DB}
    sed -i "s~#port = 4813.*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PGS2_PORT postgres
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PG2"
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
  fi
  cd $CURR_PATH

  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi

  # Start InfluxDB server
  if ! [[ $(systemctl status influxdb) == *"active (running)"* ]]
  then
    echo "Start InfluxDB Server"
    systemctl start influxdb
    sleep 2
  fi

  # Start GridDB server
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
  echo "Starting GridDB server..."
  ${GRIDDB_HOME}/bin/gs_startnode -w -u admin/testadmin
  ${GRIDDB_HOME}/bin/gs_joincluster -w -c griddbfdwTestCluster -u admin/testadmin

  # Stop TinyBrace Server
  if pgrep -x "tbserver" > /dev/null
  then
    echo "Stop TinyBrace Server"
    pkill -9 tbserver
    sleep 2
  fi

  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/test.db < tiny.dat

  # Start TinyBrace Server
  echo "Start TinyBrace Server"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3
else
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=test.db < tiny.dat
fi

cd $CURR_PATH
# Initialize data for GridDB
cp -a griddb*.data /tmp/
gcc griddb_init.c -o griddb_init -I${GRIDDB_CLIENT}/client/c/include -L${GRIDDB_CLIENT}/bin -lgridstore
./griddb_init 239.0.0.1 31999 griddbfdwTestCluster admin testadmin

## Setup CSV
rm -rf /tmp/pgtest.csv
cp pgtest.csv /tmp/

# Setup SQLite
rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite.dat

# Setup Mysql
mysql -uroot -pMysql_1234 < mysql.dat

# Setup InfluxDB
influx -import -path=./influx.data -precision=ns

# postgres should be already started with port=15432
# pg_ctl -o "-p 15432" start -D data
${POSTGRES_HOME}/bin/psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
${POSTGRES_HOME}/bin/psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
${POSTGRES_HOME}/bin/psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
${POSTGRES_HOME}/bin/psql postgres -p 15432  -U postgres < post.dat

# Setup PGSPider1 and PGSpider2
$PGS1_DIR/bin/psql -p $PGS1_PORT $DB_NAME < pgspider1.dat
$PGS2_DIR/bin/psql -p $PGS2_PORT $DB_NAME < pgspider2.dat
