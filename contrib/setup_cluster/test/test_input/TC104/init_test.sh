#PGSpider nodes
PGS1_DB=setcluster3_db1

DATA_PATH=$INIT_DATA_PATH

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

  ## Setup Gitlab
  # Setup certificate for both server and client of gitlab
  cp ${INIT_DATA_PATH}/certificate/certificate_local.* ${GITLAB_HOME}/
  cp ${INIT_DATA_PATH}/certificate/certificate_local.crt /tmp/certificate.cer
  cp ${INIT_DATA_PATH}/gitlab/docker-compose.yml ${GITLAB_HOME}/

  gitlab_container_name='gitlab_server_for_existed_test'
  CUR_PATH=$(pwd)
  cd ${GITLAB_HOME}

  # clean gitlab server if exists
  echo "Clean gitlab service if exists..."
  if [ "$(docker ps -aq -f name=^/${gitlab_container_name}$)" ]; then
      docker compose down
  fi

  # run server and wait until the service is healthy
  echo "Start gitlab service..."
  docker compose up -d --wait

fi
#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

# Init data Gitlab
echo "Init data..."
docker exec ${gitlab_container_name} /bin/bash -c '/home/test/init_gitlab_test.sh'

cd ${CUR_PATH}