\set ECHO none
\ir sql/pgspidermodify/parameters.conf
\set ECHO all
--Testcase 1:
SET datestyle = ISO;
--Testcase 2:
SET timezone = 'UTC';

--Testcase 3:
DELETE FROM pg_spd_node_info;
--Testcase 4:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 5:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER1);
--Testcase 6:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
-- Extensions
--Testcase 7:
CREATE EXTENSION postgres_fdw;
--Testcase 8:
CREATE EXTENSION sqlite_fdw;
--Testcase 9:
CREATE EXTENSION tinybrace_fdw;
--Testcase 10:
CREATE EXTENSION mysql_fdw;
--Testcase 11:
CREATE EXTENSION oracle_fdw;
--Testcase 12:
CREATE EXTENSION odbc_fdw;
--Testcase 13:
CREATE EXTENSION jdbc_fdw;
--Testcase 14:
CREATE EXTENSION griddb_fdw;
--Testcase 15:
CREATE EXTENSION mongo_fdw;
--Testcase 16:
CREATE EXTENSION dynamodb_fdw;
--Testcase 17:
CREATE EXTENSION file_fdw;
-- Used data sources
-- Data sources
-- tntbl1: postgres_svr, mysql_svr, tiny_svr, oracle_svr, sqlite_svr
-- key: c1, c2
--Testcase 18:
CREATE SERVER postgres_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_SERVER, port :POSTGRES_PORT, dbname 'pg_modify_db');
--Testcase 19:
CREATE USER mapping for public SERVER postgres_svr OPTIONS(user :POSTGRES_USER, password :POSTGRES_PASS);
--Testcase 20:
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host :MYSQL_SERVER, port :MYSQL_PORT);
--Testcase 21:
CREATE USER mapping for public SERVER mysql_svr OPTIONS(username :MYSQL_USER, password :MYSQL_PASS);
--Testcase 22:
CREATE SERVER tiny_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host :TINYBRACE_SERVER, port :TINYBRACE_PORT, dbname 'pgmodifytest.db');
--Testcase 23:
CREATE USER mapping for public SERVER tiny_svr OPTIONS(username :TINYBRACE_USER, password :TINYBRACE_PASS);
--Testcase 24:
CREATE SERVER oracle_svr FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver :ORACLE_SERVER, isolation_level 'read_committed', nchar 'true');
--Testcase 25:
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_svr OPTIONS (user :ORACLE_USER, password :ORACLE_PASS);
--Testcase 26:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/pgmodifytest.db');
-- tntbl2: odbc_post_svr, jdbc_mysql_svr, griddb_svr, mongo_svr, dynamodb_svr
-- key: _id
--Testcase 27:
CREATE SERVER odbc_mysql_svr FOREIGN DATA WRAPPER odbc_fdw OPTIONS (odbc_DRIVER :ODBC_MYSQL_DRIVERNAME, odbc_SERVER :ODBC_SERVER, odbc_port :ODBC_MYSQL_PORT, odbc_DATABASE :ODBC_DATABASE);
--Testcase 28:
CREATE USER mapping for public SERVER odbc_mysql_svr OPTIONS(odbc_UID :ODBC_MYSQL_USER, odbc_PWD :ODBC_MYSQL_PASS);
--Testcase 29:
CREATE SERVER odbc_post_svr FOREIGN DATA WRAPPER odbc_fdw OPTIONS (odbc_DRIVER :ODBC_POSTGRES_DRIVERNAME, odbc_SERVER :ODBC_SERVER, odbc_port :ODBC_POSTGRES_PORT, odbc_DATABASE :ODBC_DATABASE);
--Testcase 30:
CREATE USER mapping for public SERVER odbc_post_svr OPTIONS(odbc_UID :ODBC_POSTGRES_USER, odbc_PWD :ODBC_POSTGRES_PASS);

--Testcase 31:
CREATE SERVER jdbc_mysql_svr FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
drivername :JDBC_MYSQL_DRIVERNAME,
url :JDBC_MYSQL_URL,
querytimeout '15',
jarfile :JDBC_MYSQL_DRIVERPATH,
maxheapsize '600'
);
--Testcase 32:
CREATE USER MAPPING FOR public SERVER jdbc_mysql_svr OPTIONS(username :JDBC_MYSQL_USER, password :JDBC_MYSQL_PASS);
--Testcase 33:
CREATE SERVER jdbc_post_svr FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
drivername :JDBC_POSTGRES_DRIVERNAME,
url :JDBC_POSTGRES_URL,
querytimeout '15',
jarfile :JDBC_POSTGRES_DRIVERPATH,
maxheapsize '600'
);
--Testcase 34:
CREATE USER MAPPING FOR public SERVER jdbc_post_svr OPTIONS(username :JDBC_POSTGRES_USER, password :JDBC_POSTGRES_PASS);

--Testcase 35:
CREATE SERVER griddb_svr FOREIGN DATA WRAPPER griddb_fdw OPTIONS (host :GRIDDB_HOST, port :GRIDDB_PORT, clustername 'griddbfdwTestCluster');
--Testcase 36:
CREATE USER MAPPING FOR public SERVER griddb_svr OPTIONS (username :GRIDDB_USER, password :GRIDDB_PASS);

-- --Testcase 37:
CREATE SERVER mongo_svr FOREIGN DATA WRAPPER mongo_fdw
  OPTIONS (address :MONGO_HOST, port :MONGO_PORT);
--Testcase 38:
CREATE USER MAPPING FOR public SERVER mongo_svr OPTIONS (username :MONGO_USER, password :MONGO_PASS);

