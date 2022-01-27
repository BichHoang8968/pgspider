DROP DATABASE IF EXISTS test_setcluster;
CREATE DATABASE test_setcluster;
USE test_setcluster;
SET time_zone ='+00:00';

DROP TABLE IF EXISTS tbl_mysql;

CREATE TABLE tbl_mysql (c1 text, c2 bigint, c3 float8);
INSERT INTO tbl_mysql VALUES ('my1', 4352, 2563.54);
INSERT INTO tbl_mysql VALUES ('my2', 57672, -9563.21514);
INSERT INTO tbl_mysql VALUES ('友達と会う my3', 942322, 443.87);
INSERT INTO tbl_mysql VALUES ('simple my 4', -9322, 963.8);
INSERT INTO tbl_mysql VALUES ('nothing my5', 4839, 97.2);
INSERT INTO tbl_mysql VALUES ('my6', -4892, 7442.8);
INSERT INTO tbl_mysql VALUES ('ごきげんよう my7', 8124, 5653.884);
INSERT INTO tbl_mysql VALUES ('сковорода my8', 75, -763.5465);
INSERT INTO tbl_mysql VALUES ('ハンサム my9', 1095, 434.20);
INSERT INTO tbl_mysql VALUES ('MalaysiaNY my10', 1645, 2343.9);

