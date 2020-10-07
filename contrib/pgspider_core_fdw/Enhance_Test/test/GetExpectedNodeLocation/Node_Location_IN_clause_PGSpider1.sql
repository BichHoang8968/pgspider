------------------------------Node_Location_IN_clause_PGSpider1-----------------------------
-- Testcase 1:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%']) ORDER BY t7.* ASC;
-- Testcase 2:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3%']) ORDER BY t7.* ASC;
-- Testcase 3:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) ORDER BY t7.* ASC;
-- Testcase 4:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%', '/pgspider2/tinybrace1%', '/pgspider2/grid1%', '/pgspider2/influx2%', '/pgspider3/file1%', '/pgspider3/sqlite1%']) ORDER BY t7.* ASC;
-- Testcase 5:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/grid1%', '/pgspider2/influx1%', '/pgspider3/postgres1%', '/pgspider3/file1%', '/pgspider3/sqlite1%', '/pgspider3/sqlite2%']) ORDER BY t7.* ASC;
-- Testcase 6:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%']) ORDER BY t7.* ASC;
-- Testcase 7:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx2%']) ORDER BY t7.* ASC;
-- Testcase 8:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%', '/pgspider2/influx2%']) ORDER BY t7.* ASC;
-- Testcase 9:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%']) ORDER BY t7.* ASC;
-- Testcase 10:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post2%']) ORDER BY t7.* ASC;
-- Testcase 11:
SELECT * FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%', '/pgspider3/post2%']) ORDER BY t7.* ASC;
-- Testcase 12:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 13:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 14:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 15:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%', '/pgspider2/tinybrace1%', '/pgspider2/grid1%', '/pgspider2/influx2%', '/pgspider3/file1%', '/pgspider3/sqlite1%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 16:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/grid1%', '/pgspider2/influx1%', '/pgspider3/postgres1%', '/pgspider3/file1%', '/pgspider3/sqlite1%', '/pgspider3/sqlite2%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 17:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 18:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx2%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 19:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%', '/pgspider2/influx2%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 20:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 21:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post2%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 22:
SELECT * FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%', '/pgspider3/post2%']) ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 23:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%']) ORDER BY tmp_t15.* ASC;
-- Testcase 24:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3%']) ORDER BY tmp_t15.* ASC;
-- Testcase 25:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) ORDER BY tmp_t15.* ASC;
-- Testcase 26:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%', '/pgspider2/tinybrace1%', '/pgspider2/grid1%', '/pgspider2/influx2%', '/pgspider3/file1%', '/pgspider3/sqlite1%']) ORDER BY tmp_t15.* ASC;
-- Testcase 27:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/grid1%', '/pgspider2/influx1%', '/pgspider3/postgres1%', '/pgspider3/file1%', '/pgspider3/sqlite1%', '/pgspider3/sqlite2%']) ORDER BY tmp_t15.* ASC;
-- Testcase 28:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%']) ORDER BY tmp_t15.* ASC;
-- Testcase 29:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx2%']) ORDER BY tmp_t15.* ASC;
-- Testcase 30:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/influx1%', '/pgspider2/influx2%']) ORDER BY tmp_t15.* ASC;
-- Testcase 31:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%']) ORDER BY tmp_t15.* ASC;
-- Testcase 32:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post2%']) ORDER BY tmp_t15.* ASC;
-- Testcase 33:
SELECT * FROM tmp_t15 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%', '/pgspider3/post2%']) ORDER BY tmp_t15.* ASC;
----------ComplexCommand-----------------------------
-- Testcase 1:
SELECT DISTINCT t13.c1, bit_and(t13.c1), stddev(t13.c4) - 10, array_agg(t13.c1), count(t13.c8), 1000 - t13.c4 * (random() <= 1)::int  FROM (SELECT * FROM (SELECT * FROM t13 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3%']) AND t13.c1!= t13.c2) AS t13) AS t13 WHERE  t13.c2 >0 GROUP BY c1, c4 ORDER BY 1 ASC, 2 DESC LIMIT 50;
-- Testcase 2:
SELECT max(t5.c1), max(t5.c2)+1, max(t5.c3)+2, max(t5.c4)*3 FROM t5 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) AND t5.c1 <> ( SELECT max(t7.c3) FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) AND t7.c3 != t7.c4) GROUP BY t5.c1, t5.c17, t5.c14 HAVING t5.c1 != 3 OR SUM(t5.c17) <> 0 OR t5.c17 != 121234 ORDER BY 1, 2, 3, 4;
-- Testcase 3:
SELECT SUM(t3.c4), count(ALL t3.c1) FROM (SELECT * FROM (SELECT * FROM t13 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3%']) ORDER BY 1 DESC) AS t3 WHERE true) AS t3 WHERE t3.c1 <= ALL (SELECT max(t3.c2) FROM t3) GROUP BY t3.c1 LIMIT 1000;
-- Testcase 4:
SELECT DISTINCT c1 FROM griddb_max_range WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/grid1/%']) AND 3 >= (SELECT count(DISTINCT c1) FROM griddb_max_range WHERE c1 <= 1000 ORDER BY 1 DESC) ORDER BY c1 DESC;
-- Testcase 5:
SELECT * FROM (SELECT * FROM (SELECT count(*) FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/%', '/pgspider3%']) AND c29>=0 OR c32 = 'abc123456789')  AS t9 WHERE true ) AS t9  FULL JOIN (SELECT c4 FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/%']) AND c3 between -50 AND 60)  AS t7 ON (TRUE) ORDER BY 1, 2 OFFSET 10 LIMIT 10;
-- Testcase 6:
SELECT t13.c1, t5.c1 FROM  t13 JOIN t5 ON (t13.c1 != t5.c1 AND t13.__spd_url LIKE ANY (ARRAY['/pgspider2/tinybrace1%', '/pgspider3/sqlite1%'])) JOIN (SELECT count (*) FROM t3) AS t3 ON (t13.c1 != t5.c1) ORDER BY 1, 2 OFFSET 10 LIMIT 10;
-- Testcase 7:
SELECT t13.c1, t3.c1, t5.c1 FROM t13 INNER JOIN t3 ON (t13.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3/sqlite1%']) AND t3.__spd_url LIKE ANY (ARRAY['/pgspider2%']) AND t13.c1 = t3.c1 + 1 AND t13.c1 between -50 AND 60) FULL JOIN t5 ON (t3.c1 = t5.c1) ORDER BY t13.c1, t3.c1, t5.c1 LIMIT 10;
-- Testcase 8:
SELECT * FROM (SELECT t13.c1 FROM t13 JOIN t5 ON (t13.__spd_url LIKE ANY (ARRAY['/pgspider2/tinybrace1%', '/pgspider3%']) AND t5.__spd_url LIKE ANY (ARRAY['/pgspider2/tinybrace1%']) AND t13.c1 = t5.c1) ) AS t13 UNION SELECT t13.c1 FROM t13 ORDER BY 1 OFFSET 100 LIMIT 10;
-- Testcase 9:
SELECT count(*) FROM (SELECT c15, count(c1) FROM t9 WHERE __spd_url LIKE ANY (ARRAY['/pgspider3/post1%', '/pgspider/post2%']) GROUP BY t9.c15, SQRT(c2) HAVING (AVG(c1) / AVG(c1)) * random() <= 1 AND AVG(c1) = 500) AS t9;
-- Testcase 10:
SELECT array_agg(distinct (t13.c1)%5 ORDER BY (t13.c1)%5) FROM t13 FULL JOIN t7 on (t13.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3/sqlite1%', '/pgspider3/sqlite2%']) AND t7.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t13.c1 = t7.c3) WHERE t13.c1 < 20 or (t13.c1 is null AND t7.c3 < 5) GROUP BY (t7.c3)%3 ORDER BY 1;
-- Testcase 11:
SELECT SUM(c1%3), SUM(distinct c1%3 ORDER BY c1%3) filter (where c1%3 < 2), c2 FROM t5 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3/sqlite1%', '/pgspider3/sqlite2%']) AND c14 NOT IN ('0123456789', '敷ヘカウ告政ヨハツヤ消70者32精楽ざ') GROUP BY c2 ORDER BY 1, 2, 3;
-- Testcase 12:
SELECT count(*), SUM(t13.c1), AVG(t5.c1) FROM (SELECT c1 FROM t13 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) AND c1 between -43 AND 68) t13 FULL JOIN (SELECT c1 FROM t5 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) AND c1 between -50 AND 60) AS t5 ON (t13.c1 = t5.c1);
-- Testcase 13:
SELECT t13.c1, t3.c3 FROM (SELECT * FROM t13 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%'])) t13 LEFT JOIN (SELECT * FROM t3 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND c3 < 10) t3 ON (t13.c1 = t3.c3) WHERE t13.c1 < 10 ORDER BY 1,2 ;
-- Testcase 14:
SELECT t13.c1, t3.c3, t5.c5 FROM (SELECT * FROM t13 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2/mysql1%', '/pgspider2/mysql2%', '/pgspider2%', '/pgspider3%'])) t13 INNER JOIN t5 ON (t13.c1 !=  1 AND t13.c1 between 50 AND 60) FULL JOIN t3 ON (t3.c3 = t5.c5) ORDER BY t13.c1, t3.c3, t5.c5 LIMIT 10;
-- Testcase 15:
SELECT count(t5.c5) FROM (SELECT t5.c5, SUM(t5.c1) FROM t5 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) GROUP BY t5.c5, SQRT(ABS(t5.c1)) ORDER BY 1, 2) AS t5 WHERE t5.c5 <>( SELECT max(t7.c3) FROM t7 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t7.c3!=t5.c5) HAVING (AVG(t5.c5) / AVG(t5.c5)) * random() <= 10 AND AVG(t5.c5) > 10;
-- Testcase 16:
SELECT c.c2, COUNT(*),( SELECT t13.c24 FROM tmp_t11 INNER JOIN t3 ON (tmp_t11.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t3.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t3.c6=tmp_t11.c12) INNER JOIN t13 ON t13.c20=t3.c6 INNER JOIN t1 ON t1.c1=t3.c4 WHERE t3.c7=c.c8 ORDER BY tmp_t11.c28 DESC, t13.c21 ASC LIMIT 10) AS t13_ FROM t1 c INNER JOIN t3 ON t3.c6=c.c7 INNER JOIN tmp_t11 ON tmp_t11.c22=t3.c10 GROUP BY c.c2, c.c7, c.c8 ORDER BY 1 DESC;
-- Testcase 17:
SELECT t.c1, t.c2, t.c3, t.c4, q.NumEntries FROM (SELECT * FROM t1 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%'])) t INNER JOIN (SELECT c1, c2, c3, COUNT(*) AS NumEntries FROM t1 GROUP BY c1, c2, c3 HAVING COUNT(*) > 1)  q ON t.c1 = q.c1 AND t.c2 = q.c2 AND t.c3 = q.c3 ORDER BY t.c1, t.c2, t.c3, t.c4;
-- Testcase 18:
SELECT * FROM t1 LEFT OUTER JOIN t7 ON (t1.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t7.__spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND t1.c5 = t7.c5) WHERE c1 IS NOT NULL UNION SELECT * FROM t1 RIGHT OUTER JOIN t7 ON t1.c5 = t7.c5 WHERE t1.c1 IS NOT NULL ORDER BY 1, 2, time;
-- Testcase 19:
SELECT c5, c6, AVG(c1) FROM t1 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%']) GROUP BY c5, c6 HAVING AVG(c1) > (SELECT AVG(c1) FROM t1 WHERE t1.c7 >= t1.c8);
-- Testcase 20:
SELECT c1, c2, c3, MIN(c7) FROM t1 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND c7 != ( SELECT MIN(c12) FROM tmp_t11 WHERE __spd_url LIKE ANY (ARRAY['/pgspider2%', '/pgspider3%']) AND tmp_t11.c4 = t1.c5) GROUP BY c1, c2, c3 HAVING MIN(c7) < 5 ORDER BY 1, 2, 3, 4;
