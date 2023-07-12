-- ===================================================================
-- create FDW objects
-- ===================================================================
SET DATESTYLE TO ISO;
--Testcase 1:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 2:
CREATE EXTENSION pgspider_fdw;
--Testcase 3:
CREATE EXTENSION postgres_fdw;
--Testcase 4:
CREATE EXTENSION mysql_fdw;
--Testcase 5:
CREATE EXTENSION oracle_fdw;
--Testcase 6:
CREATE EXTENSION griddb_fdw;
--Testcase 690:
CREATE EXTENSION influxdb_fdw;

--Testcase 7:
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
-- ===================================================================
-- OPTIONS TEST
-- ===================================================================
-- Proxy with valid value but not a valid proxy to connect
--Testcase 8:
CREATE SERVER cloud_test FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (endpoint 'http://localhost:8080', proxy 'squid.proxy', batch_size '1000');
--Testcase 9:
CREATE USER MAPPING FOR public SERVER cloud_test;
--Testcase 10:
CREATE SERVER postgres_svr_test FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'test1');
--Testcase 818:
CREATE SERVER influxdb_svr_test FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '38086', dbname 'test1', version '2', retention_policy '');
--Testcase 11:
CREATE USER MAPPING FOR public SERVER postgres_svr_test OPTIONS (user 'postgres', password 'postgres');
--Testcase 819:
CREATE USER MAPPING FOR public SERVER influxdb_svr_test OPTIONS (auth_token 'mytoken');

--Testcase 12:
CREATE TABLE test_options (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
);

--Testcase 13:
INSERT INTO test_options VALUES (1000, 'test_option1', B'10101010', E'\\xa7a8a9aaabacadaeaf', true, 'a', '2001-01-01', 10000, -107, 212.2, 100, 'varchar10', 'bpchar10', 1, '2001-01-01 00:00:00', '2001-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b'], ARRAY['a',''], ARRAY[1000,2000], ARRAY[100,200], ARRAY[1,2], ARRAY['textbl1','text2'], ARRAY[1.0,2.0], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_1'], ARRAY[10000,20000], ARRAY['2001-01-01'::date,'2001-01-02'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz]);
--Testcase 14:
INSERT INTO test_options VALUES (2000, 'test_option2', B'10101010', E'\\xa7a8a9aaabacadaeaf', false, 'b', '2021-11-21', 20000, -107, 212.2, 100, 'varchar10', 'bpchar10', 2, '2021-11-11 00:00:00', '2021-11-11 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b'], ARRAY['a',''], ARRAY[1000,2000], ARRAY[100,200], ARRAY[1,2], ARRAY['textbl2','text2'], ARRAY[1.0,2.0], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_2'], ARRAY[10000,20000], ARRAY['2001-01-01'::date,'2001-01-02'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz]);

-- Migrate fail, proxy not exist
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

ALTER SERVER cloud_test OPTIONS (DROP proxy);
-- Succeed migrate
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

--Testcase 15:
SELECT * FROM test_tbl ORDER BY c1;
--Testcase 16:
DROP DATASOURCE TABLE test_tbl;
--Testcase 17:
DROP FOREIGN TABLE test_tbl;

ALTER SERVER cloud_test OPTIONS (ADD proxy 'no');
-- Wrong relay, migrate fail
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloudtest');

-- Wrong endpoint, migrate fail
ALTER SERVER cloud_test OPTIONS (SET endpoint 'http://localhost:3000');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

ALTER SERVER cloud_test OPTIONS (SET endpoint 'http://localhost:8080');

-- Wrong socket_port, migrate fail
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '-1', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '65536', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Wrong function_timeout, migrate fail
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '-1') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Force use UserID, serverID; the value is duplicated inserted, migrate fail
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test', userID 'user_id');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test', serverID 'server_id');

-- Migrate repeat on same targets, migrate fail over due to datasource exist
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test'), postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate repeat on same targets, migrate succeed with different table name
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test1_tbl', relay 'cloud_test'), postgres_svr_test OPTIONS (table_name 'test2_tbl', relay 'cloud_test');
--Testcase 18:
SELECT * FROM test_tbl ORDER BY c1;
--Testcase 19:
SELECT * FROM test_tbl__postgres_svr_test__0;
--Testcase 20:
SELECT * FROM test_tbl__postgres_svr_test__1;

--Testcase 21:
DROP DATASOURCE TABLE test_tbl__postgres_svr_test__0;
--Testcase 22:
DROP DATASOURCE TABLE test_tbl__postgres_svr_test__1;
--Testcase 23:
DROP FOREIGN TABLE test_tbl__postgres_svr_test__0;
--Testcase 24:
DROP FOREIGN TABLE test_tbl__postgres_svr_test__1;
--Testcase 25:
DROP FOREIGN TABLE test_tbl;

--Testcase 26:
CREATE table test_bytea_array (c20 bytea[]);
--Testcase 27:
INSERT INTO test_bytea_array VALUES (ARRAY[E'\\1132165131651316153'::bytea, E'\\x151354865131651321'::bytea]);
-- Migrate fail, bytea array not support
MIGRATE TABLE test_bytea_array TO test_bytea OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_bytea', relay 'cloud_test');
--Testcase 28:
DROP TABLE test_bytea_array;

-- Wrong target server
ALTER SERVER postgres_svr_test OPTIONS (SET port '12345');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

ALTER SERVER postgres_svr_test OPTIONS (SET port '5432', SET dbname 'dbnotexist');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

ALTER SERVER postgres_svr_test OPTIONS (SET dbname 'test1', SET host 'invalid_host');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

ALTER SERVER postgres_svr_test OPTIONS (SET host '127.0.0.1');
ALTER USER MAPPING FOR public SERVER postgres_svr_test OPTIONS (SET user 'user', SET password 'pass');
MIGRATE TABLE test_options TO test_tbl OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

--Testcase 29:
DROP TABLE test_options;

--Testcase 820:
CREATE TABLE test_options (time timestamp with time zone, tag1 text, field1 integer, tag2 text, field2 integer);

--Testcase 821:
INSERT INTO test_options VALUES ('2004-10-19 10:23:54+02', 'tag1_1', 1, 'tag2_1', 2);
--Testcase 822:
INSERT INTO test_options VALUES ('2004-10-19 12:23:54+02', 'tag1_2', 3, 'tag2_2', 4);

--Testcase 827:
SELECT * FROM test_options ORDER BY time;

--Testcase 828:
-- Migrate influxdb fail, missing org option
MIGRATE TABLE test_options TO tbl_influxdb OPTIONS (socket_port '4814', function_timeout '800') SERVER influxdb_svr_test OPTIONS (table 'test_options', relay 'cloud_test', tags 'tag1, tag2');

-- Test tags option and time column, migrate succeed
--Testcase 823:
MIGRATE TABLE test_options TO tbl_influxdb OPTIONS (socket_port '4814', function_timeout '800') SERVER influxdb_svr_test OPTIONS (table 'test_options', relay 'cloud_test', org 'myorg', tags 'tag1, tag2');

--Testcase 824:
SELECT * FROM tbl_influxdb ORDER BY time;
--Testcase 825:
DROP DATASOURCE TABLE tbl_influxdb;

--Testcase 829:
CREATE TABLE test_time_text (time timestamp with time zone, time_text text, tag1 text, field1 integer, tag2 text, field2 integer);
--Testcase 830:
INSERT INTO test_time_text VALUES ('2021-03-03 00:00:01+07', '2021-02-03T00:00:03.123456789Z', 'tag1', 1, 'tag2', 2);
--Testcase 831:
INSERT INTO test_time_text VALUES ('2021-02-02 00:00:01+05', '2021-02-02T00:00:02.123456789Z', 'tag3', 3, 'tag4', 4);
--Testcase 832:
SELECT * FROM test_time_text ORDER by time;

-- Migrate influxdb succeed, Inserting value has both 'time_text' and 'time' columns specified. the 'time' will be ignored
--Testcase 833:
MIGRATE TABLE test_time_text TO tbl_time_text OPTIONS (socket_port '4814', function_timeout '800') SERVER influxdb_svr_test OPTIONS (table 'test_time_text', relay 'cloud_test', org 'myorg');
--Testcase 834:
SELECT * FROM tbl_time_text ORDER by time;
--Testcase 835:
DROP DATASOURCE TABLE tbl_time_text;

--Testcase 828:
DROP FOREIGN TABLE tbl_time_text;
--Testcase 826:
DROP FOREIGN TABLE tbl_influxdb;
--Testcase 827:
DROP TABLE test_options;
--Testcase 836:
DROP TABLE test_time_text;
--Testcase 30:
DROP SERVER postgres_svr_test CASCADE;
--Testcase 31:
DROP SERVER cloud_test CASCADE;
-- ===================================================================
-- DATA COMPRESSION TRANSFER TEST
-- ===================================================================

DO $d$
    BEGIN
        EXECUTE $$CREATE SERVER loopback FOREIGN DATA WRAPPER postgres_fdw
            OPTIONS (dbname '$$||current_database()||$$',
                     port '$$||current_setting('port')||$$'
            )$$;
    END;
$d$;

--Testcase 32:
CREATE USER MAPPING FOR CURRENT_USER SERVER loopback;

-- ===================================================================
-- CREATE RELAY SERVER TABLE
-- ===================================================================
--Testcase 33:
CREATE SERVER cloud1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (endpoint 'http://localhost:8080', proxy 'no', batch_size '10000');
--Testcase 34:
CREATE SERVER cloud2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (endpoint 'http://localhost:8080', proxy 'no', batch_size '5000');
--Testcase 35:
CREATE SERVER cloud3 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (endpoint 'http://localhost:8080', proxy 'no', batch_size '1000');

--Testcase 36:
CREATE USER MAPPING FOR public SERVER cloud1;
--Testcase 37:
CREATE USER MAPPING FOR public SERVER cloud2;
--Testcase 38:
CREATE USER MAPPING FOR public SERVER cloud3;

-- ===================================================================
-- TO POSTGRES SERVER
-- ===================================================================
--Testcase 39:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 40:
CREATE DATASOURCE TABLE ft1;

