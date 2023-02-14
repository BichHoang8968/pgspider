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
CREATE EXTENSION griddb_fdw;
--Testcase 8:
CREATE SERVER griddb_svr FOREIGN DATA WRAPPER griddb_fdw OPTIONS (host :GRIDDB_HOST, port :GRIDDB_PORT, clustername 'griddbfdwTestCluster');
--Testcase 9:
CREATE USER MAPPING FOR public SERVER griddb_svr OPTIONS (username :GRIDDB_USER, password :GRIDDB_PASS);
-- Create multi tenant tables
-- tntbl1
--Testcase 10:
CREATE FOREIGN TABLE tntbl2 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_svr;
-- Foreign tables
--Testcase 11:
CREATE FOREIGN TABLE tntbl2__griddb_svr__0 (_id text OPTIONS (rowkey 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER griddb_svr OPTIONS (table_name 'tntbl2');

-- Reset data of remote table before test
DELETE FROM tntbl2__griddb_svr__0;

-- SELECT FROM table if there is any record
--Testcase 12:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 13:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 14:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 15:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 16:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 17:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 18:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 19:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 20:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 21:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 22:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 23:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 24:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 25:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 26:
INSERT INTO tntbl2 VALUES(repeat('a', 25), 30, repeat('x', 25), true, 512.0, 2000);

--Testcase 27:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

--
-- UPDATE
--
--Testcase 30:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 31:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 32:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 33:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 34:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 35:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 36:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--
-- Test VALUES in FROM
--

--Testcase 37:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 38:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 39:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 40:
INSERT INTO tntbl2 SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2;
--Testcase 41:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 42:
UPDATE tntbl2 SET (c1, c2) = (c1+11, DEFAULT) WHERE c3 = true;
--Testcase 43:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 44:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 45:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- fail, multi assignment to same column:
--Testcase 46:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 47:
UPDATE tntbl2
  SET (c1, c3) = (SELECT c1, c3 FROM tntbl2 where c1 = 1010 and c2 = 'car')
  WHERE c5 = 1000 AND c1 = 21;
--Testcase 48:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
--Testcase 49:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2);
--Testcase 50:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 51:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2);
-- set to null if no rows supplied:
--Testcase 52:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 53:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:
--Testcase 54:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 55:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 56:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 57:
UPDATE tntbl2 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 58:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 59:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1 AND s.c1 != 0)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 60:
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1 AND s.c1 != 0)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 61:
SELECT c1, c5, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 62:
UPDATE tntbl2 IN ('/griddb_svr/') SET c4 = 56563.1212;
--Testcase 63:
UPDATE tntbl2 IN ('/odbc_post_svr/', '/jdbc_mysql_svr/') SET c4 = 22.2;

--
-- INSERT with IN feature
--
--Testcase 28:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 29:
INSERT INTO tntbl2 IN ('/dynamodb_svr/', '/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 64:
DELETE FROM tntbl2 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 65:
DELETE FROM tntbl2 dt WHERE tntbl2.c1 > 25;

--Testcase 66:
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 67:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 68:
SELECT c1, char_length(_id) FROM tntbl2 ORDER BY 1, 2;
--
-- DELETE with IN feature
--
--Testcase 69:
DELETE FROM tntbl2 IN ('/griddb_svr/') WHERE c1 = 10;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 70:
ALTER FOREIGN TABLE tntbl2 OPTIONS (disable_transaction_feature_check 'false');
--Testcase 71:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('121', 29, 'DEFAULT', true, 4.0, 4000);
--Testcase 72:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2', true);
--Testcase 73:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('xin3', 10, 'tst_in_feature', true, 5.0, 5000);
--Testcase 74:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 75:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 7000;
--Testcase 76:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 77:
DELETE FROM tntbl2 WHERE c2 = '2';
--Testcase 78:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 79:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 80:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 81:
ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');

--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 82:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12);  -- duplicate key
--Testcase 83:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 84:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 85:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 86:
CREATE VIEW rw_view AS SELECT * FROM tntbl2
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 87:
\d+ rw_view
--Testcase 88:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0);
--Testcase 89:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0); -- should fail
--Testcase 90:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000);
--Testcase 91:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000); -- ok
--Testcase 92:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 93:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 94:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 95:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 96:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 97:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 98:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 99:
INSERT INTO tntbl2 VALUES ('00:05:00', 20, '2022-05-16', false, 50.0, 7000) RETURNING *;
--Testcase 100:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('_key_', 30, 'test', true, 50.0, 8000) RETURNING c1, c4, c5;
--Testcase 101:
UPDATE tntbl2 SET c2 = '2100-01-01 10:00:00+01' WHERE c1 = 20 AND c3 = false RETURNING (tntbl2), *;
--Testcase 102:
DELETE FROM tntbl2 WHERE c4 = 50.0 RETURNING _id, c1, c2;
--Testcase 103:
DELETE FROM tntbl2 RETURNING *;

--Clean
DELETE FROM tntbl2;

--Testcase 104:
DROP FOREIGN TABLE tntbl2 CASCADE;
--Testcase 105:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 106:
DROP EXTENSION griddb_fdw CASCADE;
--Testcase 107:
DROP SERVER pgspider_svr CASCADE;
--Testcase 108:
DROP EXTENSION pgspider_core_fdw CASCADE;
