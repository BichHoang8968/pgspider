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
-- tntbl2, 3
--Testcase 10:
CREATE FOREIGN TABLE tntbl2 (_id text, c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 real, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr;

-- Foreign tables
--Testcase 11:
CREATE FOREIGN TABLE tntbl2__jdbc_mysql_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint) SERVER jdbc_mysql_svr OPTIONS (table_name 'tntbl2');
CREATE FOREIGN TABLE tntbl3__jdbc_post_svr__0 (_id text OPTIONS (key 'true'), c1 int, c2 real, c3 double precision, c4 bigint) SERVER jdbc_post_svr OPTIONS (table_name 'tntbl3');

-- Reset data of remote table before test
DELETE FROM tntbl2__jdbc_mysql_svr__0;

-- SELECT FROM table if there is any record
--Testcase 12:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

-----------------------------------------------------------------------------------
-- *** Start test for tntbl2 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 140:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 141:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 142:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 143:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 144:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 145:
SELECT * FROM tntbl2;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 146:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 147:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 148:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 149:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 150:
SELECT * FROM tntbl2;

--
-- VALUES test
--
--Testcase 151:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 152:
SELECT * FROM tntbl2;

--
-- TOASTed value test
--
--Testcase 153:
INSERT INTO tntbl2 VALUES(repeat('a', 25), 30, repeat('x', 25), true, 512.0, 2000);

--Testcase 154:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2;

--
-- INSERT with IN feature
--
--Testcase 155:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 156:
INSERT INTO tntbl2 IN ('/dynamodb_svr/', '/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 157:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 158:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 159:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

-- aliases for the UPDATE target table
--Testcase 160:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 161:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

--Testcase 162:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 163:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--
-- Test VALUES in FROM
--

--Testcase 164:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 165:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

-- fail, wrong data type:
--Testcase 166:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 167:
INSERT INTO tntbl2 (SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2 ORDER BY 1, 2, 3);
--Testcase 168:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;

--Testcase 169:
UPDATE tntbl2 SET (c1, c2) = (c1+11, DEFAULT) WHERE c3 = true;
--Testcase 170:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 171:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 172:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- fail, multi assignment to same column:
--Testcase 173:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 174:
UPDATE tntbl2
  SET (c1, c3) = (SELECT c1, c3 FROM tntbl2 where c1 = 1010 and c2 = 'car')
  WHERE c5 = 1000 AND c1 = 21;
--Testcase 175:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- correlated sub-SELECT:
--Testcase 176:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2);
--Testcase 177:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- fail, multiple rows supplied:
--Testcase 178:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2);
-- set to null if no rows supplied:
--Testcase 179:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 180:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
-- *-expansion should work in this context:
--Testcase 181:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 182:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 183:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 184:
UPDATE tntbl2 SET _id = repeat('x', 25) WHERE c2 = 'car' and c1 = 5000;
--Testcase 185:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 186:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 187:
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 188:
SELECT c1, c5, char_length(c2) FROM tntbl2;
--
-- UPDATE with IN feature
--
--Testcase 189:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 56563.1212;
--Testcase 190:
UPDATE tntbl2 IN ('/odbc_post_svr/', '/jdbc_mysql_svr/') SET c4 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 191:
DELETE FROM tntbl2 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 192:
DELETE FROM tntbl2 dt WHERE tntbl2.c1 > 25;

--Testcase 193:
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2;

-- delete a row with a TOASTed value
--Testcase 194:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 195:
SELECT c1, char_length(_id) FROM tntbl2;
--
-- DELETE with IN feature
--
--Testcase 196:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 197:
DELETE FROM tntbl2 IN ('/dynamodb_svr/', '/odbc_post_svr/', '/griddb_svr/') WHERE c5 = 4000;

--Testcase 338:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('121', 29, 'DEFAULT', true, 4.0, 4000);
--Testcase 339:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2', true);
--Testcase 340:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('xin3', 10, 'tst_in_feature', true, 5.0, 5000);
--Testcase 341:
SELECT * FROM tntbl2;
--Testcase 342:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 7000;
--Testcase 343:
SELECT * FROM tntbl2;
--Testcase 344:
DELETE FROM tntbl2 WHERE c2 = '2';
--Testcase 345:
SELECT * FROM tntbl2;
--Testcase 346:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 347:
SELECT * FROM tntbl2;

--
-- Test with optional options: tntbl2
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 398:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12);  -- duplicate key
--Testcase 399:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 400:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 401:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 402:
CREATE VIEW rw_view AS SELECT * FROM tntbl2
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 403:
\d+ rw_view
--Testcase 404:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0);
--Testcase 405:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0); -- should fail
--Testcase 406:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000);
--Testcase 407:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000); -- ok
--Testcase 408:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 409:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 410:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 411:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 412:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 413:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2;
--Testcase 414:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 415:
INSERT INTO tntbl2 VALUES ('00:05:00', 20, '2022-05-16', false, 50.0, 7000) RETURNING *;
--Testcase 416:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('_key_', 30, 'test', true, 50.0, 8000) RETURNING c1, c4, c5;
--Testcase 417:
UPDATE tntbl2 SET c2 = '2100-01-01 10:00:00+01' WHERE c1 = 20 AND c3 = false RETURNING (tntbl2), *;
--Testcase 418:
DELETE FROM tntbl2 WHERE c4 = 50.0 RETURNING _id, c1, c2;
--Testcase 419:
DELETE FROM tntbl2 RETURNING *;
-- *** Finish test for tntbl2 *** --
-----------------------------------------------------------------------------------
-- Reset data of remote table before test
DELETE FROM tntbl3__jdbc_post_svr__0;
INSERT INTO tntbl3__jdbc_post_svr__0 VALUES ('jdbc', 10, 10.0, 1000.0, 10000);

