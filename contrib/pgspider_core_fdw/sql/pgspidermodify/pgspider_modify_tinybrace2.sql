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
CREATE EXTENSION tinybrace_fdw;
-- Used data sources
-- Data sources
-- tntbl1: tinybrace_svr
-- key: c1, c2
--Testcase 8:
CREATE SERVER tinybrace_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host :TINYBRACE_SERVER, port :TINYBRACE_PORT, dbname 'pgmodifytest.db');
CREATE USER mapping for public SERVER tinybrace_svr OPTIONS(username :TINYBRACE_USER, password :TINYBRACE_PASS);

CREATE SERVER tinybrace_svr1 FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host :TINYBRACE_SERVER, port :TINYBRACE_PORT, dbname 'pgmodifytest1.db');
CREATE USER mapping for public SERVER tinybrace_svr1 OPTIONS(username :TINYBRACE_USER, password :TINYBRACE_PASS);

-- Create multi tenant tables
-- tntbl1
--Testcase 10:
CREATE FOREIGN TABLE tntbl1 (c1 int , c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(30), c9 varchar(50), __spd_url text) SERVER pgspider_svr;

-- Foreign tables
--Testcase 11:
CREATE FOREIGN TABLE tntbl1__tinybrace_svr__0 (c1 int OPTIONS (key 'true'), c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(30), c9 varchar(50)) SERVER tinybrace_svr OPTIONS (table_name 'tntbl1');
CREATE FOREIGN TABLE tntbl1__tinybrace_svr1__0 (c1 int OPTIONS (key 'true'), c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(30), c9 varchar(50)) SERVER tinybrace_svr1 OPTIONS (table_name 'tntbl1');

