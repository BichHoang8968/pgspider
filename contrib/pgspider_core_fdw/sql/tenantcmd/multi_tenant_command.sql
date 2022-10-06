--Create extension
--Testcase 1:
CREATE EXTENSION pgspider_core_fdw;
--Start test for abnormal cases
--Test for abnormal cases, wrong syntax CREATE server command
--Keyword not correct in CREATE server command
--Testcase 2:
CREATE MULTI pgspider_multi_tenant;
--Testcase 3:
CREATE TENANT pgspider_multi_tenant;
--Wrong order keyword in CREATE server command
--Testcase 4:
CREATE TENANT MULTI pgspider_multi_tenant;
--Use combine old and new command keyword in CREATE server command
--Testcase 5:
CREATE SERVER MULTI TENANT pgspider_multi_tenant;
--Server name same keyword
--Testcase 6:
CREATE MULTI TENANT tenant;
--Testcase 7:
CREATE MULTI TENANT multi;
--Create tenant table with server not exist
--Testcase 8:
CREATE MULTI TENANT TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Create multi tenant succeed, used for create multi tenant table
--Testcase 9:
CREATE MULTI TENANT IF NOT EXISTS pgspider_multi_tenant;
--Keyword not correct in CREATE table command
--Testcase 10:
CREATE MULTI TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Testcase 11:
CREATE TENANT TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Testcase 12:
CREATE MULTI TENANT TABLE test_tbl (i int, __spd_url text) MULTI pgspider_multi_tenant;
--Wrong order keyword in CREATE table command
--Testcase 13:
CREATE TENANT MULTI TABLE test_tbl (i int, __spd_url text) TENANT MULTI pgspider_multi_tenant;
--Table name same keyword
--Testcase 14:
CREATE MULTI TENANT TABLE tenant (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Testcase 15:
CREATE MULTI TENANT TABLE multi (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Use combine old and new command keyword in CREATE table command
--Testcase 16:
CREATE FOREIGN MULTI TENANT TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Testcase 17:
CREATE FOREIGN TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Testcase 18:
CREATE MULTI TENANT TABLE test_tbl (i int, __spd_url text) SERVER pgspider_multi_tenant;
--DROP tables
--Testcase 19:
DROP MULTI TENANT TABLE multi;
--Testcase 20:
DROP MULTI TENANT TABLE tenant;
--Test for abnormal cases, wrong syntax ALTER command
--Keyword not correct in ALTER server command
--Testcase 21:
ALTER MULTI pgspider_multi_tenant RENAME TO pgspider;
--Testcase 22:
ALTER TENANT pgspider_multi_tenant OWNER TO CURRENT_USER;
--Wrong order keyword in ALTER server command
--Testcase 23:
ALTER TENANT MULTI pgspider_multi_tenant OPTIONS (host '127.0.0.1');
--Use combine old and new command keyword in ALTER server command
--Testcase 24:
ALTER SERVER MULTI TENANT pgspider_multi_tenant OPTIONS (SET host 'localhost');
--Testcase 25:
ALTER MULTI TENANT SERVER pgspider_multi_tenant VERSION '14.0';
--To check abnormal in alter table command, first, create table succeed
--Testcase 26:
CREATE MULTI TENANT TABLE test_tbl (i int, __spd_url text) MULTI TENANT pgspider_multi_tenant;
--Keyword not correct in ALTER table command
--Testcase 27:
ALTER TENANT TABLE test_tbl SET SCHEMA new_schema;
--Testcase 28:
ALTER MULTI TABLE test_tbl RENAME COLUMN i TO ii;
--Wrong order keyword in ALTER table command
--Testcase 29:
ALTER TENANT MULTI TABLE test_tbl DROP COLUMN ii IF EXISTS;
--Use combine old and new command keyword in ALTER table command
--Testcase 30:
ALTER FOREIGN MULTI TENANT TABLE test_tbl ADD COLUMN ii text;
--Testcase 31:
ALTER MULTI TENANT FOREIGN TABLE test_tbl ALTER COLUMN i SET NOT NULL;
--Alter table name same keyword
--Testcase 32:
ALTER MULTI TENANT TABLE test_tbl RENAME TO tenant;
--Testcase 33:
ALTER MULTI TENANT TABLE test_tbl RENAME TO multi;
--Test for abnormal cases, wrong syntax DROP command
--Keyword not correct in DROP server command
--Testcase 34:
DROP MULTI pgspider_multi_tenant;
--Testcase 35:
DROP TENANT pgspider_multi_tenant;
--Wrong order keyword in DROP server command
--Testcase 36:
DROP TENANT MULTI pgspider_multi_tenant;
--Drop server not exist
--Testcase 37:
DROP MULTI TENANT IF EXISTS pgspider_1;
--Use combine old and new command keyword in DROP server command
--Testcase 38:
DROP SERVER MULTI TENANT pgspider_multi_tenant CASCADE;
--Keyword not correct in DROP table command
--Testcase 39:
DROP MULTI TABLE test_tbl;
--Testcase 40:
DROP TENANT TABLE test_tbl;
--Wrong order keyword in DROP table command
--Testcase 41:
DROP TENANT MULTI TABLE test_tbl;
--Use combine old and new command keyword in DROP table command
--Testcase 42:
DROP FOREIGN TABLE MULTI TENANT IF EXISTS test_tbl;
--Test for abnormal cases, wrong syntax user mapping command
--Keyword not correct in CREATE USER MAPPING command
--Testcase 43:
CREATE USER MAPPING FOR CURRENT_USER TENANT pgspider_multi_tenant;
--Testcase 44:
CREATE USER MAPPING FOR CURRENT_USER MULTI pgspider_multi_tenant;
--Wrong order keyword in CREATE USER MAPPING command
--Testcase 45:
CREATE USER MAPPING FOR PUBLIC TENANT MULTI pgspider_multi_tenant;
--Use combine old and new command keyword in CREATE USER MAPPING command
--Testcase 46:
CREATE USER MAPPING FOR CURRENT_ROLE MULTI TENANT SERVER pgspider_multi_tenant;
--Testcase 47:
CREATE USER MAPPING FOR postgres SERVER MULTI TENANT pgspider_multi_tenant OPTIONS (user 'postgres', password 'postgres');
--Keyword not correct in ALTER USER MAPPING command
--Testcase 48:
ALTER USER MAPPING FOR postgres MULTI pgspider_multi_tenant OPTIONS (SET password 'public');
--Testcase 49:
ALTER USER MAPPING FOR postgres TENANT pgspider_multi_tenant OPTIONS (DROP password 'public');
--Wrong order keyword in ALTER USER MAPPING command
--Testcase 50:
ALTER USER MAPPING FOR PUBLIC TENANT MULTI pgspider_multi_tenant (ADD user 'test');
--Use combine old and new command keyword in ALTER USER MAPPING command
--Testcase 51:
ALTER USER MAPPING FOR postgres MULTI TENANT SERVER pgspider_multi_tenant OPTIONS (user 'postgres', password 'postgres');
--Keyword not correct in DROP USER MAPPING command
--Testcase 52:
DROP USER MAPPING FOR CURRENT_USER TENANT pgspider_multi_tenant;
--Testcase 53:
DROP USER MAPPING FOR CURRENT_ROLE MULTI pgspider_multi_tenant;
--Wrong order keyword in DROP USER MAPPING command
--Testcase 54:
DROP USER MAPPING IF EXISTS FOR postgres TENANT MULTI pgspider_multi_tenant;
--Use combine old and new command keyword in DROP USER MAPPING command
--Testcase 55:
DROP USER MAPPING IF EXISTS FOR public MULTI TENANT SERVER pgspider_multi_tenant;
--Now, drop multi tenant/table/user mapping
--Testcase 56:
DROP MULTI TENANT TABLE test_tbl;
--Testcase 57:
DROP MULTI TENANT pgspider_multi_tenant CASCADE;
--Testcase 58:
DROP MULTI TENANT multi;
--Testcase 59:
DROP MULTI TENANT tenant;
--End test for abnormal cases
--Test for CREATE/DROP with other keywords which not tested in pgspider_core_fdw before
--Testcase 60:
CREATE EXTENSION mysql_fdw;
--Testcase 61:
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
--Testcase 62:
CREATE USER MAPPING FOR PUBLIC SERVER mysql_svr OPTIONS(username 'root',password 'Mysql_1234');
--Testcase 63:
CREATE FOREIGN TABLE t3__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');
--Create multi tenant with type PGSpider
--Testcase 64:
CREATE MULTI TENANT pgspider_svr TYPE 'PGSpider' VERSION '14.0';
--Testcase 65:
CREATE USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr;
--Testcase 66:
CREATE MULTI TENANT TABLE t3 (t text, t2 text, i int, __spd_url text) MULTI TENANT pgspider_svr;
--Check data retrieve directly from foreign table
--Testcase 67:
SELECT * FROM t3__mysql_svr__0;
--Check data query
--Testcase 68:
SELECT * FROM t3;
--Drop tenant 
--Testcase 69:
DROP MULTI TENANT pgspider_svr CASCADE;
--Create multi tenant with type POSTGRESQL
--Testcase 70:
CREATE MULTI TENANT IF NOT EXISTS pgspider_svr TYPE 'POSTGRESQL' VERSION '14.0';
--Testcase 71:
CREATE USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr;
--Testcase 72:
CREATE MULTI TENANT TABLE t3 (t text, t2 text, i int, __spd_url text) MULTI TENANT pgspider_svr;
--Check data query
--Testcase 73:
SELECT * FROM t3;
--Drop table and re-create 
--Testcase 74:
DROP MULTI TENANT TABLE IF EXISTS t3;
--Testcase 75:
CREATE MULTI TENANT TABLE IF NOT EXISTS t3 (t text, t2 text, i int, __spd_url text) MULTI TENANT pgspider_svr;
--Check data query
--Testcase 76:
SELECT * FROM t3;
--Testcase 173:
DROP MULTI TENANT TABLE IF EXISTS t3;
--Check with partition
--Testcase 77:
CREATE TABLE main_partition_tbl (t text, t2 text, i int) PARTITION BY LIST (t);
--Testcase 78:
CREATE MULTI TENANT TABLE t3 PARTITION OF main_partition_tbl FOR VALUES IN ('node1') MULTI TENANT pgspider_svr;
--Testcase 79:
CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER MULTI TENANT pgspider_svr;
--Check data query
--Testcase 80:
SELECT * FROM t3;
--Drop table/mapping and re-create 
--Testcase 81:
DROP MULTI TENANT TABLE IF EXISTS t3;
--Testcase 82:
DROP USER MAPPING IF EXISTS FOR CURRENT_USER MULTI TENANT pgspider_svr;
--Check with inherits
--Testcase 83:
CREATE TABLE main_inherits_tbl (t text, t2 text, i int);
--Testcase 84:
CREATE MULTI TENANT TABLE t3 (t text, t2 text, i int, __spd_url text) INHERITS (main_inherits_tbl) MULTI TENANT pgspider_svr;
--Testcase 85:
CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_ROLE MULTI TENANT pgspider_svr;
--Check data query
--Testcase 86:
SELECT * FROM t3;
--Drop table/mapping and re-create
--Testcase 87:
DROP TABLE main_partition_tbl;
--Testcase 88:
DROP TABLE main_inherits_tbl CASCADE;
--Testcase 89:
DROP MULTI TENANT TABLE IF EXISTS t3;
--Testcase 90:
DROP USER MAPPING IF EXISTS FOR CURRENT_ROLE MULTI TENANT pgspider_svr;
--Check with default/check/not null
--Testcase 91:
CREATE MULTI TENANT TABLE t3 (t text DEFAULT 'aaa', t2 text, i int CHECK (i > 0), __spd_url text NOT NULL) MULTI TENANT pgspider_svr;
--Check data query
--Testcase 92:
SELECT * FROM t3;
--Drop table and re-create
--Testcase 93:
DROP MULTI TENANT TABLE t3;
--Check with collate/null
--Testcase 94:
CREATE MULTI TENANT TABLE t3 (t text COLLATE "C", t2 text NULL, i int, __spd_url text) MULTI TENANT pgspider_svr;
--Testcase 95:
CREATE USER MAPPING IF NOT EXISTS FOR USER MULTI TENANT pgspider_svr;
--Check data query
--Testcase 96:
SELECT * FROM t3;
--Drop tables
--Testcase 97:
DROP FOREIGN TABLE t3__mysql_svr__0;
--Testcase 98:
DROP SERVER mysql_svr CASCADE;
--Testcase 99:
DROP EXTENSION mysql_fdw CASCADE;
--Testcase 100:
DROP USER MAPPING IF EXISTS FOR USER MULTI TENANT pgspider_svr;
--Testcase 101:
DROP MULTI TENANT TABLE t3 CASCADE;
--Testcase 102:
DROP USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr;
--Testcase 103:
DROP MULTI TENANT IF EXISTS pgspider_svr RESTRICT;
--Test for ALTER commands
--Create MULTI TENANT/MULTI TENANT TABLE/USER MAPPING
--Testcase 104:
CREATE MULTI TENANT pgspider_svr;
--Testcase 105:
CREATE MULTI TENANT TABLE test1 (i int,__spd_url text) MULTI TENANT pgspider_svr;
--Testcase 106:
CREATE MULTI TENANT TABLE t1 (i int, t text,__spd_url text) MULTI TENANT pgspider_svr;
--Testcase 107:
CREATE USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr;
--Create foreign tables
--Testcase 108:
CREATE EXTENSION file_fdw;
--Testcase 109:
CREATE EXTENSION postgres_fdw;
--Testcase 110:
CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw;
--Testcase 111:
CREATE SERVER post_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
--Testcase 112:
CREATE USER MAPPING FOR PUBLIC SERVER post_svr OPTIONS(user 'postgres',password 'postgres');
--Testcase 113:
CREATE FOREIGN TABLE test1__file_svr__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
--Testcase 114:
CREATE FOREIGN TABLE t1__post_svr__0 (i int, t text) SERVER post_svr OPTIONS(table_name 't1');
--First, test with normal options that already tested in pgspider_core_fdw
--Alter multi tenant
--Testcase 115:
ALTER MULTI TENANT pgspider_svr OPTIONS (host '127.0.0.1', port '656');
--Testcase 116:
ALTER MULTI TENANT pgspider_svr OPTIONS (SET port '50849');
--Check data retrieve directly from foreign table
--Testcase 117:
SELECT * FROM test1__file_svr__0;
--Testcase 118:
SELECT * FROM t1__post_svr__0;
--Check query data
--Testcase 119:
SELECT * FROM test1;
--Testcase 120:
SELECT * FROM t1;
--Alter user mapping with options
--Testcase 121:
ALTER USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr OPTIONS (ADD user 'p');
--Testcase 122:
ALTER USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr OPTIONS (ADD password 'p');
--Testcase 123:
ALTER USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr OPTIONS (SET user 'postgres');
--Testcase 124:
ALTER USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr OPTIONS (DROP password);
--Testcase 125:
ALTER USER MAPPING FOR PUBLIC MULTI TENANT pgspider_svr OPTIONS (ADD password 'postgres');
--Check query data
--Testcase 126:
SELECT * FROM test1;
--Testcase 127:
SELECT * FROM t1;
--Test with new KEYWORD
--Alter multi tenant
--Testcase 128:
ALTER MULTI TENANT pgspider_svr OWNER TO CURRENT_USER;
--Testcase 129:
ALTER MULTI TENANT pgspider_svr RENAME TO pgspider_multi_tenant;
--Check query data
--Testcase 130:
SELECT * FROM test1;
--Testcase 131:
SELECT * FROM t1;
--Alter multi tenant table
--Alter columns and check query data
--Testcase 132:
ALTER MULTI TENANT TABLE test1 DROP COLUMN __spd_url;
--Testcase 133:
SELECT * FROM test1;
--Testcase 134:
ALTER MULTI TENANT TABLE test1 ADD COLUMN __spd_url text;
--Testcase 135:
SELECT * FROM test1;
--Testcase 140:
ALTER MULTI TENANT TABLE t1 DROP COLUMN IF EXISTS c2 CASCADE;
--Testcase 141:
SELECT * FROM test1;
--Alter schema
--Testcase 142:
CREATE SCHEMA new_schema;
--Testcase 143:
ALTER MULTI TENANT TABLE test1 SET SCHEMA new_schema;
--Testcase 144:
SELECT * FROM new_schema.test1;
--Testcase 145:
ALTER MULTI TENANT TABLE new_schema.test1 SET SCHEMA PUBLIC;
--Alter multi tenant table name
--Testcase 146:
ALTER MULTI TENANT TABLE test1 RENAME TO a_test;
--Testcase 174:
ALTER FOREIGN TABLE test1__file_svr__0 RENAME TO a_test__file_svr__0;
--Testcase 147:
SELECT * FROM a_test;
--Use constraint
--Testcase 148:
ALTER MULTI TENANT TABLE t1 ADD CONSTRAINT t1ipositive CHECK (i >= 0);
--Testcase 149:
SELECT * FROM t1;
--Use with trigger
--Testcase 150:
ALTER MULTI TENANT TABLE t1 ENABLE TRIGGER USER;
--Testcase 151:
SELECT * FROM t1;
--Testcase 152:
ALTER MULTI TENANT TABLE t1 DISABLE TRIGGER ALL;
--Testcase 153:
SELECT * FROM t1;
--Alter user mapping with new keyword
--Testcase 175:
CREATE USER MAPPING FOR CURRENT_USER MULTI TENANT pgspider_multi_tenant OPTIONS (password 'dummypwd');
--Testcase 156:
ALTER USER MAPPING FOR CURRENT_USER MULTI TENANT pgspider_multi_tenant OPTIONS (DROP password);
--Testcase 157:
ALTER USER MAPPING FOR CURRENT_ROLE MULTI TENANT pgspider_multi_tenant OPTIONS (ADD password 'postgres');
--Testcase 158:
ALTER USER MAPPING FOR USER MULTI TENANT pgspider_multi_tenant OPTIONS (ADD user 'postgres');
--Testcase 159:
SELECT * FROM t1;

--Clean
--Testcase 160:
DROP SERVER file_svr CASCADE;
--Testcase 161:
DROP SERVER post_svr CASCADE;
--Testcase 162:
DROP USER MAPPING FOR CURRENT_USER MULTI TENANT pgspider_multi_tenant;
--Testcase 165:
DROP USER MAPPING FOR PUBLIC MULTI TENANT pgspider_multi_tenant;
--Testcase 166:
DROP MULTI TENANT TABLE test1 CASCADE;
--Testcase 167:
DROP MULTI TENANT TABLE t1 CASCADE;
--Testcase 168:
DROP MULTI TENANT pgspider_multi_tenant CASCADE;
--Testcase 169:
DROP EXTENSION pgspider_core_fdw CASCADE;
--Testcase 170:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 171:
DROP EXTENSION file_fdw CASCADE;
