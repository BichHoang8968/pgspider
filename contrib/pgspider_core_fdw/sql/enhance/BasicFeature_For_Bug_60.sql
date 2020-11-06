------------------------------Change time setting-----------------------------
SET datestyle TO "ISO, YMD";
SET timezone TO +00;
SET intervalstyle to "postgres";
---------------------File query for bug 60---------------------
--Testcase 1:
SELECT count(*), sum(c1) from tmp_t11 GROUP BY c1 HAVING avg(c1+10)>-2 AND avg(c1)*2+100 < 100  ORDER BY 1,2;
--Testcase 2:
SELECT count(c3), max(c22) from tmp_t11 GROUP BY c4 HAVING bool_and(c4)=true AND bool_and(c1*2>10)=false ORDER BY 1,2;
--Testcase 3:
SELECT count(c3), max(c22) from tmp_t11 GROUP BY c14 HAVING bool_or(c1/(c14+10)<0)!=true AND bool_or(c1!=0)=true ORDER BY 1,2;
--Testcase 4:
SELECT min(c27), max(c22) from tmp_t11 GROUP BY c14 HAVING bit_or(c1+c14)<0 OR bit_or(c28)>7 ORDER BY 1,2;
--Testcase 5:
SELECT min(c27), max(c22) from tmp_t11 GROUP BY c29 HAVING count(c9)=4 OR max(c1)=0 ORDER BY 1,2;
--Testcase 6:
SELECT count(c26), max(c22) from tmp_t11 GROUP BY c1 HAVING count(c9)!=2 ORDER BY 1,2;
--Testcase 7:
SELECT count(c26), max(c22) from tmp_t11 GROUP BY c1 HAVING every(c1>0)=true AND every(c14<c28)=false AND every(c12*20<c27+100)=false ORDER BY 1,2;
--Testcase 8:
SELECT min(c21), max(c27) from tmp_t11 GROUP BY c27 HAVING stddev(c12*c22-c14/50)!=0 AND stddev(c14+c12/(c27+0.567)) < 10000 AND stddev(c22-c28-c14+99.998) > 1000 ORDER BY 1,2;
--Testcase 9:
SELECT min(c22), max(c27) from tmp_t11 GROUP BY c4 HAVING sum(c1)%2=0 AND (sum(c1*2+c14/2)-10)<-5000 AND sum(c14+c28)>-100000 ORDER BY 1,2;
--Testcase 10:
SELECT max(c1), sum(c14) from tmp_t11 GROUP BY c27 HAVING max(c1/(c1-23.4)*c14)>100 OR (max(c14-c22*c27)-0.567-max(c22)*2)<-1330275991 OR (max(c14*2-10)+max(c1))=10 ORDER BY 1,2;
--Testcase 11:
SELECT max(c1), min(c14) from tmp_t11 GROUP BY c2 HAVING (min(c14-c27*c12)+100+min(c1)*10)>100 OR (min(c28*2-c14)*2+100) IN (100,-15902,152, 44090,-39908) ORDER BY 1,2;
--Testcase 12:
SELECT count(c1), sum(c14) from tmp_t11 GROUP BY c3 HAVING (variance(c1+c14)/6+variance(c1))!=0 AND (variance(c27/(c1-2.566)))>1000 AND variance(c14*3)/1000 < 1000 ORDER BY 1, 2;
--Testcase 13:
SELECT max(c27), sum(c14) from tmp_t11 GROUP BY c1, c14 HAVING sqrt(abs(c1*c14))+100 < 110 OR sqrt(abs(c1))<5 ORDER BY 1,2;
--Testcase 14:
SELECT max(c27), sum(c14) from tmp_t11 GROUP BY c3 HAVING bool_and(c4 <> true)=true AND bool_and(c22 >= 10000)=true OR bool_and(c1 <> 1)=false ORDER BY 1, 2;
--Testcase 15:
SELECT min(c27), avg(c14) from tmp_t11 GROUP BY c3 HAVING bool_or(c12>0.1123)!=false AND bit_and((c1-1))<0 AND (variance(c14)*sum(c22)+stddev(c22)+10)<20 AND (max(c22)-avg(c1))>0 ORDER BY 1, 2;
--Testcase 16:
SELECT min(c27), avg(c14) from tmp_t11 GROUP BY c3 HAVING (max(c27)/min(c14)/2)>0 AND (min(c1)-avg(c12)* sum(c1*2))>200 AND max(c8) != 'kwikdikwik' AND (count(*)*10* max(c1-100))<-1980 AND (variance (c1/2) + min(c1))<300 ORDER BY 1, 2;
--Testcase 17:
SELECT min(c27), max(c14), c12 from tmp_t11 GROUP BY c1, c12 HAVING (stddev(c14)+10* sqrt(abs(c12)))<100 AND (sum(c1)+sum(c12)-sum(c14))<10000 AND c1/2!=3 AND NOT c12/10-5 > 10 ORDER BY 1, 2, 3;
--Testcase 18:
SELECT c4, c6, c12*10-5, c30, c31, c27/sum(c1+10) from  tmp_t11 GROUP BY c1, c4, c6, c12, c30, c27, c31 HAVING c1<c27 AND c27/sum(c1+10)>10 OR c4=(c12>c27) ORDER BY 1, 2, 3, 4, 5, 6;
--Testcase 19:
SELECT min(c27), avg(c14) from tmp_t11 GROUP BY c3 HAVING min(c1*5)<>-5 AND (max(c14)+10)<>10 AND count(c3)>1 AND avg(c28+c1*2)<>23.0 AND stddev(c28)<6000 AND sum(c22)<>2000 AND bit_and(c1+c28)!=1 ORDER BY 1, 2;
--Testcase 20:
SELECT c6,c2,c11,c32,c33 from tmp_t11 GROUP BY c6,c2,c11,c32,c33 HAVING c6=E'\\x706f6c6b6a6975797470' OR c2=B'1010110101' OR c11='1022-02-01' OR c32='2014-10-19 10:23:54' OR c33='2008-10-19 08:23:54+00' ORDER BY 1,2,3,4,5;
--Testcase 21:
SELECT max(c28), c1 FROM tmp_t11 GROUP BY c1 HAVING bit_or(c2)=B'1010110001' OR bit_and(c3)<>B'01101' ORDER BY 1,2;
--Testcase 22:
SELECT c3, count(c2), min(c33) FROM tmp_t11 GROUP BY c3 HAVING avg(c28)=3000.0 OR avg(c28)=-145.5 OR stddev(c22)<>0.0 AND max(c32) <> '2017-10-19 10:23:54' ORDER BY 1,2,3;

