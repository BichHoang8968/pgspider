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
CREATE EXTENSION odbc_fdw;
--Testcase 8:
CREATE SERVER odbc_mysql_svr FOREIGN DATA WRAPPER odbc_fdw OPTIONS (odbc_DRIVER :ODBC_MYSQL_DRIVERNAME, odbc_SERVER :ODBC_SERVER, odbc_port :ODBC_MYSQL_PORT, odbc_DATABASE :MYSQL_DB_NAME1);
--Testcase 9:
CREATE USER mapping for public SERVER odbc_mysql_svr OPTIONS(odbc_UID :ODBC_MYSQL_USER, odbc_PWD :ODBC_MYSQL_PASS);
--Testcase 10:
CREATE SERVER odbc_post_svr FOREIGN DATA WRAPPER odbc_fdw OPTIONS (odbc_DRIVER :ODBC_POSTGRES_DRIVERNAME, odbc_SERVER :ODBC_SERVER, odbc_port :ODBC_POSTGRES_PORT, odbc_DATABASE :ODBC_DATABASE);
--Testcase 11:
CREATE USER mapping for public SERVER odbc_post_svr OPTIONS(odbc_UID :ODBC_POSTGRES_USER, odbc_PWD :ODBC_POSTGRES_PASS);
-- Create multi tenant tables
-- tntbl1
--Testcase 12:
CREATE FOREIGN TABLE tntbl2 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_svr;
-- Foreign tables
--Testcase 13:
CREATE FOREIGN TABLE tntbl2__odbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER odbc_post_svr OPTIONS (table 'tntbl2');

-- Reset data of remote table before test
DELETE FROM tntbl2__odbc_post_svr__0;
INSERT INTO tntbl2__odbc_post_svr__0 VALUES ('odbc', 1, 'odbc text', true, 100.0, 10000);

-- SELECT FROM table if there is any record
--Testcase 14:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 15:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 16:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 17:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 18:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 19:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 20:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 21:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 22:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 23:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 24:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 25:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 26:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 27:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 28:
INSERT INTO tntbl2 VALUES(repeat('a', 25), 30, repeat('x', 25), true, 512.0, 2000);

--Testcase 29:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

--
-- UPDATE
--
--Testcase 32:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 33:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 34:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 35:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 36:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 37:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 38:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--
-- Test VALUES in FROM
--

--Testcase 39:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 40:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 41:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 42:
INSERT INTO tntbl2 SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2;
--Testcase 43:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 44:
UPDATE tntbl2 SET (_id, c1, c2) = (_id || 'bugle', c1+11, DEFAULT) WHERE c3 = true;
--Testcase 45:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 46:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 47:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- fail, multi assignment to same column:
--Testcase 48:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 49:
UPDATE tntbl2
  SET (c1, c3) = (SELECT c1, c3 FROM tntbl2 where c1 = 1010 and c2 = 'car')
  WHERE c5 = 1000 AND c1 = 21;
--Testcase 50:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
--Testcase 51:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2);
--Testcase 52:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 53:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 ORDER BY 1, 2, 3);
-- set to null if no rows supplied:
--Testcase 54:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 55:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:
--Testcase 56:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 57:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 58:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 59:
UPDATE tntbl2 SET _id = _id || repeat('x', 25) WHERE c2 = 'car';
--Testcase 60:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 61:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
-- UPDATE tntbl2 t
--   SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 62:
SELECT c1, c5, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 63:
UPDATE tntbl2 IN ('/odbc_post_svr/') SET c4 = 56563.1212;
--Testcase 64:
UPDATE tntbl2 IN ('/odbc_post_svr/', '/jdbc_mysql_svr/') SET c4 = 22.2;

--
-- INSERT with IN feature
--
--Testcase 30:
INSERT INTO tntbl2 IN ('/odbc_post_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 31:
INSERT INTO tntbl2 IN ('/dynamodb_svr/', '/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 65:
DELETE FROM tntbl2 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 66:
DELETE FROM tntbl2 dt WHERE tntbl2.c1 > 25;

--Testcase 67:
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 68:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 69:
SELECT c1, char_length(_id) FROM tntbl2 ORDER BY 1, 2;
--
-- DELETE with IN feature
--
--Testcase 70:
DELETE FROM tntbl2 IN ('/odbc_post_svr/') WHERE c1 = 10;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 71:
ALTER FOREIGN TABLE tntbl2 OPTIONS (disable_transaction_feature_check 'false');
--Testcase 72:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('121', 29, 'DEFAULT', true, 4.0, 4000);
--Testcase 73:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2', true);
--Testcase 74:
INSERT INTO tntbl2 IN ('/odbc_post_svr/') VALUES ('xin3', 10, 'tst_in_feature', true, 5.0, 5000);
--Testcase 75:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 76:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 7000;
--Testcase 77:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 78:
DELETE FROM tntbl2 WHERE c2 = '2';
--Testcase 79:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 80:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 81:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 82:
ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');

--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 83:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12);  -- duplicate key
--Testcase 84:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 85:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 86:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 87:
CREATE VIEW rw_view AS SELECT * FROM tntbl2
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 88:
\d+ rw_view
--Testcase 89:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0);
--Testcase 90:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0); -- should fail
--Testcase 91:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000);
--Testcase 92:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000); -- ok
--Testcase 93:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 94:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 95:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 96:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 97:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 98:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 99:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 100:
INSERT INTO tntbl2 VALUES ('00:05:00', 20, '2022-05-16', false, 50.0, 7000) RETURNING *;
--Testcase 101:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('_key_', 30, 'test', true, 50.0, 8000) RETURNING c1, c4, c5;
--Testcase 102:
UPDATE tntbl2 SET c2 = '2100-01-01 10:00:00+01' WHERE c1 = 20 AND c3 = false RETURNING (tntbl2), *;
--Testcase 103:
DELETE FROM tntbl2 WHERE c4 = 50.0 RETURNING _id, c1, c2;
--Testcase 104:
DELETE FROM tntbl2 RETURNING *;

