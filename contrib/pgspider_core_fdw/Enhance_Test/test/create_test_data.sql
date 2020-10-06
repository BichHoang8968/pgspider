SET timezone TO 0;
DROP SCHEMA if EXISTS temp CASCADE;
DROP TABLE if EXISTS _sqlite_max_range, 
_sqlite_max_range__sqlite1__0, 
griddb_max_range, 
griddb_max_range__grid1__0, 
griddb_max_range__grid2__0, 
influx_max_range, 
influx_max_range__influx1__0, 
mysql_max_range, 
mysql_max_range__mysql1__0, 
post_max_range, 
post_max_range__post1__0, 
t1, 
t10, 
t10__post1__0, 
t10__post2__0, 
t13, 
t13__sqlite1__0, 
t13__sqlite2__0, 
t14, 
t14__sqlite1__0, 
t14__sqlite2__0, 
t15, 
t15__tinybrace1__0, 
t15__tinybrace2__0, 
t1__grid1__0, 
t1__grid2__0, 
t2, 
t2__grid1__0, 
t2__grid2__0, 
t2__post1__0, 
t3, 
t3__mysql1__0, 
t3__mysql2__0, 
t4, 
t4__mysql1__0, 
t4__mysql2__0, 
t5, 
t5__tinybrace1__0, 
t5__tinybrace2__0, 
t6, 
t6__tinybrace1__0, 
t6__tinybrace2__0, 
t7, 
t7__influx1__0, 
t7__influx2__0, 
t8, 
t8__influx1__0, 
t8__influx2__0, 
t9, 
t9__post1__0, 
t9__post2__0, 
tinybrace_max_range, 
tinybrace_max_range__tinybrace1__0, 
tinybrace_max_range__tinybrace2__0, 
tmp_file_max_range, 
tmp_file_max_range__file_max_range__0, 
tmp_t11, 
tmp_t11__t11_sv1__0, 
tmp_t11__t11_sv2__0, 
tmp_t12, 
tmp_t12__t12_sv1__0, 
tmp_t12__t12_sv2__0, 
tmp_t15, 
tmp_t15__grid1__0, 
tmp_t15__grid2__0, 
tmp_t15__influx1__0, 
tmp_t15__mysql1__0, 
tmp_t15__post1__0, 
tmp_t15__sqlite1__0, 
tmp_t15__t15__0, 
tmp_t15__tinybrace1__0, 
tb_influx CASCADE;

DROP EXTENSION if EXISTS postgres_fdw CASCADE;
DROP SERVER foreign_server CASCADE;

CREATE SCHEMA temp;
CREATE EXTENSION postgres_fdw;
CREATE SERVER foreign_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '4101', dbname 'pgspider');
CREATE USER MAPPING FOR public SERVER foreign_server OPTIONS (user 'tsdv', password '123456');
IMPORT FOREIGN SCHEMA public FROM SERVER foreign_server INTO temp;

CREATE TABLE t1 AS SELECT * FROM temp.t1 WITH NO DATA;
CREATE TABLE t2 AS SELECT * FROM temp.t2 WITH NO DATA;
CREATE TABLE t3 AS SELECT * FROM temp.t3 WITH NO DATA;
CREATE TABLE t4 AS SELECT * FROM temp.t4 WITH NO DATA;
CREATE TABLE t5 AS SELECT * FROM temp.t5 WITH NO DATA;
CREATE TABLE t6 AS SELECT * FROM temp.t6 WITH NO DATA;
CREATE TABLE t7 AS SELECT * FROM temp.t7 WITH NO DATA;
CREATE TABLE t8 AS SELECT * FROM temp.t8 WITH NO DATA;
CREATE TABLE t9 AS SELECT * FROM temp.t9 WITH NO DATA;
CREATE TABLE t10 AS SELECT * FROM temp.t10 WITH NO DATA;
CREATE TABLE tmp_t11 AS SELECT * FROM temp.tmp_t11 WITH NO DATA;
CREATE TABLE tmp_t12 AS SELECT * FROM temp.tmp_t12 WITH NO DATA;
CREATE TABLE t13 AS SELECT * FROM temp.t13 WITH NO DATA;
CREATE TABLE t14 AS SELECT * FROM temp.t14 WITH NO DATA;
CREATE TABLE tmp_t15 AS SELECT * FROM temp.tmp_t15 WITH NO DATA;

