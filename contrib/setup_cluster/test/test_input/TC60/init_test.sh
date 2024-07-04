#PGSpider nodes
PGS1_DB=databases
PGS2_PORT=14814
PGS2_DB=setcluster2_db1
PGS3_PORT=14815
PGS3_DB=setcluster2_db2
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster1_db2
PG2_PORT=15437
PG2_DB=setcluster1_db3
PG3_PORT=15438
PG3_DB=setcluster1_db4
PG4_PORT=15439
PG4_DB=setcluster1_db5
PG5_PORT=15440
PG5_DB=setcluster1_db6


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
  #Start PGS2
  cd ${PGS2_DIR}/bin/
  if ! [ -d "../${PGS2_DB}" ];
  then
    ./initdb ../${PGS2_DB}
    sed -i "s~#port = .*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS2_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.PGS2
    sleep 2
    ./createdb -p $PGS2_PORT pgspider
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PGS2"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS2_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.PGS2
    sleep 2
  fi
  #Start PGS3
  cd ${PGS3_DIR}/bin/
  if ! [ -d "../${PGS3_DB}" ];
  then
    ./initdb ../${PGS3_DB}
    sed -i "s~#port = .*~port = $PGS3_PORT~g" ../${PGS3_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS3_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS3_DB} start #-l ../log.PGS3
    sleep 2
    ./createdb -p $PGS3_PORT pgspider
  fi
  if ! ./pg_isready -p $PGS3_PORT
  then
    echo "Start PGS3"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS3_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS3_DB} start #-l ../log.PGS3
    sleep 2
  fi

  #Start Postgres nodes
  #Start PG1
  cd ${PG1_DIR}/bin/
  if ! [ -d "../${PG1_DB}" ];
  then
    ./initdb ../${PG1_DB}
    sed -i "s~#port = .*~port = $PG1_PORT~g" ../${PG1_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PG1_PORT postgres3
  fi
  if ! ./pg_isready -p $PG1_PORT
  then
    echo "Start PG1"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PG2
  cd ${PG2_DIR}/bin/
  if ! [ -d "../${PG2_DB}" ];
  then
    ./initdb ../${PG2_DB}
    sed -i "s~#port = .*~port = $PG2_PORT~g" ../${PG2_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG2_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PG2_PORT postgres3
  fi
  if ! ./pg_isready -p $PG2_PORT
  then
    echo "Start PG2"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG2_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG2_DB} start #-l ../log.pg2
    sleep 2
  fi
  #Start PG3
  cd ${PG3_DIR}/bin/
  if ! [ -d "../${PG3_DB}" ];
  then
    ./initdb ../${PG3_DB}
    sed -i "s~#port = .*~port = $PG3_PORT~g" ../${PG3_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG3_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG3_DB} start #-l ../log.pg3
    sleep 2
    ./createdb -p $PG3_PORT postgres3
  fi
  if ! ./pg_isready -p $PG3_PORT
  then
    echo "Start PG3"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG3_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG3_DB} start #-l ../log.pg3
    sleep 2
  fi
  #Start PG4
  cd ${PG4_DIR}/bin/
  if ! [ -d "../${PG4_DB}" ];
  then
    ./initdb ../${PG4_DB}
    sed -i "s~#port = .*~port = $PG4_PORT~g" ../${PG4_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG4_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG4_DB} start #-l ../log.pg4
    sleep 2
    ./createdb -p $PG4_PORT postgres3
  fi
  if ! ./pg_isready -p $PG4_PORT
  then
    echo "Start PG4"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG4_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG4_DB} start #-l ../log.pg4
    sleep 2
  fi
  #Start PG5
  cd ${PG5_DIR}/bin/
  if ! [ -d "../${PG5_DB}" ];
  then
    ./initdb ../${PG5_DB}
    sed -i "s~#port = .*~port = $PG5_PORT~g" ../${PG5_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG5_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG5_DB} start #-l ../log.pg5
    sleep 2
    ./createdb -p $PG5_PORT postgres3
  fi
  if ! ./pg_isready -p $PG5_PORT
  then
    echo "Start PG5"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG5_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG5_DB} start #-l ../log.pg5
    sleep 2
  fi

fi
#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"
#PGSpider should be already started
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS2_DIR/bin/psql -p $PGS2_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"
#PGSpider should be already started
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS3_DIR/bin/psql -p $PGS3_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH

# postgres should be already started

$PG1_DIR/bin/psql -p $PG1_PORT postgres3 -c "create user postgres with encrypted password 'postgres';"
$PG1_DIR/bin/psql -p $PG1_PORT postgres3 -c "grant all privileges on database postgres to postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres3 -c "ALTER USER postgres WITH SUPERUSER;"
$PG1_DIR/bin/psql postgres3 -p $PG1_PORT  -U postgres < ./init_postgres.sql

$PG2_DIR/bin/psql -p $PG2_PORT postgres3 -c "create user postgres with encrypted password 'postgres';"
$PG2_DIR/bin/psql -p $PG2_PORT postgres3 -c "grant all privileges on database postgres to postgres;"
$PG2_DIR/bin/psql -p $PG2_PORT postgres3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG2_DIR/bin/psql -p $PG2_PORT postgres3 -c "ALTER USER postgres WITH SUPERUSER;"
$PG2_DIR/bin/psql postgres3 -p $PG2_PORT  -U postgres < ./init_postgres.sql

$PG3_DIR/bin/psql -p $PG3_PORT postgres3 -c "create user postgres with encrypted password 'postgres';"
$PG3_DIR/bin/psql -p $PG3_PORT postgres3 -c "grant all privileges on database postgres to postgres;"
$PG3_DIR/bin/psql -p $PG3_PORT postgres3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG3_DIR/bin/psql -p $PG3_PORT postgres3 -c "ALTER USER postgres WITH SUPERUSER;"
$PG3_DIR/bin/psql postgres3 -p $PG3_PORT  -U postgres < ./init_postgres.sql

$PG4_DIR/bin/psql -p $PG4_PORT postgres3 -c "create user postgres with encrypted password 'postgres';"
$PG4_DIR/bin/psql -p $PG4_PORT postgres3 -c "grant all privileges on database postgres to postgres;"
$PG4_DIR/bin/psql -p $PG4_PORT postgres3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG4_DIR/bin/psql -p $PG4_PORT postgres3 -c "ALTER USER postgres WITH SUPERUSER;"
$PG4_DIR/bin/psql postgres3 -p $PG4_PORT  -U postgres < ./init_postgres.sql

$PG5_DIR/bin/psql -p $PG5_PORT postgres3 -c "create user postgres with encrypted password 'postgres';"
$PG5_DIR/bin/psql -p $PG5_PORT postgres3 -c "grant all privileges on database postgres to postgres;"
$PG5_DIR/bin/psql -p $PG5_PORT postgres3 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG5_DIR/bin/psql -p $PG5_PORT postgres3 -c "ALTER USER postgres WITH SUPERUSER;"
$PG5_DIR/bin/psql postgres3 -p $PG5_PORT  -U postgres < ./init_postgres.sql
