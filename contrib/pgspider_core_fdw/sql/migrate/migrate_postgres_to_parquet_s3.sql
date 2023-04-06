-- PostgreSQL
\set ECHO none
\set source_wrapper_name 'postgres_fdw'
\set dest_wrapper_name 'parquet_s3_fdw'
\set source_server_opt 'host \'127.0.0.1\', port \'15432\', dbname \'sourcedb\''
\set dest_server_opt 'use_minio \'true\', endpoint \'127.0.0.1:9000\''
\set source_usermapping_opt 'user \'postgres\', password \'postgres\''
\set dest_usermapping_opt 'user \'minioadmin\', password \'minioadmin\''
\set source_foreigntable_opt 'table_name \'TBL1\''
\set dest_foreigntable_opt 'dirname \'s3:\/\/data\/dest\''
\set tmp_dest_foreigntable_opt 'dirname \'s3:\/\/data\/dest\''
\set tablename_opt 'dirname'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
