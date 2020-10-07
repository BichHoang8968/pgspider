------------------------------BasicFeature1_GridDB_4ARG-----------------------------
SET timezone TO 0;
-- Testcase 1:
SELECT * FROM t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC, __spd_url;
-- Testcase 2:
SELECT * FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC, __spd_url;
-- Testcase 3:
SELECT * FROM view_t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC, __spd_url;
-- Testcase 4:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 5:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 6:
SELECT c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM view_t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 7:
SELECT c11, c12, c13, c14, c15, c16, c17, c18, c19 FROM t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 8:
SELECT c11, c12, c13, c14, c15, c16, c17, c18, c19 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 9:
SELECT c11, c12, c13, c14, c15, c16, c17, c18, c19 FROM view_t1 ORDER BY 1 DESC, 2, 3 ASC, 4, 5 DESC, 6, 7, 8 DESC, 9 ASC;
-- Testcase 10:
SELECT __spd_url FROM t1 ORDER BY 1 DESC;
-- Testcase 11:
SELECT __spd_url FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC;
-- Testcase 12:
SELECT __spd_url FROM view_t1 ORDER BY 1 DESC;
-- Testcase 13:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 14:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 15:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 16:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 17:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 18:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 19:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 20:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 21:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 22:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 23:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 24:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 25:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 26:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 27:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 28:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 29:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 30:
SELECT max(c1), max(c1+10)-10, max(c1)+10.5, max(c1)*20 FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 31:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 32:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 33:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 34:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 35:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 36:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 37:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 38:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 39:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 40:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 41:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 42:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 43:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 44:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 45:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 46:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 47:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 48:
SELECT max(c3), max(c4*2+10), max(c7-10) +100 FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 49:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 50:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 51:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 52:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 53:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 54:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 55:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 56:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 57:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 58:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 59:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 60:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 61:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 62:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 63:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 64:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 65:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 66:
SELECT min(c4), min(c4)+10, min(c6)*10+1.5 FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 67:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 68:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 69:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 70:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 71:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 72:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 73:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 74:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 75:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 76:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 77:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 78:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 79:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 80:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 81:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 82:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 83:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 84:
SELECT min(c4-c3), min(c6+c7), min(c1)/max(c3) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 85:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 86:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 87:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 88:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 89:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 90:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 91:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 92:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 93:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 94:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 95:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 96:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 97:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 98:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 99:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 100:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 101:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 102:
SELECT sum(c1), sum(c3)+10, sum(c4) - 10, sum(c7) * 2, sum(c1-c3) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 103:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 104:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 105:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 106:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 107:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 108:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 109:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 110:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 111:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 112:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 113:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 114:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 115:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 116:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 117:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 118:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 119:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 120:
SELECT sum(c8)+1000, sum(c7)/min(c3) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 121:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 122:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 123:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 124:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 125:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 126:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 127:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 128:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 129:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 130:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 131:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 132:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 133:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 134:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 135:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 136:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 137:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 138:
SELECT avg(c1), avg(c3)+50, avg(c3+c4) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 139:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 140:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 141:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 142:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 143:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 144:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 145:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 146:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 147:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 148:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 149:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 150:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 151:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 152:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 153:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 154:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 155:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 156:
SELECT count(*), count(c19), count (DISTINCT c10), count (ALL c9) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 157:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 158:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 159:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 160:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 161:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 162:
SELECT stddev(c3)+10, stddev(c4)-10 FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 163:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 164:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 165:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 166:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 167:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 168:
SELECT stddev(c3)+10, stddev(c4)-10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 169:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 170:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 171:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 172:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 173:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 174:
SELECT stddev(c3)+10, stddev(c4)-10 FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 175:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 176:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 177:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 178:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 179:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 180:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 181:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 182:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 183:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 184:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 185:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 186:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 187:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 188:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 189:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 190:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 191:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 192:
SELECT array_agg(c1 order by c1), array_agg(c3 order by c3), array_agg(c4 order by c4), array_agg(not c5 order by c5), array_agg(c6-c1 order by c6,c1) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 193:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 194:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 195:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 196:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 197:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 198:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 199:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 200:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 201:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 202:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 203:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 204:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 205:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 206:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 207:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 208:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 209:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 210:
SELECT bit_and(c1), bit_and(c3)*5, bit_and(c4)-10, bit_and(c6)+10 FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 211:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 212:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 213:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 214:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 215:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 216:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 217:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 218:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 219:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 220:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 221:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 222:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 223:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 224:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 225:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 226:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 227:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 228:
SELECT bit_or(c1), bit_or(c3)*5, bit_or(c4)-10, bit_or(c6)+10, bit_or( (SELECT (c1+c3) WHERE c1<1000 AND c1>-100 AND c3<100 AND c3>-100) ) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 229:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 230:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 231:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 232:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 233:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 234:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 235:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 236:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 237:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 238:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 239:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 240:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 241:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 242:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 243:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 244:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 245:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 246:
SELECT bool_and(c5), bool_and(c1>0), bool_and(c3>0), bool_and(c8<0) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 247:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 248:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 249:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 250:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 251:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 252:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 253:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 254:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 255:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 256:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 257:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 258:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 259:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 260:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 261:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 262:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 263:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 264:
SELECT bool_or(c5), bool_or(c1>0), bool_or(c3>0), bool_or(c8<0) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 265:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 266:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 267:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC;
-- Testcase 268:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC;
-- Testcase 269:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC;
-- Testcase 270:
SELECT string_agg(c2,';' ORDER BY c2) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC;
-- Testcase 271:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 272:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 273:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1 DESC;
-- Testcase 274:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC;
-- Testcase 275:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC;
-- Testcase 276:
SELECT string_agg(c2,';' ORDER BY c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC;
-- Testcase 277:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1 ORDER BY 1 DESC;
-- Testcase 278:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1, c2 ORDER BY 1 DESC;
-- Testcase 279:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC;
-- Testcase 280:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC;
-- Testcase 281:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC;
-- Testcase 282:
SELECT string_agg(c2,';' ORDER BY c2) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC;
-- Testcase 283:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 284:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 285:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 286:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 287:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 288:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 289:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 290:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 291:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 292:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 293:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 294:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 295:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 296:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 297:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 298:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 299:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 300:
SELECT every(c1>0), every(c3!=1234), every(c5!=false), every(c7!=c8) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 301:
SELECT sqrt(abs(c7)), sqrt(abs(c3)) FROM t1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 302:
SELECT sqrt(abs(c7)), sqrt(abs(c3)) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 303:
SELECT sqrt(abs(c7)), sqrt(abs(c3)) FROM view_t1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 304:
SELECT upper(c2), upper(__spd_url), lower(c2) FROM t1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 305:
SELECT upper(c2), upper(__spd_url), lower(c2) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 306:
SELECT upper(c2), upper(__spd_url), lower(c2) FROM view_t1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 307:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 308:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 309:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 310:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 311:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 312:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 313:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 314:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 315:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 316:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 317:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 318:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 319:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 320:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3, 4;
-- Testcase 321:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3, 4;
-- Testcase 322:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3, 4;
-- Testcase 323:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3, 4;
-- Testcase 324:
SELECT max(c8), min(c7), sum(c1)+sum(c3), sum(c3-c1), count(*)+100, avg(c3) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3, 4;
-- Testcase 325:
SELECT c14, max(c8), sum(c1)-sum(c3), count(*)+100, avg(c3) FROM t1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 326:
SELECT c14, max(c8), sum(c1)-sum(c3), count(*)+100, avg(c3) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 327:
SELECT c14, max(c8), sum(c1)-sum(c3), count(*)+100, avg(c3) FROM view_t1 ORDER BY 1,2 DESC,3, 4;
-- Testcase 328:
SELECT c1* (random()<= 1)::int,  (random()<=1)::int+10+c1 FROM t1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 329:
SELECT c1* (random()<= 1)::int,  (random()<=1)::int+10+c1 FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 330:
SELECT c1* (random()<= 1)::int,  (random()<=1)::int+10+c1 FROM view_t1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 331:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 332:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 333:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 334:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 335:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 336:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 337:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 338:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 339:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 340:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 341:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 342:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 343:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 344:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1, c2 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 345:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 346:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 347:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1,2 DESC,3 DESC;
-- Testcase 348:
SELECT max(c17), count(*), exists(SELECT * FROM t1 WHERE c3>0) FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 349:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 350:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 351:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 352:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 353:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 354:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 355:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 356:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 357:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 358:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 359:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 360:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 361:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1 ORDER BY 1 DESC, 2 ASC;
-- Testcase 362:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1, c2 ORDER BY 1 DESC, 2 ASC;
-- Testcase 363:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1, c2, c3 ORDER BY 1 DESC, 2 ASC;
-- Testcase 364:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1 HAVING c1>-10 AND max(c1)>0 ORDER BY 1 DESC, 2 ASC;
-- Testcase 365:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1, c2 HAVING avg(c1)<0 AND c2!='abcd' ORDER BY 1 DESC, 2 ASC;
-- Testcase 366:
SELECT max(c1), sum(c1) filter (WHERE c3<1)  FROM view_t1 GROUP BY c1, c2, c3 HAVING sum(c1)<100 OR min(c1)<0 AND max(c3)<200 ORDER BY 1 DESC, 2 ASC;
-- Testcase 367:
SELECT 'abcd', c19, 10+c7*(random()<=1)::int FROM t1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 368:
SELECT 'abcd', c19, 10+c7*(random()<=1)::int FROM (SELECT * FROM t1 WHERE c5!=true or c5=true ) AS tb1 ORDER BY 1,2 DESC,3 DESC;
-- Testcase 369:
SELECT 'abcd', c19, 10+c7*(random()<=1)::int FROM view_t1 ORDER BY 1,2 DESC,3 DESC;
