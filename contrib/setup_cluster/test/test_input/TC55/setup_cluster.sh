$PGS1_DIR/bin/psql -d pgspider -p $PGS1_PORT -c "drop server db2 cascade;"
$PGS1_DIR/bin/psql -d pgspider -p $PGS1_PORT -c "CREATE EXTENSION postgres_fdw;"
$PGS1_DIR/bin/psql -d pgspider -p $PGS1_PORT -c "CREATE SERVER db2 FOREIGN DATA WRAPPER potgres_fdw OPTIONS (host '127.0.0.1', port '15444');"
$PGS1_DIR/bin/psql -d pgspider -p $PGS1_PORT -c "CREATE FOREIGN TABLE tbl_postgre__db2_1__0 (c1 text, c2 bigint, c3 float8, __spd_url text) SERVER db2 OPTIONS (table_name 'tbl_postgre');"

./setup_cluster