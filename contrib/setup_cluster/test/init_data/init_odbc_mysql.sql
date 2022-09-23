DROP DATABASE IF EXISTS test_setclusterodbc;
CREATE DATABASE test_setclusterodbc;
USE test_setclusterodbc;
SET time_zone ='+00:00';

DROP TABLE IF EXISTS tbl_odbcmysql;

CREATE TABLE tbl_odbcmysql (c1 text, c2 bigint, c3 float8);
INSERT INTO tbl_odbcmysql VALUES ('my1', 4352, 2563.54);
INSERT INTO tbl_odbcmysql VALUES ('my2', 57672, -9563.21514);
INSERT INTO tbl_odbcmysql VALUES ('友達と会う my3', 942322, 443.87);
INSERT INTO tbl_odbcmysql VALUES ('simple my 4', -9322, 963.8);
INSERT INTO tbl_odbcmysql VALUES ('nothing my5', 4839, 97.2);
INSERT INTO tbl_odbcmysql VALUES ('my6', -4892, 7442.8);
INSERT INTO tbl_odbcmysql VALUES ('ごきげんよう my7', 8124, 5653.884);
INSERT INTO tbl_odbcmysql VALUES ('сковорода my8', 75, -763.5465);
INSERT INTO tbl_odbcmysql VALUES ('ハンサム my9', 1095, 434.20);
INSERT INTO tbl_odbcmysql VALUES ('MalaysiaNY my10', 1645, 2343.9);