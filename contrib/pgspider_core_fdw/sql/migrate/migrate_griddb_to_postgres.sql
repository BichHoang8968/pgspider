-- GridDB
\set ECHO none
\set source_wrapper_name 'griddb_fdw'
\set dest_wrapper_name 'postgres_fdw'
\set source_server_opt 'notification_member \'127.0.0.1:10003\', clustername \'dockerGridDB\''
\set dest_server_opt 'host \'127.0.0.1\',  port \'15432\', dbname \'destdb\''
\set source_usermapping_opt 'username \'admin\', password \'admin\''
\set dest_usermapping_opt 'user \'postgres\', password \'postgres\''
\set source_foreigntable_opt 'table_name \'TBL1\''
\set dest_foreigntable_opt 'table_name \'TBL2\''
\set tmp_dest_foreigntable_opt 'table_name \'TBL1\''
\set tablename_opt 'table_name'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
