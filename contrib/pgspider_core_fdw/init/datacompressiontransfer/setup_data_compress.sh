source $(pwd)/../environment_variable.config

POSTGRES_PORT=5432
POSTGRES_DB_1=test1
POSTGRES_DB_2=test2
POSTGRES_DB_3=test3

MYSQL_DB_1=test1
MYSQL_DB_2=test2
MYSQL_DB_3=test3

PGSPIDER_PORT=14813
PGSPIDER_DB_1=test1
PGSPIDER_DB_2=test2
PGSPIDER_DB_3=test3

INFLUXDB_NAME_1=test1
INFLUXDB_NAME_2=test2
INFLUXDB_NAME_3=test3
INFLUXDB_ORG=myorg
container_name_v2='influxdb_server_v2'
influxdbV2_image='influxdb:2.2'

PGSPIDER_SOCAT_PORT=24814

function clean_docker_img()
{
  if [ "$(docker ps -aq -f name=^/${1}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${1}$)" ]; then
        docker rm ${1}
    else
        docker rm $(docker stop ${1})
    fi
  fi
}

CURR_PATH=$(pwd)
if [[ "--start" == $1 ]]
then
  # Start PostgreSQL
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../test_data_compression" ];
  then
    ./initdb ../test_data_compression
    sed -i 's/#port = 5432.*/port = '$POSTGRES_PORT'/' ../test_data_compression/postgresql.conf
    ./pg_ctl -D ../test_data_compression start
  fi
  if ! ./pg_isready -p $POSTGRES_PORT
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../test_data_compression start
  fi

  # Start PGSPIDER
  cd ${PGSPIDER_HOME}/bin/
  if ! [ -d "../test_data_compression" ];
  then
    ./initdb ../test_data_compression
    sed -i 's/#port = 4813.*/port = '$PGSPIDER_PORT'/' ../test_data_compression/postgresql.conf
    ./pg_ctl -D ../test_data_compression start
  fi
  if ! ./pg_isready -p $PGSPIDER_PORT
  then
    echo "Start PGSpider"
    ./pg_ctl -D ../test_data_compression start
  fi
  
  # Create host_name alias
  test -f /etc/hosts || sudo touch /etc/hosts
  echo "Edit /etc/hosts: map 127.0.0.1 to pgspider.test"
  if ! grep -q pgspider.test "/etc/hosts"; then
    echo '127.0.0.1 pgspider.test' | sudo tee -a /etc/hosts
  fi

  # Start SOCAT: Simulate port forward 4814->$PGSPIDER_SOCAT_PORT
  echo "Start socat forward port 4814"
  ps aux | grep -ie socat | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
  socat TCP-LISTEN:$PGSPIDER_SOCAT_PORT,fork TCP:127.0.0.1:4814 &
  
  # Start python mock: Simulate ipconfig.me
  echo "Start trust ip mock: trust_vendor_ip.py"
  ps aux | grep -ie "trust_vendor_ip.py" | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
  python3 $CURR_PATH/trust_vendor_ip.py &

  # default cluster name: dockerGridDB
  # default user: admin
  # default pass: admin
  griddb_image='griddb/griddb:5.0.0-centos7'
  griddb_container_name1=griddb_sv1
  griddb_container_name2=griddb_sv2
  griddb_container_name3=griddb_sv3

  clean_docker_img ${griddb_container_name1}
  clean_docker_img ${griddb_container_name2}
  clean_docker_img ${griddb_container_name3}

  docker run -d --name ${griddb_container_name1} -p 10002:10001 -p 20002:20001 \
      -e GRIDDB_NODE_NUM=1 \
      -e NOTIFICATION_ADDRESS=239.0.0.2 \
      ${griddb_image}

  docker run -d --name ${griddb_container_name2} -p 10003:10001 -p 20003:20001 \
      -e GRIDDB_NODE_NUM=1 \
      -e NOTIFICATION_ADDRESS=239.0.0.3 \
      ${griddb_image}

  docker run -d --name ${griddb_container_name3} -p 10004:10001 -p 20004:20001 \
    -e GRIDDB_NODE_NUM=1 \
    -e NOTIFICATION_ADDRESS=239.0.0.4 \
    ${griddb_image}

  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
  fi

  # Start Oracle server
  if ! [[ $(systemctl status oracle-xe-21c.service) == *"active (exited)"* ]]
  then
    echo "Start Oracle Server"
    systemctl start oracle-xe-21c.service
  fi

  # Start InfluxDB
  clean_docker_img ${container_name_v2}

  docker run  -d --name ${container_name_v2} -it -p 38086:8086 \
              -e "DOCKER_INFLUXDB_INIT_MODE=setup" \
              -e "DOCKER_INFLUXDB_INIT_USERNAME=root" \
              -e "DOCKER_INFLUXDB_INIT_PASSWORD=rootroot" \
              -e "DOCKER_INFLUXDB_INIT_ORG=$INFLUXDB_ORG" \
              -e "DOCKER_INFLUXDB_INIT_BUCKET=mybucket" \
              -e "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=mytoken" \
              -e "INFLUXD_STORAGE_WRITE_TIMEOUT=100s" \
              -v $(pwd)/init_influx:/tmp \
              ${influxdbV2_image}
