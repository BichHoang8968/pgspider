------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature1_TinyBrace_4ARG-----------------------------
-- Testcase 1:
SELECT * FROM t5 ORDER BY  1 ASC, 2 DESC, 3 ASC, 4, 5 DESC, 6, 7 ASC,  8, 9 ASC, 10, __spd_url;
-- Testcase 2:
SELECT * FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY  1 ASC, 2 DESC, 3 ASC, 4, 5 DESC, 6, 7 ASC,  8, 9 ASC, 10, __spd_url;
-- Testcase 3:
SELECT * FROM view_t5 ORDER BY  1 ASC, 2 DESC, 3 ASC, 4, 5 DESC, 6, 7 ASC,  8, 9 ASC, 10, __spd_url;
-- Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7, c17, c18, c19, c20 FROM t5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 5:
SELECT c1, c2, c3, c4, c5, c6, c7, c17, c18, c19, c20 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 6:
SELECT c1, c2, c3, c4, c5, c6, c7, c17, c18, c19, c20 FROM view_t5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 7:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16, c21, c22 FROM t5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 8:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16, c21, c22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 9:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16, c21, c22 FROM view_t5 ORDER BY  1 ASC, 2 ASC, 3 ASC, 4 ASC, 5 ASC, 6 ASC, 7 ASC,  8 ASC, 9 ASC, 10 ASC;
-- Testcase 10:
SELECT __spd_url FROM t5 ORDER BY 1 DESC;
-- Testcase 11:
SELECT __spd_url FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC;
-- Testcase 12:
SELECT __spd_url FROM view_t5 ORDER BY 1 DESC;
-- Testcase 13:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 14:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 15:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 16:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 17:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 18:
SELECT max(c21), min (c1*1) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 19:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 20:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 21:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 22:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 23:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 24:
SELECT max(c21), min (c1*1) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 25:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 26:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 27:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 28:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 29:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 30:
SELECT max(c21), min (c1*1) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 31:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 32:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 33:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 34:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 35:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 36:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 37:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 38:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 39:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 40:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 41:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 42:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 43:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 44:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 45:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 46:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 47:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 48:
SELECT max(c1), max(c2)/2, max(c3)-22 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 49:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 50:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 51:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 52:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 53:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 54:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 55:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 56:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 57:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 58:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 59:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 60:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 61:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 62:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 63:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 64:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 65:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 66:
SELECT min(c22), max(c18)*3-80, max(c4)%3 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 67:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 68:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 69:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 70:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 71:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 72:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 73:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 74:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 75:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 76:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 77:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 78:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 79:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 80:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 81:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 82:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 83:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 84:
SELECT min(c4), min(c5)+110, min(c6)*2, min(c7+c6) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 85:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 86:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 87:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 88:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 89:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 90:
SELECT sum(c17), sum(c18)-min(c2) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 91:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 92:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 93:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 94:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 95:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 96:
SELECT sum(c17), sum(c18)-min(c2) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 97:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 98:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 99:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 100:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 101:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 102:
SELECT sum(c17), sum(c18)-min(c2) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 103:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 104:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 105:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 106:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 107:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 108:
SELECT avg(c19), avg(c20)-100 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 109:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 110:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 111:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 112:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 113:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 114:
SELECT avg(c19), avg(c20)-100 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 115:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 116:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 117:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 118:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 119:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 120:
SELECT avg(c19), avg(c20)-100 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 121:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 122:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 123:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 124:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 125:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 126:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 127:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 128:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 129:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 130:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 131:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 132:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 133:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 134:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 135:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 136:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 137:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 138:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 139:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 140:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 141:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 142:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 143:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 144:
SELECT stddev(c19), stddev(c20)-1 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 145:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 146:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 147:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 148:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 149:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 150:
SELECT stddev(c19), stddev(c20)-1 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 151:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 152:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 153:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 154:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 155:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 156:
SELECT stddev(c19), stddev(c20)-1 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 157:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 158:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 159:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 160:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 161:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 162:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 163:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 164:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 165:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 166:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 167:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 168:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 169:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 170:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 171:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 172:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 173:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 174:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 175:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 176:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 177:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 178:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 179:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 180:
SELECT bit_and(c5), bit_and(c6)/2 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 181:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 182:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 183:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 184:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 185:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 186:
SELECT bit_and(c5), bit_and(c6)/2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 187:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 188:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 189:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 190:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 191:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 192:
SELECT bit_and(c5), bit_and(c6)/2 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 193:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 194:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 195:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 196:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 197:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 198:
SELECT bit_or(c7), bit_or(c1)*2 FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 199:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 200:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 201:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 202:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 203:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 204:
SELECT bit_or(c7), bit_or(c1)*2 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 205:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 206:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 207:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 208:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 209:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 210:
SELECT bit_or(c7), bit_or(c1)*2 FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 211:
SELECT bool_and(c4>15) FROM t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 212:
SELECT bool_and(c4>15) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 213:
SELECT bool_and(c4>15) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 214:
SELECT bool_and(c4>15) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 215:
SELECT bool_and(c4>15) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 216:
SELECT bool_and(c4>15) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 217:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 218:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 219:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 220:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 221:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 222:
SELECT bool_and(c4>15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 223:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 224:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 225:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 226:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 227:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 228:
SELECT bool_and(c4>15) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 229:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 230:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 231:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 232:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 233:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 234:
SELECT bool_or(c18< 15) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 235:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 236:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 237:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 238:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 239:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 240:
SELECT bool_or(c18< 15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 241:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 242:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 243:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 244:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 245:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 246:
SELECT bool_or(c18< 15) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 247:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 248:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 249:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 250:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 251:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 252:
SELECT string_agg(c8, ',' ORDER BY c8) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 253:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 254:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 255:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 256:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 257:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 258:
SELECT string_agg(c8, ',' ORDER BY c8) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 259:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 260:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 261:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 262:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 263:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 264:
SELECT string_agg(c8, ',' ORDER BY c8) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 265:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 266:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 267:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 268:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 269:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 270:
SELECT every(c19>0), every(c20=c19) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 271:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 272:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 273:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 274:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 275:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 276:
SELECT every(c19>0), every(c20=c19) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 277:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2;
-- Testcase 278:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2;
-- Testcase 279:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2;
-- Testcase 280:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2;
-- Testcase 281:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2;
-- Testcase 282:
SELECT every(c19>0), every(c20=c19) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2;
-- Testcase 283:
SELECT sqrt(abs(c5)) FROM t5 ORDER BY 1 DESC;
-- Testcase 284:
SELECT sqrt(abs(c5)) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC;
-- Testcase 285:
SELECT sqrt(abs(c5)) FROM view_t5 ORDER BY 1 DESC;
-- Testcase 286:
SELECT upper(c9), upper(c10), upper(__spd_url), lower(c11), lower(c12) FROM t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 287:
SELECT upper(c9), upper(c10), upper(__spd_url), lower(c11), lower(c12) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 288:
SELECT upper(c9), upper(c10), upper(__spd_url), lower(c11), lower(c12) FROM view_t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 289:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 290:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 291:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 292:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 293:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 294:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 295:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 296:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 297:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 298:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 299:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 300:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 301:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c1 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 302:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 303:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 304:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 305:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 306:
SELECT max(c1), min(c2), sum(c3), count(*), avg(c5) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 307:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 308:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 309:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 310:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 311:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 312:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 313:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM view_t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 314:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 315:
SELECT c13, max(c6), min(c17), sum(c19), count(c20), avg(c19+c20) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 316:
SELECT c3* (random()<=1)::int, (random()<=1)::int*(25+10)-34 FROM t5 ORDER BY 1 DESC, 2;
-- Testcase 317:
SELECT c3* (random()<=1)::int, (random()<=1)::int*(25+10)-34 FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC, 2;
-- Testcase 318:
SELECT c3* (random()<=1)::int, (random()<=1)::int*(25+10)-34 FROM view_t5 ORDER BY 1 DESC, 2;
-- Testcase 319:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 320:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 321:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 322:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 323:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 324:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 325:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 326:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 327:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 328:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 329:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 330:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 331:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c1 ORDER BY 1,2,3;
-- Testcase 332:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c1, c2 ORDER BY 1,2,3;
-- Testcase 333:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c2, c13 ORDER BY 1,2,3;
-- Testcase 334:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1,2,3;
-- Testcase 335:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1,2,3;
-- Testcase 336:
SELECT max(c2), count(*), exists(SELECT * FROM t5 WHERE c2>2^15) FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1,2,3;
-- Testcase 337:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 338:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 339:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 340:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 341:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 342:
SELECT sum(c5) filter (WHERE c15='b') FROM t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 343:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 344:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 345:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 346:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 347:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 348:
SELECT sum(c5) filter (WHERE c15='b') FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 349:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 350:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 351:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c2, c13 ORDER BY 1 DESC;
-- Testcase 352:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c1, c18, c19, c20 HAVING max(18)< 3000 AND sum(c19)< 3000 ORDER BY 1 DESC;
-- Testcase 353:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c14, c13, __spd_url HAVING c14>'a' ORDER BY 1 DESC;
-- Testcase 354:
SELECT sum(c5) filter (WHERE c15='b') FROM view_t5 GROUP BY c21, c22 HAVING  max(c22)> min(c21) ORDER BY 1 DESC;
-- Testcase 355:
SELECT 'ab12BD',  c16, 10+c4 * (random()<=1)::int, __spd_url FROM t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 356:
SELECT 'ab12BD',  c16, 10+c4 * (random()<=1)::int, __spd_url FROM ( SELECT * FROM t5 WHERE c1 !=5 or c2>0 ) as tb5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
-- Testcase 357:
SELECT 'ab12BD',  c16, 10+c4 * (random()<=1)::int, __spd_url FROM view_t5 ORDER BY 1 DESC, 2 ASC, 3 DESC, 4 DESC;