--Testcase 39:
CREATE SERVER dynamodb_svr FOREIGN DATA WRAPPER dynamodb_fdw
  OPTIONS (endpoint :DYNAMODB_ENDPOINT1);
--Testcase 40:
CREATE USER MAPPING FOR public SERVER dynamodb_svr
  OPTIONS (user :DYNAMODB_USER, password :DYNAMODB_PASS);
--Testcase 41:
CREATE SERVER postgres_svr_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_1_SERVER, port :POSTGRES_1_PORT, dbname 'pg_modify_db');
--Testcase 42:
CREATE USER mapping for public SERVER postgres_svr_1 OPTIONS(user :POSTGRES_1_USER, password :POSTGRES_1_PASS);
-- tntbl3: postgres_svr, mysql_svr, tiny_svr, oracle_svr, sqlite_svr, odbc_mysql_svr, jdbc_post_svr, griddb_svr, mongo_svr, dynamodb_svr, postgres_svr_1
-- key: _id
--Testcase 43:
CREATE SERVER postgres_svr_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_2_SERVER, port :POSTGRES_2_PORT, dbname 'pg_modify_db');
--Testcase 44:
CREATE USER mapping for public SERVER postgres_svr_2 OPTIONS(user :POSTGRES_2_USER, password :POSTGRES_2_PASS);
-- tntbl4: postgres_svr, postgres_svr_2
-- key: c1
-- tntbl5: file_svr, file_svr_2
-- key: c1
--Testcase 45:
CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw;
--Testcase 46:
CREATE SERVER file_svr_2 FOREIGN DATA WRAPPER file_fdw;
-- Create multi tenant tables
-- tntbl1
--Testcase 47:
CREATE FOREIGN TABLE tntbl1 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255), __spd_url text) SERVER pgspider_svr;
-- tntbl2
--Testcase 48:
CREATE FOREIGN TABLE tntbl2 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_svr;
-- tntbl3
--Testcase 49:
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 real, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr;
-- tntbl4
--Testcase 50:
CREATE FOREIGN TABLE tntbl4 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval, __spd_url text) SERVER pgspider_svr;
-- tntbl5
--Testcase 51:
CREATE FOREIGN TABLE tntbl5 (c1 int, c2 text, __spd_url text) SERVER pgspider_svr;

