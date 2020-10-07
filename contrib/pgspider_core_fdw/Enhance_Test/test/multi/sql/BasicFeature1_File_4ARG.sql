------------------------------BasicFeature1_File_4ARG-----------------------------
-- Testcase 1:
SELECT * FROM tmp_t11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 2:
SELECT * FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 3:
SELECT * FROM view_t11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 4:
SELECT c20, c21, c22, c24, c25, c26, c27, __spd_url FROM tmp_t11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 5:
SELECT c20, c21, c22, c24, c25, c26, c27, __spd_url FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 6:
SELECT c20, c21, c22, c24, c25, c26, c27, __spd_url FROM view_t11 ORDER BY c6 ASC, c20, c21 ASC, c22 ASC, c24 ASC, c27 DESC, __spd_url;
-- Testcase 7:
SELECT __spd_url FROM tmp_t11 ORDER BY 1;
-- Testcase 8:
SELECT __spd_url FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1;
-- Testcase 9:
SELECT __spd_url FROM view_t11 ORDER BY 1;
-- Testcase 10:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 11:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 12:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 13:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 14:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 15:
SELECT max(c22), max(27), max(28*c14) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 16:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 17:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 18:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 19:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 20:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 21:
SELECT max(c22), max(27), max(28*c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 22:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 23:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 24:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 25:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 26:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 27:
SELECT max(c22), max(27), max(28*c14) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 28:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 29:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 30:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 31:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 32:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 33:
SELECT max(c28), min(c14*c22) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 34:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 35:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 36:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 37:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 38:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 39:
SELECT max(c28), min(c14*c22) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 40:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 41:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 42:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 43:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 44:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 45:
SELECT max(c28), min(c14*c22) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 46:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 47:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 48:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 49:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 50:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 51:
SELECT min(c21), min(12+c27), min(c21) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 52:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 53:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 54:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 55:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 56:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 57:
SELECT min(c21), min(12+c27), min(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 58:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 59:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 60:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 61:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 62:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 63:
SELECT min(c21), min(12+c27), min(c21) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 64:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 65:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 66:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 67:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 68:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 69:
SELECT min(c14), sum(c22+c27), max(c21) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 70:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 71:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 72:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 73:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 74:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 75:
SELECT min(c14), sum(c22+c27), max(c21) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 76:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 77:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 78:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 79:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 80:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 81:
SELECT min(c14), sum(c22+c27), max(c21) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 82:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 83:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 84:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 85:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 86:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 87:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 88:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 89:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 90:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 91:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 92:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 93:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 94:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 95:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 96:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 97:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 98:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 99:
SELECT sum(c12), sum(c21), sum(c1+c28) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 100:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 101:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 102:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 103:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 104:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 105:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 106:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 107:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 108:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 109:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 110:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 111:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 112:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 113:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 114:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 115:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 116:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 117:
SELECT sum(c1+c22), max(c14), min(c12)-5 FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 118:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 119:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 120:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 121:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 122:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 123:
SELECT avg(c1), avg(c28) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 124:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 125:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 126:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 127:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 128:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 129:
SELECT avg(c1), avg(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 130:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 131:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 132:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 133:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 134:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 135:
SELECT avg(c1), avg(c28) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 136:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 137:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 138:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 139:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 140:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 141:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 142:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 143:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 144:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 145:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 146:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 147:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 148:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 149:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 150:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 151:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 152:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 153:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 154:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 155:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 156:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 157:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 158:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 159:
SELECT stddev(c1), stddev(c27) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 160:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 161:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 162:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 163:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 164:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 165:
SELECT stddev(c1), stddev(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 166:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 167:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 168:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 169:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 170:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 171:
SELECT stddev(c1), stddev(c27) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 172:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 173:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 174:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 175:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 176:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 177:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 178:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 179:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 180:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 181:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 182:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 183:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 184:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 185:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 186:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 187:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 188:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 189:
SELECT array_agg(c3 ORDER BY c3), array_agg(c2 ORDER BY c2) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 190:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 191:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 192:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 193:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 194:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 195:
SELECT bit_and(c1), bit_or(c28) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 196:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 197:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 198:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 199:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 200:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 201:
SELECT bit_and(c1), bit_or(c28) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 202:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 203:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 204:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 205:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 206:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 207:
SELECT bit_and(c1), bit_or(c28) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 208:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 209:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 210:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 211:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 212:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 213:
SELECT bit_or(c14) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 214:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1;
-- Testcase 215:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 216:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 217:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 218:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 219:
SELECT bit_or(c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 220:
SELECT bit_or(c14) FROM view_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 221:
SELECT bit_or(c14) FROM view_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 222:
SELECT bit_or(c14) FROM view_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 223:
SELECT bit_or(c14) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 224:
SELECT bit_or(c14) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 225:
SELECT bit_or(c14) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 226:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 227:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 228:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 229:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 230:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 231:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 232:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 233:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 234:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 235:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 236:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 237:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 238:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 239:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 240:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 241:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 242:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 243:
SELECT bool_and(c7='1'), bool_or(c14 != 0) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 244:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 245:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 246:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 247:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 248:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 249:
SELECT bool_or(c27< 15) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 250:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1;
-- Testcase 251:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 252:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 253:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 254:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 255:
SELECT bool_or(c27< 15) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 256:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 257:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 258:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 259:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 260:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 261:
SELECT bool_or(c27< 15) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 262:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 263:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 264:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 265:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 266:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 267:
SELECT string_agg(c29, ',' ORDER BY c29) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 268:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1;
-- Testcase 269:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 270:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 271:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 272:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 273:
SELECT string_agg(c29, ',' ORDER BY c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 274:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 275:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 276:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 277:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 278:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 279:
SELECT string_agg(c29, ',' ORDER BY c29) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 280:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 281:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 282:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 283:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 284:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 285:
SELECT every(c28>0), every(c1=c14) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 286:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 287:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 288:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 289:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 290:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 291:
SELECT every(c28>0), every(c1=c14) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 292:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 293:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 294:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 DESC, 2 ASC;
-- Testcase 295:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 296:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 DESC, 2 ASC;
-- Testcase 297:
SELECT every(c28>0), every(c1=c14) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 298:
SELECT sqrt(abs(c12))+sqrt(abs(c27)) FROM tmp_t11 ORDER BY 1;
-- Testcase 299:
SELECT sqrt(abs(c12))+sqrt(abs(c27)) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1;
-- Testcase 300:
SELECT sqrt(abs(c12))+sqrt(abs(c27)) FROM view_t11 ORDER BY 1;
-- Testcase 301:
SELECT upper(c8), upper(c7), upper(__spd_url), lower(c29) FROM tmp_t11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 302:
SELECT upper(c8), upper(c7), upper(__spd_url), lower(c29) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 303:
SELECT upper(c8), upper(c7), upper(__spd_url), lower(c29) FROM view_t11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 304:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 305:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 306:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 307:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 308:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 309:
SELECT max(c1), min(c12), count(*), avg(c27) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 310:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 311:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 312:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 313:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 314:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 315:
SELECT max(c1), min(c12), count(*), avg(c27) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 316:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 317:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 318:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 319:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 320:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 321:
SELECT max(c1), min(c12), count(*), avg(c27) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 322:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 323:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 324:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 325:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 326:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 327:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 328:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 329:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 330:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 331:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 332:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 333:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 334:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 335:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 336:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 337:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 338:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 339:
SELECT c13, max(c12), min(c14), sum(c22), count(c20) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 340:
SELECT c1*  (random()<=1)::int, (random()<=1)::int * c28+10 FROM tmp_t11 ORDER BY 1 DESC, 2 ASC;
-- Testcase 341:
SELECT c1*  (random()<=1)::int, (random()<=1)::int * c28+10 FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1 DESC, 2 ASC;
-- Testcase 342:
SELECT c1*  (random()<=1)::int, (random()<=1)::int * c28+10 FROM view_t11 ORDER BY 1 DESC, 2 ASC;
-- Testcase 343:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 344:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 345:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 346:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 347:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 348:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 349:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 350:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 351:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 352:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 353:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 354:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 355:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 356:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c1, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 357:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c13, c33 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 358:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 359:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 360:
SELECT max(c12), count(*), exists(SELECT * FROM tmp_t11 WHERE c8>='ahihi') FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 361:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 362:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 363:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 364:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 365:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 366:
SELECT sum(c22) filter (WHERE c14>=0) FROM tmp_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 367:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13 ORDER BY 1;
-- Testcase 368:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 369:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 370:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 371:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 372:
SELECT sum(c22) filter (WHERE c14>=0) FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 373:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c13 ORDER BY 1;
-- Testcase 374:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c1, c13 ORDER BY 1;
-- Testcase 375:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c13, c33 ORDER BY 1;
-- Testcase 376:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c1, c13 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 377:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c2, c12 HAVING count(c2) != '1010101100' AND c12 != 40.216 ORDER BY 1;
-- Testcase 378:
SELECT sum(c22) filter (WHERE c14>=0) FROM view_t11 GROUP BY c13, c14, c27, __spd_url HAVING c14 != 3 AND c27=0 and __spd_url != '/hi/' ORDER BY 1;
-- Testcase 379:
SELECT c33, 9231+c28*(random()<=1)::int, 'Lamsao' FROM tmp_t11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 380:
SELECT c33, 9231+c28*(random()<=1)::int, 'Lamsao' FROM ( SELECT * FROM tmp_t11 WHERE c12>=0 AND c4='t' ) AS tb11 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 381:
SELECT c33, 9231+c28*(random()<=1)::int, 'Lamsao' FROM view_t11 ORDER BY 1 ASC, 2 DESC, 3;
