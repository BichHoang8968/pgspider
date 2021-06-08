--Testcase 1230:
SET datestyle=ISO;
--Testcase 1231:
SET timezone='Japan';

--Testcase 1:
CREATE EXTENSION pgspider_core_fdw;
--Testcase 2:
CREATE SERVER pgspider_core_svr FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1');
--Testcase 3:
CREATE USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;

----------------------------------------------------------
-- test structure
-- PGSpider Top Node -> Data source
-- stub functions are provided by data source FDW

----------------------------------------------------------
-- Data source: influxdb

--Testcase 4:
CREATE FOREIGN TABLE s3 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint, __spd_url text) SERVER pgspider_core_svr;
--Testcase 5:
CREATE EXTENSION influxdb_fdw;
--Testcase 6:
CREATE SERVER influxdb_svr FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (dbname 'selectfunc_db', host 'http://localhost', port '8086');
--Testcase 7:
CREATE USER MAPPING FOR CURRENT_USER SERVER influxdb_svr OPTIONS (user 'user', password 'pass');
--Testcase 8:
CREATE FOREIGN TABLE s3__influxdb_svr__0 (time timestamp with time zone, tag1 text, value1 float8, value2 bigint, value3 float8, value4 bigint) SERVER influxdb_svr OPTIONS (table 's3', tags 'tag1');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 9:
\d s3;
--Testcase 10:
SELECT * FROM s3;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 11:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 12:
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select sqrt (builtin function, explain)
--Testcase 13:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (builtin function, result)
--Testcase 14:
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (builtin function, not pushdown constraints, explain)
--Testcase 15:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 16:
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 17:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 18:
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt(*) (stub function, explain)
--Testcase 19:
EXPLAIN VERBOSE
SELECT sqrt_all() from s3;

-- select sqrt(*) (stub function, result)
--Testcase 20:
SELECT sqrt_all() from s3;

-- select sqrt(*) (stub function and group by tag only) (explain)
--Testcase 1232:
EXPLAIN VERBOSE
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sqrt(*) (stub function and group by tag only) (result)
--Testcase 1233:
SELECT sqrt_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select abs (builtin function, explain)
--Testcase 21:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (builtin function, result)
--Testcase 22:
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 23:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 24:
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 25:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 26:
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base)
--Testcase 27:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 28:
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 29:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 30:
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 31:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 32:
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 33:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 34:
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log(*) (stub function, explain)
--Testcase 35:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3;

-- select log(*) (stub function, result)
--Testcase 36:
SELECT log_all(50) FROM s3;

-- select log(*) (stub function, explain)
--Testcase 37:
EXPLAIN VERBOSE
SELECT log_all(70.5) FROM s3;

-- select log(*) (stub function, result)
--Testcase 38:
SELECT log_all(70.5) FROM s3;

-- select log(*) (stub function and group by tag only) (explain)
--Testcase 1234:
EXPLAIN VERBOSE
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select log(*) (stub function and group by tag only) (result)
--Testcase 1235:
SELECT log_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 39:
SELECT ln_all(),log10_all(),log_all(50) FROM s3;

-- select log2 (stub function, explain)
--Testcase 40:
EXPLAIN VERBOSE
SELECT log2(value1),log2(value2) FROM s3;

-- select log2 (stub function, result)
--Testcase 41:
SELECT log2(value1),log2(value2) FROM s3;

-- select log2(*) (stub function, explain)
--Testcase 42:
EXPLAIN VERBOSE
SELECT log2_all() from s3;

-- select log2(*) (stub function, result)
--Testcase 43:
SELECT log2_all() from s3;

-- select log2(*) (stub function and group by tag only) (explain)
--Testcase 1236:
EXPLAIN VERBOSE
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select log2(*) (stub function and group by tag only) (result)
--Testcase 1237:
SELECT log2_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select log10 (stub function, explain)
--Testcase 44:
EXPLAIN VERBOSE
SELECT log10(value1),log10(value2) FROM s3;

-- select log10 (stub function, result)
--Testcase 45:
SELECT log10(value1),log10(value2) FROM s3;

-- select log10(*) (stub function, explain)
--Testcase 46:
EXPLAIN VERBOSE
SELECT log10_all() from s3;

-- select log10(*) (stub function, result)
--Testcase 47:
SELECT log10_all() from s3;

-- select log10(*) (stub function and group by tag only) (explain)
--Testcase 1238:
EXPLAIN VERBOSE
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select log10(*) (stub function and group by tag only) (result)
--Testcase 1239:
SELECT log10_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 48:
SELECT log2_all(), log10_all() FROM s3;

-- select spread (stub agg function, explain)
--Testcase 49:
EXPLAIN VERBOSE
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function, result)
--Testcase 50:
SELECT spread(value1),spread(value2),spread(value3),spread(value4) FROM s3;

-- select spread (stub agg function, raise exception if not expected type)
--Testcase 51:
SELECT spread(value1::numeric),spread(value2::numeric),spread(value3::numeric),spread(value4::numeric) FROM s3;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 52:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 53:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest with log2 (pushdown, explain)
--Testcase 54:
EXPLAIN VERBOSE
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3;

