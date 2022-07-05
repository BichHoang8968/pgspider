\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_CORE_HOST);
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION postgres_fdw;

CREATE FOREIGN TABLE J1_TBL ( i integer, j integer, t text, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J2_TBL ( i integer, k integer, __spd_url text) SERVER pgspider_core_svr;
CREATE FOREIGN TABLE J3_TBL ( i integer, t text, __spd_url text) SERVER pgspider_core_svr;
CREATE SERVER postgres_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_HOST_JOIN, port :POSTGRES_PORT_JOIN);
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_svr OPTIONS(user :POSTGRES_USER, password :POSTGRES_PASS);

CREATE FOREIGN TABLE J1_TBL__postgres_svr__0 ( i integer, j integer, t text) SERVER postgres_svr OPTIONS (table_name 'j1_tbl');
CREATE FOREIGN TABLE J2_TBL__postgres_svr__0 ( i integer, k integer) SERVER postgres_svr OPTIONS (table_name 'j2_tbl');
CREATE FOREIGN TABLE J3_TBL__postgres_svr__0 ( i integer, t text) SERVER postgres_svr OPTIONS (table_name 'j3_tbl');

\i sql/limit/join_limit.sql

DROP USER MAPPING FOR CURRENT_USER SERVER postgres_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER postgres_svr CASCADE;
DROP SERVER pgspider_core_svr CASCADE;
DROP EXTENSION postgres_fdw CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;