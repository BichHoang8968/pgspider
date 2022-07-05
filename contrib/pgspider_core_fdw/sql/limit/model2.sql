\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION influxdb_fdw;

CREATE FOREIGN TABLE tbl01 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER influx_svr FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (dbname 'limit_orderby_influx_single', host :INFLUX_HOST, port :INFLUX_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER influx_svr OPTIONS (USER :INFLUX_USER, PASSWORD :INFLUX_PASS);

CREATE FOREIGN TABLE tbl01__influx_svr__0 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER influx_svr OPTIONS (table 'tbl01');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__influx_svr__0;
DROP FOREIGN TABLE tbl01;
DROP USER MAPPING FOR CURRENT_USER SERVER influx_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER influx_svr;
DROP SERVER pgspider_core_svr;
DROP EXTENSION influxdb_fdw;
DROP EXTENSION pgspider_core_fdw;
