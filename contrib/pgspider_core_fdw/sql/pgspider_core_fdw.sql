DELETE FROM pg_spd_node_info;
--SELECT pg_sleep(15);
CREATE EXTENSION pgspider_core_fdw;
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1',port '50849');
CREATE USER mapping for public server pgspider_svr OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE test1 (i int,__spd_url text) SERVER pgspider_svr;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION file_fdw;
CREATE EXTENSION sqlite_fdw;
CREATE EXTENSION tinybrace_fdw;
CREATE EXTENSION mysql_fdw;

CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE filetbl__file_svr__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
CREATE FOREIGN TABLE filetbl (i int,__spd_url text) SERVER pgspider_svr;
SELECT * FROM filetbl;

/*
CREATE SERVER filesvr2 FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE test1__file_svr__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
SELECT * FROM test1;
CREATE FOREIGN TABLE test1__filesvr2__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
SELECT * FROM test1 order by i,__spd_url;
SELECT * FROM test1 IN ('/file_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/file_svr/') where i = 1;
*/
CREATE SERVER tiny_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host '127.0.0.1',port '5100', dbname 'test.db');
CREATE USER mapping for public server tiny_svr OPTIONS(username 'user',password 'testuser');
CREATE FOREIGN TABLE test1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS(table_name 'test1');
SELECT * FROM test1__tiny_svr__0 ORDER BY i;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/tiny_svr/');
SELECT * FROM test1 IN ('/tiny_svr/') where i = 1;
CREATE SERVER post_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
CREATE USER mapping for public server post_svr OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE test1__post_svr__0 (i int) SERVER post_svr OPTIONS(table_name 'test1');
SELECT * FROM test1__post_svr__0 ORDER BY i;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/post_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/post_svr/') where i = 1 ORDER BY i,__spd_url;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/pgtest.db');
CREATE FOREIGN TABLE test1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS(table 'test1');
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/') where i = 4 ORDER BY i,__spd_url;
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
CREATE USER mapping for public server mysql_svr OPTIONS(username 'root',password 'Mysql_1234');
CREATE FOREIGN TABLE test1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test1');
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 where i = 1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') where i = 5 ORDER BY i,__spd_url;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/test2/') ORDER BY i,__spd_url;
SELECT * FROM test1 order by i,__spd_url;
SELECT * FROM test1 IN ('/file_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/file_svr/') where i = 1 ORDER BY i,__spd_url;
SELECT * FROM test1__tiny_svr__0 order by i;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/tiny_svr/');
SELECT * FROM test1 IN ('/tiny_svr/') where i = 1;
SELECT * FROM test1__post_svr__0 order by i;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/post_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/post_svr/') where i = 1 ORDER BY i,__spd_url;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/') where i = 4 ORDER BY i,__spd_url;
SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 where i = 1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') where i = 5 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') ORDER BY  i,__spd_url;

SELECT * FROM test1 UNION ALL SELECT * FROM test1 ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') UNION ALL SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/') UNION ALL SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') UNION ALL SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') ORDER BY i,__spd_url;

