--Testcase 1264:
SET datestyle=ISO;
--Testcase 1265:
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
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 7:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 8:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 's31influx');

--Testcase 9:
CREATE EXTENSION influxdb_fdw;
--Testcase 10:
CREATE SERVER influxdb_svr FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (dbname 'selectfunc_db', host 'http://localhost', port '8086');
--Testcase 11:
CREATE USER MAPPING FOR CURRENT_USER SERVER influxdb_svr OPTIONS (user 'user', password 'pass');
--Testcase 12:
CREATE FOREIGN TABLE s3__influxdb_svr__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint) SERVER influxdb_svr OPTIONS (table 's32', tags 'tag1');

-- s3 (value1,3 as float8, value2,4 as bigint)
--Testcase 13:
\d s3;
--Testcase 14:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 15:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3 ORDER BY 1;

-- select float8() (not pushdown, remove float8, result)
--Testcase 16:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 17:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 ORDER BY 1;

-- select sqrt (buitin function, result)
--Testcase 18:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, not pushdown constraints, explain)
--Testcase 19:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 20:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 21:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 22:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select sqrt(*) (stub function, explain)
--Testcase 23:
EXPLAIN VERBOSE
SELECT sqrt_all() from s3 ORDER BY 1;

-- select sqrt(*) (stub function, result)
--Testcase 24:
SELECT * FROM (
SELECT sqrt_all() from s3
) AS t ORDER BY 1;

-- select sqrt(*) (stub function and group by tag only) (explain)
--Testcase 1266:
EXPLAIN VERBOSE
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select sqrt(*) (stub function and group by tag only) (result)
--Testcase 1267:
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs (builtin function, explain)
--Testcase 25:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 26:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 27:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 28:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 29:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 30:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base)
--Testcase 31:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 32:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 33:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 34:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 35:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 36:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 37:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 38:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log(*) (stub function, explain)
--Testcase 39:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3 ORDER BY 1;

-- select log(*) (stub function, result)
--Testcase 40:
SELECT * FROM (
SELECT log_all(50) FROM s3
) AS t ORDER BY 1;

-- select log(*) (stub function, explain)
--Testcase 41:
EXPLAIN VERBOSE
SELECT log_all(70.5) FROM s3 ORDER BY 1;

-- select log(*) (stub function, result)
--Testcase 42:
SELECT * FROM (
SELECT log_all(70.5) FROM s3
) AS t ORDER BY 1;

-- select log(*) (stub function and group by tag only) (explain)
--Testcase 1268:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log(*) (stub function and group by tag only) (result)
--Testcase 1269:
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 43:
SELECT ln_all(),log10_all(),log_all(50) FROM s3 ORDER BY 1;

-- select log2 (stub function, explain)
--Testcase 44:
EXPLAIN VERBOSE
SELECT log2(value1),log2(value2) FROM s3 ORDER BY 1;

-- select log2 (stub function, result)
--Testcase 45:
SELECT * FROM (
SELECT log2(value1),log2(value2) FROM s3
) AS t ORDER BY 1,2;

-- select log2(*) (stub function, explain)
--Testcase 46:
EXPLAIN VERBOSE
SELECT log2_all() from s3 ORDER BY 1;

-- select log2(*) (stub function, result)
--Testcase 47:
SELECT * FROM (
SELECT log2_all() from s3
) AS t ORDER BY 1;

-- select log2(*) (stub function and group by tag only) (explain)
--Testcase 1270:
EXPLAIN VERBOSE
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log2(*) (stub function and group by tag only) (result)
--Testcase 1271:
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log10 (stub function, explain)
--Testcase 48:
EXPLAIN VERBOSE
SELECT log10(value1),log10(value2) FROM s3 ORDER BY 1;

-- select log10 (stub function, result)
--Testcase 49:
SELECT * FROM (
SELECT log10(value1),log10(value2) FROM s3
) AS t ORDER BY 1,2;

-- select log10(*) (stub function, explain)
--Testcase 50:
EXPLAIN VERBOSE
SELECT log10_all() from s3 ORDER BY 1;

-- select log10(*) (stub function, result)
--Testcase 51:
SELECT * FROM (
SELECT log10_all() from s3
) AS t ORDER BY 1;

-- select log10(*) (stub function and group by tag only) (explain)
--Testcase 1272:
EXPLAIN VERBOSE
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log10(*) (stub function and group by tag only) (result)
--Testcase 1273:
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 52:
SELECT log2_all(), log10_all() FROM s3 ORDER BY 1;

-- select spread (stub agg function, explain)
--Testcase 53:
EXPLAIN VERBOSE
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3 ORDER BY 1;

