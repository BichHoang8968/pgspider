PG1_PORT=15433
PG1_DB=pg1db_limit
PG2_PORT=15434
PG2_DB=pg2db_limit

source $(pwd)/../environment_variable.config

if [[ "--start" == $1 ]]
then
  #Start PG1
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../${PG1_DB}" ];
  then
    ./initdb ../${PG1_DB}
    sed -i "s~#port = .*~port = $PG1_PORT~g" ../${PG1_DB}/postgresql.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PG1_PORT postgres
  fi
  if ! ./pg_isready -p $PG1_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PG2
  if ! [ -d "../${PG2_DB}" ];
  then
    ./initdb ../${PG2_DB}
    sed -i "s~#port = .*~port = $PG2_PORT~g" ../${PG2_DB}/postgresql.conf
    ./pg_ctl -D ../${PG2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PG2_PORT postgres
  fi
  if ! ./pg_isready -p $PG2_PORT
  then
    echo "Start PG2"
    ./pg_ctl -D ../${PG2_DB} start #-l ../log.pg2
    sleep 2
  fi
fi

cd $CURR_PATH

# postgres should be already started

$POSTGRES_HOME/bin/psql -p $PG1_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $PG1_PORT postgres -c "grant all privileges on database postgres to postgres;"
$POSTGRES_HOME/bin/psql -p $PG1_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $PG1_PORT postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql postgres -p $PG1_PORT -U postgres < ./postgres_1.dat

$POSTGRES_HOME/bin/psql -p $PG2_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $PG2_PORT postgres -c "grant all privileges on database postgres to postgres;"
$POSTGRES_HOME/bin/psql -p $PG2_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p $PG2_PORT postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql postgres -p $PG2_PORT -U postgres < ./postgres_2.dat


