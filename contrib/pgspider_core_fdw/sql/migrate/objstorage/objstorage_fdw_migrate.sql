-- ===================================================================
-- create FDW objects
-- ===================================================================
-- Create FDW extensions
--Testcase 1:
CREATE EXTENSION pgspider_core_fdw;

--Testcase 2:
SET datestyle = ISO;
SET timezone = 'UTC';

--Testcase 3:
CREATE EXTENSION objstorage_fdw;
CREATE ROLE objstorage_fdw_ddl LOGIN SUPERUSER;
SET ROLE objstorage_fdw_ddl;

-- Source: init SERVER, USER MAPPING
--Testcase 4:
CREATE SERVER source_svr FOREIGN DATA WRAPPER objstorage_fdw :SERVER_OPTIONS;
--Testcase 5:
CREATE SERVER dest_svr FOREIGN DATA WRAPPER objstorage_fdw :SERVER_OPTIONS2;
--Testcase 6:
CREATE USER MAPPING FOR CURRENT_USER SERVER source_svr :USER_PASSWORD;
--Testcase 7:
CREATE USER MAPPING FOR CURRENT_USER SERVER dest_svr :USER_PASSWORD;

SELECT format($$
CREATE FUNCTION selector(c int, dirname text)
RETURNS TEXT AS
$func$
    SELECT dirname || '/new_file.%1$I';
$func$
LANGUAGE SQL
$$, :'FILE_FORMAT')\gexec

--------------------------- MIGRATE foreign table tests -----------------------

-- pre-condition: create foreign table for source table
--Testcase 8:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 9:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 10:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

--Testcase 11:
SELECT count(*) FROM ft1;

--Testcase 12:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

-- ===================================================================
-- MIGRATE without TO/REPLACE, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- Foreign table is created for source server.
--Testcase 13:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- OK when MIGRATE parquet_s3_fdw to parquet_s3_fdw, 'dirname' inherited from source table
-- OK when MIGRATE objstorage_fdw to objstorage_fdw in cloud, option inherited from source table. 
--Testcase 14:
MIGRATE TABLE ft1 SERVER dest_svr OPTIONS (:dest_foreigntable_opt);
-- Does not create new foreign table
--Testcase 15:
\det+

-- Validate new datasource:
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
-- create temp foreign table to check data of new table which in destination server
--Testcase 16:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

--Testcase 17:
SELECT * FROM tmp_ftbl ORDER BY c1 LIMIT 10;

--Testcase 18:
SELECT count(*) FROM tmp_ftbl; -- It should return 1000 rows

-- Insert more data to new datasource
--Testcase 19:
INSERT INTO tmp_ftbl
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 20:
SELECT count(*) FROM tmp_ftbl; -- It should return 1010 rows
--Testcase 21:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 22:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 23:
DROP FOREIGN TABLE tmp_ftbl;
--Testcase 24:
DROP DATASOURCE TABLE ft1;
--Testcase 25:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE without TO/REPLACE, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 26:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 27:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 28:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 29:
\det+

-- MIGRATE datasource
--Testcase 30:
MIGRATE TABLE ft1 SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- Does not create new foreign table
--Testcase 31:
\det+

-- Validate new datasource:
-- create temp foreign table to check data of new table which in destination server
--Testcase 32:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

--Testcase 33:
SELECT * FROM tmp_ftbl ORDER BY c1 LIMIT 10;

--Testcase 34:
SELECT count(*) FROM tmp_ftbl; -- It should return 1000 rows

-- Insert more data to new datasource
ALTER TABLE tmp_ftbl OPTIONS (insert_file_selector 'selector(c1 , dirname)');
--Testcase 35:
INSERT INTO tmp_ftbl
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 36:
SELECT count(*) FROM tmp_ftbl; -- It should return 1010 rows
--Testcase 37:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 38:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 39:
DROP FOREIGN TABLE tmp_ftbl;
--Testcase 40:
DROP DATASOURCE TABLE ft1;
--Testcase 41:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE REPLACE, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 42:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 43:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 44:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 45:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- OK when MIGRATE parquet_s3_fdw to parquet_s3_fdw, 'dirname' inherited from source table
-- OK when MIGRATE objstorage_fdw to objstorage_fdw in cloud, option inherited from source table. 
--Testcase 46:
MIGRATE TABLE ft1 REPLACE SERVER dest_svr;