-- Reset data of remote table before test
DELETE FROM tntbl1__tinybrace_svr__0;
DELETE FROM tntbl1__tinybrace_svr1__0;
INSERT INTO tntbl1__tinybrace_svr__0 VALUES (100, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2022-06-22 14:00:00+07', 'tiny array', 'tiny varchar array');
INSERT INTO tntbl1__tinybrace_svr1__0 VALUES (101, 1, 2.0, 101.0, 1001, '2022-06-23 14:00:00', '2022-06-23 14:00:00+07', 'tiny array 1', 'tiny varchar array 1');

-- SELECT FROM table if there is any record
--Testcase 12:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- INSERT
-- insert with DEFAULT in the target_list
--
--Testcase 13:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (5, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 14:
INSERT INTO tntbl1 (c1, c2) VALUES (1, DEFAULT);
--Testcase 15:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (6, 5, DEFAULT);
--Testcase 16:
INSERT INTO tntbl1 VALUES (7, 6, 2.6, 5453.454, 5989, '2001-01-01 04:05:02');
--Testcase 17:
INSERT INTO tntbl1 VALUES (8, 7);

--Testcase 18:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- insert with similar expression / target_list VALUES (all fail)
--
--Testcase 19:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (10, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);
--Testcase 20:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (2, DEFAULT);
--Testcase 21:
INSERT INTO tntbl1 (c1, c2) VALUES (3, 2, 5);
--Testcase 22:
INSERT INTO tntbl1 (c1, c2) VALUES (11, DEFAULT, 6);

--Testcase 23:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- VALUES test
--
--Testcase 24:
INSERT INTO tntbl1 VALUES (10, 20, 3.0, 452.254, 599, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', '40', 'abc'), (-1, 2, DEFAULT, DEFAULT, 69845, '2004-10-19 10:23:54', '1970-01-01 00:00:01', 'Beera', 'John Does'),
    ((SELECT 2), (SELECT i FROM (VALUES(3)) as foo (i)), 4.0, 656.212, 5944, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', 'VALUES are fun!', 'foo');

--Testcase 25:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- UPDATE
--
--Testcase 29:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 30:
UPDATE tntbl1 SET c6 = DEFAULT, c4 = DEFAULT;
--Testcase 31:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table
--Testcase 32:
UPDATE tntbl1 AS t SET c1 = 10 WHERE t.c3 = 902.12;
--Testcase 33:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 34:
UPDATE tntbl1 t SET c1 = t.c1 + 10 WHERE t.c3 = 3.0;
--Testcase 35:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--
--Testcase 36:
UPDATE tntbl1 SET c1=v.i FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--Testcase 37:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, wrong data type:
--Testcase 38:
UPDATE tntbl1 SET c1 = v.* FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--
-- Test multiple-set-clause syntax
--
--Testcase 39:
INSERT INTO tntbl1 (SELECT c1+20, c2+50, c3 FROM tntbl1 ORDER BY 1, 2, 3);
--Testcase 40:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 41:
UPDATE tntbl1 SET (c8,c1,c2) = ('bugle', c1+11, DEFAULT) WHERE c9 = 'foo';
--Testcase 42:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 43:
UPDATE tntbl1 SET (c9,c4) = ('car', c1+c3), c1 = c1 + 1 WHERE c5 = 3122;
--Testcase 44:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- fail, multi assignment to same column:
--Testcase 45:
UPDATE tntbl1 SET (c9,c5) = ('car', c1+c5), c5 = c1 + 1 WHERE c2 = 20;

-- uncorrelated sub-SELECT:
--Testcase 46:
UPDATE tntbl1
  SET (c1,c3) = (SELECT c1,c3 FROM tntbl1 where c3 = 3 and c9 = 'car')
  WHERE c1 = 100 AND c2 = 20.0;
--Testcase 47:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- correlated sub-SELECT:
--Testcase 48:
UPDATE tntbl1 o
  SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 i
               where i.c4=o.c3 and i.c5=o.c5 and i.c5 is not distinct FROM o.c5);
--Testcase 49:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:
--Testcase 50:
UPDATE tntbl1 SET (c1,c2) = (SELECT c2+1,c1 FROM tntbl1);
-- set to null if no rows supplied:
--Testcase 51:
UPDATE tntbl1 SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 where c5 = 1000)
  WHERE c5 = 11;
--Testcase 52:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:
--Testcase 53:
UPDATE tntbl1 SET (c1,c2) = ROW(v.*) FROM (VALUES(2, 100)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:
--Testcase 54:
UPDATE tntbl1 SET (c1,c2) = (v.*) FROM (VALUES(2, 101)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name
--Testcase 55:
UPDATE tntbl1 AS t SET c1 = tntbl1.c1 + 10 WHERE t.c2 = 10;

-- Make sure that we can update to a TOASTed value.
--Testcase 56:
UPDATE tntbl1 SET c9 = repeat('x', 25) WHERE c9 = 'car';
--Testcase 57:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.
--Testcase 58:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;

--Testcase 59:
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;
--Testcase 60:
SELECT c2, c3, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--
--Testcase 61:
UPDATE tntbl1 IN ('/tinybrace_svr/', '/tinybrace_svr/') SET c3 = 22.2;
--
-- TOASTed value test
--
--Testcase 26:
INSERT INTO tntbl1 VALUES (9, 9, 902.12, 9545.03, 3122, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', repeat('x', 25), repeat('a', 25));

--Testcase 27:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--
--Testcase 28:
INSERT INTO tntbl1 IN ('/tinybrace_svr/') VALUES (-10, 20, 82.21, 213.12, 9565, '2003-10-19 10:23:54', '1971-01-01 00:00:01+07', 'One', 'OneOne');

--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table
--Testcase 62:
DELETE FROM tntbl1 AS dt WHERE dt.c1 > 75;
-- if an alias is specified, don't allow the original table name
-- to be referenced
--Testcase 63:
DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 25;
--Testcase 64:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- delete a row with a TOASTed value
--Testcase 65:
DELETE FROM tntbl1 WHERE c2 > 2;
--Testcase 66:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- DELETE with IN feature
--
--Testcase 67:
DELETE FROM tntbl1 IN ('/tinybrace_svr/') WHERE c1 = 20;

--Testcase 68:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 69:
DELETE FROM tntbl1 IN ('/tinybrace_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 1000;

--Testcase 70:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check
--Testcase 71:
ALTER FOREIGN TABLE tntbl1 OPTIONS (disable_transaction_feature_check 'false');
--Testcase 72:
INSERT INTO tntbl1 VALUES (200, 70, 2.0, 200.0, 3000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', DEFAULT, 'abc', 'foo');
--Testcase 73:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 74:
INSERT INTO tntbl1 VALUES (100, 20, 3.0, 300.0, 4000, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', interval '2 months ago', '40', 'abc'), (-100, 30, DEFAULT, DEFAULT, 2000, '2004-10-19 10:23:54', '1970-01-01 00:00:01+07', interval '1 year 3 hours 20 minutes', 'Beera', 'John Does'),
    ((SELECT 201), (SELECT i FROM (VALUES(3)) as foo (i)), 250, 400.212, 5000, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', interval '1 year 2 months 3 days', 'VALUES are fun!', 'foo');

--Testcase 75:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 76:
INSERT INTO tntbl1 VALUES (900, 80, 6.0, 400.03, 6000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', interval '1 months ago', repeat('x', 10), repeat('a', 20));
--Testcase 77:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 78:
UPDATE tntbl1 SET c2 = 10.001 WHERE c1 = 100;
--Testcase 79:
DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 100;
--Testcase 80:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 81:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (600, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');
--Testcase 82:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 83:
UPDATE tntbl1 IN ('/dynamodb_svr/') SET c4 = 60.0;
--Testcase 84:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 85:
DELETE FROM tntbl1 IN ('/tinybrace_svr/', '/tiny_svr/', '/mysql_svr/') WHERE c5 = 4000;
--Testcase 86:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 87:
ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');
--
-- Test with optional options: tntbl1
--
--
-- ON CONFLICT, this work only on tinybrace_fdw
--
--Testcase 88:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12);  -- duplicate key
--Testcase 89:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT DO NOTHING; -- works
--Testcase 90:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported
--Testcase 91:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 562.3213; -- unsupported
--
-- WITH CHECK, this work only on tinybrace_fdw
--
--Testcase 92:
CREATE VIEW rw_view AS SELECT * FROM tntbl1
  WHERE c1 < c2 WITH CHECK OPTION;
--Testcase 93:
\d+ rw_view
--Testcase 94:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (5, 0);
--Testcase 95:
INSERT INTO rw_view(c1, c2) VALUES (5, 0); -- should fail
--Testcase 96:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (0, 15);
--Testcase 97:
INSERT INTO rw_view(c1, c2) VALUES (0, 15); -- ok
--Testcase 98:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 99:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 100;
--Testcase 100:
UPDATE rw_view SET c1 = c1 + 100; -- should fail
--Testcase 101:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;
--Testcase 102:
UPDATE rw_view SET c2 = c2 + 15; -- ok
--Testcase 103:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--Testcase 104:
DROP VIEW rw_view;
--
-- RETURNING
--
--Testcase 105:
INSERT INTO tntbl1 VALUES (1, 2, 3.0, 6.0, 21, '2002-01-01 00:05:00', '2022-05-16 10:50:00+01', 'test1', 'test1') RETURNING *;
--Testcase 106:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5) VALUES (2, 3, 4.0, 5.0, 6) RETURNING c1, c4, c6;
--Testcase 107:
UPDATE tntbl1 SET c7 = '2100-01-01 10:00:00+01' WHERE c1 = 2 AND c2 = 3 RETURNING (tntbl1), *;
--Testcase 108:
DELETE FROM tntbl1 WHERE c4 = 6.0 RETURNING c1, c2;
--Testcase 109:
DELETE FROM tntbl1 RETURNING *;

--
-- Test case bulk insert
--
--Clean
--Testcase 115:
DELETE FROM tntbl1;
--Testcase 116:
SELECT * FROM tntbl1;

SET client_min_messages = INFO;

-- Auto config: batch_size of FDW = 10, insert 30 records
ALTER SERVER tinybrace_svr OPTIONS (ADD batch_size '10');
ALTER SERVER tinybrace_svr1 OPTIONS (ADD batch_size '10');
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);

--Testcase 117:
INSERT INTO tntbl1
	SELECT id, id % 10, id/10, id * 100, id * 1000, '1970-01-01 00:00:01'::timestamp + ((id % 100) || ' days')::interval, '1970-01-01 00:00:01'::timestamptz + ((id % 100) || ' days')::interval, to_char(id, 'FM00000'), 'foo'	FROM generate_series(1, 30) id;
--Testcase 118:
SELECT * FROM tntbl1 ORDER BY 1,2;
--Testcase 119:
SELECT * FROM tntbl1__tinybrace_svr__0 ORDER BY 1,2;
--Testcase 120:
SELECT * FROM tntbl1__tinybrace_svr1__0 ORDER BY 1,2;

--Clean
DELETE FROM tntbl1__tinybrace_svr__0;
DELETE FROM tntbl1__tinybrace_svr1__0;
--Reset data
INSERT INTO tntbl1__tinybrace_svr__0 VALUES (100, 0, 1.0, 100.0, 1000, '2022-06-22 14:00:00', '2022-06-22 14:00:00+07', 'tiny array', 'tiny varchar array');
INSERT INTO tntbl1__tinybrace_svr1__0 VALUES (101, 1, 2.0, 101.0, 1001, '2022-06-23 14:00:00', '2022-06-23 14:00:00+07', 'tiny array 1', 'tiny varchar array 1');
--Testcase 110:
DROP FOREIGN TABLE tntbl1 CASCADE;
--Testcase 111:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 112:
DROP EXTENSION tinybrace_fdw CASCADE;
--Testcase 113:
DROP SERVER pgspider_svr CASCADE;
--Testcase 114:
DROP EXTENSION pgspider_core_fdw CASCADE;