CREATE TABLE griddb_max_range AS SELECT * FROM temp.griddb_max_range WITH NO DATA;
CREATE TABLE influx_max_range AS SELECT * FROM temp.influx_max_range WITH NO DATA;
CREATE TABLE mysql_max_range AS SELECT * FROM temp.mysql_max_range WITH NO DATA;
CREATE TABLE post_max_range AS SELECT * FROM temp.post_max_range WITH NO DATA;
CREATE TABLE _sqlite_max_range AS SELECT * FROM temp._sqlite_max_range WITH NO DATA;
CREATE TABLE tinybrace_max_range AS SELECT * FROM temp.tinybrace_max_range WITH NO DATA;
CREATE TABLE tmp_file_max_range AS SELECT * FROM temp.tmp_file_max_range WITH NO DATA;

CREATE TABLE griddb_max_range__grid1__0 AS SELECT * FROM temp.griddb_max_range__grid1__0;
CREATE TABLE griddb_max_range__grid2__0 AS SELECT * FROM temp.griddb_max_range__grid2__0;
ALTER TABLE griddb_max_range__grid1__0 ADD COLUMN __spd_url text default '/grid1/';
ALTER TABLE griddb_max_range__grid1__0 INHERIT griddb_max_range;
ALTER TABLE griddb_max_range__grid2__0 ADD COLUMN __spd_url text default '/grid2/';
ALTER TABLE griddb_max_range__grid2__0 INHERIT griddb_max_range;

CREATE TABLE influx_max_range__influx1__0 AS SELECT * FROM temp.influx_max_range__influx1__0;
ALTER TABLE influx_max_range__influx1__0 ADD COLUMN __spd_url text default '/influx1/';
ALTER TABLE influx_max_range__influx1__0 INHERIT influx_max_range;

CREATE TABLE mysql_max_range__mysql1__0 AS SELECT * FROM temp.mysql_max_range__mysql1__0;
ALTER TABLE mysql_max_range__mysql1__0 ADD COLUMN __spd_url text default '/mysql1/';
ALTER TABLE mysql_max_range__mysql1__0 INHERIT mysql_max_range;

CREATE TABLE post_max_range__post1__0 AS SELECT * FROM temp.post_max_range__post1__0;
ALTER TABLE post_max_range__post1__0 ADD COLUMN __spd_url text default '/post1/';
ALTER TABLE post_max_range__post1__0 INHERIT post_max_range;

CREATE TABLE _sqlite_max_range__sqlite1__0 AS SELECT * FROM temp._sqlite_max_range__sqlite1__0;
ALTER TABLE _sqlite_max_range__sqlite1__0 ADD COLUMN __spd_url text default '/sqlite1/';
ALTER TABLE _sqlite_max_range__sqlite1__0 INHERIT _sqlite_max_range;

CREATE TABLE tinybrace_max_range__tinybrace1__0 AS SELECT * FROM temp.tinybrace_max_range__tinybrace1__0;
CREATE TABLE tinybrace_max_range__tinybrace2__0 AS SELECT * FROM temp.tinybrace_max_range__tinybrace2__0;
ALTER TABLE tinybrace_max_range__tinybrace1__0 ADD COLUMN __spd_url text default '/tinybrace1/';
ALTER TABLE tinybrace_max_range__tinybrace1__0 INHERIT tinybrace_max_range;
ALTER TABLE tinybrace_max_range__tinybrace2__0 ADD COLUMN __spd_url text default '/tinybrace2/';
ALTER TABLE tinybrace_max_range__tinybrace2__0 INHERIT tinybrace_max_range;