------------------------GridDB query for bug 60-----------------------------
--Testcase 23:
SELECT max(c1), count(c9) FROM t1 GROUP BY c13 HAVING (avg(c6*c1-c3)+17.55435 - avg(c4))>0 AND (avg(c6+c7)-10*avg(c4))>-20 AND (avg(c7+c4)-10000+avg(c1+c6)+1)<10 AND (avg(c1+c6)+9.998)<>11.998 AND (avg(c7+c7/c7)-1000)<100 ORDER BY 1, 2;
--Testcase 24:
SELECT max(c1), count(c9) FROM t1 GROUP BY c13 HAVING bool_and(c1/(c7-c1) >= 0)=true AND NOT bool_and(c8+c4*c7 <> 10)=false AND bool_and(c4/(c1+10.25)*c4 != 0)=true AND bool_and(c1/(c7+7548)-c4 < 1)=true ORDER BY 1, 2;
--Testcase 25:
SELECT max(c1), min(c7) FROM t1 GROUP BY c13 HAVING (bool_or(c7*c8*c7*100>1) AND bool_or(c6+c6-c7 <= 1235))=true AND (bool_or(c6/(c4-c1-200)<=357.1))=true OR bool_or(c1*c6-c7 >= 0.5)=false ORDER BY 1, 2;
--Testcase 26:
SELECT min(c1), max(c7) FROM t1 GROUP BY c14 HAVING (bit_and(c1) +  bit_and(c3)*5)<>6 AND (bit_and(c4)-10 - 2* bit_and(c6)+10)<1000 AND bit_and(c6)!=0 ORDER BY 1, 2;
--Testcase 27:
SELECT min(c1), max(c7) FROM t1 GROUP BY c1 HAVING ((bit_or(c1) +  bit_or(c3)*5) BETWEEN -300 AND 300) AND bit_or(c6)<>-2 OR bit_or(c6)%2=1 ORDER BY 1, 2;
--Testcase 28:
SELECT min(c1), max(c7) FROM t1 GROUP BY c13 HAVING (count(*)-10)!=0 AND (2/count(*)+max(c1))<>1 AND (count(c1)+count(c3))<10 AND (count(*)+avg(c1))<>6.0 ORDER BY 1, 2;
--Testcase 29:
SELECT min(c1), max(c7) FROM t1 GROUP BY c7 HAVING count(c8*c1)<5 AND count(c6*c7+c6)-100 = -98 AND (count(*)+c7 BETWEEN -5 AND 50) AND count(c1-c6/(c4-20))*6 = 2*6 ORDER BY 1, 2;
--Testcase 30:
SELECT min(c1), max(c7) FROM t1 GROUP BY c13 HAVING every(c1 != 1) AND every(c4+c3 < 100) AND every(c5=true)=false OR every(c8 < (c7*c6)) ORDER BY 1, 2;
--Testcase 31:
SELECT min(c1), max(c7) FROM t1 GROUP BY c15 HAVING (stddev(c8-c1+c1)+17.55+stddev(c8+c6+c7))<1000 AND (stddev(c8-c6/(c7-1000))+100)>10 OR (stddev(c1+c6-c7)/100 BETWEEN 1 AND 5) AND (5*stddev(c1/(c7+c8))/0.567)>0 ORDER BY 1, 2;
--Testcase 32:
SELECT min(c1), max(c7) FROM t1 GROUP BY c17 HAVING (sum(c1)+-9.5)>-1000 AND (sum(c7)+avg(c1))<60 AND sum(c8*c4/4)<>0 AND (sum(c6*c1/0.457)+10+sum(c4))<>12.0 OR (7-sum(c4/(c7-2.5))-6)=1 ORDER BY 1, 2;
--Testcase 33:
SELECT count(c1), sum(c6) FROM t1 GROUP BY c8 HAVING max(c1)*2 < 10 AND (max(c8*c6)-10+0.5*c8)>-10 AND (max(c7-c1)-c8/2)>-200 AND max(c2)<>'0123456789' OR max(4)=0 ORDER BY 1, 2;
--Testcase 34:
SELECT min(c1), c6, max(c6) FROM t1 GROUP BY c6 HAVING (min(c1*c6) BETWEEN -2 AND 100) AND min(c7*2)>-100 AND ((min(c7) - max(c4)) NOT BETWEEN 0 AND 30) AND min(c8/(c1+10))>-5 ORDER BY 1, 2,3;
--Testcase 35:
SELECT min(c1), max(c8) FROM t1 GROUP BY c15 HAVING (variance(c6*c8)+variance(c1))>0 AND (variance(c4+c1*c7)-1000)<9 AND (variance(c7-c1)/100)<10 AND variance(c4)>-1 ORDER BY 1, 2;
--Testcase 36:
SELECT max(c1), min(c7) FROM t1 GROUP BY c6, c4, c7, c8, c1 HAVING (sqrt(abs(c6/c7))-c1)<>2 AND c6>c4 AND (c7+c8*c4)<300 AND (c4*2+100*c1)<>104 ORDER BY 1, 2;
--Testcase 37:
SELECT max(c1), min(c7) FROM t1 GROUP BY c13, c1 HAVING ((variance(c4)+sum(c4)-max(c1)) NOT BETWEEN 4 AND 7) AND (count(*)-min(c6))<>4 AND (sqrt(abs(c1))*sum(c4))<>0 AND (8*count(c1+c7)+c1+sqrt(abs(c1)))<>22 ORDER BY 1, 2;
--Testcase 38:
SELECT max(c1), min(c7) FROM t1 GROUP BY c6 HAVING every (c2 != '0123456789') AND (count(c6)+sum(c7)-count(*))>-50 AND length(max(c2))!=31 AND 5*min(c1)<>0 AND (max(c6)-min(c1))<>0 AND c6<>7 ORDER BY 1, 2;
--Testcase 39:
SELECT max(c1), min(c7) FROM t1 GROUP BY c1, c6, c7 HAVING (c1/2*5+c6)<1000 AND (min(c4)*count(c4))<>2 AND (max(c6)+c6*0.5) NOT IN(1.5, 4.5, 10.5) AND c7/5 != c6 ORDER BY 1, 2;
--Testcase 40:
SELECT max(c1), min(c7) FROM t1 GROUP BY c6 HAVING (c6/2+max(c4))>-5 AND (c6+sum(c6))<>0 AND (count(*)+count(c4))%2=0 AND (min(c8)/2+min(c7)*123)>-6000 ORDER BY 1, 2;
--Testcase 41:
SELECT c1, min(c7) FROM t1 GROUP BY c1 HAVING sum(c6)<>0 AND (count(*)+count(c4))=4 AND (min(c8)/2+min(c7)*100)>-900 ORDER BY 1,2;
--Testcase 42:
SELECT c2,c10, max(c9), min(c6), avg(c8) FROM t1 GROUP BY c10,c2 HAVING max(c9)='2020-01-16 01:00:00' OR min(c6)=-2 OR avg(c8)=-40.763 OR c2='0123456789' OR c10=E'\\x3030393938383737' ORDER BY 1,2,3,5,4;
--Testcase 43:
SELECT c9, max(c1), count(c2), min(c3) FROM t1 GROUP BY c9 HAVING sum(c3)=252 OR avg(c6)=-2.0 OR (min(c7)>30.774 AND  min(c7)<31) OR bit_and(c3)=20 ORDER BY 4,3,2,1;

