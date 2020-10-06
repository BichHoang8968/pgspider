------------------------------BasicFeature1_tmp_t15_4ARG-----------------------------
SET timezone TO 0;
-- Testcase 1:
SELECT * FROM tmp_t15 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5, __spd_url;
-- Testcase 2:
SELECT * FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5, __spd_url;
-- Testcase 3:
SELECT * FROM view_t15 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5, __spd_url;
-- Testcase 4:
SELECT time, c2, c3 FROM tmp_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 5:
SELECT time, c2, c3 FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 6:
SELECT time, c2, c3 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 7:
SELECT time, c2, c3 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 8:
SELECT time, c2, c3 FROM view_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 9:
SELECT time, c2, c3 FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 10:
SELECT __spd_url FROM tmp_t15 ORDER BY 1  DESC;
-- Testcase 11:
SELECT __spd_url FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 12:
SELECT __spd_url FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 13:
SELECT __spd_url FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  DESC;
-- Testcase 14:
SELECT __spd_url FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 15:
SELECT __spd_url FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 16:
SELECT __spd_url FROM view_t15 ORDER BY 1  DESC;
-- Testcase 17:
SELECT __spd_url FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 18:
SELECT __spd_url FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 19:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 20:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 21:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 22:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 23:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 24:
SELECT max(time), max(c3), max(c4) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 25:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 26:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 27:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 28:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 29:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 30:
SELECT max(time), max(c3), max(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 31:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 32:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 33:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 34:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 35:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 36:
SELECT max(time), max(c3), max(c4) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 37:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 38:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 39:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 40:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 41:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 42:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 43:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 44:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 45:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 46:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 47:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 48:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 49:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 50:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 51:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 52:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 53:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 54:
SELECT max(c3+10), max(c4)-1000, max(c3+c4), max(2*c3), max(c4/3) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 55:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 56:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 57:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 58:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 59:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 60:
SELECT min(time), min(c3), min(c4) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 61:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 62:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 63:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 64:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 65:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 66:
SELECT min(time), min(c3), min(c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 67:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 68:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 69:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 70:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 71:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 72:
SELECT min(time), min(c3), min(c4) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 73:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 74:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 75:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 76:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 77:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 78:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 79:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 80:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 81:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 82:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 83:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 84:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 85:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 86:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 87:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 88:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 89:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 90:
SELECT min(c3-100), min(c3)+9900, min(c3+c4), min(2*c3), min(c4/3) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 91:
SELECT sum(c3 ORDER BY c3), sum(c4 order by c4) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 92:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 93:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 94:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 95:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 96:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 97:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 98:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 99:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 100:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 101:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 102:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 103:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 104:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 105:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 106:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 107:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 108:
SELECT sum(c3 ORDER BY c3), sum(c4 ORDER BY c4) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 109:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 110:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 111:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 112:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 113:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 114:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 115:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 116:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 117:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 118:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 119:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 120:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 121:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 122:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 123:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 124:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 125:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 126:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(2*c3+c4/2+10 ORDER BY 2*c3+c4/2+10), sum(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 127:
SELECT avg(c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 128:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 129:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 130:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 131:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 132:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 133:
SELECT avg(c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 134:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 135:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 136:
SELECT avg(c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 137:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 138:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 139:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 140:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY time, c2, c3 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 141:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2, __spd_url ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 142:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 143:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 144:
SELECT avg(c3 ORDER BY c3), avg(c4 ORDER BY c4), avg(c3+c4 ORDER BY c3+c4), avg(c3/5+c4*20+10 ORDER BY c3/5+c4*20+10), avg(c4-c3 ORDER BY c4-c3)+2000 FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY  1 DESC, 2 ASC, 3 ASC, 4, 5;
-- Testcase 145:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 146:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 147:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 148:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 149:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 150:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 151:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 152:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 153:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 154:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 155:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 156:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 157:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 158:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 159:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 160:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 161:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 162:
SELECT count(*), count(all c2), count(c3+2000-c4*5), count(DISTINCT c2) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 163:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 164:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 165:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 166:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 167:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 168:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 169:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 170:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 171:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 172:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 173:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 174:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 175:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 176:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 177:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 178:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 179:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 180:
SELECT stddev(c3 ORDER BY c3), stddev(c4 ORDER BY c4) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 181:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 182:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 183:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 184:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 185:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 186:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 187:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 188:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 189:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 190:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 191:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 192:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 193:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2;
-- Testcase 194:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2;
-- Testcase 195:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2;
-- Testcase 196:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2;
-- Testcase 197:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 198:
SELECT array_agg(time ORDER BY time), array_agg(c3+c4  ORDER BY c3,c4) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2;
-- Testcase 199:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 200:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 201:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 202:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 203:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 204:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 205:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 206:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 207:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 208:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 209:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 210:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 211:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 212:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 213:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 214:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 215:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 216:
SELECT bit_and(c3), bit_and(c3+99), bit_and(c4::int) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 217:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 218:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 219:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 220:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 221:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 222:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 223:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 224:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 225:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 226:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 227:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 228:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 229:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 230:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 231:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 232:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 233:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 234:
SELECT bit_or(c3), bit_or(c3+99), bit_or(c4::int) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 235:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 236:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 237:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 238:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 239:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 240:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 241:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 242:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 243:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 244:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 245:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 246:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 247:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 248:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 249:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 250:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 251:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 252:
SELECT bool_and(c3>0), bool_and(c4<50 AND c4>-100), bool_and(c2 != 'a') FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 253:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 254:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 255:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 256:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 257:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 258:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 259:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 260:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 261:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 262:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 263:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 264:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 265:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 266:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 267:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 268:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 269:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 270:
SELECT bool_or(c3<100), bool_or(c4>0 and c4<2000), bool_or(c2 != 'hj') FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 271:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY c2 ORDER BY 1  DESC;
-- Testcase 272:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  DESC;
-- Testcase 273:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 274:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  DESC;
-- Testcase 275:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  DESC;
-- Testcase 276:
SELECT string_agg(c2, ',' ORDER BY c2) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 277:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  DESC;
-- Testcase 278:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  DESC;
-- Testcase 279:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 280:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  DESC;
-- Testcase 281:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  DESC;
-- Testcase 282:
SELECT string_agg(c2, ',' ORDER BY c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 283:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY c2 ORDER BY 1  DESC;
-- Testcase 284:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  DESC;
-- Testcase 285:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  DESC;
-- Testcase 286:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  DESC;
-- Testcase 287:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  DESC;
-- Testcase 288:
SELECT string_agg(c2, ',' ORDER BY c2) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  DESC;
-- Testcase 289:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 290:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 291:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 292:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 293:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 294:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 295:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 296:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 297:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 298:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 299:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 300:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 301:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 302:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 303:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 304:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 305:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 306:
SELECT every(c3<1090), every(c4 != 9988), every(c2 != 'живетезе') FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 307:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM tmp_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 308:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 309:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 310:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 311:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM view_t15 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 312:
SELECT sqrt(abs(c3)), sqrt(abs(c4)), sqrt(abs(c3+c4)) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 313:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM tmp_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 314:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 315:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 316:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 317:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM view_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 318:
SELECT upper(__spd_url), upper(c2), lower(__spd_url), lower(c2) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 319:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM tmp_t15 ORDER BY 1  ASC, 2;
-- Testcase 320:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 321:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  ASC, 2;
-- Testcase 322:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 323:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM view_t15 ORDER BY 1  ASC, 2;
-- Testcase 324:
SELECT c3*(random()<=1)::int, (random()<=1)::int*5+c4 FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2;
-- Testcase 325:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 326:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 327:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 328:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 329:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 330:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 331:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 332:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 333:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 334:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 335:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 336:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 337:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 338:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 339:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 340:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 341:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 342:
SELECT max(c3), count(c2), exists(SELECT * FROM tmp_t15 WHERE c3<c4 AND c2 NOT LIKE 'The%') FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 343:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 344:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 345:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 346:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 347:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 348:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 349:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 350:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 351:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 352:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 353:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 354:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 355:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY c2 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 356:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY time, c2, c3 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 357:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY c2, __spd_url ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 358:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY c2 HAVING c2 LIKE 'The%' OR c2 LIKE 'いろ%' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 359:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 360:
SELECT sum(c3 ORDER BY c3) filter (WHERE c3>0), count(*) filter (WHERE c3<c4), max(c4) filter (WHERE c4/50<0) FROM view_t15 GROUP BY c4, __spd_url HAVING avg(c4)>-1000 AND __spd_url != '/influx1/' ORDER BY 1  ASC, 2 DESC, 3 DESC;
-- Testcase 361:
SELECT c4, c3, 100, 'happy' FROM tmp_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 362:
SELECT c4, c3, 100, 'happy' FROM tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 363:
SELECT c4, c3, 100, 'happy' FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 364:
SELECT c4, c3, 100, 'happy' FROM (SELECT * FROM tmp_t15 WHERE c3>c4 OR c4 != 7654) AS tmp_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 365:
SELECT c4, c3, 100, 'happy' FROM view_t15 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
-- Testcase 366:
SELECT c4, c3, 100, 'happy' FROM view_t15 GROUP BY c3, c4 HAVING max(c3)<max(c4) AND sum(c4)<100000 ORDER BY 1  ASC, 2 DESC, 3, 4 DESC;
