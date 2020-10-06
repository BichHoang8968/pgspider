#!/bin/bash
# script to checkout and install needed fdw

./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_File_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_File_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_File_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_File_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_GridDB_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_GridDB_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_GridDB_AllARG_1.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_GridDB_AllARG_1.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_GridDB_AllARG_2.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_GridDB_AllARG_2.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_GridDB_AllARG_3.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_GridDB_AllARG_3.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_GridDB_AllARG_4.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_GridDB_AllARG_4.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_InfluxDB_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_InfluxDB_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_InfluxDB_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_InfluxDB_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_MySQL_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_MySQL_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_MySQL_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_MySQL_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_PostgreSQL_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_PostgreSQL_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_PostgreSQL_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_PostgreSQL_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_SQLite_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_SQLite_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_SQLite_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_SQLite_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_TinyBrace_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_TinyBrace_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_TinyBrace_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_TinyBrace_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_tmp_t15_4ARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_tmp_t15_4ARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_tmp_t15_AllARG.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_tmp_t15_AllARG.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature1_t_max_range.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature1_t_max_range.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature2_JOIN_Multi_Tbl.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature2_JOIN_Multi_Tbl.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature2_SELECT_Muli_Tbl.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature2_SELECT_Muli_Tbl.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature2_UNION_Multi_Tbl.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature2_UNION_Multi_Tbl.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature_Additional_Test.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature_Additional_Test.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature_ComplexCommand.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature_ComplexCommand.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature_For_Bug_54.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature_For_Bug_54.sql.txt 2>&1
./psql -p 4101 -d pgspider -a < /home/tsdv/SVN/20A/tests/basic/sql/BasicFeature_For_Bug_60.sql > /home/tsdv/SVN/20A/tests/basic/results/BasicFeature_For_Bug_60.sql.txt 2>&1