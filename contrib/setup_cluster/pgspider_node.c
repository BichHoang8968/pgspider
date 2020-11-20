/* -------------------------------------------------------------------------
 *
 * pgspider_node.c
 * Copyright (c) 2019, TOSHIBA
 *
 * -------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libpq-fe.h>
#include "pgspider_node.h"

static void
tinybrace_fdw(nodes * option, PGconn *conn);

static void file_fdw(nodes * option, PGconn *conn);
static void pgspider_fdw(nodes * option, PGconn *conn);
static void postgres_fdw(nodes * option, PGconn *conn);
static void sqlite_fdw(nodes * option, PGconn *conn);
static void mysql_fdw(nodes * option, PGconn *conn);
static void griddb_fdw(nodes * option, PGconn *conn);
static void influxdb_fdw(nodes * option, PGconn *conn);

const spd_function spd_func[] = {
	{"file_fdw", file_fdw},
    {"pgspider_fdw",pgspider_fdw},
    {"postgres_fdw",postgres_fdw},
    {"sqlite_fdw",sqlite_fdw},
    {"tinybrace_fdw",tinybrace_fdw},
    {"mysql_fdw",mysql_fdw},
    {"griddb_fdw",griddb_fdw},
    {"influxdb_fdw",influxdb_fdw},
    {"pgspider_core_fdw",node_set_spdcore}
};

const int extension_size = sizeof(spd_func) / sizeof(*spd_func);

void
node_set_spdcore(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS pgspider_core_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option->name, "pgspider_core_fdw", option->ip, option->port);
	query_execute(conn, sql);

	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}


static void
tinybrace_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];


	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS tinybrace_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->name, "tinybrace_fdw", option->ip, option->port, option->dbname);
	query_execute(conn, sql);

	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}

static void
mysql_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS mysql_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option->name, "mysql_fdw", option->ip, option->port);
	query_execute(conn, sql);
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}

static void
postgres_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS postgres_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s',dbname '%s');\n", option->name, "postgres_fdw", option->ip, option->port, option->dbname);
	query_execute(conn, sql);

	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}

static void
pgspider_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS pgspider_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->name, "pgspider_fdw", option->ip, option->port, option->dbname);
	query_execute(conn, sql);

	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}

static void
sqlite_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS sqlite_fdw;");
	query_execute(conn, sql);
	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(database '%s');\n", option->name, "sqlite_fdw", option->dbname);
	query_execute(conn, sql);
}

static void
file_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS file_fdw;");
	query_execute(conn, sql);
	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s;", option->nodename, "file_fdw");
	printf("file %s\n", sql);
	query_execute(conn, sql);
}

static void
griddb_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];


	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS griddb_fdw;");
	query_execute(conn, sql);
	if (option->notification_member == NULL)
		sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER griddb_fdw OPTIONS(host '%s',port '%s', clustername '%s'", option->name, option->ip, option->port, option->clustername);
	else
		sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER griddb_fdw OPTIONS(notification_member '%s', clustername '%s'", option->name, option->notification_member, option->clustername);
	/* set dbname */
	if (option->dbname == NULL)
		sprintf(sql, "%s);", sql);
	else
		sprintf(sql, "%s,dbname '%s');", sql, option->dbname);
	query_execute(conn, sql);
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->name, option->user, option->pass);
	query_execute(conn, sql);
}


static void
influxdb_fdw(nodes * option, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS influxdb_fdw;");
	query_execute(conn, sql);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->name, "influxdb_fdw", option->ip, option->port, option->dbname);
	query_execute(conn, sql);
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n",
			option->name, option->user, option->pass);
	query_execute(conn, sql);
}

void
node_set(nodes * option, PGconn *conn)
{
	int			i;
	for (i = 0; i <  extension_size; i++)
	{
		if (strcasecmp(spd_func[i].name, option->fdw) == 0)
		    (*spd_func[i].func) (option, conn);
	}
}

void
mapping_set_file(nodes * option, PGconn *conn, char *table_name)
{
	char		sql[QUERY_LEN];
	char		table_path[512];

	if(option->dirpath[strlen(option->dirpath)-1]=='/')
		sprintf(table_path, "%s%s", option->dirpath, table_name);
	else
		sprintf(table_path, "%s/%s", option->dirpath, table_name);
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__0(%s) SERVER %s OPTIONS(filename '%s', format 'csv');\n",
			option->nodename, option->name, option->column, option->nodename, table_path);
	/* sprintf(table_name, "%s__%s__%d", option->fdw, option[6], resp_cnt); */
	printf("mapping set file %s\n", sql);
	query_execute(conn, sql);
}
