--Testcase 1258:
SET datestyle=ISO;
--Testcase 1259:
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
--                    +-> Child PGSpider Node -> Data source
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
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3 ORDER BY 1,2,3,4;

-- select float8() (not pushdown, remove float8, result)
--Testcase 15:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 16:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 ORDER BY 1,2;

-- select sqrt (buitin function, result)
--Testcase 17:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, not pushdown constraints, explain)
--Testcase 18:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1,2;

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 19:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 20:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200 ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 21:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select sqrt(*) (stub function, explain)
--Testcase 22:
EXPLAIN VERBOSE
SELECT sqrt_all() from s3 ORDER BY 1;

-- select sqrt(*) (stub function, result)
--Testcase 23:
SELECT * FROM (
SELECT sqrt_all() from s3
) AS t ORDER BY 1;

-- select sqrt(*) (stub function and group by tag only) (explain)
--Testcase 1260:
EXPLAIN VERBOSE
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select sqrt(*) (stub function and group by tag only) (result)
--Testcase 1261:
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs (builtin function, explain)
--Testcase 24:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1,2,3,4;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 25:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 26:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 27:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 28:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 29:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base)
--Testcase 30:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 31:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 32:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 33:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 34:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 35:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 36:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 37:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log(*) (stub function, explain)
--Testcase 38:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3 ORDER BY 1;

-- select log(*) (stub function, result)
--Testcase 39:
SELECT * FROM (
SELECT log_all(50) FROM s3
) AS t ORDER BY 1;

-- select log(*) (stub function, explain)
--Testcase 40:
EXPLAIN VERBOSE
SELECT log_all(70.5) FROM s3 ORDER BY 1;

-- select log(*) (stub function, result)
--Testcase 41:
SELECT * FROM (
SELECT log_all(70.5) FROM s3
) AS t ORDER BY 1;

-- select log(*) (stub function and group by tag only) (explain)
--Testcase 1262:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log(*) (stub function and group by tag only) (result)
--Testcase 1263:
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 42:
--SELECT ln_all(),log10_all(),log_all(50) FROM s3 ORDER BY 1;

-- select log2 (stub function, explain)
--Testcase 43:
EXPLAIN VERBOSE
SELECT log2(value1),log2(value2) FROM s3 ORDER BY 1;

-- select log2 (stub function, result)
--Testcase 44:
SELECT * FROM (
SELECT log2(value1),log2(value2) FROM s3
) AS t ORDER BY 1,2;

-- select log2(*) (stub function, explain)
--Testcase 45:
EXPLAIN VERBOSE
SELECT log2_all() from s3 ORDER BY 1;

-- select log2(*) (stub function, result)
--Testcase 46:
SELECT * FROM (
SELECT log2_all() from s3
) AS t ORDER BY 1;

-- select log2(*) (stub function and group by tag only) (explain)
--Testcase 1264:
EXPLAIN VERBOSE
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log2(*) (stub function and group by tag only) (result)
--Testcase 1265:
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log10 (stub function, explain)
--Testcase 47:
EXPLAIN VERBOSE
SELECT log10(value1), log10(value2) FROM s3 ORDER BY 1, 2;

-- select log10 (stub function, result)
--Testcase 48:
SELECT * FROM (
SELECT log10(value1), log10(value2) FROM s3
) AS t ORDER BY 1, 2;

-- select log10(*) (stub function, explain)
--Testcase 49:
EXPLAIN VERBOSE
SELECT log10_all() from s3 ORDER BY 1;

-- select log10(*) (stub function, result)
--Testcase 50:
SELECT * FROM (
SELECT log10_all() from s3
) AS t ORDER BY 1;

-- select log10(*) (stub function and group by tag only) (explain)
--Testcase 1266:
EXPLAIN VERBOSE
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select log10(*) (stub function and group by tag only) (result)
--Testcase 1267:
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 51:
--SELECT log2_all(), log10_all() FROM s3 ORDER BY 1;

-- select spread (stub agg function, explain)
--Testcase 52:
EXPLAIN VERBOSE
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3 ORDER BY 1;

