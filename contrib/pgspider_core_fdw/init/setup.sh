source $(pwd)/environment_variable.config

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
  cd $CURR_PATH
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
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/test.db < tiny.dat
  # Start TinyBrace Server
  echo "Start TinyBrace Server"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3

  # Start MINIO Server
  # Clean minio server
  if [ "$(docker ps -aq -f name=^/${container_name}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name}$)" ]; then
        docker rm ${container_name}
    else
        docker rm $(docker stop ${container_name})
    fi
  fi
  # Prepare data for MINIO Server
  cd $CURR_PATH
  rm -rf /tmp/data_s3 || true
  mkdir -p /tmp/data_s3 || true
  cp -a parquets3 /tmp/data_s3
  cp -a test-bucket /tmp/data_s3
  # run minio container
  docker run  -d --name ${container_name} -it -p 9000:9000 \
              -e "MINIO_ACCESS_KEY=minioadmin" -e "MINIO_SECRET_KEY=minioadmin" \
              -v /tmp/data_s3:/data \
              ${minio_image} \
              server /data
else
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=test.db < tiny.dat
fi

cd $CURR_PATH

cp pgtest.csv /tmp/

rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite.dat

# SET PASSWORD = PASSWORD('mysql')
mysql -uroot -pMysql_1234 < mysql.dat

# postgres should be already started with port=15432
# pg_ctl -o "-p 15432" start -D data

$POSTGRES_HOME/bin/psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql postgres -p 15432  -U postgres < post.dat
