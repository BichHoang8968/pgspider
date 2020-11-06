------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
---------------------File query for bug 54---------------------
-- Testcase 1:
SELECT array_agg(c1+c12/(c1-200) order by c1+c12/(c1-200)), array_agg(c12-c14/(c12+3.05)), array_agg((c12)*2), array_agg(c15-c15/c22), array_agg(c15/(c28-20.5)/1000000) from tmp_t11 WHERE c5>=box '((0,0),(0,0))' GROUP BY c12 ORDER BY 1, 2, 3, 4, 5; 
-- Testcase 2:
SELECT avg(c27*c27-c28)- -9.5, avg(c14+(c14-c14))-9999999999999.998, avg(c27+c22*c1)+0.567 from tmp_t11 WHERE c1<=ALL (SELECT max(c14) FROM tmp_t11)GROUP BY c27 ORDER BY 1, 2, 3 OFFSET 0;
-- Testcase 3:
SELECT bool_and(c22+c22-c28 < 1), bool_and(c22+c22-c28+17.55435 =  '1'), bool_and(c22+c22-c28+93.564 >= 10), bool_and(c4) from tmp_t11 ORDER BY 1, 2, 3, 4;
-- Testcase 4:
SELECT bool_or(c22+c27/(c12+24) != 10), bool_or(c28/(c14+c27-10234) <> 100.01), bool_or(c21/(c12-0.5556) = '0.1') from tmp_t11 WHERE c28 NOT IN (0, 500000) GROUP BY c12 ORDER BY 1, 2, 3LIMIT 10; 
-- Testcase 5:
SELECT bit_or((c1-1)), bit_or((c28*5)/2), bit_or((c14-c1)) from tmp_t11 ORDER BY 1, 2, 3;
-- Testcase 6:
SELECT count(*) - 2* count(*), 5 -  count(*) - 200 - 0.5* count(*), count(*)/2/10 from tmp_t11 ORDER BY 1, 2, 3;
-- Testcase 7:
SELECT count(c22*c21/(c28+0.12345))*0.567/count(c12*c22*c12), count(c12+c1+c27)+17.55435-count(c12*c22*c12)-6, count(c12*c22*c12)-6, count(c22+c12*c12)*-1000, count(c2)*1.5*count(c3)-count(c4)-5 from tmp_t11;
-- Testcase 8:
SELECT every(c1<>0)AND every(c1<>0), every(c12 <> 123.4) OR every((c22-10) >=3) OR every(c28/3.14 <=4), every((c22-10) >=3), every(c28/3.14 <=4), every(c14*2 = 1) from tmp_t11;
-- Testcase 9:
SELECT stddev(c12*c22-c14/1), stddev(c14+c12/(c27+0.567)), stddev(c22-c28-c14+9999999999999.998), stddev(27 order by c27) from tmp_t11 ORDER BY 1, 2, 3 , 4;
-- Testcase 10:
SELECT sum(c28+c22-c14)-1-sum(c28)* -0.5678, sum(c1+c1-c12)/1000000+2* sum(c14), sum(c1*c14+c1)+9999999999999.998 - 2/sum(c12), sum(c12*c22/15)+1000000 -  sum(c14-c22/(c22-10.25))-6 from tmp_t11 GROUP BY c22 ORDER BY 1, 2, 3 ,4;
-- Testcase 11:
SELECT max(c1/(c1-23.4)*c21) - max(c21)*0.5, max(c14-c22*c27)-0.567 - max(c22)*2, max(c22*c27)*9999999999999.998 * max (c14)/ 0.5678, max(c1/c22*c27)/100, max(c28+c12-c22)/-9.5 + max(c1) * max(c1) - max(c1) from tmp_t11 GROUP BY c1 ORDER BY 1, 2, 3 ,4, 5;
-- Testcase 12:
SELECT min(c14-c27*c12)+100+min(c1)*10, min(c1/(c28-2.3)/(c27-4.556))*9999999999999.998-min(c14)/2, min(c21)*1, min(c14/(c27+c1+12345))-6/min(c28-2) from tmp_t11 WHERE c7 LIKE '%c%' GROUP BY c14 ORDER BY 1, 2, 3;
-- Testcase 13:
SELECT variance(c12+c12-c14 ORDER BY c12+c12-c14)/6+variance(c1), variance(c27-c14/(c1-2.566) ORDER BY c27-c14/(c1-2.566))-5/variance(c22), variance(c28)+0.5*variance(c27-c12*c28 ORDER BY c27-c12*c28)- -9.5, variance(c12-c28-c12 ORDER BY c12-c28-c12)- -1000, variance(c28*c22-c1)*1000000 from tmp_t11 ORDER BY 1, 2, 3 ,4, 5;
-- Testcase 14:
SELECT sqrt(abs(c27-c1-c22))+100+ sqrt(abs(c1))*0.1010-1, sqrt(abs(c14*c1+c1))+0.567+ sqrt(abs(c22/28+c22))/-9.5,sqrt(abs(c22/28+c22))/-9.5 * 10 - sqrt(abs(c22/28+c22))/-9.5,  sqrt(abs(c22*c12/(c12+123456)))*-9.5, sqrt(abs(c12-c22/(c14-12.453)))-1000000 * sqrt(abs(c22/28+c22))/9.5 from tmp_t11 ORDER BY 1, 2, 3 ,4, 5;
-- Testcase 15:
SELECT bool_and(c4 <> true) OR bool_and(c1 <> 1), bool_and(c22 >= 1000000) from tmp_t11 WHERE EXISTS (SELECT c34 FROM tmp_t11) GROUP BY c4 ORDER BY 1, 2 LIMIT 1 OFFSET 1;
-- Testcase 16:
SELECT bool_or(c12>0.1123),  bit_and((c1-1)), variance(c14)*sum(c22)+stddev(c22)+10, max(c22)-avg(c1)  from tmp_t11 ORDER BY 1, 2,3, 4;
-- Testcase 17:
SELECT sum(c15)/(sum(c1)+15.6), max(c21)/min(c14)/2, min(c1)-avg(c12 ORDER BY c12)* sum(c1*2), max(c8), count(*) * 10* max(c1-100), variance (c1/2) + min(c1) from (select * from tmp_t11) as tmp_111 group by c4 ORDER BY 1, 2, 3, 4, 5, 6 ;
-- Testcase 18:
SELECT stddev(c14)+10* sqrt(abs(c12)), sum(c1)+sum(c12)-sum(c14), c1/2, c12/10-5 from tmp_t11 WHERE c1<=ALL (SELECT max(c14) FROM tmp_t11)  group by c1,c2, c12 ORDER BY 1, 2, 3 ,4 ;
-- Testcase 19:
SELECT c4, c6, c12*10-5, c30, c31, c27/sum(c1+10) from  tmp_t11 WHERE true group by c1, c4, c6, c12, c30, c27, c31 ORDER BY 1, 2, 3, 4, 5, 6;
-- Testcase 20:
SELECT c4, c6, c12*10-5, c30, c31, c27/sum(c1+10) from (SELECT c4, c6, c12, c30, c31, c27, c1 from tmp_t11) as als_tmp_t11 WHERE true group by c1, c4, c6, c12, c30, c27, c31 ORDER BY 1, 2, 3, 4, 5, 6;

