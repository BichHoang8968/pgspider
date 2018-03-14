rm test.db
sqlite3 test.db < sql/init.sql
make clean && make && make install && make installcheck
