-- Create extension
CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION file_fdw;

-- Create server
CREATE SERVER pgspider2 FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1', port '15432');
CREATE SERVER postgresql2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', port '35432', dbname 'pgdb2');
CREATE SERVER csv FOREIGN DATA WRAPPER file_fdw;

-- Create user for authentication
CREATE USER MAPPING FOR PUBLIC SERVER postgresql2 OPTIONS (user 'test', password '1');

-- Create table from extension
CREATE FOREIGN TABLE maxdate (i date) SERVER pgspider2;
CREATE FOREIGN TABLE maxdate__postgresql2__0(i date) SERVER postgresql2 OPTIONS (table_name 'maxdate');
CREATE FOREIGN TABLE maxdate__csv__0(i date) SERVER csv OPTIONS (filename '/home/test/PGSpider/Testing/File/maxdate.csv');