--------------------------InfluxDB query for bug 60-------------------------------
--Testcase 44:
SELECT max(c3), min(c4) FROM t7 GROUP BY c2 HAVING (avg(c3-c4)-0.5-avg(c3))<>20.6 AND (avg(c4+c3/45)*avg(c3))<>40.624 AND (avg(c3-10.2)+10+avg(c4)*4.5)<150 AND (avg(c4)+100)<>49.768 ORDER BY 1,2;
--Testcase 45:
SELECT max(c4), min(c3) FROM t7 GROUP BY c3 HAVING bool_and(c3 <> 0) AND NOT bool_and(c2 != '0123456789') OR bool_and(c4>c3) ORDER BY 1,2;
--Testcase 46:
SELECT max(c3), min(c4) FROM t7 GROUP BY c4 HAVING bool_or(c3 > c4)=false AND bool_or(c3%2=1) AND bool_or(c3+c4<=5.5) OR every(c5=true) ORDER BY 1,2;
--Testcase 47:
SELECT max(c4), min(c3) FROM t7 GROUP BY c4 HAVING bit_and(c3)<>0 AND bit_and(c3)-avg(c4) BETWEEN -50 AND 50 ORDER BY 1,2;
--Testcase 48:
SELECT max(c3), min(c4) FROM t7 GROUP BY c2 HAVING (bit_or(c3)*2+100)>0 AND (sum(c3)+bit_or(c3))<>0 ORDER BY 1,2;
--Testcase 49:
SELECT max(c3), min(c4) FROM t7 GROUP BY c5 HAVING count(c3)-10=2 AND count(c4)+count(c2) > avg(c3) ORDER BY 1,2;
--Testcase 50:
SELECT max(c3), min(c4) FROM t7 GROUP BY c4 HAVING every(length(c2)>5) AND every(c4 <> 10) AND every(c3 > 5.6) OR every(c5=true) ORDER BY 1,2;
--Testcase 51:
SELECT max(c3), min(c4) FROM t7 GROUP BY c3 HAVING ((stddev(c3*3-c3)*1000000-c3) BETWEEN -100 AND 100) AND (stddev(c3)-0.567)<0 AND stddev(c4/(c3-1.3))/6=0 AND (stddev(c3+c4/(c4-52.1))+1)=1 ORDER BY 1,2;
--Testcase 52:
SELECT max(c3), min(c4) FROM t7 GROUP BY c2 HAVING (sum(c4-c3)-6*max(c3))>0 AND (sum(c3/(c4+99)-c3)*100)<>0 AND sum(c4-c4/(c4+11))*-9.5<2000 OR sum(c4-c3-c3)/17.55<-100 AND sum(c4+c3+c3)*6<>291.744 ORDER BY 1,2;
--Testcase 53:
SELECT max(c4), min(c3) FROM t7 GROUP BY c3 HAVING (sum(c4-c3)-6+sum(c3))<>94.376 AND sum(c3)<>0 AND (sum(c4)*sum(c3)) BETWEEN -1000 AND 1000 AND sum(c4+c3)/sum(c3+10)<>-2.82 ORDER BY 1,2;
--Testcase 54:
SELECT max(c3), min(c4) FROM t7 GROUP BY c4 HAVING max(c3)%2=0 AND (max(c4)+c4-1)<500 AND (max(c4+c3)-min(c4)-3)<>0 AND (max(c3)+max(c4))>0 ORDER BY 1,2;
--Testcase 55:
SELECT max(c3), min(c4) FROM t7 GROUP BY c3 HAVING (c3 BETWEEN -100 AND 100) AND min(c3)<>1 AND (min(c3)+c3)<>8 AND min(c4+c3)>-500 AND (min(c4)+min(c3))<>22.312 ORDER BY 1,2;
--Testcase 56:
SELECT max(c3), min(c4) FROM t7 GROUP BY c3 HAVING variance(c3)<10 AND (variance(c4)+c3) IN (3,5,4,0,-4,-1) OR c3<-3 ORDER BY 1,2;
--Testcase 57:
SELECT max(c3), min(c4) FROM t7 GROUP BY c4, c5 HAVING (sqrt(abs(c4)) BETWEEN 1 AND 4) OR (sqrt(abs(c4/10+max(c3))) BETWEEN 2 AND 5) ORDER BY 1,2;
--Testcase 58:
SELECT max(c3), min(c4) FROM t7 GROUP BY c3 HAVING (max(c4)+min(c4+c3)+3)>0 AND (min(c4)+c3*2)<>60.188 AND (count(*)-count(c2)+2)=2 ORDER BY 1,2;
--Testcase 59:
SELECT max(c3), min(c4) FROM t7 HAVING (variance(c4)-5*min(c4)-1)<10e135 AND NOT every(c5 <> true) AND (max(c4+4.56)*3-min(c3))>5e68 AND (count(c3)-4)=26 ORDER BY 1,2;
--Testcase 60:
SELECT c3,c4,c5 FROM t7 GROUP BY c3, c4, c5 HAVING (c3-30)<>-31 AND (c4-10)<>-30.56 AND ((sum(c4)/3-c3) BETWEEN 0 AND 50) OR (min(c4)+c4/4)=62.735 ORDER BY 1,2;
--Testcase 61:
SELECT c2, min(c3), max(c4) from t7 GROUP BY c2 HAVING max(time)='2020-01-10 01:00:00+00' OR min(time)='2020-01-12 01:00:00+00' OR (avg(c4)>-50 AND avg(c4)<-10) AND stddev(c3)=0 ORDER BY 1,2,3;
--Testcase 62:
SELECT c5, count(c2), max(c3) from t7 GROUP BY c5 HAVING avg(c4)>2.9e+67 AND avg(c4)<3.0e+67 AND stddev(c3)=14345702026 AND sum(c3)=-73709551634 ORDER BY 1,2,3;

