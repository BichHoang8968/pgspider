#PGSpider nodes
PGS1_DB=databases
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster1_db2

source /opt/rh/gcc-toolset-11/enable
DATA_PATH=$INIT_DATA_PATH
export http_proxy=
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
  #Start Postgres
  #Start PG1
  cd ${PG1_DIR}/bin/
  
  if ! [ -d "../${PG1_DB}" ];
  then
    ./initdb ../${PG1_DB}
    sed -i "s~#port = .*~port = $PG1_PORT~g" ../${PG1_DB}/postgresql.conf
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PG1_PORT postgres
    ./createdb -p $PG1_PORT jdbcpostgres
  fi
  if ! ./pg_isready -p $PG1_PORT
  then
    echo "Start PG1"
	sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PG1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PG1_DB} start #-l ../log.pg1
    sleep 2
  fi

  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi

  cd $DATA_PATH
  # Start MongoDB
  if ! [[ $(systemctl status mongod.service) == *"active (running)"* ]]
  then
    echo "Start MongoDB Server"
    systemctl start mongod.service
    sleep 2
  fi
  # Start DynamoDB
  cd $DYNAMODB_HOME
  if ! [[ $(pgrep -f DynamoDB) ]]
  then
    echo "Start DynamoDB Server"
    java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb &
    sleep 3
  fi
  # Start Postgrest
  if pgrep -x "postgrest" > /dev/null
  then
      pkill -9 postgrest
      sleep 2
  fi
  cd $POSTGREST_BINARY_HOME
  rm -f postgrest.conf || true
  echo 'db-uri = "postgres://postgres:postgres@localhost:5432/postgres"' >> postgrest.conf
  echo 'db-schema = "public"' >> postgrest.conf
  echo 'db-anon-role = "postgres"' >> postgrest.conf
  ./postgrest postgrest.conf &

fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH
rm /tmp/test_setcluster/*
mkdir -p /tmp/test_setcluster
cp ./tbl_file.csv /tmp/test_setcluster/
# SET PASSWORD = PASSWORD('Mysql_1234')
mysql -uroot -pMysql_1234 < ./init_mysql.sql

# postgres should be already started
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "create user postgres with encrypted password 'postgres';"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "grant all privileges on database postgres to postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$PG1_DIR/bin/psql -p $PG1_PORT postgres -c "ALTER USER postgres WITH SUPERUSER;"
$PG1_DIR/bin/psql postgres -p $PG1_PORT  -U postgres -d postgres < ./init_postgrest.sql

# Setup For DyanmoDB
aws dynamodb delete-table --table-name tbl_dynamodb --endpoint-url $DYNAMODB_ENDPOINT
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT \
        create-table --table-name tbl_dynamodb \
        --attribute-definitions AttributeName=c1,AttributeType=S AttributeName=c2,AttributeType=N \
        --key-schema AttributeName=c1,KeyType=HASH AttributeName=c2,KeyType=RANGE \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"Dynamodb"}, "c2":{"N":"-2091322"}, "c3":{"N":"-2563.21514"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"Caichao"}, "c2":{"N":"25452"}, "c3":{"N":"332.8"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"simple"}, "c2":{"N":"989839"}, "c3":{"N":"54562563.21514"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"nothing"}, "c2":{"N":"-9892"}, "c3":{"N":"8657.2"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"0YJ_gG7l000"}, "c2":{"N":"1222"}, "c3":{"N":"-2563.21514"}}'

# Setup For MongoDB
# use setup_cluster
# db.createUser({user:"edb",pwd:"edb",roles:[{role:"dbOwner", db:"setup_cluster"},{role:"readWrite", db:"setup_cluster"}]})
mongo --host=$MONGO_HOST --port=$MONGO_PORT -u $MONGO_USER_NAME -p $MONGO_PWD --authenticationDatabase "setup_cluster" < init_mongo.js > /dev/null

# Setup For Parquet Local
mkdir -p /tmp/data_local/setupcluster || true
cp tbl_parquetlocal.parquet /tmp/data_local/setupcluster
