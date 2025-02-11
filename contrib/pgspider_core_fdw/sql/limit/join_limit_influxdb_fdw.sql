\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_CORE_HOST);
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION influxdb_fdw;

CREATE FOREIGN TABLE J1_TBL ( i integer, j integer, t text, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J2_TBL ( i integer, k integer, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J3_TBL ( i integer, t text, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER influx_svr FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (dbname 'join_limit', host :INFLUX_HOST, port :INFLUX_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER influx_svr OPTIONS (USER :INFLUX_USER, PASSWORD :INFLUX_PASS);

CREATE FOREIGN TABLE J1_TBL__influx_svr__0 ( i integer, j integer, t text) SERVER influx_svr OPTIONS (table 'J1_TBL');
CREATE FOREIGN TABLE J2_TBL__influx_svr__0 ( i integer, k integer) SERVER influx_svr OPTIONS (table 'J2_TBL');
CREATE FOREIGN TABLE J3_TBL__influx_svr__0 ( i integer, t text) SERVER influx_svr OPTIONS (table 'J3_TBL');

\i sql/limit/join_limit.sql

DROP USER MAPPING FOR CURRENT_USER SERVER influx_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER influx_svr CASCADE;
DROP SERVER pgspider_core_svr CASCADE;
DROP EXTENSION influxdb_fdw CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;