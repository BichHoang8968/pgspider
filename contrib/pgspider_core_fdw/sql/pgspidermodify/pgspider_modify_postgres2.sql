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
CREATE EXTENSION postgres_fdw;

--Testcase 8:
CREATE SERVER postgres_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_SERVER, port :POSTGRES_PORT, dbname 'pg_modify_db');
--Testcase 9:
CREATE USER mapping for public SERVER postgres_svr OPTIONS(user :POSTGRES_USER, password :POSTGRES_PASS);

--Testcase 10:
CREATE SERVER postgres_svr_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_1_SERVER, port :POSTGRES_1_PORT, dbname 'pg_modify_db');
--Testcase 11:
CREATE USER mapping for public SERVER postgres_svr_1 OPTIONS(user :POSTGRES_1_USER, password :POSTGRES_1_PASS);

--Testcase 12:
CREATE SERVER postgres_svr_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host :POSTGRES_2_SERVER, port :POSTGRES_2_PORT, dbname 'pg_modify_db');
--Testcase 13:
CREATE USER mapping for public SERVER postgres_svr_2 OPTIONS(user :POSTGRES_2_USER, password :POSTGRES_2_PASS);

--Testcase 14:
CREATE FOREIGN TABLE tntbl4 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval, __spd_url text) SERVER pgspider_svr;


-- Foreign tables

--Testcase 15:
CREATE FOREIGN TABLE tntbl4__postgres_svr__0 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval) SERVER postgres_svr OPTIONS (table_name 'tntbl4');
--Testcase 16:
CREATE FOREIGN TABLE tntbl4__postgres_svr_2__0 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval) SERVER postgres_svr_2 OPTIONS (table_name 'tntbl4');

-- Reset data of remote table before test
DELETE FROM tntbl4__postgres_svr__0;
DELETE FROM tntbl4__postgres_svr_2__0;
INSERT INTO tntbl4__postgres_svr__0 VALUES (10, 'text', true, 10.0, 1000, 'char array', 'varchar array', -1.0, 12, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '2001-01-01', '{"product": "test","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');
INSERT INTO tntbl4__postgres_svr_2__0 VALUES (20, 'texttext', false, -10.0, -1000, 'char array', 'varchar array', 1.0, 1, '2005-10-19 10:23:54', '2005-10-19 10:23:54+02', '2001-01-01', '{"product": "sample","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": false }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');

--Testcase 17:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-----------------------------------------------------------------------------------
-- *** Start test for tntbl4 *** --
--
-- insert with DEFAULT in the target_list
--
--Testcase 18:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 19:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (3, DEFAULT, DEFAULT);
--Testcase 20:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (4, 'ANC#$', DEFAULT);
--Testcase 21:
INSERT INTO tntbl4 VALUES (5, DEFAULT, true, 10.0, 1000, 'char array', 'char varying', 100.0, 127, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '0001-01-01', '{ "customer": "John Does"}', '{"tags": ["tag1", "tag2"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '6 years 5 months 4 days 3 hours 2 minutes 1 second');
--Testcase 22:
INSERT INTO tntbl4 VALUES (6, 'test', false, DEFAULT, 2000, 'test', 'test', 200.0, 0);

--Testcase 23:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 24:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 25:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (1, 'ex');
--Testcase 26:
INSERT INTO tntbl4 (c1) VALUES (1, 2);
--Testcase 27:
INSERT INTO tntbl4 (c1) VALUES (DEFAULT, DEFAULT);

--Testcase 28:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- VALUES test
--
--Testcase 29:
INSERT INTO tntbl4 VALUES(1, '40', true, 2.0, 2000, 'value 1'), (-1, DEFAULT, true, 4.0, 4000, 'value 2'),
    ((SELECT 20), 'fun!', false, (SELECT i FROM (VALUES(3.0)) as foo (i)), 3000, 'VALUES are fun!');

--Testcase 30:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- TOASTed value test
--
--Testcase 31:
INSERT INTO tntbl4 VALUES(30, repeat('x', 25));

--Testcase 32:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- INSERT with IN feature
--
--Testcase 33:
INSERT INTO tntbl4 IN ('/postgres_svr/') VALUES (12, '_test', true, 5.0, 5000);

--Testcase 34:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 35:
INSERT INTO tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') VALUES (13, '_infea', true, 6.0, 6000);

--Testcase 36:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- UPDATE
--
--Testcase 37:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 38:
UPDATE tntbl4 SET c3 = DEFAULT, c6 = DEFAULT;

--Testcase 39:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-- aliases for the UPDATE target table
--Testcase 40:
UPDATE tntbl4 AS t SET c5 = 10000 WHERE t.c1 = 20;

--Testcase 41:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 42:
UPDATE tntbl4 t SET c5 = t.c5 + 10 WHERE t.c1 = 20;

--Testcase 43:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- Test VALUES in FROM
--

--Testcase 44:
UPDATE tntbl4 SET c1 = v.i FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--Testcase 45:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-- fail, wrong data type:
--Testcase 46:
UPDATE tntbl4 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 47:
INSERT INTO tntbl4 SELECT c1 + 10, c2 || 'next', c3 != true FROM tntbl4;
--Testcase 48:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 49:
UPDATE tntbl4 SET (c2 , c1, c4) = ('bugle', c1 + 10, DEFAULT) WHERE c2 = 'fun!';
--Testcase 50:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
--Testcase 51:
UPDATE tntbl4 SET (c2, c5) = ('car', c1 + c5), c1 = c1 + 10 WHERE c1 = 30;
--Testcase 52:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
-- fail, multi assignment to same column:
--Testcase 53:
UPDATE tntbl4 SET (c6, c8) = ('car', c4 + c8), c8 = c4 + 1.0 WHERE c1 = 40;

-- uncorrelated sub-SELECT:
--Testcase 54:
UPDATE tntbl4
  SET (c9, c1) = (SELECT c1, c9 FROM tntbl4 where c1 = 40 and c2 = 'car')
  WHERE c5 = 1000 AND c4 = 2.0;
--Testcase 55:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
-- correlated sub-SELECT:
--Testcase 56:
UPDATE tntbl4 o
  SET (c9, c4) = (SELECT c9+1, c4 FROM tntbl4 i
               where i.c9=o.c9 and i.c4=o.c4 and i.c1 is not distinct FROM o.c1);
--Testcase 57:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
-- fail, multiple rows supplied:
--Testcase 58:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4);
-- set to null if no rows supplied:
--Testcase 59:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4 where c5 = 2000)
  WHERE c9 = 127;
