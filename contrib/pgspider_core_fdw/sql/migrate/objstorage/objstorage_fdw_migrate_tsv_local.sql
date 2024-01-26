\set ECHO none
\ir sql/migrate/objstorage/parameters_local.conf
\set ECHO all
SELECT * FROM substring(version(),1,8) \gset
\set FILE_FORMAT 'tsv'
\ir sql/migrate/objstorage/objstorage_fdw_migrate_dirname.sql
\ir sql/migrate/objstorage/objstorage_fdw_migrate_file.sql
