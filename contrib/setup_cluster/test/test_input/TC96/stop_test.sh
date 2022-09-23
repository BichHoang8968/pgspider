#PGSpider nodes
PGS1_DB=setcluster2_db1
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster2_db2
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

  # SQLumDash
  killall -9 sqlumdash
  cd $SLDCS_BIN_PATH
  ./database_management drop $SLD_DB_NAME
  ./user_account_management delete $SLD_USER

  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true

fi

cd $CURR_PATH
