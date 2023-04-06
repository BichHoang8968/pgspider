-- MySQL
\set ECHO none
\set source_wrapper_name 'mysql_fdw'
\set dest_wrapper_name 'mysql_fdw'
\set source_server_opt 'host \'localhost\', port \'3306\''
\set dest_server_opt 'host \'localhost\',  port \'3306\''
\set source_usermapping_opt 'username \'root\', password \'Mysql_1234\''
\set dest_usermapping_opt 'username \'root\', password \'Mysql_1234\''
\set source_foreigntable_opt 'dbname \'sourcedb\', table_name \'TBL1\''
\set dest_foreigntable_opt 'dbname \'destdb\', table_name \'TBL2\''
\set tmp_dest_foreigntable_opt 'dbname \'destdb\', table_name \'TBL1\''
\set tablename_opt 'table_name'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
