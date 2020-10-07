------------------------------Node_Location_IN_clause_PGSpider2-----------------------------
-- Testcase 1:
SELECT * FROM t3 IN ('/mysql1') ORDER BY t3.* ASC;
-- Testcase 2:
SELECT * FROM t3 IN ('/tinybrace1') ORDER BY t3.* ASC;
-- Testcase 3:
SELECT * FROM t3 IN ('/tinybrace1', '/tinybrace2') ORDER BY t3.* ASC;
-- Testcase 4:
SELECT * FROM t3 IN ('/mysql1', '/tinybrace1') ORDER BY t3.* ASC;
-- Testcase 5:
SELECT * FROM t3 IN ('/grid1', '/influx1') ORDER BY t3.* ASC;
-- Testcase 6:
SELECT * FROM tmp_t15 IN ('/mysql1') ORDER BY tmp_t15.* ASC;
-- Testcase 7:
SELECT * FROM tmp_t15 IN ('/tinybrace1') ORDER BY tmp_t15.* ASC;
-- Testcase 8:
SELECT * FROM tmp_t15 IN ('/tinybrace1', '/tinybrace2') ORDER BY tmp_t15.* ASC;
-- Testcase 9:
SELECT * FROM tmp_t15 IN ('/mysql1', '/tinybrace1') ORDER BY tmp_t15.* ASC;
-- Testcase 10:
SELECT * FROM tmp_t15 IN ('/grid1', '/influx1') ORDER BY tmp_t15.* ASC;
