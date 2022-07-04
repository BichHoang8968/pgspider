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

/* An interval time when retrying to create a connection of PGSpider. */
#define RETRY_INTERVAL  (100)	/* msec */

#ifdef _MSC_VER
#define MY_SLEEP(msec) Sleep(msec)
#else
#define MY_SLEEP(msec) usleep(msec * 1000)
#endif

#define PRINT_ERROR(fmt,...) err_msg(__FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)

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
	file_fdw_tables *file_tables;
	struct nodes *next;
}			nodes;

ReturnCode	create_connection(PGconn **pConn, nodes * node, char isAdmin, int timeout);
ReturnCode	query_execute(PGconn *conn, char *query);
void		err_msg(const char *file, const char *function, int line, const char *fmt,...);



#endif							/* INSTALL_UTIL_H */