-- test for mysql_odbc
-- *** Start test for tntbl3 *** --

--Testcase 105:
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 real, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr;
--Testcase 106:
CREATE FOREIGN TABLE tntbl3__odbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER odbc_mysql_svr OPTIONS (schema :MYSQL_DB_NAME1, table 'tntbl3');

--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 107:
Set pgspider_core_fdw.throw_error_ifdead to false;

--Testcase 108:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('@', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 109:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 110:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('_4', DEFAULT, 5.0, DEFAULT);
--Testcase 111:
INSERT INTO tntbl3 VALUES ('test1', DEFAULT, 5.0, 600.0, 1000);
--Testcase 112:
INSERT INTO tntbl3 VALUES ('test2', DEFAULT, 7.0);

--Testcase 113:
SELECT * FROM tntbl3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 114:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong1', DEFAULT, DEFAULT);
--Testcase 115:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong2', 1, 2.0);
--Testcase 116:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong3', 1, 2);
--Testcase 117:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong4',DEFAULT, DEFAULT);

--Testcase 118:
SELECT * FROM tntbl3;

--
-- VALUES test
--
--Testcase 119:
INSERT INTO tntbl3 VALUES('test3', 10, 2.0, 20.0, 2000), ('test4', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test5'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 120:
SELECT * FROM tntbl3;

--
-- TOASTed value test
--
--Testcase 121:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 122:
SELECT c1, c2, _id FROM tntbl3;

--
-- INSERT with IN feature
--
--Testcase 123:
INSERT INTO tntbl3 IN ('/sqlite_svr/') VALUES ('_test', 10, 5.0, 50.0, 5000);
--Testcase 124:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);

--
-- UPDATE
--
--Testcase 125:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
--Testcase 126:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 127:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;

-- aliases for the UPDATE target table
--Testcase 128:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 129:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;

--Testcase 130:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 131:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;

--
-- Test VALUES in FROM
--

--Testcase 132:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 133:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;

-- fail, wrong data type:
--Testcase 134:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

-- Commmented, fail due to oracle_fdw. Not reported yet.
--Testcase 135:
INSERT INTO tntbl3 SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3;
--Testcase 136:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;

--Testcase 137:
UPDATE tntbl3 SET (_id, c1, c2) = ('bugle', c1 + 11, DEFAULT) WHERE c2 = 2.0;
--Testcase 138:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
--Testcase 139:
UPDATE tntbl3 SET (_id, c3) = ('car1', c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 140:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
-- fail, multi assignment to same column:
--Testcase 141:
UPDATE tntbl3 SET (_id, c2) = ('car2', c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 142:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'car1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 143:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
-- correlated sub-SELECT:
--Testcase 144:
UPDATE tntbl3 o
  SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
               where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 145:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
-- fail, multiple rows supplied:
--Testcase 146:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 147:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 148:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
-- *-expansion should work in this context:
--Testcase 149:
UPDATE tntbl3 SET (c1, c3) = ROW(v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 150:
UPDATE tntbl3 SET (c1, c3) = (v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 151:
UPDATE tntbl3 AS t SET c1 = tntbl3.c1 + 10 WHERE t.c2 = 2.0;

-- Make sure that we can update to a TOASTed value.
--Testcase 152:
UPDATE tntbl3 SET _id = repeat('x', 25) WHERE c1 = 11;
--Testcase 153:
SELECT c1, c2, _id FROM tntbl3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 154:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 155:
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 156:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
--
-- UPDATE with IN feature
--
--Testcase 157:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56563.0;
--Testcase 158:
UPDATE tntbl3 IN ('/jdbc_post_svr/', '/odbc_mysql_svr/', '/oracle_svr/') SET c3 = 222.0;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 159:
DELETE FROM tntbl3 AS dt WHERE dt.c1 > 35;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 160:
DELETE FROM tntbl3 dt WHERE tntbl3.c1 > 25;

--Testcase 161:
SELECT c1, c3, _id FROM tntbl3;

-- delete a row with a TOASTed value
--Testcase 162:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 163:
SELECT c1, c3, _id FROM tntbl3;

--
-- DELETE with IN feature
--
--Testcase 164:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 165:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

--Testcase 166:
Set pgspider_core_fdw.throw_error_ifdead to true;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 167:
ALTER FOREIGN TABLE tntbl2 OPTIONS (disable_transaction_feature_check 'false');

--Testcase 168:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 169:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 170:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 171:
SELECT * FROM tntbl3;
--Testcase 172:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 173:
SELECT * FROM tntbl3;
--Testcase 174:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 175:
SELECT * FROM tntbl3;
--Testcase 176:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56.0;
--Testcase 177:
SELECT * FROM tntbl3;
--Testcase 178:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 179:
SELECT * FROM tntbl3;
--Testcase 180:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c3 = 56.0;
--Testcase 181:
SELECT * FROM tntbl3;
--Testcase 182:
ALTER FOREIGN TABLE tntbl2 OPTIONS (SET disable_transaction_feature_check 'true');
--
-- Test with __spd_url
--
--Testcase 183:
DELETE FROM tntbl3 WHERE __spd_url = '/odbc_mysql_svr/';
--Testcase 184:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 185:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
--Testcase 186:
INSERT INTO tntbl3__odbc_mysql_svr__0 VALUES(repeat('y', 10), 20, 4.0, 40.0, 5000);
--Testcase 187:
INSERT INTO tntbl3(_id, c2, c3) SELECT _id || '_foo', c2, c3 FROM tntbl3 WHERE __spd_url IN ('/odbc_mysql_svr/', '/mysql_svr/', '/griddb_svr/');
--Testcase 188:
INSERT INTO tntbl3(_id, c2, c3) SELECT _id || '_bar', c2, c3 FROM tntbl3 WHERE __spd_url = '/odbc_post_svr/';
--Testcase 189:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 190:
UPDATE tntbl3 SET _id = _id || '@' WHERE __spd_url = '/postgres_svr/';
--Testcase 191:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 192:
DELETE FROM tntbl3;
--Testcase 193:
INSERT INTO tntbl3 SELECT * FROM tntbl3;
--Testcase 194:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 195:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 196:
SELECT _id, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY _id HAVING _id IS NOT NULL LIMIT 5;
--Testcase 197:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/postgres_svr/');
--Testcase 198:
SELECT * FROM tntbl3 ORDER BY _id;
--
-- Test with optional options: tntbl3
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 199:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12);  -- duplicate key
--Testcase 200:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 201:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 202:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 203:
CREATE VIEW rw_view AS SELECT * FROM tntbl3
  WHERE c2 < c3 WITH CHECK OPTION;
--Testcase 204:
\d+ rw_view
--Testcase 205:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0);
--Testcase 206:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0); -- should fail
--Testcase 207:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000);
--Testcase 208:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000); -- ok
--Testcase 209:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
--Testcase 210:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 10000;
--Testcase 211:
UPDATE rw_view SET c2 = c2 + 10000; -- should fail
--Testcase 212:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 213:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 214:
SELECT _id, c1, c2, c3, c4 FROM tntbl3;
--Testcase 215:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 216:
INSERT INTO tntbl3 VALUES ('0000', 20, 5.0, 50.0, 5000) RETURNING *;
--Testcase 217:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_key_', 30, 4.0, 50.0, 6000) RETURNING c1, c2, c3;
--Testcase 218:
UPDATE tntbl3 SET c2 = 7.0 WHERE c1 = 20 AND c3 = 50.0 RETURNING (tntbl3), *;
--Testcase 219:
DELETE FROM tntbl3 WHERE c3 = 50.0 RETURNING _id, c1, c2;
--Testcase 220:
DELETE FROM tntbl3 RETURNING *;

-- *** Finish test for tntbl3 *** --

--Clean
--Testcase 221:
DELETE FROM tntbl2;
--Testcase 222:
DELETE FROM tntbl3;
--Reset data
INSERT INTO tntbl2 VALUES ('odbc', 1, 'odbc text', true, 100.0, 10000);
--Testcase 223:
DROP FOREIGN TABLE tntbl2, tntbl2__odbc_post_svr__0 CASCADE;
--Testcase 224:
DROP FOREIGN TABLE tntbl3, tntbl3__odbc_mysql_svr__0 CASCADE;
--Testcase 225:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 226:
DROP EXTENSION odbc_fdw CASCADE;
--Testcase 227:
DROP SERVER pgspider_svr CASCADE;
--Testcase 228:
DROP EXTENSION pgspider_core_fdw CASCADE;
