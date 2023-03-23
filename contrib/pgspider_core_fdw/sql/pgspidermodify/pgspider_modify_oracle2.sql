\set ECHO none 
\ir sql/pgspidermodify/parameters.conf
\set ECHO all

SET datestyle = ISO;

SET timezone = 'UTC';


--Testcase 1:
DELETE FROM pg_spd_node_info;

--Testcase 2:
CREATE EXTENSION pgspider_core_fdw;

--Testcase 3:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER1);

--Testcase 4:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
-- Extensions

--Testcase 5:
CREATE EXTENSION oracle_fdw;
--Testcase 6:
CREATE SERVER oracle_svr_1 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver :ORACLE_SERVER, isolation_level 'read_committed', nchar 'true');
--Testcase 7:
CREATE USER MAPPING FOR public SERVER oracle_svr_1 OPTIONS (user :ORACLE_USER, password :ORACLE_PASS);

--Testcase 8:
CREATE SERVER oracle_svr_2 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver :ORACLE_SERVER, isolation_level 'read_committed', nchar 'true');
--Testcase 9:
CREATE USER MAPPING FOR public SERVER oracle_svr_2 OPTIONS (user :ORACLE_USER, password :ORACLE_PASS);
-- Create multi tenant tables
-- tntbl1

--Testcase 10:
CREATE FOREIGN TABLE tntbl1 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(30), c9 varchar(50), __spd_url text) SERVER pgspider_svr;

-- Foreign tables