----------------------------------MySQL query for bug 60--------------------------------------------------------------------------------------------
--Testcase 63:
SELECT max(c1), min(c12) FROM t3 GROUP BY c6 HAVING avg(c4)=-60.0 OR avg(c1+c2)=7.0 OR (avg(c8+c1*c6) + count(*)) BETWEEN 0 AND 200 ORDER BY 1,2;
--Testcase 64:
SELECT max(c1), min(c12) FROM t3 GROUP BY c6 HAVING bool_and(c4>0.5) AND bool_or(c7<c8) AND bool_and(c1+c1*c9>99) ORDER BY 1,2;
--Testcase 65:
SELECT max(c4), min(c8) FROM t3 GROUP BY c5 HAVING (bit_and(c2)+0.567 + bit_or(c1)/6)>0 AND ((bit_and(c3)+0.567)/(-9.5) + bit_and(c2)) BETWEEN 0 AND 10 ORDER BY 1,2;
--Testcase 66:
SELECT max(c9), min(c10) FROM t3 GROUP BY c5 HAVING every(c1 != 1) AND (every(c4 <> c3) AND every(c7 < 5.6)) AND (every(c8 <= 2) OR every(c4 != 0)) ORDER BY 1,2;
--Testcase 67:
SELECT max(c9), min(c10) FROM t3 GROUP BY c6 HAVING stddev(c5)<>0 OR ((stddev(c5*c6/(c2+5))-9.5)*sum(c3/(c4+5)-c1)) IN (-95,-19,19,57,-57,38,110) ORDER BY 1,2;
--Testcase 68:
SELECT max(c9), min(c10) FROM t3 GROUP BY c1 HAVING min(c1)<3 OR (variance(c10+c5*c1)/6 - min(c4-c8*c10))=-7483647 ORDER BY 1,2;
--Testcase 69:
SELECT max(c13), min(c12) FROM t3 GROUP BY c2,c1,c3 HAVING c1<c2 AND c2<c3 ORDER BY 1,2;
--Testcase 70:
SELECT max(c13), min(c12) FROM t3 GROUP BY c4 HAVING (count(c4*c6/10)+sum(c4))!=2 AND (stddev(c5)+avg(c7+c8))<100 ORDER BY 1,2;
--Testcase 71:
SELECT max(c13), min(c12) FROM t3 GROUP BY c5 HAVING length(string_agg(c22, ';'))>50 AND (count(c2*c8/(c4+200))+sum(c2+(c1*c5))*stddev(c5*c8+c7))<1000 OR (count(c2*c8) + sum(c2+(c1*c5))+stddev(c5*c8+c7)) IN (4, 60, 24) ORDER BY 1,2;
--Testcase 72:
SELECT max(c13), min(c12) FROM t3 GROUP BY c6 HAVING (c6+sum(c8))>-100 AND (count(*)+max(c4))<200 AND (min(c8)/2+min(c6)*123) < 5000 ORDER BY 1,2;
--Testcase 73:
SELECT max(c13), min(c12) FROM t3 GROUP BY c22, c20, c1 HAVING upper(c22) NOT LIKE 'THE%' OR every (c18 != 'aa') AND (c1 > 20) AND (max(c2/(c1+c6))*6 + min(c7/(c8-c5))-6)<0 ORDER BY 1,2;
--Testcase 74:
SELECT max(c13), min(c12) FROM t3 GROUP BY c6 HAVING (variance(c6+c6*c8)-23.456+variance(c1))<>-23.456 AND variance(c7/c6-c1)/100>0 AND (variance(c1+c2+c4)*2+1)=7.0 ORDER BY 1,2;
--Testcase 75:
SELECT max(c13), min(c12) FROM t3 GROUP BY c7, c1 HAVING (avg(c6*c8)-23+variance(c1))<>23.0 AND (variance(c7/c6-c1)/100+c7)<>0.92 AND (stddev(c1+c2+c4)+1+2*c1)<>7 ORDER BY 1,2;
--Testcase 76:
SELECT max(c9), min(c10) FROM t3 GROUP BY c3, c5, c6, c7 HAVING min(c1/(c8+0.25)) = 508 OR min(c1+c2/(c4-25))<>5 AND min(c8-c2+c7)/(min(c1)-0.5)>0 ORDER BY 1,2;
--Testcase 77:
SELECT max(c9), min(c10) FROM t3 GROUP BY c2, c6, c7 HAVING (sum(c1+c2)-min(c1+c6)/5)>-100 AND (max(c2*c7+c7)-(max(c1)*2))<100 AND (avg(c6*c4)-c6)>0 AND (stddev(c1*c7/4)-100+c2/2)<>-100 AND (count(c7*c1+3)+20)=22 ORDER BY 1,2;
--Testcase 78:
SELECT max(c8), min(c9) FROM t3 GROUP BY c1, c2, c5 HAVING (sqrt(abs(c1*5-c2*4)) + sqrt(abs(c5+c2))) > 3 AND (3*sqrt(abs(c5-c2))+max(c4))<1000 ORDER BY 1,2;
--Testcase 79:
SELECT max(c8), min(c9) FROM t3 GROUP BY c6 HAVING (sum(c4)*min(c4))<>800 AND (count(c7)+stddev(c1))>1 AND min(c9) > max(c10) ORDER BY 1,2;
--Testcase 80:
SELECT max(c8), min(c9) FROM t3 GROUP BY c6 HAVING (variance(c1)*stddev(c2)-1)=-1 AND every(c20 <> 'In Bulgarian it is desirable') AND (max(c3+4.56)*7+sum(c3))>-100 AND (count(c3)-5+avg(c6))<>-3 ORDER BY 1,2;
--Testcase 81:
SELECT max(c8), min(c9), stddev(c4) FROM t3 GROUP BY c11 HAVING bool_and(c2 <> -2) AND bool_and(c20 != 'Thequickbrownfoxjumpsoverthelazydog') AND bool_and(c3+c4 <=10)=false AND avg(c1) BETWEEN -37 and -36 AND count(*)=14 ORDER BY 1,2;
--Testcase 82:
SELECT c21, c23, c20, c18, count(*) FROM t3 GROUP BY c21, c23, c20, c18 HAVING c21=E'\\xaaa7a8a9aaabacadaeaf' OR c23=E'\\xb6f7a8a9889a65aaabacad' OR c20='0123456789' OR c18='Thequickbrownfox' ORDER BY 1,2,3,4,5;
--Testcase 83:
SELECT c6, max(c1), min(c4) FROM t3 GROUP BY c6 HAVING (bit_or(c11)=B'1' AND bit_and(c11)=B'1' AND stddev(c3)=0) OR (stddev(c3)>40 AND stddev(c3)<41) OR (stddev(c4)>40 AND stddev(c4)<41) OR (sum(c6) BETWEEN 80 AND 82) OR avg(c8)=0.921 ORDER BY 1,2;
--Testcase 84:
SELECT c6, max(c13), min(c14), c20 FROM t3 GROUP BY c6, c20 HAVING (max(c13)='04:29:57' OR max(c13)='08:09:53') OR min(c14)='2022-12-31 23:56:59' OR c20='Thequickbrownfoxjumpsoverthelazydog' OR (c6>-3.5e+20 AND c6<-3.3e+20) ORDER BY 1,2,3,4;

