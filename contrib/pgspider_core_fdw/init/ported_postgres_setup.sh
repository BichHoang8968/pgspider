command ./dropdb -p 15432 postdb
command ./createdb -p 15432 postdb
command ./psql -p 15432 postdb < prepare.txt