fi

cd $CURR_PATH
# Influxdb/oracle startup might be slow, need retention awhile before executing command.
# Retention time depends on each machine, this value should be max of {influxdb startup time, oracle startup time}.
#
# In test environment, default value is 30s.
sleep 30

# Setup oracle
sqlplus / as sysdba << EOF
@oracle_data_compression.sql
EOF

# Setup mysql
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $MYSQL_DB_1;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $MYSQL_DB_1;"
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $MYSQL_DB_2;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $MYSQL_DB_2;"
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $MYSQL_DB_3;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $MYSQL_DB_3;"

# Setup Postgres
$POSTGRES_HOME/bin/createdb -p $POSTGRES_PORT $POSTGRES_DB_1
$POSTGRES_HOME/bin/createdb -p $POSTGRES_PORT $POSTGRES_DB_2
$POSTGRES_HOME/bin/createdb -p $POSTGRES_PORT $POSTGRES_DB_3
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "grant all privileges on database $POSTGRES_DB_1 to postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "ALTER USER postgres WITH SUPERUSER;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS \"T 2\";"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS test_tbl;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS test1_tbl;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS test2_tbl;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS test_bytea;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_1 -c "DROP TABLE IF EXISTS multi;"

$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "grant all privileges on database $POSTGRES_DB_2 to postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "ALTER USER postgres WITH SUPERUSER;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_2 -c "DROP TABLE IF EXISTS \"T 2\";"

$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "grant all privileges on database $POSTGRES_DB_3 to postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "ALTER USER postgres WITH SUPERUSER;"
$POSTGRES_HOME/bin/psql -p $POSTGRES_PORT $POSTGRES_DB_3 -c "DROP TABLE IF EXISTS \"T 2\";"

# Setup PGSpider
$PGSPIDER_HOME/bin/createdb -p $PGSPIDER_PORT $PGSPIDER_DB_1
$PGSPIDER_HOME/bin/createdb -p $PGSPIDER_PORT $PGSPIDER_DB_2
$PGSPIDER_HOME/bin/createdb -p $PGSPIDER_PORT $PGSPIDER_DB_3
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "create user postgres with encrypted password 'postgres';"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "grant all privileges on database $PGSPIDER_DB_1 to postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "ALTER USER postgres WITH SUPERUSER;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS \"T 2\";"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t1;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t2;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t3;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t6;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t10;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t13;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t16;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS t19;"
$POSTGRES_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS multi1;"
$POSTGRES_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS multi2;"
$POSTGRES_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_1 -c "DROP TABLE IF EXISTS multi3;"

$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "create user postgres with encrypted password 'postgres';"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "grant all privileges on database $PGSPIDER_DB_2 to postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "ALTER USER postgres WITH SUPERUSER;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t4;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t7;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t11;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t14;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t17;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_2 -c "DROP TABLE IF EXISTS t20;"

$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "create user postgres with encrypted password 'postgres';"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "grant all privileges on database $PGSPIDER_DB_3 to postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "ALTER USER postgres WITH SUPERUSER;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t5;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t8;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t12;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t15;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t18;"
$PGSPIDER_HOME/bin/psql -p $PGSPIDER_PORT $PGSPIDER_DB_3 -c "DROP TABLE IF EXISTS t21;"

# Setup influxdb
# create buket and database mapping for v2
INFLUXDB_1=$(docker exec ${container_name_v2} influx bucket create -n $INFLUXDB_NAME_1 --org $INFLUXDB_ORG | grep $INFLUXDB_NAME_1 | cut -f 1)
docker exec ${container_name_v2} influx v1 dbrp create --bucket-id $INFLUXDB_1 --db $INFLUXDB_NAME_1 --rp autogen --default --org $INFLUXDB_ORG
INFLUXDB_2=$(docker exec ${container_name_v2} influx bucket create -n $INFLUXDB_NAME_2 --org $INFLUXDB_ORG | grep $INFLUXDB_NAME_2 | cut -f 1)
docker exec ${container_name_v2} influx v1 dbrp create --bucket-id $INFLUXDB_2 --db $INFLUXDB_NAME_2 --rp autogen --default --org $INFLUXDB_ORG
INFLUXDB_3=$(docker exec ${container_name_v2} influx bucket create -n $INFLUXDB_NAME_3 --org $INFLUXDB_ORG | grep $INFLUXDB_NAME_3 | cut -f 1)
docker exec ${container_name_v2} influx v1 dbrp create --bucket-id $INFLUXDB_3 --db $INFLUXDB_NAME_3 --rp autogen --default --org $INFLUXDB_ORG

# Notes: griddb docker startup sometimes failover due to recovery at initial stage.
# In case of initial recovery, griddb node fail to join cluster.
# Below command workaround this situation
docker exec ${griddb_container_name1} /bin/bash -c 'gs_joincluster -w -c dockerGridDB -u admin/admin'
docker exec ${griddb_container_name2} /bin/bash -c 'gs_joincluster -w -c dockerGridDB -u admin/admin'
docker exec ${griddb_container_name3} /bin/bash -c 'gs_joincluster -w -c dockerGridDB -u admin/admin'
