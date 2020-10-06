------------------------------BasicFeature1_MySQL_4ARG-----------------------------
-- Testcase 1:
SELECT * FROM t3 ORDER BY 1, 2 ASC, 3 DESC, 4, __spd_url;
-- Testcase 2:
SELECT * FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1, 2 ASC, 3 DESC, 4, __spd_url;
-- Testcase 3:
SELECT * FROM view_t3 ORDER BY 1, 2 ASC, 3 DESC, 4, __spd_url;
-- Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 5:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 6:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM view_t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 7:
SELECT  c11, c12, c13, c14, c15 FROM t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 8:
SELECT  c11, c12, c13, c14, c15 FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 9:
SELECT  c11, c12, c13, c14, c15 FROM view_t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 10:
SELECT c16, c17, c18, c19, c20, c21, c22, c23, c24 FROM t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 11:
SELECT c16, c17, c18, c19, c20, c21, c22, c23, c24 FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 12:
SELECT c16, c17, c18, c19, c20, c21, c22, c23, c24 FROM view_t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 13:
SELECT __spd_url FROM t3 ORDER BY 1;
-- Testcase 14:
SELECT __spd_url FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1;
-- Testcase 15:
SELECT __spd_url FROM view_t3 ORDER BY 1;
-- Testcase 16:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 17:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 18:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 19:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 20:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 21:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 22:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 23:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 24:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 25:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 26:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 27:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 28:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 29:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 30:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 31:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 32:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 33:
SELECT max(c1), max(c2)+1, max(c3)+2, max(c4)*0.5, max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c12) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 34:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 35:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 36:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 37:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 38:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 39:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 40:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 41:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 42:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 43:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 44:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 45:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 46:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 47:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 48:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 49:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 50:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 51:
SELECT max(c13), max(c14), max(c15), max(c1*0.5+10), max(c9*c10) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 52:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 53:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 54:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 55:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 56:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 57:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 58:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 59:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 60:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 61:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 62:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 63:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 64:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 65:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 66:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 67:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 68:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 69:
SELECT min(c1), min(c2)+10, min(c3)-10, min(c4)*2, min(c5), min(c6), min(c7), min(c8), min(c9), min(c10), min(c12) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 70:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 71:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 72:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 73:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 74:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 75:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 76:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 77:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 78:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 79:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 80:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 81:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 82:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 83:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 84:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 85:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 86:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 87:
SELECT min(c3-c1), min(c6+c7), min(c12+'1 year'::interval) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 88:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 89:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 90:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 91:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 92:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 93:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 94:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 95:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 96:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 97:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 98:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 99:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 100:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 101:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 102:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 103:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 104:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 105:
SELECT sum(c1), sum(c2), sum(c3), sum(c4), sum(c5) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 106:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 107:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 108:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 109:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 110:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 111:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 112:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 113:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 114:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 115:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 116:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 117:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 118:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 119:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 120:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 121:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 122:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 123:
SELECT sum(c10-1000), sum(c13)-'24:00:00'::interval FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 124:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 125:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 126:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 127:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 128:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 129:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 130:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 131:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 132:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 133:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 134:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 135:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 136:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 137:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 138:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 139:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 140:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 141:
SELECT avg(c1), avg(c2), avg(c3), avg(c4), avg(c5), avg(c6), avg(c7), avg(c7) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 142:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 143:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 144:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 145:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 146:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 147:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 148:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 149:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 150:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 151:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 152:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 153:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 154:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 155:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 156:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 157:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 158:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 159:
SELECT count(*), count(c11), count (DISTINCT c12), count (ALL c13) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 160:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 161:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 162:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 163:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 164:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 165:
SELECT stddev(c3), stddev(c4) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 166:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 167:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 168:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 169:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 170:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 171:
SELECT stddev(c3), stddev(c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 172:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 173:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 174:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 175:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 176:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 177:
SELECT stddev(c3), stddev(c4) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 178:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 179:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 180:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 181:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 182:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 183:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 184:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 185:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 186:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 187:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 188:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 189:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 190:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 191:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 192:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 193:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 194:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 195:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 196:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 197:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 198:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 199:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 200:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 201:
SELECT bit_and(c5), bit_and(c3-c2) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 202:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 203:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 204:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 205:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 206:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 207:
SELECT bit_and(c5), bit_and(c3-c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 208:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1 ORDER BY 1, 2 DESC;
-- Testcase 209:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1, c14 ORDER BY 1, 2 DESC;
-- Testcase 210:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1, 2 DESC;
-- Testcase 211:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1, 2 DESC;
-- Testcase 212:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1, 2 DESC;
-- Testcase 213:
SELECT bit_and(c5), bit_and(c3-c2) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1, 2 DESC;
-- Testcase 214:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 215:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 216:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 217:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 218:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 219:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 220:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 221:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 222:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 223:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 224:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 225:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 226:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 227:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 228:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 229:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 230:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 231:
SELECT bit_or(c1), bit_or(c2), bit_or(c3+10), bit_or(c4-c3) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 232:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 233:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 234:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 235:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 236:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 237:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 238:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 239:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 240:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 241:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 242:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 243:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 244:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 245:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 246:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 247:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 248:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 249:
SELECT bool_and(c1>0), bool_and(c15>'2021-03-18 23:14:07'), bool_and(c8 != c7) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 250:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 251:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 252:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 253:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 254:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 255:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 256:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 257:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 258:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 259:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 260:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 261:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 262:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 263:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 264:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 265:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 266:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 267:
SELECT bool_or(c1 != c2), bool_or(c3>0), bool_or(c4=0), bool_or(c15<'2021-03-18 23:14:07'), bool_or(c17 != '0123456789') FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4, 5 ASC;
-- Testcase 268:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1 ORDER BY 1;
-- Testcase 269:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 270:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 271:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 272:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 273:
SELECT string_agg(c17, ','  ORDER BY c17) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 274:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1;
-- Testcase 275:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 276:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 277:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 278:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 279:
SELECT string_agg(c17, ','  ORDER BY c17) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 280:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1 ORDER BY 1;
-- Testcase 281:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 282:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 283:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 284:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 285:
SELECT string_agg(c17, ','  ORDER BY c17) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 286:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 287:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 288:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 289:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 290:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 291:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 292:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 293:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 294:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 295:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 296:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 297:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 298:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 299:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 300:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 301:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 302:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 303:
SELECT every(c1 != c2), every(c6 != c7), every(c17 != 'いろはにほへど　ちりぬるをわがよたれぞ'), every(c1<c2 AND c3>c7) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 304:
SELECT sqrt(abs(c1)), sqrt(abs(c8-10*10)), sqrt(5*4+5) FROM t3 ORDER BY 1, 2 DESC;
-- Testcase 305:
SELECT sqrt(abs(c1)), sqrt(abs(c8-10*10)), sqrt(5*4+5) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1, 2 DESC;
-- Testcase 306:
SELECT sqrt(abs(c1)), sqrt(abs(c8-10*10)), sqrt(5*4+5) FROM view_t3 ORDER BY 1, 2 DESC;
-- Testcase 307:
SELECT upper(__spd_url),upper(c17), upper(c18), lower(c20), lower(c22) FROM t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 308:
SELECT upper(__spd_url),upper(c17), upper(c18), lower(c20), lower(c22) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 309:
SELECT upper(__spd_url),upper(c17), upper(c18), lower(c20), lower(c22) FROM view_t3 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 310:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 311:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 312:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 313:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 314:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 315:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 316:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 317:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 318:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 319:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 320:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 321:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 322:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 323:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1, c14 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 324:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 325:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 326:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 327:
SELECT max(c12), min(c13), sum(c4-c3), count(*), avg(c2) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 ASC, 2 DESC, 3 ASC, 4;
-- Testcase 328:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM t3 ORDER BY 1;
-- Testcase 329:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 330:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 331:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 332:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 333:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1;
-- Testcase 334:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 335:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 336:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 337:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 338:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM view_t3 ORDER BY 1;
-- Testcase 339:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM view_t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 340:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 341:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 342:
SELECT c14, max(15), min(c14), sum(c5), count(c12), avg(c6) FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 343:
SELECT c1* (random()<=1)::int,  (random()<=1)::int+10+c2 FROM t3 ORDER BY 1, 2 DESC;
-- Testcase 344:
SELECT c1* (random()<=1)::int,  (random()<=1)::int+10+c2 FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1, 2 DESC;
-- Testcase 345:
SELECT c1* (random()<=1)::int,  (random()<=1)::int+10+c2 FROM view_t3 ORDER BY 1, 2 DESC;
-- Testcase 346:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 347:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 348:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 349:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 350:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 351:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 352:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 353:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 354:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 355:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 356:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 357:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 358:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 359:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1, c14 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 360:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 361:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 362:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 363:
SELECT max(c16), max(c17), exists (SELECT max(c15) FROM t3 WHERE c1 != c4 and c22 like '.')  FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 364:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1 ORDER BY 1;
-- Testcase 365:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 366:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 367:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 368:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 369:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 370:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 ORDER BY 1;
-- Testcase 371:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 372:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 373:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 374:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 375:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 376:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1 ORDER BY 1;
-- Testcase 377:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1, c14 ORDER BY 1;
-- Testcase 378:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1, c14, c17 ORDER BY 1;
-- Testcase 379:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1 HAVING min(c1)<0 AND avg(c1) != 0.5 AND sum(c1)<>0 ORDER BY 1;
-- Testcase 380:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1, c14 HAVING avg(c1) != 1 AND max(c14)>'1000-01-01 00:00:01' ORDER BY 1;
-- Testcase 381:
SELECT sum(c4) filter( WHERE c15>'2021-03-18 23:14:07' and c4<1000)  FROM view_t3 GROUP BY c1, c14, c17 HAVING c1 != 3 AND sum(c1)<>0 AND c17 != '0123456789' ORDER BY 1;
-- Testcase 382:
SELECT c1, 'NEWYORK', c2, 100, c3, c9 * c10, upper(c24)  FROM t3 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 383:
SELECT c1, 'NEWYORK', c2, 100, c3, c9 * c10, upper(c24)  FROM (SELECT * FROM t3 WHERE c8>5) as tb3 ORDER BY 1 DESC, 2 ASC, 3 DESC;
-- Testcase 384:
SELECT c1, 'NEWYORK', c2, 100, c3, c9 * c10, upper(c24)  FROM view_t3 ORDER BY 1 DESC, 2 ASC, 3 DESC;
