--Test cases for join multi nodes
--Testcase 1:
EXPLAIN VERBOSE SELECT t1.c1, min(t2.c4) FROM tbl01 t1 FULL JOIN tbl01 t2 USING (c4) WHERE (t1.__spd_url = t2.__spd_url) OR t1.__spd_url != '' GROUP BY t1.c1, t2.c4 LIMIT 10;
--Testcase 2:
SELECT t1.c1, min(t2.c4) FROM tbl01 t1 FULL JOIN tbl01 t2 USING (c4) WHERE (t1.__spd_url = t2.__spd_url) OR t1.__spd_url != '' GROUP BY t1.c1, t2.c4 LIMIT 10;
--Testcase 3:
EXPLAIN VERBOSE SELECT min(t2.c1), t2.c4, max(t2.c5), t2.__spd_url FROM tbl01 t1 RIGHT JOIN tbl01 t2 USING (c1) WHERE t1.c5 < 0 GROUP BY t2.c1, t2.c4, t2.c5, t2.__spd_url LIMIT 5;
--Testcase 4:
SELECT min(t2.c1), t2.c4, max(t2.c5), t2.__spd_url FROM tbl01 t1 RIGHT JOIN tbl01 t2 USING (c1) WHERE t1.c5 < 0 GROUP BY t2.c1, t2.c4, t2.c5, t2.__spd_url LIMIT 5;
--Testcase 5:
EXPLAIN VERBOSE SELECT t1.a1, t1.a4, t2.a5 FROM tbl01 t1(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12) FULL JOIN tbl01 t2(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12) ON t1.a1 = t2.a1 GROUP BY t1.a1, t1.a4, t2.a5 HAVING max(t1.a4) <> max(t2.a5) + 1 LIMIT 10 OFFSET 1;
--Testcase 6:
SELECT t1.a1, t1.a4, t2.a5 FROM tbl01 t1(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12) FULL JOIN tbl01 t2(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12) ON t1.a1 = t2.a1 GROUP BY t1.a1, t1.a4, t2.a5 HAVING max(t1.a4) <> max(t2.a5) + 1 LIMIT 10 OFFSET 1;
--Testcase 7:
EXPLAIN VERBOSE SELECT avg(t1.c4), sum(t1.c5) FROM (tbl01 t1 CROSS JOIN tbl01 t2) GROUP BY  t1.c4, t1.c5, t1.__spd_url, t2.__spd_url ORDER BY t1.c4, t1.c5, t1.__spd_url, t2.__spd_url LIMIT 5;
--Testcase 8:
SELECT avg(t1.c4), sum(t1.c5) FROM (tbl01 t1 CROSS JOIN tbl01 t2) GROUP BY  t1.c4, t1.c5, t1.__spd_url, t2.__spd_url ORDER BY t1.c4, t1.c5, t1.__spd_url, t2.__spd_url LIMIT 5;
--Testcase 9:
EXPLAIN VERBOSE SELECT t1.c1, t1.c2, t1.c4, t1.c5 FROM tbl01 t1 LEFT JOIN tbl01 t2 USING(c4) WHERE t1.c4 > 0 ORDER BY t1.c1, t1.c2, t1.c4, t1.c5 LIMIT 10 OFFSET 0;
--Testcase 10:
SELECT t1.c1, t1.c2, t1.c4, t1.c5 FROM tbl01 t1 LEFT JOIN tbl01 t2 USING(c4) WHERE t1.c4 > 0 ORDER BY t1.c1, t1.c2, t1.c4, t1.c5 LIMIT 10 OFFSET 0;
--Testcase 11:
EXPLAIN VERBOSE SELECT t1.c1, t1.c2 FROM tbl01 AS t1 LEFT JOIN tbl01 t3 ON t1.c1=t3.c1 INNER JOIN tbl01 AS ss1 ON t1.c4 >= ss1.c4 WHERE ss1.c5 > 0 GROUP BY t1.c1, t1.c2 ORDER BY t1.c1 LIMIT 10 OFFSET 0;
--Testcase 12:
SELECT t1.c1, t1.c2 FROM tbl01 AS t1 LEFT JOIN tbl01 t3 ON t1.c1=t3.c1 INNER JOIN tbl01 AS ss1 ON t1.c4 >= ss1.c4 WHERE ss1.c5 > 0 GROUP BY t1.c1, t1.c2 ORDER BY t1.c1 LIMIT 10 OFFSET 0;
--Testcase 13:
EXPLAIN VERBOSE SELECT f1.c1, f1.c2, f2.c1 FROM tbl01 f1 RIGHT JOIN tbl01 f2 ON (f1.c1 = f2.c1 AND f1.c5 IS NOT NULL) GROUP BY f1.__spd_url, f1.c2, f1.c1, f2.c1 ORDER BY f1.c1;
--Testcase 14:
SELECT f1.c1, f1.c2, f2.c1 FROM tbl01 f1 RIGHT JOIN tbl01 f2 ON (f1.c1 = f2.c1 AND f1.c5 IS NOT NULL) GROUP BY f1.__spd_url, f1.c2, f1.c1, f2.c1 ORDER BY f1.c1;
--Testcase 15:
EXPLAIN VERBOSE SELECT x.c1, x.c6, y.c7, max(x.c11), min(y.c8) FROM tbl01 x CROSS JOIN tbl01 y GROUP BY x.c1, x.c6, y.c7, x.c11, y.c8;
--Testcase 16:
SELECT x.c1, x.c6, y.c7, max(x.c11), min(y.c8) FROM tbl01 x CROSS JOIN tbl01 y GROUP BY x.c1, x.c6, y.c7, x.c11, y.c8;
