-- ===================================================================
-- create FDW objects
-- ===================================================================
-- create extension
--Testcase 1:
CREATE EXTENSION postgres_fdw;
--Testcase 2:
CREATE EXTENSION griddb_fdw;
--Testcase 3:
CREATE EXTENSION influxdb_fdw;
--Testcase 4:
CREATE EXTENSION oracle_fdw;
--Testcase 5:
CREATE EXTENSION mysql_fdw;
--Testcase 6:
CREATE EXTENSION parquet_s3_fdw;
--Testcase 7:
CREATE EXTENSION pgspider_core_fdw;

-- create servers, user mapping
--Testcase 8:
CREATE SERVER pgspider_core_srv FOREIGN DATA WRAPPER pgspider_core_fdw;
--Testcase 9:
CREATE USER MAPPING FOR public SERVER pgspider_core_srv;

--Testcase 10:
CREATE SERVER postgres_src_srv FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '15432', dbname 'sourcedb');
--Testcase 11:
CREATE SERVER postgres_dest_srv FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',  port '15432', dbname 'destdb');
--Testcase 12:
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_src_srv OPTIONS (user 'postgres', password 'postgres');
--Testcase 13:
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_dest_srv OPTIONS (user 'postgres', password 'postgres');

--Testcase 14:
CREATE SERVER griddb_src_srv FOREIGN DATA WRAPPER griddb_fdw OPTIONS (notification_member '127.0.0.1:10003', clustername 'dockerGridDB');
--Testcase 15:
CREATE SERVER griddb_dest_srv FOREIGN DATA WRAPPER griddb_fdw OPTIONS (notification_member '127.0.0.1:10003', clustername 'dockerGridDB');
--Testcase 16:
CREATE USER MAPPING FOR CURRENT_USER SERVER griddb_src_srv OPTIONS (username 'admin', password 'admin');
--Testcase 17:
CREATE USER MAPPING FOR CURRENT_USER SERVER griddb_dest_srv OPTIONS (username 'admin', password 'admin');

--Testcase 18:
CREATE SERVER influxdb_src_srv FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '8086', dbname 'sourcedb');
--Testcase 19:
CREATE SERVER influxdb_dest_srv FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (host 'http://localhost', port '8086', dbname 'destdb');
--Testcase 20:
CREATE USER MAPPING FOR CURRENT_USER SERVER influxdb_src_srv OPTIONS (user 'user', password 'pass');
--Testcase 21:
CREATE USER MAPPING FOR CURRENT_USER SERVER influxdb_dest_srv OPTIONS (user 'user', password 'pass');

--Testcase 22:
CREATE SERVER oracle_src_srv FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '', isolation_level 'read_committed', nchar 'true');
--Testcase 23:
CREATE SERVER oracle_dest_srv FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '', isolation_level 'read_committed', nchar 'true');
--Testcase 24:
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_src_srv OPTIONS (user 'source_user', password 'source_user');
--Testcase 25:
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_dest_srv OPTIONS (user 'dest_user', password 'dest_user');

--Testcase 26:
CREATE SERVER mysql_src_srv FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host 'localhost', port '3306');
--Testcase 27:
CREATE SERVER mysql_dest_srv FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host 'localhost',  port '3306');
--Testcase 28:
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_src_srv OPTIONS(username 'root', password 'Mysql_1234');
--Testcase 29:
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_dest_srv OPTIONS(username 'root', password 'Mysql_1234');

--Testcase 30:
CREATE SERVER parquet_s3_src_srv FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'true', endpoint '127.0.0.1:9000');
--Testcase 31:
CREATE SERVER parquet_s3_dest_srv FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'true', endpoint '127.0.0.1:9000');
--Testcase 32:
CREATE USER MAPPING FOR CURRENT_USER SERVER parquet_s3_src_srv OPTIONS (user 'minioadmin', password 'minioadmin');
--Testcase 33:
CREATE USER MAPPING FOR CURRENT_USER SERVER parquet_s3_dest_srv OPTIONS (user 'minioadmin', password 'minioadmin');

-- ===================================================================
-- MIGRATE without TO/REPLACE, multi servers without SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 34:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 35:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 36:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 37:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 38:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 39:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

-- pre-condition: create foreign table for parquet_s3
--Testcase 40:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 41:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 42:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 43:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 44:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 45:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 46:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 47:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 48:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 49:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 50:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 51:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 52:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- Foreign tables are created for source server.
--Testcase 53:
\det+

-- show data in source server
--Testcase 54:
SELECT * FROM ft1 ORDER BY c1;

-- MIGRATE data source from source server to destination server
-- ERROR: mysql_fdw and parquet_s3_fdw can not run without required option.
--Testcase 55:
MIGRATE TABLE ft1 SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv,
    mysql_dest_srv,
    parquet_s3_dest_srv;

