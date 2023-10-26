#PGSpider nodes
PGS1_DB=setcluster2_db1
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster2_db2

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

DATA_PATH=$INIT_DATA_PATH
export http_proxy=
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
  #Start Postgres
  #Start PG1
  cd ${PG1_DIR}/bin/
  if ! [ -d "../${PG1_DB}" ];
  then
    ./initdb ../${PG1_DB}
    sed -i "s~#port = .*~port = $PG1_PORT~g" ../${PG1_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PG1_PORT postgres
    ./createdb -p $PG1_PORT odbcpostgres
  fi
  if ! ./pg_isready -p $PG1_PORT
  then
    echo "Start PG1"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
  fi

  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi
  # Stop TinyBrace Server
  if pgrep -x "tbserver" > /dev/null
  then
    echo "Stop TinyBrace Server"
    pkill -9 tbserver
    sleep 2
  fi
  cd $DATA_PATH
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/test_setcluster.db < ./init_tiny.sql
  # Start TinyBrace Server
  echo "Start TinyBrace Server"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3
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
  rm -rf ${GS_HOME}/data/* ${GS_HOME}/txnlog/* ${GS_HOME}/swap/* ${GS_LOG}/*
  sed -i 's/\"clusterName\":.*/\"clusterName\":\"griddbfdwTestSetcluster\",/' ${GRIDDB_HOME}/conf/gs_cluster.json
  echo "Starting GridDB server..."
  ${GRIDDB_HOME}/bin/gs_startnode -w -u admin/testadmin
  ${GRIDDB_HOME}/bin/gs_joincluster -w -c griddbfdwTestSetcluster -u admin/testadmin  

  # Start Oracle server
  if ! [[ $(systemctl status oracle-xe-21c.service) == *"active (exited)"* ]]
  then
    echo "Start Oracle Server"
    systemctl start oracle-xe-21c.service
    sleep 2
  fi

  # Setup for Parquet and start Minio server
  cd $DATA_PATH
  mkdir -p /tmp/data_s3/setupcluster || true
  mkdir -p /tmp/data_local/setupcluster || true
  cp tbl_parquetminio.parquet /tmp/data_s3/setupcluster
  cp tbl_parquetlocal.parquet /tmp/data_local/setupcluster
  minio_image='minio/minio:RELEASE.2021-04-22T15-44-28Z.hotfix.56647434e'

  if [ ! "$(docker ps -q -f name=^/${MINIO_CONTAINER}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${MINIO_CONTAINER}$)" ]; then
        # cleanup
        docker rm ${MINIO_CONTAINER} 
    fi
    # run minio container
    docker run -d --name ${MINIO_CONTAINER} -it -p 8000:9000 -e "MINIO_ROOT_USER=minioadmin" -e "MINIO_ROOT_PASSWORD=minioadmin" -v /tmp/data_s3:/data ${minio_image} server /data
  fi

  # Start for SQLumDash server
  OLD_LIBRARY_PATH=$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$SQLUMDASH_LIB_PATH:$SLDCS_LIB_PATH:$SQL_LIB_PATH
  cd $SLDCS_BIN_PATH
  ./database_management create $SLD_DB_NAME
  ./user_account_management add $SLD_USER $SLD_PASSWORD
  ./sqlumdash &
  sleep 3
  export LD_LIBRARY_PATH=$OLD_LIBRARY_PATH
fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH
rm /tmp/test_setcluster/*
mkdir -p /tmp/test_setcluster
cp ./tbl_file.csv /tmp/test_setcluster/
# SET PASSWORD = PASSWORD('Mysql_1234')
mysql -uroot -pMysql_1234 < ./init_mysql.sql
mysql -uroot -pMysql_1234 < ./init_odbc_mysql.sql
# Initialize data for GridDB
echo "Init data for GridDB..."
rm /tmp/tbl_grid.data
cp tbl_grid.data /tmp/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${GRIDDB_CLIENT}/bin
gcc griddb_init.c -o griddb_init -I${GRIDDB_CLIENT}/client/c/include -L${GRIDDB_CLIENT}/bin -lgridstore
./griddb_init 239.0.0.1 31999 griddbfdwTestSetcluster admin testadmin /tmp/tbl_grid.data 1

# postgres should be already started
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "grant all privileges on database postgres to postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "grant all privileges on database odbcpostgres to postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "ALTER USER postgres WITH SUPERUSER;"
$PG1_DIR/bin/psql postgres -p $PG1_PORT  -U postgres -d postgres < ./init_postgres.sql
$PG1_DIR/bin/psql postgres -p $PG1_PORT  -U postgres -d odbcpostgres < ./init_odbc_postgres.sql

# Setup Oracle
sqlplus / as sysdba << EOF
@$DATA_PATH/init_oracle.sql
EOF

# Setup SQLumDash
cp init_sqlumdash.sql $SLDCS_CLIENT_SHELL_PATH
cd $SLDCS_CLIENT_SHELL_PATH
./shellcs  -host $SLD_HOST -port $SLD_PORT -user $SLD_USER -pwd $SLD_PASSWORD -db $SLD_DB_NAME < init_sqlumdash.sql

# Setup InfluxDB
# InfluxDB systemtest config
container_name_v2='influxdb_server_v2'
influxdbV2_image='influxdb:2.2'

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

# run server
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


# create buket and database mapping for v2
test_setcluster=$(docker exec ${container_name_v2} influx bucket create -n test_setcluster | grep test_setcluster | cut -f 1)
docker exec ${container_name_v2} influx v1 dbrp create --bucket-id $test_setcluster --db test_setcluster -rp autogen --default

# Init data V2
docker exec ${container_name_v2} influx write --bucket test_setcluster --precision s --file /tmp/tbl_influx_2.data

cd $CUR_PATH