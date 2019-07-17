PGS1_DIR=/home/jenkins/PGSpider/PGS1/
PGS1_PORT=5433
PGS2_DIR=/home/jenkins/PGSpider/PGS2/
PGS2_PORT=5434
DB_NAME=postgres
TINYBRACE_HOME=/usr/local/tinybrace
GRIDDB_CLIENT=/home/jenkins/GridDB/c_client_4.1.0/griddb
GRIDDB_HOME=/home/jenkins/GridDB/griddb_nosql-4.1.0/

## Setup GridDB
if [[ ! -d "${GRIDDB_HOME}" ]]; then
  echo "GRIDDB_HOME environment variable not set"
  exit 1
fi

# Start GridDB server
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

# Initialize data for GridDB
cp -a griddb*.data /tmp/
cp -a $GRIDDB_CLIENT ./
gcc griddb_init.c -o griddb_init -Igriddb/client/c/include -Lgriddb/bin -lgridstore
./griddb_init 239.0.0.1 31999 griddbfdwTestCluster admin testadmin

## Setup TinyBrace
# stop tbserver
if pgrep -x "tbserver" > /dev/null
then
  echo "Stop TinyBrace Server"
  pkill -9 tbserver
  sleep 2
fi
# /usr/local/tinybrace/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=test.db < tiny.dat
$TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/test.db < tiny.dat
# start tbserver
echo "Start TinyBrace Server"
CURR_PATH=$(pwd)
cd $TINYBRACE_HOME
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
bin/tbserver &
cd $CURR_PATH
sleep 3

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

psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
psql postgres -p 15432  -U postgres < post.dat

# Setup PGSPider1 and PGSpider2
$PGS1_DIR/bin/psql -p $PGS1_PORT $DB_NAME < pgspider1.dat
$PGS2_DIR/bin/psql -p $PGS2_PORT $DB_NAME < pgspider2.dat
