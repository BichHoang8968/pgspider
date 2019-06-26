# /usr/local/tinybrace/bin/tbcshell -id=user -pwd=testuser -server=127.0.0.1 -port=5100 -db=test.db < tiny.dat
/usr/local/tinybrace/bin/tbeshell /usr/local/tinybrace/databases/test.db < tiny.dat

cp pgtest.csv /tmp/

rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite.dat

# SET PASSWORD = PASSWORD('mysql')
mysql -uroot -pMysql_1234 < mysql.dat
 
# postgres should be already started with port=15432
# pg_ctl -o "-p 15432" start -D data

psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
psql postgres -p 15432  -U postgres < post.dat