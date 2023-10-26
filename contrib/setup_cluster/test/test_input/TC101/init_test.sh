#PGSpider nodes
PGS1_DB=setcluster6_db1

# Build influxdb_fdw with cxx client
CUR_PATH=$(pwd)
cd $PGSPIDER_HOME
cd ../contrib/influxdb_fdw
source /opt/rh/devtoolset-11/enable
make clean
make clean CXX_CLIENT=1
make CXX_CLIENT=1
make install
cd $CUR_PATH

if [[ "--start" == $1 ]]
then
  #Start PGSpider nodes
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = .*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
    ./createdb -p $PGS1_PORT pgspider
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PGS1"
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
  fi
fi
#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

# Setup InfluxDB
# InfluxDB systemtest config
container_name_v2='influxdb_server_v2'
influxdbV2_image='influxdb:2.2'
container_name_v1='influxdb_server_v1'
influxdbV1_image='influxdb:1.8.10'

CUR_PATH=$(pwd)
cd $INIT_DATA_PATH/init_influx_cxx

# clean influxdb server if exists
if [ "$(docker ps -aq -f name=^/${container_name_v2}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name_v2}$)" ]; then
        docker rm ${container_name_v2}
    else
        docker rm $(docker stop ${container_name_v2})
    fi
fi

if [ "$(docker ps -aq -f name=^/${container_name_v1}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name_v1}$)" ]; then
        docker rm ${container_name_v1}
    else
        docker rm $(docker stop ${container_name_v1})
    fi
fi

# run server
docker run  -d --name ${container_name_v1} -it -p 18086:8086 \
            -e "INFLUXDB_HTTP_AUTH_ENABLED=true" \
            -e "INFLUXDB_ADMIN_ENABLED=true" \
            -e "INFLUXDB_ADMIN_USER=user" \
            -e "INFLUXDB_ADMIN_PASSWORD=pass" \
            -v $(pwd):/tmp \
            ${influxdbV1_image}

# If timeout occurs, please increase this time
sleep 30

docker run  -d --name ${container_name_v2} -it -p 38086:8086 \
            -e "DOCKER_INFLUXDB_INIT_MODE=setup" \
            -e "DOCKER_INFLUXDB_INIT_USERNAME=root" \
            -e "DOCKER_INFLUXDB_INIT_PASSWORD=rootroot" \
            -e "DOCKER_INFLUXDB_INIT_ORG=myorg" \
            -e "DOCKER_INFLUXDB_INIT_BUCKET=mybucket" \
            -e "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=mytoken" \
            -e "INFLUXD_STORAGE_WRITE_TIMEOUT=100s" \
            -v $(pwd):/tmp \
            ${influxdbV2_image}

# If timeout occurs, please increase this time
sleep 30

# Init data V1
docker exec ${container_name_v1} influx -username=user -password=pass -import -path=/tmp/tbl_influx.data -precision=s

# create buket and database mapping for v2
test_setcluster=$(docker exec ${container_name_v2} influx bucket create -n test_setcluster | grep test_setcluster | cut -f 1)
docker exec ${container_name_v2} influx v1 dbrp create --bucket-id $test_setcluster --db test_setcluster -rp autogen --default

# Init data V2
docker exec ${container_name_v2} influx write --bucket test_setcluster --precision s --file /tmp/tbl_influx_2.data

cd $CUR_PATH