-- foreign table of source server has been removed,
-- foreign table of destination server is created.
--Testcase 47:
\det+

-- Validate new datasource:
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
-- create temp foreign table to check data of source table which in source server
--Testcase 48:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

--Testcase 49:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 50:
SELECT count(*) FROM ft1; -- It should return: 1000 rows

-- Insert more data to new datasource
--Testcase 51:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 52:
SELECT count(*) FROM ft1; -- It should return 1010 rows
--Testcase 53:
SELECT count(*) FROM tmp_ftbl; -- It should return 1010 rows

-- Clean up datasources
--Testcase 54:
DROP DATASOURCE TABLE ft1;
--Testcase 55:
DROP FOREIGN TABLE ft1;
--Testcase 56:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 57:
DROP FOREIGN TABLE tmp_ftbl;

-- ===================================================================
-- MIGRATE REPLACE, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 58:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 59:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 60:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 61:
\det+

-- MIGRATE datasource
--Testcase 62:
MIGRATE TABLE ft1 REPLACE SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- foreign table of source server has been removed,
-- foreign table of destination server is created.
--Testcase 63:
\det+

-- Validate new datasource:
-- create temp foreign table to check data of source table which in source server
--Testcase 64:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

--Testcase 65:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 66:
SELECT count(*) FROM ft1; -- It should return: 1000 rows

-- Insert more data to new datasource
--Testcase 67:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 68:
SELECT count(*) FROM ft1; -- It should return 1010 rows
--Testcase 69:
SELECT count(*) FROM tmp_ftbl; -- It should return 1000 rows

-- Clean up datasources
--Testcase 70:
DROP DATASOURCE TABLE ft1;
--Testcase 71:
DROP FOREIGN TABLE ft1;
--Testcase 72:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 73:
DROP FOREIGN TABLE tmp_ftbl;

-- ===================================================================
-- MIGRATE TO, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 74:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 75:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 76:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 77:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- OK when MIGRATE parquet_s3_fdw to parquet_s3_fdw, 'dirname' inherited from source table
-- OK when MIGRATE objstorage_fdw to objstorage_fdw in cloud, option inherited from source table. 
--Testcase 78:
MIGRATE TABLE ft1 TO ft2 SERVER dest_svr;

-- foreign table of source server is kept
-- foreign table of destination server is created
--Testcase 79:
\det+

-- Validate new datasource
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
--Testcase 80:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 81:
SELECT count(*) FROM ft1; -- It should return 1000 rows
--Testcase 82:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 83:
SELECT count(*) FROM ft2; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 84:
INSERT INTO ft2
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 85:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 86:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 87:
DROP DATASOURCE TABLE ft1;
--Testcase 88:
DROP FOREIGN TABLE ft1;
--Testcase 89:
DROP DATASOURCE TABLE ft2;
--Testcase 90:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 91:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 92:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 93:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 94:
\det+

-- MIGRATE datasource
--Testcase 95:
MIGRATE TABLE ft1 TO ft2 SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- foreign table of source server is kept
-- foreign table of destination server is created
--Testcase 96:
\det+

-- Validate new datasource
--Testcase 97:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 98:
SELECT count(*) FROM ft1; -- It should return 1000 rows
--Testcase 99:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 100:
SELECT count(*) FROM ft2; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 101:
INSERT INTO ft2
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 102:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 103:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 104:
DROP DATASOURCE TABLE ft1;
--Testcase 105:
DROP FOREIGN TABLE ft1;
--Testcase 106:
DROP DATASOURCE TABLE ft2;
--Testcase 107:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================

-- pre-condition: create foreign table for source table
--Testcase 108:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 109:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 110:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 111:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- OK when MIGRATE parquet_s3_fdw to parquet_s3_fdw, 'dirname' inherited from source table
-- OK when MIGRATE objstorage_fdw to objstorage_fdw in cloud, option inherited from source table. 
--Testcase 112:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER dest_svr;

