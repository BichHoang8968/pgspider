PGS1_DB=setcluster2_db1
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

  # Setup for Parquet and start Minio server
  cd $DATA_PATH
  mkdir -p /tmp/data_s3/setupcluster || true
  cp tbl_parquetminio.parquet /tmp/data_s3/setupcluster

  minio_image='minio/minio:RELEASE.2021-04-22T15-44-28Z.hotfix.56647434e'
  if [ ! "$(docker ps -q -f name=^/${MINIO_CONTAINER}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${MINIO_CONTAINER}$)" ]; then
        # cleanup
        docker rm ${MINIO_CONTAINER} 
    fi
    # run minio container
    docker run -d --name ${MINIO_CONTAINER} -it -p 8000:9000 -e "MINIO_ROOT_USER=minioadmin" -e "MINIO_ROOT_PASSWORD=minioadmin" -v /tmp/data_s3:/data ${minio_image} server /data
  fi
  sleep 15

fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"



