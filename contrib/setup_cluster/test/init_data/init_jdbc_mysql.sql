DROP DATABASE IF EXISTS test_setclusterjdbc;
CREATE DATABASE test_setclusterjdbc;
USE test_setclusterjdbc;
SET time_zone ='+00:00';

DROP TABLE IF EXISTS tbl_jdbcmysql;

CREATE TABLE tbl_jdbcmysql (c1 text, c2 bigint, c3 float8);
INSERT INTO tbl_jdbcmysql VALUES ('my1', 4352, 2563.54);
INSERT INTO tbl_jdbcmysql VALUES ('my2', 57672, -9563.21514);
INSERT INTO tbl_jdbcmysql VALUES ('友達と会う my3', 942322, 443.87);
INSERT INTO tbl_jdbcmysql VALUES ('simple my 4', -9322, 963.8);
INSERT INTO tbl_jdbcmysql VALUES ('nothing my5', 4839, 97.2);
INSERT INTO tbl_jdbcmysql VALUES ('my6', -4892, 7442.8);
INSERT INTO tbl_jdbcmysql VALUES ('ごきげんよう my7', 8124, 5653.884);
INSERT INTO tbl_jdbcmysql VALUES ('сковорода my8', 75, -763.5465);
INSERT INTO tbl_jdbcmysql VALUES ('ハンサム my9', 1095, 434.20);
INSERT INTO tbl_jdbcmysql VALUES ('MalaysiaNY my10', 1645, 2343.9);