-- New 'new_pgspider_core_svr' is created
--Testcase 113:
\des+

-- foreign table of source server is kept
-- multi-tenant table of pgspider core server is created,
-- name of server is set by USE_MULTITENANT_SERVER option
-- Child node is created with name: ft2__dest_svr__0
--Testcase 114:
\det+

-- Validate new datasource
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
--Testcase 115:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;

--Testcase 116:
SELECT count(*) FROM ft1; -- It should return 1000 rows

--Testcase 117:
SELECT count(*) FROM ft2; -- It should return 1000 rows

--Testcase 118:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 119:
INSERT INTO ft2__dest_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 120:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return 1010 rows
--Testcase 121:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 122:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 123:
DROP DATASOURCE TABLE ft1;
--Testcase 124:
DROP FOREIGN TABLE ft1;
--Testcase 125:
DROP DATASOURCE TABLE ft2__dest_svr__0;
--Testcase 126:
DROP FOREIGN TABLE ft2__dest_svr__0;
--Testcase 127:
DROP FOREIGN TABLE ft2;
--Testcase 128:
DROP SERVER new_pgspider_core_svr CASCADE;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 129:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 130:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 131:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 132:
\det+

-- MIGRATE datasource
--Testcase 133:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- New 'new_pgspider_core_svr' is created
--Testcase 134:
\des+

-- foreign table of source server is kept
-- multi-tenant table of pgspider core server is created,
-- name of server is set by USE_MULTITENANT_SERVER option
-- Child node is created with name: ft2__dest_svr__0
--Testcase 135:
\det+

-- Validate new datasource
--Testcase 136:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;

--Testcase 137:
SELECT count(*) FROM ft1; -- It should return 1000 rows

--Testcase 138:
SELECT count(*) FROM ft2; -- It should return 1000 rows

--Testcase 139:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 140:
INSERT INTO ft2__dest_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 141:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return 1010 rows
--Testcase 142:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 143:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 144:
DROP DATASOURCE TABLE ft2__dest_svr__0;
--Testcase 145:
DROP FOREIGN TABLE ft2__dest_svr__0;
--Testcase 146:
DROP FOREIGN TABLE ft2;
--Testcase 147:
DROP DATASOURCE TABLE ft1;
--Testcase 148:
DROP FOREIGN TABLE ft1;
--Testcase 149:
DROP SERVER new_pgspider_core_svr CASCADE;

--------------------------- MIGRATE Single Layer Single Node tests ------------
--Testcase 150:
CREATE SERVER pgspider_core_srv FOREIGN DATA WRAPPER pgspider_core_fdw;
--Testcase 151:
CREATE USER MAPPING FOR public SERVER pgspider_core_srv;

-- pre-condition: create foreign tables for source table
-- Create source multi-tenant table
--Testcase 152:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 153:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 154:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 155:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

--Testcase 156:
SELECT count(*) FROM ft1__source_svr__0;

--Testcase 157:
SELECT * FROM ft1__source_svr__0 ORDER BY c1 LIMIT 10;

-- ===================================================================
-- MIGRATE without TO/REPLACE, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- Foreign table is created for source server.
--Testcase 158:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- Failed if dest_svr is objstorage_fdw in cloud, objstorage_fdw cannot create bucket or write permssion
--Testcase 159:
MIGRATE TABLE ft1 SERVER dest_svr;

-- Does not create new foreign table
--Testcase 160:
\det+

-- Validate new datasource:
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
-- When dest_svr is objstorage_fdw, this validation will not work correctly due to failed MIGRATE.
-- create temp foreign table to check data of new table which in destination server
--Testcase 161:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER dest_svr OPTIONS (:default_dest_foreigntable_opt);

-- New datasource has name of multitenant foreign table, use it for temporary foreign table to query
--Testcase 162:
ALTER FOREIGN TABLE tmp_ftbl OPTIONS (SET :tablename_opt 'ft1');

--Testcase 163:
\det+

