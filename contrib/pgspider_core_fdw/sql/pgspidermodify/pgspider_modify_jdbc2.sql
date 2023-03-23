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
--Testcase 7:
CREATE EXTENSION jdbc_fdw;
--Testcase 8:
CREATE SERVER jdbc_mysql_svr FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
drivername :JDBC_MYSQL_DRIVERNAME,
url :JDBC_MYSQL_URL,
querytimeout '15',
jarfile :JDBC_MYSQL_DRIVERPATH,
maxheapsize '600'
);
--Testcase 32:
CREATE USER MAPPING FOR public SERVER jdbc_mysql_svr OPTIONS(username :JDBC_MYSQL_USER, password :JDBC_MYSQL_PASS);
--Testcase 33:
CREATE SERVER jdbc_post_svr FOREIGN DATA WRAPPER jdbc_fdw OPTIONS(
drivername :JDBC_POSTGRES_DRIVERNAME,
url :JDBC_POSTGRES_URL,
querytimeout '15',
jarfile :JDBC_POSTGRES_DRIVERPATH,
maxheapsize '600'
);
--Testcase 9:
CREATE USER MAPPING FOR public SERVER jdbc_post_svr OPTIONS(username :JDBC_POSTGRES_USER, password :JDBC_POSTGRES_PASS);

-- Create multi tenant tables
-- tntbl3
--Testcase 10:
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 real, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr;

-- Foreign tables
--Testcase 11:
CREATE FOREIGN TABLE tntbl3__jdbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER jdbc_mysql_svr OPTIONS (table_name 'tntbl3');
CREATE FOREIGN TABLE tntbl3__jdbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER jdbc_post_svr OPTIONS (table_name 'tntbl3');

-- Reset data of remote table before test
DELETE FROM tntbl3__jdbc_mysql_svr__0;
DELETE FROM tntbl3__jdbc_post_svr__0;
INSERT INTO tntbl3__jdbc_post_svr__0 VALUES ('jdbc', 10, 10.0, 1000.0, 10000);
INSERT INTO tntbl3__jdbc_mysql_svr__0 VALUES ('jdbc_mysql', 10, 10.0, 1000.0, 10000);

SELECT * FROM tntbl3 ORDER BY c1, _id;

-----------------------------------------------------------------------------------
-- *** Start test for tntbl3 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 198:
Set pgspider_core_fdw.throw_error_ifdead to false;

INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('@', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 199:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 200:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('_4', DEFAULT, 5.0, DEFAULT);
--Testcase 201:
INSERT INTO tntbl3 VALUES ('test1', DEFAULT, 5.0, 600.0, 1000);
--Testcase 202:
INSERT INTO tntbl3 VALUES ('test2', DEFAULT, 7.0);

--Testcase 203:
SELECT * FROM tntbl3 ORDER BY c1, _id;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 204:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong1', DEFAULT, DEFAULT);
--Testcase 205:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong2', 1, 2.0);
--Testcase 206:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong3', 1, 2);
--Testcase 207:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong4',DEFAULT, DEFAULT);

--Testcase 208:
SELECT * FROM tntbl3 ORDER BY c1, _id;

--
-- VALUES test
--
--Testcase 209:
INSERT INTO tntbl3 VALUES('test3', 10, 2.0, 20.0, 2000), ('test4', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test5'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 210:
SELECT * FROM tntbl3 ORDER BY c1, _id;

--
-- TOASTed value test
--
--Testcase 211:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 212:
SELECT c1, c2, _id FROM tntbl3 ORDER BY c1, _id;

--
-- INSERT with IN feature
--
--Testcase 213:
INSERT INTO tntbl3 IN ('/sqlite_svr/') VALUES ('_test', 10, 5.0, 50.0, 5000);
--Testcase 214:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);

--
-- UPDATE
--
--Testcase 215:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
--Testcase 216:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 217:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;

-- aliases for the UPDATE target table
--Testcase 218:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 219:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;

--Testcase 220:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 221:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;

--
-- Test VALUES in FROM
--

--Testcase 222:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 223:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;

-- fail, wrong data type:
--Testcase 224:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 225:
-- Commmented, fail due to oracle_fdw. Not reported yet.
INSERT INTO tntbl3 (SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 226:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;

--Testcase 227:
UPDATE tntbl3 SET (_id, c1, c2) = ('bugle', c1 + 11, DEFAULT) WHERE c2 = 8.0;
--Testcase 228:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
--Testcase 229:
UPDATE tntbl3 SET (_id, c3) = (_id || 'car1', c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 230:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
-- fail, multi assignment to same column:
--Testcase 231:
UPDATE tntbl3 SET (_id, c2) = ('car2', c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 232:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'jdbccar1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 233:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
-- correlated sub-SELECT:
--Testcase 234:
UPDATE tntbl3 o
  SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
               where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 235:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
-- fail, multiple rows supplied:
--Testcase 236:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 237:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 238:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
-- *-expansion should work in this context:
--Testcase 239:
UPDATE tntbl3 SET (c1, c3) = ROW(v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 240:
UPDATE tntbl3 SET (c1, c3) = (v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 241:
UPDATE tntbl3 AS t SET c1 = tntbl3.c1 + 10 WHERE t.c2 = 2.0;

-- Make sure that we can update to a TOASTed value.
--Testcase 242:
UPDATE tntbl3 SET _id = repeat('x', 25) WHERE c1 = 20 and c2 = 41;
--Testcase 243:
SELECT c1, c2, _id FROM tntbl3 ORDER BY c1, _id;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 244:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 245:
UPDATE tntbl3 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 246:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY _id, c1;
--
-- UPDATE with IN feature
--
--Testcase 247:
UPDATE tntbl3 IN ('/jdbc_mysql_svr/') SET c3 = 56563.0;
--Testcase 248:
UPDATE tntbl3 IN ('/jdbc_post_svr/', '/odbc_mysql_svr/', '/oracle_svr/') SET c3 = 222.0;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 249:
DELETE FROM tntbl3 AS dt WHERE dt.c1 > 35;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 250:
DELETE FROM tntbl3 dt WHERE tntbl3.c1 > 25;

--Testcase 251:
SELECT c1, c3, _id FROM tntbl3 ORDER BY c1, c3, _id;

-- delete a row with a TOASTed value
--Testcase 252:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 253:
SELECT c1, c3, _id FROM tntbl3 ORDER BY c1, _id;

--
-- DELETE with IN feature
--
--Testcase 254:
DELETE FROM tntbl3 IN ('/jdbc_mysql_svr/') WHERE c1 = 10;
--Testcase 255:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 70:
ALTER FOREIGN TABLE tntbl3 OPTIONS (disable_transaction_feature_check 'false');

--Testcase 348:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_20', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 349:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_30', 3.0, DEFAULT);
--Testcase 350:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 351:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 352:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 353:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 354:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 355:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 356:
UPDATE tntbl3 IN ('/jdbc_mysql_svr/') SET c3 = 56.0;
--Testcase 357:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 358:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 359:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 360:
DELETE FROM tntbl3 IN ('/jdbc_mysql_svr/') WHERE c3 = 56.0;
--Testcase 361:
SELECT * FROM tntbl3 ORDER BY c1, _id;
-- Reset value of disable_transaction_feature_check
ALTER FOREIGN TABLE tntbl3 OPTIONS (SET disable_transaction_feature_check 'true');

--
--
-- Test with __spd_url
--
--Testcase 362:
DELETE FROM tntbl3 WHERE __spd_url = '/jdbc_mysql_svr/';
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 363:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 364:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000);
--Duplicate key column when INSERT with SELECT *. Expect error.
--Testcase 365:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 366:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 367:
UPDATE tntbl3 SET _id = _id || '@' WHERE __spd_url = '/jdbc_mysql_svr/';
--Testcase 368:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 369:
DELETE FROM tntbl3;
--Testcase 370:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 371:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--Testcase 372:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 373:
SELECT _id, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY _id HAVING _id IS NOT NULL LIMIT 5;
--Testcase 374:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/postgres_svr/');
--Testcase 375:
SELECT * FROM tntbl3 ORDER BY c1, _id;
--
-- Test with optional options: tntbl3
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 420:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12);  -- duplicate key
--Testcase 421:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 422:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 423:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 424:
CREATE VIEW rw_view AS SELECT * FROM tntbl3
  WHERE c2 < c3 WITH CHECK OPTION;
--Testcase 425:
\d+ rw_view
--Testcase 426:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0);
--Testcase 427:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0); -- should fail
--Testcase 428:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000);
--Testcase 429:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000); -- ok
--Testcase 430:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
--Testcase 431:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 10000;
--Testcase 432:
UPDATE rw_view SET c2 = c2 + 10000; -- should fail
--Testcase 433:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 434:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 435:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY c1, _id;
--Testcase 436:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 437:
INSERT INTO tntbl3 VALUES ('0000', 20, 5.0, 50.0, 5000) RETURNING *;
--Testcase 438:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_key_', 30, 4.0, 50.0, 6000) RETURNING c1, c2, c3;
--Testcase 439:
UPDATE tntbl3 SET c2 = 7.0 WHERE c1 = 20 AND c3 = 50.0 RETURNING (tntbl3), *;
--Testcase 440:
DELETE FROM tntbl3 WHERE c3 = 50.0 RETURNING _id, c1, c2;
--Testcase 441:
DELETE FROM tntbl3 RETURNING *;
-- *** Finish test for tntbl3 *** --

--
-- Test case bulk insert
--
--Clean
--Testcase 442:
DELETE FROM tntbl3;
--Testcase 443:
SELECT * FROM tntbl3;

SET client_min_messages = INFO;

-- Auto config: batch_size of FDW = 10, insert 30 records
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);

--Testcase 444:
INSERT INTO tntbl3
	SELECT to_char(id, 'FM00000'), id, id/10, id * 20.5, id * 100	FROM generate_series(1, 30) id;
--Testcase 445:
SELECT * FROM tntbl3 ORDER BY 1,2;
--Testcase 446:
SELECT * FROM tntbl3__jdbc_mysql_svr__0 ORDER BY 1,2;
--Testcase 447:
SELECT * FROM tntbl3__jdbc_post_svr__0 ORDER BY 1,2;

--Clean
--Testcase 110:
DELETE FROM tntbl3;
--Reset data
INSERT INTO tntbl3__jdbc_post_svr__0 VALUES ('jdbc', 10, 10.0, 1000.0, 10000);
INSERT INTO tntbl3__jdbc_mysql_svr__0 VALUES ('jdbc_mysql', 10, 10.0, 1000.0, 10000);
--Testcase 111:
DROP FOREIGN TABLE tntbl3 CASCADE;
--Testcase 112:
DROP EXTENSION jdbc_fdw CASCADE;
--Testcase 113:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 114:
DROP SERVER pgspider_svr CASCADE;
--Testcase 115:
DROP EXTENSION pgspider_core_fdw CASCADE;
