------------------------------BasicFeature1_PostgreSQL_4ARG-----------------------------
SET timezone TO 0;
-- Testcase 1:
SELECT * FROM t9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 2:
SELECT * FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 3:
SELECT * FROM view_t9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7, __spd_url FROM t9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 5:
SELECT c1, c2, c3, c4, c5, c6, c7, __spd_url FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 6:
SELECT c1, c2, c3, c4, c5, c6, c7, __spd_url FROM view_t9 ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 7:
SELECT __spd_url FROM t9 ORDER BY 1;
-- Testcase 8:
SELECT __spd_url FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1;
-- Testcase 9:
SELECT __spd_url FROM view_t9 ORDER BY 1;
-- Testcase 10:
SELECT max(c22) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 11:
SELECT max(c22) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 12:
SELECT max(c22) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 13:
SELECT max(c22) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 14:
SELECT max(c22) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 15:
SELECT max(c22) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 16:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 17:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 18:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 19:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 20:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 21:
SELECT max(c22) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 22:
SELECT max(c22) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 23:
SELECT max(c22) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 24:
SELECT max(c22) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 25:
SELECT max(c22) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 26:
SELECT max(c22) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 27:
SELECT max(c22) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 28:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 29:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 30:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 31:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 32:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 33:
SELECT max(c31), min(c15*c23) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 34:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 35:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 36:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 37:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 38:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 39:
SELECT max(c31), min(c15*c23) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 40:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 41:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 42:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 43:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 44:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 45:
SELECT max(c31), min(c15*c23) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 46:
SELECT min(c2) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 47:
SELECT min(c2) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 48:
SELECT min(c2) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 49:
SELECT min(c2) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 50:
SELECT min(c2) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 51:
SELECT min(c2) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 52:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 53:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 54:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 55:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 56:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 57:
SELECT min(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 58:
SELECT min(c2) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 59:
SELECT min(c2) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 60:
SELECT min(c2) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 61:
SELECT min(c2) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 62:
SELECT min(c2) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 63:
SELECT min(c2) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 64:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 65:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 66:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 67:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 68:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 69:
SELECT min(c15), sum(c23+c30) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 70:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 71:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 72:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 73:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 74:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 75:
SELECT min(c15), sum(c23+c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 76:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 77:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 78:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 79:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 80:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 81:
SELECT min(c15), sum(c23+c30) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 82:
SELECT sum(c2) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 83:
SELECT sum(c2) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 84:
SELECT sum(c2) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 85:
SELECT sum(c2) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 86:
SELECT sum(c2) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 87:
SELECT sum(c2) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 88:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 89:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 90:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 91:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 92:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 93:
SELECT sum(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 94:
SELECT sum(c2) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 95:
SELECT sum(c2) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 96:
SELECT sum(c2) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 97:
SELECT sum(c2) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 98:
SELECT sum(c2) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 99:
SELECT sum(c2) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 100:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 101:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 102:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 103:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 104:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 105:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 106:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 107:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 108:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 109:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 110:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 111:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 112:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 113:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 114:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 115:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 116:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 117:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 118:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 119:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 120:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 121:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 122:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 123:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 124:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 125:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 126:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 127:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 128:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 129:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 130:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 131:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 132:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 133:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 134:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 135:
SELECT sum(c22), max(c13/100), min(c2)-5 FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 136:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 137:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 138:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 139:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 140:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 141:
SELECT avg(c28 ORDER BY c28) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 142:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 143:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 144:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 145:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 146:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 147:
SELECT avg(c28 ORDER BY c28) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 148:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 149:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 150:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 151:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 152:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 153:
SELECT avg(c28 ORDER BY c28) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 154:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 155:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 156:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 157:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 158:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 159:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 160:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 161:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 162:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 163:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 164:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 165:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 166:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 167:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 168:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 169:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 170:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 171:
SELECT count(*), count(c8), count (DISTINCT c9), count (ALL c10) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 172:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 173:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 174:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 175:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 176:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 177:
SELECT stddev(c1), stddev(c2) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 178:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 179:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 180:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 181:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 182:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 183:
SELECT stddev(c1), stddev(c2) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 184:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 185:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 186:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 187:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 188:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 189:
SELECT stddev(c1), stddev(c2) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 190:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 191:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 192:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 193:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 194:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 195:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 196:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 197:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 198:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 199:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 200:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 201:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 202:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 203:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 204:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 205:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 206:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 207:
SELECT array_agg(c3 ORDER BY c3), array_agg(c4 ORDER BY c4) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 208:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 209:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 210:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 211:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 212:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 213:
SELECT bit_and(c29), bit_or(c30) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 214:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 215:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 216:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 217:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 218:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 219:
SELECT bit_and(c29), bit_or(c30) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 220:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 221:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 222:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 223:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 224:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 225:
SELECT bit_and(c29), bit_or(c30) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 226:
SELECT bit_or(c31) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 227:
SELECT bit_or(c31) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 228:
SELECT bit_or(c31) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 229:
SELECT bit_or(c31) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 230:
SELECT bit_or(c31) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 231:
SELECT bit_or(c31) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 232:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 233:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 234:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 235:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 236:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 237:
SELECT bit_or(c31) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 238:
SELECT bit_or(c31) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 239:
SELECT bit_or(c31) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 240:
SELECT bit_or(c31) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 241:
SELECT bit_or(c31) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 242:
SELECT bit_or(c31) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 243:
SELECT bit_or(c31) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 244:
SELECT bool_and(c8='1') FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 245:
SELECT bool_and(c8='1') FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 246:
SELECT bool_and(c8='1') FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 247:
SELECT bool_and(c8='1') FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 248:
SELECT bool_and(c8='1') FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 249:
SELECT bool_and(c8='1') FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 250:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 251:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 252:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 253:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 254:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 255:
SELECT bool_and(c8='1') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 256:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 257:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 258:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 259:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 260:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 261:
SELECT bool_and(c8='1') FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 262:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 263:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 264:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 265:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 266:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 267:
SELECT bool_or(c29< 15) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 268:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 269:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 270:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 271:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 272:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 273:
SELECT bool_or(c29< 15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 274:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 275:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 276:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 277:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 278:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 279:
SELECT bool_or(c29< 15) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 280:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 281:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 282:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 283:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 284:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 285:
SELECT string_agg(c32, ',' ORDER BY c32) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 286:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 287:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 288:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 289:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 290:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 291:
SELECT string_agg(c32, ',' ORDER BY c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 292:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 293:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 294:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 295:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 296:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 297:
SELECT string_agg(c32, ',' ORDER BY c32) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 298:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 299:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 300:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 301:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 302:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 303:
SELECT every(c29>0), every(c1=c15) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 304:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 305:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 306:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 307:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 308:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 309:
SELECT every(c29>0), every(c1=c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 310:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 311:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 DESC, 2 ASC;
-- Testcase 312:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 DESC, 2 ASC;
-- Testcase 313:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 DESC, 2 ASC;
-- Testcase 314:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 DESC, 2 ASC;
-- Testcase 315:
SELECT every(c29>0), every(c1=c15) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 DESC, 2 ASC;
-- Testcase 316:
SELECT sqrt(abs(c1))+sqrt(abs(c30)) FROM t9 ORDER BY 1;
-- Testcase 317:
SELECT sqrt(abs(c1))+sqrt(abs(c30)) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1;
-- Testcase 318:
SELECT sqrt(abs(c1))+sqrt(abs(c30)) FROM view_t9 ORDER BY 1;
-- Testcase 319:
SELECT upper(c8), upper(c9), upper(__spd_url), lower(c32) FROM t9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 320:
SELECT upper(c8), upper(c9), upper(__spd_url), lower(c32) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 321:
SELECT upper(c8), upper(c9), upper(__spd_url), lower(c32) FROM view_t9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 322:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 323:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 324:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 325:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 326:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 327:
SELECT max(c1), min(c2), count(*), avg(c29) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 328:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 329:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 330:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 331:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 332:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 333:
SELECT max(c1), min(c2), count(*), avg(c29) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 334:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 335:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 336:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 337:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 338:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 339:
SELECT max(c1), min(c2), count(*), avg(c29) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 340:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 341:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 342:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 343:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM t9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 344:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 345:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 346:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 347:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 348:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 349:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 350:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM view_t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 351:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM view_t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 352:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 353:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM view_t9 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 354:
SELECT c13, max(c31), min(c22), sum(c29), count(c20), avg(c15) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 355:
SELECT c2*(random()<=1)::int,  (random()<=1)::int*(c28)+10 FROM t9 ORDER BY 1 DESC, 2 ASC;
-- Testcase 356:
SELECT c2*(random()<=1)::int,  (random()<=1)::int*(c28)+10 FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1 DESC, 2 ASC;
-- Testcase 357:
SELECT c2*(random()<=1)::int,  (random()<=1)::int*(c28)+10 FROM view_t9 ORDER BY 1 DESC, 2 ASC;
-- Testcase 358:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 359:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 360:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 361:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 362:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 363:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 364:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 365:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 366:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 367:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 368:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 369:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 370:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 371:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c2, c13 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 372:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 373:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 374:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 375:
SELECT max(c2), count(*), exists(SELECT * FROM t9 WHERE c8> 'a') FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1 ASC, 2 DESC, 3;
-- Testcase 376:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c13 ORDER BY 1;
-- Testcase 377:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 378:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 379:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 380:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 381:
SELECT sum(c22) filter (WHERE c15>=0) FROM t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 382:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13 ORDER BY 1;
-- Testcase 383:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 384:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 385:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 386:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 387:
SELECT sum(c22) filter (WHERE c15>=0) FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 388:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c13 ORDER BY 1;
-- Testcase 389:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c2, c13 ORDER BY 1;
-- Testcase 390:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c13, c5, __spd_url ORDER BY 1;
-- Testcase 391:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c1 HAVING min(c1)<>1 AND avg(c1) != 0 AND c1>-1000 ORDER BY 1;
-- Testcase 392:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c2, c9 HAVING count(c2) != 10 AND c9 != '1234ABCDEK' ORDER BY 1;
-- Testcase 393:
SELECT sum(c22) filter (WHERE c15>=0) FROM view_t9 GROUP BY c3, c5, c13, __spd_url HAVING c3 != b'1111111111' AND c5=true and __spd_url != '/abcd/' ORDER BY 1;
-- Testcase 394:
SELECT 'depzai',  c16, 10+c23*(random()<=1)::int FROM t9 ORDER BY 1 DESC, 2 ASC;
-- Testcase 395:
SELECT 'depzai',  c16, 10+c23*(random()<=1)::int FROM ( SELECT * FROM t9 WHERE c29>=0 ) AS tb9 ORDER BY 1 DESC, 2 ASC;
-- Testcase 396:
SELECT 'depzai',  c16, 10+c23*(random()<=1)::int FROM view_t9 ORDER BY 1 DESC, 2 ASC;
