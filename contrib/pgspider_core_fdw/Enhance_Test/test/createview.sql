create view view_t1 as select * from t1 where(c1 != 88);
create view view_t3 as select * from t3 where c1 != 198 or c17 != 'oop';
create view view_t5 as select * from t5 where c1 != 10 or c2 > 50;
create view view_t7 as select * from t7 where (c3 != 6789);
create view view_t9 as select * from t9 where (c5 != 't');
create view view_t11 as select * from tmp_t11 where (c29 >= 'vie');
create view view_t13 as select * from t13 where c1 <> 0 and c5 > 1;
create view view_t15 as select * from tmp_t15 where c2 != 'xyzt' and c4 != 5678;