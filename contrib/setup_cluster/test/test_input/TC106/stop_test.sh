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


# clean up objstorage
docker compose -p objstoragetest stop minio
docker compose -p objstoragetest stop azurite
docker compose -p objstoragetest stop gcs
docker compose -p objstoragetest rm -fsv minio
docker compose -p objstoragetest rm -fsv azurite
docker compose -p objstoragetest rm -fsv gcs
docker volume rm objstoragetest_minio-data
docker volume rm objstoragetest_azurite-data
docker volume rm objstoragetest_gcs-data