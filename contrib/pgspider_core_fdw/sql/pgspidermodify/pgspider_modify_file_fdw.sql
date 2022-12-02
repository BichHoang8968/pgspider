\set ECHO none
\ir sql/pgspidermodify/parameters.conf
\set ECHO all
--Testcase 1:
SET datestyle = ISO;
--Testcase 2:
SET timezone = 'UTC';

--Testcase 3:
DELETE FROM pg_spd_node_info;
--Testcase 4:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 5:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER1);
--Testcase 6:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
-- Extensions
--Testcase 7:
CREATE EXTENSION file_fdw;
--Testcase 8:
CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw;
--Testcase 9:
CREATE SERVER file_svr_2 FOREIGN DATA WRAPPER file_fdw;

--Testcase 10:
CREATE FOREIGN TABLE tntbl5 (c1 int, c2 text, __spd_url text) SERVER pgspider_svr;

-- *** Start test for 1 node file_fdw *** --
--Testcase 11:
CREATE FOREIGN TABLE tntbl5__file_svr__0 (c1 int, c2 text) SERVER file_svr OPTIONS (filename '/tmp/pg_modify_file1.csv', format 'csv');

-- SELECT FROM table if there is any record
--Testcase 12:
SELECT * FROM tntbl5 ORDER BY 1;

-- This FDW does not support modification, the result will fail all over
--Testcase 13:
INSERT INTO tntbl5 VALUES (DEFAULT, 'abc');
--Testcase 14:
INSERT INTO tntbl5 VALUES (1, 'foo');
--Testcase 15:
INSERT INTO tntbl5 IN ('/file_svr/') VALUES (2, 'zzzzz');
--Testcase 16:
UPDATE tntbl5 SET c2 = 'foo' WHERE c1 IS NULL;
--Testcase 17:
UPDATE tntbl5 IN ('/file_svr/', '/file_svr_2/') SET c2 = DEFAULT;
--Testcase 18:
DELETE FROM tntbl5 WHERE c2 = 'foo';
--Testcase 19:
DELETE FROM tntbl5 IN ('/file_svr/');

-- *** Start test for 2 nodes file_fdw *** --
--Testcase 20:
CREATE FOREIGN TABLE tntbl5__file_svr__2 (c1 int, c2 text) SERVER file_svr_2 OPTIONS (filename '/tmp/pg_modify_file2.csv', format 'csv');

-- SELECT FROM table if there is any record
--Testcase 21:
SELECT * FROM tntbl5 ORDER BY 1;

-- This FDW does not support modification, the result will fail all over
--Testcase 22:
INSERT INTO tntbl5 VALUES (DEFAULT, 'abc');
--Testcase 23:
INSERT INTO tntbl5 VALUES (1, 'foo');
--Testcase 24:
INSERT INTO tntbl5 IN ('/file_svr/') VALUES (2, 'zzzzz');
--Testcase 25:
UPDATE tntbl5 SET c2 = 'foo' WHERE c1 IS NULL;
--Testcase 26:
UPDATE tntbl5 IN ('/file_svr/', '/file_svr_2/') SET c2 = DEFAULT;
--Testcase 27:
DELETE FROM tntbl5 WHERE c2 = 'foo';
--Testcase 28:
DELETE FROM tntbl5 IN ('/file_svr/');

--Clean
--Testcase 29:
DROP FOREIGN TABLE tntbl5 CASCADE;
--Testcase 30:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 31:
DROP EXTENSION file_fdw CASCADE;
--Testcase 32:
DROP SERVER pgspider_svr CASCADE;
--Testcase 33:
DROP EXTENSION pgspider_core_fdw CASCADE;
