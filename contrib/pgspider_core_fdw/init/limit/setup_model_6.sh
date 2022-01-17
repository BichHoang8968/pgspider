PGS1_DIR=/home/jenkins/postgresql-13.0/install
PGS1_PORT=15433
PGS1_DB=pg1db_limit
PGS2_DIR=/home/jenkins/postgresql-13.0/install
PGS2_PORT=15434
PGS2_DB=pg2db_limit

CURR_PATH=$(pwd)

if [[ "--start" == $1 ]]
then
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = .*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS1_PORT postgres
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PGS2
  if ! [ -d "../${PGS2_DB}" ];
  then
    ./initdb ../${PGS2_DB}
    sed -i "s~#port = .*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PGS2_PORT postgres
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PG2"
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
  fi
fi

cd $CURR_PATH

# postgres should be already started

$PGS1_DIR/bin/psql -p $PGS1_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$PGS1_DIR/bin/psql -p $PGS1_PORT postgres -c "grant all privileges on database postgres to postgres;"
$PGS1_DIR/bin/psql -p $PGS1_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGS1_DIR/bin/psql postgres -p $PGS1_PORT  -U postgres $PGS1_DB < ./postgres_1.dat

$PGS2_DIR/bin/psql -p $PGS2_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$PGS2_DIR/bin/psql -p $PGS2_PORT postgres -c "grant all privileges on database postgres to postgres;"
$PGS2_DIR/bin/psql -p $PGS2_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGS2_DIR/bin/psql postgres -p $PGS2_PORT  -U postgres $PGS2_DB < ./postgres_2.dat


