source ./environment_variable.config

#=========================================================================#
# Common functions
#=========================================================================#

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

#=========================================================================#
#Start PostgreSQL
#=========================================================================#
cd ${POSTGRES_HOME}/bin/
if ! [ -d "../databases" ];
then
  ./initdb ../databases
  sed -i 's/#port = 5432.*/port = 15432/' ../databases/postgresql.conf
  ./pg_ctl -D ../databases start -l ../databases.log
  sleep 2
  ./createdb -p 15432 postgres
fi
if ! ./pg_isready -p 15432
then
  echo "Start PostgreSQL"
  ./pg_ctl -D ../databases start -l ../databases.log
  sleep 2
fi

# Prepare PostgreSQL Source
$POSTGRES_HOME/bin/dropdb -p 15432 sourcedb
$POSTGRES_HOME/bin/createdb -p 15432 sourcedb
$POSTGRES_HOME/bin/psql -p 15432 sourcedb -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 sourcedb -c "grant all privileges on database sourcedb to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 sourcedb -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 sourcedb -c "ALTER USER postgres with SUPERUSER;" # only for PostgreSQL 15.0
# Prepare PostgreSQL Destination
$POSTGRES_HOME/bin/dropdb -p 15432 destdb
$POSTGRES_HOME/bin/createdb -p 15432 destdb
$POSTGRES_HOME/bin/psql -p 15432 destdb -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 destdb -c "grant all privileges on database destdb to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 destdb -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 destdb -c "ALTER USER postgres with SUPERUSER;"  # only for PostgreSQL 15.0

#=========================================================================#
# Start GridDB server
#=========================================================================#
griddb_container_name1='griddb_node1'
clean_docker_img ${griddb_container_name1}
echo "Start GRIDDB docker NODE 1"
docker run -d --name ${griddb_container_name1} -p 10003:10001 \
    -e GRIDDB_NODE_NUM=1 \
    -e NOTIFICATION_ADDRESS=239.0.0.2 \
    ${griddb_image}

# start 2nd GridDB server in docker network
griddb_container_name2='griddb_node2'
clean_docker_img ${griddb_container_name2}
echo "Start GRIDDB docker NODE 2"

docker run -d --name ${griddb_container_name2} -p 10002:10001 \
    -e GRIDDB_NODE_NUM=1 \
    -e NOTIFICATION_ADDRESS=239.0.0.2 \
    ${griddb_image}

#=========================================================================#
# Start InfluxDB server
#=========================================================================#

if ! [[ $(systemctl status influxdb) == *"active (running)"* ]]
then
  echo "Start InfluxDB Server"
  systemctl start influxdb
  sleep 2
fi

# InfluxDB creates bukets/databases
influx -type 'influxql' -execute 'DROP DATABASE sourcedb'
influx -type 'influxql' -execute 'CREATE DATABASE sourcedb'
influx -type 'influxql' -execute 'DROP DATABASE destdb'
influx -type 'influxql' -execute 'CREATE DATABASE destdb'

#=========================================================================#
# Start MySQL
#=========================================================================#
if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
then
  echo "Start MySQL Server"
  systemctl start mysqld.service
  sleep 2
fi

# MySQL creates source and destination databases
mysql -h $MYSQL_HOST -u $MYSQL_USER_NAME -p$MYSQL_PWD -e "DROP DATABASE IF EXISTS sourcedb;"
mysql -h $MYSQL_HOST -u $MYSQL_USER_NAME -p$MYSQL_PWD -e "CREATE DATABASE sourcedb;"
mysql -h $MYSQL_HOST -u $MYSQL_USER_NAME -p$MYSQL_PWD -e "DROP DATABASE IF EXISTS destdb;"
mysql -h $MYSQL_HOST -u $MYSQL_USER_NAME -p$MYSQL_PWD -e "CREATE DATABASE destdb;"

#=========================================================================#
# Start Oracle server
#=========================================================================#
if [[ $(systemctl status oracle-xe-21c.service) == *"active (exited)"* ]]
then
  echo "Start Oracle Server"
  systemctl start oracle-xe-21c.service
  sleep 2
fi

# Oracle setup
sqlplus / as sysdba << EOF
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
DROP USER source_user CASCADE;
CREATE USER source_user IDENTIFIED BY source_user;
GRANT ALL PRIVILEGES TO source_user;
GRANT SELECT ANY DICTIONARY TO source_user;

DROP USER dest_user CASCADE;
CREATE USER dest_user IDENTIFIED BY dest_user;
GRANT ALL PRIVILEGES TO dest_user;
GRANT SELECT ANY DICTIONARY TO dest_user;
EOF

#=========================================================================#
# Docker prepare buckets/directory for S3/MinIO
#=========================================================================#

function start_minio()
{
  rm -rf ${3} || true
  mkdir -p ${3}/data/source || true
  mkdir -p ${3}/data/dest || true

  echo Start MINIO: $1 at port: $2

  clean_docker_img ${1}

  docker run  -d --name ${1} -it -p ${2}:9000 \
            -e "MINIO_ACCESS_KEY=minioadmin" -e "MINIO_SECRET_KEY=minioadmin" \
            -v ${3}:/data \
            ${minio_image} \
            server /data
}

# start 2 servers minio/s3, by docker:

minio_server1='minio_server1'
minio_server2='minio_server2'

start_minio ${minio_server1} 9000 '/tmp/data_s3_1'
start_minio ${minio_server2} 9001 '/tmp/data_s3_2'

#=========================================================================#
# END
#=========================================================================#
