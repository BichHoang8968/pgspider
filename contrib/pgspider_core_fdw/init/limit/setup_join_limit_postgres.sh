PG_PORT=15435
DB_NAME=join_limit

source $(pwd)/../environment_variable.config

if [[ "--start" == $1 ]]
then
  #Start POSTGRES
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../${DB_NAME}" ];
  then
    ./initdb ../${DB_NAME}
    sed -i "s~#port = .*~port = $PG_PORT~g" ../${DB_NAME}/postgresql.conf
    ./pg_ctl -D ../${DB_NAME} start
    sleep 2
    ./createdb -p $PG_PORT postgres
  fi
  if ! ./pg_isready -p $PG_PORT
  then
    echo "Start POSTGRES"
    ./pg_ctl -D ../${DB_NAME} start
    sleep 2
  fi

fi

cd $CURR_PATH

# postgres should be already started

$POSTGRES_HOME/bin/psql -p $PG_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p $PG_PORT postgres -c "grant all privileges on database postgres to postgres;"
$POSTGRES_HOME/bin/psql -p $PG_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql postgres -p $PG_PORT -U postgres $DB_NAME < ./postgres_join_limit.dat