--Testcase 164:
SELECT * FROM tmp_ftbl ORDER BY c1 LIMIT 10;
--Testcase 165:
SELECT count(*) FROM tmp_ftbl; -- It should return 1000 rows
--Testcase 166:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 167:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Insert more data to new datasource
--Testcase 168:
INSERT INTO tmp_ftbl
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 169:
SELECT count(*) FROM tmp_ftbl; -- It should return 1010 rows
--Testcase 170:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 171:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 172:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 173:
DROP FOREIGN TABLE ft1;
--Testcase 174:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 175:
DROP FOREIGN TABLE tmp_ftbl;

-- ===================================================================
-- MIGRATE without TO/REPLACE, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign tables for source table
-- Create source multi-tenant table
--Testcase 176:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 177:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 178:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 179:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 180:
\det+

-- MIGRATE datasource
--Testcase 181:
MIGRATE TABLE ft1 SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- Does not create new foreign table
--Testcase 182:
\det+

-- Validate new datasource:
-- create temp foreign table to check data of new table which in destination server
--Testcase 183:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

--Testcase 184:
\det+

--Testcase 185:
SELECT * FROM tmp_ftbl ORDER BY c1 LIMIT 10;
--Testcase 186:
SELECT count(*) FROM tmp_ftbl; -- It should return 1000 rows
--Testcase 187:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 188:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Insert more data to new datasource
--Testcase 189:
INSERT INTO tmp_ftbl
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 190:
SELECT count(*) FROM tmp_ftbl; -- It should return 1010 rows
--Testcase 191:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 192:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 193:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 194:
DROP FOREIGN TABLE ft1;
--Testcase 195:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 196:
DROP FOREIGN TABLE tmp_ftbl;

-- ===================================================================
-- MIGRATE REPLACE, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- pre-condition: create foreign tables for source table
-- Create source multi-tenant table
--Testcase 197:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 198:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 199:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 200:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 201:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- Failed if dest_svr is objstorage_fdw in cloud, objstorage_fdw cannot create bucket or write permssion
--Testcase 202:
MIGRATE TABLE ft1 REPLACE SERVER dest_svr;

-- foreign table of source server has been removed,
-- foreign table of destination server is created.
--Testcase 203:
\det+

-- Validate new datasource:
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
-- create temp foreign table to check data of source table which in source server
--Testcase 204:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

--Testcase 205:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 206:
SELECT count(*) FROM ft1; -- It should return: 1000 rows

-- Insert more data to new datasource
--Testcase 207:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 208:
SELECT count(*) FROM ft1; -- It should return 1010 rows

-- Clean up datasources
--Testcase 209:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 210:
DROP FOREIGN TABLE tmp_ftbl;
--Testcase 211:
DROP DATASOURCE TABLE ft1;
--Testcase 212:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE REPLACE, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create foreign tables for source table
-- Create source multi-tenant table
--Testcase 213:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 214:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 215:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 216:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 217:
\det+

-- MIGRATE datasource
--Testcase 218:
MIGRATE TABLE ft1 REPLACE SERVER dest_svr OPTIONS (:dest_foreigntable_opt);
-- foreign table of source server has been removed,
-- foreign table of destination server is created.
--Testcase 219:
\det+

