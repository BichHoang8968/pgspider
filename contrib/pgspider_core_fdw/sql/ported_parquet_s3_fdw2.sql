-- create pgspider_svr
DELETE FROM pg_spd_node_info;
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1',port '50849');
CREATE USER mapping for public server pgspider_svr OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE test1 (
    timestamp timestamp, 
    col1 text, 
    col2 bigint, 
    col3 double precision, 
    __spd_url text) 
SERVER pgspider_svr;

-- create parquet_s3_fdw extension
SET datestyle = 'ISO';
SET client_min_messages = WARNING;
SET log_statement TO 'none';
CREATE EXTENSION parquet_s3_fdw;
CREATE SERVER parquet_s3_svr FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'true');
CREATE USER MAPPING FOR public SERVER parquet_s3_svr OPTIONS (user 'minioadmin', password 'minioadmin');

-- **********************************************
-- Foreign table using 'filename' option
-- **********************************************
-- File under bucket
CREATE FOREIGN TABLE test1__parquet_s3_svr__0 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/file0.parquet');
SELECT * FROM test1__parquet_s3_svr__0;
SELECT * FROM test1;

-- File in directory
CREATE FOREIGN TABLE test1__parquet_s3_svr__1 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/file0.parquet');
SELECT * FROM test1__parquet_s3_svr__0;
SELECT * FROM test1;

-- File in sub directory
CREATE FOREIGN TABLE test1__parquet_s3_svr__2 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/dir1/dir11/file111.parquet');
SELECT * FROM test1__parquet_s3_svr__2;
SELECT * FROM test1;

-- Multiple files in the same directory
CREATE FOREIGN TABLE test1__parquet_s3_svr__3 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/dir2/file21.parquet s3://test-bucket/dir2/file22.parquet s3://test-bucket/dir2/file23.parquet');
SELECT * FROM test1__parquet_s3_svr__3;
SELECT * FROM test1;

-- Multiple files in some directories
CREATE FOREIGN TABLE test1__parquet_s3_svr__4 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/file0.parquet s3://test-bucket/dir1/dir12/file121.parquet');
SELECT * FROM test1__parquet_s3_svr__4;
SELECT * FROM test1;


-- **********************************************
-- Foreign table using 'dirname' option
-- **********************************************
-- Only bucket name
CREATE FOREIGN TABLE test1__parquet_s3_svr__5 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (dirname 's3://test-bucket');
SELECT * FROM test1__parquet_s3_svr__5;
SELECT * FROM test1;

-- Directory
CREATE FOREIGN TABLE test1__parquet_s3_svr__6 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (dirname 's3://test-bucket/dir1');
SELECT * FROM test1__parquet_s3_svr__6;
SELECT * FROM test1;

-- Sub directory
CREATE FOREIGN TABLE test1__parquet_s3_svr__7 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (dirname 's3://test-bucket/dir1/dir11');
SELECT * FROM test1__parquet_s3_svr__7;
SELECT * FROM test1;


-- **********************************************
-- Error cases
-- **********************************************
-- File does not exist
CREATE FOREIGN TABLE test1__parquet_s3_svr__8 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/dummy-file.parquet');
SELECT * FROM test1__parquet_s3_svr__8;

-- Bucket does not exist
CREATE FOREIGN TABLE test1__parquet_s3_svr__9 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (dirname 's3://dummy-bucket');
SELECT * FROM test1__parquet_s3_svr__8;

-- Directory does not exist
CREATE FOREIGN TABLE test1__parquet_s3_svr__10 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (dirname 's3://test-bucket/dummy-dir');
SELECT * FROM test1__parquet_s3_svr__8;

-- Use both options 'filename' and 'dirname'
CREATE FOREIGN TABLE test1__parquet_s3_svr__11 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/dir1/file1.parquet', dirname 's3://test-bucket/dir1');

-- Specify both local file and S3 file
CREATE FOREIGN TABLE test1__parquet_s3_svr__12 (timestamp timestamp, col1 text, col2 bigint, col3 double precision) SERVER parquet_s3_svr OPTIONS (filename 's3://test-bucket/dir1/file1.parquet /tmp/file2.parquet');


-- **********************************************
-- Cleanup
-- **********************************************
DROP EXTENSION parquet_s3_fdw CASCADE;

DROP FOREIGN TABLE test1;
DROP SERVER pgspider_svr CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;