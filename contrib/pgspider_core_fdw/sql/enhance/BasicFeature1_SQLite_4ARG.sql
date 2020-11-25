------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature1_SQLite_4ARG-----------------------------
-- Testcase 1:
SELECT * FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6, __spd_url;
-- Testcase 2:
SELECT * FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6, __spd_url;
-- Testcase 3:
SELECT * FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6, __spd_url;
-- Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7 FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 5:
SELECT c1, c2, c3, c4, c5, c6, c7 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 6:
SELECT c1, c2, c3, c4, c5, c6, c7 FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 7:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 8:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 9:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 10:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 11:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 12:
SELECT c8, c9, c10, c11, c12, c13, c14, c15, c16 , c17, c18, c19, c2, c21, c22, c23, c24 FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 13:
SELECT __spd_url FROM t13 ORDER BY 1;
-- Testcase 14:
SELECT __spd_url FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY 1;
-- Testcase 15:
SELECT __spd_url FROM view_t13 ORDER BY 1;
-- Testcase 16:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 17:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 18:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 19:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 20:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 21:
SELECT max(c1), max(c2*1), max(c3-3) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 22:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 23:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 24:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 25:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 26:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 27:
SELECT max(c1), max(c2*1), max(c3-3) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 28:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 29:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 30:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 31:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 32:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 33:
SELECT max(c1), max(c2*1), max(c3-3) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 34:
SELECT min(c23), max(c18) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 35:
SELECT min(c23), max(c18) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 36:
SELECT min(c23), max(c18) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 37:
SELECT min(c23), max(c18) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 38:
SELECT min(c23), max(c18) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 39:
SELECT min(c23), max(c18) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 40:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 41:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 42:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 43:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 44:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 45:
SELECT min(c23), max(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 46:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 47:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 48:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 49:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 50:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 51:
SELECT min(c23), max(c18) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 52:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 53:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 54:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 55:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 56:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 57:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 58:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 59:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 60:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 61:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 62:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 63:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 64:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 65:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 66:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 67:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 68:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 69:
SELECT min(c4), min(c5), min(c6+5), min(c7*0) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 70:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 71:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 72:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 73:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 74:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 75:
SELECT sum(c17), sum(c18/2) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 76:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 77:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 78:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 79:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 80:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 81:
SELECT sum(c17), sum(c18/2) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 82:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 83:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 84:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 85:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 86:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 87:
SELECT sum(c17), sum(c18/2) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 88:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 89:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 90:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 91:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 92:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 93:
SELECT avg(c19), sum(c20)*2 FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 94:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 95:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 96:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 97:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 98:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 99:
SELECT avg(c19), sum(c20)*2 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 100:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 101:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 102:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 103:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 104:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 105:
SELECT avg(c19), sum(c20)*2 FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 106:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 107:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 108:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 109:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 110:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 111:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 112:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 113:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 114:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 115:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 116:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 117:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 118:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 119:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c2, c14 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 120:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 121:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 122:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 123:
SELECT count(*), count (ALL c10) , count(c8), count (DISTINCT c9) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 124:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 125:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 126:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 127:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 128:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 129:
SELECT stddev(c21), stddev(c22) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 130:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 131:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 132:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 133:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 134:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 135:
SELECT stddev(c21), stddev(c22) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 136:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 137:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 138:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 139:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 140:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 141:
SELECT stddev(c21), stddev(c22) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 142:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 143:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 144:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 145:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 146:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 147:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 148:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 149:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 150:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 151:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 152:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 153:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 154:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 155:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 156:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 157:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 158:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 159:
SELECT array_agg(c17 ORDER BY c17), array_agg(c18 ORDER BY c18) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 160:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 161:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 162:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 163:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 164:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 165:
SELECT bit_and(c2), bit_and(c5) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 166:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 167:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 168:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 169:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 170:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 171:
SELECT bit_and(c2), bit_and(c5) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 172:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 173:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 174:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 175:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 176:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 177:
SELECT bit_and(c2), bit_and(c5) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 178:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 179:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 180:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 181:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 182:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 183:
SELECT bit_or(c7), bit_and(c6) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 184:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 185:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 186:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 187:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 188:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 189:
SELECT bit_or(c7), bit_and(c6) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 190:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 191:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 192:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 193:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 194:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 195:
SELECT bit_or(c7), bit_and(c6) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 196:
SELECT bool_and(c21>1) FROM t13 GROUP BY c14 ORDER BY 1;
-- Testcase 197:
SELECT bool_and(c21>1) FROM t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 198:
SELECT bool_and(c21>1) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 199:
SELECT bool_and(c21>1) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 200:
SELECT bool_and(c21>1) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 201:
SELECT bool_and(c21>1) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 202:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1;
-- Testcase 203:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 204:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 205:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 206:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 207:
SELECT bool_and(c21>1) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 208:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c14 ORDER BY 1;
-- Testcase 209:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 210:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 211:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 212:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 213:
SELECT bool_and(c21>1) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 214:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c14 ORDER BY 1;
-- Testcase 215:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 216:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 217:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 218:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 219:
SELECT bool_or(c22<99999) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 220:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1;
-- Testcase 221:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 222:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 223:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 224:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 225:
SELECT bool_or(c22<99999) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 226:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c14 ORDER BY 1;
-- Testcase 227:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 228:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 229:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 230:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 231:
SELECT bool_or(c22<99999) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 232:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c14 ORDER BY 1;
-- Testcase 233:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 234:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 235:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 236:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 237:
SELECT string_agg(c9, ',' ORDER BY c9) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 238:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1;
-- Testcase 239:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 240:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 241:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 242:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 243:
SELECT string_agg(c9, ',' ORDER BY c9) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 244:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c14 ORDER BY 1;
-- Testcase 245:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 246:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 247:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 248:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 249:
SELECT string_agg(c9, ',' ORDER BY c9) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 250:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 251:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 252:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 253:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 254:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 255:
SELECT every(c5<1090), every(c6>c7) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 256:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 257:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 258:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 259:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 260:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 261:
SELECT every(c5<1090), every(c6>c7) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 262:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c14 ORDER BY 1 DESC, 2;
-- Testcase 263:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c2, c14 ORDER BY 1 DESC, 2;
-- Testcase 264:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1 DESC, 2;
-- Testcase 265:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1 DESC, 2;
-- Testcase 266:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1 DESC, 2;
-- Testcase 267:
SELECT every(c5<1090), every(c6>c7) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1 DESC, 2;
-- Testcase 268:
SELECT sqrt(abs(c20)) FROM t13 ORDER BY 1;
-- Testcase 269:
SELECT sqrt(abs(c20)) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY 1;
-- Testcase 270:
SELECT sqrt(abs(c20)) FROM view_t13 ORDER BY 1;
-- Testcase 271:
SELECT upper(__spd_url), upper(c8), lower(c12), upper(c10), lower(c11) FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 272:
SELECT upper(__spd_url), upper(c8), lower(c12), upper(c10), lower(c11) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 273:
SELECT upper(__spd_url), upper(c8), lower(c12), upper(c10), lower(c11) FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 274:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 275:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 276:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 277:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 278:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 279:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 280:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 281:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 282:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 283:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 284:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 285:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 286:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 287:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 288:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 289:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 290:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 291:
SELECT  count(*), max(c17), min(c2), sum(c3/c4), avg(c18) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5;
-- Testcase 292:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 293:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 294:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 295:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 296:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 297:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 298:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 299:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 300:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 301:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 302:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 303:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 304:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 GROUP BY c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 305:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 GROUP BY c2, c14 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 306:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 307:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 308:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 309:
SELECT c14, max(c6), min(c5), sum(c19), count(c20), avg(c21) FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY  1 ASC, 2, 3 ASC, 4 ASC, 5 ASC, 6;
-- Testcase 310:
SELECT c17* (random()<=1)::int, (random()<=1)::int*5 FROM t13 ORDER BY 1 DESC, 2;
-- Testcase 311:
SELECT c17* (random()<=1)::int, (random()<=1)::int*5 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY 1 DESC, 2;
-- Testcase 312:
SELECT c17* (random()<=1)::int, (random()<=1)::int*5 FROM view_t13 ORDER BY 1 DESC, 2;
-- Testcase 313:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 314:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 315:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 316:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 317:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 318:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 319:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 320:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 321:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 322:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 323:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 324:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 325:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 326:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c2, c14 ORDER BY 1, 2, 3 DESC;
-- Testcase 327:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1, 2, 3 DESC;
-- Testcase 328:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1, 2, 3 DESC;
-- Testcase 329:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1, 2, 3 DESC;
-- Testcase 330:
SELECT max(c2), count(*), exists(SELECT * FROM t13 WHERE c13> 'আমি আজ খুব খুশি আমি আজ খুব খুশি') FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1, 2, 3 DESC;
-- Testcase 331:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c14 ORDER BY 1;
-- Testcase 332:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 333:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 334:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 335:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 336:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 337:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14 ORDER BY 1;
-- Testcase 338:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 339:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 340:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 341:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 342:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 343:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c14 ORDER BY 1;
-- Testcase 344:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c2, c14 ORDER BY 1;
-- Testcase 345:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c9, c14, __spd_url ORDER BY 1;
-- Testcase 346:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c1, c2, c3 HAVING avg(c1)<1 OR max(c2)<>211532 OR sum(c3)<3000 ORDER BY 1;
-- Testcase 347:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c10, c11, c12, c13, c14 HAVING c14 != 'a243141411' ORDER BY 1;
-- Testcase 348:
SELECT sum(c5) filter (WHERE c13='ABCD') FROM view_t13 GROUP BY c14, c23, c24 HAVING min(c23)<'2021-12-30' AND c24 != '9999-12-31 23:59:59' ORDER BY 1;
-- Testcase 349:
SELECT 100 - c4+(random()<=1)::int, 'happy',  c16, c15 FROM t13 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 350:
SELECT 100 - c4+(random()<=1)::int, 'happy',  c16, c15 FROM (SELECT * FROM t13 WHERE c1>500 OR c2!=7273 ) AS tb13 ORDER BY 1  ASC, 2 DESC, 3, 4;
-- Testcase 351:
SELECT 100 - c4+(random()<=1)::int, 'happy',  c16, c15 FROM view_t13 ORDER BY 1  ASC, 2 DESC, 3, 4;
