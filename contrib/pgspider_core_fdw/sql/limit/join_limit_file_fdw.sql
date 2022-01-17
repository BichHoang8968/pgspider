\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_CORE_HOST);
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION file_fdw;

CREATE FOREIGN TABLE J1_TBL ( i integer, j integer, t text, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J2_TBL ( i integer, k integer, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J3_TBL ( i integer, t text, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw ;
CREATE USER MAPPING FOR CURRENT_USER SERVER file_svr;

CREATE FOREIGN TABLE J1_TBL__file_svr__0 ( i integer, j integer, t text) SERVER file_svr OPTIONS (filename '/tmp/file_join_limit_1.csv', format 'csv', null 'null');
CREATE FOREIGN TABLE J2_TBL__file_svr__0 ( i integer, k integer) SERVER file_svr OPTIONS (filename '/tmp/file_join_limit_2.csv', format 'csv', null 'null');
CREATE FOREIGN TABLE J3_TBL__file_svr__0 ( i integer, t text) SERVER file_svr OPTIONS (filename '/tmp/file_join_limit_3.csv', format 'csv', null 'null');

\i sql/limit/join_limit.sql

DROP USER MAPPING FOR CURRENT_USER SERVER file_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER file_svr CASCADE;
DROP SERVER pgspider_core_svr CASCADE;
DROP EXTENSION file_fdw CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;