----------------------------------PostgreSQL query for bug 60--------------------------------------------------------------------------------------------
--Testcase 85:
SELECT c1,c2,c3 from t9 group by c1,c2,c3 having avg(c15/c31-c31) < count(c22/c23*c13) AND min(c23) < min(c15) ORDER BY c1,c2,c3;
--Testcase 86:
SELECT c2,max(c1),c4 from t9 group by c1,c2,c4 having count(c15-c31-c28)/-9.5 < stddev(c2/(c28+c13))*100 OR count(c16*2)/-9.5 > 10  ORDER BY c2,c1,c4;
--Testcase 87:
SELECT count(c3),c4,c5 from t9 group by c3,c4,c5 having avg(c2+c31*c23)+0.567 <> avg(c13-c29+c15)/9999999999999.998  ORDER BY c3,c4,c5;
--Testcase 88:
SELECT c4,c5,min(c1) from t9 group by c4,c5,c1 having variance(c31-c31-c28)*-9.5 = -0  ORDER BY c4,c5,c1;
--Testcase 89:
SELECT max(c1),c2,c3 from t9 group by c1,c2,c3 having max(c23/55*c16)/1.55435 > max(1000/c2*c16)/101000  ORDER BY c1,c2,c3; 
--Testcase 90:
SELECT max(c31),c7,c8 from t9 group by c7,c8,c31 having max(c9) >  min(c32) OR every(c8>'a') = true  ORDER BY c31,c7,c8;
--Testcase 91:
SELECT c7,c8,min(c9) from t9 group by c7,c8,c9 having bool_and(c5) = every(c30 <> 10) AND sum(c31*c1-c13)-1000000 < avg(c15)  ORDER BY c7,c8,c9;
--Testcase 92:
SELECT c7,c8,min(c9) from t9 group by c7,c8,c9 having bool_and(c5) = every(c30 <> 10) AND sum(c31*c1-c13)-1000000 < avg(c15)  ORDER BY c7,c8,c9;
--Testcase 93:
SELECT c9,c10,sum(c1) from t9 group by c1,c9,c10 having avg(c2/c23-c29)-9999999999999.998 > 999.9999 OR sum(c2/c30+c28) > 999.9999  ORDER BY c9,c10,c1;
--Testcase 94:
SELECT count(c10),c31,c12 from t9 group by c10,c12,c31 having variance(c29-c13-c13)-1 < stddev(c13+c30+c28)- -9.5  ORDER BY c10,c31,c12;
--Testcase 95:
SELECT c2,min(c12),c13 from t9 group by c2,c12,c13 having bit_and(c3) > bit_or(c3) AND stddev(c15-c28-c31) > 10   ORDER BY c2,c12,c13;
--Testcase 96:
SELECT min(c12),max(c13),c14 from t9 group by c12,c13,c14 having avg(c2/c23-c29) < avg(c23/c2) AND sum(c2/c30+c28) > 1111111  ORDER BY c12,c13,c14;
--Testcase 97:
SELECT c13,c14,sum(c15) from t9 group by c13,c14,c15 having max(c9) <> min(c32) OR every(c8>'c') = false  ORDER BY c13,c14,c15;
--Testcase 98:
SELECT c14,count(c15),min(c16) from t9 group by c1,c14,c15,c16 having sum(c16*2)/-9.5 < '01:24:12.631579' AND div(c1,2)+100000 > 10 ORDER BY c14,c15,c16;
--Testcase 99:
SELECT c15,c16,sum(c1) from t9 group by c15,c16,c1 having variance(c29-c13-c13)-1 < 0 AND max(c23/c2*c16)*17.55435 > '-26 years -3 mons -29 days +17:57:19.89' ORDER BY c15,c16,c1;
--Testcase 100:
SELECT max(c16),c1,c18 from t9 group by c16,c1,c18 having avg(c15/c31-c31)*10000 <> '-4836480000.000000000000' OR min(c31) > sum(c2)  ORDER BY c16,c1,c18;
--Testcase 101:
SELECT c1,c18,c9,c8,c9 from t9 group by c1,c2,c3,c18,c9,c8 having upper(c8) != 'ABCDEF' OR string_agg(c8,c9) > 'qwerty'  ORDER BY c1,c18,c9,c8,c9;
--Testcase 102:
SELECT c18,c29,min(c30) from t9 group by c18,c29,c30 having bit_and(c30)*min(c1)>0 AND min(c15) > sum(c2) ORDER BY c18,c29,c30;
--Testcase 103:
SELECT c9,c4,count(c3) from t9 group by c4,c9,c3 having every(c28 < 0) AND bool_and(c5) OR bool_or(c15<0)  ORDER BY c9,c4,c3;
--Testcase 104:
SELECT max(c2),count(c21),c3 from t9 group by c2,c21,c3 having variance(c1)*sum(c30)/(min(c30)-1000) = 0 AND bool_and(c5) != false  ORDER BY c2,c21,c3;
--Testcase 105:
SELECT c7, max(c22), bit_and(c4), max(c12) from t9 GROUP BY c7 HAVING c7=E'\\x41e51d3a21c321b321' OR max(c22)='-$3720368547758.08' OR bit_and(c4)=B'01010' OR max(c12)='1022-02-01' OR (max(c12) > '9998-12-31') ORDER BY 1,2,3,4;
--Testcase 106:
SELECT c1, avg(c31), stddev(c23), max(c33), min(c36) from t9 GROUP BY c1 HAVING (avg(c31)>107 AND avg(c31)<108.1 AND stddev(c23)=0) OR max(c33)='23:59:58' OR (min(c36)>'2008-10-18' AND min(c36)>'2008-10-20') ORDER BY 1,2,3,4,5;
--Testcase 107:
SELECT count(c2), stddev(c2), c32, sum(c23) from t9 GROUP BY c32 HAVING (count(c3)=2 AND sum(c23)=-40000) OR stddev(c2)<>0 OR c32='Pan Cái chảo' OR c32 like 'Ireland%';

