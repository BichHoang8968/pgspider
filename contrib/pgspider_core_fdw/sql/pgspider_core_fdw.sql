--Testcase 1:
DELETE FROM pg_spd_node_info;
--SELECT pg_sleep(15);
--Testcase 183:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 184:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1',port '50849');
--Testcase 185:
CREATE USER mapping for public server pgspider_svr OPTIONS (user 'postgres',password 'postgres');
--Testcase 186:
CREATE FOREIGN TABLE test1 (i int,__spd_url text) SERVER pgspider_svr;
--Testcase 187:
CREATE EXTENSION postgres_fdw;
--Testcase 188:
CREATE EXTENSION file_fdw;
--Testcase 189:
CREATE EXTENSION sqlite_fdw;
--Testcase 190:
CREATE EXTENSION tinybrace_fdw;
--Testcase 191:
CREATE EXTENSION mysql_fdw;
--Testcase 812:
CREATE EXTENSION oracle_fdw;

--Testcase 192:
CREATE SERVER file_svr FOREIGN DATA WRAPPER file_fdw;
--Testcase 193:
CREATE FOREIGN TABLE filetbl__file_svr__0 (i int) SERVER file_svr OPTIONS (filename '/tmp/pgtest.csv');
--Testcase 194:
CREATE FOREIGN TABLE filetbl (i int,__spd_url text) SERVER pgspider_svr;
--Testcase 2:
SELECT * FROM filetbl;

--get version
--Testcase 295:
\df pgspider_core*
--Testcase 296:
SELECT * FROM public.pgspider_core_fdw_version();
--Testcase 297:
SELECT pgspider_core_fdw_version();

--Testcase 196:
CREATE FOREIGN TABLE test1__file_svr__0 (i int) SERVER file_svr OPTIONS (filename '/tmp/pgtest.csv');
--Testcase 3:
SELECT * FROM test1;
--Testcase 197:
CREATE FOREIGN TABLE test1__file_svr__1 (i int) SERVER file_svr OPTIONS (filename '/tmp/pgtest.csv');
--Testcase 4:
SELECT * FROM test1 order by i,__spd_url;
--Testcase 5:
SELECT * FROM test1 IN ('/file_svr/') ORDER BY i,__spd_url;
--Testcase 6:
SELECT * FROM test1 IN ('/file_svr/') where i = 1;

--Testcase 198:
CREATE SERVER tiny_svr FOREIGN DATA WRAPPER tinybrace_fdw OPTIONS (host '127.0.0.1',port '5100', dbname 'test.db');
--Testcase 199:
CREATE USER mapping for public server tiny_svr OPTIONS (username 'user',password 'testuser');
--Testcase 200:
CREATE FOREIGN TABLE test1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS (table_name 'test1');
--Testcase 7:
SELECT * FROM test1__tiny_svr__0 ORDER BY i;
--Testcase 8:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 9:
SELECT * FROM test1 IN ('/tiny_svr/');
--Testcase 10:
SELECT * FROM test1 IN ('/tiny_svr/') where i = 1;
--Testcase 201:
CREATE SERVER post_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
--Testcase 202:
CREATE USER mapping for public server post_svr OPTIONS (user 'postgres',password 'postgres');
--Testcase 203:
CREATE FOREIGN TABLE test1__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test1');
--Testcase 11:
SELECT * FROM test1__post_svr__0 ORDER BY i;
--Testcase 12:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 13:
SELECT * FROM test1 IN ('/post_svr/') ORDER BY i,__spd_url;
--Testcase 14:
SELECT * FROM test1 IN ('/post_svr/') where i = 1 ORDER BY i,__spd_url;
--Testcase 204:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/pgtest.db');
--Testcase 205:
CREATE FOREIGN TABLE test1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS (table 'test1');
--Testcase 15:
SELECT * FROM test1 ORDER BY i,__spd_url;
--Testcase 16:
SELECT * FROM test1 IN ('/sqlite_svr/') ORDER BY i,__spd_url;
--Testcase 17:
SELECT * FROM test1 IN ('/sqlite_svr/') where i = 4 ORDER BY i,__spd_url;
--Testcase 206:
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
--Testcase 207:
CREATE USER mapping for public server mysql_svr OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 208:
CREATE FOREIGN TABLE test1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test1');
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

--Testcase 209:
CREATE FOREIGN TABLE test1_1 (i int,__spd_url text) SERVER pgspider_svr;
--Testcase 210:
CREATE FOREIGN TABLE test1_1__tiny_svr__0 (i int) SERVER tiny_svr OPTIONS (table_name 'test1');
--Testcase 211:
CREATE FOREIGN TABLE test1_1__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test1');
--Testcase 212:
CREATE FOREIGN TABLE test1_1__sqlite_svr__0 (i int) SERVER sqlite_svr OPTIONS (table 'test1');
--Testcase 213:
CREATE FOREIGN TABLE test1_1__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test1');

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

--Testcase 214:
EXPLAIN VERBOSE
SELECT i, __spd_url FROM test1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 215:
SELECT i, __spd_url FROM test1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 216:
EXPLAIN VERBOSE
SELECT i, __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 58:
SELECT i, __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Testcase 217:
EXPLAIN VERBOSE
SELECT __spd_url, i FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 59:
SELECT __spd_url, i FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Testcase 218:
EXPLAIN VERBOSE
SELECT avg(i), __spd_url FROM test1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 219:
SELECT avg(i), __spd_url FROM test1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 220:
EXPLAIN VERBOSE
SELECT avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 60:
SELECT avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Testcase 221:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i) FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 61:
SELECT __spd_url, avg(i) FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Testcase 222:
EXPLAIN VERBOSE
SELECT __spd_url, sum(i) FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 62:
SELECT __spd_url, sum(i) FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Testcase 223:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;
--Testcase 63:
SELECT __spd_url, avg(i), __spd_url FROM test1 GROUP BY i, __spd_url ORDER BY i,__spd_url;

--Aggregate and function with __spd_url
--Testcase 276:
EXPLAIN VERBOSE
SELECT max(__spd_url), min(__spd_url) from test1;
--Testcase 277:
SELECT max(__spd_url), min(__spd_url) from test1;
--Testcase 278:
EXPLAIN VERBOSE
SELECT lower(__spd_url), upper(__spd_url) from test1 ORDER BY 1, 2;
--Testcase 279:
SELECT lower(__spd_url), upper(__spd_url) from test1  ORDER BY 1, 2;
--Testcase 280:
EXPLAIN VERBOSE
SELECT pg_typeof(max(i)), pg_typeof(count(*)), pg_typeof(max(__spd_url)) FROM test1;
--Testcase 281:
SELECT pg_typeof(max(i)), pg_typeof(count(*)), pg_typeof(max(__spd_url)) FROM test1;

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

--Test extract expression when target contains Var which exists in GROUP BY
--Testcase 270:
EXPLAIN VERBOSE
SELECT i/2, i/4 FROM test1 GROUP BY i ORDER BY 1;
--Testcase 271:
SELECT i/2, i/4 FROM test1 GROUP BY i ORDER BY 1;
--Testcase 272:
EXPLAIN VERBOSE
SELECT i/4, avg(i) FROM test1 GROUP BY i ORDER BY 1;
--Testcase 273:
SELECT i/4, avg(i) FROM test1 GROUP BY i ORDER BY 1;
--Testcase 274:
EXPLAIN VERBOSE
SELECT i, i*i FROM test1 GROUP BY i ORDER BY 1;
--Testcase 275:
SELECT i, i*i FROM test1 GROUP BY i ORDER BY 1;

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
--Testcase 224:
   EXECUTE 'EXECUTE stmt;';
   END LOOP;
END; $$;
-- deallocate statement
DEALLOCATE stmt;

--Testcase 225:
CREATE FOREIGN TABLE t1 (i int, t text,__spd_url text) SERVER pgspider_svr;
--Testcase 226:
CREATE FOREIGN TABLE t1__post_svr__0 (i int, t text) SERVER post_svr OPTIONS (table_name 't1');
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

--Testcase 227:
EXPLAIN VERBOSE
SELECT t, __spd_url FROM t1 GROUP BY __spd_url, t ORDER BY t,__spd_url;
--Testcase 91:
SELECT t, __spd_url FROM t1 GROUP BY __spd_url, t ORDER BY t,__spd_url;

