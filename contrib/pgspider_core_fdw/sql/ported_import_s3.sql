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

-- import foreign schema
IMPORT FOREIGN SCHEMA "s3://ported"
FROM SERVER parquet_s3_svr
INTO public
OPTIONS (sorted 'one');
\d

SELECT * FROM ported_1;
SELECT * FROM ported_2;
SELECT * FROM ported_3;

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
SELECT * FROM test1 IN ('/parquet_s3_svr/') ORDER BY three,__spd_url;

-- import_parquet
create function list_parquet_s3_files(args jsonb)
returns text[] as
$$
    select array[args->>'dir' || '/ported_1.parquet', args->>'dir' || '/ported_3.parquet']::text[];
$$
language sql;

select import_parquet_s3('test1__parquet_s3_svr__3', 'public', 'parquet_s3_svr', 'list_parquet_s3_files', '{"dir": "s3://ported"}', '{"sorted": "one"}');
SELECT * FROM test1__parquet_s3_svr__3 ORDER BY one, three;
SELECT * FROM test1 ORDER BY one;

select import_parquet_s3_explicit('test1__parquet_s3_svr__4', 'public', 'parquet_s3_svr', array['one', 'three', 'six'], array['int8', 'text', 'bool']::regtype[], 'list_parquet_s3_files', '{"dir": "s3://ported"}', '{"sorted": "one"}');
SELECT * FROM test1__parquet_s3_svr__4;
SELECT * FROM test1 ORDER BY one;

CREATE FOREIGN TABLE parquets3tbl__parquet_s3_svr__0 (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8) 
SERVER parquet_s3_svr options(filename 's3://parquets3/ported_3.parquet', sorted 'one');
SELECT * FROM parquets3tbl__parquet_s3_svr__0;

CREATE FOREIGN TABLE parquets3tbl (
    one     INT8,
    two     INT8[],
    three   TEXT,
    four    TIMESTAMP,
    five    DATE,
    six     BOOL,
    seven   FLOAT8,
    __spd_url text) 
SERVER pgspider_svr;
SELECT * FROM parquets3tbl;

SELECT * FROM test1 IN ('/parquet_s3_svr/') where one < 1 ORDER BY one;; 

DROP FUNCTION list_parquet_s3_files;
DROP EXTENSION parquet_s3_fdw CASCADE;

DROP FOREIGN TABLE test1;
DROP SERVER pgspider_svr CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;