#ifndef INSTALL_UTIL_H
#define INSTALL_UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _MSC_VER
#define strcasecmp _stricmp
#else
#include <unistd.h>
#endif
#include <libpq-fe.h>
#include <stdarg.h>
#include "error_codes.h"

#define QUERY_LEN 16384
#define PATH_LEN 1024
#define READBUF_REN 1024 * 1024
#define CONFIG_LEN 128
#define TABLE_NAME_LEN 63
#define COLUMN_NAME_LEN 59
#define NODENAME "Nodename"
#define NODES "Nodes"
#define MYSQL_DRIVER_OF_JDBC "com.mysql.jdbc.Driver"
#define MYSQL_DBSERVER_OF_ODBC "mysql"
#define MONGO_OPTION_LEN 128
#define GITLAB_OPTION_LEN 128
#define ORACLE_OPTION_LEN 128

/* An interval time when retrying to create a connection of PGSpider. */
#define RETRY_INTERVAL  (100)	/* msec */

#ifdef _MSC_VER
#define MY_SLEEP(msec) Sleep(msec)
#else
#define MY_SLEEP(msec) usleep(msec * 1000)
#endif

#define PRINT_ERROR(fmt,...) err_msg(__FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)

#define IS_S3_PATH(str) (strncmp(str, "s3://", 5) == 0)

#define IS_VALID_LENGTH(max, format,...) (snprintf(NULL, 0, format, ##__VA_ARGS__) <= max)

/*
 * Support macros for escaping strings.  escape_backslash should be true
 * if generating a non-standard-conforming string.  Prefixing a string
 * with ESCAPE_STRING_SYNTAX guarantees it is non-standard-conforming.
 * Beware of multiple evaluation of the "ch" argument!
 * 
 * Referenced from PostgreSQL
 */
#define SQL_STR_DOUBLE(ch, escape_backslash) ((ch) == '\'' || ((ch) == '\\' && (escape_backslash)))
#define ESCAPE_STRING_SYNTAX 'E'
#define TRUE 1

extern const char spd_extensions[][CONFIG_LEN];

typedef struct file_fdw_tables
{
	char	   *filename;
	char	   *tablename;
	struct file_fdw_tables *next;
}			file_fdw_tables;

