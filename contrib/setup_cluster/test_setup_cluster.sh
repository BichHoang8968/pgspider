#!/bin/sh

# set global variables
POSTGRES_HOME=/home/jenkins/postgresql-15.0/install
PGSPIDER_HOME=/home/jenkins/PGSpider/install
GRIDDB_HOME=/home/jenkins/griddb-5.0/griddb-5.0.0
GRIDDB_CLIENT=/home/jenkins/griddb-5.0/griddb
TINYBRACE_HOME=/usr/local/tinybrace
POSTGREST_BINARY_HOME=/home/jenkins/binary_Postgrest
DYNAMODB_HOME=/home/jenkins/DynamoDB
GITLAB_HOME=/home/jenkins/pgspiderci/Server/Gitlab
REDMINE_HOME=/home/jenkins/pgspiderci/Server/Redmine

MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_USER_NAME="edb"
MONGO_PWD="edb"
AWS_ACCESS_KEY_ID='admin'
AWS_SECRET_ACCESS_KEY='testadmin'
AWS_REGION='us-east-1'
DYNAMODB_ENDPOINT="http://localhost:8000"
MINIO_CONTAINER='minio_server'
SLD_HOST="127.0.0.1"
SLD_PORT=12345
SLD_USER="user_sc"
SLD_PASSWORD="testuser_sc"
SLD_DB_NAME="test_sc.db"
# Path to directory contain client lib, shellcs and server binary
# $HOME/SQlumDash
#          +-- sqlumdash
#          |
#          +-- SQLumDash
#          |     +-- build: contain sqlite/sqlumdashcs lib
#          +-- SQLumDashCS
#                 +-- sqlumdash
#                 |       +-- bin: contain server binary
#                 |       +-- lib: contain lib-client
#                 +-- SQLumDashShell: contain shellcs
SQLUMDASH_PATH=$HOME/SQLumDash
SQLUMDASH_LIB_PATH=$SQLUMDASH_PATH/SQLumDash/.libs
SLDCS_PATH=$SQLUMDASH_PATH/SQLumDashCS
SLDCS_BIN_PATH=$SLDCS_PATH/sqlumdash/bin
SLDCS_LIB_PATH=$SLDCS_PATH/sqlumdash/lib
SLDCS_CLIENT_SHELL_PATH=$SLDCS_PATH/SQLumDashShell
SQL_LIB_PATH=$SQLUMDASH_PATH/SQLumDash/psmalloc

# Please replace each "/" to "\\\/" for JDBC_LIB_PATH
# Ex: /home/lib -> \\\/home\\\/lib
JDBC_LIB_PATH=\\\/home\\\/jenkins\\\/JDBC\\\/jdbc_lib

PGS_PORT=4813
LD_LIBRARY_PATH=":$PGSPIDER_HOME/lib:/usr/lib64/mysql:$GRIDDB_CLIENT/bin:/usr/local/tinybrace/lib:/usr/local/lib:/opt/oracle/product/21c/dbhomeXE/lib:/usr/local/lib64:"

SETUPCLUSTER_FOLDER=$(pwd)
INIT_DATA_PATH=$SETUPCLUSTER_FOLDER/test/init_data 
TEST_INPUT_PATH=$SETUPCLUSTER_FOLDER/test/test_input
TEST_OUTPUT_PATH=$SETUPCLUSTER_FOLDER/test/test_output

# export
export PGS1_PORT="${PGS_PORT}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export POSTGRES_HOME="${POSTGRES_HOME}"
export PGSPIDER_HOME="${PGSPIDER_HOME}"
export GRIDDB_HOME="${GRIDDB_HOME}"
export GRIDDB_CLIENT="${GRIDDB_CLIENT}"
export TINYBRACE_HOME="${TINYBRACE_HOME}"
export POSTGREST_BINARY_HOME="${POSTGREST_BINARY_HOME}"
export DYNAMODB_HOME="${DYNAMODB_HOME}"
export REDMINE_HOME="${REDMINE_HOME}"
export GITLAB_HOME="${GITLAB_HOME}"

export INIT_DATA_PATH="${INIT_DATA_PATH}" 
export TEST_INPUT_PATH="${TEST_INPUT_PATH}" 
export TEST_OUTPUT_PATH="${TEST_OUTPUT_PATH}" 

export PGS1_DIR="${PGSPIDER_HOME}"
export PGS2_DIR="${PGSPIDER_HOME}"
export PGS3_DIR="${PGSPIDER_HOME}"
export PGS4_DIR="${PGSPIDER_HOME}"
export PGS5_DIR="${PGSPIDER_HOME}"
export PG1_DIR="${POSTGRES_HOME}"
export PG2_DIR="${POSTGRES_HOME}"
export PG3_DIR="${POSTGRES_HOME}"
export PG4_DIR="${POSTGRES_HOME}"
export PG5_DIR="${POSTGRES_HOME}"
export PG6_DIR="${POSTGRES_HOME}"
export PG7_DIR="${POSTGRES_HOME}"

