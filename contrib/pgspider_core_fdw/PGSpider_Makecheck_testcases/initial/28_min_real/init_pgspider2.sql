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
CREATE FOREIGN TABLE minreal (i real) SERVER pgspider2;
CREATE FOREIGN TABLE minreal__postgresql2__0 (i real) SERVER postgresql2 OPTIONS (table_name 'minreal');
CREATE FOREIGN TABLE minreal__csv__0 (i real) SERVER csv OPTIONS (filename '/tmp/minreal.csv', format 'csv');
