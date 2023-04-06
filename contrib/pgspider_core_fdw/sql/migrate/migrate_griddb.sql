-- GridDB
\set ECHO none
\set source_wrapper_name 'griddb_fdw'
\set dest_wrapper_name 'griddb_fdw'
\set source_server_opt 'notification_member \'127.0.0.1:10001\', clustername \'griddbfdwTestCluster\''
\set dest_server_opt 'notification_member \'127.0.0.1:10002\', clustername \'dockerGridDB\''
\set source_usermapping_opt 'username \'admin\', password \'testadmin\''
\set dest_usermapping_opt 'username \'admin\', password \'admin\''
\set source_foreigntable_opt 'table_name \'TBL1\''
\set dest_foreigntable_opt 'table_name \'TBL2\''
\set tmp_dest_foreigntable_opt 'table_name \'TBL1\''
\set tablename_opt 'table_name'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
