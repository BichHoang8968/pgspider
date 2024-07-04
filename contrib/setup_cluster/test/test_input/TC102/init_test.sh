#PGSpider nodes
PGS1_DB=databases

DATA_PATH=$INIT_DATA_PATH

if [[ "--start" == $1 ]];
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

  # Setup Redmine
  redmine_container_name='redmine_server_for_existed_test'
  redmine_db_container_name='redmine_mysql_db'
  CUR_PATH=$(pwd)
  cd ${REDMINE_HOME}
  # clean redmine server if exists
  echo "Clean redmine service if exists..."
  if [ "$(docker ps -aq -f name=^/${redmine_container_name}$)" ]; then
      docker compose down
  fi

  # run server and wait until the service is healthy
  echo "Start redmine service..."
  docker compose up -d --wait

fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

# Init data
echo "Init data..."
docker exec ${redmine_container_name} /bin/bash -c 'bundle exec rails runner -e production /home/test/create_redmine_data.rb'
docker exec ${redmine_container_name} /bin/bash -c 'bundle exec rails runner -e production /home/test/create_customfields_data.rb'
docker exec ${redmine_db_container_name} /bin/bash -c '/home/test/update_date_time_fields.sh'

cd ${CUR_PATH}