-- OK
--Testcase 56:
MIGRATE TABLE ft1 SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv;

-- Does not create new foreign tables
--Testcase 57:
\det+

-- create temp foreign table to check data of new table which in destication server
--Testcase 58:
CREATE FOREIGN TABLE tmptbl_postgres (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_dest_srv OPTIONS (table_name 'ft1');

--Testcase 59:
CREATE FOREIGN TABLE tmptbl_griddb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_dest_srv OPTIONS (table_name 'ft1');

--Testcase 60:
CREATE FOREIGN TABLE tmptbl_influxdb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_dest_srv OPTIONS (table 'ft1');

--Testcase 61:
CREATE FOREIGN TABLE tmptbl_oracle (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_dest_srv OPTIONS (table 'ft1');

-- select data in destination servers
--Testcase 62:
SELECT count(*) FROM tmptbl_postgres;
--Testcase 63:
SELECT count(*) FROM tmptbl_griddb;
--Testcase 64:
SELECT count(*) FROM tmptbl_influxdb;
--Testcase 65:
SELECT count(*) FROM tmptbl_oracle;

-- record in destination server can be different by each execution time, but total record is the same
-- therefore with MIGRATE without TO/REPLACE, we create a multi-tenant table
-- to check total record of all destination servers
--Testcase 66:
CREATE FOREIGN TABLE ft1_dest (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- create child node for postgres
--Testcase 67:
CREATE FOREIGN TABLE ft1_dest__postgres_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_dest_srv OPTIONS (table_name 'ft1');

-- create child node for griddb
--Testcase 68:
CREATE FOREIGN TABLE ft1_dest__griddb_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_dest_srv OPTIONS (table_name 'ft1');

-- create child node for influxdb
--Testcase 69:
CREATE FOREIGN TABLE ft1_dest__influxdb_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_dest_srv OPTIONS (table 'ft1');

-- create child node for oracle
--Testcase 70:
CREATE FOREIGN TABLE ft1_dest__oracle_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_dest_srv OPTIONS (table 'ft1');

-- select data of all destination server by multi-tenant table
-- check total number of record
--Testcase 71:
SELECT * FROM ft1_dest ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 72:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 73:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 74:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 75:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 76:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 77:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 78:
DROP DATASOURCE TABLE tmptbl_postgres;
--Testcase 79:
DROP DATASOURCE TABLE tmptbl_griddb;
--Testcase 80:
DROP DATASOURCE TABLE tmptbl_influxdb;
--Testcase 81:
DROP DATASOURCE TABLE tmptbl_oracle;

-- clean up table in pgspider
--Testcase 82:
DROP FOREIGN TABLE tmptbl_postgres;
--Testcase 83:
DROP FOREIGN TABLE tmptbl_griddb;
--Testcase 84:
DROP FOREIGN TABLE tmptbl_influxdb;
--Testcase 85:
DROP FOREIGN TABLE tmptbl_oracle;
--Testcase 86:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 87:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 88:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 89:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 90:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 91:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 92:
DROP FOREIGN TABLE ft1;
--Testcase 93:
DROP FOREIGN TABLE ft1_dest__postgres_dest_srv__0;
--Testcase 94:
DROP FOREIGN TABLE ft1_dest__griddb_dest_srv__0;
--Testcase 95:
DROP FOREIGN TABLE ft1_dest__influxdb_dest_srv__0;
--Testcase 96:
DROP FOREIGN TABLE ft1_dest__oracle_dest_srv__0;
--Testcase 97:
DROP FOREIGN TABLE ft1_dest;

-- ===================================================================
-- MIGRATE without TO/REPLACE, multi servers with SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 98:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 99:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 100:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 101:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 102:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 103:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 104:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 105:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 106:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 107:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 108:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 109:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 110:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 111:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 112:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 113:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 114:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 115:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 116:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- Foreign tables are created for source server.
--Testcase 117:
\det+

-- show data in source server
--Testcase 118:
SELECT * FROM ft1 ORDER BY c1;

-- MIGRATE data source from source server to destination server
--Testcase 119:
MIGRATE TABLE ft1 SERVER
    postgres_dest_srv OPTIONS (table_name 'TBL2'),
    griddb_dest_srv OPTIONS (table_name 'TBL2'),
    influxdb_dest_srv OPTIONS (table 'TBL2'),
    oracle_dest_srv OPTIONS (table 'TBL2'),
    mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2'),
    parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- Does not create new foreign tables
--Testcase 120:
\det+

-- create temp foreign table to check data of new table which in destication server
--Testcase 121:
CREATE FOREIGN TABLE tmptbl_postgres (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_dest_srv OPTIONS (table_name 'TBL2');

--Testcase 122:
CREATE FOREIGN TABLE tmptbl_griddb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_dest_srv OPTIONS (table_name 'TBL2');

--Testcase 123:
CREATE FOREIGN TABLE tmptbl_influxdb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_dest_srv OPTIONS (table 'TBL2');

--Testcase 124:
CREATE FOREIGN TABLE tmptbl_oracle (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_dest_srv OPTIONS (table 'TBL2');

--Testcase 125:
CREATE FOREIGN TABLE tmptbl_mysql (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2');

--Testcase 126:
CREATE FOREIGN TABLE tmptbl_parquet_s3 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- select data in destination servers
--Testcase 127:
SELECT count(*) FROM tmptbl_postgres;
--Testcase 128:
SELECT count(*) FROM tmptbl_griddb;
--Testcase 129:
SELECT count(*) FROM tmptbl_influxdb;
--Testcase 130:
SELECT count(*) FROM tmptbl_oracle;
--Testcase 131:
SELECT count(*) FROM tmptbl_mysql;
--Testcase 132:
SELECT count(*) FROM tmptbl_parquet_s3;

-- record in destination server can be different by each execution time, but total record is the same
-- therefore with MIGRATE without TO/REPLACE, we create a multi-tenant table
-- to check total record of all destination servers
--Testcase 133:
CREATE FOREIGN TABLE tbl2_dest (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- create child node for postgres
--Testcase 134:
CREATE FOREIGN TABLE tbl2_dest__postgres_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_dest_srv OPTIONS (table_name 'TBL2');

-- create child node for griddb
--Testcase 135:
CREATE FOREIGN TABLE tbl2_dest__griddb_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_dest_srv OPTIONS (table_name 'TBL2');

-- create child node for influxdb
--Testcase 136:
CREATE FOREIGN TABLE tbl2_dest__influxdb_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_dest_srv OPTIONS (table 'TBL2');

-- create child node for oracle
--Testcase 137:
CREATE FOREIGN TABLE tbl2_dest__oracle_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_dest_srv OPTIONS (table 'TBL2');

-- create child node for mysql
--Testcase 138:
CREATE FOREIGN TABLE tbl2_dest__mysql_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2');

-- create child node for parquet
--Testcase 139:
CREATE FOREIGN TABLE tbl2_dest__parquet_s3_dest_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- select data of all destination server by multi-tenant table
-- check total number of record
--Testcase 140:
SELECT * FROM tbl2_dest ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 141:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 142:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 143:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 144:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 145:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 146:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 147:
DROP DATASOURCE TABLE tmptbl_postgres;
--Testcase 148:
DROP DATASOURCE TABLE tmptbl_griddb;
--Testcase 149:
DROP DATASOURCE TABLE tmptbl_influxdb;
--Testcase 150:
DROP DATASOURCE TABLE tmptbl_oracle;
--Testcase 151:
DROP DATASOURCE TABLE tmptbl_mysql;
--Testcase 152:
DROP DATASOURCE TABLE tmptbl_parquet_s3;

-- clean up table in pgspider
--Testcase 153:
DROP FOREIGN TABLE tmptbl_postgres;
--Testcase 154:
DROP FOREIGN TABLE tmptbl_griddb;
--Testcase 155:
DROP FOREIGN TABLE tmptbl_influxdb;
--Testcase 156:
DROP FOREIGN TABLE tmptbl_oracle;
--Testcase 157:
DROP FOREIGN TABLE tmptbl_mysql;
--Testcase 158:
DROP FOREIGN TABLE tmptbl_parquet_s3;
--Testcase 159:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 160:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 161:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 162:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 163:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 164:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 165:
DROP FOREIGN TABLE ft1;
--Testcase 166:
DROP FOREIGN TABLE tbl2_dest__postgres_dest_srv__0;
--Testcase 167:
DROP FOREIGN TABLE tbl2_dest__griddb_dest_srv__0;
--Testcase 168:
DROP FOREIGN TABLE tbl2_dest__influxdb_dest_srv__0;
--Testcase 169:
DROP FOREIGN TABLE tbl2_dest__oracle_dest_srv__0;
--Testcase 170:
DROP FOREIGN TABLE tbl2_dest__mysql_dest_srv__0;
--Testcase 171:
DROP FOREIGN TABLE tbl2_dest__parquet_s3_dest_srv__0;
--Testcase 172:
DROP FOREIGN TABLE tbl2_dest;

-- ===================================================================
-- MIGRATE REPLACE, multi servers without SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 173:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 174:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 175:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 176:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 177:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 178:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 179:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 180:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 181:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 182:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 183:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 184:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 185:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 186:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 187:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 188:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 189:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 190:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 191:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 192:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE REPLACE
--Testcase 193:
\det+

-- MIGRATE data source from source server to destination server
-- ERROR: mysql_fdw and parquet_s3_fdw can not run without required option.
--Testcase 194:
MIGRATE TABLE ft1 REPLACE SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv,
    mysql_dest_srv,
    parquet_s3_dest_srv;

-- OK
--Testcase 195:
MIGRATE TABLE ft1 REPLACE SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv;
-- list up all table after MIGRATE REPLACE
-- foreign tables of source server has been remove
-- foreign tables of destination server has been created
--Testcase 196:
\det+

-- create temp foreign table to check data of source table which in source server
--Testcase 197:
CREATE FOREIGN TABLE tmptbl_postgres (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

--Testcase 198:
CREATE FOREIGN TABLE tmptbl_griddb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

--Testcase 199:
CREATE FOREIGN TABLE tmptbl_influxdb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

--Testcase 200:
CREATE FOREIGN TABLE tmptbl_oracle (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

--Testcase 201:
CREATE FOREIGN TABLE tmptbl_mysql (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 202:
CREATE FOREIGN TABLE tmptbl_parquet_s3 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv OPTIONS (dirname 's3://data/source');

-- select data in destination server
--Testcase 203:
SELECT count(*) FROM ft1__postgres_dest_srv__0;
--Testcase 204:
SELECT count(*) FROM ft1__griddb_dest_srv__0;
--Testcase 205:
SELECT count(*) FROM ft1__influxdb_dest_srv__0;
--Testcase 206:
SELECT count(*) FROM ft1__oracle_dest_srv__0;

--Testcase 207:
SELECT * FROM ft1 ORDER BY c1, __spd_url;

-- clean up table in destination server
--Testcase 208:
DROP DATASOURCE TABLE ft1__postgres_dest_srv__0;
--Testcase 209:
DROP DATASOURCE TABLE ft1__griddb_dest_srv__0;
--Testcase 210:
DROP DATASOURCE TABLE ft1__influxdb_dest_srv__0;
--Testcase 211:
DROP DATASOURCE TABLE ft1__oracle_dest_srv__0;

-- clean up table in source server
--Testcase 212:
DROP DATASOURCE TABLE tmptbl_postgres;
--Testcase 213:
DROP DATASOURCE TABLE tmptbl_griddb;
--Testcase 214:
DROP DATASOURCE TABLE tmptbl_influxdb;
--Testcase 215:
DROP DATASOURCE TABLE tmptbl_oracle;
--Testcase 216:
DROP DATASOURCE TABLE tmptbl_mysql;
--Testcase 217:
DROP DATASOURCE TABLE tmptbl_parquet_s3;

-- clean up table in pgspider
--Testcase 218:
DROP FOREIGN TABLE tmptbl_postgres;
--Testcase 219:
DROP FOREIGN TABLE tmptbl_griddb;
--Testcase 220:
DROP FOREIGN TABLE tmptbl_influxdb;
--Testcase 221:
DROP FOREIGN TABLE tmptbl_oracle;
--Testcase 222:
DROP FOREIGN TABLE tmptbl_mysql;
--Testcase 223:
DROP FOREIGN TABLE tmptbl_parquet_s3;
--Testcase 224:
DROP FOREIGN TABLE ft1__postgres_dest_srv__0;
--Testcase 225:
DROP FOREIGN TABLE ft1__griddb_dest_srv__0;
--Testcase 226:
DROP FOREIGN TABLE ft1__influxdb_dest_srv__0;
--Testcase 227:
DROP FOREIGN TABLE ft1__oracle_dest_srv__0;

--Testcase 228:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE REPLACE, multi servers with SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 229:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 230:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 231:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 232:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 233:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 234:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 235:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 236:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 237:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 238:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 239:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 240:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 241:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 242:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 243:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 244:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 245:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 246:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 247:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 248:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE REPLACE
--Testcase 249:
\det+

-- MIGRATE data source from source server to destination server
--Testcase 250:
MIGRATE TABLE ft1 REPLACE SERVER
    postgres_dest_srv OPTIONS (table_name 'TBL2'),
    griddb_dest_srv OPTIONS (table_name 'TBL2'),
    influxdb_dest_srv OPTIONS (table 'TBL2'),
    oracle_dest_srv OPTIONS (table 'TBL2'),
    mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2'),
    parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- list up all table after MIGRATE REPLACE
-- foreign tables of source server has been remove
-- foreign tables of destination server has been created
--Testcase 251:
\det+

-- create temp foreign table to check data of source table which in source server
--Testcase 252:
CREATE FOREIGN TABLE tmptbl_postgres (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

--Testcase 253:
CREATE FOREIGN TABLE tmptbl_griddb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

--Testcase 254:
CREATE FOREIGN TABLE tmptbl_influxdb (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

--Testcase 255:
CREATE FOREIGN TABLE tmptbl_oracle (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

--Testcase 256:
CREATE FOREIGN TABLE tmptbl_mysql (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 257:
CREATE FOREIGN TABLE tmptbl_parquet_s3 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv OPTIONS (dirname 's3://data/source');

-- select data in destination server
--Testcase 258:
SELECT count(*) FROM ft1__postgres_dest_srv__0;
--Testcase 259:
SELECT count(*) FROM ft1__griddb_dest_srv__0;
--Testcase 260:
SELECT count(*) FROM ft1__influxdb_dest_srv__0;
--Testcase 261:
SELECT count(*) FROM ft1__oracle_dest_srv__0;
--Testcase 262:
SELECT count(*) FROM ft1__mysql_dest_srv__0;
--Testcase 263:
SELECT count(*) FROM ft1__parquet_s3_dest_srv__0;
--Testcase 264:
SELECT * FROM ft1 ORDER BY c1, __spd_url;

-- clean up table in destination server
--Testcase 265:
DROP DATASOURCE TABLE ft1__postgres_dest_srv__0;
--Testcase 266:
DROP DATASOURCE TABLE ft1__griddb_dest_srv__0;
--Testcase 267:
DROP DATASOURCE TABLE ft1__influxdb_dest_srv__0;
--Testcase 268:
DROP DATASOURCE TABLE ft1__oracle_dest_srv__0;
--Testcase 269:
DROP DATASOURCE TABLE ft1__mysql_dest_srv__0;
--Testcase 270:
DROP DATASOURCE TABLE ft1__parquet_s3_dest_srv__0;

-- clean up table in source server
--Testcase 271:
DROP DATASOURCE TABLE tmptbl_postgres;
--Testcase 272:
DROP DATASOURCE TABLE tmptbl_griddb;
--Testcase 273:
DROP DATASOURCE TABLE tmptbl_influxdb;
--Testcase 274:
DROP DATASOURCE TABLE tmptbl_oracle;
--Testcase 275:
DROP DATASOURCE TABLE tmptbl_mysql;
--Testcase 276:
DROP DATASOURCE TABLE tmptbl_parquet_s3;

-- clean up table in pgspider
--Testcase 277:
DROP FOREIGN TABLE tmptbl_postgres;
--Testcase 278:
DROP FOREIGN TABLE tmptbl_griddb;
--Testcase 279:
DROP FOREIGN TABLE tmptbl_influxdb;
--Testcase 280:
DROP FOREIGN TABLE tmptbl_oracle;
--Testcase 281:
DROP FOREIGN TABLE tmptbl_mysql;
--Testcase 282:
DROP FOREIGN TABLE tmptbl_parquet_s3;
--Testcase 283:
DROP FOREIGN TABLE ft1__postgres_dest_srv__0;
--Testcase 284:
DROP FOREIGN TABLE ft1__griddb_dest_srv__0;
--Testcase 285:
DROP FOREIGN TABLE ft1__influxdb_dest_srv__0;
--Testcase 286:
DROP FOREIGN TABLE ft1__oracle_dest_srv__0;
--Testcase 287:
DROP FOREIGN TABLE ft1__mysql_dest_srv__0;
--Testcase 288:
DROP FOREIGN TABLE ft1__parquet_s3_dest_srv__0;
--Testcase 289:
DROP FOREIGN TABLE ft1;

-- ===================================================================
-- MIGRATE TO, multi servers without SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 290:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 291:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 292:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 293:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 294:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 295:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

-- pre-condition: create foreign table for parquet_s3
--Testcase 296:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 297:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 298:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 299:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 300:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 301:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 302:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 303:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 304:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 305:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 306:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 307:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 308:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 309:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE TO
--Testcase 310:
\det+

-- MIGRATE data source from source server to destination server
-- ERROR: mysql_fdw and parquet_s3_fdw can not run without required option.
--Testcase 311:
MIGRATE TABLE ft1 TO ft2 SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv,
    mysql_dest_srv,
    parquet_s3_dest_srv;
-- OK
--Testcase 312:
MIGRATE TABLE ft1 TO ft2 SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv;
-- list up all table after MIGRATE TO
--Testcase 313:
\det+

-- select data in destination server
--Testcase 314:
SELECT count(*) FROM ft2__postgres_dest_srv__0;
--Testcase 315:
SELECT count(*) FROM ft2__griddb_dest_srv__0;
--Testcase 316:
SELECT count(*) FROM ft2__influxdb_dest_srv__0;
--Testcase 317:
SELECT count(*) FROM ft2__oracle_dest_srv__0;
--Testcase 318:
SELECT * FROM ft2 ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 319:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 320:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 321:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 322:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 323:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 324:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 325:
DROP DATASOURCE TABLE ft2__postgres_dest_srv__0;
--Testcase 326:
DROP DATASOURCE TABLE ft2__griddb_dest_srv__0;
--Testcase 327:
DROP DATASOURCE TABLE ft2__influxdb_dest_srv__0;
--Testcase 328:
DROP DATASOURCE TABLE ft2__oracle_dest_srv__0;

-- clean up table in pgspider
--Testcase 329:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 330:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 331:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 332:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 333:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 334:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 335:
DROP FOREIGN TABLE ft2__postgres_dest_srv__0;
--Testcase 336:
DROP FOREIGN TABLE ft2__griddb_dest_srv__0;
--Testcase 337:
DROP FOREIGN TABLE ft2__influxdb_dest_srv__0;
--Testcase 338:
DROP FOREIGN TABLE ft2__oracle_dest_srv__0;
--Testcase 339:
DROP FOREIGN TABLE ft1;
--Testcase 340:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO, multi servers with SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 341:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 342:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 343:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 344:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 345:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 346:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

-- pre-condition: create foreign table for parquet_s3
--Testcase 347:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 348:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 349:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 350:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 351:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 352:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 353:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 354:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 355:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 356:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 357:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 358:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 359:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 360:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE TO
--Testcase 361:
\det+

-- MIGRATE data source from source server to destination server
--Testcase 362:
MIGRATE TABLE ft1 TO ft2 SERVER
    postgres_dest_srv OPTIONS (table_name 'TBL2'),
    griddb_dest_srv OPTIONS (table_name 'TBL2'),
    influxdb_dest_srv OPTIONS (table 'TBL2'),
    oracle_dest_srv OPTIONS (table 'TBL2'),
    mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2'),
    parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- list up all table after MIGRATE REPLACE
--Testcase 363:
\det+

-- select data in destination server
--Testcase 364:
SELECT count(*) FROM ft2__postgres_dest_srv__0;
--Testcase 365:
SELECT count(*) FROM ft2__griddb_dest_srv__0;
--Testcase 366:
SELECT count(*) FROM ft2__influxdb_dest_srv__0;
--Testcase 367:
SELECT count(*) FROM ft2__oracle_dest_srv__0;
--Testcase 368:
SELECT count(*) FROM ft2__mysql_dest_srv__0;
--Testcase 369:
SELECT count(*) FROM ft2__parquet_s3_dest_srv__0;
--Testcase 370:
SELECT * FROM ft2 ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 371:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 372:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 373:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 374:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 375:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 376:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 377:
DROP DATASOURCE TABLE ft2__postgres_dest_srv__0;
--Testcase 378:
DROP DATASOURCE TABLE ft2__griddb_dest_srv__0;
--Testcase 379:
DROP DATASOURCE TABLE ft2__influxdb_dest_srv__0;
--Testcase 380:
DROP DATASOURCE TABLE ft2__oracle_dest_srv__0;
--Testcase 381:
DROP DATASOURCE TABLE ft2__mysql_dest_srv__0;
--Testcase 382:
DROP DATASOURCE TABLE ft2__parquet_s3_dest_srv__0;

-- clean up table in pgspider
--Testcase 383:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 384:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 385:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 386:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 387:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 388:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 389:
DROP FOREIGN TABLE ft2__postgres_dest_srv__0;
--Testcase 390:
DROP FOREIGN TABLE ft2__griddb_dest_srv__0;
--Testcase 391:
DROP FOREIGN TABLE ft2__influxdb_dest_srv__0;
--Testcase 392:
DROP FOREIGN TABLE ft2__oracle_dest_srv__0;
--Testcase 393:
DROP FOREIGN TABLE ft2__mysql_dest_srv__0;
--Testcase 394:
DROP FOREIGN TABLE ft2__parquet_s3_dest_srv__0;
--Testcase 395:
DROP FOREIGN TABLE ft1;
--Testcase 396:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, multi servers without SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 397:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 398:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 399:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 400:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 401:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 402:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

-- pre-condition: create foreign table for parquet_s3
--Testcase 403:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 404:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 405:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 406:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 407:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 408:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 409:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 410:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 411:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 412:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 413:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 414:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 415:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 416:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE TO
--Testcase 417:
\det+

-- MIGRATE data source from source server to destination server
-- ERROR: mysql_fdw and parquet_s3_fdw can not run without required option.
--Testcase 418:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv,
    mysql_dest_srv,
    parquet_s3_dest_srv;
-- OK
--Testcase 419:
MIGRATE TABLE ft1 TO ft2 OPTIONS (USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER
    postgres_dest_srv,
    griddb_dest_srv,
    influxdb_dest_srv,
    oracle_dest_srv;
-- New 'new_pgspider_core_svr' is created
--Testcase 420:
\des+

-- list up all table after MIGRATE TO
--Testcase 421:
\det+

-- select data in destination server
--Testcase 422:
SELECT count(*) FROM ft2__postgres_dest_srv__0;
--Testcase 423:
SELECT count(*) FROM ft2__griddb_dest_srv__0;
--Testcase 424:
SELECT count(*) FROM ft2__influxdb_dest_srv__0;
--Testcase 425:
SELECT count(*) FROM ft2__oracle_dest_srv__0;
--Testcase 426:
SELECT * FROM ft2 ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 427:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 428:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 429:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 430:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 431:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 432:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 433:
DROP DATASOURCE TABLE ft2__postgres_dest_srv__0;
--Testcase 434:
DROP DATASOURCE TABLE ft2__griddb_dest_srv__0;
--Testcase 435:
DROP DATASOURCE TABLE ft2__influxdb_dest_srv__0;
--Testcase 436:
DROP DATASOURCE TABLE ft2__oracle_dest_srv__0;

-- clean up table in pgspider
--Testcase 437:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 438:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 439:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 440:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 441:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 442:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 443:
DROP FOREIGN TABLE ft2__postgres_dest_srv__0;
--Testcase 444:
DROP FOREIGN TABLE ft2__griddb_dest_srv__0;
--Testcase 445:
DROP FOREIGN TABLE ft2__influxdb_dest_srv__0;
--Testcase 446:
DROP FOREIGN TABLE ft2__oracle_dest_srv__0;
--Testcase 447:
DROP FOREIGN TABLE ft2__mysql_dest_srv__0;
--Testcase 448:
DROP FOREIGN TABLE ft2__parquet_s3_dest_srv__0;
--Testcase 449:
DROP FOREIGN TABLE ft1;
--Testcase 450:
DROP FOREIGN TABLE ft2;

-- ===================================================================
-- MIGRATE TO has USE_MULTITENANT_SERVER option, multi servers with SERVER OPTION
-- ===================================================================
-- pre-condition: create multi-tenant table
--Testcase 451:
CREATE FOREIGN TABLE ft1 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text,
    __spd_url text
) SERVER pgspider_core_srv;

-- pre-condition: create foreign table for postgres
--Testcase 452:
CREATE FOREIGN TABLE ft1__postgres_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER postgres_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for griddb
--Testcase 453:
CREATE FOREIGN TABLE ft1__griddb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER griddb_src_srv OPTIONS (table_name 'TBL1');

-- pre-condition: create foreign table for influx
--Testcase 454:
CREATE FOREIGN TABLE ft1__influxdb_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER influxdb_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for oracle
--Testcase 455:
CREATE FOREIGN TABLE ft1__oracle_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER oracle_src_srv OPTIONS (table 'TBL1');

-- pre-condition: create foreign table for mysql
--Testcase 456:
CREATE FOREIGN TABLE ft1__mysql_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER mysql_src_srv OPTIONS (dbname 'sourcedb', table_name 'TBL1');

--Testcase 457:
CREATE FOREIGN TABLE ft1__parquet_s3_src_srv__0 (
    c1 int NOT NULL,
    c2 int NOT NULL,
    c3 text,
    c4 bool,
    c5 timestamp,
    c6 double precision,
    c7 text,
    c8 text
) SERVER parquet_s3_src_srv
OPTIONS (dirname 's3://data/source');

-- create table in source server
--Testcase 458:
CREATE DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 459:
CREATE DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 460:
CREATE DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 461:
CREATE DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 462:
CREATE DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 463:
CREATE DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- init data
--Testcase 464:
INSERT INTO ft1__postgres_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(1, 5) id;

--Testcase 465:
INSERT INTO ft1__griddb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(6, 10) id;

--Testcase 466:
INSERT INTO ft1__influxdb_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(11, 15) id;

--Testcase 467:
INSERT INTO ft1__oracle_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(16, 20) id;

--Testcase 468:
INSERT INTO ft1__mysql_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(21, 25) id;

--Testcase 469:
INSERT INTO ft1__parquet_s3_src_srv__0
    SELECT id,
           id % 10,
           to_char(id, 'FM00000'),
           't',
           '1980-01-01'::timestamp + ((id % 1000) || ' minute')::interval,
           (id::double precision) / 3,
           id % 10,
           'foo'
    FROM generate_series(26, 30) id;

-- show data in source server
--Testcase 470:
SELECT * FROM ft1 ORDER BY c1;

-- list up all table before MIGRATE TO
--Testcase 471:
\det+

-- MIGRATE data source from source server to destination server
--Testcase 472:
MIGRATE TABLE ft1 TO ft2 OPTIONS(USE_MULTITENANT_SERVER 'new_pgspider_core_svr') SERVER
    postgres_dest_srv OPTIONS (table_name 'TBL2'),
    griddb_dest_srv OPTIONS (table_name 'TBL2'),
    influxdb_dest_srv OPTIONS (table 'TBL2'),
    oracle_dest_srv OPTIONS (table 'TBL2'),
    mysql_dest_srv OPTIONS (dbname 'destdb', table_name 'TBL2'),
    parquet_s3_dest_srv OPTIONS (dirname 's3://data/dest');

-- list up all table after MIGRATE TO
--Testcase 473:
\det+

-- select data in destination server
--Testcase 474:
SELECT count(*) FROM ft2__postgres_dest_srv__0;
--Testcase 475:
SELECT count(*) FROM ft2__griddb_dest_srv__0;
--Testcase 476:
SELECT count(*) FROM ft2__influxdb_dest_srv__0;
--Testcase 477:
SELECT count(*) FROM ft2__oracle_dest_srv__0;
--Testcase 478:
SELECT count(*) FROM ft2__mysql_dest_srv__0;
--Testcase 479:
SELECT count(*) FROM ft2__parquet_s3_dest_srv__0;
--Testcase 480:
SELECT * FROM ft2 ORDER BY c1, __spd_url;

-- clean up table in source server
--Testcase 481:
DROP DATASOURCE TABLE ft1__postgres_src_srv__0;
--Testcase 482:
DROP DATASOURCE TABLE ft1__griddb_src_srv__0;
--Testcase 483:
DROP DATASOURCE TABLE ft1__influxdb_src_srv__0;
--Testcase 484:
DROP DATASOURCE TABLE ft1__oracle_src_srv__0;
--Testcase 485:
DROP DATASOURCE TABLE ft1__mysql_src_srv__0;
--Testcase 486:
DROP DATASOURCE TABLE ft1__parquet_s3_src_srv__0;

-- clean up table in destination server
--Testcase 487:
DROP DATASOURCE TABLE ft2__postgres_dest_srv__0;
--Testcase 488:
DROP DATASOURCE TABLE ft2__griddb_dest_srv__0;
--Testcase 489:
DROP DATASOURCE TABLE ft2__influxdb_dest_srv__0;
--Testcase 490:
DROP DATASOURCE TABLE ft2__oracle_dest_srv__0;
--Testcase 491:
DROP DATASOURCE TABLE ft2__mysql_dest_srv__0;
--Testcase 492:
DROP DATASOURCE TABLE ft2__parquet_s3_dest_srv__0;

-- clean up table in pgspider
--Testcase 493:
DROP FOREIGN TABLE ft1__postgres_src_srv__0;
--Testcase 494:
DROP FOREIGN TABLE ft1__griddb_src_srv__0;
--Testcase 495:
DROP FOREIGN TABLE ft1__influxdb_src_srv__0;
--Testcase 496:
DROP FOREIGN TABLE ft1__oracle_src_srv__0;
--Testcase 497:
DROP FOREIGN TABLE ft1__mysql_src_srv__0;
--Testcase 498:
DROP FOREIGN TABLE ft1__parquet_s3_src_srv__0;
--Testcase 499:
DROP FOREIGN TABLE ft2__postgres_dest_srv__0;
--Testcase 500:
DROP FOREIGN TABLE ft2__griddb_dest_srv__0;
--Testcase 501:
DROP FOREIGN TABLE ft2__influxdb_dest_srv__0;
--Testcase 502:
DROP FOREIGN TABLE ft2__oracle_dest_srv__0;
--Testcase 503:
DROP FOREIGN TABLE ft2__mysql_dest_srv__0;
--Testcase 504:
DROP FOREIGN TABLE ft2__parquet_s3_dest_srv__0;
--Testcase 505:
DROP FOREIGN TABLE ft1;
--Testcase 506:
DROP FOREIGN TABLE ft2;

-- clean up all extension
--Testcase 507:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 508:
DROP EXTENSION griddb_fdw CASCADE;
--Testcase 509:
DROP EXTENSION influxdb_fdw CASCADE;
--Testcase 510:
DROP EXTENSION oracle_fdw CASCADE;
--Testcase 511:
DROP EXTENSION mysql_fdw CASCADE;
--Testcase 512:
DROP EXTENSION parquet_s3_fdw CASCADE;
--Testcase 513:
DROP EXTENSION pgspider_core_fdw CASCADE;
