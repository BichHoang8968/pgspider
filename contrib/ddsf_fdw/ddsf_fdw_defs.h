#ifndef DDSF_FDW_DEFS
#define DDSF_FDW_DEFS

/*Following are global defs for DDSF FDW -- factor to ddsf_defs.h */
#define DDSF_CONF_PATH "/usr/local/pgsql/share/extension/ddsf_server_nodes.conf"
#define NODE_NAME_LEN (1024)
#define NODES_MAX (100)
#define SRVOPT_QRY "select srvoptions from information_schema._pg_foreign_servers where foreign_server_name = '%s'"
#define UMOPT_QRY "select umoptions from information_schema._pg_user_mappings where foreign_server_name = '%s'"
#define UDTNAME_QRY "select udt_name from information_schema.columns where table_name='%s' and column_name='%s'"
#define ENUMOID_QRY "select oid from pg_type where typname='%s'"
/*End defs*/


#endif							/* DDSF_FDW_DEFS */
