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
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER1);
--Testcase 6:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 7:
CREATE EXTENSION mongo_fdw;

--Testcase 8:
CREATE SERVER mongo_svr FOREIGN DATA WRAPPER mongo_fdw
  OPTIONS (address :MONGO_HOST, port :MONGO_PORT);
--Testcase 9:
CREATE USER MAPPING FOR public SERVER mongo_svr OPTIONS (username :MONGO_USER, password :MONGO_PASS);

--Testcase 10:
CREATE FOREIGN TABLE tntbl2 (_id name, c1 int, c2 varchar(255), c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_core_svr;

--Testcase 11:
CREATE FOREIGN TABLE tntbl2__mongo_svr__0 (_id name, c1 int, c2 varchar(255), c3 boolean, c4 double precision, c5 bigint) SERVER mongo_svr OPTIONS (database 'mongo_pg_modify', collection 'tntbl2');
DELETE FROM tntbl2__mongo_svr__0;

--Testcase 12:
SELECT c1, c2, c3, c4, c5 FROM tntbl2;
--Testcase 13:
SELECT c1, c2, c3, c4, c5 FROM tntbl2__mongo_svr__0;

-----------------------------------------------------------------------------------
-- *** Start test for tntbl2 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 14:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 15:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 16:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 17:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 18:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 19:
SELECT c1, c2, c3, c4, c5 FROM tntbl2;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 20:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 21:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 22:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 23:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 24:
SELECT c1, c2, c3, c4, c5 FROM tntbl2;

--
-- VALUES test
--
--Testcase 25:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 26:
SELECT c1, c2, c3, c4, c5 FROM tntbl2;

--
-- TOASTed value test
--
--Testcase 27:
INSERT INTO tntbl2 VALUES(repeat('a', 255), 30, repeat('x', 255), true, 512.0, 2000);

--Testcase 28:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2;

--
-- INSERT with IN feature
--
--Testcase 29:
INSERT INTO tntbl2 IN ('/pgspider_core_svr/pgspider_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 30:
INSERT INTO tntbl2 IN ('/pgspider_core_svr/pgspider_svr/dynamodb_svr/', '/pgspider_core_svr/pgspider_svr/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 31:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 32:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 33:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

-- aliases for the UPDATE target table
--Testcase 34:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 35:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

--Testcase 36:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 37:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--
-- Test VALUES in FROM
--

--Testcase 38:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 39:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

-- fail, wrong data type:
--Testcase 40:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 41:
INSERT INTO tntbl2 (SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2 ORDER BY 1, 2, 3);
--Testcase 42:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

--Testcase 43:
UPDATE tntbl2 SET (c1, c2) = (c1+11, DEFAULT) WHERE c3 = true;
--Testcase 44:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 45:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 46:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- fail, multi assignment to same column:
--Testcase 47:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 48:
UPDATE tntbl2
  SET (c1, c3) = (SELECT c1, c3 FROM tntbl2 where c1 = 1010 and c2 = 'car')
  WHERE c5 = 1000 AND c1 = 21;
--Testcase 49:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- correlated sub-SELECT:
--Testcase 50:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2);
--Testcase 51:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- fail, multiple rows supplied:
--Testcase 52:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2);
-- set to null if no rows supplied:
--Testcase 53:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 54:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- *-expansion should work in this context:
--Testcase 55:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 56:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 57:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 58:
UPDATE tntbl2 SET c2 = repeat('x', 255) WHERE c2 = 'car';
--Testcase 59:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 60:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 61:
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 62:
SELECT c1, c5, char_length(c2) FROM tntbl2;
--
-- UPDATE with IN feature
--
--Testcase 63:
UPDATE tntbl2 IN ('/pgspider_core_svr/pgspider_svr/') SET c4 = 56563.1212;
--Testcase 64:
UPDATE tntbl2 IN ('/pgspider_core_svr/pgspider_svr/odbc_post_svr/', '/pgspider_core_svr/pgspider_svr/jdbc_mysql_svr/') SET c4 = 22.2;
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
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2;

-- delete a row with a TOASTed value
--Testcase 68:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 69:
SELECT c1, char_length(_id) FROM tntbl2;
--
-- DELETE with IN feature
--
--Testcase 70:
DELETE FROM tntbl2 IN ('/pgspider_core_svr/pgspider_svr/') WHERE c1 = 10;
--Testcase 71:
DELETE FROM tntbl2 IN ('/pgspider_core_svr/pgspider_svr/dynamodb_svr/', '/pgspider_core_svr/pgspider_svr/odbc_post_svr/', '/pgspider_core_svr/pgspider_svr/griddb_svr/') WHERE c5 = 4000;

-- *** Finish test for tntbl2 *** --
-----------------------------------------------------------------------------------
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
CREATE VIEW rw_view AS SELECT c1, c2, c3, c4, c5 FROM tntbl2
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
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
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
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
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

--
-- Test case bulk insert
--
--Clean
--Testcase 110:
DELETE FROM tntbl2;
--Testcase 111:
SELECT * FROM tntbl2;

SET client_min_messages = INFO;
-- Manual config: batch_size server = 5, batch_size table = 6, batch_size of FDW not set, insert 10 records
-- mongo_fdw not support batch_size
--Testcase 112:
-- ALTER SERVER pgspider_svr OPTIONS (ADD batch_size '5');

--Testcase 113:
INSERT INTO tntbl2
	SELECT to_char(id, 'FM00000'), id, 'foo', true, id/10, id * 1000	FROM generate_series(1, 10) id;
--Testcase 114:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1,2;

-- Auto config: batch_size of FDW = 10, insert 25 records
DELETE FROM tntbl2;
--Testcase 115:
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);

--Testcase 116:
INSERT INTO tntbl2
	SELECT to_char(id, 'FM00000'), id, 'foo', true, id/10, id * 1000	FROM generate_series(1, 25) id;
--Testcase 117:
SELECT c1, c2, c3, c4, c5, __spd_url FROM tntbl2 ORDER BY 1,2;

--Clean
DELETE FROM tntbl2;
--Reset data
INSERT INTO tntbl2 (c1, c2, c3, c4, c5) VALUES (1, 'foo', true, -1928.121, 1000);
INSERT INTO tntbl2 (c1, c2, c3, c4, c5) VALUES (2, 'varchar', false, 2000.0, 2000);
--Verify data
SELECT c1, c2, c3, c4, c5 FROM tntbl2;
--Testcase 105:
DROP FOREIGN TABLE tntbl2 CASCADE;
--Testcase 106:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 107:
DROP EXTENSION mongo_fdw CASCADE;
--Testcase 108:
DROP SERVER pgspider_core_svr CASCADE;
--Testcase 109:
DROP EXTENSION pgspider_core_fdw CASCADE;
