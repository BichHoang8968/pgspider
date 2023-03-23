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
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER2);
--Testcase 6:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;

--Testcase 7:
CREATE EXTENSION pgspider_fdw;
--Testcase 8:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host :PGSPIDER_SERVER2, port :PGSPIDER_PORT2, dbname :PGSPIDER_DB2);
--Testcase 9:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;

-- tntbl1
--Testcase 10:
CREATE FOREIGN TABLE tntbl1 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255), __spd_url text) SERVER pgspider_core_svr;
--Testcase 11:
CREATE FOREIGN TABLE tntbl1__pgspider_svr__0 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255), __spd_url text) SERVER pgspider_svr OPTIONS (table_name 'tntbl1');
-- tntbl2
--Testcase 12:
CREATE FOREIGN TABLE tntbl2 (_id text, c1 int, c2 varchar(255), c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_core_svr;
--Testcase 13:
CREATE FOREIGN TABLE tntbl2__pgspider_svr__0 (_id text, c1 int, c2 varchar(255), c3 boolean, c4 double precision, c5 bigint, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 'tntbl2');
-- tntbl3
--Testcase 14:
CREATE FOREIGN TABLE tntbl3 (_id text, c1 int, c2 float, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_core_svr;
--Testcase 15:
CREATE FOREIGN TABLE tntbl3__pgspider_svr__0 (_id text, c1 int, c2 float, c3 double precision, c4 bigint, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 'tntbl3');
-- tntbl4
--Testcase 16:
CREATE FOREIGN TABLE tntbl4 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval, __spd_url text) SERVER pgspider_core_svr;
--Testcase 17:
CREATE FOREIGN TABLE tntbl4__pgspider_svr__0 (c1 int, c2 text, c3 boolean, c4 double precision, c5 bigint, c6 char(255), c7 varchar(255), c8 float8, c9 smallint, c10 timestamp, c11 timestamp with time zone, c12 date, c13 json, c14 jsonb, c15 uuid, c16 point, c17 bytea, c18 bit(10), c19 varbit(10), c20 interval, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 'tntbl4');
-- tntbl5
--Testcase 18:
CREATE FOREIGN TABLE tntbl5 (c1 int, c2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 19:
CREATE FOREIGN TABLE tntbl5__pgspider_svr__0 (c1 int, c2 text, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 'tntbl5');

-- SELECT FROM table if there is any record
--Testcase 20:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 21:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 22:
Set pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 23:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 24:
Set pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 25:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 26:
SELECT * FROM tntbl5 ORDER BY 1, 2, 3;
--------------------------------------------------------------------------------
-- *** Start test for tntbl1 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 27:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (5, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 28:
INSERT INTO tntbl1 (c1, c2) VALUES (1, DEFAULT);
--Testcase 29:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (6, 5, DEFAULT);
--Testcase 30:
INSERT INTO tntbl1 VALUES (7, 6, 2.6, 5453.454, 5989, '2001-01-01 04:05:02');
--Testcase 31:
INSERT INTO tntbl1 VALUES (8, 7);

--Testcase 32:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 33:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (10, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 34:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (2, DEFAULT);
--Testcase 35:
INSERT INTO tntbl1 (c1, c2) VALUES (3, 2, 5);
--Testcase 36:
INSERT INTO tntbl1 (c1, c2) VALUES (11, DEFAULT, 6);

--Testcase 37:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- VALUES test
--
--Testcase 38:
INSERT INTO tntbl1 VALUES (10, 20, 3.0, 452.254, 599, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', '40', 'abc'), (-1, 2, DEFAULT, DEFAULT, 69845, '2004-10-19 10:23:54', '1972-01-01 00:00:01', 'Beera', 'John Does'),
    ((SELECT 2), (SELECT i FROM (VALUES(3)) as foo (i)), 4.0, 656.212, 5944, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', 'VALUES are fun!', 'foo');

--Testcase 39:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- TOASTed value test
--
--Testcase 40:
INSERT INTO tntbl1 VALUES (9, 9, 902.12, 9545.03, 3122, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', repeat('x', 25), repeat('a', 25));

--Testcase 41:
SELECT c1, c2, c3, c4, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--
--Testcase 42:
INSERT INTO tntbl1 IN ('/postgres_svr/') VALUES (-10, 20, 82.21, 213.12, 9565, '2003-10-19 10:23:54', '1971-01-01 00:00:01+07', 'One', 'OneOne');
--Testcase 43:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (650, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');

--
-- UPDATE
--
--Testcase 44:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--Testcase 45:
UPDATE tntbl1 SET c6 = DEFAULT, c4 = DEFAULT;
--Testcase 46:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
-- aliases for the UPDATE target table
--Testcase 47:
UPDATE tntbl1 AS t SET c1 = 10 WHERE t.c3 = 902.12;
--Testcase 48:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--Testcase 49:
UPDATE tntbl1 t SET c1 = t.c1 + 10 WHERE t.c3 = 3.0;
--Testcase 50:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7;
--
-- Test VALUES in FROM
--

--Testcase 51:
UPDATE tntbl1 SET c1=v.i FROM (VALUES(20, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--Testcase 52:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, wrong data type:
--Testcase 53:
UPDATE tntbl1 SET c1 = v.* FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--
-- Test multiple-set-clause syntax
--

-- oracle_fdw issue skip/report
-- INSERT INTO tntbl1 SELECT c1+20, c2+50, c3 FROM tntbl1;
--Testcase 54:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

--Testcase 55:
UPDATE tntbl1 SET (c8,c1,c2) = ('bugle', c1+11, DEFAULT) WHERE c9 = 'foo';
--Testcase 56:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
--Testcase 57:
UPDATE tntbl1 SET (c9,c4) = ('car', c1+c3), c1 = c1 + 1 WHERE c5 = 3122;
--Testcase 58:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, multi assignment to same column:
--Testcase 59:
UPDATE tntbl1 SET (c9,c5) = ('car', c1+c5), c5 = c1 + 1 WHERE c2 = 20;

-- uncorrelated sub-SELECT:
--Testcase 60:
UPDATE tntbl1
  SET (c2,c3) = (SELECT c2,c3 FROM tntbl1 where c3 = 3 and c9 = 'abc')
  WHERE c2 = 6 AND c2 = 2.6;
--Testcase 61:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- correlated sub-SELECT:
-- issue of pgspider_core_fdw, report/skip
-- UPDATE tntbl1 o
--   SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 i
--                where i.c4=o.c3 and i.c5=o.c5 and i.c5 is not distinct FROM o.c5);
--Testcase 62:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- fail, multiple rows supplied:
--Testcase 63:
UPDATE tntbl1 SET (c2,c3) = (SELECT c3+1,c2 FROM tntbl1);
-- set to null if no rows supplied:
--Testcase 64:
UPDATE tntbl1 SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 where c5 = 1000)
  WHERE c5 = 11;
--Testcase 65:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
-- *-expansion should work in this context:
--Testcase 66:
UPDATE tntbl1 SET (c2,c3) = ROW(v.*) FROM (VALUES(2, 100)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 67:
UPDATE tntbl1 SET (c2,c3) = (v.*) FROM (VALUES(2, 101)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 68:
UPDATE tntbl1 AS t SET c2 = tntbl1.c2 + 10 WHERE t.c2 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 69:
UPDATE tntbl1 SET c9 = repeat('x', 25) WHERE c9 = 'car';
--Testcase 70:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 71:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
-- Crash issue/report
-- UPDATE tntbl1 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 72:
SELECT c2, c3, c9 FROM tntbl1 order by 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 73:
UPDATE tntbl1 IN ('/tiny_svr/') SET c4 = 56563.1212;
--Testcase 74:
UPDATE tntbl1 IN ('/postgres_svr/', '/sqlite_svr/') SET c3 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 75:
DELETE FROM tntbl1 AS dt WHERE dt.c1 > 75;
-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 76:
DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 25;
--Testcase 77:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- delete a row with a TOASTed value
--Testcase 78:
DELETE FROM tntbl1 WHERE c2 > 2;
--Testcase 79:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- DELETE with IN feature
--
--Testcase 80:
DELETE FROM tntbl1 IN ('/oracle_svr/') WHERE c1 = 20;

--Testcase 81:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 82:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 1000;

--Testcase 83:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

-- *** Finish test for tntbl1 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl2 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 84:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES (' ', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 85:
INSERT INTO tntbl2 (_id, c2, c3) VALUES ('3', DEFAULT, DEFAULT);
--Testcase 86:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('4', DEFAULT, '3q', DEFAULT);
--Testcase 87:
INSERT INTO tntbl2 VALUES ('DEFAULT', DEFAULT, 'test', true, 4654.0, 4000);
--Testcase 88:
INSERT INTO tntbl2 VALUES ('test', DEFAULT, 'test', false);

--Testcase 89:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 90:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('121', DEFAULT, DEFAULT);
--Testcase 91:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2');
--Testcase 92:
INSERT INTO tntbl2 (_id, c1) VALUES ('a', 1, '3');
--Testcase 93:
INSERT INTO tntbl2 (_id, c1) VALUES ('b', DEFAULT, DEFAULT);

--Testcase 94:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 95:
INSERT INTO tntbl2 VALUES('value1', 10, 'foo', false, 40.0, 5000), ('value2', -1, 'foo1', true, 2.0, DEFAULT),
    ((SELECT 'abc'), (SELECT 2), 'VALUES are fun!', true, (SELECT i FROM (VALUES(3.0)) as foo (i)), 1000);

--Testcase 96:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 97:
INSERT INTO tntbl2 VALUES(repeat('a', 25), 30, repeat('x', 25), true, 512.0, 2000);

--Testcase 98:
SELECT c1, c3, char_length(_id), char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--
--Testcase 99:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('in1', 10, 'tst_in_feature', false, 5.0, 5000);
--Testcase 100:
INSERT INTO tntbl2 IN ('/dynamodb_svr/', '/mongo_svr/') VALUES ('in2', 20, 'tst_in_feature', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 101:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 102:
UPDATE tntbl2 SET c4 = DEFAULT;

--Testcase 103:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 104:
UPDATE tntbl2 AS t SET c1 = 10 WHERE t.c5 = 1000;

--Testcase 105:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;

--Testcase 106:
UPDATE tntbl2 t SET c1 = t.c1 + 10 WHERE t.c5 = 1000;

--Testcase 107:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--
-- Test VALUES in FROM
--

--Testcase 108:
UPDATE tntbl2 SET c1=v.i FROM (VALUES(10, 1000)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--Testcase 109:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

-- fail, wrong data type:
--Testcase 110:
UPDATE tntbl2 SET c1 = v.* FROM (VALUES(1000, 10)) AS v(i, j)
  WHERE tntbl2.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 111:
INSERT INTO tntbl2 (SELECT _id || 's#', c1 + 1, c2 || '@@' FROM tntbl2 ORDER BY 1, 2, 3);
--Testcase 112:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;

--Bug of PGSpider master branch
-- -- UPDATE tntbl2 SET (c2, c1, c3) = ('bugle', c1+11, DEFAULT) WHERE c3 = true;
--Testcase 113:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 114:
UPDATE tntbl2 SET (c2, c1) = ('car', c1 + c5), c4 = c4 + 10.0 WHERE c1 = 10;
--Testcase 115:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
-- fail, multi assignment to same column:
--Testcase 116:
UPDATE tntbl2 SET (c2, c4) = ('car', c1 + c4), c4 = c1 + 1 WHERE c1 = 10;

-- uncorrelated sub-SELECT:
--Testcase 117:
UPDATE tntbl2
  SET (c2, c3) = (SELECT c2, c3 FROM tntbl2 where c1 = 1010 and c2 = 'car')
  WHERE c5 = 1000 AND c1 = 1010;
--Testcase 118:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
-- correlated sub-SELECT:
--Testcase 119:
UPDATE tntbl2 o
  SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2 i
               where i.c1=o.c1 and i.c5=o.c5 and i.c2 is not distinct FROM o.c2);
--Testcase 120:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5;
-- fail, multiple rows supplied:
--Testcase 121:
UPDATE tntbl2 SET (c5, c1) = (SELECT c1+1, c5 FROM tntbl2);
-- set to null if no rows supplied:
--Testcase 122:
UPDATE tntbl2 SET (c5 , c1) = (SELECT c1+1, c5 FROM tntbl2 where c4 = 10.0)
  WHERE c4 = 50.0;
--Testcase 123:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5;
-- *-expansion should work in this context:
--Testcase 124:
UPDATE tntbl2 SET (c1, c5) = ROW(v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 125:
UPDATE tntbl2 SET (c1, c5) = (v.*) FROM (VALUES(20, 3)) AS v(i, j)
  WHERE tntbl2.c1 = v.j;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 126:
UPDATE tntbl2 AS t SET c4 = tntbl2.c4 + 10 WHERE t.c1 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 127:
UPDATE tntbl2 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 128:
SELECT c1, char_length(c2), char_length(_id) FROM tntbl2 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 129:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 130:
UPDATE tntbl2 t
  SET (c1, c5) = (SELECT c5, c1 FROM tntbl2 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 131:
SELECT c1, c5, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 132:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 56563.1212;
--Testcase 133:
UPDATE tntbl2 IN ('/odbc_post_svr/', '/jdbc_mysql_svr/') SET c4 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 134:
DELETE FROM tntbl2 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 135:
DELETE FROM tntbl2 dt WHERE tntbl2.c1 > 25;

--Testcase 136:
SELECT char_length(_id), c1, char_length(c2) FROM tntbl2 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 137:
DELETE FROM tntbl2 WHERE c2 = 'car';

--Testcase 138:
SELECT c1, char_length(_id) FROM tntbl2 ORDER BY 1, 2;
--
-- DELETE with IN feature
--
--Testcase 139:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 140:
DELETE FROM tntbl2 IN ('/dynamodb_svr/', '/odbc_post_svr/', '/griddb_svr/') WHERE c5 = 4000;

-- *** Finish test for tntbl2 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl3 *** --
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 141:
Set pgspider_core_fdw.throw_error_ifdead to false;

--Testcase 142:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('@', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 143:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_3', 3.0, DEFAULT);
--Testcase 144:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('_4', DEFAULT, 5.0, DEFAULT);
--Testcase 145:
INSERT INTO tntbl3 VALUES ('test1', DEFAULT, 5.0, 600.0, 1000);
--Testcase 146:
INSERT INTO tntbl3 VALUES ('test2', DEFAULT, 7.0);

--Testcase 147:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 148:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong1', DEFAULT, DEFAULT);
--Testcase 149:
INSERT INTO tntbl3 (_id, c1, c2, c3) VALUES ('wrong2', 1, 2.0);
--Testcase 150:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong3', 1, 2);
--Testcase 151:
INSERT INTO tntbl3 (_id, c1) VALUES ('wrong4',DEFAULT, DEFAULT);

--Testcase 152:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 153:
INSERT INTO tntbl3 VALUES('test11', 10, 2.0, 20.0, 2000), ('test22', -1, 2.0, DEFAULT, 3000),
    ((SELECT 'test33'), (SELECT 90), (SELECT i FROM (VALUES(3.0)) as foo (i)), 30.0, 4000);

--Testcase 154:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 155:
INSERT INTO tntbl3 VALUES(repeat('x', 25), 20, 4.0, 40.0, 5000);

--Testcase 156:
SELECT c1, c2, _id FROM tntbl3 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--
--Testcase 157:
INSERT INTO tntbl3 IN ('/sqlite_svr/') VALUES ('_test', 10, 5.0, 50.0, 5000);
--Testcase 158:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);

--
-- UPDATE
--
--Testcase 159:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 160:
UPDATE tntbl3 SET c3 = DEFAULT, c4 = DEFAULT;

--Testcase 161:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 162:
UPDATE tntbl3 AS t SET c1 = 10 WHERE t.c2 = 2.0;

--Testcase 163:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 164:
UPDATE tntbl3 t SET c1 = t.c1 + 10 WHERE t.c2 = 4.0;

--Testcase 165:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 166:
UPDATE tntbl3 SET c1=v.i FROM (VALUES(100, 5)) AS v(i, j)
  WHERE tntbl3.c1 = v.j;

--Testcase 167:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 168:
UPDATE tntbl3 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl3.c4 = v.j;

--
-- Test multiple-set-clause syntax
--

-- oracle_fdw issue skip/report
-- INSERT INTO tntbl3 SELECT _id || '1', c1 + 1, c2 + 1, c3 FROM tntbl3;
--Testcase 169:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;

--Testcase 170:
UPDATE tntbl3 SET (c1, c2) = (c1 + 11, DEFAULT) WHERE c2 = 2.0;
--Testcase 171:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multi assignment to same column:
--Testcase 172:
UPDATE tntbl3 SET (c3) = (c2 + c3), c1 = c1 + 1 WHERE c1 = 10;
--Testcase 173:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 174:
UPDATE tntbl3 SET (c2) = (c2 + c3), c2 = c1 + 1 WHERE c4 = 3000;

-- uncorrelated sub-SELECT:
--Testcase 175:
UPDATE tntbl3
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 where c1 = 11 and _id = 'car1')
  WHERE c2 = 2.0 AND c3 = 20.0;
--Testcase 176:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
-- Bug of pgspider_core_fdw / commented out
-- UPDATE tntbl3 o
--   SET (c2, c3) = (SELECT c3+1, c2 FROM tntbl3 i
--                where i.c3 = o.c3 and i.c2 = o.c2 and i.c1 is not distinct FROM o.c1);
--Testcase 177:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 178:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
-- set to null if no rows supplied:
--Testcase 179:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1, c3 FROM tntbl3 where c4 = 1000)
  WHERE c1 = 11;
--Testcase 180:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3, 4, 5;
-- *-expansion should work in this context:
--Testcase 181:
UPDATE tntbl3 SET (c1, c3) = ROW(v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 182:
UPDATE tntbl3 SET (c1, c3) = (v.*) FROM (VALUES(11, 20)) AS v(i, j)
  WHERE tntbl3.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 183:
UPDATE tntbl3 AS t SET c1 = tntbl3.c1 + 10 WHERE t.c2 = 2.0;

-- Check multi-assignment with a Result node to handle a one-time filter.
-- Crash issue/report
-- EXPLAIN (VERBOSE, COSTS OFF)
-- UPDATE tntbl3 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
-- UPDATE tntbl3 t
--   SET (c2, c3) = (SELECT c3, c2 FROM tntbl3 s WHERE s.c2 = t.c2)
--   WHERE CURRENT_USER = SESSION_USER;
--Testcase 184:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 185:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56563.0;
--Testcase 186:
UPDATE tntbl3 IN ('/jdbc_post_svr/', '/odbc_mysql_svr/', '/oracle_svr/') SET c3 = 222.0;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 187:
DELETE FROM tntbl3 AS dt WHERE dt.c1 > 35;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 188:
DELETE FROM tntbl3 dt WHERE tntbl3.c1 > 25;

--Testcase 189:
SELECT c1, c3, _id FROM tntbl3 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 190:
DELETE FROM tntbl3 WHERE c1 > 10;

--Testcase 191:
SELECT c1, c3, _id FROM tntbl3 ORDER BY 1, 2, 3;

--
-- DELETE with IN feature
--
--Testcase 192:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 193:
DELETE FROM tntbl3 IN ('/dynamodb_svr/', '/odbc_mysql_svr/', '/griddb_svr/', '/oracle_svr/', '/tiny_svr/') WHERE c4 = 3000;

--Testcase 194:
Set pgspider_core_fdw.throw_error_ifdead to true;

-- *** Finish test for tntbl3 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl4 *** --
--
-- insert with DEFAULT in the target_list
--
--Testcase 195:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 196:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (3, DEFAULT, DEFAULT);
--Testcase 197:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (4, 'ANC#$', DEFAULT);
--Testcase 198:
INSERT INTO tntbl4 VALUES (5, DEFAULT, true, 10.0, 1000, 'char array', 'char varying', 100.0, 127, '2004-10-19 10:23:54', '2004-10-19 10:23:54+02', '0001-01-01', '{ "customer": "John Does"}', '{"tags": ["tag1", "tag2"], "finished": true }', '2f404849-f62c-4234-b0c8-e230bd694045', point '(1,-45)', E'\\xa7a8a9aaabacadaeaf', B'1111111111', B'10101', interval '6 years 5 months 4 days 3 hours 2 minutes 1 second');
--Testcase 199:
INSERT INTO tntbl4 VALUES (6, 'test', false, DEFAULT, 2000, 'test', 'test', 200.0, 0);

--Testcase 200:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 201:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) VALUES (DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 202:
INSERT INTO tntbl4 (c1, c2, c3) VALUES (1, 'ex');
--Testcase 203:
INSERT INTO tntbl4 (c1) VALUES (1, 2);
--Testcase 204:
INSERT INTO tntbl4 (c1) VALUES (DEFAULT, DEFAULT);

--Testcase 205:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- VALUES test
--
--Testcase 206:
INSERT INTO tntbl4 VALUES(1, '40', true, 2.0, 2000, 'value 1'), (-1, DEFAULT, true, 4.0, 4000, 'value 2'),
    ((SELECT 2), 'fun!', false, (SELECT i FROM (VALUES(3.0)) as foo (i)), 3000, 'VALUES are fun!');

--Testcase 207:
SELECT * FROM tntbl4 ORDER BY 1, 2, 3;

--
-- TOASTed value test
--
--Testcase 208:
INSERT INTO tntbl4 VALUES(30, repeat('x', 25));

--Testcase 209:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--
--Testcase 210:
INSERT INTO tntbl4 IN ('/postgres_svr/') VALUES (12, '_test', true, 5.0, 5000);
--Testcase 211:
INSERT INTO tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') VALUES (13, '_infea', true, 6.0, 6000);

--
-- UPDATE
--
--Testcase 212:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--Testcase 213:
UPDATE tntbl4 SET c3 = DEFAULT, c6 = DEFAULT;

--Testcase 214:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 215:
UPDATE tntbl4 AS t SET c5 = 10000 WHERE t.c1 = 20;

--Testcase 216:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--Testcase 217:
UPDATE tntbl4 t SET c5 = t.c5 + 10 WHERE t.c1 = 20;

--Testcase 218:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 219:
UPDATE tntbl4 SET c1 = v.i FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--Testcase 220:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;

-- fail, wrong data type:
--Testcase 221:
UPDATE tntbl4 SET c1 = v.* FROM (VALUES(100, 2000)) AS v(i, j)
  WHERE tntbl4.c5 = v.j;

--
-- Test multiple-set-clause syntax
--

--Testcase 222:
INSERT INTO tntbl4 (SELECT c1 + 10, c2 || 'next', c3 != true FROM tntbl4 ORDER BY 1, 2, 3);
--Testcase 223:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

--Testcase 224:
UPDATE tntbl4 SET (c2 , c1, c4) = ('bugle', c1 + 10, DEFAULT) WHERE c2 = 'fun!';
--Testcase 225:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
--Testcase 226:
UPDATE tntbl4 SET (c2, c5) = ('car', c1 + c5), c1 = c1 + 10 WHERE c1 = 30;
--Testcase 227:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
-- fail, multi assignment to same column:
--Testcase 228:
UPDATE tntbl4 SET (c6, c8) = ('car', c4 + c8), c8 = c4 + 1.0 WHERE c1 = 40;

-- uncorrelated sub-SELECT:
--Testcase 229:
UPDATE tntbl4
  SET (c9, c1) = (SELECT c1, c9 FROM tntbl4 where c1 = 40 and c2 = 'car')
  WHERE c5 = 1000 AND c4 = 2.0;
--Testcase 230:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
-- correlated sub-SELECT:
--Testcase 231:
UPDATE tntbl4 o
  SET (c9, c4) = (SELECT c9+1, c4 FROM tntbl4 i
               where i.c9=o.c9 and i.c4=o.c4 and i.c1 is not distinct FROM o.c1);
--Testcase 232:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 233:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4);
-- set to null if no rows supplied:
--Testcase 234:
UPDATE tntbl4 SET (c1, c9) = (SELECT c9 + 1, c1 FROM tntbl4 where c5 = 2000)
  WHERE c9 = 127;
--Testcase 235:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:
--Testcase 236:
UPDATE tntbl4 SET (c1, c9) = ROW(v.*) FROM (VALUES(20, 100)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 237:
UPDATE tntbl4 SET (c1, c9) = (v.*) FROM (VALUES(20, 101)) AS v(i, j)
  WHERE tntbl4.c1 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 238:
UPDATE tntbl4 AS t SET c9 = tntbl4.c9 + 10 WHERE t.c1 = 40;

-- Make sure that we can update to a TOASTed value.
--Testcase 239:
UPDATE tntbl4 SET c2 = repeat('x', 25) WHERE c2 = 'car';
--Testcase 240:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 241:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 242:
UPDATE tntbl4 t
  SET (c5, c1) = (SELECT c1, c5 FROM tntbl4 s WHERE s.c1 = t.c1)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 243:
SELECT c1, c5, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 244:
UPDATE tntbl4 IN ('/postgres_svr/') SET c8 = 56563.1212;
--Testcase 245:
UPDATE tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/') SET c8 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 246:
DELETE FROM tntbl4 AS dt WHERE dt.c1 > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 247:
DELETE FROM tntbl4 dt WHERE tntbl4.c1 > 45;

--Testcase 248:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

-- delete a row with a TOASTed value
--Testcase 249:
DELETE FROM tntbl4 WHERE c1 > 25;

--Testcase 250:
SELECT c1, c3, char_length(c2) FROM tntbl4 ORDER BY 1, 2, 3;

--
-- DELETE with IN feature
--
--Testcase 251:
DELETE FROM tntbl4 IN ('/postgres_svr/') WHERE c1 = 10;
--Testcase 252:
DELETE FROM tntbl4 IN ('/postgres_svr/', '/postgres_svr_2/', '/griddb_svr/') WHERE c5 = 3000;

-- *** Finish test for tntbl4 *** --
-----------------------------------------------------------------------------------
-- *** Start test for tntbl5 *** --
-- This FDW does not support modification, the result will fail all over
--Testcase 253:
SELECT c1, c2 FROM tntbl5 ORDER BY 1, 2;
--Testcase 254:
INSERT INTO tntbl5 VALUES (DEFAULT, 'abc');
--Testcase 255:
INSERT INTO tntbl5 VALUES (1, 'foo');
--Testcase 256:
INSERT INTO tntbl5 IN ('/file_svr/') VALUES (2, 'zzzzz');
--Testcase 257:
UPDATE tntbl5 SET c2 = 'foo' WHERE c1 IS NULL;
--Testcase 258:
UPDATE tntbl5 IN ('/file_svr/', '/file_svr_2/') SET c2 = DEFAULT;
--Testcase 259:
DELETE FROM tntbl5 WHERE c2 = 'foo';
--Testcase 260:
DELETE FROM tntbl5 IN ('/file_svr/');
-- *** Finish test for tntbl5 *** --
-----------------------------------------------------------------------------------
--
-- Check behavior of disable_transaction_feature_check
--
--Testcase 261:
ALTER FOREIGN TABLE tntbl1 OPTIONS (disable_transaction_feature_check 'false');
--Testcase 262:
INSERT INTO tntbl1 VALUES (200, 70, 2.0, 200.0, 3000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', DEFAULT, 'abc', 'foo');
--Testcase 263:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 264:
INSERT INTO tntbl1 VALUES (100, 20, 3.0, 300.0, 4000, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', interval '2 months ago', '40', 'abc'), (-100, 30, DEFAULT, DEFAULT, 2000, '2004-10-19 10:23:54', '1970-01-01 00:00:01+07', interval '1 year 3 hours 20 minutes', 'Beera', 'John Does'),
    ((SELECT 300), (SELECT i FROM (VALUES(3)) as foo (i)), 400.212, 200.0, 5000, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', interval '1 year 2 months 3 days', 'VALUES are fun!', 'foo');

--Testcase 265:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 266:
INSERT INTO tntbl1 VALUES (900, 80, 6.0, 400.03, 6000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', interval '1 months ago', repeat('x', 10), repeat('a', 20));
--Testcase 267:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 268:
UPDATE tntbl1 SET c2 = 10.001 WHERE c1 = 100;
--Testcase 269:
DELETE FROM tntbl1 WHERE c1 > 100;
--Testcase 270:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 271:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (600, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');
--Testcase 272:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 273:
UPDATE tntbl1 IN ('/dynamodb_svr/') SET c4 = 60.0;
--Testcase 274:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 275:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 4000;
--Testcase 276:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
-- Reset value of disable_transaction_feature_check
--Testcase 277:
ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');
--Testcase 278:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('121', 29, 'DEFAULT', true, 4.0, 4000);
--Testcase 279:
INSERT INTO tntbl2 (_id, c1, c2, c3) VALUES ('122', 1, '2', true);
--Testcase 280:
INSERT INTO tntbl2 IN ('/griddb_svr/') VALUES ('xin3', 10, 'tst_in_feature', true, 5.0, 5000);
--Testcase 281:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 282:
UPDATE tntbl2 IN ('/dynamodb_svr/') SET c4 = 7000;
--Testcase 283:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 284:
DELETE FROM tntbl2 WHERE c2 = '2';
--Testcase 285:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 286:
DELETE FROM tntbl2 IN ('/mongo_svr/') WHERE c1 = 10;
--Testcase 287:
SELECT * FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 288:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_2', DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 289:
INSERT INTO tntbl3 (_id, c2, c3) VALUES ('_33', 3.0, DEFAULT);
--Testcase 290:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 291:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 292:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mongo_svr/', '/griddb_svr/', '/mysql_svr/', '/postgres_svr/', '/postgres_svr_1/') VALUES ('_infea', 20, 6.0, 60.0, 6000);
--Testcase 293:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 294:
UPDATE tntbl3 SET (c3, c2) = (SELECT c2 + 1 , c3 FROM tntbl3);
--Testcase 295:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 296:
UPDATE tntbl3 IN ('/tiny_svr/') SET c3 = 56.0;
--Testcase 297:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 298:
DELETE FROM tntbl3 WHERE c1 > 10;
--Testcase 299:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 300:
DELETE FROM tntbl3 IN ('/mongo_svr/') WHERE c3 = 56.0;
--Testcase 301:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;

--
--
-- Test with __spd_url
--
--Testcase 302:
DELETE FROM tntbl3 WHERE __spd_url = '/mongo_svr/';
--Testcase 303:
DELETE FROM tntbl3 WHERE __spd_url IS NOT NULL;
--Testcase 304:
INSERT INTO tntbl3 IN ('/dynamodb_svr/', '/mysql_svr/', '/griddb_svr/') VALUES ('foo', 30, 5.0, 50.0, 6000);
--Testcase 305:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 306:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 307:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 308:
DELETE FROM tntbl3;
--Testcase 309:
INSERT INTO tntbl3 (SELECT * FROM tntbl3 ORDER BY 1, 2, 3);
--Testcase 310:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 311:
INSERT INTO tntbl3 VALUES(repeat('x', 10), 20, 4.0, 40.0, 5000);
--Testcase 312:
SELECT c1, sum(c1), avg(c2) FROM tntbl3 WHERE __spd_url IS NOT NULL GROUP BY c1 HAVING c1 IS NOT NULL LIMIT 5;
--Testcase 313:
INSERT INTO tntbl3 VALUES ('foo', 30, 5.0, 50.0, 6000, '/postgres_svr/');
--Testcase 314:
SELECT * FROM tntbl3 ORDER BY 1, 2, 3;
--
-- Test with optional options: tntbl1
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 315:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12);  -- duplicate key
--Testcase 316:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT DO NOTHING; -- works
--Testcase 317:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 318:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 562.3213; -- unsupported
--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 319:
CREATE VIEW rw_view AS SELECT * FROM tntbl1
  WHERE c1 < c2 WITH CHECK OPTION;
--Testcase 320:
\d+ rw_view
--Testcase 321:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (5, 0);
--Testcase 322:
INSERT INTO rw_view(c1, c2) VALUES (5, 0); -- should fail
--Testcase 323:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (0, 15);
--Testcase 324:
INSERT INTO rw_view(c1, c2) VALUES (0, 15); -- ok
--Testcase 325:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 326:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 100;
--Testcase 327:
UPDATE rw_view SET c1 = c1 + 100; -- should fail
--Testcase 328:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 329:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 330:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 331:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 332:
INSERT INTO tntbl1 VALUES (1, 2, 3.0, 6.0, 21, '2002-01-01 00:05:00', '2022-05-16 10:50:00+01', 'test1', 'test1') RETURNING *;
--Testcase 333:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5) VALUES (2, 3, 4.0, 5.0, 6) RETURNING c1, c4, c6;
--Testcase 334:
UPDATE tntbl1 SET c7 = '2100-01-01 10:00:00+01' WHERE c1 = 2 AND c2 = 3 RETURNING (tntbl1), *;
--Testcase 335:
DELETE FROM tntbl1 WHERE c4 = 6.0 RETURNING c1, c2;
--Testcase 336:
DELETE FROM tntbl1 RETURNING *;
--
-- Test with optional options: tntbl2
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 337:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12);  -- duplicate key
--Testcase 338:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 339:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 340:
INSERT INTO tntbl2(_id, c1) VALUES('key', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 341:
CREATE VIEW rw_view AS SELECT * FROM tntbl2
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 342:
\d+ rw_view
--Testcase 343:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0);
--Testcase 344:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id1', 5, 0); -- should fail
--Testcase 345:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000);
--Testcase 346:
INSERT INTO rw_view(_id, c1, c5) VALUES ('id2', 5, 3000); -- ok
--Testcase 347:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 348:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 349:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 350:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 351:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 352:
SELECT char_length(_id), c1, char_length(c2), c3, c4, c5 FROM tntbl2 ORDER BY 1, 2, 3;
--Testcase 353:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 354:
INSERT INTO tntbl2 VALUES ('00:05:00', 20, '2022-05-16', false, 50.0, 7000) RETURNING *;
--Testcase 355:
INSERT INTO tntbl2 (_id, c1, c2, c3, c4, c5) VALUES ('_key_', 30, 'test', true, 50.0, 8000) RETURNING c1, c4, c5;
--Testcase 356:
UPDATE tntbl2 SET c2 = '2100-01-01 10:00:00+01' WHERE c1 = 20 AND c3 = false RETURNING (tntbl2), *;
--Testcase 357:
DELETE FROM tntbl2 WHERE c4 = 50.0 RETURNING _id, c1, c2;
--Testcase 358:
DELETE FROM tntbl2 RETURNING *;
--
-- Test with optional options: tntbl3
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 359:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12);  -- duplicate key
--Testcase 360:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT DO NOTHING; -- works
--Testcase 361:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO NOTHING; -- unsupported
--Testcase 362:
INSERT INTO tntbl3(_id, c1) VALUES('key$', 12) ON CONFLICT (_id, c1) DO UPDATE SET c2 = 'conficted!'; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 363:
CREATE VIEW rw_view AS SELECT * FROM tntbl3
  WHERE c2 < c3 WITH CHECK OPTION;
--Testcase 364:
\d+ rw_view
--Testcase 365:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0);
--Testcase 366:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id1', 5, 0); -- should fail
--Testcase 367:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000);
--Testcase 368:
INSERT INTO rw_view(_id, c2, c3) VALUES ('id2', 5, 3000); -- ok
--Testcase 369:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 370:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 10000;
--Testcase 371:
UPDATE rw_view SET c2 = c2 + 10000; -- should fail
--Testcase 372:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 373:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 374:
SELECT _id, c1, c2, c3, c4 FROM tntbl3 ORDER BY 1, 2, 3;
--Testcase 375:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 376:
INSERT INTO tntbl3 VALUES ('0000', 20, 5.0, 50.0, 5000) RETURNING *;
--Testcase 377:
INSERT INTO tntbl3 (_id, c1, c2, c3, c4) VALUES ('_key_', 30, 4.0, 50.0, 6000) RETURNING c1, c2, c3;
--Testcase 378:
UPDATE tntbl3 SET c2 = 7.0 WHERE c1 = 20 AND c3 = 50.0 RETURNING (tntbl3), *;
--Testcase 379:
DELETE FROM tntbl3 WHERE c3 = 50.0 RETURNING _id, c1, c2;
--Testcase 380:
DELETE FROM tntbl3 RETURNING *;
--
-- Test with optional options: tntbl4
--
--
--
-- ON CONFLICT, this work only on postgres_fdw
--
--Testcase 381:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$');  -- duplicate key
--Testcase 382:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT DO NOTHING; -- works
--Testcase 383:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 384:
INSERT INTO tntbl4(c1, c2) VALUES(14, 'key$') ON CONFLICT (c1, c2) DO UPDATE SET c4 = 5.0; -- unsupported

--
-- WITH CHECK, this work only on postgres_fdw
--
--Testcase 385:
CREATE VIEW rw_view AS SELECT * FROM tntbl4
  WHERE c1 < c5 WITH CHECK OPTION;
--Testcase 386:
\d+ rw_view
--Testcase 387:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 0);
--Testcase 388:
INSERT INTO rw_view(c1, c5) VALUES (15, 0); -- should fail
--Testcase 389:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c5) VALUES (15, 3000);
--Testcase 390:
INSERT INTO rw_view(c1, c5) VALUES (15, 3000); -- ok
--Testcase 391:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 392:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 10000;
--Testcase 393:
UPDATE rw_view SET c1 = c1 + 10000; -- should fail
--Testcase 394:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 15;
--Testcase 395:
UPDATE rw_view SET c1 = c1 + 15; -- ok
--Testcase 396:
SELECT c1, char_length(c2), c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20 FROM tntbl4 ORDER BY 1, 2, 3;
--Testcase 397:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 398:
INSERT INTO tntbl4 VALUES (70, '0000', true, 5.0, 5000) RETURNING *;
--Testcase 399:
INSERT INTO tntbl4 (c1, c2, c3, c4, c5) VALUES (80, '_key_', false, 4.0, 6000) RETURNING c1, c2, c3;
--Testcase 400:
UPDATE tntbl4 SET c4 = 7.0 WHERE c1 = 70 AND c3 = true RETURNING (tntbl4), *;
--Testcase 401:
DELETE FROM tntbl4 WHERE c3 = true RETURNING c1, c2, c3;
--Testcase 402:
DELETE FROM tntbl4 RETURNING *;
--Clean
--Testcase 403:
DROP FOREIGN TABLE tntbl1 CASCADE;
--Testcase 404:
DROP FOREIGN TABLE tntbl2 CASCADE;
--Testcase 405:
DROP FOREIGN TABLE tntbl3 CASCADE;
--Testcase 406:
DROP FOREIGN TABLE tntbl4 CASCADE;
--Testcase 407:
DROP FOREIGN TABLE tntbl5 CASCADE;

--Testcase 408:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 409:
DROP EXTENSION pgspider_fdw CASCADE;
--Testcase 410:
DROP SERVER pgspider_core_svr CASCADE;
--Testcase 411:
DROP EXTENSION pgspider_core_fdw CASCADE;
