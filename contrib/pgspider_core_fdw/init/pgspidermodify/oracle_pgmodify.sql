conn test/test

ALTER DATABASE SET TIME_ZONE='00:00';

DROP TABLE tntbl1;
CREATE TABLE tntbl1 (c1 int, c2 smallint, c3 float, c4 float(126), c5 number(38), c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255), CONSTRAINT oracle_constraint PRIMARY KEY (c1));
INSERT INTO tntbl1 VALUES (-20, 0, 1.0, 100.0, 1000, TO_TIMESTAMP('2022-06-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TIMESTAMP '2017-08-07 12:00:00.00 +00:00', 'char array', 'varchar array');

DROP TABLE tntbl3;
CREATE TABLE tntbl3 (id_id varchar(4000), c1 int, c2 float, c3 float(126), c4 number(38));

DROP TABLE TNTBL1_2;
CREATE TABLE TNTBL1_2 (c1 int, c2 smallint, c3 float, c4 float(126), c5 number(38), c6 timestamp, c7 timestamp with time zone, c8 char(255), c9 varchar(255), CONSTRAINT oracle_constraint2 PRIMARY KEY (c1));