-- select spread (stub agg function, result)
--Testcase 54:
SELECT * FROM (
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select spread (stub agg function, raise exception if not expected type)
--Testcase 55:
SELECT * FROM (
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 56:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 57:
SELECT * FROM (
SELECT sum(value3),abs(sum(value3)) FROM s3
) AS t ORDER BY 1,2;

-- select abs as nest with log2 (pushdown, explain)
--Testcase 58:
EXPLAIN VERBOSE
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3 ORDER BY 1;

-- select abs as nest with log2 (pushdown, result)
--Testcase 59:
SELECT * FROM (
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3
) AS t ORDER BY 1,2;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 60:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 61:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 62:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 63:
SELECT * FROM (
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 64:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3 ORDER BY 1;

-- select spread (stub agg function and group by influx_time() and tag) (explain)
--Testcase 65:
EXPLAIN VERBOSE
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread (stub agg function and group by influx_time() and tag) (result)
--Testcase 66:
SELECT * FROM (
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1
) AS t ORDER BY 1,2,3;

-- select spread (stub agg function and group by tag only) (result)
--Testcase 67:
SELECT * FROM (
SELECT tag1,spread("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1
) AS t ORDER BY 1,2;

-- select spread (stub agg function and other aggs) (result)
--Testcase 68:
SELECT sum("value1"),spread("value1"),count("value1") FROM s3 ORDER BY 1;

-- select abs with order by (explain)
--Testcase 69:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 70:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 71:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 72:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 73:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs(*) (stub function, explain)
--Testcase 74:
EXPLAIN VERBOSE
SELECT abs_all() from s3 ORDER BY 1;

-- select abs(*) (stub function, result)
--Testcase 75:
SELECT * FROM (
SELECT abs_all() from s3
) AS t ORDER BY 1;

-- select abs(*) (stub function and group by tag only) (explain)
--Testcase 1274:
EXPLAIN VERBOSE
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs(*) (stub function and group by tag only) (result)
--Testcase 1275:
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs(*) (stub function, expose data, explain)
--Testcase 76:
EXPLAIN VERBOSE
SELECT (abs_all()::s3).* from s3 ORDER BY 1;

-- select abs(*) (stub function, expose data, result)
--Testcase 77:
SELECT * FROM (
SELECT (abs_all()::s3).* from s3
) AS t ORDER BY 1;

-- select spread over join query (explain)
--Testcase 78:
EXPLAIN VERBOSE
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select spread over join query (result, stub call error)
--Testcase 79:
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select spread with having (explain)
--Testcase 80:
EXPLAIN VERBOSE
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100 ORDER BY 1;

-- select spread with having (result, not pushdown, stub call error)
--Testcase 81:
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100 ORDER BY 1;

-- select spread(*) (stub agg function, explain)
--Testcase 82:
EXPLAIN VERBOSE
SELECT spread_all(*) from s3 ORDER BY 1;

-- select spread(*) (stub agg function, result)
--Testcase 83:
SELECT spread_all(*) from s3 ORDER BY 1;

-- select spread(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 84:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 85:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by tag only) (explain)
--Testcase 86:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by tag only) (result)
--Testcase 87:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(*) (stub agg function, expose data, explain)
--Testcase 88:
EXPLAIN VERBOSE
SELECT (spread_all(*)::s3).* from s3 ORDER BY 1;

-- select spread(*) (stub agg function, expose data, result)
--Testcase 89:
SELECT (spread_all(*)::s3).* from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, explain)
--Testcase 90:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, result)
--Testcase 91:
SELECT spread('/value[1,4]/') from s3 ORDER BY 1;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 92:
EXPLAIN VERBOSE
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 93:
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by tag only) (explain)
--Testcase 94:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by tag only) (result)
--Testcase 95:
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(regex) (stub agg function, expose data, explain)
--Testcase 96:
EXPLAIN VERBOSE
SELECT (spread('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, expose data, result)
--Testcase 97:
SELECT (spread('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 98:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 99:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 100:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (result)
--Testcase 101:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 102:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 103:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- nested function in where clause (explain)
--Testcase 104:
EXPLAIN VERBOSE
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

-- nested function in where clause (result)
--Testcase 105:
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

--Testcase 106:
EXPLAIN VERBOSE
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3 ORDER BY 1;

--Testcase 107:
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3 ORDER BY 1;

-- select first(*) (stub agg function, explain)
--Testcase 108:
EXPLAIN VERBOSE
SELECT first_all(*) from s3 ORDER BY 1;

-- select first(*) (stub agg function, result)
--Testcase 109:
SELECT * FROM (
SELECT first_all(*) from s3
) AS t ORDER BY 1;

-- select first(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 110:
EXPLAIN VERBOSE
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select first(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 111:
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select first(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(*) (stub agg function and group by tag only) (result)
-- -- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(*) (stub agg function, expose data, explain)
--Testcase 112:
EXPLAIN VERBOSE
SELECT (first_all(*)::s3).* from s3 ORDER BY 1;

-- select first(*) (stub agg function, expose data, result)
--Testcase 113:
SELECT * FROM (
SELECT (first_all(*)::s3).* from s3
) AS t ORDER BY 1;

-- select first(regex) (stub function, explain)
--Testcase 114:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/') from s3 ORDER BY 1;

-- select first(regex) (stub function, explain)
--Testcase 115:
SELECT first('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 116:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 117:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select first(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 118:
EXPLAIN VERBOSE
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select first(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 119:
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select first(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(regex) (stub agg function and group by tag only) (result)
-- -- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(regex) (stub agg function, expose data, explain)
--Testcase 120:
EXPLAIN VERBOSE
SELECT (first('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select first(regex) (stub agg function, expose data, result)
--Testcase 121:
SELECT * FROM (
SELECT (first('/value[1,4]/')::s3).* from s3
) AS t ORDER BY 1;

--Testcase 122:
EXPLAIN VERBOSE
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3 ORDER BY 1;

--Testcase 123:
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3 ORDER BY 1;

-- select last(*) (stub agg function, explain)
--Testcase 124:
EXPLAIN VERBOSE
SELECT last_all(*) from s3 ORDER BY 1;

-- select last(*) (stub agg function, result)
--Testcase 125:
SELECT * FROM (
SELECT last_all(*) from s3
) AS t ORDER BY 1;

-- select last(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 126:
EXPLAIN VERBOSE
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select last(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 127:
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select last(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(*) (stub agg function and group by tag only) (result)
-- -- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(*) (stub agg function, expose data, explain)
--Testcase 128:
EXPLAIN VERBOSE
SELECT (last_all(*)::s3).* from s3 ORDER BY 1;

-- select last(*) (stub agg function, expose data, result)
--Testcase 129:
SELECT * FROM (
SELECT (last_all(*)::s3).* from s3
) AS t ORDER BY 1;

-- select last(regex) (stub function, explain)
--Testcase 130:
EXPLAIN VERBOSE
SELECT last('/value[1,4]/') from s3 ORDER BY 1;

-- select last(regex) (stub function, result)
--Testcase 131:
SELECT last('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 132:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 133:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select last(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 134:
EXPLAIN VERBOSE
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select last(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 135:
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select last(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(regex) (stub agg function and group by tag only) (result)
-- -- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(regex) (stub agg function, expose data, explain)
--Testcase 136:
EXPLAIN VERBOSE
SELECT (last('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select last(regex) (stub agg function, expose data, result)
--Testcase 137:
SELECT * FROM (
SELECT (last('/value[1,4]/')::s3).* from s3
) AS t ORDER BY 1;

--Testcase 138:
EXPLAIN VERBOSE
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200 ORDER BY 1;
--Testcase 139:
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200 ORDER BY 1;

--Testcase 140:
EXPLAIN VERBOSE
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s') ORDER BY 1;

--Testcase 141:
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s') ORDER BY 1;

-- select sample(*, int) (stub agg function, explain)
--Testcase 142:
EXPLAIN VERBOSE
SELECT sample_all(50) from s3 ORDER BY 1;

-- select sample(*, int) (stub agg function, result)
--Testcase 143:
SELECT * FROM (
SELECT sample_all(50) from s3
) AS t ORDER BY 1;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 144:
EXPLAIN VERBOSE
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (result)
--Testcase 145:
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select sample(*, int) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(*, int) (stub agg function and group by tag only) (result)
-- -- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(*, int) (stub agg function, expose data, explain)
--Testcase 146:
EXPLAIN VERBOSE
SELECT (sample_all(50)::s3).* from s3 ORDER BY 1;

-- select sample(*, int) (stub agg function, expose data, result)
--Testcase 147:
SELECT * FROM (
SELECT (sample_all(50)::s3).* from s3
) AS t ORDER BY 1;

-- select sample(regex) (stub agg function, explain)
--Testcase 148:
EXPLAIN VERBOSE
SELECT sample('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select sample(regex) (stub agg function, result)
--Testcase 149:
SELECT sample('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 150:
EXPLAIN VERBOSE
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 151:
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select sample(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(regex) (stub agg function and group by tag only) (result)
-- -- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(regex) (stub agg function, expose data, explain)
--Testcase 152:
EXPLAIN VERBOSE
SELECT (sample('/value[1,4]/', 50)::s3).* from s3 ORDER BY 1;

-- select sample(regex) (stub agg function, expose data, result)
--Testcase 153:
SELECT * FROM (
SELECT (sample('/value[1,4]/', 50)::s3).* from s3
) AS t ORDER BY 1;

--Testcase 154:
EXPLAIN VERBOSE
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3 ORDER BY 1;

--Testcase 155:
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3 ORDER BY 1;

-- select cumulative_sum(*) (stub function, explain)
--Testcase 156:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() from s3 ORDER BY 1;

-- select cumulative_sum(*) (stub function, result)
--Testcase 157:
SELECT * FROM (
SELECT cumulative_sum_all() from s3
) AS t ORDER BY 1;

-- select cumulative_sum(regex) (stub function, result)
--Testcase 158:
SELECT cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select cumulative_sum(regex) (stub function, result)
--Testcase 159:
SELECT cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (result)
--Testcase 160:
EXPLAIN VERBOSE
SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (result)
--Testcase 161:
SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select cumulative_sum(*) (stub function and group by tag only) (explain)
--Testcase 1276:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(*) (stub function and group by tag only) (result)
--Testcase 1277:
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select cumulative_sum(regex) (stub function and group by tag only) (explain)
--Testcase 1278:
EXPLAIN VERBOSE
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(regex) (stub function and group by tag only) (result)
--Testcase 1279:
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, explain)
--Testcase 162:
EXPLAIN VERBOSE
SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, result)
--Testcase 163:
SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

--Testcase 164:
EXPLAIN VERBOSE
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3 ORDER BY 1;

--Testcase 165:
SELECT * FROM (
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

--Testcase 166:
EXPLAIN VERBOSE
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3 ORDER BY 1;

--Testcase 167:
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3 ORDER BY 1;

-- select derivative(*) (stub function, explain)
--Testcase 168:
EXPLAIN VERBOSE
SELECT derivative_all() from s3 ORDER BY 1;

-- select derivative(*) (stub function, result)
--Testcase 169:
SELECT * FROM (
SELECT derivative_all() from s3
) as t ORDER BY 1;

-- select derivative(regex) (stub function, explain)
--Testcase 170:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select derivative(regex) (stub function, result)
--Testcase 171:
SELECT derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 172:
EXPLAIN VERBOSE
SELECT derivative_all(), derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 173:
SELECT derivative_all(), derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select derivative(*) (stub function and group by tag only) (explain)
--Testcase 1280:
EXPLAIN VERBOSE
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(*) (stub function and group by tag only) (result)
--Testcase 1281:
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1282:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(regex) (stub function and group by tag only) (result)
--Testcase 1283:
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(*) (stub function, expose data, explain)
--Testcase 174:
EXPLAIN VERBOSE
SELECT (derivative_all()::s3).* from s3 ORDER BY 1;

-- select derivative(*) (stub function, expose data, result)
--Testcase 175:
SELECT * FROM (
SELECT (derivative_all()::s3).* from s3
) as t ORDER BY 1;

-- select derivative(regex) (stub function, expose data, explain)
--Testcase 176:
EXPLAIN VERBOSE
SELECT (derivative('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select derivative(regex) (stub function, expose data, result)
--Testcase 177:
SELECT * FROM (
SELECT (derivative('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 178:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3 ORDER BY 1;

--Testcase 179:
SELECT * FROM (
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

--Testcase 180:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3 ORDER BY 1;

--Testcase 181:
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, explain)
--Testcase 182:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, result)
--Testcase 183:
SELECT * FROM (
SELECT non_negative_derivative_all() from s3
) as t ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, explain)
--Testcase 184:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, result)
--Testcase 185:
SELECT non_negative_derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1284:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(*) (stub function and group by tag only) (result)
--Testcase 1285:
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1286:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1287:
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, expose data, explain)
--Testcase 186:
EXPLAIN VERBOSE
SELECT (non_negative_derivative_all()::s3).* from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, expose data, result)
--Testcase 187:
SELECT * FROM (
SELECT (non_negative_derivative_all()::s3).* from s3
) as t ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, expose data, explain)
--Testcase 188:
EXPLAIN VERBOSE
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, expose data, result)
--Testcase 189:
SELECT * FROM (
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 190:
EXPLAIN VERBOSE
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3 ORDER BY 1;

--Testcase 191:
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3 ORDER BY 1;

-- select difference(*) (stub function, explain)
--Testcase 192:
EXPLAIN VERBOSE
SELECT difference_all() from s3 ORDER BY 1;

-- select difference(*) (stub function, result)
--Testcase 193:
SELECT * FROM (
SELECT difference_all() from s3
) as t ORDER BY 1;

-- select difference(regex) (stub function, explain)
--Testcase 194:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') from s3 ORDER BY 1;

-- select difference(regex) (stub function, result)
--Testcase 195:
SELECT difference('/value[1,4]/') from s3 ORDER BY 1;

-- select difference(*) (stub function and group by tag only) (explain)
--Testcase 1288:
EXPLAIN VERBOSE
SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(*) (stub function and group by tag only) (result)
--Testcase 1289:
 SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(regex) (stub function and group by tag only) (explain)
--Testcase 1290:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(regex) (stub function and group by tag only) (result)
--Testcase 1291:
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(*) (stub function, expose data, explain)
--Testcase 196:
EXPLAIN VERBOSE
SELECT (difference_all()::s3).* from s3 ORDER BY 1;

-- select difference(*) (stub function, expose data, result)
--Testcase 197:
SELECT * FROM (
SELECT (difference_all()::s3).* from s3
) as t ORDER BY 1;

-- select difference(regex) (stub function, expose data, explain)
--Testcase 198:
EXPLAIN VERBOSE
SELECT (difference('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select difference(regex) (stub function, expose data, result)
--Testcase 199:
SELECT * FROM (
SELECT (difference('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 200:
EXPLAIN VERBOSE
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3 ORDER BY 1;

--Testcase 201:
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, explain)
--Testcase 202:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, result)
--Testcase 203:
SELECT * FROM (
SELECT non_negative_difference_all() from s3
) as t ORDER BY 1;

-- select non_negative_difference(regex) (stub function, explain)
--Testcase 204:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_difference(*), non_negative_difference(regex) (stub function, result)
--Testcase 205:
SELECT non_negative_difference('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function and group by tag only) (explain)
--Testcase 1292:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select non_negative_difference(*) (stub function and group by tag only) (result)
--Testcase 1293:
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select non_negative_difference(regex) (stub function and group by tag only) (explain)
--Testcase 1294:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select non_negative_difference(regex) (stub function and group by tag only) (result)
--Testcase 1295:
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_difference(*) (stub function, expose data, explain)
--Testcase 206:
EXPLAIN VERBOSE
SELECT (non_negative_difference_all()::s3).* from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, expose data, result)
--Testcase 207:
SELECT * FROM (
SELECT (non_negative_difference_all()::s3).* from s3
) as t ORDER BY 1;

-- select non_negative_difference(regex) (stub function, expose data, explain)
--Testcase 208:
EXPLAIN VERBOSE
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select non_negative_difference(regex) (stub function, expose data, result)
--Testcase 209:
SELECT * FROM (
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 210:
EXPLAIN VERBOSE
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3 ORDER BY 1;

--Testcase 211:
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3 ORDER BY 1;

--Testcase 212:
EXPLAIN VERBOSE
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3 ORDER BY 1;

--Testcase 213:
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3 ORDER BY 1;

-- select elapsed(*) (stub function, explain)
--Testcase 214:
EXPLAIN VERBOSE
SELECT elapsed_all() from s3 ORDER BY 1;

-- select elapsed(*) (stub function, result)
--Testcase 215:
SELECT * FROM (
SELECT elapsed_all() from s3
) as t ORDER BY 1;

-- select elapsed(regex) (stub function, explain)
--Testcase 216:
EXPLAIN VERBOSE
SELECT elapsed('/value[1,4]/') from s3 ORDER BY 1;

-- select elapsed(regex) (stub function, result)
--Testcase 217:
SELECT elapsed('/value[1,4]/') from s3 ORDER BY 1;

-- select elapsed(*) (stub function and group by tag only) (explain)
--Testcase 1296:
EXPLAIN VERBOSE
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select elapsed(*) (stub function and group by tag only) (result)
--Testcase 1297:
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select elapsed(regex) (stub function and group by tag only) (explain)
--Testcase 1298:
EXPLAIN VERBOSE
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;
-- select elapsed(regex) (stub function and group by tag only) (result)
--Testcase 1299:
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select elapsed(*) (stub function, expose data, explain)
--Testcase 218:
EXPLAIN VERBOSE
SELECT (elapsed_all()::s3).* from s3 ORDER BY 1;

-- select elapsed(*) (stub function, expose data, result)
--Testcase 219:
SELECT * FROM (
SELECT (elapsed_all()::s3).* from s3
) as t ORDER BY 1;

-- select elapsed(regex) (stub function, expose data, explain)
--Testcase 220:
EXPLAIN VERBOSE
SELECT (elapsed('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select elapsed(regex) (stub function, expose data, result)
--Testcase 221:
SELECT * FROM (
SELECT (elapsed('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 222:
EXPLAIN VERBOSE
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 223:
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3 ORDER BY 1;

-- select moving_average(*) (stub function, explain)
--Testcase 224:
EXPLAIN VERBOSE
SELECT moving_average_all(2) from s3 ORDER BY 1;

-- select moving_average(*) (stub function, result)
--Testcase 225:
SELECT * FROM (
SELECT moving_average_all(2) from s3
) as t ORDER BY 1;

-- select moving_average(regex) (stub function, explain)
--Testcase 226:
EXPLAIN VERBOSE
SELECT moving_average('/value[1,4]/', 2) from s3 ORDER BY 1;

-- select moving_average(regex) (stub function, result)
--Testcase 227:
SELECT moving_average('/value[1,4]/', 2) from s3 ORDER BY 1;

-- select moving_average(*) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1300:
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(*) (stub function and group by tag only) (result)
--Testcase 1301:
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1302:
EXPLAIN VERBOSE
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1303:
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(*) (stub function, expose data, explain)
--Testcase 228:
EXPLAIN VERBOSE
SELECT (moving_average_all(2)::s3).* from s3 ORDER BY 1;

-- select moving_average(*) (stub function, expose data, result)
--Testcase 229:
SELECT * FROM (
SELECT (moving_average_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select moving_average(regex) (stub function, expose data, explain)
--Testcase 230:
EXPLAIN VERBOSE
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3 ORDER BY 1;

-- select moving_average(regex) (stub function, expose data, result)
--Testcase 231:
SELECT * FROM (
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 232:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3 ORDER BY 1;

--Testcase 233:
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3 ORDER BY 1;

--Testcase 234:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 235:
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, explain)
--Testcase 236:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, result)
--Testcase 237:
SELECT * FROM (
SELECT chande_momentum_oscillator_all(2) from s3
) as t ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, explain)
--Testcase 238:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, result)
--Testcase 239:
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (explain)
--Testcase 1304:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (result)
--Testcase 1305:
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (explain)
--Testcase 1306:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (result)
--Testcase 1307:
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, expose data, explain)
--Testcase 240:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, expose data, result)
--Testcase 241:
SELECT * FROM (
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, expose data, explain)
--Testcase 242:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, expose data, result)
--Testcase 243:
SELECT * FROM (
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 244:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 245:
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 246:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 247:
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function, explain)
--Testcase 248:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function, result)
--Testcase 249:
SELECT * FROM (
SELECT exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select exponential_moving_average(regex) (stub function, explain)
--Testcase 250:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function, result)
--Testcase 251:
SELECT exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1308:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1309:
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1310:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1311:
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 252:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 253:
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 254:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 255:
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function, explain)
--Testcase 256:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function, result)
--Testcase 257:
SELECT * FROM (
SELECT double_exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function, explain)
--Testcase 258:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function, result)
--Testcase 259:
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1312:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1313:
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1314:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1315:
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 260:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3 ORDER BY 1;

--Testcase 261:
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3 ORDER BY 1;

--Testcase 262:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 263:
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, explain)
--Testcase 264:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, result)
--Testcase 265:
SELECT * FROM (
SELECT kaufmans_efficiency_ratio_all(2) from s3
) as t ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, explain)
--Testcase 266:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, result)
--Testcase 267:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (explain)
--Testcase 1316:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (result)
--Testcase 1317:
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (explain)
--Testcase 1318:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (result)
--Testcase 1319:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, explain)
--Testcase 268:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, result)
--Testcase 269:
SELECT * FROM (
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, explain)
--Testcase 270:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, result)
--Testcase 271:
SELECT * FROM (
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 272:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 273:
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 274:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 275:
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function, explain)
--Testcase 276:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function, result)
--Testcase 277:
SELECT * FROM (
SELECT kaufmans_adaptive_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function, explain)
--Testcase 278:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function, result)
--Testcase 279:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1320:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1321:
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1322:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1323:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 280:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 281:
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 282:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 283:
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function, explain)
--Testcase 284:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function, result)
--Testcase 285:
SELECT * FROM (
SELECT triple_exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function, explain)
--Testcase 286:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function, result)
--Testcase 287:
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1324:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1325:
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1326:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1327:
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 288:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3 ORDER BY 1;

--Testcase 289:
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3 ORDER BY 1;

--Testcase 290:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 291:
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function, explain)
--Testcase 292:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function, result)
--Testcase 293:
SELECT * FROM (
SELECT triple_exponential_derivative_all(2) from s3
) as t ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function, explain)
--Testcase 294:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function, result)
--Testcase 295:
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1328:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (result)
--Testcase 1329:
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1330:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1331:
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 296:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3 ORDER BY 1;

--Testcase 297:
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3 ORDER BY 1;

--Testcase 298:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 299:
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, explain)
--Testcase 300:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, result)
--Testcase 301:
SELECT * FROM (
SELECT relative_strength_index_all(2) from s3
) as t ORDER BY 1;

-- select relative_strength_index(regex) (stub function, explain)
--Testcase 302:
EXPLAIN VERBOSE
SELECT relative_strength_index('/value[1,4]/',2) from s3 ORDER BY 1;

-- select relative_strength_index(regex) (stub function, result)
--Testcase 303:
SELECT relative_strength_index('/value[1,4]/',2) from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function and group by tag only) (explain)
--Testcase 1332:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(*) (stub function and group by tag only) (result)
--Testcase 1333:
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(regex) (stub function and group by tag only) (explain)
--Testcase 1334:
EXPLAIN VERBOSE
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(regex) (stub function and group by tag only) (result)
--Testcase 1335:
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(*) (stub function, expose data, explain)
--Testcase 304:
EXPLAIN VERBOSE
SELECT (relative_strength_index_all(2)::s3).* from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, expose data, result)
--Testcase 305:
SELECT * FROM (
SELECT (relative_strength_index_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select relative_strength_index(regex) (stub function, expose data, explain)
--Testcase 306:
EXPLAIN VERBOSE
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select relative_strength_index(regex) (stub function, expose data, result)
--Testcase 307:
SELECT * FROM (
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

-- select integral (stub agg function, explain)
--Testcase 308:
EXPLAIN VERBOSE
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3 ORDER BY 1;

-- select integral (stub agg function, result)
--Testcase 309:
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3 ORDER BY 1;

--Testcase 310:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3 ORDER BY 1;

-- select integral (stub agg function, result)
--Testcase 311:
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3 ORDER BY 1;

-- select integral (stub agg function, raise exception if not expected type)
--Testcase 312:
--SELECT integral(value1::numeric),integral(value2::numeric),integral(value3::numeric),integral(value4::numeric) FROM s3 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 313:
EXPLAIN VERBOSE
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 314:
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 315:
EXPLAIN VERBOSE
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 316:
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 317:
SELECT tag1,integral("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select integral (stub agg function and other aggs) (result)
--Testcase 318:
SELECT sum("value1"),integral("value1"),count("value1") FROM s3 ORDER BY 1;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 319:
SELECT tag1,integral("value1", interval '1s') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select integral (stub agg function and other aggs) (result)
--Testcase 320:
SELECT sum("value1"),integral("value1", interval '1s'),count("value1") FROM s3 ORDER BY 1;

-- select integral over join query (explain)
--Testcase 321:
EXPLAIN VERBOSE
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (result, stub call error)
--Testcase 322:
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (explain)
--Testcase 323:
EXPLAIN VERBOSE
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (result, stub call error)
--Testcase 324:
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral with having (explain)
--Testcase 325:
EXPLAIN VERBOSE
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100 ORDER BY 1;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 326:
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100 ORDER BY 1;

-- select integral with having (explain)
--Testcase 327:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100 ORDER BY 1;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 328:
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100 ORDER BY 1;

-- select integral(*) (stub agg function, explain)
--Testcase 329:
EXPLAIN VERBOSE
SELECT integral_all(*) from s3 ORDER BY 1;

-- select integral(*) (stub agg function, result)
--Testcase 330:
SELECT integral_all(*) from s3 ORDER BY 1;

-- select integral(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 331:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 332:
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by tag only) (explain)
--Testcase 333:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by tag only) (result)
--Testcase 334:
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(*) (stub agg function, expose data, explain)
--Testcase 335:
EXPLAIN VERBOSE
SELECT (integral_all(*)::s3).* from s3 ORDER BY 1;

-- select integral(*) (stub agg function, expose data, result)
--Testcase 336:
SELECT (integral_all(*)::s3).* from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, explain)
--Testcase 337:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, result)
--Testcase 338:
SELECT integral('/value[1,4]/') from s3 ORDER BY 1;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 339:
EXPLAIN VERBOSE
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 340:
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by tag only) (explain)
--Testcase 341:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by tag only) (result)
--Testcase 342:
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(regex) (stub agg function, expose data, explain)
--Testcase 343:
EXPLAIN VERBOSE
SELECT (integral('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, expose data, result)
--Testcase 344:
SELECT (integral('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select mean (stub agg function, explain)
--Testcase 345:
EXPLAIN VERBOSE
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3 ORDER BY 1;

-- select mean (stub agg function, result)
--Testcase 346:
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3 ORDER BY 1;

-- select mean (stub agg function, raise exception if not expected type)
--Testcase 347:
--SELECT mean(value1::numeric),mean(value2::numeric),mean(value3::numeric),mean(value4::numeric) FROM s3 ORDER BY 1;

-- select mean (stub agg function and group by influx_time() and tag) (explain)
--Testcase 348:
EXPLAIN VERBOSE
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean (stub agg function and group by influx_time() and tag) (result)
--Testcase 349:
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean (stub agg function and group by tag only) (result)
--Testcase 350:
SELECT tag1,mean("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean (stub agg function and other aggs) (result)
--Testcase 351:
SELECT sum("value1"),mean("value1"),count("value1") FROM s3 ORDER BY 1;

-- select mean over join query (explain)
--Testcase 352:
EXPLAIN VERBOSE
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select mean over join query (result, stub call error)
--Testcase 353:
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select mean with having (explain)
--Testcase 354:
EXPLAIN VERBOSE
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100 ORDER BY 1;

-- select mean with having (explain, not pushdown, stub call error)
--Testcase 355:
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100 ORDER BY 1;

-- select mean(*) (stub agg function, explain)
--Testcase 356:
EXPLAIN VERBOSE
SELECT mean_all(*) from s3 ORDER BY 1;

-- select mean(*) (stub agg function, result)
--Testcase 357:
SELECT mean_all(*) from s3 ORDER BY 1;

-- select mean(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 358:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 359:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by tag only) (explain)
--Testcase 360:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by tag only) (result)
--Testcase 361:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(*) (stub agg function, expose data, explain)
--Testcase 362:
EXPLAIN VERBOSE
SELECT (mean_all(*)::s3).* from s3 ORDER BY 1;

-- select mean(*) (stub agg function, expose data, result)
--Testcase 363:
SELECT (mean_all(*)::s3).* from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, explain)
--Testcase 364:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, result)
--Testcase 365:
SELECT mean('/value[1,4]/') from s3 ORDER BY 1;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 366:
EXPLAIN VERBOSE
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 367:
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by tag only) (explain)
--Testcase 368:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by tag only) (result)
--Testcase 369:
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(regex) (stub agg function, expose data, explain)
--Testcase 370:
EXPLAIN VERBOSE
SELECT (mean('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, expose data, result)
--Testcase 371:
SELECT (mean('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select median (stub agg function, explain)
--Testcase 372:
EXPLAIN VERBOSE
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3 ORDER BY 1;

-- select median (stub agg function, result)
--Testcase 373:
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3 ORDER BY 1;

-- select median (stub agg function, raise exception if not expected type)
--Testcase 374:
--SELECT median(value1::numeric),median(value2::numeric),median(value3::numeric),median(value4::numeric) FROM s3 ORDER BY 1;

-- select median (stub agg function and group by influx_time() and tag) (explain)
--Testcase 375:
EXPLAIN VERBOSE
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median (stub agg function and group by influx_time() and tag) (result)
--Testcase 376:
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median (stub agg function and group by tag only) (result)
--Testcase 377:
SELECT tag1,median("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median (stub agg function and other aggs) (result)
--Testcase 378:
SELECT sum("value1"),median("value1"),count("value1") FROM s3 ORDER BY 1;

-- select median over join query (explain)
--Testcase 379:
EXPLAIN VERBOSE
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select median over join query (result, stub call error)
--Testcase 380:
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select median with having (explain)
--Testcase 381:
EXPLAIN VERBOSE
SELECT median(value1) FROM s3 HAVING median(value1) > 100 ORDER BY 1;

-- select median with having (explain, not pushdown, stub call error)
--Testcase 382:
SELECT median(value1) FROM s3 HAVING median(value1) > 100 ORDER BY 1;

-- select median(*) (stub agg function, explain)
--Testcase 383:
EXPLAIN VERBOSE
SELECT median_all(*) from s3 ORDER BY 1;

-- select median(*) (stub agg function, result)
--Testcase 384:
SELECT median_all(*) from s3 ORDER BY 1;

-- select median(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 385:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 386:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by tag only) (explain)
--Testcase 387:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by tag only) (result)
--Testcase 388:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(*) (stub agg function, expose data, explain)
--Testcase 389:
EXPLAIN VERBOSE
SELECT (median_all(*)::s3).* from s3 ORDER BY 1;

-- select median(*) (stub agg function, expose data, result)
--Testcase 390:
SELECT (median_all(*)::s3).* from s3 ORDER BY 1;

-- select median(regex) (stub agg function, explain)
--Testcase 391:
EXPLAIN VERBOSE
SELECT median('/^v.*/') from s3 ORDER BY 1;

-- select median(regex) (stub agg function, result)
--Testcase 392:
SELECT  median('/^v.*/') from s3 ORDER BY 1;

-- select median(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 393:
EXPLAIN VERBOSE
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 394:
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by tag only) (explain)
--Testcase 395:
EXPLAIN VERBOSE
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by tag only) (result)
--Testcase 396:
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(regex) (stub agg function, expose data, explain)
--Testcase 397:
EXPLAIN VERBOSE
SELECT (median('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select median(regex) (stub agg function, expose data, result)
--Testcase 398:
SELECT (median('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_mode (stub agg function, explain)
--Testcase 399:
EXPLAIN VERBOSE
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function, result)
--Testcase 400:
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function, raise exception if not expected type)
--Testcase 401:
--SELECT influx_mode(value1::numeric),influx_mode(value2::numeric),influx_mode(value3::numeric),influx_mode(value4::numeric) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function and group by influx_time() and tag) (explain)
--Testcase 402:
EXPLAIN VERBOSE
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode (stub agg function and group by influx_time() and tag) (result)
--Testcase 403:
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode (stub agg function and group by tag only) (result)
--Testcase 404:
SELECT tag1,influx_mode("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode (stub agg function and other aggs) (result)
--Testcase 405:
SELECT sum("value1"),influx_mode("value1"),count("value1") FROM s3 ORDER BY 1;

-- select influx_mode over join query (explain)
--Testcase 406:
EXPLAIN VERBOSE
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select influx_mode over join query (result, stub call error)
--Testcase 407:
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select influx_mode with having (explain)
--Testcase 408:
EXPLAIN VERBOSE
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100 ORDER BY 1;

-- select influx_mode with having (explain, not pushdown, stub call error)
--Testcase 409:
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100 ORDER BY 1;

-- select influx_mode(*) (stub agg function, explain)
--Testcase 410:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function, result)
--Testcase 411:
SELECT influx_mode_all(*) from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 412:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 413:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by tag only) (explain)
--Testcase 414:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by tag only) (result)
--Testcase 415:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function, expose data, explain)
--Testcase 416:
EXPLAIN VERBOSE
SELECT (influx_mode_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function, expose data, result)
--Testcase 417:
SELECT (influx_mode_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_mode(regex) (stub function, explain)
--Testcase 418:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_mode(regex) (stub function, result)
--Testcase 419:
SELECT influx_mode('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 420:
EXPLAIN VERBOSE
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 421:
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by tag only) (explain)
--Testcase 422:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by tag only) (result)
--Testcase 423:
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function, expose data, explain)
--Testcase 424:
EXPLAIN VERBOSE
SELECT (influx_mode('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_mode(regex) (stub agg function, expose data, result)
--Testcase 425:
SELECT (influx_mode('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select stddev (agg function, explain)
--Testcase 426:
EXPLAIN VERBOSE
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3 ORDER BY 1;

-- select stddev (agg function, result)
--Testcase 427:
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3 ORDER BY 1;

-- select stddev (agg function and group by influx_time() and tag) (explain)
--Testcase 428:
EXPLAIN VERBOSE
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev (agg function and group by influx_time() and tag) (result)
--Testcase 429:
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev (agg function and group by tag only) (result)
--Testcase 430:
SELECT tag1,stddev("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev (agg function and other aggs) (result)
--Testcase 431:
SELECT sum("value1"),stddev("value1"),count("value1") FROM s3 ORDER BY 1;

-- select stddev(*) (stub agg function, explain)
--Testcase 432:
EXPLAIN VERBOSE
SELECT stddev_all(*) from s3 ORDER BY 1;

-- select stddev(*) (stub agg function, result)
--Testcase 433:
SELECT stddev_all(*) from s3 ORDER BY 1;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 434:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 435:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by tag only) (explain)
--Testcase 436:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by tag only) (result)
--Testcase 437:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(regex) (stub function, explain)
--Testcase 438:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') from s3 ORDER BY 1;

-- select stddev(regex) (stub function, result)
--Testcase 439:
SELECT stddev('/value[1,4]/') from s3 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 440:
EXPLAIN VERBOSE
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 441:
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by tag only) (explain)
--Testcase 442:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by tag only) (result)
--Testcase 443:
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function, explain)
--Testcase 444:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function, result)
--Testcase 445:
SELECT influx_sum_all(*) from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 446:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 447:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by tag only) (explain)
--Testcase 448:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by tag only) (result)
--Testcase 449:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function, expose data, explain)
--Testcase 450:
EXPLAIN VERBOSE
SELECT (influx_sum_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function, expose data, result)
--Testcase 451:
SELECT (influx_sum_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_sum(regex) (stub function, explain)
--Testcase 452:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_sum(regex) (stub function, result)
--Testcase 453:
SELECT influx_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 454:
EXPLAIN VERBOSE
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 455:
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by tag only) (explain)
--Testcase 456:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by tag only) (result)
--Testcase 457:
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function, expose data, explain)
--Testcase 458:
EXPLAIN VERBOSE
SELECT (influx_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_sum(regex) (stub agg function, expose data, result)
--Testcase 459:
SELECT (influx_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- selector function bottom() (explain)
--Testcase 460:
EXPLAIN VERBOSE
SELECT bottom(value1, 1) FROM s3 ORDER BY 1;

-- selector function bottom() (result)
--Testcase 461:
SELECT bottom(value1, 1) FROM s3 ORDER BY 1;

-- selector function bottom() cannot be combined with other functions(explain)
--Testcase 462:
EXPLAIN VERBOSE
SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3 ORDER BY 1;

-- selector function bottom() cannot be combined with other functions(result)
--Testcase 463:
SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, explain)
--Testcase 464:
EXPLAIN VERBOSE
SELECT influx_max_all(*) from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, result)
--Testcase 465:
SELECT influx_max_all(*) from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 466:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 467:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by tag only) (explain)
--Testcase 468:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by tag only) (result)
--Testcase 469:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function, expose data, explain)
--Testcase 470:
EXPLAIN VERBOSE
SELECT (influx_max_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, expose data, result)
--Testcase 471:
SELECT (influx_max_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_max(regex) (stub function, explain)
--Testcase 472:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_max(regex) (stub function, result)
--Testcase 473:
SELECT influx_max('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 474:
EXPLAIN VERBOSE
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 475:
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by tag only) (explain)
--Testcase 476:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by tag only) (result)
--Testcase 477:
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function, expose data, explain)
--Testcase 478:
EXPLAIN VERBOSE
SELECT (influx_max('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_max(regex) (stub agg function, expose data, result)
--Testcase 479:
SELECT (influx_max('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, explain)
--Testcase 480:
EXPLAIN VERBOSE
SELECT influx_min_all(*) from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, result)
--Testcase 481:
SELECT influx_min_all(*) from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 482:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 483:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by tag only) (explain)
--Testcase 484:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by tag only) (result)
--Testcase 485:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function, expose data, explain)
--Testcase 486:
EXPLAIN VERBOSE
SELECT (influx_min_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, expose data, result)
--Testcase 487:
SELECT (influx_min_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_min(regex) (stub function, explain)
--Testcase 488:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_min(regex) (stub function, result)
--Testcase 489:
SELECT influx_min('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 490:
EXPLAIN VERBOSE
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 491:
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by tag only) (explain)
--Testcase 492:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by tag only) (result)
--Testcase 493:
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function, expose data, explain)
--Testcase 494:
EXPLAIN VERBOSE
SELECT (influx_min('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_min(regex) (stub agg function, expose data, result)
--Testcase 495:
SELECT (influx_min('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- selector function percentile() (explain)
--Testcase 496:
EXPLAIN VERBOSE
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3 ORDER BY 1;

-- selector function percentile() (result)
--Testcase 497:
SELECT * FROM (
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- selector function percentile() (explain)
--Testcase 498:
EXPLAIN VERBOSE
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3 ORDER BY 3;

-- selector function percentile() (result)
--Testcase 499:
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3 ORDER BY 3;

-- select percentile(*, int) (stub function, explain)
--Testcase 500:
EXPLAIN VERBOSE
SELECT percentile_all(50) from s3 ORDER BY 1;

-- select percentile(*, int) (stub function, result)
--Testcase 501:
SELECT * FROM (
SELECT percentile_all(50) from s3
) as t ORDER BY 1;

-- select percentile(*, float8) (stub function, explain)
--Testcase 502:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) from s3 ORDER BY 1;

-- select percentile(*, float8) (stub function, result)
--Testcase 503:
SELECT percentile_all(70.5) from s3 ORDER BY 1;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (explain)
--Testcase 504:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (result)
--Testcase 505:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (explain)
--Testcase 506:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (result)
--Testcase 507:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by tag only) (explain)
--Testcase 1336:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by tag only) (result)
--Testcase 1337:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1338:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by tag only) (result)
--Testcase 1339:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 508:
EXPLAIN VERBOSE
SELECT (percentile_all(50)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 509:
SELECT * FROM (
SELECT (percentile_all(50)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 510:
EXPLAIN VERBOSE
SELECT (percentile_all(70.5)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 511:
SELECT * FROM (
SELECT (percentile_all(70.5)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- select percentile(regex) (stub function, explain)
--Testcase 512:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select percentile(regex) (stub function, result)
--Testcase 513:
SELECT percentile('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select percentile(regex) (stub function and group by influx_time() and tag) (explain)
--Testcase 514:
EXPLAIN VERBOSE
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by influx_time() and tag) (result)
--Testcase 515:
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by tag only) (explain)
--Testcase 1340:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by tag only) (result)
--Testcase 1341:
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 516:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3 ORDER BY 1, 2, 3;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 517:
SELECT * FROM (
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3
) as t ORDER BY 1, 2, 3;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 518:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3 ORDER BY 1, 2, 3;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 519:
SELECT * FROM (
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3
) as t ORDER BY 1, 2, 3;

-- selector function top(field_key,N) (explain)
--Testcase 520:
EXPLAIN VERBOSE
SELECT top(value1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,N) (result)
--Testcase 521:
SELECT top(value1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,tag_key(s),N) (explain)
--Testcase 522:
EXPLAIN VERBOSE
SELECT top(value1, tag1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,tag_key(s),N) (result)
--Testcase 523:
SELECT top(value1, tag1, 1) FROM s3 ORDER BY 1;

-- selector function top() cannot be combined with other functions(explain)
--Testcase 524:
EXPLAIN VERBOSE
SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3 ORDER BY 1;

-- selector function top() cannot be combined with other functions(result)
--Testcase 525:
SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3 ORDER BY 1;

-- select acos (builtin function, explain)
--Testcase 526:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 ORDER BY 1;

-- select acos (builtin function, result)
--Testcase 527:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 ORDER BY 1;

-- select acos (builtin function, not pushdown constraints, explain)
--Testcase 528:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select acos (builtin function, not pushdown constraints, result)
--Testcase 529:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select acos (builtin function, pushdown constraints, explain)
--Testcase 530:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select acos (builtin function, pushdown constraints, result)
--Testcase 531:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select acos as nest function with (pushdown, explain)
--Testcase 532:
EXPLAIN VERBOSE
SELECT sum(value3),acos(sum(value3)) FROM s3 ORDER BY 1;

-- select acos as nest function with (pushdown, result)
--Testcase 533:
SELECT sum(value3),acos(sum(value3)) FROM s3 ORDER BY 1;

-- select acos as nest with log2 (pushdown, explain)
--Testcase 534:
EXPLAIN VERBOSE
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select acos as nest with log2 (pushdown, result)
--Testcase 535:
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select acos with non pushdown func and explicit constant (explain)
--Testcase 536:
EXPLAIN VERBOSE
SELECT acos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select acos with non pushdown func and explicit constant (result)
--Testcase 537:
SELECT * FROM (
SELECT acos(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select acos with order by (explain)
--Testcase 538:
EXPLAIN VERBOSE
SELECT value1, acos(1-value1) FROM s3 ORDER BY acos(1-value1);

-- select acos with order by (result)
--Testcase 539:
SELECT value1, acos(1-value1) FROM s3 ORDER BY acos(1-value1);

-- select acos with order by index (result)
--Testcase 540:
SELECT value1, acos(1-value1) FROM s3 ORDER BY 2,1;

-- select acos with order by index (result)
--Testcase 541:
SELECT value1, acos(1-value1) FROM s3 ORDER BY 1,2;

-- select acos and as
--Testcase 542:
SELECT acos(value3) as acos1 FROM s3 ORDER BY 1;

-- select acos(*) (stub function, explain)
--Testcase 543:
EXPLAIN VERBOSE
SELECT acos_all() from s3 ORDER BY 1;

-- select acos(*) (stub function, result)
--Testcase 544:
SELECT * FROM (
SELECT acos_all() from s3
) as t ORDER BY 1;

-- select acos(*) (stub function and group by tag only) (explain)
--Testcase 1342:
EXPLAIN VERBOSE
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select acos(*) (stub function and group by tag only) (result)
--Testcase 1343:
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select acos(*) (stub function, expose data, explain)
--Testcase 545:
EXPLAIN VERBOSE
SELECT (acos_all()::s3).* from s3 ORDER BY 1;

-- select acos(*) (stub function, expose data, result)
--Testcase 546:
SELECT * FROM (
SELECT (acos_all()::s3).* from s3
) as t ORDER BY 1;

-- select asin (builtin function, explain)
--Testcase 547:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 ORDER BY 1;

-- select asin (builtin function, result)
--Testcase 548:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 ORDER BY 1;

-- select asin (builtin function, not pushdown constraints, explain)
--Testcase 549:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select asin (builtin function, not pushdown constraints, result)
--Testcase 550:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select asin (builtin function, pushdown constraints, explain)
--Testcase 551:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select asin (builtin function, pushdown constraints, result)
--Testcase 552:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select asin as nest function with (pushdown, explain)
--Testcase 553:
EXPLAIN VERBOSE
SELECT sum(value3),asin(sum(value3)) FROM s3 ORDER BY 1;

-- select asin as nest function with (pushdown, result)
--Testcase 554:
SELECT sum(value3),asin(sum(value3)) FROM s3 ORDER BY 1;

-- select asin as nest with log2 (pushdown, explain)
--Testcase 555:
EXPLAIN VERBOSE
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select asin as nest with log2 (pushdown, result)
--Testcase 556:
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select asin with non pushdown func and explicit constant (explain)
--Testcase 557:
EXPLAIN VERBOSE
SELECT asin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select asin with non pushdown func and explicit constant (result)
--Testcase 558:
SELECT asin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select asin with order by (explain)
--Testcase 559:
EXPLAIN VERBOSE
SELECT value1, asin(1-value1) FROM s3 ORDER BY asin(1-value1);

-- select asin with order by (result)
--Testcase 560:
SELECT value1, asin(1-value1) FROM s3 ORDER BY asin(1-value1);

-- select asin with order by index (result)
--Testcase 561:
SELECT value1, asin(1-value1) FROM s3 ORDER BY 2,1;

-- select asin with order by index (result)
--Testcase 562:
SELECT value1, asin(1-value1) FROM s3 ORDER BY 1,2;

-- select asin and as
--Testcase 563:
SELECT asin(value3) as asin1 FROM s3 ORDER BY 1;

-- select asin(*) (stub function, explain)
--Testcase 564:
EXPLAIN VERBOSE
SELECT asin_all() from s3 ORDER BY 1;

-- select asin(*) (stub function, result)
--Testcase 565:
SELECT * FROM (
SELECT asin_all() from s3
) as t ORDER BY 1;

-- select asin(*) (stub function and group by tag only) (explain)
--Testcase 1344:
EXPLAIN VERBOSE
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select asin(*) (stub function and group by tag only) (result)
--Testcase 1345:
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select asin(*) (stub function, expose data, explain)
--Testcase 566:
EXPLAIN VERBOSE
SELECT (asin_all()::s3).* from s3 ORDER BY 1;

-- select asin(*) (stub function, expose data, result)
--Testcase 567:
SELECT * FROM (
SELECT (asin_all()::s3).* from s3
) as t ORDER BY 1;

-- select atan (builtin function, explain)
--Testcase 568:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 ORDER BY 1;

-- select atan (builtin function, result)
--Testcase 569:
SELECT * FROM (
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3
) as t ORDER BY 1;

-- select atan (builtin function, not pushdown constraints, explain)
--Testcase 570:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan (builtin function, not pushdown constraints, result)
--Testcase 571:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan (builtin function, pushdown constraints, explain)
--Testcase 572:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan (builtin function, pushdown constraints, result)
--Testcase 573:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan as nest function with agg (pushdown, explain)
--Testcase 574:
EXPLAIN VERBOSE
SELECT sum(value3),atan(sum(value3)) FROM s3 ORDER BY 1;

-- select atan as nest function with agg (pushdown, result)
--Testcase 575:
SELECT sum(value3),atan(sum(value3)) FROM s3 ORDER BY 1;

-- select atan as nest with log2 (pushdown, explain)
--Testcase 576:
EXPLAIN VERBOSE
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan as nest with log2 (pushdown, result)
--Testcase 577:
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan with non pushdown func and explicit constant (explain)
--Testcase 578:
EXPLAIN VERBOSE
SELECT atan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan with non pushdown func and explicit constant (result)
--Testcase 579:
SELECT atan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan with order by (explain)
--Testcase 580:
EXPLAIN VERBOSE
SELECT value1, atan(1-value1) FROM s3 ORDER BY atan(1-value1);

-- select atan with order by (result)
--Testcase 581:
SELECT value1, atan(1-value1) FROM s3 ORDER BY atan(1-value1);

-- select atan with order by index (result)
--Testcase 582:
SELECT value1, atan(1-value1) FROM s3 ORDER BY 2,1;

-- select atan with order by index (result)
--Testcase 583:
SELECT value1, atan(1-value1) FROM s3 ORDER BY 1,2;

-- select atan and as
--Testcase 584:
SELECT * FROM (
SELECT atan(value3) as atan1 FROM s3
) as t ORDER BY 1;

-- select atan(*) (stub function, explain)
--Testcase 585:
EXPLAIN VERBOSE
SELECT atan_all() from s3 ORDER BY 1;

-- select atan(*) (stub function, result)
--Testcase 586:
SELECT * FROM (
SELECT atan_all() from s3
) as t ORDER BY 1;

-- select atan(*) (stub function and group by tag only) (explain)
--Testcase 1346:
EXPLAIN VERBOSE
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select atan(*) (stub function and group by tag only) (result)
--Testcase 1347:
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select atan(*) (stub function, expose data, explain)
--Testcase 587:
EXPLAIN VERBOSE
SELECT (atan_all()::s3).* from s3 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 588:
SELECT asin_all(), acos_all(), atan_all() FROM s3 ORDER BY 1;

-- select atan2 (builtin function, explain)
--Testcase 589:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 ORDER BY 1;

-- select atan2 (builtin function, result)
--Testcase 590:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 ORDER BY 1;

-- select atan2 (builtin function, not pushdown constraints, explain)
--Testcase 591:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan2 (builtin function, not pushdown constraints, result)
--Testcase 592:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan2 (builtin function, pushdown constraints, explain)
--Testcase 593:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan2 (builtin function, pushdown constraints, result)
--Testcase 594:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan2 as nest function with agg (pushdown, explain)
--Testcase 595:
EXPLAIN VERBOSE
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3 ORDER BY 1;

-- select atan2 as nest function with agg (pushdown, result)
--Testcase 596:
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3 ORDER BY 1;

-- select atan2 as nest with log2 (pushdown, explain)
--Testcase 597:
EXPLAIN VERBOSE
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan2 as nest with log2 (pushdown, result)
--Testcase 598:
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan2 with non pushdown func and explicit constant (explain)
--Testcase 599:
EXPLAIN VERBOSE
SELECT atan2(value3, value4), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan2 with non pushdown func and explicit constant (result)
--Testcase 600:
SELECT atan2(value3, value4), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan2 with order by (explain)
--Testcase 601:
EXPLAIN VERBOSE
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY atan2(1-value1, 1-value2);

-- select atan2 with order by (result)
--Testcase 602:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY atan2(1-value1, 1-value2);

-- select atan2 with order by index (result)
--Testcase 603:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY 2,1;

-- select atan2 with order by index (result)
--Testcase 604:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY 1,2;

-- select atan2 and as
--Testcase 605:
SELECT atan2(value3, value4) as atan21 FROM s3 ORDER BY 1;

-- select atan2(*) (stub function, explain)
--Testcase 606:
EXPLAIN VERBOSE
SELECT atan2_all(value1) from s3 ORDER BY 1;

-- select atan2(*) (stub function, result)
--Testcase 607:
SELECT * FROM (
SELECT atan2_all(value1) from s3
) as t ORDER BY 1;

-- select ceil (builtin function, explain)
--Testcase 608:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 ORDER BY 1;

-- select ceil (builtin function, result)
--Testcase 609:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 ORDER BY 1;

-- select ceil (builtin function, not pushdown constraints, explain)
--Testcase 610:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ceil (builtin function, not pushdown constraints, result)
--Testcase 611:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ceil (builtin function, pushdown constraints, explain)
--Testcase 612:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ceil (builtin function, pushdown constraints, result)
--Testcase 613:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ceil as nest function with agg (pushdown, explain)
--Testcase 614:
EXPLAIN VERBOSE
SELECT sum(value3),ceil(sum(value3)) FROM s3 ORDER BY 1;

-- select ceil as nest function with agg (pushdown, result)
--Testcase 615:
SELECT sum(value3),ceil(sum(value3)) FROM s3 ORDER BY 1;

-- select ceil as nest with log2 (pushdown, explain)
--Testcase 616:
EXPLAIN VERBOSE
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ceil as nest with log2 (pushdown, result)
--Testcase 617:
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ceil with non pushdown func and explicit constant (explain)
--Testcase 618:
EXPLAIN VERBOSE
SELECT ceil(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ceil with non pushdown func and explicit constant (result)
--Testcase 619:
SELECT * FROM (
SELECT ceil(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select ceil with order by (explain)
--Testcase 620:
EXPLAIN VERBOSE
SELECT value1, ceil(1-value1) FROM s3 ORDER BY ceil(1-value1);

-- select ceil with order by (result)
--Testcase 621:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY ceil(1-value1);

-- select ceil with order by index (result)
--Testcase 622:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY 2,1;

-- select ceil with order by index (result)
--Testcase 623:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY 1,2;

-- select ceil and as
--Testcase 624:
SELECT * FROM (
SELECT ceil(value3) as ceil1 FROM s3
) as t ORDER BY 1;

-- select ceil(*) (stub function, explain)
--Testcase 625:
EXPLAIN VERBOSE
SELECT ceil_all() from s3 ORDER BY 1;

-- select ceil(*) (stub function, result)
--Testcase 626:
SELECT * FROM (
SELECT ceil_all() from s3
) as t ORDER BY 1;

-- select ceil(*) (stub function and group by tag only) (explain)
--Testcase 1348:
EXPLAIN VERBOSE
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ceil(*) (stub function and group by tag only) (result)
--Testcase 1349:
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ceil(*) (stub function, expose data, explain)
--Testcase 627:
EXPLAIN VERBOSE
SELECT (ceil_all()::s3).* from s3 ORDER BY 1;

-- select ceil(*) (stub function, expose data, result)
--Testcase 628:
SELECT * FROM (
SELECT (ceil_all()::s3).* from s3
) as t ORDER BY 1;

-- select cos (builtin function, explain)
--Testcase 629:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 ORDER BY 1;

-- select cos (builtin function, result)
--Testcase 630:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 ORDER BY 1;

-- select cos (builtin function, not pushdown constraints, explain)
--Testcase 631:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select cos (builtin function, not pushdown constraints, result)
--Testcase 632:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select cos (builtin function, pushdown constraints, explain)
--Testcase 633:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select cos (builtin function, pushdown constraints, result)
--Testcase 634:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select cos as nest function with agg (pushdown, explain)
--Testcase 635:
EXPLAIN VERBOSE
SELECT sum(value3),cos(sum(value3)) FROM s3 ORDER BY 1;

-- select cos as nest function with agg (pushdown, result)
--Testcase 636:
SELECT sum(value3),cos(sum(value3)) FROM s3 ORDER BY 1;

-- select cos as nest with log2 (pushdown, explain)
--Testcase 637:
EXPLAIN VERBOSE
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select cos as nest with log2 (pushdown, result)
--Testcase 638:
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select cos with non pushdown func and explicit constant (explain)
--Testcase 639:
EXPLAIN VERBOSE
SELECT cos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select cos with non pushdown func and explicit constant (result)
--Testcase 640:
SELECT cos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select cos with order by (explain)
--Testcase 641:
EXPLAIN VERBOSE
SELECT value1, cos(1-value1) FROM s3 ORDER BY cos(1-value1);

-- select cos with order by (result)
--Testcase 642:
SELECT value1, cos(1-value1) FROM s3 ORDER BY cos(1-value1);

-- select cos with order by index (result)
--Testcase 643:
SELECT value1, cos(1-value1) FROM s3 ORDER BY 2,1;

-- select cos with order by index (result)
--Testcase 644:
SELECT value1, cos(1-value1) FROM s3 ORDER BY 1,2;

-- select cos and as
--Testcase 645:
SELECT cos(value3) as cos1 FROM s3 ORDER BY 1;

-- select cos(*) (stub function, explain)
--Testcase 646:
EXPLAIN VERBOSE
SELECT cos_all() from s3 ORDER BY 1;

-- select cos(*) (stub function, result)
--Testcase 647:
SELECT * FROM (
SELECT cos_all() from s3
) as t ORDER BY 1;

-- select cos(*) (stub function and group by tag only) (explain)
--Testcase 1350:
EXPLAIN VERBOSE
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cos(*) (stub function and group by tag only) (result)
--Testcase 1351:
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exp (builtin function, explain)
--Testcase 648:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 ORDER BY 1;

-- select exp (builtin function, result)
--Testcase 649:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 ORDER BY 1;

-- select exp (builtin function, not pushdown constraints, explain)
--Testcase 650:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select exp (builtin function, not pushdown constraints, result)
--Testcase 651:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select exp (builtin function, pushdown constraints, explain)
--Testcase 652:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select exp (builtin function, pushdown constraints, result)
--Testcase 653:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select exp as nest function with agg (pushdown, explain)
--Testcase 654:
EXPLAIN VERBOSE
SELECT sum(value3),exp(sum(value3)) FROM s3 ORDER BY 1;

-- select exp as nest function with agg (pushdown, result)
--Testcase 655:
SELECT sum(value3),exp(sum(value3)) FROM s3 ORDER BY 1;

-- select exp as nest with log2 (pushdown, explain)
--Testcase 656:
EXPLAIN VERBOSE
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3 ORDER BY 1;

-- select exp as nest with log2 (pushdown, result)
--Testcase 657:
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3 ORDER BY 1;

-- select exp with non pushdown func and explicit constant (explain)
--Testcase 658:
EXPLAIN VERBOSE
SELECT exp(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select exp with non pushdown func and explicit constant (result)
--Testcase 659:
SELECT exp(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select exp with order by (explain)
--Testcase 660:
EXPLAIN VERBOSE
SELECT value1, exp(1-value1) FROM s3 ORDER BY exp(1-value1);

-- select exp with order by (result)
--Testcase 661:
SELECT value1, exp(1-value1) FROM s3 ORDER BY exp(1-value1);

-- select exp with order by index (result)
--Testcase 662:
SELECT value1, exp(1-value1) FROM s3 ORDER BY 2,1;

-- select exp with order by index (result)
--Testcase 663:
SELECT value1, exp(1-value1) FROM s3 ORDER BY 1,2;

-- select exp and as
--Testcase 664:
SELECT exp(value3) as exp1 FROM s3 ORDER BY 1;

-- select exp(*) (stub function, explain)
--Testcase 665:
EXPLAIN VERBOSE
SELECT exp_all() from s3 ORDER BY 1;

-- select exp(*) (stub function, result)
--Testcase 666:
SELECT * FROM (
SELECT exp_all() from s3
) as t ORDER BY 1;

-- select exp(*) (stub function and group by tag only) (explain)
--Testcase 1352:
EXPLAIN VERBOSE
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exp(*) (stub function and group by tag only) (result)
--Testcase 1353:
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 667:
SELECT ceil_all(), cos_all(), exp_all() FROM s3 ORDER BY 1;

-- select floor (builtin function, explain)
--Testcase 668:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 ORDER BY 1;

-- select floor (builtin function, result)
--Testcase 669:
SELECT * FROM (
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select floor (builtin function, not pushdown constraints, explain)
--Testcase 670:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select floor (builtin function, not pushdown constraints, result)
--Testcase 671:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select floor (builtin function, pushdown constraints, explain)
--Testcase 672:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select floor (builtin function, pushdown constraints, result)
--Testcase 673:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select floor as nest function with agg (pushdown, explain)
--Testcase 674:
EXPLAIN VERBOSE
SELECT sum(value3),floor(sum(value3)) FROM s3 ORDER BY 1;

-- select floor as nest function with agg (pushdown, result)
--Testcase 675:
SELECT sum(value3),floor(sum(value3)) FROM s3 ORDER BY 1;

-- select floor as nest with log2 (pushdown, explain)
--Testcase 676:
EXPLAIN VERBOSE
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3 ORDER BY 1;

-- select floor as nest with log2 (pushdown, result)
--Testcase 677:
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3 ORDER BY 1;

-- select floor with non pushdown func and explicit constant (explain)
--Testcase 678:
EXPLAIN VERBOSE
SELECT floor(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select floor with non pushdown func and explicit constant (result)
--Testcase 679:
SELECT * FROM (
SELECT floor(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select floor with order by (explain)
--Testcase 680:
EXPLAIN VERBOSE
SELECT value1, floor(1-value1) FROM s3 ORDER BY floor(1-value1);

-- select floor with order by (result)
--Testcase 681:
SELECT value1, floor(1-value1) FROM s3 ORDER BY floor(1-value1);

-- select floor with order by index (result)
--Testcase 682:
SELECT value1, floor(1-value1) FROM s3 ORDER BY 2,1;

-- select floor with order by index (result)
--Testcase 683:
SELECT value1, floor(1-value1) FROM s3 ORDER BY 1,2;

-- select floor and as
--Testcase 684:
SELECT floor(value3) as floor1 FROM s3 ORDER BY 1;

-- select floor(*) (stub function, explain)
--Testcase 685:
EXPLAIN VERBOSE
SELECT floor_all() from s3 ORDER BY 1;

-- select floor(*) (stub function, result)
--Testcase 686:
SELECT * FROM (
SELECT floor_all() from s3
) as t ORDER BY 1;

-- select floor(*) (stub function and group by tag only) (explain)
--Testcase 1354:
EXPLAIN VERBOSE
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select floor(*) (stub function and group by tag only) (result)
--Testcase 1355:
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select floor(*) (stub function, expose data, explain)
--Testcase 687:
EXPLAIN VERBOSE
SELECT (floor_all()::s3).* from s3 ORDER BY 1;

-- select floor(*) (stub function, expose data, result)
--Testcase 688:
SELECT * FROM (
SELECT (floor_all()::s3).* from s3
) as t ORDER BY 1;

-- select ln (builtin function, explain)
--Testcase 689:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 ORDER BY 1;

-- select ln (builtin function, result)
--Testcase 690:
SELECT * FROM (
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select ln (builtin function, not pushdown constraints, explain)
--Testcase 691:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ln (builtin function, not pushdown constraints, result)
--Testcase 692:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ln (builtin function, pushdown constraints, explain)
--Testcase 693:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ln (builtin function, pushdown constraints, result)
--Testcase 694:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ln as nest function with agg (pushdown, explain)
--Testcase 695:
EXPLAIN VERBOSE
SELECT sum(value3),ln(sum(value3)) FROM s3 ORDER BY 1;

-- select ln as nest function with agg (pushdown, result)
--Testcase 696:
SELECT sum(value3),ln(sum(value3)) FROM s3 ORDER BY 1;

-- select ln as nest with log2 (pushdown, explain)
--Testcase 697:
EXPLAIN VERBOSE
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ln as nest with log2 (pushdown, result)
--Testcase 698:
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ln with non pushdown func and explicit constant (explain)
--Testcase 699:
EXPLAIN VERBOSE
SELECT ln(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ln with non pushdown func and explicit constant (result)
--Testcase 700:
SELECT ln(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ln with order by (explain)
--Testcase 701:
EXPLAIN VERBOSE
SELECT value1, ln(1-value1) FROM s3 ORDER BY ln(1-value1);

-- select ln with order by (result)
--Testcase 702:
SELECT value1, ln(1-value1) FROM s3 ORDER BY ln(1-value1);

-- select ln with order by index (result)
--Testcase 703:
SELECT value1, ln(1-value1) FROM s3 ORDER BY 2,1;

-- select ln with order by index (result)
--Testcase 704:
SELECT value1, ln(1-value1) FROM s3 ORDER BY 1,2;

-- select ln and as
--Testcase 705:
SELECT ln(value1) as ln1 FROM s3 ORDER BY 1;

-- select ln(*) (stub function, explain)
--Testcase 706:
EXPLAIN VERBOSE
SELECT ln_all() from s3 ORDER BY 1;

-- select ln(*) (stub function, result)
--Testcase 707:
SELECT * FROM (
SELECT ln_all() from s3
) as t ORDER BY 1;

-- select ln(*) (stub function and group by tag only) (explain)
--Testcase 1356:
EXPLAIN VERBOSE
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ln(*) (stub function and group by tag only) (result)
--Testcase 1357:
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 708:
SELECT ln_all(), floor_all() FROM s3 ORDER BY 1;

-- select pow (builtin function, explain)
--Testcase 709:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 ORDER BY 1;

-- select pow (builtin function, result)
--Testcase 710:
SELECT * FROM (
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select pow (builtin function, not pushdown constraints, explain)
--Testcase 711:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select pow (builtin function, not pushdown constraints, result)
--Testcase 712:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select pow (builtin function, pushdown constraints, explain)
--Testcase 713:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select pow (builtin function, pushdown constraints, result)
--Testcase 714:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select pow as nest function with agg (pushdown, explain)
--Testcase 715:
EXPLAIN VERBOSE
SELECT sum(value3),pow(sum(value3), 2) FROM s3 ORDER BY 1;

-- select pow as nest function with agg (pushdown, result)
--Testcase 716:
SELECT sum(value3),pow(sum(value3), 2) FROM s3 ORDER BY 1;

-- select pow as nest with log2 (pushdown, explain)
--Testcase 717:
EXPLAIN VERBOSE
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3 ORDER BY 1;

-- select pow as nest with log2 (pushdown, result)
--Testcase 718:
SELECT * FROM (
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3
) as t ORDER BY 1;

-- select pow with non pushdown func and explicit constant (explain)
--Testcase 719:
EXPLAIN VERBOSE
SELECT pow(value3, 2), pi(), 4.1 FROM s3 ORDER BY 1;

-- select pow with non pushdown func and explicit constant (result)
--Testcase 720:
SELECT pow(value3, 2), pi(), 4.1 FROM s3 ORDER BY 1;

-- select pow with order by (explain)
--Testcase 721:
EXPLAIN VERBOSE
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY pow(1-value1, 2);

-- select pow with order by (result)
--Testcase 722:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY pow(1-value1, 2);

-- select pow with order by index (result)
--Testcase 723:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY 2,1;

-- select pow with order by index (result)
--Testcase 724:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY 1,2;

-- select pow and as
--Testcase 725:
SELECT * FROM (
SELECT pow(value3, 2) as pow1 FROM s3
) as t ORDER BY 1;

-- select pow_all(2) (stub function, explain)
--Testcase 726:
EXPLAIN VERBOSE
SELECT pow_all(2) from s3 ORDER BY 1;

-- select pow_all(2) (stub function, result)
--Testcase 727:
SELECT * FROM (
SELECT pow_all(2) from s3
) as t ORDER BY 1;

-- select pow_all(2) (stub function and group by tag only) (explain)
--Testcase 1358:
EXPLAIN VERBOSE
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select pow_all(2) (stub function and group by tag only) (result)
--Testcase 1359:
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select pow_all(2) (stub function, expose data, explain)
--Testcase 728:
EXPLAIN VERBOSE
SELECT (pow_all(2)::s3).* from s3 ORDER BY 1;

-- select pow_all(2) (stub function, expose data, result)
--Testcase 729:
SELECT * FROM (
SELECT (pow_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select round (builtin function, explain)
--Testcase 730:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 ORDER BY 1;

-- select round (builtin function, result)
--Testcase 731:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 ORDER BY 1;

-- select round (builtin function, not pushdown constraints, explain)
--Testcase 732:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select round (builtin function, not pushdown constraints, result)
--Testcase 733:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select round (builtin function, pushdown constraints, explain)
--Testcase 734:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select round (builtin function, pushdown constraints, result)
--Testcase 735:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select round as nest function with agg (pushdown, explain)
--Testcase 736:
EXPLAIN VERBOSE
SELECT sum(value3),round(sum(value3)) FROM s3 ORDER BY 1;

-- select round as nest function with agg (pushdown, result)
--Testcase 737:
SELECT sum(value3),round(sum(value3)) FROM s3 ORDER BY 1;

-- select round as nest with log2 (pushdown, explain)
--Testcase 738:
EXPLAIN VERBOSE
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3 ORDER BY 1;

-- select round as nest with log2 (pushdown, result)
--Testcase 739:
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3 ORDER BY 1;

-- select round with non pushdown func and roundlicit constant (explain)
--Testcase 740:
EXPLAIN VERBOSE
SELECT round(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select round with non pushdown func and roundlicit constant (result)
--Testcase 741:
SELECT round(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select round with order by (explain)
--Testcase 742:
EXPLAIN VERBOSE
SELECT value1, round(1-value1) FROM s3 ORDER BY round(1-value1);

-- select round with order by (result)
--Testcase 743:
SELECT value1, round(1-value1) FROM s3 ORDER BY round(1-value1);

-- select round with order by index (result)
--Testcase 744:
SELECT value1, round(1-value1) FROM s3 ORDER BY 2,1;

-- select round with order by index (result)
--Testcase 745:
SELECT value1, round(1-value1) FROM s3 ORDER BY 1,2;

-- select round and as
--Testcase 746:
SELECT round(value3) as round1 FROM s3 ORDER BY 1;

-- select round(*) (stub function, explain)
--Testcase 747:
EXPLAIN VERBOSE
SELECT round_all() from s3 ORDER BY 1;

-- select round(*) (stub function, result)
--Testcase 748:
SELECT * FROM (
SELECT round_all() from s3
) as t ORDER BY 1;

-- select round(*) (stub function and group by tag only) (explain)
--Testcase 1360:
EXPLAIN VERBOSE
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select round(*) (stub function and group by tag only) (result)
--Testcase 1361:
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select round(*) (stub function, expose data, explain)
--Testcase 749:
EXPLAIN VERBOSE
SELECT (round_all()::s3).* from s3 ORDER BY 1;

-- select round(*) (stub function, expose data, result)
--Testcase 750:
SELECT * FROM (
SELECT (round_all()::s3).* from s3
) as t ORDER BY 1;

-- select sin (builtin function, explain)
--Testcase 751:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 ORDER BY 1;

-- select sin (builtin function, result)
--Testcase 752:
SELECT * FROM (
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select sin (builtin function, not pushdown constraints, explain)
--Testcase 753:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sin (builtin function, not pushdown constraints, result)
--Testcase 754:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sin (builtin function, pushdown constraints, explain)
--Testcase 755:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sin (builtin function, pushdown constraints, result)
--Testcase 756:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sin as nest function with agg (pushdown, explain)
--Testcase 757:
EXPLAIN VERBOSE
SELECT sum(value3),sin(sum(value3)) FROM s3 ORDER BY 1;

-- select sin as nest function with agg (pushdown, result)
--Testcase 758:
SELECT sum(value3),sin(sum(value3)) FROM s3 ORDER BY 1;

-- select sin as nest with log2 (pushdown, explain)
--Testcase 759:
EXPLAIN VERBOSE
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select sin as nest with log2 (pushdown, result)
--Testcase 760:
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select sin with non pushdown func and explicit constant (explain)
--Testcase 761:
EXPLAIN VERBOSE
SELECT sin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sin with non pushdown func and explicit constant (result)
--Testcase 762:
SELECT sin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sin with order by (explain)
--Testcase 763:
EXPLAIN VERBOSE
SELECT value1, sin(1-value1) FROM s3 ORDER BY sin(1-value1);

-- select sin with order by (result)
--Testcase 764:
SELECT value1, sin(1-value1) FROM s3 ORDER BY sin(1-value1);

-- select sin with order by index (result)
--Testcase 765:
SELECT value1, sin(1-value1) FROM s3 ORDER BY 2,1;

-- select sin with order by index (result)
--Testcase 766:
SELECT value1, sin(1-value1) FROM s3 ORDER BY 1,2;

-- select sin and as
--Testcase 767:
SELECT sin(value3) as sin1 FROM s3 ORDER BY 1;

-- select sin(*) (stub function, explain)
--Testcase 768:
EXPLAIN VERBOSE
SELECT sin_all() from s3 ORDER BY 1;

-- select sin(*) (stub function, result)
--Testcase 769:
SELECT * FROM (
SELECT sin_all() from s3
) as t ORDER BY 1;

-- select sin(*) (stub function and group by tag only) (explain)
--Testcase 1362:
EXPLAIN VERBOSE
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select sin(*) (stub function and group by tag only) (result)
--Testcase 1363:
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select tan (builtin function, explain)
--Testcase 770:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 ORDER BY 1;

-- select tan (builtin function, result)
--Testcase 771:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 ORDER BY 1;

-- select tan (builtin function, not pushdown constraints, explain)
--Testcase 772:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select tan (builtin function, not pushdown constraints, result)
--Testcase 773:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select tan (builtin function, pushdown constraints, explain)
--Testcase 774:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select tan (builtin function, pushdown constraints, result)
--Testcase 775:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select tan as nest function with agg (pushdown, explain)
--Testcase 776:
EXPLAIN VERBOSE
SELECT sum(value3),tan(sum(value3)) FROM s3 ORDER BY 1;

-- select tan as nest function with agg (pushdown, result)
--Testcase 777:
SELECT sum(value3),tan(sum(value3)) FROM s3 ORDER BY 1;

-- select tan as nest with log2 (pushdown, explain)
--Testcase 778:
EXPLAIN VERBOSE
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select tan as nest with log2 (pushdown, result)
--Testcase 779:
SELECT * FROM (
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3
) as t ORDER BY 1, 2;

-- select tan with non pushdown func and tanlicit constant (explain)
--Testcase 780:
EXPLAIN VERBOSE
SELECT tan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select tan with non pushdown func and tanlicit constant (result)
--Testcase 781:
SELECT tan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select tan with order by (explain)
--Testcase 782:
EXPLAIN VERBOSE
SELECT value1, tan(1-value1) FROM s3 ORDER BY tan(1-value1);

-- select tan with order by (result)
--Testcase 783:
SELECT value1, tan(1-value1) FROM s3 ORDER BY tan(1-value1);

-- select tan with order by index (result)
--Testcase 784:
SELECT value1, tan(1-value1) FROM s3 ORDER BY 2,1;

-- select tan with order by index (result)
--Testcase 785:
SELECT value1, tan(1-value1) FROM s3 ORDER BY 1,2;

-- select tan and as
--Testcase 786:
SELECT tan(value3) as tan1 FROM s3 ORDER BY 1;

-- select tan(*) (stub function, explain)
--Testcase 787:
EXPLAIN VERBOSE
SELECT tan_all() from s3 ORDER BY 1;

-- select tan(*) (stub function, result)
--Testcase 788:
SELECT * FROM (
SELECT tan_all() from s3
) as t ORDER BY 1;

-- select tan(*) (stub function and group by tag only) (explain)
--Testcase 1364:
EXPLAIN VERBOSE
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select tan(*) (stub function and group by tag only) (result)
--Testcase 1365:
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 789:
SELECT sin_all(), round_all(), tan_all() FROM s3 ORDER BY 1;

-- select predictors function holt_winters() (explain)
--Testcase 790:
EXPLAIN VERBOSE
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters() (result)
--Testcase 791:
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters_with_fit() (explain)
--Testcase 792:
EXPLAIN VERBOSE
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters_with_fit() (result)
--Testcase 793:
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function, explain)
--Testcase 794:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function, result)
--Testcase 795:
SELECT influx_count_all(*) FROM s3 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (explain)
--Testcase 796:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (result)
--Testcase 797:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (explain)
--Testcase 798:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (result)
--Testcase 799:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select count(*) function of InfluxDB over join query (explain)
--Testcase 800:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select count(*) function of InfluxDB over join query (result, stub call error)
--Testcase 801:
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct (stub agg function, explain)
--Testcase 802:
EXPLAIN VERBOSE
SELECT influx_distinct(value1) FROM s3 ORDER BY 1;

-- select distinct (stub agg function, result)
--Testcase 803:
SELECT influx_distinct(value1) FROM s3 ORDER BY 1;

-- select distinct (stub agg function and group by influx_time() and tag) (explain)
--Testcase 804:
EXPLAIN VERBOSE
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select distinct (stub agg function and group by influx_time() and tag) (result)
--Testcase 805:
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select distinct (stub agg function and group by tag only) (explain)
--Testcase 806:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select distinct (stub agg function and group by tag only) (result)
--Testcase 807:
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select distinct over join query (explain)
--Testcase 808:
EXPLAIN VERBOSE
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct over join query (result, stub call error)
--Testcase 809:
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct with having (explain)
--Testcase 810:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100 ORDER BY 1;

-- select distinct with having (result, not pushdown, stub call error)
--Testcase 811:
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100 ORDER BY 1;

--Testcase 812:
DROP FOREIGN TABLE s3__influxdb_svr__0;
--Testcase 813:
DROP USER MAPPING FOR CURRENT_USER SERVER influxdb_svr;
--Testcase 814:
DROP SERVER influxdb_svr;
--Testcase 815:
DROP EXTENSION influxdb_fdw;

--Testcase 816:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 817:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 818:
DROP SERVER pgspider_svr;
--Testcase 819:
DROP EXTENSION pgspider_fdw;

--Testcase 820:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: sqlite

--Testcase 821:
CREATE FOREIGN TABLE s3 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;

--Testcase 822:
CREATE EXTENSION pgspider_fdw;
--Testcase 823:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 824:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 825:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 's31sqlite');

--Testcase 826:
CREATE EXTENSION sqlite_fdw;
--Testcase 827:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/pgtest.db');
--Testcase 828:
CREATE FOREIGN TABLE s3__sqlite_svr__0 (id text OPTIONS (key 'true'), time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text) SERVER sqlite_svr OPTIONS(table 's32');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 829:
\d s3;
--Testcase 830:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- select abs (builtin function, explain)
--Testcase 831:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1;

-- select abs (buitin function, result)
--Testcase 832:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 833:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 834:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 835:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 836:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 837:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 838:
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 839:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 840:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select abs with order by (explain)
--Testcase 841:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 842:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 843:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 844:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 845:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 846:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 847:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 848:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 849:
SELECT * FROM (
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1
) AS t ORDER BY 1,2,3;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 850:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 851:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- sqlite pushdown supported functions (explain)
--Testcase 852:
EXPLAIN VERBOSE
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3 ORDER BY 1;

-- sqlite pushdown supported functions (result)
--Testcase 853:
SELECT * FROM (
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3
) AS t ORDER BY 1,2,3,4,5,6,7,8,9,10;

--Testcase 854:
DROP FOREIGN TABLE s3__sqlite_svr__0;
--Testcase 855:
DROP SERVER sqlite_svr;
--Testcase 856:
DROP EXTENSION sqlite_fdw;

--Testcase 857:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 858:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 859:
DROP SERVER pgspider_svr;
--Testcase 860:
DROP EXTENSION pgspider_fdw;

--Testcase 861:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: mysql

--Testcase 862:
CREATE FOREIGN TABLE ftextsearch (id int, content text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 863:
CREATE FOREIGN TABLE s3 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;

--Testcase 864:
CREATE EXTENSION pgspider_fdw;
--Testcase 865:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 866:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 867:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr OPTIONS (table_name 's31mysql');

--Testcase 868:
CREATE EXTENSION mysql_fdw;
--Testcase 869:
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw;
--Testcase 870:
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_svr OPTIONS(username 'root', password 'Mysql_1234');
--Testcase 871:
CREATE FOREIGN TABLE s3__mysql_svr__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text) SERVER mysql_svr OPTIONS(dbname 'test', table_name 's32');

--Testcase 872:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr__0 (id int, content text) SERVER pgspider_svr OPTIONS (table_name 'ftextsearch1');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 873:
\d s3;
--Testcase 874:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 875:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3 ORDER BY 1;

-- select float8() (not pushdown, remove float8, result)
--Testcase 876:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 877:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 ORDER BY 1;

-- select sqrt (buitin function, result)
--Testcase 878:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 879:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 880:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 881:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 882:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 883:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 884:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 885:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 886:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 887:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 888:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base), mysql (base, v)
--Testcase 889:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 890:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 891:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 892:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 893:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 894:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 895:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 896:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 897:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 898:
SELECT * FROM (
SELECT sum(value3),abs(sum(value3)) FROM s3
) AS t ORDER BY 1;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 899:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 900:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 901:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 902:
SELECT * FROM (
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3
) AS t ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 903:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3 ORDER BY 1;

-- select abs with order by (explain)
--Testcase 904:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 905:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 906:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 907:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 908:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 909:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 910:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 911:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 912:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 913:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 914:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3
) AS t ORDER BY 1,2,3;

-- full text search table
--Testcase 915:
CREATE FOREIGN TABLE ftextsearch__mysql_svr__0 (id int, content text) SERVER mysql_svr OPTIONS(dbname 'test', table_name 'ftextsearch2');

-- text search (pushdown, explain)
--Testcase 916:
EXPLAIN VERBOSE
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0;

-- text search (pushdown, result)
--Testcase 917:
SELECT content FROM (
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0
       ) AS t ORDER BY 1;

--Testcase 918:
DROP FOREIGN TABLE ftextsearch__mysql_svr__0;
--Testcase 919:
DROP FOREIGN TABLE ftextsearch__pgspider_svr__0;
--Testcase 920:
DROP FOREIGN TABLE s3__mysql_svr__0;
--Testcase 921:
DROP USER MAPPING FOR CURRENT_USER SERVER mysql_svr;
--Testcase 922:
DROP SERVER mysql_svr;
--Testcase 923:
DROP EXTENSION mysql_fdw;

--Testcase 924:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 925:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 926:
DROP SERVER pgspider_svr;
--Testcase 927:
DROP EXTENSION pgspider_fdw;

--Testcase 928:
DROP FOREIGN TABLE s3;
--Testcase 929:
DROP FOREIGN TABLE ftextsearch;

----------------------------------------------------------
-- Data source: griddb

--Testcase 930:
CREATE FOREIGN TABLE s3 (
       date timestamp without time zone,
       value1 integer,
       value2 double precision,
       name text,
       age integer,
       location text,
       gpa double precision,
       date1 timestamp without time zone,
       date2 timestamp without time zone,
       strcol text,
       booleancol boolean,
       bytecol smallint,
       shortcol smallint,
       intcol integer,
       longcol bigint,
       floatcol real,
       doublecol double precision,
       blobcol bytea,
       stringarray text[],
       boolarray boolean[],
       bytearray smallint[],
       shortarray smallint[],
       integerarray integer[],
       longarray bigint[],
       floatarray real[],
       doublearray double precision[],
       timestamparray timestamp without time zone[],
       __spd_url text
) SERVER pgspider_core_svr;

--Testcase 931:
CREATE EXTENSION pgspider_fdw;
--Testcase 932:
CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 933:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 934:
CREATE FOREIGN TABLE s3__pgspider_svr__0 (
       date timestamp without time zone,
       value1 integer,
       value2 double precision,
       name text,
       age integer,
       location text,
       gpa double precision,
       date1 timestamp without time zone,
       date2 timestamp without time zone,
       strcol text,
       booleancol boolean,
       bytecol smallint,
       shortcol smallint,
       intcol integer,
       longcol bigint,
       floatcol real,
       doublecol double precision,
       blobcol bytea,
       stringarray text[],
       boolarray boolean[],
       bytearray smallint[],
       shortarray smallint[],
       integerarray integer[],
       longarray bigint[],
       floatarray real[],
       doublearray double precision[],
       timestamparray timestamp without time zone[],
       __spd_url text
) SERVER pgspider_svr OPTIONS(table_name 's31griddb');

--Testcase 935:
CREATE EXTENSION griddb_fdw;
--Testcase 936:
CREATE SERVER griddb_svr FOREIGN DATA WRAPPER griddb_fdw  OPTIONS (host '239.0.0.1', port '31999', clustername 'griddbfdwTestCluster');
--Testcase 937:
CREATE USER MAPPING FOR public SERVER griddb_svr OPTIONS (username 'admin', password 'testadmin');
--Testcase 938:
CREATE FOREIGN TABLE s3__griddb_svr__0 (
       date timestamp without time zone  OPTIONS (rowkey 'true'),
       value1 integer,
       value2 double precision,
       name text,
       age integer,
       location text,
       gpa double precision,
       date1 timestamp without time zone,
       date2 timestamp without time zone,
       strcol text,
       booleancol boolean,
       bytecol smallint,
       shortcol smallint,
       intcol integer,
       longcol bigint,
       floatcol real,
       doublecol double precision,
       blobcol bytea,
       stringarray text[],
       boolarray boolean[],
       bytearray smallint[],
       shortarray smallint[],
       integerarray integer[],
       longarray bigint[],
       floatarray real[],
       doublearray double precision[],
       timestamparray timestamp without time zone[]
) SERVER griddb_svr OPTIONS(table_name 's32');

--Test foreign table
--Testcase 939:
\d s3;
--Testcase 940:
SELECT * FROM s3 ORDER BY 1,2;

--
-- Test for non-unique functions of GridDB in WHERE clause
--
-- char_length
--Testcase 941:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) > 4  ORDER BY 1;
--Testcase 942:
SELECT * FROM s3 WHERE char_length(name) > 4  ORDER BY 1;
--Testcase 943:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) < 6  ORDER BY 1;
--Testcase 944:
SELECT * FROM s3 WHERE char_length(name) < 6  ORDER BY 1;

--Testcase 945:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george' ORDER BY 1;
--Testcase 946:
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george' ORDER BY 1;

--substr
--Testcase 947:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,2,3) = 'red' ORDER BY 1;
--Testcase 948:
SELECT * FROM s3 WHERE substr(name,2,3) = 'red' ORDER BY 1;
--Testcase 949:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre' ORDER BY 1;
--Testcase 950:
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre' ORDER BY 1;

--upper
--Testcase 951:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) = 'FRED' ORDER BY 1;
--Testcase 952:
SELECT * FROM s3 WHERE upper(name) = 'FRED' ORDER BY 1;
--Testcase 953:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) <> 'FRED' ORDER BY 1;
--Testcase 954:
SELECT * FROM s3 WHERE upper(name) <> 'FRED' ORDER BY 1;

--lower
--Testcase 955:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 956:
SELECT * FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 957:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) <> 'bob' ORDER BY 1;
--Testcase 958:
SELECT * FROM s3 WHERE lower(name) <> 'bob' ORDER BY 1;

--round
--Testcase 959:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 960:
SELECT * FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 961:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) <= 3 ORDER BY 1;
--Testcase 962:
SELECT * FROM s3 WHERE round(gpa) <= 3 ORDER BY 1;

--floor
--Testcase 963:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) = 3 ORDER BY 1;
--Testcase 964:
SELECT * FROM s3 WHERE floor(gpa) = 3 ORDER BY 1;
--Testcase 965:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) < 2 ORDER BY 1;
--Testcase 966:
SELECT * FROM s3 WHERE floor(gpa) < 3 ORDER BY 1;

--ceiling
--Testcase 967:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) >= 3 ORDER BY 1;
--Testcase 968:
SELECT * FROM s3 WHERE ceiling(gpa) >= 3 ORDER BY 1;
--Testcase 969:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) = 4 ORDER BY 1;
--Testcase 970:
SELECT * FROM s3 WHERE ceiling(gpa) = 4 ORDER BY 1;

--
--Test for unique functions of GridDB in WHERE clause: time functions
--
--griddb_timestamp: push down timestamp function to GridDB
--Testcase 971:
EXPLAIN VERBOSE
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00' ORDER BY 1;
--Testcase 972:
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00' ORDER BY 1;
--Testcase 973:
EXPLAIN VERBOSE
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol) ORDER BY 1;
--Testcase 974:
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol) ORDER BY 1;
--griddb_timestamp: push down timestamp function to GridDB and gets error because GridDB only support YYYY-MM-DDThh:mm:ss.SSSZ format for timestamp function
--UPDATE time_series2__griddb_svr__0 SET strcol = '2020-01-05 21:00:00';
--EXPLAIN VERBOSE
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';

--timestampadd
--YEAR
--Testcase 975:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00' ORDER BY 1;
--Testcase 976:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00' ORDER BY 1;
--Testcase 977:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00' ORDER BY 1;
--Testcase 978:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00' ORDER BY 1;
--Testcase 979:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29' ORDER BY 1;
--Testcase 980:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29' ORDER BY 1;
--MONTH
--Testcase 981:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 982:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 983:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30' ORDER BY 1;
--Testcase 984:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30' ORDER BY 1;
--Testcase 985:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29' ORDER BY 1;
--Testcase 986:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29' ORDER BY 1;
--DAY
--Testcase 987:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 988:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 989:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30' ORDER BY 1;
--Testcase 990:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30' ORDER BY 1;
--Testcase 991:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01' ORDER BY 1;
--Testcase 992:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01' ORDER BY 1;
--HOUR
--Testcase 993:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 994:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 995:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00' ORDER BY 1;
--Testcase 996:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00' ORDER BY 1;
--MINUTE
--Testcase 997:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00' ORDER BY 1;
--Testcase 998:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00' ORDER BY 1;
--Testcase 999:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1000:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--SECOND
--Testcase 1001:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30' ORDER BY 1;
--Testcase 1002:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30' ORDER BY 1;
--Testcase 1003:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1004:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -30) = '2020-12-29 05:00:00' ORDER BY 1;
--MILLISECOND
--Testcase 1005:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420' ORDER BY 1;
--Testcase 1006:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420' ORDER BY 1;
--Testcase 1007:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;
--Testcase 1008:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;
--Input wrong unit
--Testcase 1009:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MICROSECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;

--timestampdiff
--YEAR
--Testcase 1010:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0 ORDER BY 1;
--Testcase 1011:
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0 ORDER BY 1;
--Testcase 1012:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1013:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1014:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10 ORDER BY 1;
--Testcase 1015:
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10 ORDER BY 1;
--MONTH
--Testcase 1016:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1 ORDER BY 1;
--Testcase 1017:
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1 ORDER BY 1;
--Testcase 1018:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1019:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1020:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10 ORDER BY 1;
--Testcase 1021:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10 ORDER BY 1;
--DAY
--Testcase 1022:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1023:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1024:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1025:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1026:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10 ORDER BY 1;
--Testcase 1027:
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10 ORDER BY 1;
--HOUR
--Testcase 1028:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0 ORDER BY 1;
--Testcase 1029:
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0 ORDER BY 1;
--Testcase 1030:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5 ORDER BY 1;
--Testcase 1031:
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5 ORDER BY 1;
--Testcase 1032:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10 ORDER BY 1;
--Testcase 1033:
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10 ORDER BY 1;
--MINUTE
--Testcase 1034:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1035:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1036:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1037:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1038:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10 ORDER BY 1;
--Testcase 1039:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10 ORDER BY 1;
--SECOND
--Testcase 1040:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000 ORDER BY 1;
--Testcase 1041:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000 ORDER BY 1;
--Testcase 1042:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100 ORDER BY 1;
--Testcase 1043:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100 ORDER BY 1;
--Testcase 1044:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000 ORDER BY 1;
--Testcase 1045:
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000 ORDER BY 1;
--MILLISECOND
--Testcase 1046:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200 ORDER BY 1;
--Testcase 1047:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200 ORDER BY 1;
--Testcase 1048:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0 ORDER BY 1;
--Testcase 1049:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0 ORDER BY 1;
--Testcase 1050:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443 ORDER BY 1;
--Testcase 1051:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443 ORDER BY 1;
--Input wrong unit
--Testcase 1052:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MICROSECOND', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1053:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DECADE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1054:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('NANOSECOND', date1, date2) > 10 ORDER BY 1;

--to_timestamp_ms
--Normal case
--Testcase 1055:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;
--Testcase 1056:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;
--Return error if column contains -1 value
--Testcase 1057:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;

--to_epoch_ms
--Testcase 1058:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1) ORDER BY 1;
--Testcase 1059:
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1) ORDER BY 1;
--Testcase 1060:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE to_epoch_ms(date2) < 1000000000000 ORDER BY 1;

--
--Test for unique functions of GridDB in WHERE clause: array functions
--
--array_length
--Testcase 1061:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3 ORDER BY 1;
--Testcase 1062:
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3 ORDER BY 1;
--Testcase 1063:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3 ORDER BY 1;
--Testcase 1064:
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3 ORDER BY 1;
--Testcase 1065:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray) ORDER BY 1;
--Testcase 1066:
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray) ORDER BY 1;
--Testcase 1067:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray) ORDER BY 1;
--Testcase 1068:
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray) ORDER BY 1;
--Testcase 1069:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0 ORDER BY 1, 2;
--Testcase 1070:
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0 ORDER BY 1, 2;
--Testcase 1071:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3 ORDER BY 1;
--Testcase 1072:
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3 ORDER BY 1;

