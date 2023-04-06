-- InfluxDB
\set ECHO none
\set source_wrapper_name 'influxdb_fdw'
\set dest_wrapper_name 'influxdb_fdw'
\set source_server_opt 'host \'http://localhost\', port \'8086\', dbname \'sourcedb\''
\set dest_server_opt 'host \'http://localhost\', port \'8086\', dbname \'destdb\''
\set source_usermapping_opt 'user \'user\', password \'pass\''
\set dest_usermapping_opt 'user \'user\', password \'pass\''
\set source_foreigntable_opt 'table \'TBL1\''
\set dest_foreigntable_opt 'table \'TBL2\''
\set tmp_dest_foreigntable_opt 'table \'TBL1\''
\set tablename_opt 'table'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
