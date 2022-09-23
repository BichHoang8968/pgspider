#PGSpider nodes
PGS1_DB=setcluster11_db1
PGS2_PORT=14814
PGS2_DB=setcluster11_db4
PGS3_PORT=14815
PGS3_DB=setcluster11_db7
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster11_db2
PG2_PORT=15437
PG2_DB=setcluster11_db3
PG3_PORT=15438
PG3_DB=setcluster11_db5
PG4_PORT=15439
PG4_DB=setcluster11_db6
PG5_PORT=15440
PG5_DB=setcluster11_db8
PG6_PORT=15441
PG6_DB=setcluster11_db9
PG7_PORT=15442
PG7_DB=setcluster11_db10

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
  #stop PGS2
  cd ${PGS2_DIR}/bin/
  if ./pg_isready -p $PGS2_PORT
  then
    echo "stop PGS2"
    ./pg_ctl -D ../${PGS2_DB} stop #-l ../log.PGS2
    sleep 2
  fi
  #stop PGS3
  cd ${PGS3_DIR}/bin/
  if ./pg_isready -p $PGS3_PORT
  then
    echo "stop PGS3"
    ./pg_ctl -D ../${PGS3_DB} stop #-l ../log.PGS3
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
  #stop PG2
  cd ${PG2_DIR}/bin/
  if ./pg_isready -p $PG2_PORT
  then
    echo "stop PG2"
    ./pg_ctl -D ../${PG2_DB} stop #-l ../log.pg2
    sleep 2
  fi
  #stop PG3
  cd ${PG3_DIR}/bin/
  if ./pg_isready -p $PG3_PORT
  then
    echo "stop PG3"
    ./pg_ctl -D ../${PG3_DB} stop #-l ../log.pg3
    sleep 2
  fi
  #stop PG4
  cd ${PG4_DIR}/bin/
  if ./pg_isready -p $PG4_PORT
  then
    echo "stop PG4"
    ./pg_ctl -D ../${PG4_DB} stop #-l ../log.pg4
    sleep 2
  fi
  #stop PG5
  cd ${PG5_DIR}/bin/
  if ./pg_isready -p $PG5_PORT
  then
    echo "stop PG5"
    ./pg_ctl -D ../${PG5_DB} stop #-l ../log.pg5
    sleep 2
  fi
  #stop PG6
  cd ${PG6_DIR}/bin/
  if ./pg_isready -p $PG6_PORT
  then
    echo "stop PG6"
    ./pg_ctl -D ../${PG6_DB} stop #-l ../log.PG6
    sleep 2
  fi
  #stop PG7
  cd ${PG7_DIR}/bin/
  if ./pg_isready -p $PG7_PORT
  then
    echo "stop PG7"
    ./pg_ctl -D ../${PG7_DB} stop #-l ../log.PG7
    sleep 2
  fi
  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true
  cd ${PGS2_DIR}
  rm -rf ${PGS2_DB} || true
  cd ${PGS3_DIR}
  rm -rf ${PGS3_DB} || true

  cd ${PG1_DIR}
  rm -rf ${PG1_DB} || true
  cd ${PG2_DIR}
  rm -rf ${PG2_DB} || true
  cd ${PG3_DIR}
  rm -rf ${PG3_DB} || true
  cd ${PG4_DIR}
  rm -rf ${PG4_DB} || true
  cd ${PG5_DIR}
  rm -rf ${PG5_DB} || true
  cd ${PG6_DIR}
  rm -rf ${PG6_DB} || true
  cd ${PG7_DIR}
  rm -rf ${PG7_DB} || true 
fi