----------------------------------TinyBrace query for bug 60-------------------------------------------------------------------------------------------------
--Testcase 108:
SELECT min(c1),c2,max(c3) from t5 group by c2,c3,c1 having avg(c7-c5-c7)*0.567 > avg(c19-c18+c1)+-9.5 AND min(c1) < min(c17) ORDER BY c1,c2,c3;
--Testcase 109:
SELECT c2,sum(c3),c4 from t5 group by c2,c3,c4 having sum(c1+c17/c4)*6 = 60120.00819 AND avg(c2) < sum(c18) ORDER BY c2,c3,c4;
--Testcase 110:
SELECT min(c3),count(c4),c5 from t5 group by c3,c4,c5 having bit_and(c5) != bit_or(c3) AND avg(c2) < sum(c17) ORDER BY c3,c4,c5;
--Testcase 111:
SELECT c4,sum(c5),c6 from t5 group by c4,c5,c6 having count(c4+c7+c5)/490 < 0 OR avg(c1) > sum(c19) ORDER BY c4,c5,c6;
--Testcase 112:
SELECT c6,min(c7) from t5 group by c3,c6,c7,c19,c20 having max(c17/c1/c4)/0.567 < sqrt(abs(c19*c3+c20)) AND sum(c1) > sum(c2) ORDER BY c6,c7;
--Testcase 113:
SELECT max(c6),c7,count(c8) from t5 group by c6,c7,c8,c17 having bit_or(c1)/sqrt(abs(c17)) > 0 OR every(c19<>0) = true AND bit_and(c4)=0  ORDER BY c6,c7,c8;
--Testcase 114:
SELECT max(c7),c8,c9 from t5 group by c7,c8,c9 having upper(c8) like '%C%' AND length(string_agg(c14,c11)) < 100+1  ORDER BY c7,c8,c9;
--Testcase 115:
SELECT c8,c9,min(c10) from t5 group by c8,c9,c10 having max(c1*c17+c18)/6 < min(c20*c5+c1)  AND min(c8) <> max(c9) ORDER BY c8,c9,c10;
--Testcase 116:
SELECT count(c9),c10,c11 from t5 group by c9,c10,c11 having max(c19*c17+c1)/6 < count(c2/(c5+2222)-c18)- -1000 AND min(c17*c4+c18)/6 < count(c2/(c5+2222)-c18)- -1000  ORDER BY c9,c10,c11;
--Testcase 117:
SELECT c10,c11,max(c12) from t5 group by c10,c11,c12 having stddev(c20+c20+c7)/9999999999999.998 = 0 AND variance(c5+c6+c7)*1000000 = 0  ORDER BY c10,c11,c12;
--Testcase 118:
SELECT min(c11),c12,c13 from t5 group by c11,c12,c13 having length(string_agg(c14,c12)) > -777 OR every(c13 > 'c') = true  ORDER BY c11,c12,c13;
--Testcase 119:
SELECT c12,count(c13),max(c14) from t5 group by c12,c13,c14 having sum(c1+c17/c4)*6 > 0 AND sum(c2) < max(c19) ORDER BY c12,c13,c14;
--Testcase 120:
SELECT min(c13),c14,count(c15) from t5 group by c13,c14,c15 having count(c2/(c5+2222)-c18)- -1000<1002 OR max(c19*c17+c1)/6<0   ORDER BY c13,c14,c15;
--Testcase 121:
SELECT min(c14),c15,count(c16) from t5 group by c14,c15,c16,c18 having bit_or(c5)-bit_and(c2)*sqrt(abs(c18)) > 1.42353654747  ORDER BY c14,c15,c16;
--Testcase 122:
SELECT count(c15),c16,sum(c17) from t5 group by c15,c16,c17 having avg(c5)/(bit_and(c4)+114)-sum(c20) < min(c5)-stddev(c20)*bit_or(c6)  ORDER BY c15,c16,c17;
--Testcase 123:
SELECT c16,min(c17),c18 from t5 group by c16,c17,c18 having string_agg(c11,c12) not like '%c' AND bool_and(c1>c2) = true  ORDER BY c16,c17,c18;
--Testcase 124:
SELECT c17,c18,sum(c19) from t5 group by c17,c18,c19 having string_agg(c9,c12) like '%c%' AND sum(c17) > avg(c19) ORDER BY c17,c18,c19;
--Testcase 125:
SELECT c18,count(c19),min(c20) from t5 group by c18,c19,c20 having avg(c5)/bit_and(c4)+variance(c2) > max(c7)+variance(c3)/(bit_or(c5)+1.111999) AND bool_or(c6>c3) = true  ORDER BY c18,c19,c20;
--Testcase 126:
SELECT c19,c20,max(c21) from t5 group by c19,c20,c21,c17 having min(c3)+sqrt(abs(c17))/max(c18)<-10 AND sum(c3) > min(c18) ORDER BY c19,c20,c21;
--Testcase 127:
SELECT c20,min(c21),min(c22) from t5 group by c20,c21,c22 having bool_and(c1>c2) = true AND every(c19<c7) = true  ORDER BY c20,c21,c22;
--Testcase 128:
SELECT avg(c2), stddev(c3), sum(c4), count(c20), min(c19) from t5 GROUP BY c17 HAVING avg(c2)=30 OR (avg(c2)>-41 AND avg(c2)<-39) OR stddev(c3)<>0 OR (sum(c4)>1800000-1 AND sum(c4)<1800000+1) OR sum(c4)-1000=0 OR min(c19)<-1300000.78 ORDER BY 1,2,3,4,5;
--Testcase 129:
SELECT max(c11), min(c12), max(c22), min(c21), min(c17), c4 from t5 GROUP BY c4 HAVING max(c11)='57384724718724757' OR min(c12)='Ông ấy là nhà văn' OR (max(c22)>'3020-01-11' AND max(c22)>'3020-01-13') OR max(c22)='2521-01-19 09:10:19' OR min(c21)='7020-01-18' OR min(c17)>11000.88345 OR c4=-6000 ORDER BY 1,2,3,4,5,6;

