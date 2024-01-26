\set ECHO all
-- ===================================================================
-- **Migrate dirname 
-- Note: objstorage will use "relaion name" as prefix to create file.
-- ===================================================================
\set src_var :PATH_FILENAME'/':FILE_FORMAT'/migrate_src_':FILE_FORMAT
\set des_var :PATH_FILENAME'/':FILE_FORMAT'/migrate_des_':FILE_FORMAT
\set src_foreigntable_opt 'dirname ':'src_var'', format ':'FILE_FORMAT'', insert_file_selector \'selector(c1 , dirname)\''
\set dest_foreigntable_opt 'dirname ':'des_var'', format ':'FILE_FORMAT'
\set tablename_opt 'dirname'
\set default_dest_foreigntable_opt 'dirname ':'des_var'', format \'json\''


\ir objstorage_fdw_migrate.sql