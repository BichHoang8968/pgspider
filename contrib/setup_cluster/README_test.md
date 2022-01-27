# Precondition
- Install all necessary DB servers as : MySQL, PostgreSQL, InfluxDB, SQLite, GridDB.
- Build setup_cluster successfully.
- Build PGSpider/Postgres successfully. 

# Test folder structure
Code test for setup_cluster tool is written in path PGSpider/contrib/setup_cluster/test. This test include parts as following:

1. init_data: initialize data for model test.

2. test_input: include sub folder corresponding with each test case: start/stop server, initialize data for each test case and run test.
    - TC01
    - TC02
    - ...

3. test_output: include expectation for each test case

# How to run test
1. In test folder, update correctly path name in file test_setup_cluster.sh, following is path names need to correct:

    - POSTGRES_HOME
    - PGSPIDER_HOME
    - GRIDDB_HOME
    - GRIDDB_CLIENT
    - TINYBRACE_HOME

2. Run test by command

    ./test_setup_cluster.sh

# How to confirm test result
## What test program checking
Test result includes 2 types of information as example:

`SETUP_CLUSTER: OK/NG --------- GET_DATA: OK/NG`

1. SETUP_CLUSTER checkpoint: verify log after run setup_cluster, setup_cluster result match expected or not.
2. GET_DATA checkpoint: verify data on foreign table of parent PGSpider node.