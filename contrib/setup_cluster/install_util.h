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
#define NODENAME "Nodename"
#define NODES "Nodes"
#define MYSQL_DRIVER_OF_JDBC "com.mysql.jdbc.Driver"
#define MYSQL_DBSERVER_OF_ODBC "mysql"
#define MONGO_OPTION_LEN 128
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
	char	   *filename;				 /* Use the specified file as data source. */
	char	   *dirname;				 /* Use all files under the specified directory as data source. */
	char	   *format;					 /* Data format. */
	char	   *schemaless;				 /* true : schemaless / false : normal table. */
	char	   *key_columns;			 /* Key columns on schemaless table Multiple values can be set by separating with commas. */
	char	   *key;					 /* true : use as key column. */
	char	   *influxdb_version;		 /* InfluxDB version */
	char	   *token;					 /* InfluxDB V2 token. */
	char	   *retention_policy;		 /* InfluxDB V2 retention policy*/

	file_fdw_tables *file_tables;
	struct nodes *next;
}			nodes;

ReturnCode	create_connection(PGconn **pConn, nodes * node, char isAdmin, int timeout);
ReturnCode	query_execute(PGconn *conn, char *query);
void		err_msg(const char *file, const char *function, int line, const char *fmt,...);



#endif							/* INSTALL_UTIL_H */
