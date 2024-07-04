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

  #clean Gitlab
  cd ${GITLAB_HOME}
  docker compose down
fi