--Testcase 228:
EXPLAIN VERBOSE
SELECT i, __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 92:
SELECT i, __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 229:
EXPLAIN VERBOSE
SELECT __spd_url, i FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 93:
SELECT __spd_url, i FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 230:
EXPLAIN VERBOSE
SELECT avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 94:
SELECT avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 231:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i) FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 95:
SELECT __spd_url, avg(i) FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 232:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 96:
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 233:
EXPLAIN VERBOSE
SELECT __spd_url, sum(i) FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 97:
SELECT __spd_url, sum(i) FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 234:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 98:
SELECT __spd_url, avg(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

--Testcase 235:
EXPLAIN VERBOSE
SELECT __spd_url, avg(i), sum(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;
--Testcase 99:
SELECT __spd_url, avg(i), sum(i), __spd_url FROM t1 GROUP BY __spd_url, i ORDER BY i,__spd_url;

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
--Testcase 236:
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
--Testcase 237:
   EXECUTE 'EXECUTE stmt;';
   END LOOP;
END; $$;
-- deallocate statement
DEALLOCATE stmt;

--Testcase 107:
EXPLAIN (VERBOSE, COSTS OFF) SELECT STDDEV(i) FROM t1;

--Testcase 238:
CREATE FOREIGN TABLE t3 (t text, t2 text, i int,__spd_url text) SERVER pgspider_svr;
--Testcase 239:
CREATE FOREIGN TABLE t3__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test3');

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
--Testcase 418:
Set pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 240:
CREATE SERVER mysql_svr2 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
--Testcase 241:
CREATE USER mapping for public server mysql_svr2 OPTIONS (username 'root',password 'wrongpass');
--Testcase 242:
CREATE FOREIGN TABLE t3__mysql_svr2__0 (t text,t2 text,i int) SERVER mysql_svr2 OPTIONS (dbname 'test',table_name 'test3');
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

-- Expect two warning messages of one mysql child node because of JOIN query.
-- The other mysql child returns result.
--Testcase 298:
SELECT * FROM t3 x1 JOIN t3 x2 ON x1.t = x2.t;

--Testcase 419:
Set pgspider_core_fdw.throw_error_ifdead to true;

--Testcase 243:
DROP FOREIGN TABLE t3;
--Testcase 244:
DROP FOREIGN TABLE t3__mysql_svr__0;
--Testcase 245:
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

--Testcase 246:
CREATE FOREIGN TABLE mysqlt (t text, t2 text, i int,__spd_url text) SERVER pgspider_svr;
--Testcase 247:
CREATE FOREIGN TABLE mysqlt__mysql_svr__0 (t text,t2 text,i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test3');
--Testcase 248:
CREATE FOREIGN TABLE mysqlt__mysql_svr__1 (t text,t2 text,i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test3');
--Testcase 249:
CREATE FOREIGN TABLE mysqlt__mysql_svqr__2 (t text,t2 text,i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test3');

DO $$
BEGIN
   FOR counter IN 1..50 LOOP
   PERFORM sum(i) FROM mysqlt;
   END LOOP;
END; $$;

--Testcase 250:
CREATE FOREIGN TABLE post_large (i int, t text,__spd_url text) SERVER pgspider_svr;
--Testcase 251:
CREATE FOREIGN TABLE post_large__post_svr__1 (i int, t text) SERVER post_svr OPTIONS (table_name 'large_t');
--Testcase 252:
CREATE FOREIGN TABLE post_large__post_svr__2 (i int, t text) SERVER post_svr OPTIONS (table_name 'large_t');
--Testcase 253:
CREATE FOREIGN TABLE post_large__post_svr__3 (i int, t text) SERVER post_svr OPTIONS (table_name 'large_t');

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

--Testcase 254:
CREATE FOREIGN TABLE t2 (i int, t text, a text,__spd_url text) SERVER pgspider_svr;
--Testcase 255:
CREATE FOREIGN TABLE t2__post_svr__0 (i int, t text,a text) SERVER post_svr OPTIONS (table_name 't2');
--Testcase 159:
SELECT i,t,a FROM t2 ORDER BY i,__spd_url;
--Testcase 256:
CREATE FOREIGN TABLE t2__post_svr__1 (i int, t text,a text) SERVER post_svr OPTIONS (table_name 't2');
--Testcase 257:
CREATE FOREIGN TABLE t2__post_svr__2 (i int, t text,a text) SERVER post_svr OPTIONS (table_name 't2');
--Testcase 258:
CREATE FOREIGN TABLE t2__post_svr__3 (i int, t text,a text) SERVER post_svr OPTIONS (table_name 't2');

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
--Testcase 259:
CREATE SERVER post_svr2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '49503');
--Testcase 260:
CREATE USER mapping for public server post_svr2 OPTIONS (user 'postgres',password 'postgres');
--Testcase 261:
CREATE FOREIGN TABLE t2__post_svr2__0 (i int, t text,a text) SERVER post_svr2 OPTIONS (table_name 't2');
--Testcase 165:
INSERT INTO pg_spd_node_info VALUES(0,'post_svr','postgres_fdw','127.0.0.1');
--Testcase 166:
INSERT INTO pg_spd_node_info VALUES(0,'post_svr2','postgres_fdw','127.0.0.1');
--Testcase 167:
SELECT pg_sleep(2);
--Testcase 420:
Set pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 168:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 421:
SET pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 169:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 422:
SET pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 170:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 423:
SET pgspider_core_fdw.print_error_nodes to true;
--Testcase 171:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 424:
SET pgspider_core_fdw.print_error_nodes to false;
--Testcase 172:
SELECT i,t,a FROM t2 ORDER BY i,t,a,__spd_url;
--Testcase 262:
CREATE SERVER post_svr3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '192.168.11.12',port '15432');
--Testcase 263:
CREATE USER mapping for public server post_svr3 OPTIONS (user 'postgres',password 'postgres');
--Testcase 264:
CREATE FOREIGN TABLE t2__post_svr3__0 (i int, t text,a text) SERVER post_svr3 OPTIONS (table_name 't2');
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

-- Test CoerceViaIO type
--Testcase 282:
CREATE FOREIGN TABLE tbl01 (c1 timestamp without time zone, c2 timestamp with time zone) SERVER pgspider_svr;
--Testcase 283:
CREATE FOREIGN TABLE tbl01__sqlite_svr__0 (c1 timestamp without time zone, c2 timestamp with time zone) SERVER sqlite_svr OPTIONS (table 'tbl01');
--Testcase 284:
SELECT * FROM tbl01;
--Testcase 285:
SELECT c1 || 'time1', c2 || 'time2' FROM tbl01 GROUP BY c1, c2;
--Testcase 286:
DROP FOREIGN TABLE tbl01__sqlite_svr__0;
--Testcase 287:
DROP FOREIGN TABLE tbl01;

-- Test select operator expressions which contain different data type, with WHERE clause contains __spd_url
--Testcase 288:
CREATE FOREIGN TABLE tbl02 (c1 double precision, c2 integer, c3 real, c4 smallint, c5 bigint, c6 numeric,__spd_url text) SERVER pgspider_svr;
--Testcase 289:
CREATE FOREIGN TABLE tbl02__sqlite_svr__0 (c1 double precision, c2 integer, c3 real, c4 smallint, c5 bigint, c6 numeric) SERVER sqlite_svr OPTIONS (table 'tbl02');
--Testcase 290:
SELECT * FROM tbl02;
--Testcase 291:
EXPLAIN VERBOSE
SELECT c1-c2, c2-c3, c3-c4, c3-c5, c5-c6 FROM tbl02 WHERE __spd_url != '$';
--Testcase 292:
SELECT c1-c2, c2-c3, c3-c4, c3-c5, c5-c6 FROM tbl02 WHERE __spd_url != '$';

-- Test for drop/add __spd_url column
--Testcase 298:
SELECT * FROM test1 ORDER BY i, __spd_url;
--Testcase 299:
ALTER FOREIGN TABLE test1 DROP COLUMN __spd_url;
--Testcase 300:
SELECT * FROM test1 ORDER BY i;
--Testcase 301:
ALTER FOREIGN TABLE test1 ADD COLUMN __spd_url text;
--Testcase 302:
SELECT * FROM test1 ORDER BY i, __spd_url;

-- Test bug: using same connection
--Testcase 425:
SET pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 310:
CREATE SERVER server1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
--Testcase 311:
CREATE SERVER server2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');
--Testcase 312:
CREATE SERVER server3 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1',port '15432');

--Testcase 313:
CREATE USER MAPPING FOR public SERVER server1 OPTIONS (user 'postgres',password 'postgres');
--Testcase 314:
CREATE USER MAPPING FOR public SERVER server2 OPTIONS (user 'postgres',password 'postgres');
--Testcase 315:
CREATE USER MAPPING FOR public SERVER server3 OPTIONS (user 'postgres',password 'postgres');

--Testcase 316:
CREATE FOREIGN TABLE tbl03__server1__0 (i int) SERVER server1 OPTIONS (table_name 'tbl03_1');
--Testcase 317:
CREATE FOREIGN TABLE tbl03__server2__0 (i int) SERVER server2 OPTIONS (table_name 'tbl03_2');
--Testcase 318:
CREATE FOREIGN TABLE tbl03__server3__0 (i int) SERVER server3 OPTIONS (table_name 'tbl03_3');
--Testcase 319:
CREATE FOREIGN TABLE tbl03_4 (i int) SERVER server2 OPTIONS (table_name 'tbl03_4');
--Testcase 320:
CREATE FOREIGN TABLE tbl03_5 (i int) SERVER server3 OPTIONS (table_name 'tbl03_5');

--Testcase 321:
CREATE FOREIGN TABLE tbl03 (i int, __spd_url text) SERVER pgspider_svr;

--Testcase 322:
SELECT count(*) FROM tbl03_4;

--Testcase 323:
INSERT INTO tbl03_5 SELECT i FROM tbl03;

--Testcase 324:
SELECT count(*) FROM tbl03_5;

--Testcase 325:
DELETE FROM tbl03_5;

-- modify multitenant table in manual commit mode
BEGIN;
--Testcase 326:
DELETE FROM tbl03;
--Testcase 327:
INSERT INTO tbl03 VALUES (100), (101);
--Testcase 328:
UPDATE tbl03 SET i = 102 WHERE i = 100;
--Testcase 329:
DELETE FROM tbl03 WHERE i = 102 OR i = 101;
ROLLBACK;

--Testcase 426:
SET pgspider_core_fdw.throw_error_ifdead to false;

--Testcase 330:
DROP FOREIGN TABLE tbl03__server1__0;
--Testcase 331:
DROP FOREIGN TABLE tbl03__server2__0;
--Testcase 332:
DROP FOREIGN TABLE tbl03__server3__0;
--Testcase 333:
DROP FOREIGN TABLE tbl03;
--Testcase 334:
DROP SERVER server1, server2, server3 CASCADE;
--
-- Test case routing insert feature
--
-- Test in case of throw_candidate_error = false
-- there are 4 nodes support modification with order: mysql_svr, post_svr, sqlite_svr, tiny_svr
-- file_fdw does not support modification, it's not included in candidate list
--Testcase 427:
CREATE FOREIGN TABLE test2 (i int, __spd_url text) SERVER pgspider_svr;
--Testcase 428:
CREATE FOREIGN TABLE test2__file_svr__0 (i int) SERVER file_svr OPTIONS (filename '/tmp/pgtest.csv');
--Testcase 429:
CREATE FOREIGN TABLE test2__tiny_svr__0 (i int OPTIONS (key 'true')) SERVER tiny_svr OPTIONS (table_name 'test2');
--Testcase 430:
CREATE FOREIGN TABLE test2__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test2');
--Testcase 431:
CREATE FOREIGN TABLE test2__sqlite_svr__0 (i int OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'test2');
--Testcase 432:
CREATE FOREIGN TABLE test2__mysql_svr__0 (i int OPTIONS (key 'true')) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test2');

--Testcase 433:
SET pgspider_core_fdw.throw_error_ifdead to false;
--Testcase 434:
SET pgspider_core_fdw.throw_candidate_error to false;
--Testcase 335:
DELETE FROM test2;
-- First, single insert
--Testcase 336:
INSERT INTO test2 VALUES (1);
--Testcase 435:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 436:
SELECT * FROM test2__mysql_svr__0;
--Testcase 337:
INSERT INTO test2 VALUES (2);
--Testcase 437:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 438:
SELECT * FROM test2__post_svr__0;
--Testcase 338:
INSERT INTO test2 VALUES (3);
--Testcase 439:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 440:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 339:
INSERT INTO test2 VALUES (4);
--Testcase 441:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 442:
SELECT * FROM test2__tiny_svr__0;
--Testcase 340:
INSERT INTO test2 VALUES (5);
--Testcase 443:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 444:
SELECT * FROM test2__mysql_svr__0;
--Testcase 341:
INSERT INTO test2 VALUES (6);
--Testcase 445:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 446:
SELECT * FROM test2__post_svr__0;
--Testcase 342:
DELETE FROM test2;
--Testcase 343:
INSERT INTO test2 VALUES (7);
--Testcase 447:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 448:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 344:
INSERT INTO test2 VALUES (8);
--Testcase 449:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 450:
SELECT * FROM test2__tiny_svr__0;
--Testcase 345:
INSERT INTO test2 VALUES (9);
--Testcase 451:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 452:
SELECT * FROM test2__mysql_svr__0;
--Testcase 346:
INSERT INTO test2 VALUES (10);
--Testcase 453:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 454:
SELECT * FROM test2__post_svr__0;
--Testcase 347:
INSERT INTO test2 VALUES (11);
--Testcase 455:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 456:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 348:
INSERT INTO test2 VALUES (12);
--Testcase 457:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 458:
SELECT * FROM test2__tiny_svr__0;
-- Insert multi values
--Testcase 349:
DELETE FROM test2;
--Testcase 350:
INSERT INTO test2 VALUES (13), (14);
--Testcase 459:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 460:
SELECT * FROM test2__mysql_svr__0;
--Testcase 461:
SELECT * FROM test2__post_svr__0;
--Testcase 462:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 463:
SELECT * FROM test2__tiny_svr__0;
--Testcase 351:
INSERT INTO test2 VALUES (15), (16), (17);
--Testcase 464:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 465:
SELECT * FROM test2__mysql_svr__0;
--Testcase 466:
SELECT * FROM test2__post_svr__0;
--Testcase 467:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 468:
SELECT * FROM test2__tiny_svr__0;
--Testcase 352:
INSERT INTO test2 VALUES (18), (19), (20);
--Testcase 469:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 470:
SELECT * FROM test2__mysql_svr__0;
--Testcase 471:
SELECT * FROM test2__post_svr__0;
--Testcase 472:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 473:
SELECT * FROM test2__tiny_svr__0;
--Testcase 353:
INSERT INTO test2 VALUES (21), (22), (23), (24), (25), (26), (27), (28), (29);
--Testcase 474:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 475:
SELECT * FROM test2__mysql_svr__0;
--Testcase 476:
SELECT * FROM test2__post_svr__0;
--Testcase 477:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 478:
SELECT * FROM test2__tiny_svr__0;
--Testcase 354:
INSERT INTO test2 VALUES (30), (31), (32), (33), (34);
--Testcase 479:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 480:
SELECT * FROM test2__mysql_svr__0;
--Testcase 481:
SELECT * FROM test2__post_svr__0;
--Testcase 482:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 483:
SELECT * FROM test2__tiny_svr__0;
--Testcase 355:
INSERT INTO test2 VALUES (35), (36), (37), (38), (39);
--Testcase 484:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 485:
SELECT * FROM test2__mysql_svr__0;
--Testcase 486:
SELECT * FROM test2__post_svr__0;
--Testcase 487:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 488:
SELECT * FROM test2__tiny_svr__0;
--Testcase 356:
DELETE FROM test2;

-- Insert with IN
--Testcase 357:
INSERT INTO test2 IN ('/post_svr/') VALUES (23);
--Testcase 489:
SELECT * FROM test2__post_svr__0;
--Testcase 358:
INSERT INTO test2 IN ('/tiny_svr/') VALUES (24);
--Testcase 490:
SELECT * FROM test2__tiny_svr__0;
--Testcase 359:
INSERT INTO test2 VALUES (25);
--Testcase 491:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 360:
INSERT INTO test2 IN ('/mysql_svr/') VALUES (26);
--Testcase 492:
SELECT * FROM test2__mysql_svr__0;
--Testcase 361:
INSERT INTO test2 VALUES (27);
--Testcase 493:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 362:
INSERT INTO test2 IN ('/sqlite_svr/') VALUES (28);
--Testcase 494:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 495:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 363:
INSERT INTO test2 IN ('/mysql_svr/') VALUES (29);
--Testcase 496:
SELECT * FROM test2__mysql_svr__0;
--Testcase 364:
INSERT INTO test2 VALUES (30);
--Testcase 497:
SELECT * FROM test2 ORDER BY i, __spd_url;
-- Insert multiple with IN
--Testcase 365:
INSERT INTO test2 IN ('/tiny_svr/', '/sqlite_svr/') VALUES (31), (32), (33), (34), (35);
--Testcase 498:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 499:
SELECT * FROM test2__tiny_svr__0;
--Testcase 500:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 366:
INSERT INTO test2 IN ('/file_svr/') VALUES (36), (37);
--Testcase 501:
SELECT * FROM test2 ORDER BY i, __spd_url;
-- Insert with changing candidate
--Testcase 367:
DELETE FROM test2;
-- Remove next target, in this case, tiny candidate table
--Testcase 502:
DROP FOREIGN TABLE test2__tiny_svr__0;
--Testcase 368:
INSERT INTO test2 VALUES (1);
--Testcase 503:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 504:
SELECT * FROM test2__mysql_svr__0;
--Testcase 505:
SELECT * FROM test2__post_svr__0;
--Testcase 506:
SELECT * FROM test2__sqlite_svr__0;
-- Remove previous target
--Testcase 507:
DROP FOREIGN TABLE test2__mysql_svr__0;
--Testcase 369:
INSERT INTO test2 VALUES (2);
--Testcase 508:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 509:
SELECT * FROM test2__post_svr__0;
--Testcase 510:
SELECT * FROM test2__sqlite_svr__0;
-- Remove all targets
--Testcase 511:
DROP FOREIGN TABLE test2__post_svr__0;
--Testcase 512:
DROP FOREIGN TABLE test2__sqlite_svr__0;
--Testcase 370:
INSERT INTO test2 VALUES (3), (4), (5), (6);
--Testcase 513:
SELECT * FROM test2 ORDER BY i, __spd_url;
-- Create error for child node
--Testcase 371:
DELETE FROM test2;
--Testcase 514:
ALTER SERVER post_svr OPTIONS (SET port '15421');
--Testcase 515:
CREATE FOREIGN TABLE test2__tiny_svr__0 (i int OPTIONS (key 'true')) SERVER tiny_svr OPTIONS (table_name 'test2');
--Testcase 516:
CREATE FOREIGN TABLE test2__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test2');
--Testcase 517:
CREATE FOREIGN TABLE test2__sqlite_svr__0 (i int OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'test2');
--Testcase 518:
CREATE FOREIGN TABLE test2__mysql_svr__0 (i int OPTIONS (key 'true')) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test2');

--Testcase 372:
INSERT INTO test2 VALUES (4), (5), (6), (7);
--Testcase 519:
SELECT * FROM test2 ORDER BY i, __spd_url;

--Testcase 520:
ALTER SERVER post_svr OPTIONS (SET port '15432');
-- Combine insert routing and batch insert
--Testcase 521:
SET client_min_messages = INFO;

--Testcase 373:
DELETE FROM test2;
--Testcase 522:
ALTER SERVER post_svr OPTIONS (ADD batch_size '2');
--Testcase 523:
ALTER SERVER sqlite_svr OPTIONS (ADD batch_size '3');
--Testcase 374:
INSERT INTO test2 VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20), (21), (22);
--Testcase 524:
SELECT * FROM test2 ORDER BY i, __spd_url;

--Testcase 375:
DELETE FROM test2;
--Testcase 525:
SET client_min_messages = NOTICE;
--Testcase 526:
ALTER SERVER post_svr OPTIONS (DROP batch_size);
--Testcase 527:
ALTER SERVER sqlite_svr OPTIONS (DROP batch_size);

-- Test in case of throw_candidate_error = true
-- these below test create error on child node before insert
--Testcase 528:
SET pgspider_core_fdw.throw_candidate_error to true;
-- Single insert
-- Rename a table cannot be reached due to wrong server name
--Testcase 529:
CREATE SERVER sqlite_svr1 FOREIGN DATA WRAPPER sqlite_fdw OPTIONS (database '/tmp/not_existed_pgtest.db');
--Testcase 530:
CREATE FOREIGN TABLE test2__sqlite_svr1__0 (i int OPTIONS (key 'true')) SERVER sqlite_svr1 OPTIONS (table 'test2');
--Testcase 376:
INSERT INTO test2 VALUES (1);
--Testcase 531:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 532:
SELECT * FROM test2__mysql_svr__0;
--Testcase 377:
INSERT INTO test2 VALUES (2);
--Testcase 533:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 534:
SELECT * FROM test2__post_svr__0;
--Testcase 378:
INSERT INTO test2 VALUES (3);
--Testcase 535:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 536:
SELECT * FROM test2__sqlite_svr1__0;
--Testcase 379:
INSERT INTO test2 VALUES (4);
--Testcase 537:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 538:
SELECT * FROM test2__tiny_svr__0;
-- Revert previous table name, and create a non exist table
--Testcase 539:
DROP SERVER sqlite_svr1 CASCADE;
--Testcase 540:
CREATE SERVER mysql_svr1 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '127.0.0.1',port '3306');
--Testcase 541:
CREATE USER mapping for public server mysql_svr1 OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 542:
CREATE FOREIGN TABLE test2__mysql_svr1__0 (i int OPTIONS (key 'true')) SERVER mysql_svr1 OPTIONS (dbname 'not_existed',table_name 'test2');
--Testcase 380:
INSERT INTO test2 VALUES (5);
--Testcase 543:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 544:
SELECT * FROM test2__mysql_svr__0;
--Testcase 381:
INSERT INTO test2 VALUES (6);
--Testcase 545:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 546:
SELECT * FROM test2__mysql_svr__0;
--Testcase 547:
SELECT * FROM test2__mysql_svr1__0;
--Testcase 548:
SELECT * FROM test2__post_svr__0;
--Testcase 382:
DELETE FROM test2__mysql_svr1__0;
--Testcase 383:
INSERT INTO test2 VALUES (7);
--Testcase 549:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 550:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 384:
INSERT INTO test2 VALUES (8);
--Testcase 551:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 552:
SELECT * FROM test2__tiny_svr__0;
--Testcase 553:
DROP FOREIGN TABLE test2__mysql_svr1__0;
--Testcase 554:
DROP SERVER mysql_svr1 CASCADE;
-- More than 1 foreign table error
--Testcase 555:
CREATE FOREIGN TABLE test2__tiny_svr__1 (i int OPTIONS (key 'true')) SERVER tiny_svr OPTIONS (table_name 'test_not_existed');
--Testcase 556:
CREATE FOREIGN TABLE test2__post_svr__1 (i int) SERVER post_svr OPTIONS (table_name 'test_not_existed');
--Testcase 385:
INSERT INTO test2 VALUES (9);
--Testcase 557:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 558:
SELECT * FROM test2__mysql_svr__0;
--Testcase 386:
INSERT INTO test2 VALUES (10);
--Testcase 559:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 560:
SELECT * FROM test2__post_svr__0;
--Testcase 387:
INSERT INTO test2 VALUES (11);
--Testcase 561:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 562:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 563:
SELECT * FROM test2__post_svr__1;
--Testcase 388:
INSERT INTO test2 VALUES (12);
--Testcase 564:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 565:
SELECT * FROM test2__tiny_svr__0;
--Testcase 566:
SELECT * FROM test2__tiny_svr__1;
--Testcase 389:
DELETE FROM test2__post_svr__1;
--Testcase 567:
DROP FOREIGN TABLE test2__tiny_svr__1;
-- Insert multi values
-- At this step, there is 1 invalid candidate test2__post_svr__1. Because postgres_fdw returns an error only after calling postgresIterateForeignScan(), 
-- pgspider_core_fdw cannot detect it (postgres) is an invalid candidate at the listing candidate phase such as PlanForeignModify or BeginForeignModify.
-- So setting invalid table name for foreign table on postgres_fdw is not the case of candidate error.
-- It means that after the insert target is decided, if the chosen postgres is invalid then it raises error, otherwise it succeeds (invalid is not chosen)
--Testcase 390:
INSERT INTO test2 VALUES (13), (14), (15);
--Testcase 568:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 569:
SELECT * FROM test2__mysql_svr__0;
--Testcase 570:
SELECT * FROM test2__post_svr__0;
--Testcase 571:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 572:
SELECT * FROM test2__tiny_svr__0;
--Testcase 573:
SELECT * FROM test2__post_svr__1;
--Testcase 391:
INSERT INTO test2 VALUES (16), (17);
--Testcase 574:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 575:
SELECT * FROM test2__mysql_svr__0;
--Testcase 576:
SELECT * FROM test2__post_svr__0;
--Testcase 577:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 578:
SELECT * FROM test2__tiny_svr__0;
--Testcase 579:
SELECT * FROM test2__post_svr__1;
--Testcase 392:
INSERT INTO test2 VALUES (18), (19), (20);
--Testcase 580:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 581:
SELECT * FROM test2__mysql_svr__0;
--Testcase 582:
SELECT * FROM test2__post_svr__0;
--Testcase 583:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 584:
SELECT * FROM test2__tiny_svr__0;
--Testcase 585:
SELECT * FROM test2__post_svr__1;
--Testcase 393:
INSERT INTO test2 VALUES (21), (22), (23), (24);
--Testcase 586:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 587:
SELECT * FROM test2__mysql_svr__0;
--Testcase 588:
SELECT * FROM test2__post_svr__0;
--Testcase 589:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 590:
SELECT * FROM test2__tiny_svr__0;
--Testcase 591:
SELECT * FROM test2__post_svr__1;
--Testcase 394:
DELETE FROM test2__post_svr__1;

--Testcase 395:
INSERT INTO test2 VALUES (25), (26), (27), (28), (29), (30), (31), (32), (33), (34), (35), (36), (37), (38);
--Testcase 592:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 593:
SELECT * FROM test2__mysql_svr__0;
--Testcase 594:
SELECT * FROM test2__post_svr__0;
--Testcase 595:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 596:
SELECT * FROM test2__tiny_svr__0;
--Testcase 597:
DROP FOREIGN TABLE test2__post_svr__1;
--Testcase 396:
INSERT INTO test2 VALUES (39), (40), (41), (42), (43);
--Testcase 598:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 599:
SELECT * FROM test2__mysql_svr__0;
--Testcase 600:
SELECT * FROM test2__post_svr__0;
--Testcase 601:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 602:
SELECT * FROM test2__tiny_svr__0;
--Testcase 397:
INSERT INTO test2 VALUES (44), (45), (46), (47), (48);
--Testcase 603:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 604:
SELECT * FROM test2__mysql_svr__0;
--Testcase 605:
SELECT * FROM test2__post_svr__0;
--Testcase 606:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 607:
SELECT * FROM test2__tiny_svr__0;

--Testcase 398:
DELETE FROM test2;
-- Insert with changing candidate
-- Remove previous target, tiny node and change its position
--Testcase 608:
ALTER SERVER tiny_svr RENAME TO atiny_svr;
--Testcase 609:
CREATE FOREIGN TABLE test2__atiny_svr__1 (i int OPTIONS (key 'true')) SERVER atiny_svr OPTIONS (table_name 'test2');
--Testcase 610:
DROP FOREIGN TABLE test2__tiny_svr__0;
--Testcase 611:
CREATE FOREIGN TABLE test2__atiny_svr__0 (i int OPTIONS (key 'true')) SERVER atiny_svr OPTIONS (table_name 'test_not_existed');
-- The existing tiny foreign table become unreachable, order is atiny, tiny (invalid), mysql, post, sqlite
--Testcase 399:
INSERT INTO test2 VALUES (1), (2), (3), (4), (5), (6);
--Testcase 612:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 613:
SELECT * FROM test2__atiny_svr__1;
--Testcase 614:
SELECT * FROM test2__mysql_svr__0;
--Testcase 615:
SELECT * FROM test2__post_svr__0;
--Testcase 616:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 617:
SELECT * FROM test2__atiny_svr__0;
--Testcase 400:
DELETE FROM test2__atiny_svr__0;
--Testcase 618:
DROP FOREIGN TABLE test2__atiny_svr__0;
-- After previous insert, the next target is sqlite node
-- Remove next target, change its position
--Testcase 619:
ALTER SERVER sqlite_svr RENAME TO bsqlite_svr;
--Testcase 620:
ALTER FOREIGN TABLE test2__sqlite_svr__0 RENAME TO test2__bsqlite_svr__0;
-- The order now is atiny, bsqlite, mysql, post
--Testcase 401:
INSERT INTO test2 VALUES (1), (2), (3), (4), (5), (6), (7), (8);
--Testcase 621:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 622:
SELECT * FROM test2__atiny_svr__1;
--Testcase 623:
SELECT * FROM test2__mysql_svr__0;
--Testcase 624:
SELECT * FROM test2__post_svr__0;
--Testcase 625:
SELECT * FROM test2__bsqlite_svr__0;
-- Remove all targets
--Testcase 626:
DELETE FROM test2__atiny_svr__1;
--Testcase 627:
DELETE FROM test2__mysql_svr__0;
--Testcase 628:
DELETE FROM test2__post_svr__0;
--Testcase 629:
DELETE FROM test2__bsqlite_svr__0;
--Testcase 630:
DROP FOREIGN TABLE test2__atiny_svr__1;
--Testcase 631:
DROP FOREIGN TABLE test2__mysql_svr__0;
--Testcase 632:
DROP FOREIGN TABLE test2__post_svr__0;
--Testcase 633:
DROP FOREIGN TABLE test2__bsqlite_svr__0;
--Testcase 402:
INSERT INTO test2 VALUES (11), (12), (13), (14), (15);
--Testcase 634:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 403:
DELETE FROM test2;
-- Now revert server and table name, order become mysql, post, sqlite, tiny
--Testcase 635:
ALTER SERVER atiny_svr RENAME TO tiny_svr;
--Testcase 636:
ALTER SERVER bsqlite_svr RENAME TO sqlite_svr;
-- Create an invalid table test2__tiny_svr__1
--Testcase 637:
CREATE FOREIGN TABLE test2__tiny_svr__1 (i int OPTIONS (key 'true')) SERVER tiny_svr OPTIONS (table_name 'not_existed');
--Testcase 638:
CREATE FOREIGN TABLE test2__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test2');
--Testcase 639:
CREATE FOREIGN TABLE test2__sqlite_svr__0 (i int OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'test2');
--Testcase 640:
CREATE FOREIGN TABLE test2__mysql_svr__0 (i int OPTIONS (key 'true')) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test2');
-- Insert with IN in case of error with foreign table
--Testcase 404:
INSERT INTO test2 IN ('/tiny_svr/') VALUES (1);
--Testcase 405:
INSERT INTO test2 IN ('/tiny_svr/') VALUES (2);
--Testcase 641:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 642:
SELECT * FROM test2__tiny_svr__1;
--Testcase 406:
INSERT INTO test2 IN ('/file_svr/') VALUES (3);
--Testcase 643:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 644:
SELECT * FROM test2__file_svr__0;
--Testcase 407:
INSERT INTO test2 VALUES (4);
--Testcase 645:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 408:
INSERT INTO test2 IN ('/post_svr/') VALUES (5);
--Testcase 646:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 647:
SELECT * FROM test2__post_svr__0;
--Testcase 409:
INSERT INTO test2 VALUES (6);
--Testcase 648:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 410:
INSERT INTO test2 IN ('/sqlite_svr/', '/mysql_svr/') VALUES (7), (8);
--Testcase 649:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 650:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 651:
SELECT * FROM test2__mysql_svr__0;
--Testcase 411:
INSERT INTO test2 VALUES (9);
--Testcase 652:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 412:
INSERT INTO test2 IN ('/sqlite_svr/') VALUES (10);
--Testcase 653:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 654:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 413:
INSERT INTO test2 VALUES (11);
--Testcase 655:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 414:
DELETE FROM test2__tiny_svr__1;
--Testcase 656:
DELETE FROM test2__mysql_svr__0;
--Testcase 657:
DELETE FROM test2__sqlite_svr__0;
--Testcase 658:
DELETE FROM test2__post_svr__0;
-- Combine insert routing and batch insert in case of error with foreign table
--Testcase 659:
SET client_min_messages = INFO;
--Testcase 660:
ALTER SERVER mysql_svr OPTIONS (ADD batch_size '2');
--Testcase 661:
ALTER SERVER tiny_svr OPTIONS (ADD batch_size '3');
--Testcase 415:
INSERT INTO test2 VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20), (21), (22), (23), (24), (25);
--Testcase 662:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 663:
SELECT * FROM test2__mysql_svr__0;
--Testcase 664:
SELECT * FROM test2__post_svr__0;
--Testcase 665:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 666:
SELECT * FROM test2__tiny_svr__1;
--Testcase 416:
DROP FOREIGN TABLE test2__tiny_svr__1;
--Testcase 667:
INSERT INTO test2 VALUES (31), (32), (33), (34), (35), (36), (37), (38), (39), (40), (41), (42), (43), (44), (45), (46), (47), (48), (49), (50), (51), (52), (53), (54), (55);
--Testcase 668:
SELECT * FROM test2 ORDER BY i, __spd_url;
--Testcase 669:
SELECT * FROM test2__mysql_svr__0;
--Testcase 670:
SELECT * FROM test2__post_svr__0;
--Testcase 671:
SELECT * FROM test2__sqlite_svr__0;

