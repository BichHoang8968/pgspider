PGS1_DB=setcluster2_db1
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

  # Parquet/Minio
  if [ "$(docker ps -q -f name=^/${MINIO_CONTAINER}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${MINIO_CONTAINER}$)" ]; then
        docker rm ${MINIO_CONTAINER} 
    fi
    docker rm $(docker stop ${MINIO_CONTAINER})
  fi
  rm -rf /tmp/data_s3/setupcluster

  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true

fi

cd $CURR_PATH