export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SHLIB=$ORACLE_HOME/lib
export ORACLE_SID=XE
export ORAENV_ASK=NO

export MONGO_HOST="${MONGO_HOST}"
export MONGO_PORT="${MONGO_PORT}"
export MONGO_USER_NAME="${MONGO_USER_NAME}"
export MONGO_PWD="${MONGO_PWD}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_REGION="${AWS_REGION}"

export DYNAMODB_ENDPOINT="${DYNAMODB_ENDPOINT}"

export MINIO_CONTAINER="${MINIO_CONTAINER}"

export SLD_HOST="${SLD_HOST}"
export SLD_PORT="${SLD_PORT}"
export SLD_USER="${SLD_USER}"
export SLD_PASSWORD="${SLD_PASSWORD}"
export SLD_DB_NAME="${SLD_DB_NAME}"

export SQLUMDASH_PATH="${SQLUMDASH_PATH}"
export SQLUMDASH_LIB_PATH="${SQLUMDASH_LIB_PATH}"
export SLDCS_PATH="${SLDCS_PATH}"
export SLDCS_BIN_PATH="${SLDCS_BIN_PATH}"
export SLDCS_LIB_PATH="${SLDCS_LIB_PATH}"
export SLDCS_CLIENT_SHELL_PATH="${SLDCS_CLIENT_SHELL_PATH}"
export SQL_LIB_PATH="${SQL_LIB_PATH}"

# Path to directory contain jdbc lib
# $JDBC_LIB_PATH
#          +-- mysql-connector-java-8.0.29.jar
#          |
#          +-- postgresql-42.3.5.jar
#          |
#          +-- gridstore-jdbc-5.0.0.jar
export JDBC_LIB_PATH="${JDBC_LIB_PATH}"


# build setup_cluster
cd $SETUPCLUSTER_FOLDER
make clean && make > /dev/null 2>&1


# scan test suite into TC_list
cd $TEST_INPUT_PATH

