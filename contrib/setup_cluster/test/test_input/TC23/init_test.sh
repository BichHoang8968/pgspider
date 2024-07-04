#PGSpider nodes
PGS1_DB=databases
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster1_db2

DATA_PATH=$INIT_DATA_PATH

if [[ "--start" == $1 ]]
then
  #Start PGSpider nodes
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = .*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
    ./createdb -p $PGS1_PORT pgspider
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PGS1"
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
  fi
  #Start Postgres nodes
  #Start PG1
  # cd ${PG1_DIR}/bin/
  # if ! [ -d "../${PG1_DB}" ];
  # then
    # ./initdb ../${PG1_DB}
    # sed -i "s~#port = .*~port = $PG1_PORT~g" ../${PG1_DB}/postgresql.conf
	# sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    # ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    # sleep 2
    # ./createdb -p $PG1_PORT postgres
  # fi
  # if ! ./pg_isready -p $PG1_PORT
  # then
    # echo "Start PG1"
	# sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    # ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    # sleep 2
  # fi
 
fi
#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH

# postgres should be already started
# $PG1_DIR/bin/psql -p $PG1_PORT postgres -c "create user postgres with encrypted password 'postgres';"
# $PG1_DIR/bin/psql -p $PG1_PORT postgres -c "grant all privileges on database postgres to postgres;"
# $PG1_DIR/bin/psql -p $PG1_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "ALTER USER postgres WITH SUPERUSER;"
# $PG1_DIR/bin/psql postgres -p $PG1_PORT  -U postgres < ./init_postgres.sql