------------------------GridDB query for bug 54-----------------------------
-- Testcase 21:
SELECT array_agg(c15 order by c15), array_agg(c17 order by c17), array_agg(c6+c1 order by c6+c1), array_agg(c12 order by c12), array_agg(c13 order by c13), array_agg(c14 order by c14), array_agg(c18 order by c18) from t1 GROUP BY c18 order by 1,2,3,4,5,6,7;
-- Testcase 22:
SELECT avg(c6/c8-c7)+17.55435 - avg(c4), avg(c7+c7/c7)- -1000*avg(c8), avg(c7+c4)-1000000+avg(c1+c6-c1)+1, avg(c1+c6)+9.998, avg(c7+c7/c7)- -1000,avg(c8+c7)/2 from t1 WHERE c2<>'0123456789' GROUP BY c4 order by 1,2,3,4,5;
-- Testcase 23:
SELECT bool_and(c1/(c7-c1) >= 9), bool_and(c8+c4*c7 <> 10), bool_and(c4/(c1+10.25)*c4 != 0), bool_and(c1/(c7+7548)-c4 < 1) from t1 WHERE c1 BETWEEN -100 AND 1000 GROUP BY C1 ORDER BY 1,2,3,4;
-- Testcase 24:
SELECT bool_or(c7*c8*c7*100 > 1) AND  bool_or(c6+c6-c7 <= 1235), bool_or(c6/(c4-c1-200) <=457.1) OR bool_or(c7+c4-c6 != 4), bool_or(c1*c6-c7 >= 0.5) from t1 WHERE c1 in (0, -1, 1, -2147483648) GROUP BY c2 ORDER BY 1,2,3 limit 5;
-- Testcase 25:
SELECT bit_and(c1) +  bit_and(c3)*5, bit_and(c4)-10 - 2* bit_and(c6)+10, bit_and(c6) from t1 WHERE not c8<10 GROUP BY c3 ORDER BY 1, 2, 3;
-- Testcase 26:
SELECT bit_or(c1) +  bit_or(c3)*5, bit_or(c4)-10 - 2* bit_or(c6)+10, bit_or(c6) from t1 WHERE not c8<10 GROUP BY c3 ORDER BY 1, 2, 3;
-- Testcase 27:
SELECT count(*)-10, 2/count(*)-count(*), count(*)-count(*), count(*)+c1, count(*)-c6 from t1 WHERE c7>=30.5 GROUP BY c1, c6 ORDER BY 1,2,3,4,5;
-- Testcase 28:
SELECT count(c8*c1+c7)-1-c8, count(c6*c7+c6)-100+c7, count(c8-c1/(c4-0.98457))*17.55435+count(c1+c8+c8)/100, count(c1-c6/(c4-20))*6-c8 from t1 WHERE true  GROUP BY c8, c7 ORDER BY 1,2,3,4;
-- Testcase 29:
SELECT every(c1 != 1) AND true, every(c4 <> 10) OR every(c7 > 5.6), every(c8 <= 2) OR c5 from t1 GROUP BY c5 ORDER BY 1,2,3 limit 6;
-- Testcase 30:
SELECT stddev(c8-c1+c1)+17.55435+stddev(c8+c6+c7)+6, stddev(c8-c6/(c7-1000))+1000000+c6, stddev(c1+c6-c7)/100-4*c1, 5*stddev(c1/(c7+c8))/0.567+c8 from t1 WHERE c2 like '敷ヘ%' GROUP BY c6, c1, c8 ORDER BY 1,2,3,4;
-- Testcase 31:
SELECT sum(c8/(c7-19.5)-c1)+-9.5+sum(c1), sum(c7-c7+c8)/-1000+c8, sum(c8*c4/4)+0.567-5*c7, sum(c6*c1/0.457)+9999999999999.998+sum(c4), 7-sum(c4/(c7-2.5))-6 from t1 GROUP BY c1, c7, c8 ORDER BY 1,2,3,4,5;
-- Testcase 32:
SELECT max(c1-c8-c7)*2-max(c7*c6+c8)+-1000, max(c8*c6+c7)-0.567+0.5*c6, max(c7-c7-c1)*6-max(c7)-c7/2, max(c2), max(c15), max(4) from t1 WHERE c3>ALL (SELECT min(c1)+100 FROM t1 WHERE c1<10) GROUP BY c6, c7 ORDER BY 1,2,3,4,5;
-- Testcase 33:
SELECT min(c7+c1/(c8+0.25))/100-min(c1+c6/(c7-14.25))/0.567, min(c8-c7+c7)/(min(c1)-9.5), min(c6*c4)*100-c6, min(c1*c7/4)-100+c7/2, min(c7*c8-c7)+6-min(c8) from t1 GROUP BY c6, c7 order by 1,2,3,4,5;
-- Testcase 34:
SELECT variance(c6+c6*c8)-17.55435+variance(c1), variance(c4+c1*c7)/1- variance(c1-c4-c7)- -1000, variance(c7/c7-c1)/100+c7,variance(c1+c7+c4)+1+2*c1 from t1 WHERE EXISTS (SELECT * FROM t1 WHERE c5=true AND c1=c3)  GROUP BY c7, c1 ORDER BY 1,2,3,4; 
-- Testcase 35:
SELECT sqrt(abs(c6/c7*c6))-1+sqrt(abs(c8*c4/4))*1, sqrt(abs(c4+c1+c4))*sqrt(abs(c6))+1+c6, 0.5*sqrt(abs(c6-c4*c6))-6-c4 from t1 WHERE c8<20  GROUP BY c6, c4, c7, c8, c1 ORDER BY 1,2,3;
-- Testcase 36:
SELECT variance(c4)+sum(c4)-max(c1)+c1,array_agg(c4), count(*)-min(c6)+c7, sqrt(abs(c7))*c8-sum(c4), 8*count(c1+c7)+c1+sqrt(abs(c1)) from t1 GROUP BY c1, c7, c8  ORDER BY 1,2,3,4,5;
-- Testcase 37:
SELECT every (c2 != 'aa') AND c5, count(c6)+sum(c7)-count(*), lower(c2), upper(c2), 5*min(c1)-c1, c4/2+4, max(c6)-min(c6) from t1 GROUP BY c2, c1, c4, c5 ORDER BY 1,2,3,4,5,6;
-- Testcase 38:
SELECT c1/2*5+c1, min(c4)*count(c4), max(c6)+c6*0.5, c7/4 from t1 WHERE NOT EXISTS (SELECT * FROM t1 WHERE c2='abcd1234') GROUP BY c1, c6, c7 ORDER BY 1,2,3,4;
-- Testcase 39:
SELECT c18, c19, c6/2+c6, c6+c7+sum(c6), count(*)+count(c4), min(c8)/2+min(c7)*123 from t1 GROUP BY c6, c7, c18, c19 ORDER BY 1,2,3,4,5;
-- Testcase 40:
SELECT c18, c19, c6+c7+sum(c6), count(*)+count(c4), min(c8)/2+min(c7)*123 from (SELECT c18, c19, c6, c7, c4, c8 from t1) as als_t1 GROUP BY c18, c19, c6, c7 ORDER BY 1,2,3,4,5;