-- Validate new datasource:
-- create temp foreign table to check data of source table which in source server
--Testcase 220:
CREATE FOREIGN TABLE tmp_ftbl (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

--Testcase 221:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;

--Testcase 222:
SELECT count(*) FROM ft1; -- It should return: 1000 rows

-- Insert more data to new datasource
--Testcase 223:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 224:
SELECT count(*) FROM ft1; -- It should return 1010 rows

-- Clean up datasources
--Testcase 225:
DROP DATASOURCE TABLE tmp_ftbl;
--Testcase 226:
DROP FOREIGN TABLE tmp_ftbl;
--Testcase 227:
DROP DATASOURCE TABLE ft1;
--Testcase 228:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE TO, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- pre-condition: create multitenant and foreign table for source table
--Testcase 229:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 230:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 231:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 232:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 233:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- Failed if dest_svr is objstorage_fdw in cloud, objstorage_fdw cannot create bucket or write permssion
--Testcase 234:
MIGRATE TABLE ft1 TO ft2 SERVER dest_svr;

-- foreign table of source server is kept
-- foreign table of destination server is created
--Testcase 235:
\det+

-- Validate new datasource
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
--Testcase 236:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 237:
SELECT count(*) FROM ft1; -- It should return 1000 rows
--Testcase 238:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 239:
SELECT count(*) FROM ft2; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 240:
INSERT INTO ft2
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 241:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 242:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 243:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 244:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 245:
DROP FOREIGN TABLE ft1;
--Testcase 246:
DROP DATASOURCE TABLE ft2;
--Testcase 247:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create multitenant and foreign table for source table
--Testcase 248:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 249:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 250:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 251:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 252:
\det+

-- MIGRATE datasource
--Testcase 253:
MIGRATE TABLE ft1 TO ft2 SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- foreign table of source server is kept
-- foreign table of destination server is created
--Testcase 254:
\det+

-- Validate new datasource
--Testcase 255:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 256:
SELECT count(*) FROM ft1; -- It should return 1000 rows
--Testcase 257:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 258:
SELECT count(*) FROM ft2; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 259:
INSERT INTO ft2
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 260:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 261:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 262:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 263:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 264:
DROP FOREIGN TABLE ft1;
--Testcase 265:
DROP DATASOURCE TABLE ft2;
--Testcase 266:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, single server without any SERVER OPTION
-- Can not MIGRATE data to mysql_fdw and parquet_s3_fdw without any OPTIONS.
--		- mysql_fdw requires 'dbname' option
--		- parquet_s3_fdw requires 'dirname' option
-- ===================================================================
-- pre-condition: create multitenant and foreign table for source table
--Testcase 267:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 268:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 269:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 270:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 271:
\det+

-- MIGRATE datasource
-- Failed if dest_svr is server of mysql_fdw or parquet_s3_fdw.
-- Failed if dest_svr is objstorage_fdw in cloud, objstorage_fdw cannot create bucket or write permssion
--Testcase 272:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER dest_svr;

-- New 'new_pgspider_core_svr' is created
--Testcase 273:
\des+

-- foreign table of source server is kept
-- multi-tenant table of pgspider core server is created,
-- name of server is set by USE_MULTITENANT_SERVER option
-- Create new ft2 multitenant
-- Child node is created with name: ft2__dest_svr__0
--Testcase 274:
\det+

-- Validate new datasource
-- When dest_svr is the server of mysql_fdw or parquet_s3_fdw, this validation will not work correctly due to failed MIGRATE.
--Testcase 275:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;

--Testcase 276:
SELECT count(*) FROM ft1; -- It should return 1000 rows

--Testcase 277:
SELECT count(*) FROM ft2; -- It should return 1000 rows

--Testcase 278:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 279:
INSERT INTO ft2__dest_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 280:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return 1010 rows
--Testcase 281:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 282:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 283:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 284:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 285:
DROP FOREIGN TABLE ft1;
--Testcase 286:
DROP DATASOURCE TABLE ft2__dest_svr__0;
--Testcase 287:
DROP FOREIGN TABLE ft2__dest_svr__0;
--Testcase 288:
DROP FOREIGN TABLE ft2;
--Testcase 289:
DROP SERVER new_pgspider_core_svr CASCADE;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, single server with SERVER OPTION
-- ===================================================================
-- pre-condition: create multitenant and foreign table for source table
--Testcase 290:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text,
	__spd_url text
) SERVER pgspider_core_srv;

--Testcase 291:
CREATE FOREIGN TABLE ft1__source_svr__0 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 292:
CREATE DATASOURCE TABLE ft1__source_svr__0;

-- Init data for source datasource
--Testcase 293:
INSERT INTO ft1__source_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- Foreign table is created for source server.
--Testcase 294:
\det+

-- MIGRATE datasource
--Testcase 295:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

-- New 'new_pgspider_core_svr' is created
--Testcase 296:
\des+

-- foreign table of source server is kept
-- multi-tenant table of pgspider core server is created,
-- name of server is set by USE_MULTITENANT_SERVER option
-- Create new ft2 multitenant
-- Child node is created with name: ft2__dest_svr__0
--Testcase 297:
\det+

-- Validate new datasource
--Testcase 298:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;

--Testcase 299:
SELECT count(*) FROM ft1; -- It should return 1000 rows

