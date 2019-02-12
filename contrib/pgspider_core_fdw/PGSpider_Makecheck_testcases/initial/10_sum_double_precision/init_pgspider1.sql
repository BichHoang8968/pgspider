-- Create extension
CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION sqlite_fdw;

-- Create server
CREATE SERVER pgspider1 FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1');
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '15432', dbname 'pgsdb2');
CREATE SERVER postgresql1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '25432', dbname 'pgdb1');
CREATE SERVER sqlite FOREIGN DATA WRAPPER sqlite_fdw (database '/home/test/PGSpider/Testing/File/sqlite.db');

-- Create user for authentication
CREATE USER MAPPING FOR PUBLIC SERVER postgresql1 OPTIONS (user 'test', password '1');
CREATE USER MAPPING FOR PUBLIC SERVER pgspider2 OPTIONS (user 'test', password '1');

-- Create table from extension
CREATE FOREIGN TABLE sumdouble (i double precision) SERVER pgspider1;
CREATE FOREIGN TABLE sumdouble__postgresql1__0 (i double precision) SERVER postgresql1 OPTIONS (table_name 'sumdouble');
CREATE FOREIGN TABLE sumdouble__pgspider2__0 (i double precision) SERVER pgspider2 OPTIONS (table_name 'sumdouble');
CREATE FOREIGN TABLE sumdouble__sqlite__0 (i double precision) SERVER sqlite OPTIONS (table 'sumdouble');
