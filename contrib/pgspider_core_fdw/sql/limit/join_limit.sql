--Pattern 2
--Join  with WHERE __spd_url + ORDER BY
--Testcase 1:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL WHERE J1_TBL.__spd_url != '23afw' ORDER BY 1, 2, 3;
--Testcase 2:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL WHERE J1_TBL.__spd_url != '23afw' ORDER BY 1, 2, 3;
--Testcase 3:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (i) AS x WHERE J1_TBL.__spd_url != 'ffff' ORDER BY J1_TBL.i;
--Testcase 4:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (i) AS x WHERE J1_TBL.__spd_url != 'ffff' ORDER BY J1_TBL.i;
--Testcase 5:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) FULL JOIN J2_TBL t2 (a, b, d) USING (b) WHERE t1.d IS NOT NULL ORDER BY t1.a, t2.a;
--Testcase 6:
SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) FULL JOIN J2_TBL t2 (a, b, d) USING (b) WHERE t1.d IS NOT NULL ORDER BY t1.a, t2.a;
--Join  with WHERE __spd_url + aggregate function + GROUP BY + LIMIT
--Testcase 7:
EXPLAIN VERBOSE SELECT count(J1_TBL.i), sum(J1_TBL.j), J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (k != 1 AND J1_TBL.__spd_url IS NOT NULL) GROUP BY J1_TBL.t LIMIT 5;
--Testcase 8:
SELECT count(J1_TBL.i), sum(J1_TBL.j), J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (k != 1 AND J1_TBL.__spd_url IS NOT NULL) GROUP BY J1_TBL.t LIMIT 5;
--Testcase 9:
EXPLAIN VERBOSE SELECT avg(J2_TBL.i) + 91, min(J2_TBL.k) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE (i = 1 OR J2_TBL.__spd_url = '/influx') GROUP BY J2_TBL.i LIMIT 5;
--Testcase 10:
SELECT avg(J2_TBL.i) + 91, min(J2_TBL.k) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE (i = 1 OR J2_TBL.__spd_url = '/influx') GROUP BY J2_TBL.i LIMIT 5;
--Testcase 11:
EXPLAIN VERBOSE SELECT t1.i, min(j), t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 WHERE t1.__spd_url != '' GROUP BY t1.i, t1.j, t1.t, t3.t LIMIT 5;
--Testcase 12:
SELECT t1.i, min(j), t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 WHERE t1.__spd_url != '' GROUP BY t1.i, t1.j, t1.t, t3.t LIMIT 5;
--Join  with WHERE __spd_url + ORDER BY + OFFSET
--Testcase 13:
EXPLAIN VERBOSE SELECT t1.j FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.__spd_url = t2.__spd_url) WHERE t1.__spd_url != '' ORDER BY t1.j OFFSET 10;
--Testcase 14:
SELECT t1.j FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.__spd_url = t2.__spd_url) WHERE t1.__spd_url != '' ORDER BY t1.j OFFSET 10;
--Testcase 15:
EXPLAIN VERBOSE SELECT j1.i, j, k  FROM J1_TBL j1 CROSS JOIN J2_TBL j2 WHERE j1.__spd_url != 'this' ORDER BY j1.t, j, k OFFSET 2;
--Testcase 16:
SELECT j1.i, j, k  FROM J1_TBL j1 CROSS JOIN J2_TBL j2 WHERE j1.__spd_url != 'this' ORDER BY j1.t, j, k OFFSET 2;
--Testcase 17:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL WHERE J1_TBL.__spd_url != 'twq' ORDER BY J1_TBL.i, J1_TBL.j, J1_TBL.t OFFSET 1;
--Testcase 18:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL WHERE J1_TBL.__spd_url != 'twq' ORDER BY J1_TBL.i, J1_TBL.j, J1_TBL.t OFFSET 1;
--Join  with ON  __spd_url + LIMIT
--Testcase 19:
EXPLAIN VERBOSE SELECT j3.i, k FROM j2_tbl INNER JOIN (SELECT i FROM j1_tbl) j3 ON j2_tbl.__spd_url != '' LIMIT 5;
--Testcase 20:
SELECT j3.i, k FROM j2_tbl INNER JOIN (SELECT i FROM j1_tbl) j3 ON j2_tbl.__spd_url != '' LIMIT 5;
--Testcase 21:
EXPLAIN VERBOSE SELECT k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL ON (J1_TBL.__spd_url <= J2_TBL.__spd_url) LIMIT 5;
--Testcase 22:
SELECT k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL ON (J1_TBL.__spd_url <= J2_TBL.__spd_url) LIMIT 5;
--Testcase 23:
EXPLAIN VERBOSE SELECT J1_TBL.i, k, t FROM J1_TBL FULL JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) LIMIT 3;
--Testcase 24:
SELECT J1_TBL.i, k, t FROM J1_TBL FULL JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) LIMIT 3;
--Join  with ON __spd_url + ORDER BY + OFFSET
--Testcase 25:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) ORDER BY J1_TBL.i OFFSET 1;
--Testcase 26:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) ORDER BY J1_TBL.i OFFSET 1;
--Testcase 27:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t1.c, t2.a, t2.d FROM J1_TBL t1 (a, b, c, e) FULL JOIN J2_TBL t2 (a, d, e) ON (t1.e = t2.e) ORDER BY t1.a, t1.b, t1.c, t2.a, t2.d OFFSET 3;
--Testcase 28:
SELECT t1.a, t1.b, t1.c, t2.a, t2.d FROM J1_TBL t1 (a, b, c, e) FULL JOIN J2_TBL t2 (a, d, e) ON (t1.e = t2.e) ORDER BY t1.a, t1.b, t1.c, t2.a, t2.d OFFSET 3;
--Testcase 29:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.__spd_url = t2.__spd_url RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL ORDER BY t1.i OFFSET 1;
--Testcase 30:
SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.__spd_url = t2.__spd_url RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL ORDER BY t1.i OFFSET 1;
--Join  with ON __spd_url + aggregate function + GROUP BY + ORDER BY
--Testcase 31:
EXPLAIN VERBOSE SELECT t1.j + 1, max(t1.i), min(t1.t) FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.__spd_url = t2.__spd_url) GROUP BY t1.j ORDER BY t1.j;
--Testcase 32:
SELECT t1.j + 1, max(t1.i), min(t1.t) FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.__spd_url = t2.__spd_url) GROUP BY t1.j ORDER BY t1.j;
--Testcase 33:
EXPLAIN VERBOSE SELECT count(J1_TBL.i) + 2, max(k), min(t) FROM J1_TBL FULL JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) GROUP BY J1_TBL.i ORDER BY J1_TBL.i;
--Testcase 34:
SELECT count(J1_TBL.i) + 2, max(k), min(t) FROM J1_TBL FULL JOIN J2_TBL ON (J1_TBL.__spd_url = J2_TBL.__spd_url) GROUP BY J1_TBL.i ORDER BY J1_TBL.i;
--Join  with USING  __spd_url + ORDER BY
--Testcase 35:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (__spd_url) AS x ORDER BY J1_TBL.i;
--Testcase 36:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (__spd_url) AS x ORDER BY J1_TBL.i;
--Testcase 37:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t1.c, t2.a, t2.d FROM J1_TBL t1 (a, b, c, f) FULL JOIN J2_TBL t2 (a, d, f) USING(f) ORDER BY t1.a, t1.b, t1.c, t2.a, t2.d;
--Testcase 38:
SELECT t1.a, t1.b, t1.c, t2.a, t2.d FROM J1_TBL t1 (a, b, c, f) FULL JOIN J2_TBL t2 (a, d, f) USING(f) ORDER BY t1.a, t1.b, t1.c, t2.a, t2.d;
--Testcase 39:
EXPLAIN VERBOSE SELECT t1.i, k, t3.t FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(__spd_url) CROSS JOIN J3_TBL t3 ORDER BY 1, 2, 3;
--Testcase 40:
SELECT t1.i, k, t3.t FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(__spd_url) CROSS JOIN J3_TBL t3 ORDER BY 1, 2, 3;
--Join  with USING  __spd_url + GROUP BY + LIMIT + ORDER BY
--Testcase 41:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (__spd_url) GROUP BY J1_TBL.i, J1_TBL.j, J1_TBL.t ORDER BY J1_TBL.i LIMIT 5;
--Testcase 42:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (__spd_url) GROUP BY J1_TBL.i, J1_TBL.j, J1_TBL.t ORDER BY J1_TBL.i LIMIT 5;
--Testcase 43:
EXPLAIN VERBOSE SELECT J2_TBL.i, J2_TBL.k FROM J1_TBL RIGHT JOIN J2_TBL USING (__spd_url) GROUP BY J2_TBL.i, J2_TBL.k ORDER BY J2_TBL.i LIMIT 5;
--Testcase 44:
SELECT J2_TBL.i, J2_TBL.k FROM J1_TBL RIGHT JOIN J2_TBL USING (__spd_url) GROUP BY J2_TBL.i, J2_TBL.k ORDER BY J2_TBL.i LIMIT 5;
--Pattern 3
--SELECT __spd_url FROM join clause + LIMIT
--Testcase 45:
EXPLAIN VERBOSE SELECT * FROM J1_TBL LEFT JOIN J2_TBL ON (J1_TBL.i = J2_TBL.i) LIMIT 10;
--Testcase 46:
SELECT * FROM J1_TBL LEFT JOIN J2_TBL ON (J1_TBL.i = J2_TBL.i) LIMIT 10;
--Testcase 47:
EXPLAIN VERBOSE SELECT * FROM (SELECT * FROM J1_TBL) AS t1 INNER JOIN (SELECT * FROM J2_TBL) t2 USING (i) LIMIT 10;
--Testcase 48:
SELECT * FROM (SELECT * FROM J1_TBL) AS t1 INNER JOIN (SELECT * FROM J2_TBL) t2 USING (i) LIMIT 10;
--Testcase 49:
EXPLAIN VERBOSE SELECT * FROM (SELECT * FROM J1_TBL) AS t1 FULL JOIN (SELECT * FROM J2_TBL) t2 USING (i) LIMIT 10;
--Testcase 50:
SELECT * FROM (SELECT * FROM J1_TBL) AS t1 FULL JOIN (SELECT * FROM J2_TBL) t2 USING (i) LIMIT 10;
--Testcase 51:
EXPLAIN VERBOSE SELECT i, k, t, J1_TBL.__spd_url FROM J1_TBL RIGHT JOIN J2_TBL USING (i) LIMIT 10;
--Testcase 52:
SELECT i, k, t, J1_TBL.__spd_url FROM J1_TBL RIGHT JOIN J2_TBL USING (i) LIMIT 10;
--SELECT __spd_url FROM join clause + ORDER BY + OFFSET
--Testcase 53:
EXPLAIN VERBOSE SELECT * FROM J1_TBL CROSS JOIN J2_TBL ORDER BY J1_TBL.i OFFSET 1;
--Testcase 54:
SELECT * FROM J1_TBL CROSS JOIN J2_TBL ORDER BY J1_TBL.i OFFSET 1;
--Testcase 55:
EXPLAIN VERBOSE SELECT * FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e) FULL JOIN J2_TBL x2(xx1,xx2) ON (x1.a = xx1) ORDER BY x1.a, x1.b OFFSET 1;
--Testcase 56:
SELECT * FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e) FULL JOIN J2_TBL x2(xx1,xx2) ON (x1.a = xx1) ORDER BY x1.a, x1.b OFFSET 1;
--Testcase 57:
EXPLAIN VERBOSE SELECT J1_TBL.* FROM J1_TBL FULL JOIN J2_TBL ON J1_TBL.i = J2_TBL.i ORDER BY J1_TBL.i, J2_TBL.i OFFSET 2;
--Testcase 58:
SELECT J1_TBL.* FROM J1_TBL FULL JOIN J2_TBL ON J1_TBL.i = J2_TBL.i ORDER BY J1_TBL.i, J2_TBL.i OFFSET 2;
--Testcase 59:
EXPLAIN VERBOSE SELECT J2_TBL.* FROM J1_TBL RIGHT JOIN J2_TBL ON J1_TBL.i = J2_TBL.i ORDER BY J2_TBL.i OFFSET 3;
--Testcase 60:
SELECT J2_TBL.* FROM J1_TBL RIGHT JOIN J2_TBL ON J1_TBL.i = J2_TBL.i ORDER BY J2_TBL.i OFFSET 3;
--Testcase 61:
EXPLAIN VERBOSE SELECT t2.* FROM J1_TBL t1 LEFT JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i OFFSET 1;
--Testcase 62:
SELECT t2.* FROM J1_TBL t1 LEFT JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i OFFSET 1;
--Testcase 63:
EXPLAIN VERBOSE SELECT * FROM J1_TBL INNER JOIN (SELECT distinct i FROM J2_TBL) j2 ON J1_TBL.i = j2.i ORDER BY j2 OFFSET 1;
--Testcase 64:
SELECT * FROM J1_TBL INNER JOIN (SELECT distinct i FROM J2_TBL) j2 ON J1_TBL.i = j2.i ORDER BY j2 OFFSET 1;
--Testcase 65:
EXPLAIN VERBOSE SELECT t1.i, t2.k, t3.__spd_url FROM J1_TBL t1 RIGHT JOIN (J2_TBL t2 LEFT JOIN J3_TBL t3 ON t2.i > t3.i INNER JOIN J1_TBL t4 ON t2.i = t4.i) ON t1.i = t2.i AND t1.t != t3.t ORDER BY t1.i, t2.k OFFSET 1;
--Testcase 66:
SELECT t1.i, t2.k, t3.__spd_url FROM J1_TBL t1 RIGHT JOIN (J2_TBL t2 LEFT JOIN J3_TBL t3 ON t2.i > t3.i INNER JOIN J1_TBL t4 ON t2.i = t4.i) ON t1.i = t2.i AND t1.t != t3.t ORDER BY t1.i, t2.k OFFSET 1;
--LATERAL subquery is involved in Join  + LIMIT
--Testcase 67:
EXPLAIN VERBOSE SELECT a.i, x.i FROM J1_TBL a, LATERAL (SELECT * FROM J2_TBL b WHERE i = a.i) x LIMIT 5;
--Testcase 68:
SELECT a.i, x.i FROM J1_TBL a, LATERAL (SELECT * FROM J2_TBL b WHERE i = a.i) x LIMIT 5;
--Testcase 69:
EXPLAIN VERBOSE SELECT ss.i, x.k FROM J2_TBL x CROSS JOIN LATERAL (SELECT i FROM J1_TBL WHERE i = x.i) ss LIMIT 3;
--Testcase 70:
SELECT ss.i, x.k FROM J2_TBL x CROSS JOIN LATERAL (SELECT i FROM J1_TBL WHERE i = x.i) ss LIMIT 3;
--Testcase 71:
EXPLAIN VERBOSE SELECT x.i, x.j, x.t FROM J1_TBL x LEFT JOIN LATERAL (SELECT i, k FROM J2_TBL WHERE i=x.i) ss ON true LIMIT 5;
--Testcase 72:
SELECT x.i, x.j, x.t FROM J1_TBL x LEFT JOIN LATERAL (SELECT i, k FROM J2_TBL WHERE i=x.i) ss ON true LIMIT 5;
--SELECT __spd_url, aggregate functions FROM join clause + WHERE + GROUP BY + LIMIT
--Testcase 73:
EXPLAIN VERBOSE SELECT *, count (J1_TBL.i) FROM J1_TBL LEFT JOIN J2_TBL ON (J1_TBL.i = J2_TBL.i) WHERE J1_TBL.i IS NOT NULL GROUP BY J1_TBL.i, J1_TBL.j, J1_TBL.t, J1_TBL.__spd_url, J2_TBL.i, J2_TBL.k, J2_TBL.__spd_url LIMIT 5;
--Testcase 74:
SELECT *, count (J1_TBL.i) FROM J1_TBL LEFT JOIN J2_TBL ON (J1_TBL.i = J2_TBL.i) WHERE J1_TBL.i IS NOT NULL GROUP BY J1_TBL.i, J1_TBL.j, J1_TBL.t, J1_TBL.__spd_url, J2_TBL.i, J2_TBL.k, J2_TBL.__spd_url LIMIT 5;
--Testcase 75:
EXPLAIN VERBOSE SELECT *, max(t1.i), min(t2.i) FROM (SELECT * FROM J1_TBL) AS t1 INNER JOIN (SELECT * FROM J2_TBL) t2 USING (i) WHERE i IN (1, 2, 3, 4, 5) GROUP BY t1.i, t1.j, t1.t, t1.__spd_url, t2.k, t2.__spd_url LIMIT 5;
--Testcase 76:
SELECT *, max(t1.i), min(t2.i) FROM (SELECT * FROM J1_TBL) AS t1 INNER JOIN (SELECT * FROM J2_TBL) t2 USING (i) WHERE i IN (1, 2, 3, 4, 5) GROUP BY t1.i, t1.j, t1.t, t1.__spd_url, t2.k, t2.__spd_url LIMIT 5;
--Testcase 77:
EXPLAIN VERBOSE SELECT *, avg(t1.j) FROM (SELECT * FROM J1_TBL) AS t1 FULL JOIN (SELECT * FROM J2_TBL) t2 USING (i) WHERE t1.j BETWEEN 0 AND 8 GROUP BY t1.i, t1.j, t1.t, t1.__spd_url, t2.i, t2.k, t2.__spd_url LIMIT 5;
--Testcase 78:
SELECT *, avg(t1.j) FROM (SELECT * FROM J1_TBL) AS t1 FULL JOIN (SELECT * FROM J2_TBL) t2 USING (i) WHERE t1.j BETWEEN 0 AND 8 GROUP BY t1.i, t1.j, t1.t, t1.__spd_url, t2.i, t2.k, t2.__spd_url LIMIT 5;
--Testcase 79:
EXPLAIN VERBOSE SELECT max(J1_TBL.i), max(k), min(t), max(J1_TBL.__spd_url) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE k < 0 GROUP BY J1_TBL.i, J2_TBL.k, J1_TBL.t, J1_TBL.__spd_url LIMIT 3;
--Testcase 80:
SELECT max(J1_TBL.i), max(k), min(t), max(J1_TBL.__spd_url) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE k < 0 GROUP BY J1_TBL.i, J2_TBL.k, J1_TBL.t, J1_TBL.__spd_url LIMIT 3;
--Testcase 81:
EXPLAIN VERBOSE SELECT max(ss1), min(ss2), ii, tt, kk FROM (J1_TBL CROSS JOIN J2_TBL) AS tx (ii, jj, tt, ii2, kk, ss1, ss2) WHERE ii > 0 GROUP BY ss1, ss2, ii, tt, kk LIMIT 5;
--Testcase 82:
SELECT max(ss1), min(ss2), ii, tt, kk FROM (J1_TBL CROSS JOIN J2_TBL) AS tx (ii, jj, tt, ii2, kk, ss1, ss2) WHERE ii > 0 GROUP BY ss1, ss2, ii, tt, kk LIMIT 5;
--Testcase 83:
EXPLAIN VERBOSE SELECT max(t1.i + t2.i), t1.__spd_url, t2.__spd_url FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t1.i = t2.i WHERE EXISTS (SELECT t3.i, t FROM J3_TBL t3 CROSS JOIN J2_TBL t4) AND t2.k < 1 GROUP BY t1.i, t2.i, t1.__spd_url, t2.__spd_url LIMIT 5;
--Testcase 84:
SELECT max(t1.i + t2.i), t1.__spd_url, t2.__spd_url FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t1.i = t2.i WHERE EXISTS (SELECT t3.i, t FROM J3_TBL t3 CROSS JOIN J2_TBL t4) AND t2.k < 1 GROUP BY t1.i, t2.i, t1.__spd_url, t2.__spd_url LIMIT 5;
--Pattern 4
--Join  with + HAVING(aggregate function) + GROUP BY + LIMIT + OFFSET
--Testcase 85:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(i) GROUP BY t1.i, t1.j, t1.t HAVING max(t1.i) NOT IN (1, 2, 3) LIMIT 5 OFFSET 0;
--Testcase 86:
SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(i) GROUP BY t1.i, t1.j, t1.t HAVING max(t1.i) NOT IN (1, 2, 3) LIMIT 5 OFFSET 0;
--Testcase 87:
EXPLAIN VERBOSE SELECT t1.i FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.__spd_url, t1.i HAVING min(t1.t) != '' LIMIT 3 OFFSET 1;
--Testcase 88:
SELECT t1.i FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.__spd_url, t1.i HAVING min(t1.t) != '' LIMIT 3 OFFSET 1;
--Testcase 89:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) LEFT JOIN J2_TBL t2 (a, b, d) USING (a) GROUP BY t1.a, t1.b, t1.c, t2.a, t2.b, t1.d HAVING max(t1.d) <> '/example' LIMIT 5 OFFSET 1;
--Testcase 90:
SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) LEFT JOIN J2_TBL t2 (a, b, d) USING (a) GROUP BY t1.a, t1.b, t1.c, t2.a, t2.b, t1.d HAVING max(t1.d) <> '/example' LIMIT 5 OFFSET 1;
--Testcase 91:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i GROUP BY t1.i, t2.i, t3.i, t4.i HAVING count(t1.i) > 1 LIMIT 5 OFFSET 0;
--Testcase 92:
SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i GROUP BY t1.i, t2.i, t3.i, t4.i HAVING count(t1.i) > 1 LIMIT 5 OFFSET 0;
--Join  with + HAVING(aggregate function) + GROUP BY + ORDER BY
--Testcase 93:
EXPLAIN VERBOSE SELECT J1_TBL.i, j, k FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i, j, k HAVING max(J1_TBL.t) > '$' ORDER BY J1_TBL.i, j, k;
--Testcase 94:
SELECT J1_TBL.i, j, k FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i, j, k HAVING max(J1_TBL.t) > '$' ORDER BY J1_TBL.i, j, k;
--Testcase 95:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL RIGHT JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i GROUP BY __spd_url, J1_TBL.i, J1_TBL.j, J1_TBL.t HAVING count(s.i) > 3 ORDER BY J1_TBL.i, J1_TBL.j, J1_TBL.t;
--Testcase 96:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL RIGHT JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i GROUP BY __spd_url, J1_TBL.i, J1_TBL.j, J1_TBL.t HAVING count(s.i) > 3 ORDER BY J1_TBL.i, J1_TBL.j, J1_TBL.t;
--Testcase 97:
EXPLAIN VERBOSE SELECT x1.a, x1.b, x1.c, x1.d, x1.e, xx1 FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e) FULL JOIN J2_TBL x2(xx1,xx2) ON (x1.a = xx1) GROUP BY x1.a, x1.b, x1.c, x1.d, x1.e, xx1 HAVING max(x1.a) > 0 ORDER BY x1.a, x1.b;
--Testcase 98:
SELECT x1.a, x1.b, x1.c, x1.d, x1.e, xx1 FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e) FULL JOIN J2_TBL x2(xx1,xx2) ON (x1.a = xx1) GROUP BY x1.a, x1.b, x1.c, x1.d, x1.e, xx1 HAVING max(x1.a) > 0 ORDER BY x1.a, x1.b;
--Join  with aggregate functions not safe + GROUP BY + ORDER BY + LIMIT
--Testcase 99:
EXPLAIN VERBOSE SELECT count(DISTINCT i), string_agg(t, '~!@#' ORDER BY t) FROM J1_TBL FULL JOIN J2_TBL USING (i) GROUP BY i ORDER BY i LIMIT 1;
--Testcase 100:
SELECT count(DISTINCT i), string_agg(t, '~!@#' ORDER BY t) FROM J1_TBL FULL JOIN J2_TBL USING (i) GROUP BY i ORDER BY i LIMIT 1;
--Testcase 101:
EXPLAIN VERBOSE SELECT string_agg(t, ' ' ORDER BY t) FROM J1_TBL LEFT JOIN J2_TBL USING (i) GROUP BY i ORDER BY i LIMIT 2;
--Testcase 102:
SELECT string_agg(t, ' ' ORDER BY t) FROM J1_TBL LEFT JOIN J2_TBL USING (i) GROUP BY i ORDER BY i LIMIT 2;
--Testcase 103:
EXPLAIN VERBOSE SELECT t1.a, string_agg(t1.c, t1.c), t2.d FROM J1_TBL t1 (a, b, c, e) INNER JOIN J2_TBL t2 (a, d, e) USING(a) GROUP BY t1.a, t2.d ORDER BY t1.a LIMIT 3;
--Testcase 104:
SELECT t1.a, string_agg(t1.c, t1.c), t2.d FROM J1_TBL t1 (a, b, c, e) INNER JOIN J2_TBL t2 (a, d, e) USING(a) GROUP BY t1.a, t2.d ORDER BY t1.a LIMIT 3;
--Testcase 105:
EXPLAIN VERBOSE SELECT string_agg(t, ' ' ORDER BY t), json_agg(('~!@#', t)) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY t ORDER BY t LIMIT 1;
--Testcase 106:
SELECT string_agg(t, ' ' ORDER BY t), json_agg(('~!@#', t)) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY t ORDER BY t LIMIT 1;
--Testcase 107:
EXPLAIN VERBOSE SELECT count(DISTINCT i), count(*), string_agg(t, ' ' ORDER BY t) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) GROUP BY i, t ORDER BY i, t LIMIT 1;
--Testcase 108:
SELECT count(DISTINCT i), count(*), string_agg(t, ' ' ORDER BY t) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) GROUP BY i, t ORDER BY i, t LIMIT 1;
--Testcase 109:
EXPLAIN VERBOSE SELECT t1.i, string_agg(t, ' ' ORDER BY t), t3.t FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t ORDER BY t1.i LIMIT 5;
--Testcase 110:
SELECT t1.i, string_agg(t, ' ' ORDER BY t), t3.t FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t ORDER BY t1.i LIMIT 5;
--Pattern 5
--Join  with ORDER BY (__spd_url)
--Testcase 111:
EXPLAIN VERBOSE SELECT J1_TBL.i, k, t FROM J1_TBL CROSS JOIN J2_TBL ORDER BY i, k, t, J1_TBL.__spd_url;
--Testcase 112:
SELECT J1_TBL.i, k, t FROM J1_TBL CROSS JOIN J2_TBL ORDER BY i, k, t, J1_TBL.__spd_url;
--Testcase 113:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL FULL JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i ORDER BY __spd_url;
--Testcase 114:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL FULL JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i ORDER BY __spd_url;
--Testcase 115:
EXPLAIN VERBOSE SELECT t2.a, t1.a FROM J1_TBL t1(a, b, c, d) INNER JOIN J2_TBL t2 (a, d, e) USING (a) ORDER BY t1.d;
--Testcase 116:
SELECT t2.a, t1.a FROM J1_TBL t1(a, b, c, d) INNER JOIN J2_TBL t2 (a, d, e) USING (a) ORDER BY t1.d;
--Testcase 117:
EXPLAIN VERBOSE SELECT t1.c, t1.a, t2.b FROM J1_TBL t1 (a, b, c, e) LEFT JOIN J2_TBL t2(a, b, e) USING (b) ORDER BY t2.b, t2.e;
--Testcase 118:
SELECT t1.c, t1.a, t2.b FROM J1_TBL t1 (a, b, c, e) LEFT JOIN J2_TBL t2(a, b, e) USING (b) ORDER BY t2.b, t2.e;
--Testcase 119:
EXPLAIN VERBOSE SELECT a.i, a.j, a.t FROM J1_TBL a RIGHT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z ORDER BY a.i, a.j, ss.z, a.__spd_url;
--Testcase 120:
SELECT a.i, a.j, a.t FROM J1_TBL a RIGHT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z ORDER BY a.i, a.j, ss.z, a.__spd_url;
--Testcase 121:
EXPLAIN VERBOSE SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 ORDER BY t1.i, t1.j, t1.__spd_url, t3.t;
--Testcase 122:
SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 ORDER BY t1.i, t1.j, t1.__spd_url, t3.t;
--Join  + ORDER BY (__spd_url) + OFFSET
--Testcase 123:
EXPLAIN VERBOSE SELECT t1.i, k, t FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i = 0 ORDER BY t1.i, t1.__spd_url OFFSET 1;
--Testcase 124:
SELECT t1.i, k, t FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i = 0 ORDER BY t1.i, t1.__spd_url OFFSET 1;
--Testcase 125:
EXPLAIN VERBOSE SELECT t2.i, k, t FROM J1_TBL x CROSS JOIN J2_TBL t2 ORDER BY t2.__spd_url OFFSET 2;
--Testcase 126:
SELECT t2.i, k, t FROM J1_TBL x CROSS JOIN J2_TBL t2 ORDER BY t2.__spd_url OFFSET 2;
--Testcase 127:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t2.d FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d ORDER BY t1.f OFFSET 3;
--Testcase 128:
SELECT t1.a, t1.b, t2.d FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d ORDER BY t1.f OFFSET 3;
--Testcase 129:
EXPLAIN VERBOSE SELECT a.i, a.j, x.i, x.j, ss.z FROM J1_TBL a, J1_TBL x LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON x.i = ss.z ORDER BY a.__spd_url OFFSET 5;
--Testcase 130:
SELECT a.i, a.j, x.i, x.j, ss.z FROM J1_TBL a, J1_TBL x LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON x.i = ss.z ORDER BY a.__spd_url OFFSET 5;
--Testcase 131:
EXPLAIN VERBOSE SELECT f1.i, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NOT NULL) ORDER BY f1.__spd_url OFFSET 3;
--Testcase 132:
SELECT f1.i, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NOT NULL) ORDER BY f1.__spd_url OFFSET 3;
--Testcase 133:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL ORDER BY t1.__spd_url OFFSET 1;
--Testcase 134:
SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL ORDER BY t1.__spd_url OFFSET 1;
--Join  + aggregate functions + GROUP BY + ORDER BY(__spd_url) + LIMIT
--Testcase 135:
EXPLAIN VERBOSE SELECT max(t1.i + t1.j), t1.t, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(i) GROUP BY t1.i, t1.j, t1.t, t2.i, t2.k, t1.__spd_url ORDER BY t1.__spd_url LIMIT 5;
--Testcase 136:
SELECT max(t1.i + t1.j), t1.t, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 USING(i) GROUP BY t1.i, t1.j, t1.t, t2.i, t2.k, t1.__spd_url ORDER BY t1.__spd_url LIMIT 5;
--Testcase 137:
EXPLAIN VERBOSE SELECT min(t1.i) FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.i, t2.i, t1.__spd_url ORDER BY t1.__spd_url LIMIT 3;
--Testcase 138:
SELECT min(t1.i) FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.i, t2.i, t1.__spd_url ORDER BY t1.__spd_url LIMIT 3;
--Testcase 139:
EXPLAIN VERBOSE SELECT avg(t1.i * t1.j), t1.t, sum(t2.i - t2.k) FROM J1_TBL t1 LEFT JOIN J2_TBL t2 USING (i) GROUP BY t1.t, t2.__spd_url ORDER BY t2.__spd_url LIMIT 5;
--Testcase 140:
SELECT avg(t1.i * t1.j), t1.t, sum(t2.i - t2.k) FROM J1_TBL t1 LEFT JOIN J2_TBL t2 USING (i) GROUP BY t1.t, t2.__spd_url ORDER BY t2.__spd_url LIMIT 5;
--Testcase 141:
EXPLAIN VERBOSE SELECT J1_TBL.i, max(j), k FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i, j, k, J1_TBL.__spd_url ORDER BY J1_TBL.__spd_url LIMIT 5;
--Testcase 142:
SELECT J1_TBL.i, max(j), k FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i, j, k, J1_TBL.__spd_url ORDER BY J1_TBL.__spd_url LIMIT 5;
--Testcase 143:
EXPLAIN VERBOSE SELECT sum(J1_TBL.i) + avg(J1_TBL.j), count(J1_TBL.t) FROM J1_TBL RIGHT JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i GROUP BY J1_TBL.__spd_url ORDER BY J1_TBL.__spd_url LIMIT 3;
--Testcase 144:
SELECT sum(J1_TBL.i) + avg(J1_TBL.j), count(J1_TBL.t) FROM J1_TBL RIGHT JOIN (SELECT i, k FROM J2_TBL) s ON J1_TBL.i = s.i GROUP BY J1_TBL.__spd_url ORDER BY J1_TBL.__spd_url LIMIT 3;
--Testcase 145:
EXPLAIN VERBOSE SELECT count(k), max(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY k, t3.t, t3.__spd_url ORDER BY t3.__spd_url LIMIT 5;
--Testcase 146:
SELECT count(k), max(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY k, t3.t, t3.__spd_url ORDER BY t3.__spd_url LIMIT 5;
--Pattern 7+8
--Join  with WHERE + LIMIT
--Testcase 147:
EXPLAIN VERBOSE SELECT k, t FROM J1_TBL INNER JOIN J2_TBL USING (i) WHERE J1_TBL.i <= J2_TBL.k LIMIT 5;
--Testcase 148:
SELECT k, t FROM J1_TBL INNER JOIN J2_TBL USING (i) WHERE J1_TBL.i <= J2_TBL.k LIMIT 5;
--Testcase 149:
EXPLAIN VERBOSE SELECT t1.i, k, t FROM J1_TBL t1 CROSS JOIN J2_TBL t2 WHERE t1.i = t2.i LIMIT 3;
--Testcase 150:
SELECT t1.i, k, t FROM J1_TBL t1 CROSS JOIN J2_TBL t2 WHERE t1.i = t2.i LIMIT 3;
--Testcase 151:
EXPLAIN VERBOSE SELECT k, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (k != 1) LIMIT 1;
--Testcase 152:
SELECT k, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (k != 1) LIMIT 1;
--Testcase 153:
EXPLAIN VERBOSE SELECT t1.i, k, t FROM J1_TBL t1 FULL JOIN J2_TBL t2 USING (i) WHERE k IS NOT NULL LIMIT 5;
--Testcase 154:
SELECT t1.i, k, t FROM J1_TBL t1 FULL JOIN J2_TBL t2 USING (i) WHERE k IS NOT NULL LIMIT 5;
--Testcase 155:
EXPLAIN VERBOSE SELECT i, k FROM (SELECT i, t FROM J1_TBL) AS t1 RIGHT JOIN (SELECT i, k FROM J2_TBL) t2 USING (i) WHERE i IS NOT NULL LIMIT 5;
--Testcase 156:
SELECT i, k FROM (SELECT i, t FROM J1_TBL) AS t1 RIGHT JOIN (SELECT i, k FROM J2_TBL) t2 USING (i) WHERE i IS NOT NULL LIMIT 5;
--Testcase 157:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL LIMIT 5;
--Testcase 158:
SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i WHERE t1.i IS NOT NULL LIMIT 5;
--Join  with WHERE + ORDER BY +  OFFSET
--Testcase 159:
EXPLAIN VERBOSE SELECT tx.ii, tx.jj, tx.kk FROM (J1_TBL t1 (a, b, c, f) CROSS JOIN J2_TBL t2 (d, e, f)) AS tx (ii, jj, tt, ff, ii2, kk, ff2) WHERE tx.ii IS NOT NULL ORDER BY tx.ii, tx.jj, tx.kk OFFSET 1;
--Testcase 160:
SELECT tx.ii, tx.jj, tx.kk FROM (J1_TBL t1 (a, b, c, f) CROSS JOIN J2_TBL t2 (d, e, f)) AS tx (ii, jj, tt, ff, ii2, kk, ff2) WHERE tx.ii IS NOT NULL ORDER BY tx.ii, tx.jj, tx.kk OFFSET 1;
--Testcase 161:
EXPLAIN VERBOSE SELECT i, j, t FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE t IS NOT NULL ORDER BY i, j, t OFFSET 2;
--Testcase 162:
SELECT i, j, t FROM J1_TBL RIGHT JOIN J2_TBL USING (i) WHERE t IS NOT NULL ORDER BY i, j, t OFFSET 2;
--Testcase 163:
EXPLAIN VERBOSE SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i) WHERE i >= 0 ORDER BY i, k, t OFFSET 1;
--Testcase 164:
SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i) WHERE i >= 0 ORDER BY i, k, t OFFSET 1;
--Testcase 165:
EXPLAIN VERBOSE SELECT i, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (i >= 1) ORDER BY i, t OFFSET 1;
--Testcase 166:
SELECT i, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (i >= 1) ORDER BY i, t OFFSET 1;
--Testcase 167:
EXPLAIN VERBOSE SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i WHERE t1.i > 0 ORDER BY t1.i OFFSET 1;
--Testcase 168:
SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i WHERE t1.i > 0 ORDER BY t1.i OFFSET 1;
--Join  with LIMIT
--Testcase 169:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL LIMIT 5;
--Testcase 170:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL CROSS JOIN J2_TBL LIMIT 5;
--Testcase 171:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (i) AS x LIMIT 10;
--Testcase 172:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL INNER JOIN J2_TBL USING (i) AS x LIMIT 10;
--Testcase 173:
EXPLAIN VERBOSE SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) FULL JOIN J2_TBL t2 (a, b, d) USING (b) LIMIT 5;
--Testcase 174:
SELECT t1.a, t1.b, t1.c, t2.a, t2.b FROM J1_TBL t1 (a, b, c, d) FULL JOIN J2_TBL t2 (a, b, d) USING (b) LIMIT 5;
--Testcase 175:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (i) LIMIT 5;
--Testcase 176:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t FROM J1_TBL LEFT JOIN J2_TBL USING (i) LIMIT 5;
--Testcase 177:
EXPLAIN VERBOSE SELECT J2_TBL.i, J2_TBL.k FROM J1_TBL RIGHT JOIN J2_TBL USING (i) LIMIT 5;
--Testcase 178:
SELECT J2_TBL.i, J2_TBL.k FROM J1_TBL RIGHT JOIN J2_TBL USING (i) LIMIT 5;
--Join  with OFFSET
--Testcase 179:
EXPLAIN VERBOSE SELECT i, k, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) OFFSET 2;
--Testcase 180:
SELECT i, k, t FROM J1_TBL LEFT JOIN J2_TBL USING (i) OFFSET 2;
--Testcase 181:
EXPLAIN VERBOSE SELECT i, k, t FROM J1_TBL INNER JOIN J2_TBL USING (i) OFFSET 1;
--Testcase 182:
SELECT i, k, t FROM J1_TBL INNER JOIN J2_TBL USING (i) OFFSET 1;
--Testcase 183:
EXPLAIN VERBOSE SELECT J1_TBL.i, J2_TBL.k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL USING (i) OFFSET 1;
--Testcase 184:
SELECT J1_TBL.i, J2_TBL.k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL USING (i) OFFSET 1;
--Testcase 185:
EXPLAIN VERBOSE SELECT J1_TBL.i, k, t FROM J1_TBL CROSS JOIN J2_TBL OFFSET 1;
--Testcase 186:
SELECT J1_TBL.i, k, t FROM J1_TBL CROSS JOIN J2_TBL OFFSET 1;
--Testcase 187:
EXPLAIN VERBOSE SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i) OFFSET 3;
--Testcase 188:
SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i) OFFSET 3;
--Join  with LIMIT, OFFSET
--Testcase 189:
EXPLAIN VERBOSE SELECT x, t2.i FROM (SELECT j/2 AS x FROM J1_TBL) ss1 INNER JOIN J2_TBL t2 ON x = i LIMIT 5 OFFSET 0;
--Testcase 190:
SELECT x, t2.i FROM (SELECT j/2 AS x FROM J1_TBL) ss1 INNER JOIN J2_TBL t2 ON x = i LIMIT 5 OFFSET 0;
--Testcase 191:
EXPLAIN VERBOSE SELECT x.i, x.j, x.t, y.i, y.k FROM J1_TBL x LEFT JOIN (SELECT i, k FROM J2_TBL) y ON x.i = y.i LIMIT 3 OFFSET 5;
--Testcase 192:
SELECT x.i, x.j, x.t, y.i, y.k FROM J1_TBL x LEFT JOIN (SELECT i, k FROM J2_TBL) y ON x.i = y.i LIMIT 3 OFFSET 5;
--Testcase 193:
EXPLAIN VERBOSE SELECT f1.i, f1.j, f2.i, f2.k FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j >= f2.k) LIMIT 5 OFFSET 1;
--Testcase 194:
SELECT f1.i, f1.j, f2.i, f2.k FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j >= f2.k) LIMIT 5 OFFSET 1;
--Testcase 195:
EXPLAIN VERBOSE SELECT j1.i, j2.i, j1.t, j2.k FROM J1_TBL j1 CROSS JOIN J2_TBL j2 LIMIT 3 OFFSET 0;
--Testcase 196:
SELECT j1.i, j2.i, j1.t, j2.k FROM J1_TBL j1 CROSS JOIN J2_TBL j2 LIMIT 3 OFFSET 0;
--Testcase 197:
EXPLAIN VERBOSE SELECT j1.i, j2.i, j1.i + j2.i, j1.j * j2.k, j1.t FROM J1_TBL j1 FULL JOIN J2_TBL j2 ON j1.i = j2.i LIMIT 5 OFFSET 0;
--Testcase 198:
SELECT j1.i, j2.i, j1.i + j2.i, j1.j * j2.k, j1.t FROM J1_TBL j1 FULL JOIN J2_TBL j2 ON j1.i = j2.i LIMIT 5 OFFSET 0;
--Join  with LIMIT, OFFSET and ORDER BY
--Testcase 199:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 LEFT JOIN (SELECT i, k , '***'::text AS d1 FROM J2_TBL t2) b1 ON t1.i = b1.i ORDER BY t1.i, b1.i LIMIT 5 OFFSET 0;
--Testcase 200:
SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 LEFT JOIN (SELECT i, k , '***'::text AS d1 FROM J2_TBL t2) b1 ON t1.i = b1.i ORDER BY t1.i, b1.i LIMIT 5 OFFSET 0;
--Testcase 201:
EXPLAIN VERBOSE SELECT t1.i, t1.j, b1.i FROM J1_TBL t1 RIGHT JOIN (SELECT i, null::int AS d2 FROM J2_TBL t2) b1 ON t1.i = b1.i ORDER BY t1.i, b1.i LIMIT 5 OFFSET 1;
--Testcase 202:
SELECT t1.i, t1.j, b1.i FROM J1_TBL t1 RIGHT JOIN (SELECT i, null::int AS d2 FROM J2_TBL t2) b1 ON t1.i = b1.i ORDER BY t1.i, b1.i LIMIT 5 OFFSET 1;
--Testcase 203:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.k = 2 ORDER BY t1.i LIMIT 3 OFFSET 0;
--Testcase 204:
SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.k = 2 ORDER BY t1.i LIMIT 3 OFFSET 0;
--Testcase 205:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i LIMIT 3 OFFSET 0;
--Testcase 206:
SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i LIMIT 3 OFFSET 0;
--Testcase 207:
EXPLAIN VERBOSE SELECT t1.i/2, t1.j - 1, t1.t || '***' FROM J1_TBL t1 CROSS JOIN J2_TBL t2(x, y, z) ORDER BY t1.i LIMIT 5 OFFSET 2;
--Testcase 208:
SELECT t1.i/2, t1.j - 1, t1.t || '***' FROM J1_TBL t1 CROSS JOIN J2_TBL t2(x, y, z) ORDER BY t1.i LIMIT 5 OFFSET 2;
--Testcase 209:
EXPLAIN VERBOSE SELECT x1.a, x1.b, x1.c, x1.e, xx1 FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e, f, g) FULL JOIN J2_TBL x2(xx1, xx2, xx3) ON (x1.a = xx1) ORDER BY x1.a, x1.b LIMIT 10 OFFSET 0;
--Testcase 210:
SELECT x1.a, x1.b, x1.c, x1.e, xx1 FROM (J1_TBL t1 LEFT JOIN J2_TBL t2 ON (t1.i = t2.i)) x1(a, b, c, d, e, f, g) FULL JOIN J2_TBL x2(xx1, xx2, xx3) ON (x1.a = xx1) ORDER BY x1.a, x1.b LIMIT 10 OFFSET 0;
--Join  with GROUP BY, OFFSET and ORDER BY
--Testcase 211:
EXPLAIN VERBOSE SELECT t1.i, t1.j, b1.k FROM J1_TBL t1 LEFT JOIN (SELECT i, k , '***'::text AS d1 FROM J2_TBL t2) b1 ON t1.i = b1.i GROUP BY t1.i, t1.j, b1.k, b1.i ORDER BY t1.i, b1.i OFFSET 1;
--Testcase 212:
SELECT t1.i, t1.j, b1.k FROM J1_TBL t1 LEFT JOIN (SELECT i, k , '***'::text AS d1 FROM J2_TBL t2) b1 ON t1.i = b1.i GROUP BY t1.i, t1.j, b1.k, b1.i ORDER BY t1.i, b1.i OFFSET 1;
--Testcase 213:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 RIGHT JOIN (SELECT i, null::int AS d2 FROM J2_TBL t2) b1 ON t1.i = b1.i GROUP BY t1.i, t1.j, t1.t, b1.i ORDER BY t1.i, b1.i OFFSET 1;
--Testcase 214:
SELECT t1.i, t1.j, t1.t FROM J1_TBL t1 RIGHT JOIN (SELECT i, null::int AS d2 FROM J2_TBL t2) b1 ON t1.i = b1.i GROUP BY t1.i, t1.j, t1.t, b1.i ORDER BY t1.i, b1.i OFFSET 1;
--Testcase 215:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.k = 2 GROUP BY t1.i, t1.j, t2.i, t2.k ORDER BY t1.i OFFSET 1;
--Testcase 216:
SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.k = 2 GROUP BY t1.i, t1.j, t2.i, t2.k ORDER BY t1.i OFFSET 1;
--Testcase 217:
EXPLAIN VERBOSE SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i GROUP BY t1.i, t1.j, t2.i, t2.k ORDER BY t1.i, t1.j, t2.i, t2.k OFFSET 1;
--Testcase 218:
SELECT t1.i, t1.j, t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i GROUP BY t1.i, t1.j, t2.i, t2.k ORDER BY t1.i, t1.j, t2.i, t2.k OFFSET 1;
--Testcase 219:
EXPLAIN VERBOSE SELECT t1.i/2, t1.j - 1, t1.t || '***' FROM J1_TBL t1 CROSS JOIN J2_TBL t2(x, y, z) GROUP BY t1.i, t1.j, t2.x, t1.t ORDER BY t1.i OFFSET 2;
--Testcase 220:
SELECT t1.i/2, t1.j - 1, t1.t || '***' FROM J1_TBL t1 CROSS JOIN J2_TBL t2(x, y, z) GROUP BY t1.i, t1.j, t2.x, t1.t ORDER BY t1.i OFFSET 2;
--Join  with LIMIT, OFFSET, aggregate function, GROUP BY
--Testcase 221:
EXPLAIN VERBOSE SELECT t1.i, count(k), '12x ' || t  FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i != 0 GROUP BY t1.i, k, t LIMIT 5 OFFSET 0;
--Testcase 222:
SELECT t1.i, count(k), '12x ' || t  FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i != 0 GROUP BY t1.i, k, t LIMIT 5 OFFSET 0;
--Testcase 223:
EXPLAIN VERBOSE SELECT count(J1_TBL.i), avg(k), min(t) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY k, t LIMIT 5 OFFSET 0;
--Testcase 224:
SELECT count(J1_TBL.i), avg(k), min(t) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY k, t LIMIT 5 OFFSET 0;
--Testcase 225:
EXPLAIN VERBOSE SELECT max(t1.a), min(t1.b), t2.d FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d GROUP BY t1.a, t1.b, t2.d LIMIT 5 OFFSET 5;
--Testcase 226:
SELECT max(t1.a), min(t1.b), t2.d FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d GROUP BY t1.a, t1.b, t2.d LIMIT 5 OFFSET 5;
--Testcase 227:
EXPLAIN VERBOSE SELECT t1.i, max(k), min(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t LIMIT 5 OFFSET 0;
--Testcase 228:
SELECT t1.i, max(k), min(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t LIMIT 5 OFFSET 0;
--Join  with WHERE, LIMIT, OFFSET, ORDER BY, GROUP BY
--Testcase 229:
EXPLAIN VERBOSE SELECT a.i, a.j, ss.z FROM J1_TBL a LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z WHERE a.j = ss.z GROUP BY a.i, a.j, ss.z ORDER BY a.i ASC, a.j DESC, ss.z LIMIT 5 OFFSET 1;
--Testcase 230:
SELECT a.i, a.j, ss.z FROM J1_TBL a LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z WHERE a.j = ss.z GROUP BY a.i, a.j, ss.z ORDER BY a.i ASC, a.j DESC, ss.z LIMIT 5 OFFSET 1;
--Testcase 231:
EXPLAIN VERBOSE SELECT f1.i, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NOT NULL) WHERE f1.t IS NULL GROUP BY f1.i, f1.j, f2.i ORDER BY 1 DESC LIMIT 5 OFFSET 1;
--Testcase 232:
SELECT f1.i, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NOT NULL) WHERE f1.t IS NULL GROUP BY f1.i, f1.j, f2.i ORDER BY 1 DESC LIMIT 5 OFFSET 1;
--Pattern 9
--Join  with GROUP BY + ORDER BY
--Testcase 233:
EXPLAIN VERBOSE SELECT j2_tbl.i, k FROM j2_tbl INNER JOIN (SELECT i FROM j1_tbl GROUP BY i) j3 ON j2_tbl.i = j3.i GROUP BY j3.i, j2_tbl.i, k  ORDER BY j3.i;
--Testcase 234:
SELECT j2_tbl.i, k FROM j2_tbl INNER JOIN (SELECT i FROM j1_tbl GROUP BY i) j3 ON j2_tbl.i = j3.i GROUP BY j3.i, j2_tbl.i, k  ORDER BY j3.i;
--Testcase 235:
EXPLAIN VERBOSE SELECT t1.j FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.i = t2.i) GROUP BY t1.j ORDER BY t1.j;
--Testcase 236:
SELECT t1.j FROM j1_tbl t1 LEFT JOIN j2_tbl t2 ON (t1.i = t2.i) GROUP BY t1.j ORDER BY t1.j;
--Testcase 237:
EXPLAIN VERBOSE SELECT t1.i FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.i ORDER BY 1;
--Testcase 238:
SELECT t1.i FROM j1_tbl t1 FULL JOIN (SELECT i, k FROM j2_tbl) t2 ON (t1.i = t2.i) GROUP BY t1.i ORDER BY 1;
--Testcase 239:
EXPLAIN VERBOSE SELECT j1.i, j1.j, j2.k  FROM J1_TBL j1 CROSS JOIN J2_TBL j2 GROUP BY j1.i, j1.j, j2.k ORDER BY j2.k;
--Testcase 240:
SELECT j1.i, j1.j, j2.k  FROM J1_TBL j1 CROSS JOIN J2_TBL j2 GROUP BY j1.i, j1.j, j2.k ORDER BY j2.k;
--Testcase 241:
EXPLAIN VERBOSE SELECT J2_TBL.k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL ON (J1_TBL.i <= J2_TBL.k) GROUP BY J1_TBL.i, J2_TBL.k, J1_TBL.t ORDER BY J2_TBL.k;
--Testcase 242:
SELECT J2_TBL.k, J1_TBL.t FROM J1_TBL RIGHT JOIN J2_TBL ON (J1_TBL.i <= J2_TBL.k) GROUP BY J1_TBL.i, J2_TBL.k, J1_TBL.t ORDER BY J2_TBL.k;
--Testcase 243:
EXPLAIN VERBOSE SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 GROUP BY t1.i, t1.j, t1.t, t3.t ORDER BY t1.i, t1.j, t1.t, t3.t;
--Testcase 244:
SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1 GROUP BY t1.i, t1.j, t1.t, t3.t ORDER BY t1.i, t1.j, t1.t, t3.t;
--Join  + aggregate functions + GROUP BY + ORDER BY
--Testcase 245:
EXPLAIN VERBOSE SELECT count(t1.i) - 1, k, t FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i != 0 GROUP BY t1.i, k, t ORDER BY 1, 2, 3;
--Testcase 246:
SELECT count(t1.i) - 1, k, t FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t2.i != 0 GROUP BY t1.i, k, t ORDER BY 1, 2, 3;
--Testcase 247:
EXPLAIN VERBOSE SELECT sum(x.i+x.j), avg(k) FROM J1_TBL x CROSS JOIN J2_TBL y GROUP BY k, t ORDER BY k, t;
--Testcase 248:
SELECT sum(x.i+x.j), avg(k) FROM J1_TBL x CROSS JOIN J2_TBL y GROUP BY k, t ORDER BY k, t;
--Testcase 249:
EXPLAIN VERBOSE SELECT max(t1.a) + max(t2.d) + 1, t1.b, t2.e FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d GROUP BY t1.a, t1.b, t2.e ORDER BY t1.a, t1.b, t2.e;
--Testcase 250:
SELECT max(t1.a) + max(t2.d) + 1, t1.b, t2.e FROM J1_TBL t1(a, b, c, f) FULL JOIN J2_TBL t2(d, e, f) ON t1.a = t2.d GROUP BY t1.a, t1.b, t2.e ORDER BY t1.a, t1.b, t2.e;
--Testcase 251:
EXPLAIN VERBOSE SELECT min(a.j), ss.z FROM J1_TBL a LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z GROUP BY a.j, ss.z ORDER BY ss.z;
--Testcase 252:
SELECT min(a.j), ss.z FROM J1_TBL a LEFT JOIN (SELECT i FROM J2_TBL y) ss(z) ON a.i = ss.z GROUP BY a.j, ss.z ORDER BY ss.z;
--Testcase 253:
EXPLAIN VERBOSE SELECT f1.i, min(f1.j) > 0, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NULL) GROUP BY f1.i, f1.j, f2.i ORDER BY f1.i;
--Testcase 254:
SELECT f1.i, min(f1.j) > 0, f1.j, f2.i FROM J1_TBL f1 RIGHT JOIN J2_TBL f2 ON (f1.i = f2.i AND f1.j IS NULL) GROUP BY f1.i, f1.j, f2.i ORDER BY f1.i;
--Testcase 255:
EXPLAIN VERBOSE SELECT t1.i, k, max(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t ORDER BY 1, 2, 3;
--Testcase 256:
SELECT t1.i, k, max(t3.t) FROM J1_TBL t1 CROSS JOIN J2_TBL t2 INNER JOIN J3_TBL t3 USING(t) GROUP BY t1.i, k, t3.t ORDER BY 1, 2, 3;
--Join  with ORDER BY
--Testcase 257:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t1.j, t2.k FROM J1_TBL t1 LEFT JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i, t2.i;
--Testcase 258:
SELECT t1.i, t2.i, t1.j, t2.k FROM J1_TBL t1 LEFT JOIN J2_TBL t2 ON t1.i = t2.i ORDER BY t1.i, t2.i;
--Testcase 259:
EXPLAIN VERBOSE SELECT t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 using(i) ORDER BY t1.i;
--Testcase 260:
SELECT t2.i, t2.k FROM J1_TBL t1 FULL JOIN J2_TBL t2 using(i) ORDER BY t1.i;
--Testcase 261:
EXPLAIN VERBOSE SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t, J2_TBL.i, J2_TBL.k FROM J1_TBL CROSS JOIN J2_TBL ORDER BY J1_TBL.i;
--Testcase 262:
SELECT J1_TBL.i, J1_TBL.j, J1_TBL.t, J2_TBL.i, J2_TBL.k FROM J1_TBL CROSS JOIN J2_TBL ORDER BY J1_TBL.i;
--Testcase 263:
EXPLAIN VERBOSE SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i ORDER BY t1.i;
--Testcase 264:
SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i ORDER BY t1.i;
--Testcase 265:
EXPLAIN VERBOSE SELECT t2.i FROM J1_TBL t1 RIGHT JOIN J2_TBL t2 ON t2.i = t1.i ORDER BY t2.i;
--Testcase 266:
SELECT t2.i FROM J1_TBL t1 RIGHT JOIN J2_TBL t2 ON t2.i = t1.i ORDER BY t2.i;
--Testcase 267:
EXPLAIN VERBOSE SELECT t1.i, t2.k, t3.i FROM J1_TBL t1 RIGHT JOIN (J2_TBL t2 LEFT JOIN J3_TBL t3 ON t2.i > t3.i INNER JOIN J1_TBL t4 ON t2.i = t4.i) ON t1.i = t2.i AND t1.t != t3.t ORDER BY t1.i, t2.k, t3.i;
--Testcase 268:
SELECT t1.i, t2.k, t3.i FROM J1_TBL t1 RIGHT JOIN (J2_TBL t2 LEFT JOIN J3_TBL t3 ON t2.i > t3.i INNER JOIN J1_TBL t4 ON t2.i = t4.i) ON t1.i = t2.i AND t1.t != t3.t ORDER BY t1.i, t2.k, t3.i;
--Pattern 10
--Join 
--Testcase 269:
EXPLAIN VERBOSE SELECT tx.ii, tx.jj, tx.kk FROM (J1_TBL t1 (a, b, c, s) CROSS JOIN J2_TBL t2 (d, e, s)) AS tx (ii, jj, tt, ii2, kk, ss1, ss2);
--Testcase 270:
SELECT tx.ii, tx.jj, tx.kk FROM (J1_TBL t1 (a, b, c, s) CROSS JOIN J2_TBL t2 (d, e, s)) AS tx (ii, jj, tt, ii2, kk, ss1, ss2);
--Testcase 271:
EXPLAIN VERBOSE SELECT i, j, t FROM J1_TBL RIGHT JOIN J2_TBL USING (i);
--Testcase 272:
SELECT i, j, t FROM J1_TBL RIGHT JOIN J2_TBL USING (i);
--Testcase 273:
EXPLAIN VERBOSE SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i);
--Testcase 274:
SELECT i, k, t FROM J1_TBL FULL JOIN J2_TBL USING (i);
--Testcase 275:
EXPLAIN VERBOSE SELECT i, t FROM J1_TBL LEFT JOIN J2_TBL USING (i);
--Testcase 276:
SELECT i, t FROM J1_TBL LEFT JOIN J2_TBL USING (i);
--Testcase 277:
EXPLAIN VERBOSE SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i;
--Testcase 278:
SELECT t1.i FROM J1_TBL AS t1 INNER JOIN J2_TBL AS t2 ON t1.i = t2.i;
--Testcase 279:
EXPLAIN VERBOSE SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1;
--Testcase 280:
SELECT t1.i, j, t3.t FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i LEFT JOIN J3_TBL t3 ON t3.i = 1;
--Testcase 281:
EXPLAIN VERBOSE SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i;
--Testcase 282:
SELECT t1.i, t2.i, t3.i, t4.i FROM J1_TBL AS t1 LEFT JOIN J2_TBL AS t2 ON t1.i = t2.i RIGHT JOIN J3_TBL AS t3 INNER JOIN J1_TBL AS t4 ON t4.i = t3.i ON t1.i = t3.i;
--Join  + aggregate functions  + GROUP BY
--Testcase 283:
EXPLAIN VERBOSE SELECT count(*) FROM J1_TBL a INNER JOIN J2_TBL b ON a.i = b.i GROUP BY a.i, b.i;
--Testcase 284:
SELECT count(*) FROM J1_TBL a INNER JOIN J2_TBL b ON a.i = b.i GROUP BY a.i, b.i;
--Testcase 285:
EXPLAIN VERBOSE SELECT count(J1_TBL.i) AS x, J1_TBL.j AS y FROM J1_TBL LEFT JOIN J2_TBL ON J1_TBL.i=J2_TBL.i GROUP BY J1_TBL.j, J1_TBL.i;
--Testcase 286:
SELECT count(J1_TBL.i) AS x, J1_TBL.j AS y FROM J1_TBL LEFT JOIN J2_TBL ON J1_TBL.i=J2_TBL.i GROUP BY J1_TBL.j, J1_TBL.i;
--Testcase 287:
EXPLAIN VERBOSE SELECT sum(J1_TBL.i), avg(J1_TBL.j) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i;
--Testcase 288:
SELECT sum(J1_TBL.i), avg(J1_TBL.j) FROM J1_TBL CROSS JOIN J2_TBL GROUP BY J1_TBL.i;
--Testcase 289:
EXPLAIN VERBOSE SELECT max(J1_TBL.t || '111'), min(J2_TBL.i) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) GROUP BY J1_TBL.i, J2_TBL.i;
--Testcase 290:
SELECT max(J1_TBL.t || '111'), min(J2_TBL.i) FROM J1_TBL RIGHT JOIN J2_TBL USING (i) GROUP BY J1_TBL.i, J2_TBL.i;
--Testcase 291:
EXPLAIN VERBOSE SELECT t1.i, min(t1.j), max(t2.i), sum(t2.k) FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i GROUP BY t1.i, t1.t;
--Testcase 292:
SELECT t1.i, min(t1.j), max(t2.i), sum(t2.k) FROM J1_TBL t1 FULL JOIN J2_TBL t2 ON t1.i = t2.i GROUP BY t1.i, t1.t;
--Testcase 293:
EXPLAIN VERBOSE SELECT sum(t1.i + t2.i), avg(t1.i - t2.i) FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t1.i = t2.i CROSS JOIN J2_TBL t3 GROUP BY t1.i, t2.i;
--Testcase 294:
SELECT sum(t1.i + t2.i), avg(t1.i - t2.i) FROM J1_TBL t1 INNER JOIN J2_TBL t2 ON t1.i = t2.i CROSS JOIN J2_TBL t3 GROUP BY t1.i, t2.i;
