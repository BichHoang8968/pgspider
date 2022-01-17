\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1');
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE FOREIGN TABLE tbl01 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/sqlite_limit_orderby.db');
CREATE FOREIGN TABLE tbl01__sqlite_svr__0 (c1 character(30), c2 nchar(30), c3 varchar(255), c4 bigint, c5 float, c6 int, c7 character varying (255), c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER sqlite_svr OPTIONS (table 'tbl01');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__sqlite_svr__0;
DROP FOREIGN TABLE tbl01;
DROP SERVER sqlite_svr;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER pgspider_core_svr;
DROP EXTENSION sqlite_fdw;
DROP EXTENSION pgspider_core_fdw;
