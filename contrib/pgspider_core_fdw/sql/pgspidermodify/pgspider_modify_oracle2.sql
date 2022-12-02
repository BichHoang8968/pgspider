\set ECHO none 
\ir sql/pgspidermodify/parameters.conf
\set ECHO all

SET datestyle = ISO;

SET timezone = 'UTC';


DELETE FROM pg_spd_node_info;

CREATE EXTENSION pgspider_core_fdw;

CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_SERVER1);

CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
-- Extensions

CREATE EXTENSION oracle_fdw;
CREATE SERVER oracle_svr_1 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver :ORACLE_SERVER, isolation_level 'read_committed', nchar 'true');
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_svr_1 OPTIONS (user :ORACLE_USER, password :ORACLE_PASS);

CREATE SERVER oracle_svr_2 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver :ORACLE_SERVER, isolation_level 'read_committed', nchar 'true');
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_svr_2 OPTIONS (user :ORACLE_USER, password :ORACLE_PASS);
-- Create multi tenant tables
-- tntbl1

CREATE FOREIGN TABLE tntbl1 (c1 int, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(30), c9 varchar(50), __spd_url text) SERVER pgspider_svr;

-- Foreign tables

CREATE FOREIGN TABLE tntbl1__oracle_svr_1__0 (c1 int OPTIONS (key 'yes') NOT NULL, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER oracle_svr_1 OPTIONS (table 'TNTBL1');

CREATE FOREIGN TABLE tntbl1__oracle_svr_2__0 (c1 int OPTIONS (key 'yes') NOT NULL, c2 smallint, c3 float, c4 double precision, c5 bigint, c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255)) SERVER oracle_svr_2 OPTIONS (table 'TNTBL1_2');

-- SELECT FROM table if there is any record
SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- INSERT
-- insert with DEFAULT in the target_list
--

INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (4, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO tntbl1 (c1, c2) VALUES (1, DEFAULT);

INSERT INTO tntbl1 (c1, c2, c3) VALUES (5, 5, DEFAULT);

INSERT INTO tntbl1 VALUES (6, 6, 2.6, 5453.454, 5989, '2001-01-01 04:05:02');

INSERT INTO tntbl1 VALUES (7, 7);


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- insert with similar expression / target_list VALUES (all fail)
--

INSERT INTO tntbl1 (c1, c2, c3, c4, c5, c6, c7, c8, c9) VALUES (10, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO tntbl1 (c1, c2, c3) VALUES (2, DEFAULT);

INSERT INTO tntbl1 (c1, c2) VALUES (3, 2, 5);

INSERT INTO tntbl1 (c1, c2) VALUES (8, DEFAULT, 6);


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- VALUES test
--

INSERT INTO tntbl1 VALUES (10, 20, 3.0, 452.254, 599, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', '40', 'abc'), (-1, 2, DEFAULT, DEFAULT, 69845, '2004-10-19 10:23:54', '1970-01-01 00:00:01', 'Beera', 'John Does'),
    ((SELECT 2), (SELECT i FROM (VALUES(3)) as foo (i)), 4.0, 656.212, 5944, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', 'VALUES are fun!', 'foo');


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;
--
-- TOASTed value test
--

INSERT INTO tntbl1 VALUES (9, 9, 902.12, 9545.03, 3122, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', repeat('x', 25), repeat('a', 25));


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- INSERT with IN feature, this feature not work yet
--

INSERT INTO tntbl1 IN ('/oracle_svr/') VALUES (-10, 20, 82.21, 213.12, 9565, '2003-10-19 10:23:54', '1971-01-01 00:00:01+07', 'One', 'OneOne');

--
-- UPDATE
--

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

UPDATE tntbl1 SET c6 = DEFAULT, c4 = DEFAULT;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- aliases for the UPDATE target table

UPDATE tntbl1 AS t SET c1 = 15 WHERE t.c3 = 902.12;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

UPDATE tntbl1 t SET c1 = t.c1 + 10 WHERE t.c3 = 3.0;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Test VALUES in FROM
--

UPDATE tntbl1 SET c1=v.i FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;


SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, wrong data type:

UPDATE tntbl1 SET c1 = v.* FROM (VALUES(30, 0)) AS v(i, j)
  WHERE tntbl1.c2 = v.j;

--
-- Test multiple-set-clause syntax
--
INSERT INTO tntbl1 SELECT c1+20, c2+50, c3 FROM tntbl1;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;


UPDATE tntbl1 SET (c8,c1,c2) = ('bugle', c1+11, DEFAULT) WHERE c9 = 'foo';

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

UPDATE tntbl1 SET (c9,c4) = ('car', c1+c3), c1 = c1 + 1 WHERE c5 = 3122;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- fail, multi assignment to same column:

UPDATE tntbl1 SET (c9,c5) = ('car', c1+c5), c5 = c1 + 1 WHERE c2 = 20;

-- uncorrelated sub-SELECT:
-- 
UPDATE tntbl1
  SET (c1,c3) = (SELECT c1,c3 FROM tntbl1 where c3 = 3 and c9 = 'car')
  WHERE c1 = 100 AND c2 = 20.0;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- correlated sub-SELECT:

UPDATE tntbl1 o
  SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 i
               where i.c4=o.c3 and i.c5=o.c5 and i.c5 is not distinct FROM o.c5);

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- fail, multiple rows supplied:

UPDATE tntbl1 SET (c1,c2) = (SELECT c2+1,c1 FROM tntbl1);
--set to null if no rows supplied:
UPDATE tntbl1 SET (c4,c5) = (SELECT c4+1,c5 FROM tntbl1 where c5 = 1000)
  WHERE c5 = 11;

SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- *-expansion should work in this context:

UPDATE tntbl1 SET (c1,c2) = ROW(v.*) FROM (VALUES(2, 100)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;
-- you might expect this to work, but syntactically it's not a RowExpr:

UPDATE tntbl1 SET (c1,c2) = (v.*) FROM (VALUES(2, 101)) AS v(i, j)
  WHERE tntbl1.c2 = v.i;

-- if an alias for the target table is specified, don't allow references
-- to the original table name

UPDATE tntbl1 AS t SET c1 = tntbl1.c1 + 10 WHERE t.c2 = 10;

-- Make sure that we can update to a TOASTed value.

UPDATE tntbl1 SET c9 = repeat('x', 25) WHERE c9 = 'car';

SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;

-- Check multi-assignment with a Result node to handle a one-time filter.

EXPLAIN (VERBOSE, COSTS OFF)
UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;

UPDATE tntbl1 t
  SET (c2, c3) = (SELECT c3, c2 FROM tntbl1 s WHERE s.c2 = t.c2)
  WHERE CURRENT_USER = SESSION_USER;

SELECT c2, c3, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- UPDATE with IN feature
--

UPDATE tntbl1 IN ('/oracle_svr/', '/sqlite_svr/') SET c3 = 22.2;
--
-- DELETE
--
-- allow an alias to be specified for DELETE's target table

DELETE FROM tntbl1 AS dt WHERE dt.c1 > 75;
-- if an alias is specified, don't allow the original table name
-- to be referenced

DELETE FROM tntbl1 dt WHERE tntbl1.c1 > 25;

SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
-- delete a row with a TOASTed value

DELETE FROM tntbl1 WHERE c2 > 2;

SELECT c1, c2, c9 FROM tntbl1 ORDER BY 1, 2, 3;
--
-- DELETE with IN feature
--

DELETE FROM tntbl1 IN ('/oracle_svr/') WHERE c1 = 20;


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/oracle_svr/') WHERE c5 = 1000;


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

--
-- Check behavior of disable_transaction_feature_check
--
-- Check value of disable_transaction_feature_check

ALTER FOREIGN TABLE tntbl1 OPTIONS (disable_transaction_feature_check 'false');

INSERT INTO tntbl1 VALUES (200, 70, 2.0, 200.0, 3000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', DEFAULT, 'abc', 'foo');

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

INSERT INTO tntbl1 VALUES (100, 20, 3.0, 300.0, 4000, '2038-01-19 03:14:07', '2004-10-19 10:23:54+02', interval '2 months ago', '40', 'abc'), (-100, 30, DEFAULT, DEFAULT, 2000, '2004-10-19 10:23:54', '1970-01-01 00:00:01+07', interval '1 year 3 hours 20 minutes', 'Beera', 'John Does'),
    ((SELECT 220), (SELECT i FROM (VALUES(3)) as foo (i)), 250, 400.212, 5000, '2007-10-19 10:23:54', '2007-10-19 10:23:54+02', interval '1 year 2 months 3 days', 'VALUES are fun!', 'foo');


SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

INSERT INTO tntbl1 VALUES (900, 80, 6.0, 400.03, 6000, '2030-02-20 03:00:07', '2005-10-20 10:20:54+02', interval '1 months ago', repeat('x', 10), repeat('a', 20));

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

UPDATE tntbl1 SET c2 = 10.001 WHERE c1 = 100;

DELETE FROM tntbl1 WHERE tntbl1.c1 > 100;

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

INSERT INTO tntbl1 IN ('/oracle_svr/', '/tiny_svr/') VALUES (600, 120, 73.265, 78523.5, 5421659, '2002-10-19 10:23:54', '1972-01-01 00:00:01+07', 'Two', 'TwoTwo');

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

UPDATE tntbl1 IN ('/oracle_svr/') SET c4 = 60.0;

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

DELETE FROM tntbl1 IN ('/sqlite_svr/', '/tiny_svr/', '/oracle_svr/') WHERE c5 = 4000;

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;


ALTER FOREIGN TABLE tntbl1 OPTIONS (SET disable_transaction_feature_check 'true');
--
-- Test with optional options: tntbl1
--
--
-- ON CONFLICT, this work only on postgres_fdw
--

INSERT INTO tntbl1(c1, c2) VALUES(11, 12);  -- duplicate key

INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT DO NOTHING; -- works

INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO NOTHING; -- unsupported

INSERT INTO tntbl1(c1, c2) VALUES(11, 12) ON CONFLICT (c1, c2) DO UPDATE SET c3 = 562.3213; -- unsupported
--
-- WITH CHECK, this work only on postgres_fdw
--

CREATE VIEW rw_view AS SELECT * FROM tntbl1
  WHERE c1 < c2 WITH CHECK OPTION;

\d+ rw_view

EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (5, 0);

INSERT INTO rw_view(c1, c2) VALUES (5, 0); -- should fail

EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rw_view(c1, c2) VALUES (0, 15);

INSERT INTO rw_view(c1, c2) VALUES (0, 15); -- ok

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c1 = c1 + 100;

UPDATE rw_view SET c1 = c1 + 100; -- should fail

EXPLAIN (VERBOSE, COSTS OFF)
UPDATE rw_view SET c2 = c2 + 15;

UPDATE rw_view SET c2 = c2 + 15; -- ok

SELECT * FROM tntbl1 ORDER BY 1, 2, 3;

DROP VIEW rw_view;
--
-- RETURNING
--

INSERT INTO tntbl1 VALUES (1, 2, 3.0, 6.0, 21, '2002-01-01 00:05:00', '2022-05-16 10:50:00+01', 'test1', 'test1') RETURNING *;

INSERT INTO tntbl1 (c1, c2, c3, c4, c5) VALUES (2, 3, 4.0, 5.0, 6) RETURNING c1, c4, c6;

UPDATE tntbl1 SET c7 = '2100-01-01 10:00:00+01' WHERE c1 = 2 AND c2 = 3 RETURNING (tntbl1), *;

DELETE FROM tntbl1 WHERE c4 = 6.0 RETURNING c1, c2;

DELETE FROM tntbl1 RETURNING *;

--Clean
DELETE FROM tntbl1;
--Reset data
INSERT INTO tntbl1__oracle_svr_1__0 VALUES (-20, 0, 1.0, 100.0, 1000, TO_TIMESTAMP('2022-06-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2017-08-07 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'char array', 'varchar array');
SELECT * FROM tntbl1;

DROP FOREIGN TABLE tntbl1 CASCADE;

DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;

DROP EXTENSION oracle_fdw CASCADE;

DROP SERVER pgspider_svr CASCADE;

DROP EXTENSION pgspider_core_fdw CASCADE;
