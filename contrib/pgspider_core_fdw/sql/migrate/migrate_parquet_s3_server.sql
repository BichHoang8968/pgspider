-- Parquet S3 server
\set ECHO none
\set source_wrapper_name 'parquet_s3_fdw'
\set dest_wrapper_name 'parquet_s3_fdw'
\set source_server_opt 'use_minio \'true\', endpoint \'127.0.0.1:9000\''
\set dest_server_opt 'use_minio \'true\', endpoint \'127.0.0.1:9001\''
\set source_usermapping_opt 'user \'minioadmin\', password \'minioadmin\''
\set dest_usermapping_opt 'user \'minioadmin\', password \'minioadmin\''
\set source_foreigntable_opt 'dirname \'s3:\/\/data\/source\''
\set dest_foreigntable_opt 'dirname \'s3:\/\/data\/dest\''
\set tmp_dest_foreigntable_opt 'dirname \'s3:\/\/data\/source\''
\set tablename_opt 'dirname'
\set ECHO all
SET datestyle = ISO;
SET timezone = 'UTC';

\i sql/migrate/migrate_ddl_command.sql