CREATE TABLE tmp_file_max_range__file_max_range__0 AS SELECT * FROM temp.tmp_file_max_range__file_max_range__0;
ALTER TABLE tmp_file_max_range__file_max_range__0 ADD COLUMN __spd_url text default '/tmp_file_max_range/';
ALTER TABLE tmp_file_max_range__file_max_range__0 INHERIT tmp_file_max_range;

CREATE TABLE t1__grid1__0 AS SELECT * FROM temp.t1__grid1__0;
CREATE TABLE t1__grid2__0 AS SELECT * FROM temp.t1__grid2__0;
ALTER TABLE t1__grid1__0 ADD COLUMN __spd_url text default '/grid1/';
ALTER TABLE t1__grid1__0 INHERIT t1;
ALTER TABLE t1__grid2__0 ADD COLUMN __spd_url text default '/grid2/';
ALTER TABLE t1__grid2__0 INHERIT t1;

CREATE TABLE t3__mysql1__0 AS SELECT * FROM temp.t3__mysql1__0;
CREATE TABLE t3__mysql2__0 AS SELECT * FROM temp.t3__mysql2__0;
ALTER TABLE t3__mysql1__0 ADD COLUMN __spd_url text default '/mysql1/';
ALTER TABLE t3__mysql1__0 INHERIT t3;
ALTER TABLE t3__mysql2__0 ADD COLUMN __spd_url text default '/mysql2/';
ALTER TABLE t3__mysql2__0 INHERIT t3;

CREATE TABLE t5__tinybrace1__0 AS SELECT * FROM temp.t5__tinybrace1__0;
CREATE TABLE t5__tinybrace2__0 AS SELECT * FROM temp.t5__tinybrace2__0;
ALTER TABLE t5__tinybrace1__0 ADD COLUMN __spd_url text default '/tinybrace1/';
ALTER TABLE t5__tinybrace1__0 INHERIT t5;
ALTER TABLE t5__tinybrace2__0 ADD COLUMN __spd_url text default '/tinybrace2/';
ALTER TABLE t5__tinybrace2__0 INHERIT t5;

CREATE TABLE t7__influx1__0 AS SELECT * FROM temp.t7__influx1__0;
CREATE TABLE t7__influx2__0 AS SELECT * FROM temp.t7__influx2__0;
ALTER TABLE t7__influx1__0 ADD COLUMN __spd_url text default '/influx1/';
ALTER TABLE t7__influx1__0 INHERIT t7;
ALTER TABLE t7__influx2__0 ADD COLUMN __spd_url text default '/influx2/';
ALTER TABLE t7__influx2__0 INHERIT t7;

CREATE TABLE t9__post1__0 AS SELECT * FROM temp.t9__post1__0;
CREATE TABLE t9__post2__0 AS SELECT * FROM temp.t9__post2__0;
ALTER TABLE t9__post1__0 ADD COLUMN __spd_url text default '/post1/';
ALTER TABLE t9__post1__0 INHERIT t9;
ALTER TABLE t9__post2__0 ADD COLUMN __spd_url text default '/post2/';
ALTER TABLE t9__post2__0 INHERIT t9;

CREATE TABLE tmp_t11__t11_sv1__0 AS SELECT * FROM temp.tmp_t11__t11_sv1__0;
CREATE TABLE tmp_t11__t11_sv2__0 AS SELECT * FROM temp.tmp_t11__t11_sv2__0;
ALTER TABLE tmp_t11__t11_sv1__0 ADD COLUMN __spd_url text default '/tmp_t11/';
ALTER TABLE tmp_t11__t11_sv1__0 INHERIT tmp_t11;
ALTER TABLE tmp_t11__t11_sv2__0 ADD COLUMN __spd_url text default '/tmp_t11/';
ALTER TABLE tmp_t11__t11_sv2__0 INHERIT tmp_t11;

