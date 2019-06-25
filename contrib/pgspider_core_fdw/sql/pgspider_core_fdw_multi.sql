CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION pgspider_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1',port '50849');
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE FOREIGN TABLE test1 (i int,__spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE test2 (t text, t2 text, i int,__spd_url text) SERVER pgspider_core_svr;
--- PGSpider 1
CREATE SERVER pgspider_srv_1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_srv_1;
-- pgspider_core_fdw table
CREATE FOREIGN TABLE test1__pgspider_srv_1__test (i int,__spd_url text) SERVER pgspider_srv_1 OPTIONS (table_name 'test1');
SELECT * FROM test1__pgspider_srv_1__test ORDER BY i, __spd_url;
SELECT * FROM test1 ORDER BY i, __spd_url;
SELECT i FROM test1__pgspider_srv_1__test ORDER BY i;
SELECT __spd_url FROM test1__pgspider_srv_1__test ORDER BY __spd_url;
SELECT i FROM test1 ORDER BY i;
SELECT __spd_url FROM test1 ORDER BY __spd_url;
--
CREATE FOREIGN TABLE test2__pgspider_srv_1__test2 (t text, t2 text, i int,__spd_url text) SERVER pgspider_srv_1 OPTIONS (table_name 'test2');
SELECT * FROM test2__pgspider_srv_1__test2 ORDER BY i, t2, __spd_url;
SELECT * FROM test2 ORDER BY i, t, t2, __spd_url;
SELECT i, t, t2 FROM test2__pgspider_srv_1__test2 ORDER BY i, t2;
SELECT __spd_url FROM test2__pgspider_srv_1__test2 ORDER BY __spd_url;
SELECT i, t, t2 FROM test2 ORDER BY i, t2;
SELECT __spd_url FROM test2 ORDER BY __spd_url;
-- SELECT UNDER
SELECT * FROM test1 UNDER '/pgspider_srv_1pgspider_srv_2/' ORDER BY i;
SELECT * FROM test1 UNDER '/pgspider_srv_1pgspider_srv_2/' WHERE i<>0 ORDER BY i;
SELECT * FROM test2 UNDER '/pgspider_srv_2pgspider_srv_1/' ORDER BY i;
SELECT * FROM test2 UNDER '/pgspider_srv_2pgspider_srv_1/' WHERE i<>500 ORDER BY __spd_url;
SELECT * FROM test1 UNDER '/pgspider_srv_1/sqlite_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_1/sqlite_svr/' ORDER BY i;
SELECT * FROM test1 UNDER '/pgspider_srv_1/mysql_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_1/mysql_svr/' ORDER BY i;
SELECT * FROM test1 UNDER '/pgspider_srv_1/post_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_1/post_svr/' ORDER BY i;
--
SELECT * FROM test2 UNDER '/pgspider_srv_1/mysql_svr/' ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE __spd_url = '/pgspider_srv_1/mysql_svr/' ORDER BY i, t, t2, __spd_url;
--- PGSpider 2
CREATE SERVER pgspider_srv_2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_srv_2;
-- pgspider_core_fdw table
CREATE FOREIGN TABLE test1__pgspider_srv_2__test (i int,__spd_url text) SERVER pgspider_srv_2 OPTIONS (table_name 'test1');
SELECT * FROM test1__pgspider_srv_2__test ORDER BY i, __spd_url;
SELECT * FROM test1 ORDER BY i, __spd_url;
SELECT i FROM test1__pgspider_srv_2__test ORDER BY i;
SELECT __spd_url FROM test1__pgspider_srv_2__test ORDER BY __spd_url;
SELECT i FROM test1 ORDER BY i;
SELECT __spd_url FROM test1 ORDER BY __spd_url;
--
CREATE FOREIGN TABLE test2__pgspider_srv_2__test2 (t text,t2 text,i int,__spd_url text) SERVER pgspider_srv_2 OPTIONS (table_name 'test2');
SELECT * FROM test2__pgspider_srv_2__test2 ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 ORDER BY i, t, t2, __spd_url;
SELECT t, t2, i FROM test2__pgspider_srv_2__test2 ORDER BY i, t2;
SELECT __spd_url FROM test2__pgspider_srv_2__test2 ORDER BY __spd_url;
SELECT t, t2, i FROM test2 ORDER BY i, t2;
SELECT __spd_url FROM test2 ORDER BY __spd_url;
-- SELECT UNDER
SELECT * FROM test1 UNDER '/test1/' ORDER BY i;
SELECT * FROM test1 UNDER '/test1/' WHERE i>0 ORDER BY i;
SELECT * FROM test2 UNDER '/test2/' ORDER BY i;
SELECT * FROM test2 UNDER '/test2/' WHERE i<>500 ORDER BY __spd_url;
SELECT * FROM test1 UNDER '/pgspider_srv_2/influxdb_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_2/influxdb_svr/' ORDER BY i;
SELECT * FROM test1 UNDER '/pgspider_srv_2/griddb_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_2/griddb_svr/' ORDER BY i;
SELECT * FROM test1 UNDER '/pgspider_srv_2/file_svr/' ORDER BY i;
SELECT * FROM test1 WHERE __spd_url = '/pgspider_srv_2/file_svr/' ORDER BY i;
SELECT * FROM test2 UNDER '/pgspider_srv_2/influxdb_svr/' ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE __spd_url = '/pgspider_srv_2/influxdb_svr/' ORDER BY i, t, t2, __spd_url;
-- SELECT WHERE
SELECT * FROM test1 WHERE (i + 1000) = 1777 ORDER BY i, __spd_url;
SELECT * FROM test1 WHERE (i * 2) = 44444 ORDER BY i, __spd_url;
SELECT * FROM test1 WHERE i < 5 AND i > 0 ORDER BY i, __spd_url;
SELECT MAX(i) FROM test1 WHERE i < 2000;

SELECT t, i FROM test2 WHERE (i + 1000) = 1001 ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE (i * 2) = 4204 ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE i > 0 AND i <> 2103 ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE t = 'influx1a' ORDER BY i, t, t2, __spd_url;
SELECT * FROM test2 WHERE t2 IS NULL AND i < 1000 ORDER BY i, t, t2, __spd_url;
SELECT MAX(i) FROM test2 WHERE i < 2002;
-- DROP FOREIGN TABLE
DROP FOREIGN TABLE test1__pgspider_srv_2__test;
SELECT * FROM test1__pgspider_srv_2__test;
SELECT * FROM test1 ORDER BY i, __spd_url;
SELECT * FROM test1 WHERE i = 1 OR i = 777 ORDER BY i, __spd_url ;
DROP FOREIGN TABLE test1__pgspider_srv_1__test;
SELECT * FROM test1__pgspider_srv_1__test;
SELECT * FROM test1 ORDER BY i, __spd_url;
DROP FOREIGN TABLE test2__pgspider_srv_1__test2;
SELECT * FROM test2 ORDER BY i, t, t2, __spd_url;
DROP FOREIGN TABLE test2__pgspider_srv_2__test2;
SELECT * FROM test2 ORDER BY i, t, t2, __spd_url;
-- Clean up
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_srv_1;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_srv_2;
DROP FOREIGN TABLE test1;
DROP FOREIGN TABLE test2;
DROP SERVER pgspider_srv_1;
DROP SERVER pgspider_srv_2;
DROP SERVER pgspider_core_svr;
DROP EXTENSION pgspider_core_fdw;
DROP EXTENSION pgspider_fdw;