-- select abs as nest with log2 (pushdown, result)
--Testcase 55:
SELECT abs(log2(value1)),abs(log2(1/value1)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 56:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 57:
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 58:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 59:
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 60:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select spread (stub agg function and group by influx_time() and tag) (explain)
--Testcase 61:
EXPLAIN VERBOSE
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread (stub agg function and group by influx_time() and tag) (result)
--Testcase 62:
SELECT spread("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread (stub agg function and group by tag only) (result)
--Testcase 63:
SELECT tag1,spread("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select spread (stub agg function and other aggs) (result)
--Testcase 64:
SELECT sum("value1"),spread("value1"),count("value1") FROM s3;

-- select abs with order by (explain)
--Testcase 65:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 order by abs(1-value1);

-- select abs with order by (result)
--Testcase 66:
SELECT value1, abs(1-value1) FROM s3 order by abs(1-value1);

-- select abs with order by index (result)
--Testcase 67:
SELECT value1, abs(1-value1) FROM s3 order by 2,1;

-- select abs with order by index (result)
--Testcase 68:
SELECT value1, abs(1-value1) FROM s3 order by 1,2;

-- select abs and as
--Testcase 69:
SELECT abs(value3) as abs1 FROM s3;

-- select abs(*) (stub function, explain)
--Testcase 70:
EXPLAIN VERBOSE
SELECT abs_all() from s3;

-- select abs(*) (stub function, result)
--Testcase 71:
SELECT abs_all() from s3;

-- select abs(*) (stub function and group by tag only) (explain)
--Testcase 1240:
EXPLAIN VERBOSE
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select abs(*) (stub function and group by tag only) (result)
--Testcase 1241:
SELECT abs_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select abs(*) (stub function, expose data, explain)
--Testcase 72:
EXPLAIN VERBOSE
SELECT (abs_all()::s3).* from s3;

-- select abs(*) (stub function, expose data, result)
--Testcase 73:
SELECT (abs_all()::s3).* from s3;

-- select spread over join query (explain)
--Testcase 74:
EXPLAIN VERBOSE
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread over join query (result, stub call error)
--Testcase 75:
SELECT spread(t1.value1), spread(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select spread with having (explain)
--Testcase 76:
EXPLAIN VERBOSE
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select spread with having (result, not pushdown, stub call error)
--Testcase 77:
SELECT spread(value1) FROM s3 HAVING spread(value1) > 100;

-- select spread(*) (stub agg function, explain)
--Testcase 78:
EXPLAIN VERBOSE
SELECT spread_all(*) from s3;

-- select spread(*) (stub agg function, result)
--Testcase 79:
SELECT spread_all(*) from s3;

-- select spread(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 80:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 81:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread(*) (stub agg function and group by tag only) (explain)
--Testcase 82:
EXPLAIN VERBOSE
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select spread(*) (stub agg function and group by tag only) (result)
--Testcase 83:
SELECT spread_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select spread(*) (stub agg function, expose data, explain)
--Testcase 84:
EXPLAIN VERBOSE
SELECT (spread_all(*)::s3).* from s3;

-- select spread(*) (stub agg function, expose data, result)
--Testcase 85:
SELECT (spread_all(*)::s3).* from s3;

-- select spread(regex) (stub agg function, explain)
--Testcase 86:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') from s3;

-- select spread(regex) (stub agg function, result)
--Testcase 87:
SELECT spread('/value[1,4]/') from s3;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 88:
EXPLAIN VERBOSE
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 89:
SELECT spread('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select spread(regex) (stub agg function and group by tag only) (explain)
--Testcase 90:
EXPLAIN VERBOSE
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select spread(regex) (stub agg function and group by tag only) (result)
--Testcase 91:
SELECT spread('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select spread(regex) (stub agg function, expose data, explain)
--Testcase 92:
EXPLAIN VERBOSE
SELECT (spread('/value[1,4]/')::s3).* from s3;

-- select spread(regex) (stub agg function, expose data, result)
--Testcase 93:
SELECT (spread('/value[1,4]/')::s3).* from s3;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 94:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 95:
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select with order by limit (explain)
--Testcase 96:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (result)
--Testcase 97:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 98:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 99:
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- nested function in where clause (explain)
--Testcase 100:
EXPLAIN VERBOSE
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

-- nested function in where clause (result)
--Testcase 101:
SELECT sqrt(abs(value3)),min(value1) FROM s3 GROUP BY value3 HAVING sqrt(abs(value3)) > 0 ORDER BY 1,2;

--Testcase 102:
EXPLAIN VERBOSE
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3;

--Testcase 103:
SELECT first(time, value1), first(time, value2), first(time, value3), first(time, value4) FROM s3;

-- select first(*) (stub agg function, explain)
--Testcase 104:
EXPLAIN VERBOSE
SELECT first_all(*) from s3;

-- select first(*) (stub agg function, result)
--Testcase 105:
SELECT first_all(*) from s3;

-- select first(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 106:
EXPLAIN VERBOSE
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select first(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 107:
SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select first(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(*) (stub agg function and group by tag only) (result)
-- -- SELECT first_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(*) (stub agg function, expose data, explain)
--Testcase 108:
EXPLAIN VERBOSE
SELECT (first_all(*)::s3).* from s3;

-- select first(*) (stub agg function, expose data, result)
--Testcase 109:
SELECT (first_all(*)::s3).* from s3;

-- select first(regex) (stub function, explain)
--Testcase 110:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/') from s3;

-- select first(regex) (stub function, explain)
--Testcase 111:
SELECT first('/value[1,4]/') from s3;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 112:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 113:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3;

-- select first(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 114:
EXPLAIN VERBOSE
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select first(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 115:
SELECT first('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select first(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select first(regex) (stub agg function and group by tag only) (result)
-- -- SELECT first('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select first(regex) (stub agg function, expose data, explain)
--Testcase 116:
EXPLAIN VERBOSE
SELECT (first('/value[1,4]/')::s3).* from s3;

-- select first(regex) (stub agg function, expose data, result)
--Testcase 117:
SELECT (first('/value[1,4]/')::s3).* from s3;

--Testcase 118:
EXPLAIN VERBOSE
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3;

--Testcase 119:
SELECT last(time, value1), last(time, value2), last(time, value3), last(time, value4) FROM s3;

-- select last(*) (stub agg function, explain)
--Testcase 120:
EXPLAIN VERBOSE
SELECT last_all(*) from s3;

-- select last(*) (stub agg function, result)
--Testcase 121:
SELECT last_all(*) from s3;

-- select last(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 122:
EXPLAIN VERBOSE
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select last(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 123:
SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select last(*) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(*) (stub agg function and group by tag only) (result)
-- -- SELECT last_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(*) (stub agg function, expose data, explain)
--Testcase 124:
EXPLAIN VERBOSE
SELECT (last_all(*)::s3).* from s3;

-- select last(*) (stub agg function, expose data, result)
--Testcase 125:
SELECT (last_all(*)::s3).* from s3;

-- select last(regex) (stub function, explain)
--Testcase 126:
EXPLAIN VERBOSE
SELECT last('/value[1,4]/') from s3;

-- select last(regex) (stub function, result)
--Testcase 127:
SELECT last('/value[1,4]/') from s3;

-- select multiple regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 128:
EXPLAIN VERBOSE
SELECT first('/value[1,4]/'), first('/^v.*/') from s3;

-- select multiple regex functions (do not push down, raise warning and stub error) (result)
--Testcase 129:
SELECT first('/value[1,4]/'), first('/^v.*/') from s3;

-- select last(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 130:
EXPLAIN VERBOSE
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select last(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 131:
SELECT last('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select last(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select last(regex) (stub agg function and group by tag only) (result)
-- -- SELECT last('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select last(regex) (stub agg function, expose data, explain)
--Testcase 132:
EXPLAIN VERBOSE
SELECT (last('/value[1,4]/')::s3).* from s3;

-- select last(regex) (stub agg function, expose data, result)
--Testcase 133:
SELECT (last('/value[1,4]/')::s3).* from s3;

--Testcase 134:
EXPLAIN VERBOSE
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200;

--Testcase 135:
SELECT sample(value2, 3) FROM s3 WHERE value2 < 200;

--Testcase 136:
EXPLAIN VERBOSE
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s');

--Testcase 137:
SELECT sample(value2, 1) FROM s3 WHERE time >= to_timestamp(0) AND time <= to_timestamp(5) GROUP BY influx_time(time, interval '3s');

-- select sample(*, int) (stub agg function, explain)
--Testcase 138:
EXPLAIN VERBOSE
SELECT sample_all(50) from s3;

-- select sample(*, int) (stub agg function, result)
--Testcase 139:
SELECT sample_all(50) from s3;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 140:
EXPLAIN VERBOSE
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select sample(*, int) (stub agg function and group by influx_time() and tag) (result)
--Testcase 141:
SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select sample(*, int) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(*, int) (stub agg function and group by tag only) (result)
-- -- SELECT sample_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(*, int) (stub agg function, expose data, explain)
--Testcase 142:
EXPLAIN VERBOSE
SELECT (sample_all(50)::s3).* from s3;

-- select sample(*, int) (stub agg function, expose data, result)
--Testcase 143:
SELECT (sample_all(50)::s3).* from s3;

-- select sample(regex) (stub agg function, explain)
--Testcase 144:
EXPLAIN VERBOSE
SELECT sample('/value[1,4]/', 50) from s3;

-- select sample(regex) (stub agg function, result)
--Testcase 145:
SELECT sample('/value[1,4]/', 50) from s3;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 146:
EXPLAIN VERBOSE
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select sample(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 147:
SELECT sample('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- -- select sample(regex) (stub agg function and group by tag only) (explain)
-- -- EXPLAIN VERBOSE
-- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- -- select sample(regex) (stub agg function and group by tag only) (result)
-- -- SELECT sample('/value[1,4]/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sample(regex) (stub agg function, expose data, explain)
--Testcase 148:
EXPLAIN VERBOSE
SELECT (sample('/value[1,4]/', 50)::s3).* from s3;

-- select sample(regex) (stub agg function, expose data, result)
--Testcase 149:
SELECT (sample('/value[1,4]/', 50)::s3).* from s3;

--Testcase 150:
EXPLAIN VERBOSE
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3;

--Testcase 151:
SELECT cumulative_sum(value1),cumulative_sum(value2),cumulative_sum(value3),cumulative_sum(value4) FROM s3;

-- select cumulative_sum(*) (stub function, explain)
--Testcase 152:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() from s3;

-- select cumulative_sum(*) (stub function, result)
--Testcase 153:
SELECT cumulative_sum_all() from s3;

-- select cumulative_sum(regex) (stub function, result)
--Testcase 154:
SELECT cumulative_sum('/value[1,4]/') from s3;

-- select cumulative_sum(regex) (stub function, result)
--Testcase 155:
SELECT cumulative_sum('/value[1,4]/') from s3;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (result)
--Testcase 156:
EXPLAIN VERBOSE
SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (result)
--Testcase 157:
SELECT cumulative_sum_all(), cumulative_sum('/value[1,4]/') from s3;

-- select cumulative_sum(*) (stub function and group by tag only) (explain)
--Testcase 1242:
EXPLAIN VERBOSE
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select cumulative_sum(*) (stub function and group by tag only) (result)
--Testcase 1243:
SELECT cumulative_sum_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select cumulative_sum(regex) (stub function and group by tag only) (explain)
--Testcase 1244:
EXPLAIN VERBOSE
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select cumulative_sum(regex) (stub function and group by tag only) (result)
--Testcase 1245:
SELECT cumulative_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, explain)
--Testcase 158:
EXPLAIN VERBOSE
SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3;

-- select cumulative_sum(*), cumulative_sum(regex) (stub function, expose data, result)
--Testcase 159:
SELECT (cumulative_sum_all()::s3).*, (cumulative_sum('/value[1,4]/')::s3).* from s3;

--Testcase 160:
EXPLAIN VERBOSE
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3;

--Testcase 161:
SELECT derivative(value1),derivative(value2),derivative(value3),derivative(value4) FROM s3;

--Testcase 162:
EXPLAIN VERBOSE
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3;

--Testcase 163:
SELECT derivative(value1, interval '0.5s'),derivative(value2, interval '0.2s'),derivative(value3, interval '0.1s'),derivative(value4, interval '2s') FROM s3;

-- select derivative(*) (stub function, explain)
--Testcase 164:
EXPLAIN VERBOSE
SELECT derivative_all() from s3;

-- select derivative(*) (stub function, result)
--Testcase 165:
SELECT derivative_all() from s3;

-- select derivative(regex) (stub function, explain)
--Testcase 166:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') from s3;

-- select derivative(regex) (stub function, result)
--Testcase 167:
SELECT derivative('/value[1,4]/') from s3;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 168:
EXPLAIN VERBOSE
SELECT derivative_all(), derivative('/value[1,4]/') from s3;

-- select multiple star and regex functions (do not push down, raise warning and stub error) (explain)
--Testcase 169:
SELECT derivative_all(), derivative('/value[1,4]/') from s3;

-- select derivative(*) (stub function and group by tag only) (explain)
--Testcase 1246:
EXPLAIN VERBOSE
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select derivative(*) (stub function and group by tag only) (result)
--Testcase 1247:
SELECT derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1248:
EXPLAIN VERBOSE
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select derivative(regex) (stub function and group by tag only) (result)
--Testcase 1249:
SELECT derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select derivative(*) (stub function, expose data, explain)
--Testcase 170:
EXPLAIN VERBOSE
SELECT (derivative_all()::s3).* from s3;

-- select derivative(*) (stub function, expose data, result)
--Testcase 171:
SELECT (derivative_all()::s3).* from s3;

-- select derivative(regex) (stub function, expose data, explain)
--Testcase 172:
EXPLAIN VERBOSE
SELECT (derivative('/value[1,4]/')::s3).* from s3;

-- select derivative(regex) (stub function, expose data, result)
--Testcase 173:
SELECT (derivative('/value[1,4]/')::s3).* from s3;

--Testcase 174:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3;

--Testcase 175:
SELECT non_negative_derivative(value1),non_negative_derivative(value2),non_negative_derivative(value3),non_negative_derivative(value4) FROM s3;

--Testcase 176:
EXPLAIN VERBOSE
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3;

--Testcase 177:
SELECT non_negative_derivative(value1, interval '0.5s'),non_negative_derivative(value2, interval '0.2s'),non_negative_derivative(value3, interval '0.1s'),non_negative_derivative(value4, interval '2s') FROM s3;

-- select non_negative_derivative(*) (stub function, explain)
--Testcase 178:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() from s3;

-- select non_negative_derivative(*) (stub function, result)
--Testcase 179:
SELECT non_negative_derivative_all() from s3;

-- select non_negative_derivative(regex) (stub function, explain)
--Testcase 180:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') from s3;

-- select non_negative_derivative(regex) (stub function, result)
--Testcase 181:
SELECT non_negative_derivative('/value[1,4]/') from s3;

-- select non_negative_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1250:
EXPLAIN VERBOSE
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_derivative(*) (stub function and group by tag only) (result)
--Testcase 1251:
SELECT non_negative_derivative_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (explain)
--Testcase 1252:
EXPLAIN VERBOSE
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1253:
SELECT non_negative_derivative('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_derivative(*) (stub function, expose data, explain)
--Testcase 182:
EXPLAIN VERBOSE
SELECT (non_negative_derivative_all()::s3).* from s3;

-- select non_negative_derivative(*) (stub function, expose data, result)
--Testcase 183:
SELECT (non_negative_derivative_all()::s3).* from s3;

-- select non_negative_derivative(regex) (stub function, expose data, explain)
--Testcase 184:
EXPLAIN VERBOSE
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3;

-- select non_negative_derivative(regex) (stub function, expose data, result)
--Testcase 185:
SELECT (non_negative_derivative('/value[1,4]/')::s3).* from s3;

--Testcase 186:
EXPLAIN VERBOSE
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3;

--Testcase 187:
SELECT difference(value1),difference(value2),difference(value3),difference(value4) FROM s3;

-- select difference(*) (stub function, explain)
--Testcase 188:
EXPLAIN VERBOSE
SELECT difference_all() from s3;

-- select difference(*) (stub function, result)
--Testcase 189:
SELECT difference_all() from s3;

-- select difference(regex) (stub function, explain)
--Testcase 190:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') from s3;

-- select difference(regex) (stub function, result)
--Testcase 191:
SELECT difference('/value[1,4]/') from s3;

-- select difference(*) (stub function and group by tag only) (explain)
--Testcase 1254:
EXPLAIN VERBOSE
SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select difference(*) (stub function and group by tag only) (result)
--Testcase 1255:
SELECT difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select difference(regex) (stub function and group by tag only) (explain)
--Testcase 1256:
EXPLAIN VERBOSE
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select difference(regex) (stub function and group by tag only) (result)
--Testcase 1257:
SELECT difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select difference(*) (stub function, expose data, explain)
--Testcase 192:
EXPLAIN VERBOSE
SELECT (difference_all()::s3).* from s3;

-- select difference(*) (stub function, expose data, result)
--Testcase 193:
SELECT (difference_all()::s3).* from s3;

-- select difference(regex) (stub function, expose data, explain)
--Testcase 194:
EXPLAIN VERBOSE
SELECT (difference('/value[1,4]/')::s3).* from s3;

-- select difference(regex) (stub function, expose data, result)
--Testcase 195:
SELECT (difference('/value[1,4]/')::s3).* from s3;

--Testcase 196:
EXPLAIN VERBOSE
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3;

--Testcase 197:
SELECT non_negative_difference(value1),non_negative_difference(value2),non_negative_difference(value3),non_negative_difference(value4) FROM s3;

-- select non_negative_difference(*) (stub function, explain)
--Testcase 198:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() from s3;

-- select non_negative_difference(*) (stub function, result)
--Testcase 199:
SELECT non_negative_difference_all() from s3;

-- select non_negative_difference(regex) (stub function, explain)
--Testcase 200:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') from s3;

-- select non_negative_difference(*), non_negative_difference(regex) (stub function, result)
--Testcase 201:
SELECT non_negative_difference('/value[1,4]/') from s3;

-- select non_negative_difference(*) (stub function and group by tag only) (explain)
--Testcase 1258:
EXPLAIN VERBOSE
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_difference(*) (stub function and group by tag only) (result)
--Testcase 1259:
SELECT non_negative_difference_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_difference(regex) (stub function and group by tag only) (explain)
--Testcase 1260:
EXPLAIN VERBOSE
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_difference(regex) (stub function and group by tag only) (result)
--Testcase 1261:
SELECT non_negative_difference('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select non_negative_difference(*) (stub function, expose data, explain)
--Testcase 202:
EXPLAIN VERBOSE
SELECT (non_negative_difference_all()::s3).* from s3;

-- select non_negative_difference(*) (stub function, expose data, result)
--Testcase 203:
SELECT (non_negative_difference_all()::s3).* from s3;

-- select non_negative_difference(regex) (stub function, expose data, explain)
--Testcase 204:
EXPLAIN VERBOSE
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3;

-- select non_negative_difference(regex) (stub function, expose data, result)
--Testcase 205:
SELECT (non_negative_difference('/value[1,4]/')::s3).* from s3;

--Testcase 206:
EXPLAIN VERBOSE
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3;

--Testcase 207:
SELECT elapsed(value1),elapsed(value2),elapsed(value3),elapsed(value4) FROM s3;

--Testcase 208:
EXPLAIN VERBOSE
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3;

--Testcase 209:
SELECT elapsed(value1, interval '0.5s'),elapsed(value2, interval '0.2s'),elapsed(value3, interval '0.1s'),elapsed(value4, interval '2s') FROM s3;

-- select elapsed(*) (stub function, explain)
--Testcase 210:
EXPLAIN VERBOSE
SELECT elapsed_all() from s3;

-- select elapsed(*) (stub function, result)
--Testcase 211:
SELECT elapsed_all() from s3;

-- select elapsed(regex) (stub function, explain)
--Testcase 212:
EXPLAIN VERBOSE
SELECT elapsed('/value[1,4]/') from s3;

-- select elapsed(regex) (stub function, result)
--Testcase 213:
SELECT elapsed('/value[1,4]/') from s3;

-- select elapsed(*) (stub function and group by tag only) (explain)
--Testcase 1262:
EXPLAIN VERBOSE
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select elapsed(*) (stub function and group by tag only) (result)
--Testcase 1263:
SELECT elapsed_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select elapsed(regex) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1264:
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select elapsed(regex) (stub function and group by tag only) (result)
--Testcase 1265:
SELECT elapsed('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select elapsed(*) (stub function, expose data, explain)
--Testcase 214:
EXPLAIN VERBOSE
SELECT (elapsed_all()::s3).* from s3;

-- select elapsed(*) (stub function, expose data, result)
--Testcase 215:
SELECT (elapsed_all()::s3).* from s3;

-- select elapsed(regex) (stub function, expose data, explain)
--Testcase 216:
EXPLAIN VERBOSE
SELECT (elapsed('/value[1,4]/')::s3).* from s3;

-- select elapsed(regex) (stub function, expose data, result)
--Testcase 217:
SELECT (elapsed('/value[1,4]/')::s3).* from s3;

--Testcase 218:
EXPLAIN VERBOSE
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3;

--Testcase 219:
SELECT moving_average(value1, 2),moving_average(value2, 2),moving_average(value3, 2),moving_average(value4, 2) FROM s3;

-- select moving_average(*) (stub function, explain)
--Testcase 220:
EXPLAIN VERBOSE
SELECT moving_average_all(2) from s3;

-- select moving_average(*) (stub function, result)
--Testcase 221:
SELECT moving_average_all(2) from s3;

-- select moving_average(regex) (stub function, explain)
--Testcase 222:
EXPLAIN VERBOSE
SELECT moving_average('/value[1,4]/', 2) from s3;

-- select moving_average(regex) (stub function, result)
--Testcase 223:
SELECT moving_average('/value[1,4]/', 2) from s3;

-- select moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1266:
EXPLAIN VERBOSE
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select moving_average(*) (stub function and group by tag only) (result)
--Testcase 1267:
SELECT moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select moving_average(regex) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1268:
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1269:
SELECT moving_average('/value[1,4]/', 2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select moving_average(*) (stub function, expose data, explain)
--Testcase 224:
EXPLAIN VERBOSE
SELECT (moving_average_all(2)::s3).* from s3;

-- select moving_average(*) (stub function, expose data, result)
--Testcase 225:
SELECT (moving_average_all(2)::s3).* from s3;

-- select moving_average(regex) (stub function, expose data, explain)
--Testcase 226:
EXPLAIN VERBOSE
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3;

-- select moving_average(regex) (stub function, expose data, result)
--Testcase 227:
SELECT (moving_average('/value[1,4]/', 2)::s3).* from s3;

--Testcase 228:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3;

--Testcase 229:
SELECT chande_momentum_oscillator(value1, 2),chande_momentum_oscillator(value2, 2),chande_momentum_oscillator(value3, 2),chande_momentum_oscillator(value4, 2) FROM s3;

--Testcase 230:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3;

--Testcase 231:
SELECT chande_momentum_oscillator(value1, 2, 2),chande_momentum_oscillator(value2, 2, 2),chande_momentum_oscillator(value3, 2, 2),chande_momentum_oscillator(value4, 2, 2) FROM s3;

-- select chande_momentum_oscillator(*) (stub function, explain)
--Testcase 232:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) from s3;

-- select chande_momentum_oscillator(*) (stub function, result)
--Testcase 233:
SELECT chande_momentum_oscillator_all(2) from s3;

-- select chande_momentum_oscillator(regex) (stub function, explain)
--Testcase 234:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3;

-- select chande_momentum_oscillator(regex) (stub function, result)
--Testcase 235:
SELECT chande_momentum_oscillator('/value[1,4]/',2) from s3;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (explain)
--Testcase 1270:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select chande_momentum_oscillator(*) (stub function and group by tag only) (result)
--Testcase 1271:
SELECT chande_momentum_oscillator_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (explain)
--Testcase 1272:
EXPLAIN VERBOSE
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select chande_momentum_oscillator(regex) (stub function and group by tag only) (result)
--Testcase 1273:
SELECT chande_momentum_oscillator('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select chande_momentum_oscillator(*) (stub function, expose data, explain)
--Testcase 236:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3;

-- select chande_momentum_oscillator(*) (stub function, expose data, result)
--Testcase 237:
SELECT (chande_momentum_oscillator_all(2)::s3).* from s3;

-- select chande_momentum_oscillator(regex) (stub function, expose data, explain)
--Testcase 238:
EXPLAIN VERBOSE
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3;

-- select chande_momentum_oscillator(regex) (stub function, expose data, result)
--Testcase 239:
SELECT (chande_momentum_oscillator('/value[1,4]/',2)::s3).* from s3;

--Testcase 240:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3;

--Testcase 241:
SELECT exponential_moving_average(value1, 2),exponential_moving_average(value2, 2),exponential_moving_average(value3, 2),exponential_moving_average(value4, 2) FROM s3;

--Testcase 242:
EXPLAIN VERBOSE
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3;

--Testcase 243:
SELECT exponential_moving_average(value1, 2, 2),exponential_moving_average(value2, 2, 2),exponential_moving_average(value3, 2, 2),exponential_moving_average(value4, 2, 2) FROM s3;

-- select exponential_moving_average(*) (stub function, explain)
--Testcase 244:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) from s3;

-- select exponential_moving_average(*) (stub function, result)
--Testcase 245:
SELECT exponential_moving_average_all(2) from s3;

-- select exponential_moving_average(regex) (stub function, explain)
--Testcase 246:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) from s3;

-- select exponential_moving_average(regex) (stub function, result)
--Testcase 247:
SELECT exponential_moving_average('/value[1,4]/',2) from s3;

-- select exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1274:
EXPLAIN VERBOSE
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1275:
SELECT exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1276:
EXPLAIN VERBOSE
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1277:
SELECT exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

--Testcase 248:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3;

--Testcase 249:
SELECT double_exponential_moving_average(value1, 2),double_exponential_moving_average(value2, 2),double_exponential_moving_average(value3, 2),double_exponential_moving_average(value4, 2) FROM s3;

--Testcase 250:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3;

--Testcase 251:
SELECT double_exponential_moving_average(value1, 2, 2),double_exponential_moving_average(value2, 2, 2),double_exponential_moving_average(value3, 2, 2),double_exponential_moving_average(value4, 2, 2) FROM s3;

-- select double_exponential_moving_average(*) (stub function, explain)
--Testcase 252:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) from s3;

-- select double_exponential_moving_average(*) (stub function, result)
--Testcase 253:
SELECT double_exponential_moving_average_all(2) from s3;

-- select double_exponential_moving_average(regex) (stub function, explain)
--Testcase 254:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3;

-- select double_exponential_moving_average(regex) (stub function, result)
--Testcase 255:
SELECT double_exponential_moving_average('/value[1,4]/',2) from s3;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1278:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select double_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1279:
SELECT double_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1280:
EXPLAIN VERBOSE
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select double_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1281:
SELECT double_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

--Testcase 256:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3;

--Testcase 257:
SELECT kaufmans_efficiency_ratio(value1, 2),kaufmans_efficiency_ratio(value2, 2),kaufmans_efficiency_ratio(value3, 2),kaufmans_efficiency_ratio(value4, 2) FROM s3;

--Testcase 258:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3;

--Testcase 259:
SELECT kaufmans_efficiency_ratio(value1, 2, 2),kaufmans_efficiency_ratio(value2, 2, 2),kaufmans_efficiency_ratio(value3, 2, 2),kaufmans_efficiency_ratio(value4, 2, 2) FROM s3;

-- select kaufmans_efficiency_ratio(*) (stub function, explain)
--Testcase 260:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) from s3;

-- select kaufmans_efficiency_ratio(*) (stub function, result)
--Testcase 261:
SELECT kaufmans_efficiency_ratio_all(2) from s3;

-- select kaufmans_efficiency_ratio(regex) (stub function, explain)
--Testcase 262:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3;

-- select kaufmans_efficiency_ratio(regex) (stub function, result)
--Testcase 263:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) from s3;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (explain)
--Testcase 1282:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_efficiency_ratio(*) (stub function and group by tag only) (result)
--Testcase 1283:
SELECT kaufmans_efficiency_ratio_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (explain)
--Testcase 1284:
EXPLAIN VERBOSE
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_efficiency_ratio(regex) (stub function and group by tag only) (result)
--Testcase 1285:
SELECT kaufmans_efficiency_ratio('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, explain)
--Testcase 264:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3;

-- select kaufmans_efficiency_ratio(*) (stub function, expose data, result)
--Testcase 265:
SELECT (kaufmans_efficiency_ratio_all(2)::s3).* from s3;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, explain)
--Testcase 266:
EXPLAIN VERBOSE
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3;

-- select kaufmans_efficiency_ratio(regex) (stub function, expose data, result)
--Testcase 267:
SELECT (kaufmans_efficiency_ratio('/value[1,4]/',2)::s3).* from s3;

--Testcase 268:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3;

--Testcase 269:
SELECT kaufmans_adaptive_moving_average(value1, 2),kaufmans_adaptive_moving_average(value2, 2),kaufmans_adaptive_moving_average(value3, 2),kaufmans_adaptive_moving_average(value4, 2) FROM s3;

--Testcase 270:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3;

--Testcase 271:
SELECT kaufmans_adaptive_moving_average(value1, 2, 2),kaufmans_adaptive_moving_average(value2, 2, 2),kaufmans_adaptive_moving_average(value3, 2, 2),kaufmans_adaptive_moving_average(value4, 2, 2) FROM s3;

-- select kaufmans_adaptive_moving_average(*) (stub function, explain)
--Testcase 272:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) from s3;

-- select kaufmans_adaptive_moving_average(*) (stub function, result)
--Testcase 273:
SELECT kaufmans_adaptive_moving_average_all(2) from s3;

-- select kaufmans_adaptive_moving_average(regex) (stub function, explain)
--Testcase 274:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3;

-- select kaufmans_adaptive_moving_average(regex) (stub function, result)
--Testcase 275:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) from s3;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1286:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_adaptive_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1287:
SELECT kaufmans_adaptive_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1288:
EXPLAIN VERBOSE
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select kaufmans_adaptive_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1289:
SELECT kaufmans_adaptive_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

--Testcase 276:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3;

--Testcase 277:
SELECT triple_exponential_moving_average(value1, 2),triple_exponential_moving_average(value2, 2),triple_exponential_moving_average(value3, 2),triple_exponential_moving_average(value4, 2) FROM s3;

--Testcase 278:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3;

--Testcase 279:
SELECT triple_exponential_moving_average(value1, 2, 2),triple_exponential_moving_average(value2, 2, 2),triple_exponential_moving_average(value3, 2, 2),triple_exponential_moving_average(value4, 2, 2) FROM s3;

-- select triple_exponential_moving_average(*) (stub function, explain)
--Testcase 280:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) from s3;

-- select triple_exponential_moving_average(*) (stub function, result)
--Testcase 281:
SELECT triple_exponential_moving_average_all(2) from s3;

-- select triple_exponential_moving_average(regex) (stub function, explain)
--Testcase 282:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3;

-- select triple_exponential_moving_average(regex) (stub function, result)
--Testcase 283:
SELECT triple_exponential_moving_average('/value[1,4]/',2) from s3;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (explain)
--Testcase 1290:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_moving_average(*) (stub function and group by tag only) (result)
--Testcase 1291:
SELECT triple_exponential_moving_average_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (explain)
--Testcase 1292:
EXPLAIN VERBOSE
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_moving_average(regex) (stub function and group by tag only) (result)
--Testcase 1293:
SELECT triple_exponential_moving_average('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

--Testcase 284:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3;

--Testcase 285:
SELECT triple_exponential_derivative(value1, 2),triple_exponential_derivative(value2, 2),triple_exponential_derivative(value3, 2),triple_exponential_derivative(value4, 2) FROM s3;

--Testcase 286:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3;

--Testcase 287:
SELECT triple_exponential_derivative(value1, 2, 2),triple_exponential_derivative(value2, 2, 2),triple_exponential_derivative(value3, 2, 2),triple_exponential_derivative(value4, 2, 2) FROM s3;

-- select triple_exponential_derivative(*) (stub function, explain)
--Testcase 288:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) from s3;

-- select triple_exponential_derivative(*) (stub function, result)
--Testcase 289:
SELECT triple_exponential_derivative_all(2) from s3;

-- select triple_exponential_derivative(regex) (stub function, explain)
--Testcase 290:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3;

-- select triple_exponential_derivative(regex) (stub function, result)
--Testcase 291:
SELECT triple_exponential_derivative('/value[1,4]/',2) from s3;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (explain)
--Testcase 1294:
EXPLAIN VERBOSE
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_derivative(*) (stub function and group by tag only) (result)
--Testcase 1295:
SELECT triple_exponential_derivative_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1296:
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select triple_exponential_derivative(regex) (stub function and group by tag only) (result)
--Testcase 1297:
SELECT triple_exponential_derivative('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

--Testcase 292:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3;

--Testcase 293:
SELECT relative_strength_index(value1, 2),relative_strength_index(value2, 2),relative_strength_index(value3, 2),relative_strength_index(value4, 2) FROM s3;

--Testcase 294:
EXPLAIN VERBOSE
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3;

--Testcase 295:
SELECT relative_strength_index(value1, 2, 2),relative_strength_index(value2, 2, 2),relative_strength_index(value3, 2, 2),relative_strength_index(value4, 2, 2) FROM s3;

-- select relative_strength_index(*) (stub function, explain)
--Testcase 296:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) from s3;

-- select relative_strength_index(*) (stub function, result)
--Testcase 297:
SELECT relative_strength_index_all(2) from s3;

-- select relative_strength_index(regex) (stub function, explain)
--Testcase 298:
EXPLAIN VERBOSE
SELECT relative_strength_index('/value[1,4]/',2) from s3;

-- select relative_strength_index(regex) (stub function, result)
--Testcase 299:
SELECT relative_strength_index('/value[1,4]/',2) from s3;

-- select relative_strength_index(*) (stub function and group by tag only) (explain)
--Testcase 1298:
EXPLAIN VERBOSE
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select relative_strength_index(*) (stub function and group by tag only) (result)
--Testcase 1299:
SELECT relative_strength_index_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select relative_strength_index(regex) (stub function and group by tag only) (explain)
-- EXPLAIN VERBOSE
--Testcase 1300:
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select relative_strength_index(regex) (stub function and group by tag only) (result)
--Testcase 1301:
SELECT relative_strength_index('/value[1,4]/',2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select relative_strength_index(*) (stub function, expose data, explain)
--Testcase 300:
EXPLAIN VERBOSE
SELECT (relative_strength_index_all(2)::s3).* from s3;

-- select relative_strength_index(*) (stub function, expose data, result)
--Testcase 301:
SELECT (relative_strength_index_all(2)::s3).* from s3;

-- select relative_strength_index(regex) (stub function, expose data, explain)
--Testcase 302:
EXPLAIN VERBOSE
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3;

-- select relative_strength_index(regex) (stub function, expose data, result)
--Testcase 303:
SELECT (relative_strength_index('/value[1,4]/',2)::s3).* from s3;

-- select integral (stub agg function, explain)
--Testcase 304:
EXPLAIN VERBOSE
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3;

-- select integral (stub agg function, result)
--Testcase 305:
SELECT integral(value1),integral(value2),integral(value3),integral(value4) FROM s3;

--Testcase 306:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3;

-- select integral (stub agg function, result)
--Testcase 307:
SELECT integral(value1, interval '1s'),integral(value2, interval '1s'),integral(value3, interval '1s'),integral(value4, interval '1s') FROM s3;

-- select integral (stub agg function, raise exception if not expected type)
--Testcase 308:
SELECT integral(value1::numeric),integral(value2::numeric),integral(value3::numeric),integral(value4::numeric) FROM s3;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 309:
EXPLAIN VERBOSE
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 310:
SELECT integral("value1"),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral (stub agg function and group by influx_time() and tag) (explain)
--Testcase 311:
EXPLAIN VERBOSE
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral (stub agg function and group by influx_time() and tag) (result)
--Testcase 312:
SELECT integral("value1", interval '1s'),influx_time(time, interval '1s'),tag1 FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 313:
SELECT tag1,integral("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1, 2;

-- select integral (stub agg function and other aggs) (result)
--Testcase 314:
SELECT sum("value1"),integral("value1"),count("value1") FROM s3;

-- select integral (stub agg function and group by tag only) (result)
--Testcase 315:
SELECT tag1,integral("value1", interval '1s') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1 ORDER BY 1, 2;

-- select integral (stub agg function and other aggs) (result)
--Testcase 316:
SELECT sum("value1"),integral("value1", interval '1s'),count("value1") FROM s3;

-- select integral over join query (explain)
--Testcase 317:
EXPLAIN VERBOSE
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select integral over join query (result, stub call error)
--Testcase 318:
SELECT integral(t1.value1), integral(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select integral over join query (explain)
--Testcase 319:
EXPLAIN VERBOSE
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select integral over join query (result, stub call error)
--Testcase 320:
SELECT integral(t1.value1, interval '1s'), integral(t2.value1, interval '1s') FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select integral with having (explain)
--Testcase 321:
EXPLAIN VERBOSE
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 322:
SELECT integral(value1) FROM s3 HAVING integral(value1) > 100;

-- select integral with having (explain)
--Testcase 323:
EXPLAIN VERBOSE
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100;

-- select integral with having (explain, not pushdown, stub call error)
--Testcase 324:
SELECT integral(value1, interval '1s') FROM s3 HAVING integral(value1, interval '1s') > 100;

-- select integral(*) (stub agg function, explain)
--Testcase 325:
EXPLAIN VERBOSE
SELECT integral_all(*) from s3;

-- select integral(*) (stub agg function, result)
--Testcase 326:
SELECT integral_all(*) from s3;

-- select integral(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 327:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 328:
SELECT integral_all(*) FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral(*) (stub agg function and group by tag only) (explain)
--Testcase 329:
EXPLAIN VERBOSE
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1;

-- select integral(*) (stub agg function and group by tag only) (result)
--Testcase 330:
SELECT integral_all(*) FROM s3 WHERE value1 > 0.3 GROUP BY tag1;

-- select integral(*) (stub agg function, expose data, explain)
--Testcase 331:
EXPLAIN VERBOSE
SELECT (integral_all(*)::s3).* from s3;

-- select integral(*) (stub agg function, expose data, result)
--Testcase 332:
SELECT (integral_all(*)::s3).* from s3;

-- select integral(regex) (stub agg function, explain)
--Testcase 333:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') from s3;

-- select integral(regex) (stub agg function, result)
--Testcase 334:
SELECT integral('/value[1,4]/') from s3;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 335:
EXPLAIN VERBOSE
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 336:
SELECT integral('/^v.*/') FROM s3 GROUP BY influx_time(time, interval '1s'), tag1;

-- select integral(regex) (stub agg function and group by tag only) (explain)
--Testcase 337:
EXPLAIN VERBOSE
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1;

-- select integral(regex) (stub agg function and group by tag only) (result)
--Testcase 338:
SELECT integral('/value[1,4]/') FROM s3 WHERE value1 > 0.3 GROUP BY tag1;

-- select integral(regex) (stub agg function, expose data, explain)
--Testcase 339:
EXPLAIN VERBOSE
SELECT (integral('/value[1,4]/')::s3).* from s3;

-- select integral(regex) (stub agg function, expose data, result)
--Testcase 340:
SELECT (integral('/value[1,4]/')::s3).* from s3;

-- select mean (stub agg function, explain)
--Testcase 341:
EXPLAIN VERBOSE
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3;

-- select mean (stub agg function, result)
--Testcase 342:
SELECT mean(value1),mean(value2),mean(value3),mean(value4) FROM s3;

-- select mean (stub agg function, raise exception if not expected type)
--Testcase 343:
SELECT mean(value1::numeric),mean(value2::numeric),mean(value3::numeric),mean(value4::numeric) FROM s3;

-- select mean (stub agg function and group by influx_time() and tag) (explain)
--Testcase 344:
EXPLAIN VERBOSE
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean (stub agg function and group by influx_time() and tag) (result)
--Testcase 345:
SELECT mean("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean (stub agg function and group by tag only) (result)
--Testcase 346:
SELECT tag1,mean("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select mean (stub agg function and other aggs) (result)
--Testcase 347:
SELECT sum("value1"),mean("value1"),count("value1") FROM s3;

-- select mean over join query (explain)
--Testcase 348:
EXPLAIN VERBOSE
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select mean over join query (result, stub call error)
--Testcase 349:
SELECT mean(t1.value1), mean(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select mean with having (explain)
--Testcase 350:
EXPLAIN VERBOSE
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100;

-- select mean with having (explain, not pushdown, stub call error)
--Testcase 351:
SELECT mean(value1) FROM s3 HAVING mean(value1) > 100;

-- select mean(*) (stub agg function, explain)
--Testcase 352:
EXPLAIN VERBOSE
SELECT mean_all(*) from s3;

-- select mean(*) (stub agg function, result)
--Testcase 353:
SELECT mean_all(*) from s3;

-- select mean(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 354:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 355:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean(*) (stub agg function and group by tag only) (explain)
--Testcase 356:
EXPLAIN VERBOSE
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select mean(*) (stub agg function and group by tag only) (result)
--Testcase 357:
SELECT mean_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select mean(*) (stub agg function, expose data, explain)
--Testcase 358:
EXPLAIN VERBOSE
SELECT (mean_all(*)::s3).* from s3;

-- select mean(*) (stub agg function, expose data, result)
--Testcase 359:
SELECT (mean_all(*)::s3).* from s3;

-- select mean(regex) (stub agg function, explain)
--Testcase 360:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') from s3;

-- select mean(regex) (stub agg function, result)
--Testcase 361:
SELECT mean('/value[1,4]/') from s3;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 362:
EXPLAIN VERBOSE
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 363:
SELECT mean('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select mean(regex) (stub agg function and group by tag only) (explain)
--Testcase 364:
EXPLAIN VERBOSE
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select mean(regex) (stub agg function and group by tag only) (result)
--Testcase 365:
SELECT mean('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select mean(regex) (stub agg function, expose data, explain)
--Testcase 366:
EXPLAIN VERBOSE
SELECT (mean('/value[1,4]/')::s3).* from s3;

-- select mean(regex) (stub agg function, expose data, result)
--Testcase 367:
SELECT (mean('/value[1,4]/')::s3).* from s3;

-- select median (stub agg function, explain)
--Testcase 368:
EXPLAIN VERBOSE
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3;

-- select median (stub agg function, result)
--Testcase 369:
SELECT median(value1),median(value2),median(value3),median(value4) FROM s3;

-- select median (stub agg function, raise exception if not expected type)
--Testcase 370:
SELECT median(value1::numeric),median(value2::numeric),median(value3::numeric),median(value4::numeric) FROM s3;

-- select median (stub agg function and group by influx_time() and tag) (explain)
--Testcase 371:
EXPLAIN VERBOSE
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median (stub agg function and group by influx_time() and tag) (result)
--Testcase 372:
SELECT median("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median (stub agg function and group by tag only) (result)
--Testcase 373:
SELECT tag1,median("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select median (stub agg function and other aggs) (result)
--Testcase 374:
SELECT sum("value1"),median("value1"),count("value1") FROM s3;

-- select median over join query (explain)
--Testcase 375:
EXPLAIN VERBOSE
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select median over join query (result, stub call error)
--Testcase 376:
SELECT median(t1.value1), median(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select median with having (explain)
--Testcase 377:
EXPLAIN VERBOSE
SELECT median(value1) FROM s3 HAVING median(value1) > 100;

-- select median with having (explain, not pushdown, stub call error)
--Testcase 378:
SELECT median(value1) FROM s3 HAVING median(value1) > 100;

-- select median(*) (stub agg function, explain)
--Testcase 379:
EXPLAIN VERBOSE
SELECT median_all(*) from s3;

-- select median(*) (stub agg function, result)
--Testcase 380:
SELECT median_all(*) from s3;

-- select median(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 381:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 382:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median(*) (stub agg function and group by tag only) (explain)
--Testcase 383:
EXPLAIN VERBOSE
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select median(*) (stub agg function and group by tag only) (result)
--Testcase 384:
SELECT median_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select median(*) (stub agg function, expose data, explain)
--Testcase 385:
EXPLAIN VERBOSE
SELECT (median_all(*)::s3).* from s3;

-- select median(*) (stub agg function, expose data, result)
--Testcase 386:
SELECT (median_all(*)::s3).* from s3;

-- select median(regex) (stub agg function, explain)
--Testcase 387:
EXPLAIN VERBOSE
SELECT median('/^v.*/') from s3;

-- select median(regex) (stub agg function, result)
--Testcase 388:
SELECT  median('/^v.*/') from s3;

-- select median(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 389:
EXPLAIN VERBOSE
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 390:
SELECT median('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select median(regex) (stub agg function and group by tag only) (explain)
--Testcase 391:
EXPLAIN VERBOSE
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select median(regex) (stub agg function and group by tag only) (result)
--Testcase 392:
SELECT median('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select median(regex) (stub agg function, expose data, explain)
--Testcase 393:
EXPLAIN VERBOSE
SELECT (median('/value[1,4]/')::s3).* from s3;

-- select median(regex) (stub agg function, expose data, result)
--Testcase 394:
SELECT (median('/value[1,4]/')::s3).* from s3;

-- select influx_mode (stub agg function, explain)
--Testcase 395:
EXPLAIN VERBOSE
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3;

-- select influx_mode (stub agg function, result)
--Testcase 396:
SELECT influx_mode(value1),influx_mode(value2),influx_mode(value3),influx_mode(value4) FROM s3;

-- select influx_mode (stub agg function, raise exception if not expected type)
--Testcase 397:
SELECT influx_mode(value1::numeric),influx_mode(value2::numeric),influx_mode(value3::numeric),influx_mode(value4::numeric) FROM s3;

-- select influx_mode (stub agg function and group by influx_time() and tag) (explain)
--Testcase 398:
EXPLAIN VERBOSE
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode (stub agg function and group by influx_time() and tag) (result)
--Testcase 399:
SELECT influx_mode("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode (stub agg function and group by tag only) (result)
--Testcase 400:
SELECT tag1,influx_mode("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_mode (stub agg function and other aggs) (result)
--Testcase 401:
SELECT sum("value1"),influx_mode("value1"),count("value1") FROM s3;

-- select influx_mode over join query (explain)
--Testcase 402:
EXPLAIN VERBOSE
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select influx_mode over join query (result, stub call error)
--Testcase 403:
SELECT influx_mode(t1.value1), influx_mode(t2.value1) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select influx_mode with having (explain)
--Testcase 404:
EXPLAIN VERBOSE
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100;

-- select influx_mode with having (explain, not pushdown, stub call error)
--Testcase 405:
SELECT influx_mode(value1) FROM s3 HAVING influx_mode(value1) > 100;

-- select influx_mode(*) (stub agg function, explain)
--Testcase 406:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) from s3;

-- select influx_mode(*) (stub agg function, result)
--Testcase 407:
SELECT influx_mode_all(*) from s3;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 408:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 409:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode(*) (stub agg function and group by tag only) (explain)
--Testcase 410:
EXPLAIN VERBOSE
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_mode(*) (stub agg function and group by tag only) (result)
--Testcase 411:
SELECT influx_mode_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_mode(*) (stub agg function, expose data, explain)
--Testcase 412:
EXPLAIN VERBOSE
SELECT (influx_mode_all(*)::s3).* from s3;

-- select influx_mode(*) (stub agg function, expose data, result)
--Testcase 413:
SELECT (influx_mode_all(*)::s3).* from s3;

-- select influx_mode(regex) (stub function, explain)
--Testcase 414:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') from s3;

-- select influx_mode(regex) (stub function, result)
--Testcase 415:
SELECT influx_mode('/value[1,4]/') from s3;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 416:
EXPLAIN VERBOSE
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 417:
SELECT influx_mode('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_mode(regex) (stub agg function and group by tag only) (explain)
--Testcase 418:
EXPLAIN VERBOSE
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_mode(regex) (stub agg function and group by tag only) (result)
--Testcase 419:
SELECT influx_mode('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_mode(regex) (stub agg function, expose data, explain)
--Testcase 420:
EXPLAIN VERBOSE
SELECT (influx_mode('/value[1,4]/')::s3).* from s3;

-- select influx_mode(regex) (stub agg function, expose data, result)
--Testcase 421:
SELECT (influx_mode('/value[1,4]/')::s3).* from s3;

-- select stddev (agg function, explain)
--Testcase 422:
EXPLAIN VERBOSE
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3;

-- select stddev (agg function, result)
--Testcase 423:
SELECT stddev(value1),stddev(value2),stddev(value3),stddev(value4) FROM s3;

-- select stddev (agg function and group by influx_time() and tag) (explain)
--Testcase 424:
EXPLAIN VERBOSE
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev (agg function and group by influx_time() and tag) (result)
--Testcase 425:
SELECT stddev("value1"),influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev (agg function and group by tag only) (result)
--Testcase 426:
SELECT tag1,stddev("value1") FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select stddev (agg function and other aggs) (result)
--Testcase 427:
SELECT sum("value1"),stddev("value1"),count("value1") FROM s3;

-- select stddev(*) (stub agg function, explain)
--Testcase 428:
EXPLAIN VERBOSE
SELECT stddev_all(*) from s3;

-- select stddev(*) (stub agg function, result)
--Testcase 429:
SELECT stddev_all(*) from s3;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 430:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 431:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev(*) (stub agg function and group by tag only) (explain)
--Testcase 432:
EXPLAIN VERBOSE
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select stddev(*) (stub agg function and group by tag only) (result)
--Testcase 433:
SELECT stddev_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select stddev(regex) (stub function, explain)
--Testcase 434:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') from s3;

-- select stddev(regex) (stub function, result)
--Testcase 435:
SELECT stddev('/value[1,4]/') from s3;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 436:
EXPLAIN VERBOSE
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 437:
SELECT stddev('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select stddev(regex) (stub agg function and group by tag only) (explain)
--Testcase 438:
EXPLAIN VERBOSE
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select stddev(regex) (stub agg function and group by tag only) (result)
--Testcase 439:
SELECT stddev('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_sum(*) (stub agg function, explain)
--Testcase 440:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) from s3;

-- select influx_sum(*) (stub agg function, result)
--Testcase 441:
SELECT influx_sum_all(*) from s3;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 442:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_sum(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 443:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_sum(*) (stub agg function and group by tag only) (explain)
--Testcase 444:
EXPLAIN VERBOSE
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_sum(*) (stub agg function and group by tag only) (result)
--Testcase 445:
SELECT influx_sum_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_sum(*) (stub agg function, expose data, explain)
--Testcase 446:
EXPLAIN VERBOSE
SELECT (influx_sum_all(*)::s3).* from s3;

-- select influx_sum(*) (stub agg function, expose data, result)
--Testcase 447:
SELECT (influx_sum_all(*)::s3).* from s3;

-- select influx_sum(regex) (stub function, explain)
--Testcase 448:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') from s3;

-- select influx_sum(regex) (stub function, result)
--Testcase 449:
SELECT influx_sum('/value[1,4]/') from s3;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 450:
EXPLAIN VERBOSE
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_sum(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 451:
SELECT influx_sum('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_sum(regex) (stub agg function and group by tag only) (explain)
--Testcase 452:
EXPLAIN VERBOSE
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_sum(regex) (stub agg function and group by tag only) (result)
--Testcase 453:
SELECT influx_sum('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_sum(regex) (stub agg function, expose data, explain)
--Testcase 454:
EXPLAIN VERBOSE
SELECT (influx_sum('/value[1,4]/')::s3).* from s3;

-- select influx_sum(regex) (stub agg function, expose data, result)
--Testcase 455:
SELECT (influx_sum('/value[1,4]/')::s3).* from s3;

-- selector function bottom() (explain)
--Testcase 456:
EXPLAIN VERBOSE
SELECT bottom(value1, 1) FROM s3;

-- selector function bottom() (result)
--Testcase 457:
SELECT bottom(value1, 1) FROM s3;

-- selector function bottom() cannot be combined with other functions(explain)
--Testcase 458:
EXPLAIN VERBOSE
SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3;

-- selector function bottom() cannot be combined with other functions(result)
--Testcase 459:
SELECT bottom(value1, 1), bottom(value2, 1), bottom(value3, 1), bottom(value4, 1) FROM s3;

-- select influx_max(*) (stub agg function, explain)
--Testcase 460:
EXPLAIN VERBOSE
SELECT influx_max_all(*) from s3;

-- select influx_max(*) (stub agg function, result)
--Testcase 461:
SELECT influx_max_all(*) from s3;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 462:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_max(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 463:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_max(*) (stub agg function and group by tag only) (explain)
--Testcase 464:
EXPLAIN VERBOSE
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_max(*) (stub agg function and group by tag only) (result)
--Testcase 465:
SELECT influx_max_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_max(*) (stub agg function, expose data, explain)
--Testcase 466:
EXPLAIN VERBOSE
SELECT (influx_max_all(*)::s3).* from s3;

-- select influx_max(*) (stub agg function, expose data, result)
--Testcase 467:
SELECT (influx_max_all(*)::s3).* from s3;

-- select influx_max(regex) (stub function, explain)
--Testcase 468:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') from s3;

-- select influx_max(regex) (stub function, result)
--Testcase 469:
SELECT influx_max('/value[1,4]/') from s3;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 470:
EXPLAIN VERBOSE
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_max(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 471:
SELECT influx_max('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_max(regex) (stub agg function and group by tag only) (explain)
--Testcase 472:
EXPLAIN VERBOSE
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_max(regex) (stub agg function and group by tag only) (result)
--Testcase 473:
SELECT influx_max('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_max(regex) (stub agg function, expose data, explain)
--Testcase 474:
EXPLAIN VERBOSE
SELECT (influx_max('/value[1,4]/')::s3).* from s3;

-- select influx_max(regex) (stub agg function, expose data, result)
--Testcase 475:
SELECT (influx_max('/value[1,4]/')::s3).* from s3;

-- select influx_min(*) (stub agg function, explain)
--Testcase 476:
EXPLAIN VERBOSE
SELECT influx_min_all(*) from s3;

-- select influx_min(*) (stub agg function, result)
--Testcase 477:
SELECT influx_min_all(*) from s3;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 478:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_min(*) (stub agg function and group by influx_time() and tag) (result)
--Testcase 479:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_min(*) (stub agg function and group by tag only) (explain)
--Testcase 480:
EXPLAIN VERBOSE
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_min(*) (stub agg function and group by tag only) (result)
--Testcase 481:
SELECT influx_min_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_min(*) (stub agg function, expose data, explain)
--Testcase 482:
EXPLAIN VERBOSE
SELECT (influx_min_all(*)::s3).* from s3;

-- select influx_min(*) (stub agg function, expose data, result)
--Testcase 483:
SELECT (influx_min_all(*)::s3).* from s3;

-- select influx_min(regex) (stub function, explain)
--Testcase 484:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') from s3;

-- select influx_min(regex) (stub function, result)
--Testcase 485:
SELECT influx_min('/value[1,4]/') from s3;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (explain)
--Testcase 486:
EXPLAIN VERBOSE
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_min(regex) (stub agg function and group by influx_time() and tag) (result)
--Testcase 487:
SELECT influx_min('/^v.*/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select influx_min(regex) (stub agg function and group by tag only) (explain)
--Testcase 488:
EXPLAIN VERBOSE
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_min(regex) (stub agg function and group by tag only) (result)
--Testcase 489:
SELECT influx_min('/value[1,4]/') FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select influx_min(regex) (stub agg function, expose data, explain)
--Testcase 490:
EXPLAIN VERBOSE
SELECT (influx_min('/value[1,4]/')::s3).* from s3;

-- select influx_min(regex) (stub agg function, expose data, result)
--Testcase 491:
SELECT (influx_min('/value[1,4]/')::s3).* from s3;

-- selector function percentile() (explain)
--Testcase 492:
EXPLAIN VERBOSE
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3;

-- selector function percentile() (result)
--Testcase 493:
SELECT percentile(value1, 50), percentile(value2, 60), percentile(value3, 25), percentile(value4, 33) FROM s3;

-- selector function percentile() (explain)
--Testcase 494:
EXPLAIN VERBOSE
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3;

-- selector function percentile() (result)
--Testcase 495:
SELECT percentile(value1, 1.5), percentile(value2, 6.7), percentile(value3, 20.5), percentile(value4, 75.2) FROM s3;

-- select percentile(*, int) (stub function, explain)
--Testcase 496:
EXPLAIN VERBOSE
SELECT percentile_all(50) from s3;

-- select percentile(*, int) (stub function, result)
--Testcase 497:
SELECT percentile_all(50) from s3;

-- select percentile(*, float8) (stub function, explain)
--Testcase 498:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) from s3;

-- select percentile(*, float8) (stub function, result)
--Testcase 499:
SELECT percentile_all(70.5) from s3;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (explain)
--Testcase 500:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(*, int) (stub function and group by influx_time() and tag) (result)
--Testcase 501:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (explain)
--Testcase 502:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(*, float8) (stub function and group by influx_time() and tag) (result)
--Testcase 503:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(*, int) (stub function and group by tag only) (explain)
--Testcase 1302:
EXPLAIN VERBOSE
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(*, int) (stub function and group by tag only) (result)
--Testcase 1303:
SELECT percentile_all(50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(*, float8) (stub function and group by tag only) (explain)
--Testcase 1304:
EXPLAIN VERBOSE
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(*, float8) (stub function and group by tag only) (result)
--Testcase 1305:
SELECT percentile_all(70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 504:
EXPLAIN VERBOSE
SELECT (percentile_all(50)::s3).* from s3;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 505:
SELECT (percentile_all(50)::s3).* from s3;

-- select percentile(*, int) (stub function, expose data, explain)
--Testcase 506:
EXPLAIN VERBOSE
SELECT (percentile_all(70.5)::s3).* from s3;

-- select percentile(*, int) (stub function, expose data, result)
--Testcase 507:
SELECT (percentile_all(70.5)::s3).* from s3;

-- select percentile(regex) (stub function, explain)
--Testcase 508:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 50) from s3;

-- select percentile(regex) (stub function, result)
--Testcase 509:
SELECT percentile('/value[1,4]/', 50) from s3;

-- select percentile(regex) (stub function and group by influx_time() and tag) (explain)
--Testcase 510:
EXPLAIN VERBOSE
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(regex) (stub function and group by influx_time() and tag) (result)
--Testcase 511:
SELECT percentile('/^v.*/', 50) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select percentile(regex) (stub function and group by tag only) (explain)
--Testcase 1306:
EXPLAIN VERBOSE
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(regex) (stub function and group by tag only) (result)
--Testcase 1307:
SELECT percentile('/value[1,4]/', 70.5) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 512:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 513:
SELECT (percentile('/value[1,4]/', 50)::s3).* from s3;

-- select percentile(regex) (stub function, expose data, explain)
--Testcase 514:
EXPLAIN VERBOSE
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3;

-- select percentile(regex) (stub function, expose data, result)
--Testcase 515:
SELECT (percentile('/value[1,4]/', 70.5)::s3).* from s3;

-- selector function top(field_key,N) (explain)
--Testcase 516:
EXPLAIN VERBOSE
SELECT top(value1, 1) FROM s3;

-- selector function top(field_key,N) (result)
--Testcase 517:
SELECT top(value1, 1) FROM s3;

-- selector function top(field_key,tag_key(s),N) (explain)
--Testcase 518:
EXPLAIN VERBOSE
SELECT top(value1, tag1, 1) FROM s3;

-- selector function top(field_key,tag_key(s),N) (result)
--Testcase 519:
SELECT top(value1, tag1, 1) FROM s3;

-- selector function top() cannot be combined with other functions(explain)
--Testcase 520:
EXPLAIN VERBOSE
SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3;

-- selector function top() cannot be combined with other functions(result)
--Testcase 521:
SELECT top(value1, 1), top(value2, 1), top(value3, 1), top(value4, 1) FROM s3;

-- select acos (builtin function, explain)
--Testcase 522:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3;

-- select acos (builtin function, result)
--Testcase 523:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3;

-- select acos (builtin function, not pushdown constraints, explain)
--Testcase 524:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64';

-- select acos (builtin function, not pushdown constraints, result)
--Testcase 525:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE to_hex(value2) = '64';

-- select acos (builtin function, pushdown constraints, explain)
--Testcase 526:
EXPLAIN VERBOSE
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200;

-- select acos (builtin function, pushdown constraints, result)
--Testcase 527:
SELECT acos(value1), acos(value2), acos(value3), acos(value4) FROM s3 WHERE value2 != 200;

-- select acos as nest function with agg (pushdown, explain)
--Testcase 528:
EXPLAIN VERBOSE
SELECT sum(value3),acos(sum(value3)) FROM s3;

-- select acos as nest function with agg (pushdown, result)
--Testcase 529:
SELECT sum(value3),acos(sum(value3)) FROM s3;

-- select acos as nest with log2 (pushdown, explain)
--Testcase 530:
EXPLAIN VERBOSE
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3;

-- select acos as nest with log2 (pushdown, result)
--Testcase 531:
SELECT acos(log2(value1)),acos(log2(1/value1)) FROM s3;

-- select acos with non pushdown func and explicit constant (explain)
--Testcase 532:
EXPLAIN VERBOSE
SELECT acos(value3), pi(), 4.1 FROM s3;

-- select acos with non pushdown func and explicit constant (result)
--Testcase 533:
SELECT acos(value3), pi(), 4.1 FROM s3;

-- select acos with order by (explain)
--Testcase 534:
EXPLAIN VERBOSE
SELECT value1, acos(1-value1) FROM s3 order by acos(1-value1);

-- select acos with order by (result)
--Testcase 535:
SELECT value1, acos(1-value1) FROM s3 order by acos(1-value1);

-- select acos with order by index (result)
--Testcase 536:
SELECT value1, acos(1-value1) FROM s3 order by 2,1;

-- select acos with order by index (result)
--Testcase 537:
SELECT value1, acos(1-value1) FROM s3 order by 1,2;

-- select acos and as
--Testcase 538:
SELECT acos(value3) as acos1 FROM s3;

-- select acos(*) (stub function, explain)
--Testcase 539:
EXPLAIN VERBOSE
SELECT acos_all() from s3;

-- select acos(*) (stub function, result)
--Testcase 540:
SELECT acos_all() from s3;

-- select acos(*) (stub function and group by tag only) (explain)
--Testcase 1308:
EXPLAIN VERBOSE
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select acos(*) (stub function and group by tag only) (result)
--Testcase 1309:
SELECT acos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select acos(*) (stub function, expose data, explain)
--Testcase 541:
EXPLAIN VERBOSE
SELECT (acos_all()::s3).* from s3;

-- select acos(*) (stub function, expose data, result)
--Testcase 542:
SELECT (acos_all()::s3).* from s3;

-- select asin (builtin function, explain)
--Testcase 543:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3;

-- select asin (builtin function, result)
--Testcase 544:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3;

-- select asin (builtin function, not pushdown constraints, explain)
--Testcase 545:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64';

-- select asin (builtin function, not pushdown constraints, result)
--Testcase 546:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE to_hex(value2) = '64';

-- select asin (builtin function, pushdown constraints, explain)
--Testcase 547:
EXPLAIN VERBOSE
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200;

-- select asin (builtin function, pushdown constraints, result)
--Testcase 548:
SELECT asin(value1), asin(value2), asin(value3), asin(value4) FROM s3 WHERE value2 != 200;

-- select asin as nest function with agg (pushdown, explain)
--Testcase 549:
EXPLAIN VERBOSE
SELECT sum(value3),asin(sum(value3)) FROM s3;

-- select asin as nest function with agg (pushdown, result)
--Testcase 550:
SELECT sum(value3),asin(sum(value3)) FROM s3;

-- select asin as nest with log2 (pushdown, explain)
--Testcase 551:
EXPLAIN VERBOSE
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3;

-- select asin as nest with log2 (pushdown, result)
--Testcase 552:
SELECT asin(log2(value1)),asin(log2(1/value1)) FROM s3;

-- select asin with non pushdown func and explicit constant (explain)
--Testcase 553:
EXPLAIN VERBOSE
SELECT asin(value3), pi(), 4.1 FROM s3;

-- select asin with non pushdown func and explicit constant (result)
--Testcase 554:
SELECT asin(value3), pi(), 4.1 FROM s3;

-- select asin with order by (explain)
--Testcase 555:
EXPLAIN VERBOSE
SELECT value1, asin(1-value1) FROM s3 order by asin(1-value1);

-- select asin with order by (result)
--Testcase 556:
SELECT value1, asin(1-value1) FROM s3 order by asin(1-value1);

-- select asin with order by index (result)
--Testcase 557:
SELECT value1, asin(1-value1) FROM s3 order by 2,1;

-- select asin with order by index (result)
--Testcase 558:
SELECT value1, asin(1-value1) FROM s3 order by 1,2;

-- select asin and as
--Testcase 559:
SELECT asin(value3) as asin1 FROM s3;

-- select asin(*) (stub function, explain)
--Testcase 560:
EXPLAIN VERBOSE
SELECT asin_all() from s3;

-- select asin(*) (stub function, result)
--Testcase 561:
SELECT asin_all() from s3;

-- select asin(*) (stub function and group by tag only) (explain)
--Testcase 1310:
EXPLAIN VERBOSE
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select asin(*) (stub function and group by tag only) (result)
--Testcase 1311:
SELECT asin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select asin(*) (stub function, expose data, explain)
--Testcase 562:
EXPLAIN VERBOSE
SELECT (asin_all()::s3).* from s3;

-- select asin(*) (stub function, expose data, result)
--Testcase 563:
SELECT (asin_all()::s3).* from s3;

-- select atan (builtin function, explain)
--Testcase 564:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3;

-- select atan (builtin function, result)
--Testcase 565:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3;

-- select atan (builtin function, not pushdown constraints, explain)
--Testcase 566:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select atan (builtin function, not pushdown constraints, result)
--Testcase 567:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select atan (builtin function, pushdown constraints, explain)
--Testcase 568:
EXPLAIN VERBOSE
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200;

-- select atan (builtin function, pushdown constraints, result)
--Testcase 569:
SELECT atan(value1), atan(value2), atan(value3), atan(value4) FROM s3 WHERE value2 != 200;

-- select atan as nest function with agg (pushdown, explain)
--Testcase 570:
EXPLAIN VERBOSE
SELECT sum(value3),atan(sum(value3)) FROM s3;

-- select atan as nest function with agg (pushdown, result)
--Testcase 571:
SELECT sum(value3),atan(sum(value3)) FROM s3;

-- select atan as nest with log2 (pushdown, explain)
--Testcase 572:
EXPLAIN VERBOSE
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3;

-- select atan as nest with log2 (pushdown, result)
--Testcase 573:
SELECT atan(log2(value1)),atan(log2(1/value1)) FROM s3;

-- select atan with non pushdown func and explicit constant (explain)
--Testcase 574:
EXPLAIN VERBOSE
SELECT atan(value3), pi(), 4.1 FROM s3;

-- select atan with non pushdown func and explicit constant (result)
--Testcase 575:
SELECT atan(value3), pi(), 4.1 FROM s3;

-- select atan with order by (explain)
--Testcase 576:
EXPLAIN VERBOSE
SELECT value1, atan(1-value1) FROM s3 order by atan(1-value1);

-- select atan with order by (result)
--Testcase 577:
SELECT value1, atan(1-value1) FROM s3 order by atan(1-value1);

-- select atan with order by index (result)
--Testcase 578:
SELECT value1, atan(1-value1) FROM s3 order by 2,1;

-- select atan with order by index (result)
--Testcase 579:
SELECT value1, atan(1-value1) FROM s3 order by 1,2;

-- select atan and as
--Testcase 580:
SELECT atan(value3) as atan1 FROM s3;

-- select atan(*) (stub function, explain)
--Testcase 581:
EXPLAIN VERBOSE
SELECT atan_all() from s3;

-- select atan(*) (stub function, result)
--Testcase 582:
SELECT atan_all() from s3;

-- select atan(*) (stub function and group by tag only) (explain)
--Testcase 1312:
EXPLAIN VERBOSE
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select atan(*) (stub function and group by tag only) (result)
--Testcase 1313:
SELECT atan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select atan(*) (stub function, expose data, explain)
--Testcase 583:
EXPLAIN VERBOSE
SELECT (atan_all()::s3).* from s3;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 584:
SELECT asin_all(), acos_all(), atan_all() FROM s3;

-- select atan2 (builtin function, explain)
--Testcase 585:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3;

-- select atan2 (builtin function, result)
--Testcase 586:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3;

-- select atan2 (builtin function, not pushdown constraints, explain)
--Testcase 587:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64';

-- select atan2 (builtin function, not pushdown constraints, result)
--Testcase 588:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE to_hex(value2) != '64';

-- select atan2 (builtin function, pushdown constraints, explain)
--Testcase 589:
EXPLAIN VERBOSE
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200;

-- select atan2 (builtin function, pushdown constraints, result)
--Testcase 590:
SELECT atan2(value1, value2), atan2(value2, value3), atan2(value3, value4), atan2(value4, value1) FROM s3 WHERE value2 != 200;

-- select atan2 as nest function with agg (pushdown, explain)
--Testcase 591:
EXPLAIN VERBOSE
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3;

-- select atan2 as nest function with agg (pushdown, result)
--Testcase 592:
SELECT sum(value3), sum(value4),atan2(sum(value3), sum(value3)) FROM s3;

-- select atan2 as nest with log2 (pushdown, explain)
--Testcase 593:
EXPLAIN VERBOSE
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3;

-- select atan2 as nest with log2 (pushdown, result)
--Testcase 594:
SELECT atan2(log2(value1), log2(value1)),atan2(log2(1/value1), log2(1/value1)) FROM s3;

-- select atan2 with non pushdown func and explicit constant (explain)
--Testcase 595:
EXPLAIN VERBOSE
SELECT atan2(value3, value4), pi(), 4.1 FROM s3;

-- select atan2 with non pushdown func and explicit constant (result)
--Testcase 596:
SELECT atan2(value3, value4), pi(), 4.1 FROM s3;

-- select atan2 with order by (explain)
--Testcase 597:
EXPLAIN VERBOSE
SELECT value1, atan2(1-value1, 1-value2) FROM s3 order by atan2(1-value1, 1-value2);

-- select atan2 with order by (result)
--Testcase 598:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 order by atan2(1-value1, 1-value2);

-- select atan2 with order by index (result)
--Testcase 599:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 order by 2,1;

-- select atan2 with order by index (result)
--Testcase 600:
SELECT value1, atan2(1-value1, 1-value2) FROM s3 order by 1,2;

-- select atan2 and as
--Testcase 601:
SELECT atan2(value3, value4) as atan21 FROM s3;

-- select atan2(*) (stub function, explain)
--Testcase 602:
EXPLAIN VERBOSE
SELECT atan2_all(value1) from s3;

-- select atan2(*) (stub function, result)
--Testcase 603:
SELECT atan2_all(value1) from s3;

-- select ceil (builtin function, explain)
--Testcase 604:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3;

-- select ceil (builtin function, result)
--Testcase 605:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3;

-- select ceil (builtin function, not pushdown constraints, explain)
--Testcase 606:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select ceil (builtin function, not pushdown constraints, result)
--Testcase 607:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select ceil (builtin function, pushdown constraints, explain)
--Testcase 608:
EXPLAIN VERBOSE
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200;

-- select ceil (builtin function, pushdown constraints, result)
--Testcase 609:
SELECT ceil(value1), ceil(value2), ceil(value3), ceil(value4) FROM s3 WHERE value2 != 200;

-- select ceil as nest function with agg (pushdown, explain)
--Testcase 610:
EXPLAIN VERBOSE
SELECT sum(value3),ceil(sum(value3)) FROM s3;

-- select ceil as nest function with agg (pushdown, result)
--Testcase 611:
SELECT sum(value3),ceil(sum(value3)) FROM s3;

-- select ceil as nest with log2 (pushdown, explain)
--Testcase 612:
EXPLAIN VERBOSE
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3;

-- select ceil as nest with log2 (pushdown, result)
--Testcase 613:
SELECT ceil(log2(value1)),ceil(log2(1/value1)) FROM s3;

-- select ceil with non pushdown func and explicit constant (explain)
--Testcase 614:
EXPLAIN VERBOSE
SELECT ceil(value3), pi(), 4.1 FROM s3;

-- select ceil with non pushdown func and explicit constant (result)
--Testcase 615:
SELECT ceil(value3), pi(), 4.1 FROM s3;

-- select ceil with order by (explain)
--Testcase 616:
EXPLAIN VERBOSE
SELECT value1, ceil(1-value1) FROM s3 order by ceil(1-value1);

-- select ceil with order by (result)
--Testcase 617:
SELECT value1, ceil(1-value1) FROM s3 order by ceil(1-value1);

-- select ceil with order by index (result)
--Testcase 618:
SELECT value1, ceil(1-value1) FROM s3 order by 2,1;

-- select ceil with order by index (result)
--Testcase 619:
SELECT value1, ceil(1-value1) FROM s3 order by 1,2;

-- select ceil and as
--Testcase 620:
SELECT ceil(value3) as ceil1 FROM s3;

-- select ceil(*) (stub function, explain)
--Testcase 621:
EXPLAIN VERBOSE
SELECT ceil_all() from s3;

-- select ceil(*) (stub function, result)
--Testcase 622:
SELECT ceil_all() from s3;

-- select ceil(*) (stub function and group by tag only) (explain)
--Testcase 1314:
EXPLAIN VERBOSE
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select ceil(*) (stub function and group by tag only) (result)
--Testcase 1315:
SELECT ceil_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select ceil(*) (stub function, expose data, explain)
--Testcase 623:
EXPLAIN VERBOSE
SELECT (ceil_all()::s3).* from s3;

-- select ceil(*) (stub function, expose data, result)
--Testcase 624:
SELECT (ceil_all()::s3).* from s3;

-- select cos (builtin function, explain)
--Testcase 625:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3;

-- select cos (builtin function, result)
--Testcase 626:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3;

-- select cos (builtin function, not pushdown constraints, explain)
--Testcase 627:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select cos (builtin function, not pushdown constraints, result)
--Testcase 628:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select cos (builtin function, pushdown constraints, explain)
--Testcase 629:
EXPLAIN VERBOSE
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200;

-- select cos (builtin function, pushdown constraints, result)
--Testcase 630:
SELECT cos(value1), cos(value2), cos(value3), cos(value4) FROM s3 WHERE value2 != 200;

-- select cos as nest function with agg (pushdown, explain)
--Testcase 631:
EXPLAIN VERBOSE
SELECT sum(value3),cos(sum(value3)) FROM s3;

-- select cos as nest function with agg (pushdown, result)
--Testcase 632:
SELECT sum(value3),cos(sum(value3)) FROM s3;

-- select cos as nest with log2 (pushdown, explain)
--Testcase 633:
EXPLAIN VERBOSE
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3;

-- select cos as nest with log2 (pushdown, result)
--Testcase 634:
SELECT cos(log2(value1)),cos(log2(1/value1)) FROM s3;

-- select cos with non pushdown func and explicit constant (explain)
--Testcase 635:
EXPLAIN VERBOSE
SELECT cos(value3), pi(), 4.1 FROM s3;

-- select cos with non pushdown func and explicit constant (result)
--Testcase 636:
SELECT cos(value3), pi(), 4.1 FROM s3;

-- select cos with order by (explain)
--Testcase 637:
EXPLAIN VERBOSE
SELECT value1, cos(1-value1) FROM s3 order by cos(1-value1);

-- select cos with order by (result)
--Testcase 638:
SELECT value1, cos(1-value1) FROM s3 order by cos(1-value1);

-- select cos with order by index (result)
--Testcase 639:
SELECT value1, cos(1-value1) FROM s3 order by 2,1;

-- select cos with order by index (result)
--Testcase 640:
SELECT value1, cos(1-value1) FROM s3 order by 1,2;

-- select cos and as
--Testcase 641:
SELECT cos(value3) as cos1 FROM s3;

-- select cos(*) (stub function, explain)
--Testcase 642:
EXPLAIN VERBOSE
SELECT cos_all() from s3;

-- select cos(*) (stub function, result)
--Testcase 643:
SELECT cos_all() from s3;

-- select cos(*) (stub function and group by tag only) (explain)
--Testcase 1316:
EXPLAIN VERBOSE
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select cos(*) (stub function and group by tag only) (result)
--Testcase 1317:
SELECT cos_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select exp (builtin function, explain)
--Testcase 644:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3;

-- select exp (builtin function, result)
--Testcase 645:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3;

-- select exp (builtin function, not pushdown constraints, explain)
--Testcase 646:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select exp (builtin function, not pushdown constraints, result)
--Testcase 647:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select exp (builtin function, pushdown constraints, explain)
--Testcase 648:
EXPLAIN VERBOSE
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200;

-- select exp (builtin function, pushdown constraints, result)
--Testcase 649:
SELECT exp(value1), exp(value2), exp(value3), exp(value4) FROM s3 WHERE value2 != 200;

-- select exp as nest function with agg (pushdown, explain)
--Testcase 650:
EXPLAIN VERBOSE
SELECT sum(value3),exp(sum(value3)) FROM s3;

-- select exp as nest function with agg (pushdown, result)
--Testcase 651:
SELECT sum(value3),exp(sum(value3)) FROM s3;

-- select exp as nest with log2 (pushdown, explain)
--Testcase 652:
EXPLAIN VERBOSE
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3;

-- select exp as nest with log2 (pushdown, result)
--Testcase 653:
SELECT exp(log2(value1)),exp(log2(1/value1)) FROM s3;

-- select exp with non pushdown func and explicit constant (explain)
--Testcase 654:
EXPLAIN VERBOSE
SELECT exp(value3), pi(), 4.1 FROM s3;

-- select exp with non pushdown func and explicit constant (result)
--Testcase 655:
SELECT exp(value3), pi(), 4.1 FROM s3;

-- select exp with order by (explain)
--Testcase 656:
EXPLAIN VERBOSE
SELECT value1, exp(1-value1) FROM s3 order by exp(1-value1);

-- select exp with order by (result)
--Testcase 657:
SELECT value1, exp(1-value1) FROM s3 order by exp(1-value1);

-- select exp with order by index (result)
--Testcase 658:
SELECT value1, exp(1-value1) FROM s3 order by 2,1;

-- select exp with order by index (result)
--Testcase 659:
SELECT value1, exp(1-value1) FROM s3 order by 1,2;

-- select exp and as
--Testcase 660:
SELECT exp(value3) as exp1 FROM s3;

-- select exp(*) (stub function, explain)
--Testcase 661:
EXPLAIN VERBOSE
SELECT exp_all() from s3;

-- select exp(*) (stub function, result)
--Testcase 662:
SELECT exp_all() from s3;

-- select exp(*) (stub function and group by tag only) (explain)
--Testcase 1318:
EXPLAIN VERBOSE
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select exp(*) (stub function and group by tag only) (result)
--Testcase 1319:
SELECT exp_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 663:
SELECT ceil_all(), cos_all(), exp_all() FROM s3;

-- select floor (builtin function, explain)
--Testcase 664:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3;

-- select floor (builtin function, result)
--Testcase 665:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3;

-- select floor (builtin function, not pushdown constraints, explain)
--Testcase 666:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select floor (builtin function, not pushdown constraints, result)
--Testcase 667:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select floor (builtin function, pushdown constraints, explain)
--Testcase 668:
EXPLAIN VERBOSE
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200;

-- select floor (builtin function, pushdown constraints, result)
--Testcase 669:
SELECT floor(value1), floor(value2), floor(value3), floor(value4) FROM s3 WHERE value2 != 200;

-- select floor as nest function with agg (pushdown, explain)
--Testcase 670:
EXPLAIN VERBOSE
SELECT sum(value3),floor(sum(value3)) FROM s3;

-- select floor as nest function with agg (pushdown, result)
--Testcase 671:
SELECT sum(value3),floor(sum(value3)) FROM s3;

-- select floor as nest with log2 (pushdown, explain)
--Testcase 672:
EXPLAIN VERBOSE
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3;

-- select floor as nest with log2 (pushdown, result)
--Testcase 673:
SELECT floor(log2(value1)),floor(log2(1/value1)) FROM s3;

-- select floor with non pushdown func and explicit constant (explain)
--Testcase 674:
EXPLAIN VERBOSE
SELECT floor(value3), pi(), 4.1 FROM s3;

-- select floor with non pushdown func and explicit constant (result)
--Testcase 675:
SELECT floor(value3), pi(), 4.1 FROM s3;

-- select floor with order by (explain)
--Testcase 676:
EXPLAIN VERBOSE
SELECT value1, floor(1-value1) FROM s3 order by floor(1-value1);

-- select floor with order by (result)
--Testcase 677:
SELECT value1, floor(1-value1) FROM s3 order by floor(1-value1);

-- select floor with order by index (result)
--Testcase 678:
SELECT value1, floor(1-value1) FROM s3 order by 2,1;

-- select floor with order by index (result)
--Testcase 679:
SELECT value1, floor(1-value1) FROM s3 order by 1,2;

-- select floor and as
--Testcase 680:
SELECT floor(value3) as floor1 FROM s3;

-- select floor(*) (stub function, explain)
--Testcase 681:
EXPLAIN VERBOSE
SELECT floor_all() from s3;

-- select floor(*) (stub function, result)
--Testcase 682:
SELECT floor_all() from s3;

-- select floor(*) (stub function and group by tag only) (explain)
--Testcase 1320:
EXPLAIN VERBOSE
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select floor(*) (stub function and group by tag only) (result)
--Testcase 1321:
SELECT floor_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select floor(*) (stub function, expose data, explain)
--Testcase 683:
EXPLAIN VERBOSE
SELECT (floor_all()::s3).* from s3;

-- select floor(*) (stub function, expose data, result)
--Testcase 684:
SELECT (floor_all()::s3).* from s3;

-- select ln (builtin function, explain)
--Testcase 685:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3;

-- select ln (builtin function, result)
--Testcase 686:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3;

-- select ln (builtin function, not pushdown constraints, explain)
--Testcase 687:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select ln (builtin function, not pushdown constraints, result)
--Testcase 688:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select ln (builtin function, pushdown constraints, explain)
--Testcase 689:
EXPLAIN VERBOSE
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200;

-- select ln (builtin function, pushdown constraints, result)
--Testcase 690:
SELECT ln(value1), ln(value2), ln(value3), ln(value4) FROM s3 WHERE value2 != 200;

-- select ln as nest function with agg (pushdown, explain)
--Testcase 691:
EXPLAIN VERBOSE
SELECT sum(value3),ln(sum(value3)) FROM s3;

-- select ln as nest function with agg (pushdown, result)
--Testcase 692:
SELECT sum(value3),ln(sum(value3)) FROM s3;

-- select ln as nest with log2 (pushdown, explain)
--Testcase 693:
EXPLAIN VERBOSE
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3;

-- select ln as nest with log2 (pushdown, result)
--Testcase 694:
SELECT ln(log2(value1)),ln(log2(1/value1)) FROM s3;

-- select ln with non pushdown func and explicit constant (explain)
--Testcase 695:
EXPLAIN VERBOSE
SELECT ln(value3), pi(), 4.1 FROM s3;

-- select ln with non pushdown func and explicit constant (result)
--Testcase 696:
SELECT ln(value3), pi(), 4.1 FROM s3;

-- select ln with order by (explain)
--Testcase 697:
EXPLAIN VERBOSE
SELECT value1, ln(1-value1) FROM s3 order by ln(1-value1);

-- select ln with order by (result)
--Testcase 698:
SELECT value1, ln(1-value1) FROM s3 order by ln(1-value1);

-- select ln with order by index (result)
--Testcase 699:
SELECT value1, ln(1-value1) FROM s3 order by 2,1;

-- select ln with order by index (result)
--Testcase 700:
SELECT value1, ln(1-value1) FROM s3 order by 1,2;

-- select ln and as
--Testcase 701:
SELECT ln(value1) as ln1 FROM s3;

-- select ln(*) (stub function, explain)
--Testcase 702:
EXPLAIN VERBOSE
SELECT ln_all() from s3;

-- select ln(*) (stub function, result)
--Testcase 703:
SELECT ln_all() from s3;

-- select ln(*) (stub function and group by tag only) (explain)
--Testcase 1322:
EXPLAIN VERBOSE
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select ln(*) (stub function and group by tag only) (result)
--Testcase 1323:
SELECT ln_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 704:
SELECT ln_all(), floor_all() FROM s3;

-- select pow (builtin function, explain)
--Testcase 705:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3;

-- select pow (builtin function, result)
--Testcase 706:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3;

-- select pow (builtin function, not pushdown constraints, explain)
--Testcase 707:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64';

-- select pow (builtin function, not pushdown constraints, result)
--Testcase 708:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE to_hex(value2) != '64';

-- select pow (builtin function, pushdown constraints, explain)
--Testcase 709:
EXPLAIN VERBOSE
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200;

-- select pow (builtin function, pushdown constraints, result)
--Testcase 710:
SELECT pow(value1, 2), pow(value2, 2), pow(value3, 2), pow(value4, 2) FROM s3 WHERE value2 != 200;

-- select pow as nest function with agg (pushdown, explain)
--Testcase 711:
EXPLAIN VERBOSE
SELECT sum(value3),pow(sum(value3), 2) FROM s3;

-- select pow as nest function with agg (pushdown, result)
--Testcase 712:
SELECT sum(value3),pow(sum(value3), 2) FROM s3;

-- select pow as nest with log2 (pushdown, explain)
--Testcase 713:
EXPLAIN VERBOSE
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3;

-- select pow as nest with log2 (pushdown, result)
--Testcase 714:
SELECT pow(log2(value1), 2),pow(log2(1/value1), 2) FROM s3;

-- select pow with non pushdown func and explicit constant (explain)
--Testcase 715:
EXPLAIN VERBOSE
SELECT pow(value3, 2), pi(), 4.1 FROM s3;

-- select pow with non pushdown func and explicit constant (result)
--Testcase 716:
SELECT pow(value3, 2), pi(), 4.1 FROM s3;

-- select pow with order by (explain)
--Testcase 717:
EXPLAIN VERBOSE
SELECT value1, pow(1-value1, 2) FROM s3 order by pow(1-value1, 2);

-- select pow with order by (result)
--Testcase 718:
SELECT value1, pow(1-value1, 2) FROM s3 order by pow(1-value1, 2);

-- select pow with order by index (result)
--Testcase 719:
SELECT value1, pow(1-value1, 2) FROM s3 order by 2,1;

-- select pow with order by index (result)
--Testcase 720:
SELECT value1, pow(1-value1, 2) FROM s3 order by 1,2;

-- select pow and as
--Testcase 721:
SELECT pow(value3, 2) as pow1 FROM s3;

-- select pow_all(2) (stub function, explain)
--Testcase 722:
EXPLAIN VERBOSE
SELECT pow_all(2) from s3;

-- select pow_all(2) (stub function, result)
--Testcase 723:
SELECT pow_all(2) from s3;

-- select pow_all(2) (stub function and group by tag only) (explain)
--Testcase 1324:
EXPLAIN VERBOSE
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select pow_all(2) (stub function and group by tag only) (result)
--Testcase 1325:
SELECT pow_all(2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select pow_all(2) (stub function, expose data, explain)
--Testcase 724:
EXPLAIN VERBOSE
SELECT (pow_all(2)::s3).* from s3;

-- select pow_all(2) (stub function, expose data, result)
--Testcase 725:
SELECT (pow_all(2)::s3).* from s3;

-- select round (builtin function, explain)
--Testcase 726:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3;

-- select round (builtin function, result)
--Testcase 727:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3;

-- select round (builtin function, not pushdown constraints, explain)
--Testcase 728:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select round (builtin function, not pushdown constraints, result)
--Testcase 729:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select round (builtin function, pushdown constraints, explain)
--Testcase 730:
EXPLAIN VERBOSE
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200;

-- select round (builtin function, pushdown constraints, result)
--Testcase 731:
SELECT round(value1), round(value2), round(value3), round(value4) FROM s3 WHERE value2 != 200;

-- select round as nest function with agg (pushdown, explain)
--Testcase 732:
EXPLAIN VERBOSE
SELECT sum(value3),round(sum(value3)) FROM s3;

-- select round as nest function with agg (pushdown, result)
--Testcase 733:
SELECT sum(value3),round(sum(value3)) FROM s3;

-- select round as nest with log2 (pushdown, explain)
--Testcase 734:
EXPLAIN VERBOSE
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3;

-- select round as nest with log2 (pushdown, result)
--Testcase 735:
SELECT round(log2(value1)),round(log2(1/value1)) FROM s3;

-- select round with non pushdown func and roundlicit constant (explain)
--Testcase 736:
EXPLAIN VERBOSE
SELECT round(value3), pi(), 4.1 FROM s3;

-- select round with non pushdown func and roundlicit constant (result)
--Testcase 737:
SELECT round(value3), pi(), 4.1 FROM s3;

-- select round with order by (explain)
--Testcase 738:
EXPLAIN VERBOSE
SELECT value1, round(1-value1) FROM s3 order by round(1-value1);

-- select round with order by (result)
--Testcase 739:
SELECT value1, round(1-value1) FROM s3 order by round(1-value1);

-- select round with order by index (result)
--Testcase 740:
SELECT value1, round(1-value1) FROM s3 order by 2,1;

-- select round with order by index (result)
--Testcase 741:
SELECT value1, round(1-value1) FROM s3 order by 1,2;

-- select round and as
--Testcase 742:
SELECT round(value3) as round1 FROM s3;

-- select round(*) (stub function, explain)
--Testcase 743:
EXPLAIN VERBOSE
SELECT round_all() from s3;

-- select round(*) (stub function, result)
--Testcase 744:
SELECT round_all() from s3;

-- select round(*) (stub function and group by tag only) (explain)
--Testcase 1326:
EXPLAIN VERBOSE
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select round(*) (stub function and group by tag only) (result)
--Testcase 1327:
SELECT round_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select round(*) (stub function, expose data, explain)
--Testcase 745:
EXPLAIN VERBOSE
SELECT (round_all()::s3).* from s3;

-- select round(*) (stub function, expose data, result)
--Testcase 746:
SELECT (round_all()::s3).* from s3;

-- select sin (builtin function, explain)
--Testcase 747:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3;

-- select sin (builtin function, result)
--Testcase 748:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3;

-- select sin (builtin function, not pushdown constraints, explain)
--Testcase 749:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select sin (builtin function, not pushdown constraints, result)
--Testcase 750:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select sin (builtin function, pushdown constraints, explain)
--Testcase 751:
EXPLAIN VERBOSE
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200;

-- select sin (builtin function, pushdown constraints, result)
--Testcase 752:
SELECT sin(value1), sin(value2), sin(value3), sin(value4) FROM s3 WHERE value2 != 200;

-- select sin as nest function with agg (pushdown, explain)
--Testcase 753:
EXPLAIN VERBOSE
SELECT sum(value3),sin(sum(value3)) FROM s3;

-- select sin as nest function with agg (pushdown, result)
--Testcase 754:
SELECT sum(value3),sin(sum(value3)) FROM s3;

-- select sin as nest with log2 (pushdown, explain)
--Testcase 755:
EXPLAIN VERBOSE
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3;

-- select sin as nest with log2 (pushdown, result)
--Testcase 756:
SELECT sin(log2(value1)),sin(log2(1/value1)) FROM s3;

-- select sin with non pushdown func and explicit constant (explain)
--Testcase 757:
EXPLAIN VERBOSE
SELECT sin(value3), pi(), 4.1 FROM s3;

-- select sin with non pushdown func and explicit constant (result)
--Testcase 758:
SELECT sin(value3), pi(), 4.1 FROM s3;

-- select sin with order by (explain)
--Testcase 759:
EXPLAIN VERBOSE
SELECT value1, sin(1-value1) FROM s3 order by sin(1-value1);

-- select sin with order by (result)
--Testcase 760:
SELECT value1, sin(1-value1) FROM s3 order by sin(1-value1);

-- select sin with order by index (result)
--Testcase 761:
SELECT value1, sin(1-value1) FROM s3 order by 2,1;

-- select sin with order by index (result)
--Testcase 762:
SELECT value1, sin(1-value1) FROM s3 order by 1,2;

-- select sin and as
--Testcase 763:
SELECT sin(value3) as sin1 FROM s3;

-- select sin(*) (stub function, explain)
--Testcase 764:
EXPLAIN VERBOSE
SELECT sin_all() from s3;

-- select sin(*) (stub function, result)
--Testcase 765:
SELECT sin_all() from s3;

-- select sin(*) (stub function and group by tag only) (explain)
--Testcase 1328:
EXPLAIN VERBOSE
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select sin(*) (stub function and group by tag only) (result)
--Testcase 1329:
SELECT sin_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select tan (builtin function, explain)
--Testcase 766:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3;

-- select tan (builtin function, result)
--Testcase 767:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3;

-- select tan (builtin function, not pushdown constraints, explain)
--Testcase 768:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select tan (builtin function, not pushdown constraints, result)
--Testcase 769:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select tan (builtin function, pushdown constraints, explain)
--Testcase 770:
EXPLAIN VERBOSE
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200;

-- select tan (builtin function, pushdown constraints, result)
--Testcase 771:
SELECT tan(value1), tan(value2), tan(value3), tan(value4) FROM s3 WHERE value2 != 200;

-- select tan as nest function with agg (pushdown, explain)
--Testcase 772:
EXPLAIN VERBOSE
SELECT sum(value3),tan(sum(value3)) FROM s3;

-- select tan as nest function with agg (pushdown, result)
--Testcase 773:
SELECT sum(value3),tan(sum(value3)) FROM s3;

-- select tan as nest with log2 (pushdown, explain)
--Testcase 774:
EXPLAIN VERBOSE
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3;

-- select tan as nest with log2 (pushdown, result)
--Testcase 775:
SELECT tan(log2(value1)),tan(log2(1/value1)) FROM s3;

-- select tan with non pushdown func and tanlicit constant (explain)
--Testcase 776:
EXPLAIN VERBOSE
SELECT tan(value3), pi(), 4.1 FROM s3;

-- select tan with non pushdown func and tanlicit constant (result)
--Testcase 777:
SELECT tan(value3), pi(), 4.1 FROM s3;

-- select tan with order by (explain)
--Testcase 778:
EXPLAIN VERBOSE
SELECT value1, tan(1-value1) FROM s3 order by tan(1-value1);

-- select tan with order by (result)
--Testcase 779:
SELECT value1, tan(1-value1) FROM s3 order by tan(1-value1);

-- select tan with order by index (result)
--Testcase 780:
SELECT value1, tan(1-value1) FROM s3 order by 2,1;

-- select tan with order by index (result)
--Testcase 781:
SELECT value1, tan(1-value1) FROM s3 order by 1,2;

-- select tan and as
--Testcase 782:
SELECT tan(value3) as tan1 FROM s3;

-- select tan(*) (stub function, explain)
--Testcase 783:
EXPLAIN VERBOSE
SELECT tan_all() from s3;

-- select tan(*) (stub function, result)
--Testcase 784:
SELECT tan_all() from s3;

-- select tan(*) (stub function and group by tag only) (explain)
--Testcase 1330:
EXPLAIN VERBOSE
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select tan(*) (stub function and group by tag only) (result)
--Testcase 1331:
SELECT tan_all() FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select multiple star functions (do not push down, raise warning and stub error) (result)
--Testcase 785:
SELECT sin_all(), round_all(), tan_all() FROM s3;

-- select predictors function holt_winters() (explain)
--Testcase 786:
EXPLAIN VERBOSE
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s');

-- select predictors function holt_winters() (result)
--Testcase 787:
SELECT holt_winters(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s');

-- select predictors function holt_winters_with_fit() (explain)
--Testcase 788:
EXPLAIN VERBOSE
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s');

-- select predictors function holt_winters_with_fit() (result)
--Testcase 789:
SELECT holt_winters_with_fit(min(value1), 5, 1) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s');

-- select count(*) function of InfluxDB (stub agg function, explain)
--Testcase 790:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3;

-- select count(*) function of InfluxDB (stub agg function, result)
--Testcase 791:
SELECT influx_count_all(*) FROM s3;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (explain)
--Testcase 792:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select count(*) function of InfluxDB (stub agg function and group by influx_time() and tag) (result)
--Testcase 793:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (explain)
--Testcase 794:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select count(*) function of InfluxDB (stub agg function and group by tag only) (result)
--Testcase 795:
SELECT influx_count_all(*) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select count(*) function of InfluxDB over join query (explain)
--Testcase 796:
EXPLAIN VERBOSE
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select count(*) function of InfluxDB over join query (result, stub call error)
--Testcase 797:
SELECT influx_count_all(*) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select distinct (stub agg function, explain)
--Testcase 798:
EXPLAIN VERBOSE
SELECT influx_distinct(value1) FROM s3;

-- select distinct (stub agg function, result)
--Testcase 799:
SELECT influx_distinct(value1) FROM s3;

-- select distinct (stub agg function and group by influx_time() and tag) (explain)
--Testcase 800:
EXPLAIN VERBOSE
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select distinct (stub agg function and group by influx_time() and tag) (result)
--Testcase 801:
SELECT influx_distinct(value1), influx_time(time, interval '1s'),tag1 FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY influx_time(time, interval '1s'), tag1;

-- select distinct (stub agg function and group by tag only) (explain)
--Testcase 802:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select distinct (stub agg function and group by tag only) (result)
--Testcase 803:
SELECT influx_distinct(value2) FROM s3 WHERE time >= to_timestamp(0) and time <= to_timestamp(4) GROUP BY tag1;

-- select distinct over join query (explain)
--Testcase 804:
EXPLAIN VERBOSE
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select distinct over join query (result, stub call error)
--Testcase 805:
SELECT influx_distinct(t1.value2) FROM s3 t1 INNER JOIN s3 t2 ON (t1.value1 = t2.value1) where t1.value1 = 0.1;

-- select distinct with having (explain)
--Testcase 806:
EXPLAIN VERBOSE
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100;

-- select distinct with having (result, not pushdown, stub call error)
--Testcase 807:
SELECT influx_distinct(value2) FROM s3 HAVING influx_distinct(value2) > 100;

--Testcase 808:
DROP FOREIGN TABLE s3__influxdb_svr__0;
--Testcase 809:
DROP USER MAPPING FOR CURRENT_USER SERVER influxdb_svr;
--Testcase 810:
DROP SERVER influxdb_svr;
--Testcase 811:
DROP EXTENSION influxdb_fdw;
--Testcase 812:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: sqlite

--Testcase 813:
CREATE FOREIGN TABLE s3 (id text, time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 814:
CREATE EXTENSION sqlite_fdw;
--Testcase 815:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/pgtest.db');
--Testcase 816:
CREATE FOREIGN TABLE s3__sqlite_svr__0 (id text OPTIONS (key 'true'), time timestamp, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text) SERVER sqlite_svr OPTIONS(table 's3');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 817:
\d s3;
--Testcase 818:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- select abs (builtin function, explain)
--Testcase 819:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- select abs (buitin function, result)
--Testcase 820:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 821:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 822:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 823:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 824:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 825:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 826:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 827:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 828:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select abs with order by (explain)
--Testcase 829:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 830:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 831:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 832:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 833:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 834:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 835:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 836:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 837:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 838:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 839:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), upper(tag1) FROM s3
) AS t ORDER BY 1,2,3;

-- sqlite pushdown supported functions (explain)
--Testcase 840:
EXPLAIN VERBOSE
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3;

-- sqlite pushdown supported functions (result)
--Testcase 841:
SELECT * FROM (
SELECT abs(value3), length(tag1), ltrim(str2), ltrim(str1, '-'), replace(str1, 'XYZ', 'ABC'), round(value3), rtrim(str1, '-'), rtrim(str2), substr(str1, 4), substr(str1, 4, 3) FROM s3
) AS t ORDER BY 1,2,3,4,5,6,7,8,9,10;

--Testcase 842:
DROP FOREIGN TABLE s3__sqlite_svr__0;
--Testcase 843:
DROP SERVER sqlite_svr;
--Testcase 844:
DROP EXTENSION sqlite_fdw;
--Testcase 845:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: mysql

--Testcase 846:
CREATE FOREIGN TABLE s3 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 847:
CREATE FOREIGN TABLE ftextsearch (id int, content text, __spd_url text) SERVER pgspider_core_svr;
--Testcase 848:
CREATE EXTENSION mysql_fdw;
--Testcase 849:
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw;
--Testcase 850:
CREATE USER MAPPING FOR CURRENT_USER SERVER mysql_svr OPTIONS(username 'root', password 'Mysql_1234');
--Testcase 851:
CREATE FOREIGN TABLE s3__mysql_svr__0 (id int, tag1 text, value1 float, value2 int, value3 float, value4 int, str1 text, str2 text) SERVER mysql_svr OPTIONS(dbname 'test', table_name 's3');

-- s3 (value1 as float8, value2 as bigint)
--Testcase 852:
\d s3;
--Testcase 853:
SELECT * FROM s3 ORDER BY 1,2,3,4,5,6,7,8,9;

-- select float8() (not pushdown, remove float8, explain)
--Testcase 854:
EXPLAIN VERBOSE
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3;

-- select float8() (not pushdown, remove float8, result)
--Testcase 855:
SELECT * FROM (
SELECT float8(value1), float8(value2), float8(value3), float8(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select sqrt (builtin function, explain)
--Testcase 856:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3;

-- select sqrt (buitin function, result)
--Testcase 857:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3
) AS t ORDER BY 1,2;

-- select sqrt (builtin function,, not pushdown constraints, explain)
--Testcase 858:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64';

-- select sqrt (builtin function, not pushdown constraints, result)
--Testcase 859:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2;

-- select sqrt (builtin function, pushdown constraints, explain)
--Testcase 860:
EXPLAIN VERBOSE
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200;

-- select sqrt (builtin function, pushdown constraints, result)
--Testcase 861:
SELECT * FROM (
SELECT sqrt(value1), sqrt(value2) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2;

-- select abs (builtin function, explain)
--Testcase 862:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3;

-- ABS() returns negative values if integer (https://github.com/influxdata/influxdb/issues/10261)
-- select abs (buitin function, result)
--Testcase 863:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, not pushdown constraints, explain)
--Testcase 864:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64';

-- select abs (builtin function, not pushdown constraints, result)
--Testcase 865:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE to_hex(value2) != '64'
) AS t ORDER BY 1,2,3,4;

-- select abs (builtin function, pushdown constraints, explain)
--Testcase 866:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200;

-- select abs (builtin function, pushdown constraints, result)
--Testcase 867:
SELECT * FROM (
SELECT abs(value1), abs(value2), abs(value3), abs(value4) FROM s3 WHERE value2 != 200
) AS t ORDER BY 1,2,3,4;

-- select log (builtin function, need to swap arguments, numeric cast, explain)
-- log_<base>(v) : postgresql (base, v), influxdb (v, base), mysql (base, v)
--Testcase 868:
EXPLAIN VERBOSE
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1;

-- select log (builtin function, need to swap arguments, numeric cast, result)
--Testcase 869:
SELECT * FROM (
SELECT log(value1::numeric, value2::numeric) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, float8, explain)
--Testcase 870:
EXPLAIN VERBOSE
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, float8, result)
--Testcase 871:
SELECT * FROM (
SELECT log(value1, 0.1) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, bigint, explain)
--Testcase 872:
EXPLAIN VERBOSE
SELECT log(value2, 3) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, bigint, result)
--Testcase 873:
SELECT * FROM (
SELECT log(value2, 3) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select log (stub function, need to swap arguments, mix type, explain)
--Testcase 874:
EXPLAIN VERBOSE
SELECT log(value1, value2) FROM s3 WHERE value1 != 1;

-- select log (stub function, need to swap arguments, mix type, result)
--Testcase 875:
SELECT * FROM (
SELECT log(value1, value2) FROM s3 WHERE value1 != 1
) AS t ORDER BY 1;

-- select abs as nest function with agg (pushdown, explain)
--Testcase 876:
EXPLAIN VERBOSE
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs as nest function with agg (pushdown, result)
--Testcase 877:
SELECT sum(value3),abs(sum(value3)) FROM s3;

-- select abs with non pushdown func and explicit constant (explain)
--Testcase 878:
EXPLAIN VERBOSE
SELECT abs(value3), pi(), 4.1 FROM s3;

-- select abs with non pushdown func and explicit constant (result)
--Testcase 879:
SELECT * FROM (
SELECT abs(value3), pi(), 4.1 FROM s3
) AS t ORDER BY 1,2,3;

-- select sqrt as nest function with agg and explicit constant (pushdown, explain)
--Testcase 880:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant (pushdown, result)
--Testcase 881:
SELECT sqrt(count(value1)), pi(), 4.1 FROM s3;

-- select sqrt as nest function with agg and explicit constant and tag (error, explain)
--Testcase 882:
EXPLAIN VERBOSE
SELECT sqrt(count(value1)), pi(), 4.1, tag1 FROM s3;

-- select abs with order by (explain)
--Testcase 883:
EXPLAIN VERBOSE
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by (result)
--Testcase 884:
SELECT value1, abs(1-value1) FROM s3 ORDER BY abs(1-value1);

-- select abs with order by index (result)
--Testcase 885:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 2,1;

-- select abs with order by index (result)
--Testcase 886:
SELECT value1, abs(1-value1) FROM s3 ORDER BY 1,2;

-- select abs and as
--Testcase 887:
SELECT * FROM (
SELECT abs(value3) as abs1 FROM s3
) AS t ORDER BY 1;

-- select abs with arithmetic and tag in the middle (explain)
--Testcase 888:
EXPLAIN VERBOSE
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3;

-- select abs with arithmetic and tag in the middle (result)
--Testcase 889:
SELECT * FROM (
SELECT abs(value1) + 1, value2, tag1, sqrt(value2) FROM s3
) AS t ORDER BY 1,2,3,4;

-- select with order by limit (explain)
--Testcase 890:
EXPLAIN VERBOSE
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select with order by limit (explain)
--Testcase 891:
SELECT abs(value1), abs(value3), sqrt(value2) FROM s3 ORDER BY abs(value3) LIMIT 1;

-- select mixing with non pushdown func (all not pushdown, explain)
--Testcase 892:
EXPLAIN VERBOSE
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3;

-- select mixing with non pushdown func (result)
--Testcase 893:
SELECT * FROM (
SELECT abs(value1), sqrt(value2), chr(id+40) FROM s3
) AS t ORDER BY 1,2,3;

-- full text search table
--Testcase 894:
CREATE FOREIGN TABLE ftextsearch__mysql_svr__0 (id int, content text) SERVER mysql_svr OPTIONS(dbname 'test', table_name 'ftextsearch');

-- text search (pushdown, explain)
--Testcase 895:
EXPLAIN VERBOSE
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0;

-- text search (pushdown, result)
--Testcase 896:
SELECT content FROM (
SELECT MATCH_AGAINST(ARRAY[content, 'success catches']) AS score, content FROM ftextsearch WHERE MATCH_AGAINST(ARRAY[content, 'success catches','IN BOOLEAN MODE']) != 0
       ) AS t ORDER BY 1;

--Testcase 897:
DROP FOREIGN TABLE ftextsearch__mysql_svr__0;
--Testcase 898:
DROP FOREIGN TABLE s3__mysql_svr__0;
--Testcase 899:
DROP USER MAPPING FOR CURRENT_USER SERVER mysql_svr;
--Testcase 900:
DROP SERVER mysql_svr;
--Testcase 901:
DROP EXTENSION mysql_fdw;
--Testcase 902:
DROP FOREIGN TABLE ftextsearch;
--Testcase 903:
DROP FOREIGN TABLE s3;

----------------------------------------------------------
-- Data source: griddb

--Testcase 904:
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

--Testcase 905:
CREATE EXTENSION griddb_fdw;
--Testcase 906:
CREATE SERVER griddb_svr FOREIGN DATA WRAPPER griddb_fdw  OPTIONS (host '239.0.0.1', port '31999', clustername 'griddbfdwTestCluster');
--Testcase 907:
CREATE USER MAPPING FOR public SERVER griddb_svr OPTIONS (username 'admin', password 'testadmin');

--Testcase 908:
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
) SERVER griddb_svr OPTIONS(table_name 's3');
--Test foreign table
--Testcase 909:
\d s3;
--Testcase 910:
SELECT * FROM s3 ORDER BY 1,2;
--
-- Test for non-unique functions of GridDB in WHERE clause
--
-- char_length
--Testcase 911:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) > 4 ;
--Testcase 912:
SELECT * FROM s3 WHERE char_length(name) > 4 ;
--Testcase 913:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE char_length(name) < 6 ;
--Testcase 914:
SELECT * FROM s3 WHERE char_length(name) < 6 ;

--Testcase 915:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george';
--Testcase 916:
SELECT * FROM s3 WHERE concat(name,' and george') = 'fred and george';

--substr
--Testcase 917:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,2,3) = 'red';
--Testcase 918:
SELECT * FROM s3 WHERE substr(name,2,3) = 'red';
--Testcase 919:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre';
--Testcase 920:
SELECT * FROM s3 WHERE substr(name,1,3) <> 'fre';

--upper
--Testcase 921:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) = 'FRED';
--Testcase 922:
SELECT * FROM s3 WHERE upper(name) = 'FRED';
--Testcase 923:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE upper(name) <> 'FRED';
--Testcase 924:
SELECT * FROM s3 WHERE upper(name) <> 'FRED';

--lower
--Testcase 925:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) = 'george';
--Testcase 926:
SELECT * FROM s3 WHERE lower(name) = 'george';
--Testcase 927:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE lower(name) <> 'bob';
--Testcase 928:
SELECT * FROM s3 WHERE lower(name) <> 'bob';

--round
--Testcase 929:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) > 3.5;
--Testcase 930:
SELECT * FROM s3 WHERE round(gpa) > 3.5;
--Testcase 931:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE round(gpa) <= 3;
--Testcase 932:
SELECT * FROM s3 WHERE round(gpa) <= 3;

--floor
--Testcase 933:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) = 3;
--Testcase 934:
SELECT * FROM s3 WHERE floor(gpa) = 3;
--Testcase 935:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE floor(gpa) < 2;
--Testcase 936:
SELECT * FROM s3 WHERE floor(gpa) < 3;

--ceiling
--Testcase 937:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) >= 3;
--Testcase 938:
SELECT * FROM s3 WHERE ceiling(gpa) >= 3;
--Testcase 939:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE ceiling(gpa) = 4;
--Testcase 940:
SELECT * FROM s3 WHERE ceiling(gpa) = 4;

--
--Test for unique functions of GridDB in WHERE clause: time functions
--
--griddb_timestamp: push down timestamp function to GridDB
--Testcase 941:
EXPLAIN VERBOSE
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00';
--Testcase 942:
SELECT date, strcol, booleancol, bytecol, shortcol, intcol, longcol, floatcol, doublecol FROM s3 WHERE griddb_timestamp(strcol) > '2020-01-05 21:00:00';
--Testcase 943:
EXPLAIN VERBOSE
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol);
--Testcase 944:
SELECT date, strcol FROM s3 WHERE date < griddb_timestamp(strcol);
--griddb_timestamp: push down timestamp function to GridDB and gets error because GridDB only support YYYY-MM-DDThh:mm:ss.SSSZ format for timestamp function
--UPDATE time_series2__griddb_svr__0 SET strcol = '2020-01-05 21:00:00';
--EXPLAIN VERBOSE
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';
--SELECT date, strcol FROM time_series2 WHERE griddb_timestamp(strcol) = '2020-01-05 21:00:00';

--timestampadd
--YEAR
--Testcase 945:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00';
--Testcase 946:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, -1) > '2019-12-29 05:00:00';
--Testcase 947:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00';
--Testcase 948:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29 04:50:00';
--Testcase 949:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29';
--Testcase 950:
SELECT date1 FROM s3 WHERE timestampadd('YEAR', date1, 5) >= '2025-12-29';
--MONTH
--Testcase 951:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00';
--Testcase 952:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, -3) > '2020-06-29 05:00:00';
--Testcase 953:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30';
--Testcase 954:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) = '2021-03-29 05:00:30';
--Testcase 955:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29';
--Testcase 956:
SELECT date1 FROM s3 WHERE timestampadd('MONTH', date1, 3) >= '2021-03-29';
--DAY
--Testcase 957:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00';
--Testcase 958:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, -3) > '2020-06-29 05:00:00';
--Testcase 959:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30';
--Testcase 960:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) = '2021-01-01 05:00:30';
--Testcase 961:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01';
--Testcase 962:
SELECT date1 FROM s3 WHERE timestampadd('DAY', date1, 3) >= '2021-01-01';
--HOUR
--Testcase 963:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00';
--Testcase 964:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, -1) > '2020-12-29 04:00:00';
--Testcase 965:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00';
--Testcase 966:
SELECT date1 FROM s3 WHERE timestampadd('HOUR', date1, 2) >= '2020-12-29 06:50:00';
--MINUTE
--Testcase 967:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00';
--Testcase 968:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, 20) = '2020-12-29 05:00:00';
--Testcase 969:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00';
--Testcase 970:
SELECT date1 FROM s3 WHERE timestampadd('MINUTE', date1, -50) <= '2020-12-29 04:00:00';
--SECOND
--Testcase 971:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30';
--Testcase 972:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, 25) >= '2020-12-29 04:40:30';
--Testcase 973:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -50) <= '2020-12-29 04:00:00';
--Testcase 974:
SELECT date1 FROM s3 WHERE timestampadd('SECOND', date1, -30) = '2020-12-29 05:00:00';
--MILLISECOND
--Testcase 975:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420';
--Testcase 976:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, 300) = '2020-12-29 05:10:00.420';
--Testcase 977:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065';
--Testcase 978:
SELECT date1 FROM s3 WHERE timestampadd('MILLISECOND', date1, -55) = '2020-12-29 05:10:00.065';
--Input wrong unit
--Testcase 979:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampadd('MICROSECOND', date1, -55) = '2020-12-29 05:10:00.065';

--timestampdiff
--YEAR
--Testcase 980:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0;
--Testcase 981:
SELECT date1 FROM s3 WHERE timestampdiff('YEAR', date1, '2018-01-04 08:48:00') > 0;
--Testcase 982:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5;
--Testcase 983:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2015-07-15 08:48:00', date2) < 5;
--Testcase 984:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10;
--Testcase 985:
SELECT date1, date2 FROM s3 WHERE timestampdiff('YEAR', date1, date2) > 10;
--MONTH
--Testcase 986:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1;
--Testcase 987:
SELECT date1 FROM s3 WHERE timestampdiff('MONTH', date1, '2020-11-04 08:48:00') = 1;
--Testcase 988:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5;
--Testcase 989:
SELECT date2 FROM s3 WHERE timestampdiff('YEAR', '2020-02-15 08:48:00', date2) < 5;
--Testcase 990:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10;
--Testcase 991:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MONTH', date1, date2) < 10;
--DAY
--Testcase 992:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20;
--Testcase 993:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', date2, '2020-12-04 08:48:00') > 20;
--Testcase 994:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5;
--Testcase 995:
SELECT date2 FROM s3 WHERE timestampdiff('DAY', '2020-02-15 08:48:00', date2) < 5;
--Testcase 996:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10;
--Testcase 997:
SELECT date1, date2 FROM s3 WHERE timestampdiff('DAY', date1, date2) > 10;
--HOUR
--Testcase 998:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0;
--Testcase 999:
SELECT date1 FROM s3 WHERE timestampdiff('HOUR', date1, '2020-12-29 07:40:00') < 0;
--Testcase 1000:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5;
--Testcase 1001:
SELECT date2 FROM s3 WHERE timestampdiff('HOUR', '2020-12-15 08:48:00', date2) > 3.5;
--Testcase 1002:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10;
--Testcase 1003:
SELECT date1, date2 FROM s3 WHERE timestampdiff('HOUR', date1, date2) > 10;
--MINUTE
--Testcase 1004:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20;
--Testcase 1005:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', date2, '2020-12-04 08:48:00') > 20;
--Testcase 1006:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5;
--Testcase 1007:
SELECT date2 FROM s3 WHERE timestampdiff('MINUTE', '2020-02-15 08:48:00', date2) < 5;
--Testcase 1008:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10;
--Testcase 1009:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MINUTE', date1, date2) > 10;
--SECOND
--Testcase 1010:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000;
--Testcase 1011:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', date2, '2020-12-04 08:48:00') > 1000;
--Testcase 1012:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100;
--Testcase 1013:
SELECT date2 FROM s3 WHERE timestampdiff('SECOND', '2020-03-17 04:50:00', date2) < 100;
--Testcase 1014:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000;
--Testcase 1015:
SELECT date1, date2 FROM s3 WHERE timestampdiff('SECOND', date1, date2) > 1600000;
--MILLISECOND
--Testcase 1016:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200;
--Testcase 1017:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', date2, '2020-12-04 08:48:00') > 200;
--Testcase 1018:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0;
--Testcase 1019:
SELECT date2 FROM s3 WHERE timestampdiff('MILLISECOND', '2020-03-17 08:48:00', date2) < 0;
--Testcase 1020:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443;
--Testcase 1021:
SELECT date1, date2 FROM s3 WHERE timestampdiff('MILLISECOND', date1, date2) = -443;
--Input wrong unit
--Testcase 1022:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('MICROSECOND', date2, '2020-12-04 08:48:00') > 20;
--Testcase 1023:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE timestampdiff('DECADE', '2020-02-15 08:48:00', date2) < 5;
--Testcase 1024:
EXPLAIN VERBOSE
SELECT date1, date2 FROM s3 WHERE timestampdiff('NANOSECOND', date1, date2) > 10;

--to_timestamp_ms
--Normal case
--Testcase 1025:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00';
--Testcase 1026:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00';
--Return error if column contains -1 value
--Testcase 1027:
SELECT date1 FROM s3 WHERE to_timestamp_ms(intcol) > '1970-01-01 1:00:00';

--to_epoch_ms
--Testcase 1028:
EXPLAIN VERBOSE
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1);
--Testcase 1029:
SELECT date1 FROM s3 WHERE intcol < to_epoch_ms(date1);
--Testcase 1030:
EXPLAIN VERBOSE
SELECT date2 FROM s3 WHERE to_epoch_ms(date2) < 1000000000000;

--
--Test for unique functions of GridDB in WHERE clause: array functions
--
--array_length
--Testcase 1031:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3;
--Testcase 1032:
SELECT boolarray FROM s3 WHERE array_length(boolarray) = 3;
--Testcase 1033:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3;
--Testcase 1034:
SELECT stringarray FROM s3 WHERE array_length(stringarray) = 3;
--Testcase 1035:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray);
--Testcase 1036:
SELECT bytearray, shortarray FROM s3 WHERE array_length(bytearray) > array_length(shortarray);
--Testcase 1037:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray);
--Testcase 1038:
SELECT integerarray, longarray FROM s3 WHERE array_length(integerarray) = array_length(longarray);
--Testcase 1039:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0;
--Testcase 1040:
SELECT floatarray, doublearray FROM s3 WHERE array_length(floatarray) - array_length(doublearray) = 0;
--Testcase 1041:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3;
--Testcase 1042:
SELECT timestamparray FROM s3 WHERE array_length(timestamparray) < 3;

--element
--Normal case
--Testcase 1043:
EXPLAIN VERBOSE
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f';
--Testcase 1044:
SELECT boolarray FROM s3 WHERE element(1, boolarray) = 'f';
--Testcase 1045:
EXPLAIN VERBOSE
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb';
--Testcase 1046:
SELECT stringarray FROM s3 WHERE element(1, stringarray) != 'bbb';
--Testcase 1047:
EXPLAIN VERBOSE
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray);
--Testcase 1048:
SELECT bytearray, shortarray FROM s3 WHERE element(0, bytearray) = element(0, shortarray);
--Testcase 1049:
EXPLAIN VERBOSE
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray);
--Testcase 1050:
SELECT integerarray, longarray FROM s3 WHERE element(0, integerarray)*100+44 = element(0,longarray);
--Testcase 1051:
EXPLAIN VERBOSE
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray);
--Testcase 1052:
SELECT floatarray, doublearray FROM s3 WHERE element(2, floatarray)*10 < element(0,doublearray);
--Testcase 1053:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00';
--Testcase 1054:
SELECT timestamparray FROM s3 WHERE element(1,timestamparray) > '2020-12-29 04:00:00';
--Return error when getting non-existent element
--Testcase 1055:
EXPLAIN VERBOSE
SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00';
--Testcase 1056:
SELECT timestamparray FROM s3 WHERE element(2,timestamparray) > '2020-12-29 04:00:00';

--
--if user selects non-unique functions which Griddb only supports in WHERE clause => do not push down
--if user selects unique functions which Griddb only supports in WHERE clause => still push down, return error of Griddb
--
--Testcase 1057:
EXPLAIN VERBOSE
SELECT char_length(name) FROM s3;
--Testcase 1058:
SELECT char_length(name) FROM s3;
--Testcase 1059:
EXPLAIN VERBOSE
SELECT concat(name,'abc') FROM s3;
--Testcase 1060:
SELECT concat(name,'abc') FROM s3;
--Testcase 1061:
EXPLAIN VERBOSE
SELECT substr(name,2,3) FROM s3;
--Testcase 1062:
SELECT substr(name,2,3) FROM s3;
--Testcase 1063:
EXPLAIN VERBOSE
SELECT element(1, timestamparray) FROM s3;
--Testcase 1064:
SELECT element(1, timestamparray) FROM s3;
--Testcase 1065:
EXPLAIN VERBOSE
SELECT upper(name) FROM s3;
--Testcase 1066:
SELECT upper(name) FROM s3;
--Testcase 1067:
EXPLAIN VERBOSE
SELECT lower(name) FROM s3;
--Testcase 1068:
SELECT lower(name) FROM s3;
--Testcase 1069:
EXPLAIN VERBOSE
SELECT round(gpa) FROM s3;
--Testcase 1070:
SELECT round(gpa) FROM s3;
--Testcase 1071:
EXPLAIN VERBOSE
SELECT floor(gpa) FROM s3;
--Testcase 1072:
SELECT floor(gpa) FROM s3;
--Testcase 1073:
EXPLAIN VERBOSE
SELECT ceiling(gpa) FROM s3;
--Testcase 1074:
SELECT ceiling(gpa) FROM s3;
--Testcase 1075:
EXPLAIN VERBOSE
SELECT griddb_timestamp(strcol) FROM s3;
--Testcase 1076:
SELECT griddb_timestamp(strcol) FROM s3;
--Testcase 1077:
EXPLAIN VERBOSE
SELECT timestampadd('YEAR', date1, -1) FROM s3;
--Testcase 1078:
SELECT timestampadd('YEAR', date1, -1) FROM s3;
--Testcase 1079:
EXPLAIN VERBOSE
SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3;
--Testcase 1080:
SELECT timestampdiff('YEAR', date1, '2018-01-04 08:48:00') FROM s3;
--Testcase 1081:
EXPLAIN VERBOSE
SELECT to_timestamp_ms(intcol) FROM s3;
--Testcase 1082:
SELECT to_timestamp_ms(intcol) FROM s3;
--Testcase 1083:
EXPLAIN VERBOSE
SELECT to_epoch_ms(date1) FROM s3;
--Testcase 1084:
SELECT to_epoch_ms(date1) FROM s3;
--Testcase 1085:
EXPLAIN VERBOSE
SELECT array_length(boolarray) FROM s3;
--Testcase 1086:
SELECT array_length(boolarray) FROM s3;
--Testcase 1087:
EXPLAIN VERBOSE
SELECT element(1, stringarray) FROM s3;
--Testcase 1088:
SELECT element(1, stringarray) FROM s3;

--
--Test for unique functions of GridDB in SELECT clause: time-series functions
--
--time_next
--specified time exist => return that row
--Testcase 1089:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:00:00') FROM s3;
--Testcase 1090:
SELECT time_next('2018-12-01 10:00:00') FROM s3;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1091:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:05:00') FROM s3;
--Testcase 1092:
SELECT time_next('2018-12-01 10:05:00') FROM s3;
--specified time does not exist, there is no time after the specified time => return no row
--Testcase 1093:
EXPLAIN VERBOSE
SELECT time_next('2018-12-01 10:45:00') FROM s3;
--Testcase 1094:
SELECT time_next('2018-12-01 10:45:00') FROM s3;

--time_next_only
--even though specified time exist, still return the row whose time is immediately after the specified time
--Testcase 1095:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:00:00') FROM s3;
--Testcase 1096:
SELECT time_next_only('2018-12-01 10:00:00') FROM s3;
--specified time does not exist => return the row whose time  is immediately after the specified time
--Testcase 1097:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:05:00') FROM s3;
--Testcase 1098:
SELECT time_next_only('2018-12-01 10:05:00') FROM s3;
--there is no time after the specified time => return no row
--Testcase 1099:
EXPLAIN VERBOSE
SELECT time_next_only('2018-12-01 10:45:00') FROM s3;
--Testcase 1100:
SELECT time_next_only('2018-12-01 10:45:00') FROM s3;

--time_prev
--specified time exist => return that row
--Testcase 1101:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:10:00') FROM s3;
--Testcase 1102:
SELECT time_prev('2018-12-01 10:10:00') FROM s3;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1103:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 10:05:00') FROM s3;
--Testcase 1104:
SELECT time_prev('2018-12-01 10:05:00') FROM s3;
--specified time does not exist, there is no time before the specified time => return no row
--Testcase 1105:
EXPLAIN VERBOSE
SELECT time_prev('2018-12-01 09:45:00') FROM s3;
--Testcase 1106:
SELECT time_prev('2018-12-01 09:45:00') FROM s3;

--time_prev_only
--even though specified time exist, still return the row whose time is immediately before the specified time
--Testcase 1107:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3;
--Testcase 1108:
SELECT time_prev_only('2018-12-01 10:10:00') FROM s3;
--specified time does not exist => return the row whose time  is immediately before the specified time
--Testcase 1109:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3;
--Testcase 1110:
SELECT time_prev_only('2018-12-01 10:05:00') FROM s3;
--there is no time before the specified time => return no row
--Testcase 1111:
EXPLAIN VERBOSE
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3;
--Testcase 1112:
SELECT time_prev_only('2018-12-01 09:45:00') FROM s3;

--time_interpolated
--specified time exist => return that row
--Testcase 1113:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3;
--Testcase 1114:
SELECT time_interpolated(value1, '2018-12-01 10:10:00') FROM s3;
--specified time does not exist => return the row which has interpolated value.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1115:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3;
--Testcase 1116:
SELECT time_interpolated(value1, '2018-12-01 10:05:00') FROM s3;
--specified time does not exist. There is no row before or after the specified time => can not calculate interpolated value, return no row.
--Testcase 1117:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3;
--Testcase 1118:
SELECT time_interpolated(value1, '2018-12-01 09:05:00') FROM s3;
--Testcase 1119:
EXPLAIN VERBOSE
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3;
--Testcase 1120:
SELECT time_interpolated(value1, '2018-12-01 10:45:00') FROM s3;

--time_sampling by MINUTE
--rows for sampling exists => return those rows
--Testcase 1121:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3;
--Testcase 1122:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:20:00', 10, 'MINUTE') FROM s3;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1123:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3;
--Testcase 1124:
SELECT time_sampling(value1, '2018-12-01 10:05:00', '2018-12-01 10:35:00', 10, 'MINUTE') FROM s3;
--mix exist and non-exist sampling
--Testcase 1125:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;
--Testcase 1126:
SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1127:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3;
--Testcase 1128:
SELECT time_sampling(value1, '2018-12-01 09:30:00', '2018-12-01 11:00:00', 10, 'MINUTE') FROM s3;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--UPDATE time_series__griddb_svr__0 SET value1 = 5 where date = '2018-12-01 10:40:00';
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;
--SELECT time_sampling('2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE') FROM s3;

--time_sampling by HOUR
--rows for sampling exists => return those rows
--Testcase 1129:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3;
--Testcase 1130:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 12:00:00', 2, 'HOUR') FROM s3;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1131:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3;
--Testcase 1132:
SELECT time_sampling(value1, '2018-12-02 10:05:00', '2018-12-02 21:00:00', 3, 'HOUR') FROM s3;
--mix exist and non-exist sampling
--Testcase 1133:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;
--Testcase 1134:
SELECT time_sampling(value1, '2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1135:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3;
--Testcase 1136:
SELECT time_sampling(value1, '2018-12-02 6:00:00', '2018-12-02 23:00:00', 3, 'HOUR') FROM s3;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;
--SELECT time_sampling('2018-12-02 10:00:00', '2018-12-02 21:40:00', 2, 'HOUR') FROM s3;

--time_sampling by DAY
--rows for sampling exists => return those rows
--Testcase 1137:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3;
--Testcase 1138:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-04 11:00:00', 1, 'DAY') FROM s3;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1139:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3;
--Testcase 1140:
SELECT time_sampling(value1, '2018-12-03 09:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3;
--mix exist and non-exist sampling
--Testcase 1141:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3;
--Testcase 1142:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-05 12:00:00', 1, 'DAY') FROM s3;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1143:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3;
--Testcase 1144:
SELECT time_sampling(value1, '2018-12-03 09:30:00', '2018-12-03 11:00:00', 1, 'DAY') FROM s3;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 6;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3;
--Testcase 1145:
SELECT time_sampling(value1, '2018-12-03 11:00:00', '2018-12-03 12:00:00', 1, 'DAY') FROM s3;

--time_sampling by SECOND
--rows for sampling exists => return those rows
--Testcase 1146:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3;
--Testcase 1147:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 10:00:20', 10, 'SECOND') FROM s3;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1148:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3;
--Testcase 1149:
SELECT time_sampling(value1, '2018-12-06 10:00:03', '2018-12-06 10:00:35', 15, 'SECOND') FROM s3;
--mix exist and non-exist sampling
--Testcase 1150:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3;
--Testcase 1151:
SELECT time_sampling(value1, '2018-12-06 10:00:00', '2018-12-06 11:00:00', 10, 'SECOND') FROM s3;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1152:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3;
--Testcase 1153:
SELECT time_sampling(value1, '2018-12-06 08:30:00', '2018-12-06 11:00:00', 20, 'SECOND') FROM s3;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;

--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 11:00:00', 10, 'SECOND') FROM time_series;

--time_sampling by MILLISECOND
--rows for sampling exists => return those rows
--Testcase 1154:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3;
--Testcase 1155:
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.140', 20, 'MILLISECOND') FROM s3;
--rows for sampling does not exist => return rows that contains interpolated values.
--The column which is specified as the 1st parameter will be calculated by linearly interpolating the value of the previous and next rows.
--Other values will be equal to the values of rows previous to the specified time.
--Testcase 1156:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3;
--Testcase 1157:
SELECT time_sampling(value1, '2018-12-07 10:00:00.115', '2018-12-07 10:00:00.155', 15, 'MILLISECOND') FROM s3;
--mix exist and non-exist sampling
--Testcase 1158:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3;
--Testcase 1159:
SELECT time_sampling(value1, '2018-12-07 10:00:00.100', '2018-12-07 10:00:00.150', 5, 'MILLISECOND') FROM s3;
--In linearly interpolating the value of the previous and next rows, if one of the values does not exist => the sampling row will not be returned
--Testcase 1160:
EXPLAIN VERBOSE
SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3;
--Testcase 1161:
SELECT time_sampling(value1, '2018-12-07 10:00:00.002', '2018-12-07 10:00:00.500', 20, 'MILLISECOND') FROM s3;
--if the first parameter is not set, * will be added as the first parameter.
--When specified time does not exist, all columns (except timestamp key column) will be equal to the values of rows previous to the specified time.
--DELETE FROM time_series__griddb_svr__0 WHERE value1 = 4;
--EXPLAIN VERBOSE
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;
--SELECT time_sampling(value1, '2018-12-01 10:00:00.100', '2018-12-01 10:00:00.150', 5, 'MILLISECOND') FROM time_series;

--max_rows
--Testcase 1162:
EXPLAIN VERBOSE
SELECT max_rows(value2) FROM s3;
--Testcase 1163:
SELECT max_rows(value2) FROM s3;
--Testcase 1164:
EXPLAIN VERBOSE
SELECT max_rows(date) FROM s3;
--Testcase 1165:
SELECT max_rows(date) FROM s3;

--min_rows
--Testcase 1166:
EXPLAIN VERBOSE
SELECT min_rows(value2) FROM s3;
--Testcase 1167:
SELECT min_rows(value2) FROM s3;
--Testcase 1168:
EXPLAIN VERBOSE
SELECT min_rows(date) FROM s3;
--Testcase 1169:
SELECT min_rows(date) FROM s3;

--
--if WHERE clause contains functions which Griddb only supports in SELECT clause => still push down, return error of Griddb
--
--Testcase 1170:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"';
--Testcase 1171:
SELECT * FROM s3 WHERE time_next('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"';
--Testcase 1172:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00');
--Testcase 1173:
SELECT date FROM s3 WHERE time_next_only('2018-12-01 10:00:00') = time_interpolated(value1, '2018-12-01 10:10:00');
--Testcase 1174:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"';
--Testcase 1175:
SELECT * FROM s3 WHERE time_prev('2018-12-01 10:00:00') = '"2020-01-05 21:00:00,{t,f,t}"';
--Testcase 1176:
EXPLAIN VERBOSE
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE');
--Testcase 1177:
SELECT date FROM s3 WHERE time_prev_only('2018-12-01 10:00:00') = time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:40:00', 10, 'MINUTE');
--Testcase 1178:
EXPLAIN VERBOSE
SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2);
--Testcase 1179:
SELECT * FROM s3 WHERE max_rows(date) = min_rows(value2);

--
-- Test syntax (xxx()::s3).*
--
--Testcase 1180:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3;
--Testcase 1181:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).* FROM s3;
--Testcase 1182:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3;
--Testcase 1183:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).date FROM s3;
--Testcase 1184:
EXPLAIN VERBOSE
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3;
--Testcase 1185:
SELECT (time_sampling(value1, '2018-12-01 10:00:00', '2018-12-01 10:50:00', 20, 'MINUTE')::s3).value1 FROM s3;

--
-- Test aggregate function time_avg
--
--Testcase 1186:
EXPLAIN VERBOSE
SELECT time_avg(value1) FROM s3;
--Testcase 1187:
SELECT time_avg(value1) FROM s3;
--Testcase 1188:
EXPLAIN VERBOSE
SELECT time_avg(value2) FROM s3;
--Testcase 1189:
SELECT time_avg(value2) FROM s3;
-- GridDB does not support select multiple target in a query => do not push down, raise stub function error
--Testcase 1190:
EXPLAIN VERBOSE
SELECT time_avg(value1), time_avg(value2) FROM s3;
--Testcase 1191:
SELECT time_avg(value1), time_avg(value2) FROM s3;
-- Do not push down when expected type is not correct, raise stub function error
--Testcase 1192:
EXPLAIN VERBOSE
SELECT time_avg(date) FROM s3;
--Testcase 1193:
SELECT time_avg(date) FROM s3;
--Testcase 1194:
EXPLAIN VERBOSE
SELECT time_avg(blobcol) FROM s3;
--Testcase 1195:
SELECT time_avg(blobcol) FROM s3;

--
-- Test aggregate function min, max, count, sum, avg, variance, stddev
--
--Testcase 1196:
EXPLAIN VERBOSE
SELECT min(age) FROM s3;
--Testcase 1197:
SELECT min(age) FROM s3;

--Testcase 1198:
EXPLAIN VERBOSE
SELECT max(gpa) FROM s3;
--Testcase 1199:
SELECT max(gpa) FROM s3;

--Testcase 1200:
EXPLAIN VERBOSE
SELECT count(*) FROM s3;
--Testcase 1201:
SELECT count(*) FROM s3;
--Testcase 1202:
EXPLAIN VERBOSE
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42;
--Testcase 1203:
SELECT count(*) FROM s3 WHERE gpa < 3.5 OR age < 42;

--Testcase 1204:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3;
--Testcase 1205:
SELECT sum(age) FROM s3;
--Testcase 1206:
EXPLAIN VERBOSE
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5;
--Testcase 1207:
SELECT sum(age) FROM s3 WHERE round(gpa) > 3.5;

--Testcase 1208:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3;
--Testcase 1209:
SELECT avg(gpa) FROM s3;
--Testcase 1210:
EXPLAIN VERBOSE
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george';
--Testcase 1211:
SELECT avg(gpa) FROM s3 WHERE lower(name) = 'george';

--Testcase 1212:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3;
--Testcase 1213:
SELECT variance(gpa) FROM s3;
--Testcase 1214:
EXPLAIN VERBOSE
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5;
--Testcase 1215:
SELECT variance(gpa) FROM s3 WHERE gpa > 3.5;

--Testcase 1216:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3;
--Testcase 1217:
SELECT stddev(age) FROM s3;
--Testcase 1218:
EXPLAIN VERBOSE
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4;
--Testcase 1219:
SELECT stddev(age) FROM s3 WHERE char_length(name) > 4;

--Testcase 1220:
EXPLAIN VERBOSE
SELECT max(gpa), min(age) FROM s3;
--Testcase 1221:
SELECT max(gpa), min(age) FROM s3;

--Drop all foreign tables
--Testcase 1222:
DROP FOREIGN TABLE s3;
--Testcase 1223:
DROP FOREIGN TABLE s3__griddb_svr__0;

--Testcase 1224:
DROP USER MAPPING FOR public SERVER griddb_svr;
--Testcase 1225:
DROP SERVER griddb_svr;
--Testcase 1226:
DROP EXTENSION griddb_fdw;
--Testcase 1227:
DROP USER MAPPING FOR CURRENT_USER SERVER pgspider_core_svr;
--Testcase 1228:
DROP SERVER pgspider_core_svr;
--Testcase 1229:
DROP EXTENSION pgspider_core_fdw;
