alter session set "_ORACLE_SCRIPT"=true;
create user setupcluster identified by setupcluster;
grant all privileges to setupcluster;
GRANT SELECT ANY DICTIONARY TO setupcluster;
GRANT SELECT ON V_$SESSION TO setupcluster;

conn setupcluster/setupcluster
DROP TABLE tbl_oracle;
CREATE TABLE tbl_oracle ( c1 VARCHAR(15), c2 NUMBER(10), c3 FLOAT) SEGMENT CREATION IMMEDIATE;
INSERT INTO tbl_oracle (c1,c2,c3) VALUES ('Caichao', 25452, 54562563.21514);
INSERT INTO tbl_oracle (c1,c2,c3) VALUES ('two', 1222, -2563.21514);
INSERT INTO tbl_oracle (c1,c2,c3) VALUES ('simple', -28391322, 82563.8);
INSERT INTO tbl_oracle (c1,c2,c3) VALUES ('nothing', 989839, 8657.2);
INSERT INTO tbl_oracle (c1,c2,c3) VALUES ('0YJ_gG7l000', -9892, 332.8);