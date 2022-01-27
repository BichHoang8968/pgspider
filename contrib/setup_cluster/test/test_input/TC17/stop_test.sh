#PGSpider nodes
#PGS1_DIR=/home/jenkins/PGSpider/install
#PGS1_PORT=14813
PGS1_DB=setcluster1_db1
#PGS2_DIR=/home/jenkins/PGSpider/install
PGS2_PORT=14814
PGS2_DB=setcluster1_db4
#PGS3_DIR=/home/jenkins/PGSpider/install
PGS3_PORT=14815
PGS3_DB=setcluster1_db5
#PGS4_DIR=/home/jenkins/PGSpider/install
PGS4_PORT=14816
PGS4_DB=setcluster1_db7
#PGS5_DIR=/home/jenkins/PGSpider/install
PGS5_PORT=14817
PGS5_DB=setcluster1_db10
#Postgres nodes
#PG1_DIR=/home/jenkins/postgresql-14beta2/install
PG1_PORT=5432
PG1_DB=setcluster1_db2
#PG2_DIR=/home/jenkins/postgresql-14beta2/install
PG2_PORT=15437
PG2_DB=setcluster1_db3
#PG3_DIR=/home/jenkins/postgresql-14beta2/install
PG3_PORT=15438
PG3_DB=setcluster1_db6
#PG4_DIR=/home/jenkins/postgresql-14beta2/install
PG4_PORT=15439
PG4_DB=setcluster1_db8
#PG5_DIR=/home/jenkins/postgresql-14beta2/install
PG5_PORT=15440
PG5_DB=setcluster1_db9
#PG6_DIR=/home/jenkins/postgresql-14beta2/install
PG6_PORT=15441
PG6_DB=setcluster1_db11
#PG7_DIR=/home/jenkins/postgresql-14beta2/install
PG7_PORT=15442
PG7_DB=setcluster1_db12

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
  #stop PGS4
  cd ${PGS4_DIR}/bin/
  if ./pg_isready -p $PGS4_PORT
  then
    echo "stop PGS4"
    ./pg_ctl -D ../${PGS4_DB} stop #-l ../log.PGS4
    sleep 2
  fi
  #stop PGS5
  cd ${PGS5_DIR}/bin/
  if ./pg_isready -p $PGS5_PORT
  then
    echo "stop PGS5"
    ./pg_ctl -D ../${PGS5_DB} stop #-l ../log.PGS5
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
    ./pg_ctl -D ../${PG6_DB} stop #-l ../log.pg6
    sleep 2
  fi
  #stop PG7
  cd ${PG7_DIR}/bin/
  if ./pg_isready -p $PG7_PORT
  then
    echo "stop PG7"
    ./pg_ctl -D ../${PG7_DB} stop #-l ../log.pg7
    sleep 2
  fi  
fi
  #clean DB folder
  cd ${PGS1_DIR}
  rm -rf ${PGS1_DB} || true
  cd ${PGS2_DIR}
  rm -rf ${PGS2_DB} || true
  cd ${PGS3_DIR}
  rm -rf ${PGS3_DB} || true
  cd ${PGS4_DIR}
  rm -rf ${PGS4_DB} || true
  cd ${PGS5_DIR}
  rm -rf ${PGS5_DB} || true
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
cd $CURR_PATH
