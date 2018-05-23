sqlite_fdw
==========

Foreign Data Wrapper for sqlite

Compilation
-----------


<pre>
make
make install
</pre>


Usage
--------

Load extension:

<pre>
CREATE EXTENSION sqlite_fdw;
</pre>

Create server with specifying SQLite database path as option:
<pre>
CREATE SERVER sqlite_server
  FOREIGN DATA WRAPPER sqlite_fdw
  OPTIONS (database '/var/lib/pgsql/test.db');
</pre>


Create foreign table:
<pre>
CREATE FOREIGN TABLE t1(a integer, b text)
  SERVER sqlite_server
  OPTIONS (table 'table_name_of_sqlite');
</pre>


<pre>
IMPORT FOREIGN SCHEMA public FROM SERVER sqlite_server INTO public;
</pre>

Now, to get the contents of the remote table, you just need to execute a SELECT query on it:

<pre>
SELECT * FROM t1;
</pre>

Test
-----------
<pre>
./init.sh
make check
</pre>