--------------------------InfluxDB query for bug 54-------------------------------
-- Testcase 41:
SELECT array_agg(c4-c3-c3), array_agg(c3/c4*c3), array_agg((c3+c3/c4)*-1000), array_agg(c3*c4-c3), array_agg((c4-c4+c3)+9999999999999.998) from t7 GROUP BY c3, c4 ORDER BY 1, 2, 3, 4, 5;
-- Testcase 42:
SELECT avg(c3-c3-c4)-0.567-avg(c4/3+c3)+17.55435, avg(c4+c3/(c3+45))- -9.5+2*avg(c3), avg(c3/(c3-10.2)*c3)+0.567+avg(c4)*4.5+c3, avg(c4+c4/(c3+5.6))+100-c4 from t7 WHERE c2<='$' AND c3<>-5 AND c4<>10.746  GROUP BY c3, c4 ORDER BY 1,2,3,4 limit 5;
-- Testcase 43:
SELECT bool_and(c1 <> 10) AND true, bool_and(c2 != 'aghsjfh'), bool_and(c3+c4 <=5.5) OR false from t1 ORDER BY 1,2,3;
-- Testcase 44:
SELECT bool_or(c1 <> 10) AND true, bool_or(c2 != 'aghsjfh'), bool_or(c3+c4 <=5.5) OR false from t1 ORDER BY 1,2,3;
-- Testcase 45:
SELECT bit_and(c4/3*c3)-1 + bit_and(c3/4/(c4+6)),2* bit_and(c4-c3+c3)*1, 5-bit_and(c4+c3-c3)-1000000+c3  from t1 WHERE c2<='$' AND c3<>-5 AND c4<>10.746 GROUP BY C3 ORDER BY 1,2,3;
-- Testcase 46:
SELECT bit_or(c4/3*c3)-1 + bit_or(c3/4/(c4+6)),2* bit_or(c4-c3+c3)*1, 5-bit_or(c4+c3-c3)-1000000+c3  from t1 WHERE c2<='$' AND c3<>-5 AND c4<>10.746 GROUP BY C3 ORDER BY 1,2,3;
-- Testcase 47:
SELECT count(*)-5.6, 2*count(*), 10.2/count(*)+count(*)-c3 from t1 WHERE c4>0.774 OR c2 = 'Which started out as a kind' GROUP BY c3 ORDER BY 1, 2, 3;
-- Testcase 48:
SELECT count(c1)+count(c2)-2*count(c3), count(c4)/count(c5)-c3 from t1 GROUP BY c5, c3 order by 1, 2 limit 1;
-- Testcase 49:
SELECT every(c1 != 5.5) AND true, every(c4 <> 10) OR every(c3 > 5.6), every(c4 <= 2) OR c5 from t1 GROUP BY c5 ORDER BY 1,2,3 limit 6;
-- Testcase 50:
SELECT stddev(c3*3-c3)*1000000-c3, stddev(c3)-0.567, stddev(c4/(c3-1.3))/6, stddev(c3+4*c3)*100, stddev(c3+c4/(c4-52.1))+1 from t1 WHERE c4<0 GROUP BY c3 ORDER BY 1,2,3,4,5 ;
-- Testcase 51:
SELECT sum(c3+c4-c3)-6, sum(c3/(c4+9999999)-c3)*9999999999999.998, sum(c4-c4/(c4+111111))*-9.5, sum(c4-c3-c3)/17.55435, sum(c4+c3+c3)*6 from t1;
-- Testcase 52:
SELECT sum(c4-c3)-6+sum(c3), sum(c3*1.3-c3)*9.998-sum(c4)*4, sum(c4-c4/4)*-9.5-c4, sum(c4-c3-c3)/17.55435+c3, sum(c4+c3+c3)*6-c3-c4 from t1 GROUP BY c3, c4 ORDER BY 1,2,3,4,5;
-- Testcase 53:
SELECT max(c1), max(c3)+c3-1, max(c4+c3)-c4-3, max(c3)+max(c4) from t1 WHERE c1>= 0 GROUP BY c3, c4 ORDER BY 1,2,3,4;
-- Testcase 54:
SELECT min(c2), min(c3)+c3-1, min(c4+c3)-c4-3, min(c3)+min(c4) from t1 WHERE c1<0 GROUP BY c3, c4 ORDER BY 1,2,3,4;
-- Testcase 55:
SELECT variance(c3+c4)+c3, variance(c3*3)+c4+1, variance(c4-2)+10 from t1 GROUP BY c3, c4 ORDER BY 1,2,3;
-- Testcase 56:
SELECT sqrt(abs(c3*5)) + sqrt(abs(c4+6)), sqrt(abs(c3)+5)+c3, 4*sqrt(abs(c4-100))-c4 from t1 WHERE c4<ALL (SELECT c4 FROM t7 WHERE c4>0) ORDER BY 1, 2, 3;
-- Testcase 57:
SELECT max(c3)+min(c3)+3, min(c4)-sqrt(abs(c3-45.21))+c3*2, count(*)-count(c5)+2, c5, c3 from t1 GROUP BY c3, c4, c5 ORDER BY 1,2,3,4;
-- Testcase 58:
SELECT variance(c4)-5*min(c4)-1, every(c5 <> true), max(c4+4.56)*3-min(c3), count(c3)-4 from t1 WHERE c3=ANY (ARRAY[1,2,3]) ORDER BY 1,2,3,4;
-- Testcase 59:
SELECT c3-30, c4-10, sum(c4)/3-c3, min(c4)+c4/4, c5 from t1 GROUP BY c3, c4, c5 ORDER BY 1,2,3,4,5;