--Testcase 11:
CREATE FOREIGN TABLE tntbl1__oracle_svr_1__0 (c1 int OPTIONS (key 'yes') NOT NULL, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER oracle_svr_1 OPTIONS (table 'TNTBL1');

--Testcase 12:
CREATE FOREIGN TABLE tntbl1__oracle_svr_2__0 (c1 int OPTIONS (key 'yes') NOT NULL, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER oracle_svr_2 OPTIONS (table 'TNTBL1_2');

-- SELECT FROM table if there is any record
--Testcase 13:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- INSERT
-- insert with DEFAULT in the target_list
--

--Testcase 14:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (4, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

--Testcase 15:
INSERT INTO tntbl1 (c1, c2) VALUES (1, DEFAULT);

--Testcase 16:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (5, 5, DEFAULT);

--Testcase 17:
INSERT INTO tntbl1 VALUES (6, 6, 2.6, 5453.454, 5989, '2001-01-01 04:05:02');

--Testcase 18:
INSERT INTO tntbl1 VALUES (7, 7);


--Testcase 19:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- insert with similar expression / target_list VALUES (all fail)
--

--Testcase 20:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (10, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

--Testcase 21:
INSERT INTO tntbl1 (c1, c2, c3) VALUES (2, DEFAULT);

--Testcase 22:
INSERT INTO tntbl1 (c1, c2) VALUES (3, 2, 5);

--Testcase 23:
INSERT INTO tntbl1 (c1, c2) VALUES (8, DEFAULT, 6);


--Testcase 24:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- VALUES test
--

--Testcase 25:
INSERT INTO tntbl1 VALUES (10, 20, 3.0, 452.254, 599, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', '40', 'abc'), (-1, 2, DEFAULT, DEFAULT, 69845, '2004-10-19 10:23:54', '1970-01-01 00:00:01', 'Beera', 'John Does'),
    ((SELECT 2), (SELECT i FROM (VALUES(3)) as foo (i)), 4.0, 656.212, 5944, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', 'VALUES are fun!', 'foo');


--Testcase 26:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- TOASTed value test
--

--Testcase 27:
INSERT INTO tntbl1 VALUES (9, 9, 902.12, 9545.03, 3122, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', repeat('x', 25), repeat('a', 25));


--Testcase 28:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature
--

--Testcase 29:
INSERT INTO tntbl1 IN ('/oracle_svr/') VALUES (-10, 20, 82.21, 213.12, 9565, '2003-10-19 10:23:54', '1971-01-01 00:00:01+07', 'One', 'OneOne');

--
-- UPDATE
--

--Testcase 30:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 31:
UPDATE tntbl1 SET c6 = DEFAULT, c4 = DEFAULT;

--Testcase 32:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table

--Testcase 33:
UPDATE tntbl1 AS t SET c1 = 15 WHERE t.c3 = 902.12;

--Testcase 34:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 35:
UPDATE tntbl1 t SET c1 = t.c1 + 10 WHERE t.c3 = 3.0;

--Testcase 36:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

--Testcase 37:
UPDATE tntbl1 SET c1=v.i FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;


--Testcase 38:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, wrong data type:

--Testcase 39:
UPDATE tntbl1 SET c1 = v.* FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--
-- Test multiple-set-clause syntax
--
--Testcase 40:
INSERT INTO tntbl1 (SELECT c1+20, c2+50, c3 FROM tntbl1 ORDER BY 1, 2, 3);

--Testcase 41:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;


--Testcase 42:
UPDATE tntbl1 SET (c8,c1,c2) = ('bugle', c1+11, DEFAULT) WHERE c9 = 'foo';

--Testcase 43:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 44:
UPDATE tntbl1 SET (c9,c4) = ('car', c1+c3), c1 = c1 + 1 WHERE c5 = 3122;

--Testcase 45:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- fail, multi assignment to same column:

--Testcase 46:
UPDATE tntbl1 SET (c9,c5) = ('car', c1+c5), c5 = c1 + 1 WHERE c2 = 20;

-- uncorrelated sub-SELECT:
-- 
--Testcase 47:
UPDATE tntbl1
  SET (c1,c3) = (SELECT c1,c3 FROM tntbl1 where c3 = 3 and c9 = 'car')
  WHERE c1 = 100 AND c2 = 20.0;

--Testcase 48:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- correlated sub-SELECT:

--Testcase 49:
UPDATE tntbl1 o
  SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 i
               where i.c4=o.c3 and i.c5=o.c5 and i.c5 is not distinct FROM o.c5);

--Testcase 50:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:

--Testcase 51:
UPDATE tntbl1 SET (c1,c2) = (SELECT c2+1,c1 FROM tntbl1);
--set to null if no rows supplied:
--Testcase 52:
UPDATE tntbl1 SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 where c5 = 1000)
  WHERE c5 = 11;

--Testcase 53:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:

--Testcase 54:
UPDATE tntbl1 SET (c1,c2) = ROW(v.*) FROM (VALUES(2, 100)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:

--Testcase 55:
UPDATE tntbl1 SET (c1,c2) = (v.*) FROM (VALUES(2, 101)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name

--Testcase 56:
UPDATE tntbl1 AS t SET c1 = tntbl1.c1 + 10 WHERE t.c2 = 10;

-- Make sure that we can update to a TOASTed value.

--Testcase 57:
UPDATE tntbl1 SET c9 = repeat('x', 25) WHERE c9 = 'car';

--Testcase 58:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.

--Testcase 59:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;

--Testcase 60:
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;

--Testcase 61:
SELECT c2, c3, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--

--Testcase 62:
UPDATE tntbl1 IN ('/oracle_svr/', '/sqlite_svr/') SET c3 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table

--Testcase 63:
DELETE FROM tntbl1 AS dt WHERE dt.c1 > 75;
-- if an alias is specified, don't allow the original table name
-- to be referenced

--Testcase 64:
DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 25;

--Testcase 65:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- delete a row with a TOASTed value

--Testcase 66:
DELETE FROM tntbl1 WHERE c2 > 2;

--Testcase 67:
SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- DELETE with IN feature
--

--Testcase 68:
DELETE FROM tntbl1 IN ('/oracle_svr/') WHERE c1 = 20;


--Testcase 69:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 70:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/oracle_svr/') WHERE c5 = 1000;


--Testcase 71:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check

ALTER FOREIGN TABLE tntbl1 OPTIONS (disable_transaction_feature_check 'false');

--Testcase 72:
INSERT INTO tntbl1 VALUES (200, 70, 2.0, 200.0, 3000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', DEFAULT, 'abc', 'foo');

--Testcase 73:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 74:
INSERT INTO tntbl1 VALUES (100, 20, 3.0, 300.0, 4000, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', interval '2 months ago', '40', 'abc'), (-100, 30, DEFAULT, DEFAULT, 2000, '2004-10-19 10:23:54', '1970-01-01 00:00:01+07', interval '1 year 3 hours 20 minutes', 'Beera', 'John Does'),
    ((SELECT 220), (SELECT i FROM (VALUES(3)) as foo (i)), 250, 400.212, 5000, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', interval '1 year 2 months 3 days', 'VALUES are fun!', 'foo');


--Testcase 75:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 76:
INSERT INTO tntbl1 VALUES (900, 80, 6.0, 400.03, 6000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', interval '1 months ago', repeat('x', 10), repeat('a', 20));

--Testcase 77:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 78:
UPDATE tntbl1 SET c2 = 10.001 WHERE c1 = 100;

--Testcase 79:
DELETE FROM tntbl1 WHERE tntbl1.c1 > 100;

--Testcase 80:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 81:
INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (600, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');

--Testcase 82:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 83:
UPDATE tntbl1 IN ('/oracle_svr/') SET c4 = 60.0;

--Testcase 84:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 85:
DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/oracle_svr/') WHERE c5 = 4000;

--Testcase 86:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;


ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');
--
-- Test with optional options: tntbl1
--
--
-- ON CONFLICT, this work only on postgres_fdw
--

--Testcase 87:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12);  -- duplicate key

--Testcase 88:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT DO NOTHING; -- works

--Testcase 89:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported

--Testcase 90:
INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 562.3213; -- unsupported
--
-- WITH CHECK, this work only on postgres_fdw
--

--Testcase 91:
CREATE VIEW rw_view AS SELECT * FROM tntbl1
  WHERE c1 < c2 WITH CHECK OPTION;

--Testcase 92:
\d+ rw_view

--Testcase 93:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (5, 0);

--Testcase 94:
INSERT INTO rw_view(c1, c2) VALUES (5, 0); -- should fail

--Testcase 95:
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (0, 15);

--Testcase 96:
INSERT INTO rw_view(c1, c2) VALUES (0, 15); -- ok

--Testcase 97:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 98:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 100;

--Testcase 99:
UPDATE rw_view SET c1 = c1 + 100; -- should fail

--Testcase 100:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;

--Testcase 101:
UPDATE rw_view SET c2 = c2 + 15; -- ok

--Testcase 102:
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--Testcase 103:
DROP VIEW rw_view;
--
-- RETURNING
--

--Testcase 104:
INSERT INTO tntbl1 VALUES (1, 2, 3.0, 6.0, 21, '2002-01-01 00:05:00', '2022-05-16 10:50:00+01', 'test1', 'test1') RETURNING *;

--Testcase 105:
INSERT INTO tntbl1 (c1, c2, c3, c4, c5) VALUES (2, 3, 4.0, 5.0, 6) RETURNING c1, c4, c6;

--Testcase 106:
UPDATE tntbl1 SET c7 = '2100-01-01 10:00:00+01' WHERE c1 = 2 AND c2 = 3 RETURNING (tntbl1), *;

--Testcase 107:
DELETE FROM tntbl1 WHERE c4 = 6.0 RETURNING c1, c2;

--Testcase 108:
DELETE FROM tntbl1 RETURNING *;

--
-- Test case bulk insert
--
--Clean
--Testcase 109:
DELETE FROM tntbl1;
--Testcase 110:
SELECT * FROM tntbl1;
SET client_min_messages = INFO;

-- Auto config: batch_size of FDW = 10, insert 30 records
--Testcase 111:
INSERT INTO tntbl1
	SELECT id, id % 10, id/10, id * 100, id * 1000, '1970-01-01 00:00:01'::timestamp + ((id % 100) || ' days')::interval, '1970-01-01 00:00:01'::timestamptz + ((id % 100) || ' days')::interval, to_char(id, 'FM00000'), 'foo'	FROM generate_series(1, 30) id;

--Testcase 112:
SELECT * FROM tntbl1 ORDER BY 1,2;
--Testcase 113:
SELECT * FROM tntbl1__oracle_svr_1__0 ORDER BY 1,2;
--Testcase 114:
SELECT * FROM tntbl1__oracle_svr_2__0 ORDER BY 1,2;

--Clean
--Testcase 115:
DELETE FROM tntbl1;
--Reset data
--Testcase 116:
INSERT INTO tntbl1__oracle_svr_1__0 VALUES (-20, 0, 1.0, 100.0, 1000, TO_TIMESTAMP('2022-06-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2017-08-07 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'char array', 'varchar array');
--Testcase 117:
SELECT * FROM tntbl1;

--Testcase 118:
DROP FOREIGN TABLE tntbl1 CASCADE;

--Testcase 119:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;

--Testcase 120:
DROP EXTENSION oracle_fdw CASCADE;

--Testcase 121:
DROP SERVER pgspider_svr CASCADE;

--Testcase 122:
DROP EXTENSION pgspider_core_fdw CASCADE;
