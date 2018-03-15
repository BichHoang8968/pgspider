tinybrace Foreign Data Wrapper for PostgreSQL
=========================================

This PostgreSQL extension implements a Foreign Data Wrapper (FDW) for TinyBrace

1. Installation
---------------

To compile the TinyBrace foreign data wrapper, TinyBrace's C client library and tinybrace.h is needed.

1. To build on POSIX-compliant systems you need to ensure the `pg_config` executable is in your path when you run `make`. This executable is typically in your PostgreSQL installation's `bin` directory. For example:

    ```
    $ export PATH=/usr/local/pgsql/bin/:$PATH
    ```

2. The `tinybrace_config` must also be in the path, it resides in the tinybrace `bin` directory.

    ```
    $ export PATH=/usr/local/tinybrace/lib/:$PATH
    ```


3. Compile the code using make.

    ```
    $ make USE_PGXS=1
    ```

4.  Finally install the foreign data wrapper.

    ```
    $ make USE_PGXS=1 install
    ```

Enhancements
------------
### Read-only FDW
This version only read-only.

  * `username`: Username to use when connecting to Tinybrace.
  * `password`: Password to authenticate to the Tinybrace server with.

Usage
-----

The following parameters can be set on a Tinybrace foreign server object:

  * `host`: Address or hostname of the Tinybrace server. Defaults to `127.0.0.1`
  * `port`: Port number of the Tinybrace server. Defaults to `5100`
  * `dbname`: Name of the Tinybrace database to query.

The following parameters can be set on a Tinybrace foreign table object:
  * `table_name`: Name of the Tinybrace table, default is the same as foreign table.

The following parameters need to supplied while creating user mapping.

  * `username`: Username to use when connecting to Tinybrace.
  * `password`: Password to authenticate to the Tinybrace server with.

-- load extension first time after install

    CREATE EXTENSION tinybrace_fdw;

-- create server object

    CREATE SERVER tinybrace_server
         FOREIGN DATA WRAPPER tinybrace_fdw
         OPTIONS (host '127.0.0.1', port '5100', dbname 'test.db');

-- create user mapping

    CREATE USER MAPPING FOR postgres
	SERVER tinybrace_server
	OPTIONS (username 'foo', password 'bar');

-- create foreign table

    CREATE FOREIGN TABLE warehouse(
         warehouse_id int,
         warehouse_name text,
         warehouse_created datetime)
    SERVER tinybrace_server
         OPTIONS (table_name 'warehouse');

-- select from table

    SELECT * FROM warehouse;
