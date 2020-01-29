# PGSpider
PGSpider is data retrieval system for distributed big data,
PGSpider code is based on PostgreSQL. We provide PostgreSQL patch.  
Usage of PGSpider is the same as PostgreSQL. You can use libpq, psql and some client.

## Features
* Multi-Tenant  
    PGSpider can view them as a single virtual table.
    User can see the table collected from tables in each data source by UNION ALL. 
    
* Parallel processing  
    Executes queries and fetches results from child nodes in parallel.  
    Expand multi-tenant table to child tables.Create new threads for each child tables to access corresponding data source.

* Pushdown   
    WHERE and Some aggregations are pushed down to child nodes.(include AVG, STDDEV and VARIANCE).

The current version can work with PostgreSQL 11.6. 

Download PostgreSQL source code.
<pre>
https://www.postgresql.org/ftp/source/v11.6/
</pre>

Decompression PostgreSQL souce code and patch.
<pre>
patch -p1 -d postgresql-11.6 < pgspider.patch
</pre>

Make and install PGSpider and extensions.
<pre>
./configure
make
sudo make install
cd contrib/pgspider_core_fdw
make 
sudo make install
</pre>

If you want to create a tree structure with three or more layers, please install pgspider_fdw.

<pre>
cd contrib/pgspider_fdw
make 
sudo make install
</pre>

PGSpider can get pallarel with some fdw.  
For example, we will create 2 different child nodes, PostgreSQL and SQLite.  
Please install PostgreSQL server and SQLite server. 

<pre>
#PostgreSQL FDW install
cd ../postgres_fdw
make 
sudo make install
#SQLite FDW install
 cd ../
git clone https://github.com/pgspider/sqlite_fdw.git
cd sqlite_fdw
make
sudo make install
</pre>

## Usage
### Start PGSpider
PGSpider binary name is same as PostgreSQL. 
Default install folder name is changed. 
<pre>
/usrl/local/pgspider
</pre>

Please execute initdb and start server with pg_ctl.
### Load extension
#### PGSpider(Parent node)
<pre>
CREATE EXTENSION pgspider_core_fdw;
</pre>

#### PostgreSQL,SQLite(Child node)
<pre>
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION sqlite_fdw;
</pre>

### Create server
#### PGSpider(Parent node)
<pre>
CREATE SERVER parent FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS
(host '127.0.0.1', port '5432');
</pre>

#### PostgreSQL(Child node)
In this example, Child PostgreSQL node IP is localhost and port  is 15432.   
SQLite node's database is /tmp/temp.db.
<pre>   
CREATE SERVER postgres_svr FOREIGN DATA WRAPPER postgres_fdw OPTIONS
(host '127.0.0.1', port '15432') ;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw OPTIONS 
(database '/tmp/temp.db');
</pre>

### Create user mapping
#### PGSpider(Parent node)
<pre>
CREATE USER MAPPING FOR CURRENT_USER SERVER parent OPTIONS(user 'user', password 'pass');
</pre>

#### PostgreSQL(Child node)
<pre>
CREATE USER MAPPING FOR CURRENT_USER SERVER postgres_svr OPTIONS(user 'user', password 'pass');
</pre>

### Create foreign table
PGSpider needs to expand Multi-Tenant table to data source tables.
Searches child node tables by name having [Multi-Tenant table name]__[data source name]__0.

#### PGSpider(Parent node)
You need to declare a column named "__spd_url" on parent table.
This column is node location in PGSpider. It allows you to know where the data is comming from node.  
In this example, we get 't1' table data from PostgreSQL node and SQLite node.
<pre>
CREATE FOREIGN TABLE t1(i int, t text, __spd_url text) SERVER parent;
</pre>

#### PostgreSQL(Child node)
<pre>
CREATE FOREIGN TABLE t1__postgres_svr__0(i int, t text) SERVER postgres_svr OPTIONS (table_name 't1');
CREATE FOREIGN TABLE t1__sqlite_svr__0(i int, t text) SERVER sqlite_svr OPTIONS (table 't1');
</pre>

### Access foregin table
<pre>
SELECT * FROM t1;
</pre>

### Access foregin table using node filter 
PGSpider returns a resultset having node name column.
You can choose getting node with 'IN' clause after TABLE clause.

<pre>
SELECT * FROM t1 IN '/postgres_svr/';
</pre>

## Tree Structure
PGSpider can get child PGSpider node data, it means PGSpider can create tree structure.   
For example, we will add Parent-Parent node to previous example.  
Parent-Parent node's child is Parent PGSpider node.

### Start parent-parent PGSpider

Create new database directory with initdb and fix port number.  
After Creating directory, start and connect Parent-Parent node.

### Load extension
#### PGSpider(Parent-Parent node)
If Child node is PGSpider, PGSpider use pgspider_fdw.

<pre>
CREATE EXTENSION pgspider_core_fdw;
CREATE EXTENSION pgspider_fdw;
</pre>

### Create server
#### PGSpider(Parent-Parent node)
<pre>
CREATE SERVER parent_parent FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS
(host '127.0.0.1', port '54321') ;
</pre>

#### PGSpider(Parent node)
<pre>
CREATE SERVER parent FOREIGN DATA WRAPPER pgspider_svr OPTIONS
(host '127.0.0.1', port '5432') ;
</pre>

### Create user mapping
#### PGSpider(Parent-Parent node)
<pre>
CREATE USER MAPPING FOR CURRENT_USER SERVER parent_parent OPTIONS(user 'user', password 'pass');
</pre>

#### PostgreSQL(Parent node)
<pre>
CREATE USER MAPPING FOR CURRENT_USER SERVER parent OPTIONS(user 'user', password 'pass');
</pre>

### Create foreign table
PGSpider use pgspider_fdw when child datasouce is PGSpider.

#### PGSpider(Parent-Parent node)
<pre>
CREATE FOREIGN TABLE t1(i int, t text, __spd_url text) SERVER parent_parent;
</pre>

#### PGSpider(Parent node)
PGSpider has node location column. 
<pre>
CREATE FOREIGN TABLE t1(i int, t text, __spd_url text) SERVER parent;
</pre>

### Access foregin table
<pre>
SELECT * FROM t1;
</pre>

## Note
When a query to foreing tables fails, you can find why it fails by seeing a query executed in PGSpider with `EXPLAIN (VERBOSE)`.

## Contributing
Opening issues and pull requests on GitHub are welcome.

## License
Copyright (c) 2020, TOSHIBA Corporation

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

See the [`LICENSE`][4] file for full details.

[4]: LICENSE