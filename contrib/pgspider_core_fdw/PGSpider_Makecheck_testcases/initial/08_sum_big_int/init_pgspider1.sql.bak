-- Create extension
CREATE EXTENSION spd_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION sqlite_fdw;

-- Create server
CREATE SERVER pgspider1 FOREIGN DATA WRAPPER spd_fdw OPTIONS (host '127.0.0.1');
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '15432', dbname 'pgsdb2');
CREATE SERVER postgresql1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '25432', dbname 'pgdb1');
CREATE SERVER sqlite FOREIGN DATA WRAPPER sqlite_fdw (database '/home/test/PGSpider/Testing/File/sqlite.db');

-- Create user for authentication
CREATE USER MAPPING FOR PUBLIC SERVER postgresql1 OPTIONS (user 'test', password '1');
CREATE USER MAPPING FOR PUBLIC SERVER pgspider2 OPTIONS (user 'test', password '1');

-- Create table from extension
CREATE FOREIGN TABLE sumbigint (i bigint) SERVER pgspider1;
CREATE FOREIGN TABLE sumbigint__postgresql1__0 (i bigint) SERVER postgresql1 OPTIONS (table_name 'sumbigint');
CREATE FOREIGN TABLE sumbigint__pgspider2__0 (i bigint) SERVER pgspider2 OPTIONS (table_name 'sumbigint');
CREATE FOREIGN TABLE sumbigint__sqlite__0 (i bigint) SERVER sqlite OPTIONS (table 'sumbigint');