----------------------------------mysql--------------------------------------------------------------------------------------------
-- Testcase 60:
SELECT array_agg(c15 order by c15), array_agg(c17 order by c17), array_agg(c6+c1 order by c6+c1), array_agg(c12 order by c12), array_agg(c13 order by c13), array_agg(c14 order by c14), array_agg(c18 order by c18) from t3 GROUP BY c18 order by 1,2,3,4,5,6,7;
-- Testcase 61:
SELECT avg(c8+c1*c6)*17.55435 + (count(c4/c8-c1)-1)/(sum(c4-c1*c3)+-9.5) FROM t3 GROUP BY c4 ORDER BY 1;
-- Testcase 62:
SELECT bool_and(c4+c6-c5 < 0.5), bool_or(c9/c10*c1 != 0), bool_and(c1+c1*c9 > 99) FROM t3 WHERE c9 > 20.5 GROUP BY c5, c6 ORDER BY 1;
-- Testcase 63:
SELECT bit_and(c2)+0.567 + bit_or(c1)/6, (bit_and(c3)+0.567)/(-9.5) + bit_and(c2) FROM t3 WHERE NOT EXISTS (SELECT * FROM t1 WHERE c2='abcd1234') GROUP BY c1, c6, c7 ORDER BY 1,2;
-- Testcase 64:
SELECT every(c1 != 1) AND true, every(c4 <> 10) OR every(c7 > 5.6), every(c8 <= 2) OR (c4 != 0) FROM t3 GROUP BY c5, c4 ORDER BY 1,2,3 limit 6;
-- Testcase 65:
SELECT (stddev(c5*c6/(c2+5))+(-9.5))*sum(c3/(c4+5)-c1) FROM t3 GROUP BY c5 ORDER BY 1;
-- Testcase 66:
SELECT min(c1/(c2+30.5))*1000000 + sqrt(abs(c9/(c5+100))), variance(c10+c5*c1)/6 - min(c4-c8*c10) FROM t3 GROUP BY c9, c5, c4 ORDER BY 1, 2;
-- Testcase 67:
SELECT sqrt(abs(c6/c7*c8))-3.5+sqrt(abs(c8*c5/4))*1, sqrt(abs(c4+c1*c4))*sqrt(abs(c6))+100+c6, 0.5*sqrt(abs(c6+c4*c6))-6+c4 from t3 WHERE c8<20  GROUP BY c6, c4, c7, c8, c1, c5 ORDER BY 1,2,3;
-- Testcase 68:
SELECT c22, count(c4*c6/c7) + sum(c2/c1*c1)/stddev(c5/c8+c7) FROM t3 WHERE c3=ANY (ARRAY[1,2,3]) group by c22 ORDER BY 1,2;
-- Testcase 69:
SELECT string_agg(c22, 'xxx'), count(c2*c8/(c4+200)) + sum(c2+(c1*c5))*stddev(c5*c8+c7) FROM t3 WHERE c3=ANY (ARRAY[10,11,12]) GROUP BY c22 ORDER BY 1,2;
-- Testcase 70:
SELECT c18, c24, c6*c7-sum(c8), count(*)+max(c4), min(c8)/2+min(c6)*123 from (SELECT * from t3 WHERE c3 > 100) as als_t1 GROUP BY c18, c19, c6, c7, 2 ORDER BY 1,2,3,4,5;
-- Testcase 71:
SELECT upper(c22), lower(c20), every (c18 != 'aa') AND (c1 > 20), max(c2/(c1+c6))*6 + min(c7/(c8-c5))-6 FROM t3 GROUP BY c22, c20, c1 ORDER BY 1;
-- Testcase 72:
SELECT variance(c6+c6*c8)-23.456+variance(c1), variance(c7/c6-c1)/100+c7,variance(c1+c2+c4)+1+2*c1 from t3 WHERE EXISTS (SELECT * FROM t3 WHERE c5  > 10.5)  GROUP BY c7, c1 ORDER BY 1,2,3;
-- Testcase 73:
SELECT avg(c6+c6*c8)-23.456+variance(c1), variance(c7/c6-c1)/100+c7,stddev(c1+c2+c4)+1+2*c1 from t3 WHERE EXISTS (SELECT * FROM t3 WHERE c5  > 10.5)  GROUP BY c7, c1 ORDER BY 1,2,3;
-- Testcase 74:
SELECT min(c1/(c8+0.25))/50*min(c1+c2/(c4-14.25))/1.234, min(c8-c2+c7)/(min(c1)-0.5), min(c6*c4)*100-c3, min(c1*c7/4)-94+c5/2, min(c7*c8-c9)-min(c8) from t3 GROUP BY c3, c5, c6, c7 order by 1,2,3,4,5;
-- Testcase 75:
SELECT sum(c1+c2/(c3+5.25))-min(c1+c6*(c7+30))/5, max(c2*c7+c7)*(max(c1)*2), avg(c6*c4)*100-c6, stddev(c1*c7/4)-100+c2/2, count(c7*c1 + 3)+20 from t3 GROUP BY c2, c6, c7 order by 1,2,3,4,5;
-- Testcase 76:
SELECT sqrt(abs(c1*5-c2*4)) + sqrt(abs(c5+c2)), 3*sqrt(abs(c5-c2))+max(c4) from t3 WHERE c4<ALL (SELECT c4 FROM t3 WHERE c4>0) GROUP BY c1, c2, c5 ORDER BY 1, 2;
-- Testcase 77:
SELECT c1/13*5+c2, sum(c4)*min(c4), count(c7)+c2*3.5, c8/4 from t3 WHERE EXISTS (SELECT * FROM t3 WHERE c20='In Bulgarian it is desirable') GROUP BY c1, c6, c7, c2, c8 ORDER BY 1,2,3,4;
-- Testcase 78:
SELECT variance(c1)*stddev(c2)-1, every(c20 <> 'In Bulgarian it is desirable'), max(c3+4.56)*7+sum(c3), count(c3)-5+avg(c6) from t3 WHERE c3=ANY (ARRAY[1,2,3]) ORDER BY 1,2,3,4;
-- Testcase 79:
SELECT bool_and(c2 <> -2) AND false, bool_and(c20 != 'Thequickbrownfoxjumpsoverthelazydog'), bool_and(c3+c4 <=10) OR false from t3 ORDER BY 1,2,3;

