--Testcase 1:
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
--Testcase 2:
SELECT * FROM filetbl;

CREATE SERVER filesvr2 FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE test1__file_svr__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
--Testcase 3:
SELECT * FROM test1;
CREATE FOREIGN TABLE test1__filesvr2__0 (i int) SERVER file_svr options(filename '/tmp/pgtest.csv');
--Testcase 4:
SELECT * FROM test1 order by i,__spd_url;
--Testcase 5:
SELECT * FROM test1 IN ('/file_svr/') ORDER BY i,__spd_url;
--Testcase 6:
SELECT * FROM test1 IN ('/file_svr/') where i = 1;

CREATE SERVER tiny_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host '127.0.0.1',port '5100', dbname 'test.db');
CREATE USER mapping for public server tiny_svr OPTIONS(username 'user',password 'testuser');
CREATE FOREIGN TABLE test1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS(table_name 'test1');
--Testcase 7:
SELECT * FROM test1__tiny_svr__0 ORDER BY i;
--Testcase 8:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 9:
SELECT * FROM test1 IN ('/tiny_svr/');
--Testcase 10:
SELECT * FROM test1 IN ('/tiny_svr/') where i = 1;
CREATE SERVER post_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
CREATE USER mapping for public server post_svr OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE test1__post_svr__0 (i int) SERVER post_svr OPTIONS(table_name 'test1');
--Testcase 11:
SELECT * FROM test1__post_svr__0 ORDER BY i;
--Testcase 12:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 13:
SELECT * FROM test1 IN ('/post_svr/') ORDER BY i,__spd_url;
--Testcase 14:
SELECT * FROM test1 IN ('/post_svr/') where i = 1 ORDER BY i,__spd_url;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/pgtest.db');
CREATE FOREIGN TABLE test1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS(table 'test1');
--Testcase 15:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 16:
SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
--Testcase 17:
SELECT * FROM test1 IN ('/sqlite_svr/') where i = 4 ORDER BY i,__spd_url;
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
CREATE USER mapping for public server mysql_svr OPTIONS(username 'root',password 'Mysql_1234');
CREATE FOREIGN TABLE test1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test1');
--Testcase 18:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 19:
SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
--Testcase 20:
SELECT * FROM test1 where i = 1 ORDER BY i,__spd_url;
--Testcase 21:
SELECT * FROM test1 IN ('/mysql_svr/') where i = 5 ORDER BY i,__spd_url;
--Testcase 22:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 23:
SELECT * FROM test1 IN ('/test2/') ORDER BY i,__spd_url;
--Testcase 24:
SELECT * FROM test1 order by i,__spd_url;
--Testcase 25:
SELECT * FROM test1 IN ('/file_svr/') ORDER BY i,__spd_url;
--Testcase 26:
SELECT * FROM test1 IN ('/file_svr/') where i = 1 ORDER BY i,__spd_url;
--Testcase 27:
SELECT * FROM test1__tiny_svr__0 order by i;
--Testcase 28:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 29:
SELECT * FROM test1 IN ('/tiny_svr/');
--Testcase 30:
SELECT * FROM test1 IN ('/tiny_svr/') where i = 1;
--Testcase 31:
SELECT * FROM test1__post_svr__0 order by i;
--Testcase 32:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 33:
SELECT * FROM test1 IN ('/post_svr/') ORDER BY i,__spd_url;
--Testcase 34:
SELECT * FROM test1 IN ('/post_svr/') where i = 1 ORDER BY i,__spd_url;
--Testcase 35:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 36:
SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
--Testcase 37:
SELECT * FROM test1 IN ('/sqlite_svr/') where i = 4 ORDER BY i,__spd_url;
--Testcase 38:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 39:
SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
--Testcase 40:
SELECT * FROM test1 where i = 1 ORDER BY i,__spd_url;
--Testcase 41:
SELECT * FROM test1 IN ('/mysql_svr/') where i = 5 ORDER BY i,__spd_url;
--Testcase 42:
SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') ORDER BY  i,__spd_url;

--Testcase 43:
SELECT * FROM test1 UNION ALL SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 44:
SELECT * FROM test1 IN ('/mysql_svr/') UNION ALL SELECT * FROM test1 IN ('/mysql_svr/') ORDER BY i,__spd_url;
--Testcase 45:
SELECT * FROM test1 IN ('/mysql_svr/') UNION ALL SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
--Testcase 46:
SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') UNION ALL SELECT * FROM test1 IN ('/mysql_svr/', '/sqlite_svr/') ORDER BY i,__spd_url;

