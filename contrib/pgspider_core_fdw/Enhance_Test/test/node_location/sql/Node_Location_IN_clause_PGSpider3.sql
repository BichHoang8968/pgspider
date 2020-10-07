------------------------------Node_Location_IN_clause_PGSpider3-----------------------------
-- Testcase 1:
SELECT * FROM t9 IN ('/post1') ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 2:
SELECT * FROM t9 IN ('/post1', '/post2') ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 3:
SELECT * FROM t9 IN ('/post1', '/file1', '/sqlite1') ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 4:
SELECT * FROM t9 IN ('/file1', '/sqlite1') ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 5:
SELECT * FROM t9 IN ('/post1', '/file1') ORDER BY c1 ASC, c2 ASC, c3 ASC, c4 ASC, c5 DESC, c7 DESC, __spd_url;
-- Testcase 6:
SELECT * FROM tmp_t15 IN ('/post1') ORDER BY tmp_t15.* ASC;
-- Testcase 7:
SELECT * FROM tmp_t15 IN ('/post1', '/post2') ORDER BY tmp_t15.* ASC;
-- Testcase 8:
SELECT * FROM tmp_t15 IN ('/post1', '/file1', '/sqlite1') ORDER BY tmp_t15.* ASC;
-- Testcase 9:
SELECT * FROM tmp_t15 IN ('/file1', '/sqlite1') ORDER BY tmp_t15.* ASC;
-- Testcase 10:
SELECT * FROM tmp_t15 IN ('/post1', '/file1') ORDER BY tmp_t15.* ASC;
