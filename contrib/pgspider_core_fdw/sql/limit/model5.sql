\set ECHO none
\ir sql/limit/parameters.conf
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw;
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
CREATE EXTENSION griddb_fdw;

CREATE FOREIGN TABLE tbl01 (c1 text, c2 text, c3 text, c4 int, c5 real, c6 smallint, c7 text, c8 bigint, c9 double precision, c10 smallint, c11 timestamp, __spd_url text) SERVER pgspider_core_svr;

CREATE SERVER griddb_svr_1 FOREIGN DATA WRAPPER griddb_fdw OPTIONS (notification_member :GRIDDB_NOTI_MEMBER_2, clustername :GRIDDB_CLUSTER_NAME);
CREATE USER MAPPING FOR CURRENT_USER SERVER griddb_svr_1 OPTIONS (username :GRIDDB_USER, password :GRIDDB_PASS);

CREATE SERVER griddb_svr_2 FOREIGN DATA WRAPPER griddb_fdw OPTIONS (notification_member :GRIDDB_NOTI_MEMBER_3, clustername :GRIDDB_CLUSTER_NAME);
CREATE USER MAPPING FOR CURRENT_USER SERVER griddb_svr_2 OPTIONS (username :GRIDDB_USER, password :GRIDDB_PASS);

CREATE FOREIGN TABLE tbl01__griddb_svr_1__0 (c1 text, c2 text, c3 text, c4 int, c5 real, c6 smallint, c7 text, c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER griddb_svr_1 OPTIONS (table_name 'tbl01');
CREATE FOREIGN TABLE tbl01__griddb_svr_2__0 (c1 text, c2 text, c3 text, c4 int, c5 real, c6 smallint, c7 text, c8 bigint, c9 double precision, c10 smallint, c11 timestamp) SERVER griddb_svr_2 OPTIONS (table_name 'tbl01');

\i sql/limit/limit_orderby.sql

DROP FOREIGN TABLE tbl01__griddb_svr_1__0;
DROP FOREIGN TABLE tbl01__griddb_svr_2__0;
DROP FOREIGN TABLE tbl01;
DROP USER MAPPING FOR CURRENT_USER SERVER griddb_svr_1;
DROP USER MAPPING FOR CURRENT_USER SERVER griddb_svr_2;
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
DROP SERVER griddb_svr_1;
DROP SERVER griddb_svr_2;
DROP SERVER pgspider_core_svr;
DROP EXTENSION griddb_fdw;
DROP EXTENSION pgspider_core_fdw;