--Testcase 672:
SET client_min_messages = NOTICE;
--Testcase 673:
ALTER SERVER mysql_svr OPTIONS (DROP batch_size);
--Testcase 674:
ALTER SERVER tiny_svr OPTIONS (DROP batch_size);
--Testcase 417:
DELETE FROM test2;
--Testcase 675:
DROP FOREIGN TABLE test2__mysql_svr__0;
--Testcase 676:
DROP FOREIGN TABLE test2__post_svr__0;
--Testcase 677:
DROP FOREIGN TABLE test2__sqlite_svr__0;
--Testcase 678:
DROP FOREIGN TABLE test2__file_svr__0;
--Testcase 679:
DROP FOREIGN TABLE test2;

--
-- Test case bulk insert
--
--Testcase 304:
CREATE FOREIGN TABLE test2 (i int,__spd_url text) SERVER pgspider_svr;
--Testcase 305:
CREATE FOREIGN TABLE test2__file_svr__0 (i int) SERVER file_svr OPTIONS (filename '/tmp/pgtest.csv');
--Testcase 306:
CREATE FOREIGN TABLE test2__tiny_svr__0 (i int OPTIONS (key 'true')) SERVER tiny_svr OPTIONS (table_name 'test2');
--Testcase 307:
CREATE FOREIGN TABLE test2__post_svr__0 (i int) SERVER post_svr OPTIONS (table_name 'test2');
--Testcase 308:
CREATE FOREIGN TABLE test2__sqlite_svr__0 (i int OPTIONS (key 'true')) SERVER sqlite_svr OPTIONS (table 'test2');
--Testcase 309:
CREATE FOREIGN TABLE test2__mysql_svr__0 (i int) SERVER mysql_svr OPTIONS (dbname 'test',table_name 'test2');

