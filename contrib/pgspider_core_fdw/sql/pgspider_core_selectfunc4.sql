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
-- PGSpider Top Node -+-> Child PGSpider Node -> Data source
--                    +-> Data source
-- stub functions are provided by pgspider_fdw and/or Data source FDW (mix use)

----------------------------------------------------------
-- Data source: influxdb

--Testcase 4:
CREATE FOREIGN TABLE s3 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_core_svr;
--Testcase 5:
CREATE EXTENSION pgspider_fdw;
--Testcase 6:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 7:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 8:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_svr1 OPTIONS (table_name 's31influx');

--Testcase 9:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 10:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 11:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_svr2 OPTIONS (table_name 's32influx');

-- s3 (value1,3 as float8, value2,4 as bigint)
--Testcase 12:
\d s3;
--Testcase 13:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 14:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 15:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 16:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (buitin function, result)
--Testcase 17:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 18:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 19:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 20:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 21:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 22:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 23:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 24:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 25:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 26:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 27:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base)
--Testcase 28:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 29:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 30:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 31:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 32:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 33:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 34:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 35:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log2 (stub function, explain)
--Testcase 36:
EXPLAIN VERBOSE
SELECT log2(value1),log2(value2) FROM s3;

-- select log2 (stub function, result)
--Testcase 37:
SELECT * FROM (
SELECT log2(value1),log2(value2) FROM s3
) AS t ORDER BY 1,2;

-- select spread (stub agg function, explain)
--Testcase 38:
EXPLAIN VERBOSE
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function, result)
--Testcase 39:
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function with numeric cast, explain)
--Testcase 40:
EXPLAIN VERBOSE
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3;

-- select spread (stub agg function, error)
--Testcase 41:
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 42:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 43:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest with log2 (pushdown, explain)
--Testcase 44:
EXPLAIN VERBOSE
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3;

-- select abs as nest with log2 (pushdown, result)
--Testcase 45:
SELECT * FROM (
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3
) AS t ORDER BY 1,2;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 46:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 47:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 48:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 49:
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 50:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select spread (stub agg function and group by influx_time() and tag) (explain)
--Testcase 51:
EXPLAIN VERBOSE
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread (stub agg function and group by influx_time() and tag) (result)
--Testcase 52:
SELECT * FROM (
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1
) AS t ORDER BY 1,2,3;

-- select spread (stub agg function and group by tag only) (result)
--Testcase 53:
SELECT * FROM (
SELECT tag1,spread("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1
) AS t ORDER BY 1,2;

-- select spread (stub agg function and other aggs) (result)
--Testcase 54:
SELECT sum("value1"),spread("value1"),count("value1") FROM s3;

-- select abs with order by (explain)
--Testcase 55:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 56:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 57:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 58:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 59:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select spread over join query (explain)
--Testcase 60:
EXPLAIN VERBOSE
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread over join query (result, stub call error)
--Testcase 61:
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread with having (explain)
--Testcase 62:
EXPLAIN VERBOSE
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select spread with having (explain, cannot pushdown, stub call error)
--Testcase 63:
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 64:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 65:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 66:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 67:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 68:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 69:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

--Testcase 70:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 71:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 72:
DROP SERVER pgspider_svr2;

--Testcase 73:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 74:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 75:
DROP SERVER pgspider_svr1;
--Testcase 76:
DROP EXTENSION pgspider_fdw;
--Testcase 77:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: sqlite

--Testcase 78:
CREATE FOREIGN TABLE s3 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 79:
CREATE EXTENSION pgspider_fdw;
--Testcase 80:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 81:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 82:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr1 OPTIONS (table_name 's31sqlite');

--Testcase 83:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 84:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 85:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr2 OPTIONS (table_name 's32sqlite');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 86:
\d s3;
--Testcase 87:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- select abs (builtin function, explain)
--Testcase 88:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- select abs (buitin function, result)
--Testcase 89:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 90:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 91:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 92:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 93:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 94:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 95:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 96:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 97:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select abs with order by (explain)
--Testcase 98:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 99:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 100:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 101:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 102:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 103:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 104:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 105:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 106:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 107:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 108:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- sqlite pushdown supported functions (explain)
--Testcase 109:
EXPLAIN VERBOSE
SELECT abs(value3), length(tag1), lower(str1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3;

-- sqlite pushdown supported functions (result)
--Testcase 110:
SELECT * FROM (
SELECT abs(value3), length(tag1), lower(str1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3
) AS t ORDER BY 1,2,3,4,5,6,7,8,9,10,11;

--Testcase 111:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 112:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 113:
DROP SERVER pgspider_svr2;

--Testcase 114:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 115:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 116:
DROP SERVER pgspider_svr1;
--Testcase 117:
DROP EXTENSION pgspider_fdw;
--Testcase 118:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: mysql

--Testcase 119:
CREATE FOREIGN TABLE s3 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 120:
CREATE FOREIGN TABLE ftextsearch (id int, content text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 121:
CREATE EXTENSION pgspider_fdw;
--Testcase 122:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');

--Testcase 123:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 124:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr1 OPTIONS (table_name 's31mysql');

--Testcase 125:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 126:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 127:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr2 OPTIONS (table_name 's32mysql');

--Testcase 128:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr1__0 (id int, content text) SERVER pgspider_svr1 OPTIONS (table_name 'ftextsearch1');
--Testcase 129:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr2__0 (id int, content text) SERVER pgspider_svr2 OPTIONS (table_name 'ftextsearch2');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 130:
\d s3;
--Testcase 131:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 132:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 133:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 134:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (buitin function, result)
--Testcase 135:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 136:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 137:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 138:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 139:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 140:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 141:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 142:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 143:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 144:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 145:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base), mysql (base, v)
--Testcase 146:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 147:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 148:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 149:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 150:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 151:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 152:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 153:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 154:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 155:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 156:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 157:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 158:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 159:
SELECT * FROM (
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 160:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select abs with order by (explain)
--Testcase 161:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 162:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 163:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 164:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 165:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 166:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 167:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 168:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 169:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 170:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 171:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3
) AS t ORDER BY 1,2,3;

-- full text search table

-- text search (pushdown, explain)
--Testcase 172:
EXPLAIN VERBOSE
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0;

-- text search (pushdown, result)
--Testcase 173:
SELECT content FROM (
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0
       ) AS t ORDER BY 1;

--Testcase 174:
DROP FOREIGN TABLE ftextsearch__pgspider_svr1__0;
--Testcase 175:
DROP FOREIGN TABLE ftextsearch__pgspider_svr2__0;
--Testcase 176:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 177:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 178:
DROP SERVER pgspider_svr2;

--Testcase 179:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 180:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 181:
DROP SERVER pgspider_svr1;

--Testcase 182:
DROP EXTENSION pgspider_fdw;

--Testcase 183:
DROP FOREIGN TABLE ftextsearch;
--Testcase 184:
DROP FOREIGN TABLE s3;
--Testcase 185:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 186:
DROP SERVER pgspider_core_svr;
--Testcase 187:
DROP EXTENSION pgspider_core_fdw;