---------------------------------SQLite query for bug 60-------------------------------------------------------------------------------------------------------------
--Testcase 130:
SELECT sum(c1),min(c2),max(c3) from t13 group by c1,c2,c3 having bit_and(c1+c3*c2) < bit_or(c4-c2+c7)/9999999999999.998 OR min(c8) < min(c11) ORDER BY c1,c2,c3;
--Testcase 131:
SELECT max(c2),c3,min(c4) from t13 group by c2,c3,c4 having count(*)/-6.35+999999 != count(c18*c3*c22)/0.567 AND every(c3-c17-c7 > 0) = false  ORDER BY c2,c3,c4;
--Testcase 132:
SELECT count(c3),c4,max(c5) from t13 group by c3,c4,c5 having stddev(c1+c7-c2) =0 AND sum(c4-c20+c7)-100 > max(c3+c18-c3)+1   ORDER BY c3,c4,c5;
--Testcase 133:
SELECT sum(c4),c5,count(c6) from t13 group by c4,c5,c6 having variance(c21/(c22+987654321)+c2)+-9.5 != stddev((c4/(c1+1001002)+c18)+c18)*9999999999999.998  ORDER BY c4,c5,c6;
--Testcase 134:
SELECT sum(c1),max(c2),max(c7) from t13 group by c1,c2,c7,c20 having sqrt(abs(c1+c7-c2))-100 <> sqrt(abs(c2*c20/(c7+9999999999)))*0.567 AND stddev(c17+c17-c19)*1 = -0  ORDER BY c2,c2,c7;
--Testcase 135:
SELECT max(c6),c7,min(c8) from t13 group by c6,c7,c8 having length(string_agg(c14,c11)) < 100 AND min(c9) like '%alibabadigiaybata'  ORDER BY c6,c7,c8;
--Testcase 136:
SELECT c7,count(c8),max(c9) from t13 group by c7,c8,c9 having bool_and(c7/c3/c19 > 0) =true AND every(c1*c7/c3 <> 1000) = true  ORDER BY c7,c8,c9;
--Testcase 137:
SELECT min(c18),max(c20) from t13 group by c9,c10,c17,c18,c20 having sqrt(abs(c20+c17-c18))-1000000 < variance(c7*c18+c17)/17.55435 AND max(c1*c2+c21)/-1000 < max(c2)  ORDER BY c18,c20;
--Testcase 138:
SELECT c9,c10,min(c11) from t13 group by c9,c10,c11 having bit_and(c1+c4/c3)-1 < avg(c2+c21*c19)*9999999999999.998 AND min(c12) < min(c13) ORDER BY c9,c10,c11;
--Testcase 139:
SELECT c10,max(c11),max(c12) from t13 group by c10,c11,c12 having avg(c1-c17+c22)*9999999999999.998 > max(c1) OR upper(c11) like '%今日はとても'  ORDER BY c10,c11,c12;
--Testcase 140:
SELECT c11,count(c12),length(c13) from t13 group by c9,c11,c12,c13 having length(string_agg(c9,c10)) > length(c9) OR lower(c13) like '%abc'  ORDER BY c11,c12,c13;
--Testcase 141:
SELECT c12,count(c13),max(c14) from t13 group by c12,c13,c14 having bool_and(c18 > c19) AND bool_or(c20 <> 9) AND bool_and(c3 < 0)  ORDER BY c12,c13,c14;
--Testcase 142:
SELECT min(c13),max(c14),length(c15) from t13 group by c13,c14,c15 having variance(c19)/min(c18)-sum(c19) < avg(c7)*min(c22)-variance(c7) AND bit_and(c4)*max(c18)/min(c17) > 1  ORDER BY c13,c14,c15;
--Testcase 143:
SELECT c14,min(c15),count(c16) from t13 group by c14,c15,c16 having  string_agg(c13,c9) like 'c%' OR min(c13) not like '%C'  ORDER BY c14,c15,c16;
--Testcase 144:
SELECT c15,c16,count(c17) from t13 group by c15,c16,c17 having every(c3-c17-c7 > 0)= true  AND avg(c17) > sum(c19) ORDER BY c15,c16,c17;
--Testcase 145:
SELECT sum(c17),count(c18) from t13 group by c16,c17,c18,c19 having length(string_agg(c14,c11)) <> 56 AND min(c1) < sqrt(abs(c18/(c19*1)/(c19/-2)))+17.55435  ORDER BY c17,c18;
--Testcase 146:
SELECT sum(c17),max(c18),c19 from t13 group by c17,c18,c19 having variance(c18)/min(c19)-sum(c18) > 100000 AND min(c19) > max(c21) ORDER BY c17,c18,c19;
--Testcase 147:
SELECT min(c18),count(c19),min(c20) from t13 group by c18,c19,c20 having avg(c7)*min(c22)/(bit_or(c1)+10) <> 100000000.000 AND max(c17) > min(c22) ORDER BY c18,c19,c20;
--Testcase 148:
SELECT c19,c20,min(c21) from t13 group by c19,c20,c21 having stddev(c7)+count(c3)-bit_or(c1) < 0 AND min(c18) > max(c22) ORDER BY c19,c20,c21;
--Testcase 149:
SELECT max(c4),min(c14),c22 from t13 group by c4,c14,c22 having avg(c3)*sqrt(abs(c4))-max(c19) > stddev(c7)+count(c3)-bit_or(c1) AND bool_or(c20 > -209) = false OR bool_or(c3 < 9999) = false  ORDER BY c4,c14,c22;
--Testcase 150:
SELECT count(c20),min(c22),max(c23) from t13 group by c20,c22,c23 having bit_and(c1)/count(*)+sum(c1) < sqrt(abs(c20))+bit_or(c1)*max(c1) AND bool_and(c12 like '%c%') = true AND every(c18 > -1000) = true  ORDER BY c20,c22,c23;
--Testcase 151:
SELECT avg(c2), stddev(c3), sum(c4), count(c20), min(c19) from t13 GROUP BY c17 HAVING avg(c2)=-128 OR avg(c2)>126 OR stddev(c3)<>0 OR sum(c4)=-777216 OR count(c20)<>2 OR (min(c19)>=-1300000.11346 AND min(c19)<=-1100000.44345) ORDER BY 1,2,3,4,5;
--Testcase 152:
SELECT max(c11), min(c12), max(c22), min(c21), min(c20), max(c23), max(c24) from t13 GROUP BY c19 HAVING max(c11)='134263625372' OR min(c12)='Hello' OR (max(c22)<60000 AND max(c22)>40000) OR min(c21)=3000 OR (min(c20)>400 AND min(c20)<800) OR max(c23)='7020-01-17' OR max(c24)='5620-01-18 08:10:23' OR max(c24)<'1620-01-16 06:10:59' ORDER BY 1,2,3,4,5,6,7;

