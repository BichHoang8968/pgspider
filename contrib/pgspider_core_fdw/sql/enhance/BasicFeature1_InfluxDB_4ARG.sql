------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature1_InfluxDB_4ARG-----------------------------
-- Testcase 1:
SELECT * FROM t7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5, __spd_url;
-- Testcase 2:
SELECT * FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5, __spd_url;
-- Testcase 3:
SELECT * FROM view_t7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5, __spd_url;
-- Testcase 4:
SELECT time, c2 FROM t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 5:
SELECT time, c2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC;
-- Testcase 6:
SELECT time, c2 FROM view_t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 7:
SELECT  c2, c3, c4, c5 FROM t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 8:
SELECT  c2, c3, c4, c5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 9:
SELECT  c2, c3, c4, c5 FROM view_t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 10:
SELECT __spd_url FROM t7 ORDER BY 1;
-- Testcase 11:
SELECT __spd_url FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1;
-- Testcase 12:
SELECT __spd_url FROM view_t7 ORDER BY 1;
-- Testcase 13:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 14:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 15:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 16:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 17:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 18:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 19:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 20:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 21:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 22:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 23:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 24:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 25:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 26:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 27:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 28:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 29:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 30:
SELECT max(time), max(c3), max(c3)+10, max(c3)-10, max(c4), max(c4)/2 FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 31:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 32:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 33:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 34:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 35:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 36:
SELECT max(time), max(c4*0.5), max(c3+10) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 37:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 38:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 39:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 40:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 41:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 42:
SELECT max(time), max(c4*0.5), max(c3+10) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 43:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 44:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 45:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 46:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 47:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 48:
SELECT max(time), max(c4*0.5), max(c3+10) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 49:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 50:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 51:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 52:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 53:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 54:
SELECT min(time), min(c3)+10, min(c4)/2 FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 55:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 56:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 57:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 58:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 59:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 60:
SELECT min(time), min(c3)+10, min(c4)/2 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 61:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 62:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 63:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 64:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 65:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 66:
SELECT min(time), min(c3)+10, min(c4)/2 FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 67:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 68:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 69:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 70:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 71:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 72:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 73:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 74:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 75:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 76:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 77:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 78:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 79:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 80:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 81:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 82:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 83:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 84:
SELECT min(time)+'10 days'::interval, min(c3+c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 85:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 86:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 87:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 88:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 89:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 90:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 91:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 92:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 93:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 94:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 95:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 96:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 97:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 98:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 99:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 100:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 101:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 102:
SELECT sum(c3), sum(c4 ORDER BY c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 103:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 104:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 105:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 106:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 107:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 108:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 109:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 110:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 111:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 112:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 113:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 114:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 115:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 116:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 117:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 118:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 119:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 120:
SELECT sum(c3+c4 ORDER BY c3+c4), sum(c3*2), sum(c3)-5 FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 121:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 122:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 123:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 124:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 125:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 126:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 127:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 128:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 129:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 130:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 131:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 132:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 133:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 134:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 135:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 136:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 137:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 138:
SELECT avg(c4 ORDER BY c4), avg(c3), avg(c3)-10, avg(c3)*0.5 FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 139:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 140:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 141:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 142:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 143:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 144:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 145:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 146:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 147:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 148:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 149:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 150:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 151:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 152:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 153:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 154:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 155:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 156:
SELECT avg(c4-c3 ORDER BY c4-c3) c1, avg(c3)>50 FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 157:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 158:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 159:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 160:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 161:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 162:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 163:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 164:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 165:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 166:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 167:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 168:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 169:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 170:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 171:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 172:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 173:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 174:
SELECT count(*), count(time), count (DISTINCT c3), count (ALL c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 175:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 176:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 177:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 178:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 179:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 180:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 181:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 182:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 183:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 184:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 185:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 186:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 187:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 188:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 189:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 190:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 191:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 192:
SELECT stddev(c3), stddev(c4 ORDER BY c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 193:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 194:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 195:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 196:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 197:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 198:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 199:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 200:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 201:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 202:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 203:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 204:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 205:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 206:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 207:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 208:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 209:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 210:
SELECT array_agg(c3/2 ORDER BY c3), array_agg(c2 ORDER BY c2), array_agg(time ORDER BY time) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 211:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 212:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 213:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 214:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 215:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 216:
SELECT bit_and(c3), bit_and(c3+15) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 217:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 218:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 219:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 220:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 221:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 222:
SELECT bit_and(c3), bit_and(c3+15) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 223:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 224:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 225:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 226:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 227:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 228:
SELECT bit_and(c3), bit_and(c3+15) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 229:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 230:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 231:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 232:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 233:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 234:
SELECT bit_or(c3), bit_or(c3/2) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 235:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 236:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 237:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 238:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 239:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 240:
SELECT bit_or(c3), bit_or(c3/2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 241:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 242:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 243:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 244:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 245:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 246:
SELECT bit_or(c3), bit_or(c3/2) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 247:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 248:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 249:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 250:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 251:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 252:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 253:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 254:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 255:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 256:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 257:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 258:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 259:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 260:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 261:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 262:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 263:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 264:
SELECT bool_and(c4>0), bool_and(c3<0), bool_and(c3<c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 265:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 266:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 267:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 268:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 269:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 270:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 271:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 272:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 273:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 274:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 275:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 276:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 277:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY time ORDER BY 1 DESC, 2, 3;
-- Testcase 278:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY c2 ORDER BY 1 DESC, 2, 3;
-- Testcase 279:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 280:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC, 2, 3;
-- Testcase 281:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC, 2, 3;
-- Testcase 282:
SELECT bool_or(c4<0), bool_or(c3>10), bool_or(c3 != c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC, 2, 3;
-- Testcase 283:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY time ORDER BY 1;
-- Testcase 284:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY c2 ORDER BY 1;
-- Testcase 285:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1;
-- Testcase 286:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1;
-- Testcase 287:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1;
-- Testcase 288:
SELECT string_agg(c2, ';' ORDER BY c2) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1;
-- Testcase 289:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1;
-- Testcase 290:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1;
-- Testcase 291:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1;
-- Testcase 292:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1;
-- Testcase 293:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1;
-- Testcase 294:
SELECT string_agg(c2, ';' ORDER BY c2) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1;
-- Testcase 295:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY time ORDER BY 1;
-- Testcase 296:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY c2 ORDER BY 1;
-- Testcase 297:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1;
-- Testcase 298:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1;
-- Testcase 299:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1;
-- Testcase 300:
SELECT string_agg(c2, ';' ORDER BY c2) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1;
-- Testcase 301:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 302:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 303:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 304:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 305:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 306:
SELECT every(c3>0), every(c4 != c3) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 307:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 308:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 309:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 310:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 311:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 312:
SELECT every(c3>0), every(c4 != c3) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 313:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 314:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 315:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 316:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 317:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 318:
SELECT every(c3>0), every(c4 != c3) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 319:
SELECT sqrt(abs(c3)), sqrt(abs(c4)) FROM t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 320:
SELECT sqrt(abs(c3)), sqrt(abs(c4)) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC;
-- Testcase 321:
SELECT sqrt(abs(c3)), sqrt(abs(c4)) FROM view_t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 322:
SELECT upper(c2), upper(__spd_url), lower(c2), lower(__spd_url) FROM t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 323:
SELECT upper(c2), upper(__spd_url), lower(c2), lower(__spd_url) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 324:
SELECT upper(c2), upper(__spd_url), lower(c2), lower(__spd_url) FROM view_t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 325:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 326:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 327:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 328:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 329:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 330:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 331:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 332:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 333:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 334:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 335:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 336:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 337:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 338:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY c2 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 339:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 340:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 341:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 342:
SELECT max(time), min(c3), sum(c4 ORDER BY c4), count(*), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 343:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 344:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM t7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 345:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 346:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 347:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM view_t7 GROUP BY time ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 348:
SELECT time, max(c3), min(c4-c3), sum(c3), count(c2), avg(c4 ORDER BY c4) FROM view_t7 ORDER BY 1 DESC,2 ASC,3 DESC,4,5;
-- Testcase 349:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 350:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 351:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 352:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 353:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC;
-- Testcase 354:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 355:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 356:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 357:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM view_t7 ORDER BY 1 ASC,2 DESC;
-- Testcase 358:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 359:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 360:
SELECT c3*(random()<=1)::int, (random()<=1)::int*(25-10)+10 FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 361:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 362:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 363:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 364:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 365:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 366:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 367:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 368:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 369:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 370:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 371:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 372:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 373:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 374:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 375:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 376:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 377:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 378:
SELECT max(c3), count(*), exists(SELECT * FROM t7 WHERE c3>1), exists (SELECT count(*) FROM t7 WHERE c4>10.5) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 379:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 380:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 381:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 382:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 383:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 384:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 385:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 386:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 387:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 388:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 389:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 390:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 391:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY time ORDER BY 1 ASC,2 DESC;
-- Testcase 392:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY c2 ORDER BY 1 ASC,2 DESC;
-- Testcase 393:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)>min(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 394:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY c2, c3, c4 HAVING sum(c3)>avg(c4) ORDER BY 1 ASC,2 DESC;
-- Testcase 395:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY c3, c4 HAVING min(c3)<100 AND max(c4)<1000 AND sum(c3)>-1000 AND avg(c3)>-1000 ORDER BY 1 ASC,2 DESC;
-- Testcase 396:
SELECT sum(c3) filter (WHERE c3<100 and c3>-100), avg(c4 ORDER BY c4) filter (WHERE c4 >0 AND c4<100) FROM view_t7 GROUP BY c5 HAVING c5 != true ORDER BY 1 ASC,2 DESC;
-- Testcase 397:
SELECT 'abcd', 1234, c3/2, 10+c4 * (random()<=1)::int * 0.5 FROM t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 398:
SELECT 'abcd', 1234, c3/2, 10+c4 * (random()<=1)::int * 0.5 FROM ( SELECT * FROM t7 WHERE c3>-1000 AND c4<1000 ) AS tb7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
-- Testcase 399:
SELECT 'abcd', 1234, c3/2, 10+c4 * (random()<=1)::int * 0.5 FROM view_t7 ORDER BY 1 ASC,2 DESC,3 ASC,4;