-- Foreign tables
--Testcase 52:
CREATE FOREIGN TABLE tntbl1__postgres_svr__0 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER postgres_svr OPTIONS (table_name 'tntbl1');
--Testcase 53:
CREATE FOREIGN TABLE tntbl1__mysql_svr__0 (c1 int OPTIONS (key 'true'), c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER mysql_svr OPTIONS (dbname :MYSQL_DB_NAME1, table_name 'tntbl1');
--Testcase 54:
CREATE FOREIGN TABLE tntbl1__tiny_svr__0 (c1 int OPTIONS (key 'true'), c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER tiny_svr OPTIONS (table_name 'tntbl1');
--Testcase 55:
CREATE FOREIGN TABLE tntbl1__oracle_svr__0 (c1 int OPTIONS (key 'yes') NOT NULL, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER oracle_svr OPTIONS (table 'TNTBL1');
--Testcase 56:
CREATE FOREIGN TABLE tntbl1__sqlite_svr__0 (c1 int OPTIONS (key 'true'), c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER sqlite_svr OPTIONS (table 'tntbl1');

--Testcase 57:
CREATE FOREIGN TABLE tntbl2__odbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER odbc_post_svr OPTIONS (table 'tntbl2');
--Testcase 58:
CREATE FOREIGN TABLE tntbl2__jdbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER jdbc_mysql_svr OPTIONS (table_name 'tntbl2');
--Testcase 59:
CREATE FOREIGN TABLE tntbl2__mongo_svr__0 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER mongo_svr OPTIONS (database 'mongo_pg_modify', collection 'tntbl2');
--Testcase 60:
CREATE FOREIGN TABLE tntbl2__dynamodb_svr__0 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER dynamodb_svr OPTIONS (table_name 'tntbl2', partition_key '_id');
--Testcase 61:
CREATE FOREIGN TABLE tntbl2__griddb_svr__0 (_id text OPTIONS (rowkey 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER griddb_svr OPTIONS (table_name 'tntbl2');

--Testcase 62:
CREATE FOREIGN TABLE tntbl3__jdbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER jdbc_post_svr OPTIONS (table_name 'tntbl3');
--Testcase 63:
CREATE FOREIGN TABLE tntbl3__odbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER odbc_mysql_svr OPTIONS (schema :ODBC_DB_SCHEMA, table 'tntbl3');
--Testcase 64:
CREATE FOREIGN TABLE tntbl3__mongo_svr__0 (_id text, c1 int, c2 real, c3 double precision, c4 bigint) SERVER mongo_svr OPTIONS (database 'mongo_pg_modify', collection 'tntbl3');
--Testcase 65:
CREATE FOREIGN TABLE tntbl3__dynamodb_svr__0 (_id text, c1 int, c2 real, c3 double precision, c4 bigint) SERVER dynamodb_svr OPTIONS (table_name 'tntbl3', partition_key '_id');
--Testcase 66:
CREATE FOREIGN TABLE tntbl3__griddb_svr__0 (_id text OPTIONS (rowkey 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER griddb_svr OPTIONS (table_name 'tntbl3');
--Testcase 67:
CREATE FOREIGN TABLE tntbl3__postgres_svr__0 (_id text, c1 int, c2 real, c3 double precision, c4 bigint) SERVER postgres_svr OPTIONS (table_name 'tntbl3');
--Testcase 68:
CREATE FOREIGN TABLE tntbl3__mysql_svr__0 (_id text, c1 int, c2 real, c3 double precision, c4 bigint) SERVER mysql_svr OPTIONS (dbname :MYSQL_DB_NAME1, table_name 'tntbl3');
--Testcase 69:
CREATE FOREIGN TABLE tntbl3__tiny_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER tiny_svr OPTIONS (table_name 'tntbl3');
--Testcase 70:
CREATE FOREIGN TABLE tntbl3__oracle_svr__0 (_id text OPTIONS (key 'yes', column_name 'ID_ID') NOT NULL, c1 int, c2 real, c3 double precision, c4 bigint) SERVER oracle_svr OPTIONS (table 'TNTBL3');
--Testcase 71:
CREATE FOREIGN TABLE tntbl3__sqlite_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER sqlite_svr OPTIONS (table 'tntbl3');
--Testcase 72:
-- CREATE FOREIGN TABLE tntbl3__postgres_svr__1 (_id text, c1 int, c2 real, c3 double precision, c4 bigint) SERVER postgres_svr_1 OPTIONS (table_name 'tntbl3');

--Testcase 73:
CREATE FOREIGN TABLE tntbl4__postgres_svr__0 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval) SERVER postgres_svr OPTIONS (table_name 'tntbl4');
--Testcase 74:
CREATE FOREIGN TABLE tntbl4__postgres_svr_2__0 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval) SERVER postgres_svr_2 OPTIONS (table_name 'tntbl4');

--Testcase 75:
CREATE FOREIGN TABLE tntbl5__file_svr__0 (c1 int, c2 text) SERVER file_svr OPTIONS (filename '/tmp/pg_modify_file1.csv', format 'csv');
--Testcase 76:
CREATE FOREIGN TABLE tntbl5__file_svr__2 (c1 int, c2 text) SERVER file_svr_2 OPTIONS (filename '/tmp/pg_modify_file2.csv', format 'csv');

-- SELECT FROM table if there is any record
--Testcase 77:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 78:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 79:
Set pgspider_core_fdw.throw_error_ifdead to false;

SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;

Set pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 80:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 81:
SELECT * FROM tntbl5 ORDER BY 1, 2, 3;
--------------------------------------------------------------------------------
-- *** Start test for tntbl1 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 82:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (5, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 83:
INSERT INTO tntbl1 (c1, c2) VALUES (1, DEFAULT);
--Testcase 84:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (6, 5, DEFAULT);
--Testcase 85:
INSERT INTO tntbl1 VALUES (7, 6, 2.6, 5453.454, 5989, '2001-01-01 04:05:02');
--Testcase 86:
INSERT INTO tntbl1 VALUES (8, 7);

--Testcase 87:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 88:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (10, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 89:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (2, DEFAULT);
--Testcase 90:
INSERT INTO tntbl1 (c1, c2) VALUES (3, 2, 5);
--Testcase 91:
INSERT INTO tntbl1 (c1, c2) VALUES (11, DEFAULT, 6);

--Testcase 92:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- VALUES test
--
--Testcase 93:
INSERT INTO tntbl1 VALUES (10, 20, 3.0, 452.254, 599, '2037-01-19 03:14:07', '2004-10-19 10:23:54+02', '40', 'abc'), (-1, 2, DEFAULT, DEFAULT, 69845, '2004-10-19 10:23:54', '1972-01-01 00:00:01', 'Beera', 'John Does'),
    ((SELECT 2), (SELECT i FROM (VALUES(3)) as foo (i)), 4.0, 656.212, 5944, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', 'VALUES are fun!', 'foo');

--Testcase 94:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- TOASTed value test
--
--Testcase 95:
INSERT INTO tntbl1 VALUES (9, 9, 902.12, 9545.03, 3122, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', repeat('x', 25), repeat('a', 25));

--Testcase 96:
SELECT c1, c2, c3, c4, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature, this feature not work yet
--
--Testcase 97:
INSERT INTO tntbl1 IN ('/postgres_svr/') VALUES (-10, 20, 82.21, 213.12, 9565, '2003-10-19 10:23:54', '1971-01-01 00:00:01+07', 'One', 'OneOne'); 
--Testcase 98:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (650, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');

--
-- UPDATE
--
--Testcase 99:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--Testcase 100:
UPDATE tntbl1 SET c6 = DEFAULT, c4 = DEFAULT;
--Testcase 101:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
-- aliases for the UPDATE target table
--Testcase 102:
UPDATE tntbl1 AS t SET c1 = 10 WHERE t.c3 = 902.12;
--Testcase 103:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--Testcase 104:
UPDATE tntbl1 t SET c1 = t.c1 + 10 WHERE t.c3 = 3.0;
--Testcase 105:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--
-- Test VALUES in FROM
--

--Testcase 106:
UPDATE tntbl1 SET c1=v.i FROM (VALUES(20, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--Testcase 107:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, wrong data type:
--Testcase 108:
UPDATE tntbl1 SET c1 = v.* FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 109:
-- oracle_fdw issue skip/report
-- INSERT INTO tntbl1 SELECT c1+20, c2+50, c3 FROM tntbl1;
--Testcase 110:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

--Testcase 111:
UPDATE tntbl1 SET (c8,c1,c2) = ('bugle', c1+11, DEFAULT) WHERE c9 = 'foo';
--Testcase 112:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
--Testcase 113:
UPDATE tntbl1 SET (c9,c4) = ('car', c1+c3), c1 = c1 + 1 WHERE c5 = 3122;
--Testcase 114:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, multi assignment to same column:
--Testcase 115:
UPDATE tntbl1 SET (c9,c5) = ('car', c1+c5), c5 = c1 + 1 WHERE c2 = 20;

-- uncorrelated sub-SELECT:
--Testcase 116:
UPDATE tntbl1
  SET (c2,c3) = (SELECT c2,c3 FROM tntbl1 where c3 = 3 and c9 = 'abc')
  WHERE c2 = 6 AND c2 = 2.6;
--Testcase 117:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- correlated sub-SELECT:
--Testcase 118:
-- issue of pgspider_core_fdw, report/skip
-- UPDATE tntbl1 o
--   SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 i
--                where i.c4=o.c3 and i.c5=o.c5 and i.c5 is not distinct FROM o.c5);
--Testcase 119:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, multiple rows supplied:
--Testcase 120:
UPDATE tntbl1 SET (c2,c3) = (SELECT c3+1,c2 FROM tntbl1);
-- set to null if no rows supplied:
--Testcase 121:
UPDATE tntbl1 SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 where c5 = 1000)
  WHERE c5 = 11;
--Testcase 122:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- *-expansion should work in this context:
--Testcase 123:
UPDATE tntbl1 SET (c2,c3) = ROW(v.*) FROM (VALUES(2, 100)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 124:
UPDATE tntbl1 SET (c2,c3) = (v.*) FROM (VALUES(2, 101)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 125:
UPDATE tntbl1 AS t SET c2 = tntbl1.c2 + 10 WHERE t.c2 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 126:
UPDATE tntbl1 SET c9 = repeat('x', 25) WHERE c9 = 'car';
--Testcase 127:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 128:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
-- Crash issue/report
--Testcase 129:
-- UPDATE tntbl1 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 130:
SELECT c2, c3, c9 FROM tntbl1 order by 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 131:
UPDATE tntbl1 IN ('/tiny_svr/') SET c4 = 56563.1212;
--Testcase 132:
UPDATE tntbl1 IN ('/postgres_svr/', '/sqlite_svr/') SET c3 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 133:
DELETE FROM tntbl1 AS dt WHERE dt.c1 > 75;
-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 134:
DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 25;
--Testcase 135:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- delete a row with a TOASTed value
--Testcase 136:
DELETE FROM tntbl1 WHERE c2 > 2;
--Testcase 137:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- DELETE with IN feature
--
--Testcase 138:
DELETE FROM tntbl1 IN ('/oracle_svr/') WHERE c1 = 20;

SELECT * FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;
--Testcase 139:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 1000;

SELECT * FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;

-- *** Finish test for tntbl1 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl2 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 140:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 141:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 142:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 143:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 144:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 145:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 146:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 147:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 148:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 149:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 150:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

--
-- VALUES test
--
--Testcase 151:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 152:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

--
-- TOASTed value test
--
--Testcase 153:
INSERT INTO tntbl2 VALUES(repeat('a', 25), 30, repeat('x', 25), true, 512.0, 2000);

--Testcase 154:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3, 4;

--
-- INSERT with IN feature, this feature not work yet
--
--Testcase 155:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 156:
INSERT INTO tntbl2 IN ('/dynamodb_svr/', '/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 157:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 158:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 159:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 160:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 161:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 162:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 163:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--
-- Test VALUES in FROM
--

--Testcase 164:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 165:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

-- fail, wrong data type:
--Testcase 166:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 167:
INSERT INTO tntbl2 SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2;
--Testcase 168:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

--Bug of PGSpider master branch
-- --Testcase 169:
-- UPDATE tntbl2 SET (c2, c1, c3) = ('bugle', c1+11, DEFAULT) WHERE c3 = true;
--Testcase 170:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 171:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 172:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
-- fail, multi assignment to same column:
--Testcase 173:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 174:
UPDATE tntbl2
  SET (c2, c3) = (SELECT c2, c3 FROM tntbl2 where c1 = 5010)
  WHERE c5 = 1000 AND c1 = 1010;
--Testcase 175:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
-- correlated sub-SELECT:
--Testcase 176:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2 and char_length(i._id) = 24);
--Testcase 177:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5;
-- fail, multiple rows supplied:
--Testcase 178:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2);
-- set to null if no rows supplied:
--Testcase 179:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 180:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5;
-- *-expansion should work in this context:
--Testcase 181:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 182:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 183:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 184:
UPDATE tntbl2 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 185:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 186:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 187:
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 188:
SELECT c1, c5, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 189:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 56563.1212;
--Testcase 190:
UPDATE tntbl2 IN ('/odbc_post_svr/', '/jdbc_mysql_svr/') SET c4 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 191:
DELETE FROM tntbl2 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 192:
DELETE FROM tntbl2 dt WHERE tntbl2.c1 > 25;

--Testcase 193:
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 194:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 195:
SELECT c1, char_length(_id) FROM tntbl2 ORDER BY 1, 2;
--
-- DELETE with IN feature
--
--Testcase 196:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 197:
DELETE FROM tntbl2 IN ('/dynamodb_svr/', '/odbc_post_svr/', '/griddb_svr/') WHERE c5 = 4000;

-- *** Finish test for tntbl2 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl3 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 198:
Set pgspider_core_fdw.throw_error_ifdead to false;

INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('@', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 199:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 200:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('_4', DEFAULT, 5.0, DEFAULT);
--Testcase 201:
INSERT INTO tntbl3 VALUES ('test1', DEFAULT, 5.0, 600.0, 1000);
--Testcase 202:
INSERT INTO tntbl3 VALUES ('test2', DEFAULT, 7.0);

--Testcase 203:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 204:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong1', DEFAULT, DEFAULT);
--Testcase 205:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong2', 1, 2.0);
--Testcase 206:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong3', 1, 2);
--Testcase 207:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong4',DEFAULT, DEFAULT);

--Testcase 208:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;

--
-- VALUES test
--
--Testcase 209:
INSERT INTO tntbl3 VALUES('test11', 10, 2.0, 20.0, 2000), ('test22', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test33'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 210:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;

--
-- TOASTed value test
--
--Testcase 211:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 212:
SELECT c1, c2 FROM tntbl3 ORDER BY 1, 2;

--
-- INSERT with IN feature, this feature not work yet
--
--Testcase 213:
INSERT INTO tntbl3 IN ('/sqlite_svr/') VALUES ('_test', 10, 5.0, 50.0, 5000);
--Testcase 214:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);

--
-- UPDATE
--
--Testcase 215:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 216:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 217:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 218:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 219:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 220:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 221:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 222:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 223:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 224:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 225:
-- oracle_fdw issue skip/report
-- INSERT INTO tntbl3 SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3;
--Testcase 226:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 227:
UPDATE tntbl3 SET (c1, c2) = (c1 + 11, DEFAULT) WHERE c2 = 2.0;
--Testcase 228:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multi assignment to same column:
--Testcase 229:
UPDATE tntbl3 SET (c3) = (c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 230:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 231:
UPDATE tntbl3 SET (c2) = (c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 232:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'car1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 233:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
--Testcase 234:
-- Bug of pgspider_core_fdw / commented out
-- UPDATE tntbl3 o
--   SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
--                where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 235:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 236:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 237:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 238:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3, 4;
-- *-expansion should work in this context:
--Testcase 239:
UPDATE tntbl3 SET (c1, c3) = ROW(v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 240:
UPDATE tntbl3 SET (c1, c3) = (v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 241:
UPDATE tntbl3 AS t SET c1 = tntbl3.c1 + 10 WHERE t.c2 = 2.0;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 244:
-- Crash issue/report
-- EXPLAIN (VERBOSE, COSTS OFF)
-- UPDATE tntbl3 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 245:
-- UPDATE tntbl3 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 246:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 247:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56563.0;
--Testcase 248:
UPDATE tntbl3 IN ('/jdbc_post_svr/', '/odbc_mysql_svr/', '/oracle_svr/') SET c3 = 222.0;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 249:
DELETE FROM tntbl3 AS dt WHERE dt.c1 > 35;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 250:
DELETE FROM tntbl3 dt WHERE tntbl3.c1 > 25;

--Testcase 251:
SELECT c1, c3 FROM tntbl3 ORDER BY 1, 2;

-- delete a row with a TOASTed value
--Testcase 252:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 253:
SELECT c1, c3 FROM tntbl3 ORDER BY 1, 2;

--
-- DELETE with IN feature
--
--Testcase 254:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 255:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

Set pgspider_core_fdw.throw_error_ifdead to true;

-- *** Finish test for tntbl3 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl4 *** --
--
-- insert with DEFAULT in the target_list
--
--Testcase 256:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 257:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (3, DEFAULT, DEFAULT);
--Testcase 258:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (4, 'ANC#$', DEFAULT);
--Testcase 259:
INSERT INTO tntbl4 VALUES (5, DEFAULT, true, 10.0, 1000, 'char array', 'char varying', 100.0, 127, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '0001-01-01', '{ "customer": "John Does"}', '{"tags": ["tag1", "tag2"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '6 years 5 months 4 days 3 hours 2 minutes 1 second');
--Testcase 260:
INSERT INTO tntbl4 VALUES (6, 'test', false, DEFAULT, 2000, 'test', 'test', 200.0, 0);

--Testcase 261:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 262:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 263:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (1, 'ex');
--Testcase 264:
INSERT INTO tntbl4 (c1) VALUES (1, 2);
--Testcase 265:
INSERT INTO tntbl4 (c1) VALUES (DEFAULT, DEFAULT);

--Testcase 266:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 267:
INSERT INTO tntbl4 VALUES(1, '40', true, 2.0, 2000, 'value 1'), (-1, DEFAULT, true, 4.0, 4000, 'value 2'),
    ((SELECT 2), 'fun!', false, (SELECT i FROM (VALUES(3.0)) as foo (i)), 3000, 'VALUES are fun!');

--Testcase 268:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 269:
INSERT INTO tntbl4 VALUES(30, repeat('x', 25));

--Testcase 270:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature, this feature not work yet
--
--Testcase 271:
INSERT INTO tntbl4 IN ('/postgres_svr/') VALUES (12, '_test', true, 5.0, 5000);
--Testcase 272:
INSERT INTO tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') VALUES (13, '_infea', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 273:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--Testcase 274:
UPDATE tntbl4 SET c3 = DEFAULT, c6 = DEFAULT;

--Testcase 275:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 276:
UPDATE tntbl4 AS t SET c5 = 10000 WHERE t.c1 = 20;

--Testcase 277:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--Testcase 278:
UPDATE tntbl4 t SET c5 = t.c5 + 10 WHERE t.c1 = 20;

--Testcase 279:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 280:
UPDATE tntbl4 SET c1 = v.i FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--Testcase 281:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 282:
UPDATE tntbl4 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 283:
INSERT INTO tntbl4 SELECT c1 + 10, c2 || 'next', c3 != true FROM tntbl4 ;
--Testcase 284:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

--Testcase 285:
UPDATE tntbl4 SET (c2 , c1, c4) = ('bugle', c1 + 10, DEFAULT) WHERE c2 = 'fun!';
--Testcase 286:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
--Testcase 287:
UPDATE tntbl4 SET (c2, c5) = ('car', c1 + c5), c1 = c1 + 10 WHERE c1 = 30;
--Testcase 288:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
-- fail, multi assignment to same column:
--Testcase 289:
UPDATE tntbl4 SET (c6, c8) = ('car', c4 + c8), c8 = c4 + 1.0 WHERE c1 = 40;

-- uncorrelated sub-SELECT:
--Testcase 290:
UPDATE tntbl4
  SET (c9, c1) = (SELECT c1, c9 FROM tntbl4 where c1 = 40 and c2 = 'car')
  WHERE c5 = 1000 AND c4 = 2.0;
--Testcase 291:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;
-- correlated sub-SELECT:
--Testcase 292:
UPDATE tntbl4 o
  SET (c9, c4) = (SELECT c9+1, c4 FROM tntbl4 i
               where i.c9=o.c9 and i.c4=o.c4 and i.c1 is not distinct FROM o.c1);
--Testcase 293:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;
-- fail, multiple rows supplied:
--Testcase 294:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4);
-- set to null if no rows supplied:
--Testcase 295:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4 where c5 = 2000)
  WHERE c9 = 127;
--Testcase 296:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;
-- *-expansion should work in this context:
--Testcase 297:
UPDATE tntbl4 SET (c1, c9) = ROW(v.*) FROM (VALUES(20, 100)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 298:
UPDATE tntbl4 SET (c1, c9) = (v.*) FROM (VALUES(20, 101)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 299:
UPDATE tntbl4 AS t SET c9 = tntbl4.c9 + 10 WHERE t.c1 = 40;

-- Make sure that we can update to a TOASTed value.
--Testcase 300:
UPDATE tntbl4 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 301:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 302:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 303:
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 304:
SELECT c1, c5, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 305:
UPDATE tntbl4 IN ('/postgres_svr/') SET c8 = 56563.1212;
--Testcase 306:
UPDATE tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') SET c8 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 307:
DELETE FROM tntbl4 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 308:
DELETE FROM tntbl4 dt WHERE tntbl4.c1 > 45;

--Testcase 309:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 310:
DELETE FROM tntbl4 WHERE c1 > 25;

--Testcase 311:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

--
-- DELETE with IN feature
--
--Testcase 312:
DELETE FROM tntbl4 IN ('/postgres_svr/') WHERE c1 = 10;
--Testcase 313:
DELETE FROM tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/', '/griddb_svr/') WHERE c5 = 3000;

-- *** Finish test for tntbl4 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl5 *** --
-- This FDW does not support modification, the result will fail all over
--Testcase 314:
SELECT c1, c2 FROM tntbl5 ORDER BY 1, 2;
--Testcase 315:
INSERT INTO tntbl5 VALUES (DEFAULT, 'abc');
--Testcase 316:
INSERT INTO tntbl5 VALUES (1, 'foo');
--Testcase 317:
INSERT INTO tntbl5 IN ('/file_svr/') VALUES (2, 'zzzzz');
--Testcase 318:
UPDATE tntbl5 SET c2 = 'foo' WHERE c1 IS NULL;
--Testcase 319:
UPDATE tntbl5 IN ('/file_svr/', '/file_svr_2/') SET c2 = DEFAULT;
--Testcase 320:
DELETE FROM tntbl5 WHERE c2 = 'foo';
--Testcase 321:
DELETE FROM tntbl5 IN ('/file_svr/');
-- *** Finish test for tntbl5 *** --
-----------------------------------------------------------------------------------
--
-- Check behavior of disable_transaction_feature_check
--
--Testcase 322:
ALTER FOREIGN TABLE tntbl1 OPTIONS (disable_transaction_feature_check 'false');
--Testcase 323:
INSERT INTO tntbl1 VALUES (200, 70, 2.0, 200.0, 3000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', DEFAULT, 'abc', 'foo');
--Testcase 324:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 325:
INSERT INTO tntbl1 VALUES (100, 20, 3.0, 300.0, 4000, '2037-01-19 03:14:07', '2004-10-19 10:23:54+02', interval '2 months ago', '40', 'abc'), (-100, 30, DEFAULT, DEFAULT, 2000, '2004-10-19 10:23:54', '1972-01-01 00:00:00+07', interval '1 year 3 hours 20 minutes', 'Beera', 'John Does'),
    ((SELECT 300), (SELECT i FROM (VALUES(3)) as foo (i)), 400.212, 200.0, 5000, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', interval '1 year 2 months 3 days', 'VALUES are fun!', 'foo');

--Testcase 326:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 327:
INSERT INTO tntbl1 VALUES (900, 80, 6.0, 400.03, 6000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', interval '1 months ago', repeat('x', 10), repeat('a', 20));
--Testcase 328:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 329:
UPDATE tntbl1 SET c2 = 10.001 WHERE c1 = 100;
--Testcase 330:
DELETE FROM tntbl1 WHERE c1 > 100;
--Testcase 331:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 332:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (600, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');
--Testcase 333:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 334:
UPDATE tntbl1 IN ('/dynamodb_svr/') SET c4 = 60.0;
--Testcase 335:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 336:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 4000;
--Testcase 337:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
-- Reset value of disable_transaction_feature_check
ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');
--Testcase 338:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('121', 29, 'DEFAULT', true, 4.0, 4000);
--Testcase 339:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2', true);
--Testcase 340:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('xin3', 10, 'tst_in_feature', true, 5.0, 5000);
--Testcase 341:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 342:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 7000;
--Testcase 343:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 344:
DELETE FROM tntbl2 WHERE c2 = '2';
--Testcase 345:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 346:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 347:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 348:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_2', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 349:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_33', 3.0, DEFAULT);
--Testcase 350:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 351:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 352:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 353:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 354:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 355:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 356:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56.0;
--Testcase 357:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 358:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 359:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 360:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c3 = 56.0;
--Testcase 361:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;

--
--
-- Test with __spd_url
--
--Testcase 362:
DELETE FROM tntbl3 WHERE __spd_url = '/mongo_svr/';
--Testcase 363:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
--Testcase 364:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mysql_svr/', '/griddb_svr/') VALUES ('foo', 30, 5.0, 50.0, 6000);
--Testcase 365:
INSERT INTO tntbl3 SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 366:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 368:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 369:
DELETE FROM tntbl3;
--Testcase 370:
INSERT INTO tntbl3 SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 371:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--Testcase 372:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 373:
SELECT c1, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY c1 HAVING c1 IS NOT NULL LIMIT 5;
--Testcase 374:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/postgres_svr/');
--Testcase 375:
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
--
-- Test with optional options: tntbl1
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 376:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12);  -- duplicate key
--Testcase 377:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT DO NOTHING; -- works
--Testcase 378:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 379:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 562.3213; -- unsupported
--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 380:
CREATE VIEW rw_view AS SELECT * FROM tntbl1
  WHERE c1 < c2 WITH CHECK OPTION;
--Testcase 381:
\d+ rw_view
--Testcase 382:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (5, 0);
--Testcase 383:
INSERT INTO rw_view(c1, c2) VALUES (5, 0); -- should fail
--Testcase 384:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (0, 15);
--Testcase 385:
INSERT INTO rw_view(c1, c2) VALUES (0, 15); -- ok
--Testcase 386:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 387:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 100;
--Testcase 388:
UPDATE rw_view SET c1 = c1 + 100; -- should fail
--Testcase 389:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 390:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 391:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 392:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 393:
INSERT INTO tntbl1 VALUES (1, 2, 3.0, 6.0, 21, '2002-01-01 00:05:00', '2022-05-16 10:50:00+01', 'test1', 'test1') RETURNING *;
--Testcase 394:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5) VALUES (2, 3, 4.0, 5.0, 6) RETURNING c1, c4, c6;
--Testcase 395:
UPDATE tntbl1 SET c7 = '2100-01-01 10:00:00+01' WHERE c1 = 2 AND c2 = 3 RETURNING (tntbl1), *;
--Testcase 396:
DELETE FROM tntbl1 WHERE c4 = 6.0 RETURNING c1, c2;
--Testcase 397:
DELETE FROM tntbl1 RETURNING *;
--
-- Test with optional options: tntbl2
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 398:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12);  -- duplicate key
--Testcase 399:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 400:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 401:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 402:
CREATE VIEW rw_view AS SELECT * FROM tntbl2
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 403:
\d+ rw_view
--Testcase 404:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0);
--Testcase 405:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0); -- should fail
--Testcase 406:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000);
--Testcase 407:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000); -- ok
--Testcase 408:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 409:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 410:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 411:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 412:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 413:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 414:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 415:
INSERT INTO tntbl2 VALUES ('00:05:00', 20, '2022-05-16', false, 50.0, 7000) RETURNING *;
--Testcase 416:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('_key_', 30, 'test', true, 50.0, 8000) RETURNING c1, c4, c5;
--Testcase 417:
UPDATE tntbl2 SET c2 = '2100-01-01 10:00:00+01' WHERE c1 = 20 AND c3 = false RETURNING (tntbl2), *;
--Testcase 418:
DELETE FROM tntbl2 WHERE c4 = 50.0 RETURNING _id, c1, c2;
--Testcase 419:
DELETE FROM tntbl2 RETURNING *;
--
-- Test with optional options: tntbl3
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 420:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12);  -- duplicate key
--Testcase 421:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 422:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 423:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 424:
CREATE VIEW rw_view AS SELECT * FROM tntbl3
  WHERE c2 < c3 WITH CHECK OPTION;
--Testcase 425:
\d+ rw_view
--Testcase 426:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0);
--Testcase 427:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0); -- should fail
--Testcase 428:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000);
--Testcase 429:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000); -- ok
--Testcase 430:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 431:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 10000;
--Testcase 432:
UPDATE rw_view SET c2 = c2 + 10000; -- should fail
--Testcase 433:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 434:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 435:
SELECT c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 436:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 437:
INSERT INTO tntbl3 VALUES ('0000', 20, 5.0, 50.0, 5000) RETURNING *;
--Testcase 438:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_key_', 30, 4.0, 50.0, 6000) RETURNING c1, c2, c3;
--Testcase 439:
UPDATE tntbl3 SET c2 = 7.0 WHERE c1 = 20 AND c3 = 50.0 RETURNING (tntbl3), *;
--Testcase 440:
DELETE FROM tntbl3 WHERE c3 = 50.0 RETURNING _id, c1, c2;
--Testcase 441:
DELETE FROM tntbl3 RETURNING *;
--
-- Test with optional options: tntbl4
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 442:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$');  -- duplicate key
--Testcase 443:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT DO NOTHING; -- works
--Testcase 444:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 445:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO UPDATE SET c4 = 5.0; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 446:
CREATE VIEW rw_view AS SELECT * FROM tntbl4
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 447:
\d+ rw_view
--Testcase 448:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 0);
--Testcase 449:
INSERT INTO rw_view(c1, c5) VALUES (15, 0); -- should fail
--Testcase 450:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 3000);
--Testcase 451:
INSERT INTO rw_view(c1, c5) VALUES (15, 3000); -- ok
--Testcase 452:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 453:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 454:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 455:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 456:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 457:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 458:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 459:
INSERT INTO tntbl4 VALUES (70, '0000', true, 5.0, 5000) RETURNING *;
--Testcase 460:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5) VALUES (80, '_key_', false, 4.0, 6000) RETURNING c1, c2, c3;
--Testcase 461:
UPDATE tntbl4 SET c4 = 7.0 WHERE c1 = 70 AND c3 = true RETURNING (tntbl4), *;
--Testcase 462:
DELETE FROM tntbl4 WHERE c3 = true RETURNING c1, c2, c3;
--Testcase 463:
DELETE FROM tntbl4 RETURNING *;
--Clean
DELETE FROM tntbl1;
DELETE FROM tntbl2;
DELETE FROM tntbl3;
DELETE FROM tntbl4;
--Reset data
INSERT INTO tntbl1__oracle_svr__0 VALUES (-20, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2017-08-07 12:00:00+00', 'char array', 'varchar array');
INSERT INTO tntbl1__postgres_svr__0 VALUES (1, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2022-06-22 14:00:00+07', 'char array', 'varchar array');
INSERT INTO tntbl1__tiny_svr__0 VALUES (100, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2022-06-22 14:00:00+07', 'tiny array', 'tiny varchar array');
INSERT INTO tntbl1__sqlite_svr__0 VALUES (1000, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2022-06-22 14:00:00+07', 'sqlite char array', 'sqlite varchar array');
INSERT INTO tntbl2__mongo_svr__0 (c1, c2, c3, c4, c5) VALUES (1, 'foo', true, -1928.121, 1000);
INSERT INTO tntbl2__mongo_svr__0 (c1, c2, c3, c4, c5) VALUES (2, 'varchar', false, 2000.0, 2000);
INSERT INTO tntbl2__odbc_post_svr__0 VALUES ('odbc', 1, 'odbc text', true, 100.0, 10000);
INSERT INTO tntbl3__mongo_svr__0 (c1, c2) VALUES (1, -19.1);
INSERT INTO tntbl3__mongo_svr__0 (c1, c2) VALUES (2, 20.0);
INSERT INTO tntbl3__postgres_svr__0 VALUES ('text_post_id', 1, 1.0, 100.0, 1000);
INSERT INTO tntbl3__sqlite_svr__0 VALUES ('text_sqlite_id', 1, 1.0, 100.0, 1000);
INSERT INTO tntbl3__tiny_svr__0 VALUES ('text_tiny', 1, 1.0, 100.0, 1000);
INSERT INTO tntbl3__jdbc_post_svr__0 VALUES ('jdbc', 10, 10.0, 1000.0, 10000);
INSERT INTO tntbl4__postgres_svr__0 VALUES (10, 'text', true, 10.0, 1000, 'char array', 'varchar array', -1.0, 12, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '2001-01-01', '{"product": "test","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');
INSERT INTO tntbl4__postgres_svr_2__0 VALUES (20, 'texttext', false, -10.0, -1000, 'char array', 'varchar array', 1.0, 1, '2005-10-19 10:23:54', '2005-10-19 10:23:54+02', '2001-01-01', '{"product": "sample","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": false }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');
--Verify data
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
SELECT c1, c2, c3, c4, __spd_url FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;
SELECT * FROM tntbl5 ORDER BY 1, 2, 3;
--Testcase 464:
DROP FOREIGN TABLE tntbl1 CASCADE;
--Testcase 465:
DROP FOREIGN TABLE tntbl2 CASCADE;
--Testcase 466:
DROP FOREIGN TABLE tntbl3 CASCADE;
--Testcase 467:
DROP FOREIGN TABLE tntbl4 CASCADE;
--Testcase 468:
DROP FOREIGN TABLE tntbl5 CASCADE;
--Testcase 469:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 470:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 471:
DROP EXTENSION sqlite_fdw CASCADE;
--Testcase 472:
DROP EXTENSION tinybrace_fdw CASCADE;
--Testcase 473:
DROP EXTENSION griddb_fdw CASCADE;
--Testcase 474:
DROP EXTENSION oracle_fdw CASCADE;
--Testcase 475:
DROP EXTENSION odbc_fdw CASCADE;
--Testcase 476:
DROP EXTENSION jdbc_fdw CASCADE;
--Testcase 477:
DROP EXTENSION mysql_fdw CASCADE;
--Testcase 478:
DROP EXTENSION mongo_fdw CASCADE;
--Testcase 479:
DROP EXTENSION dynamodb_fdw CASCADE;
--Testcase 480:
DROP EXTENSION file_fdw CASCADE;
--Testcase 481:
DROP SERVER pgspider_svr CASCADE;
--Testcase 482:
DROP EXTENSION pgspider_core_fdw CASCADE;