--Testcase 60:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
-- *-expansion should work in this context:
--Testcase 61:
UPDATE tntbl4 SET (c1, c9) = ROW(v.*) FROM (VALUES(20, 100)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 62:
UPDATE tntbl4 SET (c1, c9) = (v.*) FROM (VALUES(20, 101)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 63:
UPDATE tntbl4 AS t SET c9 = tntbl4.c9 + 10 WHERE t.c1 = 40;

-- Make sure that we can update to a TOASTed value.
--Testcase 64:
UPDATE tntbl4 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 65:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 66:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 67:
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 68:
SELECT c1, c5, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- Check behavior of disable_transaction_feature_check
--
--Testcase 82:
ALTER FOREIGN TABLE tntbl4 OPTIONS (disable_transaction_feature_check 'true');

--
-- UPDATE with IN feature
--
--Testcase 69:
UPDATE tntbl4 IN ('/postgres_svr/') SET c8 = 56563.1212;

SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 70:
UPDATE tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') SET c8 = 22.2;

SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 71:
DELETE FROM tntbl4 AS dt WHERE dt.c1 > 75;

--Testcase 72:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 73:
DELETE FROM tntbl4 dt WHERE tntbl4.c1 > 45;

--Testcase 74:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

-- delete a row with a TOASTed value
--Testcase 75:
DELETE FROM tntbl4 WHERE c1 > 25;

--Testcase 76:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--
-- DELETE with IN feature
--
--Testcase 77:
DELETE FROM tntbl4 IN ('/postgres_svr/') WHERE c1 = 10;

--Testcase 78:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
--Testcase 79:
DELETE FROM tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/', '/griddb_svr/') WHERE c5 = 3000;

--Testcase 80:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;

--Testcase 81:
ALTER FOREIGN TABLE tntbl4 OPTIONS (SET disable_transaction_feature_check 'false');

--
-- Test with optional options: tntbl4
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 83:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$');  -- duplicate key
--Testcase 84:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT DO NOTHING; -- works

--Testcase 85:
SELECT * FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
--Testcase 86:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 87:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO UPDATE SET c4 = 5.0; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 88:
CREATE VIEW rw_view AS SELECT * FROM tntbl4
  WHERE c1 < c5 ORDER BY c1 WITH CHECK OPTION;
--Testcase 89:
\d+ rw_view
--Testcase 90:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 0);
--Testcase 91:
INSERT INTO rw_view(c1, c5) VALUES (15, 0); -- should fail
--Testcase 92:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 3000);
--Testcase 93:
INSERT INTO rw_view(c1, c5) VALUES (15, 3000); -- ok
--Testcase 94:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5;
--Testcase 95:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 96:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 97:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 98:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 99:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY c1, c2, c3, c4, c5;
--Testcase 100:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 101:
INSERT INTO tntbl4 VALUES (70, '0000', true, 5.0, 5000) RETURNING *;
--Testcase 102:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5) VALUES (80, '_key_', false, 4.0, 6000) RETURNING c1, c2, c3;
--Testcase 103:
UPDATE tntbl4 SET c4 = 7.0 WHERE c1 = 70 AND c3 = true RETURNING (tntbl4), *;
--Testcase 104:
DELETE FROM tntbl4 WHERE c3 = true RETURNING c1, c2, c3;
--Testcase 105:
DELETE FROM tntbl4 RETURNING *;
--Clean
DELETE FROM tntbl4__postgres_svr__0;
DELETE FROM tntbl4__postgres_svr_2__0;
--Reset data
INSERT INTO tntbl4__postgres_svr__0 VALUES (10, 'text', true, 10.0, 1000, 'char array', 'varchar array', -1.0, 12, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '2001-01-01', '{"product": "test","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');
INSERT INTO tntbl4__postgres_svr_2__0 VALUES (20, 'texttext', false, -10.0, -1000, 'char array', 'varchar array', 1.0, 1, '2005-10-19 10:23:54', '2005-10-19 10:23:54+02', '2001-01-01', '{"product": "sample","quantity": 1}', '{"name": "paintings", "tags": ["Scene", "Portrait"], "finished": false }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '1 year 3 hours 20 minutes');
--Testcase 106:
DROP FOREIGN TABLE tntbl4 CASCADE;
--Testcase 107:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 108:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 109:
DROP SERVER pgspider_svr CASCADE;
--Testcase 110:
DROP EXTENSION pgspider_core_fdw CASCADE;
