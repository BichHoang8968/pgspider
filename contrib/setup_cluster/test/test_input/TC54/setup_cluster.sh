$PGS1_DIR/bin/psql -d pgspider -p $PGS1_PORT -c "create extension postgres_fdw;"
./setup_cluster