----------------------------------posgres--------------------------------------------------------------------------------------------
-- Testcase 80:
SELECT avg(c15/c31-c31 order by c15/c31-c31)-1, count(c22/c23*c13 order by c22/c23*c13)*17.55435 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 81:
SELECT count(c15-c31-c28 order by c15-c31-c28)/-9.5, stddev(c2/(c28+c13) order by c2/(c28+c13))*100, sum(c16*2 order by c16)/-9.5 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 82:
SELECT avg(c2+c31*c23 order by c2+c31*c23)+0.567, avg(c13-c29+c15 order by c13-c29+c15)/9999999999999.998, max(c13-c15*c23)-100 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 83:
SELECT max(c23/c2*c16)*17.55435 , variance(c31-c31-c28 order by c31-c31-c28)*-9.5 , sqrt(c31+1000/c2) from t9 group by c15,c8,c31,c2 ORDER BY c8,c15,c31 ;
-- Testcase 84:
SELECT upper(c8), string_agg(c8,c32), lower(c32) from t9 group by c15,c8,c31,c5,c32 ORDER BY c8,c15,c31;
-- Testcase 85:
SELECT max(c9), every(c8>'a') , min(c32) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 86:
SELECT bool_and(c5) , every(c30 <> 10) , sum(c31*c1-c13 order by c31*c1-c13)-1000000 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 87:
SELECT array_agg(c2*c23*c15), bool_and(c31*2 > 100) , every(c23/c13*c15 <> 100) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 88:
SELECT array_agg(c22*2) , avg(c2/c23-c29 order by c2/c23-c29)-9999999999999.998 , sum(c2/c30+c28 order by c2/c30+c28) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 89:
SELECT max(c23/c2*c16)*17.55435 , variance(c29-c13-c13)-1 , stddev(c13+c30+c28 order by c13+c30+c28)- -9.5 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 90:
SELECT count(*) , bit_or(c1+c15) , bit_and(c3), stddev(c15-c28-c31 order by c15-c28-c31)+9999999999999.998 from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 91:
SELECT array_agg(c22*2) , avg(c2/c23-c29 order by c2/c23-c15)+99999999999.998 , sum(c2/c30+c28 order by c2/c30+c28) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 92:
SELECT max(c9), every(c8>'a') , min(c32) from t9 WHERE c8>='b' group by c15,c8,c31 ORDER BY c8,c15,c31 ;
-- Testcase 93:
SELECT count(c15-c31-c28 order by c15-c31+c1)/-9.5, stddev(c2/(c28+c13) order by c2/(c28+c13))*100, sum(c16*2 order by c16)/-9.5 from t9 group by c15 having sum(c16*2 order by c16)/-9.5 < '01:24:12.631579';
-- Testcase 94:
SELECT max(c23/c2*c16)*17.55435 , variance(c29-c13-c13)-1 , stddev(c13+c30+c28 order by c13+c30+c28)- -9.5 from t9 group by c13,c23 having variance(c29-c13-c13)-1 < 0 AND max(c23/c2*c16)*17.55435 > '-26 years -3 mons -29 days +17:57:19.89';
-- Testcase 95:
SELECT avg(c15/c31-c31 order by c15/c31-c31)*10000, count(c22/c23*c13 order by c22/c23*c13)*17.55435 from t9 WHERE c28 IN (0, 300000) group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 96:
SELECT array_agg(c31),avg(c23)*min(c15)-max(c1), stddev(c23)*count(*)-sum(c29) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 97:
SELECT lower(c9), upper(c8), string_agg(c8,c9) from t9 group by c9,c8 having upper(c8) != 'ABCDEF' OR string_agg(c8,c9) > 'qwerty' ORDER BY 1, 2, 3;
-- Testcase 98:
SELECT bool_or(c5), every(c28 < 0) AND bool_and(c5) OR bool_or(c15<0) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 99:
SELECT stddev(c15)*count(c16)/max(c31), sum(c22)/10, avg(c1)+avg(c30)/sum(c13) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 100:
SELECT variance(c13)*avg(c28)/(max(c29)-12), count(*)*stddev(c23)-sum(c1)/(min(c15)+21) from t9 WHERE c2>=ALL (SELECT min(c2)+100 FROM t9) group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 101:
SELECT variance(c1)*sum(c30)/(min(c30)-1) , every(c1<>0 ) AND bool_and(c5), sum(c31)-variance(c13)/(stddev(c1)+88889999) from t9 WHERE c1 BETWEEN -6231 AND 0 group by c15,c8,c31 ORDER BY c8,c15,c31;
-- Testcase 102:
SELECT avg(c1)*avg(c15)/sum(c31), upper(c32), sum(c29)-avg(c15)*max(c1) from t9 WHERE c1>0 OR c2=200 group by c15,c8,c31,c32 ORDER BY c8,c15,c31,c32;
-- Testcase 103:
SELECT bit_or(c29)+sum(c15)/avg(c2), bit_and(c30)*min(c1), max(c23)/count(c29) from t9 group by c30 having bit_and(c30)*min(c1)>0;
-- Testcase 104:
SELECT every(c30 <> 100) AND bool_and(c5), min(c29)-sum(c30)*variance(c15), array_agg(c15) from t9 group by c15,c8,c31 ORDER BY c8,c15,c31;


