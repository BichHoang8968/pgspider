--LIMIT/OFFSET
--LIMIT/OFFSET 1
--Testcase 1:
EXPLAIN VERBOSE SELECT * FROM tbl01 WHERE __spd_url <> '/pgspider/sqlite_svr' LIMIT NULL;
--Testcase 2:
SELECT * FROM tbl01 WHERE __spd_url <> '/pgspider/sqlite_svr' LIMIT NULL;
--Testcase 3:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url like '%svr_' LIMIT 0;
--Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url like '%svr_' LIMIT 0;
--Testcase 5:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4-c5, c6*c10+c8-c9, c11 FROM tbl01 WHERE __spd_url != '$' LIMIT ALL;
--Testcase 6:
SELECT c1, c2, c3 || c7, c4-c5, c6*c10+c8-c9, c11 FROM tbl01 WHERE __spd_url != '$' LIMIT ALL;
--LIMIT/OFFSET 2
--Testcase 7:
EXPLAIN VERBOSE SELECT * FROM tbl01 WHERE __spd_url <> '/pgspider' OFFSET NULL;
--Testcase 8:
SELECT * FROM tbl01 WHERE __spd_url <> '/pgspider' OFFSET NULL;
--Testcase 9:
EXPLAIN VERBOSE SELECT c5, c6, c7, c8, c1, c2, c3, c4  FROM tbl01 WHERE __spd_url ilike '%svr_' OFFSET 0;
--Testcase 10:
SELECT c5, c6, c7, c8, c1, c2, c3, c4  FROM tbl01 WHERE __spd_url ilike '%svr_' OFFSET 0;
--Testcase 11:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4-c5+c8+c9, c11 FROM tbl01 WHERE __spd_url != '$' OFFSET 1;
--Testcase 12:
SELECT c1, c2, c3 || c7, c4-c5+c8+c9, c11 FROM tbl01 WHERE __spd_url != '$' OFFSET 1;
--LIMIT/OFFSET 3
--Testcase 13:
EXPLAIN VERBOSE SELECT max(c4), min(c4), sum(c4), count(c4) FROM tbl01 WHERE __spd_url != 'aekfjw2' LIMIT 10 OFFSET 0;
--Testcase 14:
SELECT max(c4), min(c4), sum(c4), count(c4) FROM tbl01 WHERE __spd_url != 'aekfjw2' LIMIT 10 OFFSET 0;
--Testcase 15:
EXPLAIN VERBOSE SELECT min(c1 || c2), max(c4+c5), min(c8-c9), count(c11) FROM tbl01 WHERE __spd_url < 'sBi(' LIMIT 5 OFFSET 1;
--Testcase 16:
SELECT min(c1 || c2), max(c4+c5), min(c8-c9), count(c11) FROM tbl01 WHERE __spd_url < 'sBi(' LIMIT 5 OFFSET 1;
--Testcase 17:
EXPLAIN VERBOSE SELECT sum(c6+c10), max(c7), min(c8), count(c9-c5) FROM tbl01 WHERE __spd_url NOT LIKE 'owoefj%' LIMIT 10 OFFSET NULL;
--Testcase 18:
SELECT sum(c6+c10), max(c7), min(c8), count(c9-c5) FROM tbl01 WHERE __spd_url NOT LIKE 'owoefj%' LIMIT 10 OFFSET NULL;
--LIMIT/OFFSET 4
--Testcase 19:
EXPLAIN VERBOSE SELECT max(c4), min(c4), sum(c4), count(c4) FROM tbl01 WHERE __spd_url != 'wefwe' ORDER BY 1 ASC LIMIT 10 OFFSET 0;
--Testcase 20:
SELECT max(c4), min(c4), sum(c4), count(c4) FROM tbl01 WHERE __spd_url != 'wefwe' ORDER BY 1 ASC LIMIT 10 OFFSET 0;
--Testcase 21:
EXPLAIN VERBOSE SELECT min(c1), min(c2), max(c4-c5), min(c8/122*c9), count(c11) FROM tbl01 WHERE __spd_url NOT ILIKE 'sBi(' ORDER BY 1, 2 LIMIT ALL OFFSET NULL;
--Testcase 22:
SELECT min(c1), min(c2), max(c4-c5), min(c8/122*c9), count(c11) FROM tbl01 WHERE __spd_url NOT ILIKE 'sBi(' ORDER BY 1, 2 LIMIT ALL OFFSET NULL;
--Testcase 23:
EXPLAIN VERBOSE SELECT sum(c5), max(c7), min(c8), count(c9/c5) FROM tbl01 WHERE __spd_url NOT LIKE '%owoefj%' ORDER BY 1 ASC, 2 DESC, 3 LIMIT 10 OFFSET 1;
--Testcase 24:
SELECT sum(c5), max(c7), min(c8), count(c9/c5) FROM tbl01 WHERE __spd_url NOT LIKE '%owoefj%' ORDER BY 1 ASC, 2 DESC, 3 LIMIT 10 OFFSET 1;
--LIMIT/OFFSET 5
--Testcase 25:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4 - c5 + c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'any' LIMIT 10;
--Testcase 26:
SELECT c1, c2, c3, c4 - c5 + c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'any' LIMIT 10;
--Testcase 27:
EXPLAIN VERBOSE SELECT c1 || c2, c3, c4+c5*c6, c9-c10*12 FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING c4 > 0 LIMIT 10;
--Testcase 28:
SELECT c1 || c2, c3, c4+c5*c6, c9-c10*12 FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING c4 > 0 LIMIT 10;
--Testcase 29:
EXPLAIN VERBOSE SELECT lower(c1 || c2), c3 || c7, sqrt(c4-c5+c8/c9) FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9 HAVING c4 <> 0 LIMIT 5;
--Testcase 30:
SELECT lower(c1 || c2), c3 || c7, sqrt(c4-c5+c8/c9) FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9 HAVING c4 <> 0 LIMIT 5;
--LIMIT/OFFSET 6
--Testcase 31:
EXPLAIN VERBOSE SELECT c8, c7, c5, c3, c2, c6, c1, c4 FROM tbl01 WHERE __spd_url ilike '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'thing' OFFSET 1;
--Testcase 32:
SELECT c8, c7, c5, c3, c2, c6, c1, c4 FROM tbl01 WHERE __spd_url ilike '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'thing' OFFSET 1;
--Testcase 33:
EXPLAIN VERBOSE SELECT length(c1 || '&&' || c2), upper(c3 || c7), abs(c4-c5), round(c6*c10) FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4, c5, c6, c7, c10 HAVING c4 > 0 OFFSET 1;
--Testcase 34:
SELECT length(c1 || '&&' || c2), upper(c3 || c7), abs(c4-c5), round(c6*c10) FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4, c5, c6, c7, c10 HAVING c4 > 0 OFFSET 1;
--Testcase 35:
EXPLAIN VERBOSE SELECT c1 || c11 || c2, c3 || c7, c4-c5, c8/c9 FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING c4 != 0 OFFSET 1;
--Testcase 36:
SELECT c1 || c11 || c2, c3 || c7, c4-c5, c8/c9 FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING c4 != 0 OFFSET 1;
--LIMIT/OFFSET 7
--Testcase 37:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'impossible' LIMIT 10 OFFSET 1;
--Testcase 38:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING c3 != 'impossible' LIMIT 10 OFFSET 1;
--Testcase 39:
EXPLAIN VERBOSE SELECT c1 || c2, c3, @c4 FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4 HAVING c4 > 0 LIMIT 5 OFFSET 1;
--Testcase 40:
SELECT c1 || c2, c3, @c4 FROM tbl01 WHERE __spd_url != 'ae' GROUP BY c1, c2, c3, c4 HAVING c4 > 0 LIMIT 5 OFFSET 1;
--Testcase 41:
EXPLAIN VERBOSE SELECT upper(c1 || c2), lower(c3 || c7), ceil(c4-c5), round(c8/12+c9), c11 FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING c5 < 0 LIMIT NULL OFFSET NULL;
--Testcase 42:
SELECT upper(c1 || c2), lower(c3 || c7), ceil(c4-c5), round(c8/12+c9), c11 FROM tbl01 WHERE __spd_url != '$' GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING c5 < 0 LIMIT NULL OFFSET NULL;
--LIMIT/OFFSET 8
--Testcase 43:
EXPLAIN VERBOSE SELECT max(c3), min(c3), sum(c4), count(c3) FROM tbl01 WHERE __spd_url != '4t2ef' GROUP BY c9 HAVING c9 > 0 ORDER BY c9 ASC LIMIT 10 OFFSET 0;
--Testcase 44:
SELECT max(c3), min(c3), sum(c4), count(c3) FROM tbl01 WHERE __spd_url != '4t2ef' GROUP BY c9 HAVING c9 > 0 ORDER BY c9 ASC LIMIT 10 OFFSET 0;
--Testcase 45:
EXPLAIN VERBOSE SELECT min (c1 || c2), max(c4+c5), min(c8-c9*12), count(c5) FROM tbl01 WHERE __spd_url <> 'sBi(' GROUP BY c8, c9 HAVING (c8-c9) != 0 ORDER BY c8 DESC, c9 ASC LIMIT 5 OFFSET 1;
--Testcase 46:
SELECT min (c1 || c2), max(c4+c5), min(c8-c9*12), count(c5) FROM tbl01 WHERE __spd_url <> 'sBi(' GROUP BY c8, c9 HAVING (c8-c9) != 0 ORDER BY c8 DESC, c9 ASC LIMIT 5 OFFSET 1;
--Testcase 47:
EXPLAIN VERBOSE SELECT sum(c6+c10), max(c7), min(c8), count(c9-c5) FROM tbl01 WHERE __spd_url NOT LIKE 'owoefj%' GROUP BY c3, c7 HAVING c3 != c7 ORDER BY c3, c7 LIMIT 10 OFFSET NULL;
--Testcase 48:
SELECT sum(c6+c10), max(c7), min(c8), count(c9-c5) FROM tbl01 WHERE __spd_url NOT LIKE 'owoefj%' GROUP BY c3, c7 HAVING c3 != c7 ORDER BY c3, c7 LIMIT 10 OFFSET NULL;
--LIMIT/OFFSET 9
--Testcase 49:
EXPLAIN VERBOSE SELECT max(c3), min(c4), sum(c5) FROM tbl01 WHERE __spd_url NOT IN ('/spider/iff', '/in_svr') GROUP BY c6 HAVING c6 != 0 ORDER BY c6 ASC LIMIT 5;
--Testcase 50:
SELECT max(c3), min(c4), sum(c5) FROM tbl01 WHERE __spd_url NOT IN ('/spider/iff', '/in_svr') GROUP BY c6 HAVING c6 != 0 ORDER BY c6 ASC LIMIT 5;
--Testcase 51:
EXPLAIN VERBOSE SELECT count(*) FROM tbl01 WHERE __spd_url != 'aef3' GROUP BY c7 HAVING c7 != 'APO' ORDER BY c7 LIMIT ALL;
--Testcase 52:
SELECT count(*) FROM tbl01 WHERE __spd_url != 'aef3' GROUP BY c7 HAVING c7 != 'APO' ORDER BY c7 LIMIT ALL;
--Testcase 53:
EXPLAIN VERBOSE SELECT max(c5 + c6), max(c7), min(c8) FROM tbl01 WHERE __spd_url != NULL GROUP BY c8 HAVING c8 != 0 ORDER BY c8 DESC LIMIT 5;
--Testcase 54:
SELECT max(c5 + c6), max(c7), min(c8) FROM tbl01 WHERE __spd_url != NULL GROUP BY c8 HAVING c8 != 0 ORDER BY c8 DESC LIMIT 5;
--Testcase 55:
EXPLAIN VERBOSE SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 WHERE __spd_url NOT IN ('/awefwe/awefawef/af', '/pgspider') GROUP BY c4,c5 HAVING (c4 + c5) > 0 ORDER BY c4, c5 LIMIT 10;
--Testcase 56:
SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 WHERE __spd_url NOT IN ('/awefwe/awefawef/af', '/pgspider') GROUP BY c4,c5 HAVING (c4 + c5) > 0 ORDER BY c4, c5 LIMIT 10;
--LIMIT/OFFSET 10
--Testcase 57:
EXPLAIN VERBOSE SELECT * FROM tbl01 LIMIT 10;
--Testcase 58:
SELECT * FROM tbl01 LIMIT 10;
--Testcase 59:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4-22.2, c5+2.232, c6*12.11, c9+2.12, c10 + 232.23 FROM tbl01 LIMIT ALL;
--Testcase 60:
SELECT c1, c2, c3, c4-22.2, c5+2.232, c6*12.11, c9+2.12, c10 + 232.23 FROM tbl01 LIMIT ALL;
--Testcase 61:
EXPLAIN VERBOSE SELECT c1 || c2, c3 || c7, c4-c5+c10, c8-c9*12-c6 FROM tbl01 LIMIT 5;
--Testcase 62:
SELECT c1 || c2, c3 || c7, c4-c5+c10, c8-c9*12-c6 FROM tbl01 LIMIT 5;
--Testcase 63:
EXPLAIN VERBOSE SELECT lower(c1 || c11 || c2), upper(c3 || c7), abs(c4-c5+c6), sqrt(c8/32+c9+c10) FROM tbl01 LIMIT 0;
--Testcase 64:
SELECT lower(c1 || c11 || c2), upper(c3 || c7), abs(c4-c5+c6), sqrt(c8/32+c9+c10) FROM tbl01 LIMIT 0;
--LIMIT/OFFSET 11
--Testcase 65:
EXPLAIN VERBOSE SELECT * FROM tbl01 LIMIT 10 OFFSET 5;
--Testcase 66:
SELECT * FROM tbl01 LIMIT 10 OFFSET 5;
--Testcase 67:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4 / 2, c5 + 100, c6*2, c9-23, c10 FROM tbl01 LIMIT ALL OFFSET 0;
--Testcase 68:
SELECT c1, c2, c3, c4 / 2, c5 + 100, c6*2, c9-23, c10 FROM tbl01 LIMIT ALL OFFSET 0;
--Testcase 69:
EXPLAIN VERBOSE SELECT c1 || 'A', 'B' || c2, c3 || c7, c4-c5, c8/12+c9 FROM tbl01 LIMIT 5 OFFSET 5;
--Testcase 70:
SELECT c1 || 'A', 'B' || c2, c3 || c7, c4-c5, c8/12+c9 FROM tbl01 LIMIT 5 OFFSET 5;
--Testcase 71:
EXPLAIN VERBOSE SELECT c4/3+c5, c6, c7 || 123, abs(c8-c5-c9+c10), c11 FROM tbl01 LIMIT 15 OFFSET 5;
--Testcase 72:
SELECT c4/3+c5, c6, c7 || 123, abs(c8-c5-c9+c10), c11 FROM tbl01 LIMIT 15 OFFSET 5;
--LIMIT/OFFSET 12
--Testcase 73:
EXPLAIN VERBOSE SELECT * FROM tbl01 WHERE c3 > c7 LIMIT 10 OFFSET 5;
--Testcase 74:
SELECT * FROM tbl01 WHERE c3 > c7 LIMIT 10 OFFSET 5;
--Testcase 75:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4/22+c8, c5+12*c9, c11 FROM tbl01 WHERE c7 NOT IN ('inbetween', 'simple') LIMIT 15 OFFSET 5;
--Testcase 76:
SELECT c1, c2, c3 || c7, c4/22+c8, c5+12*c9, c11 FROM tbl01 WHERE c7 NOT IN ('inbetween', 'simple') LIMIT 15 OFFSET 5;
--Testcase 77:
EXPLAIN VERBOSE SELECT c1 || c2, c7 || c3, c4-c6, c5*12 FROM tbl01 WHERE c3 != 'ABC' LIMIT 10 OFFSET 1;
--Testcase 78:
SELECT c1 || c2, c7 || c3, c4-c6, c5*12 FROM tbl01 WHERE c3 != 'ABC' LIMIT 10 OFFSET 1;
--LIMIT/OFFSET 13
--Testcase 79:
EXPLAIN VERBOSE SELECT c5/2 + c6, c7, abs(c8)/c9+c10, c11 FROM tbl01 GROUP BY c3, c5, c6, c7, c8, c9, c10, c11 HAVING c3 <> 'AJEFO' LIMIT 5;
--Testcase 80:
SELECT c5/2 + c6, c7, abs(c8)/c9+c10, c11 FROM tbl01 GROUP BY c3, c5, c6, c7, c8, c9, c10, c11 HAVING c3 <> 'AJEFO' LIMIT 5;
--Testcase 81:
EXPLAIN VERBOSE SELECT lower(c1), c3, c5, upper(c7), c9, c11 FROM tbl01 GROUP BY c1, c3, c5, c7, c9, c11 HAVING sum(c5) != c9 LIMIT 5;
--Testcase 82:
SELECT lower(c1), c3, c5, upper(c7), c9, c11 FROM tbl01 GROUP BY c1, c3, c5, c7, c9, c11 HAVING sum(c5) != c9 LIMIT 5;
--Testcase 83:
EXPLAIN VERBOSE SELECT upper(c1 || c2), lower(c3 || c7), c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING max(c4) > max(c8) LIMIT 10;
--Testcase 84:
SELECT upper(c1 || c2), lower(c3 || c7), c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING max(c4) > max(c8) LIMIT 10;
--Testcase 85:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8 HAVING min(c4) < min(c8) LIMIT 10;
--Testcase 86:
SELECT c1, c2, c3 || c7, c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8 HAVING min(c4) < min(c8) LIMIT 10;
--LIMIT/OFFSET 14
--Testcase 87:
EXPLAIN VERBOSE SELECT c1 || c2, c3, c4, c5, to_hex(c6), c9, c10 FROM tbl01 WHERE c4/c5 > c4/c9 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING c3 != '$%' LIMIT 5;
--Testcase 88:
SELECT c1 || c2, c3, c4, c5, to_hex(c6), c9, c10 FROM tbl01 WHERE c4/c5 > c4/c9 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING c3 != '$%' LIMIT 5;
--Testcase 89:
EXPLAIN VERBOSE SELECT c1 || c2 || c3, c7, round(c4-c5, 2), floor(c8/c9) FROM tbl01 WHERE c4-c5 > c8-c9 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8, c9 HAVING c6 < c5 LIMIT 15;
--Testcase 90:
SELECT c1 || c2 || c3, c7, round(c4-c5, 2), floor(c8/c9) FROM tbl01 WHERE c4-c5 > c8-c9 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8, c9 HAVING c6 < c5 LIMIT 15;
--Testcase 91:
EXPLAIN VERBOSE SELECT c4/2+c5, c6, c7, c8/22*c5-c9, c10, c11 FROM tbl01 WHERE c4/100+c5 > c8 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING c4 != 0 LIMIT 15;
--Testcase 92:
SELECT c4/2+c5, c6, c7, c8/22*c5-c9, c10, c11 FROM tbl01 WHERE c4/100+c5 > c8 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING c4 != 0 LIMIT 15;
--Testcase 93:
EXPLAIN VERBOSE SELECT lower(c1 || c3), c5, c7, c9, c11 + '1 hour'::interval FROM tbl01 WHERE c3 NOT IN ('/pgspider', '/postgres', '/svr')  GROUP BY c1, c3, c5, c7, c8, c9, c11 HAVING c8 BETWEEN -10000 AND 10000 LIMIT 15;
--Testcase 94:
SELECT lower(c1 || c3), c5, c7, c9, c11 + '1 hour'::interval FROM tbl01 WHERE c3 NOT IN ('/pgspider', '/postgres', '/svr')  GROUP BY c1, c3, c5, c7, c8, c9, c11 HAVING c8 BETWEEN -10000 AND 10000 LIMIT 15;
--LIMIT/OFFSET 15
--Testcase 95:
EXPLAIN VERBOSE SELECT c1 || c2, c3, c4 - 100, c5, c6, c9, c10 FROM tbl01 WHERE c4-c5 > c8-c9 GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1 ASC, 2 DESC, 3, 4, 5, 6, 7 LIMIT 5;
--Testcase 96:
SELECT c1 || c2, c3, c4 - 100, c5, c6, c9, c10 FROM tbl01 WHERE c4-c5 > c8-c9 GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1 ASC, 2 DESC, 3, 4, 5, 6, 7 LIMIT 5;
--Testcase 97:
EXPLAIN VERBOSE SELECT c1, c2 || c3 || c7, ceil(c4-c5), abs(c8/c9) FROM tbl01 WHERE c4/100+c5 > c8 GROUP BY 1, 2, 3, 4 ORDER BY 1 DESC, 2, 3, 4 LIMIT 15;
--Testcase 98:
SELECT c1, c2 || c3 || c7, ceil(c4-c5), abs(c8/c9) FROM tbl01 WHERE c4/100+c5 > c8 GROUP BY 1, 2, 3, 4 ORDER BY 1 DESC, 2, 3, 4 LIMIT 15;
--Testcase 99:
EXPLAIN VERBOSE SELECT lower(c1 || c2), c3, c4-c5, c8*0.212+c9, c11 FROM tbl01 WHERE c3 <> 'AJEOF' GROUP BY 1, 2, 3, 4, 5 ORDER BY 1 ASC, 2, 3, 4, 5 LIMIT 5;
--Testcase 100:
SELECT lower(c1 || c2), c3, c4-c5, c8*0.212+c9, c11 FROM tbl01 WHERE c3 <> 'AJEOF' GROUP BY 1, 2, 3, 4, 5 ORDER BY 1 ASC, 2, 3, 4, 5 LIMIT 5;
--Testcase 101:
EXPLAIN VERBOSE SELECT upper(c1 || '&' || c3), c5, c7, c9, c11 + '1 hour'::interval FROM tbl01 WHERE c7 != '[]' GROUP BY 1, 2, 3, 4, 5 ORDER BY 1, 2, 3, 4, 5 LIMIT 10;
--Testcase 102:
SELECT upper(c1 || '&' || c3), c5, c7, c9, c11 + '1 hour'::interval FROM tbl01 WHERE c7 != '[]' GROUP BY 1, 2, 3, 4, 5 ORDER BY 1, 2, 3, 4, 5 LIMIT 10;
--LIMIT/OFFSET 16
--Testcase 103:
EXPLAIN VERBOSE SELECT count(*) FROM tbl01 WHERE c8 > 0 ORDER BY 1 LIMIT 5;
--Testcase 104:
SELECT count(*) FROM tbl01 WHERE c8 > 0 ORDER BY 1 LIMIT 5;
--Testcase 105:
EXPLAIN VERBOSE SELECT min(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 WHERE c4 <> 0 ORDER BY 1 ASC, 2 DESC, 3 LIMIT 1;
--Testcase 106:
SELECT min(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 WHERE c4 <> 0 ORDER BY 1 ASC, 2 DESC, 3 LIMIT 1;
--Testcase 107:
EXPLAIN VERBOSE SELECT min(c5/3 + c6), max(c7), min(c8), max(c9/2+c10), max(c11) FROM tbl01 WHERE c3 || 'abc' > 'AEJFOAWF' ORDER BY 1 ASC,2 ASC,3 LIMIT 15;
--Testcase 108:
SELECT min(c5/3 + c6), max(c7), min(c8), max(c9/2+c10), max(c11) FROM tbl01 WHERE c3 || 'abc' > 'AEJFOAWF' ORDER BY 1 ASC,2 ASC,3 LIMIT 15;
--Testcase 109:
EXPLAIN VERBOSE SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 WHERE c5 <> c9 ORDER BY 1, 2 LIMIT 15;
--Testcase 110:
SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 WHERE c5 <> c9 ORDER BY 1, 2 LIMIT 15;
--Testcase 111:
EXPLAIN VERBOSE SELECT sum(c5), max(c7), min(c8), count(c9/2-c5*2) FROM tbl01 WHERE c8 BETWEEN -10000 AND 10000 ORDER BY 1 LIMIT 15;
--Testcase 112:
SELECT sum(c5), max(c7), min(c8), count(c9/2-c5*2) FROM tbl01 WHERE c8 BETWEEN -10000 AND 10000 ORDER BY 1 LIMIT 15;
--LIMIT/OFFSET 17
--Testcase 113:
EXPLAIN VERBOSE SELECT c1 || c2, min(c3), c4/c5+ c6, c7, ceil(c8) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING min(c3) != 'wef' LIMIT 10 OFFSET 1;
--Testcase 114:
SELECT c1 || c2, min(c3), c4/c5+ c6, c7, ceil(c8) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING min(c3) != 'wef' LIMIT 10 OFFSET 1;
--Testcase 115:
EXPLAIN VERBOSE SELECT c4-c5 + c8/2*c9/23, c11 || 'time1', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING max(c4) > 0 LIMIT 5 OFFSET 1;
--Testcase 116:
SELECT c4-c5 + c8/2*c9/23, c11 || 'time1', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING max(c4) > 0 LIMIT 5 OFFSET 1;
--Testcase 117:
EXPLAIN VERBOSE SELECT c11 + '1 hour'::interval, c1, c2, c3, c4/(c5+2), c8/(c9-12) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING sum(c5) != min(c4) LIMIT 5 OFFSET NULL;
--Testcase 118:
SELECT c11 + '1 hour'::interval, c1, c2, c3, c4/(c5+2), c8/(c9-12) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING sum(c5) != min(c4) LIMIT 5 OFFSET NULL;
--LIMIT/OFFSET 18
--Testcase 119:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE c3 != 'wef' ORDER BY c1 LIMIT 10 OFFSET 1;
--Testcase 120:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE c3 != 'wef' ORDER BY c1 LIMIT 10 OFFSET 1;
--Testcase 121:
EXPLAIN VERBOSE SELECT c4-c5, c8/(c9-23), c11 + '3 days'::interval, c10 FROM tbl01 WHERE c4 > 0 ORDER BY c1, c2 LIMIT 5 OFFSET 5;
--Testcase 122:
SELECT c4-c5, c8/(c9-23), c11 + '3 days'::interval, c10 FROM tbl01 WHERE c4 > 0 ORDER BY c1, c2 LIMIT 5 OFFSET 5;
--Testcase 123:
EXPLAIN VERBOSE SELECT concat(c1, c2, c3), c4-c5, c8/2+c9, c11 FROM tbl01 WHERE  c5 > c4 ORDER BY 1,2 LIMIT 15 OFFSET 1;
--Testcase 124:
SELECT concat(c1, c2, c3), c4-c5, c8/2+c9, c11 FROM tbl01 WHERE  c5 > c4 ORDER BY 1,2 LIMIT 15 OFFSET 1;
--Testcase 125:
EXPLAIN VERBOSE SELECT upper(c1 || c2 || 'base64'), c5, round(c8/23+c9), c10 FROM tbl01 WHERE NOT c4 < 0 ORDER BY 1,2 LIMIT 5 OFFSET 3;
--Testcase 126:
SELECT upper(c1 || c2 || 'base64'), c5, round(c8/23+c9), c10 FROM tbl01 WHERE NOT c4 < 0 ORDER BY 1,2 LIMIT 5 OFFSET 3;
--LIMIT/OFFSET 19
--Testcase 127:
EXPLAIN VERBOSE SELECT c1 || c2, upper(c3), round(c4-c5+c6-c9-c10) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING sum(c4/c5) > c4 LIMIT 5;
--Testcase 128:
SELECT c1 || c2, upper(c3), round(c4-c5+c6-c9-c10) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 HAVING sum(c4/c5) > c4 LIMIT 5;
--Testcase 129:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4-c5, c8/(c9+12) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c8, c9 HAVING count(c3) < c5 LIMIT 5;
--Testcase 130:
SELECT c1, c2, c3, c4-c5, c8/(c9+12) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c8, c9 HAVING count(c3) < c5 LIMIT 5;
--Testcase 131:
EXPLAIN VERBOSE SELECT c4/2+c5, c6, c7, c8-c5-c9, c10, c11 FROM tbl01 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING max(c4) != 0 LIMIT 15;
--Testcase 132:
SELECT c4/2+c5, c6, c7, c8-c5-c9, c10, c11 FROM tbl01 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING max(c4) != 0 LIMIT 15;
--Testcase 133:
EXPLAIN VERBOSE SELECT length(c1 || c2 || c3), 1, 2, 'abc' FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c9 HAVING NOT min(c4) > (c5 + c9) LIMIT 15;
--Testcase 134:
SELECT length(c1 || c2 || c3), 1, 2, 'abc' FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c9 HAVING NOT min(c4) > (c5 + c9) LIMIT 15;
--LIMIT/OFFSET 20
--Testcase 135:
EXPLAIN VERBOSE SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 ORDER BY c1, c2, c3 LIMIT 15;
--Testcase 136:
SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 ORDER BY c1, c2, c3 LIMIT 15;
--Testcase 137:
EXPLAIN VERBOSE SELECT c4-c5, c8/c9, c11 || 'time3', c10 FROM tbl01 ORDER BY 1 DESC,2 ASC, 3 LIMIT ALL;
--Testcase 138:
SELECT c4-c5, c8/c9, c11 || 'time3', c10 FROM tbl01 ORDER BY 1 DESC,2 ASC, 3 LIMIT ALL;
--Testcase 139:
EXPLAIN VERBOSE SELECT c1 || c2, c3, c4-c5, c8-c9 FROM tbl01 ORDER BY 1 ASC,2 , 3 LIMIT 5;
--Testcase 140:
SELECT c1 || c2, c3, c4-c5, c8-c9 FROM tbl01 ORDER BY 1 ASC,2 , 3 LIMIT 5;
--Testcase 141:
EXPLAIN VERBOSE SELECT c4/(c5+c6), c7, abs(c8-c5-c9), c10, c11 FROM tbl01 ORDER BY c4/(c5 + c6) DESC, c7 LIMIT 15;
--Testcase 142:
SELECT c4/(c5+c6), c7, abs(c8-c5-c9), c10, c11 FROM tbl01 ORDER BY c4/(c5 + c6) DESC, c7 LIMIT 15;
--Testcase 143:
EXPLAIN VERBOSE SELECT c1 || c2, c3 || c7, round(c4/(c8-c5)+c9), c11 FROM tbl01 ORDER BY c1, c2, c3 || c7 ASC LIMIT 5;
--Testcase 144:
SELECT c1 || c2, c3 || c7, round(c4/(c8-c5)+c9), c11 FROM tbl01 ORDER BY c1, c2, c3 || c7 ASC LIMIT 5;
--Testcase 145:
EXPLAIN VERBOSE SELECT c1, c2 || c3, 1, 2, 'abc' FROM tbl01 ORDER BY c1, c2, c3 LIMIT 5;
--Testcase 146:
SELECT c1, c2 || c3, 1, 2, 'abc' FROM tbl01 ORDER BY c1, c2, c3 LIMIT 5;
--LIMIT/OFFSET 21
--Testcase 147:
EXPLAIN VERBOSE SELECT 122,332, 'wefakef', 2332, 'anypossibility' FROM tbl01 LIMIT 1;
--Testcase 148:
SELECT 122,332, 'wefakef', 2332, 'anypossibility' FROM tbl01 LIMIT 1;
--Testcase 149:
EXPLAIN VERBOSE SELECT c1, c2, c3, __spd_url FROM tbl01 LIMIT 15;
--Testcase 150:
SELECT c1, c2, c3, __spd_url FROM tbl01 LIMIT 15;
--Testcase 151:
EXPLAIN VERBOSE SELECT count(DISTINCT c5) FROM tbl01 LIMIT 5;
--Testcase 152:
SELECT count(DISTINCT c5) FROM tbl01 LIMIT 5;
--Testcase 153:
EXPLAIN VERBOSE SELECT array_agg(c3 || ' ' || c7), json_agg(('~!@#', c4)), jsonb_agg(('_(*#', c5)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 LIMIT 5;
--Testcase 154:
SELECT array_agg(c3 || ' ' || c7), json_agg(('~!@#', c4)), jsonb_agg(('_(*#', c5)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 LIMIT 5;
--Testcase 155:
EXPLAIN VERBOSE SELECT string_agg(c3, ' ' ORDER BY c3), string_agg(c7, ',' ORDER BY c7) FROM tbl01 LIMIT 5;
--Testcase 156:
SELECT string_agg(c3, ' ' ORDER BY c3), string_agg(c7, ',' ORDER BY c7) FROM tbl01 LIMIT 5;
--Testcase 157:
EXPLAIN VERBOSE SELECT string_agg(c3, c7) FROM tbl01 LIMIT 1;
--Testcase 158:
SELECT string_agg(c3, c7) FROM tbl01 LIMIT 1;
--LIMIT/OFFSET 22
--Testcase 159:
EXPLAIN VERBOSE SELECT length(c1), length(c2), c3, c4, c5, c6, c9, c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10, __spd_url HAVING __spd_url != '/spider' OFFSET 5;
--Testcase 160:
SELECT length(c1), length(c2), c3, c4, c5, c6, c9, c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10, __spd_url HAVING __spd_url != '/spider' OFFSET 5;
--Testcase 161:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4-c5, c8/c9 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9 HAVING count(DISTINCT c4) > 0 OFFSET 1;
--Testcase 162:
SELECT c1, c2, c3 || c7, c4-c5, c8/c9 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9 HAVING count(DISTINCT c4) > 0 OFFSET 1;
--Testcase 163:
EXPLAIN VERBOSE SELECT c4/12+c5, c6, c7, c8/(c5-c9), c10, c11 + '3 days'::interval FROM tbl01 GROUP BY c3, c4, c5, c6, c7, c8, c9, c10, c11 HAVING c3 = ANY(array_agg(c3)) OFFSET 3;
--Testcase 164:
SELECT c4/12+c5, c6, c7, c8/(c5-c9), c10, c11 + '3 days'::interval FROM tbl01 GROUP BY c3, c4, c5, c6, c7, c8, c9, c10, c11 HAVING c3 = ANY(array_agg(c3)) OFFSET 3;
--Testcase 165:
EXPLAIN VERBOSE SELECT c1 || c2, c3, abs(c4-c5), abs(c8/23+c9), c11 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING string_agg(c3, ' ' ORDER BY c3) != 'a3W' OFFSET 1;
--Testcase 166:
SELECT c1 || c2, c3, abs(c4-c5), abs(c8/23+c9), c11 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING string_agg(c3, ' ' ORDER BY c3) != 'a3W' OFFSET 1;
--Testcase 167:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7 HAVING string_agg(c3, c7) != '9u3wro' OFFSET 1;
--Testcase 168:
SELECT c1, c2, c3 || c7, c4/100-c5 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7 HAVING string_agg(c3, c7) != '9u3wro' OFFSET 1;
--LIMIT/OFFSET 23
--Testcase 169:
EXPLAIN VERBOSE SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 GROUP BY __spd_url, c1, c2, c3, c4, c7, c8 ORDER BY 1 ASC, 2 DESC LIMIT 1 OFFSET 1;
--Testcase 170:
SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 GROUP BY __spd_url, c1, c2, c3, c4, c7, c8 ORDER BY 1 ASC, 2 DESC LIMIT 1 OFFSET 1;
--Testcase 171:
EXPLAIN VERBOSE SELECT c4-c5, c8/23+c9, c11 || 'time4', c10 FROM tbl01 GROUP BY __spd_url, c4, c5, c8, c9, c10, c11 ORDER BY 1 DESC LIMIT 5 OFFSET 1;
--Testcase 172:
SELECT c4-c5, c8/23+c9, c11 || 'time4', c10 FROM tbl01 GROUP BY __spd_url, c4, c5, c8, c9, c10, c11 ORDER BY 1 DESC LIMIT 5 OFFSET 1;
--Testcase 173:
EXPLAIN VERBOSE SELECT c4/(c5+c6), c7, c8/c5-c9, c10, c11 FROM tbl01 GROUP BY __spd_url, c4, c5, c6, c7, c8, c9, c10, c11 ORDER BY 1 ASC LIMIT 5 OFFSET 2;
--Testcase 174:
SELECT c4/(c5+c6), c7, c8/c5-c9, c10, c11 FROM tbl01 GROUP BY __spd_url, c4, c5, c6, c7, c8, c9, c10, c11 ORDER BY 1 ASC LIMIT 5 OFFSET 2;
--Testcase 175:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c9, c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, __spd_url, c9, c10 ORDER BY 1 LIMIT 5 OFFSET 3;
--Testcase 176:
SELECT c1, c2, c3, c4, c5, c6, c9, c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, __spd_url, c9, c10 ORDER BY 1 LIMIT 5 OFFSET 3;
--Testcase 177:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4-c5, c8/2+c9 FROM tbl01 GROUP BY c1, c2, c3, __spd_url, c4, c5, c7, c8, c9 ORDER BY 1 LIMIT 5 OFFSET 4;
--Testcase 178:
SELECT c1, c2, c3 || c7, c4-c5, c8/2+c9 FROM tbl01 GROUP BY c1, c2, c3, __spd_url, c4, c5, c7, c8, c9 ORDER BY 1 LIMIT 5 OFFSET 4;
--Testcase 179:
EXPLAIN VERBOSE SELECT * FROM tbl01 WHERE c4/2+c5 > c4/2-c8 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, __spd_url ORDER BY 1 LIMIT 10 OFFSET 5;
--Testcase 180:
SELECT * FROM tbl01 WHERE c4/2+c5 > c4/2-c8 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, __spd_url ORDER BY 1 LIMIT 10 OFFSET 5;
--LIMIT/OFFSET 24
--Testcase 181:
EXPLAIN VERBOSE SELECT 1,2, 'wefakef', 2332, ')!@*&<>\\//' FROM tbl01 WHERE c3 IS NOT NULL ORDER BY 1, 2, 3 LIMIT 1 OFFSET 5;
--Testcase 182:
SELECT 1,2, 'wefakef', 2332, ')!@*&<>\\//' FROM tbl01 WHERE c3 IS NOT NULL ORDER BY 1, 2, 3 LIMIT 1 OFFSET 5;
--Testcase 183:
EXPLAIN VERBOSE SELECT c1 || c2, c3, __spd_url FROM tbl01 WHERE c4 != 0 ORDER BY 1, 2 LIMIT 5 OFFSET 3;
--Testcase 184:
SELECT c1 || c2, c3, __spd_url FROM tbl01 WHERE c4 != 0 ORDER BY 1, 2 LIMIT 5 OFFSET 3;
--Testcase 185:
EXPLAIN VERBOSE SELECT count(DISTINCT c5) FROM tbl01 WHERE c5 > 0 ORDER BY 1 LIMIT 1 OFFSET 0;
--Testcase 186:
SELECT count(DISTINCT c5) FROM tbl01 WHERE c5 > 0 ORDER BY 1 LIMIT 1 OFFSET 0;
--Testcase 187:
EXPLAIN VERBOSE SELECT array_agg(c3 || ' ' || c7), json_agg(('xx', c4)), jsonb_agg(('yy', c5)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 WHERE c7 IS NOT NULL ORDER BY 1 LIMIT 5 OFFSET 0;
--Testcase 188:
SELECT array_agg(c3 || ' ' || c7), json_agg(('xx', c4)), jsonb_agg(('yy', c5)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 WHERE c7 IS NOT NULL ORDER BY 1 LIMIT 5 OFFSET 0;
--Testcase 189:
EXPLAIN VERBOSE SELECT string_agg(c3, '-' ORDER BY c3), string_agg(c7, '_' ORDER BY c7) FROM tbl01 WHERE c8 != c9 ORDER BY 1, 2 LIMIT 5 OFFSET 0;
--Testcase 190:
SELECT string_agg(c3, '-' ORDER BY c3), string_agg(c7, '_' ORDER BY c7) FROM tbl01 WHERE c8 != c9 ORDER BY 1, 2 LIMIT 5 OFFSET 0;
--Testcase 191:
EXPLAIN VERBOSE SELECT string_agg(c3, c7) FROM tbl01 WHERE c8 < c9 ORDER BY 1 ASC LIMIT 1 OFFSET 0;
--Testcase 192:
SELECT string_agg(c3, c7) FROM tbl01 WHERE c8 < c9 ORDER BY 1 ASC LIMIT 1 OFFSET 0;
--LIMIT/OFFSET 25
--Testcase 193:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 ORDER BY __spd_url LIMIT 5;
--Testcase 194:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 ORDER BY __spd_url LIMIT 5;
--Testcase 195:
EXPLAIN VERBOSE SELECT round(c4-c5), ceil(c8/(c9+33)), c11 || 'time5', c10 FROM tbl01 ORDER BY __spd_url LIMIT 1;
--Testcase 196:
SELECT round(c4-c5), ceil(c8/(c9+33)), c11 || 'time5', c10 FROM tbl01 ORDER BY __spd_url LIMIT 1;
--Testcase 197:
EXPLAIN VERBOSE SELECT c1, c2 || c3, c4-c5, c8/23+c9, c11 FROM tbl01 ORDER BY __spd_url LIMIT 2;
--Testcase 198:
SELECT c1, c2 || c3, c4-c5, c8/23+c9, c11 FROM tbl01 ORDER BY __spd_url LIMIT 2;
--LIMIT/OFFSET 26
--Testcase 199:
EXPLAIN VERBOSE SELECT c1 || c2, c3, c4/21212+c5/221*c6-c9, c10 FROM tbl01 ORDER BY __spd_url OFFSET 5;
--Testcase 200:
SELECT c1 || c2, c3, c4/21212+c5/221*c6-c9, c10 FROM tbl01 ORDER BY __spd_url OFFSET 5;
--Testcase 201:
EXPLAIN VERBOSE SELECT lower(c1 || c2 || c3), round(c4-c5), round(c8/2-c9) FROM tbl01 ORDER BY __spd_url OFFSET 1;
--Testcase 202:
SELECT lower(c1 || c2 || c3), round(c4-c5), round(c8/2-c9) FROM tbl01 ORDER BY __spd_url OFFSET 1;
--Testcase 203:
EXPLAIN VERBOSE SELECT c4/c5, c6, c7, c8/(c5-c9), c10, c11 FROM tbl01 ORDER BY __spd_url OFFSET 5;
--Testcase 204:
SELECT c4/c5, c6, c7, c8/(c5-c9), c10, c11 FROM tbl01 ORDER BY __spd_url OFFSET 5;
--LIMIT/OFFSET 27
--Testcase 205:
EXPLAIN VERBOSE SELECT * FROM tbl01 ORDER BY __spd_url LIMIT 5 OFFSET 3;
--Testcase 206:
SELECT * FROM tbl01 ORDER BY __spd_url LIMIT 5 OFFSET 3;
--Testcase 207:
EXPLAIN VERBOSE SELECT c7, c8, c6, c4, c5, c3, c2, c1 FROM tbl01 ORDER BY __spd_url LIMIT 1 OFFSET 1;
--Testcase 208:
SELECT c7, c8, c6, c4, c5, c3, c2, c1 FROM tbl01 ORDER BY __spd_url LIMIT 1 OFFSET 1;
--Testcase 209:
EXPLAIN VERBOSE SELECT lower(c1 || c2 || c3), 1, 2, 'abc' FROM tbl01 ORDER BY __spd_url LIMIT 5 OFFSET 1;
--Testcase 210:
SELECT lower(c1 || c2 || c3), 1, 2, 'abc' FROM tbl01 ORDER BY __spd_url LIMIT 5 OFFSET 1;
--ORDER BY
--ORDER BY 1
--Testcase 211:
EXPLAIN VERBOSE SELECT * FROM tbl01 ORDER BY c1 ASC, c2 DESC, c3;
--Testcase 212:
SELECT * FROM tbl01 ORDER BY c1 ASC, c2 DESC, c3;
--Testcase 213:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4 /2, c5 + 23.12, c6 * 23, c9 - 23, c10 + 231 FROM tbl01 ORDER BY 1 ASC,2 DESC, 3 ASC;
--Testcase 214:
SELECT c1, c2, c3, c4 /2, c5 + 23.12, c6 * 23, c9 - 23, c10 + 231 FROM tbl01 ORDER BY 1 ASC,2 DESC, 3 ASC;
--Testcase 215:
EXPLAIN VERBOSE SELECT c1, c2, c3 || c7, c4-c5, c8/(c9+c6) FROM tbl01 ORDER BY c4-c5 DESC, c8/2 ASC;
--Testcase 216:
SELECT c1, c2, c3 || c7, c4-c5, c8/(c9+c6) FROM tbl01 ORDER BY c4-c5 DESC, c8/2 ASC;
--ORDER BY 2
--Testcase 217:
EXPLAIN VERBOSE SELECT * FROM tbl01 ORDER BY __spd_url;
--Testcase 218:
SELECT * FROM tbl01 ORDER BY __spd_url;
--Testcase 219:
EXPLAIN VERBOSE SELECT lower(c1 || c2), c3 || c7, c4/(c5+c6)-c8 FROM tbl01 ORDER BY __spd_url;
--Testcase 220:
SELECT lower(c1 || c2), c3 || c7, c4/(c5+c6)-c8 FROM tbl01 ORDER BY __spd_url;
--Testcase 221:
EXPLAIN VERBOSE SELECT c1, c2, c3, 1, 2, 'abc' FROM tbl01 ORDER BY __spd_url;
--Testcase 222:
SELECT c1, c2, c3, 1, 2, 'abc' FROM tbl01 ORDER BY __spd_url;
--ORDER BY 3
--Testcase 223:
EXPLAIN VERBOSE SELECT count(*) FROM tbl01 ORDER BY 1;
--Testcase 224:
SELECT count(*) FROM tbl01 ORDER BY 1;
--Testcase 225:
EXPLAIN VERBOSE SELECT count(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 ORDER BY 1, 2 DESC;
--Testcase 226:
SELECT count(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 ORDER BY 1, 2 DESC;
--Testcase 227:
EXPLAIN VERBOSE SELECT count(c5/2+c6), max(c7), min(c8), sum(c9/2+c10) FROM tbl01 ORDER BY 1 ASC, 2 DESC, 3;
--Testcase 228:
SELECT count(c5/2+c6), max(c7), min(c8), sum(c9/2+c10) FROM tbl01 ORDER BY 1 ASC, 2 DESC, 3;
--Testcase 229:
EXPLAIN VERBOSE SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 ORDER BY 1 DESC, 2 ASC, 3;
--Testcase 230:
SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 ORDER BY 1 DESC, 2 ASC, 3;
--Testcase 231:
EXPLAIN VERBOSE SELECT sum(c5), max(c7), min(c8), count(c9/2+c5) FROM tbl01 ORDER BY 1 ASC, 2, 3;
--Testcase 232:
SELECT sum(c5), max(c7), min(c8), count(c9/2+c5) FROM tbl01 ORDER BY 1 ASC, 2, 3;
--ORDER BY 4
--Testcase 233:
EXPLAIN VERBOSE SELECT 122, 332, 'wefakef', 2332, '?.,>>><[]\\+_!~@#' FROM tbl01 ORDER BY 1;
--Testcase 234:
SELECT 122, 332, 'wefakef', 2332, '?.,>>><[]\\+_!~@#' FROM tbl01 ORDER BY 1;
--Testcase 235:
EXPLAIN VERBOSE SELECT c1, c2, c3, __spd_url FROM tbl01 ORDER BY 1, 2, 3 ;
--Testcase 236:
SELECT c1, c2, c3, __spd_url FROM tbl01 ORDER BY 1, 2, 3 ;
--Testcase 237:
EXPLAIN VERBOSE SELECT count(DISTINCT c5) FROM tbl01 ORDER BY 1;
--Testcase 238:
SELECT count(DISTINCT c5) FROM tbl01 ORDER BY 1;
--Testcase 239:
EXPLAIN VERBOSE SELECT array_agg(c3 || ' ' || c7), json_agg(('json_x', c3)), jsonb_agg(('json_y', c3)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 ORDER BY 1 DESC;
--Testcase 240:
SELECT array_agg(c3 || ' ' || c7), json_agg(('json_x', c3)), jsonb_agg(('json_y', c3)), json_object_agg('x', c7), jsonb_object_agg('y', c7) FROM tbl01 ORDER BY 1 DESC;
--Testcase 241:
EXPLAIN VERBOSE SELECT string_agg(c3, ':' ORDER BY c3), string_agg(c7, '>>' ORDER BY c7) FROM tbl01 ORDER BY 1, 2;
--Testcase 242:
SELECT string_agg(c3, ':' ORDER BY c3), string_agg(c7, '>>' ORDER BY c7) FROM tbl01 ORDER BY 1, 2;
--Testcase 243:
EXPLAIN VERBOSE SELECT string_agg(c3, c7) FROM tbl01 ORDER BY 1 DESC;
--Testcase 244:
SELECT string_agg(c3, c7) FROM tbl01 ORDER BY 1 DESC;
--ORDER BY 5
--Testcase 245:
EXPLAIN VERBOSE SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 GROUP BY c1, c2, c3, c4, c7, c8 HAVING count(c3) > 0 ORDER BY c1, c2, c3, c4, c7, c8;
--Testcase 246:
SELECT c1, c2, c3 || '123' || c7, c4, c8/1000 FROM tbl01 GROUP BY c1, c2, c3, c4, c7, c8 HAVING count(c3) > 0 ORDER BY c1, c2, c3, c4, c7, c8;
--Testcase 247:
EXPLAIN VERBOSE SELECT c4-c5, c8/(c9-23), c11 || 'time3', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING sum(c5/c4) != 0 ORDER BY c4, c5, c8, c9, c10, c11;
--Testcase 248:
SELECT c4-c5, c8/(c9-23), c11 || 'time3', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING sum(c5/c4) != 0 ORDER BY c4, c5, c8, c9, c10, c11;
--Testcase 249:
EXPLAIN VERBOSE SELECT c1, lower(c2 || c3), c4-c5, round(c8/c9) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9 HAVING max(c4/c5) > 10 ORDER BY c1, c2, c3, c4, c5, c8, c9;
--Testcase 250:
SELECT c1, lower(c2 || c3), c4-c5, round(c8/c9) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9 HAVING max(c4/c5) > 10 ORDER BY c1, c2, c3, c4, c5, c8, c9;
--Testcase 251:
EXPLAIN VERBOSE SELECT abs(c4/c5+c6), upper(c7), c8/23+c5-c9/3+c10, c11 FROM tbl01 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING min(c4) < 0 ORDER BY c4, c5, c6, c7, c8, c9, c10, c11;
--Testcase 252:
SELECT abs(c4/c5+c6), upper(c7), c8/23+c5-c9/3+c10, c11 FROM tbl01 GROUP BY c4, c5, c6, c7, c8, c9, c10, c11 HAVING min(c4) < 0 ORDER BY c4, c5, c6, c7, c8, c9, c10, c11;
--Testcase 253:
EXPLAIN VERBOSE SELECT c1 || c2, c3 || c7, c4/2+c8-c5/32+c9, c11 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING min(c4) < min (c8) ORDER BY c1, c2, c3, c4, c5, c7, c8, c9, c11;
--Testcase 254:
SELECT c1 || c2, c3 || c7, c4/2+c8-c5/32+c9, c11 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 HAVING min(c4) < min (c8) ORDER BY c1, c2, c3, c4, c5, c7, c8, c9, c11;
--Testcase 255:
EXPLAIN VERBOSE SELECT c1, c2, c3, 1, 2, 'abc' FROM tbl01 GROUP BY c1, c2, c3 HAVING max(c4) - max(c5) > 0 ORDER BY c1, c2, c3;
--Testcase 256:
SELECT c1, c2, c3, 1, 2, 'abc' FROM tbl01 GROUP BY c1, c2, c3 HAVING max(c4) - max(c5) > 0 ORDER BY c1, c2, c3;
--ORDER BY 6
--Testcase 257:
EXPLAIN VERBOSE SELECT c4-c5, c8/c9, c11 || 'timex', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 ORDER BY c4, c5, c8, c9, c10, c11;
--Testcase 258:
SELECT c4-c5, c8/c9, c11 || 'timex', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 ORDER BY c4, c5, c8, c9, c10, c11;
--Testcase 259:
EXPLAIN VERBOSE SELECT c1 || c2 || c3, c4 - 100, c5/112*c6-c9/c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 ORDER BY c1, c2, c3, c4, c5, c6, c9, c10;
--Testcase 260:
SELECT c1 || c2 || c3, c4 - 100, c5/112*c6-c9/c10 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c9, c10 ORDER BY c1, c2, c3, c4, c5, c6, c9, c10;
--Testcase 261:
EXPLAIN VERBOSE SELECT upper(c1 || c2), lower(c3 || c7), abs(c4/2+c5 + c8/(c9-23)) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 ORDER BY c1, c2, c3, c4, c5, c7, c8, c9, c11;
--Testcase 262:
SELECT upper(c1 || c2), lower(c3 || c7), abs(c4/2+c5 + c8/(c9-23)) FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c7, c8, c9, c11 ORDER BY c1, c2, c3, c4, c5, c7, c8, c9, c11;
--Testcase 263:
EXPLAIN VERBOSE SELECT length(c1 || c2 || c3), floor(c4-c5), c8/3+c9, c11 + '23 hours'::interval FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 ORDER BY c1, c2, c3, c4, c5, c8, c9, c11;
--Testcase 264:
SELECT length(c1 || c2 || c3), floor(c4-c5), c8/3+c9, c11 + '23 hours'::interval FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 ORDER BY c1, c2, c3, c4, c5, c8, c9, c11;
--Testcase 265:
EXPLAIN VERBOSE SELECT c1, c3, c5, c7, c9, c11 FROM tbl01 GROUP BY c1, c3, c5, c7, c9, c11 ORDER BY c1, c3, c5, c7, c9, c11;
--Testcase 266:
SELECT c1, c3, c5, c7, c9, c11 FROM tbl01 GROUP BY c1, c3, c5, c7, c9, c11 ORDER BY c1, c3, c5, c7, c9, c11;
--ORDER BY 7
--Testcase 267:
EXPLAIN VERBOSE SELECT c3, c5, c1, c8, c7, c2, c4, c6 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING min(c3) != 'wef' ORDER BY c1, c2, c3, c4, c5, c6, c7, c8;
--Testcase 268:
SELECT c3, c5, c1, c8, c7, c2, c4, c6 FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 HAVING min(c3) != 'wef' ORDER BY c1, c2, c3, c4, c5, c6, c7, c8;
--Testcase 269:
EXPLAIN VERBOSE SELECT c4-c5, c8/c9, c11 || 'timez', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING max(c4) > 0 ORDER BY c4, c5, c8, c9, c11;
--Testcase 270:
SELECT c4-c5, c8/c9, c11 || 'timez', c10 FROM tbl01 GROUP BY c4, c5, c8, c9, c10, c11 HAVING max(c4) > 0 ORDER BY c4, c5, c8, c9, c11;
--Testcase 271:
EXPLAIN VERBOSE SELECT c1, lower(c2 || c3), abs(c4-c5), abs(c8/3+c9), c11 + '23 hours'::interval FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING sum(c5) != min(c4) ORDER BY c1, c2, c3, c4, c5, c8, c9, c11;
--Testcase 272:
SELECT c1, lower(c2 || c3), abs(c4-c5), abs(c8/3+c9), c11 + '23 hours'::interval FROM tbl01 GROUP BY c1, c2, c3, c4, c5, c8, c9, c11 HAVING sum(c5) != min(c4) ORDER BY c1, c2, c3, c4, c5, c8, c9, c11;
--ORDER BY 8
--Testcase 273:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 ORDER BY 1, 2, 3;
--Testcase 274:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE __spd_url != '%svr_' GROUP BY c1, c2, c3, c4, c5, c6, c7, c8 ORDER BY 1, 2, 3;
--Testcase 275:
EXPLAIN VERBOSE SELECT * FROM tbl01 WHERE __spd_url != 'ae' ORDER BY c1, c2;
--Testcase 276:
SELECT * FROM tbl01 WHERE __spd_url != 'ae' ORDER BY c1, c2;
--Testcase 277:
EXPLAIN VERBOSE SELECT c1 || c2, c3 || c7, c4-c5, c8/(c9+c6), c11 + '23 hours'::interval FROM tbl01 WHERE c5 >= 0 AND __spd_url != '$' ORDER BY 1,2;
--Testcase 278:
SELECT c1 || c2, c3 || c7, c4-c5, c8/(c9+c6), c11 + '23 hours'::interval FROM tbl01 WHERE c5 >= 0 AND __spd_url != '$' ORDER BY 1,2;
--Testcase 279:
EXPLAIN VERBOSE SELECT lower(c1), upper(c2 || c3), c4/(c5+3)*c6-c8/122 FROM tbl01 WHERE __spd_url ilike '%svr_' ORDER BY 1,2,3,4,5;
--Testcase 280:
SELECT lower(c1), upper(c2 || c3), c4/(c5+3)*c6-c8/122 FROM tbl01 WHERE __spd_url ilike '%svr_' ORDER BY 1,2,3,4,5;
--ORDER BY 9
--Testcase 281:
EXPLAIN VERBOSE SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE c3 != 'wef' ORDER BY c1;
--Testcase 282:
SELECT c1, c2, c3, c4, c5, c6, c7, c8 FROM tbl01 WHERE c3 != 'wef' ORDER BY c1;
--Testcase 283:
EXPLAIN VERBOSE SELECT round(c4-c5), floor(c8/3+c9), c11 || 'timey', c10 FROM tbl01 WHERE c4 > 0 ORDER BY c1, c2;
--Testcase 284:
SELECT round(c4-c5), floor(c8/3+c9), c11 || 'timey', c10 FROM tbl01 WHERE c4 > 0 ORDER BY c1, c2;
--Testcase 285:
EXPLAIN VERBOSE SELECT c1 || c2, upper(c3), floor(c4/112-c5+ c8/3+c9), c11 + '1 hour'::interval FROM tbl01 WHERE c5 > c4 ORDER BY 1,2;
--Testcase 286:
SELECT c1 || c2, upper(c3), floor(c4/112-c5+ c8/3+c9), c11 + '1 hour'::interval FROM tbl01 WHERE c5 > c4 ORDER BY 1,2;
--Testcase 287:
EXPLAIN VERBOSE SELECT length(c1 || c2), lower(c3), abs(c5/12+c8/3-c9+c10) FROM tbl01 WHERE NOT c4 < 0 ORDER BY 1,2;
--Testcase 288:
SELECT length(c1 || c2), lower(c3), abs(c5/12+c8/3-c9+c10) FROM tbl01 WHERE NOT c4 < 0 ORDER BY 1,2;
--ORDER BY 10
--Testcase 289:
EXPLAIN VERBOSE SELECT count(*), count(c1), count(c3) FROM tbl01 GROUP BY c4 HAVING min(c4) != 0 ORDER BY 1;
--Testcase 290:
SELECT count(*), count(c1), count(c3) FROM tbl01 GROUP BY c4 HAVING min(c4) != 0 ORDER BY 1;
--Testcase 291:
EXPLAIN VERBOSE SELECT min(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 GROUP BY c3 HAVING max(c3) IS NOT NULL ORDER BY c3;
--Testcase 292:
SELECT min(c1 || c2), max(c3), min(c4), sum(c5) FROM tbl01 GROUP BY c3 HAVING max(c3) IS NOT NULL ORDER BY c3;
--Testcase 293:
EXPLAIN VERBOSE SELECT max(c5+c6), max(c7), min(c8), min(c9 - c10), max(c11) FROM tbl01 GROUP BY c3, c7 HAVING max(c7) != max(c3) ORDER BY c3, c7;
--Testcase 294:
SELECT max(c5+c6), max(c7), min(c8), min(c9 - c10), max(c11) FROM tbl01 GROUP BY c3, c7 HAVING max(c7) != max(c3) ORDER BY c3, c7;
--Testcase 295:
EXPLAIN VERBOSE SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 GROUP BY c4, c8 HAVING min(c4) < min(c8) ORDER BY c4, c8;
--Testcase 296:
SELECT min(c7), max(c8), sum(c8-c9), count(c10) FROM tbl01 GROUP BY c4, c8 HAVING min(c4) < min(c8) ORDER BY c4, c8;
--Testcase 297:
EXPLAIN VERBOSE SELECT sum(c5), max(c7), min(c8), count(c9/2-c5) FROM tbl01 GROUP BY c3 HAVING count(c3) > 0 ORDER BY c3;
--Testcase 298:
SELECT sum(c5), max(c7), min(c8), count(c9/2-c5) FROM tbl01 GROUP BY c3 HAVING count(c3) > 0 ORDER BY c3;
--ORDER BY 11
--Testcase 299:
EXPLAIN VERBOSE SELECT '~!@#$%^&*()_+=-,./[]\\',332, 'wefakef', 21332 FROM tbl01 WHERE c3 IS NOT NULL GROUP BY c7 HAVING c7 != '' ORDER BY c7;
--Testcase 300:
SELECT '~!@#$%^&*()_+=-,./[]\\',332, 'wefakef', 21332 FROM tbl01 WHERE c3 IS NOT NULL GROUP BY c7 HAVING c7 != '' ORDER BY c7;
--Testcase 301:
EXPLAIN VERBOSE SELECT c1, c2, c3, __spd_url FROM tbl01 WHERE c3 > c7 GROUP BY c1, c2, c3, c4, __spd_url HAVING c4 BETWEEN -11000 AND 10000 ORDER BY c1, c2, c3, c4, __spd_url;
--Testcase 302:
SELECT c1, c2, c3, __spd_url FROM tbl01 WHERE c3 > c7 GROUP BY c1, c2, c3, c4, __spd_url HAVING c4 BETWEEN -11000 AND 10000 ORDER BY c1, c2, c3, c4, __spd_url;
--Testcase 303:
EXPLAIN VERBOSE SELECT count(DISTINCT c8), c1, c2, c3 FROM tbl01 WHERE c5 NOT IN (-122.2,233.12,232.2) GROUP BY c1, c2, c3, c8, c9 HAVING c8 > c9 ORDER BY c1, c2, c3, c8, c9;
--Testcase 304:
SELECT count(DISTINCT c8), c1, c2, c3 FROM tbl01 WHERE c5 NOT IN (-122.2,233.12,232.2) GROUP BY c1, c2, c3, c8, c9 HAVING c8 > c9 ORDER BY c1, c2, c3, c8, c9;
--Testcase 305:
EXPLAIN VERBOSE SELECT array_agg(c3 || ' ' || c7), json_agg(('c3_x',c3)), jsonb_agg(('c3_y',c3)), json_object_agg('c7_x', c7), jsonb_object_agg('c7_y', c7) FROM tbl01 WHERE c4 > c5 GROUP BY c8 HAVING c8 != 0 ORDER BY c8;
--Testcase 306:
SELECT array_agg(c3 || ' ' || c7), json_agg(('c3_x',c3)), jsonb_agg(('c3_y',c3)), json_object_agg('c7_x', c7), jsonb_object_agg('c7_y', c7) FROM tbl01 WHERE c4 > c5 GROUP BY c8 HAVING c8 != 0 ORDER BY c8;
--Testcase 307:
EXPLAIN VERBOSE SELECT string_agg(c3, ' ' ORDER BY c3), string_agg(c7, ' ' ORDER BY c7), c1, c2 FROM tbl01 WHERE c9 >= c8 GROUP BY c1, c2, c8, c9 HAVING c9 >= 0 ORDER BY c1,c2;
--Testcase 308:
SELECT string_agg(c3, ' ' ORDER BY c3), string_agg(c7, ' ' ORDER BY c7), c1, c2 FROM tbl01 WHERE c9 >= c8 GROUP BY c1, c2, c8, c9 HAVING c9 >= 0 ORDER BY c1,c2;
--Testcase 309:
EXPLAIN VERBOSE SELECT lower(c1), c2 || c3, string_agg(c3, c7) FROM tbl01 WHERE c8-c9 != 0 GROUP BY c1, c2, c3, c4, c5 HAVING c4 - c5 > 0 ORDER BY c1, c2, c3;
--Testcase 310:
SELECT lower(c1), c2 || c3, string_agg(c3, c7) FROM tbl01 WHERE c8-c9 != 0 GROUP BY c1, c2, c3, c4, c5 HAVING c4 - c5 > 0 ORDER BY c1, c2, c3;

