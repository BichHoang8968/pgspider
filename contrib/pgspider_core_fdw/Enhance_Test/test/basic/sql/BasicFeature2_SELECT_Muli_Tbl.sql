------------------------------BasicFeature2_SELECT_Muli_Tbl-----------------------------
SET timezone TO 0;
-- Testcase 1:
SELECT * FROM t1, griddb_max_range m ORDER BY t1.*, m.*, t1.__spd_url, m.__spd_url;
-- Testcase 2:
SELECT t1.c1, m.c1, m.c2, m.c3, m.c4, t1.c4/2, t1.c6*2, t1.c5  FROM t1, griddb_max_range m WHERE m.c3<1000 AND t1.c4%2=1 ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 3:
SELECT max(t1.c1), max(t1.c3+t1.c4), max(m.c1), max(t1.c3)*2-1000, max(t1.c9), min(t1.c8), min(t1.c4-t1.c3), min(m.c5), min(m.c8), min(m.c2)/5, min(m.c3/100) FROM t1, griddb_max_range m WHERE t1.c3 <> 1000 ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 4:
SELECT sum(t1.c3), sum(t1.c4)/5+100, sum(t1.c3+t1.c4), sum(m.c3/10000), sum(m.c2), sum(m.c3/10000 - t1.c3), avg(t1.c3), avg(t1.c3/50+100), avg(m.c3*0+1000.5)/2+100 FROM t1, griddb_max_range m WHERE m.c2 <> t1.c3 ORDER BY 1,2,3;
-- Testcase 5:
SELECT count(*), count(t1.c7+m.c2), count(m.c8), count(distinct t1.c3), count(distinct m.c5), count(m.c8)/2 +10 FROM t1, griddb_max_range m WHERE t1.c3 != 0 AND m.c2>0 OR m.c4=true;
-- Testcase 6:
SELECT stddev(t1.c3), stddev(t1.c3/5+t1.c4), stddev(abs(t1.c3)+t1.c4), stddev(m.c2), stddev(distinct m.c2), stddev(t1.c7)/5+100 FROM t1, griddb_max_range m;
-- Testcase 7:
SELECT array_agg(t1.c2 order by t1.c2), array_agg(m.c8 order by m.c8), array_agg(t1.c5 order by t1.c5), array_agg(not (m.c5>0) order by m.c5), array_agg(t1.c3 order by t1.c3) FROM t1, griddb_max_range m WHERE t1.c1=1 AND m.c2>0 AND m.c4=true;
-- Testcase 8:
SELECT bit_and(t1.c3)+10, bit_and(m.c2)/2, bit_or(t1.c3)/2, bit_or(t1.c3*5)+10, bool_and(t1.c5), bool_or(m.c4) FROM t1, griddb_max_range m WHERE t1.c3 != m.c2;
-- Testcase 9:
SELECT t1.c9, t1.c2, m.c4, m.c7 FROM t1, griddb_max_range m WHERE t1.c2='0123456789' AND m.c5=-9223372036854775808 AND m.c2<>127 AND t1.c3!=0 AND t1.c4<100 AND t1.c3>-10000000 ORDER BY 1,2,3,4;
-- Testcase 10:
SELECT t1.c4, t1.c17, m.c4, m.c8, t1.c3/2+10 FROM t1, griddb_max_range m WHERE t1.c3 >= 0 AND m.c1 <= -1 ORDER BY 1,2,3,4,5 LIMIT 30 OFFSET 2;
-- Testcase 11:
SELECT (m.c2/1000.2)/(t1.c3), 500/(m.c3) FROM t1, griddb_max_range m;
-- Testcase 12:
SELECT count(t1.*), sum(m.c3), avg(t1.c8 ORDER BY t1.c8) FROM t1, griddb_max_range m WHERE true ORDER BY 1,2;
-- Testcase 13:
SELECT t1.*, m.* FROM t1, griddb_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 14:
SELECT t1.c3, m.c8, t1.c3 < m.c1, m.c5, m.c2 FROM t1, griddb_max_range m WHERE m.c2 IN (-9223372036854775808, 0, -128) AND t1.c3 IN (0,1,2,3,4,30) ORDER BY 1,2,3,4,5;
-- Testcase 15:
SELECT t1.c2, t1.c11, m.c2, m.c5 FROM t1, griddb_max_range m WHERE t1.c2 LIKE '%345%' OR t1.c2 LIKE '%Canada%' order by 1,2,3,4 LIMIT 40 OFFSET 0;
-- Testcase 16:
SELECT DISTINCT t1.c14, t1.c2, m.c5, m.c4 FROM t1, griddb_max_range m WHERE t1.c3 IN (SELECT c2 FROM griddb_max_range WHERE c1!=1000) ORDER BY 1,2,3,4 LIMIT 50;
-- Testcase 17:
SELECT count(*), sum(t1.c1), avg(m.c1) FROM t1, griddb_max_range m WHERE m.c2 > (SELECT avg(c4)/100 FROM t1 WHERE c3 > 0) ORDER BY 1 OFFSET 0 LIMIT 60;
-- Testcase 18:
SELECT max(t1.c4), max(m.c2), count(*) FROM t1, griddb_max_range m WHERE t1.c3 BETWEEN 0 AND 1000 OR t1.c4 BETWEEN -50 AND 50;
-- Testcase 19:
SELECT DISTINCT t1.c9, t1.c3, t1.c2, m.c2, m.c4, abs(t1.c4) FROM t1, griddb_max_range m WHERE t1.c9 = '2010-01-13 01:00:00' OR t1.c3 = -2 AND t1.c3 != m.c2 ORDER BY 1,2,3,4,5,6 LIMIT 30 OFFSET 0;
-- Testcase 20:
SELECT t1.*, m.* FROM t1, griddb_max_range m WHERE -1000 < ALL(SELECT c3 FROM t1 WHERE c4 < 0 AND c4 > -100) AND m.c5 = ANY(ARRAY[0,9223372036854775806,9223372036854775806]) AND EXISTS (SELECT * FROM t1 WHERE t1.c4 > t1.c3) AND t1.c1 BETWEEN -5 AND 5 ORDER BY t1.*, m.* LIMIT 60 OFFSET 1;
-- Testcase 21:
SELECT * FROM t1, griddb_max_range m WHERE m.c2 ISNULL AND t1.c3 IS NOT NULL;
-- Testcase 22:
SELECT t1.c11, max(t1.c8)-100+count(*), count(t1.c8) filter(where t1.c8 > 1000), avg(m.c2), sum(m.c2), min(t1.c1-m.c2) FROM  t1, griddb_max_range m GROUP BY t1.c11 ORDER BY 1,2,3,4,5,6;
-- Testcase 23:
SELECT avg(t1.c3*4), max(m.c2), count(m.c5), avg(t1.c3)+sum(m.c3), avg(t1.c4), sum(t1.c4+100), min(m.c6) FROM t1, griddb_max_range m GROUP BY t1.c3 HAVING t1.c3>-50 AND t1.c3%2=0 ORDER BY 1,2,3,4,5,6,7;
-- Testcase 24:
SELECT max(distinct t1.c4), min(t1.c3+t1.c4), sum(distinct t1.c4), sum(t1.c3), count(m.c4) FROM t1, griddb_max_range m GROUP BY t1.c2, m.c2 ORDER BY 1,2,3,4,5 LIMIT 100 OFFSET 0;
-- Testcase 25:
SELECT count(*)+100, max(t1.c3+t1.c4), sum(t1.c3), avg(m.c2), stddev(t1.c3) + min(m.c2) + sum(m.c1) FROM t1, griddb_max_range m GROUP BY t1.c3, m.c2 HAVING m.c2>0 AND t1.c3<0 AND t1.c3 IN (-1,-2,-3,-4) ORDER BY 1,2,3,4,5;
-- Testcase 26:
SELECT DISTINCT t1.c2, m.c7, t1.c5, m.c2, t1.c3, t1.c18, m.c4 FROM t1, griddb_max_range m WHERE t1.c6 != m.c3 AND m.c2 > 0 ORDER BY 1, 2 DESC, t1.c5 DESC, m.c2 ASC, t1.c3 DESC, t1.c18 ASC, m.c4 ASC;
-- Testcase 27:
SELECT t1.c4, t1.c3 > m.c2, m.c5 FROM t1, griddb_max_range m ORDER BY 1,2,3 LIMIT 10;
-- Testcase 28:
SELECT DISTINCT t1.c5, t1.c4 < m.c2, m.c5, t1.c2 FROM t1, griddb_max_range m WHERE t1.c2 NOT LIKE '%M%' ORDER BY 4,3,2,1 OFFSET 20;
-- Testcase 29:
SELECT array_agg(m.c2 ORDER BY m.c2), array_agg(t1.c3 ORDER BY t1.c3 DESC), string_agg(t1.c2, '|' order by t1.c2) FROM t1, griddb_max_range m WHERE t1.c3%2>0 AND m.c4 = true AND t1.c2 LIKE '%a%';
-- Testcase 30:
SELECT count(distinct t1.c3/2), array_agg(distinct m.c2 order by m.c2), sum(distinct t1.c3)/2+100, array_agg(distinct m.c4) FROM t1, griddb_max_range m;
-- Testcase 31:
SELECT t1.*, m.c1, m.c2, m.c5 FROM t1, (SELECT * FROM griddb_max_range WHERE c2>1 OR c4 = true) m WHERE t1.c3 IN (-4,-5,-6,-7) AND m.c2 > 0 ORDER BY t1.*, m.*;
-- Testcase 32:
SELECT t1.c3, count(t1.c2), max(t1.c3-t1.c4), sum(t1.c3+100)/2-555, avg(m.c2/2), stddev(t1.c3)+10 FROM t1, griddb_max_range m WHERE t1.c3%2=0 OR t1.c2 LIKE '%a%' GROUP BY t1.c3, m.c2 HAVING sum(t1.c3)<100 AND t1.c3 IN (-1,-2,-3,-4) ORDER BY 1,2,3,4,5,6 LIMIT 20 OFFSET 2;
-- Testcase 33:
SELECT array_agg(t1.c1 order by t1.c1), avg(t1.c1), bit_and(t1.c1), bit_or(t1.c1), bool_and(t1.c5), bool_or(t1.c5), count(*), count(t1.c19), every(t1.c1>0), json_agg(t1.c1 order by t1.c1), jsonb_agg(t1.c1 order by t1.c1), json_object_agg(t1.c1,t1.c2 order by t1.c1,t1.c2), jsonb_object_agg(t1.c1,t1.c2 order by t1.c1,t1.c2), max(t1.c1), min(t1.c1), string_agg(t1.c2,';' order by t1.c2), sum(t1.c1), corr(t1.c8,t1.c7), covar_pop(t1.c7,t1.c8), covar_samp(t1.c7,t1.c8), regr_avgx(t1.c8,t1.c8), regr_avgy(t1.c7,t1.c7), regr_count(t1.c7,t1.c8), regr_intercept(t1.c7,t1.c8), regr_r2(t1.c7,t1.c8), regr_slope(t1.c8,t1.c8), regr_sxx(t1.c7,t1.c8), regr_sxy(t1.c8,t1.c7), regr_syy(t1.c7,t1.c8), stddev(t1.c7), stddev_pop(t1.c8), stddev_samp(t1.c7), variance(t1.c1), var_pop(t1.c1), var_samp(t1.c7) from t1, griddb_max_range t2 WHERE t1.c1=1 OR t1.c1=2 AND t2.c2=-128;
-- Testcase 34:
SELECT array_agg(t1.c1 order by t1.c1), avg(t1.c1)-100, bit_and(t1.c1)*2+50, bit_or(t1.c1)-100, bool_and(t1.c5)=(90<50), bool_or(t1.c5)=(64<80), count(*)*2+50*2, count(t1.c19)+100, every(t1.c1>0)=false, json_agg(t1.c1 order by t1.c1), jsonb_agg(t1.c1 order by t1.c1), json_object_agg(t1.c1,t1.c2 order by t1.c1,t1.c2), jsonb_object_agg(t1.c1,t1.c2 order by t1.c1,t1.c2), max(t1.c1)/2+50, min(t1.c1)+100/2, string_agg(t1.c2,';' order by t1.c2), sum(t1.c1)*5-100, corr(t1.c8,t1.c7 ORDER BY t1.c8,t1.c7)*3-90, covar_pop(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)*5, covar_samp(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)+100, regr_avgx(t1.c8,t1.c8 ORDER BY t1.c8,t1.c8)-10, regr_avgy(t1.c7,t1.c7 ORDER BY t1.c7,t1.c7)+10, regr_count(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)/10, regr_intercept(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)-100, regr_r2(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)+10, regr_slope(t1.c8,t1.c8 ORDER BY t1.c8,t1.c8)-100, regr_sxx(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)+10, regr_sxy(t1.c8,t1.c7 ORDER BY t1.c8,t1.c7)-99, regr_syy(t1.c7,t1.c8 ORDER BY t1.c7,t1.c8)+90, stddev(t1.c7 ORDER BY t1.c7)-80, stddev_pop(t1.c8 ORDER BY t1.c8)-100, stddev_samp(t1.c7 ORDER BY t1.c7)+78, variance(t1.c1)+70, var_pop(t1.c1)*15, var_samp(t1.c7 ORDER BY t1.c7)*2-10*5 from t1, griddb_max_range t2 WHERE t1.c1=1 OR t1.c1=2 AND t2.c2=-128;
-- Testcase 35:
SELECT * FROM t7, influx_max_range m ORDER BY t7.time, t7.c2, t7.c3, t7.c4, t7.c5, m.time, m.c2, m.c4, m.c3, t7.__spd_url, m.__spd_url;
-- Testcase 36:
SELECT t7.time, m.time, m.c4, m.c2, t7.c3/2, t7.c4*2, t7.c5  FROM t7, influx_max_range m WHERE m.c2<1000 AND t7.c3%2=1 ORDER BY 1,2,3,4,6,5;
-- Testcase 37:
SELECT max(t7.time), max(t7.c4+t7.c3), max(m.time), max(t7.c3)*2-1000, max(t7.time), min(t7.c3)/5, min(t7.c4-t7.c3), min(m.time), min(m.c2)/5, min(m.c2/100) FROM t7, influx_max_range m WHERE t7.c3 <> 1000 ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 38:
SELECT sum(t7.c3/2 order by t7.c3), sum(t7.c4 order by t7.c4)/5+100, sum(t7.c3+t7.c4/2  order by t7.c3, t7.c4/2), sum(m.c2/10000.5 order by m.c2/10000.5)+10, sum(m.c2/50000.5+t7.c3 order by m.c2/50000.5+t7.c3), avg(t7.c3 order by t7.c3), avg(t7.c3/50+100 order by t7.c3/50+100), avg(m.c2/1000.5 order by m.c2/1000.5)  FROM t7, influx_max_range m WHERE m.time <> t7.time ORDER BY 1,2,3;
-- Testcase 39:
SELECT count(*), count(t7.time), count(m.time), count(distinct t7.c3), count(distinct m.c4) FROM t7, influx_max_range m WHERE t7.c3 != 0 AND m.c2>0 OR m.c3>0;
-- Testcase 40:
SELECT stddev(t7.c3 ORDER BY t7.c3), stddev(t7.c3/5+t7.c4 ORDER BY t7.c3/5+t7.c4), stddev(abs(t7.c3)+t7.c4 ORDER BY abs(t7.c3)+t7.c4), stddev(m.c2), stddev(distinct m.c2) FROM t7, influx_max_range m ORDER By 1,2,3,4,5;
-- Testcase 41:
SELECT array_agg(t7.time order by t7.time), array_agg(m.time order by m.time), array_agg(t7.c5 order by t7.c5), array_agg(not m.c4 order by m.c4), array_agg(t7.c3+t7.c4 order by t7.c3+t7.c4) FROM t7, influx_max_range m WHERE t7.time != '2020-01-11 20:00:00-05' AND m.c2>0 AND T7.c3%2=0;
-- Testcase 42:
SELECT bit_and(t7.c3)+10, bit_and(m.c2)/2, bit_or(t7.c3)/2, bit_or(t7.c3*5)+10, bool_and(t7.c5), bool_or(m.c4) FROM t7, influx_max_range m WHERE t7.time < m.time;
-- Testcase 43:
SELECT t7.time, t7.c2, m.c4, m.time FROM t7, influx_max_range m WHERE t7.c2 = '0123456789' AND m.c2 = -9223372036854775808 AND m.c2 <> 127 AND t7.c3 != 0 AND t7.c4 < 100 AND t7.c3 > -10000000 ORDER BY 1,2,3,4;
-- Testcase 44:
SELECT t7.c4 - 50, t7.time, m.c4, m.time, t7.c3*t7.c4 FROM t7, influx_max_range m WHERE t7.c3 >= 0 AND m.c3 <= -1 ORDER BY 1,2,3,4,5 LIMIT 30 OFFSET 0;
-- Testcase 45:
SELECT (m.c2/1000.2)/(t7.c3), 500/(t7.c3) FROM t7, influx_max_range m;
-- Testcase 46:
SELECT t7.*, m.c4 FROM t7, influx_max_range m WHERE true ORDER BY 1,2,3,4,5,6,7 LIMIT 50;
-- Testcase 47:
SELECT t7.*, m.* FROM t7, influx_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 48:
SELECT t7.c3, m.time, t7.time < m.time, m.c4, m.c2 FROM t7, influx_max_range m WHERE m.c2 IN (-9223372036854775808, 0, -128) AND t7.c3 IN (0,1,2,3,4,30) ORDER BY 1,2,3,4,5;
-- Testcase 49:
SELECT t7.time, t7.c3, m.c2, m.c4 FROM t7, influx_max_range m WHERE t7.c2 LIKE '%べ員葉コ%' OR t7.c2 LIKE '%t%' order by 1,2,3,4 LIMIT 30 OFFSET 5;
-- Testcase 50:
SELECT t7.time, t7.c2, m.c2, m.c4 FROM t7, influx_max_range m WHERE t7.c5 IN (SELECT c2>0 FROM influx_max_range WHERE true) ORDER BY 1,2,3,4 OFFSET 1 LIMIT 20;
-- Testcase 51:
SELECT t7.*, m.c2, m.c4 FROM t7, influx_max_range m WHERE m.c2 > (SELECT avg(c4)/2000 FROM t7 WHERE c3 > 0) ORDER BY 1,2,3,4,5,6,__spd_url,7,8 OFFSET 1 LIMIT 30;
-- Testcase 52:
SELECT max(t7.c4), max(m.c2) FROM t7, influx_max_range m WHERE t7.c3 BETWEEN 0 AND 1000 OR t7.c4 BETWEEN -50 AND 50;
-- Testcase 53:
SELECT DISTINCT t7.c3, t7.c2, m.c2, m.c4, abs(t7.c4) FROM t7, influx_max_range m WHERE t7.c2 = '$' OR t7.c3 = -2 AND t7.c3 < m.c2 OR m.c3 <> -3000 ORDER BY 1,2,3,4,5 LIMIT 50 OFFSET 10;
-- Testcase 54:
SELECT t7.*, m.* FROM t7, influx_max_range m WHERE -1000 < ALL(SELECT c3 FROM t7 WHERE c4 < 0 AND c4 > -100) AND m.c2 = ANY(ARRAY[0,9223372036854775806,9223372036854775806]) AND EXISTS (SELECT * FROM t7 WHERE t7.c4 > t7.c3) ORDER BY 1,2,3,4,5,6,7,8,9,10,11 LIMIT 40 OFFSET 0;
-- Testcase 55:
SELECT * FROM t7, influx_max_range m WHERE m.c2 ISNULL AND t7.c3 IS NOT NULL;
-- Testcase 56:
SELECT t7.time, max(t7.c2), count(m.time), avg(m.c2), sum(m.c2), min(t7.time-m.time) FROM  t7, influx_max_range m GROUP BY t7.time ORDER BY 1,2,3,4,5,6;
-- Testcase 57:
SELECT avg(t7.c3*4 order by t7.c3), max(m.c2), count(m.c4), avg(t7.c4 order by t7.c4), sum(t7.c4+100 order by t7.c4), min(m.time) FROM t7, influx_max_range m GROUP BY t7.c3 HAVING t7.c3>-50 AND t7.c3%2=0 ORDER BY 1,2,3,4,6,5;
-- Testcase 58:
SELECT max(distinct t7.c4), min(t7.c3+t7.c4), sum(distinct t7.c4), sum(t7.c3), count(m.c4) FROM t7, influx_max_range m GROUP BY t7.c2, m.c2 ORDER BY 1,2,3,4,5 LIMIT 40 OFFSET 10;
-- Testcase 59:
SELECT count(*), max(t7.c3+t7.c4), sum(t7.c3), avg(m.c2), stddev(t7.c3) FROM t7, influx_max_range m GROUP BY t7.c3, m.c2 HAVING m.c2>0 AND t7.c3<0 AND t7.c3 IN (-1,-2,-3,-4) ORDER BY 1,2,3,4,5;
-- Testcase 60:
SELECT DISTINCT t7.c2, m.time, t7.c5, m.c2, t7.c3, t7.time, m.c4 FROM t7, influx_max_range m WHERE t7.time != m.time AND m.c2 > 0 ORDER BY 1, 2 DESC, t7.c5 ASC, m.c2 DESC, t7.c3 ASC, t7.time, m.c4;
-- Testcase 61:
SELECT t7.c4, t7.c3 > m.c2, m.c4 FROM t7, influx_max_range m ORDER BY 1,2,3 LIMIT 30;
-- Testcase 62:
SELECT DISTINCT t7.c5, t7.c4 < m.c2, m.c4, t7.c2 FROM t7, influx_max_range m WHERE t7.c2 NOT LIKE '%M%' ORDER BY 1,2,3,4 OFFSET 20;
-- Testcase 63:
SELECT array_agg(m.c2 ORDER BY m.c2), array_agg(t7.c3 ORDER BY t7.c3 DESC) FROM t7, influx_max_range m WHERE t7.c3%2>0 AND m.c4 = true AND t7.c2 NOT LIKE '%t%';
-- Testcase 64:
SELECT count(distinct t7.c3/2), array_agg(distinct m.c2 order by m.c2) FROM t7, influx_max_range m;
-- Testcase 65:
SELECT t7.*, m.time, m.c2, m.c4 FROM t7, (SELECT * FROM influx_max_range WHERE c2>1 OR c3 != -127.5) m WHERE t7.c3 < 0 AND m.c2 > 0 ORDER BY 1,2,3,4,5,__spd_url,7,8,9;
-- Testcase 66:
SELECT t7.c3, count(t7.c2), max(t7.c3-t7.c4), sum(t7.c3+100)/2-555, avg(m.c2/2), stddev(t7.c3)+10 FROM t7, influx_max_range m WHERE t7.c3%2=0 OR t7.c2 LIKE '%a%' GROUP BY t7.c3, m.c2 HAVING sum(t7.c3)<100 AND t7.c3 IN (-1,-2,-3,-4) ORDER BY 1,2,3,4,5,6 LIMIT 20 OFFSET 1;
-- Testcase 67:
SELECT avg(t7.c3), count(*), count(t7.c2), max(t7.c3), min(t7.c3), sum(t7.c3), stddev(t7.c4 ORDER BY t7.c4), variance(t7.c4 ORDER BY t7.c4) from t7, influx_max_range WHERE t7.c3=1 OR t7.c3=0;
-- Testcase 68:
SELECT array_agg(t7.c3 order by t7.c3), bit_and(t7.c3), bit_or(t7.c3), bool_and(t7.c5), bool_or(t7.c5), every(t7.c3>0), json_agg(t7.c3 order by t7.c3), jsonb_agg(t7.c3 order by t7.c3), json_object_agg(t7.c3,t7.c4 order by t7.c3,t7.c4), jsonb_object_agg(t7.c3,t7.c4 order by t7.c3,t7.c4), string_agg(t7.c2,';' order by t7.c2), corr(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), covar_pop(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), covar_samp(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_avgx(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_avgy(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_count(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_intercept(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_r2(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_slope(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_sxx(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_sxy(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), regr_syy(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4), stddev_pop(t7.c4 ORDER BY t7.c4), stddev_samp(t7.c4 ORDER BY t7.c4), var_pop(t7.c4 ORDER BY t7.c4), var_samp(t7.c4 ORDER BY t7.c4) from t7, influx_max_range WHERE t7.c3=1 OR t7.c3=2;
-- Testcase 69:
SELECT avg(t7.c3)*2, count(*)-100, count(t7.c2)*3, max(t7.c3)+100, min(t7.c3)-9, sum(t7.c3)+30, stddev(t7.c4 ORDER BY t7.c4)*5, variance(t7.c4 ORDER BY t7.c4)-100 from t7, influx_max_range WHERE t7.c3=1 OR t7.c3=0;
-- Testcase 70:
SELECT array_agg(t7.c3 order by t7.c3), bit_and(t7.c3)*2, bit_or(t7.c3+100)+100, bool_and(t7.c5)=false, bool_or(t7.c5)=true, every(t7.c3>0)=true, json_agg(t7.c3 order by t7.c3), jsonb_agg(t7.c3 order by t7.c3), json_object_agg(t7.c3,t7.c4 order by t7.c3,t7.c4), jsonb_object_agg(t7.c3,t7.c4 order by t7.c3,t7.c4), string_agg(t7.c2,';' order by t7.c2), corr(t7.c4,t7.c4+10 ORDER BY t7.c4,t7.c4+10)-100, covar_pop(t7.c4+30,t7.c4 ORDER BY t7.c4+30,t7.c4)*2, covar_samp(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)-10, regr_avgx(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)+60, regr_avgy(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)/2, regr_count(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)-100, regr_intercept(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)+100, regr_r2(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)*2+10, regr_slope(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)+100, regr_sxx(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)-100, regr_sxy(t7.c4,t7.c4 ORDER BY t7.c4,t7.c4)-200, regr_syy(t7.c4,t7.c4*2 ORDER BY t7.c4,t7.c4*2)*2, stddev_pop(t7.c4+100 ORDER BY t7.c4+100)*2, stddev_samp(t7.c4+90 ORDER BY t7.c4+90), var_pop(t7.c4-10 ORDER BY t7.c4-10)+10, var_samp(t7.c4 ORDER BY t7.c4)+100 from t7, influx_max_range WHERE t7.c3=1 OR t7.c3=2;
-- Testcase 71:
SELECT * FROM t5, tinybrace_max_range m ORDER BY 10,9,8,7,6,5,4,3,2,1,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37 LIMIT 100;
-- Testcase 72:
SELECT (t5.c1 - t5.c2), m.c1, (m.c3+t5.c3), t5.c21, t5.c12, m.c9, m.c8, m.c13, m.c4/2  FROM t5, tinybrace_max_range m WHERE m.c3 < 1000  ORDER BY 1,2,3,4,5,6,7,8,9;
-- Testcase 73:
SELECT max(t5.c1), max(t5.c7+t5.c4), max(m.c1)/2, max(m.c8)-100, max(t5.c1/2), min(t5.c5+t5.c4*2), min(t5.c17-1000), min(t5.c8), min(m.c1/2), min(m.c4), min(m.c9)/5, min(m.c12) FROM t5, tinybrace_max_range m WHERE t5.c3 <> 1000 ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 74:
SELECT sum(t5.c1+m.c2), sum(t5.c7)+10, sum(t5.c5+t5.c6/2), sum(m.c1/100)+10, sum(m.c2+t5.c3), sum(m.c4/10000 - t5.c6), avg(t5.c5+t5.c6), avg(t5.c20/50 +100 ORDER BY t5.c20/50 +100), avg(m.c7)+100, avg(m.c1/1000+t5.c6)  FROM t5, tinybrace_max_range m WHERE m.c3 <> t5.c1 ORDER BY 1,2,3;
-- Testcase 75:
SELECT count(*)/2+10, count(t5.c1)*5-20, count(m.c1), count(distinct t5.c3), count(distinct m.c5) FROM t5, tinybrace_max_range m WHERE t5.c1%2 != 0 AND m.c2>0;
-- Testcase 76:
SELECT stddev(t5.c1), stddev(t5.c2+t5.c1), stddev(t5.c3), stddev(m.c4), stddev(distinct m.c2) FROM t5, tinybrace_max_range m;
-- Testcase 77:
SELECT array_agg(distinct t5.c1 order by t5.c1), array_agg(m.c1 order by m.c1), array_agg(t5.c1+m.c1/5+1 order by t5.c1, m.c1), array_agg(distinct m.c5 order by m.c5), array_agg(t5.c2+t5.c3 order by t5.c2, t5.c3) FROM t5, tinybrace_max_range m WHERE t5.c1 < -100 AND m.c2>0;
-- Testcase 78:
SELECT bit_and(t5.c1)+10, bit_and(m.c2/20)/2, bit_or(m.c1)/2, bit_or(t5.c1+t5.c2)+10, bool_and(t5.c2>100), bool_or(m.c2<100) FROM t5, tinybrace_max_range m WHERE t5.c1 < m.c1;
-- Testcase 79:
SELECT t5.c1, t5.c2, m.c3, m.c13 FROM t5, tinybrace_max_range m WHERE t5.c1 =  3000 AND m.c2 = -128 AND m.c2 <> 127 AND t5.c2 != 0 AND t5.c3 > -100 AND m.c3 < 1000 ORDER BY 1,2,3,4;
-- Testcase 80:
SELECT t5.c5 - 50, t5.c10, m.c4, m.c12, t5.c2*m.c2 FROM t5, tinybrace_max_range m WHERE t5.c1 >= 0 AND m.c1 <= -1 ORDER BY 1,2,3,4,5;
-- Testcase 81:
SELECT t5.c1/(m.c2+127), m.c1/t5.c3 FROM t5, tinybrace_max_range m;
-- Testcase 82:
SELECT t5.c9, m.c11, m.c5 FROM t5, tinybrace_max_range m WHERE true ORDER BY 1,2,3 LIMIT 40;
-- Testcase 83:
SELECT t5.*, m.c11, m.c12 FROM t5, tinybrace_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 84:
SELECT t5.c3, m.c1, t5.c1+m.c2, m.c5, m.c2 FROM t5, tinybrace_max_range m WHERE m.c2 IN (-127, 0, -128) AND t5.c2 IN (0, 30) ORDER BY 1,2,3,4,5;
-- Testcase 85:
SELECT t5.c2, t5.c3 FROM t5, tinybrace_max_range m WHERE t5.c8 LIKE '%B%' AND m.c2 <> 127 order by 1,2;
-- Testcase 86:
SELECT t5.c10, m.c3, m.c4 FROM t5, tinybrace_max_range m WHERE t5.c2 IN (SELECT c2 FROM tinybrace_max_range WHERE c2 < 0) ORDER BY 1,2,3 OFFSET 1 LIMIT 20;
-- Testcase 87:
SELECT t5.c10, m.c3, m.c4 FROM t5, tinybrace_max_range m WHERE t5.c1 < (SELECT avg(c4) FROM tinybrace_max_range WHERE c2 > 0) ORDER BY 3,2,1 OFFSET 1 LIMIT 30;
-- Testcase 88:
SELECT max(t5.c1), max(m.c2) FROM t5, tinybrace_max_range m WHERE t5.c2 BETWEEN 0 AND 1000 AND m.c2 BETWEEN -1000 AND 0;
-- Testcase 89:
SELECT DISTINCT t5.c20, t5.c21, t5.c22, m.c1, m.c2*2+t5.c1, abs(m.c1) FROM t5, tinybrace_max_range m WHERE t5.c2 = 4 OR t5.c1 = 0 AND m.c1 = 127 OR m.c3 < -3000 ORDER BY 1,2,3,4,5,6 LIMIT 30 OFFSET 10; 
-- Testcase 90:
SELECT t5.c16, t5.c17, t5.c18, m.c1, m.c4, m.c5 FROM t5, tinybrace_max_range m WHERE -1000 < ALL(SELECT c2 FROM tinybrace_max_range) AND t5.c2 = ANY(ARRAY[0,127,3]) AND EXISTS ( SELECT * FROM t5 WHERE t5.c1 > m.c2) ORDER BY 1,2,3,4,5,6;
-- Testcase 91:
SELECT * FROM t5, tinybrace_max_range m WHERE m.c9 ISNULL AND t5.c22 IS NOT NULL ORDER BY m.*, t5.* LIMIT 100;
-- Testcase 92:
SELECT t5.c1, max(t5.c2), count(m.c1), avg(m.c1), sum(m.c2), min(t5.c1-m.c1) FROM  t5, tinybrace_max_range m GROUP BY t5.c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 93:
SELECT avg(t5.c1), max(t5.c3), count(m.c1), avg(m.c1), sum(m.c2), min(t5.c1-m.c1) FROM  t5, tinybrace_max_range m GROUP BY t5.c1 HAVING t5.c1>-50 AND t5.c1%2=0 ORDER BY 1,2,3,4,5,6;
-- Testcase 94:
SELECT max(t5.c5), min(t5.c14), sum( distinct t5.c6), sum(m.c1), count(m.c4) FROM t5, tinybrace_max_range m GROUP BY t5.c1, m.c2 ORDER BY 1,2,3,4,5;
-- Testcase 95:
SELECT count(*), max(m.c1+t5.c2), sum(t5.c1+m.c1), avg(m.c2), stddev(m.c3) FROM t5, tinybrace_max_range m GROUP BY t5.c2, m.c1 HAVING t5.c2*100 > m.c1 AND t5.c2 IN (1,127,0) AND m.c1<0 ORDER BY 1,2,3,4,5;
-- Testcase 96:
SELECT DISTINCT t5.c7, m.c1, t5.c8, m.c9, t5.c9, t5.c10, m.c3 FROM t5, tinybrace_max_range m WHERE t5.c1 != m.c1 AND m.c2 > 0 ORDER BY t5.c10 DESC, m.c3, t5.c7 DESC, m.c1, m.c9, t5.c9 DESC, t5.c8;
-- Testcase 97:
SELECT t5.c1, t5.c1 > m.c1 ,m.c5 FROM t5, tinybrace_max_range m ORDER BY 1,2,3 LIMIT 20;
-- Testcase 98:
SELECT DISTINCT t5.c6, t5.c2 < m.c2, m.c4 FROM t5, tinybrace_max_range m WHERE t5.c9 NOT LIKE '%M%' ORDER BY 1,2,3 OFFSET 10;
-- Testcase 99:
SELECT array_agg(m.c1 ORDER BY m.c1), array_agg(t5.c1 ORDER BY t5.c1 DESC) FROM t5, tinybrace_max_range m WHERE t5.c1%2=0 AND m.c8>0 AND t5.c9 NOT LIKE '%t%';
-- Testcase 100:
SELECT count(distinct t5.c1/2), array_agg(distinct m.c2 order by m.c2) FROM t5, tinybrace_max_range m;
-- Testcase 101:
SELECT t5.c3, t5.c4, t5.c5, m.c1*10+1, m.c2 FROM t5, (SELECT * FROM tinybrace_max_range WHERE c4%2=1 OR c2=-127) m WHERE t5.c3 < 0 AND m.c1 > 0 ORDER BY 1,2,3,4,5;
-- Testcase 102:
SELECT t5.c2, m.c1, count(*), max(m.c1+t5.c2), sum(t5.c1+m.c1), avg(m.c2), stddev(m.c3) FROM t5, tinybrace_max_range m WHERE t5.c5 < t5.c6 OR t5.c2 > 10 GROUP BY t5.c2, m.c1 HAVING t5.c2*100 > m.c1 AND t5.c2 IN (1,127,0, 30, 50, 90, -127, -60) AND m.c1<0 ORDER BY 1,2,3,4,5,6,7 LIMIT 30 OFFSET 5;
-- Testcase 103:
SELECT avg(t5.c3), count(*), count(t5.c2), max(t5.c3), min(t5.c3), sum(t5.c3), stddev(t5.c4), variance(t5.c4) from t5, tinybrace_max_range WHERE t5.c3>0;
-- Testcase 104:
SELECT array_agg(c3 order by c3), bit_and(c3), bit_or(c3), bool_and(c5>0), bool_or(c5<10), every(c3>0), json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c8,';' order by c8), corr(c4,c4), covar_pop(c4,c4), covar_samp(c4,c4), regr_avgx(c4,c4), regr_avgy(c4,c4), regr_count(c4,c4), regr_intercept(c4,c4), regr_r2(c4,c4), regr_slope(c4,c4), regr_sxx(c4,c4), regr_sxy(c4,c4), regr_syy(c4,c4), stddev_pop(c4), stddev_samp(c4), var_pop(c4), var_samp(c4) from t5 WHERE c5=1 OR c5=0;
-- Testcase 105:
SELECT array_agg(t5.c3 order by t5.c3), bit_and(t5.c3), bit_or(t5.c3), bool_and(t5.c5>0), bool_or(t5.c5<10), every(t5.c3>0), json_agg(t5.c3 order by t5.c3), jsonb_agg(t5.c3 order by t5.c3), json_object_agg(t5.c3,t5.c4 order by t5.c3,t5.c4), jsonb_object_agg(t5.c3,t5.c4 order by t5.c3,t5.c4), string_agg(t5.c8,';' order by t5.c8), corr(t5.c4,t5.c4), covar_pop(t5.c4,t5.c4), covar_samp(t5.c4,t5.c4), regr_avgx(t5.c4,t5.c4), regr_avgy(t5.c4,t5.c4), regr_count(t5.c4,t5.c4), regr_intercept(t5.c4,t5.c4), regr_r2(t5.c4,t5.c4), regr_slope(t5.c4,t5.c4), regr_sxx(t5.c4,t5.c4), regr_sxy(t5.c4,t5.c4), regr_syy(t5.c4,t5.c4), stddev_pop(t5.c4), stddev_samp(t5.c4), var_pop(t5.c4), var_samp(t5.c4) from t5, tinybrace_max_range m WHERE t5.c5=1 OR t5.c5=0 AND m.c2=127;
-- Testcase 106:
SELECT avg(t5.c3)-100, count(*)*2, count(t5.c2)*2+9, max(t5.c3-100)+7, min(t5.c3-100)-89, sum(t5.c3*2)+10, stddev(t5.c4)-188, variance(t5.c4)/2-10 from t5, tinybrace_max_range WHERE t5.c3>0;
-- Testcase 107:
SELECT array_agg(t5.c3 order by t5.c3), bit_and(t5.c3)-10, bit_or(t5.c3)+10, bool_and(t5.c5>0)=true, bool_or(t5.c5<10)=false, every(t5.c3>0)=false, json_agg(t5.c3 order by t5.c3), jsonb_agg(t5.c3 order by t5.c3), json_object_agg(t5.c3,t5.c4 order by t5.c3,t5.c4), jsonb_object_agg(t5.c3,t5.c4 order by t5.c3,t5.c4), string_agg(t5.c8,';' order by t5.c8), corr(t5.c4,t5.c4)*2+10, covar_pop(t5.c4,t5.c4-10)+10, covar_samp(t5.c4,t5.c4*2)-10, regr_avgx(t5.c4,t5.c4)+100, regr_avgy(t5.c4,t5.c4)/2, regr_count(t5.c4,t5.c4)+92, regr_intercept(t5.c4,t5.c4)-82, regr_r2(t5.c4,t5.c4)+82, regr_slope(t5.c4,t5.c4)*2, regr_sxx(t5.c4,t5.c4)/4+89, regr_sxy(t5.c4,t5.c4-100.5)+10, regr_syy(t5.c4,t5.c4)+12, stddev_pop(t5.c4)*32+83, stddev_samp(t5.c4)-90, var_pop(t5.c4)+21*2, var_samp(t5.c4)*2+19 from t5, tinybrace_max_range m WHERE t5.c5=1 OR t5.c5=0 AND m.c2=127;
-- Testcase 108:
SELECT * FROM t3, mysql_max_range m ORDER BY m.*, t3.*;
-- Testcase 109:
SELECT (t3.c1+t3.c2), m.c1, (m.c3+t3.c3), t3.c24, t3.c12, m.c12, m.c8, m.c10  FROM t3, mysql_max_range m WHERE m.c3<1000 ORDER BY 4,5,6,7,8,1,2,3;
-- Testcase 110:
SELECT max(t3.c1), max(t3.c7+t3.c4), max(m.c1), max(m.c8), max(t3.c1/2), min(t3.c5+t3.c4*2), min(t3.c12-1000), min(t3.c8), min(m.c1/2), min(m.c4), min(m.c9), min(m.c2) FROM t3, mysql_max_range m WHERE t3.c3 <> 1000 ORDER BY 1,2,3;
-- Testcase 111:
SELECT sum(t3.c1+t3.c5 ORDER BY t3.c1+t3.c5), sum(t3.c10 ORDER BY t3.c10), sum(t3.c7+t3.c8 ORDER BY t3.c7+t3.c8), sum(m.c1/100 ORDER BY m.c1/100)+10, sum(m.c2+t3.c3 ORDER By m.c2+t3.c3), sum(m.c4/10000 - t3.c6 ORDER BY m.c4/10000 - t3.c6), avg(t3.c5+t3.c6 ORDER BY t3.c5+t3.c6), avg(t3.c10/50 +100 ORDER BY t3.c10/50 +100), avg(m.c7*0 ORDER BY m.c7*0)+100, avg(m.c1/1000+t3.c6 ORDER BY m.c1/1000+t3.c6)  FROM t3, mysql_max_range m WHERE m.c3 <> t3.c1 ORDER BY 1,2,3,4,5,6,7,8,9,10;
-- Testcase 112:
SELECT count(t3.c1), count(m.c1), count(distinct t3.c3), count(distinct m.c5) FROM t3, mysql_max_range m WHERE t3.c1%2 != 0 AND m.c2>0;
-- Testcase 113:
SELECT stddev(t3.c1), stddev(t3.c2+t3.c1), stddev(t3.c3), stddev(m.c4) FROM t3, mysql_max_range m;
-- Testcase 114:
SELECT array_agg(t3.c1 order by t3.c1), array_agg(m.c1 order by m.c1),array_agg(t3.c1+m.c1/5+1 order by t3.c1,m.c1),array_agg(m.c5 order by m.c5),array_agg(t3.c2+t3.c3 order by t3.c2,t3.c3) FROM t3, mysql_max_range m WHERE t3.c1<-100 AND m.c2>0;
-- Testcase 115:
SELECT bit_and(t3.c1), bit_and(m.c2/20), bit_or(m.c1), bit_or(t3.c1+t3.c2), bool_and(t3.c2>100), bool_or(m.c2<100) FROM t3, mysql_max_range m WHERE t3.c1<m.c1;
-- Testcase 116:
SELECT t3.c1, t3.c2, m.c3, m.c8 FROM t3, mysql_max_range m WHERE t3.c1=-3 AND m.c1=-128 AND m.c2 <> 127 AND t3.c2 != 0 AND t3.c3>-100 AND m.c3<1000 ORDER BY 1,2,3,4;
-- Testcase 117:
SELECT t3.c5, t3.c10, m.c4, m.c12 FROM t3, mysql_max_range m WHERE t3.c1 >= 0 AND m.c1 <= -1 ORDER BY 1,2,3,4;
-- Testcase 118:
SELECT t3.c1/(m.c1+127), m.c1/t3.c1 FROM t3, mysql_max_range m;
-- Testcase 119:
SELECT t3.c23, m.c11, m.c12 FROM t3, mysql_max_range m WHERE true ORDER BY 1,2,3 LIMIT 20;
-- Testcase 120:
SELECT t3.c23, m.c11, m.c12 FROM t3, mysql_max_range m WHERE false ORDER BY 1,2,3 LIMIT 20;
-- Testcase 121:
SELECT t3.c3, m.c1, m.c5, m.c2 FROM t3, mysql_max_range m WHERE t3.c3 IN (-50, 10, 0) AND m.c2 IN (32767, 32766) ORDER BY 1,2,3,4;
-- Testcase 122:
SELECT t3.c5, m.c3 FROM t3, mysql_max_range m WHERE t3.c17 LIKE '%いろ%' AND m.c1=127 ORDER BY 1,2;
-- Testcase 123:
SELECT t3.c10, m.c3, m.c4 FROM t3, mysql_max_range m WHERE t3.c1 IN (SELECT c1 FROM mysql_max_range WHERE c2<0) ORDER BY 1,2,3 OFFSET 1 LIMIT 50; 
-- Testcase 124:
SELECT t3.c10, m.c3, m.c4 FROM t3, mysql_max_range m WHERE t3.c1<(SELECT avg(c1) FROM mysql_max_range WHERE c2<0) ORDER BY 1,2,3; 
-- Testcase 125:
SELECT max(t3.c1), max(m.c2) FROM t3, mysql_max_range m WHERE t3.c2 BETWEEN 0 AND 1000 AND m.c1 BETWEEN -1000 AND 1000;
-- Testcase 126:
SELECT t3.c20, t3.c21, t3.c22, m.c1, m.c2*2+t3.c1, abs(m.c1) FROM t3, mysql_max_range m WHERE t3.c2=4 OR t3.c1=0 AND m.c1=127 OR m.c2<-100 ORDER BY 1,2,3,4,5,6; 
-- Testcase 127:
SELECT t3.c16, t3.c17, t3.c18, m.c1, m.c4, m.c5 FROM t3, mysql_max_range m WHERE -1000<ALL(SELECT c1 FROM mysql_max_range) AND t3.c1=ANY(ARRAY[1,2,3]) AND EXISTS ( SELECT * FROM t3 WHERE t3.c1>m.c2);
-- Testcase 128:
SELECT * FROM t3, mysql_max_range m WHERE m.c9 ISNULL AND t3.c22 IS NOT NULL ORDER BY m.*, t3.*;
-- Testcase 129:
SELECT t3.c1, max(t3.c2), count(m.c1), avg(m.c1), sum(m.c2), min(t3.c1-m.c1) FROM  t3, mysql_max_range m GROUP BY t3.c1 ORDER BY 1,2,3,4,6,5;
-- Testcase 130:
SELECT avg(t3.c1), max(t3.c3), count(m.c1), avg(m.c1), sum(m.c2), min(t3.c1-m.c1) FROM  t3, mysql_max_range m GROUP BY t3.c1 HAVING t3.c1>-50 AND t3.c1 <= 100 ORDER BY 1,2,3,4,6,5;
-- Testcase 131:
SELECT max(t3.c5), min(t3.c14), sum(t3.c8), sum(m.c1), count(m.c4) FROM t3, mysql_max_range m GROUP BY t3.c1, m.c2 ORDER BY 1,2,3,4,5;
-- Testcase 132:
SELECT count(*), max(m.c1+t3.c2), sum(t3.c1+m.c1), avg(m.c2), stddev(m.c3) FROM t3, mysql_max_range m GROUP BY t3.c2, m.c1 HAVING t3.c2>m.c1 AND t3.c2 >= -1000 AND m.c1 IN (127,-128,126) ORDER BY 1,2,3,4,5;
-- Testcase 133:
SELECT t3.c7, m.c1, t3.c8, m.c9, t3.c9, t3.c10, m.c3 FROM t3, mysql_max_range m WHERE t3.c1 != m.c1 AND m.c2>0 ORDER BY m.c3, 1 DESC, 2, m.c1 DESC, t3.c8 ASC, m.c9 DESC, t3.c9, t3.c10 ASC;
-- Testcase 134:
SELECT t3.c1, t3.c1>m.c1 ,m.c5 FROM t3, mysql_max_range m ORDER BY 1,2,3 LIMIT 20;
-- Testcase 135:
SELECT t3.c6, t3.c2<m.c2, m.c4 FROM t3, mysql_max_range m ORDER BY 1,2,3 OFFSET 60;
-- Testcase 136:
SELECT array_agg(m.c1 ORDER BY m.c1), array_agg(t3.c1 ORDER BY  t3.c1 DESC) FROM t3, mysql_max_range m WHERE t3.c1%2=0 AND m.c1>0;
-- Testcase 137:
SELECT count(distinct t3.c1/2), array_agg(distinct m.c2 order by m.c2) FROM t3, mysql_max_range m;
-- Testcase 138:
SELECT t3.c3, t3.c4, t3.c5, m.c1*10+1, m.c2 FROM t3, (SELECT * FROM mysql_max_range WHERE c1 <= 126) m WHERE t3.c3<0 AND m.c1>0 ORDER BY 1,2,3,4,5;
-- Testcase 139:
SELECT t3.c2, m.c1, count(distinct m.c3), max(m.c1-t3.c2), sum(t3.c1*10+m.c1+1), avg(m.c2)/5+10, stddev(m.c3) FROM t3, mysql_max_range m WHERE t3.c2 != m.c1 AND t3.c5%2=1 OR t3.c6>-1000 GROUP BY t3.c2, m.c1 HAVING t3.c2>m.c1 AND t3.c2 >= -1000 AND m.c1 IN (127,-128,126) ORDER BY 1,2,3,4,5,6,7 LIMIT 30 OFFSET 2;
-- Testcase 140:
SELECT array_agg(t3.c1 order by t3.c1), avg(t3.c1), bit_and(t3.c1), bit_or(t3.c1), bool_and(t3.c5>10), bool_or(t3.c5<-10), count(*), count(t3.c19), every(t3.c1>0), json_agg(t3.c1 order by t3.c1), jsonb_agg(t3.c1 order by t3.c1), json_object_agg(t3.c1,t3.c2 order by t3.c1,t3.c2), jsonb_object_agg(t3.c1,t3.c2 order by t3.c1,t3.c2), max(t3.c1), min(t3.c1), string_agg(t3.c18,';' order by t3.c18), sum(t3.c1), corr(t3.c8,t3.c7 ORDER BY t3.c8,t3.c7), covar_pop(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), covar_samp(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), regr_avgx(t3.c8,t3.c8 ORDER BY t3.c8), regr_avgy(t3.c7,t3.c7 ORDER BY t3.c7), regr_count(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), regr_intercept(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), regr_r2(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), regr_slope(t3.c8,t3.c8 ORDER BY t3.c8), regr_sxx(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), regr_sxy(t3.c8,t3.c7 ORDER BY t3.c8,t3.c7), regr_syy(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8), stddev(t3.c7 ORDER BY t3.c7), stddev_pop(t3.c8 ORDER BY t3.c8), stddev_samp(t3.c7 ORDER BY t3.c7), variance(t3.c1), var_pop(t3.c1), var_samp(t3.c7 ORDER BY t3.c7) from t3, mysql_max_range t2 WHERE t3.c1=1 OR t3.c1=2 AND t2.c2=-128;
-- Testcase 141:
SELECT array_agg(t3.c1 order by t3.c1), avg(t3.c1)+100, bit_and(t3.c1-10)*2+10, bit_or(t3.c1*2)-10, bool_and(t3.c5>10)=false, bool_or(t3.c5<-10)=true, count(*)-1000, count(t3.c19)*2-10, every(t3.c1>0)=false, json_agg(t3.c1 order by t3.c1), jsonb_agg(t3.c1 order by t3.c1), json_object_agg(t3.c1,t3.c2 order by t3.c1,t3.c2), jsonb_object_agg(t3.c1,t3.c2 order by t3.c1,t3.c2), max(t3.c1)*2-10, min(t3.c1+12)-10, string_agg(t3.c18,';' order by t3.c18), sum(t3.c1)-100, corr(t3.c8,t3.c7-9 ORDER BY t3.c8,t3.c7-9)+20, covar_pop(t3.c7,t3.c8/2 ORDER BY t3.c7,t3.c8/2)*2, covar_samp(t3.c7,t3.c8+100 ORDER BY t3.c7,t3.c8+100)-10, regr_avgx(t3.c8-10,t3.c8-100 ORDER BY t3.c8-10,t3.c8-100)*5-100, regr_avgy(t3.c7,t3.c7+100 ORDER BY t3.c7,t3.c7+100)*2, regr_count(t3.c7,t3.c8/2 ORDER BY t3.c7,t3.c8/2)+6, regr_intercept(t3.c7*3,t3.c8 ORDER BY t3.c7*3,t3.c8), regr_r2(t3.c7*2,t3.c8 ORDER BY t3.c7*2,t3.c8)+9, regr_slope(t3.c8,t3.c8+10 ORDER BY t3.c8,t3.c8+10)-10, regr_sxx(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8)-9, regr_sxy(t3.c8,t3.c7 ORDER BY t3.c8,t3.c7)*2, regr_syy(t3.c7,t3.c8 ORDER BY t3.c7,t3.c8)/2, stddev(t3.c7 ORDER BY t3.c7)+10, stddev_pop(t3.c8 ORDER BY t3.c8)-100, stddev_samp(t3.c7 ORDER BY t3.c7)/2, variance(t3.c1)-100, var_pop(t3.c1+2)-10, var_samp(t3.c7 ORDER BY t3.c7)*5 from t3, mysql_max_range t2 WHERE t3.c1=1 OR t3.c1=2 AND t2.c2=-128;
-- Testcase 142:
SELECT * FROM t9, post_max_range m ORDER BY m.*, 1,2,3,4,5,7,8,9,10,12,13,14,15,16,18,21,22,23,25,41,40,38,37,36,35,34,33,32,31,30,29 LIMIT 50;
-- Testcase 143:
SELECT (t9.c1 - t9.c2), m.c1, m.c2, t9.c21, t9.c12, m.c9, m.c8, m.c13, m.c4/2  FROM t9, post_max_range m WHERE m.c1 < 1000 AND t9.c2 < 50 ORDER BY 1,2,3,4,5,6,7,8,9;
-- Testcase 144:
SELECT max(t9.c1), max(t9.c2 + t9.c13), max(m.c1)/2, max(m.c8)-100, max(t9.c1/2), min(t9.c2+t9.c31*2), min(t9.c30-1000), min(t9.c8), min(m.c1/2), min(m.c4), min(m.c9)/5, min(m.c12) FROM t9, post_max_range m WHERE t9.c5 != true ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 145:
SELECT sum(t9.c1), sum(t9.c30) + 10, sum(t9.c29+t9.c28/2 ORDER BY t9.c29+t9.c28/2), sum(m.c1/100) + 10, sum(m.c8 + t9.c13), sum(m.c9/10000.5), avg(t9.c15+t9.c1), avg(t9.c28/50+100 ORDER BY t9.c28/50+100), avg(m.c7) + 100, avg(m.c7/1000 + t9.c1)  FROM t9, post_max_range m WHERE m.c1 <> t9.c1;
-- Testcase 146:
SELECT count(*), count(t9.c1), count(m.c1), count(distinct t9.c3), count(distinct m.c5) FROM t9, post_max_range m WHERE t9.c1%2 != 0 AND m.c2>0;
-- Testcase 147:
SELECT stddev(t9.c1*2)+100, stddev(t9.c2+t9.c1), stddev(t9.c15/t9.c1), stddev(m.c5), stddev(distinct m.c2) FROM t9, post_max_range m WHERE t9.c1 > 0;
-- Testcase 148:
SELECT array_agg(t9.c1 order by t9.c1), array_agg(m.c1 order by m.c1), array_agg(t9.c1 + t9.c2/5 + 1 order by t9.c1 + t9.c2/5 + 1), array_agg(m.c5 order by m.c5), array_agg(t9.c5 order by t9.c5) FROM t9, post_max_range m WHERE t9.c1 BETWEEN -1 AND 1 AND m.c2 < 2;
-- Testcase 149:
SELECT bit_and(t9.c1)+10, bit_and(m.c2/20)/2, bit_or(m.c1)/2, bit_or(t9.c1+t9.c2)+10, bool_and(t9.c2>100), bool_or(m.c2<100) FROM t9, post_max_range m WHERE t9.c1 < m.c1;
-- Testcase 150:
SELECT t9.c1, t9.c2, m.c3, m.c13 FROM t9, post_max_range m WHERE t9.c1 = -3 AND m.c2 = 2 AND m.c8 <> 1 AND t9.c2 != 0 AND t9.c28 > -100 AND m.c7 < 100000 ORDER BY 1,2,3,4;
-- Testcase 151:
SELECT t9.c6, t9.c7, m.c4, m.c12, t9.c2*m.c8 FROM t9, post_max_range m WHERE t9.c1 >= 0 AND m.c2 <= 100 ORDER BY 2,3,4,5 LIMIT 30;
-- Testcase 152:
SELECT t9.c1/(m.c8-1), m.c9/t9.c1 FROM t9, post_max_range m;
-- Testcase 153:
SELECT t9.*, m.*, m.c5 FROM t9, post_max_range m WHERE true ORDER BY m.*,1,2,3,4,5,7,8,9,10,12,13,14,15,16,18,21,22,23,25,41,40,38,37,36,35,34,33,32,31,30,29 LIMIT 20;
-- Testcase 154:
SELECT t9.*, m.c11, m.c12 FROM t9, post_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 155:
SELECT t9.c3, m.c1, t9.c1 + m.c2, m.c5, m.c2 FROM t9, post_max_range m WHERE m.c2 IN (1, 2, -128) AND t9.c2 IN (200, 500000) ORDER BY 1,2,3,4,5;
-- Testcase 156:
SELECT t9.c2, t9.c3 FROM t9, post_max_range m WHERE t9.c8 LIKE '%B%' AND m.__spd_url LIKE '/post1/' order by 1,2;
-- Testcase 157:
SELECT t9.c10, m.c3, m.c4 FROM t9, post_max_range m WHERE t9.c1 IN (SELECT c2 FROM post_max_range WHERE c2 < 100) ORDER BY 1,2,3 OFFSET 1 LIMIT 50;
-- Testcase 158:
SELECT t9.c10, m.c3, m.c4 FROM t9, post_max_range m WHERE t9.c1 < (SELECT avg(c7) FROM post_max_range WHERE c2 > 0) ORDER BY 1,2,3 OFFSET 1 LIMIT 30;
-- Testcase 159:
SELECT max(t9.c1), max(m.c2) FROM t9, post_max_range m WHERE (t9.c2 BETWEEN -10000 AND 10000) AND (m.c2 BETWEEN -1000 AND 10000);
-- Testcase 160:
SELECT t9.c20, t9.c21, t9.c22, m.c1, m.c8*2+t9.c1, abs(m.c8) FROM t9, post_max_range m WHERE t9.c2 = 4 OR t9.c1 = 0 AND m.c1 <> 127 OR m.c2 < -3000 ORDER BY 2,3,4,5,6 LIMIT 30 OFFSET 10;
-- Testcase 161:
SELECT t9.c16, t9.c17, t9.c18, m.c1, m.c4, m.c5 FROM t9, post_max_range m WHERE -1000 < ALL(SELECT c2 FROM post_max_range) AND t9.c8 = ANY(ARRAY['IJKLMNOP','Portugal','a']) AND EXISTS ( SELECT * FROM t9 WHERE t9.c1 > m.c2) ORDER BY 1,3,4,5,6;
-- Testcase 162:
SELECT * FROM t9, post_max_range m WHERE m.c9 ISNULL AND t9.c22 IS NOT NULL;
-- Testcase 163:
SELECT t9.c1, max(t9.c2), count(m.c1), avg(m.c8), sum(m.c2), min(t9.c1-m.c7) FROM  t9, post_max_range m GROUP BY t9.c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 164:
SELECT avg(t9.c1), max(t9.c13), count(m.c1), avg(m.c8/m.c7), sum(m.c5), min(t9.c1-t9.c2) FROM  t9, post_max_range m GROUP BY t9.c1 HAVING t9.c1>-50 AND t9.c1%2=0 ORDER BY 1,2,3,4,5,6;
-- Testcase 165:
SELECT count(*), max(m.c11), min(t9.c14), sum(distinct t9.c29), sum(distinct m.c1), count(m.c4) FROM t9, post_max_range m GROUP BY t9.c1, m.c2 ORDER BY 1,2,3,4,5,6 LIMIT 30;
-- Testcase 166:
SELECT count(*), max(m.c1/10.5+t9.c2), sum(t9.c1+m.c8), avg(m.c2), stddev(m.c2) FROM t9, post_max_range m GROUP BY t9.c2, m.c1 HAVING t9.c2*100 > m.c1 AND t9.c2 IN (1,127,0) AND m.c1<0 ORDER BY 1,2,3,4,5;
-- Testcase 167:
SELECT DISTINCT t9.c7, m.c1, t9.c8, m.c9, t9.c9, t9.c10, m.c3 FROM t9, post_max_range m WHERE t9.c1 != m.c1 AND m.c2 > 0 ORDER BY 1, 2 DESC, t9.c8 ASC, m.c9 DESC, t9.c9, t9.c10 DESC, m.c3 ASC;
-- Testcase 168:
SELECT t9.c1, t9.c1 > m.c1 ,m.c5 FROM t9, post_max_range m ORDER BY 1,2,3 LIMIT 20;
-- Testcase 169:
SELECT DISTINCT t9.c7, t9.c2 < m.c2, m.c4 FROM t9, post_max_range m WHERE t9.c9 NOT LIKE '%M%' ORDER BY 2,3,1 OFFSET 10;
-- Testcase 170:
SELECT array_agg(m.c1 ORDER BY m.c1), array_agg(t9.c1 ORDER BY t9.c1 DESC) FROM t9, post_max_range m WHERE t9.c1%2=0 AND m.c2<100 AND t9.c9 NOT LIKE '%t%' AND t9.c1 BETWEEN -2 AND 2;
-- Testcase 171:
SELECT count(distinct t9.c1/2), array_agg(distinct m.c2 order by m.c2) FROM t9, post_max_range m;
-- Testcase 172:
SELECT t9.c3, t9.c4, t9.c5, m.c13, m.c2 FROM t9, (SELECT DISTINCT * FROM post_max_range WHERE c11<'12:00:00' OR c2=-127) m WHERE t9.c2 > 0 AND m.c1 > 0 ORDER BY 1,2,3,4,5 LIMIT 30;
-- Testcase 173:
SELECT t9.c2, m.c1, count(*), max(m.c1/10.5+t9.c2), sum(t9.c1+m.c8), avg(m.c2), stddev(m.c2) FROM t9, post_max_range m WHERE t9.c2%100=0 OR t9.c9 LIKE '%a%' GROUP BY t9.c2, m.c1 HAVING t9.c2*1000 != m.c1 AND t9.c2 BETWEEN -1000 AND 20000 ORDER BY 1,2,3,4,5,6,7 LIMIT 20 OFFSET 4;
-- Testcase 174:
SELECT array_agg(t9.c1 order by t9.c1), avg(t9.c1), bit_and(t9.c1), bit_or(t9.c1), bool_and(t9.c5), bool_or(t9.c5), count(*), count(t9.c19), every(t9.c1>0), max(t9.c1), min(t9.c1),  sum(t9.c1), corr(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), covar_pop(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), covar_samp(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), regr_avgx(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), regr_avgy(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), regr_count(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13), regr_intercept(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), regr_r2(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13), regr_slope(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), regr_sxx(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13), regr_sxy(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13), regr_syy(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28), stddev(t9.c28 ORDER BY t9.c28), stddev_pop(t9.c28 ORDER BY t9.c28), stddev_samp(t9.c28 ORDER BY t9.c28), variance(t9.c1), var_pop(t9.c1), var_samp(t9.c28 ORDER BY t9.c28) from t9, post_max_range m WHERE t9.c1=1 OR t9.c1=2;
-- Testcase 175:
SELECT json_agg(t9.c1 order by t9.c1), jsonb_agg(t9.c1 order by t9.c1), json_object_agg(t9.c1,t9.c2 order by t9.c1,t9.c2), jsonb_object_agg(t9.c1,t9.c2 order by t9.c1,t9.c2), string_agg(t9.c8,';' order by t9.c8) from t9,  post_max_range m WHERE t9.c1=1 OR t9.c1=2;
-- Testcase 176:
SELECT array_agg(t9.c1 order by t9.c1), avg(t9.c1)+100, bit_and(t9.c1)-10, bit_or(t9.c1)-100, bool_and(t9.c5)=true, bool_or(t9.c5)=false, count(*)*2+100, count(t9.c19)-100, every(t9.c1>0)=true, max(t9.c1)*2, min(t9.c1)/5,  sum(t9.c1)+10, corr(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)+100, covar_pop(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)-100, covar_samp(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)-90, regr_avgx(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)+80, regr_avgy(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)*2, regr_count(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13)-82, regr_intercept(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)+100, regr_r2(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13)-30, regr_slope(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)*2, regr_sxx(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13)-100, regr_sxy(t9.c28,t9.c13 ORDER BY t9.c28,t9.c13)+21, regr_syy(t9.c13,t9.c28 ORDER BY t9.c13,t9.c28)/90+10, stddev(t9.c28 ORDER BY t9.c28)*22, stddev_pop(t9.c28 ORDER BY t9.c28)-100, stddev_samp(t9.c28 ORDER BY t9.c28)-10, variance(t9.c1)+20, var_pop(t9.c1)+90, var_samp(t9.c28 ORDER BY t9.c28)*2+5 from t9, post_max_range m WHERE t9.c1=1 OR t9.c1=2;
-- Testcase 177:
SELECT json_agg(t9.c1*2 order by t9.c1), jsonb_agg(t9.c1+10 order by t9.c1), json_object_agg(t9.c1*20,t9.c2 order by t9.c1,t9.c2), jsonb_object_agg(t9.c1,t9.c2+10 order by t9.c1,t9.c2), string_agg(upper(t9.c8),';' order by t9.c8) from t9,  post_max_range m WHERE t9.c1=1 OR t9.c1=2;
-- Testcase 178:
SELECT * FROM tmp_t11, tmp_file_max_range m ORDER BY m.*, 1,2,3,4,6,7,8,9,11,12,13,14,15,18,19,20,22,25,26,27,28,29,30,31,32,33,35,36 LIMIT 50;
-- Testcase 179:
SELECT (tmp_t11.c1 - tmp_t11.c1/1000), m.c1, m.c2, tmp_t11.c21, tmp_t11.c12, m.c9, m.c8, m.c10, m.c4/2  FROM tmp_t11, tmp_file_max_range m WHERE m.c1 < 1000 AND tmp_t11.c12 < 50 ORDER BY 1,2,3,4,5,6,7,8,9;
-- Testcase 180:
SELECT max(tmp_t11.c1+55), max(m.c4 + tmp_t11.c22), max(m.c1)/2, max(m.c10), max(tmp_t11.c1/2), min(tmp_t11.c14+tmp_t11.c27*2), min(tmp_t11.c30-'10 days'::interval), min(tmp_t11.c8), min(m.c1/2), min(m.c4), min(tmp_t11.c8), min(m.c10) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1<10 ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 181:
SELECT sum((tmp_t11.c1+45)/2), sum(tmp_t11.c12)/5 + 10, sum(tmp_t11.c14+m.c6/2), sum(m.c5/100) + 10, sum(m.c4 + tmp_t11.c1), sum(m.c5/10000.5), avg(tmp_t11.c1+tmp_t11.c12), avg(tmp_t11.c28/50+100), avg(m.c6)/5 + 100, avg(m.c6/500 + tmp_t11.c1*5 + tmp_t11.c1) FROM tmp_t11, tmp_file_max_range m WHERE m.c1 <> tmp_t11.c1 ORDER BY 1,2,3;
-- Testcase 182:
SELECT count(*), count(distinct tmp_t11.c7) filter (where tmp_t11.c1>0), count(tmp_t11.c1), count(m.c1), count(distinct tmp_t11.c3), count(distinct m.c5) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1%2 != 0 AND m.c3>0;
-- Testcase 183:
SELECT stddev(tmp_t11.c1*2)+100, stddev(tmp_t11.c12+m.c4)*2-200, stddev(m.c4/tmp_t11.c1), stddev(m.c5)/5 + 10, stddev(distinct m.c6) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 > 0 AND m.c2 <> '1999-02-04';
-- Testcase 184:
SELECT array_agg(tmp_t11.c1 order by tmp_t11.c1), array_agg(distinct m.c1 order by m.c1), array_agg(tmp_t11.c12 + tmp_t11.c1/5 + 1 order by tmp_t11.c12 + tmp_t11.c1/5 + 1), array_agg(m.c5 order by m.c5), array_agg(distinct tmp_t11.c29 order by tmp_t11.c29) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 BETWEEN -1 AND 1 AND m.c7 != '00:00:01';
-- Testcase 185:
SELECT bit_and(tmp_t11.c1)+10, bit_and((m.c6+500)/20)/2+100, bit_or(m.c4)/2, bit_or(tmp_t11.c1+tmp_t11.c14)+10, bool_and(tmp_t11.c28>100), bool_or(m.c2<'9990-12-31') FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 < m.c1;
-- Testcase 186:
SELECT tmp_t11.c1, tmp_t11.c2, m.c3, m.c10, m.__spd_url FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 = -3 AND m.c2 = '0001-01-02' AND m.c6 <> 32766 AND tmp_t11.c2 != b'10100' AND tmp_t11.c28 > -100 AND m.c1 < 100000 ORDER BY 1,2,3,4;
-- Testcase 187:
SELECT tmp_t11.c6, tmp_t11.c7, m.c4, m.c9, tmp_t11.c14*m.c6 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 >= 0 AND m.c2 <= '8000-12-01' ORDER BY 1,2,3,4,5 LIMIT 30;
-- Testcase 188:
SELECT tmp_t11.c1/(m.c6+32768), m.c6/tmp_t11.c1 FROM tmp_t11, tmp_file_max_range m;
-- Testcase 189:
SELECT tmp_t11.*, m.*, m.c5 FROM tmp_t11, tmp_file_max_range m WHERE true ORDER BY m.*, 1,2,3,4,6,7,8,9,11,12,13,14,15,18,19,20,22,25,26,27,28,29,30,31,32,33,35,36 LIMIT 20;
-- Testcase 190:
SELECT tmp_t11.*, m.c5, m.* FROM tmp_t11, tmp_file_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 191:
SELECT tmp_t11.c3, m.c1, tmp_t11.c1 + m.c6, m.c5, m.c2 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c2 IN (b'1010101100', b'0000000000', b'1111111111') AND m.c2 IN ('9999-12-31', '0001-01-02') ORDER BY 1,2,3,4,5;
-- Testcase 192:
SELECT tmp_t11.c2, tmp_t11.c3, tmp_t11.c8 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c8 LIKE '%B%' AND m.__spd_url LIKE '/tmp%' order by 1,2,3;
-- Testcase 193:
SELECT tmp_t11.c33, m.c3, m.c4 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 IN (SELECT c6 + 32768 FROM tmp_file_max_range WHERE c6 != 32767) ORDER BY 1,2,3 OFFSET 1 LIMIT 50;
-- Testcase 194:
SELECT tmp_t11.c30, m.c3, m.c4 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 < (SELECT avg(c6) FROM tmp_file_max_range WHERE c1 > 0) ORDER BY 1,2,3 OFFSET 1 LIMIT 30;
-- Testcase 195:
SELECT max(tmp_t11.c1), max(m.c2), min(m.c1), min(tmp_t11.c27)+100 FROM tmp_t11, tmp_file_max_range m WHERE (tmp_t11.c12 BETWEEN -10000 AND 10000) AND (m.c6 BETWEEN -1000 AND 1000000);
-- Testcase 196:
SELECT tmp_t11.c20, tmp_t11.c21, tmp_t11.c22, m.c1, m.c5*2+tmp_t11.c1, abs(m.c5) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 = 4 OR tmp_t11.c1 = 0 AND m.c1 <> 127 OR m.c6 < -3000 ORDER BY 1,2,3,4,5,6 LIMIT 30 OFFSET 10;
-- Testcase 197:
SELECT tmp_t11.c10, tmp_t11.c20, tmp_t11.c18, m.c1, m.c4, m.c5 FROM tmp_t11, tmp_file_max_range m WHERE -1000 < ALL(SELECT c6 FROM tmp_file_max_range WHERE c6 > -20000) AND tmp_t11.c8 = ANY(ARRAY['IJKLMNOP','Portugal','0123456789']) AND EXISTS (SELECT * FROM tmp_t11 WHERE tmp_t11.c1 > m.c5) ORDER BY 2,4,5,6;
-- Testcase 198:
SELECT * FROM tmp_t11, tmp_file_max_range m WHERE m.c9 ISNULL AND tmp_t11.c22 IS NOT NULL ORDER BY m.*, 1,2,3,4,6,7,8,9,11,12,13,14,15,18,19,20,22,25,26,27,28,29,30,31,32,33,35,36;
-- Testcase 199:
SELECT tmp_t11.c1, max(tmp_t11.c29), count(m.c1), avg(m.c6/5), sum(m.c5 + 100), min(tmp_t11.c1-m.c5) FROM  tmp_t11, tmp_file_max_range m GROUP BY tmp_t11.c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 200:
SELECT avg(tmp_t11.c1), max(tmp_t11.c13), count(m.c1), avg(m.c6/m.c5), sum(m.c5), min(tmp_t11.c1-tmp_t11.c28) FROM  tmp_t11, tmp_file_max_range m GROUP BY tmp_t11.c1 HAVING tmp_t11.c1>-50 AND tmp_t11.c1%2=0 ORDER BY 1,2,3,4,5,6;
-- Testcase 201:
SELECT count(*), max(m.c1)/500+10, min(tmp_t11.c14), sum(distinct tmp_t11.c1), sum(distinct m.c6), count(distinct tmp_t11.c20) FROM tmp_t11, tmp_file_max_range m GROUP BY tmp_t11.c1, m.c2 ORDER BY 1,2,3,4,5,6 LIMIT 30;
-- Testcase 202:
SELECT count(*), max(m.c5/10.5+tmp_t11.c1), sum(tmp_t11.c1+m.c6), avg(m.c5), stddev(m.c6) FROM tmp_t11, tmp_file_max_range m GROUP BY tmp_t11.c1, m.c1 HAVING tmp_t11.c1*100 > m.c1 AND tmp_t11.c1 IN (1,127,0) AND m.c1<0 ORDER BY 1,2,3,4,5;
-- Testcase 203:
SELECT DISTINCT tmp_t11.c7, m.c1, tmp_t11.c8, m.c9 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1 != m.c1 AND m.c1 > 100 ORDER BY 1, m.c1 DESC, tmp_t11.c8 ASC, m.c9 DESC LIMIT 30;
-- Testcase 204:
SELECT tmp_t11.c1, tmp_t11.c1 > m.c1 ,m.c5 FROM tmp_t11, tmp_file_max_range m ORDER BY 1,2,3 LIMIT 20;
-- Testcase 205:
SELECT DISTINCT tmp_t11.c7, tmp_t11.c28 < m.c1, m.c4 FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c7 NOT LIKE '%M%' ORDER BY 1,2,3 OFFSET 10 LIMIT 30;
-- Testcase 206:
SELECT array_agg(m.c1 ORDER BY m.c1), array_agg(tmp_t11.c1 ORDER BY tmp_t11.c1 DESC) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c1%2=0 AND m.c1<100 AND tmp_t11.c8 NOT LIKE '%t%' AND tmp_t11.c1 BETWEEN -2 AND 2;
-- Testcase 207:
SELECT count(distinct tmp_t11.c1/2), array_agg(distinct m.c2 order by m.c2) FROM tmp_t11, tmp_file_max_range m;
-- Testcase 208:
SELECT tmp_t11.c3, tmp_t11.c4, tmp_t11.c6, m.c10, m.c2 FROM tmp_t11, (SELECT DISTINCT * FROM tmp_file_max_range WHERE c7<'12:00:00' OR c6=32767) m WHERE tmp_t11.c28 > 0 AND m.c1 > 0 ORDER BY 1,2,3,4,5 LIMIT 30;
-- Testcase 209:
SELECT tmp_t11.c1, m.c1, count(*), max(m.c5/10.5+tmp_t11.c1), sum(tmp_t11.c1+m.c6), avg(m.c5), stddev(m.c6) FROM tmp_t11, tmp_file_max_range m WHERE tmp_t11.c8 NOT LIKE '%1%' AND tmp_t11.c14%3!=0 GROUP BY tmp_t11.c1, m.c1 HAVING tmp_t11.c1*100 >= max(m.c1) AND tmp_t11.c1 IN (1,127,0,-1,-2,-3,-4,-5,-6) AND m.c1<0 ORDER BY 1,2,3,4,5,6,7 LIMIT 10 OFFSET 2;
-- Testcase 210:
SELECT array_agg(tmp_t11.c1 order by tmp_t11.c1), avg(tmp_t11.c1), bit_and(tmp_t11.c1), bit_or(tmp_t11.c1), bool_and(tmp_t11.c4), bool_or(tmp_t11.c4), count(*), count(tmp_t11.c19), every(tmp_t11.c1>0), json_agg(tmp_t11.c1 order by tmp_t11.c1), jsonb_agg(tmp_t11.c1 order by tmp_t11.c1), json_object_agg(tmp_t11.c1,tmp_t11.c2 order by tmp_t11.c1,tmp_t11.c2), jsonb_object_agg(tmp_t11.c1,tmp_t11.c2 order by tmp_t11.c1,tmp_t11.c2), max(tmp_t11.c1), min(tmp_t11.c1), string_agg(tmp_t11.c7,';' order by tmp_t11.c7), sum(tmp_t11.c1), corr(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27), covar_pop(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), covar_samp(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_avgx(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_avgy(tmp_t11.c27,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27), regr_count(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_intercept(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_r2(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_slope(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27), regr_sxx(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), regr_sxy(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27), regr_syy(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12), stddev(tmp_t11.c27 ORDER BY tmp_t11.c27), stddev_pop(tmp_t11.c12 ORDER BY tmp_t11.c12), stddev_samp(tmp_t11.c27 ORDER BY tmp_t11.c27), variance(tmp_t11.c1), var_pop(tmp_t11.c1), var_samp(tmp_t11.c27 ORDER BY tmp_t11.c27) from tmp_t11, tmp_file_max_range WHERE tmp_t11.c1=1 OR tmp_t11.c1=2;
-- Testcase 211:
SELECT array_agg(tmp_t11.c1 order by tmp_t11.c1), avg(tmp_t11.c1)-100, bit_and(tmp_t11.c1)+100, bit_or(tmp_t11.c1)+10, bool_and(tmp_t11.c4)=true, bool_or(tmp_t11.c4)=false, count(*)*2+100, count(tmp_t11.c19)-100, every(tmp_t11.c1>0)=false, json_agg(tmp_t11.c1 order by tmp_t11.c1), jsonb_agg(tmp_t11.c1 order by tmp_t11.c1), json_object_agg(tmp_t11.c1,tmp_t11.c2 order by tmp_t11.c1,tmp_t11.c2), jsonb_object_agg(tmp_t11.c1,tmp_t11.c2 order by tmp_t11.c1,tmp_t11.c2), max(tmp_t11.c1)-100, min(tmp_t11.c1)/2, string_agg(tmp_t11.c7,';' order by tmp_t11.c7), sum(tmp_t11.c1)*10, corr(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27)+100, covar_pop(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)*4, covar_samp(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)/6, regr_avgx(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)-100, regr_avgy(tmp_t11.c27,tmp_t11.c27 ORDER BY tmp_t11.c27)+89, regr_count(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)-50, regr_intercept(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)*5, regr_r2(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)/5, regr_slope(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27)+9, regr_sxx(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)-10, regr_sxy(tmp_t11.c12,tmp_t11.c27 ORDER BY tmp_t11.c12,tmp_t11.c27)+78, regr_syy(tmp_t11.c27,tmp_t11.c12 ORDER BY tmp_t11.c27,tmp_t11.c12)+56, stddev(tmp_t11.c27 ORDER BY tmp_t11.c27)*5, stddev_pop(tmp_t11.c12 ORDER BY tmp_t11.c12)+100, stddev_samp(tmp_t11.c27+90 ORDER BY tmp_t11.c27+90), variance(tmp_t11.c1-10)+1, var_pop(tmp_t11.c1*2)+10, var_samp(tmp_t11.c27*5+100 ORDER BY tmp_t11.c27*5+100) from tmp_t11, tmp_file_max_range WHERE tmp_t11.c1=1 OR tmp_t11.c1=2;
-- Testcase 212:
SELECT * FROM t13, _sqlite_max_range m ORDER BY t13.*, m.* LIMIT 100;
-- Testcase 213:
SELECT (t13.c1 - t13.c2), m.c1, (m.c3 + t13.c3), t13.c21, t13.c12, m.c9, m.c8, m.c13, m.c4/2  FROM t13, _sqlite_max_range m WHERE m.c3 < 1000 ORDER BY 1,2,3,4,5,6,7,8,9;
-- Testcase 214:
SELECT max(t13.c1), max(t13.c7 + t13.c4), max(m.c1)/2, max(m.c8)-100, max(t13.c1/2), min(t13.c5+t13.c4*2), min(t13.c17-1000), min(t13.c8), min(m.c1/2), min(m.c4), min(m.c9)/5, min(m.c12) FROM t13, _sqlite_max_range m WHERE t13.c3 <> 1000 ORDER BY 1,2,3 LIMIT 5 OFFSET 0;
-- Testcase 215:
SELECT sum(t13.c1 + m.c2), sum(t13.c7) + 10, sum(t13.c5+t13.c6/2), sum(m.c1/100) + 10, sum(m.c2 + t13.c3), sum(m.c4/10000 - t13.c6), avg(t13.c5+t13.c6), avg(t13.c20/50  + 100), avg(m.c7) + 100, avg(m.c1/1000 + t13.c6)  FROM t13, _sqlite_max_range m WHERE m.c3 <> t13.c1 ORDER BY 1,2,3;
-- Testcase 216:
SELECT count(*)/2+10, count(t13.c1)*5-20, count(m.c1), count(distinct t13.c3), count(distinct m.c5) FROM t13, _sqlite_max_range m WHERE t13.c1%2 != 0 AND m.c2>0;
-- Testcase 217:
SELECT stddev(t13.c1), stddev(t13.c2+t13.c1), stddev(t13.c3), stddev(m.c4), stddev(distinct m.c2) FROM t13, _sqlite_max_range m;
-- Testcase 218:
SELECT array_agg(t13.c1 order by t13.c1), array_agg(m.c1 order by m.c1), array_agg(t13.c1 + m.c1/5 + 1 order by t13.c1, m.c1), array_agg(m.c5  order by m.c5), array_agg(t13.c2+t13.c3 order by t13.c2, t13.c3) FROM t13, _sqlite_max_range m WHERE t13.c1 < -100 AND m.c2>0;
-- Testcase 219:
SELECT bit_and(t13.c1)+10, bit_and(m.c2/20)/2, bit_or(m.c1)/2, bit_or(t13.c1+t13.c2)+10, bool_and(t13.c2>100), bool_or(m.c2<100) FROM t13, _sqlite_max_range m WHERE t13.c1 < m.c1;
-- Testcase 220:
SELECT t13.c1, t13.c2, m.c3, m.c13 FROM t13, _sqlite_max_range m WHERE t13.c1 = -5 AND m.c2 = -128 AND m.c3 <> 127 AND t13.c2 != 0 AND t13.c4 < -100 AND m.c3 < 1000 ORDER BY 1,2,3,4;
-- Testcase 221:
SELECT t13.c5 - 50, t13.c10, m.c4, m.c12, t13.c2*m.c2 FROM t13, _sqlite_max_range m WHERE t13.c1 >= 0 AND m.c1 <= -1 ORDER BY 1,2,3,4,5;
-- Testcase 222:
SELECT t13.c1/(m.c2+127), m.c1/t13.c3 FROM t13, _sqlite_max_range m;
-- Testcase 223:
SELECT t13.c9, m.c11, m.c5 FROM t13, _sqlite_max_range m WHERE true ORDER BY 1,2,3 LIMIT 20;
-- Testcase 224:
SELECT t13.*, m.c11, m.c12 FROM t13, _sqlite_max_range m WHERE false ORDER BY 2,3 LIMIT 20;
-- Testcase 225:
SELECT t13.c3, m.c1, t13.c1 + m.c2, m.c5, m.c2 FROM t13, _sqlite_max_range m WHERE m.c2 IN (-127, 0, -128) AND t13.c2 IN (0, 30) ORDER BY 1,2,3,4,5;
-- Testcase 226:
SELECT t13.c2, t13.c3 FROM t13, _sqlite_max_range m WHERE t13.c8 LIKE '%B%' AND m.c2 <> 127 order by 1,2;
-- Testcase 227:
SELECT t13.c10, m.c3, m.c4 FROM t13, _sqlite_max_range m WHERE t13.c2 IN (SELECT c2 FROM _sqlite_max_range WHERE c2 < 0) ORDER BY 1,2,3 OFFSET 1 LIMIT 40;
-- Testcase 228:
SELECT t13.c10, m.c3, m.c4 FROM t13, _sqlite_max_range m WHERE t13.c1 < (SELECT avg(c4) FROM _sqlite_max_range WHERE c2 > 0) ORDER BY 1,2,3 OFFSET 1 LIMIT 30;
-- Testcase 229:
SELECT max(t13.c1), max(m.c2) FROM t13, _sqlite_max_range m WHERE t13.c2 BETWEEN 0 AND 1000 AND m.c2 BETWEEN -1000 AND 0;
-- Testcase 230:
SELECT DISTINCT t13.c20, t13.c21, t13.c22, m.c1, m.c2*2+t13.c1, abs(m.c1) FROM t13, _sqlite_max_range m WHERE t13.c2 = 4 OR t13.c1 = 0 AND m.c1 = 127 OR m.c3 < -3000 ORDER BY 1,2,3,4,5,6 LIMIT 30 OFFSET 10; 
-- Testcase 231:
SELECT t13.c16, t13.c17, t13.c18, m.c1, m.c4, m.c5 FROM t13, _sqlite_max_range m WHERE -1000 < ALL(SELECT c2 FROM _sqlite_max_range) AND t13.c2 = ANY(ARRAY[0,127,3]) AND EXISTS (SELECT * FROM t13 WHERE t13.c1 > m.c2) ORDER BY 1,2,3,4,5,6;
-- Testcase 232:
SELECT * FROM t13, _sqlite_max_range m WHERE m.c9 ISNULL AND t13.c22 IS NOT NULL ORDER BY t13.*, m.* LIMIT 100;
-- Testcase 233:
SELECT t13.c1, max(t13.c2), count(m.c1), avg(m.c1), sum(m.c2), min(t13.c1-m.c1) FROM  t13, _sqlite_max_range m GROUP BY t13.c1 ORDER BY 1,2,3,4,5,6;
-- Testcase 234:
SELECT avg(t13.c1), max(t13.c3), count(m.c1), avg(m.c1), sum(m.c2), min(t13.c1-m.c1) FROM  t13, _sqlite_max_range m GROUP BY t13.c1 HAVING t13.c1>-50 AND t13.c1%2=0 ORDER BY 1,2,3,4,5,6;
-- Testcase 235:
SELECT max(t13.c5), min(t13.c14), sum( distinct t13.c6), sum(m.c1), count(m.c4) FROM t13, _sqlite_max_range m GROUP BY t13.c1, m.c2 ORDER BY 1,2,3,4,5;
-- Testcase 236:
SELECT count(*), max(m.c1+t13.c2), sum(t13.c1+m.c1), avg(m.c2), stddev(m.c3) FROM t13, _sqlite_max_range m GROUP BY t13.c2, m.c1 HAVING t13.c2*100 > m.c1 AND t13.c2 IN (1,127,0) AND m.c1<0 ORDER BY 1,2,3,4,5;
-- Testcase 237:
SELECT DISTINCT t13.c7, m.c1, t13.c8, m.c9, t13.c9, t13.c10, m.c3 FROM t13, _sqlite_max_range m WHERE t13.c1 != m.c1 AND m.c2 > 0 ORDER BY 1, m.c1 DESC, t13.c8 ASC, m.c9 DESC, t13.c9 ASC, t13.c10, m.c3 DESC;
-- Testcase 238:
SELECT t13.c1, t13.c1 > m.c1 ,m.c5 FROM t13, _sqlite_max_range m ORDER BY 1,2,3 LIMIT 20;
-- Testcase 239:
SELECT DISTINCT t13.c6, t13.c2 < m.c2, m.c4 FROM t13, _sqlite_max_range m WHERE t13.c9 NOT LIKE '%M%' ORDER BY 1,2,3 OFFSET 10;
-- Testcase 240:
SELECT array_agg(distinct m.c1 ORDER BY m.c1), array_agg(t13.c1 ORDER BY t13.c1 DESC) FROM t13, _sqlite_max_range m WHERE t13.c1%2=0 AND m.c8>0 AND t13.c9 NOT LIKE '%t%';
-- Testcase 241:
SELECT count(distinct t13.c1/2), array_agg(distinct m.c2 order by m.c2) FROM t13, _sqlite_max_range m;
-- Testcase 242:
SELECT t13.c3, t13.c4, t13.c5, m.c1*10+1, m.c2 FROM t13, (SELECT * FROM _sqlite_max_range WHERE c4%2=1 OR c2=-127) m WHERE t13.c3 < 0 AND m.c1 > 0 ORDER BY 1,2,3,4,5;
-- Testcase 243:
SELECT t13.c2, m.c1, count(*), max(m.c1+t13.c2), sum(t13.c1+m.c1), avg(m.c2), stddev(m.c3) FROM t13, _sqlite_max_range m WHERE t13.c2<t13.c6/10000 AND t13.c9 NOT LIKE '%a%' GROUP BY t13.c2, m.c1 HAVING t13.c2*100 > m.c1 AND t13.c2 NOT IN (100,0) AND m.c1<0 ORDER BY 1,2,3,4,5,6,7 LIMIT 10 OFFSET 4;
-- Testcase 244:
SELECT avg(t13.c3), count(*), count(t13.c2), max(t13.c3), min(t13.c3), sum(t13.c3), stddev(t13.c4), variance(t13.c4) from t13, _sqlite_max_range WHERE t13.c3>0;
-- Testcase 245:
SELECT array_agg(t13.c3 order by t13.c3), bit_and(t13.c3), bit_or(t13.c3), bool_and(t13.c5>0), bool_or(t13.c5<10), every(t13.c3>0), json_agg(t13.c3 order by t13.c3), jsonb_agg(t13.c3 order by t13.c3), json_object_agg(t13.c3,t13.c4 order by t13.c3,t13.c4), jsonb_object_agg(t13.c3,t13.c4 order by t13.c3,t13.c4), string_agg(t13.c8,';' order by t13.c8), corr(t13.c4,t13.c4), covar_pop(t13.c4,t13.c4), covar_samp(t13.c4,t13.c4), regr_avgx(t13.c4,t13.c4), regr_avgy(t13.c4,t13.c4), regr_count(t13.c4,t13.c4), regr_intercept(t13.c4,t13.c4), regr_r2(t13.c4,t13.c4), regr_slope(t13.c4,t13.c4), regr_sxx(t13.c4,t13.c4), regr_sxy(t13.c4,t13.c4), regr_syy(t13.c4,t13.c4), stddev_pop(t13.c4), stddev_samp(t13.c4), var_pop(t13.c4), var_samp(t13.c4) from t13, _sqlite_max_range m WHERE t13.c5=1 OR t13.c5=0 AND m.c2=127;
-- Testcase 246:
SELECT avg(t13.c3-10)-10, count(*)+100, count(t13.c2)-20, max(t13.c3)*5, min(t13.c3)/5+100, sum(t13.c3)+90, stddev(t13.c4)*5-10, variance(t13.c4)+100 from t13, _sqlite_max_range WHERE t13.c3>0;
-- Testcase 247:
SELECT array_agg(t13.c3 order by t13.c3), bit_and(t13.c3/2+10)+10, bit_or(t13.c3*2+9)-100, bool_and(t13.c5>0)=false, bool_or(t13.c5<10)=false, every(t13.c3>0)=false, json_agg(t13.c3 order by t13.c3), jsonb_agg(t13.c3 order by t13.c3), json_object_agg(t13.c3,t13.c4 order by t13.c3,t13.c4), jsonb_object_agg(t13.c3,t13.c4 order by t13.c3,t13.c4), string_agg(t13.c8,';' order by t13.c8), corr(t13.c4,t13.c4)*50+10, covar_pop(t13.c4,t13.c4)-100, covar_samp(t13.c4,t13.c4)+90, regr_avgx(t13.c4,t13.c4)*2-70, regr_avgy(t13.c4,t13.c4)+100, regr_count(t13.c4,t13.c4)*2-100, regr_intercept(t13.c4,t13.c4)/60, regr_r2(t13.c4,t13.c4+10)+8, regr_slope(t13.c4/2,t13.c4)*82-10, regr_sxx(t13.c4,t13.c4+100)-100, regr_sxy(t13.c4-9,t13.c4+1)-100, regr_syy(t13.c4,t13.c4)*2, stddev_pop(t13.c4)/5+10, stddev_samp(t13.c4)*10-10, var_pop(t13.c4)/5, var_samp(t13.c4-100)*5+8 from t13, _sqlite_max_range m WHERE t13.c5=1 OR t13.c5=0 AND m.c2=127;
-- Testcase 248:
SELECT * FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1=12345 AND t3.c1=12345 AND t5.c1=12345 AND t7.c2='a' AND t9.c1=12345 AND tmp_t11.c1=12345 AND t13.c1=12345;
-- Testcase 249:
SELECT t1.c1, t3.c1, t5.c1, t7.c2, t9.c1, tmp_t11.c1, t13.c1 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1=1 AND t3.c1=1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0;
-- Testcase 250:
SELECT sum(t1.c1), sum(t3.c1+t7.c3), count(t3.c1), avg(t5.c1), count(t7.c2), sum(t9.c1+100), avg(tmp_t11.c1)+100, avg(t13.c1)+100 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1=1 AND t3.c1=1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0;
-- Testcase 251:
SELECT max(t1.c1), min(t3.c1+t7.c3), stddev(t3.c1), max(t5.c1) + min(t7.c4), stddev(t9.c1+100), max(tmp_t11.c1)+100 + min(t13.c1)+100 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1 IN (1,2) AND t3.c1>1 AND t3.c1<5 AND t5.c1>3000 AND t5.c1<15000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=2 AND t13.c1=2;
-- Testcase 252:
SELECT array_agg(distinct t1.c1 order by t1.c1), bit_and(t3.c1+t7.c3) + count(t5.c1), bit_or(t3.c1), bool_and(t5.c1<t5.c4), bool_or(t9.c1+100>0), avg(tmp_t11.c1)+100 + bit_and(t13.c1)+100 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1 IN (1,2) AND t3.c1>1 AND t3.c1<5 AND t5.c1>3000 AND t5.c1<15000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=2 AND t13.c1=2;
-- Testcase 253:
SELECT 100/(t7.c3-1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1 IN (1,2) AND t3.c1>1 AND t3.c1<5 AND t5.c1>3000 AND t5.c1<15000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=2 AND t13.c1=2;
-- Testcase 254:
SELECT t1.c1, max(t1.c2), sum(t3.c2), avg(t5.c2), count(t7.c3), min(t9.c1), stddev(tmp_t11.c1), avg(t13.c1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1%2=0 AND t3.c1=1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1 ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 255:
SELECT t1.c1, max(t1.c2), sum(t3.c2), avg(t5.c2), count(t7.c3), min(t9.c1), stddev(tmp_t11.c1), avg(t13.c1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1!=0 AND t3.c1=1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1<10 AND t13.c1=0 GROUP BY t1.c1 HAVING max(t1.c1)>0 OR min(t1.c1)<-2 ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 256:
SELECT t1.c1, max(t1.c2), sum(t3.c2), avg(t5.c2), count(t7.c3), min(t9.c1), stddev(tmp_t11.c1), avg(t13.c1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1%2=0 AND t3.c1>1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1, t3.c1 ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 257:
SELECT t1.c1, max(t1.c2), sum(t3.c2), avg(t5.c2), count(t7.c3), min(t9.c1), stddev(tmp_t11.c1), avg(t13.c1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1%2=0 AND t3.c1>1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1, t3.c1 HAVING max(t1.c1) < max(t3.c1) ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 258:
SELECT array_agg(distinct t1.c1 ORDER BY t1.c1), array_agg(distinct t1.c2 ORDER BY t1.c2), array_agg(distinct t3.c2 ORDER BY t3.c2), array_agg(distinct t5.c2 ORDER BY t5.c2), array_agg(distinct t7.c3 ORDER BY t7.c3), array_agg(distinct t9.c1 ORDER BY t9.c1), array_agg(distinct tmp_t11.c1 ORDER BY tmp_t11.c1), array_agg(distinct t13.c1 ORDER BY t13.c1) FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1=0 AND t3.c1=1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1 ORDER BY 1,2,3,4,5,6,7,8;
-- Testcase 259:
SELECT max(distinct t1.c1), sum(distinct t3.c1+t7.c3), count(distinct t3.c1) + count(t7.c2), avg(distinct t5.c1), min(distinct t7.c2), stddev(distinct t9.c1+100), avg(distinct tmp_t11.c1)+100, sum(distinct t13.c1)+100 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1>1 AND t3.c1<1 AND t5.c1>3000 AND t7.c3<1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0;
-- Testcase 260:
SELECT max(distinct t1.c1), sum(distinct t3.c1+t7.c3), count(distinct t3.c1) + count(t7.c2), avg(distinct t5.c1), min(distinct t7.c2), stddev(distinct t9.c1+100), avg(distinct tmp_t11.c1)+100, sum(distinct t13.c1)+100 FROM t1,(SELECT * FROM t3 WHERE t3.c5%3=2) AS t3,(SELECT * FROM t5 WHERE t5.c3>t5.c4) AS t5,t7,t9,tmp_t11,t13 WHERE t1.c1=1 AND t3.c1>1 AND t5.c1!=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0;
-- Testcase 261:
SELECT t1.c1, max(distinct t1.c1), sum(distinct t3.c1+t7.c3), count(distinct t3.c1) + count(t7.c2), avg(distinct t5.c1), min(distinct t7.c2), stddev(distinct t9.c1+100), avg(distinct tmp_t11.c1)+100, sum(distinct t13.c1)+100 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1>(SELECT count(*) FROM t3 WHERE t3.c1 != 0) AND t3.c1<1 AND t5.c1>(SELECT avg(t7.c3) FROM t7 WHERE true) AND t7.c3<1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1 ORDER BY 1,2,3,4,5,6,7,8,9;
-- Testcase 262:
SELECT avg(t1.c1)/2+100, avg(t1.c7)-200, stddev(t3.c2-100)+100, avg(t5.c2)*5+100, stddev(t7.c3)-100, avg(t9.c1+t3.c1), stddev(tmp_t11.c1)+100, avg(t13.c1)-1234 FROM t1,t3,t5,t7,t9,tmp_t11,t13 WHERE t1.c1%2=0 AND t3.c1>1 AND t5.c1=3000 AND t7.c3=1 AND t9.c1=1 AND tmp_t11.c1=1 AND t13.c1=0 GROUP BY t1.c1, t3.c1 ORDER BY 1,2,3,4,5,6,7,8;
