PGS_DIR=/home/jenkins/postgresql-14beta2/install
PGS_PORT=15435
PGS_DB=join_limit


CURR_PATH=$(pwd)

if [[ "--start" == $1 ]]
then
  #Start PGS1
  cd ${PGS_DIR}/bin/
  if ! [ -d "../${PGS_DB}" ];
  then
    ./initdb ../${PGS_DB}
    sed -i "s~#port = .*~port = $PGS_PORT~g" ../${PGS_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS_PORT postgres
  fi
  if ! ./pg_isready -p $PGS_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS_DB} start #-l ../log.pg1
    sleep 2
  fi

fi

cd $CURR_PATH

# postgres should be already started

$PGS_DIR/bin/psql -p $PGS_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$PGS_DIR/bin/psql -p $PGS_PORT postgres -c "grant all privileges on database postgres to postgres;"
$PGS_DIR/bin/psql -p $PGS_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PGS_DIR/bin/psql postgres -p $PGS_PORT -U postgres $PGS_DB < ./postgres_join_limit.dat