-- SELECT FROM table if there is any record
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

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
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

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
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 209:
INSERT INTO tntbl3 VALUES('test111', 10, 2.0, 20.0, 2000), ('test222', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test3'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 210:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 211:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 212:
SELECT c1, c2, _id FROM tntbl3 ORDER BY 1, 2, 3;

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
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 216:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 217:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 218:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 219:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 220:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 221:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 222:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 223:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 224:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 225:
-- Commmented, fail due to oracle_fdw. Not reported yet.
-- INSERT INTO tntbl3 SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3;
--Testcase 226:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 227:
UPDATE tntbl3 SET (c1, c2) = (c1 + 11, DEFAULT) WHERE c2 = 2.0;
--Testcase 228:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 229:
UPDATE tntbl3 SET (c2, c3) = (300, c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 230:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multi assignment to same column:
--Testcase 231:
UPDATE tntbl3 SET (c2, c1) = (100, c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 232:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'car1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 233:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
--Testcase 234:
UPDATE tntbl3 o
  SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
               where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 235:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 236:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 237:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 238:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
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
UPDATE tntbl3 SET _id = repeat('a', 25) WHERE c1 = 11;
--Testcase 243:
SELECT c1, c2, _id FROM tntbl3 ORDER BY 1, 2, 3;

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
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 247:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56563.0;
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
SELECT c1, c3, _id FROM tntbl3 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 252:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 253:
SELECT c1, c3, _id FROM tntbl3 ORDER BY 1, 2, 3;

--
-- DELETE with IN feature
--
--Testcase 254:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 255:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

Set pgspider_core_fdw.throw_error_ifdead to true;

--Testcase 348:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES (100, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 349:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_33', 3.0, DEFAULT);
--Testcase 350:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 351:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 352:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 353:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 354:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 355:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 356:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56.0;
--Testcase 357:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 358:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 359:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 360:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c3 = 56.0;
--Testcase 361:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
-- Reset value of disable_transaction_feature_check
SET disable_transaction_feature_check TO true;
--
--
-- Test with __spd_url
--
--Testcase 362:
DELETE FROM tntbl3 WHERE __spd_url = '/mongo_svr/';
--Testcase 363:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
--Testcase 364:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mysql_svr/', '/griddb_svr/') VALUES ('foo', 30, 5.0, 50.0, 6000);
--Testcase 365:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 366:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 367:
UPDATE tntbl3 SET _id = _id || '@' WHERE __spd_url = '/postgres_svr/';
--Testcase 368:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 369:
DELETE FROM tntbl3;
--Testcase 370:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 371:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 372:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 373:
SELECT _id, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY _id HAVING _id IS NOT NULL LIMIT 5;
--Testcase 374:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/postgres_svr/');
--Testcase 375:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
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
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
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
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
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
DELETE FROM tntbl2;
--Testcase 443:
SELECT * FROM tntbl2;

SET client_min_messages = INFO;

-- Manual config: batch_size server = 5, batch_size table not set, batch_size of FDW = 6, insert 10 records
-- jdbc_fdw not support batch_size
--Testcase 444:
-- ALTER SERVER pgspider_svr OPTIONS (ADD batch_size '5');
--Testcase 445:
INSERT INTO tntbl2
	SELECT to_char(id, 'FM00000'), id, 'foo', true, id/10, id * 1000	FROM generate_series(1, 10) id;
--Testcase 446:
SELECT * FROM tntbl2 ORDER BY 1,2;

-- Auto config: batch_size of FDW = 10, insert 25 records
DELETE FROM tntbl2;
--Testcase 447:
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);

--Testcase 448:
INSERT INTO tntbl2
	SELECT to_char(id, 'FM00000'), id, 'foo', true, id/10, id * 1000	FROM generate_series(1, 25) id;
--Testcase 449:
SELECT * FROM tntbl2 ORDER BY 1,2;

--Clean
--Testcase 110:
DELETE FROM tntbl2;
--Testcase 111:
DELETE FROM tntbl3;
--Reset data
INSERT INTO tntbl3__jdbc_post_svr__0 VALUES ('jdbc', 10, 10.0, 1000.0, 10000);
--Testcase 112:
DROP FOREIGN TABLE tntbl2, tntbl2__jdbc_mysql_svr__0 CASCADE;
--Testcase 113:
DROP FOREIGN TABLE tntbl3, tntbl3__jdbc_post_svr__0 CASCADE;
--Testcase 114:
DROP EXTENSION jdbc_fdw CASCADE;
--Testcase 115:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 116:
DROP SERVER pgspider_svr CASCADE;
--Testcase 117:
DROP EXTENSION pgspider_core_fdw CASCADE;
