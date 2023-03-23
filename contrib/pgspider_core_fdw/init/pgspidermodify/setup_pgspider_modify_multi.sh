PGS1_PORT=5433
PGS1_DB=pg1_modify_db
DB_NAME=postgres
PGS2_PORT=5434
PGS2_DB=pg2_modify_db
source $(pwd)/../environment_variable.config

POSTGRES_DB_NAME=pg_modify_db

CURR_PATH=$(pwd)
if [[ "--start" == $1 ]]
then
  # Start PostgreSQL 1
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../test_pgspider_modify" ];
  then
    ./initdb ../test_pgspider_modify
    sed -i 's/#port = 5432.*/port = 15432/' ../test_pgspider_modify/postgresql.conf
    ./pg_ctl -D ../test_pgspider_modify start
    sleep 2
    ./createdb -p 15432 $POSTGRES_DB_NAME
  fi
  if ! ./pg_isready -p 15432
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../test_pgspider_modify start
    sleep 2
  fi

  cd ${PGSPIDER_HOME}/bin/
  #Start PGS1
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = 4813.*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS1_PORT $DB_NAME
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
    sed -i "s~#port = 4813.*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS2_PORT $DB_NAME
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg1
    sleep 2
  fi
fi

cd ${CURR_PATH}/

# Setup Postgres
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "grant all privileges on database $POSTGRES_DB_NAME to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "ALTER USER postgres WITH SUPERUSER;"
$POSTGRES_HOME/bin/psql $POSTGRES_DB_NAME -p 15432 -U postgres < ./pg_modify_1.dat

# Setup PGSpider1 for running multi layer with 1 node postgres_fdw
$PGSPIDER_HOME/bin/psql -p $PGS1_PORT $DB_NAME < pgspider_modify_for_postgres.dat

# Setup PGSpider1 for running multi layer with multi nodes
#$PGSPIDER_HOME/bin/psql -p $PGS2_PORT $DB_NAME < pgspider_modify_multi.dat