--element
--Normal case
--Testcase 1073:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f' ORDER BY 1;
--Testcase 1074:
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f' ORDER BY 1;
--Testcase 1075:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb' ORDER BY 1;
--Testcase 1076:
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb' ORDER BY 1;
--Testcase 1077:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray) ORDER BY 1;
--Testcase 1078:
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray) ORDER BY 1;
--Testcase 1079:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray) ORDER BY 1;
--Testcase 1080:
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray) ORDER BY 1;
--Testcase 1081:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray) ORDER BY 1;
--Testcase 1082:
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray) ORDER BY 1;
--Testcase 1083:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1084:
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Return error when getting non-existent element
--Testcase 1085:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1086:
SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;

--
--if user selects non-unique functions which Griddb only supports in WHERE clause => do not push down
--if user selects unique functions which Griddb only supports in WHERE clause => still push down, return error of Griddb
--
--Testcase 1087:
EXPLAIN VERBOSE
SELECT char_length(name) FROM s3 ORDER BY 1;
--Testcase 1088:
SELECT char_length(name) FROM s3 ORDER BY 1;
--Testcase 1089:
EXPLAIN VERBOSE
SELECT concat(name,'abc') FROM s3 ORDER BY 1;
--Testcase 1090:
SELECT concat(name,'abc') FROM s3 ORDER BY 1;
--Testcase 1091:
EXPLAIN VERBOSE
SELECT substr(name,2,3) FROM s3 ORDER BY 1;
--Testcase 1092:
SELECT substr(name,2,3) FROM s3 ORDER BY 1;
--Testcase 1093:
EXPLAIN VERBOSE
SELECT element(1, timestamparray) FROM s3 ORDER BY 1;
--Testcase 1094:
SELECT element(1, timestamparray) FROM s3 ORDER BY 1;
--Testcase 1095:
EXPLAIN VERBOSE
SELECT upper(name) FROM s3 ORDER BY 1;
--Testcase 1096:
SELECT upper(name) FROM s3 ORDER BY 1;
--Testcase 1097:
EXPLAIN VERBOSE
SELECT lower(name) FROM s3 ORDER BY 1;
--Testcase 1098:
SELECT lower(name) FROM s3 ORDER BY 1;
--Testcase 1099:
EXPLAIN VERBOSE
SELECT round(gpa) FROM s3 ORDER BY 1;
--Testcase 1100:
SELECT round(gpa) FROM s3 ORDER BY 1;
--Testcase 1101:
EXPLAIN VERBOSE
SELECT floor(gpa) FROM s3 ORDER BY 1;
--Testcase 1102:
SELECT floor(gpa) FROM s3 ORDER BY 1;
--Testcase 1103:
EXPLAIN VERBOSE
SELECT ceiling(gpa) FROM s3 ORDER BY 1;
--Testcase 1104:
SELECT ceiling(gpa) FROM s3 ORDER BY 1;
--Testcase 1105:
EXPLAIN VERBOSE
SELECT griddb_timestamp(strcol) FROM s3 ORDER BY 1;
--Testcase 1106:
SELECT griddb_timestamp(strcol) FROM s3 ORDER BY 1;
--Testcase 1107:
EXPLAIN VERBOSE
SELECT timestampadd('YEAR', date1, -1) FROM s3 ORDER BY 1;
--Testcase 1108:
SELECT timestampadd('YEAR', date1, -1) FROM s3 ORDER BY 1;
--Testcase 1109:
EXPLAIN VERBOSE
SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3 ORDER BY 1;
--Testcase 1110:
SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3 ORDER BY 1;
--Testcase 1111:
EXPLAIN VERBOSE
SELECT to_timestamp_ms(intcol) FROM s3 ORDER BY 1;
--Testcase 1112:
SELECT to_timestamp_ms(intcol) FROM s3 ORDER BY 1;
--Testcase 1113:
EXPLAIN VERBOSE
SELECT to_epoch_ms(date1) FROM s3 ORDER BY 1;
--Testcase 1114:
SELECT to_epoch_ms(date1) FROM s3 ORDER BY 1;
--Testcase 1115:
EXPLAIN VERBOSE
SELECT array_length(boolarray) FROM s3 ORDER BY 1;
--Testcase 1116:
SELECT array_length(boolarray) FROM s3 ORDER BY 1;
--Testcase 1117:
EXPLAIN VERBOSE
SELECT element(1, stringarray) FROM s3 ORDER BY 1;
--Testcase 1118:
SELECT element(1, stringarray) FROM s3 ORDER BY 1;