--Testcase 310:
SET client_min_messages = INFO;
-- Manual config:
-- batch_size server = 6, batch_size table = 6553500, batch_size of FDW (if support) not set, insert 120 records
--Testcase 312:
-- ALTER SERVER pgspider_svr OPTIONS (ADD batch_size '6');
--Testcase 680:
ALTER FOREIGN TABLE test2__tiny_svr__0 OPTIONS (ADD batch_size '6553500');
--Testcase 681:
ALTER FOREIGN TABLE test2__post_svr__0 OPTIONS (ADD batch_size '6553500');
--Testcase 682:
ALTER FOREIGN TABLE test2__sqlite_svr__0 OPTIONS (ADD batch_size '6553500');
--Testcase 683:
ALTER FOREIGN TABLE test2__mysql_svr__0 OPTIONS (ADD batch_size '6553500');

--Testcase 684:
INSERT INTO test2 SELECT id FROM generate_series(1, 120) id;

--Testcase 685:
SELECT * FROM test2 ORDER BY 1, 2;

--Testcase 686:
DELETE FROM test2;
--Testcase 687:
SELECT * FROM test2 ORDER BY 1, 2;
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);
--Testcase 688:
ALTER FOREIGN TABLE test2__tiny_svr__0 OPTIONS (DROP batch_size);
--Testcase 689:
ALTER FOREIGN TABLE test2__post_svr__0 OPTIONS (DROP batch_size);
--Testcase 690:
ALTER FOREIGN TABLE test2__sqlite_svr__0 OPTIONS (DROP batch_size);
--Testcase 691:
ALTER FOREIGN TABLE test2__mysql_svr__0 OPTIONS (DROP batch_size);

