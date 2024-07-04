#PGSpider nodes
PGS1_DB=databases

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

  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true

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