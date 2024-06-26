source $(pwd)/../environment_variable.config

export MONGO_HOST="localhost"
export MONGO_PORT="27017"
export MONGO_USER_NAME="edb"
export MONGO_PWD="edb"

export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export PATH=$ORACLE_HOME/bin:$PATH
export ORAENV_ASK=NO
export ORACLE_SHLIB=$ORACLE_HOME/lib
export ORACLE_SID=XE
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

MONGO_DB_NAME="mongo_pg_modify"
MONGO_DB_NAME2="mongo_pg_modify2"
DYNAMODB_HOME=$DYNAMODB_HOME
DYNAMODB_ENDPOINT1="http://localhost:8001"
DYNAMODB_ENDPOINT2="http://localhost:8002"
DYNAMODB_PORT1=8001
DYNAMODB_PORT2=8002
GRIDDB_CLIENT=$GRIDDB_CLIENT
#Init data used in Postgres: tbl1, tbl2, tbl3, tbl4, tbl5
POSTGRES_DB_NAME=pg_modify_db
MYSQL_DB_NAME1=pg_modify_db1
MYSQL_DB_NAME2=pg_modify_db2
JDBC_POSTGRES_DB_NAME=jdbc_modify_db
ODBC_POSTGRES_DB_NAME=odbc_pg_modify
JDBC_MYSQL_DB_NAME=jdbc_modify_db
ODBC_MYSQL_DB_NAME=odbc_pg_modify

function clean_docker_img()
{
  if [ "$(docker ps -aq -f name=^/${1}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${1}$)" ]; then
        docker rm ${1}
    else
        docker rm $(docker stop ${1})
    fi
  fi
}

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
    sleep 5
    ./createdb -p 15432 $POSTGRES_DB_NAME
    ./createdb -p 15432 $ODBC_POSTGRES_DB_NAME
    ./createdb -p 15432 $JDBC_POSTGRES_DB_NAME
  fi
  if ! ./pg_isready -p 15432
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../test_pgspider_modify start
    sleep 10
  fi
  #Postgres with port 15433 as offline, so do not start it
  # Start PostgreSQL 2
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../test_pgspider_modify_2" ];
  then
    ./initdb ../test_pgspider_modify_2
    sed -i 's/#port = 5432.*/port = 15434/' ../test_pgspider_modify_2/postgresql.conf
    ./pg_ctl -D ../test_pgspider_modify_2 start
    sleep 10
    ./createdb -p 15434 $POSTGRES_DB_NAME
  fi
  if ! ./pg_isready -p 15434
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../test_pgspider_modify_2 start
    sleep 10
  fi

# Start GridDB server docker
griddb_image=$GRIDDB_IMAGE
griddb_container_name=griddb_svr
clean_docker_img ${griddb_container_name}
docker run -d --name ${griddb_container_name} -p 10001:10001 -e GRIDDB_NODE_NUM=1 ${griddb_image}

  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 10
  fi
  # Start Oracle server
  if [[ $(systemctl status oracle-xe-21c.service) == *"active (exited)"* ]]
  then
    echo "Start Oracle Server"
    systemctl start oracle-xe-21c.service
    sleep 10
  fi
  # Start MongoDB
  if ! [[ $(systemctl status mongod.service) == *"active (running)"* ]]
  then
    echo "Start MongoDB Server"
    systemctl start mongod.service
    sleep 10
  fi

  # Stop DynamoDB
  cd $DYNAMODB_HOME
  if [[ $(pgrep -f DynamoDB) ]]
  then
    echo "Stop DynamoDB Server"
    pkill -9 -f 'java -jar DynamoDBLocal.jar'
    sleep 3
  fi

  # Start DynamoDB
  echo "Start DynamoDB Server"
  java -jar DynamoDBLocal.jar -sharedDb -port $DYNAMODB_PORT1 &
  sleep 3
  java -jar DynamoDBLocal.jar -port $DYNAMODB_PORT2 &
  sleep 3

  # Stop TinyBrace Server
  if pgrep -x "tbserver" > /dev/null
  then
    echo "Stop TinyBrace Server"
    pkill -9 tbserver
    sleep 10
  fi

  cd $CURR_PATH
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/pgmodifytest.db < pg_modify_tiny.dat
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/pgmodifytest1.db < pg_modify_tiny1.dat
  # Start TinyBrace Server
  echo "Start TinyBrace Server"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3
else
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=pgmodifytest.db < pg_modify_tiny.dat
fi

cd $CURR_PATH
# Setup SQLite
rm /tmp/pgmodifytest.db
sqlite3 /tmp/pgmodifytest.db < pg_modify_sqlite.dat
rm /tmp/pgmodifytest1.db
sqlite3 /tmp/pgmodifytest1.db < pg_modify_sqlite.dat

#Setup File_fdw
rm /tmp/pg_modify_file1.csv
rm /tmp/pg_modify_file2.csv
rm /tmp/pg_modify_bulk_insert.csv
cp pg_modify_file1.csv /tmp/
cp pg_modify_file2.csv /tmp/
cp pg_modify_bulk_insert.csv /tmp/

# Setup oracle
sqlplus / as sysdba << EOF
@oracle_pgmodify.sql
EOF

#Setup griddb
cp -a $GRIDDB_CLIENT .
export LD_LIBRARY_PATH=./griddb/bin
make clean && make
result="$?"
if [[ "$result" -eq 0 ]]; then
  ./griddb_init notification_member=127.0.0.1:10001  cluster=dockerGridDB user=admin passwd=admin