CREATE FOREIGN TABLE test1_1 (i int,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE test1_1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS(table_name 'test1');
CREATE FOREIGN TABLE test1_1__post_svr__0 (i int) SERVER post_svr OPTIONS(table_name 'test1');
CREATE FOREIGN TABLE test1_1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS(table 'test1');
CREATE FOREIGN TABLE test1_1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test1');

--Testcase 47:
SELECT * FROM test1 IN ('/mysql_svr/'), test1_1 IN ('/sqlite_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
--Testcase 48:
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svr/'), test1_1 IN ('/mysql_svr/','/sqlite_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
-- nothing case
--Testcase 49:
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svrrrrrr/');
--Testcase 50:
SELECT * FROM test1 IN ('/mysql_svr/'), test1_1 IN ('/mysql_svr2/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
--Testcase 51:
SELECT * FROM test1 IN ('/mysql_svr2/'), test1_1 IN ('/mysql_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
--Testcase 52:
SELECT * FROM test1 IN ('/mysql_svr2/'), test1_1 IN ('/mysql_svr2/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;
--Testcase 53:
SELECT * FROM test1 IN ('/sqlite_svr/','/mysql_svr2/'), test1_1 IN ('/sqlite_svr2/','/mysql_svr/') ORDER BY test1.i,test1.__spd_url,test1_1.i,test1_1.__spd_url;

--Testcase 54:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM test1;
-- some fdw push down and some fdw not 
--Testcase 55:
EXPLAIN (VERBOSE, COSTS OFF) SELECT sum(i), avg(i) FROM test1;
-- only post_svr is alive
--Testcase 56:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM test1 IN ('/post_svr/');

-- only __spd_url target list is OK
--Testcase 57:
SELECT __spd_url FROM test1 ORDER BY __spd_url;

--Testcase 58:
SELECT i, __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;
--Testcase 59:
SELECT __spd_url, i FROM test1 GROUP BY i, __spd_url ORDER BY i;
--Testcase 60:
SELECT avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;
--Testcase 61:
SELECT __spd_url, avg(i) FROM test1 GROUP BY i, __spd_url ORDER BY i;
--Testcase 62:
SELECT __spd_url, sum(i) FROM test1 GROUP BY i, __spd_url ORDER BY i;
--Testcase 63:
SELECT __spd_url, avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i;

--Testcase 64:
SELECT sum(i) FROM test1;

--Testcase 65:
SELECT avg(i) FROM test1;
--Testcase 66:
SELECT avg(i),i FROM test1 group by i order by i;
--Testcase 67:
SELECT sum(i),count(i),i FROM test1 group by i order by i;

--Testcase 68:
SELECT avg(i), count(i) FROM test1 group by i;

--Testcase 69:
SELECT SUM(i) as aa, avg(i) FROM test1 GROUP BY i;
--Testcase 70:
SELECT SUM(i) as aa, avg(i), i/2, SUM(i)/2 FROM test1 GROUP BY i;
--Testcase 71:
SELECT SUM(i) as aa, avg(i) FROM test1 GROUP BY i ORDER BY aa;
--Testcase 72:
SELECT sum(i), avg(i) FROM test1 GROUP BY i ORDER BY 1;
--Testcase 73:
SELECT i, avg(i) FROM test1 GROUP BY i ORDER BY 1;

-- allocate statement
--Testcase 74:
PREPARE stmt AS SELECT sum(i),count(i),i FROM test1 group by i order by i;
-- execute first time
--Testcase 75:
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
--Testcase 76:
SELECT * FROM t1;
--Testcase 77:
SELECT * FROM t1 WHERE __spd_url='/post_svr/' and i = 1 and t = 'a';
--Testcase 78:
SELECT sum(i),t FROM t1 group by t;
--Testcase 79:
SELECT sum(i),t,count(i) FROM t1 group by t;

--Testcase 80:
SELECT * FROM t1 WHERE i = 1;
--Testcase 81:
SELECT sum(i),t FROM t1 group by t;
--Testcase 82:
SELECT avg(i) FROM t1;
--Testcase 83:
SELECT stddev(i) FROM t1;
--Testcase 84:
SELECT sum(i),t FROM t1 WHERE i = 1 group by t;
--Testcase 85:
SELECT avg(i),sum(i) FROM t1;
--Testcase 86:
SELECT sum(i),sum(i) FROM t1;
--Testcase 87:
SELECT avg(i),t FROM t1 group by t;
--Testcase 88:
SELECT avg(i) FROM t1 group by i;

--Testcase 89:
SELECT avg(i), count(i) FROM t1 GROUP BY i ORDER BY i;
--Testcase 90:
SELECT t, avg(i), t FROM t1 GROUP BY i, t ORDER BY i;

--Testcase 91:
SELECT t, __spd_url FROM t1 GROUP BY __spd_url, t ORDER BY t;
--Testcase 92:
SELECT i, __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 93:
SELECT __spd_url, i FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 94:
SELECT avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 95:
SELECT __spd_url, avg(i) FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 96:
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 97:
SELECT __spd_url, sum(i) FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 98:
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;
--Testcase 99:
SELECT __spd_url, avg(i), sum(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i;

--Testcase 100:
SELECT * FROM (SELECT sum(i) FROM t1) A,(SELECT count(i) FROM t1) B;

--Testcase 101:
SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY i;
--Testcase 102:
SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY t;
--Testcase 103:
SELECT SUM(i) as aa, avg(i), i/2, SUM(i)/2 FROM t1 GROUP BY i, t;
--Testcase 104:
SELECT SUM(i) as aa, avg(i) FROM t1 GROUP BY i ORDER BY aa;

-- query contains all constant
SELECT 1, 2, 'asd$@' FROM t1 group by 1, 3, 2;

-- allocate statement
--Testcase 105:
PREPARE stmt AS SELECT * FROM t1;
-- execute first time
--Testcase 106:
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

--Testcase 107:
EXPLAIN (VERBOSE, COSTS OFF) SELECT STDDEV(i) FROM t1;

CREATE FOREIGN TABLE t3 (t text, t2 text, i int,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE t3__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS(dbname 'test',table_name 'test3');

--Testcase 108:
SELECT count(t) FROM t3;
--Testcase 109:
SELECT count(t2) FROM t3;
--Testcase 110:
SELECT count(i) FROM t3;

--Testcase 111:
SELECT * FROM t3;
-- test target list push down for mysql fdw
-- push down abs(-i*2) and i+1
--Testcase 112:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(-i*2), i+1, i, i FROM t3;
--Testcase 113:
SELECT abs(-i*2), i+1, i, i FROM t3;

-- can't push down abs(A.i) in join case
--Testcase 114:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(A.i) FROM t3 A, t3 B LIMIT 3;
--Testcase 115:
SELECT abs(A.i) FROM t3 A, t3 B LIMIT 3;

--Testcase 116:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT abs(i) c1 FROM t3 UNION SELECT abs(i+1) FROM t3 ORDER BY c1;
--Testcase 117:
SELECT abs(i) c1 FROM t3 UNION SELECT abs(i+1) FROM t3 ORDER BY c1;

--Testcase 118:
SELECT i+1, __spd_url FROM t3;
--Testcase 119:
SELECT i, __spd_url FROM t3 ORDER BY i, __spd_url;
--Testcase 120:
SELECT i FROM t3 ORDER BY __spd_url;

-- can't push down i+1 because test1 includes fdws other than mysql fdw
--Testcase 121:
EXPLAIN (VERBOSE, COSTS OFF) 
SELECT i+1,__spd_url FROM test1 ORDER BY __spd_url, i;
--Testcase 122:
SELECT i+1,__spd_url FROM test1  ORDER BY __spd_url, i;
--Testcase 123:
SELECT __spd_url,i FROM test1 ORDER BY __spd_url, i;

-- t is not included in target list, but is pushed down, it is OK
--Testcase 124:
select t from t3 where i  = 1;

-- t is not included and cannot be pushed down, so it is error
-- select i from t3 where t COLLATE "ja_JP.utf8" = 'aa';

-- error stack test
Set pgspider_core_fdw.throw_error_ifdead to false;
CREATE SERVER mysql_svr2 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
CREATE USER mapping for public server mysql_svr2 OPTIONS(username 'root',password 'wrongpass');
CREATE FOREIGN TABLE t3__mysql_svr2__0 (t text,t2 text,i int) SERVER mysql_svr2 OPTIONS(dbname 'test',table_name 'test3');
--Testcase 125:
SELECT count(t) FROM t3;
--Testcase 126:
SELECT count(t) FROM t3;
--Testcase 127:
SELECT count(t) FROM t3;
--Testcase 128:
SELECT count(t) FROM t3;
--Testcase 129:
SELECT count(t) FROM t3;
--Testcase 130:
SELECT count(t) FROM t3;
--Testcase 131:
SELECT count(t) FROM t3;
--Testcase 132:
SELECT count(t) FROM t3;
--Testcase 133:
SELECT count(t) FROM t3;
--Testcase 134:
SELECT count(t) FROM t3;
--Testcase 135:
SELECT count(t) FROM t3;
--Testcase 136:
SELECT count(t) FROM t3;
--Testcase 137:
SELECT count(t) FROM t3;
--Testcase 138:
SELECT count(t) FROM t3;
--Testcase 139:
SELECT count(t) FROM t3;
--Testcase 140:
SELECT count(t) FROM t3;
--Testcase 141:
SELECT count(t) FROM t3;
--Testcase 142:
SELECT count(t) FROM t3;
--Testcase 143:
SELECT count(t) FROM t3;
--Testcase 144:
SELECT count(t) FROM t3;
--Testcase 145:
SELECT count(t) FROM t3;
--Testcase 146:
SELECT count(t) FROM t3;
--Testcase 147:
SELECT count(t) FROM t3;
--Testcase 148:
SELECT count(t) FROM t3;
--Testcase 149:
SELECT count(t) FROM t3;
--Testcase 150:
SELECT count(t) FROM t3;
--Testcase 151:
SELECT count(t) FROM t3;
--Testcase 152:
SELECT count(t) FROM t3;
--Testcase 153:
SELECT count(t) FROM t3;
--Testcase 154:
SELECT count(t) FROM t3;
--Testcase 155:
SELECT count(t) FROM t3;
--Testcase 156:
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

--Testcase 157:
SELECT i,t FROM post_large WHERE i < 3 ORDER BY i,t;
DO $$
BEGIN
   FOR counter IN 1..10 LOOP
   PERFORM i,t FROM post_large WHERE i < 3 ORDER BY i,t;
   END LOOP;
END; $$;

--Testcase 158:
SELECT count(*) FROM post_large;

DO $$
BEGIN
   FOR counter IN 1..10 LOOP
   PERFORM sum(i) FROM post_large;
   END LOOP;
END; $$;

CREATE FOREIGN TABLE t2 (i int, t text, a text,__spd_url text) SERVER pgspider_svr;
CREATE FOREIGN TABLE t2__post_svr__0 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
--Testcase 159:
SELECT i,t,a FROM t2 ORDER BY i,__spd_url;
CREATE FOREIGN TABLE t2__post_svr__1 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
CREATE FOREIGN TABLE t2__post_svr__2 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');
CREATE FOREIGN TABLE t2__post_svr__3 (i int, t text,a text) SERVER post_svr OPTIONS(table_name 't2');

-- random cannot be pushed down and i=2 is pushed down
--Testcase 160:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM t2 WHERE i=2 AND random() < 2.0;
--Testcase 161:
SELECT * FROM t2 WHERE i=2 AND random() < 2.0;

--Testcase 162:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 163:
SELECT a,i, __spd_url, t FROM t2 ORDER BY i,t,a,__spd_url;

--Testcase 164:
SELECT __spd_url,i FROM t2 WHERE __spd_url='/post_svr/' ORDER BY i LIMIT 1;

-- Keep alive test
CREATE SERVER post_svr2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '49503');
CREATE USER mapping for public server post_svr2 OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE t2__post_svr2__0 (i int, t text,a text) SERVER post_svr2 OPTIONS(table_name 't2');
--Testcase 165:
INSERT INTO pg_spd_node_info VALUES(0,'post_svr','postgres_fdw','127.0.0.1');
--Testcase 166:
INSERT INTO pg_spd_node_info VALUES(0,'post_svr2','postgres_fdw','127.0.0.1');
--Testcase 167:
SELECT pg_sleep(2);
Set pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 168:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 169:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 170:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.print_error_nodes to true;
--Testcase 171:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
SET pgspider_core_fdw.print_error_nodes to false;
--Testcase 172:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;;
CREATE SERVER post_svr3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '192.168.11.12',port '15432');
CREATE USER mapping for public server post_svr3 OPTIONS(user 'postgres',password 'postgres');
CREATE FOREIGN TABLE t2__post_svr3__0 (i int, t text,a text) SERVER post_svr3 OPTIONS(table_name 't2');
--Testcase 173:
INSERT INTO pg_spd_node_info VALUES(0,'post_svr3','postgres_fdw','192.168.11.12');
--Testcase 174:
SELECT pg_sleep(2);

/*
--Testcase 175:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 176:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 177:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.print_error_nodes to true;
--Testcase 178:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
SET pgspider_core_fdw.print_error_nodes to false;
--Testcase 179:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
DROP FOREIGN TABLE t2__post_svr3__0;
--Testcase 180:
DELETE FROM pg_spd_node_info WHERE servername = 't2__post_svr3__0';
--Testcase 181:
SELECT pg_sleep(2);
--Testcase 182:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
*/
DROP FOREIGN TABLE test1;
DROP FOREIGN TABLE t1;
DROP FOREIGN TABLE t2;
DROP SERVER pgspider_svr CASCADE;
DROP EXTENSION pgspider_core_fdw CASCADE;
