\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION postgres_fdw;

CREATE FOREIGN TABLE tbl01 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER postgres_svr_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_HOST_1, port :POSTGRES_PORT_1);
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_svr_1 OPTIONS (user :POSTGRES_USER, password :POSTGRES_PASS);

CREATE SERVER postgres_svr_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_HOST_2, port :POSTGRES_PORT_2);
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_svr_2 OPTIONS (user :POSTGRES_USER, password :POSTGRES_PASS);

CREATE FOREIGN TABLE tbl01__postgres_svr_1__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER postgres_svr_1 OPTIONS (table_name 'tbl01');
CREATE FOREIGN TABLE tbl01__postgres_svr_2__0 (c1 text, c2 text, c3 char(255), c4 int, c5 float8, c6 int, c7 varchar(255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER postgres_svr_2 OPTIONS (table_name 'tbl01');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__postgres_svr_1__0;
DROP FOREIGN TABLE tbl01__postgres_svr_2__0;
DROP FOREIGN TABLE tbl01;
DROP USER MAPPING FOR CURRENT_USER SERVER postgres_svr_1;
DROP USER MAPPING FOR CURRENT_USER SERVER postgres_svr_2;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER postgres_svr_1;
DROP SERVER postgres_svr_2;
DROP SERVER pgspider_core_svr;
DROP EXTENSION postgres_fdw;
DROP EXTENSION pgspider_core_fdw;