-- batch_size server = 20, batch_size table not set, batch_size of FDW (if support) difference values, insert 120 records
--Testcase 313:
-- ALTER SERVER pgspider_svr OPTIONS (ADD batch_size '20');
--Testcase 692:
ALTER SERVER post_svr OPTIONS (ADD batch_size '4');
--Testcase 693:
ALTER SERVER sqlite_svr OPTIONS (ADD batch_size '5');
--Testcase 694:
ALTER SERVER tiny_svr OPTIONS (ADD batch_size '6');
--Testcase 695:
ALTER SERVER mysql_svr OPTIONS (ADD batch_size '7');

--Testcase 696:
INSERT INTO test2 SELECT id FROM generate_series(1, 120) id;

--Testcase 697:
SELECT * FROM test2 ORDER BY 1, 2;

--Testcase 698:
DELETE FROM test2;
--Testcase 699:
SELECT * FROM test2 ORDER BY 1, 2;
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);
--Testcase 700:
ALTER SERVER post_svr OPTIONS (DROP batch_size);
--Testcase 701:
ALTER SERVER sqlite_svr OPTIONS (DROP batch_size);
--Testcase 702:
ALTER SERVER tiny_svr OPTIONS (DROP batch_size);
--Testcase 703:
ALTER SERVER mysql_svr OPTIONS (DROP batch_size);