list_TC=$(find . -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g' | sort -V)
# echo $list_TC


# Run each testcase by for loop
echo ">>>>>>> TEST SUITE <<<<<<<<"
cd $SETUPCLUSTER_FOLDER
rm -rf results || true
mkdir results || true

for i in ${list_TC[@]}
do
    # Ignore this case, pgspider_core_fdw cannot handle mixing of schemaless and non-schemaless tables
    if [ ${i} == "TC107" ]; then
        continue
    fi

    if [ ${i} == "." ]; then
        continue
    fi

    #clear node_*.json
    cd $SETUPCLUSTER_FOLDER
    rm -rf node_*

    setup_cluster="NULL"
    results_get_data="NULL"

    echo "TESTCASE: ${i}"
    TC_PATH=$TEST_INPUT_PATH/$i
    mkdir -p results/$i || true

    cd $TC_PATH
    chmod a+x *.sh
    # start server and prepare data for child node
    ./init_test.sh --start > /dev/null 2>&1

    cp node_* $SETUPCLUSTER_FOLDER

    # setup cluster for parent node
    # ./setup_cluster
    #todo: setup_cluster need special config for some testcases. We need call ./setup_cluster by another scripts.
    cd $SETUPCLUSTER_FOLDER
    $TC_PATH/setup_cluster.sh $LD_LIBRARY_PATH >> results/$i/logs.out 2>&1

    # Check expected setup_cluster
    cmp -s results/$i/logs.out $TEST_OUTPUT_PATH/$i/logs.out
    if [ $? == 0 ]; then
        setup_cluster="OK"
    else
        setup_cluster="FAIL"
    fi

    # Get data in parent node
    echo "select * from tbl_postgre order by c2, __spd_url;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_postgre order by c2, __spd_url;" >> results/$i/results.out 2>&1
    echo "select * from tmp_test_setcluster order by c2, __spd_url;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tmp_test_setcluster order by c2, __spd_url;" >> results/$i/results.out 2>&1

    # tmp_test_setcluster2 is only created in TC79
    if [[ ${i} == "TC79" ]]; then
        echo "select * from tmp_test_setcluster2;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tmp_test_setcluster2;" >> results/$i/results.out 2>&1
    fi

    echo "select * from tbl_grid;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_grid;" >> results/$i/results.out 2>&1

    # influxdb uses UTC timezone by default, need to set the same timezoe on PGSpider to display the same result.
    echo "select * from tbl_influx;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "SET TIMEZONE to 'UTC'; select * from tbl_influx;" >> results/$i/results.out 2>&1

    # show table of some test cases for influx v2
    if [ ${i} == "TC98" ] || [ ${i} == "TC99" ] || [ ${i} == "TC100" ] || [ ${i} == "TC101" ]; then
        echo "select * from tbl_influx_2;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "SET TIMEZONE to 'UTC'; select * from tbl_influx_2;" >> results/$i/results.out 2>&1
    fi

    echo "select * from tbl_mysql;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_mysql;" >> results/$i/results.out 2>&1
    echo "select * from tbl_sqlite;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_sqlite;" >> results/$i/results.out 2>&1
    echo "select * from tbl_tiny;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_tiny;" >> results/$i/results.out 2>&1

    echo "select * from tbl_parquetminio;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_parquetminio;" >> results/$i/results.out 2>&1
    echo "select * from tbl_parquetlocal;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_parquetlocal;" >> results/$i/results.out 2>&1
    echo "select * from tbl_oracle;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_oracle;" >> results/$i/results.out 2>&1
    echo "select * from tbl_sqlumdash;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_sqlumdash;" >> results/$i/results.out 2>&1
    echo "select * from tbl_odbcmysql;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_odbcmysql;" >> results/$i/results.out 2>&1
    echo "select * from tbl_odbcpostgres;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_odbcpostgres;" >> results/$i/results.out 2>&1
    echo "select * from tbl_dynamodb;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_dynamodb;" >> results/$i/results.out 2>&1
    echo "select * from tbl_mongo;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_mongo;" >> results/$i/results.out 2>&1
    echo "select * from tbl_jdbcmysql;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_jdbcmysql;" >> results/$i/results.out 2>&1
    echo "select * from tbl_jdbcpostgres;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_jdbcpostgres;" >> results/$i/results.out 2>&1
    echo "select * from tbl_jdbcgrid;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_jdbcgrid;" >> results/$i/results.out 2>&1
    echo "select * from tbl_postgrest;" >> results/$i/results.out
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_postgrest;" >> results/$i/results.out 2>&1

    # test for redmine fdw
    if [ ${i} == "TC102" ]; then
        echo "select * from issues order by id, parent_id;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "SET TIMEZONE to 'UTC'; select * from issues order by id, parent_id;" >> results/$i/results.out 2>&1
    fi

    # test for gitlab fdw
    if [ ${i} == "TC103" ] || [ ${i} == "TC104" ]; then
        echo "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out 2>&1
    fi

    # test for objstorage_fdw

    # non-schemaless
    if [ ${i} == "TC105" ]; then
        echo "select * from test_table1 order by 3, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table1 order by 3, __spd_url;" >> results/$i/results.out 2>&1
    fi

    # schemaless
    if [ ${i} == "TC106" ]; then
        echo "select * from test_table1 order by v->>'One', __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table1 order by v->>'One', __spd_url;" >> results/$i/results.out 2>&1
    fi

    # mix of non-schemaless and schemaless - failed
    if [ ${i} == "TC107" ]; then
        echo "select * from test_table1;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table1;" >> results/$i/results.out 2>&1
    fi

    # mix of data format
    if [ ${i} == "TC108" ]; then
        echo "select * from test_table1 order by v->>'One', __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table1 order by v->>'One', __spd_url;" >> results/$i/results.out 2>&1
    fi

    # directory
    if [ ${i} == "TC109" ]; then
        echo "select * from test_table2 order by v, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table2 order by v, __spd_url;" >> results/$i/results.out 2>&1
    fi

    # mixed nodes
    if [ ${i} == "TC110" ]; then
        # objstorage
        echo "select * from test_table2 order by v, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from test_table2 order by v, __spd_url;" >> results/$i/results.out 2>&1
        # gitlab
        echo "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out 2>&1
        # redmine
        echo "select * from issues order by id, parent_id;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from issues order by id, parent_id;" >> results/$i/results.out 2>&1
    fi

    # test for redmine fdw, failed case
    if [ ${i} == "TC111" ]; then
        echo "select * from issues order by id, parent_id;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from issues order by id, parent_id;" >> results/$i/results.out 2>&1
    fi

    # test for gitlab fdw, failed case
    if [ ${i} == "TC112" ]; then
        echo "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from branches order by name, web_url, __spd_url;" >> results/$i/results.out 2>&1
    fi

    # test for redmine fdw, failed case. Allow user to input backslash or single quote character in option value.
    if [ ${i} == "TC113" ]; then
        echo "select * from issues order by id, parent_id;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from issues order by id, parent_id;" >> results/$i/results.out 2>&1
    fi

    # test for redmine_fdw, the endpoint name has hyphen character.
    if [ ${i} == "TC114" ]; then
        echo "select * from issues order by id, parent_id;" >> results/$i/results.out
        $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from issues order by id, parent_id;" >> results/$i/results.out 2>&1
    fi

    # Check data in parent node
    cmp -s results/$i/results.out $TEST_OUTPUT_PATH/$i/results.out
    if [ $? == 0 ]; then
        results_get_data="OK"
    else
        results_get_data="FAIL"
    fi

    # clean
    cd $TC_PATH
    ./stop_test.sh --stop > /dev/null 2>&1

    echo "SETUP_CLUSTER: ${setup_cluster} --------- GET_DATA: ${results_get_data}"
    cd $SETUPCLUSTER_FOLDER
done

