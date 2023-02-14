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
-- *** Start test for tntbl3 *** --

-- Create multi tenant tables
--Testcase 12:
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 real, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr;
--Testcase 13:
CREATE FOREIGN TABLE tntbl3__odbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER odbc_mysql_svr OPTIONS (schema :MYSQL_DB_NAME1, table 'tntbl3');
--Testcase 14:
CREATE FOREIGN TABLE tntbl3__odbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER odbc_post_svr OPTIONS (table 'tntbl3');

-- Reset data of remote table before test
DELETE FROM tntbl3__odbc_mysql_svr__0;
DELETE FROM tntbl3__odbc_post_svr__0;
INSERT INTO tntbl3__odbc_post_svr__0 VALUES ('odbc postgres', 1, 1.1, 100.0, 10000);
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 15:
Set pgspider_core_fdw.throw_error_ifdead to false;

--Testcase 16:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('@', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 17:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 18:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('_4', DEFAULT, 5.0, DEFAULT);
--Testcase 19:
INSERT INTO tntbl3 VALUES ('test1', DEFAULT, 5.0, 600.0, 1000);
--Testcase 20:
INSERT INTO tntbl3 VALUES ('test2', DEFAULT, 7.0);

--Testcase 21:
SELECT * FROM tntbl3 ORDER BY _id;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 22:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong1', DEFAULT, DEFAULT);
--Testcase 23:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong2', 1, 2.0);
--Testcase 24:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong3', 1, 2);
--Testcase 25:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong4',DEFAULT, DEFAULT);

--Testcase 26:
SELECT * FROM tntbl3 ORDER BY _id;

--
-- VALUES test
--
--Testcase 27:
INSERT INTO tntbl3 VALUES('test3', 10, 2.0, 20.0, 2000), ('test4', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test5'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 28:
SELECT * FROM tntbl3 ORDER BY _id;

--
-- TOASTed value test
--
--Testcase 29:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 30:
SELECT c1, c2, _id FROM tntbl3 ORDER BY _id;

--
-- INSERT with IN feature
--
--Testcase 31:
INSERT INTO tntbl3 IN ('/sqlite_svr/') VALUES ('_test', 10, 5.0, 50.0, 5000);
--Testcase 32:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);

--
-- UPDATE
--
--Testcase 33:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
--Testcase 34:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 35:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;

-- aliases for the UPDATE target table
--Testcase 36:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 37:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;

--Testcase 38:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 39:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;

--
-- Test VALUES in FROM
--

--Testcase 40:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 41:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;

-- fail, wrong data type:
--Testcase 42:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 43:
INSERT INTO tntbl3 SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3;
--Testcase 44:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;

--Testcase 45:
UPDATE tntbl3 SET (_id, c1, c2) = ('bugle', c1 + 11, DEFAULT) WHERE c2 = 2.0;
--Testcase 46:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
--Testcase 47:
UPDATE tntbl3 SET (_id, c3) = ('car1', c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 48:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
-- fail, multi assignment to same column:
--Testcase 49:
UPDATE tntbl3 SET (_id, c2) = ('car2', c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 50:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'car1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 51:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
-- correlated sub-SELECT:
--Testcase 52:
UPDATE tntbl3 o
  SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
               where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 53:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
-- fail, multiple rows supplied:
--Testcase 54:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 55:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 56:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
-- *-expansion should work in this context:
--Testcase 57:
UPDATE tntbl3 SET (c1, c3) = ROW(v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 58:
UPDATE tntbl3 SET (c1, c3) = (v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 59:
UPDATE tntbl3 AS t SET c1 = tntbl3.c1 + 10 WHERE t.c2 = 2.0;

-- Make sure that we can update to a TOASTed value.
--Testcase 60:
UPDATE tntbl3 SET _id = repeat('x', 25) WHERE c1 = 11;
--Testcase 61:
SELECT c1, c2, _id FROM tntbl3 ORDER BY _id;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 62:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 63:
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 64:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
--
-- UPDATE with IN feature
--
--Testcase 65:
UPDATE tntbl3 IN ('/odbc_post_svr/') SET c3 = 56563.0;
--Testcase 66:
UPDATE tntbl3 IN ('/jdbc_post_svr/', '/odbc_mysql_svr/', '/oracle_svr/') SET c3 = 222.0;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 67:
DELETE FROM tntbl3 AS dt WHERE dt.c1 > 35;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 68:
DELETE FROM tntbl3 dt WHERE tntbl3.c1 > 25;

--Testcase 69:
SELECT c1, c3, _id FROM tntbl3 ORDER BY _id;

-- delete a row with a TOASTed value
--Testcase 70:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 71:
SELECT c1, c3, _id FROM tntbl3 ORDER BY _id;

--
-- DELETE with IN feature
--
--Testcase 72:
DELETE FROM tntbl3 IN ('/odbc_mysql_svr/') WHERE c1 IS NULL;
--Testcase 73:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

--Testcase 74:
Set pgspider_core_fdw.throw_error_ifdead to true;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 75:
ALTER FOREIGN TABLE tntbl3 OPTIONS (disable_transaction_feature_check 'false');

--Testcase 76:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 77:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 78:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 79:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 80:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 81:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 82:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 83:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 84:
UPDATE tntbl3 IN ('/odbc_mysql_svr/') SET c3 = 56.0;
--Testcase 85:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 86:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 87:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 88:
DELETE FROM tntbl3 IN ('/odbc_post_svr/') WHERE c3 = 56.0;
--Testcase 89:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 90:
ALTER FOREIGN TABLE tntbl3 OPTIONS (SET disable_transaction_feature_check 'true');
--
-- Test with __spd_url
--
--Testcase 91:
DELETE FROM tntbl3 WHERE __spd_url = '/odbc_mysql_svr/';
--Testcase 92:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 93:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
--Testcase 94:
INSERT INTO tntbl3__odbc_post_svr__0 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 95:
INSERT INTO tntbl3__odbc_mysql_svr__0 VALUES(repeat('y', 10), 20, 4.0, 40.0, 5000);
--Testcase 96:
INSERT INTO tntbl3(_id, c2, c3) SELECT _id || '_foo', c2, c3 FROM tntbl3 WHERE __spd_url IN ('/odbc_mysql_svr/', '/mysql_svr/', '/griddb_svr/');
--Testcase 97:
INSERT INTO tntbl3(_id, c2, c3) SELECT _id || '_bar', c2, c3 FROM tntbl3 WHERE __spd_url = '/odbc_post_svr/';
--Testcase 98:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 99:
UPDATE tntbl3 SET _id = _id || '@' WHERE __spd_url = '/odbc_post_svr/';
--Testcase 100:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 101:
DELETE FROM tntbl3;
--Testcase 102:
INSERT INTO tntbl3 SELECT * FROM tntbl3;
--Testcase 103:
SELECT * FROM tntbl3 ORDER BY _id;
--Testcase 104:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 105:
SELECT _id, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY _id HAVING _id IS NOT NULL LIMIT 5;
--Testcase 106:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/odbc_post_svr/');
--Testcase 107:
SELECT * FROM tntbl3 ORDER BY _id;

--
-- Test with optional options: tntbl3
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 108:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12);  -- duplicate key
--Testcase 109:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 110:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 111:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 112:
CREATE VIEW rw_view AS SELECT * FROM tntbl3
  WHERE c2 < c3 WITH CHECK OPTION;
--Testcase 113:
\d+ rw_view
--Testcase 114:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0);
--Testcase 115:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0); -- should fail
--Testcase 116:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000);
--Testcase 117:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000); -- ok
--Testcase 118:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
--Testcase 119:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 10000;
--Testcase 120:
UPDATE rw_view SET c2 = c2 + 10000; -- should fail
--Testcase 121:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 122:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 123:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id;
--Testcase 124:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 125:
INSERT INTO tntbl3 VALUES ('0000', 20, 5.0, 50.0, 5000) RETURNING *;
--Testcase 126:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_key_', 30, 4.0, 50.0, 6000) RETURNING c1, c2, c3;
--Testcase 127:
UPDATE tntbl3 SET c2 = 7.0 WHERE c1 = 20 AND c3 = 50.0 RETURNING (tntbl3), *;
--Testcase 128:
DELETE FROM tntbl3 WHERE c3 = 50.0 RETURNING _id, c1, c2;
--Testcase 129:
DELETE FROM tntbl3 RETURNING *;

-- *** Finish test for tntbl3 *** --

--Clean
DELETE FROM tntbl3__odbc_mysql_svr__0;
DELETE FROM tntbl3__odbc_post_svr__0;
--Reset data
INSERT INTO tntbl3__odbc_post_svr__0 VALUES ('odbc postgres', 1, 1.1, 100.0, 10000);
--Testcase 130:
DELETE FROM tntbl3;
--Testcase 131:
DROP FOREIGN TABLE tntbl3, tntbl3__odbc_post_svr__0, tntbl3__odbc_mysql_svr__0 CASCADE;
--Testcase 132:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 133:
DROP EXTENSION odbc_fdw CASCADE;
--Testcase 134:
DROP SERVER pgspider_svr CASCADE;
--Testcase 135:
DROP EXTENSION pgspider_core_fdw CASCADE;