CREATE FOREIGN TABLE test1_1 (i int,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE test1_1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS(table_name 'test1');
CREATE FOREIGN TABLE test1_1__post_svr__0 (i int) SERVER post_svr OPTIONS(table_name 'test1');
CREATE FOREIGN TABLE test1_1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS(table 'test1');
CREATE FOREIGN TABLE test1_1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test1');

SELECT * FROM test1 IN ('/mysql_svr/'), test1_1 IN ('/sqlite_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svr/'), test1_1 IN ('/mysql_svr/','/sqlite_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
-- nothing case
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svrrrrrr/');
SELECT * FROM test1 IN ('/mysql_svr/'), test1_1 IN ('/mysql_svr2/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
SELECT * FROM test1 IN ('/mysql_svr2/'), test1_1 IN ('/mysql_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
SELECT * FROM test1 IN ('/mysql_svr2/'), test1_1 IN ('/mysql_svr2/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svr2/'), test1_1 IN ('/sqlite_svr2/','/mysql_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;

EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM test1;
-- some fdw push down and some fdw not 
EXPLAIN (VERBOSE, COSTS OFF) SELECT sum(i), avg(i) FROM test1;
-- only post_svr is alive
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM test1 IN ('/post_svr/');

-- only __spd_url target list is OK
SELECT __spd_url FROM test1 ORDER BY __spd_url;

SELECT i, __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;
SELECT __spd_url, i FROM test1 GROUP BY i, __spd_url ORDER BY i;
SELECT avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;
SELECT __spd_url, avg(i) FROM test1 GROUP BY i, __spd_url ORDER BY i;
SELECT __spd_url, sum(i) FROM test1 GROUP BY i, __spd_url ORDER BY i;
SELECT __spd_url, avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;

SELECT sum(i) FROM test1;

SELECT avg(i) FROM test1;
SELECT avg(i),i FROM test1 group by i order by i;
SELECT sum(i),count(i),i FROM test1 group by i order by i;

SELECT avg(i), count(i) FROM test1 group by i;

SELECT SUM(i) as aa, avg(i) FROM test1 GROUP BY i;
SELECT SUM(i) as aa, avg(i), i/2, SUM(i)/2 FROM test1 GROUP BY i;
SELECT SUM(i) as aa, avg(i) FROM test1 GROUP BY i ORDER BY aa;
SELECT sum(i), avg(i) FROM test1 GROUP BY i ORDER BY 1;
SELECT i, avg(i) FROM test1 GROUP BY i ORDER BY 1;

-- allocate statement
PREPARE stmt AS SELECT sum(i),count(i),i FROM test1 group by i order by i;
-- execute first time
EXECUTE stmt;
-- performance test prepared statement
DO $$
BEGIN
   FOR counter IN 1..50 LOOP
   EXECUTE 'EXECUTE stmt;';
   END LOOP;
END; $$;
-- deallocate statement
DEALLOCATE stmt;

CREATE FOREIGN TABLE t1 (i int, t text,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE t1__post_svr__0 (i int, t text) SERVER post_svr OPTIONS(table_name 't1');
SELECT * FROM t1;
SELECT * FROM t1 WHERE __spd_url='/post_svr/' and i = 1 and t = 'a';
SELECT sum(i),t FROM t1 group by t;
SELECT sum(i),t,count(i) FROM t1 group by t;

SELECT * FROM t1 WHERE i = 1;
SELECT sum(i),t FROM t1 group by t;
SELECT avg(i) FROM t1;
SELECT stddev(i) FROM t1;
SELECT sum(i),t FROM t1 WHERE i = 1 group by t;
SELECT avg(i),sum(i) FROM t1;
SELECT sum(i),sum(i) FROM t1;
SELECT avg(i),t FROM t1 group by t;
SELECT avg(i) FROM t1 group by i;

SELECT avg(i), count(i) FROM t1 GROUP BY i ORDER BY i;
SELECT t, avg(i), t FROM t1 GROUP BY i, t ORDER BY i;

SELECT t, __spd_url FROM t1 GROUP BY __spd_url, t ORDER BY t;
SELECT i, __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, i FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, avg(i) FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, sum(i) FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
SELECT __spd_url, avg(i), sum(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;

SELECT * FROM (SELECT sum(i) FROM t1) A,(SELECT count(i) FROM t1) B;

SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY i;
SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY t;
SELECT SUM(i) as aa, avg(i), i/2, SUM(i)/2 FROM t1 GROUP BY i, t;
SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY i ORDER BY aa;

-- allocate statement
PREPARE stmt AS SELECT * FROM t1;
-- execute first time
EXECUTE stmt;
-- performance test prepared statement
DO $$
BEGIN
   FOR counter IN 1..50 LOOP
   EXECUTE 'EXECUTE stmt;';
   END LOOP;
END; $$;
-- deallocate statement
DEALLOCATE stmt;

EXPLAIN (VERBOSE, COSTS OFF) SELECT STDDEV(i) FROM t1;

CREATE FOREIGN TABLE t3 (t text, t2 text, i int,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE t3__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');

SELECT count(t) FROM t3;
SELECT count(t2) FROM t3;
SELECT count(i) FROM t3;

SELECT * FROM t3;
-- test target list push down for mysql fdw
-- push down abs(-i*2) and i+1
EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(-i*2), i+1, i, i FROM t3;
SELECT abs(-i*2), i+1, i, i FROM t3;

-- can't push down abs(A.i) in join case
EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(A.i) FROM t3 A, t3 B LIMIT 3;
SELECT abs(A.i) FROM t3 A, t3 B LIMIT 3;

EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(i) c1 FROM t3 UNION SELECT abs(i+1) FROM t3 ORDER BY c1;
SELECT abs(i) c1 FROM t3 UNION SELECT abs(i+1) FROM t3 ORDER BY c1;

SELECT i+1, __spd_url FROM t3;
SELECT i, __spd_url FROM t3 ORDER BY i, __spd_url;
SELECT i FROM t3 ORDER BY __spd_url;

-- can't push down i+1 because test1 includes fdws other than mysql fdw
EXPLAIN (VERBOSE, COSTS OFF) 
SELECT i+1,__spd_url FROM test1 ORDER BY __spd_url, i;
SELECT i+1,__spd_url FROM test1  ORDER BY __spd_url, i;
SELECT __spd_url,i FROM test1 ORDER BY __spd_url, i;

-- t is not included in target list, but is pushed down, it is OK
select t from t3 where i  = 1;

-- t is not included and cannot be pushed down, so it is error
-- select i from t3 where t COLLATE "ja_JP.utf8" = 'aa';

-- error stack test
Set pgspider_core_fdw.throw_error_ifdead to false;
CREATE SERVER mysql_svr2 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
CREATE USER mapping for public server mysql_svr2 OPTIONS(username 'root',password 'wrongpass');
CREATE FOREIGN TABLE t3__mysql_svr2__0 (t text,t2 text,i int) SERVER mysql_svr2 OPTIONS(dbname 'test',table_name 'test3');
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;
SELECT count(t) FROM t3;

Set pgspider_core_fdw.throw_error_ifdead to true;

DROP FOREIGN TABLE t3;
DROP FOREIGN TABLE t3__mysql_svr__0;
DROP FOREIGN TABLE t3__mysql_svr2__0;
-- wrong result:
-- SELECT sum(i),t  FROM t1 group by t having sum(i) > 2;
--  sum | t 
-- -----+---
--    1 | a
--    5 | b
--    4 | c
-- (3 rows)

-- stress test for finding multithread error
DO $$
BEGIN
   FOR counter IN 1..50 LOOP
   PERFORM sum(i) FROM test1;
   END LOOP;
END; $$;

CREATE FOREIGN TABLE mysqlt (t text, t2 text, i int,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE mysqlt__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');
CREATE FOREIGN TABLE mysqlt__mysql_svr__1 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');
CREATE FOREIGN TABLE mysqlt__mysql_svqr__2 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');

DO $$
BEGIN
   FOR counter IN 1..50 LOOP
   PERFORM sum(i) FROM mysqlt;
   END LOOP;
END; $$;

CREATE FOREIGN TABLE post_large (i int, t text,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE post_large__post_svr__1 (i int, t text) SERVER post_svr OPTIONS(table_name 'large_t');
CREATE FOREIGN TABLE post_large__post_svr__2 (i int, t text) SERVER post_svr OPTIONS(table_name 'large_t');
CREATE FOREIGN TABLE post_large__post_svr__3 (i int, t text) SERVER post_svr OPTIONS(table_name 'large_t');

SELECT i,t FROM post_large WHERE i < 3 ORDER BY i,t;
DO $$
BEGIN
   FOR counter IN 1..10 LOOP
   PERFORM i,t FROM post_large WHERE i < 3 ORDER BY i,t;
   END LOOP;
END; $$;

SELECT count(*) FROM post_large;

DO $$
BEGIN
   FOR counter IN 1..10 LOOP
   PERFORM sum(i) FROM post_large;
   END LOOP;
END; $$;

CREATE FOREIGN TABLE t2 (i int, t text, a text,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE t2__post_svr__0 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
SELECT i,t,a FROM t2 ORDER BY i,__spd_url;
CREATE FOREIGN TABLE t2__post_svr__1 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
CREATE FOREIGN TABLE t2__post_svr__2 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
CREATE FOREIGN TABLE t2__post_svr__3 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');

-- random cannot be pushed down and i=2 is pushed down
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM t2 WHERE i=2 AND random() < 2.0;
SELECT * FROM t2 WHERE i=2 AND random() < 2.0;

SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SELECT a,i, __spd_url, t FROM t2 ORDER BY i,t,a,__spd_url;

SELECT __spd_url,i FROM t2 WHERE __spd_url='/post_svr/' ORDER BY i LIMIT 1;

-- Keep alive test
CREATE SERVER post_svr2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '49503');
CREATE USER mapping for public server post_svr2 OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE t2__post_svr2__0 (i int, t text,a text) SERVER post_svr2 OPTIONS(table_name 't2');
INSERT INTO pg_spd_node_info VALUES(0,'post_svr','postgres_fdw','127.0.0.1');
INSERT INTO pg_spd_node_info VALUES(0,'post_svr2','postgres_fdw','127.0.0.1');
SELECT pg_sleep(2);
Set pgspider_core_fdw.throw_error_ifdead to false;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.throw_error_ifdead to true;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.throw_error_ifdead to false;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.print_error_nodes to true;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.print_error_nodes to false;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
CREATE SERVER post_svr3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '192.168.11.12',port '15432');
CREATE USER mapping for public server post_svr3 OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE t2__post_svr3__0 (i int, t text,a text) SERVER post_svr3 OPTIONS(table_name 't2');
INSERT INTO pg_spd_node_info VALUES(0,'post_svr3','postgres_fdw','192.168.11.12');
SELECT pg_sleep(2);

/*
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.throw_error_ifdead to true;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.throw_error_ifdead to false;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.print_error_nodes to true;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.print_error_nodes to false;
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
DROP FOREIGN TABLE t2__post_svr3__0;
DELETE FROM pg_spd_node_info WHERE servername = 't2__post_svr3__0';
SELECT pg_sleep(2);
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
*/
DROP FOREIGN TABLE test1;
DROP FOREIGN TABLE t1;
DROP FOREIGN TABLE t2;
DROP SERVER pgspider_svr CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;