typedef struct nodes
{
	char	   *nodename;
	char	   *fdw;
	char	   *ip;
	char	   *port;
	char	   *user;
	char	   *pass;
	char	   *user_admin;
	char	   *pass_admin;
	char	   *dbname;
	char	   *table;
	char	   *clustername;
	char	   *notification_member;
	char	   *dbpath;
	char	   *dirpath;
	char	   *column;
	char	   *servername;

	/* Specific options for parquet_s3_fdw, dynamodb_fdw */
	char	   *endpoint;		/* The URL of the entry point for an AWS web 
								 * service. */
	char	   *useminio;		/* option for create server to connect
								 * s3/minio server. */
	char	   *region;			/* the value of AWS region used to connect to
								 * (default ap-northeast-1). */
	char	   *sorted;			/* list of columns that Parquet files are
								 * presorted. */

	/* Specific options for oracle_fdw */
	char	   *dbserver;		/* oracle database connection string for the
								 * remote database. */
	char	   *isolation_level;	/* the transaction isolation level to use
									 * at the Oracle database. */
	char	   *nchar;			/* setting this option to `on` chooses a more
								 * expensive character conversion on the
								 * Oracle side. */
	char	   *case_opt;		/* controls case folding for table and column
								 * names during import. */

	/* Specific options for odbc_fdw, jdbc_fdw */
	char	   *dbdrivername;	/* the name of the ODBC driver to use */
	char	   *querytimeout;	/* the number of seconds that an SQL statement
								 * may execute before timing out. */
	char	   *dburl;			/* the JDBC URL that shall be used to connect
								 * to the foreign database. */
	char	   *driverpathjar;	/* the path and name of the JAR file of the
								 * JDBC driver to be used of the foreign
								 * database. */
	char	   *maxheapsize;	/* the value of the option shall be set to the
								 * maximum heap size of the JVM which is being
								 * used in jdbc fdw. */

	/* Specific options for mongo_fdw */
	char	   *use_remote_estimate;	 /* Controls whether mongo_fdw uses exact rows from remote collection
										  * to obtain cost estimates. Default is false. */
	char	   *enable_join_pushdown;	 /* If true, pushes the join between two foreign
										  * tables from the same foreign server, instead of fetching all the rows
										  * for both the tables and performing a join locally. This option can also
										  * be set for an individual table, and if any of the tables involved in the
										  * join has set it to false then the join will not be pushed down. The
										  * table-level value of the option takes precedence over the server-level
										  * option value. Default is true. */
	char	   *authentication_database; /* Database against which user will be authenticated against.
										  * Only valid with password based authentication. */
	char	   *replica_set;			 /* Replica set the server is member of.
										  * If set, driver will auto-connect to correct primary in the replica set when writing. */
	char	   *read_preference;		 /* primary [default], secondary, primaryPreferred, secondaryPreferred, or nearest. */
	char	   *ssl;					 /* false [default], true to enable ssl.
										  * See http://mongoc.org/libmongoc/current/mongoc_ssl_opt_t.html to understand the options.*/
	char	   *pem_file;				 /* The .pem file that contains both the TLS/SSL certificate and key.*/
	char	   *pem_pwd;				 /* The password to decrypt the certificate key file(i.e. pem_file) */
	char	   *ca_file;				 /* The .pem file that contains the root certificate chain from the Certificate Authority. */
	char	   *ca_dir;					 /* The absolute path to the ca_file. */
	char	   *crl_file;				 /* The .pem file that contains the Certificate Revocation List. */
	char	   *weak_cert_validation;	 /* false [default], This is to enable or disable the validation checks for TLS/SSL certificates
										  * and allows the use of invalid certificates to connect if set to true.*/

	/* Specific options for objstorage_fdw */
	char	   *storage_type;			 /* Storage server type. */
	char	   *tablename;				 /* foreign table name */
	char	   *filename;				 /* Use the specified file as data source. */
	char	   *dirname;				 /* Use all files under the specified directory as data source. */
	char	   *format;					 /* Data format. */
	char	   *schemaless;				 /* true : schemaless / false : normal table. */
	char	   *key_columns;			 /* Key columns on schemaless table Multiple values can be set by separating with commas. */
	char	   *key;					 /* true : use as key column. */

	/* Specific options for influxdb_fdw */
	char	   *influxdb_version;		 /* InfluxDB version */
	char	   *token;					 /* InfluxDB V2 token. */
	char	   *retention_policy;		 /* InfluxDB V2 retention policy*/

	/*
	 * Specific options for redmine_fdw, gitlab_fdw.
	 * There are some options endpoint, user, password, ca_file are already mentioned above.
	 */
	char	   *timeout;				 /* Maximum time in seconds that allow the curl transfer operation to take */
	char	   *proxy;					 /* Set proxy to use */
	char	   *ssl_verifypeer;			 /* Determine whether Curl verify the authenticity of the peer's certificate or not */
	char	   *ca_path;				 /* The directory path that holds multiple Certificate Authority certificate files to verify the peer with */
	char	   *api_key;				 /* User’s API key which is a handy way to avoid putting a password */
	char	   *access_token;			 /* token access to gitlab */

	file_fdw_tables *file_tables;
	struct nodes *next;
}			nodes;

/* Note: Referenced from the struct StringInfoData of PostgreSQL */
typedef struct string_info_data
{
	char	   *data;
	int			len;
	int			maxlen;
} string_info_data;
typedef string_info_data *string_info;

ReturnCode	create_connection(PGconn **pConn, nodes * node, char isAdmin, int timeout);
ReturnCode	query_execute(PGconn *conn, char *query);
void		err_msg(const char *file, const char *function, int line, const char *fmt,...);
void		deparse_string_literal(string_info str, const char *val);
void 		init_string_info(string_info str);
char*		to_lower(char *str);

#endif							/* INSTALL_UTIL_H */
