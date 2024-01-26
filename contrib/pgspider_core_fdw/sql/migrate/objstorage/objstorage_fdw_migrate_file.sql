\set ECHO all

-- ===================================================================
-- **Migrate filename
-- Note: objstorage will still use 'dirname' to create file in case no option inherit.
-- ===================================================================

\set src_var :PATH_FILENAME'/':FILE_FORMAT'/migrate_src.':FILE_FORMAT
\set des_var :PATH_FILENAME'/':FILE_FORMAT'/migrate_des.':FILE_FORMAT
\set src_foreigntable_opt 'filename ':'src_var'', format ':'FILE_FORMAT'
\set dest_foreigntable_opt 'filename ':'des_var'', format ':'FILE_FORMAT'
\set tablename_opt 'dirname'
\set default_dest_foreigntable_opt 'dirname ':'des_var'', format \'json\''


\ir objstorage_fdw_migrate.sql