-- batch_size server = 8, batch_size table not set, batch_size of FDW (if support) difference values, insert 20 records
--Testcase 316:
-- ALTER SERVER pgspider_svr OPTIONS (ADD batch_size '8');
--Testcase 704:
ALTER SERVER post_svr OPTIONS (ADD batch_size '2');
--Testcase 705:
ALTER SERVER sqlite_svr OPTIONS (ADD batch_size '3');
--Testcase 706:
ALTER SERVER tiny_svr OPTIONS (ADD batch_size '4');
--Testcase 707:
ALTER SERVER mysql_svr OPTIONS (ADD batch_size '5');

--Testcase 708:
INSERT INTO test2 SELECT id FROM generate_series(1, 20) id;

--Testcase 709:
SELECT * FROM test2 ORDER BY 1, 2;

--Testcase 710:
DELETE FROM test2;
--Testcase 711:
SELECT * FROM test2 ORDER BY 1, 2;
-- ALTER SERVER pgspider_svr OPTIONS (DROP batch_size);
--Testcase 712:
ALTER SERVER post_svr OPTIONS (DROP batch_size);
--Testcase 713:
ALTER SERVER sqlite_svr OPTIONS (DROP batch_size);
--Testcase 714:
ALTER SERVER tiny_svr OPTIONS (DROP batch_size);
--Testcase 715:
ALTER SERVER mysql_svr OPTIONS (DROP batch_size);

-- Auto config:
-- batch size of fdw (if support) difference values
--Testcase 314:
ALTER SERVER post_svr OPTIONS (ADD batch_size '2');
--Testcase 716:
ALTER SERVER sqlite_svr OPTIONS (ADD batch_size '3');
--Testcase 717:
ALTER SERVER tiny_svr OPTIONS (ADD batch_size '4');
--Testcase 718:
ALTER SERVER mysql_svr OPTIONS (ADD batch_size '5');

--Testcase 719:
INSERT INTO test2 SELECT id FROM generate_series(1, 200) id;

--Testcase 720:
SELECT * FROM test2 ORDER BY 1, 2;

--Testcase 721:
DELETE FROM test2;
--Testcase 722:
SELECT * FROM test2 ORDER BY 1, 2;
--Testcase 723:
ALTER SERVER post_svr OPTIONS (DROP batch_size);
--Testcase 724:
ALTER SERVER sqlite_svr OPTIONS (DROP batch_size);
--Testcase 725:
ALTER SERVER tiny_svr OPTIONS (DROP batch_size);
--Testcase 726:
ALTER SERVER mysql_svr OPTIONS (DROP batch_size);

-- batch size of fdw (if support) difference values for FDW but  LCM < limit
--Testcase 315:
ALTER SERVER post_svr OPTIONS (ADD batch_size '2');
--Testcase 727:
ALTER SERVER sqlite_svr OPTIONS (ADD batch_size '3');
--Testcase 728:
ALTER SERVER tiny_svr OPTIONS (ADD batch_size '7');
--Testcase 729:
ALTER SERVER mysql_svr OPTIONS (ADD batch_size '5');

--Testcase 730:
INSERT INTO test2 SELECT id FROM generate_series(1, 1000) id;

--Testcase 731:
SELECT * FROM test2 ORDER BY 1, 2;

