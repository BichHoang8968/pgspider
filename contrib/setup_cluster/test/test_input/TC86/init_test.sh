PGS1_DB=setcluster2_db1
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

  # Start DynamoDB
  cd $DYNAMODB_HOME
  if ! [[ $(pgrep -f DynamoDB) ]]
  then
    echo "Start DynamoDB Server"
    java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb &
    sleep 3
  fi
fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH
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