---------------------------------tmp_t15 query for bug 60---------------------------------------------------------------------------------------------------------------------------
--Testcase 153:
SELECT c2,c3,c4 from tmp_t15 group by c2,c3,c4 having array_agg(c3/(c3+9999)+c4) = '{-549999.5457,-549999.5457}' AND bool_or(c3-c3-c4 > 0) = true ORDER BY c2,c3,c4;
--Testcase 154:
SELECT c2,max(c3),min(c4) from tmp_t15 group by c2 having bit_and(c3)+-9.5/34567 < stddev(c4*c3*c3)*9999999999999.998 AND every(c4*c3-c3 > c3) <> false  ORDER BY 1,2,3;
--Testcase 155:
SELECT time,c2,c3,c4 from tmp_t15 group by c2,c3,c4,time having sum(c3/(c3+1)+c4)+6 < max(c3/(c3-11)+c3)-17.55435 OR variance(c4-c4+c4)*17.55435 = 0 ORDER BY c2,c3,c4;
--Testcase 156:
SELECT count(c2),max(c4),c3 from tmp_t15 group by c3 having variance(c4*c3-c3)*-9.5 < min(c4-c3)/100 OR sqrt(abs(c3)+6753)+0.567 < min(c4) ORDER BY 1,2,3;
--Testcase 157:
SELECT max(c2),min(c3),c4 from tmp_t15 group by c2,c3,c4 having string_agg(c2,c2) = 'いろはにほへど　ちりぬるをわがよたれぞいろはにほへど　ちりぬるをわがよたれぞいろはにほへど　ちりぬるをわがよたれぞ' AND lower(c2) not like '%ma' ORDER BY c2,c3,c4;
--Testcase 158:
SELECT c2,c3,c4 from tmp_t15 group by c2,c3,c4 having stddev(c3+c3+c3)*0.567 = stddev(c4+c3/(c4+9))/17.55435  ORDER BY c2,c3,c4;
--Testcase 159:
SELECT c2,max(c3),min(c4) from tmp_t15 group by c2 having stddev(c4*2)*-1000 <> stddev(c3+c4)/5 ORDER BY 1,2,3;
--Testcase 160:
SELECT c2,c3,time,c4 from tmp_t15 group by c2,c3,c4,time having max(c3*c3+c4)+1 < min(c4-c4*c3)*-9.5 ORDER BY c2,c3,c4,time;
--Testcase 161:
SELECT c2,c3,c4 from tmp_t15 group by c2,c3,c4 having every(c3-c4/(c3+-2) > c3) != false AND bool_and(c4 <c3) = false ORDER BY c2,c3,c4;
--Testcase 162:
SELECT min(c2),max(c3),c4 from tmp_t15 group by c2,c3,c4 having sqrt(abs(c4-c3*c3))+0.567 > variance(c4+c3+c3)/17.55435 OR bool_and(c3 < c4) != true ORDER BY c2,c3,c4;
--Testcase 163:
SELECT c2,c3,c4 from tmp_t15 group by c2,c3,c4 having avg(c4)-sqrt(abs(c3))*min(c4) > bit_or(c3)*max(c4)-count(*) OR bit_and(c3)/count(*) < sqrt(abs(c4)) ORDER BY c2,c3,c4;
--Testcase 164:
SELECT c2,time,c3,c4 from tmp_t15 group by time,c2,c3,c4 having bit_or(c3)/count(*)/(variance(c4)-6) > bit_and(c3)-bit_or(c3)/(avg(c4)+5) AND bit_or(c3) < sqrt(abs(c3))+variance(c4) ORDER BY c2,c3,c4;
--Testcase 165:
SELECT c2,count(c3),c4 from tmp_t15 group by c2,c3,c4 having bit_or(c3)/count(*)/(variance(c4)+1) > bit_and(c3)-bit_or(c3)/avg(c4) OR bit_or(c3) < sqrt(abs(c3))+variance(c4) ORDER BY c2,c3,c4;
--Testcase 166:
SELECT c2,c3,count(c4) from tmp_t15 group by c2,c3,c4 having bool_and(c2 like 'janfjnaukehuavklanvkmvamv%') = true OR every(c2 not like '%c') AND max(c3)-bit_or(c3)/(avg(c3)+1) > avg(c4)+stddev(c4)-min(c3) ORDER BY c2,c3,c4;
--Testcase 167:
SELECT count(c2),c3,min(c4) from tmp_t15 group by c3 having sqrt(abs(c3+c3)+6753)+0.567 > 260 ORDER BY 1,2,3;
--Testcase 168:
SELECT c2,c3,time,c4 from tmp_t15 group by c2,c3,time,c4 having bool_or(c3-c3-c4 > 0) = true ORDER BY c2,c3,c4,time;
--Testcase 169:
SELECT min(c2),count(c3),c4 from tmp_t15 group by c2,c3,c4 having max(c4)*bit_and(c3)+variance(c4) > variance(c4)/(avg(c3)-1)-sqrt(abs(c4)) ORDER BY c2,c3,c4;
--Testcase 170:
SELECT c2,c3,c4 from tmp_t15 group by c2,c3,c4 having array_agg(c3/(c3+9969)+c4) = '{40000.05221}' OR variance(c3)+count(c3)+sum(c3) = variance(c3)*stddev(c4)-bit_and(c3) ORDER BY c2,c3,c4;
--Testcase 171:
SELECT c2,c3,c4,time from tmp_t15 group by time,c2,c3,c4 having min(time) > '2008-05-19 14:23:50' ORDER BY c2,c3,c4;
--Testcase 172:
SELECT c2,c3,c4,max(time) from tmp_t15 group by time,c2,c3,c4 having sqrt(abs(c4))/(max(c3)+3) < sqrt(abs(c4)) AND max(c4) > (sum(c3)+1)-bit_or(c3) ORDER BY time,c2,c3,c4;
--Testcase 173:
SELECT c2,time,c3,c4,upper(c2) from tmp_t15 group by time,c2,c3,c4,time having max(time) <> '2006-03-19 12:23:52' ORDER BY time,c2,c3,c4;
--Testcase 174:
SELECT max(c3), count(c4), min(c4) FROM tmp_t15 GROUP BY c2 HAVING max(c3)=-45000 OR min(c4) BETWEEN 0 AND 100 AND count(c2)<>6 ORDER BY 1,2,3;
--Testcase 175:
SELECT max(c4), count(c2), min(c3) FROM tmp_t15 GROUP BY c2 HAVING avg(c3)=0.0 OR avg(c3)=-250000.0 OR avg(c4)=0.58371 OR avg(c4)=35000.1 ORDER BY 1,2,3;
--Testcase 176:
SELECT max(c4), count(c2), min(c3) FROM tmp_t15 GROUP BY c4 HAVING every(c3>0) AND count(*)>1 ORDER BY 1,2,3;
--Testcase 177:
SELECT max(c4), count(c2), min(c3) FROM tmp_t15 GROUP BY c4 HAVING sum(c3)<sum(c4) OR avg(c3)<avg(c4) ORDER BY 1,2,3;
--Testcase 178:
SELECT max(c4), max(c3), count(c3) FROM tmp_t15 GROUP BY c4 HAVING sum(c3+c4)<avg(c4*2) AND max(c3)<count(c3) ORDER BY 1,2,3;
--Testcase 179:
SELECT max(c4), min(c3), count(c3) FROM tmp_t15 GROUP BY c4 HAVING max(c4)>avg(c3) AND max(c3)=min(c3) AND min(c3)<>0 AND sum(c4)<1000.5 OR avg(c3)>avg(c4) ORDER BY 1,2,3;
--Testcase 180:
SELECT max(c4), min(c3), count(c3) FROM tmp_t15 GROUP BY c2 HAVING bit_and(c3)=4906 OR variance(c3)=100 OR bit_and(c3)=0 OR bit_or(c3)=07 OR bool_and(c3>0) OR length(string_agg(c2,'a'))=107 ORDER BY 1,2,3;
--Testcase 181:
SELECT max(c4), max(c3), count(c3) FROM tmp_t15 GROUP BY c3, c4 HAVING count(*)<max(c4) AND avg(c3)<>sum(c3) AND sum(c3)>avg(c4) AND sum(c4)>sum(c3) OR max(c3)>max(c4) ORDER BY 1,2,3;
--Testcase 182:
SELECT max(c4), min(c3), count(c3) FROM tmp_t15 GROUP BY c3 HAVING (count(c3+c4)*2+c3)=70002 OR (avg(c4+c3)*5+100)=102.4652 OR (sum(c3)+sum(c4))=-130.9481 OR stddev(c3)=0 AND every(c4>c3+10)=false OR ((min(c3+c4)+avg(c4/2+100)) BETWEEN -300 AND -200) OR (max(c3)+min(c4)-sum(c3/2)+avg(c4-100))=0264.8963 AND c3%2=0 ORDER BY 1,2,3;
--Testcase 183:
SELECT max(c2), c3, min(c4), count(c4) from tmp_t15 group by c3 HAVING max(c2)='Thequickbrownfoxjumpsoverthelazydog' OR c3=-55 OR min(c4)=30000.0562 OR (max(c4) BETWEEN 0 AND 1000) OR count(c4)=3 ORDER BY 1,2,3,4;
--Testcase 184:
SELECT avg(c3), stddev(c4), sum(c3), min(c4) from tmp_t15 group by c2 HAVING (avg(c3)>181676 AND avg(c3)<348345.0) OR stddev(c4)>314126.12345 OR sum(c3)=-2405065 OR (min(c4)>0 AND min(c4)<10) ORDER BY 1,2,3,4;
