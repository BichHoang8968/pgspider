-- Oracle
\set ECHO none
\set source_wrapper_name 'oracle_fdw'
\set dest_wrapper_name 'postgres_fdw'
\set source_server_opt 'dbserver \'\', isolation_level \'read_committed\', nchar \'true\''
\set dest_server_opt 'host \'127.0.0.1\',  port \'15432\', dbname \'destdb\''
\set source_usermapping_opt 'user \'source_user\', password \'source_user\''
\set dest_usermapping_opt 'user \'postgres\', password \'postgres\''
\set source_foreigntable_opt 'table \'TBL1\''
\set dest_foreigntable_opt 'table_name \'TBL2\''
\set tmp_dest_foreigntable_opt 'table_name \'TBL1\''
\set tablename_opt 'table_name'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
