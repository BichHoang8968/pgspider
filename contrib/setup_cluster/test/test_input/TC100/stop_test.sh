#PGSpider nodes
PGS1_DB=databases
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster1_db2
CURR_PATH=$(pwd)

if [[ "--stop" == $1 ]]
then
  #stop PGSpider nodes
  #stop PGS1
  cd ${PGS1_DIR}/bin/
  if ./pg_isready -p $PGS1_PORT
  then
    echo "Stop PGS1"
    ./pg_ctl -D ../${PGS1_DB} stop #-l ../log.pgs1
    sleep 2
  fi 
  #stop Postgres nodes
  #stop PG1
  cd ${PG1_DIR}/bin/
  if ./pg_isready -p $PG1_PORT
  then
    echo "stop PG1"
    ./pg_ctl -D ../${PG1_DB} stop #-l ../log.pg1

    pkill -9 pgspider
    sleep 2
  fi

  #stop DynamoDB
  pid_dynamodb=$(pgrep -f DynamoDB)
  kill -9 $pid_dynamodb

  #stop Postgrest
  pkill -9 postgrest

  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true
  cd ${PG1_DIR}
  rm -rf ${PG1_DB} || true

  rm -rf /tmp/data_local/setupcluster
fi

cd $CURR_PATH

# InfluxDB systemtest config
container_name_v2='influxdb_server_v2'

# clean influxdb server if exists
if [ "$(docker ps -aq -f name=^/${container_name_v2}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name_v2}$)" ]; then
        docker rm ${container_name_v2}
    else
        docker rm $(docker stop ${container_name_v2})
    fi
fi

# Build influxdb_fdw with go client
CURR_PATH=$(pwd)
cd $PGSPIDER_HOME
cd ../contrib/influxdb_fdw
make clean
make clean CXX_CLIENT=1
make
make install
cd $CURR_PATH