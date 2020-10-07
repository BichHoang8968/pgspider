------------------------------BasicFeature_Additional_Test-----------------------------
SET timezone TO 0;
-- Testcase 1:
explain (verbose, costs off) SELECT count(c1), count(c2), count(c3), count(c4) FROM tb_influx GROUP BY c1,c2 ORDER BY 1,2,3,4;
-- Testcase 2:
SELECT count(c1), count(c2), count(c3), count(c4) FROM tb_influx GROUP BY c1,c2 ORDER BY 1,2,3,4;
-- Testcase 3:
explain (verbose, costs off) SELECT max(c4), min(c5), avg(c4), count(c5), sum(c5 ORDER BY c5), sum(c4) FROM tb_influx GROUP BY c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 4:
SELECT max(c4), min(c5), avg(c4), count(c5), sum(c5 ORDER BY c5), sum(c4) FROM tb_influx GROUP BY c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 5:
SELECT min(c4), max(c5), avg(c4), count(c5), count(c2), count(c1) FROM tb_influx WHERE c4>0 AND c6=true OR c5>500 GROUP BY c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 6:
explain (verbose, costs off) SELECT count(distinct c4) FROM tb_influx GROUP BY c1 ORDER BY 1;
-- Testcase 7:
SELECT count(distinct c4) FROM tb_influx GROUP BY c1 ORDER BY 1;
-- Testcase 8:
explain (verbose, costs off) SELECT count(c2), bit_and(c4), bit_or(c4), bool_and(c6) FROM tb_influx GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 9:
SELECT count(c2), bit_and(c4), bit_or(c4), bool_and(c6) FROM tb_influx GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 10:
explain (verbose, costs off) SELECT count(c5) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-20 00:00:00' GROUP BY influx_time(time, interval '1d5h30m') ORDER BY 1;
-- Testcase 11:
SELECT count(c5) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-20 00:00:00' GROUP BY influx_time(time, interval '1d5h30m') ORDER BY 1;
-- Testcase 12:
explain (verbose, costs off) SELECT max(c4), min(c5), avg(c4), count(c1), sum(c5 ORDER BY c5), sum(c4) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '1d5h30m') ORDER BY 1,2,3,4,5,6;
-- Testcase 13:
SELECT max(c4), min(c5), avg(c4), count(c1), sum(c5 ORDER BY c5), sum(c4) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '1d5h30m') ORDER BY 1,2,3,4,5,6;
-- Testcase 14:
explain (verbose, costs off) SELECT avg(c5), max(c4), sum(c5 ORDER BY c5) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '2d'), c1 ORDER BY 1,2,3;
-- Testcase 15:
SELECT avg(c5), max(c4), sum(c5 ORDER BY c5) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '2d'), c1 ORDER BY 1,2,3;
-- Testcase 16:
SELECT count(c1), bit_and(c4) FROM tb_influx GROUP BY influx_time(time, interval '2d') ORDER BY 1;
-- Testcase 17:
explain (verbose, costs off) SELECT max(c4), min(c5), avg(c4), sum(c5 ORDER BY c5), count(c4) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '1d', interval '10h30m') ORDER BY 1,2,3,4,5;
-- Testcase 18:
SELECT max(c4), min(c5), avg(c4), sum(c5 ORDER BY c5), count(c4) FROM tb_influx WHERE time > '2020-01-10 00:00:00' AND time < '2020-01-15 00:00:00' GROUP BY influx_time(time, interval '1d', interval '10h30m') ORDER BY 1,2,3,4,5;
-- Testcase 19:
explain (verbose, costs off) SELECT count(c4) FROM tb_influx GROUP BY time ORDER BY 1;
-- Testcase 20:
SELECT count(c4) FROM tb_influx GROUP BY time ORDER BY 1;
-- Testcase 21:
explain (verbose, costs off) SELECT count(c3) FROM tb_influx GROUP BY c4 ORDER BY 1;
-- Testcase 22:
SELECT count(c3) FROM tb_influx GROUP BY c4 ORDER BY 1;
-- Testcase 23:
explain (verbose, costs off) SELECT min(time), max(time), count(time) FROM tb_influx ORDER BY 1,2,3;
-- Testcase 24:
SELECT min(time), max(time), count(time) FROM tb_influx ORDER BY 1,2,3;
-- Testcase 25:
explain (verbose, costs off) SELECT min(time), max(time), count(time) FROM tb_influx GROUP BY c2 ORDER BY 1,2,3;
-- Testcase 26:
SELECT min(time), max(time), count(time) FROM tb_influx GROUP BY c2 ORDER BY 1,2,3;
-- Testcase 27:
SELECT min(time), max(time), count(time) FROM tb_influx GROUP BY c2 HAVING (c2!='HELLO' OR c2!='Canada' AND count(c2)>1) ORDER BY 1,2,3;
-- Testcase 28:
SELECT min(time), max(time), count(time) FROM tb_influx GROUP BY c4 ORDER BY 1,2,3;
-- Testcase 29:
explain (verbose, costs off) SELECT count(c3), avg(c4), sum(c5 ORDER BY c5) FROM tb_influx GROUP BY c2 HAVING(avg(c4)<1000 AND sum(c5 ORDER BY c5)<1000) ORDER BY 1,2,3;
-- Testcase 30:
SELECT count(c3), avg(c4), sum(c5 ORDER BY c5) FROM tb_influx GROUP BY c2 HAVING(avg(c4)<1000 AND sum(c5 ORDER BY c5)<1000) ORDER BY 1,2,3;
-- Testcase 31:
explain (verbose, costs off) SELECT count(c4), sum(c5 ORDER BY c5), min(c4) FROM tb_influx GROUP BY c2 HAVING(c2!='Keywords' AND c2!='HELLO') ORDER BY 1,2,3;
-- Testcase 32:
SELECT count(c4), sum(c5 ORDER BY c5), min(c4) FROM tb_influx GROUP BY c2 HAVING(c2!='Keywords' AND c2!='HELLO') ORDER BY 1,2,3;
-- Testcase 33:
explain (verbose, costs off) SELECT count(c3), max(c4), sum(c4) FROM tb_influx GROUP BY c1,c2 HAVING(max(c1)!='HELLO' and count(c2)>1) ORDER BY 1,2,3;
-- Testcase 34:
SELECT count(c3), max(c4), sum(c4) FROM tb_influx GROUP BY c1,c2 HAVING(max(c1)!='HELLO' and count(c2)>1) ORDER BY 1,2,3;
-- Testcase 35:
explain (verbose, costs off) SELECT count(c3), max(c4), sum(c4) FROM tb_influx GROUP BY c1,c2 HAVING(max(c1)<min(c2)) ORDER BY 1,2,3;
-- Testcase 36:
SELECT count(c3), max(c4), sum(c4) FROM tb_influx GROUP BY c1,c2 HAVING(max(c1)<min(c2)) ORDER BY 1,2,3;