-- Test if values of GUC variables are kept after query
SHOW session_authorization;
SHOW timezone_abbreviations;
--Testcase 732:
SELECT * FROM test2 ORDER BY 1, 2 LIMIT 1;
SHOW session_authorization;
SHOW timezone_abbreviations;
-- Verify in parallel mode. Try to force parallel mode to produce parallel plan.
--Testcase 733:
SET parallel_setup_cost=0;
--Testcase 734:
SET parallel_tuple_cost=0;
--Testcase 735:
SET max_parallel_workers_per_gather=4;
--Testcase 736:
SET debug_parallel_query=ON;
--Testcase 750:
SET enable_hashjoin=false;
--Testcase 751:
SET enable_nestloop=true;
--Testcase 752:
SET enable_mergejoin= false;
--Testcase 737:
CREATE TABLE newusermap(dtype text, id text , name text, location text, parentid text, updatetime timestamp DEFAULT now());
--Testcase 738:
ALTER TABLE newusermap ADD PRIMARY KEY (id);
--Testcase 739:
INSERT INTO newusermap SELECT cast (id as text), cast (id as text),cast (id as text),cast (id as text),cast (id as text) FROM generate_series(1, 10) id;
--Testcase 740:
CREATE FOREIGN TABLE usermap__post_svr__0(dtype text, id text NOT NULL, name text, location text, parentid text, updatetime timestamp) SERVER post_svr options (table_name 'usermap');
--Testcase 741:
CREATE FOREIGN TABLE usermap (dtype text, id text NOT NULL, name text, location text, parentid text, updatetime timestamp, __spd_url text) SERVER pgspider_svr;
--Testcase 742:
INSERT INTO usermap SELECT cast (id as text), cast (id as text),cast (id as text),cast (id as text),cast (id as text) FROM generate_series(1, 10) id;
--Testcase 743:
EXPLAIN VERBOSE
SELECT t1.location, t2.location FROM newusermap AS t1, usermap AS t2 WHERE t1.id = t2.id;
--Testcase 744:
SELECT t1.location, t2.location FROM newusermap AS t1, usermap AS t2 WHERE t1.id = t2.id;
--Testcase 745:
EXPLAIN VERBOSE
SELECT min(cast (id as integer)) FROM newusermap;
--Testcase 746:
SELECT min(cast (id as integer)) FROM newusermap;

-- ====================================================================
-- Test if pgspider_core_fdw propagates correct userid to child foreign tables.
-- ====================================================================
--Testcase 753:
Set pgspider_core_fdw.throw_error_ifdead to true;
--Testcase 754:
CREATE ROLE regress_view_owner_another;
GRANT SELECT ON test2 TO regress_view_owner_another;
-- Drop file_fdw child foreign table because it is similar to sqlite_fdw (does not use
-- user mapping).
--Testcase 814:
DROP FOREIGN TABlE test2__file_svr__0;
-- GetUserMapping automatically searches for user mapping of public if not found
-- specific user. Therefore, remove all user mapping of child foreign tables for public
-- to make sure that we test correct user.
--Testcase 755:
DROP USER MAPPING FOR public server mysql_svr;
--Testcase 756:
DROP USER MAPPING FOR public SERVER post_svr;
--Testcase 757:
DROP USER MAPPING FOR public SERVER tiny_svr;
-- Create user mapping for current user, so that current user can query as normal.
--Testcase 758:
CREATE USER MAPPING FOR CURRENT_USER server mysql_svr OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 759:
CREATE USER MAPPING FOR CURRENT_USER SERVER post_svr OPTIONS (user 'postgres',password 'postgres');
--Testcase 760:
CREATE USER MAPPING FOR CURRENT_USER SERVER tiny_svr OPTIONS (username 'user',password 'testuser');

-- Create child foreign table of oracle_fdw
--Testcase 820:
CREATE SERVER oracle_svr FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '', isolation_level 'read_committed', nchar 'true');
--Testcase 821:
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle_svr OPTIONS (user 'test', password 'test');
--Testcase 822:
CREATE FOREIGN TABLE test2__oracle_svr__0 (i int OPTIONS (key 'yes') NOT NULL) SERVER oracle_svr OPTIONS (table 'TEST2');
DO
$$BEGIN
--Testcase 5:
   SELECT oracle_execute('oracle_svr', 'DROP TABLE TEST2 PURGE');
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;$$;
--Testcase 823:
SELECT oracle_execute('oracle_svr', E'CREATE TABLE TEST2 (i int PRIMARY KEY) SEGMENT CREATION IMMEDIATE');
--Testcase 824:
SELECT oracle_execute('oracle_svr', 'INSERT INTO TEST2 VALUES (150)');
--Testcase 825:
SELECT oracle_execute('oracle_svr', 'INSERT INTO TEST2 VALUES (250)');
--Testcase 826:
SELECT * FROM test2__oracle_svr__0;
-- Set use_remote_estimate to true to force postgres_fdw and mysql_fdw use userid at GetForeignRelsize
-- file_fdw and sqlite_fdw does not use userid, tinybrace_fdw always uses userid at GetForeignRelSize,
-- so unnecessary to set for them.
--Testcase 761:
ALTER FOREIGN TABLE test2__post_svr__0 OPTIONS (ADD use_remote_estimate 'true');
--Testcase 762:
ALTER FOREIGN TABLE test2__mysql_svr__0 OPTIONS (ADD use_remote_estimate 'true');
-- Firstly, use current user to query. Expect success.
--Testcase 763:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
--Testcase 764:
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
-- Switch to regress_view_owner_another and query. Expect error because user mapping of mysql_svr for
-- regress_view_owner_another is not created.
--Testcase 765:
SET ROLE regress_view_owner_another;
--Testcase 766:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
--Testcase 767:
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
-- Create user mapping of mysql_svr for regress_view_owner_another and try again. However, user mappings of
-- other child server are not created, so error still occurs. It is required to create user mapping for
-- all necessary child server to be able to query successfully.
--Testcase 768:
RESET ROLE;
--Testcase 769:
CREATE USER MAPPING for regress_view_owner_another server mysql_svr OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 770:
SET ROLE regress_view_owner_another;
--Testcase 771:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
--Testcase 772:
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
-- Now, we create user mapping of all child servers for regress_view_owner_another.
--Testcase 773:
RESET ROLE;
--Testcase 827:
CREATE USER MAPPING FOR regress_view_owner_another SERVER oracle_svr OPTIONS (user 'test', password 'test');
--Testcase 774:
CREATE USER MAPPING for regress_view_owner_another SERVER post_svr OPTIONS (user 'postgres',password 'postgres', password_required 'false');
--Testcase 775:
CREATE USER MAPPING FOR regress_view_owner_another SERVER tiny_svr OPTIONS (username 'user',password 'testuser');
-- Confirm that regress_view_owner_another does not have SELECT privilege on child foreign tables
--Testcase 776:
SET ROLE regress_view_owner_another;
--Testcase 778:
SELECT * FROM test2__mysql_svr__0;
--Testcase 779:
SELECT * FROM test2__post_svr__0;
--Testcase 780:
SELECT * FROM test2__sqlite_svr__0;
--Testcase 781:
SELECT * FROM test2__tiny_svr__0;
--Testcase 829:
SELECT * FROM test2__oracle_svr__0;
-- Even though regress_view_owner_another does not have SELECT privilege on child foreign tables,
-- it still has the SELECT privilege on parent multi-tenant table. Therefore, when querying through
-- multi-tenant table, it can get data from child foreign tables.
-- Now, all user mappings are created, so query success.
--Testcase 782:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
--Testcase 783:
SELECT * FROM test2 ORDER BY i, __spd_url LIMIT 10;
--Testcase 784:
RESET ROLE;