----------------------------------tinybrace-------------------------------------------------------------------------------------------------
-- Testcase 105:
SELECT avg(c7-c5-c7 order by c7-c5-c7)*0.567, avg(c19-c18+c1 order by c19-c18+c1)+-9.5, count(c18*c5+c18)+-1000 from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 106:
SELECT count(c2/c17/c17)-9999999999999.998, sum(c1+c17/c4 order by c1+c17/c4)*6, stddev(c1+c5-c4 order by c1+c5-c4)-0.567 from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 107:
SELECT bit_and(c5), array_agg(c17*c3*c4), bit_or(c3) from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 108:
SELECT count(c4+c7+c5)+17.55435 , every(c2/(c6+c20) > 9) from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 109:
SELECT stddev(c20+c20+c7)/9999999999999.998 , max(c17/c1/c4)/0.567, sqrt(abs(c19*c3+c20)) from t5 group by c19,c3,c20,c5,c7,c18 ORDER BY c5,c7,c18,c19;
-- Testcase 110:
SELECT bit_or(c1)/sqrt(abs(c17)) , every(c19<>0) AND bit_and(c4)=0, string_agg(c13,c11) from t5 group by c5,c17,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 111:
SELECT upper(c8), string_agg(c14,c11), lower(c9) from t5 group by c8,c9,c14,c11 ORDER BY c8,c9,c14,c11;
-- Testcase 112:
SELECT string_agg(c11,c9) , max(c1*c17+c18)/6 , max(c20*c5+c1)/6 from t5 group by c5,c17,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 113:
SELECT count(c2/(c5+2222)-c18)- -1000 , max(c19*c17+c1)/6 , min(c17*c4+c18)/6 from t5 group by c5,c17,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 114:
SELECT stddev(c20+c20+c7)/9999999999999.998,  variance(c5+c6+c7)*1000000, sqrt(abs(c1/c1+c2))+-9.5from t5 group by c1,c2,c5,c17,c7,c18,c19 ORDER BY c1,c2,c5,c7,c18,c19;
-- Testcase 115:
SELECT string_agg(c14,c12), min(c8), every(c13 > 'c') from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 116:
SELECT count(c2/c17/c17)-9999999999999.998, sum(c1+c17/c4 order by c1+c17/c4)*6, stddev(c1+c5-c4 order by c1+c5-c4)-0.567 from t5 group by c2 having sum(c1+c17/c4 order by c1+c17/c4)*6 > 0;
-- Testcase 117:
SELECT count(c2/(c1+2222)-c18)- -1000 , max(c19*c17+c1)/6 , min(c17*c4+c18)/6 from t5 group by c5 having count(c2/(c5+2222)-c18)- -1000<1002 OR max(c19*c17+c1)/6<0 ORDER BY 1, 2, 3;
-- Testcase 118:
SELECT bit_or(c5)-bit_and(c2)*sqrt(abs(c18)), count(*)*min(c19)/(stddev(c1)+102) , variance(c2)+max(c1) from t5 group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 119:
SELECT avg(c5)/(bit_and(c4)+114)-sum(c20), min(c5)-stddev(c20)*bit_or(c6), sqrt(abs(c4))*min(c2)-avg(c20) from t5 WHERE c5<99  OR c2>=1000 OR c19>=213.7 group by c4,c5,c7,c18,c19 ORDER BY c4,c5,c7,c18,c19;
-- Testcase 120:
SELECT string_agg(c11,c12) like '%c' AND bool_and(c1>c2) AND bool_or(c14<c10), stddev(c1)*count(c18)-avg(c2), stddev(c1)*count(c18)+max(c19) from t5 group by c5,c7,c10,c18,c19 ORDER BY c5,c7,c10,c18,c19;
-- Testcase 121:
SELECT sqrt(abs(c17))*count(*)+stddev(c1), string_agg(c9,c12), every(c19<c20) AND bit_and(c4)=1 from t5 group by c17 having string_agg(c9,c12) like '%c%' ORDER BY 1;
-- Testcase 122:
SELECT avg(c5)/(bit_and(c4)-6688)+variance(c2), max(c7)+variance(c3)/bit_or(c5), bool_or(c6>c3) AND bool_and(c2<>c6) from t5 WHERE c4>800000 AND c13>'abcd' OR c2>1000 OR c18<>0.45 OR c12='0123456789 abcde' group by c5,c7,c18,c19 ORDER BY c5,c7,c18,c19;
-- Testcase 123:
SELECT bool_and(c6<c17) OR every(c13>'c'), min(c3)+sqrt(abs(c17))/max(c18), array_agg(c5) from t5 group by c17 having min(c3)+sqrt(abs(c17))/max(c18)<-10 ORDER BY 1, 2, 3;
-- Testcase 124:
SELECT max(c1)/(bit_or(c3)+55555)+sum(c4), bool_and(c1>c2) OR every(c19<c7), bit_and(c7)-variance(c3)/max(c1) from t5 WHERE c1 BETWEEN 0 AND 10000 group by c1,c5,c7,c18,c19 ORDER BY c1,c5,c7,c18,c19;
-- Testcase 125:
SELECT every(c19>10) OR bool_and(c4>c20), sqrt(abs(c1))+stddev(c19)-avg(c17), string_agg(c9,c14) from t5 WHERE c4 NOT IN (-40, 0) group by c1,c5,c7,c18,c19 ORDER BY c1,c5,c7,c18,c19;
-- Testcase 126:
SELECT max(c3)-bit_or(c5)+sum(c17), array_agg(c20), avg(c7)*stddev(c19)/variance(c3) from t5 WHERE c3 != 100 OR c14 <='abcd' OR c3<1000 OR c17<22.6 group by c1,c5,c7,c18,c19 ORDER BY c1,c5,c7,c18,c19;
-- Testcase 127:
SELECT avg(c17)+sqrt(abs(c19))*bit_and(c4), string_agg(c10,c14), max(c20)/min(c1)+max(c19) from t5 WHERE c14 <'c' AND c15 >'abcd' group by c1,c5,c7,c18,c19 ORDER BY c1,c5,c7,c18,c19;
-- Testcase 128:
SELECT max(c6)+count(c4)/(count(*)+1), bit_or(c7)-min(c2)-max(c1), bit_or(c1)*2 - bit_or(c1)+sum(c3) from t5 group by c1,c5,c7,c18,c19 ORDER BY c1,c5,c7,c18,c19;
-- Testcase 129:
SELECT lower(c10) like '%a', string_agg(c8,c14), sqrt(abs(c19))-sum(c17)+variance(c2) from t5 WHERE c2 IN (10, 30) group by c9,c10,c5,c7,c18,c19 ORDER BY c9,c10,c5,c7,c18,c19;