--
--Test for unique functions of GridDB in SELECT clause: time-series functions
--
--time_next
--specified time exist => return that row
--Testcase 1119:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--Testcase 1120:
SELECT time_next('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1121:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1122:
SELECT time_next('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist, there is no time after the specified time => return no row
--Testcase 1123:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1124:
SELECT time_next('2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_next_only
--even though specified time exist, still return the row whose time is immediately after the specified time
--Testcase 1125:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--Testcase 1126:
SELECT time_next_only('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1127:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1128:
SELECT time_next_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--there is no time after the specified time => return no row
--Testcase 1129:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1130:
SELECT time_next_only('2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_prev
--specified time exist => return that row
--Testcase 1131:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1132:
SELECT time_prev('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1133:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1134:
SELECT time_prev('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist, there is no time before the specified time => return no row
--Testcase 1135:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 09:45:00') FROM s3 ORDER BY 1;
--Testcase 1136:
SELECT time_prev('2018-12-01 09:45:00') FROM s3 ORDER BY 1;

--time_prev_only
--even though specified time exist, still return the row whose time is immediately before the specified time
--Testcase 1137:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1138:
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1139:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1140:
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--there is no time before the specified time => return no row
--Testcase 1141:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3 ORDER BY 1;
--Testcase 1142:
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3 ORDER BY 1;

--time_interpolated
--specified time exist => return that row
--Testcase 1143:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1144:
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row which has interpolated value.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1145:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1146:
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist. There is no row before or after the specified time => can not calculate interpolated value, return no row.
--Testcase 1147:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3 ORDER BY 1;
--Testcase 1148:
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3 ORDER BY 1;
--Testcase 1149:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1150:
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_sampling by MINUTE
--rows for sampling exists => return those rows
--Testcase 1151:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1152:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1153:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1154:
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1155:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1156:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1157:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1158:
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--UPDATE time_series__griddb_svr__0 SET value1 = 5 where date = '2018-12-01 10:40:00';
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;

--time_sampling by HOUR
--rows for sampling exists => return those rows
--Testcase 1159:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1160:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1161:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1162:
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1163:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1164:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1165:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1166:
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;

--time_sampling by DAY
--rows for sampling exists => return those rows
--Testcase 1167:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1168:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1169:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1170:
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1171:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1172:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1173:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1174:
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 6;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3;
--Testcase 1175:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;

--time_sampling by SECOND
--rows for sampling exists => return those rows
--Testcase 1176:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1177:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1178:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1179:
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1180:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1181:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1182:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1183:
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;

--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;

--time_sampling by MILLISECOND
--rows for sampling exists => return those rows
--Testcase 1184:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1185:
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1186:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1187:
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1188:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1189:
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1190:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1191:
SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;

--max_rows
--Testcase 1192:
EXPLAIN VERBOSE
SELECT max_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1193:
SELECT max_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1194:
EXPLAIN VERBOSE
SELECT max_rows(date) FROM s3 ORDER BY 1;
--Testcase 1195:
SELECT max_rows(date) FROM s3 ORDER BY 1;

--min_rows
--Testcase 1196:
EXPLAIN VERBOSE
SELECT min_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1197:
SELECT min_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1198:
EXPLAIN VERBOSE
SELECT min_rows(date) FROM s3 ORDER BY 1;
--Testcase 1199:
SELECT min_rows(date) FROM s3 ORDER BY 1;

--
--if WHERE clause contains functions which Griddb only supports in SELECT clause => still push down, return error of Griddb
--
--Testcase 1200:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1201:
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1202:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00') ORDER BY 1;
--Testcase 1203:
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00') ORDER BY 1;
--Testcase 1204:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1205:
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1206:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') ORDER BY 1;
--Testcase 1207:
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') ORDER BY 1;
--Testcase 1208:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2) ORDER BY 1;
--Testcase 1209:
SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2) ORDER BY 1;

--
-- Test syntax (xxx()::s3).*
--
--Testcase 1210:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3 ORDER BY 1;
--Testcase 1211:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3 ORDER BY 1;
--Testcase 1212:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3 ORDER BY 1;
--Testcase 1213:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3 ORDER BY 1;
--Testcase 1214:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3 ORDER BY 1;
--Testcase 1215:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3 ORDER BY 1;

--
-- Test aggregate function time_avg
--
--Testcase 1216:
EXPLAIN VERBOSE
SELECT time_avg(value1) FROM s3 ORDER BY 1;
--Testcase 1217:
SELECT time_avg(value1) FROM s3 ORDER BY 1;
--Testcase 1218:
EXPLAIN VERBOSE
SELECT time_avg(value2) FROM s3 ORDER BY 1;
--Testcase 1219:
SELECT time_avg(value2) FROM s3 ORDER BY 1;
-- GridDB does not support select multiple target in a query => do not push down, raise stub function error
--Testcase 1220:
EXPLAIN VERBOSE
SELECT time_avg(value1), time_avg(value2) FROM s3 ORDER BY 1;
--Testcase 1221:
--SELECT time_avg(value1), time_avg(value2) FROM s3 ORDER BY 1;
-- Do not push down when expected type is not correct, raise stub function error
--Testcase 1222:
EXPLAIN VERBOSE
SELECT time_avg(date) FROM s3 ORDER BY 1;
--Testcase 1223:
--SELECT time_avg(date) FROM s3 ORDER BY 1;
--Testcase 1224:
EXPLAIN VERBOSE
SELECT time_avg(blobcol) FROM s3 ORDER BY 1;
--Testcase 1225:
--SELECT time_avg(blobcol) FROM s3 ORDER BY 1;

--
-- Test aggregate function min, max, count, sum, avg, variance, stddev
--
--Testcase 1226:
EXPLAIN VERBOSE
SELECT min(age) FROM s3 ORDER BY 1;
--Testcase 1227:
SELECT min(age) FROM s3 ORDER BY 1;

--Testcase 1228:
EXPLAIN VERBOSE
SELECT max(gpa) FROM s3 ORDER BY 1;
--Testcase 1229:
SELECT max(gpa) FROM s3 ORDER BY 1;

--Testcase 1230:
EXPLAIN VERBOSE
SELECT count(*) FROM s3 ORDER BY 1;
--Testcase 1231:
SELECT count(*) FROM s3 ORDER BY 1;
--Testcase 1232:
EXPLAIN VERBOSE
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42 ORDER BY 1;
--Testcase 1233:
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42 ORDER BY 1;

--Testcase 1234:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3 ORDER BY 1;
--Testcase 1235:
SELECT sum(age) FROM s3 ORDER BY 1;
--Testcase 1236:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 1237:
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;

--Testcase 1238:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3 ORDER BY 1;
--Testcase 1239:
SELECT avg(gpa) FROM s3 ORDER BY 1;
--Testcase 1240:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 1241:
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george' ORDER BY 1;

--Testcase 1242:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3 ORDER BY 1;
--Testcase 1243:
SELECT variance(gpa) FROM s3 ORDER BY 1;
--Testcase 1244:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5 ORDER BY 1;
--Testcase 1245:
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5 ORDER BY 1;

--Testcase 1246:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3 ORDER BY 1;
--Testcase 1247:
SELECT stddev(age) FROM s3 ORDER BY 1;
--Testcase 1248:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4 ORDER BY 1;
--Testcase 1249:
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4 ORDER BY 1;

--Testcase 1250:
EXPLAIN VERBOSE
SELECT max(gpa), min(age) FROM s3 ORDER BY 1;
--Testcase 1251:
SELECT max(gpa), min(age) FROM s3 ORDER BY 1;

--Drop all foreign tables
--Testcase 1252:
DROP FOREIGN TABLE s3__griddb_svr__0;
--Testcase 1253:
DROP USER MAPPING FOR public SERVER griddb_svr;
--Testcase 1254:
DROP SERVER griddb_svr;
--Testcase 1255:
DROP EXTENSION griddb_fdw;

--Testcase 1256:
DROP FOREIGN TABLE s3__pgspider_svr__0;
--Testcase 1257:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr;
--Testcase 1258:
DROP SERVER pgspider_svr;
--Testcase 1259:
DROP EXTENSION pgspider_fdw;
--Testcase 1260:
DROP FOREIGN TABLE s3;

--Testcase 1261:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 1262:
DROP SERVER pgspider_core_svr;
--Testcase 1263:
DROP EXTENSION pgspider_core_fdw;
