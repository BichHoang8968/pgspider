#ifndef INSTALL_UTIL_H
#define INSTALL_UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libpq-fe.h>
#include <stdarg.h>

#define QUERY_LEN 16384
#define PATH_LEN 1024
#define READBUF_REN 1024 * 1024
#define CONFIG_LEN 128
#define NODENAME "Nodename"
#define NODES "Nodes"

#define STRFILENAME "./node_structure.json"
#define INFOFILENAME "./node_information.json"
#define ERROR(fmt,...) err_msg(__FILE__, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)

extern const char spd_extensions[][CONFIG_LEN];

typedef struct nodes
{
	char	   *nodename;
	char	   *fdw;
	char	   *name;
	char	   *ip;
	char	   *port;
	char	   *user;
	char	   *pass;
	char	   *dbname;
	char	   *tablename;
	char	   *clustername;
	char	   *notification_member;
	char	   *dbpath;
	char	   *dirpath;
	char	   *column;
	char	   *servername;
	struct nodes *next;
}			nodes;

void		create_connection(PGconn **conn, nodes * node);
void		exit_error(PGconn *conn);
void		query_execute(PGconn *conn, char *query);
void		err_msg(const char *file, const char *function, int line, const char *fmt,...);



#endif							/* PGSPIDER_FDW_H */