---------------------------------sqlite-------------------------------------------------------------------------------------------------------------
-- Testcase 130:
SELECT avg(c7/c17-c3 order by c7/c17-c3)*-9.5 , bit_and(c1+c3*c2), bit_or(c4-c2+c7)/9999999999999.998 from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 131:
SELECT count(*)/-6.35+999999,  count(c18*c3*c22)/0.567, every(c3-c17-c7 > 0) from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 132:
SELECT stddev(c1+c7-c2 order by c1+c7-c2)/1000000 , sum(c4-c20+c7 order by c4-c20+c7)-100, max(c3+c18-c3)+1 from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 133:
SELECT min(c17/(c22-13579)*c3)*17.55435, variance(c21/(c22+987654321)+c2)+-9.5, stddev(c4/(c1+1001002)+c18 order by c4/(c1+1001002)+c18)*9999999999999.998 from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 134:
SELECT sqrt(abs(c1+c7-c2))-100 , sqrt(abs(c2*c20/(c7+9999999999)))*0.567 , stddev(c17+c17-c19 order by c17+c17-c19)*1 from t13 group by c7,c1,c2,c3,c4,c20 ORDER BY c1,c2,c3,c4,c7,c20;
-- Testcase 135:
SELECT string_agg(c14,c11) , min(c9), sqrt(abs(c18/(c19*1)/(c19/-2)))+17.55435 , array_agg(c3) from t13 group by c1,c2,c3,c4,c18,c19 ORDER BY c1,c2,c3,c4,c18,c19;
-- Testcase 136:
SELECT bool_and(c7/c3/c19 > 0), bit_and(c7-c4*c2), every(c1*c7/c3 <> 1000) from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 137:
SELECT sqrt(abs(c20+c17-c18))-1000000, variance(c7*c18+c17)/17.55435, max(c1*c2+c21)/-1000 from t13 group by c17,c18,c20,c1,c2,c3,c4 ORDER BY c1,c2,c3,c4,c17,c18,c20;
-- Testcase 138:
SELECT variance(c22-c19/c21)/-9.5 , bit_and(c1+c4/c3)-1, avg(c2+c21*c19 order by c2+c21*c19)*9999999999999.998 from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 139:
SELECT avg(c1-c17+c22 order by c1-c17+c22)*9999999999999.998 , array_agg(c21), upper(c11), lower(c14) from t13 group by c1,c2,c3,c4,c11,c14 ORDER BY c1,c2,c3,c4,c11,c14;
-- Testcase 140:
SELECT lower(c13) , string_agg(c9,c10) , sqrt(abs(c7-c3-c7))/2 from t13 group by c1,c2,c3,c4,c7,c13 ORDER BY c1,c2,c3,c4,c7,c13;
-- Testcase 141:
SELECT bool_and(c18 > c19) AND bool_or(c20 <> 9) AND bool_and(c3 < 0), bit_and(c2)-max(c22)*min(c1), avg(c3)*variance(c4)/(sqrt(abs(c2))+1212212221) from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 142:
SELECT variance(c19)/min(c18)-sum(c19), avg(c7)*min(c22)-variance(c7), bit_and(c4)*max(c18)/min(c17) from t13 group by c1,c2,c3,c4 ORDER BY c1,c2,c3,c4;
-- Testcase 143:
SELECT string_agg(c13,c9) like 'c%', upper(c8) , lower(c14) from t13 group by c1,c2,c3,c4,c8,c9,c13,c14 ORDER BY c1,c2,c3,c4,c8,c9,c13,c14;
-- Testcase 144:
SELECT count(*)/-6.35+9988999,  count(c18*c1*c22 )/0.675498, every(c3-c17-c7 > 0) from t13 group by c3 having every(c3-c17-c7 > 0)= true;
-- Testcase 145:
SELECT string_agg(c14,c11) , min(c9), sqrt(abs(c18/(c19*1)/(c19/-2)))+17.55435 , array_agg(c3) from t13 WHERE c17<522 OR c18>=1000 OR c19<=43.73 group by c18,c19 ORDER BY c18,c19;
-- Testcase 146:
SELECT variance(c18)/min(c19)-sum(c18), avg(c7)*min(c22)-variance(c3), bit_and(c4)*max(c18)/min(c17) from t13 group by c18 having variance(c18)/min(c19)-sum(c18) > 100000 ORDER BY 1, 2, 3;
-- Testcase 147:
SELECT max(c10) like 'a%', every(c18*c7*c2 > 0) = true AND bool_and(c2<0) , avg(c7)*min(c22)/(bit_or(c1)+10) from t13 group by c2 having avg(c7)*min(c22)/(bit_or(c1)+10) <> 100000000.000 ORDER BY 1, 2, 3;
-- Testcase 148:
SELECT avg(c3)*sqrt(abs(c4))-max(c19), stddev(c7)+count(c3)-bit_or(c1), bool_or(c20 > -209) AND false OR bool_or(c3 < 9999) = false from t13 group by c4 having stddev(c7)+count(c3)-bit_or(c1) < 0 ORDER BY 1, 2, 3;
-- Testcase 149:
SELECT bool_and(c18 > c17) AND bool_or(c20 <> 9) AND bool_and(c1 > 0), bit_and(c2)-max(c22)*min(c1), avg(c3)*variance(c4)/(sqrt(abs(c2))+1299912221) from t13 WHERE c20 in (0, 5870)group by c2 ORDER BY c2;
-- Testcase 150:
SELECT bit_and(c1)/count(*)+sum(c1), sqrt(abs(c20))+bit_or(c1)*max(c1), bool_and(c12 like '%c%') OR true AND every(c18 > -1000) from t13 WHERE c1=12 OR c2<127 group by c18,c20 ORDER BY c18,c20;