fi

# Setup mysql
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $MYSQL_DB_NAME1;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $MYSQL_DB_NAME1;"
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $MYSQL_DB_NAME2;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $MYSQL_DB_NAME2;"
mysql -u root -pMysql_1234 -D $MYSQL_DB_NAME1 < ./pg_modify_mysql1.dat
mysql -u root -pMysql_1234 -D $MYSQL_DB_NAME2 < ./pg_modify_mysql2.dat
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $JDBC_MYSQL_DB_NAME;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $JDBC_MYSQL_DB_NAME;"
mysql -u root -pMysql_1234 -D $JDBC_MYSQL_DB_NAME < ./pg_modify_jdbc_mysql.dat
mysql -u root -pMysql_1234 -e "DROP DATABASE IF EXISTS $ODBC_MYSQL_DB_NAME;"
mysql -u root -pMysql_1234 -e "CREATE DATABASE $ODBC_MYSQL_DB_NAME;"
mysql -u root -pMysql_1234 -D $ODBC_MYSQL_DB_NAME -e "CREATE TABLE tntbl3 (_id text, c1 int, c2 float, c3 double precision, c4 bigint);"

# Setup MongoDB
mongo << EOF
use mongo_pg_modify
db.dropUser("edb")
db.createUser({user:"edb",pwd:"edb",roles:[{role:"dbOwner", db:"mongo_pg_modify"},{role:"readWrite", db:"mongo_pg_modify"}]})
use mongo_pg_modify2
db.createUser({user:"edb",pwd:"edb",roles:[{role:"dbOwner", db:"mongo_pg_modify2"},{role:"readWrite", db:"mongo_pg_modify2"}]})
EOF
mongo --host=$MONGO_HOST --port=$MONGO_PORT -u $MONGO_USER_NAME -p $MONGO_PWD --authenticationDatabase $MONGO_DB_NAME < mongo_pg_modify.js > /dev/null
mongo --host=$MONGO_HOST --port=$MONGO_PORT -u $MONGO_USER_NAME -p $MONGO_PWD --authenticationDatabase $MONGO_DB_NAME2 < mongo_pg_modify2.js

# Setup Postgres
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "grant all privileges on database $POSTGRES_DB_NAME to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"

$POSTGRES_HOME/bin/psql -p 15432 $JDBC_POSTGRES_DB_NAME -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 $JDBC_POSTGRES_DB_NAME -c "grant all privileges on database $JDBC_POSTGRES_DB_NAME to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $JDBC_POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $JDBC_POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"

$POSTGRES_HOME/bin/psql -p 15432 $ODBC_POSTGRES_DB_NAME -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 $ODBC_POSTGRES_DB_NAME -c "grant all privileges on database $ODBC_POSTGRES_DB_NAME to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $ODBC_POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 $ODBC_POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"

$POSTGRES_HOME/bin/psql -p 15434 $POSTGRES_DB_NAME -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15434 $POSTGRES_DB_NAME -c "grant all privileges on database $POSTGRES_DB_NAME to postgres;"
$POSTGRES_HOME/bin/psql -p 15434 $POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15434 $POSTGRES_DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"

$POSTGRES_HOME/bin/psql $POSTGRES_DB_NAME -p 15432 -U postgres < ./pg_modify_1.dat
$POSTGRES_HOME/bin/psql $POSTGRES_DB_NAME -p 15434 -U postgres < ./pg_modify_2.dat
$POSTGRES_HOME/bin/psql $ODBC_POSTGRES_DB_NAME -p 15432 -U postgres < ./pg_modify_odbc_post.dat

$POSTGRES_HOME/bin/psql $JDBC_POSTGRES_DB_NAME -p 15432 -U postgres < ./pg_modify_jdbc_post.dat

#Setup Dynamodb
# Below commands must be run in DynamoDB to create databases used in regression tests with `admin` user and `testadmin` password.
# aws configure
# -- AWS Access Key ID : edb
# -- AWS Secret Access Key : edb
# -- Default region name [None]: us-west-2

# Clean data
aws dynamodb delete-table --table-name tntbl1 --endpoint-url $DYNAMODB_ENDPOINT1 > /dev/null 2>&1
aws dynamodb delete-table --table-name tntbl1 --endpoint-url $DYNAMODB_ENDPOINT2 > /dev/null 2>&1
aws dynamodb delete-table --table-name tntbl2 --endpoint-url $DYNAMODB_ENDPOINT1 > /dev/null 2>&1
aws dynamodb delete-table --table-name tntbl3 --endpoint-url $DYNAMODB_ENDPOINT1 > /dev/null 2>&1

# create table for test
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT1 create-table --table-name tntbl1 \
          --attribute-definitions AttributeName=c1,AttributeType=N --key-schema AttributeName=_id,KeyType=HASH \
          --key-schema AttributeName=c1,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 > /dev/null 2>&1

aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT2 create-table --table-name tntbl1 \
          --attribute-definitions AttributeName=c1,AttributeType=N --key-schema AttributeName=_id,KeyType=HASH \
          --key-schema AttributeName=c1,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 > /dev/null 2>&1

aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT1 create-table --table-name tntbl2 \
          --attribute-definitions AttributeName=_id,AttributeType=S --key-schema AttributeName=_id,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 > /dev/null 2>&1

aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT1 create-table --table-name tntbl3 \
          --attribute-definitions AttributeName=_id,AttributeType=S --key-schema AttributeName=_id,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 > /dev/null 2>&1