--Testcase 300:
SELECT count(*) FROM ft2; -- It should return 1000 rows

--Testcase 301:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return same as ft1: 1000 rows

-- Insert more data to new datasource
--Testcase 302:
INSERT INTO ft2__dest_svr__0
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       'f',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1000, 1009) id;

--Testcase 303:
SELECT count(*) FROM ft2__dest_svr__0; -- It should return 1010 rows
--Testcase 304:
SELECT count(*) FROM ft2; -- It should return 1010 rows
--Testcase 305:
SELECT count(*) FROM ft1; -- It should return 1000 rows

-- Clean up datasources
--Testcase 306:
DROP DATASOURCE TABLE ft2__dest_svr__0;
--Testcase 307:
DROP FOREIGN TABLE ft2__dest_svr__0;
--Testcase 308:
DROP FOREIGN TABLE ft2;
--Testcase 309:
DROP DATASOURCE TABLE ft1__source_svr__0;
--Testcase 310:
DROP FOREIGN TABLE ft1__source_svr__0;
--Testcase 311:
DROP FOREIGN TABLE ft1;
--Testcase 312:
DROP SERVER new_pgspider_core_svr CASCADE;

-- ===================================================================
-- MIGRATE to an existed table in destination: same name but different schema with source table
-- ===================================================================
-- pre-condition: create foreign table for source table
--Testcase 313:
CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 bool,
	c5 timestamptz,
	c6 double precision,
	c7 text,
	c8 text
) SERVER source_svr OPTIONS (:src_foreigntable_opt);

-- Create source datasource
--Testcase 314:
CREATE DATASOURCE TABLE ft1;

-- Init data for source datasource
--Testcase 315:
INSERT INTO ft1
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       't',
	       '1980-01-01'::timestamptz + ((id % 1000) || ' minute')::interval,
	       (id::double precision) / 3,
	       id % 10,
	       'foo'
	FROM generate_series(1, 1000) id;

-- pre-condition: create an existed table in destination: same name but different schema with source table
--Testcase 316:
CREATE FOREIGN TABLE existed_ft1 (
	c1 int NOT NULL,
	c2 bool,
	c3 double precision,
	c4 text
) SERVER dest_svr OPTIONS (:dest_foreigntable_opt);

--Testcase 317:
CREATE DATASOURCE TABLE existed_ft1;

--Testcase 318:
INSERT INTO existed_ft1
	SELECT id,
	       't',
	       (id::double precision) / 3,
	       id % 10
	FROM generate_series(1, 5) id;

--Testcase 319:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 320:
SELECT * FROM existed_ft1 ORDER BY c1 LIMIT 10;

-- list all foreign tables
--Testcase 321:
\det+

-- MIGRATE datasource
--Testcase 322:
MIGRATE TABLE ft1 TO ft2 SERVER dest_svr OPTIONS (:dest_foreigntable_opt); -- failed
--Testcase 323:
SELECT * FROM ft1 ORDER BY c1 LIMIT 10;
--Testcase 324:
SELECT * FROM ft2 ORDER BY c1 LIMIT 10;
--Testcase 325:
SELECT * FROM existed_ft1 ORDER BY c1 LIMIT 10;
-- list all foreign tables
--Testcase 326:
\det+

-- Clean up datasources
--Testcase 327:
DROP DATASOURCE TABLE ft2;
--Testcase 328:
DROP FOREIGN TABLE ft2;
--Testcase 329:
DROP DATASOURCE TABLE existed_ft1;
--Testcase 330:
DROP FOREIGN TABLE existed_ft1;
--Testcase 331:
DROP DATASOURCE TABLE ft1;
--Testcase 332:
DROP FOREIGN TABLE ft1;

--------------------------- End tests -----------------------------------------

DROP FUNCTION selector(int, text);
--Testcase 333:
DROP EXTENSION pgspider_core_fdw CASCADE;
--Testcase 334:
DROP EXTENSION objstorage_fdw CASCADE;
--Testcase 335:
DROP EXTENSION IF EXISTS objstorage_fdw CASCADE;
RESET ROLE;
DROP ROLE objstorage_fdw_ddl;
