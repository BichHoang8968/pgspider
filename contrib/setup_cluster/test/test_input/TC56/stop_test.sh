#PGSpider nodes
PGS1_DB=databases
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster1_db2

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
  #stop Postgres nodes
  #stop PG1
  cd ${PG1_DIR}/bin/
  if ./pg_isready -p $PG1_PORT
  then
    echo "stop PG1"
    ./pg_ctl -D ../${PG1_DB} stop #-l ../log.pg1
    sleep 2
  fi

  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true
  cd ${PG1_DIR}
  rm -rf ${PG1_DB} || true

fi
