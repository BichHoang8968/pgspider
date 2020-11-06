------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature2_UNION_Multi_Tbl-----------------------------
-- Testcase 1:
SELECT c1, c9 FROM t1 UNION SELECT c1, c14 FROM t3 ORDER BY 1,2;
-- Testcase 2:
SELECT max(c1), min(c3), count(*) FROM t1 UNION SELECT max(c1), min(c6), count(c7) FROM t3 ORDER BY 1,2,3;
-- Testcase 3:
SELECT sum(c1), avg(c1), stddev(c6),bool_or(c5),bool_and(c5) FROM t1 UNION SELECT sum(c2), avg(c3), stddev(c4),bool_or(c4<c5),bool_and(c1>c5) FROM t3 ORDER BY 1,2,3,5,4;
-- Testcase 4:
SELECT c1, array_agg(c1 order by c1), string_agg(c2, ';' order by c2), every(c1!=8989) FROM t1 GROUP BY c1 UNION SELECT c1, array_agg(c1 order by c1), string_agg(c17, ';' order by c17), every(c4<c5) FROM t3 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 5:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c3) + 100 FROM t1 UNION SELECT stddev(c1 + 3) + 100, stddev(c2/5)/5+10, avg(c3) + 100 FROM t3 ORDER BY 1,2,3;
-- Testcase 6:
SELECT a.c1+b.c1 FROM t1 a, t3 b WHERE a.c1>0 AND b.c1<0 UNION SELECT t3.c1/2 + t1.c1*5 + 10 FROM t1, t3 WHERE t3.c1 != t1.c1 AND t1.c1>t3.c1 ORDER BY 1;
-- Testcase 7:
SELECT c1, c2 FROM (SELECT count(c1) c1, max(c4) c2 FROM t1 GROUP BY c3) AS t1 UNION SELECT c1, c2 FROM (SELECT c2 c1, c3 c2 FROM t3 WHERE c7 < c8) AS t2 ORDER BY 1,2;
-- Testcase 8:
SELECT c1, c9 FROM t1 UNION ALL SELECT c1, c14 FROM t3 ORDER BY 1,2;
-- Testcase 9:
SELECT max(c1), min(c3), count(*) FROM t1 UNION ALL SELECT max(c1), min(c6), count(c7) FROM t3 ORDER BY 1,2,3;
-- Testcase 10:
SELECT sum(c1), avg(c1), stddev(c6),bool_or(c5),bool_and(c5) FROM t1 UNION ALL SELECT sum(c2), avg(c3), stddev(c4),bool_or(c4<c5),bool_and(c1>c5) FROM t3 ORDER BY 1,2,3;
-- Testcase 11:
SELECT c1, array_agg(c1 order by c1), string_agg(c2, ';' order by c2), every(c1!=8989) FROM t1 GROUP BY c1 UNION ALL SELECT c1, array_agg(c1 order by c1), string_agg(c17, ';' order by c17), every(c4<c5) FROM t3 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 12:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c3) + 100 FROM t1 UNION ALL SELECT stddev(c1 + 3) + 100, stddev(c2/5)/5+10, avg(c3) + 100 FROM t3 ORDER BY 1,2,3;
-- Testcase 13:
SELECT a.c1+b.c1 FROM t1 a, t3 b WHERE a.c1>0 AND b.c1<0 UNION ALL SELECT t3.c1/2 + t1.c1*5 + 10 FROM t1, t3 WHERE t3.c1 != t1.c1 AND t1.c1>t3.c1 ORDER BY 1;
-- Testcase 14:
SELECT c1, c2 FROM (SELECT count(c1) c1, max(c4) c2 FROM t1 GROUP BY c3) AS t1 UNION ALL SELECT c1, c2 FROM (SELECT c2 c1, c3 c2 FROM t3 WHERE c7 < c8) AS t2 ORDER BY 1,2;
-- Testcase 15:
SELECT c1, c11 FROM t5 UNION SELECT c3, c2 FROM t7 ORDER BY 1,2;
-- Testcase 16:
SELECT max(c1), min(c1), count(*) FROM t5 UNION SELECT max(c3), min(c3), count(c2) FROM t7 ORDER BY 1,2,3;
-- Testcase 17:
SELECT sum(c1), avg(c1), stddev(c17),bool_or(c6>c7),bool_and(c5>c6) FROM t5 UNION SELECT sum(c3), avg(c4), stddev(c3),bool_or(c5),bool_and(c5) FROM t7 ORDER BY 1,2,3;
-- Testcase 18:
SELECT c1, array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c7!=8989) FROM t5 GROUP BY c1 UNION SELECT c3, array_agg(c3 order by c3), string_agg(c2, ';' order by c2), every(c5=true) FROM t7 GROUP BY c3 ORDER BY 1,2,3,4;
-- Testcase 19:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c1) + 100 FROM t5 UNION SELECT stddev(c3 + 3) + 100, stddev(c3/5)/5+10, avg(c4) + 100 FROM t7 ORDER BY 1,2,3;
-- Testcase 20:
SELECT a.c1 +b.c3 FROM t5 a, t7 b WHERE a.c1>0 AND b.c3<0 UNION SELECT t7.c3/2 + t5.c1*5 + 10 FROM t5, t7 WHERE t7.c3 != t5.c1 AND t5.c1>t7.c3 ORDER BY 1;
-- Testcase 21:
SELECT c1, c2 FROM (SELECT c3 c1, max(c17) c2 FROM t5 GROUP BY c3) AS t1 UNION SELECT c1, c2 FROM (SELECT c3 c1, c4 c2 FROM t7 WHERE c3 < c4) AS t2 ORDER BY 1,2;
-- Testcase 22:
SELECT c1, c11 FROM t5 UNION ALL SELECT c3, c2 FROM t7 ORDER BY 1,2;
-- Testcase 23:
SELECT max(c1), min(c1), count(*) FROM t5 UNION ALL SELECT max(c3), min(c3), count(c2) FROM t7 ORDER BY 1,2,3;
-- Testcase 24:
SELECT sum(c1), avg(c1), stddev(c17),bool_or(c6>c7),bool_and(c5>c6) FROM t5 UNION ALL SELECT sum(c3), avg(c4), stddev(c3),bool_or(c5),bool_and(c5) FROM t7 ORDER BY 1,2,3;
-- Testcase 25:
SELECT c1, array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c7!=8989) FROM t5 GROUP BY c1 UNION ALL SELECT c3, array_agg(c3 order by c3), string_agg(c2, ';' order by c2), every(c5=true) FROM t7 GROUP BY c3 ORDER BY 1,2,3,4;
-- Testcase 26:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c1) + 100 FROM t5 UNION ALL SELECT stddev(c3 + 3) + 100, stddev(c3/5)/5+10, avg(c4) + 100 FROM t7 ORDER BY 1,2,3;
-- Testcase 27:
SELECT a.c1 +b.c3 FROM t5 a, t7 b WHERE a.c1>0 AND b.c3<0 UNION ALL SELECT t7.c3/2 + t5.c1*5 + 10 FROM t5, t7 WHERE t7.c3 != t5.c1 AND t5.c1>t7.c3 ORDER BY 1;
-- Testcase 28:
SELECT c1, c2 FROM (SELECT c3 c1, max(c17) c2 FROM t5 GROUP BY c3) AS t1 UNION ALL SELECT c1, c2 FROM (SELECT c3 c1, c4 c2 FROM t7 WHERE c3 < c4) AS t2 ORDER BY 1,2;
-- Testcase 29:
SELECT c1, c8 FROM t9 UNION SELECT c1, c7 FROM tmp_t11 ORDER BY 1,2;
-- Testcase 30:
SELECT max(c1), min(c2), count(*) FROM t9 UNION SELECT max(c1), min(c14), count(c7) FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 31:
SELECT sum(c1), avg(c1), stddev(c13),bool_or(c2>102),bool_and(c5) FROM t9 UNION SELECT sum(c1), avg(c12), stddev(c28),bool_or(c4),bool_and(c4) FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 32:
SELECT c1, array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c2!=8989) FROM t9 GROUP BY c1 UNION SELECT c1, array_agg(c1 order by c1), string_agg(c7, ';' order by c7), every(c4=true) FROM tmp_t11 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 33:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c15) + 100 FROM t9 UNION SELECT stddev(c1 + 3) + 100, stddev(c12/5)/5+10, avg(c22) + 100 FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 34:
SELECT a.c1+b.c1 FROM t9 a, tmp_t11 b WHERE a.c1>0 AND b.c1<0 UNION SELECT tmp_t11.c1/2 + t9.c1*5 + 10 FROM t9, tmp_t11 WHERE tmp_t11.c1 != t9.c1 AND t9.c1>tmp_t11.c1 ORDER BY 1;
-- Testcase 35:
SELECT c1, c2 FROM (SELECT c29 c1, max(c15) c2 FROM t9 GROUP BY c29) AS t1 UNION SELECT c1, c2 FROM (SELECT c14 c1, c12 c2 FROM tmp_t11 WHERE c7 < c8) AS t2 ORDER BY 1,2;
-- Testcase 36:
SELECT c1, c8 FROM t9 UNION ALL SELECT c1, c7 FROM tmp_t11 ORDER BY 1,2;
-- Testcase 37:
SELECT max(c1), min(c2), count(*) FROM t9 UNION ALL SELECT max(c1), min(c14), count(c7) FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 38:
SELECT sum(c1), avg(c1), stddev(c13),bool_or(c2>102),bool_and(c5) FROM t9 UNION ALL SELECT sum(c1), avg(c12), stddev(c28),bool_or(c4),bool_and(c4) FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 39:
SELECT c1, array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c2!=8989) FROM t9 GROUP BY c1 UNION ALL SELECT c1, array_agg(c1 order by c1), string_agg(c7, ';' order by c7), every(c4=true) FROM tmp_t11 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 40:
SELECT stddev(c1 + 3) + 100, stddev(c1/5)/5+10, avg(c15) + 100 FROM t9 UNION ALL SELECT stddev(c1 + 3) + 100, stddev(c12/5)/5+10, avg(c22) + 100 FROM tmp_t11 ORDER BY 1,2,3;
-- Testcase 41:
SELECT a.c1+b.c1 FROM t9 a, tmp_t11 b WHERE a.c1>0 AND b.c1<0 UNION ALL SELECT tmp_t11.c1/2 + t9.c1*5 + 10 FROM t9, tmp_t11 WHERE tmp_t11.c1 != t9.c1 AND t9.c1>tmp_t11.c1 ORDER BY 1;
-- Testcase 42:
SELECT c1, c2 FROM (SELECT c29 c1, max(c15) c2 FROM t9 GROUP BY c29) AS t1 UNION ALL SELECT c1, c2 FROM (SELECT c14 c1, c12 c2 FROM tmp_t11 WHERE c7 < c8) AS t2 ORDER BY 1,2;
-- Testcase 43:
SELECT c2,c3,c4 FROM t7 UNION SELECT c9,c4,c18 FROM t13 ORDER BY 1,2,3;
-- Testcase 44:
SELECT max(c3), min(c4), count(*) FROM t7 UNION SELECT max(c1), min(c17), count(c7) FROM t13 ORDER BY 1,2,3;
-- Testcase 45:
SELECT sum(c3), avg(c4), stddev(c3),bool_or(c2 LIKE '%a%'),bool_and(c5) FROM t7 UNION SELECT sum(c1), avg(c2), stddev(c3),bool_or(c2>c3),bool_and(c2<c3) FROM t13 ORDER BY 1,2,3,4,5;
-- Testcase 46:
SELECT c5, array_agg(c3 order by c3), string_agg(c2, ';' order by c2), every(c4>c3*10) FROM t7 GROUP BY c5 UNION SELECT c1>max(c2), array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c4<c3) FROM t13 WHERE c5>0 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 47:
SELECT stddev(c3 + 3) + 100, stddev(c4/5)/5+10, avg(c4) + 100 FROM t7 UNION SELECT stddev(c1 + 3) + 100, stddev(c2/5)/5+10, avg(c3+c4) + 100 FROM t13 ORDER BY 1,2,3;
-- Testcase 48:
SELECT a.c3+b.c1 FROM t7 a, t13 b WHERE a.c3>0 AND b.c1<0 UNION SELECT t13.c1/2 + t7.c3*5 + 10 FROM t7, t13 WHERE t13.c1 != t7.c3 AND t7.c3>t13.c1 ORDER BY 1;
-- Testcase 49:
SELECT c1, c2 FROM (SELECT c3+c4 c1, max(c4) c2 FROM t7 GROUP BY c1) AS t1 UNION SELECT c1, c2 FROM (SELECT c2+c3 c1, c18 c2 FROM t13 WHERE c7 < c3) AS t2 ORDER BY 1,2;
-- Testcase 50:
SELECT c2,c3,c4 FROM t7 UNION ALL SELECT c9,c4,c18 FROM t13 ORDER BY 1,2,3;
-- Testcase 51:
SELECT max(c3), min(c4), count(*) FROM t7 UNION ALL SELECT max(c1), min(c17), count(c7) FROM t13 ORDER BY 1,2,3;
-- Testcase 52:
SELECT sum(c3), avg(c4), stddev(c3),bool_or(c2 LIKE '%a%'),bool_and(c5) FROM t7 UNION ALL SELECT sum(c1), avg(c2), stddev(c3),bool_or(c2>c3),bool_and(c2<c3) FROM t13 ORDER BY 1,2,3,4,5;
-- Testcase 53:
SELECT c5, array_agg(c3 order by c3), string_agg(c2, ';' order by c2), every(c4>c3*10) FROM t7 GROUP BY c5 UNION ALL SELECT c1>max(c2), array_agg(c1 order by c1), string_agg(c8, ';' order by c8), every(c4<c3) FROM t13 WHERE c5>0 GROUP BY c1 ORDER BY 1,2,3,4;
-- Testcase 54:
SELECT stddev(c3 + 3 ORDER BY c3+3) + 100, stddev(c4/5 ORDER BY c4/5)/5+10, avg(c4 ORDER BY c4) + 100 FROM t7 UNION ALL SELECT stddev(c1 + 3) + 100, stddev(c2/5)/5+10, avg(c3+c4) + 100 FROM t13 ORDER BY 1,2,3;
-- Testcase 55:
SELECT a.c3+b.c1 FROM t7 a, t13 b WHERE a.c3>0 AND b.c1<0 UNION ALL SELECT t13.c1/2 + t7.c3*5 + 10 FROM t7, t13 WHERE t13.c1 != t7.c3 AND t7.c3>t13.c1 ORDER BY 1;
-- Testcase 56:
SELECT c1, c2 FROM (SELECT c3+c4 c1, max(c4) c2 FROM t7 GROUP BY c1) AS t1 UNION ALL SELECT c1, c2 FROM (SELECT c2+c3 c1, c18 c2 FROM t13 WHERE c7 < c3) AS t2 ORDER BY 1,2;
-- Testcase 57:
SELECT c1,c2 FROM t1 UNION SELECT c2,c17 FROM t3 UNION SELECT c3, c8 FROM t5 UNION SELECT c3,c2 FROM t7 UNION SELECT c1, c8 FROM t9 UNION SELECT c1, c7 FROM tmp_t11 UNION SELECT c3, c8 FROM t13 ORDER BY 1,2;
-- Testcase 58:
SELECT max(c1), min(c1), count(c3) FROM t1 UNION SELECT max(c1), min(c1), count(c7) FROM t3 UNION SELECT max(c1), min(c2), count(*) FROM t5 UNION SELECT max(c3),min(c3), count(c2) FROM t7 UNION SELECT max(c1), min(c1), count(c8) FROM t9 UNION SELECT max(c1), min(c1), count(c7) FROM tmp_t11 UNION SELECT max(c3), min(c1), count(c8) FROM t13 ORDER BY 1,2,3;
-- Testcase 59:
SELECT sum(c1), avg(c1), stddev(c1) FROM t1 UNION SELECT sum(c1), avg(c1), stddev(c1) FROM t3 UNION SELECT sum(c1), avg(c1), stddev(c1) FROM t5 UNION SELECT sum(c3),avg(c3), stddev(c3) FROM t7 UNION SELECT sum(c1), avg(c1), stddev(c1) FROM t9 UNION SELECT sum(c1), avg(c1), stddev(c1) FROM tmp_t11 UNION SELECT sum(c1), avg(c1), stddev(c1) FROM t13 ORDER BY 1,3,2;
-- Testcase 60:
SELECT max(c1), min(c1), count(c3) FROM t1 GROUP BY c1 UNION SELECT max(c1), min(c1), count(c7) FROM t3 GROUP BY c1 UNION SELECT max(c1), min(c2), count(*) FROM t5 GROUP BY c1 UNION SELECT max(c3),min(c3), count(c2) FROM t7 GROUP BY c2 UNION SELECT max(c1), min(c1), count(c8) FROM t9 GROUP BY c1 UNION SELECT max(c1), min(c1), count(c7) FROM tmp_t11 GROUP BY c1 UNION SELECT max(c3), min(c1), count(c8) FROM t13 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 61:
SELECT c1,c2 FROM (SELECT * FROM t1 WHERE true) as t1 UNION SELECT c2,c17 FROM (SELECT * FROM t3 WHERE c1>0) AS t3 UNION SELECT c3, c8 FROM (SELECT * FROM t5 WHERE t5.c1!=0) AS t5 UNION SELECT c3,c2 FROM (SELECT * FROM t7 WHERE c3=c4) AS t7 UNION SELECT c1, c8 FROM (SELECT c1, c8 FROM t9) AS t9 UNION SELECT c1, c7 FROM (SELECT * FROM tmp_t11) AS tmp_t11 UNION SELECT c3, c8 FROM (SELECT * FROM t13) AS t13 ORDER BY 1,2;
-- Testcase 62:
SELECT c1,c2 FROM t1 UNION ALL SELECT c2,c17 FROM t3 UNION ALL SELECT c3, c8 FROM t5 UNION ALL SELECT c3,c2 FROM t7 UNION ALL SELECT c1, c8 FROM t9 UNION ALL SELECT c1, c7 FROM tmp_t11 UNION ALL SELECT c3, c8 FROM t13 ORDER BY 1,2;
-- Testcase 63:
SELECT max(c1), min(c1), count(c3) FROM t1 UNION ALL SELECT max(c1), min(c1), count(c7) FROM t3 UNION ALL SELECT max(c1), min(c2), count(*) FROM t5 UNION ALL SELECT max(c3),min(c3), count(c2) FROM t7 UNION ALL SELECT max(c1), min(c1), count(c8) FROM t9 UNION ALL SELECT max(c1), min(c1), count(c7) FROM tmp_t11 UNION ALL SELECT max(c3), min(c1), count(c8) FROM t13 ORDER BY 1,2,3;
-- Testcase 64:
SELECT sum(c1), avg(c1), stddev(c1) FROM t1 UNION ALL SELECT sum(c1), avg(c1), stddev(c1) FROM t3 UNION ALL SELECT sum(c1), avg(c1), stddev(c1) FROM t5 UNION ALL SELECT sum(c3),avg(c3), stddev(c3) FROM t7 UNION ALL SELECT sum(c1), avg(c1), stddev(c1) FROM t9 UNION ALL SELECT sum(c1), avg(c1), stddev(c1) FROM tmp_t11 UNION ALL SELECT sum(c1), avg(c1), stddev(c1) FROM t13 ORDER BY 1,2,3;
-- Testcase 65:
SELECT max(c1), min(c1), count(c3) FROM t1 GROUP BY c1 UNION ALL SELECT max(c1), min(c1), count(c7) FROM t3 GROUP BY c1 UNION ALL SELECT max(c1), min(c2), count(*) FROM t5 GROUP BY c1 UNION ALL SELECT max(c3),min(c3), count(c2) FROM t7 GROUP BY c2 UNION ALL SELECT max(c1), min(c1), count(c8) FROM t9 GROUP BY c1 UNION ALL SELECT max(c1), min(c1), count(c7) FROM tmp_t11 GROUP BY c1 UNION ALL SELECT max(c3), min(c1), count(c8) FROM t13 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 66:
SELECT c1,c2 FROM (SELECT * FROM t1 WHERE true) as t1 UNION ALL SELECT c2,c17 FROM (SELECT * FROM t3 WHERE c1>0) AS t3 UNION ALL SELECT c3, c8 FROM (SELECT * FROM t5 WHERE t5.c1!=0) AS t5 UNION ALL SELECT c3,c2 FROM (SELECT * FROM t7 WHERE c3=c4) AS t7 UNION ALL SELECT c1, c8 FROM (SELECT c1, c8 FROM t9) AS t9 UNION ALL SELECT c1, c7 FROM (SELECT * FROM tmp_t11) AS tmp_t11 UNION ALL SELECT c3, c8 FROM (SELECT * FROM t13) AS t13 ORDER BY 1,2;
