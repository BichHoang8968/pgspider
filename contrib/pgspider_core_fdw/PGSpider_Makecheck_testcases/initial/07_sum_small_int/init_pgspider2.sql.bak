-- Create extension
CREATE EXTENSION spd_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION file_fdw;

-- Create server
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER spd_fdw OPTIONS (host '127.0.0.1', port '15432');
CREATE SERVER postgresql2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '35432', dbname 'pgdb2');
CREATE SERVER csv FOREIGN DATA WRAPPER file_fdw;

-- Create user for authentication
CREATE USER MAPPING FOR PUBLIC SERVER postgresql2 OPTIONS (user 'test', password '1');

-- Create table from extension
CREATE FOREIGN TABLE sumsmallint (i smallint) SERVER pgspider2;
CREATE FOREIGN TABLE sumsmallint__postgresql2__0(i smallint) SERVER postgresql2 OPTIONS (table_name 'sumsmallint');
CREATE FOREIGN TABLE sumsmallint__csv__0(i smallint) SERVER csv OPTIONS (filename '/home/test/PGSpider/Testing/File/sumsmallint.csv');