---------------------------------tmp_15---------------------------------------------------------------------------------------------------------------------------
-- Testcase 151:
SELECT array_agg(c3/(c3+9999)+c4) , avg(c3-c3-c4)-9999999999999.998 , bool_or(c3-c3-c4 > 0) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 152:
SELECT bit_and(c3)+-9.5/34567, count(*), every(c4*c3-c3 > c3), stddev(c4*c3*c3)*9999999999999.998 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 153:
SELECT sum(c3/(c3+1)+c4)+6 , max(c3/(c3-11)+c3)-17.55435 , variance(c4-c4+c4)*17.55435 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 154:
SELECT variance(c4*c3-c3)*-9.5 , sqrt(abs(c3-c3)+6753)+0.567, min(c4-c4-c3)/100 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 155:
SELECT string_agg(c2,c2) , variance(c4+c4+c3)-9999999999999.998, lower(c2) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 156:
SELECT stddev(c3+c3+c3)*0.567 , sum(c4*c4/(c3-1))*100, stddev(c4+c3/(c4+9))/17.55435 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 157:
SELECT stddev(c4*c4/c4)*-1000 , stddev(c3-c3-c4)/9999999999999.998, min(c4+c3*c4)/1000000 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 158:
SELECT max(c3*c3+c4)+1 , min(c4-c4*c3)*-9.5 , count(c4+c3*c3)/6 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 159:
SELECT every(c3-c4/(c3+-2) > c3), bit_and(c3+c3), bool_and(c4 <c3) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 160:
SELECT sqrt(abs(c4-c3*c3))+0.567 , bool_and(c3 < c4), variance(c4+c3+c3)/17.55435 from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 161:
SELECT avg(c4)-sqrt(abs(c3))*min(c4), bit_or(c3)*max(c4)-count(*), bit_and(c3)/count(*)+sqrt(abs(c4)) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 162:
SELECT bit_or(c3)/count(*)/(variance(c4)-6), bit_and(c3)-bit_or(c3)/(avg(c4)+5) , bit_or(c3)+sqrt(abs(c3))+variance(c4) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 163:
SELECT bit_or(c3)/count(*)/(variance(c4)+1), bit_and(c3)-bit_or(c3)/avg(c4) , bit_or(c3)+sqrt(abs(c3))+variance(c4) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 164:
SELECT bool_and(c2 like 'janfjnaukehuavklanvkmvamv%') AND every(c2 not like '%c'), max(c3)-bit_or(c3)/(avg(c3)+1), avg(c4)+stddev(c4)-min(c3) from tmp_t15 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 165:
SELECT variance(c4*c3-c3 order by c4*c3-c3)*-6779.5 , sqrt(abs(c3+c3)+6753)+0.567, min(c4+c4/(c3+-1))/100 from tmp_t15 group by c3 having sqrt(abs(c3+c3)+6753)+0.567 > -50 ORDER BY 1, 2, 3;
-- Testcase 166:
SELECT array_agg(c3/(c3+9969)+c4 ORDER BY c3/(c3+9969)+c4) , avg(c3-c3-c4)-9999999999999.998 , bool_or(c3-c3-c4 > 0) from tmp_t15 group by c3 having bool_or(c3-c3-c4 > 0) = true ORDER BY 2;
-- Testcase 167:
SELECT max(c4)*bit_and(c3)+variance(c4), variance(c4)/avg(c3)-sqrt(abs(c4)), count(*)-avg(c3)+sum(c4) from tmp_t15 WHERE c2 != 'Thequickbrownfoxjumpsoverthelazydog' AND c3%100 != 0 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 168:
SELECT sqrt(abs(c4))*stddev(c3)/(stddev(c3)+10000), variance(c3)+count(c3)+sum(c3) , variance(c3)*stddev(c4)-bit_and(c3) from tmp_t15 WHERE c3 BETWEEN -45000 AND 45000 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 169:
SELECT max(c4)/(sum(c3)+1)-bit_or(c3), sqrt(abs(c3))*min(c3)/(max(c4)-38), bool_and(c4 <> 0) AND every(c4>c3) OR bool_or(c4 < c3) from tmp_t15 WHERE EXISTS (SELECT * FROM tmp_t15 WHERE c3=123 OR time='2008-05-19 14:23:50') group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 170:
SELECT max(time), sqrt(abs(c4))/(max(c3)+3)+sqrt(abs(c4)),  max(c4)/(sum(c3)+1)-bit_or(c3) from tmp_t15 WHERE time<'2020-01-02 01:00:00' AND c3<-1000 group by c2,c3,c4 ORDER BY c2,c3,c4;
-- Testcase 171:
SELECT upper(c2) , min(time), every(c3 <> c4) from tmp_t15 WHERE NOT time!='2006-03-19 12:23:52' group by time,c2 ORDER BY time,c2;
