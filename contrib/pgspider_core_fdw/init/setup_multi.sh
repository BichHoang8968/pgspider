PGS1_DIR=/home/jenkins/PGSpider/PGS1/
PGS1_PORT=5433
PGS2_DIR=/home/jenkins/PGSpider/PGS2/
PGS2_PORT=5434
DB_NAME=postgres
GRIDDB_CLIENT=/home/jenkins/GridDB/c_client_4.1.0/griddb

/usr/local/tinybrace/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=test.db < tiny.dat

rm -rf /tmp/pgtest.csv
cp pgtest.csv /tmp/

rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite.dat

# SET PASSWORD = PASSWORD('mysql')
mysql -uroot -pMysql_1234 < mysql.dat

influx -import -path=./influx.data -precision=ns

# postgres should be already started with port=15432
# pg_ctl -o "-p 15432" start -D data

psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
psql postgres -p 15432  -U postgres < post.dat

# setup for GridDB
cp -a griddb*.data /tmp/
cp -a $GRIDDB_CLIENT ./
gcc griddb_init.c -o griddb_init -Igriddb/client/c/include -Lgriddb/bin -lgridstore
./griddb_init 239.0.0.1 31999 ktymCluster admin testadmin

$PGS1_DIR/bin/psql -p $PGS1_PORT $DB_NAME < pgspider1.dat
$PGS2_DIR/bin/psql -p $PGS2_PORT $DB_NAME < pgspider2.dat
