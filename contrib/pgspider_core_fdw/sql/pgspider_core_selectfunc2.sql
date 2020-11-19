SET datestyle=ISO;
SET timezone='Japan';

--Testcase 1:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 2:
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1');
--Testcase 3:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;

----------------------------------------------------------
-- test structure
-- PGSpider Top Node -> Child PGSpider Node -> Data source
-- stub functions are provided by pgspider_fdw

----------------------------------------------------------
-- Data source: influxdb

--Testcase 4:
CREATE FOREIGN TABLE s3 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_core_svr;
--Testcase 5:
CREATE EXTENSION pgspider_fdw;
--Testcase 6:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 7:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 8:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 's3influx');

-- s3 (value1,3 as float8, value2,4 as bigint)
--Testcase 9:
\d s3;
--Testcase 10:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 11:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 12:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 13:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (buitin function, result)
--Testcase 14:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 15:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 16:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 17:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 18:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 19:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 20:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 21:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 22:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 23:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 24:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base)
--Testcase 25:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 26:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 27:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 28:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 29:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 30:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 31:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 32:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log2 (stub function, explain)
--Testcase 33:
EXPLAIN VERBOSE
SELECT log2(value1),log2(value2) FROM s3;

-- select log2 (stub function, result)
--Testcase 34:
SELECT * FROM (
SELECT log2(value1),log2(value2) FROM s3
) AS t ORDER BY 1,2;

-- select spread (stub agg function, explain)
--Testcase 35:
EXPLAIN VERBOSE
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function, result)
--Testcase 36:
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function with numeric cast, explain)
--Testcase 37:
EXPLAIN VERBOSE
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3;

-- select spread (stub agg function with numeric cast, )
--Testcase 38:
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 39:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 40:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest with log2 (pushdown, explain)
--Testcase 41:
EXPLAIN VERBOSE
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3;

-- select abs as nest with log2 (pushdown, result)
--Testcase 42:
SELECT * FROM (
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3
) AS t ORDER BY 1,2;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 43:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 44:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 45:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 46:
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 47:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select spread (stub agg function and group by influx_time() and tag) (explain)
--Testcase 48:
EXPLAIN VERBOSE
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread (stub agg function and group by influx_time() and tag) (result)
--Testcase 49:
SELECT * FROM (
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1
) AS t ORDER BY 1,2,3;

-- select spread (stub agg function and group by tag only) (result)
--Testcase 50:
SELECT * FROM (
SELECT tag1,spread("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1
) AS t ORDER BY 1,2;

-- select spread (stub agg function and other aggs) (result)
--Testcase 51:
SELECT sum("value1"),spread("value1"),count("value1") FROM s3;

-- select abs with order by (explain)
--Testcase 52:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 53:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 54:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 55:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 56:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select spread over join query (explain)
--Testcase 57:
EXPLAIN VERBOSE
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread over join query (result, stub call error)
--Testcase 58:
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread with having (explain)
--Testcase 59:
EXPLAIN VERBOSE
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select spread with having (explain, cannot pushdown, stub call error)
--Testcase 60:
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 61:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 62:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 63:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 64:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 65:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 66:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

--Testcase 67:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 68:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 69:
DROP SERVER pgspider_svr;
--Testcase 70:
DROP EXTENSION pgspider_fdw;
--Testcase 71:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: sqlite

--Testcase 72:
CREATE FOREIGN TABLE s3 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 73:
CREATE EXTENSION pgspider_fdw;
--Testcase 74:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 75:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 76:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr OPTIONS(table_name 's3sqlite');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 77:
\d s3;
--Testcase 78:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- select abs (builtin function, explain)
--Testcase 79:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- select abs (buitin function, result)
--Testcase 80:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 81:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 82:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 83:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 84:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 85:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 86:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 87:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 88:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select abs with order by (explain)
--Testcase 89:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 90:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 91:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 92:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 93:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 94:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 95:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 96:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 97:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 98:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 99:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- sqlite pushdown supported functions (explain)
--Testcase 100:
EXPLAIN VERBOSE
SELECT abs(value3), length(tag1), lower(str1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3;

-- sqlite pushdown supported functions (result)
--Testcase 101:
SELECT * FROM (
SELECT abs(value3), length(tag1), lower(str1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3
) AS t ORDER BY 1,2,3,4,5,6,7,8,9,10,11;

--Testcase 102:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 103:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 104:
DROP SERVER pgspider_svr;
--Testcase 105:
DROP EXTENSION pgspider_fdw;
--Testcase 106:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: mysql

--Testcase 107:
CREATE FOREIGN TABLE s3 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 108:
CREATE FOREIGN TABLE ftextsearch (id int, content text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 109:
CREATE EXTENSION pgspider_fdw;
--Testcase 110:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 111:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 112:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 's3mysql');
--Testcase 113:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr__0 (id int, content text) SERVER pgspider_svr OPTIONS (table_name 'ftextsearch');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 114:
\d s3;
--Testcase 115:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 116:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 117:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 118:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (buitin function, result)
--Testcase 119:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 120:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 121:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 122:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 123:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 124:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 125:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 126:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 127:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 128:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 129:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base), mysql (base, v)
--Testcase 130:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 131:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 132:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 133:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 134:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 135:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 136:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 137:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 138:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 139:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 140:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 141:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 142:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 143:
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 144:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select abs with order by (explain)
--Testcase 145:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 146:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 147:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 148:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 149:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 150:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 151:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 152:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 153:
SELECT * FROM (
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1
) AS t ORDER BY 1,2,3;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 154:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 155:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3
) AS t ORDER BY 1,2,3;

-- full text search table

-- text search (pushdown, explain)
--Testcase 156:
EXPLAIN VERBOSE
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0;

-- text search (pushdown, result)
--Testcase 157:
SELECT content FROM (
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0
       ) AS t ORDER BY 1;

--Testcase 158:
DROP FOREIGN TABLE ftextsearch__pgspider_svr__0;
--Testcase 159:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 160:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 161:
DROP SERVER pgspider_svr;
--Testcase 162:
DROP EXTENSION pgspider_fdw;
--Testcase 163:
DROP FOREIGN TABLE ftextsearch;
--Testcase 164:
DROP FOREIGN TABLE s3;

--Testcase 165:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 166:
DROP SERVER pgspider_core_svr;
--Testcase 167:
DROP EXTENSION pgspider_core_fdw;
