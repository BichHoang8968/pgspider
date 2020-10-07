------------------------------BasicFeature_ComplexCommand-----------------------------
SET timezone TO 0;
-- Testcase 1:
SELECT DISTINCT t13.c1, bit_and(t13.c1), stddev(t13.c4) - 10, array_agg(t13.c1), count(t13.c8), 1000 - t13.c4 * (random() <= 1)::int  FROM (SELECT * FROM (SELECT * FROM t13 WHERE t13.c1 != t13.c2) AS t13) AS t13 WHERE  t13.c2 >0 GROUP BY c1, c4 ORDER BY 1 ASC, 2 DESC, 3, 4, 5, 6 LIMIT 50;
-- Testcase 2:
SELECT max(t5.c1), max(t5.c2)+1, max(t5.c3)+2, max(t5.c4)*3 FROM t5 WHERE t5.c1 <> ( SELECT max(t7.c3) FROM t7 WHERE t7.c3 != t7.c4) GROUP BY t5.c1, t5.c17, t5.c14 HAVING t5.c1 != 3 OR SUM(t5.c17) <> 0 OR t5.c17 != 121234 ORDER BY 1, 2, 3, 4;
-- Testcase 3:
SELECT SUM(t3.c4), count(ALL t3.c1) FROM (SELECT * FROM (SELECT * FROM t13 ORDER BY 1 DESC) AS t3 WHERE true) AS t3 WHERE t3.c1 <= ALL (SELECT max(t3.c2) FROM t3) GROUP BY t3.c1 ORDER BY 1, 2 LIMIT 1000;
-- Testcase 4:
SELECT DISTINCT c1 FROM griddb_max_range WHERE 3 >= (SELECT count(DISTINCT c1) FROM griddb_max_range WHERE c1 <= 1000 ORDER BY 1 DESC) ORDER BY c1 DESC;
-- Testcase 5:
SELECT * FROM (SELECT * FROM (SELECT count(*) FROM t9 WHERE c29>=0 OR c32 = 'abc123456789')  AS t9 WHERE true ) AS t9  FULL JOIN (SELECT c4 FROM t7 WHERE c3 between -50 AND 60)  AS t7 ON (TRUE) ORDER BY 1, 2 OFFSET 0 LIMIT 100;
-- Testcase 6:
SELECT t13.c1, t3.c1, t5.c1 FROM t13 INNER JOIN t3 ON (t13.c1 = t3.c4 AND t13.c1 between -1530 AND 69840) FULL JOIN t5 ON (t3.c1 = t5.c1) ORDER BY t13.c1, t3.c1, t5.c1 LIMIT 50;
-- Testcase 7:
SELECT * FROM (SELECT t13.c1, t13.c3, t5.c7 FROM t13 JOIN t5 ON (t13.c1 != t5.c1)) AS t13 ORDER BY 1, 2, 3 OFFSET 100 LIMIT 50;
-- Testcase 8:
SELECT count(*) FROM (SELECT c15, count(c1) FROM t9 GROUP BY t9.c15, SQRT(ABS(c29)) HAVING AVG(c1) <= 1 AND AVG(c1) < 500) AS t9;
-- Testcase 9:
SELECT array_agg(distinct (t13.c1)%5 ORDER BY (t13.c1)%5) FROM t13 FULL JOIN t7 on (t13.c1 = t7.c3) WHERE t13.c1 < 20 or (t13.c1 is null AND t7.c3 < 5) GROUP BY (t7.c3)%3 ORDER BY 1;
-- Testcase 10:
SELECT SUM(c1%3), SUM(distinct c1%3 ORDER BY c1%3) filter (where c1%3 < 2), c2 FROM t5 WHERE c14 NOT IN ('0123456789', '敷ヘカウ告政ヨハツヤ消70者32精楽ざ') GROUP BY c2 ORDER BY 1, 2, 3;
-- Testcase 11:
SELECT count(*), SUM(t13.c1), AVG(t5.c1) FROM (SELECT c1 FROM t13 WHERE c1 between -61250 AND 6940) AS t13 FULL JOIN (SELECT c1 FROM t5 WHERE c1 between -8510 AND 69840) AS t5 on (t13.c1 = t5.c1);
-- Testcase 12:
SELECT t13.c1, t3.c3 FROM t13 LEFT JOIN (SELECT * FROM t3 WHERE c3 < 10) AS t3 ON t13.c1 = t3.c3 WHERE t13.c1 < 10 ORDER BY 1,2;
-- Testcase 13:
SELECT t13.c1, t3.c3, t5.c5 FROM t13 INNER JOIN t5 ON (t13.c1 !=  1 AND t13.c1 between -51650 AND 68460) FULL JOIN t3 ON (t3.c3 = t5.c5) ORDER BY t13.c1, t3.c3, t5.c5 LIMIT 20;
-- Testcase 14:
SELECT count(t5.c5) FROM (SELECT t5.c5, SUM(t5.c1) FROM t5 GROUP BY t5.c5 ORDER BY 1) AS t5 WHERE t5.c5 <>( SELECT max(t9.c1) FROM t9) HAVING AVG(t5.c5) * 2 <= 641100 AND AVG(t5.c5) > -65110;
-- Testcase 15:
SELECT COUNT(*), (SELECT t13.c24 FROM tmp_t11 INNER JOIN t3 ON t3.c6=tmp_t11.c12 INNER JOIN t13 ON t13.c20=t3.c6 INNER JOIN t1 ON t1.c1=t3.c4 WHERE t3.c7=t1.c8 ORDER BY tmp_t11.c28 DESC, t13.c21 ASC LIMIT 10) AS t13_ FROM t1 INNER JOIN t3 ON t3.c6=t1.c7 INNER JOIN tmp_t11 ON tmp_t11.c22!=t3.c10 ORDER BY 1 DESC;
-- Testcase 16:
SELECT t.c1, t.c2, t.c3, t.c4, q.NumEntries FROM t1 t INNER JOIN (SELECT c1, c2, c3, COUNT(*) AS NumEntries FROM t1 GROUP BY c1, c2, c3 HAVING COUNT(*) > 1 /* Duplicates exist */) q ON t.c1 = q.c1 AND t.c2 = q.c2 AND t.c3 = q.c3 ORDER BY t.c1, t.c2, t.c3, t.c4, 5;
-- Testcase 17:
SELECT * FROM t1 INNER JOIN t9 ON t1.c5 = t9.c5 LEFT OUTER JOIN t3 ON t1.c1 = t3.c4 ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,32,33,34,35,36,38,41,42,43,45,48,49,50,51,52,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,69,70, t3.__spd_url;
-- Testcase 18:
SELECT * FROM t1 LEFT OUTER JOIN t7 ON t1.c5 = t7.c5 WHERE t7.time IS NOT NULL UNION SELECT * FROM t1 RIGHT OUTER JOIN t7 ON t1.c5 = t7.c5 WHERE t1.c1 IS NOT NULL ORDER BY 1, 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26;
-- Testcase 19:
SELECT c5, c6, AVG(c1) FROM t1 GROUP BY c5, c6 HAVING AVG(c1) > (SELECT AVG(c1) FROM t1 WHERE t1.c7 >= t1.c8);
-- Testcase 20:
SELECT c1, c2, c3, MIN(c7) FROM t1 A WHERE c7 != ( SELECT MIN(c12) FROM tmp_t11 B WHERE B.c4 != A.c5) GROUP BY c1, c2, c3 HAVING MIN(c7) < 5 ORDER BY 1, 2, 3, 4;
-- Testcase 21:
SELECT array_agg(c1 order by c1), avg(c1), bit_and(c1), bit_or(c1), bool_and(c5), bool_or(c5), count(*), count(c19), every(c1>0), json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1), min(c1), string_agg(c2,';' order by c2), sum(c1), corr(c8,c7), covar_pop(c7,c8), covar_samp(c7,c8), regr_avgx(c8,c8), regr_avgy(c7,c7), regr_count(c7,c8), regr_intercept(c7,c8), regr_r2(c7,c8), regr_slope(c8,c8), regr_sxx(c7,c8), regr_sxy(c8,c7), regr_syy(c7,c8), stddev(c7), stddev_pop(c8), stddev_samp(c7), variance(c1), var_pop(c1), var_samp(c7) from t1 WHERE c1=1 OR c1=2;
-- Testcase 22:
SELECT array_agg(c3 order by c3), bit_and(c3), bit_or(c3), bool_and(c5), bool_or(c5), every(c3>0), json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c2,';' order by c2), corr(c4,c4), covar_pop(c4,c4), covar_samp(c4,c4), regr_avgx(c4,c4), regr_avgy(c4,c4), regr_count(c4,c4), regr_intercept(c4,c4), regr_r2(c4,c4), regr_slope(c4,c4), regr_sxx(c4,c4), regr_sxy(c4,c4), regr_syy(c4,c4), stddev_pop(c4), stddev_samp(c4), var_pop(c4), var_samp(c4) from t7 WHERE c3=1 OR c3=2;
-- Testcase 23:
SELECT array_agg(c1 order by c1), avg(c1), bit_and(c1), bit_or(c1), bool_and(c1>0), bool_or(c2<0), count(*), count(c19), every(c1>0), json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1), min(c1), string_agg(c18,';' order by c18), sum(c1), corr(c8,c7), covar_pop(c7,c8), covar_samp(c7,c8), regr_avgx(c8,c8), regr_avgy(c7,c7), regr_count(c7,c8), regr_intercept(c7,c8), regr_r2(c7,c8), regr_slope(c8,c8), regr_sxx(c7,c8), regr_sxy(c8,c7), regr_syy(c7,c8), stddev(c7), stddev_pop(c8), stddev_samp(c7), variance(c1), var_pop(c1), var_samp(c7) from t3 WHERE c1=1 OR c1=2;
-- Testcase 24:
SELECT json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), string_agg(c8,';' order by c8) from t9 WHERE c1=1 OR c1=2;
-- Testcase 25:
SELECT array_agg(c1 order by c1), avg(c1), bit_and(c1), bit_or(c1), bool_and(c4), bool_or(c4), count(*), count(c19), every(c1>0), json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1), min(c1), string_agg(c7,';' order by c7), sum(c1), corr(c12,c27), covar_pop(c27,c12), covar_samp(c27,c12), regr_avgx(c27,c12), regr_avgy(c27,c27), regr_count(c27,c12), regr_intercept(c27,c12), regr_r2(c27,c12), regr_slope(c12,c27), regr_sxx(c27,c12), regr_sxy(c12,c27), regr_syy(c27,c12), stddev(c27), stddev_pop(c12), stddev_samp(c27), variance(c1), var_pop(c1), var_samp(c27) from tmp_t11 WHERE c1=1 OR c1=2;
-- Testcase 26:
SELECT array_agg(c3 order by c3), bit_and(c3), bit_or(c3), bool_and(c5>0), bool_or(c5<10), every(c3>0), json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c8,';' order by c8), corr(c4,c4), covar_pop(c4,c4), covar_samp(c4,c4), regr_avgx(c4,c4), regr_avgy(c4,c4), regr_count(c4,c4), regr_intercept(c4,c4), regr_r2(c4,c4), regr_slope(c4,c4), regr_sxx(c4,c4), regr_sxy(c4,c4), regr_syy(c4,c4), stddev_pop(c4), stddev_samp(c4), var_pop(c4), var_samp(c4) from t13 WHERE c5=1 OR c5=0;
-- Testcase 27:
SELECT avg(c3), count(*), count(c2), max(c3), min(c3), sum(c3), stddev(c4), variance(c4) from t7 WHERE c3=1 OR c3=2;
-- Testcase 28:
SELECT avg(c3), count(*), count(c2), max(c3), min(c3), sum(c3), stddev(c4), variance(c4) from t5 WHERE c3>0;
-- Testcase 29:
SELECT array_agg(c1 order by c1), avg(c1), bit_and(c1), bit_or(c1), bool_and(c5), bool_or(c5), count(*), count(c19), every(c1>0), max(c1), min(c1),  sum(c1), corr(c13,c28), covar_pop(c13,c28), covar_samp(c13,c28), regr_avgx(c13,c28), regr_avgy(c13,c28), regr_count(c28,c13), regr_intercept(c13,c28), regr_r2(c28,c13), regr_slope(c13,c28), regr_sxx(c28,c13), regr_sxy(c28,c13), regr_syy(c13,c28), stddev(c28), stddev_pop(c28), stddev_samp(c28), variance(c1), var_pop(c1), var_samp(c28) from t9 WHERE c1=1 OR c1=2;
-- Testcase 30:
SELECT avg(c3), count(*), count(c2), max(c3), min(c3), sum(c3), stddev(c4), variance(c4) from t13 WHERE c3>0;
-- Testcase 31:
SELECT array_agg(c1 order by c1), avg(c1+10)*2+100, bit_and(c1-10)-100, bit_or(c1+10)-55, bool_and(c5)=false, bool_or(c5)=false, count(*)+100, count(c19)-100, every(c1>0)=false, json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1)+10.55, min(c1)-100.6, string_agg(c2,';' order by c2), sum(c1)+100, corr(c8,c7)-100, covar_pop(c7,c8)-100, covar_samp(c7,c8)+100, regr_avgx(c8,c8)-55, regr_avgy(c7,c7)-80, regr_count(c7,c8)-100, regr_intercept(c7,c8)+76.5, regr_r2(c7,c8)+10.5, regr_slope(c8,c8)*20+10, regr_sxx(c7,c8)-100, regr_sxy(c8,c7)-90, regr_syy(c7,c8)+10, stddev(c7)+50.6, stddev_pop(c8)-10, stddev_samp(c7)+10, variance(c1)+100, var_pop(c1)+10, var_samp(c7)*2+10 from t1 WHERE c1=1 OR c1=2;
-- Testcase 32:
SELECT avg(c3)+10, count(*)*2+10, count(c2)-10, max(c3)+100, min(c3)/5, sum(c3)+19, stddev(c4)+20, variance(c4)*5+16.5 from t7 WHERE c3=1 OR c3=2;
-- Testcase 33:
SELECT avg(c3*2)+10, count(*)-100, count(c2+90)+10, max(c3)/3+10, min(c3+9)-100, sum(c3)+100, stddev(c4)*6+100, variance(c4)-100 from t5 WHERE c3>0;
-- Testcase 34:
SELECT array_agg(c1 order by c1), avg(c1)-10, bit_and(c1)+10, bit_or(c1-89)+90, bool_and(c5)=true, bool_or(c5)=false, count(*)-100, count(c19)*2, every(c1>0)=true, max(c1)-10, min(c1)/5,  sum(c1)+90, corr(c13,c28)*2, covar_pop(c13,c28)-100, covar_samp(c13,c28)*2+10, regr_avgx(c13,c28)-100, regr_avgy(c13,c28+10)+10, regr_count(c28,c13-c28)+100, regr_intercept(c13,c28-1)*29, regr_r2(c28,c13)-10, regr_slope(c13,c28)+190, regr_sxx(c28,c13)-100, regr_sxy(c28,c13)+100, regr_syy(c13,c28)/2, stddev(c28)*50, stddev_pop(c28)-100, stddev_samp(c28)+100, variance(c1)*5, var_pop(c1)/100, var_samp(c28)-100 from t9 WHERE c1=1 OR c1=2;
-- Testcase 35:
SELECT array_agg(c1 order by c1), avg(c1+10)-10, bit_and(c1)+100, bit_or(c1)*2+100, bool_and(c4)=false, bool_or(c4)=true, count(*)*5, count(c19)+100, every(c1>0)=false, json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1+10)*2-100, min(c1-1)+100, string_agg(c7,';' order by c7), sum(c1)-10, corr(c12,c27)*2+10, covar_pop(c27,c12)/50, covar_samp(c27,c12)+10, regr_avgx(c27,c12)-100, regr_avgy(c27,c27)+100, regr_count(c27,c12)-10, regr_intercept(c27,c12)*7+10, regr_r2(c27,c12)/3+10, regr_slope(c12,c27)-100, regr_sxx(c27,c12)*2+10, regr_sxy(c12,c27)-10, regr_syy(c27,c12)+90, stddev(c27)/2, stddev_pop(c12)*3, stddev_samp(c27)*5, variance(c1)/10, var_pop(c1)+100, var_samp(c27)/30 from tmp_t11 WHERE c1=1 OR c1=2;
-- Testcase 36:
SELECT avg(c3)*2, count(*)/3, count(c2)+10, max(c3)*2+10, min(c3)-100, sum(c3)*5+10, stddev(c4+10)+100, variance(c4/2)*2+90 from t13 WHERE c3>0;
-- Testcase 37:
SELECT array_agg(c1 order by c1), avg(c1)*2+10, bit_and(c1*5)-100, bit_or(c1-90)+10, bool_and(c1>0)=true, bool_or(c2<0)=false, count(*)*2+89, count(c19)+100, every(c1>0)=true, json_agg(c1 order by c1), jsonb_agg(c1 order by c1), json_object_agg(c1,c2 order by c1,c2), jsonb_object_agg(c1,c2 order by c1,c2), max(c1*2)+100, min(c1-5)*2+89, string_agg(c18,';' order by c18), sum(c1)-100, corr(c8,c7-1)+100, covar_pop(c7,c8)-100, covar_samp(c7-c8,c8)+100, regr_avgx(c8,c8)-100, regr_avgy(c7,c7)-90, regr_count(c7,c8)*2, regr_intercept(c7,c8)/5, regr_r2(c7,c8)+900, regr_slope(c8,c8-c7)+100, regr_sxx(c7,c8)+100, regr_sxy(c8,c7)*34, regr_syy(c7,c8)-10, stddev(c7)+32, stddev_pop(c8)*2, stddev_samp(c7)-100, variance(c1+12)+10, var_pop(c1)-100, var_samp(c7)+90 from t3 WHERE c1=1 OR c1=2;
-- Testcase 38:
SELECT array_agg(c3 order by c3), bit_and(c3)-20, bit_or(c3)*2+10, bool_and(c5)=true, bool_or(c5)=true, every(c3>0)=false, json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c2,';' order by c2), corr(c4,c4)+10, covar_pop(c4,c4)+20, covar_samp(c4,c4)/2, regr_avgx(c4,c4)*5, regr_avgy(c4,c4)-50.2, regr_count(c4,c4)+52, regr_intercept(c4,c4)-65, regr_r2(c4,c4)*50, regr_slope(c4,c4)*2+9, regr_sxx(c4,c4)-5+9, regr_sxy(c4,c4)+9, regr_syy(c4,c4)-5, stddev_pop(c4)+3, stddev_samp(c4+5)-5, var_pop(c4+6)-100, var_samp(c4-9)+10 from t7 WHERE c3=1 OR c3=2;
-- Testcase 39:
SELECT array_agg(c3 order by c3), bit_and(c3+10)+10, bit_or(c3)-100, bool_and(c5>0)=true, bool_or(c5<10)=false, every(c3>0)=false, json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c8,';' order by c8), corr(c4,c4-10)-10, covar_pop(c4-10,c4)-100, covar_samp(c4,c4)*2+19, regr_avgx(c4-10,c4*2)-10, regr_avgy(c4+2,c4-100), regr_count(c4*2,c4)-100, regr_intercept(c4,c4)*2+10, regr_r2(c4,c4)/200, regr_slope(c4,c4)*36, abs(regr_sxx(c4,c4)-100), regr_sxy(c4,c4)-19+20*2, regr_syy(c4,c4)*2-9, stddev_pop(c4)-29, stddev_samp(c4)+92, var_pop(c4)*2-100, var_samp(c4/2)+100 from t5 WHERE c5=1 OR c5=0;
-- Testcase 40:
SELECT json_agg(c1+10 order by c1), jsonb_agg(c1-10 order by c1), json_object_agg(c1-c2,c2 order by c1,c2), jsonb_object_agg(c1*2,c2 order by c1,c2), string_agg(upper(c8),';' order by c8) from t9 WHERE c1=1 OR c1=2;
-- Testcase 41:
SELECT array_agg(c3 order by c3), bit_and(c3)+10, bit_or(c3)-10, bool_and(c5>0)=false, bool_or(c5<10)=true, every(c3>0)=false, json_agg(c3 order by c3), jsonb_agg(c3 order by c3), json_object_agg(c3,c4 order by c3,c4), jsonb_object_agg(c3,c4 order by c3,c4), string_agg(c8,';' order by c8), corr(c4,c4)-10, covar_pop(c4,c4)*2+10, covar_samp(c4,c4)*6+10, regr_avgx(c4,c4)/2, regr_avgy(c4,c4)+100, regr_count(c4,c4)-10, regr_intercept(c4,c4)*5, regr_r2(c4,c4)-100, regr_slope(c4,c4)*2-10, regr_sxx(c4,c4)+90, regr_sxy(c4+90,c4/2)+100, regr_syy(c4,c4)*5+10, stddev_pop(c4)*4+10, stddev_samp(c4)-100, var_pop(c4)+50, var_samp(c4*2+10)*2-10 from t13 WHERE c5=1 OR c5=0;
-- Testcase 42:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM t1;
-- Testcase 43:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM t3;
-- Testcase 44:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM t5;
-- Testcase 45:
SELECT pg_typeof(max(c4)), pg_typeof(count(*)), pg_typeof(avg(c3)), pg_typeof(stddev(c4)), pg_typeof(max(__spd_url)), pg_typeof(sum(c4)) FROM t7;
-- Testcase 46:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM t9;
-- Testcase 47:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM tmp_t11;
-- Testcase 48:
SELECT pg_typeof(max(c1)), pg_typeof(count(*)), pg_typeof(avg(c1)), pg_typeof(stddev(c1)), pg_typeof(max(__spd_url)), pg_typeof(sum(c1)) FROM t13;
-- Testcase 49:
SELECT sum(c1), sum(c1+10), sum(c1) FROM t1 ORDER BY 1, 2, 3;
-- Testcase 50:
SELECT sum(c1), sum(c1+10), sum(c1) FROM t3 ORDER BY 1, 2, 3;
-- Testcase 51:
SELECT sum(c1), sum(c1+10), sum(c1) FROM t5 ORDER BY 1, 2, 3;
-- Testcase 52:
SELECT sum(c3), sum(c3+10), sum(c3) FROM t7 ORDER BY 1, 2, 3;
-- Testcase 53:
SELECT sum(c1), sum(c1+10), sum(c1) FROM t9 ORDER BY 1, 2, 3;
-- Testcase 54:
SELECT sum(c1), sum(c1+10), sum(c1) FROM tmp_t11 ORDER BY 1, 2, 3;
-- Testcase 55:
SELECT sum(c1), sum(c1+10), sum(c1) FROM t13 ORDER BY 1, 2, 3;
-- Testcase 56:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t1;
-- Testcase 57:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t3;
-- Testcase 58:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t5;
-- Testcase 59:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t7;
-- Testcase 60:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t9;
-- Testcase 61:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM tmp_t11;
-- Testcase 62:
SELECT max(__spd_url), min(__spd_url), count(__spd_url) FROM t13;
-- Testcase 63:
SELECT c1 FROM t1 WHERE c1 > 10.5 ORDER BY 1;
-- Testcase 64:
SELECT c1 FROM t3 WHERE c1 > 10.5 ORDER BY 1;
-- Testcase 65:
SELECT c1 FROM t5 WHERE c1 > 10.5 ORDER BY 1;
-- Testcase 66:
SELECT c3 FROM t7 WHERE c3 > 10.5 ORDER BY 1;
-- Testcase 67:
SELECT c1 FROM t9 WHERE c1 > 10.5 ORDER BY 1;
-- Testcase 68:
SELECT c1 FROM tmp_t11 WHERE c1 < 10.5 ORDER BY 1;
-- Testcase 69:
SELECT c1 FROM t13 WHERE c1 > 10.5 ORDER BY 1 DESC;
