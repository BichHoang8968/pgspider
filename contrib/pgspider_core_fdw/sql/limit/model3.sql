\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION file_fdw;

CREATE FOREIGN TABLE tbl01 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw ;
CREATE USER MAPPING FOR CURRENT_USER SERVER file_svr;

CREATE FOREIGN TABLE tbl01__file_svr__0 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER file_svr OPTIONS (filename '/tmp/file_fdw_single.csv', format 'csv');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__file_svr__0;
DROP FOREIGN TABLE tbl01;
DROP USER MAPPING FOR CURRENT_USER SERVER file_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER file_svr;
DROP SERVER pgspider_core_svr;
DROP EXTENSION file_fdw;
DROP EXTENSION pgspider_core_fdw;
