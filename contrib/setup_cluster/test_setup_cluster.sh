#!/bin/sh

# set global variables
POSTGRES_HOME=/home/jenkins/postgresql-14beta2/install
PGSPIDER_HOME=/home/jenkins/PGSpider/install
GRIDDB_HOME=/home/jenkin/griddb-4.6.1
GRIDDB_CLIENT=/home/jenkin/griddb-4.6.0/griddb
TINYBRACE_HOME=/usr/local/tinybrace

PGS_PORT=4813
LD_LIBRARY_PATH=":$PGSPIDER_HOME/lib:/usr/lib64/mysql:$GRIDDB_CLIENT/bin:/usr/local/tinybrace/lib:/usr/local/lib:"

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


# build setup_cluster
cd $SETUPCLUSTER_FOLDER
make clean && make > /dev/null 2>&1


# scan test suite into TC_list
cd $TEST_INPUT_PATH

list_TC=$(find . -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g' | sort -n)
# echo $list_TC


# Run each testcase by for loop
echo ">>>>>>> TEST SUITE <<<<<<<<"
cd $SETUPCLUSTER_FOLDER
rm -rf results || true
mkdir results || true

for i in ${list_TC[@]}
do
    if [[ ${i} == "." ]]; then
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
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_postgre;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tmp_test_setcluster;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_grid;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_influx;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_mysql;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_sqlite;" >> results/$i/results.out 2>&1
    $PGSPIDER_HOME/bin/psql -d pgspider -p $PGS_PORT -c "select * from tbl_tiny;" >> results/$i/results.out 2>&1

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