CREATE TABLE t13__sqlite1__0 AS SELECT * FROM temp.t13__sqlite1__0;
CREATE TABLE t13__sqlite2__0 AS SELECT * FROM temp.t13__sqlite2__0;
ALTER TABLE t13__sqlite1__0 ADD COLUMN __spd_url text default '/sqlite1/';
ALTER TABLE t13__sqlite1__0 INHERIT t13;
ALTER TABLE t13__sqlite2__0 ADD COLUMN __spd_url text default '/sqlite2/';
ALTER TABLE t13__sqlite2__0 INHERIT t13;

CREATE TABLE tmp_t15__grid1__0 AS SELECT * FROM temp.tmp_t15__grid1__0;
CREATE TABLE tmp_t15__grid2__0 AS SELECT * FROM temp.tmp_t15__grid2__0;
ALTER TABLE tmp_t15__grid1__0 ADD COLUMN __spd_url text default '/grid1/';
ALTER TABLE tmp_t15__grid1__0 INHERIT tmp_t15;
ALTER TABLE tmp_t15__grid2__0 ADD COLUMN __spd_url text default '/grid2/';
ALTER TABLE tmp_t15__grid2__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__influx1__0 AS SELECT * FROM temp.tmp_t15__influx1__0;
ALTER TABLE tmp_t15__influx1__0 ALTER COLUMN time TYPE timestamp without time zone;
ALTER TABLE tmp_t15__influx1__0 ADD COLUMN __spd_url text default '/influx1/';
ALTER TABLE tmp_t15__influx1__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__mysql1__0 AS SELECT * FROM temp.tmp_t15__mysql1__0;
ALTER TABLE tmp_t15__mysql1__0 ADD COLUMN __spd_url text default '/mysql1/';
ALTER TABLE tmp_t15__mysql1__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__post1__0 AS SELECT * FROM temp.tmp_t15__post1__0;
ALTER TABLE tmp_t15__post1__0 ADD COLUMN __spd_url text default '/post1/';
ALTER TABLE tmp_t15__post1__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__sqlite1__0 AS SELECT * FROM temp.tmp_t15__sqlite1__0;
ALTER TABLE tmp_t15__sqlite1__0 ADD COLUMN __spd_url text default '/sqlite1/';
ALTER TABLE tmp_t15__sqlite1__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__t15__0 AS SELECT * FROM temp.tmp_t15__t15__0;
ALTER TABLE tmp_t15__t15__0 RENAME COLUMN c1 to time;
ALTER TABLE tmp_t15__t15__0 ADD COLUMN __spd_url text default '/tmp_t15/';
ALTER TABLE tmp_t15__t15__0 INHERIT tmp_t15;

CREATE TABLE tmp_t15__tinybrace1__0 AS SELECT * FROM temp.tmp_t15__tinybrace1__0;
ALTER TABLE tmp_t15__tinybrace1__0 ADD COLUMN __spd_url text default '/tinybrace1/';
ALTER TABLE tmp_t15__tinybrace1__0 INHERIT tmp_t15;

CREATE TABLE tb_influx AS SELECT * FROM temp.tb_influx;

create view view_t1 as select * from t1 where(c1 != 88);
create view view_t3 as select * from t3 where c1 != 198 or c17 != 'oop';
create view view_t5 as select * from t5 where c1 != 10 or c2 > 50;
create view view_t7 as select * from t7 where (c3 != 6789);
create view view_t9 as select * from t9 where (c5 != 't');
create view view_t11 as select * from tmp_t11 where (c29 >= 'vie');
create view view_t13 as select * from t13 where c1 <> 0 and c5 > 1;
create view view_t15 as select * from tmp_t15 where c2 != 'xyzt' and c4 != 5678;
