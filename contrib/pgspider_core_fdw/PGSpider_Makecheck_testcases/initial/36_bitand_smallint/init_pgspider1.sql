-- Create extension
CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION sqlite_fdw;

-- Create server
CREATE SERVER pgspider1 FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1', port '5432');
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '15432', dbname 'pgsdb2');
CREATE SERVER postgresql1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '25432', dbname 'pgdb1');
CREATE SERVER sqlite FOREIGN DATA WRAPPER sqlite_fdw (database '/tmp/sqlite.db');

-- Create user for authentication
CREATE USER MAPPING for public SERVER postgresql1 OPTIONS (user 'tamtv', password '1');
CREATE USER MAPPING for public SERVER pgspider2 OPTIONS (user 'tamtv', password '1');

-- Create table from extension
CREATE FOREIGN TABLE bitandsmallint (i smallint) SERVER pgspider1;
CREATE FOREIGN TABLE bitandsmallint__pgspider2__0 (i smallint) SERVER pgspider2 OPTIONS (table_name 'bitandsmallint');
CREATE FOREIGN TABLE bitandsmallint__postgresql1__0 (i smallint) SERVER postgresql1 OPTIONS (table_name 'bitandsmallint');
CREATE FOREIGN TABLE bitandsmallint__sqlite__0 (i smallint) SERVER sqlite OPTIONS (table 'bitandsmallint');
