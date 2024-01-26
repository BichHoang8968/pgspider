\set ECHO none
\ir sql/migrate/objstorage/parameters_gcs.conf
\set ECHO all
SELECT * FROM substring(version(),1,8) \gset
\set FILE_FORMAT 'avro'
\ir sql/migrate/objstorage/objstorage_fdw_migrate_dirname.sql
\ir sql/migrate/objstorage/objstorage_fdw_migrate_file.sql