--Testcase 41:
INSERT INTO t1 VALUES (1000, 'textbl_postgres', B'10101010', E'\\xa7a8a9aaabacadaeaf', true, 'a', '2001-01-01', 10000, 1E-107, 1E-37, 100, 'varchar10', 'bpchar10', 1, '2001-01-01 00:00:00', '2001-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b'], ARRAY['a',''], ARRAY[1000,2000], ARRAY[100,200], ARRAY[1,2], ARRAY['textbl_postgres','text2'], ARRAY[1.0,2.0], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_postgres'], ARRAY[10000,20000], ARRAY['2001-01-01'::date,'2001-01-02'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz]);
--Testcase 42:
INSERT INTO t1 VALUES (2000, 'text2', B'10101010', E'\\x9416a61d32132b321c', true, 'b', '2002-01-01', 20000, 1E-107, 1E-37, 100, 'varchar10', 'bpchar10', 2, '2001-01-01 00:00:00', '2001-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b', 'c'], ARRAY['a','', null], ARRAY[1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','text3'], ARRAY[1.0,2.0,null], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_postgres','vartextbl_postgres'], ARRAY[10000,20000,30000], ARRAY['2001-01-01'::date,'2001-01-02'::date,'2001-01-03'::date,'2001-01-04'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time,'2001-01-03 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz,'2001-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz,'2004-10-21 10:00:00+02'::timestamptz]);
--Testcase 43:
INSERT INTO t1 VALUES (3000, 'text3', B'10101010', E'\\x151354865131651321', false, 'c', '2003-01-01', 30000, 21122.213, 100.0, 200, 'char array', 'bpchar[]', 3, '2002-01-01 00:00:00', '2002-01-01 00:00:01+00', '2005-10-19 10:23:54','2005-10-19 10:23:54+02', ARRAY[true, false, true, null], ARRAY['a', 'b', 'c', null], ARRAY['a','','x'], ARRAY[1000,null,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2',null], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2001-01-01'::date,'2001-01-02'::date,'2001-01-03'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time,'2001-01-03 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz,'2001-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,null,'2004-10-21 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz,'2004-10-21 10:00:00+02'::timestamptz]);
--Testcase 44:
INSERT INTO t1 VALUES (4000, 'text4', B'10101010', E'\\x9416a61d32132b321c', false, 'd', '2004-01-01', 40000, 6565.10, 200.0, 300, 'char array', 'bpchar 1', 4, '2003-01-01 00:00:00', '2003-01-01 00:00:01+00', '2003-10-19 10:23:54','2003-10-19 10:23:54+02', ARRAY[true, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,-2000,3000], ARRAY[100,-200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000,50000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 45:
INSERT INTO t1 VALUES (5000, 'text5', B'10101010', E'\\x941231b65d15f16515', true, 'e', '2005-01-01', 50000, 599.010, 300.0, 400, 'char array', 'bpchar 2', 5, '2003-01-01 00:00:00', '2003-01-01 00:00:01+00', '2003-10-19 10:23:54','2003-10-19 10:23:54+02', ARRAY[true, false, false, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr',null], ARRAY[1.0,-2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 46:
INSERT INTO t1 VALUES (6000, 'text6', B'10101010', E'\\x151354865131651321', false, 'f', '2006-01-01', 60000, 4645.0, -400.0, 500, 'char array', 'bpchar 3', -1, '2004-01-01 00:00:00', '2004-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false, true, false], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5,6,7,8,9,10], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000,40000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 47:
INSERT INTO t1 VALUES (7000, 'text7', B'10101010', E'\\x941231b65d15f16515', true, 'g', '2007-01-01', 70000, -435.10, 500.0, -600, 'char array', 'bpchar 4', -2, '2005-01-01 00:00:00', '2005-01-01 00:00:01+00', '2005-10-19 10:23:54','2005-10-19 10:23:54+02', ARRAY[true, false, true, true,false], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300,400], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 48:
INSERT INTO t1 VALUES (8000, 'text8', B'10101010', E'\\x155e13a312d1c321b2', false, 'h', '2008-01-01', 80000, -4578.10, 600.0, 700, 'char array', 'bpchar 5', -3, '2006-01-01 00:00:00', '2006-01-01 00:00:01+00', '2006-10-19 10:23:54','2006-10-19 10:23:54+02', ARRAY[true, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,-200,300], ARRAY[1,2,-3,4,-5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,-20000,30000,null], ARRAY['2002-01-01'::date,'2001-01-02'::date,null,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 49:
INSERT INTO t1 VALUES (9000, 'text9', B'01010101', E'\\x6513213a321d321c23', true, 'i', '2009-01-01', 90000, 97878.10, 700.0, 800, 'char array', 'bpchar 6', -4, '2007-01-01 00:00:00', '2007-01-01 00:00:01+00', '2007-10-19 09:00:30','2003-10-19 09:00:30+02', ARRAY[false, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,200,300,400,500], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[-1.0,-2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 09:00:30'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 09:00:30'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 50:
INSERT INTO t1 VALUES (10000, 'textbl_postgres0', B'00000000', E'\\x16a51b651f651c651d', false, 'j', '2010-01-01', 10000, 454.10, 800.0, -900, 'char array', 'bpchar 7', 0, '2008-01-01 00:00:00', '2008-01-01 00:00:01+00', '2008-10-19 09:00:30','2008-10-19 09:00:30+02', ARRAY[true, false, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300], ARRAY[-1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 09:00:30'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 09:00:30'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 51:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 52:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 53:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 54:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 55:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 56:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 57:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 58:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 59:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 60:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 61:
INSERT INTO t1 SELECT * FROM t1;

--Testcase 62:
SELECT count(*) FROM ft1;
--Testcase 63:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 64:
CREATE SERVER postgres1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'test1');
--Testcase 65:
CREATE SERVER postgres2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'test2');
--Testcase 66:
CREATE SERVER postgres3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'test3');

--Testcase 67:
CREATE USER MAPPING FOR public SERVER postgres1 OPTIONS (user 'postgres', password 'postgres');
--Testcase 68:
CREATE USER MAPPING FOR public SERVER postgres2 OPTIONS (user 'postgres', password 'postgres');
--Testcase 69:
CREATE USER MAPPING FOR public SERVER postgres3 OPTIONS (user 'postgres', password 'postgres');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres1 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 70:
\d

-- create foreign table to check new datasource
--Testcase 71:
CREATE foreign table ft_test (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres1 OPTIONS (table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 72:
SELECT count(*) FROM ft_test;
--Testcase 73:
SELECT * FROM ft_test ORDER BY c1 LIMIT 10;
--Testcase 74:
DROP DATASOURCE TABLE ft_test;
--Testcase 75:
DROP FOREIGN TABLE ft_test;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres1 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 76:
\d

-- Check data for first 10 records and number of records
--Testcase 77:
SELECT count(*) FROM ft2;
--Testcase 78:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 79:
DROP DATASOURCE TABLE ft2;
--Testcase 80:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres1 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 81:
\d

-- Check data for first 10 records and number of records
--Testcase 82:
SELECT count(*) FROM ft1;
--Testcase 83:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 84:
DROP DATASOURCE TABLE ft1;
--Testcase 85:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 86:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 87:
\d

-- create foreign table to check new datasource
--Testcase 88:
CREATE foreign table ft_test1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres1 OPTIONS (table_name 'T 2');

--Testcase 89:
CREATE foreign table ft_test2 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres2 OPTIONS (table_name 'T 2');

--Testcase 90:
CREATE foreign table ft_test3 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres3 OPTIONS (table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 91:
SELECT count(*) FROM ft_test1;
--Testcase 92:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 93:
DROP DATASOURCE TABLE ft_test1;
--Testcase 94:
DROP FOREIGN TABLE ft_test1;

--Testcase 95:
SELECT count(*) FROM ft_test2;
--Testcase 96:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 97:
DROP DATASOURCE TABLE ft_test2;
--Testcase 98:
DROP FOREIGN TABLE ft_test2;

--Testcase 99:
SELECT count(*) FROM ft_test3;
--Testcase 100:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 101:
DROP DATASOURCE TABLE ft_test3;
--Testcase 102:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 103:
\d

-- Check data for first 10 records and number of records
--Testcase 104:
SELECT count(*) FROM ft2;
--Testcase 105:
SELECT * FROM ft2__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 106:
SELECT * FROM ft2__postgres2__0 ORDER BY c1 LIMIT 10;
--Testcase 107:
SELECT * FROM ft2__postgres3__0 ORDER BY c1 LIMIT 10;
--Testcase 108:
DROP DATASOURCE TABLE ft2__postgres1__0;
--Testcase 109:
DROP DATASOURCE TABLE ft2__postgres2__0;
--Testcase 110:
DROP DATASOURCE TABLE ft2__postgres3__0;
--Testcase 111:
DROP FOREIGN TABLE ft2__postgres1__0;
--Testcase 112:
DROP FOREIGN TABLE ft2__postgres2__0;
--Testcase 113:
DROP FOREIGN TABLE ft2__postgres3__0;
--Testcase 114:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 115:
\d

-- Check data for first 10 records and number of records
--Testcase 116:
SELECT count(*) FROM ft1;
--Testcase 117:
SELECT * FROM ft1__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 118:
SELECT * FROM ft1__postgres2__0 ORDER BY c1 LIMIT 10;
--Testcase 119:
SELECT * FROM ft1__postgres3__0 ORDER BY c1 LIMIT 10;
--Testcase 120:
DROP DATASOURCE TABLE ft1__postgres1__0;
--Testcase 121:
DROP DATASOURCE TABLE ft1__postgres2__0;
--Testcase 122:
DROP DATASOURCE TABLE ft1__postgres3__0;
--Testcase 123:
DROP FOREIGN TABLE ft1__postgres1__0;
--Testcase 124:
DROP FOREIGN TABLE ft1__postgres2__0;
--Testcase 125:
DROP FOREIGN TABLE ft1__postgres3__0;
--Testcase 126:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 127:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud2'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud3');
--Testcase 128:
\d

-- create foreign table to check new datasource
--Testcase 129:
CREATE foreign table ft_test1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres1 OPTIONS (table_name 'T 2');

--Testcase 130:
CREATE foreign table ft_test2 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres2 OPTIONS (table_name 'T 2');

--Testcase 131:
CREATE foreign table ft_test3 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER postgres3 OPTIONS (table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 132:
SELECT count(*) FROM ft_test1;
--Testcase 133:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 134:
DROP DATASOURCE TABLE ft_test1;
--Testcase 135:
DROP FOREIGN TABLE ft_test1;

--Testcase 136:
SELECT count(*) FROM ft_test2;
--Testcase 137:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 138:
DROP DATASOURCE TABLE ft_test2;
--Testcase 139:
DROP FOREIGN TABLE ft_test2;

--Testcase 140:
SELECT count(*) FROM ft_test3;
--Testcase 141:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 142:
DROP DATASOURCE TABLE ft_test3;
--Testcase 143:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud2'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud2');
--Testcase 144:
\d

-- Check data for first 10 records and number of records
--Testcase 145:
SELECT count(*) FROM ft2;
--Testcase 146:
SELECT * FROM ft2__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 147:
SELECT * FROM ft2__postgres2__0 ORDER BY c1 LIMIT 10;
--Testcase 148:
SELECT * FROM ft2__postgres3__0 ORDER BY c1 LIMIT 10;
--Testcase 149:
DROP DATASOURCE TABLE ft2__postgres1__0;
--Testcase 150:
DROP DATASOURCE TABLE ft2__postgres2__0;
--Testcase 151:
DROP DATASOURCE TABLE ft2__postgres3__0;
--Testcase 152:
DROP FOREIGN TABLE ft2__postgres1__0;
--Testcase 153:
DROP FOREIGN TABLE ft2__postgres2__0;
--Testcase 154:
DROP FOREIGN TABLE ft2__postgres3__0;
--Testcase 155:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'T 2', relay 'cloud1'),
        postgres2 OPTIONS (table_name 'T 2', relay 'cloud2'),
        postgres3 OPTIONS (table_name 'T 2', relay 'cloud3');
--Testcase 156:
\d

-- Check data for first 10 records and number of records
--Testcase 157:
SELECT count(*) FROM ft1;
--Testcase 158:
SELECT * FROM ft1__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 159:
SELECT * FROM ft1__postgres2__0 ORDER BY c1 LIMIT 10;
--Testcase 160:
SELECT * FROM ft1__postgres3__0 ORDER BY c1 LIMIT 10;
--Testcase 161:
DROP DATASOURCE TABLE ft1__postgres1__0;
--Testcase 162:
DROP DATASOURCE TABLE ft1__postgres2__0;
--Testcase 163:
DROP DATASOURCE TABLE ft1__postgres3__0;
--Testcase 164:
DROP FOREIGN TABLE ft1__postgres1__0;
--Testcase 165:
DROP FOREIGN TABLE ft1__postgres2__0;
--Testcase 166:
DROP FOREIGN TABLE ft1__postgres3__0;
--Testcase 167:
DROP FOREIGN TABLE ft1;

--Testcase 168:
DROP TABLE t1;
-- ===================================================================
-- TO PGSPIDER SERVER
-- ===================================================================
--Testcase 169:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 170:
CREATE DATASOURCE TABLE ft1;

--Testcase 171:
INSERT INTO t1 VALUES (1000, 'textbl_postgres', B'10101010', E'\\xa7a8a9aaabacadaeaf', true, 'a', '2001-01-01', 10000, 1E-107, 1E-37, 100, 'varchar10', 'bpchar10', 1, '2001-01-01 00:00:00', '2001-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b'], ARRAY['a',''], ARRAY[1000,2000], ARRAY[100,200], ARRAY[1,2], ARRAY['textbl_postgres','text2'], ARRAY[1.0,2.0], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_postgres'], ARRAY[10000,20000], ARRAY['2001-01-01'::date,'2001-01-02'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz]);
--Testcase 172:
INSERT INTO t1 VALUES (2000, 'text2', B'10101010', E'\\x9416a61d32132b321c', true, 'b', '2002-01-01', 20000, 1E-107, 1E-37, 100, 'varchar10', 'bpchar10', 2, '2001-01-01 00:00:00', '2001-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false], ARRAY['a', 'b', 'c'], ARRAY['a','', null], ARRAY[1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','text3'], ARRAY[1.0,2.0,null], ARRAY[1000.0,2000.0], ARRAY['var1','textbl_postgres','vartextbl_postgres'], ARRAY[10000,20000,30000], ARRAY['2001-01-01'::date,'2001-01-02'::date,'2001-01-03'::date,'2001-01-04'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time,'2001-01-03 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz,'2001-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-20 10:23:54'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz,'2004-10-21 10:00:00+02'::timestamptz]);
--Testcase 173:
INSERT INTO t1 VALUES (3000, 'text3', B'10101010', E'\\x151354865131651321', false, 'c', '2003-01-01', 30000, 21122.213, 100.0, 200, 'char array', 'bpchar[]', 3, '2002-01-01 00:00:00', '2002-01-01 00:00:01+00', '2005-10-19 10:23:54','2005-10-19 10:23:54+02', ARRAY[true, false, true, null], ARRAY['a', 'b', 'c', null], ARRAY['a','','x'], ARRAY[1000,null,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2',null], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2001-01-01'::date,'2001-01-02'::date,'2001-01-03'::date], ARRAY['2001-01-01 00:00:00'::time,'2001-01-02 00:00:00'::time,'2001-01-03 00:00:00'::time], ARRAY['2001-01-01 00:00:01+00'::timetz,'2001-01-02 00:00:01+00'::timetz,'2001-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,null,'2004-10-21 10:23:54'::timestamp], ARRAY['2004-10-19 10:23:54+02'::timestamptz,'2004-10-20 10:23:54+02'::timestamptz,'2004-10-21 10:00:00+02'::timestamptz]);
--Testcase 174:
INSERT INTO t1 VALUES (4000, 'text4', B'10101010', E'\\x9416a61d32132b321c', false, 'd', '2004-01-01', 40000, 6565.10, 200.0, 300, 'char array', 'bpchar 1', 4, '2003-01-01 00:00:00', '2003-01-01 00:00:01+00', '2003-10-19 10:23:54','2003-10-19 10:23:54+02', ARRAY[true, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,-2000,3000], ARRAY[100,-200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000,50000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 175:
INSERT INTO t1 VALUES (5000, 'text5', B'10101010', E'\\x941231b65d15f16515', true, 'e', '2005-01-01', 50000, 599.010, 300.0, 400, 'char array', 'bpchar 2', 5, '2003-01-01 00:00:00', '2003-01-01 00:00:01+00', '2003-10-19 10:23:54','2003-10-19 10:23:54+02', ARRAY[true, false, false, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr',null], ARRAY[1.0,-2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 176:
INSERT INTO t1 VALUES (6000, 'text6', B'10101010', E'\\x151354865131651321', false, 'f', '2006-01-01', 60000, 4645.0, -400.0, 500, 'char array', 'bpchar 3', -1, '2004-01-01 00:00:00', '2004-01-01 00:00:01+00', '2004-10-19 10:23:54','2004-10-19 10:23:54+02', ARRAY[true, false, true, false], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300], ARRAY[1,2,3,4,5,6,7,8,9,10], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000,40000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 177:
INSERT INTO t1 VALUES (7000, 'text7', B'10101010', E'\\x941231b65d15f16515', true, 'g', '2007-01-01', 70000, -435.10, 500.0, -600, 'char array', 'bpchar 4', -2, '2005-01-01 00:00:00', '2005-01-01 00:00:01+00', '2005-10-19 10:23:54','2005-10-19 10:23:54+02', ARRAY[true, false, true, true,false], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300,400], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 10:23:54+02'::timestamptz,'2005-10-20 10:23:54+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 178:
INSERT INTO t1 VALUES (8000, 'text8', B'10101010', E'\\x155e13a312d1c321b2', false, 'h', '2008-01-01', 80000, -4578.10, 600.0, 700, 'char array', 'bpchar 5', -3, '2006-01-01 00:00:00', '2006-01-01 00:00:01+00', '2006-10-19 10:23:54','2006-10-19 10:23:54+02', ARRAY[true, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,-200,300], ARRAY[1,2,-3,4,-5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,-20000,30000,null], ARRAY['2002-01-01'::date,'2001-01-02'::date,null,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 10:23:54'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 10:23:54'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 179:
INSERT INTO t1 VALUES (9000, 'text9', B'01010101', E'\\x6513213a321d321c23', true, 'i', '2009-01-01', 90000, 97878.10, 700.0, 800, 'char array', 'bpchar 6', -4, '2007-01-01 00:00:00', '2007-01-01 00:00:01+00', '2007-10-19 09:00:30','2003-10-19 09:00:30+02', ARRAY[false, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[1000,2000,3000], ARRAY[100,200,300,400,500], ARRAY[1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[-1.0,-2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 09:00:30'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 09:00:30'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 180:
INSERT INTO t1 VALUES (10000, 'textbl_postgres0', B'00000000', E'\\x16a51b651f651c651d', false, 'j', '2010-01-01', 10000, 454.10, 800.0, -900, 'char array', 'bpchar 7', 0, '2008-01-01 00:00:00', '2008-01-01 00:00:01+00', '2008-10-19 09:00:30','2008-10-19 09:00:30+02', ARRAY[true, false, false, true, true], ARRAY['a', 'b', 'c', 'd'], ARRAY['a','c','','x'], ARRAY[-1000,2000,3000], ARRAY[100,200,300], ARRAY[-1,2,3,4,5], ARRAY['textbl_postgres','text2','textarr'], ARRAY[1.0,2.0,3.0], ARRAY[1000.0,2000.0,3000.0], ARRAY['vararr','textarr','vartextarray'], ARRAY[10000,20000,30000], ARRAY['2002-01-01'::date,'2001-01-02'::date,'2002-01-03'::date], ARRAY['2002-01-01 00:00:00'::time,'2002-01-02 00:00:00'::time,'2002-01-03 00:00:00'::time], ARRAY['2002-01-01 00:00:01+00'::timetz,'2002-01-02 00:00:01+00'::timetz,'2002-01-03 00:00:01+00'::timetz], ARRAY['2004-10-19 09:00:30'::timestamp,'2004-10-21 10:00:00'::timestamp,'2004-10-21 09:00:30'::timestamp], ARRAY['2005-10-19 09:00:30+02'::timestamptz,'2005-10-20 09:00:30+02'::timestamptz,'2005-10-21 10:00:00+02'::timestamptz]);
--Testcase 181:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 182:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 183:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 184:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 185:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 186:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 187:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 188:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 189:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 190:
INSERT INTO t1 SELECT * FROM t1;
--Testcase 191:
INSERT INTO t1 SELECT * FROM t1;

--Testcase 192:
SELECT count(*) FROM ft1;
--Testcase 193:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 194:
CREATE SERVER pgspider1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '14813', dbname 'test1');
--Testcase 195:
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '14813', dbname 'test2');
--Testcase 196:
CREATE SERVER pgspider3 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '14813', dbname 'test3');

--Testcase 197:
CREATE USER MAPPING FOR public SERVER pgspider1 OPTIONS (user 'postgres', password 'postgres');
--Testcase 198:
CREATE USER MAPPING FOR public SERVER pgspider2 OPTIONS (user 'postgres', password 'postgres');
--Testcase 199:
CREATE USER MAPPING FOR public SERVER pgspider3 OPTIONS (user 'postgres', password 'postgres');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER pgspider1 OPTIONS (table_name 'T 2', relay 'cloud1');
--Testcase 200:
\d

-- create foreign table to check new datasource
--Testcase 201:
CREATE foreign table ft_test (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider1 OPTIONS (table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 202:
SELECT count(*) FROM ft_test;
--Testcase 203:
SELECT * FROM ft_test ORDER BY c1 LIMIT 10;
--Testcase 204:
DROP FOREIGN TABLE ft_test;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER pgspider1 OPTIONS (table_name 't1', relay 'cloud1');
--Testcase 205:
\d

-- Check data for first 10 records and number of records
--Testcase 206:
SELECT count(*) FROM ft2;
--Testcase 207:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 208:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER pgspider1 OPTIONS (table_name 't2', relay 'cloud1');
--Testcase 209:
\d

-- Check data for first 10 records and number of records
--Testcase 210:
SELECT count(*) FROM ft1;
--Testcase 211:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 212:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 213:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't3', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't4', relay 'cloud1'),
        pgspider3 OPTIONS (table_name 't5', relay 'cloud1');
--Testcase 214:
\d

-- create foreign table to check new datasource
--Testcase 215:
CREATE foreign table ft_test1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider1 OPTIONS (table_name 't3');

--Testcase 216:
CREATE foreign table ft_test2 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider2 OPTIONS (table_name 't4');

--Testcase 217:
CREATE foreign table ft_test3 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider3 OPTIONS (table_name 't5');

-- Check data for first 10 records and number of records
--Testcase 218:
SELECT count(*) FROM ft_test1;
--Testcase 219:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 220:
DROP FOREIGN TABLE ft_test1;

--Testcase 221:
SELECT count(*) FROM ft_test2;
--Testcase 222:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 223:
DROP FOREIGN TABLE ft_test2;

--Testcase 224:
SELECT count(*) FROM ft_test3;
--Testcase 225:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 226:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't6', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't7', relay 'cloud1'),
        pgspider3 OPTIONS (table_name 't8', relay 'cloud1');
--Testcase 227:
\d

-- Check data for first 10 records and number of records
--Testcase 228:
SELECT count(*) FROM ft2;
--Testcase 229:
SELECT * FROM ft2__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 230:
SELECT * FROM ft2__pgspider2__0 ORDER BY c1 LIMIT 10;
--Testcase 231:
SELECT * FROM ft2__pgspider3__0 ORDER BY c1 LIMIT 10;
--Testcase 232:
DROP FOREIGN TABLE ft2__pgspider1__0;
--Testcase 233:
DROP FOREIGN TABLE ft2__pgspider2__0;
--Testcase 234:
DROP FOREIGN TABLE ft2__pgspider3__0;
--Testcase 235:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't10', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't11', relay 'cloud1'),
        pgspider3 OPTIONS (table_name 't12', relay 'cloud1');
--Testcase 236:
\d
-- Check data for first 10 records and number of records
--Testcase 237:
SELECT count(*) FROM ft1;
--Testcase 238:
SELECT * FROM ft1__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 239:
SELECT * FROM ft1__pgspider2__0 ORDER BY c1 LIMIT 10;
--Testcase 240:
SELECT * FROM ft1__pgspider3__0 ORDER BY c1 LIMIT 10;
--Testcase 241:
DROP FOREIGN TABLE ft1__pgspider1__0;
--Testcase 242:
DROP FOREIGN TABLE ft1__pgspider2__0;
--Testcase 243:
DROP FOREIGN TABLE ft1__pgspider3__0;
--Testcase 244:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 245:
CREATE foreign table ft1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't13', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't14', relay 'cloud2'),
        pgspider3 OPTIONS (table_name 't15', relay 'cloud3');
--Testcase 246:
\d
-- create foreign table to check new datasource
--Testcase 247:
CREATE foreign table ft_test1 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider1 OPTIONS (table_name 't13');

--Testcase 248:
CREATE foreign table ft_test2 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider2 OPTIONS (table_name 't14');

--Testcase 249:
CREATE foreign table ft_test3 (c1 bigint, c2 text, c3 bit(8), c4 bytea, c5 bool, c6 "char", c7 date, c8 numeric, c9 float8,
    c10 float4, c11 int, c12 varchar(10), c13 char(10), c14 smallint, c15 time, c16 timetz, c17 timestamp, c18 timestamptz,
    c19 bool[], c21 "char"[], c22 char[], c23 bigint[], c24 int[], c25 smallint[], c26 text[], c27 float4[], c28 float8[],
    c29 varchar[], c30 numeric[], c31 date[], c32 time[], c33 timetz[], c34 timestamp[], c35 timestamptz[]
)SERVER pgspider3 OPTIONS (table_name 't15');

-- Check data for first 10 records and number of records
--Testcase 250:
SELECT count(*) FROM ft_test1;
--Testcase 251:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 252:
DROP FOREIGN TABLE ft_test1;

--Testcase 253:
SELECT count(*) FROM ft_test2;
--Testcase 254:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 255:
DROP FOREIGN TABLE ft_test2;

--Testcase 256:
SELECT count(*) FROM ft_test3;
--Testcase 257:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 258:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't16', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't17', relay 'cloud2'),
        pgspider3 OPTIONS (table_name 't18', relay 'cloud2');
--Testcase 259:
\d

-- Check data for first 10 records and number of records
--Testcase 260:
SELECT count(*) FROM ft2;
--Testcase 261:
SELECT * FROM ft2__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 262:
SELECT * FROM ft2__pgspider2__0 ORDER BY c1 LIMIT 10;
--Testcase 263:
SELECT * FROM ft2__pgspider3__0 ORDER BY c1 LIMIT 10;
--Testcase 264:
DROP FOREIGN TABLE ft2__pgspider1__0;
--Testcase 265:
DROP FOREIGN TABLE ft2__pgspider2__0;
--Testcase 266:
DROP FOREIGN TABLE ft2__pgspider3__0;
--Testcase 267:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        pgspider1 OPTIONS (table_name 't19', relay 'cloud1'),
        pgspider2 OPTIONS (table_name 't20', relay 'cloud2'),
        pgspider3 OPTIONS (table_name 't21', relay 'cloud3');
--Testcase 268:
\d

-- Check data for first 10 records and number of records
--Testcase 269:
SELECT count(*) FROM ft1;
--Testcase 270:
SELECT * FROM ft1__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 271:
SELECT * FROM ft1__pgspider2__0 ORDER BY c1 LIMIT 10;
--Testcase 272:
SELECT * FROM ft1__pgspider3__0 ORDER BY c1 LIMIT 10;
--Testcase 273:
DROP FOREIGN TABLE ft1__pgspider1__0;
--Testcase 274:
DROP FOREIGN TABLE ft1__pgspider2__0;
--Testcase 275:
DROP FOREIGN TABLE ft1__pgspider3__0;
--Testcase 276:
DROP FOREIGN TABLE ft1;

--Testcase 277:
DROP TABLE t1;
-- ===================================================================
-- TO MYSQL SERVER
-- ===================================================================
--Testcase 278:
CREATE FOREIGN TABLE ft1 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 279:
CREATE DATASOURCE TABLE ft1;

--Testcase 280:
INSERT INTO t1 VALUES (100, 10, 1, 1.0, 100.0, 10000, B'1', '2001-01-01', '2001-01-03 00:00:00', '2000-11-11 10:10:10', '15454a', 'mysql: text1', 'test1', '\x9416a61d32132b321c');
--Testcase 281:
INSERT INTO t1 VALUES (200, 20, 2, 2.0, 200.0, 20000, B'0', '2002-02-02', '2002-02-03 20:00:00', '2002-12-12 10:12:11', 'DDr', 'mysql: text2', 'test2', '\x9416a61d32132b321c');
--Testcase 282:
INSERT INTO t1 VALUES (300, 30, 3, 3.0, 300.0, 30000, B'1', '2003-03-03', '2003-03-03 10:10:00', '2003-11-13 10:12:10', 'vad', 'mysql: text3', 'test3', '\x16a51b651f651c651d');
--Testcase 283:
INSERT INTO t1 VALUES (400, 40, 4, 4.0, 400.0, 40000, B'0', '2004-04-04', '2004-04-04 18:01:01', '2004-04-14 20:20:10', 'rwe', 'mysql: text4', 'test4', '\x151354865131651321');
--Testcase 284:
INSERT INTO t1 VALUES (500, 50, 5, 5.0, 500.0, 50000, B'1', '2005-05-05', '2005-05-05 05:05:05', '2005-11-15 15:15:15', 'are', 'mysql: text5', 'test5', '\x151354865131651321');
--Testcase 285:
INSERT INTO t1 VALUES (600, 60, 6, 6.0, 600.0, 60000, B'1', '2006-06-06', '2006-06-06 06:06:06', '2006-06-06 16:16:16', 'test', 'mysql: any text possible 1', 'test6', '\x16a51b651f651c651d');
--Testcase 286:
INSERT INTO t1 VALUES (700, 70, 7, 7.0, 700.0, 70000, B'0', '2007-07-07', '2007-07-07 07:07:07', '2007-07-07 17:17:17', 'tet', 'mysql: any text possible 2', 'test7', '\x151354865131651321');
--Testcase 287:
INSERT INTO t1 VALUES (800, 80, 8, 8.0, 800.0, 80000, B'1', '2008-08-08', '2008-08-08 08:08:08', '2008-08-11 18:10:12', 'test', 'mysql: any text possible 3', 'test8', '\x151354865131651321');
--Testcase 288:
INSERT INTO t1 VALUES (900, 90, 9, 19.0, 900.0, 90000, B'1', '2009-09-09', '2009-01-03 00:00:00', '2009-11-11 20:12:10', 'afawef', 'mysql: any text possible 4', 'test9', '\x16a51b651f651c651d');
--Testcase 289:
INSERT INTO t1 VALUES (1000, 100, 10, 10.0, 1000.0, 100000, B'0', '2010-01-01', '2011-01-03 00:01:01', '2011-11-11 10:15:10', 'aw4333g', 'mysql: any text possible 5', 'test10', '\x9416a61d32132b321c');
--Testcase 290:
INSERT INTO t1 select * from t1;
--Testcase 291:
INSERT INTO t1 select * from t1;
--Testcase 292:
INSERT INTO t1 select * from t1;
--Testcase 293:
INSERT INTO t1 select * from t1;
--Testcase 294:
INSERT INTO t1 select * from t1;
--Testcase 295:
INSERT INTO t1 select * from t1;
--Testcase 296:
INSERT INTO t1 select * from t1;
--Testcase 297:
INSERT INTO t1 select * from t1;
--Testcase 298:
INSERT INTO t1 select * from t1;
--Testcase 299:
INSERT INTO t1 select * from t1;
--Testcase 300:
INSERT INTO t1 select * from t1;

--Testcase 301:
SELECT count(*) FROM ft1;
--Testcase 302:
SELECT * FROM ft1 LIMIT 10;

--Testcase 303:
CREATE SERVER mysql1 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1', port '3306');
--Testcase 304:
CREATE SERVER mysql2 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1', port '3306');
--Testcase 305:
CREATE SERVER mysql3 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1', port '3306');

--Testcase 306:
CREATE USER MAPPING FOR public SERVER mysql1 OPTIONS (username 'root', password 'Mysql_1234');
--Testcase 307:
CREATE USER MAPPING FOR public SERVER mysql2 OPTIONS (username 'root', password 'Mysql_1234');
--Testcase 308:
CREATE USER MAPPING FOR public SERVER mysql3 OPTIONS (username 'root', password 'Mysql_1234');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1');
--Testcase 309:
\d
-- create foreign table to check new datasource
--Testcase 310:
CREATE foreign table ft_test ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 311:
SELECT count(*) FROM ft_test;
--Testcase 312:
SELECT * FROM ft_test LIMIT 10;
--Testcase 313:
DROP DATASOURCE TABLE ft_test;
--Testcase 314:
DROP FOREIGN TABLE ft_test;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1');
--Testcase 315:
\d

-- Check data for first 10 records and number of records
--Testcase 316:
SELECT count(*) FROM ft2;
--Testcase 317:
SELECT * FROM ft2 LIMIT 10;
--Testcase 318:
DROP DATASOURCE TABLE ft2;
--Testcase 319:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1');
--Testcase 320:
\d

-- Check data for first 10 records and number of records
--Testcase 321:
SELECT count(*) FROM ft1;
--Testcase 322:
SELECT * FROM ft1 LIMIT 10;
--Testcase 323:
DROP DATASOURCE TABLE ft1;
--Testcase 324:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 325:
CREATE foreign table ft1 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud1'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud1');
--Testcase 326:
\d

-- create foreign table to check new datasource
--Testcase 327:
CREATE foreign table ft_test1 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2');

--Testcase 328:
CREATE foreign table ft_test2 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql2 OPTIONS (dbname 'test2', table_name 'T 2');

--Testcase 329:
CREATE foreign table ft_test3 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql3 OPTIONS (dbname 'test3', table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 330:
SELECT count(*) FROM ft_test1;
--Testcase 331:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 332:
DROP DATASOURCE TABLE ft_test1;
--Testcase 333:
DROP FOREIGN TABLE ft_test1;

--Testcase 334:
SELECT count(*) FROM ft_test2;
--Testcase 335:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 336:
DROP DATASOURCE TABLE ft_test2;
--Testcase 337:
DROP FOREIGN TABLE ft_test2;

--Testcase 338:
SELECT count(*) FROM ft_test3;
--Testcase 339:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 340:
DROP DATASOURCE TABLE ft_test3;
--Testcase 341:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud1'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud1');
--Testcase 342:
\d

-- Check data for first 10 records and number of records
--Testcase 343:
SELECT count(*) FROM ft2;
--Testcase 344:
SELECT * FROM ft2__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 345:
SELECT * FROM ft2__mysql2__0 ORDER BY c1 LIMIT 10;
--Testcase 346:
SELECT * FROM ft2__mysql3__0 ORDER BY c1 LIMIT 10;
--Testcase 347:
DROP DATASOURCE TABLE ft2__mysql1__0;
--Testcase 348:
DROP DATASOURCE TABLE ft2__mysql2__0;
--Testcase 349:
DROP DATASOURCE TABLE ft2__mysql3__0;
--Testcase 350:
DROP FOREIGN TABLE ft2__mysql1__0;
--Testcase 351:
DROP FOREIGN TABLE ft2__mysql2__0;
--Testcase 352:
DROP FOREIGN TABLE ft2__mysql3__0;
--Testcase 353:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud1'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud1');
--Testcase 354:
\d

-- Check data for first 10 records and number of records
--Testcase 355:
SELECT count(*) FROM ft1;
--Testcase 356:
SELECT * FROM ft1__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 357:
SELECT * FROM ft1__mysql2__0 ORDER BY c1 LIMIT 10;
--Testcase 358:
SELECT * FROM ft1__mysql3__0 ORDER BY c1 LIMIT 10;
--Testcase 359:
DROP DATASOURCE TABLE ft1__mysql1__0;
--Testcase 360:
DROP DATASOURCE TABLE ft1__mysql2__0;
--Testcase 361:
DROP DATASOURCE TABLE ft1__mysql3__0;
--Testcase 362:
DROP FOREIGN TABLE ft1__mysql1__0;
--Testcase 363:
DROP FOREIGN TABLE ft1__mysql2__0;
--Testcase 364:
DROP FOREIGN TABLE ft1__mysql3__0;
--Testcase 365:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 366:
CREATE foreign table ft1 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud2'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud3');
--Testcase 367:
\d

-- create foreign table to check new datasource
--Testcase 368:
CREATE foreign table ft_test1 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql1 OPTIONS (dbname 'test1', table_name 'T 2');

--Testcase 369:
CREATE foreign table ft_test2 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql2 OPTIONS (dbname 'test2', table_name 'T 2');

--Testcase 370:
CREATE foreign table ft_test3 ( c1 bigint, c2 int, c3 smallint, c4 float4,
        c5 float8, c6 numeric, c7 bit, c8 date, c9 time, c10 timestamp,
        c11 varchar(10), c12 text, c13 char(10), c14 bytea
)SERVER mysql3 OPTIONS (dbname 'test3', table_name 'T 2');

-- Check data for first 10 records and number of records
--Testcase 371:
SELECT count(*) FROM ft_test1;
--Testcase 372:
SELECT * FROM ft_test1 LIMIT 10;
--Testcase 373:
DROP DATASOURCE TABLE ft_test1;
--Testcase 374:
DROP FOREIGN TABLE ft_test1;

--Testcase 375:
SELECT count(*) FROM ft_test2;
--Testcase 376:
SELECT * FROM ft_test2 LIMIT 10;
--Testcase 377:
DROP DATASOURCE TABLE ft_test2;
--Testcase 378:
DROP FOREIGN TABLE ft_test2;

--Testcase 379:
SELECT count(*) FROM ft_test3;
--Testcase 380:
SELECT * FROM ft_test3 LIMIT 10;
--Testcase 381:
DROP DATASOURCE TABLE ft_test3;
--Testcase 382:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud2'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud2');
--Testcase 383:
\d

-- Check data for first 10 records and number of records
--Testcase 384:
SELECT count(*) FROM ft2;
--Testcase 385:
SELECT * FROM ft2__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 386:
SELECT * FROM ft2__mysql2__0 ORDER BY c1 LIMIT 10;
--Testcase 387:
SELECT * FROM ft2__mysql3__0 ORDER BY c1 LIMIT 10;
--Testcase 388:
DROP DATASOURCE TABLE ft2__mysql1__0;
--Testcase 389:
DROP DATASOURCE TABLE ft2__mysql2__0;
--Testcase 390:
DROP DATASOURCE TABLE ft2__mysql3__0;
--Testcase 391:
DROP FOREIGN TABLE ft2__mysql1__0;
--Testcase 392:
DROP FOREIGN TABLE ft2__mysql2__0;
--Testcase 393:
DROP FOREIGN TABLE ft2__mysql3__0;
--Testcase 394:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        mysql1 OPTIONS (dbname 'test1', table_name 'T 2', relay 'cloud1'),
        mysql2 OPTIONS (dbname 'test2', table_name 'T 2', relay 'cloud2'),
        mysql3 OPTIONS (dbname 'test3', table_name 'T 2', relay 'cloud3');
--Testcase 395:
\d

-- Check data for first 10 records and number of records
--Testcase 396:
SELECT count(*) FROM ft1;
--Testcase 397:
SELECT * FROM ft1__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 398:
SELECT * FROM ft1__mysql2__0 ORDER BY c1 LIMIT 10;
--Testcase 399:
SELECT * FROM ft1__mysql3__0 ORDER BY c1 LIMIT 10;
--Testcase 400:
DROP DATASOURCE TABLE ft1__mysql1__0;
--Testcase 401:
DROP DATASOURCE TABLE ft1__mysql2__0;
--Testcase 402:
DROP DATASOURCE TABLE ft1__mysql3__0;
--Testcase 403:
DROP FOREIGN TABLE ft1__mysql1__0;
--Testcase 404:
DROP FOREIGN TABLE ft1__mysql2__0;
--Testcase 405:
DROP FOREIGN TABLE ft1__mysql3__0;
--Testcase 406:
DROP FOREIGN TABLE ft1;

--Testcase 407:
DROP TABLE t1;
-- ===================================================================
-- TO GRIDDB SERVER
-- ===================================================================
--Testcase 408:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 409:
CREATE DATASOURCE TABLE ft1;

--Testcase 410:
INSERT INTO t1
	SELECT id,
	       id % 1000,
		   id % 100,
		   id / 110,
		   id / 2,
		   true,
		   '1970-01-02'::timestamp + ((id % 100) || ' days')::interval,
	           to_char(id, 'FM00000')
        FROM generate_series(1, 20000) id;

--Testcase 411:
SELECT count(*) FROM ft1;
--Testcase 412:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

-- Griddb use port 20001 for JDBC connection
--Testcase 413:
CREATE SERVER griddb1 FOREIGN DATA WRAPPER griddb_fdw OPTIONS (host '127.0.0.1', port '20002', clustername 'dockerGridDB');
--Testcase 414:
CREATE SERVER griddb2 FOREIGN DATA WRAPPER griddb_fdw OPTIONS (host '127.0.0.1', port '20003', clustername 'dockerGridDB');
--Testcase 415:
CREATE SERVER griddb3 FOREIGN DATA WRAPPER griddb_fdw OPTIONS (host '127.0.0.1', port '20004', clustername 'dockerGridDB');

--Testcase 416:
CREATE USER MAPPING FOR public SERVER griddb1 OPTIONS (username 'admin', password 'admin');
--Testcase 417:
CREATE USER MAPPING FOR public SERVER griddb2 OPTIONS (username 'admin', password 'admin');
--Testcase 418:
CREATE USER MAPPING FOR public SERVER griddb3 OPTIONS (username 'admin', password 'admin');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER griddb1 OPTIONS (table_name 'T2', relay 'cloud1');
--Testcase 419:
\d

-- create foreign table to check new datasource
--Testcase 420:
CREATE foreign table ft_test (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb1 OPTIONS (table_name 'T2');

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 421:
SELECT count(*) FROM ft_test;
--Testcase 422:
SELECT * FROM ft_test ORDER BY c1 LIMIT 10;
--Testcase 423:
DROP DATASOURCE TABLE ft_test;
--Testcase 424:
DROP FOREIGN TABLE ft_test;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER griddb1 OPTIONS (table_name 'T2', relay 'cloud1');
--Testcase 425:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 426:
SELECT count(*) FROM ft2;
--Testcase 427:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 428:
DROP DATASOURCE TABLE ft2;
--Testcase 429:
DROP FOREIGN TABLE ft2;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER griddb1 OPTIONS (table_name 'T2', relay 'cloud1');
--Testcase 430:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 431:
SELECT count(*) FROM ft1;
--Testcase 432:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 433:
DROP DATASOURCE TABLE ft1;
--Testcase 434:
DROP FOREIGN TABLE ft1;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

-- create again src table
--Testcase 435:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud1'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud1');
--Testcase 436:
\d

-- create foreign table to check new datasource
--Testcase 437:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb1 OPTIONS (table_name 't1');

--Testcase 438:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb2 OPTIONS (table_name 't2');

--Testcase 439:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb3 OPTIONS (table_name 't3');

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 440:
SELECT count(*) FROM ft_test1;
--Testcase 441:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 442:
DROP DATASOURCE TABLE ft_test1;
--Testcase 443:
DROP FOREIGN TABLE ft_test1;

--Testcase 444:
SELECT count(*) FROM ft_test2;
--Testcase 445:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 446:
DROP DATASOURCE TABLE ft_test2;
--Testcase 447:
DROP FOREIGN TABLE ft_test2;

--Testcase 448:
SELECT count(*) FROM ft_test3;
--Testcase 449:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 450:
DROP DATASOURCE TABLE ft_test3;
--Testcase 451:
DROP FOREIGN TABLE ft_test3;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud1'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud1');
--Testcase 452:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 453:
SELECT count(*) FROM ft2;
--Testcase 690:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 454:
SELECT * FROM ft2__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 455:
SELECT * FROM ft2__griddb2__0 ORDER BY c1 LIMIT 10;
--Testcase 456:
SELECT * FROM ft2__griddb3__0 ORDER BY c1 LIMIT 10;
--Testcase 457:
DROP DATASOURCE TABLE ft2__griddb1__0;
--Testcase 458:
DROP DATASOURCE TABLE ft2__griddb2__0;
--Testcase 459:
DROP DATASOURCE TABLE ft2__griddb3__0;
--Testcase 460:
DROP FOREIGN TABLE ft2__griddb1__0;
--Testcase 461:
DROP FOREIGN TABLE ft2__griddb2__0;
--Testcase 462:
DROP FOREIGN TABLE ft2__griddb3__0;
--Testcase 463:
DROP FOREIGN TABLE ft2;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud1'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud1');
--Testcase 464:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 465:
SELECT count(*) FROM ft1;
--Testcase 691:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 466:
SELECT * FROM ft1__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 467:
SELECT * FROM ft1__griddb2__0 ORDER BY c1 LIMIT 10;
--Testcase 468:
SELECT * FROM ft1__griddb3__0 ORDER BY c1 LIMIT 10;
--Testcase 469:
DROP DATASOURCE TABLE ft1__griddb1__0;
--Testcase 470:
DROP DATASOURCE TABLE ft1__griddb2__0;
--Testcase 471:
DROP DATASOURCE TABLE ft1__griddb3__0;
--Testcase 472:
DROP FOREIGN TABLE ft1__griddb1__0;
--Testcase 473:
DROP FOREIGN TABLE ft1__griddb2__0;
--Testcase 474:
DROP FOREIGN TABLE ft1__griddb3__0;
--Testcase 475:
DROP FOREIGN TABLE ft1;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

-- create again src table
--Testcase 476:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud2'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud3');
--Testcase 477:
\d

-- create foreign table to check new datasource
--Testcase 478:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb1 OPTIONS (table_name 't1');

--Testcase 479:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb2 OPTIONS (table_name 't2');

--Testcase 480:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb3 OPTIONS (table_name 't3');

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 481:
SELECT count(*) FROM ft_test1;
--Testcase 482:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 483:
DROP DATASOURCE TABLE ft_test1;
--Testcase 484:
DROP FOREIGN TABLE ft_test1;

--Testcase 485:
SELECT count(*) FROM ft_test2;
--Testcase 486:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 487:
DROP DATASOURCE TABLE ft_test2;
--Testcase 488:
DROP FOREIGN TABLE ft_test2;

--Testcase 489:
SELECT count(*) FROM ft_test3;
--Testcase 490:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 491:
DROP DATASOURCE TABLE ft_test3;
--Testcase 492:
DROP FOREIGN TABLE ft_test3;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud2'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud2');
--Testcase 493:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 494:
SELECT count(*) FROM ft2;
--Testcase 692:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 495:
SELECT * FROM ft2__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 496:
SELECT * FROM ft2__griddb2__0 ORDER BY c1 LIMIT 10;
--Testcase 497:
SELECT * FROM ft2__griddb3__0 ORDER BY c1 LIMIT 10;
--Testcase 498:
DROP DATASOURCE TABLE ft2__griddb1__0;
--Testcase 499:
DROP DATASOURCE TABLE ft2__griddb2__0;
--Testcase 500:
DROP DATASOURCE TABLE ft2__griddb3__0;
--Testcase 501:
DROP FOREIGN TABLE ft2__griddb1__0;
--Testcase 502:
DROP FOREIGN TABLE ft2__griddb2__0;
--Testcase 503:
DROP FOREIGN TABLE ft2__griddb3__0;
--Testcase 504:
DROP FOREIGN TABLE ft2;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        griddb1 OPTIONS (table_name 't1', relay 'cloud1'),
        griddb2 OPTIONS (table_name 't2', relay 'cloud2'),
        griddb3 OPTIONS (table_name 't3', relay 'cloud3');
--Testcase 505:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
ALTER SERVER griddb2 OPTIONS (drop host);
ALTER SERVER griddb2 OPTIONS (drop port);
ALTER SERVER griddb2 OPTIONS (add notification_member '127.0.0.1:10003');
ALTER SERVER griddb3 OPTIONS (drop host);
ALTER SERVER griddb3 OPTIONS (drop port);
ALTER SERVER griddb3 OPTIONS (add notification_member '127.0.0.1:10004');
--Testcase 506:
SELECT count(*) FROM ft1;
--Testcase 693:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 507:
SELECT * FROM ft1__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 508:
SELECT * FROM ft1__griddb2__0 ORDER BY c1 LIMIT 10;
--Testcase 509:
SELECT * FROM ft1__griddb3__0 ORDER BY c1 LIMIT 10;
--Testcase 510:
DROP DATASOURCE TABLE ft1__griddb1__0;
--Testcase 511:
DROP DATASOURCE TABLE ft1__griddb2__0;
--Testcase 512:
DROP DATASOURCE TABLE ft1__griddb3__0;
--Testcase 513:
DROP FOREIGN TABLE ft1__griddb1__0;
--Testcase 514:
DROP FOREIGN TABLE ft1__griddb2__0;
--Testcase 515:
DROP FOREIGN TABLE ft1__griddb3__0;
--Testcase 516:
DROP FOREIGN TABLE ft1;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');
ALTER SERVER griddb2 OPTIONS (drop notification_member);
ALTER SERVER griddb2 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb2 OPTIONS (add port '20003');
ALTER SERVER griddb3 OPTIONS (drop notification_member);
ALTER SERVER griddb3 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb3 OPTIONS (add port '20004');

--Testcase 517:
DROP TABLE t1;
-- ===================================================================
-- TO ORACLE SERVER
-- ===================================================================
--Testcase 518:
CREATE FOREIGN TABLE ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 519:
CREATE DATASOURCE TABLE ft1;

--Testcase 520:
INSERT INTO t1
	 SELECT id,
	        id % 1000,
		id % 100,
		id / 110,
		id / 2,
		id * 3,
		'1970-01-01'::date + ((id % 100) || ' days')::interval,
		'1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
	        '1970-01-01'::timestamptz + ((id % 100) || ' days')::interval,
	        'ora' || id,
	        to_char(id, 'FM00000'),
	        'foo',
		'\x151354865131651321'
	FROM generate_series(1, 20000) id;

--Testcase 521:
SELECT count(*) FROM ft1;
--Testcase 522:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 523:
CREATE SERVER oracle1 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver 'localhost:1521/XE', isolation_level 'read_committed', nchar 'true');
--Testcase 524:
CREATE SERVER oracle2 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver 'localhost:1521/XE', isolation_level 'read_committed', nchar 'true');
--Testcase 525:
CREATE SERVER oracle3 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver 'localhost:1521/XE', isolation_level 'read_committed', nchar 'true');

--Testcase 526:
CREATE USER MAPPING FOR public SERVER oracle1 OPTIONS (user 'test1', password 'test1');
--Testcase 527:
CREATE USER MAPPING FOR public SERVER oracle2 OPTIONS (user 'test2', password 'test2');
--Testcase 528:
CREATE USER MAPPING FOR public SERVER oracle3 OPTIONS (user 'test3', password 'test3');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER oracle1 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 529:
\d
-- create foreign table to check new datasource
--Testcase 530:
CREATE foreign table ft_test (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle1 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 531:
SELECT count(*) FROM ft_test;
--Testcase 532:
SELECT * FROM ft_test ORDER BY c1 LIMIT 10;
--Testcase 533:
DROP DATASOURCE TABLE ft_test;
--Testcase 534:
DROP FOREIGN TABLE ft_test;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER oracle1 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 535:
\d

-- Check data for first 10 records and number of records
--Testcase 536:
SELECT count(*) FROM ft2;
--Testcase 537:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 538:
DROP DATASOURCE TABLE ft2;
--Testcase 539:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER oracle1 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 540:
\d

-- Check data for first 10 records and number of records
--Testcase 541:
SELECT count(*) FROM ft1;
--Testcase 542:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 543:
DROP DATASOURCE TABLE ft1;
--Testcase 544:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 545:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud1'),
        oracle3 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 546:
\d

-- create foreign table to check new datasource
--Testcase 547:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle1 OPTIONS (table 'T2');

--Testcase 548:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle2 OPTIONS (table 'T2');

--Testcase 549:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle3 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 550:
SELECT count(*) FROM ft_test1;
--Testcase 551:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 552:
DROP DATASOURCE TABLE ft_test1;
--Testcase 553:
DROP FOREIGN TABLE ft_test1;

--Testcase 554:
SELECT count(*) FROM ft_test2;
--Testcase 555:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 556:
DROP DATASOURCE TABLE ft_test2;
--Testcase 557:
DROP FOREIGN TABLE ft_test2;

--Testcase 558:
SELECT count(*) FROM ft_test3;
--Testcase 559:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 560:
DROP DATASOURCE TABLE ft_test3;
--Testcase 561:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud1'),
        oracle3 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 562:
\d

-- Check data for first 10 records and number of records
--Testcase 563:
SELECT count(*) FROM ft2;
--Testcase 564:
SELECT * FROM ft2__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 565:
SELECT * FROM ft2__oracle2__0 ORDER BY c1 LIMIT 10;
--Testcase 566:
SELECT * FROM ft2__oracle3__0 ORDER BY c1 LIMIT 10;
--Testcase 567:
DROP DATASOURCE TABLE ft2__oracle1__0;
--Testcase 568:
DROP DATASOURCE TABLE ft2__oracle2__0;
--Testcase 569:
DROP DATASOURCE TABLE ft2__oracle3__0;
--Testcase 570:
DROP FOREIGN TABLE ft2__oracle1__0;
--Testcase 571:
DROP FOREIGN TABLE ft2__oracle2__0;
--Testcase 572:
DROP FOREIGN TABLE ft2__oracle3__0;
--Testcase 573:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud1'),
        oracle3 OPTIONS (table 'T2', relay 'cloud1');
--Testcase 574:
\d

-- Check data for first 10 records and number of records
--Testcase 575:
SELECT count(*) FROM ft1;
--Testcase 576:
SELECT * FROM ft1__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 577:
SELECT * FROM ft1__oracle2__0 ORDER BY c1 LIMIT 10;
--Testcase 578:
SELECT * FROM ft1__oracle3__0 ORDER BY c1 LIMIT 10;
--Testcase 579:
DROP DATASOURCE TABLE ft1__oracle1__0;
--Testcase 580:
DROP DATASOURCE TABLE ft1__oracle2__0;
--Testcase 581:
DROP DATASOURCE TABLE ft1__oracle3__0;
--Testcase 582:
DROP FOREIGN TABLE ft1__oracle1__0;
--Testcase 583:
DROP FOREIGN TABLE ft1__oracle2__0;
--Testcase 584:
DROP FOREIGN TABLE ft1__oracle3__0;
--Testcase 585:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 586:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud2'),
        oracle3 OPTIONS (table 'T2', relay 'cloud3');
--Testcase 587:
\d

-- create foreign table to check new datasource
--Testcase 588:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle1 OPTIONS (table 'T2');

--Testcase 589:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle2 OPTIONS (table 'T2');

--Testcase 590:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8,
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER oracle3 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 591:
SELECT count(*) FROM ft_test1;
--Testcase 592:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 593:
DROP DATASOURCE TABLE ft_test1;
--Testcase 594:
DROP FOREIGN TABLE ft_test1;

--Testcase 595:
SELECT count(*) FROM ft_test2;
--Testcase 596:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 597:
DROP DATASOURCE TABLE ft_test2;
--Testcase 598:
DROP FOREIGN TABLE ft_test2;

--Testcase 599:
SELECT count(*) FROM ft_test3;
--Testcase 600:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 601:
DROP DATASOURCE TABLE ft_test3;
--Testcase 602:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud2'),
        oracle3 OPTIONS (table 'T2', relay 'cloud2');
--Testcase 603:
\d

-- Check data for first 10 records and number of records
--Testcase 604:
SELECT count(*) FROM ft2;
--Testcase 605:
SELECT * FROM ft2__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 606:
SELECT * FROM ft2__oracle2__0 ORDER BY c1 LIMIT 10;
--Testcase 607:
SELECT * FROM ft2__oracle3__0 ORDER BY c1 LIMIT 10;
--Testcase 608:
DROP DATASOURCE TABLE ft2__oracle1__0;
--Testcase 609:
DROP DATASOURCE TABLE ft2__oracle2__0;
--Testcase 610:
DROP DATASOURCE TABLE ft2__oracle3__0;
--Testcase 611:
DROP FOREIGN TABLE ft2__oracle1__0;
--Testcase 612:
DROP FOREIGN TABLE ft2__oracle2__0;
--Testcase 613:
DROP FOREIGN TABLE ft2__oracle3__0;
--Testcase 614:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        oracle1 OPTIONS (table 'T2', relay 'cloud1'),
        oracle2 OPTIONS (table 'T2', relay 'cloud2'),
        oracle3 OPTIONS (table 'T2', relay 'cloud3');
--Testcase 615:
\d

-- Check data for first 10 records and number of records
--Testcase 616:
SELECT count(*) FROM ft1;
--Testcase 617:
SELECT * FROM ft1__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 618:
SELECT * FROM ft1__oracle2__0 ORDER BY c1 LIMIT 10;
--Testcase 619:
SELECT * FROM ft1__oracle3__0 ORDER BY c1 LIMIT 10;
--Testcase 620:
DROP DATASOURCE TABLE ft1__oracle1__0;
--Testcase 621:
DROP DATASOURCE TABLE ft1__oracle2__0;
--Testcase 622:
DROP DATASOURCE TABLE ft1__oracle3__0;
--Testcase 623:
DROP FOREIGN TABLE ft1__oracle1__0;
--Testcase 624:
DROP FOREIGN TABLE ft1__oracle2__0;
--Testcase 625:
DROP FOREIGN TABLE ft1__oracle3__0;
--Testcase 626:
DROP FOREIGN TABLE ft1;

--Testcase 627:
DROP TABLE t1;
-- ===================================================================
-- TO INFLUXDB SERVER
-- ===================================================================
--Testcase 691:
CREATE FOREIGN TABLE ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');
--Testcase 692:
CREATE DATASOURCE TABLE ft1;
--Testcase 693:
INSERT INTO t1
	 SELECT id,
	        id % 1000,
		id % 100,
		id / 110,
		id / 2,
		id * 3,
		'1970-01-01'::date + ((id % 100) || ' days')::interval,
		'1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
	        '1970-01-01'::timestamptz + ((id % 100) || ' days')::interval,
	        'ora' || id,
	        to_char(id, 'FM00000'),
	        'foo',
		'\x151354865131651321'
	FROM generate_series(1, 20000) id;
--Testcase 694:
SELECT count(*) FROM ft1;
--Testcase 695:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 696:
CREATE SERVER influx1 FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '38086', dbname 'test1', version '2', retention_policy '');
--Testcase 697:
CREATE SERVER influx2 FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '38086', dbname 'test2', version '2', retention_policy '');
--Testcase 698:
CREATE SERVER influx3 FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '38086', dbname 'test3', version '2', retention_policy '');
--Testcase 699:
CREATE USER MAPPING FOR public SERVER influx1 OPTIONS (auth_token 'mytoken');
--Testcase 700:
CREATE USER MAPPING FOR public SERVER influx2 OPTIONS (auth_token 'mytoken');
--Testcase 701:
CREATE USER MAPPING FOR public SERVER influx3 OPTIONS (auth_token 'mytoken');

-- * migrate sigle target server and single relay server
-- MIGRATE NONE
--Testcase 702:
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 703:
\d
-- create foreign table to check new datasource
--Testcase 704:
CREATE foreign table ft_test (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx1 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 705:
SELECT count(*) FROM ft_test;
--Testcase 706:
SELECT * FROM ft_test ORDER BY c1 LIMIT 10;
--Testcase 707:
DROP DATASOURCE TABLE ft_test;
--Testcase 708:
DROP FOREIGN TABLE ft_test; 

-- MIGRATE TO
--Testcase 709:
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 710:
\d

-- Check data for first 10 records and number of records
--Testcase 711:
SELECT count(*) FROM ft2;
--Testcase 710:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 712:
DROP DATASOURCE TABLE ft2;
--Testcase 713:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
--Testcase 714:
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 715:
\d

-- Check data for first 10 records and number of records
--Testcase 716:
SELECT count(*) FROM ft1;
--Testcase 717:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 718:
DROP DATASOURCE TABLE ft1;
--Testcase 719:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 720:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and single relay server
-- MIGRATE NONE
--Testcase 721:
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER 
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 722:
\d

-- create foreign table to check new datasource
--Testcase 723:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx1 OPTIONS (table 'T2');
--Testcase 724:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx2 OPTIONS (table 'T2');
--Testcase 725:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx3 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 726:
SELECT count(*) FROM ft_test1;
--Testcase 727:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 728:
DROP DATASOURCE TABLE ft_test1;
--Testcase 729:
DROP FOREIGN TABLE ft_test1;
--Testcase 730:
SELECT count(*) FROM ft_test2;
--Testcase 731:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 732:
DROP DATASOURCE TABLE ft_test2;
--Testcase 733:
DROP FOREIGN TABLE ft_test2;
--Testcase 734:
SELECT count(*) FROM ft_test3;
--Testcase 735:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 736:
DROP DATASOURCE TABLE ft_test3;
--Testcase 737:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
--Testcase 738:
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER 
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 739:
\d

-- Check data for first 10 records and number of records
--Testcase 740:
SELECT count(*) FROM ft2;
--Testcase 741:
SELECT * FROM ft2__influx1__0 ORDER BY c1 LIMIT 10;
--Testcase 742:
SELECT * FROM ft2__influx2__0 ORDER BY c1 LIMIT 10;
--Testcase 743:
SELECT * FROM ft2__influx3__0 ORDER BY c1 LIMIT 10;
--Testcase 744:
DROP DATASOURCE TABLE ft2__influx1__0;
--Testcase 745:
DROP DATASOURCE TABLE ft2__influx2__0;
--Testcase 746:
DROP DATASOURCE TABLE ft2__influx3__0;
--Testcase 747:
DROP FOREIGN TABLE ft2__influx1__0;
--Testcase 748:
DROP FOREIGN TABLE ft2__influx2__0;
--Testcase 749:
DROP FOREIGN TABLE ft2__influx3__0;
--Testcase 750:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
--Testcase 751:
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud1', org 'myorg');
--Testcase 752:
\d

-- Check data for first 10 records and number of records
--Testcase 753:
SELECT count(*) FROM ft1;
--Testcase 754:
SELECT * FROM ft1__influx1__0 ORDER BY c1 LIMIT 10;
--Testcase 755:
SELECT * FROM ft1__influx2__0 ORDER BY c1 LIMIT 10;
--Testcase 756:
SELECT * FROM ft1__influx3__0 ORDER BY c1 LIMIT 10;
--Testcase 757:
DROP DATASOURCE TABLE ft1__influx1__0;
--Testcase 758:
DROP DATASOURCE TABLE ft1__influx2__0;
--Testcase 759:
DROP DATASOURCE TABLE ft1__influx3__0;
--Testcase 760:
DROP FOREIGN TABLE ft1__influx1__0;
--Testcase 761:
DROP FOREIGN TABLE ft1__influx2__0;
--Testcase 762:
DROP FOREIGN TABLE ft1__influx3__0;
--Testcase 763:
DROP FOREIGN TABLE ft1;

-- create again src table
--Testcase 764:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER loopback OPTIONS (table_name 't1');

-- * migrate multi target server and multi relay server
-- MIGRATE NONE
--Testcase 765:
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud2', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud3', org 'myorg');
--Testcase 766:
\d

-- create foreign table to check new datasource
--Testcase 767:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx1 OPTIONS (table 'T2');
--Testcase 768:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx2 OPTIONS (table 'T2');
--Testcase 769:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint, c4 float4, c5 float8, 
    c6 numeric, c7 date, c8 timestamp, c9 timestamptz, c10 varchar(10), c11 text,
    c12 char(10), c13 bytea
)SERVER influx3 OPTIONS (table 'T2');

-- Check data for first 10 records and number of records
--Testcase 770:
SELECT count(*) FROM ft_test1;
--Testcase 771:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 772:
DROP DATASOURCE TABLE ft_test1;
--Testcase 773:
DROP FOREIGN TABLE ft_test1;

--Testcase 774:
SELECT count(*) FROM ft_test2;
--Testcase 775:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 776:
DROP DATASOURCE TABLE ft_test2;
--Testcase 777:
DROP FOREIGN TABLE ft_test2;

--Testcase 778:
SELECT count(*) FROM ft_test3;
--Testcase 779:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 780:
DROP DATASOURCE TABLE ft_test3;
--Testcase 781:
DROP FOREIGN TABLE ft_test3;

-- MIGRATE TO
--Testcase 782:
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud2', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud3', org 'myorg');
--Testcase 783:
\d

-- Check data for first 10 records and number of records
--Testcase 784:
SELECT count(*) FROM ft2;
--Testcase 785:
SELECT * FROM ft2__influx1__0 ORDER BY c1 LIMIT 10;
--Testcase 786:
SELECT * FROM ft2__influx2__0 ORDER BY c1 LIMIT 10;
--Testcase 787:
SELECT * FROM ft2__influx3__0 ORDER BY c1 LIMIT 10;
--Testcase 788:
DROP DATASOURCE TABLE ft2__influx1__0;
--Testcase 789:
DROP DATASOURCE TABLE ft2__influx2__0;
--Testcase 790:
DROP DATASOURCE TABLE ft2__influx3__0;
--Testcase 791:
DROP FOREIGN TABLE ft2__influx1__0;
--Testcase 792:
DROP FOREIGN TABLE ft2__influx2__0;
--Testcase 793:
DROP FOREIGN TABLE ft2__influx3__0;
--Testcase 794:
DROP FOREIGN TABLE ft2;

-- MIGRATE REPLACE
--Testcase 795:
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER 
        influx1 OPTIONS (table 'T2', relay 'cloud1', org 'myorg'),
        influx2 OPTIONS (table 'T2', relay 'cloud2', org 'myorg'), 
        influx3 OPTIONS (table 'T2', relay 'cloud3', org 'myorg');
--Testcase 796:
\d

-- Check data for first 10 records and number of records
--Testcase 797:
SELECT count(*) FROM ft1;
--Testcase 798:
SELECT * FROM ft1__influx1__0 ORDER BY c1 LIMIT 10;
--Testcase 799:
SELECT * FROM ft1__influx2__0 ORDER BY c1 LIMIT 10;
--Testcase 800:
SELECT * FROM ft1__influx3__0 ORDER BY c1 LIMIT 10;
--Testcase 801:
DROP DATASOURCE TABLE ft1__influx1__0;
--Testcase 802:
DROP DATASOURCE TABLE ft1__influx2__0;
--Testcase 803:
DROP DATASOURCE TABLE ft1__influx3__0;
--Testcase 804:
DROP FOREIGN TABLE ft1__influx1__0;
--Testcase 805:
DROP FOREIGN TABLE ft1__influx2__0;
--Testcase 806:
DROP FOREIGN TABLE ft1__influx3__0;
--Testcase 807:
DROP FOREIGN TABLE ft1;

--Testcase 816:
DROP TABLE t1;
-- ===================================================================
-- TO DIFERENCE TARGET SERVER
-- ===================================================================
--Testcase 628:
CREATE foreign table ft1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER loopback OPTIONS (table_name 't1');

--Testcase 629:
CREATE DATASOURCE TABLE ft1;

--Testcase 630:
INSERT INTO t1
	SELECT id,
	       id % 1000,
		   id % 100,
		   id / 110,
		   id / 2,
		   true,
		   '1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
	           to_char(id, 'FM00000')
        FROM generate_series(1, 20000) id;

--Testcase 631:
SELECT count(*) FROM ft1;
--Testcase 632:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

-- MIGRATE NONE
MIGRATE TABLE ft1 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'multi', relay 'cloud1'),
        pgspider1 OPTIONS (table_name 'multi1', relay 'cloud1'),
        mysql1 OPTIONS (dbname 'test1', table_name 'multi', relay 'cloud1'),
        griddb1 OPTIONS (table_name 'multi', relay 'cloud1'),
        oracle1 OPTIONS (table 'multi', relay 'cloud1'),
        influx1 OPTIONS (table 'multi', relay 'cloud1', org 'myorg');
--Testcase 633:
\d

-- create foreign table to check new datasource
--Testcase 634:
CREATE foreign table ft_test1 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER postgres1 OPTIONS (table_name 'multi');
--Testcase 635:
CREATE foreign table ft_test2 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER pgspider1 OPTIONS (table_name 'multi1');
--Testcase 636:
CREATE foreign table ft_test3 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER mysql1 OPTIONS (dbname 'test1', table_name 'multi');
--Testcase 637:
CREATE foreign table ft_test4 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER griddb1 OPTIONS (table_name 'multi');
--Testcase 638:
CREATE foreign table ft_test5 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER oracle1 OPTIONS (table 'multi');
--Testcase 808:
CREATE foreign table ft_test6 (c1 bigint, c2 int, c3 smallint,
    c4 float4, c5 float8, c6 bool, c7 timestamp, c8 text
)SERVER influx1 OPTIONS (table 'multi');

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 639:
SELECT count(*) FROM ft_test1;
--Testcase 640:
SELECT * FROM ft_test1 ORDER BY c1 LIMIT 10;
--Testcase 641:
SELECT count(*) FROM ft_test2;
--Testcase 642:
SELECT * FROM ft_test2 ORDER BY c1 LIMIT 10;
--Testcase 643:
SELECT count(*) FROM ft_test3;
--Testcase 644:
SELECT * FROM ft_test3 ORDER BY c1 LIMIT 10;
--Testcase 645:
SELECT count(*) FROM ft_test4;
--Testcase 646:
SELECT * FROM ft_test4 ORDER BY c1 LIMIT 10;
--Testcase 647:
SELECT count(*) FROM ft_test5;
--Testcase 648:
SELECT * FROM ft_test5 ORDER BY c1 LIMIT 10;
--Testcase 809:
SELECT count(*) FROM ft_test6;
--Testcase 810:
SELECT * FROM ft_test6 ORDER BY c1 LIMIT 10;

--Testcase 649:
DROP DATASOURCE TABLE ft_test1;
--Testcase 650:
DROP DATASOURCE TABLE ft_test3;
--Testcase 651:
DROP DATASOURCE TABLE ft_test4;
--Testcase 652:
DROP DATASOURCE TABLE ft_test5;
--Testcase 811:
DROP DATASOURCE TABLE ft_test6;
--Testcase 653:
DROP FOREIGN TABLE ft_test1;
--Testcase 654:
DROP FOREIGN TABLE ft_test2;
--Testcase 655:
DROP FOREIGN TABLE ft_test3;
--Testcase 656:
DROP FOREIGN TABLE ft_test4;
--Testcase 657:
DROP FOREIGN TABLE ft_test5;
--Testcase 812:
DROP FOREIGN TABLE ft_test6;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

-- MIGRATE TO
MIGRATE TABLE ft1 TO ft2 OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'multi', relay 'cloud1'),
        pgspider1 OPTIONS (table_name 'multi2', relay 'cloud1'),
        mysql1 OPTIONS (dbname 'test1', table_name 'multi', relay 'cloud1'),
        griddb1 OPTIONS (table_name 'multi', relay 'cloud1'),
        oracle1 OPTIONS (table 'multi', relay 'cloud1'),
        influx1 OPTIONS (table 'multi', relay 'cloud1', org 'myorg');
--Testcase 658:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 659:
SELECT count(*) FROM ft2;
--Testcase 660:
SELECT * FROM ft2__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 661:
SELECT * FROM ft2__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 662:
SELECT * FROM ft2__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 663:
SELECT * FROM ft2__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 664:
SELECT * FROM ft2__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 813:
SELECT * FROM ft2__influx1__0 ORDER BY c1 LIMIT 10;
--Testcase 665:
DROP DATASOURCE TABLE ft2__postgres1__0;
--Testcase 666:
DROP DATASOURCE TABLE ft2__mysql1__0;
--Testcase 667:
DROP DATASOURCE TABLE ft2__griddb1__0;
--Testcase 668:
DROP DATASOURCE TABLE ft2__oracle1__0;
--Testcase 814:
DROP DATASOURCE TABLE ft2__influx1__0;
--Testcase 669:
DROP FOREIGN TABLE ft2__postgres1__0;
--Testcase 670:
DROP FOREIGN TABLE ft2__pgspider1__0;
--Testcase 671:
DROP FOREIGN TABLE ft2__mysql1__0;
--Testcase 672:
DROP FOREIGN TABLE ft2__griddb1__0;
--Testcase 673:
DROP FOREIGN TABLE ft2__oracle1__0;
--Testcase 815:
DROP FOREIGN TABLE ft2__influx1__0;
--Testcase 674:
DROP FOREIGN TABLE ft2;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

-- MIGRATE REPLACE
MIGRATE TABLE ft1 REPLACE OPTIONS (socket_port '4814', function_timeout '800') SERVER
        postgres1 OPTIONS (table_name 'multi', relay 'cloud1'),
        pgspider1 OPTIONS (table_name 'multi3', relay 'cloud1'),
        mysql1 OPTIONS (dbname 'test1', table_name 'multi', relay 'cloud1'),
        griddb1 OPTIONS (table_name 'multi', relay 'cloud1'),
        oracle1 OPTIONS (table 'multi', relay 'cloud1'),
        influx1 OPTIONS (table 'multi', relay 'cloud1', org 'myorg');
--Testcase 675:
\d

-- Check data for first 10 records and number of records
ALTER SERVER griddb1 OPTIONS (drop host);
ALTER SERVER griddb1 OPTIONS (drop port);
ALTER SERVER griddb1 OPTIONS (add notification_member '127.0.0.1:10002');
--Testcase 676:
SELECT count(*) FROM ft1;
--Testcase 677:
SELECT * FROM ft1__postgres1__0 ORDER BY c1 LIMIT 10;
--Testcase 678:
SELECT * FROM ft1__pgspider1__0 ORDER BY c1 LIMIT 10;
--Testcase 679:
SELECT * FROM ft1__mysql1__0 ORDER BY c1 LIMIT 10;
--Testcase 680:
SELECT * FROM ft1__griddb1__0 ORDER BY c1 LIMIT 10;
--Testcase 681:
SELECT * FROM ft1__oracle1__0 ORDER BY c1 LIMIT 10;
--Testcase 682:
DROP FOREIGN TABLE ft1;
ALTER SERVER griddb1 OPTIONS (drop notification_member);
ALTER SERVER griddb1 OPTIONS (add host '127.0.0.1');
ALTER SERVER griddb1 OPTIONS (add port '20002');

--Testcase 683:
DROP TABLE t1;

-- ===================================================================
-- CREATE RELAY SERVER TABLE WITH NAT OPTIONS
-- ===================================================================

CREATE SERVER postgres_svr_test FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '5432', dbname 'test1');
CREATE USER MAPPING FOR public SERVER postgres_svr_test OPTIONS (user 'postgres', password 'postgres');
CREATE SERVER cloud_test FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (endpoint 'http://localhost:8080', proxy 'no', batch_size '10000');
CREATE USER MAPPING FOR public SERVER cloud_test;
CREATE table test_nat_tbl (c1 bigint);
INSERT INTO test_nat_tbl VALUES (12346);

