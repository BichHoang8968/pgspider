------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
------------------------------BasicFeature1_t_max_range-----------------------------
-- griddb_max_range
-- Testcase 1:
SELECT * FROM griddb_max_range ORDER BY griddb_max_range.*;
-- Testcase 2:
SELECT c11, c12, c13, c14, __spd_url FROM griddb_max_range ORDER BY 1, 2, 3, 4, 5;
-- Testcase 3:
SELECT max(c10), max(c2)/2, max(c3)*2 FROM griddb_max_range;
-- Testcase 4:
SELECT min(c11), min(c7+0), min(c5) FROM griddb_max_range;
-- Testcase 5:
SELECT sum(c2), sum(c3)-5, sum(c5*1) FROM griddb_max_range;
-- Testcase 6:
SELECT avg(c1), avg(c2)/avg(c3), avg(c6)+avg(c5) FROM griddb_max_range;
-- Testcase 7:
SELECT max(c6)-avg(c7), min(c3-0)+sum(c5/1) FROM griddb_max_range;
-- Testcase 8:
SELECT stddev(c3), array_agg(c6 ORDER BY c6), every(c1!=3422) FROM griddb_max_range;
-- Testcase 9:
SELECT bit_and(c3), bit_or(c2), bool_and(c1>0), bool_or(c1!=c2) FROM griddb_max_range;
-- Testcase 10:
SELECT c15, max(c5), count(*), exists (SELECT max(c5) FROM griddb_max_range WHERE c1!=c7) FROM griddb_max_range GROUP BY c15 ORDER BY 1, 2, 3;
-- Testcase 11:
SELECT sum(c5) filter( WHERE c2<1000) FROM griddb_max_range;
-- Testcase 12:
SELECT '#%$#!12312fvdfs', c4,  c1*(random()<=1)::int, __spd_url, sqrt(abs(c5)) FROM griddb_max_range;
-- Testcase 13:
SELECT min(c1*20) FROM griddb_max_range;
-- Testcase 14:
SELECT avg(c3+c2+c5) FROM griddb_max_range;
-- Testcase 15:
SELECT sum(c6*c3) FROM griddb_max_range;
-- Testcase 16:
SELECT max(c8+'1 year'::interval) FROM griddb_max_range;
-- Testcase 17:
SELECT c7*c7 FROM griddb_max_range ORDER BY 1;
-- mysql_max_range 
-- Testcase 18:
SELECT * FROM mysql_max_range ORDER BY mysql_max_range.*;
-- Testcase 19:
SELECT c1, c2, c3, c4, __spd_url FROM mysql_max_range ORDER BY 1, 2, 3, 4, 5;
-- Testcase 20:
SELECT max(c1), max(c2)-5, max(c3)*2 FROM mysql_max_range;
-- Testcase 21:
SELECT min(c6), min(c7)+ 5, min(c8)/2 FROM mysql_max_range;
-- Testcase 22:
SELECT sum(c1), sum(c4+0), sum(c5*1) FROM mysql_max_range; 
-- Testcase 23:
SELECT avg(c1), avg(c2)-avg(c3), avg(c4)+avg(c5) FROM mysql_max_range;
-- Testcase 24:
SELECT max(c2)/avg(c2), min(c3)-sum(c4) FROM mysql_max_range;
-- Testcase 25:
SELECT stddev(c3), array_agg(c4), every(c9 != '9999-12-30') FROM mysql_max_range;
-- Testcase 26:
SELECT bit_and(c3), bit_or(c2), bool_and(c1>=0), bool_or(c1 != c2) FROM mysql_max_range;
-- Testcase 27:
SELECT c10, max(c5), count(*), exists ( SELECT max(c5) FROM mysql_max_range WHERE c1 != c4) FROM mysql_max_range GROUP BY c10 ORDER BY 1, 2, 3;
-- Testcase 28:
SELECT sum(c4) filter( WHERE c12>'2021-03-18 23:14:07' AND c4<1000) FROM mysql_max_range;
-- Testcase 29:
SELECT c12, 'NEWYORK', c1* (random()<=1)::int, __spd_url, sqrt(abs(c5)) FROM mysql_max_range;
-- Testcase 30:
SELECT max(c2*2) FROM mysql_max_range;
-- Testcase 31:
SELECT avg(c3+c2) FROM mysql_max_range;
-- Testcase 32:
SELECT sum(c4*c3) FROM mysql_max_range;
-- Testcase 33:
SELECT min(c11+'1 year'::interval) FROM mysql_max_range;
-- Testcase 34:
SELECT c1*c1, c2 FROM mysql_max_range ORDER BY 1, 2;
-- tinybrace_max_range 
-- Testcase 35:
SELECT * FROM tinybrace_max_range ORDER BY tinybrace_max_range.*;
-- Testcase 36:
SELECT c1, c2, __spd_url FROM tinybrace_max_range ORDER BY 1, 2, 3;
-- Testcase 37:
SELECT max(c1), max(c2)-50, max(c3)*3 FROM tinybrace_max_range;
-- Testcase 38:
SELECT min(c6), min(c7)+100, min(c8)/3 FROM tinybrace_max_range;
-- Testcase 39:
SELECT sum(c10), sum(c4+0), sum(c5*1) FROM tinybrace_max_range; 
-- Testcase 40:
SELECT avg(c1), avg(c2)-avg(c3), avg(c4)+avg(c5) FROM tinybrace_max_range; 
-- Testcase 41:
SELECT min(c9)/avg(c10), min(c3)-sum(c4) FROM tinybrace_max_range; 
-- Testcase 42:
SELECT stddev(c3), array_agg(c4), every(c12 != '1022-01-04') FROM tinybrace_max_range; 
-- Testcase 43:
SELECT bit_and(c3), bit_or(c2), bool_and(c1>46240), bool_or(c1 != c2) FROM tinybrace_max_range; 
-- Testcase 44:
SELECT count (DISTINCT c9), c12, sum(c5), exists (SELECT avg(c5) FROM t5 WHERE c1 != c4) FROM tinybrace_max_range GROUP BY c12 ORDER BY 1, 2, 3; 
-- Testcase 45:
SELECT sum(c4) filter( WHERE c13 != '2021-03-18 23:14:07') FROM tinybrace_max_range; 
-- Testcase 46:
SELECT c11, '1235@#$', c1* (random()<=1)::int, sqrt(abs(c3)) FROM tinybrace_max_range GROUP BY c1, c3, c11 ORDER BY 1, 2, 3, 4; 
-- Testcase 47:
SELECT max(c2*3) FROM tinybrace_max_range; 
-- Testcase 48:
SELECT avg(c3-c2) FROM tinybrace_max_range; 
-- Testcase 49:
SELECT sum(c7*c8) FROM tinybrace_max_range; 
-- Testcase 50:
SELECT min(c12+'1 year'::interval) FROM tinybrace_max_range; 
-- Testcase 51:
SELECT c2*c2, c7 FROM tinybrace_max_range ORDER BY 1, 2;
-- influx_max_range 
-- Testcase 52:
SELECT * FROM influx_max_range ORDER BY influx_max_range.*;
-- Testcase 53:
SELECT __spd_url , c2 FROM influx_max_range ORDER BY 1, 2;
-- Testcase 54:
SELECT max(c3)*4 , max(c2)+500, max(c2)  FROM influx_max_range;
-- Testcase 55:
SELECT min(c3), min(c2)-1000, min(c2)/4 FROM influx_max_range;
-- Testcase 56:
SELECT sum(c2+0), sum(c3*1) FROM influx_max_range; 
-- Testcase 57:
SELECT avg(c2)-avg(c3), avg(c3)+avg(c2) FROM influx_max_range; 
-- Testcase 58:
SELECT  sum(c2)-min(c3), avg(c3)/min(c2) FROM influx_max_range; 
-- Testcase 59:
SELECT stddev(c2), array_agg(c3), every(c4 != FALSE) FROM influx_max_range; 
-- Testcase 60:
SELECT bit_and(c2), bit_or(c2), bool_and(c3>136), bool_or(c3 != c2) FROM influx_max_range; 
-- Testcase 61:
SELECT count (ALL c4), c2, avg(c3), exists (SELECT * FROM  influx_max_range WHERE c3<c2) FROM influx_max_range GROUP BY c2 ORDER BY 1, 2, 3; 
-- Testcase 62:
SELECT sum(c2) filter(WHERE c3>-651) FROM influx_max_range; 
-- Testcase 63:
SELECT sqrt(abs(c3)), '$g%DG', c2*(random()<=1)::int  FROM influx_max_range ORDER BY 1, 2, 3;  
-- Testcase 64:
SELECT max(c2*3) FROM influx_max_range; 
-- Testcase 65:
SELECT avg(c3-c2) FROM influx_max_range; 
-- Testcase 66:
SELECT sum(c2*c3) FROM influx_max_range; 
-- Testcase 67:
SELECT min(c2-5) FROM influx_max_range; 
-- Testcase 68:
SELECT c3*c3, c4, time FROM influx_max_range;
-- post_max_range 
-- Testcase 69:
SELECT * FROM post_max_range ORDER BY post_max_range.*;
-- Testcase 70:
SELECT max(c1), max(c2), max(c4), max(c5), max(c6), max(c7), max(c8), max(c9) FROM post_max_range;
-- Testcase 71:
SELECT min(c1), min(c2), min(c4), min(c5), min(c6), min(c7), min(c8), min(c9) FROM post_max_range;
-- Testcase 72:
SELECT max(c1), min(c2), min(c4), max(c5), max(c6), min(c7), max(c8), min(c9) FROM post_max_range;
-- Testcase 73:
SELECT min(c1+c2) FROM post_max_range;
-- Testcase 74:
SELECT max(c4+c6) FROM post_max_range;
-- Testcase 75:
SELECT sum(c9) FROM post_max_range;
-- Testcase 76:
SELECT sum(c5), min(c6), max(c7) FROM post_max_range;
-- Testcase 77:
SELECT sum(c4+c7) FROM post_max_range;
-- Testcase 78:
SELECT avg(c5), avg(c6) FROM post_max_range;
-- Testcase 79:
SELECT count(c1), count(*), count(DISTINCT c4), count(ALL c5) FROM post_max_range;
-- Testcase 80:
SELECT stddev(c1), stddev(c2), stddev(c4+c7) FROM post_max_range;
-- Testcase 81:
SELECT array_agg(c5), array_agg(c6), array_agg(c7), array_agg(c8), array_agg(c9) FROM post_max_range;
-- Testcase 82:
SELECT bit_and(c1), bit_or(c2), bit_and(c5), bit_or(c7) FROM post_max_range;
-- Testcase 83:
SELECT bool_or(c1>0), bool_or(c2<=0), bool_and(c4<>0), bool_and(c5>=0) FROM post_max_range;
-- Testcase 84:
SELECT sqrt(abs(c1)), sqrt(abs(c4)), sqrt(abs(c6)), sqrt(abs(c7+c8)) FROM post_max_range;
-- tmp_file_max_range 
-- Testcase 85:
SELECT * FROM tmp_file_max_range ORDER BY tmp_file_max_range.*;
-- Testcase 86:
SELECT max(c1), max(c3), max(c4), max(c5), max(c6) FROM tmp_file_max_range;
-- Testcase 87:
SELECT min(c1), min(c3), min(c4), min(c5), min(c6) FROM tmp_file_max_range;
-- Testcase 88:
SELECT max(c1), min(c3), min(c4), max(c5), max(c6) FROM tmp_file_max_range;
-- Testcase 89:
SELECT min(c5+c3) FROM tmp_file_max_range;
-- Testcase 90:
SELECT max(c4+c1) FROM tmp_file_max_range;
-- Testcase 91:
SELECT sum(c6) FROM tmp_file_max_range;
-- Testcase 92:
SELECT sum(c5), min(c6), max(c1) FROM tmp_file_max_range;
-- Testcase 93:
SELECT sum(c4+c3) FROM tmp_file_max_range;
-- Testcase 94:
SELECT avg(c5), avg(c6) FROM tmp_file_max_range;
-- Testcase 95:
SELECT count(c2), count(*), count(DISTINCT c4), count(ALL c9) FROM tmp_file_max_range;
-- Testcase 96:
SELECT stddev(c1), stddev(c3), stddev(c4+c6) FROM tmp_file_max_range;
-- Testcase 97:
SELECT array_agg(c5), array_agg(c6), array_agg(c7), array_agg(c8), array_agg(c9) FROM tmp_file_max_range;
-- Testcase 98:
SELECT bit_and(c1), bit_or(c4), bit_and(c6) FROM tmp_file_max_range;
-- Testcase 99:
SELECT bool_or(c1>0), bool_or(c3<=0), bool_and(c4<>0), bool_and(c5>=0) FROM tmp_file_max_range;
-- Testcase 100:
SELECT sqrt(abs(c1)), sqrt(abs(c4)), sqrt(abs(c6)), sqrt(abs(c3+c5)) FROM tmp_file_max_range;
-- _sqlite_max_range 
-- Testcase 101:
SELECT * FROM _sqlite_max_range ORDER BY _sqlite_max_range.*;
-- Testcase 102:
SELECT max(c1), max(c2), max(c4), max(c5), max(c6), max(c7), max(c8), max(c9), max(c10), max(c11) FROM _sqlite_max_range;
-- Testcase 103:
SELECT min(c1), min(c2), min(c4), min(c5), min(c6), min(c7), min(c8), min(c9), max(c10), max(c11) FROM _sqlite_max_range;
-- Testcase 104:
SELECT max(c1), min(c2), min(c4), max(c5), max(c6), min(c7), max(c8), min(c9), max(c10), min(c11) FROM _sqlite_max_range;
-- Testcase 105:
SELECT min(c1+c3), max(c2+c6), max(c4+c5), min(c7*c9), max(c11/c10) FROM _sqlite_max_range;
-- Testcase 106:
SELECT sum(c9), sum(c1), sum(c11) FROM _sqlite_max_range;
-- Testcase 107:
SELECT sum(c5), min(c6), max(c7) FROM _sqlite_max_range;
-- Testcase 108:
SELECT sum(c4+c7), sum(c1*c10), max(c2*c8), min(c3+c9)  FROM _sqlite_max_range;
-- Testcase 109:
SELECT avg(c5), avg(c6+c9) FROM _sqlite_max_range;
-- Testcase 110:
SELECT count(c1), count(*), count(DISTINCT c4), count(ALL c5) FROM _sqlite_max_range;
-- Testcase 111:
SELECT stddev(c1), stddev(c2), stddev(c4+c7) FROM _sqlite_max_range;
-- Testcase 112:
SELECT array_agg(c5), array_agg(c6), array_agg(c11), array_agg(c8), array_agg(c9) FROM _sqlite_max_range;
-- Testcase 113:
SELECT bit_or(c2), bit_and(c3), bit_and(c5), bit_or(c6), bit_or(c7) FROM _sqlite_max_range;
-- Testcase 114:
SELECT bool_or(c3>0), bool_or(c9<=0), bool_and(c4<>0), bool_and(c11>=0) FROM _sqlite_max_range;
-- Testcase 115:
SELECT sqrt(abs(c10)), sqrt(abs(c4)), sqrt(abs(c6)), sqrt(abs(c7+c10)) FROM _sqlite_max_range ORDER BY 1, 2, 3, 4;