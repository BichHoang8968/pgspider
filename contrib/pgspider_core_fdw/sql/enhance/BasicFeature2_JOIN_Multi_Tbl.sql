------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature2_JOIN_Multi_Tbl-----------------------------
-- Testcase 1:
SELECT * FROM t3 JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 IN (1,2)) ORDER BY t3.*, t1.* LIMIT 20;
-- Testcase 2:
SELECT t3.c1, t1.c2, t3.c10, t1.c10, t3.c17, t1.c11 FROM t3 JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 < 100) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 3:
SELECT max(t3.c1+t1.c1), min(t1.c4), sum(t1.c3), avg(t3.c2+t3.c3+t1.c1), count(t3.c9), stddev(t1.c3), array_agg(t3.c7 order by t3.c7), bit_and(t1.c1), bit_or(t3.c1), bool_and(t3.c2<t1.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t1.c4), sqrt(abs(t3.c1)), upper('abcd') FROM t3 JOIN t1 on t3.c1=t1.c1 GROUP BY t3.c1, t1.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 4:
SELECT DISTINCT t3.c1 + t1.c3 a1, t3.c10, t1. c10 FROM t3 JOIN t1 ON t3.c1 < t1.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t1.c4!=1 AND t1.c3>=-10000 AND t1.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 5:
SELECT * FROM t3 JOIN t1 ON t3.c1=5/t1.c3 ORDER BY t1.c3 LIMIT 20;
-- Testcase 6:
SELECT t1.c8, t3.c1, t3.c5, t1.c2 FROM t3 JOIN t1 ON t3.c1 BETWEEN -3 AND 3 AND t1.c1 = ANY(ARRAY[0,30,50]) AND t1.c2 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 7:
SELECT t3.c4, max(t3.c1+t1.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 JOIN t1 ON ((t3.c5<0)=t1.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 8:
SELECT count(distinct t3.c1), max(t3.c2+t1.c3), stddev(t1.c3+t3.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 JOIN t1 ON (t3.c1=(t1.c3/10)) GROUP BY t3.c1,t1.c3 HAVING t3.c1<sum(t1.c3) ORDER BY 1,2,3,4,5;
-- Testcase 9:
SELECT t3.c10, t1.c10, t1.c7, t1.c8, t1.c3+t3.c1 FROM t3 JOIN t1 ON (t3.c5%2=0) = (t1.c2 LIKE '%a%') ORDER BY t3.c10 DESC, t1.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 10:
SELECT * FROM t3 LEFT JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 IN (1,2)) ORDER BY t3.*, t1.* LIMIT 20;
-- Testcase 11:
SELECT t3.c1, t1.c2, t3.c10, t1.c10, t3.c17, t1.c11 FROM t3 LEFT JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 < 100) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 12:
SELECT max(t3.c1+t1.c1), min(t1.c4), sum(t1.c3), avg(t3.c2+t3.c3+t1.c1), count(t3.c9), stddev(t1.c3), array_agg(t3.c7 order by t3.c7), bit_and(t1.c1), bit_or(t3.c1), bool_and(t3.c2<t1.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t1.c4), sqrt(abs(t3.c1)), upper('abcd') FROM t3 LEFT JOIN t1 on t3.c1=t1.c1 GROUP BY t3.c1, t1.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 13:
SELECT DISTINCT t3.c1 + t1.c3 a1, t3.c10, t1. c10 FROM t3 LEFT JOIN t1 ON t3.c1 < t1.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t1.c4!=1 AND t1.c3>=-10000 AND t1.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 14:
SELECT * FROM t3 LEFT JOIN t1 ON t3.c1=5/t1.c3 ORDER BY t1.c3 LIMIT 20;
-- Testcase 15:
SELECT t1.c8, t3.c1, t3.c5, t1.c2 FROM t3 LEFT JOIN t1 ON t3.c1 BETWEEN -3 AND 3 AND t1.c1 = ANY(ARRAY[0,30,50]) AND t1.c2 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 16:
SELECT t3.c4, max(t3.c1+t1.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 LEFT JOIN t1 ON ((t3.c5<0)=t1.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 17:
SELECT count(distinct t3.c1), max(t3.c2+t1.c3), stddev(t1.c3+t3.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 LEFT JOIN t1 ON (t3.c1=(t1.c3/10)) GROUP BY t3.c1,t1.c3 HAVING t3.c1<sum(t1.c3) ORDER BY 1,2,3,4,5;
-- Testcase 18:
SELECT t3.c10, t1.c10, t1.c7, t1.c8, t1.c3+t3.c1 FROM t3 LEFT JOIN t1 ON (t3.c5%2=0) = (t1.c2 LIKE '%a%') ORDER BY t3.c10 DESC, t1.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 19:
SELECT * FROM t3 RIGHT JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 IN (1,2)) ORDER BY t3.*, t1.* LIMIT 20;
-- Testcase 20:
SELECT t3.c1, t1.c2, t3.c10, t1.c10, t3.c17, t1.c11 FROM t3 RIGHT JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 < 100) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 21:
SELECT max(t3.c1+t1.c1), min(t1.c4), sum(t1.c3), avg(t3.c2+t3.c3+t1.c1), count(t3.c9), stddev(t1.c3), array_agg(t3.c7 order by t3.c7), bit_and(t1.c1), bit_or(t3.c1), bool_and(t3.c2<t1.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t1.c4), sqrt(abs(t3.c1)), upper('abcd') FROM t3 RIGHT JOIN t1 on t3.c1=t1.c1 GROUP BY t3.c1, t1.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 22:
SELECT DISTINCT t3.c1 + t1.c3 a1, t3.c10, t1. c10 FROM t3 RIGHT JOIN t1 ON t3.c1 < t1.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t1.c4!=1 AND t1.c3>=-10000 AND t1.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 23:
SELECT * FROM t3 RIGHT JOIN t1 ON t3.c1=5/t1.c3 ORDER BY t1.c3 LIMIT 20;
-- Testcase 24:
SELECT t1.c8, t3.c1, t3.c5, t1.c2 FROM t3 RIGHT JOIN t1 ON t3.c1 BETWEEN -3 AND 3 AND t1.c1 = ANY(ARRAY[0,30,50]) AND t1.c2 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 25:
SELECT t3.c4, max(t3.c1+t1.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 RIGHT JOIN t1 ON ((t3.c5<0)=t1.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 26:
SELECT count(distinct t3.c1), max(t3.c2+t1.c3), stddev(t1.c3+t3.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 RIGHT JOIN t1 ON (t3.c1=(t1.c3/10)) GROUP BY t3.c1,t1.c3 HAVING t3.c1<sum(t1.c3) ORDER BY 1,2,3,4,5;
-- Testcase 27:
SELECT t3.c10, t1.c10, t1.c7, t1.c8, t1.c3+t3.c1 FROM t3 RIGHT JOIN t1 ON (t3.c5%2=0) = (t1.c2 LIKE '%a%') ORDER BY t3.c10 DESC, t1.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 28:
SELECT * FROM t3 FULL JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 IN (1,2)) ORDER BY t3.*, t1.* LIMIT 20;
-- Testcase 29:
SELECT t3.c1, t1.c2, t3.c10, t1.c10, t3.c17, t1.c11 FROM t3 FULL JOIN t1 ON (t3.c1 = t1.c1 AND t3.c1 < 100) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 30:
SELECT max(t3.c1+t1.c1), min(t1.c4), sum(t1.c3), avg(t3.c2+t3.c3+t1.c1), count(t3.c9), stddev(t1.c3), array_agg(t3.c7 order by t3.c7), bit_and(t1.c1), bit_or(t3.c1), bool_and(t3.c2<t1.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t1.c4), sqrt(abs(t3.c1)), upper('abcd') FROM t3 FULL JOIN t1 on t3.c1=t1.c1 GROUP BY t3.c1, t1.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 31:
SELECT DISTINCT t3.c1 + t1.c3 a1, t3.c10, t1. c10 FROM t3 FULL JOIN t1 ON t3.c1 < t1.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t1.c4!=1 AND t1.c3>=-10000 AND t1.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 32:
SELECT * FROM t3 FULL JOIN t1 ON t3.c1=5/t1.c3 ORDER BY t1.c3 LIMIT 20;
-- Testcase 33:
SELECT t3.c4, max(t3.c1+t1.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 FULL JOIN t1 ON ((t3.c5<0)=t1.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 34:
SELECT count(distinct t3.c1), max(t3.c2+t1.c3), stddev(t1.c3+t3.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 FULL JOIN t1 ON (t3.c1=(t1.c3/10)) GROUP BY t3.c1,t1.c3 HAVING t3.c1<sum(t1.c3) ORDER BY 1,2,3,4,5;
-- Testcase 35:
SELECT t3.c10, t1.c10, t1.c7, t1.c8, t1.c3+t3.c1 FROM t3 FULL JOIN t1 ON (t3.c5%2=0) = (t1.c2 LIKE '%a%') ORDER BY t3.c10 DESC, t1.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 36:
SELECT * FROM t3 CROSS JOIN t1 ORDER BY t3.*, t1.* LIMIT 20;
-- Testcase 37:
SELECT t3.c1, t1.c2, t3.c10, t1.c10, t3.c17, t1.c11 FROM t3 CROSS JOIN t1 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 38:
SELECT max(t3.c1+t1.c1), min(t1.c4), sum(t1.c3), avg(t3.c2+t3.c3+t1.c1), count(t3.c9), stddev(t1.c3), array_agg(t3.c7 order by t3.c7), bit_and(t1.c1), bit_or(t3.c1), bool_and(t3.c2<t1.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t1.c4), sqrt(abs(t3.c1)), upper('abcd') FROM t3 CROSS JOIN t1 GROUP BY t3.c1, t1.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 39:
SELECT DISTINCT t3.c1 + t1.c3 a1, t3.c10, t1. c10 FROM t3 CROSS JOIN t1 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t1.c4!=1 AND t1.c3>=-10000 AND t1.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 40:
SELECT * FROM t3 CROSS JOIN t1 WHERE t3.c1=5/t1.c3 ORDER BY t1.c3 LIMIT 20;
-- Testcase 41:
SELECT t3.c4, max(t3.c1+t1.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 CROSS JOIN t1 GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 42:
SELECT count(distinct t3.c1), max(t3.c2+t1.c3), stddev(t1.c3+t3.c1), avg(t1.c3), sum(t3.c3), min(t1.c6+t3.c1) FROM t3 CROSS JOIN t1 GROUP BY t3.c1,t1.c3 HAVING t3.c1<sum(t1.c3) ORDER BY 1,2,3,4,5;
-- Testcase 43:
SELECT t3.c10, t1.c10, t1.c7, t1.c8, t1.c3+t3.c1 FROM t3 CROSS JOIN t1 ORDER BY t3.c10 DESC, t1.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 44:
SELECT * FROM t3 JOIN t5 ON t3.c1 = t5.c2 ORDER BY t3.*, t5.* LIMIT 20;
-- Testcase 45:
SELECT t3.c1, t5.c2, t3.c10, t5.c20, t3.c17, t5.c11 FROM t3 JOIN t5 ON t3.c1 = t5.c2 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 46:
SELECT max(t3.c1+t5.c2), min(t5.c4), sum(t5.c3), avg(t3.c2+t3.c3+t5.c1), count(t3.c9), stddev(t5.c3), array_agg(t3.c7 order by t3.c7), bit_and(t5.c7), bit_or(t3.c1), bool_and(t3.c2<t5.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t5.c4), sqrt(abs(t3.c1)), upper(t5.c8) FROM t3 JOIN t5 on t3.c1=t5.c2 GROUP BY t3.c1, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 47:
SELECT DISTINCT t3.c1 + t5.c2 a1, t3.c10, t5. c10 FROM t3 JOIN t5 ON t3.c1 < t5.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 48:
SELECT * FROM t3 JOIN t5 ON t3.c1/t5.c2=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 49:
SELECT t5.c8, t3.c1, t3.c5, t5.c2 FROM t3 JOIN t5 ON t3.c1 BETWEEN -3 AND 3 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 50:
SELECT t3.c4, max(t3.c1+t5.c2), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 JOIN t5 ON (t3.c5=t5.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 51:
SELECT count(distinct t3.c1), max(t3.c2+t5.c3), stddev(t5.c2+t3.c1), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 JOIN t5 ON (t3.c5=(t5.c2/10)) GROUP BY t3.c1,t5.c3 HAVING t3.c1<sum(t5.c3) ORDER BY 1,2,3,4,5;
-- Testcase 52:
SELECT t3.c10, t5.c10, t5.c7, t5.c8, t5.c2+t3.c2 FROM t3 JOIN t5 ON t3.c5>t5.c2 ORDER BY t3.c10 DESC, t5.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 53:
SELECT * FROM t3 LEFT JOIN t5 ON t3.c1 = t5.c2 ORDER BY t3.__spd_url,t3.c1,t3.c2,t3.c3,t3.c4,t3.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3 LIMIT 40;
-- Testcase 54:
SELECT t3.c1, t5.c2, t3.c10, t5.c20, t3.c17, t5.c11 FROM t3 LEFT JOIN t5 ON t3.c1 = t5.c2 ORDER BY 1,2,3,4,5,6 LIMIT 40;
-- Testcase 55:
SELECT max(t3.c1+t5.c2), min(t5.c4), sum(t5.c3), avg(t3.c2+t3.c3+t5.c1), count(t3.c9), stddev(t5.c3), array_agg(t3.c7 order by t3.c7), bit_and(t5.c7), bit_or(t3.c1), bool_and(t3.c2<t5.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t5.c4), sqrt(abs(t3.c1)), upper(t5.c8) FROM t3 LEFT JOIN t5 on t3.c1=t5.c2 GROUP BY t3.c1, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 56:
SELECT DISTINCT t3.c1 + t5.c2 a1, t3.c10, t5. c10 FROM t3 LEFT JOIN t5 ON t3.c1 < t5.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 57:
SELECT * FROM t3 LEFT JOIN t5 ON t3.c1/t5.c2=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 58:
SELECT t5.c8, t3.c1, t3.c5, t5.c2 FROM t3 LEFT JOIN t5 ON t3.c1 BETWEEN -3 AND 3 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 59:
SELECT t3.c4, max(t3.c1+t5.c2), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 LEFT JOIN t5 ON (t3.c5=t5.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 60:
SELECT count(distinct t3.c1), max(t3.c2+t5.c3), stddev(t5.c2+t3.c1), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 LEFT JOIN t5 ON (t3.c5=(t5.c2/10)) GROUP BY t3.c1,t5.c3 HAVING t3.c1<sum(t5.c3) ORDER BY 1,2,3,4,5;
-- Testcase 61:
SELECT t3.c10, t5.c10, t5.c7, t5.c8, t5.c2+t3.c2 FROM t3 LEFT JOIN t5 ON t3.c5>t5.c2 ORDER BY t3.c10 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 20;
-- Testcase 62:
SELECT * FROM t3 RIGHT JOIN t5 ON t3.c1 = t5.c2 ORDER BY t3.__spd_url,t3.c1,t3.c2,t3.c3,t3.c4,t3.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3 LIMIT 20;
-- Testcase 63:
SELECT t3.c1, t5.c2, t3.c10, t5.c20, t3.c17, t5.c11 FROM t3 RIGHT JOIN t5 ON t3.c1 = t5.c2 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 64:
SELECT max(t3.c1+t5.c2), min(t5.c4), sum(t5.c3), avg(t3.c2+t3.c3+t5.c1), count(t3.c9), stddev(t5.c3), array_agg(t3.c7 order by t3.c7), bit_and(t5.c7), bit_or(t3.c1), bool_and(t3.c2<t5.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t5.c4), sqrt(abs(t3.c1)), upper(t5.c8) FROM t3 RIGHT JOIN t5 on t3.c1=t5.c2 GROUP BY t3.c1, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 65:
SELECT DISTINCT t3.c1 + t5.c2 a1, t3.c10, t5. c10 FROM t3 RIGHT JOIN t5 ON t3.c1 < t5.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 66:
SELECT * FROM t3 RIGHT JOIN t5 ON (t3.c1/t5.c2)=1 ORDER BY t5.c2 LIMIT 20;
-- Testcase 67:
SELECT t5.c8, t3.c1, t3.c5, t5.c2 FROM t3 RIGHT JOIN t5 ON t3.c1 BETWEEN -3 AND 3 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 68:
SELECT t3.c4, max(t3.c1+t5.c2), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 RIGHT JOIN t5 ON (t3.c5=t5.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 69:
SELECT count(distinct t3.c1), max(t3.c2+t5.c3), stddev(t5.c2+t3.c1), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 RIGHT JOIN t5 ON (t3.c5=(t5.c2/10)) GROUP BY t3.c1,t5.c3 HAVING t3.c1<sum(t5.c3) ORDER BY 1,2,3,4,5;
-- Testcase 70:
SELECT t3.c10, t5.c10, t5.c7, t5.c8, t5.c2+t3.c2 FROM t3 RIGHT JOIN t5 ON t3.c5>t5.c2 ORDER BY t3.c10 DESC, t5.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 71:
SELECT * FROM t3 FULL JOIN t5 ON t3.c1 = t5.c2 ORDER BY t3.__spd_url,t3.c1,t3.c2,t3.c3,t3.c4,t3.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3 LIMIT 20;
-- Testcase 72:
SELECT t3.c1, t5.c2, t3.c10, t5.c20, t3.c17, t5.c11 FROM t3 FULL JOIN t5 ON t3.c1 = t5.c2 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 73:
SELECT max(t3.c1+t5.c2), min(t5.c4), sum(t5.c3), avg(t3.c2+t3.c3+t5.c1), count(t3.c9), stddev(t5.c3), array_agg(t3.c7 order by t3.c7), bit_and(t5.c7), bit_or(t3.c1), bool_and(t3.c2<t5.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t5.c4), sqrt(abs(t3.c1)), upper(t5.c8) FROM t3 FULL JOIN t5 on t3.c1=t5.c2 GROUP BY t3.c1, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 74:
SELECT DISTINCT t3.c1 + t5.c2 a1, t3.c10, t5. c10 FROM t3 FULL JOIN t5 ON t3.c1 < t5.c4 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 75:
SELECT * FROM t3 FULL JOIN t5 ON t3.c1=(5/t5.c2) ORDER BY t5.c2 LIMIT 20;
-- Testcase 76:
SELECT t3.c4, max(t3.c1+t5.c2), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 FULL JOIN t5 ON (t3.c5=t5.c5) GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 77:
SELECT count(distinct t3.c1), max(t3.c2+t5.c3), stddev(t5.c2+t3.c1), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 FULL JOIN t5 ON (t3.c5=(t5.c2/10)) GROUP BY t3.c1,t5.c3 HAVING t3.c1<sum(t5.c3) ORDER BY 1,2,3,4,5;
-- Testcase 78:
SELECT t3.c10, t5.c10, t5.c7, t5.c8, t5.c2+t3.c2 FROM t3 FULL JOIN t5 ON t3.c5=t5.c2 ORDER BY t3.c10 DESC, t5.c10, 3, 4, 5 LIMIT 30 OFFSET 40;
-- Testcase 79:
SELECT * FROM t3 CROSS JOIN t5 ORDER BY t3.__spd_url,t3.c1,t3.c2,t3.c3,t3.c4,t3.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3 LIMIT 40;
-- Testcase 80:
SELECT t3.c1, t5.c2, t3.c10, t5.c20, t3.c17, t5.c11 FROM t3 CROSS JOIN t5 ORDER BY 1,2,3,4,5,6 LIMIT 40;
-- Testcase 81:
SELECT max(t3.c1+t5.c2), min(t5.c4), sum(t5.c3), avg(t3.c2+t3.c3+t5.c1), count(t3.c9), stddev(t5.c3), array_agg(t3.c7 order by t3.c7), bit_and(t5.c7), bit_or(t3.c1), bool_and(t3.c2<t5.c3), bool_or(t3.c2>0), string_agg(t3.c17, ';' order by t3.c17), every(t3.c4<t5.c4), sqrt(abs(t3.c1)), upper(t5.c8) FROM t3 CROSS JOIN t5 GROUP BY t3.c1, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 82:
SELECT DISTINCT t3.c1 + t5.c2 a1, t3.c10, t5. c10 FROM t3 CROSS JOIN t5 WHERE (t3.c1=-5 OR t3.c4>t3.c1) AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40;
-- Testcase 83:
SELECT * FROM t3 CROSS JOIN t5 WHERE t3.c1/t5.c2=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 84:
SELECT t5.c8, t3.c1, t3.c5, t5.c2 FROM t3 CROSS JOIN t5 WHERE t3.c1 BETWEEN -3 AND 3 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 85:
SELECT t3.c4, max(t3.c1+t5.c2), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 CROSS JOIN t5 GROUP BY t3.c4 HAVING t3.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 86:
SELECT count(distinct t3.c1), max(t3.c2+t5.c3), stddev(t5.c2+t3.c1), avg(t5.c3), sum(t3.c3), min(t5.c6+t3.c1) FROM t3 CROSS JOIN t5 GROUP BY t3.c1,t5.c3 HAVING t3.c1<sum(t5.c3) ORDER BY 1,2,3,4,5 LIMIT 50 OFFSET 10;
-- Testcase 87:
SELECT t3.c10, t5.c10, t5.c7, t5.c8, t5.c2+t3.c2 FROM t3 CROSS JOIN t5 ORDER BY t3.c10 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 20;
-- Testcase 88:
SELECT * FROM t7 JOIN t5 ON t7.c3 = t5.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3,t5.c4,t5.c5,t5.c6 LIMIT 20 OFFSET 5;
-- Testcase 89:
SELECT t7.time, t5.c2, t7.c5, t5.c20, t7.c3, t5.c11 FROM t7 JOIN t5 ON t7.c3 = -t5.c2/20 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 90:
SELECT max(t7.c3+t5.c2), min(t5.c4), sum(t5.c3), avg(t7.c3+t5.c1), count(t7.c2), stddev(t5.c3), array_agg(t7.c4 order by t7.c4), bit_and(t5.c7), bit_or(t7.c3), bool_and(t7.c4<t5.c3), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t5.c4), sqrt(abs(t7.c3)), upper(t5.c8) FROM t7 JOIN t5 ON t7.c3*10=t5.c2 GROUP BY t7.c3, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 91:
SELECT DISTINCT t7.time, t5.c2 a1, t7.c5, t5.c10 FROM t7 JOIN t5 ON t7.c3 < t5.c4 WHERE t7.c3<=50 AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 92:
SELECT * FROM t7 JOIN t5 ON (t7.c3/t5.c2)=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 93:
SELECT t5.c8, t7.time, t7.c5, t5.c2 FROM t7 JOIN t5 ON t7.c4 BETWEEN -30 AND 100 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 94:
SELECT t7.c4, max(t7.c2), avg(t5.c3), sum(t7.c3), min(t5.c6) FROM t7 JOIN t5 ON (t7.c3=(t5.c1/1000) OR t5.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 95:
SELECT count(distinct t7.c2), max(t7.c3+t5.c3), stddev(t5.c2+t7.c4), avg(t5.c3), sum(t7.c3), min(t5.c6+t7.c3) FROM t7 JOIN t5 ON (t7.c3<(t5.c2/10)) GROUP BY t7.c2,t5.c3 HAVING max(t7.c3)<sum(t5.c3)/100 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 96:
SELECT DISTINCT t7.c5, t5.c10, t5.c7, t5.c8, t5.c2+t7.c3 FROM t7 JOIN t5 ON t7.c2>t5.c8 ORDER BY t7.c5 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 97:
SELECT * FROM t7 LEFT JOIN t5 ON t7.c3 = t5.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3,t5.c4,t5.c5,t5.c6 LIMIT 20 OFFSET 5;
-- Testcase 98:
SELECT t7.time, t5.c2, t7.c5, t5.c20, t7.c3, t5.c11 FROM t7 LEFT JOIN t5 ON t7.c3 = -t5.c2/20 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 99:
SELECT max(t7.c3+t5.c2), min(t5.c4), sum(t5.c3), avg(t7.c3+t5.c1), count(t7.c2), stddev(t5.c3), array_agg(t7.c4 order by t7.c4), bit_and(t5.c7), bit_or(t7.c3), bool_and(t7.c4<t5.c3), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t5.c4), sqrt(abs(t7.c3)), upper(t5.c8) FROM t7 LEFT JOIN t5 ON t7.c3*10=t5.c2 GROUP BY t7.c3, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 100:
SELECT DISTINCT t7.time, t5.c2 a1, t7.c5, t5.c10 FROM t7 LEFT JOIN t5 ON t7.c3 < t5.c4 WHERE t7.c3<=50 AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 101:
SELECT * FROM t7 LEFT JOIN t5 ON (t7.c3/t5.c2)=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 102:
SELECT t5.c8, t7.time, t7.c5, t5.c2 FROM t7 LEFT JOIN t5 ON t7.c4 BETWEEN -30 AND 100 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 103:
SELECT t7.c4, max(t7.c2), avg(t5.c3), sum(t7.c3), min(t5.c6) FROM t7 LEFT JOIN t5 ON (t7.c3=(t5.c1/1000) OR t5.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 104:
SELECT count(distinct t7.c2), max(t7.c3+t5.c3), stddev(t5.c2+t7.c4), avg(t5.c3), sum(t7.c3), min(t5.c6+t7.c3) FROM t7 LEFT JOIN t5 ON (t7.c3<(t5.c2/10)) GROUP BY t7.c2,t5.c3 HAVING max(t7.c3)<sum(t5.c3)/100 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 105:
SELECT DISTINCT t7.c5, t5.c10, t5.c7, t5.c8, t5.c2+t7.c3 FROM t7 LEFT JOIN t5 ON t7.c2>t5.c8 ORDER BY t7.c5 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 106:
SELECT * FROM t7 RIGHT JOIN t5 ON t7.c3 = t5.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3,t5.c4,t5.c5,t5.c6 LIMIT 20 OFFSET 5;
-- Testcase 107:
SELECT t7.time, t5.c2, t7.c5, t5.c20, t7.c3, t5.c11 FROM t7 RIGHT JOIN t5 ON t7.c3 = -t5.c2/20 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 108:
SELECT max(t7.c3+t5.c2), min(t5.c4), sum(t5.c3), avg(t7.c3+t5.c1), count(t7.c2), stddev(t5.c3), array_agg(t7.c4 order by t7.c4), bit_and(t5.c7), bit_or(t7.c3), bool_and(t7.c4<t5.c3), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t5.c4), sqrt(abs(t7.c3)), upper(t5.c8) FROM t7 RIGHT JOIN t5 ON t7.c3*10=t5.c2 GROUP BY t7.c3, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 109:
SELECT DISTINCT t7.time, t5.c2 a1, t7.c5, t5.c10 FROM t7 RIGHT JOIN t5 ON t7.c3 < t5.c4 WHERE t7.c3<=50 AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 110:
SELECT * FROM t7 RIGHT JOIN t5 ON (t7.c3/t5.c2)=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 111:
SELECT t5.c8, t7.time, t7.c5, t5.c2 FROM t7 RIGHT JOIN t5 ON t7.c4 BETWEEN -30 AND 100 AND t5.c2 = ANY(ARRAY[0,30,50]) AND t5.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 112:
SELECT t7.c4, max(t7.c2), avg(t5.c3), sum(t7.c3), min(t5.c6) FROM t7 RIGHT JOIN t5 ON (t7.c3=(t5.c1/1000) OR t5.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 113:
SELECT count(distinct t7.c2), max(t7.c3+t5.c3), stddev(t5.c2+t7.c4), avg(t5.c3), sum(t7.c3), min(t5.c6+t7.c3) FROM t7 RIGHT JOIN t5 ON (t7.c3<(t5.c2/10)) GROUP BY t7.c2,t5.c3 HAVING max(t7.c3)<sum(t5.c3)/100 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 114:
SELECT DISTINCT t7.c5, t5.c10, t5.c7, t5.c8, t5.c2+t7.c3 FROM t7 RIGHT JOIN t5 ON t7.c2>t5.c8 ORDER BY t7.c5 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 115:
SELECT * FROM t7 FULL JOIN t5 ON t7.c3 = t5.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3,t5.c4,t5.c5,t5.c6 LIMIT 20 OFFSET 5;
-- Testcase 116:
SELECT t7.time, t5.c2, t7.c5, t5.c20, t7.c3, t5.c11 FROM t7 FULL JOIN t5 ON t7.c3 = -t5.c2/20 ORDER BY 1,2,3,4,5,6 LIMIT 20;
-- Testcase 117:
SELECT max(t7.c3+t5.c2), min(t5.c4), sum(t5.c3), avg(t7.c3+t5.c1), count(t7.c2), stddev(t5.c3), array_agg(t7.c4 order by t7.c4), bit_and(t5.c7), bit_or(t7.c3), bool_and(t7.c4<t5.c3), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t5.c4), sqrt(abs(t7.c3)), upper(t5.c8) FROM t7 FULL JOIN t5 ON t7.c3*10=t5.c2 GROUP BY t7.c3, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 118:
SELECT DISTINCT t7.time, t5.c2 a1, t7.c5, t5.c10 FROM t7 FULL JOIN t5 ON t7.c3 < t5.c4 WHERE t7.c3<=50 AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 119:
SELECT * FROM t7 FULL JOIN t5 ON t7.c3=(5/t5.c2) ORDER BY t5.c2 LIMIT 20;
-- Testcase 120:
SELECT t7.c4, max(t7.c2), avg(t5.c3), sum(t7.c3), min(t5.c6) FROM t7 FULL JOIN t5 ON (t7.c3=(t5.c1/1000) OR t5.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 121:
SELECT count(distinct t7.c2), max(t7.c3+t5.c3), stddev(t5.c2+t7.c4), avg(t5.c3), sum(t7.c3), min(t5.c6+t7.c3) FROM t7 FULL JOIN t5 ON t7.c3=(t5.c2/10) GROUP BY t7.c2,t5.c3 HAVING max(t7.c3)<sum(t5.c3)/100 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 122:
SELECT DISTINCT t7.c5, t5.c10, t5.c7, t5.c8, t5.c2+t7.c3 FROM t7 FULL JOIN t5 ON t7.c3=t5.c3/10000 ORDER BY t7.c5 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 0;
-- Testcase 123:
SELECT * FROM t7 CROSS JOIN t5 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t5.__spd_url,t5.c1,t5.c2,t5.c3,t5.c4,t5.c5,t5.c6 LIMIT 20 OFFSET 5;
-- Testcase 124:
SELECT DISTINCT t7.time, t5.c2, t7.c5, t5.c20, t7.c3, t5.c11 FROM t7 CROSS JOIN t5 ORDER BY 1,2,3,4,5,6 LIMIT 40;
-- Testcase 125:
SELECT max(t7.c3+t5.c2), min(t5.c4), sum(t5.c3), avg(t7.c3+t5.c1), count(t7.c2), stddev(t5.c3), array_agg(t7.c4 order by t7.c4), bit_and(t5.c7), bit_or(t7.c3), bool_and(t7.c4<t5.c3), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t5.c4), sqrt(abs(t7.c3)), upper(t5.c8) FROM t7 CROSS JOIN t5 GROUP BY t7.c3, t5.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 LIMIT 50;
-- Testcase 126:
SELECT DISTINCT t7.time, t5.c2 a1, t7.c5, t5.c10 FROM t7 CROSS JOIN t5 WHERE t7.c3<=50 AND t5.c4!=1 AND t5.c3>=-10000 AND t5.c3 <=1000000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 127:
SELECT * FROM t7 CROSS JOIN t5 WHERE (t7.c3/t5.c2)=0 ORDER BY t5.c2 LIMIT 20;
-- Testcase 128:
SELECT t7.c4, max(t7.c2), avg(t5.c3), sum(t7.c3), min(t5.c6) FROM t7 CROSS JOIN t5 GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 129:
SELECT count(distinct t7.c2), max(t7.c3+t5.c3), stddev(t5.c2+t7.c4), avg(t5.c3), sum(t7.c3), min(t5.c6+t7.c3) FROM t7 CROSS JOIN t5 GROUP BY t7.c2,t5.c3 HAVING max(t7.c3)<sum(t5.c3)/100 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 130:
SELECT DISTINCT t7.c5, t5.c10, t5.c7, t5.c8, t5.c2+t7.c3 FROM t7 CROSS JOIN t5 ORDER BY t7.c5 DESC, t5.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 131:
SELECT * FROM t7 JOIN t9 ON t7.c3 = t9.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 132:
SELECT t7.time, t9.c2, t7.c5, t9.c7, t7.c3, t9.c8 FROM t7 JOIN t9 ON t7.c3=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 133:
SELECT max(t7.c3+t9.c2), min(t9.c8), sum(t9.c1), avg(t7.c3+t9.c1), count(t7.c2), stddev(t9.c2), array_agg(t7.c4 order by t7.c4), bit_and(t9.c4), bit_or(t7.c3), bool_and(t7.c4<t9.c2), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t9.c15), sqrt(abs(t7.c3)), upper(t9.c8) FROM t7 JOIN t9 ON t7.c3=t9.c1 GROUP BY t7.c3, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 134:
SELECT DISTINCT t7.time, t9.c2 a1, t7.c5, t9.c10 FROM t7 JOIN t9 ON t7.c4 < t9.c2 WHERE t7.c3<=50 AND t9.c15!=1 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 135:
SELECT * FROM t7 JOIN t9 ON (t7.c3/t9.c1)=0 ORDER BY t9.c1 LIMIT 20;
-- Testcase 136:
SELECT t9.c8, t7.time, t7.c5, t9.c2 FROM t7 JOIN t9 ON t7.c4 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 137:
SELECT t7.c4, max(t7.c2), avg(t9.c15), sum(t7.c3), min(t9.c8) FROM t7 JOIN t9 ON (t7.c3=(t9.c1/1000) OR t9.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 138:
SELECT count(distinct t7.c2), max(t9.c1), stddev(t9.c2+t7.c4), avg(t9.c2), sum(t7.c3), min(t7.c4) FROM t7 JOIN t9 ON (t7.c3=t9.c1 OR t7.c4>t9.c2) GROUP BY t7.c3,t9.c1 HAVING t7.c3<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 139:
SELECT DISTINCT t7.c5, t9.c10, t9.c7, t9.c8, t9.c2+t7.c3 FROM t7 JOIN t9 ON t7.c2>t9.c8 ORDER BY t7.c5 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 140:
SELECT * FROM t7 LEFT OUTER JOIN t9 ON t7.c3 = t9.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 141:
SELECT t7.time, t9.c2, t7.c5, t9.c7, t7.c3, t9.c8 FROM t7 LEFT OUTER JOIN t9 ON t7.c3=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 142:
SELECT max(t7.c3+t9.c2), min(t9.c8), sum(t9.c1), avg(t7.c3+t9.c1), count(t7.c2), stddev(t9.c2), array_agg(t7.c4 order by t7.c4), bit_and(t9.c4), bit_or(t7.c3), bool_and(t7.c4<t9.c2), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t9.c15), sqrt(abs(t7.c3)), upper(t9.c8) FROM t7 LEFT OUTER JOIN t9 ON t7.c3=t9.c1 GROUP BY t7.c3, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 143:
SELECT DISTINCT t7.time, t9.c2 a1, t7.c5, t9.c10 FROM t7 LEFT OUTER JOIN t9 ON t7.c4 < t9.c2 WHERE t7.c3<=50 AND t9.c15!=1 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 144:
SELECT * FROM t7 LEFT OUTER JOIN t9 ON (t7.c3/t9.c1)=0 ORDER BY t9.c1 LIMIT 20;
-- Testcase 145:
SELECT DISTINCT t9.c8, t7.time, t7.c5, t9.c2 FROM t7 LEFT OUTER JOIN t9 ON t7.c4 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 146:
SELECT t7.c4, max(t7.c2), avg(t9.c15), sum(t7.c3), min(t9.c8) FROM t7 LEFT OUTER JOIN t9 ON (t7.c3=(t9.c1/1000) OR t9.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 147:
SELECT count(distinct t7.c2), max(t9.c1), stddev(t9.c2+t7.c4), avg(t9.c2), sum(t7.c3), min(t7.c4) FROM t7 LEFT OUTER JOIN t9 ON (t7.c3=t9.c1 OR t7.c4>t9.c2) GROUP BY t7.c3,t9.c1 HAVING t7.c3<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 148:
SELECT DISTINCT t7.c5, t9.c10, t9.c7, t9.c8, t9.c2+t7.c3 FROM t7 LEFT OUTER JOIN t9 ON t7.c2>t9.c8 ORDER BY t7.c5 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 149:
SELECT * FROM t7 RIGHT OUTER JOIN t9 ON t7.c3 = t9.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 150:
SELECT t7.time, t9.c2, t7.c5, t9.c7, t7.c3, t9.c8 FROM t7 RIGHT OUTER JOIN t9 ON t7.c3=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 151:
SELECT max(t7.c3+t9.c2), min(t9.c8), sum(t9.c1), avg(t7.c3+t9.c1), count(t7.c2), stddev(t9.c2), array_agg(t7.c4 order by t7.c4), bit_and(t9.c4), bit_or(t7.c3), bool_and(t7.c4<t9.c2), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t9.c15), sqrt(abs(t7.c3)), upper(t9.c8) FROM t7 RIGHT OUTER JOIN t9 ON t7.c3=t9.c1 GROUP BY t7.c3, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 152:
SELECT DISTINCT t7.time, t9.c2 a1, t7.c5, t9.c10 FROM t7 RIGHT OUTER JOIN t9 ON t7.c4 < t9.c2 WHERE t7.c3<=50 AND t9.c15!=1 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 153:
SELECT * FROM t7 RIGHT OUTER JOIN t9 ON t7.c3=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 154:
SELECT DISTINCT t9.c8, t7.time, t7.c5, t9.c2 FROM t7 RIGHT OUTER JOIN t9 ON t7.c4 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 155:
SELECT t7.c4, max(t7.c2), avg(t9.c15), sum(t7.c3), min(t9.c8) FROM t7 RIGHT OUTER JOIN t9 ON (t7.c3=(t9.c1/1000) OR t9.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 156:
SELECT count(distinct t7.c2), max(t9.c1), stddev(t9.c2+t7.c4), avg(t9.c2), sum(t7.c3), min(t7.c4) FROM t7 RIGHT OUTER JOIN t9 ON (t7.c3=t9.c1 OR t7.c4>t9.c2) GROUP BY t7.c3,t9.c1 HAVING t7.c3<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 157:
SELECT DISTINCT t7.c5, t9.c10, t9.c7, t9.c8, t9.c2+t7.c3 FROM t7 RIGHT OUTER JOIN t9 ON t7.c2>t9.c8 ORDER BY t7.c5 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 40;
-- Testcase 158:
SELECT * FROM t7 FULL OUTER JOIN t9 ON t7.c3 = t9.c2/10 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 159:
SELECT t7.time, t9.c2, t7.c5, t9.c7, t7.c3, t9.c8 FROM t7 FULL OUTER JOIN t9 ON t7.c3=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 160:
SELECT max(t7.c3+t9.c2), min(t9.c8), sum(t9.c1), avg(t7.c3+t9.c1), count(t7.c2), stddev(t9.c2), array_agg(t7.c4 order by t7.c4), bit_and(t9.c4), bit_or(t7.c3), bool_and(t7.c4<t9.c2), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t9.c15), sqrt(abs(t7.c3)), upper(t9.c8) FROM t7 FULL OUTER JOIN t9 ON t7.c3=t9.c1 GROUP BY t7.c3, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 161:
SELECT DISTINCT t7.time, t9.c2 a1, t7.c5, t9.c10 FROM t7 FULL OUTER JOIN t9 ON t7.c4 < t9.c2 WHERE t7.c3<=50 AND t9.c15!=1 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 162:
SELECT * FROM t7 FULL OUTER JOIN t9 ON t7.c3=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 163:
SELECT t7.c4, max(t7.c2), avg(t9.c15), sum(t7.c3), min(t9.c8) FROM t7 FULL OUTER JOIN t9 ON (t7.c3=(t9.c1/1000) OR t9.c2>t7.c3) GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 164:
SELECT count(distinct t7.c2), max(t9.c1), stddev(t9.c2+t7.c4), avg(t9.c2), sum(t7.c3), min(t7.c4) FROM t7 FULL OUTER JOIN t9 ON t7.c3=t9.c1 GROUP BY t7.c3,t9.c1 HAVING t7.c3<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 165:
SELECT DISTINCT t7.c5, t9.c10, t9.c7, t9.c8, t9.c2+t7.c3 FROM t7 FULL OUTER JOIN t9 ON t7.c3=t9.c1 ORDER BY t7.c5 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 166:
SELECT * FROM t7 CROSS JOIN t9 ORDER BY t7.__spd_url,t7.time,t7.c2,t7.c3,t7.c4,t7.c5,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 167:
SELECT t7.time, t9.c2, t7.c5, t9.c7, t7.c3, t9.c8 FROM t7 CROSS JOIN t9 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 168:
SELECT max(t7.c3+t9.c2), min(t9.c8), sum(t9.c1), avg(t7.c3+t9.c1), count(t7.c2), stddev(t9.c2), array_agg(t7.c4 order by t7.c4), bit_and(t9.c4), bit_or(t7.c3), bool_and(t7.c4<t9.c2), bool_or(t7.c4>0), string_agg(t7.c2, ';' order by t7.c2), every(t7.c4<t9.c15), sqrt(abs(t7.c3)), upper(t9.c8) FROM t7 CROSS JOIN t9 GROUP BY t7.c3, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 LIMIT 100;
-- Testcase 169:
SELECT DISTINCT t7.time, t9.c2 a1, t7.c5, t9.c10 FROM t7 CROSS JOIN t9 WHERE t7.c3<=50 AND t9.c15!=1 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 170:
SELECT * FROM t7 CROSS JOIN t9 WHERE t7.c3=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 171:
SELECT t7.c4, max(t7.c2), avg(t9.c15), sum(t7.c3), min(t9.c8) FROM t7 CROSS JOIN t9 GROUP BY t7.c4 HAVING t7.c4<100 ORDER BY 1,2,3,4,5;
-- Testcase 172:
SELECT count(distinct t7.c2), max(t9.c1), stddev(t9.c2+t7.c4), avg(t9.c2), sum(t7.c3), min(t7.c4) FROM t7 CROSS JOIN t9 GROUP BY t7.c3,t9.c1 HAVING t7.c3<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 173:
SELECT DISTINCT t7.c5, t9.c10, t9.c7, t9.c8, t9.c2+t7.c3 FROM t7 CROSS JOIN t9 ORDER BY t7.c5 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 174:
SELECT * FROM tmp_t11 t11 JOIN t9 ON t11.c1 = t9.c2/10 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 175:
SELECT t11.c9, t9.c2, t11.c11, t9.c21, t11.c3, t9.c8 FROM tmp_t11 t11 JOIN t9 ON t11.c1=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 176:
SELECT max(t9.c2), min(t9.c8), sum(t9.c1), avg(t9.c15), count(t11.c2), stddev(t9.c2), array_agg(t11.c4 order by t11.c4), bit_and(t9.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1<100000), sqrt(abs(t11.c1)), upper(t9.c8) FROM tmp_t11 t11 JOIN t9 ON t11.c1=t9.c1 GROUP BY t11.c1, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 177:
SELECT DISTINCT t11.c1, t9.c2 a1, t11.c6, t9.c10 FROM tmp_t11 t11 JOIN t9 ON t11.c1 < t9.c2 WHERE t11.c4!=true AND t9.c15>2 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 178:
SELECT * FROM tmp_t11 t11 JOIN t9 ON t11.c1=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 179:
SELECT t9.c8, t11.c14, t11.c6, t9.c2 FROM tmp_t11 t11 JOIN t9 ON t11.c1 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 180:
SELECT t11.c1, max(t11.c12), avg(t9.c15), sum(t11.c14), min(t9.c8) FROM tmp_t11 t11 JOIN t9 ON (t11.c4=t9.c5 OR t9.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 181:
SELECT count(distinct t11.c2), max(t9.c1), stddev(t11.c1), avg(t9.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 JOIN t9 ON (t11.c1=t9.c1 OR t11.c4=t9.c5) GROUP BY t11.c3,t9.c1 HAVING 100<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 182:
SELECT DISTINCT t11.c8, t9.c10, t9.c7, t9.c8, t11.c3 FROM tmp_t11 t11 JOIN t9 ON t11.c1!=t9.c1 ORDER BY t11.c8 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 183:
SELECT * FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1 = t9.c2/10 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 184:
SELECT t11.c9, t9.c2, t11.c11, t9.c21, t11.c3, t9.c8 FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 185:
SELECT max(t9.c2), min(t9.c8), sum(t9.c1), avg(t9.c15), count(t11.c2), stddev(t9.c2), array_agg(t11.c4 order by t11.c4), bit_and(t9.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1<100000), sqrt(abs(t11.c1)), upper(t9.c8) FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1=t9.c1 GROUP BY t11.c1, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 186:
SELECT DISTINCT t11.c1, t9.c2 a1, t11.c6, t9.c10 FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1 < t9.c2 WHERE t11.c4!=true AND t9.c15>2 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 187:
SELECT * FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 188:
SELECT t9.c8, t11.c14, t11.c6, t9.c2 FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 189:
SELECT t11.c1, max(t11.c12), avg(t9.c15), sum(t11.c14), min(t9.c8) FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON (t11.c4=t9.c5 OR t9.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 190:
SELECT count(distinct t11.c2), max(t9.c1), stddev(t11.c1), avg(t9.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON (t11.c1=t9.c1 OR t11.c4=t9.c5) GROUP BY t11.c3,t9.c1 HAVING 100<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 191:
SELECT DISTINCT t11.c8, t9.c10, t9.c7, t9.c8, t11.c3 FROM tmp_t11 t11 LEFT OUTER JOIN t9 ON t11.c1!=t9.c1 ORDER BY t11.c8 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 192:
SELECT * FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1 = t9.c2/10 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 193:
SELECT t11.c9, t9.c2, t11.c11, t9.c21, t11.c3, t9.c8 FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 194:
SELECT max(t9.c2), min(t9.c8), sum(t9.c1), avg(t9.c15), count(t11.c2), stddev(t9.c2), array_agg(t11.c4 order by t11.c4), bit_and(t9.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1<100000), sqrt(abs(t11.c1)), upper(t9.c8) FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1=t9.c1 GROUP BY t11.c1, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 195:
SELECT DISTINCT t11.c1, t9.c2 a1, t11.c6, t9.c10 FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1 < t9.c2 WHERE t11.c4!=true AND t9.c15>2 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 196:
SELECT * FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 197:
SELECT t9.c8, t11.c14, t11.c6, t9.c2 FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1 BETWEEN -30 AND 100 AND t9.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t9.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 40;
-- Testcase 198:
SELECT t11.c1, max(t11.c12), avg(t9.c15), sum(t11.c14), min(t9.c8) FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON (t11.c4=t9.c5 OR t9.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 199:
SELECT count(distinct t11.c2), max(t9.c1), stddev(t11.c1), avg(t9.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON (t11.c1=t9.c1 OR t11.c4=t9.c5) GROUP BY t11.c3,t9.c1 HAVING 100<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 200:
SELECT DISTINCT t11.c8, t9.c10, t9.c7, t9.c8, t11.c3 FROM tmp_t11 t11 RIGHT OUTER JOIN t9 ON t11.c1!=t9.c1 ORDER BY t11.c8 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 201:
SELECT * FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1 = t9.c2/10 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 202:
SELECT t11.c9, t9.c2, t11.c11, t9.c21, t11.c3, t9.c8 FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1=-t9.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 203:
SELECT max(t9.c2), min(t9.c8), sum(t9.c1), avg(t9.c15), count(t11.c2), stddev(t9.c2), array_agg(t11.c4 order by t11.c4), bit_and(t9.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1<100000), sqrt(abs(t11.c1)), upper(t9.c8) FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1=t9.c1 GROUP BY t11.c1, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 204:
SELECT DISTINCT t11.c1, t9.c2 a1, t11.c6, t9.c10 FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1 < t9.c2 WHERE t11.c4!=true AND t9.c15>2 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 205:
SELECT * FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 206:
SELECT t11.c1, max(t11.c12), avg(t9.c15), sum(t11.c14), min(t9.c8) FROM tmp_t11 t11 FULL OUTER JOIN t9 ON (t11.c4=t9.c5 OR t9.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 207:
SELECT count(distinct t11.c2), max(t9.c1), stddev(t11.c1), avg(t9.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1=t9.c15 GROUP BY t11.c3,t9.c1 HAVING 1<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 208:
SELECT DISTINCT t11.c8, t9.c10, t9.c7, t9.c8, t11.c3 FROM tmp_t11 t11 FULL OUTER JOIN t9 ON t11.c1=t9.c1 ORDER BY t11.c8 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 209:
SELECT * FROM tmp_t11 t11 CROSS JOIN t9 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t9.__spd_url,t9.c1,t9.c2,t9.c3,t9.c4,t9.c5,t9.c7,t9.c8 LIMIT 20 OFFSET 5;
-- Testcase 210:
SELECT t11.c9, t9.c2, t11.c11, t9.c21, t11.c3, t9.c8 FROM tmp_t11 t11 CROSS JOIN t9 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 211:
SELECT max(t9.c2), min(t9.c8), sum(t9.c1), avg(t9.c15), count(t11.c2), stddev(t9.c2), array_agg(t11.c4 order by t11.c4), bit_and(t9.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1<100000), sqrt(abs(t11.c1)), upper(t9.c8) FROM tmp_t11 t11 CROSS JOIN t9 GROUP BY t11.c1, t9.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 212:
SELECT DISTINCT t11.c1, t9.c2 a1, t11.c6, t9.c10 FROM tmp_t11 t11 CROSS JOIN t9 WHERE t11.c4!=true AND t9.c15>2 AND t9.c13>=-10000 AND t9.c15<=1000 ORDER BY 1,2,3 LIMIT 40 OFFSET 5;
-- Testcase 213:
SELECT * FROM tmp_t11 t11 CROSS JOIN t9 WHERE t11.c1=5/t9.c1 ORDER BY t9.c1 LIMIT 20;
-- Testcase 214:
SELECT t11.c1, max(t11.c12), avg(t9.c15), sum(t11.c14), min(t9.c8) FROM tmp_t11 t11 CROSS JOIN t9 GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 215:
SELECT count(distinct t11.c2), max(t9.c1), stddev(t11.c1), avg(t9.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 CROSS JOIN t9 GROUP BY t11.c3,t9.c1 HAVING 1<sum(t9.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 216:
SELECT DISTINCT t11.c8, t9.c10, t9.c7, t9.c8, t11.c3 FROM tmp_t11 t11 CROSS JOIN t9 ORDER BY t11.c8 DESC, t9.c10, 3, 4, 5 LIMIT 40 OFFSET 2;
-- Testcase 217:
SELECT * FROM tmp_t11 t11 JOIN t13 ON (t11.c1=t13.c2/10 AND t13.c2>0) ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t11.c7,t11.c8,t11.c9,t11.c11,t11.c12,t11.c13,t11.c14,t11.c15,t13.* LIMIT 20 OFFSET 5;
-- Testcase 218:
SELECT t11.c9, t13.c2, t11.c11, t13.c21, t11.c3, t13.c8 FROM tmp_t11 t11 JOIN t13 ON t11.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 219:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t11.c2), stddev(t11.c1), array_agg(t11.c4 order by t11.c4), bit_and(t13.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1+t13.c1<100000), sqrt(abs(t11.c1*2)), upper(t13.c8) FROM tmp_t11 t11 JOIN t13 ON t11.c1=t13.c1 GROUP BY t11.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 220:
SELECT DISTINCT t11.c1, t13.c2 a1, t11.c6, t13.c10 FROM tmp_t11 t11 JOIN t13 ON t11.c1 < t13.c2 WHERE t11.c4!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 221:
SELECT * FROM tmp_t11 t11 JOIN t13 ON t11.c1=5/t13.c1 ORDER BY t13.c1 LIMIT 20;
-- Testcase 222:
SELECT DISTINCT t13.c1, t11.c14, t11.c6, t13.c2 FROM tmp_t11 t11 JOIN t13 ON t11.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 223:
SELECT t11.c1, max(t11.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t11.c14 ORDER BY t11.c14), min(t13.c8) FROM tmp_t11 t11 JOIN t13 ON (t11.c1=t13.c2 OR t13.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 224:
SELECT count(distinct t11.c2), max(t13.c1), stddev(t11.c1), avg(t13.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 JOIN t13 ON (t11.c1=t13.c1 OR t11.c12<t13.c5) GROUP BY t11.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 225:
SELECT DISTINCT t11.c8, t13.c10, t13.c7, t13.c8, t11.c3 FROM tmp_t11 t11 JOIN t13 ON t11.c1!=t13.c1 ORDER BY t11.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 226:
SELECT * FROM tmp_t11 t11 LEFT JOIN t13 ON (t11.c1=t13.c2/10 AND t13.c2>0) ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t11.c7,t11.c8,t11.c9,t11.c11,t11.c12,t11.c13,t11.c14,t11.c15,t13.* LIMIT 20 OFFSET 5;
-- Testcase 227:
SELECT t11.c9, t13.c2, t11.c11, t13.c21, t11.c3, t13.c8 FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 228:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t11.c2), stddev(t11.c1), array_agg(t11.c4 order by t11.c4), bit_and(t13.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1+t13.c1<100000), sqrt(abs(t11.c1*2)), upper(t13.c8) FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1=t13.c1 GROUP BY t11.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 229:
SELECT DISTINCT t11.c1, t13.c2 a1, t11.c6, t13.c10 FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1 < t13.c2 WHERE t11.c4!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 230:
SELECT * FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1=5/t13.c1 ORDER BY t13.c1 LIMIT 20;
-- Testcase 231:
SELECT DISTINCT t13.c1, t11.c14, t11.c6, t13.c2 FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 232:
SELECT t11.c1, max(t11.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t11.c14 ORDER BY t11.c14), min(t13.c8) FROM tmp_t11 t11 LEFT JOIN t13 ON (t11.c1=t13.c2 OR t13.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 233:
SELECT count(distinct t11.c2), max(t13.c1), stddev(t11.c1), avg(t13.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 LEFT JOIN t13 ON (t11.c1=t13.c1 OR t11.c12<t13.c5) GROUP BY t11.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 234:
SELECT DISTINCT t11.c8, t13.c10, t13.c7, t13.c8, t11.c3 FROM tmp_t11 t11 LEFT JOIN t13 ON t11.c1!=t13.c1 ORDER BY t11.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 235:
SELECT * FROM tmp_t11 t11 RIGHT JOIN t13 ON (t11.c1=t13.c2/10 AND t13.c2>0) ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t11.c7,t11.c8,t11.c9,t11.c11,t11.c12,t11.c13,t11.c14,t11.c15,t13.* LIMIT 20 OFFSET 5;
-- Testcase 236:
SELECT t11.c9, t13.c2, t11.c11, t13.c21, t11.c3, t13.c8 FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 237:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t11.c2), stddev(t11.c1), array_agg(t11.c4 order by t11.c4), bit_and(t13.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1+t13.c1<100000), sqrt(abs(t11.c1*2)), upper(t13.c8) FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1=t13.c1 GROUP BY t11.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 238:
SELECT DISTINCT t11.c1, t13.c2 a1, t11.c6, t13.c10 FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1 < t13.c2 WHERE t11.c4!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 239:
SELECT * FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1=5/t13.c1 ORDER BY t13.c1 LIMIT 20;
-- Testcase 240:
SELECT DISTINCT t13.c1, t11.c14, t11.c6, t13.c2 FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 241:
SELECT t11.c1, max(t11.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t11.c14 ORDER BY t11.c14), min(t13.c8) FROM tmp_t11 t11 RIGHT JOIN t13 ON (t11.c1=t13.c2 OR t13.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 242:
SELECT count(distinct t11.c2), max(t13.c1), stddev(t11.c1), avg(t13.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 RIGHT JOIN t13 ON (t11.c1=t13.c1 OR t11.c12<t13.c5) GROUP BY t11.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 243:
SELECT DISTINCT t11.c8, t13.c10, t13.c7, t13.c8, t11.c3 FROM tmp_t11 t11 RIGHT JOIN t13 ON t11.c1!=t13.c1 ORDER BY t11.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 244:
SELECT * FROM tmp_t11 t11 FULL JOIN t13 ON (t11.c1=t13.c2/10 AND t13.c2>0) ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t11.c7,t11.c8,t11.c9,t11.c11,t11.c12,t11.c13,t11.c14,t11.c15,t13.* LIMIT 20 OFFSET 5;
-- Testcase 245:
SELECT t11.c9, t13.c2, t11.c11, t13.c21, t11.c3, t13.c8 FROM tmp_t11 t11 FULL JOIN t13 ON t11.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 246:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t11.c2), stddev(t11.c1), array_agg(t11.c4 order by t11.c4), bit_and(t13.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1+t13.c1<100000), sqrt(abs(t11.c1*2)), upper(t13.c8) FROM tmp_t11 t11 FULL JOIN t13 ON t11.c1=t13.c1 GROUP BY t11.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 247:
SELECT DISTINCT t11.c1, t13.c2 a1, t11.c6, t13.c10 FROM tmp_t11 t11 FULL JOIN t13 ON t11.c1 < t13.c2 WHERE t11.c4!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 248:
SELECT * FROM tmp_t11 t11 FULL JOIN t13 ON t11.c1=5/t13.c1 ORDER BY t13.c1 LIMIT 20;
-- Testcase 249:
SELECT t11.c1, max(t11.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t11.c14 ORDER BY t11.c14), min(t13.c8) FROM tmp_t11 t11 FULL JOIN t13 ON (t11.c1=t13.c2 OR t13.c2>t11.c12) GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 250:
SELECT count(distinct t11.c2), max(t13.c1), stddev(t11.c1), avg(t13.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 FULL JOIN t13 ON (t11.c1=t13.c1) GROUP BY t11.c3,t13.c1 HAVING -100<sum(t13.c1) OR max(t11.c1) >= avg(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 251:
SELECT DISTINCT t11.c8, t13.c10, t13.c7, t13.c8, t11.c3 FROM tmp_t11 t11 FULL JOIN t13 ON t11.c1=-t13.c1 ORDER BY t11.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 5;
-- Testcase 252:
SELECT * FROM tmp_t11 t11 CROSS JOIN t13 ORDER BY t11.__spd_url,t11.c1,t11.c2,t11.c3,t11.c4,t11.c6,t11.c7,t11.c8,t11.c9,t11.c11,t11.c12,t11.c13,t11.c14,t11.c15,t13.* LIMIT 20 OFFSET 5;
-- Testcase 253:
SELECT t11.c9, t13.c2, t11.c11, t13.c21, t11.c3, t13.c8 FROM tmp_t11 t11 CROSS JOIN t13 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 254:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t11.c2), stddev(t11.c1), array_agg(t11.c4 order by t11.c4), bit_and(t13.c4), bit_or(t11.c3), bool_and(t11.c4), bool_or(t11.c4), string_agg(t11.c7, ';' order by t11.c7), every(t11.c1+t13.c1<100000), sqrt(abs(t11.c1*2)), upper(t13.c8) FROM tmp_t11 t11 CROSS JOIN t13 GROUP BY t11.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 255:
SELECT DISTINCT t11.c1, t13.c2 a1, t11.c6, t13.c10 FROM tmp_t11 t11 CROSS JOIN t13 WHERE t11.c4!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 256:
SELECT * FROM tmp_t11 t11 CROSS JOIN t13 WHERE t11.c1=5/t13.c1 ORDER BY t13.c1 LIMIT 20;
-- Testcase 257:
SELECT t11.c1, max(t11.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t11.c14 ORDER BY t11.c14), min(t13.c8) FROM tmp_t11 t11 CROSS JOIN t13 GROUP BY t11.c1 HAVING t11.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 258:
SELECT count(distinct t11.c2), max(t13.c1), stddev(t11.c1), avg(t13.c2), sum(t11.c12 ORDER BY t11.c12), min(t11.c14) FROM tmp_t11 t11 CROSS JOIN t13 GROUP BY t11.c3,t13.c1 HAVING -100<sum(t13.c1) OR max(t11.c1) >= avg(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 259:
SELECT DISTINCT t11.c8, t13.c10, t13.c7, t13.c8, t11.c3 FROM tmp_t11 t11 CROSS JOIN t13 ORDER BY t11.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 5;
-- Testcase 260:
SELECT * FROM t1 JOIN t13 ON (t1.c1=t13.c2/10 AND t13.c2>0) ORDER BY t1.*,t13.* LIMIT 40 OFFSET 5;
-- Testcase 261:
SELECT t1.c9, t13.c2, t1.c11, t13.c21, t1.c3, t13.c8 FROM t1 JOIN t13 ON t1.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 262:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t1.c2), stddev(t1.c1), array_agg(t1.c4 order by t1.c4), bit_and(t13.c4), bit_or(t1.c3), bool_and(t1.c5), bool_or(not t1.c5), string_agg(t1.c2, ';' order by t1.c2), every(t1.c1+t13.c1<100000), sqrt(abs(t1.c1*2)), upper(t13.c8) FROM t1 JOIN t13 ON t1.c1=t13.c1+2 GROUP BY t1.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 263:
SELECT DISTINCT t1.c1, t13.c2 a1, t1.c6, t13.c10 FROM t1 JOIN t13 ON t1.c1 < t13.c2 WHERE t1.c5!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 264:
SELECT * FROM t1 JOIN t13 ON t1.c1=5/t13.c1 WHERE 5/t1.c1>0;
-- Testcase 265:
SELECT DISTINCT t13.c1, t1.c14, t1.c6, t13.c2 FROM t1 JOIN t13 ON t1.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 266:
SELECT t1.c1, max(t1.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t1.c7 ORDER BY t1.c7), min(t13.c8) FROM t1 JOIN t13 ON (t1.c1=t13.c2 OR t13.c2>t1.c8) GROUP BY t1.c1 HAVING count(t13.c1)!=t1.c1 AND t1.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 267:
SELECT count(distinct t1.c2), max(t13.c1), stddev(t1.c1), avg(t13.c2), sum(t1.c8), min(t1.c14) FROM t1 JOIN t13 ON (t1.c1=t13.c1 OR t1.c5=(t13.c1>t13.c2)) GROUP BY t1.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 268:
SELECT DISTINCT t1.c8, t13.c10, t13.c7, t13.c8, t1.c3 FROM t1 JOIN t13 ON t1.c1!=t13.c1 ORDER BY t1.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 269:
SELECT * FROM t1 LEFT JOIN t13 ON (t1.c1=t13.c2/10 AND t13.c2>0) ORDER BY t1.*,t13.* LIMIT 40 OFFSET 5;
-- Testcase 270:
SELECT t1.c9, t13.c2, t1.c11, t13.c21, t1.c3, t13.c8 FROM t1 LEFT JOIN t13 ON t1.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 271:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t1.c2), stddev(t1.c1), array_agg(t1.c4 order by t1.c4), bit_and(t13.c4), bit_or(t1.c3), bool_and(t1.c5), bool_or(not t1.c5), string_agg(t1.c2, ';' order by t1.c2), every(t1.c1+t13.c1<100000), sqrt(abs(t1.c1*2)), upper(t13.c8) FROM t1 LEFT JOIN t13 ON t1.c1=t13.c1+2 GROUP BY t1.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 272:
SELECT DISTINCT t1.c1, t13.c2 a1, t1.c6, t13.c10 FROM t1 LEFT JOIN t13 ON t1.c1 < t13.c2 WHERE t1.c5!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 273:
SELECT * FROM t1 LEFT JOIN t13 ON t1.c1=5/t13.c1 WHERE 5/t1.c1>0;
-- Testcase 274:
SELECT DISTINCT t13.c1, t1.c14, t1.c6, t13.c2 FROM t1 LEFT JOIN t13 ON t1.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 275:
SELECT t1.c1, max(t1.c12), avg(t13.c17)-50, sum(t1.c7), min(t13.c8) FROM t1 LEFT JOIN t13 ON (t1.c1=t13.c2 OR t13.c2>t1.c8) GROUP BY t1.c1 HAVING count(t13.c1)!=t1.c1 AND t1.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 276:
SELECT count(distinct t1.c2), max(t13.c1), stddev(t1.c1), avg(t13.c2), sum(t1.c8), min(t1.c14) FROM t1 LEFT JOIN t13 ON (t1.c1=t13.c1 OR t1.c5=(t13.c1>t13.c2)) GROUP BY t1.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 277:
SELECT DISTINCT t1.c8, t13.c10, t13.c7, t13.c8, t1.c3 FROM t1 LEFT JOIN t13 ON t1.c1!=t13.c1 ORDER BY t1.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 278:
SELECT * FROM t1 RIGHT JOIN t13 ON (t1.c1=t13.c2/10 AND t13.c2>0) ORDER BY t1.*,t13.* LIMIT 40 OFFSET 5;
-- Testcase 279:
SELECT t1.c9, t13.c2, t1.c11, t13.c21, t1.c3, t13.c8 FROM t1 RIGHT JOIN t13 ON t1.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 280:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t1.c2), stddev(t1.c1), array_agg(t1.c4 order by t1.c4), bit_and(t13.c4), bit_or(t1.c3), bool_and(t1.c5), bool_or(not t1.c5), string_agg(t1.c2, ';' order by t1.c2), every(t1.c1+t13.c1<100000), sqrt(abs(t1.c1*2)), upper(t13.c8) FROM t1 RIGHT JOIN t13 ON t1.c1=t13.c1+2 GROUP BY t1.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 281:
SELECT DISTINCT t1.c1, t13.c2 a1, t1.c6, t13.c10 FROM t1 RIGHT JOIN t13 ON t1.c1 < t13.c2 WHERE t1.c5!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 282:
SELECT * FROM t1 RIGHT JOIN t13 ON t1.c1=5/t13.c1 WHERE 5/t1.c1>0;
-- Testcase 283:
SELECT DISTINCT t13.c1, t1.c14, t1.c6, t13.c2 FROM t1 RIGHT JOIN t13 ON t1.c1 BETWEEN -30 AND 100 AND t13.c1 = ANY(ARRAY[0,1,-1,2,3,4,30,50]) AND t13.c8 LIKE '%a%' ORDER BY 1,2,3,4 LIMIT 60;
-- Testcase 284:
SELECT t1.c1, max(t1.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t1.c7 ORDER BY t1.c7), min(t13.c8) FROM t1 RIGHT JOIN t13 ON (t1.c1=t13.c2 OR t13.c2>t1.c8) GROUP BY t1.c1 HAVING count(t13.c1)!=t1.c1 AND t1.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 285:
SELECT count(distinct t1.c2), max(t13.c1), stddev(t1.c1), avg(t13.c2), sum(t1.c8), min(t1.c14) FROM t1 RIGHT JOIN t13 ON (t1.c1=t13.c1 OR t1.c5=(t13.c1>t13.c2)) GROUP BY t1.c3,t13.c1 HAVING 100<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 286:
SELECT DISTINCT t1.c8, t13.c10, t13.c7, t13.c8, t1.c3 FROM t1 RIGHT JOIN t13 ON t1.c1!=t13.c1 ORDER BY t1.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 20;
-- Testcase 287:
SELECT * FROM t1 FULL JOIN t13 ON (t1.c1=t13.c2/10 AND t13.c2>0) ORDER BY t1.*,t13.* LIMIT 40 OFFSET 5;
-- Testcase 288:
SELECT t1.c9, t13.c2, t1.c11, t13.c21, t1.c3, t13.c8 FROM t1 FULL JOIN t13 ON t1.c1=-t13.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 289:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t1.c2), stddev(t1.c1), array_agg(t1.c4 order by t1.c4), bit_and(t13.c4), bit_or(t1.c3), bool_and(t1.c5), bool_or(not t1.c5), string_agg(t1.c2, ';' order by t1.c2), every(t1.c1+t13.c1<100000), sqrt(abs(t1.c1*2)), upper(t13.c8) FROM t1 FULL JOIN t13 ON t1.c1=t13.c1+2 GROUP BY t1.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 290:
SELECT DISTINCT t1.c1, t13.c2 a1, t1.c6, t13.c10 FROM t1 FULL JOIN t13 ON t1.c1 < t13.c2 WHERE t1.c5!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 291:
SELECT * FROM t1 FULL JOIN t13 ON t1.c1=5/t13.c1 WHERE 5/t1.c1>0;
-- Testcase 292:
SELECT t1.c1, max(t1.c12), avg(t13.c17)-50, sum(t1.c7), min(t13.c8) FROM t1 FULL JOIN t13 ON (t1.c1=t13.c2 OR t13.c2>t1.c8) GROUP BY t1.c1 HAVING count(t13.c1)!=t1.c1 AND t1.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 293:
SELECT count(distinct t1.c2), max(t13.c1), stddev(t1.c1), avg(t13.c2), sum(t1.c8), min(t1.c14) FROM t1 FULL JOIN t13 ON (t1.c1=t13.c1 AND true=(t13.c1!=t13.c2)) GROUP BY t1.c3,t13.c1 HAVING -1000<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 294:
SELECT DISTINCT t1.c8, t13.c10, t13.c7, t13.c8, t1.c3 FROM t1 FULL JOIN t13 ON t1.c1=t13.c1 ORDER BY t1.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 5;
-- Testcase 295:
SELECT * FROM t1 CROSS JOIN t13 ORDER BY t1.*,t13.* LIMIT 40 OFFSET 5;
-- Testcase 296:
SELECT t1.c9, t13.c2, t1.c11, t13.c21, t1.c3, t13.c8 FROM t1 CROSS JOIN t13 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 297:
SELECT max(t13.c3), min(t13.c8), sum(t13.c1), avg(t13.c7), count(t1.c2), stddev(t1.c1), array_agg(t1.c4 order by t1.c4), bit_and(t13.c4), bit_or(t1.c3), bool_and(t1.c5), bool_or(not t1.c5), string_agg(t1.c2, ';' order by t1.c2), every(t1.c1+t13.c1<100000), sqrt(abs(t1.c1*2)), upper(t13.c8) FROM t1 CROSS JOIN t13 GROUP BY t1.c1, t13.c8 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;
-- Testcase 298:
SELECT DISTINCT t1.c1, t13.c2 a1, t1.c6, t13.c10 FROM t1 CROSS JOIN t13 WHERE t1.c5!=true AND t13.c5>2 AND t13.c3>=-10000 AND t13.c5<=1000 ORDER BY 1,2,3,4 LIMIT 40 OFFSET 5;
-- Testcase 299:
SELECT * FROM t1 CROSS JOIN t13 WHERE t1.c1=5/t13.c1 ORDER BY t13.c1;
-- Testcase 300:
SELECT t1.c1, max(t1.c12), avg(t13.c17 ORDER BY t13.c17)-50, sum(t1.c7), min(t13.c8) FROM t1 CROSS JOIN t13 GROUP BY t1.c1 HAVING count(t13.c1)!=t1.c1 AND t1.c1<10 ORDER BY 1,2,3,4,5;
-- Testcase 301:
SELECT count(distinct t1.c2), max(t13.c1), stddev(t1.c1), avg(t13.c2), sum(t1.c8), min(t1.c14) FROM t1 CROSS JOIN t13 GROUP BY t1.c3,t13.c1 HAVING -1000<sum(t13.c1) ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 302:
SELECT DISTINCT t1.c8, t13.c10, t13.c7, t13.c8, t1.c3 FROM t1 CROSS JOIN t13 ORDER BY t1.c8 DESC, t13.c10, 3, 4 DESC, 5 LIMIT 40 OFFSET 5;
-- Testcase 303:
SELECT t1.c1,t3.c1,t5.c1 FROM t1 JOIN t3 ON (t1.c1=1234) JOIN t5 ON (t5.c1=1234) JOIN t7 ON (t7.c3=t5.c1) JOIN t9 ON (t9.c1=t1.c1) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1);
-- Testcase 304:
SELECT DISTINCT t1.c1,t3.c1,t5.c1 FROM t1 JOIN t3 ON (t1.c1=1) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3=-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 305:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 JOIN t3 ON (t1.c1=2) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3=-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 306:
SELECT max(t1.c1),min(t3.c1),avg(t7.c3) FROM t1 JOIN t3 ON (t1.c1<t3.c1) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3<t7.c4) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 307:
SELECT array_agg(distinct t1.c2 order by t1.c2),bit_and(t3.c2),bit_or(t7.c3),bool_and(t9.c1<t7.c3), bool_or(t13.c1<t13.c2) FROM t1 JOIN t3 ON (t1.c1=1) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3=1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3,4,5 LIMIT 50;
-- Testcase 308:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 JOIN t3 ON (5/t1.c1=1) JOIN t5 ON (10/t5.c2=5) JOIN t7 ON (6/t7.c3=-1) JOIN t9 ON (1/t9.c1=-5) JOIN tmp_t11 ON (10/tmp_t11.c1=0) JOIN t13 ON (5/t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 309:
SELECT max(t3.c2), min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 JOIN t3 ON (t1.c1<1) JOIN t5 ON (t5.c2<0) JOIN t7 ON (t7.c3>-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 310:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 JOIN t3 ON (t1.c1<1) JOIN t5 ON (t5.c2<0) JOIN t7 ON (t7.c3>-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 HAVING (t5.c1!=3) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 311:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 JOIN t3 ON (t1.c1<1) JOIN t5 ON (t5.c2<0) JOIN t7 ON (t7.c3>-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 312:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 JOIN t3 ON (t1.c1<1) JOIN t5 ON (t5.c2<0) JOIN t7 ON (t7.c3>-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 HAVING (t5.c1 < sum(t7.c3)) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 313:
SELECT array_agg(distinct t7.c3 order by t7.c3), count(t13.c2) FROM t1 JOIN t3 ON (t3.c2=0) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3>t1.c1) JOIN t9 ON (t9.c1>-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=0) GROUP BY t9.c1 ORDER BY 1,2 LIMIT 50;
-- Testcase 314:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 JOIN t3 ON (1<(SELECT max(t1.c1) FROM t1)) JOIN t5 ON (t5.c2=0) JOIN t7 ON (t7.c3=-1) JOIN t9 ON (t9.c1=-5) JOIN tmp_t11 ON (tmp_t11.c1=0) JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 315:
SELECT t1.c1,t3.c1,t5.c1 FROM t1 LEFT JOIN t3 ON (t1.c1=1234) LEFT JOIN t5 ON (t5.c1=1234) LEFT JOIN t7 ON (t7.c3=t5.c1) LEFT JOIN t9 ON (t9.c1=t1.c1) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3;
-- Testcase 316:
SELECT DISTINCT t1.c1,t3.c1,t5.c1 FROM t1 LEFT JOIN t3 ON (t1.c1=1) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3=-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 317:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 LEFT JOIN t3 ON (t1.c1=2) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3=-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 318:
SELECT max(t1.c1),min(t3.c1),avg(t7.c3) FROM t1 LEFT JOIN t3 ON (t1.c1<t3.c1) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3<t7.c4) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 319:
SELECT array_agg(distinct t1.c2 order by t1.c2),bit_and(t3.c2),bit_or(t7.c3),bool_and(t9.c1<t7.c3), bool_or(t13.c1<t13.c2) FROM t1 LEFT JOIN t3 ON (t1.c1=1) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3=1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3,4,5 LIMIT 50;
-- Testcase 320:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 LEFT JOIN t3 ON (5/t1.c1=1) LEFT JOIN t5 ON (10/t5.c2=5) LEFT JOIN t7 ON (6/t7.c3=-1) LEFT JOIN t9 ON (1/t9.c1=-5) LEFT JOIN tmp_t11 ON (10/tmp_t11.c1=0) LEFT JOIN t13 ON (5/t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 321:
SELECT max(t3.c2), min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 LEFT JOIN t3 ON (t1.c1<1) LEFT JOIN t5 ON (t5.c2<0) LEFT JOIN t7 ON (t7.c3>-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 322:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 LEFT JOIN t3 ON (t1.c1<1) LEFT JOIN t5 ON (t5.c2<0) LEFT JOIN t7 ON (t7.c3>-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 HAVING (t5.c1!=3) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 323:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 LEFT JOIN t3 ON (t1.c1<1) LEFT JOIN t5 ON (t5.c2<0) LEFT JOIN t7 ON (t7.c3>-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 324:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 LEFT JOIN t3 ON (t1.c1<1) LEFT JOIN t5 ON (t5.c2<0) LEFT JOIN t7 ON (t7.c3>-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 HAVING (t5.c1 < sum(t7.c3)) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 325:
SELECT array_agg(distinct t7.c3 order by t7.c3), count(t13.c2) FROM t1 LEFT JOIN t3 ON (t3.c2=0) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3>t1.c1) LEFT JOIN t9 ON (t9.c1>-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=0) GROUP BY t9.c1 ORDER BY 1,2 LIMIT 50;
-- Testcase 326:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 LEFT JOIN t3 ON (1<(SELECT max(t1.c1) FROM t1)) LEFT JOIN t5 ON (t5.c2=0) LEFT JOIN t7 ON (t7.c3=-1) LEFT JOIN t9 ON (t9.c1=-5) LEFT JOIN tmp_t11 ON (tmp_t11.c1=0) LEFT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 327:
SELECT t1.c1,t3.c1,t5.c1 FROM t1 RIGHT JOIN t3 ON (t1.c1=1234) RIGHT JOIN t5 ON (t5.c1=1234) RIGHT JOIN t7 ON (t7.c3=t5.c1) RIGHT JOIN t9 ON (t9.c1=t1.c1) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3;
-- Testcase 328:
SELECT DISTINCT t1.c1,t3.c1,t5.c1 FROM t1 RIGHT JOIN t3 ON (t1.c1=1) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3=-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 329:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 RIGHT JOIN t3 ON (t1.c1=2) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3=-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 330:
SELECT max(t1.c1),min(t3.c1),avg(t7.c3) FROM t1 RIGHT JOIN t3 ON (t1.c1<t3.c1) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3<t7.c4) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 331:
SELECT array_agg(distinct t1.c2 order by t1.c2),bit_and(t3.c2),bit_or(t7.c3),bool_and(t9.c1<t7.c3), bool_or(t13.c1<t13.c2) FROM t1 RIGHT JOIN t3 ON (t1.c1=1) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3=1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=1) ORDER BY 1,2,3,4,5 LIMIT 50;
-- Testcase 332:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 RIGHT JOIN t3 ON (5/t1.c1=1) RIGHT JOIN t5 ON (10/t5.c2=5) RIGHT JOIN t7 ON (6/t7.c3=-1) RIGHT JOIN t9 ON (1/t9.c1=-5) RIGHT JOIN tmp_t11 ON (10/tmp_t11.c1=0) RIGHT JOIN t13 ON (5/t13.c1!=t5.c1) ORDER BY 1,2,3 LIMIT 50;
-- Testcase 333:
SELECT max(t3.c2), min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 RIGHT JOIN t3 ON (t1.c1<1) RIGHT JOIN t5 ON (t5.c2<0) RIGHT JOIN t7 ON (t7.c3>-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 ORDER BY 1,2,3,4,5,6 LIMIT 50;
-- Testcase 334:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 RIGHT JOIN t3 ON (t1.c1<1) RIGHT JOIN t5 ON (t5.c2<0) RIGHT JOIN t7 ON (t7.c3>-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 HAVING (t5.c1!=3) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 335:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 RIGHT JOIN t3 ON (t1.c1<1) RIGHT JOIN t5 ON (t5.c2<0) RIGHT JOIN t7 ON (t7.c3>-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 336:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 RIGHT JOIN t3 ON (t1.c1<1) RIGHT JOIN t5 ON (t5.c2<0) RIGHT JOIN t7 ON (t7.c3>-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 HAVING (t5.c1 < sum(t7.c3)) ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 337:
SELECT array_agg(distinct t7.c3 order by t7.c3), count(t13.c2) FROM t1 RIGHT JOIN t3 ON (t3.c2=0) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3>t1.c1) RIGHT JOIN t9 ON (t9.c1>-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=0) GROUP BY t9.c1 ORDER BY 1,2 LIMIT 50;
-- Testcase 338:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 RIGHT JOIN t3 ON (1<(SELECT max(t1.c1) FROM t1)) RIGHT JOIN t5 ON (t5.c2=0) RIGHT JOIN t7 ON (t7.c3=-1) RIGHT JOIN t9 ON (t9.c1=-5) RIGHT JOIN tmp_t11 ON (tmp_t11.c1=0) RIGHT JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1,t7.c3 ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 339:
SELECT t1.c1,t3.c1,t5.c1 FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3 LIMIT 100;
-- Testcase 340:
SELECT DISTINCT t1.c1,t3.c1,t5.c2 FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) ORDER BY 1,2,3 LIMIT 100;
-- Testcase 341:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 342:
SELECT max(t1.c1),min(t3.c1),avg(t7.c3) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 343:
SELECT array_agg(distinct t1.c2 order by t1.c2),bit_and(t3.c2),bit_or(t7.c3),bool_and(t9.c1<t7.c3), bool_or(t13.c1<t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 344:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 FULL JOIN t3 ON (t1.c1=10/t3.c1) FULL JOIN t5 ON (10/t5.c1=t3.c1) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 345:
SELECT max(t3.c2), min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 346:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) GROUP BY t5.c1 HAVING (min(t5.c1+10)>0) ORDER BY 1,2,3,4,5,6 LIMIT 100;
-- Testcase 347:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) GROUP BY t9.c1, t1.c1 ORDER BY 1,2,3,4,5,6,7 LIMIT 100;
-- Testcase 348:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) GROUP BY t9.c1, t1.c1 HAVING(max(t9.c1)<sum(t1.c1)) ORDER BY 1,2,3,4,5,6,7 LIMIT 100;
-- Testcase 349:
SELECT array_agg(distinct t7.c3 order by t7.c3 DESC), count(t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND t1.c1=1) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 350:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 FULL JOIN t3 ON (t1.c1=t3.c1 AND 5> (SELECT min(t1.c1)-100 FROM t1)) FULL JOIN t5 ON (t5.c1=t3.c1 AND t5.c1=0) FULL JOIN t7 ON (t7.c3=t5.c1) FULL JOIN t9 ON (t9.c1=t1.c1) FULL JOIN tmp_t11 ON (tmp_t11.c1=t1.c1 AND t1.c1=1) FULL JOIN t13 ON (t13.c1=t3.c1) LIMIT 100;
-- Testcase 351:
SELECT t1.c1,t3.c1,t5.c1 FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t13.c1=2 AND t5.c1=1 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 LIMIT 100;
-- Testcase 352:
SELECT DISTINCT t1.c1,t3.c1,t5.c2 FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 ORDER BY 1,2,3 LIMIT 100;
-- Testcase 353:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 LIMIT 100;
-- Testcase 354:
SELECT max(t1.c1),min(t3.c1),avg(t7.c3) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 LIMIT 100;
-- Testcase 355:
SELECT array_agg(distinct t1.c2 order by t1.c2),bit_and(t3.c2),bit_or(t7.c3),bool_and(t9.c1<t7.c3), bool_or(t13.c1<t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 LIMIT 100;
-- Testcase 356:
SELECT sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE 5/t1.c1=10 AND t3.c1/t5.c4=3 LIMIT 100;
-- Testcase 357:
SELECT max(t3.c2), min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3=2 AND t9.c1>0 AND tmp_t11.c1=1 AND t13.c1<0 GROUP BY t13.c3 LIMIT 100;
-- Testcase 358:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1>0 AND t5.c4>3 AND t7.c3=2 AND t9.c1<0 AND tmp_t11.c1%2=1 AND t13.c1>0 GROUP BY t13.c1 HAVING (max(t13.c1) > -10000) ORDER BY 1,2,3,4,5,6,7 LIMIT 100;
-- Testcase 359:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1>0 AND t5.c4=3 AND t7.c3=2 AND t9.c1>10 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c6, t9.c2 ORDER BY 1,2,3,4,5,6,7 LIMIT 100;
-- Testcase 360:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1>0 AND t5.c4=3 AND t7.c3=2 AND t9.c1<0 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c6, t9.c2 HAVING ( max(t1.c6)>avg(t9.c2)+100 ) ORDER BY 1,2,3,4,5,6,7 LIMIT 100;
-- Testcase 361:
SELECT array_agg(distinct t7.c3 order by t7.c3 DESC), count(t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1=0 AND t5.c4=3 AND t7.c3>2 AND t9.c1=0 AND tmp_t11.c1=1 AND t13.c1=0 LIMIT 100;
-- Testcase 362:
SELECT max(t3.c2)-10, min(t7.c4), stddev(t9.c2),sum(t1.c1),count(t3.c1),avg(t5.c1), count(t13.c2) FROM t1 CROSS JOIN t3 CROSS JOIN t5 CROSS JOIN t7 CROSS JOIN t9 CROSS JOIN tmp_t11 CROSS JOIN t13 WHERE t1.c1<(SELECT max(t9.c1)+10 FROM t9 WHERE t9.c2!=0) AND t5.c4=3 AND t7.c3=2 AND t9.c1=0 AND tmp_t11.c1<1 AND t13.c1>0 LIMIT 100;
