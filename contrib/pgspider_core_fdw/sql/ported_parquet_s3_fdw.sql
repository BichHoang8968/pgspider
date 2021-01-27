-- create pgspider_svr
DELETE FROM pg_spd_node_info;
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1',port '50849');
CREATE USER mapping for public server pgspider_svr OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE test1 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8,
    __spd_url text) 
SERVER pgspider_svr;

-- create parquet_s3_fdw extension
SET datestyle = 'ISO';
SET client_min_messages = WARNING;
SET log_statement TO 'none';
CREATE EXTENSION parquet_s3_fdw;
CREATE SERVER parquet_s3_svr FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'true');
CREATE USER MAPPING FOR public SERVER parquet_s3_svr OPTIONS (user 'minioadmin', password 'minioadmin');

-- create multi-tenant
CREATE FOREIGN TABLE test1__parquet_s3_svr__0 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_1.parquet', sorted 'one');

SELECT * FROM test1 ORDER BY one;

CREATE FOREIGN TABLE test1__parquet_s3_svr__1 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_2.parquet', sorted 'one');

SELECT * FROM test1 ORDER BY one;

CREATE FOREIGN TABLE test1__parquet_s3_svr__2 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_3.parquet', sorted 'one');

SELECT * FROM test1 ORDER BY one;
SELECT * FROM test1 IN ('/parquet_s3_svr/') ORDER BY one,seven,__spd_url;

-- no explicit columns mentions
SELECT 1 as x FROM test1;
SELECT count(*) as count FROM test1;

-- sorting
EXPLAIN (COSTS OFF) SELECT * FROM test1 ORDER BY one;
EXPLAIN (COSTS OFF) SELECT * FROM test1 ORDER BY three;

-- filtering
SET client_min_messages = DEBUG1;
SELECT * FROM test1 WHERE one < 1 ORDER BY one;
SELECT * FROM test1 WHERE one <= 1 ORDER BY one;
SELECT * FROM test1 WHERE one > 6 ORDER BY one;
SELECT * FROM test1 WHERE one >= 6 ORDER BY one;
SELECT * FROM test1 WHERE one = 2 ORDER BY one;
SELECT * FROM test1 WHERE one = 7 ORDER BY one;
SELECT * FROM test1 WHERE six = true ORDER BY one;
SELECT * FROM test1 WHERE six = false ORDER BY one;
SELECT * FROM test1 WHERE seven < 0.9 ORDER BY one;
SELECT * FROM test1 WHERE seven IS NULL ORDER BY one;

-- prepared statements
prepare prep(date) as select * from test1 where five < $1;
execute prep('2018-01-03');
execute prep('2018-01-01');

-- invalid options
SET client_min_messages = WARNING;
CREATE FOREIGN TABLE test1__parquet_s3_svr__3 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr;
CREATE FOREIGN TABLE test1__parquet_s3_svr__3 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 'nonexistent.parquet', some_option '123');
CREATE FOREIGN TABLE test1__parquet_s3_svr__3 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_2.parquet', some_option '123');

-- type mismatch
CREATE FOREIGN TABLE test1__parquet_s3_svr__4 (one INT8[], two INT8, three TEXT)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_2.parquet', sorted 'one');
SELECT one FROM test1__parquet_s3_svr__4;
SELECT two FROM test1__parquet_s3_svr__4;

-- sequential multifile reader
CREATE FOREIGN TABLE test2 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8,
    __spd_url text) 
SERVER pgspider_svr;

CREATE FOREIGN TABLE test2__parquet_s3_svr__0 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_3.parquet s3://parquets3/ported_2.parquet s3://parquets3/ported_1.parquet', sorted 'one');
EXPLAIN SELECT * FROM test2;
SELECT * FROM test2;

-- multifile merge reader
CREATE FOREIGN TABLE test3 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8,
    __spd_url text) 
SERVER pgspider_svr;

CREATE FOREIGN TABLE test3__parquet_s3_svr__0 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_3.parquet s3://parquets3/ported_2.parquet s3://parquets3/ported_1.parquet', sorted 'one');
EXPLAIN (COSTS OFF) SELECT * FROM test3 ORDER BY one;
SELECT * FROM test3 ORDER BY one;

---- parallel execution
--SET parallel_setup_cost = 0;
--SET parallel_tuple_cost = 0.001;
--SET cpu_operator_cost = 0.000025;
--ANALYZE test2;
--ANALYZE test3;
--EXPLAIN (COSTS OFF) SELECT * FROM test2;
--EXPLAIN (COSTS OFF) SELECT * FROM test2 ORDER BY one;
--EXPLAIN (COSTS OFF) SELECT * FROM test2 ORDER BY two;
--EXPLAIN (COSTS OFF) SELECT * FROM test3;
--EXPLAIN (COSTS OFF) SELECT * FROM test3 ORDER BY one;
--EXPLAIN (COSTS OFF) SELECT * FROM test3 ORDER BY two;

-- multiple sorting keys
CREATE FOREIGN TABLE test4 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8,
    __spd_url text) 
SERVER pgspider_svr;

CREATE FOREIGN TABLE test4__parquet_s3_svr__0 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_1.parquet', sorted 'one five');

CREATE FOREIGN TABLE test4__parquet_s3_svr__1 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_2.parquet', sorted 'one five');

CREATE FOREIGN TABLE test4__parquet_s3_svr__2 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8)
SERVER parquet_s3_svr
OPTIONS (filename 's3://parquets3/ported_3.parquet', sorted 'one five');

EXPLAIN (COSTS OFF) SELECT * FROM test4 ORDER BY one, five;
SELECT * FROM test4 ORDER BY one, five;

DROP EXTENSION parquet_s3_fdw CASCADE;

DROP FOREIGN TABLE test1;
DROP FOREIGN TABLE test2;
DROP FOREIGN TABLE test3;
DROP FOREIGN TABLE test4;
DROP SERVER pgspider_svr CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;