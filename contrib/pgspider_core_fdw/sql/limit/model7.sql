\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE FOREIGN TABLE tbl01 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE EXTENSION postgres_fdw;
CREATE SERVER postgres_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_HOST, port :POSTGRES_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_svr OPTIONS(user :POSTGRES_USER, password :POSTGRES_PASS);
CREATE FOREIGN TABLE tbl01__postgres_svr__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER postgres_svr OPTIONS (table_name 'tbl01');

CREATE EXTENSION file_fdw;
CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw ;
CREATE USER MAPPING FOR CURRENT_USER SERVER file_svr;
CREATE FOREIGN TABLE tbl01__file_svr__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER file_svr OPTIONS (filename '/tmp/file_fdw_multi.csv', format 'csv');

CREATE EXTENSION mysql_fdw;
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host :MYSQL_HOST, port :MYSQL_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_svr OPTIONS (username :MYSQL_USER_NAME, password :MYSQL_PASS);
CREATE FOREIGN TABLE tbl01__mysql_svr__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER mysql_svr OPTIONS (dbname 'limit_orderby', table_name 'tbl01');

CREATE EXTENSION influxdb_fdw;
CREATE SERVER influx_svr FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (dbname 'limit_orderby', host :INFLUX_HOST, port :INFLUX_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER influx_svr OPTIONS (USER :INFLUX_USER, PASSWORD :INFLUX_PASS);
CREATE FOREIGN TABLE tbl01__influx_svr__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER influx_svr OPTIONS (table 'tbl01');

CREATE EXTENSION tinybrace_fdw;
CREATE SERVER tinybrace_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host :TINYBRACE_HOST, port :TINYBRACE_PORT, dbname 'limit_orderby.db');
CREATE USER MAPPING FOR CURRENT_USER SERVER tinybrace_svr OPTIONS (username :TINYBRACE_USER, password :TINYBRACE_PASS);
CREATE FOREIGN TABLE tbl01__tinybrace_svr__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER tinybrace_svr OPTIONS (table_name 'tbl01');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__postgres_svr__0;
DROP FOREIGN TABLE tbl01__file_svr__0;
DROP FOREIGN TABLE tbl01__mysql_svr__0;
DROP FOREIGN TABLE tbl01__influx_svr__0;
DROP FOREIGN TABLE tbl01__tinybrace_svr__0;
DROP FOREIGN TABLE tbl01;
DROP USER MAPPING FOR CURRENT_USER SERVER postgres_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER file_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER mysql_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER influx_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER tinybrace_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER postgres_svr;
DROP SERVER file_svr;
DROP SERVER mysql_svr;
DROP SERVER influx_svr;
DROP SERVER tinybrace_svr;
DROP SERVER pgspider_core_svr;
DROP EXTENSION postgres_fdw;
DROP EXTENSION file_fdw;
DROP EXTENSION mysql_fdw;
DROP EXTENSION influxdb_fdw;
DROP EXTENSION tinybrace_fdw;
DROP EXTENSION pgspider_core_fdw;
