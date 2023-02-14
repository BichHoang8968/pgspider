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

--
-- Test case routing insert feature
--
-- Test in case of throw_candidate_error = false
--Testcase 47:
SET pgspider_core_fdw.throw_candidate_error = false;
-- First, single insert for nodes
--Testcase 48:
INSERT INTO tntbl5 VALUES (60, 'awefaAW#');
--Testcase 49:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 50:
INSERT INTO tntbl5 VALUES (61, 'AEFA');
--Testcase 51:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 52:
INSERT INTO tntbl5 VALUES (62, 'e4rw3fr');
--Testcase 53:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 54:
INSERT INTO tntbl5 VALUES (63, 'sreg32sf aef');
--Testcase 55:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 56:
INSERT INTO tntbl5 VALUES (64, 'sgwegaw3');
--Testcase 57:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 58:
INSERT INTO tntbl5 VALUES (65, 'a3rq2raeff');
--Testcase 59:
SELECT * FROM tntbl5 ORDER BY 1;
-- Multi insert to nodes
--Testcase 60:
INSERT INTO tntbl5 VALUES (66, 'awefaAW#'), (67, '42342q');
--Testcase 61:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 62:
INSERT INTO tntbl5 VALUES (68, 'w3r3wrfa#'), (69, '32423'), (70, 'agaw'), (71, 'seg3agawega'), (72, 'rj34yerg');
--Testcase 63:
SELECT * FROM tntbl5 ORDER BY 1;
--
-- Test in case of throw_candidate_error = true
-- If at least one child node has an error, pgspider_core_fdw raises an error
--Testcase 64:
SET pgspider_core_fdw.throw_candidate_error = true;
ALTER FOREIGN TABLE tntbl5__file_svr__0 OPTIONS (SET filename '/tmp/pg_modify_file_not_existed.csv');
-- Insert single value
--Testcase 65:
INSERT INTO tntbl5 VALUES (80, 'A#KRA#');
--Testcase 66:
SELECT * FROM tntbl5 ORDER BY 1;
ALTER FOREIGN TABLE tntbl5__file_svr__0 OPTIONS (SET filename '/tmp/pg_modify_file1.csv');
--Testcase 67:
INSERT INTO tntbl5 VALUES ('81', '2ea3r2');
--Testcase 68:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 69:
INSERT INTO tntbl5 VALUES (82, 42452);
--Testcase 70:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 71:
INSERT INTO tntbl5 VALUES (83, '32r21rawf');
--Testcase 72:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 73:
INSERT INTO tntbl5 VALUES (84, 'A#afwf#');
--Testcase 74:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 75:
INSERT INTO tntbl5 VALUES (85, 'a3r2e');
--Testcase 76:
SELECT * FROM tntbl5 ORDER BY 1;
-- Insert multi value
--Testcase 77:
INSERT INTO tntbl5 VALUES ('86', '3wra'), (87, 452);
--Testcase 78:
SELECT * FROM tntbl5 ORDER BY 1;
--Testcase 79:
INSERT INTO tntbl5 VALUES (88, '3wra'), (89, 'taw35ta'), (90, 'erfawfa'), (91, 'avaewvaf'), (92, 'avAEGAWRG'), (93, 'AMEF_awe.fawlfe');
--Testcase 80:
SELECT * FROM tntbl5 ORDER BY 1;

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
