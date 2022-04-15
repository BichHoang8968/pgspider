\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_CORE_HOST);
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION mysql_fdw;

CREATE FOREIGN TABLE J1_TBL ( i integer, j integer, t text, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J2_TBL ( i integer, k integer, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J3_TBL ( i integer, t text, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host :MYSQL_HOST, port :MYSQL_PORT);
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_svr OPTIONS (username :MYSQL_USER_NAME, password :MYSQL_PASS);

CREATE FOREIGN TABLE J1_TBL__mysql_svr__0 ( i integer, j integer, t text) SERVER mysql_svr OPTIONS (dbname 'join_limit', table_name 'J1_TBL');
CREATE FOREIGN TABLE J2_TBL__mysql_svr__0 ( i integer, k integer) SERVER mysql_svr OPTIONS (dbname 'join_limit', table_name 'J2_TBL');
CREATE FOREIGN TABLE J3_TBL__mysql_svr__0 ( i integer, t text) SERVER mysql_svr OPTIONS (dbname 'join_limit', table_name 'J3_TBL');

\i sql/limit/join_limit.sql

DROP USER MAPPING FOR CURRENT_USER SERVER mysql_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER mysql_svr CASCADE;
DROP SERVER pgspider_core_svr CASCADE;
DROP EXTENSION mysql_fdw CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;