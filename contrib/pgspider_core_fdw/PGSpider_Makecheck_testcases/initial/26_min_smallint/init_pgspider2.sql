-- Create extension
CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION file_fdw;

-- Create server
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1', port '15432');
CREATE SERVER postgresql2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '35432', dbname 'pgdb2');
CREATE SERVER csv FOREIGN DATA WRAPPER file_fdw;

-- Create user for authentication
CREATE USER MAPPING for public SERVER postgresql2 OPTIONS (user 'tamtv', password '1');

-- Create table from extension
CREATE FOREIGN TABLE minsmallint (i smallint) SERVER pgspider2;
CREATE FOREIGN TABLE minsmallint__postgresql2__0 (i smallint) SERVER postgresql2 OPTIONS (table_name 'minsmallint');
CREATE FOREIGN TABLE minsmallint__csv__0 (i smallint) SERVER csv OPTIONS (filename '/tmp/minsmallint.csv', format 'csv');