-- Migrate fail, ifconfig_service does not correct
--Testcase 684:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', ifconfig_service 'localhost:2222') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate fail, host does not correct
--Testcase 685:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '123.123.123.123.123') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host 'pgspider_no_exist.test') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate fail, public_host and ifconfig_service cannot both config
--Testcase 686:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', ifconfig_service 'localhost:2255') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate success
--Testcase 687:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', ifconfig_service 'localhost:2255' ) SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
SELECT * FROM test_tbl;

DROP DATASOURCE TABLE test_tbl;
DROP FOREIGN TABLE test_tbl;

-- Migrate fail, port out of range
--Testcase 688:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', public_port '0') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', public_port '65536') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', public_port 'localhost') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate fail, port does not correct
--Testcase 689:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', public_port '4444') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');

-- Migrate success, port valid
--Testcase 690:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_host '127.0.0.1', public_port '24814') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
SELECT * FROM test_tbl;

DROP DATASOURCE TABLE test_tbl;
DROP FOREIGN TABLE test_tbl;

-- Migrate success
--Testcase 691:
MIGRATE TABLE test_nat_tbl TO test_tbl OPTIONS (socket_port '4814', function_timeout '800', public_port '24814', ifconfig_service 'localhost:2255') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl', relay 'cloud_test');
SELECT * FROM test_tbl;
-- Migrate success
--Testcase 692:
MIGRATE TABLE test_nat_tbl TO test_tbl2 OPTIONS (socket_port '4814', function_timeout '800', public_host 'pgspider.test') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl2', relay 'cloud_test');
SELECT * FROM test_tbl2;
-- Migrate success
--Testcase 693:
MIGRATE TABLE test_nat_tbl TO test_tbl3 OPTIONS (socket_port '4814', function_timeout '800') SERVER postgres_svr_test OPTIONS (table_name 'test_tbl3', relay 'cloud_test');
SELECT * FROM test_tbl3;

DROP DATASOURCE TABLE test_tbl;
DROP DATASOURCE TABLE test_tbl2;
DROP DATASOURCE TABLE test_tbl3;
DROP FOREIGN TABLE test_tbl;
DROP FOREIGN TABLE test_tbl2;
DROP FOREIGN TABLE test_tbl3;

DROP TABLE test_nat_tbl;

DROP SERVER postgres_svr_test CASCADE;

-- Clean
--Testcase 694:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 695:
DROP EXTENSION mysql_fdw CASCADE;
--Testcase 696:
DROP EXTENSION oracle_fdw CASCADE;
--Testcase 697:
DROP EXTENSION griddb_fdw CASCADE;
--Testcase 698:
DROP EXTENSION influxdb_fdw CASCADE;
--Testcase 699:
DROP EXTENSION pgspider_fdw CASCADE;
--Testcase 700:
DROP EXTENSION pgspider_core_fdw CASCADE;