-- When querying to a normal view (security definer view), view owner is used to query
-- (not current user). Verify if pgspider_core_fdw can propagate correctly when querying
-- to that view.
--Testcase 785:
CREATE VIEW view1 AS SELECT * FROM test2;
--Testcase 786:
ALTER VIEW view1 OWNER TO regress_view_owner_another;
--Testcase 787:
DROP USER MAPPING FOR regress_view_owner_another server mysql_svr;
--Testcase 788:
DROP USER MAPPING FOR regress_view_owner_another SERVER post_svr;
--Testcase 789:
DROP USER MAPPING FOR regress_view_owner_another SERVER tiny_svr;
--Testcase 831:
DROP USER MAPPING FOR regress_view_owner_another SERVER oracle_svr;
-- Select from view, view owner regress_view_owner_another is used and propagated
-- to child tables, so error occurs because user mapping for regress_view_owner_another
-- is not created.
--Testcase 790:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i, __spd_url LIMIT 10;
--Testcase 805:
SELECT * FROM view1 ORDER BY i, __spd_url LIMIT 10;
-- Likewise, but with the query under an UNION ALL
--Testcase 791:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM (SELECT * FROM view1 UNION ALL SELECT * FROM view1) ORDER BY i, __spd_url LIMIT 10;
--Testcase 806:
SELECT * FROM (SELECT * FROM view1 UNION ALL SELECT * FROM view1) ORDER BY i, __spd_url LIMIT 10;
-- Mixing querying to view and foreign table, regress_view_owner_another is used for view1,
-- and current user is used for test2. Same error occurs.
--Testcase 792:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.i, t2.i FROM view1 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;
--Testcase 807:
SELECT t1.i, t2.i FROM view1 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;
-- The error does not occur when we mix foreign tables only, because it uses current user to query.
--Testcase 793:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.i, t2.i FROM test2 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;
--Testcase 808:
SELECT t1.i, t2.i FROM test2 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;
-- Now, create user mappings for child tables and try again. Expect success.
--Testcase 794:
CREATE USER MAPPING for regress_view_owner_another server mysql_svr OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 795:
CREATE USER MAPPING for regress_view_owner_another SERVER post_svr OPTIONS (user 'postgres',password 'postgres', password_required 'false');
--Testcase 796:
CREATE USER MAPPING FOR regress_view_owner_another SERVER tiny_svr OPTIONS (username 'user',password 'testuser');
--Testcase 833:
CREATE USER MAPPING FOR regress_view_owner_another SERVER oracle_svr OPTIONS (user 'test', password 'test');
--Testcase 797:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i, __spd_url LIMIT 10;
--Testcase 809:
SELECT * FROM view1 ORDER BY i, __spd_url LIMIT 10;
--Testcase 798:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM (SELECT * FROM view1 UNION ALL SELECT * FROM view1) ORDER BY i, __spd_url LIMIT 10;
--Testcase 810:
SELECT * FROM (SELECT * FROM view1 UNION ALL SELECT * FROM view1) ORDER BY i, __spd_url LIMIT 10;
--Testcase 799:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT t1.i, t2.i FROM view1 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;
--Testcase 811:
SELECT t1.i, t2.i FROM view1 t1 LEFT JOIN test2 t2 ON (t1.i = t2.i) ORDER BY t1.i, t2.i OFFSET 10 LIMIT 10;

-- Verify some other clauses: INSERT, UPDATE, DELETE, ORDER BY, LIMIT, aggregate function
-- Push down LIMIT to oracle_fdw is difficult because of cost, so remove it to make sure that we can push down
-- to all child foreign tables
--Testcase 870:
DROP FOREIGN TABLE test2__oracle_svr__0;
-- Drop user mappings for regress_view_owner_another
--Testcase 837:
DROP USER MAPPING FOR regress_view_owner_another SERVER post_svr;
--Testcase 838:
DROP USER MAPPING FOR regress_view_owner_another SERVER tiny_svr;
--Testcase 841:
DROP USER MAPPING FOR regress_view_owner_another server mysql_svr;
-- Push down ORDER BY, LIMIT, expect error because user mapping is missing
--Testcase 842:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i LIMIT 1;
-- Push down aggregate function, expect error because user mapping is missing
--Testcase 843:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM view1;
-- Modification, expect error because user mapping is missing
GRANT INSERT ON test2 TO regress_view_owner_another;
GRANT UPDATE ON test2 TO regress_view_owner_another;
GRANT DELETE ON test2 TO regress_view_owner_another;
--Testcase 844:
INSERT INTO view1 VALUES (1000), (2000);
--Testcase 845:
UPDATE view1 SET i = i + 1;
--Testcase 846:
DELETE FROM view1 WHERE i > 1000;
-- Recreate user mappings and try again, expect success
--Testcase 847:
CREATE USER MAPPING for regress_view_owner_another server mysql_svr OPTIONS (username 'root',password 'Mysql_1234');
--Testcase 850:
CREATE USER MAPPING for regress_view_owner_another SERVER post_svr OPTIONS (user 'postgres',password 'postgres', password_required 'false');
--Testcase 851:
CREATE USER MAPPING FOR regress_view_owner_another SERVER tiny_svr OPTIONS (username 'user',password 'testuser');
-- Push down ORDER BY, LIMIT
--Testcase 852:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i LIMIT 1;
-- Push down aggregate function
--Testcase 853:
EXPLAIN (VERBOSE, COSTS OFF) SELECT count(*) FROM view1;
-- Modification
--Testcase 854:
INSERT INTO view1 VALUES (1000), (2000);
--Testcase 855:
UPDATE view1 SET i = i + 1;
--Testcase 856:
DELETE FROM view1 WHERE i > 1000;

-- Verify JOIN and OFFSET push down
-- JOIN and OFFSET can only push down to child tables in case of single node, so remove all child nodes except postgres_fdw
--Testcase 857:
DROP FOREIGN TABLE test2__mysql_svr__0;
--Testcase 859:
DROP FOREIGN TABLE test2__sqlite_svr__0;
--Testcase 860:
DROP FOREIGN TABLE test2__tiny_svr__0;
-- Drop user mapping for regress_view_owner_another
--Testcase 861:
DROP USER MAPPING FOR regress_view_owner_another SERVER post_svr;
-- Push down JOIN, expect error because user mapping is missing
--Testcase 862:
EXPLAIN (VERBOSE, COSTS OFF) SELECT t1.i, t2.i FROM view1 t1 JOIN view1 t2 ON (t1.i = t2.i);
--Testcase 863:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i LIMIT 10 OFFSET 1;
--Testcase 864:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 OFFSET 10;
-- Recreate user mapping and try again, expect success
--Testcase 865:
CREATE USER MAPPING for regress_view_owner_another SERVER post_svr OPTIONS (user 'postgres',password 'postgres', password_required 'false');
--Testcase 866:
EXPLAIN (VERBOSE, COSTS OFF) SELECT t1.i, t2.i FROM view1 t1 JOIN view1 t2 ON (t1.i = t2.i);
--Testcase 867:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i LIMIT 10;
--Testcase 868:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 ORDER BY i LIMIT 10 OFFSET 1;
--Testcase 869:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view1 OFFSET 10;

-- Verify Security Invoker View
--Testcase 871:
CREATE VIEW view2 WITH (security_invoker = true) AS SELECT * FROM test2;
--Testcase 872:
ALTER VIEW view2 OWNER TO regress_view_owner_another;
-- Select from view, because security_invoker is true, current user is used to query.
-- Expect success.
--Testcase 873:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view2 ORDER BY i, __spd_url LIMIT 10;
-- Drop user mapping for regress_view_owner_another, it does not affect to the query,
-- because current user is used. View owner is not used.
--Testcase 874:
DROP USER MAPPING FOR regress_view_owner_another SERVER post_svr;
--Testcase 875:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view2 ORDER BY i, __spd_url LIMIT 10;
-- Try to drop user mapping of current user, expect error.
--Testcase 876:
DROP USER MAPPING FOR CURRENT_USER SERVER post_svr;
--Testcase 877:
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM view2 ORDER BY i, __spd_url LIMIT 10;
-- Restore user mapping
--Testcase 878:
CREATE USER MAPPING for CURRENT_USER SERVER post_svr OPTIONS (user 'postgres',password 'postgres', password_required 'false');

--Testcase 747:
DELETE FROM test2;

-- Clean up
--Testcase 800:
DROP USER MAPPING FOR regress_view_owner_another server mysql_svr;
--Testcase 802:
DROP USER MAPPING FOR regress_view_owner_another SERVER tiny_svr;
--Testcase 758:
DROP USER MAPPING FOR CURRENT_USER server mysql_svr;
--Testcase 759:
DROP USER MAPPING FOR CURRENT_USER SERVER post_svr;
--Testcase 760:
DROP USER MAPPING FOR CURRENT_USER SERVER tiny_svr;
--Testcase 803:
DROP OWNED BY regress_view_owner_another;
--Testcase 804:
DROP ROLE regress_view_owner_another;

--Testcase 748:
DROP FOREIGN TABLE test2 CASCADE;

--Testcase 749:
SET client_min_messages = NOTICE;
--Testcase 293:
DROP FOREIGN TABLE tbl02__sqlite_svr__0;
--Testcase 294:
DROP FOREIGN TABLE tbl02;
--Testcase 265:
DROP FOREIGN TABLE test1;
--Testcase 266:
DROP FOREIGN TABLE t1;
--Testcase 267:
DROP FOREIGN TABLE t2;
--Testcase 268:
DROP SERVER pgspider_svr CASCADE;
--Testcase 269:
DROP EXTENSION pgspider_core_fdw CASCADE;

--Clean
--Testcase 270:
DROP EXTENSION postgres_fdw CASCADE;
--Testcase 271:
DROP EXTENSION file_fdw CASCADE;
--Testcase 272:
DROP EXTENSION sqlite_fdw CASCADE;
--Testcase 273:
DROP EXTENSION tinybrace_fdw CASCADE;
--Testcase 274:
DROP EXTENSION mysql_fdw CASCADE;
--Testcase 880:
DROP EXTENSION oracle_fdw CASCADE;