-- select spread (stub agg function, result)
--Testcase 53:
SELECT * FROM (
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select spread (stub agg function, raise exception if not expected type)
--Testcase 54:
SELECT * FROM (
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 55:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 56:
SELECT * FROM (
SELECT sum(value3),abs(sum(value3)) FROM s3
) AS t ORDER BY 1,2;

-- select abs as nest with log2 (pushdown, explain)
--Testcase 57:
EXPLAIN VERBOSE
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3 ORDER BY 1;

-- select abs as nest with log2 (pushdown, result)
--Testcase 58:
SELECT * FROM (
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3
) AS t ORDER BY 1,2;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 59:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 60:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 61:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 62:
SELECT * FROM (
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 63:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3 ORDER BY 1;

-- select spread (stub agg function and group by influx_time() and tag) (explain)
--Testcase 64:
EXPLAIN VERBOSE
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread (stub agg function and group by influx_time() and tag) (result)
--Testcase 65:
SELECT * FROM (
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1
) AS t ORDER BY 1,2,3;

-- select spread (stub agg function and group by tag only) (result)
--Testcase 66:
SELECT * FROM (
SELECT tag1,spread("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1
) AS t ORDER BY 1,2;

-- select spread (stub agg function and other aggs) (result)
--Testcase 67:
SELECT sum("value1"),spread("value1"),count("value1") FROM s3 ORDER BY 1;

-- select abs with order by (explain)
--Testcase 68:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 69:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 70:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 71:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 72:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs(*) (stub function, explain)
--Testcase 73:
EXPLAIN VERBOSE
SELECT abs_all() from s3 ORDER BY 1;

-- select abs(*) (stub function, result)
--Testcase 74:
SELECT * FROM (
SELECT abs_all() from s3
) AS t ORDER BY 1;

-- select abs(*) (stub function and group by tag only) (explain)
--Testcase 1268:
EXPLAIN VERBOSE
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs(*) (stub function and group by tag only) (result)
--Testcase 1269:
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select abs(*) (stub function, expose data, explain)
--Testcase 75:
EXPLAIN VERBOSE
SELECT (abs_all()::s3).* from s3 ORDER BY 1;

-- select abs(*) (stub function, expose data, result)
--Testcase 76:
SELECT * FROM (
SELECT (abs_all()::s3).* from s3
) AS t ORDER BY 1;

-- select spread over join query (explain)
--Testcase 77:
EXPLAIN VERBOSE
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select spread over join query (result, stub call error)
--Testcase 78:
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select spread with having (explain)
--Testcase 79:
EXPLAIN VERBOSE
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100 ORDER BY 1;

-- select spread with having (result, not pushdown, stub call error)
--Testcase 80:
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100 ORDER BY 1;

-- select spread(*) (stub agg function, explain)
--Testcase 81:
EXPLAIN VERBOSE
SELECT spread_all(*) from s3 ORDER BY 1;

-- select spread(*) (stub agg function, result)
--Testcase 82:
SELECT spread_all(*) from s3 ORDER BY 1;

-- select spread(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 83:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 84:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by tag only) (explain)
--Testcase 85:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(*) (stub agg function and group by tag only) (result)
--Testcase 86:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(*) (stub agg function, expose data, explain)
--Testcase 87:
EXPLAIN VERBOSE
SELECT (spread_all(*)::s3).* from s3 ORDER BY 1;

-- select spread(*) (stub agg function, expose data, result)
--Testcase 88:
SELECT (spread_all(*)::s3).* from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, explain)
--Testcase 89:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, result)
--Testcase 90:
SELECT spread('/value[1,4]/') from s3 ORDER BY 1;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 91:
EXPLAIN VERBOSE
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 92:
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by tag only) (explain)
--Testcase 93:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(regex) (stub agg function and group by tag only) (result)
--Testcase 94:
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select spread(regex) (stub agg function, expose data, explain)
--Testcase 95:
EXPLAIN VERBOSE
SELECT (spread('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select spread(regex) (stub agg function, expose data, result)
--Testcase 96:
SELECT (spread('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 97:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 98:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 99:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (result)
--Testcase 100:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 101:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 102:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- nested function in where clause (explain)
--Testcase 103:
EXPLAIN VERBOSE
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

-- nested function in where clause (result)
--Testcase 104:
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

--Testcase 105:
EXPLAIN VERBOSE
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3 ORDER BY 1;

--Testcase 106:
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3 ORDER BY 1;

-- select first(*) (stub agg function, explain)
--Testcase 107:
EXPLAIN VERBOSE
SELECT first_all(*) from s3 ORDER BY 1;

-- select first(*) (stub agg function, result)
--Testcase 108:
SELECT * FROM (
SELECT first_all(*) from s3
) AS t ORDER BY 1;

-- select first(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 109:
EXPLAIN VERBOSE
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select first(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 110:
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select first(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(*) (stub agg function and group by tag only) (result)
-- -- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(*) (stub agg function, expose data, explain)
--Testcase 111:
EXPLAIN VERBOSE
SELECT (first_all(*)::s3).* from s3 ORDER BY 1;

-- select first(*) (stub agg function, expose data, result)
--Testcase 112:
SELECT * FROM (
SELECT (first_all(*)::s3).* from s3
) AS t ORDER BY 1;

-- select first(regex) (stub function, explain)
--Testcase 113:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/') from s3 ORDER BY 1;

-- select first(regex) (stub function, explain)
--Testcase 114:
SELECT first('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 115:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 116:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select first(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 117:
EXPLAIN VERBOSE
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select first(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 118:
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select first(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(regex) (stub agg function and group by tag only) (result)
-- -- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(regex) (stub agg function, expose data, explain)
--Testcase 119:
EXPLAIN VERBOSE
SELECT (first('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select first(regex) (stub agg function, expose data, result)
--Testcase 120:
SELECT * FROM (
SELECT (first('/value[1,4]/')::s3).* from s3
) AS t ORDER BY 1;

--Testcase 121:
EXPLAIN VERBOSE
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3 ORDER BY 1;

--Testcase 122:
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3 ORDER BY 1;

-- select last(*) (stub agg function, explain)
--Testcase 123:
EXPLAIN VERBOSE
SELECT last_all(*) from s3 ORDER BY 1;

-- select last(*) (stub agg function, result)
--Testcase 124:
SELECT * FROM (
SELECT last_all(*) from s3
) AS t ORDER BY 1;

-- select last(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 125:
EXPLAIN VERBOSE
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select last(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 126:
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select last(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(*) (stub agg function and group by tag only) (result)
-- -- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(*) (stub agg function, expose data, explain)
--Testcase 127:
EXPLAIN VERBOSE
SELECT (last_all(*)::s3).* from s3 ORDER BY 1;

-- select last(*) (stub agg function, expose data, result)
--Testcase 128:
SELECT * FROM (
SELECT (last_all(*)::s3).* from s3
) AS t ORDER BY 1;

-- select last(regex) (stub function, explain)
--Testcase 129:
EXPLAIN VERBOSE
SELECT last('/value[1,4]/') from s3 ORDER BY 1;

-- select last(regex) (stub function, result)
--Testcase 130:
SELECT last('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 131:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 132:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3 ORDER BY 1;

-- select last(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 133:
EXPLAIN VERBOSE
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select last(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 134:
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select last(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(regex) (stub agg function and group by tag only) (result)
-- -- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(regex) (stub agg function, expose data, explain)
--Testcase 135:
EXPLAIN VERBOSE
SELECT (last('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select last(regex) (stub agg function, expose data, result)
--Testcase 136:
SELECT * FROM (
SELECT (last('/value[1,4]/')::s3).* from s3
) AS t ORDER BY 1;

--Testcase 137:
EXPLAIN VERBOSE
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200 ORDER BY 1;
--Testcase 138:
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200 ORDER BY 1;

--Testcase 139:
EXPLAIN VERBOSE
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s') ORDER BY 1;

--Testcase 140:
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s') ORDER BY 1;

-- select sample(*, int) (stub agg function, explain)
--Testcase 141:
EXPLAIN VERBOSE
SELECT sample_all(50) from s3 ORDER BY 1;

-- select sample(*, int) (stub agg function, result)
--Testcase 142:
SELECT * FROM (
SELECT sample_all(50) from s3
) AS t ORDER BY 1;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 143:
EXPLAIN VERBOSE
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (result)
--Testcase 144:
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select sample(*, int) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(*, int) (stub agg function and group by tag only) (result)
-- -- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(*, int) (stub agg function, expose data, explain)
--Testcase 145:
EXPLAIN VERBOSE
SELECT (sample_all(50)::s3).* from s3 ORDER BY 1;

-- select sample(*, int) (stub agg function, expose data, result)
--Testcase 146:
SELECT * FROM (
SELECT (sample_all(50)::s3).* from s3
) AS t ORDER BY 1;

-- select sample(regex) (stub agg function, explain)
--Testcase 147:
EXPLAIN VERBOSE
SELECT sample('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select sample(regex) (stub agg function, result)
--Testcase 148:
SELECT sample('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 149:
EXPLAIN VERBOSE
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 150:
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- -- select sample(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(regex) (stub agg function and group by tag only) (result)
-- -- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(regex) (stub agg function, expose data, explain)
--Testcase 151:
EXPLAIN VERBOSE
SELECT (sample('/value[1,4]/', 50)::s3).* from s3 ORDER BY 1;

-- select sample(regex) (stub agg function, expose data, result)
--Testcase 152:
SELECT * FROM (
SELECT (sample('/value[1,4]/', 50)::s3).* from s3
) AS t ORDER BY 1;

--Testcase 153:
EXPLAIN VERBOSE
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 154:
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3 ORDER BY 1, 2, 3, 4;

-- select cumulative_sum(*) (stub function, explain)
--Testcase 155:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() from s3 ORDER BY 1;

-- select cumulative_sum(*) (stub function, result)
--Testcase 156:
SELECT * FROM (
SELECT cumulative_sum_all() from s3
) AS t ORDER BY 1;

-- select cumulative_sum(regex) (stub function, explain)
--Testcase 157:
EXPLAIN VERBOSE
SELECT cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select cumulative_sum(regex) (stub function, result)
--Testcase 158:
SELECT cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 159:
EXPLAIN VERBOSE
SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (result)
--Testcase 160:
--SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select cumulative_sum(*) (stub function and group by tag only) (explain)
--Testcase 1270:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(*) (stub function and group by tag only) (result)
--Testcase 1271:
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(regex) (stub function and group by tag only) (explain)
--Testcase 1272:
EXPLAIN VERBOSE
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(regex) (stub function and group by tag only) (result)
--Testcase 1273:
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, explain)
--Testcase 161:
EXPLAIN VERBOSE
SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, result)
--Testcase 162:
--SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

--Testcase 163:
EXPLAIN VERBOSE
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 164:
SELECT * FROM (
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

--Testcase 165:
EXPLAIN VERBOSE
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3 ORDER BY 1;

--Testcase 166:
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3 ORDER BY 1;

-- select derivative(*) (stub function, explain)
--Testcase 167:
EXPLAIN VERBOSE
SELECT derivative_all() from s3 ORDER BY 1;

-- select derivative(*) (stub function, result)
--Testcase 168:
SELECT * FROM (
SELECT derivative_all() from s3
) as t ORDER BY 1;

-- select derivative(regex) (stub function, explain)
--Testcase 169:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select derivative(regex) (stub function, result)
--Testcase 170:
SELECT derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 171:
EXPLAIN VERBOSE
SELECT derivative_all(), derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 172:
--SELECT derivative_all(), derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select derivative(*) (stub function and group by tag only) (explain)
--Testcase 1274:
EXPLAIN VERBOSE
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(*) (stub function and group by tag only) (result)
--Testcase 1275:
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1276:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(regex) (stub function and group by tag only) (result)
--Testcase 1277:
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select derivative(*) (stub function, expose data, explain)
--Testcase 173:
EXPLAIN VERBOSE
SELECT (derivative_all()::s3).* from s3 ORDER BY 1;

-- select derivative(*) (stub function, expose data, result)
--Testcase 174:
SELECT * FROM (
SELECT (derivative_all()::s3).* from s3
) as t ORDER BY 1;

-- select derivative(regex) (stub function, expose data, explain)
--Testcase 175:
EXPLAIN VERBOSE
SELECT (derivative('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select derivative(regex) (stub function, expose data, result)
--Testcase 176:
SELECT * FROM (
SELECT (derivative('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 177:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 178:
SELECT * FROM (
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

--Testcase 179:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 180:
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3 ORDER BY 1, 2, 3, 4;

-- select non_negative_derivative(*) (stub function, explain)
--Testcase 181:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, result)
--Testcase 182:
SELECT * FROM (
SELECT non_negative_derivative_all() from s3
) as t ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, explain)
--Testcase 183:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, result)
--Testcase 184:
SELECT non_negative_derivative('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1278:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(*) (stub function and group by tag only) (result)
--Testcase 1279:
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1280:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1281:
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, expose data, explain)
--Testcase 185:
EXPLAIN VERBOSE
SELECT (non_negative_derivative_all()::s3).* from s3 ORDER BY 1;

-- select non_negative_derivative(*) (stub function, expose data, result)
--Testcase 186:
SELECT * FROM (
SELECT (non_negative_derivative_all()::s3).* from s3
) as t ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, expose data, explain)
--Testcase 187:
EXPLAIN VERBOSE
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select non_negative_derivative(regex) (stub function, expose data, result)
--Testcase 188:
SELECT * FROM (
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 189:
EXPLAIN VERBOSE
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3 ORDER BY 1, 2, 3, 4;

--Testcase 190:
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3 ORDER BY 1, 2, 3, 4;

-- select difference(*) (stub function, explain)
--Testcase 191:
EXPLAIN VERBOSE
SELECT difference_all() from s3 ORDER BY 1;

-- select difference(*) (stub function, result)
--Testcase 192:
SELECT * FROM (
SELECT difference_all() from s3
) as t ORDER BY 1;

-- select difference(regex) (stub function, explain)
--Testcase 193:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') from s3 ORDER BY 1;

-- select difference(regex) (stub function, result)
--Testcase 194:
SELECT difference('/value[1,4]/') from s3 ORDER BY 1;

-- select difference(*) (stub function and group by tag only) (explain)
--Testcase 1282:
EXPLAIN VERBOSE
SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(*) (stub function and group by tag only) (result)
--Testcase 1283:
SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(regex) (stub function and group by tag only) (explain)
--Testcase 1284:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(regex) (stub function and group by tag only) (result)
--Testcase 1285:
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select difference(*) (stub function, expose data, explain)
--Testcase 195:
EXPLAIN VERBOSE
SELECT (difference_all()::s3).* from s3 ORDER BY 1;

-- select difference(*) (stub function, expose data, result)
--Testcase 196:
SELECT * FROM (
SELECT (difference_all()::s3).* from s3
) as t ORDER BY 1;

-- select difference(regex) (stub function, expose data, explain)
--Testcase 197:
EXPLAIN VERBOSE
SELECT (difference('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select difference(regex) (stub function, expose data, result)
--Testcase 198:
SELECT * FROM (
SELECT (difference('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 199:
EXPLAIN VERBOSE
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3 ORDER BY 1;

--Testcase 200:
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, explain)
--Testcase 201:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, result)
--Testcase 202:
SELECT * FROM (
SELECT non_negative_difference_all() from s3
) as t ORDER BY 1;

-- select non_negative_difference(regex) (stub function, explain)
--Testcase 203:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_difference(*), non_negative_difference(regex) (stub function, result)
--Testcase 204:
SELECT non_negative_difference('/value[1,4]/') from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function and group by tag only) (explain)
--Testcase 1286:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_difference(*) (stub function and group by tag only) (result)
--Testcase 1287:
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_difference(regex) (stub function and group by tag only) (explain)
--Testcase 1288:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_difference(regex) (stub function and group by tag only) (result)
--Testcase 1289:
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select non_negative_difference(*) (stub function, expose data, explain)
--Testcase 205:
EXPLAIN VERBOSE
SELECT (non_negative_difference_all()::s3).* from s3 ORDER BY 1;

-- select non_negative_difference(*) (stub function, expose data, result)
--Testcase 206:
SELECT * FROM (
SELECT (non_negative_difference_all()::s3).* from s3
) as t ORDER BY 1;

-- select non_negative_difference(regex) (stub function, expose data, explain)
--Testcase 207:
EXPLAIN VERBOSE
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select non_negative_difference(regex) (stub function, expose data, result)
--Testcase 208:
SELECT * FROM (
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 209:
EXPLAIN VERBOSE
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3 ORDER BY 1;

--Testcase 210:
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3 ORDER BY 1;

--Testcase 211:
EXPLAIN VERBOSE
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3 ORDER BY 1;

--Testcase 212:
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3 ORDER BY 1;

-- select elapsed(*) (stub function, explain)
--Testcase 213:
EXPLAIN VERBOSE
SELECT elapsed_all() from s3 ORDER BY 1;

-- select elapsed(*) (stub function, result)
--Testcase 214:
SELECT * FROM (
SELECT elapsed_all() from s3
) as t ORDER BY 1;

-- select elapsed(regex) (stub function, explain)
--Testcase 215:
EXPLAIN VERBOSE
SELECT elapsed('/value[1,4]/') from s3 ORDER BY 1;

-- select elapsed(regex) (stub function, result)
--Testcase 216:
SELECT elapsed('/value[1,4]/') from s3 ORDER BY 1;

-- select elapsed(*) (stub function and group by tag only) (explain)
--Testcase 1290:
EXPLAIN VERBOSE
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select elapsed(*) (stub function and group by tag only) (result)
--Testcase 1291:
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select elapsed(regex) (stub function and group by tag only) (explain)
--Testcase 1292:
EXPLAIN VERBOSE
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select elapsed(regex) (stub function and group by tag only) (result)
--Testcase 1293:
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select elapsed(*) (stub function, expose data, explain)
--Testcase 217:
EXPLAIN VERBOSE
SELECT (elapsed_all()::s3).* from s3 ORDER BY 1;

-- select elapsed(*) (stub function, expose data, result)
--Testcase 218:
SELECT * FROM (
SELECT (elapsed_all()::s3).* from s3
) as t ORDER BY 1;

-- select elapsed(regex) (stub function, expose data, explain)
--Testcase 219:
EXPLAIN VERBOSE
SELECT (elapsed('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select elapsed(regex) (stub function, expose data, result)
--Testcase 220:
SELECT * FROM (
SELECT (elapsed('/value[1,4]/')::s3).* from s3
) as t ORDER BY 1;

--Testcase 221:
EXPLAIN VERBOSE
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 222:
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3 ORDER BY 1;

-- select moving_average(*) (stub function, explain)
--Testcase 223:
EXPLAIN VERBOSE
SELECT moving_average_all(2) from s3 ORDER BY 1;

-- select moving_average(*) (stub function, result)
--Testcase 224:
SELECT * FROM (
SELECT moving_average_all(2) from s3
) as t ORDER BY 1;

-- select moving_average(regex) (stub function, explain)
--Testcase 225:
EXPLAIN VERBOSE
SELECT moving_average('/value[1,4]/', 2) from s3 ORDER BY 1;

-- select moving_average(regex) (stub function, result)
--Testcase 226:
SELECT moving_average('/value[1,4]/', 2) from s3 ORDER BY 1;

-- select moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1294:
EXPLAIN VERBOSE
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(*) (stub function and group by tag only) (result)
--Testcase 1295:
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1296:
EXPLAIN VERBOSE
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1297:
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select moving_average(*) (stub function, expose data, explain)
--Testcase 227:
EXPLAIN VERBOSE
SELECT (moving_average_all(2)::s3).* from s3 ORDER BY 1;

-- select moving_average(*) (stub function, expose data, result)
--Testcase 228:
SELECT * FROM (
SELECT (moving_average_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select moving_average(regex) (stub function, expose data, explain)
--Testcase 229:
EXPLAIN VERBOSE
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3 ORDER BY 1;

-- select moving_average(regex) (stub function, expose data, result)
--Testcase 230:
SELECT * FROM (
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 231:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3 ORDER BY 1;

--Testcase 232:
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3 ORDER BY 1;

--Testcase 233:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 234:
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, explain)
--Testcase 235:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, result)
--Testcase 236:
SELECT * FROM (
SELECT chande_momentum_oscillator_all(2) from s3
) as t ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, explain)
--Testcase 237:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, result)
--Testcase 238:
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (explain)
--Testcase 1298:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (result)
--Testcase 1299:
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (explain)
--Testcase 1300:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (result)
--Testcase 1301:
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, expose data, explain)
--Testcase 239:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3 ORDER BY 1;

-- select chande_momentum_oscillator(*) (stub function, expose data, result)
--Testcase 240:
SELECT * FROM (
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, expose data, explain)
--Testcase 241:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select chande_momentum_oscillator(regex) (stub function, expose data, result)
--Testcase 242:
SELECT * FROM (
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 243:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 244:
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 245:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 246:
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function, explain)
--Testcase 247:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function, result)
--Testcase 248:
SELECT * FROM (
SELECT exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select exponential_moving_average(regex) (stub function, explain)
--Testcase 249:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function, result)
--Testcase 250:
SELECT exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1302:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1303:
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1304:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1305:
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 251:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 252:
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 253:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 254:
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function, explain)
--Testcase 255:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function, result)
--Testcase 256:
SELECT * FROM (
SELECT double_exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function, explain)
--Testcase 257:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function, result)
--Testcase 258:
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1306:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1307:
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1308:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1309:
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 259:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3 ORDER BY 1;

--Testcase 260:
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3 ORDER BY 1;

--Testcase 261:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 262:
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, explain)
--Testcase 263:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, result)
--Testcase 264:
SELECT * FROM (
SELECT kaufmans_efficiency_ratio_all(2) from s3
) as t ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, explain)
--Testcase 265:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, result)
--Testcase 266:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (explain)
--Testcase 1310:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (result)
--Testcase 1311:
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (explain)
--Testcase 1312:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (result)
--Testcase 1313:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, explain)
--Testcase 267:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, result)
--Testcase 268:
SELECT * FROM (
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, explain)
--Testcase 269:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, result)
--Testcase 270:
SELECT * FROM (
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

--Testcase 271:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 272:
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 273:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 274:
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function, explain)
--Testcase 275:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function, result)
--Testcase 276:
SELECT * FROM (
SELECT kaufmans_adaptive_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function, explain)
--Testcase 277:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function, result)
--Testcase 278:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1314:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1315:
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1316:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1317:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 279:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 280:
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3 ORDER BY 1;

--Testcase 281:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 282:
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function, explain)
--Testcase 283:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function, result)
--Testcase 284:
SELECT * FROM (
SELECT triple_exponential_moving_average_all(2) from s3
) as t ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function, explain)
--Testcase 285:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function, result)
--Testcase 286:
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1318:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1319:
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1320:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1321:
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 287:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3 ORDER BY 1;

--Testcase 288:
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3 ORDER BY 1;

--Testcase 289:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 290:
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function, explain)
--Testcase 291:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function, result)
--Testcase 292:
SELECT * FROM (
SELECT triple_exponential_derivative_all(2) from s3
) as t ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function, explain)
--Testcase 293:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function, result)
--Testcase 294:
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1322:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (result)
--Testcase 1323:
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1324:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1325:
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

--Testcase 295:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3 ORDER BY 1;

--Testcase 296:
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3 ORDER BY 1;

--Testcase 297:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3 ORDER BY 1;

--Testcase 298:
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, explain)
--Testcase 299:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, result)
--Testcase 300:
SELECT * FROM (
SELECT relative_strength_index_all(2) from s3
) as t ORDER BY 1;

-- select relative_strength_index(regex) (stub function, explain)
--Testcase 301:
EXPLAIN VERBOSE
SELECT relative_strength_index('/value[1,4]/',2) from s3 ORDER BY 1;

-- select relative_strength_index(regex) (stub function, result)
--Testcase 302:
SELECT relative_strength_index('/value[1,4]/',2) from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function and group by tag only) (explain)
--Testcase 1326:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(*) (stub function and group by tag only) (result)
--Testcase 1327:
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(regex) (stub function and group by tag only) (explain)
--Testcase 1328:
EXPLAIN VERBOSE
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(regex) (stub function and group by tag only) (result)
--Testcase 1329:
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select relative_strength_index(*) (stub function, expose data, explain)
--Testcase 303:
EXPLAIN VERBOSE
SELECT (relative_strength_index_all(2)::s3).* from s3 ORDER BY 1;

-- select relative_strength_index(*) (stub function, expose data, result)
--Testcase 304:
SELECT * FROM (
SELECT (relative_strength_index_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select relative_strength_index(regex) (stub function, expose data, explain)
--Testcase 305:
EXPLAIN VERBOSE
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3 ORDER BY 1;

-- select relative_strength_index(regex) (stub function, expose data, result)
--Testcase 306:
SELECT * FROM (
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3
) as t ORDER BY 1;

-- select integral (stub agg function, explain)
--Testcase 307:
EXPLAIN VERBOSE
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3 ORDER BY 1;

-- select integral (stub agg function, result)
--Testcase 308:
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3 ORDER BY 1;

--Testcase 309:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3 ORDER BY 1;

-- select integral (stub agg function, result)
--Testcase 310:
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3 ORDER BY 1;

-- select integral (stub agg function, raise exception if not expected type)
--Testcase 311:
--SELECT integral(value1::numeric),integral(value2::numeric),integral(value3::numeric),integral(value4::numeric) FROM s3 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 312:
EXPLAIN VERBOSE
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 313:
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 314:
EXPLAIN VERBOSE
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 315:
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 316:
SELECT tag1,integral("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select integral (stub agg function and other aggs) (result)
--Testcase 317:
SELECT sum("value1"),integral("value1"),count("value1") FROM s3 ORDER BY 1;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 318:
SELECT tag1,integral("value1", interval '1s') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select integral (stub agg function and other aggs) (result)
--Testcase 319:
SELECT sum("value1"),integral("value1", interval '1s'),count("value1") FROM s3 ORDER BY 1;

-- select integral over join query (explain)
--Testcase 320:
EXPLAIN VERBOSE
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (result, stub call error)
--Testcase 321:
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (explain)
--Testcase 322:
EXPLAIN VERBOSE
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral over join query (result, stub call error)
--Testcase 323:
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select integral with having (explain)
--Testcase 324:
EXPLAIN VERBOSE
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100 ORDER BY 1;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 325:
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100 ORDER BY 1;

-- select integral with having (explain)
--Testcase 326:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100 ORDER BY 1;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 327:
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100 ORDER BY 1;

-- select integral(*) (stub agg function, explain)
--Testcase 328:
EXPLAIN VERBOSE
SELECT integral_all(*) from s3 ORDER BY 1;

-- select integral(*) (stub agg function, result)
--Testcase 329:
SELECT integral_all(*) from s3 ORDER BY 1;

-- select integral(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 330:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 331:
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by tag only) (explain)
--Testcase 332:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(*) (stub agg function and group by tag only) (result)
--Testcase 333:
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(*) (stub agg function, expose data, explain)
--Testcase 334:
EXPLAIN VERBOSE
SELECT (integral_all(*)::s3).* from s3 ORDER BY 1;

-- select integral(*) (stub agg function, expose data, result)
--Testcase 335:
SELECT (integral_all(*)::s3).* from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, explain)
--Testcase 336:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, result)
--Testcase 337:
SELECT integral('/value[1,4]/') from s3 ORDER BY 1;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 338:
EXPLAIN VERBOSE
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 339:
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by tag only) (explain)
--Testcase 340:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(regex) (stub agg function and group by tag only) (result)
--Testcase 341:
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1 ORDER BY 1;

-- select integral(regex) (stub agg function, expose data, explain)
--Testcase 342:
EXPLAIN VERBOSE
SELECT (integral('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select integral(regex) (stub agg function, expose data, result)
--Testcase 343:
SELECT (integral('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select mean (stub agg function, explain)
--Testcase 344:
EXPLAIN VERBOSE
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3 ORDER BY 1;

-- select mean (stub agg function, result)
--Testcase 345:
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3 ORDER BY 1;

-- select mean (stub agg function, raise exception if not expected type)
--Testcase 346:
--SELECT mean(value1::numeric),mean(value2::numeric),mean(value3::numeric),mean(value4::numeric) FROM s3 ORDER BY 1;

-- select mean (stub agg function and group by influx_time() and tag) (explain)
--Testcase 347:
EXPLAIN VERBOSE
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean (stub agg function and group by influx_time() and tag) (result)
--Testcase 348:
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean (stub agg function and group by tag only) (result)
--Testcase 349:
SELECT tag1,mean("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean (stub agg function and other aggs) (result)
--Testcase 350:
SELECT sum("value1"),mean("value1"),count("value1") FROM s3 ORDER BY 1;

-- select mean over join query (explain)
--Testcase 351:
EXPLAIN VERBOSE
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select mean over join query (result, stub call error)
--Testcase 352:
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select mean with having (explain)
--Testcase 353:
EXPLAIN VERBOSE
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100 ORDER BY 1;

-- select mean with having (explain, not pushdown, stub call error)
--Testcase 354:
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100 ORDER BY 1;

-- select mean(*) (stub agg function, explain)
--Testcase 355:
EXPLAIN VERBOSE
SELECT mean_all(*) from s3 ORDER BY 1;

-- select mean(*) (stub agg function, result)
--Testcase 356:
SELECT mean_all(*) from s3 ORDER BY 1;

-- select mean(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 357:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 358:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by tag only) (explain)
--Testcase 359:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(*) (stub agg function and group by tag only) (result)
--Testcase 360:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(*) (stub agg function, expose data, explain)
--Testcase 361:
EXPLAIN VERBOSE
SELECT (mean_all(*)::s3).* from s3 ORDER BY 1;

-- select mean(*) (stub agg function, expose data, result)
--Testcase 362:
SELECT (mean_all(*)::s3).* from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, explain)
--Testcase 363:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, result)
--Testcase 364:
SELECT mean('/value[1,4]/') from s3 ORDER BY 1;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 365:
EXPLAIN VERBOSE
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 366:
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by tag only) (explain)
--Testcase 367:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(regex) (stub agg function and group by tag only) (result)
--Testcase 368:
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select mean(regex) (stub agg function, expose data, explain)
--Testcase 369:
EXPLAIN VERBOSE
SELECT (mean('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select mean(regex) (stub agg function, expose data, result)
--Testcase 370:
SELECT (mean('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select median (stub agg function, explain)
--Testcase 371:
EXPLAIN VERBOSE
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3 ORDER BY 1;

-- select median (stub agg function, result)
--Testcase 372:
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3 ORDER BY 1;

-- select median (stub agg function, raise exception if not expected type)
--Testcase 373:
--SELECT median(value1::numeric),median(value2::numeric),median(value3::numeric),median(value4::numeric) FROM s3 ORDER BY 1;

-- select median (stub agg function and group by influx_time() and tag) (explain)
--Testcase 374:
EXPLAIN VERBOSE
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median (stub agg function and group by influx_time() and tag) (result)
--Testcase 375:
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median (stub agg function and group by tag only) (result)
--Testcase 376:
SELECT tag1,median("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median (stub agg function and other aggs) (result)
--Testcase 377:
SELECT sum("value1"),median("value1"),count("value1") FROM s3 ORDER BY 1;

-- select median over join query (explain)
--Testcase 378:
EXPLAIN VERBOSE
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select median over join query (result, stub call error)
--Testcase 379:
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select median with having (explain)
--Testcase 380:
EXPLAIN VERBOSE
SELECT median(value1) FROM s3 HAVING median(value1) > 100 ORDER BY 1;

-- select median with having (explain, not pushdown, stub call error)
--Testcase 381:
SELECT median(value1) FROM s3 HAVING median(value1) > 100 ORDER BY 1;

-- select median(*) (stub agg function, explain)
--Testcase 382:
EXPLAIN VERBOSE
SELECT median_all(*) from s3 ORDER BY 1;

-- select median(*) (stub agg function, result)
--Testcase 383:
SELECT median_all(*) from s3 ORDER BY 1;

-- select median(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 384:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 385:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by tag only) (explain)
--Testcase 386:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(*) (stub agg function and group by tag only) (result)
--Testcase 387:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(*) (stub agg function, expose data, explain)
--Testcase 388:
EXPLAIN VERBOSE
SELECT (median_all(*)::s3).* from s3 ORDER BY 1;

-- select median(*) (stub agg function, expose data, result)
--Testcase 389:
SELECT (median_all(*)::s3).* from s3 ORDER BY 1;

-- select median(regex) (stub agg function, explain)
--Testcase 390:
EXPLAIN VERBOSE
SELECT median('/^v.*/') from s3 ORDER BY 1;

-- select median(regex) (stub agg function, result)
--Testcase 391:
SELECT  median('/^v.*/') from s3 ORDER BY 1;

-- select median(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 392:
EXPLAIN VERBOSE
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 393:
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by tag only) (explain)
--Testcase 394:
EXPLAIN VERBOSE
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(regex) (stub agg function and group by tag only) (result)
--Testcase 395:
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select median(regex) (stub agg function, expose data, explain)
--Testcase 396:
EXPLAIN VERBOSE
SELECT (median('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select median(regex) (stub agg function, expose data, result)
--Testcase 397:
SELECT (median('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_mode (stub agg function, explain)
--Testcase 398:
EXPLAIN VERBOSE
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function, result)
--Testcase 399:
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function, raise exception if not expected type)
--Testcase 400:
--SELECT influx_mode(value1::numeric),influx_mode(value2::numeric),influx_mode(value3::numeric),influx_mode(value4::numeric) FROM s3 ORDER BY 1;

-- select influx_mode (stub agg function and group by influx_time() and tag) (explain)
--Testcase 401:
EXPLAIN VERBOSE
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode (stub agg function and group by influx_time() and tag) (result)
--Testcase 402:
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode (stub agg function and group by tag only) (result)
--Testcase 403:
SELECT tag1,influx_mode("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode (stub agg function and other aggs) (result)
--Testcase 404:
SELECT sum("value1"),influx_mode("value1"),count("value1") FROM s3 ORDER BY 1;

-- select influx_mode over join query (explain)
--Testcase 405:
EXPLAIN VERBOSE
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select influx_mode over join query (result, stub call error)
--Testcase 406:
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select influx_mode with having (explain)
--Testcase 407:
EXPLAIN VERBOSE
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100 ORDER BY 1;

-- select influx_mode with having (explain, not pushdown, stub call error)
--Testcase 408:
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100 ORDER BY 1;

-- select influx_mode(*) (stub agg function, explain)
--Testcase 409:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function, result)
--Testcase 410:
SELECT influx_mode_all(*) from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 411:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 412:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by tag only) (explain)
--Testcase 413:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function and group by tag only) (result)
--Testcase 414:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(*) (stub agg function, expose data, explain)
--Testcase 415:
EXPLAIN VERBOSE
SELECT (influx_mode_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_mode(*) (stub agg function, expose data, result)
--Testcase 416:
SELECT (influx_mode_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_mode(regex) (stub function, explain)
--Testcase 417:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_mode(regex) (stub function, result)
--Testcase 418:
SELECT influx_mode('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 419:
EXPLAIN VERBOSE
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 420:
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by tag only) (explain)
--Testcase 421:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function and group by tag only) (result)
--Testcase 422:
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_mode(regex) (stub agg function, expose data, explain)
--Testcase 423:
EXPLAIN VERBOSE
SELECT (influx_mode('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_mode(regex) (stub agg function, expose data, result)
--Testcase 424:
SELECT (influx_mode('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select stddev (agg function, explain)
--Testcase 425:
EXPLAIN VERBOSE
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3 ORDER BY 1;

-- select stddev (agg function, result)
--Testcase 426:
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3 ORDER BY 1;

-- select stddev (agg function and group by influx_time() and tag) (explain)
--Testcase 427:
EXPLAIN VERBOSE
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev (agg function and group by influx_time() and tag) (result)
--Testcase 428:
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev (agg function and group by tag only) (result)
--Testcase 429:
SELECT tag1,stddev("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev (agg function and other aggs) (result)
--Testcase 430:
SELECT sum("value1"),stddev("value1"),count("value1") FROM s3 ORDER BY 1;

-- select stddev(*) (stub agg function, explain)
--Testcase 431:
EXPLAIN VERBOSE
SELECT stddev_all(*) from s3 ORDER BY 1;

-- select stddev(*) (stub agg function, result)
--Testcase 432:
SELECT stddev_all(*) from s3 ORDER BY 1;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 433:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 434:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by tag only) (explain)
--Testcase 435:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(*) (stub agg function and group by tag only) (result)
--Testcase 436:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(regex) (stub function, explain)
--Testcase 437:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') from s3 ORDER BY 1;

-- select stddev(regex) (stub function, result)
--Testcase 438:
SELECT stddev('/value[1,4]/') from s3 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 439:
EXPLAIN VERBOSE
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 440:
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by tag only) (explain)
--Testcase 441:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select stddev(regex) (stub agg function and group by tag only) (result)
--Testcase 442:
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function, explain)
--Testcase 443:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function, result)
--Testcase 444:
SELECT influx_sum_all(*) from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 445:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 446:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by tag only) (explain)
--Testcase 447:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function and group by tag only) (result)
--Testcase 448:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(*) (stub agg function, expose data, explain)
--Testcase 449:
EXPLAIN VERBOSE
SELECT (influx_sum_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_sum(*) (stub agg function, expose data, result)
--Testcase 450:
SELECT (influx_sum_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_sum(regex) (stub function, explain)
--Testcase 451:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_sum(regex) (stub function, result)
--Testcase 452:
SELECT influx_sum('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 453:
EXPLAIN VERBOSE
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 454:
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by tag only) (explain)
--Testcase 455:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function and group by tag only) (result)
--Testcase 456:
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_sum(regex) (stub agg function, expose data, explain)
--Testcase 457:
EXPLAIN VERBOSE
SELECT (influx_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_sum(regex) (stub agg function, expose data, result)
--Testcase 458:
SELECT (influx_sum('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- selector function bottom() (explain)
--Testcase 459:
EXPLAIN VERBOSE
SELECT bottom(value1, 1) FROM s3 ORDER BY 1;

-- selector function bottom() (result)
--Testcase 460:
SELECT bottom(value1, 1) FROM s3 ORDER BY 1;

-- selector function bottom() cannot be combined with other functions(explain)
--Testcase 461:
EXPLAIN VERBOSE
SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3 ORDER BY 1;

-- selector function bottom() cannot be combined with other functions(result)
--Testcase 462:
--SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, explain)
--Testcase 463:
EXPLAIN VERBOSE
SELECT influx_max_all(*) from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, result)
--Testcase 464:
SELECT influx_max_all(*) from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 465:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 466:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by tag only) (explain)
--Testcase 467:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function and group by tag only) (result)
--Testcase 468:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(*) (stub agg function, expose data, explain)
--Testcase 469:
EXPLAIN VERBOSE
SELECT (influx_max_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_max(*) (stub agg function, expose data, result)
--Testcase 470:
SELECT (influx_max_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_max(regex) (stub function, explain)
--Testcase 471:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_max(regex) (stub function, result)
--Testcase 472:
SELECT influx_max('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 473:
EXPLAIN VERBOSE
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 474:
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by tag only) (explain)
--Testcase 475:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function and group by tag only) (result)
--Testcase 476:
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_max(regex) (stub agg function, expose data, explain)
--Testcase 477:
EXPLAIN VERBOSE
SELECT (influx_max('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_max(regex) (stub agg function, expose data, result)
--Testcase 478:
SELECT (influx_max('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, explain)
--Testcase 479:
EXPLAIN VERBOSE
SELECT influx_min_all(*) from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, result)
--Testcase 480:
SELECT influx_min_all(*) from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 481:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 482:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by tag only) (explain)
--Testcase 483:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function and group by tag only) (result)
--Testcase 484:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(*) (stub agg function, expose data, explain)
--Testcase 485:
EXPLAIN VERBOSE
SELECT (influx_min_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_min(*) (stub agg function, expose data, result)
--Testcase 486:
SELECT (influx_min_all(*)::s3).* from s3 ORDER BY 1;

-- select influx_min(regex) (stub function, explain)
--Testcase 487:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_min(regex) (stub function, result)
--Testcase 488:
SELECT influx_min('/value[1,4]/') from s3 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 489:
EXPLAIN VERBOSE
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 490:
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by tag only) (explain)
--Testcase 491:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function and group by tag only) (result)
--Testcase 492:
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select influx_min(regex) (stub agg function, expose data, explain)
--Testcase 493:
EXPLAIN VERBOSE
SELECT (influx_min('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- select influx_min(regex) (stub agg function, expose data, result)
--Testcase 494:
SELECT (influx_min('/value[1,4]/')::s3).* from s3 ORDER BY 1;

-- selector function percentile() (explain)
--Testcase 495:
EXPLAIN VERBOSE
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3 ORDER BY 1;

-- selector function percentile() (result)
--Testcase 496:
SELECT * FROM (
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- selector function percentile() (explain)
--Testcase 497:
EXPLAIN VERBOSE
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3 ORDER BY 1, 2, 3, 4;

-- selector function percentile() (result)
--Testcase 498:
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3 ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, explain)
--Testcase 499:
EXPLAIN VERBOSE
SELECT percentile_all(50) from s3 ORDER BY 1;

-- select percentile(*, int) (stub function, result)
--Testcase 500:
SELECT * FROM (
SELECT percentile_all(50) from s3
) as t ORDER BY 1;

-- select percentile(*, float8) (stub function, explain)
--Testcase 501:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) from s3 ORDER BY 1;

-- select percentile(*, float8) (stub function, result)
--Testcase 502:
SELECT percentile_all(70.5) from s3 ORDER BY 1;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (explain)
--Testcase 503:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (result)
--Testcase 504:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (explain)
--Testcase 505:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (result)
--Testcase 506:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by tag only) (explain)
--Testcase 1330:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, int) (stub function and group by tag only) (result)
--Testcase 1331:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by tag only) (explain)
--Testcase 1332:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, float8) (stub function and group by tag only) (result)
--Testcase 1333:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 507:
EXPLAIN VERBOSE
SELECT (percentile_all(50)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 508:
SELECT * FROM (
SELECT (percentile_all(50)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 509:
EXPLAIN VERBOSE
SELECT (percentile_all(70.5)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 510:
SELECT * FROM (
SELECT (percentile_all(70.5)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- select percentile(regex) (stub function, explain)
--Testcase 511:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select percentile(regex) (stub function, result)
--Testcase 512:
SELECT percentile('/value[1,4]/', 50) from s3 ORDER BY 1;

-- select percentile(regex) (stub function and group by influx_time() and tag) (explain)
--Testcase 513:
EXPLAIN VERBOSE
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by influx_time() and tag) (result)
--Testcase 514:
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by tag only) (explain)
--Testcase 1334:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(regex) (stub function and group by tag only) (result)
--Testcase 1335:
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 515:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 516:
SELECT * FROM (
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 517:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3 ORDER BY 1, 2, 3, 4;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 518:
SELECT * FROM (
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3
) as t ORDER BY 1, 2, 3, 4;

-- selector function top(field_key,N) (explain)
--Testcase 519:
EXPLAIN VERBOSE
SELECT top(value1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,N) (result)
--Testcase 520:
SELECT top(value1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,tag_key(s),N) (explain)
--Testcase 521:
EXPLAIN VERBOSE
SELECT top(value1, tag1, 1) FROM s3 ORDER BY 1;

-- selector function top(field_key,tag_key(s),N) (result)
--Testcase 522:
SELECT top(value1, tag1, 1) FROM s3 ORDER BY 1;

-- selector function top() cannot be combined with other functions(explain)
--Testcase 523:
EXPLAIN VERBOSE
SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3 ORDER BY 1;

-- selector function top() cannot be combined with other functions(result)
--Testcase 524:
--SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3 ORDER BY 1;

-- select acos (builtin function, explain)
--Testcase 525:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 ORDER BY 1;

-- select acos (builtin function, result)
--Testcase 526:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 ORDER BY 1;

-- select acos (builtin function, not pushdown constraints, explain)
--Testcase 527:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select acos (builtin function, not pushdown constraints, result)
--Testcase 528:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select acos (builtin function, pushdown constraints, explain)
--Testcase 529:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select acos (builtin function, pushdown constraints, result)
--Testcase 530:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select acos as nest function with agg (pushdown, explain)
--Testcase 531:
EXPLAIN VERBOSE
SELECT sum(value3),acos(sum(value3)) FROM s3 ORDER BY 1;

-- select acos as nest function with agg (pushdown, result)
--Testcase 532:
SELECT sum(value3),acos(sum(value3)) FROM s3 ORDER BY 1;

-- select acos as nest with log2 (pushdown, explain)
--Testcase 533:
EXPLAIN VERBOSE
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select acos as nest with log2 (pushdown, result)
--Testcase 534:
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select acos with non pushdown func and explicit constant (explain)
--Testcase 535:
EXPLAIN VERBOSE
SELECT acos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select acos with non pushdown func and explicit constant (result)
--Testcase 536:
SELECT * FROM (
SELECT acos(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select acos with order by (explain)
--Testcase 537:
EXPLAIN VERBOSE
SELECT value1, acos(1-value1) FROM s3 ORDER BY acos(1-value1);

-- select acos with order by (result)
--Testcase 538:
SELECT value1, acos(1-value1) FROM s3 ORDER BY acos(1-value1);

-- select acos with order by index (result)
--Testcase 539:
SELECT value1, acos(1-value1) FROM s3 ORDER BY 2,1;

-- select acos with order by index (result)
--Testcase 540:
SELECT value1, acos(1-value1) FROM s3 ORDER BY 1,2;

-- select acos and as
--Testcase 541:
SELECT acos(value3) as acos1 FROM s3 ORDER BY 1;

-- select acos(*) (stub function, explain)
--Testcase 542:
EXPLAIN VERBOSE
SELECT acos_all() from s3 ORDER BY 1;

-- select acos(*) (stub function, result)
--Testcase 543:
SELECT * FROM (
SELECT acos_all() from s3
) as t ORDER BY 1;

-- select acos(*) (stub function and group by tag only) (explain)
--Testcase 1336:
EXPLAIN VERBOSE
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select acos(*) (stub function and group by tag only) (result)
--Testcase 1337:
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select acos(*) (stub function, expose data, explain)
--Testcase 544:
EXPLAIN VERBOSE
SELECT (acos_all()::s3).* from s3 ORDER BY 1;

-- select acos(*) (stub function, expose data, result)
--Testcase 545:
SELECT * FROM (
SELECT (acos_all()::s3).* from s3
) as t ORDER BY 1;

-- select asin (builtin function, explain)
--Testcase 546:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 ORDER BY 1;

-- select asin (builtin function, result)
--Testcase 547:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 ORDER BY 1;

-- select asin (builtin function, not pushdown constraints, explain)
--Testcase 548:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select asin (builtin function, not pushdown constraints, result)
--Testcase 549:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64' ORDER BY 1;

-- select asin (builtin function, pushdown constraints, explain)
--Testcase 550:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select asin (builtin function, pushdown constraints, result)
--Testcase 551:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select asin as nest function with agg (pushdown, explain)
--Testcase 552:
EXPLAIN VERBOSE
SELECT sum(value3),asin(sum(value3)) FROM s3 ORDER BY 1;

-- select asin as nest function with agg (pushdown, result)
--Testcase 553:
SELECT sum(value3),asin(sum(value3)) FROM s3 ORDER BY 1;

-- select asin as nest with log2 (pushdown, explain)
--Testcase 554:
EXPLAIN VERBOSE
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select asin as nest with log2 (pushdown, result)
--Testcase 555:
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select asin with non pushdown func and explicit constant (explain)
--Testcase 556:
EXPLAIN VERBOSE
SELECT asin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select asin with non pushdown func and explicit constant (result)
--Testcase 557:
SELECT asin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select asin with order by (explain)
--Testcase 558:
EXPLAIN VERBOSE
SELECT value1, asin(1-value1) FROM s3 ORDER BY asin(1-value1);

-- select asin with order by (result)
--Testcase 559:
SELECT value1, asin(1-value1) FROM s3 ORDER BY asin(1-value1);

-- select asin with order by index (result)
--Testcase 560:
SELECT value1, asin(1-value1) FROM s3 ORDER BY 2,1;

-- select asin with order by index (result)
--Testcase 561:
SELECT value1, asin(1-value1) FROM s3 ORDER BY 1,2;

-- select asin and as
--Testcase 562:
SELECT asin(value3) as asin1 FROM s3 ORDER BY 1;

-- select asin(*) (stub function, explain)
--Testcase 563:
EXPLAIN VERBOSE
SELECT asin_all() from s3 ORDER BY 1;

-- select asin(*) (stub function, result)
--Testcase 564:
SELECT * FROM (
SELECT asin_all() from s3
) as t ORDER BY 1;

-- select asin(*) (stub function and group by tag only) (explain)
--Testcase 1338:
EXPLAIN VERBOSE
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select asin(*) (stub function and group by tag only) (result)
--Testcase 1339:
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select asin(*) (stub function, expose data, explain)
--Testcase 565:
EXPLAIN VERBOSE
SELECT (asin_all()::s3).* from s3 ORDER BY 1;

-- select asin(*) (stub function, expose data, result)
--Testcase 566:
SELECT * FROM (
SELECT (asin_all()::s3).* from s3
) as t ORDER BY 1;

-- select atan (builtin function, explain)
--Testcase 567:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 ORDER BY 1;

-- select atan (builtin function, result)
--Testcase 568:
SELECT * FROM (
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3
) as t ORDER BY 1;

-- select atan (builtin function, not pushdown constraints, explain)
--Testcase 569:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan (builtin function, not pushdown constraints, result)
--Testcase 570:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan (builtin function, pushdown constraints, explain)
--Testcase 571:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan (builtin function, pushdown constraints, result)
--Testcase 572:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan as nest function with agg (pushdown, explain)
--Testcase 573:
EXPLAIN VERBOSE
SELECT sum(value3),atan(sum(value3)) FROM s3 ORDER BY 1;

-- select atan as nest function with agg (pushdown, result)
--Testcase 574:
SELECT sum(value3),atan(sum(value3)) FROM s3 ORDER BY 1;

-- select atan as nest with log2 (pushdown, explain)
--Testcase 575:
EXPLAIN VERBOSE
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan as nest with log2 (pushdown, result)
--Testcase 576:
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan with non pushdown func and explicit constant (explain)
--Testcase 577:
EXPLAIN VERBOSE
SELECT atan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan with non pushdown func and explicit constant (result)
--Testcase 578:
SELECT atan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan with order by (explain)
--Testcase 579:
EXPLAIN VERBOSE
SELECT value1, atan(1-value1) FROM s3 ORDER BY atan(1-value1);

-- select atan with order by (result)
--Testcase 580:
SELECT value1, atan(1-value1) FROM s3 ORDER BY atan(1-value1);

-- select atan with order by index (result)
--Testcase 581:
SELECT value1, atan(1-value1) FROM s3 ORDER BY 2,1;

-- select atan with order by index (result)
--Testcase 582:
SELECT value1, atan(1-value1) FROM s3 ORDER BY 1,2;

-- select atan and as
--Testcase 583:
SELECT * FROM (
SELECT atan(value3) as atan1 FROM s3
) as t ORDER BY 1;

-- select atan(*) (stub function, explain)
--Testcase 584:
EXPLAIN VERBOSE
SELECT atan_all() from s3 ORDER BY 1;

-- select atan(*) (stub function, result)
--Testcase 585:
SELECT * FROM (
SELECT atan_all() from s3
) as t ORDER BY 1;

-- select atan(*) (stub function and group by tag only) (explain)
--Testcase 1340:
EXPLAIN VERBOSE
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select atan(*) (stub function and group by tag only) (result)
--Testcase 1341:
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select atan(*) (stub function, expose data, explain)
--Testcase 586:
EXPLAIN VERBOSE
SELECT (atan_all()::s3).* from s3 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 587:
--SELECT asin_all(), acos_all(), atan_all() FROM s3 ORDER BY 1;

-- select atan2 (builtin function, explain)
--Testcase 588:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 ORDER BY 1;

-- select atan2 (builtin function, result)
--Testcase 589:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 ORDER BY 1;

-- select atan2 (builtin function, not pushdown constraints, explain)
--Testcase 590:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan2 (builtin function, not pushdown constraints, result)
--Testcase 591:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select atan2 (builtin function, pushdown constraints, explain)
--Testcase 592:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan2 (builtin function, pushdown constraints, result)
--Testcase 593:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select atan2 as nest function with agg (pushdown, explain)
--Testcase 594:
EXPLAIN VERBOSE
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3 ORDER BY 1;

-- select atan2 as nest function with agg (pushdown, result)
--Testcase 595:
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3 ORDER BY 1;

-- select atan2 as nest with log2 (pushdown, explain)
--Testcase 596:
EXPLAIN VERBOSE
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan2 as nest with log2 (pushdown, result)
--Testcase 597:
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3 ORDER BY 1;

-- select atan2 with non pushdown func and explicit constant (explain)
--Testcase 598:
EXPLAIN VERBOSE
SELECT atan2(value3, value4), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan2 with non pushdown func and explicit constant (result)
--Testcase 599:
SELECT atan2(value3, value4), pi(), 4.1 FROM s3 ORDER BY 1;

-- select atan2 with order by (explain)
--Testcase 600:
EXPLAIN VERBOSE
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY atan2(1-value1, 1-value2);

-- select atan2 with order by (result)
--Testcase 601:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY atan2(1-value1, 1-value2);

-- select atan2 with order by index (result)
--Testcase 602:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY 2,1;

-- select atan2 with order by index (result)
--Testcase 603:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 ORDER BY 1,2;

-- select atan2 and as
--Testcase 604:
SELECT atan2(value3, value4) as atan21 FROM s3 ORDER BY 1;

-- select atan2(*) (stub function, explain)
--Testcase 605:
EXPLAIN VERBOSE
SELECT atan2_all(value1) from s3 ORDER BY 1;

-- select atan2(*) (stub function, result)
--Testcase 606:
SELECT * FROM (
SELECT atan2_all(value1) from s3
) as t ORDER BY 1;

-- select ceil (builtin function, explain)
--Testcase 607:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 ORDER BY 1;

-- select ceil (builtin function, result)
--Testcase 608:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 ORDER BY 1;

-- select ceil (builtin function, not pushdown constraints, explain)
--Testcase 609:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ceil (builtin function, not pushdown constraints, result)
--Testcase 610:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ceil (builtin function, pushdown constraints, explain)
--Testcase 611:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ceil (builtin function, pushdown constraints, result)
--Testcase 612:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ceil as nest function with agg (pushdown, explain)
--Testcase 613:
EXPLAIN VERBOSE
SELECT sum(value3),ceil(sum(value3)) FROM s3 ORDER BY 1;

-- select ceil as nest function with agg (pushdown, result)
--Testcase 614:
SELECT sum(value3),ceil(sum(value3)) FROM s3 ORDER BY 1;

-- select ceil as nest with log2 (pushdown, explain)
--Testcase 615:
EXPLAIN VERBOSE
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ceil as nest with log2 (pushdown, result)
--Testcase 616:
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ceil with non pushdown func and explicit constant (explain)
--Testcase 617:
EXPLAIN VERBOSE
SELECT ceil(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ceil with non pushdown func and explicit constant (result)
--Testcase 618:
SELECT * FROM (
SELECT ceil(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select ceil with order by (explain)
--Testcase 619:
EXPLAIN VERBOSE
SELECT value1, ceil(1-value1) FROM s3 ORDER BY ceil(1-value1);

-- select ceil with order by (result)
--Testcase 620:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY ceil(1-value1);

-- select ceil with order by index (result)
--Testcase 621:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY 2,1;

-- select ceil with order by index (result)
--Testcase 622:
SELECT value1, ceil(1-value1) FROM s3 ORDER BY 1,2;

-- select ceil and as
--Testcase 623:
SELECT * FROM (
SELECT ceil(value3) as ceil1 FROM s3
) as t ORDER BY 1;

-- select ceil(*) (stub function, explain)
--Testcase 624:
EXPLAIN VERBOSE
SELECT ceil_all() from s3 ORDER BY 1;

-- select ceil(*) (stub function, result)
--Testcase 625:
SELECT * FROM (
SELECT ceil_all() from s3
) as t ORDER BY 1;

-- select ceil(*) (stub function and group by tag only) (explain)
--Testcase 1342:
EXPLAIN VERBOSE
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ceil(*) (stub function and group by tag only) (result)
--Testcase 1343:
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ceil(*) (stub function, expose data, explain)
--Testcase 626:
EXPLAIN VERBOSE
SELECT (ceil_all()::s3).* from s3 ORDER BY 1;

-- select ceil(*) (stub function, expose data, result)
--Testcase 627:
SELECT * FROM (
SELECT (ceil_all()::s3).* from s3
) as t ORDER BY 1;

-- select cos (builtin function, explain)
--Testcase 628:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 ORDER BY 1;

-- select cos (builtin function, result)
--Testcase 629:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 ORDER BY 1;

-- select cos (builtin function, not pushdown constraints, explain)
--Testcase 630:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select cos (builtin function, not pushdown constraints, result)
--Testcase 631:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select cos (builtin function, pushdown constraints, explain)
--Testcase 632:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select cos (builtin function, pushdown constraints, result)
--Testcase 633:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select cos as nest function with agg (pushdown, explain)
--Testcase 634:
EXPLAIN VERBOSE
SELECT sum(value3),cos(sum(value3)) FROM s3 ORDER BY 1;

-- select cos as nest function with agg (pushdown, result)
--Testcase 635:
SELECT sum(value3),cos(sum(value3)) FROM s3 ORDER BY 1;

-- select cos as nest with log2 (pushdown, explain)
--Testcase 636:
EXPLAIN VERBOSE
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select cos as nest with log2 (pushdown, result)
--Testcase 637:
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3 ORDER BY 1;

-- select cos with non pushdown func and explicit constant (explain)
--Testcase 638:
EXPLAIN VERBOSE
SELECT cos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select cos with non pushdown func and explicit constant (result)
--Testcase 639:
SELECT cos(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select cos with order by (explain)
--Testcase 640:
EXPLAIN VERBOSE
SELECT value1, cos(1-value1) FROM s3 ORDER BY cos(1-value1);

-- select cos with order by (result)
--Testcase 641:
SELECT value1, cos(1-value1) FROM s3 ORDER BY cos(1-value1);

-- select cos with order by index (result)
--Testcase 642:
SELECT value1, cos(1-value1) FROM s3 ORDER BY 2,1;

-- select cos with order by index (result)
--Testcase 643:
SELECT value1, cos(1-value1) FROM s3 ORDER BY 1,2;

-- select cos and as
--Testcase 644:
SELECT cos(value3) as cos1 FROM s3 ORDER BY 1;

-- select cos(*) (stub function, explain)
--Testcase 645:
EXPLAIN VERBOSE
SELECT cos_all() from s3 ORDER BY 1;

-- select cos(*) (stub function, result)
--Testcase 646:
SELECT * FROM (
SELECT cos_all() from s3
) as t ORDER BY 1;

-- select cos(*) (stub function and group by tag only) (explain)
--Testcase 1344:
EXPLAIN VERBOSE
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select cos(*) (stub function and group by tag only) (result)
--Testcase 1345:
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exp (builtin function, explain)
--Testcase 647:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 ORDER BY 1;

-- select exp (builtin function, result)
--Testcase 648:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 ORDER BY 1;

-- select exp (builtin function, not pushdown constraints, explain)
--Testcase 649:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select exp (builtin function, not pushdown constraints, result)
--Testcase 650:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select exp (builtin function, pushdown constraints, explain)
--Testcase 651:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select exp (builtin function, pushdown constraints, result)
--Testcase 652:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select exp as nest function with agg (pushdown, explain)
--Testcase 653:
EXPLAIN VERBOSE
SELECT sum(value3),exp(sum(value3)) FROM s3 ORDER BY 1;

-- select exp as nest function with agg (pushdown, result)
--Testcase 654:
SELECT sum(value3),exp(sum(value3)) FROM s3 ORDER BY 1;

-- select exp as nest with log2 (pushdown, explain)
--Testcase 655:
EXPLAIN VERBOSE
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3 ORDER BY 1;

-- select exp as nest with log2 (pushdown, result)
--Testcase 656:
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3 ORDER BY 1;

-- select exp with non pushdown func and explicit constant (explain)
--Testcase 657:
EXPLAIN VERBOSE
SELECT exp(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select exp with non pushdown func and explicit constant (result)
--Testcase 658:
SELECT exp(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select exp with order by (explain)
--Testcase 659:
EXPLAIN VERBOSE
SELECT value1, exp(1-value1) FROM s3 ORDER BY exp(1-value1);

-- select exp with order by (result)
--Testcase 660:
SELECT value1, exp(1-value1) FROM s3 ORDER BY exp(1-value1);

-- select exp with order by index (result)
--Testcase 661:
SELECT value1, exp(1-value1) FROM s3 ORDER BY 2,1;

-- select exp with order by index (result)
--Testcase 662:
SELECT value1, exp(1-value1) FROM s3 ORDER BY 1,2;

-- select exp and as
--Testcase 663:
SELECT exp(value3) as exp1 FROM s3 ORDER BY 1;

-- select exp(*) (stub function, explain)
--Testcase 664:
EXPLAIN VERBOSE
SELECT exp_all() from s3 ORDER BY 1;

-- select exp(*) (stub function, result)
--Testcase 665:
SELECT * FROM (
SELECT exp_all() from s3
) as t ORDER BY 1;

-- select exp(*) (stub function and group by tag only) (explain)
--Testcase 1346:
EXPLAIN VERBOSE
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select exp(*) (stub function and group by tag only) (result)
--Testcase 1347:
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 666:
--SELECT ceil_all(), cos_all(), exp_all() FROM s3 ORDER BY 1;

-- select floor (builtin function, explain)
--Testcase 667:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 ORDER BY 1;

-- select floor (builtin function, result)
--Testcase 668:
SELECT * FROM (
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select floor (builtin function, not pushdown constraints, explain)
--Testcase 669:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select floor (builtin function, not pushdown constraints, result)
--Testcase 670:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select floor (builtin function, pushdown constraints, explain)
--Testcase 671:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select floor (builtin function, pushdown constraints, result)
--Testcase 672:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select floor as nest function with agg (pushdown, explain)
--Testcase 673:
EXPLAIN VERBOSE
SELECT sum(value3),floor(sum(value3)) FROM s3 ORDER BY 1;

-- select floor as nest function with agg (pushdown, result)
--Testcase 674:
SELECT sum(value3),floor(sum(value3)) FROM s3 ORDER BY 1;

-- select floor as nest with log2 (pushdown, explain)
--Testcase 675:
EXPLAIN VERBOSE
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3 ORDER BY 1;

-- select floor as nest with log2 (pushdown, result)
--Testcase 676:
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3 ORDER BY 1;

-- select floor with non pushdown func and explicit constant (explain)
--Testcase 677:
EXPLAIN VERBOSE
SELECT floor(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select floor with non pushdown func and explicit constant (result)
--Testcase 678:
SELECT * FROM (
SELECT floor(value3), pi(), 4.1 FROM s3
) as t ORDER BY 1;

-- select floor with order by (explain)
--Testcase 679:
EXPLAIN VERBOSE
SELECT value1, floor(1-value1) FROM s3 ORDER BY floor(1-value1);

-- select floor with order by (result)
--Testcase 680:
SELECT value1, floor(1-value1) FROM s3 ORDER BY floor(1-value1);

-- select floor with order by index (result)
--Testcase 681:
SELECT value1, floor(1-value1) FROM s3 ORDER BY 2,1;

-- select floor with order by index (result)
--Testcase 682:
SELECT value1, floor(1-value1) FROM s3 ORDER BY 1,2;

-- select floor and as
--Testcase 683:
SELECT floor(value3) as floor1 FROM s3 ORDER BY 1;

-- select floor(*) (stub function, explain)
--Testcase 684:
EXPLAIN VERBOSE
SELECT floor_all() from s3 ORDER BY 1;

-- select floor(*) (stub function, result)
--Testcase 685:
SELECT * FROM (
SELECT floor_all() from s3
) as t ORDER BY 1;

-- select floor(*) (stub function and group by tag only) (explain)
--Testcase 1348:
EXPLAIN VERBOSE
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select floor(*) (stub function and group by tag only) (result)
--Testcase 1349:
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select floor(*) (stub function, expose data, explain)
--Testcase 686:
EXPLAIN VERBOSE
SELECT (floor_all()::s3).* from s3 ORDER BY 1;

-- select floor(*) (stub function, expose data, result)
--Testcase 687:
SELECT * FROM (
SELECT (floor_all()::s3).* from s3
) as t ORDER BY 1;

-- select ln (builtin function, explain)
--Testcase 688:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 ORDER BY 1;

-- select ln (builtin function, result)
--Testcase 689:
SELECT * FROM (
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select ln (builtin function, not pushdown constraints, explain)
--Testcase 690:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ln (builtin function, not pushdown constraints, result)
--Testcase 691:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select ln (builtin function, pushdown constraints, explain)
--Testcase 692:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ln (builtin function, pushdown constraints, result)
--Testcase 693:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select ln as nest function with agg (pushdown, explain)
--Testcase 694:
EXPLAIN VERBOSE
SELECT sum(value3),ln(sum(value3)) FROM s3 ORDER BY 1;

-- select ln as nest function with agg (pushdown, result)
--Testcase 695:
SELECT sum(value3),ln(sum(value3)) FROM s3 ORDER BY 1;

-- select ln as nest with log2 (pushdown, explain)
--Testcase 696:
EXPLAIN VERBOSE
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ln as nest with log2 (pushdown, result)
--Testcase 697:
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3 ORDER BY 1;

-- select ln with non pushdown func and explicit constant (explain)
--Testcase 698:
EXPLAIN VERBOSE
SELECT ln(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ln with non pushdown func and explicit constant (result)
--Testcase 699:
SELECT ln(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select ln with order by (explain)
--Testcase 700:
EXPLAIN VERBOSE
SELECT value1, ln(1-value1) FROM s3 ORDER BY ln(1-value1);

-- select ln with order by (result)
--Testcase 701:
SELECT value1, ln(1-value1) FROM s3 ORDER BY ln(1-value1);

-- select ln with order by index (result)
--Testcase 702:
SELECT value1, ln(1-value1) FROM s3 ORDER BY 2,1;

-- select ln with order by index (result)
--Testcase 703:
SELECT value1, ln(1-value1) FROM s3 ORDER BY 1,2;

-- select ln and as
--Testcase 704:
SELECT ln(value1) as ln1 FROM s3 ORDER BY 1;

-- select ln(*) (stub function, explain)
--Testcase 705:
EXPLAIN VERBOSE
SELECT ln_all() from s3 ORDER BY 1;

-- select ln(*) (stub function, result)
--Testcase 706:
SELECT * FROM (
SELECT ln_all() from s3
) as t ORDER BY 1;

-- select ln(*) (stub function and group by tag only) (explain)
--Testcase 1350:
EXPLAIN VERBOSE
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select ln(*) (stub function and group by tag only) (result)
--Testcase 1351:
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 707:
--SELECT ln_all(), floor_all() FROM s3 ORDER BY 1;

-- select pow (builtin function, explain)
--Testcase 708:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 ORDER BY 1;

-- select pow (builtin function, result)
--Testcase 709:
SELECT * FROM (
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select pow (builtin function, not pushdown constraints, explain)
--Testcase 710:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select pow (builtin function, not pushdown constraints, result)
--Testcase 711:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select pow (builtin function, pushdown constraints, explain)
--Testcase 712:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select pow (builtin function, pushdown constraints, result)
--Testcase 713:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select pow as nest function with agg (pushdown, explain)
--Testcase 714:
EXPLAIN VERBOSE
SELECT sum(value3),pow(sum(value3), 2) FROM s3 ORDER BY 1;

-- select pow as nest function with agg (pushdown, result)
--Testcase 715:
SELECT sum(value3),pow(sum(value3), 2) FROM s3 ORDER BY 1;

-- select pow as nest with log2 (pushdown, explain)
--Testcase 716:
EXPLAIN VERBOSE
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3 ORDER BY 1;

-- select pow as nest with log2 (pushdown, result)
--Testcase 717:
SELECT * FROM (
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3
) as t ORDER BY 1;

-- select pow with non pushdown func and explicit constant (explain)
--Testcase 718:
EXPLAIN VERBOSE
SELECT pow(value3, 2), pi(), 4.1 FROM s3 ORDER BY 1;

-- select pow with non pushdown func and explicit constant (result)
--Testcase 719:
SELECT pow(value3, 2), pi(), 4.1 FROM s3 ORDER BY 1;

-- select pow with order by (explain)
--Testcase 720:
EXPLAIN VERBOSE
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY pow(1-value1, 2);

-- select pow with order by (result)
--Testcase 721:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY pow(1-value1, 2);

-- select pow with order by index (result)
--Testcase 722:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY 2,1;

-- select pow with order by index (result)
--Testcase 723:
SELECT value1, pow(1-value1, 2) FROM s3 ORDER BY 1,2;

-- select pow and as
--Testcase 724:
SELECT * FROM (
SELECT pow(value3, 2) as pow1 FROM s3
) as t ORDER BY 1;

-- select pow_all(2) (stub function, explain)
--Testcase 725:
EXPLAIN VERBOSE
SELECT pow_all(2) from s3 ORDER BY 1;

-- select pow_all(2) (stub function, result)
--Testcase 726:
SELECT * FROM (
SELECT pow_all(2) from s3
) as t ORDER BY 1;

-- select pow_all(2) (stub function and group by tag only) (explain)
--Testcase 1352:
EXPLAIN VERBOSE
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select pow_all(2) (stub function and group by tag only) (result)
--Testcase 1353:
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select pow_all(2) (stub function, expose data, explain)
--Testcase 727:
EXPLAIN VERBOSE
SELECT (pow_all(2)::s3).* from s3 ORDER BY 1;

-- select pow_all(2) (stub function, expose data, result)
--Testcase 728:
SELECT * FROM (
SELECT (pow_all(2)::s3).* from s3
) as t ORDER BY 1;

-- select round (builtin function, explain)
--Testcase 729:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 ORDER BY 1;

-- select round (builtin function, result)
--Testcase 730:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 ORDER BY 1;

-- select round (builtin function, not pushdown constraints, explain)
--Testcase 731:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select round (builtin function, not pushdown constraints, result)
--Testcase 732:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select round (builtin function, pushdown constraints, explain)
--Testcase 733:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select round (builtin function, pushdown constraints, result)
--Testcase 734:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select round as nest function with agg (pushdown, explain)
--Testcase 735:
EXPLAIN VERBOSE
SELECT sum(value3),round(sum(value3)) FROM s3 ORDER BY 1;

-- select round as nest function with agg (pushdown, result)
--Testcase 736:
SELECT sum(value3),round(sum(value3)) FROM s3 ORDER BY 1;

-- select round as nest with log2 (pushdown, explain)
--Testcase 737:
EXPLAIN VERBOSE
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3 ORDER BY 1;

-- select round as nest with log2 (pushdown, result)
--Testcase 738:
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3 ORDER BY 1;

-- select round with non pushdown func and roundlicit constant (explain)
--Testcase 739:
EXPLAIN VERBOSE
SELECT round(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select round with non pushdown func and roundlicit constant (result)
--Testcase 740:
SELECT round(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select round with order by (explain)
--Testcase 741:
EXPLAIN VERBOSE
SELECT value1, round(1-value1) FROM s3 ORDER BY round(1-value1);

-- select round with order by (result)
--Testcase 742:
SELECT value1, round(1-value1) FROM s3 ORDER BY round(1-value1);

-- select round with order by index (result)
--Testcase 743:
SELECT value1, round(1-value1) FROM s3 ORDER BY 2,1;

-- select round with order by index (result)
--Testcase 744:
SELECT value1, round(1-value1) FROM s3 ORDER BY 1,2;

-- select round and as
--Testcase 745:
SELECT round(value3) as round1 FROM s3 ORDER BY 1;

-- select round(*) (stub function, explain)
--Testcase 746:
EXPLAIN VERBOSE
SELECT round_all() from s3 ORDER BY 1;

-- select round(*) (stub function, result)
--Testcase 747:
SELECT * FROM (
SELECT round_all() from s3
) as t ORDER BY 1;

-- select round(*) (stub function and group by tag only) (explain)
--Testcase 1354:
EXPLAIN VERBOSE
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select round(*) (stub function and group by tag only) (result)
--Testcase 1355:
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select round(*) (stub function, expose data, explain)
--Testcase 748:
EXPLAIN VERBOSE
SELECT (round_all()::s3).* from s3 ORDER BY 1;

-- select round(*) (stub function, expose data, result)
--Testcase 749:
SELECT * FROM (
SELECT (round_all()::s3).* from s3
) as t ORDER BY 1;

-- select sin (builtin function, explain)
--Testcase 750:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 ORDER BY 1;

-- select sin (builtin function, result)
--Testcase 751:
SELECT * FROM (
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3
) as t ORDER BY 1, 2, 3, 4;

-- select sin (builtin function, not pushdown constraints, explain)
--Testcase 752:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sin (builtin function, not pushdown constraints, result)
--Testcase 753:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sin (builtin function, pushdown constraints, explain)
--Testcase 754:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sin (builtin function, pushdown constraints, result)
--Testcase 755:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sin as nest function with agg (pushdown, explain)
--Testcase 756:
EXPLAIN VERBOSE
SELECT sum(value3),sin(sum(value3)) FROM s3 ORDER BY 1;

-- select sin as nest function with agg (pushdown, result)
--Testcase 757:
SELECT sum(value3),sin(sum(value3)) FROM s3 ORDER BY 1;

-- select sin as nest with log2 (pushdown, explain)
--Testcase 758:
EXPLAIN VERBOSE
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select sin as nest with log2 (pushdown, result)
--Testcase 759:
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3 ORDER BY 1;

-- select sin with non pushdown func and explicit constant (explain)
--Testcase 760:
EXPLAIN VERBOSE
SELECT sin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sin with non pushdown func and explicit constant (result)
--Testcase 761:
SELECT sin(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sin with order by (explain)
--Testcase 762:
EXPLAIN VERBOSE
SELECT value1, sin(1-value1) FROM s3 ORDER BY sin(1-value1);

-- select sin with order by (result)
--Testcase 763:
SELECT value1, sin(1-value1) FROM s3 ORDER BY sin(1-value1);

-- select sin with order by index (result)
--Testcase 764:
SELECT value1, sin(1-value1) FROM s3 ORDER BY 2,1;

-- select sin with order by index (result)
--Testcase 765:
SELECT value1, sin(1-value1) FROM s3 ORDER BY 1,2;

-- select sin and as
--Testcase 766:
SELECT sin(value3) as sin1 FROM s3 ORDER BY 1;

-- select sin(*) (stub function, explain)
--Testcase 767:
EXPLAIN VERBOSE
SELECT sin_all() from s3 ORDER BY 1;

-- select sin(*) (stub function, result)
--Testcase 768:
SELECT * FROM (
SELECT sin_all() from s3
) as t ORDER BY 1;

-- select sin(*) (stub function and group by tag only) (explain)
--Testcase 1356:
EXPLAIN VERBOSE
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select sin(*) (stub function and group by tag only) (result)
--Testcase 1357:
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select tan (builtin function, explain)
--Testcase 769:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 ORDER BY 1;

-- select tan (builtin function, result)
--Testcase 770:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 ORDER BY 1;

-- select tan (builtin function, not pushdown constraints, explain)
--Testcase 771:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select tan (builtin function, not pushdown constraints, result)
--Testcase 772:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select tan (builtin function, pushdown constraints, explain)
--Testcase 773:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select tan (builtin function, pushdown constraints, result)
--Testcase 774:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select tan as nest function with agg (pushdown, explain)
--Testcase 775:
EXPLAIN VERBOSE
SELECT sum(value3),tan(sum(value3)) FROM s3 ORDER BY 1;

-- select tan as nest function with agg (pushdown, result)
--Testcase 776:
SELECT sum(value3),tan(sum(value3)) FROM s3 ORDER BY 1;

-- select tan as nest with log2 (pushdown, explain)
--Testcase 777:
EXPLAIN VERBOSE
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3 ORDER BY 1;

-- select tan as nest with log2 (pushdown, result)
--Testcase 778:
SELECT * FROM (
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3
) as t ORDER BY 1, 2;

-- select tan with non pushdown func and tanlicit constant (explain)
--Testcase 779:
EXPLAIN VERBOSE
SELECT tan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select tan with non pushdown func and tanlicit constant (result)
--Testcase 780:
SELECT tan(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select tan with order by (explain)
--Testcase 781:
EXPLAIN VERBOSE
SELECT value1, tan(1-value1) FROM s3 ORDER BY tan(1-value1);

-- select tan with order by (result)
--Testcase 782:
SELECT value1, tan(1-value1) FROM s3 ORDER BY tan(1-value1);

-- select tan with order by index (result)
--Testcase 783:
SELECT value1, tan(1-value1) FROM s3 ORDER BY 2,1;

-- select tan with order by index (result)
--Testcase 784:
SELECT value1, tan(1-value1) FROM s3 ORDER BY 1,2;

-- select tan and as
--Testcase 785:
SELECT tan(value3) as tan1 FROM s3 ORDER BY 1;

-- select tan(*) (stub function, explain)
--Testcase 786:
EXPLAIN VERBOSE
SELECT tan_all() from s3 ORDER BY 1;

-- select tan(*) (stub function, result)
--Testcase 787:
SELECT * FROM (
SELECT tan_all() from s3
) as t ORDER BY 1;

-- select tan(*) (stub function and group by tag only) (explain)
--Testcase 1358:
EXPLAIN VERBOSE
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select tan(*) (stub function and group by tag only) (result)
--Testcase 1359:
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 788:
--SELECT sin_all(), round_all(), tan_all() FROM s3 ORDER BY 1;

-- select predictors function holt_winters() (explain)
--Testcase 789:
EXPLAIN VERBOSE
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters() (result)
--Testcase 790:
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters_with_fit() (explain)
--Testcase 791:
EXPLAIN VERBOSE
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select predictors function holt_winters_with_fit() (result)
--Testcase 792:
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s') ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function, explain)
--Testcase 793:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function, result)
--Testcase 794:
SELECT influx_count_all(*) FROM s3 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (explain)
--Testcase 795:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (result)
--Testcase 796:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (explain)
--Testcase 797:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (result)
--Testcase 798:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select count(*) function of InfluxDB over join query (explain)
--Testcase 799:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select count(*) function of InfluxDB over join query (result, stub call error)
--Testcase 800:
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct (stub agg function, explain)
--Testcase 801:
EXPLAIN VERBOSE
SELECT influx_distinct(value1) FROM s3 ORDER BY 1;

-- select distinct (stub agg function, result)
--Testcase 802:
SELECT influx_distinct(value1) FROM s3 ORDER BY 1;

-- select distinct (stub agg function and group by influx_time() and tag) (explain)
--Testcase 803:
EXPLAIN VERBOSE
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select distinct (stub agg function and group by influx_time() and tag) (result)
--Testcase 804:
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1 ORDER BY 1;

-- select distinct (stub agg function and group by tag only) (explain)
--Testcase 805:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select distinct (stub agg function and group by tag only) (result)
--Testcase 806:
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1;

-- select distinct over join query (explain)
--Testcase 807:
EXPLAIN VERBOSE
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct over join query (result, stub call error)
--Testcase 808:
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1 ORDER BY 1;

-- select distinct with having (explain)
--Testcase 809:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100 ORDER BY 1;

-- select distinct with having (result, not pushdown, stub call error)
--Testcase 810:
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100 ORDER BY 1;

--Testcase 811:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 812:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 813:
DROP SERVER pgspider_svr2;

--Testcase 814:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 815:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 816:
DROP SERVER pgspider_svr1;
--Testcase 817:
DROP EXTENSION pgspider_fdw;
--Testcase 818:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: sqlite

--Testcase 819:
CREATE FOREIGN TABLE s3 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 820:
CREATE EXTENSION pgspider_fdw;
--Testcase 821:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 822:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 823:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr1 OPTIONS (table_name 's31sqlite');

--Testcase 824:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 825:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 826:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr2 OPTIONS (table_name 's32sqlite');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 827:
\d s3;
--Testcase 828:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- select abs (builtin function, explain)
--Testcase 829:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1;

-- select abs (buitin function, result)
--Testcase 830:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 831:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 832:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 833:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 834:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 835:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 836:
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 837:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 838:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select abs with order by (explain)
--Testcase 839:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 840:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 841:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 842:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 843:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 844:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 845:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 846:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 847:
SELECT * FROM (
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1
) AS t ORDER BY 1,2,3;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 848:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 849:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- sqlite pushdown supported functions (explain)
--Testcase 850:
EXPLAIN VERBOSE
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3 ORDER BY 1;

-- sqlite pushdown supported functions (result)
--Testcase 851:
SELECT * FROM (
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3
) AS t ORDER BY 1,2,3,4,5,6,7,8,9,10;

--Testcase 852:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 853:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 854:
DROP SERVER pgspider_svr2;

--Testcase 855:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 856:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 857:
DROP SERVER pgspider_svr1;
--Testcase 858:
DROP EXTENSION pgspider_fdw;
--Testcase 859:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: mysql

--Testcase 860:
CREATE FOREIGN TABLE s3 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 861:
CREATE FOREIGN TABLE ftextsearch (id int, content text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 862:
CREATE EXTENSION pgspider_fdw;
--Testcase 863:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');

--Testcase 864:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 865:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr1 OPTIONS (table_name 's31mysql');

--Testcase 866:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 867:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 868:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_svr2 OPTIONS (table_name 's32mysql');

--Testcase 869:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr1__0 (id int, content text) SERVER pgspider_svr1 OPTIONS (table_name 'ftextsearch1');
--Testcase 870:
CREATE FOREIGN TABLE ftextsearch__pgspider_svr2__0 (id int, content text) SERVER pgspider_svr2 OPTIONS (table_name 'ftextsearch2');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 871:
\d s3;
--Testcase 872:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 873:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3 ORDER BY 1;

-- select float8() (not pushdown, remove float8, result)
--Testcase 874:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 875:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 ORDER BY 1;

-- select sqrt (buitin function, result)
--Testcase 876:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 877:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 878:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 879:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 880:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 881:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 ORDER BY 1;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 882:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 883:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64' ORDER BY 1;

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 884:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 885:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200 ORDER BY 1;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 886:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base), mysql (base, v)
--Testcase 887:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 888:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 889:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 890:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 891:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 892:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 893:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1 ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 894:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 895:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3 ORDER BY 1;

-- select abs as nest function with agg (pushdown, result)
--Testcase 896:
SELECT * FROM (
SELECT sum(value3),abs(sum(value3)) FROM s3
) AS t ORDER BY 1;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 897:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3 ORDER BY 1;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 898:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 899:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3 ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 900:
SELECT * FROM (
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3
) AS t ORDER BY 1;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 901:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3 ORDER BY 1;

-- select abs with order by (explain)
--Testcase 902:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 903:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 904:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 905:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 906:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 907:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3 ORDER BY 1;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 908:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 909:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 910:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 911:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3 ORDER BY 1;

-- select mixing with non pushdown func (result)
--Testcase 912:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3
) AS t ORDER BY 1,2,3;

-- full text search table

-- text search (pushdown, explain)
--Testcase 913:
EXPLAIN VERBOSE
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0 ORDER BY 1;

-- text search (pushdown, result)
--Testcase 914:
SELECT content FROM (
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0
       ) AS t ORDER BY 1;

--Testcase 915:
DROP FOREIGN TABLE ftextsearch__pgspider_svr1__0;
--Testcase 916:
DROP FOREIGN TABLE ftextsearch__pgspider_svr2__0;
--Testcase 917:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 918:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 919:
DROP SERVER pgspider_svr2;

--Testcase 920:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 921:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 922:
DROP SERVER pgspider_svr1;

--Testcase 923:
DROP EXTENSION pgspider_fdw;

--Testcase 924:
DROP FOREIGN TABLE ftextsearch;
--Testcase 925:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: griddb

--Testcase 926:
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

--Testcase 927:
CREATE EXTENSION pgspider_fdw;
--Testcase 928:
CREATE SERVER pgspider_svr1 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5433', dbname 'postgres');
--Testcase 929:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 930:
CREATE FOREIGN TABLE s3__pgspider_svr1__0 (
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
) SERVER pgspider_svr1 OPTIONS(table_name 's31griddb');

--Testcase 931:
CREATE SERVER pgspider_svr2 FOREIGN DATA WRAPPER pgspider_fdw OPTIONS (host '127.0.0.1', port '5434', dbname 'postgres');
--Testcase 932:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 933:
CREATE FOREIGN TABLE s3__pgspider_svr2__0 (
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
) SERVER pgspider_svr2 OPTIONS(table_name 's32griddb');

--Test foreign table
--Testcase 934:
\d s3;
--Testcase 935:
SELECT * FROM s3 ORDER BY 1,2;

--
-- Test for non-unique functions of GridDB in WHERE clause
--
-- char_length
--Testcase 936:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) > 4 ORDER BY 1;
--Testcase 937:
SELECT * FROM s3 WHERE char_length(name) > 4 ORDER BY 1;
--Testcase 938:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) < 6 ORDER BY 1;
--Testcase 939:
SELECT * FROM s3 WHERE char_length(name) < 6 ORDER BY 1;

--Testcase 940:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george' ORDER BY 1;
--Testcase 941:
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george' ORDER BY 1;

--substr
--Testcase 942:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,2,3) = 'red' ORDER BY 1;
--Testcase 943:
SELECT * FROM s3 WHERE substr(name,2,3) = 'red' ORDER BY 1;
--Testcase 944:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre' ORDER BY 1;
--Testcase 945:
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre' ORDER BY 1;

--upper
--Testcase 946:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) = 'FRED' ORDER BY 1;
--Testcase 947:
SELECT * FROM s3 WHERE upper(name) = 'FRED' ORDER BY 1;
--Testcase 948:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) <> 'FRED' ORDER BY 1;
--Testcase 949:
SELECT * FROM s3 WHERE upper(name) <> 'FRED' ORDER BY 1;

--lower
--Testcase 950:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 951:
SELECT * FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 952:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) <> 'bob' ORDER BY 1;
--Testcase 953:
SELECT * FROM s3 WHERE lower(name) <> 'bob' ORDER BY 1;

--round
--Testcase 954:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 955:
SELECT * FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 956:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) <= 3 ORDER BY 1;
--Testcase 957:
SELECT * FROM s3 WHERE round(gpa) <= 3 ORDER BY 1;

--floor
--Testcase 958:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) = 3 ORDER BY 1;
--Testcase 959:
SELECT * FROM s3 WHERE floor(gpa) = 3 ORDER BY 1;
--Testcase 960:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) < 2 ORDER BY 1;
--Testcase 961:
SELECT * FROM s3 WHERE floor(gpa) < 3 ORDER BY 1;

--ceiling
--Testcase 962:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) >= 3 ORDER BY 1;
--Testcase 963:
SELECT * FROM s3 WHERE ceiling(gpa) >= 3 ORDER BY 1;
--Testcase 964:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) = 4 ORDER BY 1;
--Testcase 965:
SELECT * FROM s3 WHERE ceiling(gpa) = 4 ORDER BY 1;

--
--Test for unique functions of GridDB in WHERE clause: time functions
--
--griddb_timestamp: push down timestamp function to GridDB
--Testcase 966:
EXPLAIN VERBOSE
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00' ORDER BY 1;
--Testcase 967:
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00' ORDER BY 1;
--Testcase 968:
EXPLAIN VERBOSE
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol) ORDER BY 1;
--Testcase 969:
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol) ORDER BY 1;
--griddb_timestamp: push down timestamp function to GridDB and gets error because GridDB only support YYYY-MM-DDThh:mm:ss.SSSZ format for timestamp function
--UPDATE time_series2__griddb_svr__0 SET strcol = '2020-01-05 21:00:00';
--EXPLAIN VERBOSE
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';

--timestampadd
--YEAR
--Testcase 970:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00' ORDER BY 1;
--Testcase 971:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00' ORDER BY 1;
--Testcase 972:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00' ORDER BY 1;
--Testcase 973:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00' ORDER BY 1;
--Testcase 974:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29' ORDER BY 1;
--Testcase 975:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29' ORDER BY 1;
--MONTH
--Testcase 976:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 977:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 978:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30' ORDER BY 1;
--Testcase 979:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30' ORDER BY 1;
--Testcase 980:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29' ORDER BY 1;
--Testcase 981:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29' ORDER BY 1;
--DAY
--Testcase 982:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 983:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00' ORDER BY 1;
--Testcase 984:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30' ORDER BY 1;
--Testcase 985:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30' ORDER BY 1;
--Testcase 986:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01' ORDER BY 1;
--Testcase 987:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01' ORDER BY 1;
--HOUR
--Testcase 988:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 989:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 990:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00' ORDER BY 1;
--Testcase 991:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00' ORDER BY 1;
--MINUTE
--Testcase 992:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00' ORDER BY 1;
--Testcase 993:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00' ORDER BY 1;
--Testcase 994:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 995:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--SECOND
--Testcase 996:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30' ORDER BY 1;
--Testcase 997:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30' ORDER BY 1;
--Testcase 998:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -50) <= '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 999:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -30) = '2020-12-29 05:00:00' ORDER BY 1;
--MILLISECOND
--Testcase 1000:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420' ORDER BY 1;
--Testcase 1001:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420' ORDER BY 1;
--Testcase 1002:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;
--Testcase 1003:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;
--Input wrong unit
--Testcase 1004:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MICROSECOND', date1, -55) = '2020-12-29 05:10:00.065' ORDER BY 1;

--timestampdiff
--YEAR
--Testcase 1005:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0 ORDER BY 1;
--Testcase 1006:
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0 ORDER BY 1;
--Testcase 1007:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1008:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1009:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10 ORDER BY 1;
--Testcase 1010:
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10 ORDER BY 1;
--MONTH
--Testcase 1011:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1 ORDER BY 1;
--Testcase 1012:
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1 ORDER BY 1;
--Testcase 1013:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1014:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1015:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10 ORDER BY 1;
--Testcase 1016:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10 ORDER BY 1;
--DAY
--Testcase 1017:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1018:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1019:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1020:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1021:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10 ORDER BY 1;
--Testcase 1022:
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10 ORDER BY 1;
--HOUR
--Testcase 1023:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0 ORDER BY 1;
--Testcase 1024:
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0 ORDER BY 1;
--Testcase 1025:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5 ORDER BY 1;
--Testcase 1026:
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5 ORDER BY 1;
--Testcase 1027:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10 ORDER BY 1;
--Testcase 1028:
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10 ORDER BY 1;
--MINUTE
--Testcase 1029:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1030:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1031:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1032:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1033:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10 ORDER BY 1;
--Testcase 1034:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10 ORDER BY 1;
--SECOND
--Testcase 1035:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000 ORDER BY 1;
--Testcase 1036:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000 ORDER BY 1;
--Testcase 1037:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100 ORDER BY 1;
--Testcase 1038:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100 ORDER BY 1;
--Testcase 1039:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000 ORDER BY 1;
--Testcase 1040:
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000 ORDER BY 1;
--MILLISECOND
--Testcase 1041:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200 ORDER BY 1;
--Testcase 1042:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200 ORDER BY 1;
--Testcase 1043:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0 ORDER BY 1;
--Testcase 1044:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0 ORDER BY 1;
--Testcase 1045:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443 ORDER BY 1;
--Testcase 1046:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443 ORDER BY 1;
--Input wrong unit
--Testcase 1047:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MICROSECOND', date2, '2020-12-04 08:48:00') > 20 ORDER BY 1;
--Testcase 1048:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DECADE', '2020-02-15 08:48:00', date2) < 5 ORDER BY 1;
--Testcase 1049:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('NANOSECOND', date1, date2) > 10 ORDER BY 1;

--to_timestamp_ms
--Normal case
--Testcase 1050:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;
--Testcase 1051:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;
--Return error if column contains -1 value
--Testcase 1052:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00' ORDER BY 1;

--to_epoch_ms
--Testcase 1053:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1) ORDER BY 1;
--Testcase 1054:
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1) ORDER BY 1;
--Testcase 1055:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE to_epoch_ms(date2) < 1000000000000 ORDER BY 1;

--
--Test for unique functions of GridDB in WHERE clause: array functions
--
--array_length
--Testcase 1056:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3 ORDER BY 1;
--Testcase 1057:
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3 ORDER BY 1;
--Testcase 1058:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3 ORDER BY 1;
--Testcase 1059:
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3 ORDER BY 1;
--Testcase 1060:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray) ORDER BY 1;
--Testcase 1061:
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray) ORDER BY 1;
--Testcase 1062:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray) ORDER BY 1;
--Testcase 1063:
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray) ORDER BY 1;
--Testcase 1064:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0 ORDER BY 1;
--Testcase 1065:
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0 ORDER BY 1;
--Testcase 1066:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3 ORDER BY 1;
--Testcase 1067:
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3 ORDER BY 1;

--element
--Normal case
--Testcase 1068:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f' ORDER BY 1;
--Testcase 1069:
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f' ORDER BY 1;
--Testcase 1070:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb' ORDER BY 1;
--Testcase 1071:
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb' ORDER BY 1;
--Testcase 1072:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray) ORDER BY 1;
--Testcase 1073:
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray) ORDER BY 1;
--Testcase 1074:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray) ORDER BY 1;
--Testcase 1075:
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray) ORDER BY 1;
--Testcase 1076:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray) ORDER BY 1;
--Testcase 1077:
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray) ORDER BY 1;
--Testcase 1078:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1079:
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Return error when getting non-existent element
--Testcase 1080:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;
--Testcase 1081:
--SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00' ORDER BY 1;

--
--if user selects non-unique functions which Griddb only supports in WHERE clause => do not push down
--if user selects unique functions which Griddb only supports in WHERE clause => still push down, return error of Griddb
--
--Testcase 1082:
EXPLAIN VERBOSE
SELECT char_length(name) FROM s3 ORDER BY 1;
--Testcase 1083:
SELECT char_length(name) FROM s3 ORDER BY 1;
--Testcase 1084:
EXPLAIN VERBOSE
SELECT concat(name,'abc') FROM s3 ORDER BY 1;
--Testcase 1085:
SELECT concat(name,'abc') FROM s3 ORDER BY 1;
--Testcase 1086:
EXPLAIN VERBOSE
SELECT substr(name,2,3) FROM s3 ORDER BY 1;
--Testcase 1087:
SELECT substr(name,2,3) FROM s3 ORDER BY 1;
--Testcase 1088:
EXPLAIN VERBOSE
SELECT element(1, timestamparray) FROM s3 ORDER BY 1;
--Testcase 1089:
--SELECT element(1, timestamparray) FROM s3 ORDER BY 1;
--Testcase 1090:
EXPLAIN VERBOSE
SELECT upper(name) FROM s3 ORDER BY 1;
--Testcase 1091:
SELECT upper(name) FROM s3 ORDER BY 1;
--Testcase 1092:
EXPLAIN VERBOSE
SELECT lower(name) FROM s3 ORDER BY 1;
--Testcase 1093:
SELECT lower(name) FROM s3 ORDER BY 1;
--Testcase 1094:
EXPLAIN VERBOSE
SELECT round(gpa) FROM s3 ORDER BY 1;
--Testcase 1095:
SELECT round(gpa) FROM s3 ORDER BY 1;
--Testcase 1096:
EXPLAIN VERBOSE
SELECT floor(gpa) FROM s3 ORDER BY 1;
--Testcase 1097:
SELECT floor(gpa) FROM s3 ORDER BY 1;
--Testcase 1098:
EXPLAIN VERBOSE
SELECT ceiling(gpa) FROM s3 ORDER BY 1;
--Testcase 1099:
SELECT ceiling(gpa) FROM s3 ORDER BY 1;
--Testcase 1100:
EXPLAIN VERBOSE
SELECT griddb_timestamp(strcol) FROM s3 ORDER BY 1;
--Testcase 1101:
--SELECT griddb_timestamp(strcol) FROM s3 ORDER BY 1;
--Testcase 1102:
EXPLAIN VERBOSE
SELECT timestampadd('YEAR', date1, -1) FROM s3 ORDER BY 1;
--Testcase 1103:
--SELECT timestampadd('YEAR', date1, -1) FROM s3 ORDER BY 1;
--Testcase 1104:
EXPLAIN VERBOSE
SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3 ORDER BY 1;
--Testcase 1105:
--SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3 ORDER BY 1;
--Testcase 1106:
EXPLAIN VERBOSE
SELECT to_timestamp_ms(intcol) FROM s3 ORDER BY 1;
--Testcase 1107:
--SELECT to_timestamp_ms(intcol) FROM s3 ORDER BY 1;
--Testcase 1108:
EXPLAIN VERBOSE
SELECT to_epoch_ms(date1) FROM s3 ORDER BY 1;
--Testcase 1109:
--SELECT to_epoch_ms(date1) FROM s3 ORDER BY 1;
--Testcase 1110:
EXPLAIN VERBOSE
SELECT array_length(boolarray) FROM s3 ORDER BY 1;
--Testcase 1111:
--SELECT array_length(boolarray) FROM s3 ORDER BY 1;
--Testcase 1112:
EXPLAIN VERBOSE
SELECT element(1, stringarray) FROM s3 ORDER BY 1;
--Testcase 1113:
--SELECT element(1, stringarray) FROM s3 ORDER BY 1;

--
--Test for unique functions of GridDB in SELECT clause: time-series functions
--
--time_next
--specified time exist => return that row
--Testcase 1114:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--Testcase 1115:
SELECT time_next('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1116:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1117:
SELECT time_next('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist, there is no time after the specified time => return no row
--Testcase 1118:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1119:
SELECT time_next('2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_next_only
--even though specified time exist, still return the row whose time is immediately after the specified time
--Testcase 1120:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--Testcase 1121:
SELECT time_next_only('2018-12-01 10:00:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1122:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1123:
SELECT time_next_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--there is no time after the specified time => return no row
--Testcase 1124:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1125:
SELECT time_next_only('2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_prev
--specified time exist => return that row
--Testcase 1126:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1127:
SELECT time_prev('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1128:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1129:
SELECT time_prev('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist, there is no time before the specified time => return no row
--Testcase 1130:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 09:45:00') FROM s3 ORDER BY 1;
--Testcase 1131:
SELECT time_prev('2018-12-01 09:45:00') FROM s3 ORDER BY 1;

--time_prev_only
--even though specified time exist, still return the row whose time is immediately before the specified time
--Testcase 1132:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1133:
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1134:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1135:
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--there is no time before the specified time => return no row
--Testcase 1136:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3 ORDER BY 1;
--Testcase 1137:
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3 ORDER BY 1;

--time_interpolated
--specified time exist => return that row
--Testcase 1138:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--Testcase 1139:
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3 ORDER BY 1;
--specified time does not exist => return the row which has interpolated value.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1140:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--Testcase 1141:
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3 ORDER BY 1;
--specified time does not exist. There is no row before or after the specified time => can not calculate interpolated value, return no row.
--Testcase 1142:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3 ORDER BY 1;
--Testcase 1143:
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3 ORDER BY 1;
--Testcase 1144:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3 ORDER BY 1;
--Testcase 1145:
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3 ORDER BY 1;

--time_sampling by MINUTE
--rows for sampling exists => return those rows
--Testcase 1146:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1147:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1148:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1149:
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1150:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1151:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1152:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--Testcase 1153:
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--UPDATE time_series__griddb_svr__0 SET value1 = 5 where date = '2018-12-01 10:40:00';
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;

--time_sampling by HOUR
--rows for sampling exists => return those rows
--Testcase 1154:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1155:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1156:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1157:
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1158:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1159:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1160:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--Testcase 1161:
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;

--time_sampling by DAY
--rows for sampling exists => return those rows
--Testcase 1162:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1163:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1164:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1165:
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1166:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1167:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1168:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--Testcase 1169:
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 6;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3;
--Testcase 1170:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3 ORDER BY 1;

--time_sampling by SECOND
--rows for sampling exists => return those rows
--Testcase 1171:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1172:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1173:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1174:
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1175:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1176:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1177:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3 ORDER BY 1;
--Testcase 1178:
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;

--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;

--time_sampling by MILLISECOND
--rows for sampling exists => return those rows
--Testcase 1179:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1180:
--SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1181:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1182:
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3 ORDER BY 1;
--mix exist and non-exist sampling
--Testcase 1183:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1184:
--SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3 ORDER BY 1;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1185:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--Testcase 1186:
--SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3 ORDER BY 1;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;

--max_rows
--Testcase 1187:
EXPLAIN VERBOSE
SELECT max_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1188:
SELECT max_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1189:
EXPLAIN VERBOSE
SELECT max_rows(date) FROM s3 ORDER BY 1;
--Testcase 1190:
SELECT max_rows(date) FROM s3 ORDER BY 1;

--min_rows
--Testcase 1191:
EXPLAIN VERBOSE
SELECT min_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1192:
SELECT min_rows(value2) FROM s3 ORDER BY 1;
--Testcase 1193:
EXPLAIN VERBOSE
SELECT min_rows(date) FROM s3 ORDER BY 1;
--Testcase 1194:
SELECT min_rows(date) FROM s3 ORDER BY 1;

--
--if WHERE clause contains functions which Griddb only supports in SELECT clause => still push down, return error of Griddb
--
--Testcase 1195:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1196:
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1197:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00') ORDER BY 1;
--Testcase 1198:
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00') ORDER BY 1;
--Testcase 1199:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1200:
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"' ORDER BY 1;
--Testcase 1201:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') ORDER BY 1;
--Testcase 1202:
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') ORDER BY 1;
--Testcase 1203:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2) ORDER BY 1;
--Testcase 1204:
--SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2) ORDER BY 1;

--
-- Test syntax (xxx()::s3).*
--
--Testcase 1205:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3 ORDER BY 1;
--Testcase 1206:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3 ORDER BY 1;
--Testcase 1207:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3 ORDER BY 1;
--Testcase 1208:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3 ORDER BY 1;
--Testcase 1209:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3 ORDER BY 1;
--Testcase 1210:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3 ORDER BY 1;

--
-- Test aggregate function time_avg
--
--Testcase 1211:
EXPLAIN VERBOSE
SELECT time_avg(value1) FROM s3 ORDER BY 1;
--Testcase 1212:
SELECT time_avg(value1) FROM s3 ORDER BY 1;
--Testcase 1213:
EXPLAIN VERBOSE
SELECT time_avg(value2) FROM s3 ORDER BY 1;
--Testcase 1214:
SELECT time_avg(value2) FROM s3 ORDER BY 1;
-- GridDB does not support select multiple target in a query => do not push down, raise stub function error
--Testcase 1215:
EXPLAIN VERBOSE
SELECT time_avg(value1), time_avg(value2) FROM s3 ORDER BY 1;
--Testcase 1216:
--SELECT time_avg(value1), time_avg(value2) FROM s3 ORDER BY 1;
-- Do not push down when expected type is not correct, raise stub function error
--Testcase 1217:
EXPLAIN VERBOSE
SELECT time_avg(date) FROM s3 ORDER BY 1;
--Testcase 1218:
--SELECT time_avg(date) FROM s3 ORDER BY 1;
--Testcase 1219:
EXPLAIN VERBOSE
SELECT time_avg(blobcol) FROM s3 ORDER BY 1;
--Testcase 1220:
--SELECT time_avg(blobcol) FROM s3 ORDER BY 1;

--
-- Test aggregate function min, max, count, sum, avg, variance, stddev
--
--Testcase 1221:
EXPLAIN VERBOSE
SELECT min(age) FROM s3 ORDER BY 1;
--Testcase 1222:
SELECT min(age) FROM s3 ORDER BY 1;

--Testcase 1223:
EXPLAIN VERBOSE
SELECT max(gpa) FROM s3 ORDER BY 1;
--Testcase 1224:
SELECT max(gpa) FROM s3 ORDER BY 1;

--Testcase 1225:
EXPLAIN VERBOSE
SELECT count(*) FROM s3 ORDER BY 1;
--Testcase 1226:
SELECT count(*) FROM s3 ORDER BY 1;
--Testcase 1227:
EXPLAIN VERBOSE
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42 ORDER BY 1;
--Testcase 1228:
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42 ORDER BY 1;

--Testcase 1229:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3 ORDER BY 1;
--Testcase 1230:
SELECT sum(age) FROM s3 ORDER BY 1;
--Testcase 1231:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;
--Testcase 1232:
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5 ORDER BY 1;

--Testcase 1233:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3 ORDER BY 1;
--Testcase 1234:
SELECT avg(gpa) FROM s3 ORDER BY 1;
--Testcase 1235:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george' ORDER BY 1;
--Testcase 1236:
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george' ORDER BY 1;

--Testcase 1237:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3 ORDER BY 1;
--Testcase 1238:
SELECT variance(gpa) FROM s3 ORDER BY 1;
--Testcase 1239:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5 ORDER BY 1;
--Testcase 1240:
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5 ORDER BY 1;

--Testcase 1241:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3 ORDER BY 1;
--Testcase 1242:
SELECT stddev(age) FROM s3 ORDER BY 1;
--Testcase 1243:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4 ORDER BY 1;
--Testcase 1244:
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4 ORDER BY 1;

--Testcase 1245:
EXPLAIN VERBOSE
SELECT max(gpa), min(age) FROM s3 ORDER BY 1;
--Testcase 1246:
SELECT max(gpa), min(age) FROM s3 ORDER BY 1;

--Testcase 1247:
DROP FOREIGN TABLE s3__pgspider_svr2__0;
--Testcase 1248:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr2;
--Testcase 1249:
DROP SERVER pgspider_svr2;
--Testcase 1250:
DROP FOREIGN TABLE s3__pgspider_svr1__0;
--Testcase 1251:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_svr1;
--Testcase 1252:
DROP SERVER pgspider_svr1;
--Testcase 1253:
DROP EXTENSION pgspider_fdw;
--Testcase 1254:
DROP FOREIGN TABLE s3;

--Testcase 1255:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 1256:
DROP SERVER pgspider_core_svr;
--Testcase 1257:
DROP EXTENSION pgspider_core_fdw;
