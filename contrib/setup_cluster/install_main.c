/* -------------------------------------------------------------------------
 *
 * pgspider_install.c
 * Copyright (c) 2019, TOSHIBA
 *
 * -------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "libpq-fe.h"
#ifdef _MSC_VER
#include <io.h>
#else
#include <unistd.h>
#endif
#include <fcntl.h>

#include <assert.h>
#include <string.h>
#include <memory.h>
#include <jansson.h>
#include <dirent.h>
#include <sys/stat.h>

#include "install_util.h"
#include "pgspider_node.h"
#include "config.h"

#define PORT_NUMBER_MAX_LENGTH 5
#define PORT_NUMBER_MIN 1
#define PORT_NUMBER_MAX 65535

static ReturnCode parse_conf(json_t * element, nodes * nodes_data);
static nodes * create_node();
static nodes * add_node(nodes * head, nodes * node);
static nodes * search_nodes(char *nodename, nodes * node);

typedef struct child_node_list
{
	char	   *node_name;
	struct child_node_list *children;
	int			child_nums;
}			child_node_list;

/*
 * Create an extension
 *
 * @param[in] name - Extension name
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static ReturnCode
create_extension(char *name, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE EXTENSION IF NOT EXISTS %s;", name);
	return query_execute(conn, sql);
}

/*
 * Drop an extension
 *
 * @param[in] name - Extension name
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static ReturnCode
drop_extension(const char *name, PGconn *conn)
{
	char		query[QUERY_LEN];

	sprintf(query, "DROP EXTENSION IF EXISTS %s CASCADE;", name);
	return query_execute(conn, query);
}

/*
 * Drop extensions which this tool are supporting.
 *
 * @param[in] conn - Connection for PGSpider
 *
 * @return Return code
 */
static ReturnCode
drop_extensions(PGconn *conn)
{
	int			i;

	for (i = 0; i < extension_size; i++)
	{
		ReturnCode	rc;

		rc = drop_extension(spd_func[i].name, conn);
		if (rc != SETUP_OK)
			return rc;
	}

	return SETUP_OK;
}

/*
 * Drop extensions as log as possible. Even if it failed to drop one of FDW extension,
 * it continues to drop the other FDW extensions.
 *
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static void
drop_all_fdws(PGconn *conn)
{
	int			i;
	PGresult   *res;

	/* Get extension name existing in PGSpider. */
	res = PQexec(conn, "SELECT extname FROM pg_extension WHERE extname LIKE '%_fdw'");
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		PRINT_ERROR("Error: Can not find extension list \n%s \n%s\n",
					PQresStatus(PQresultStatus(res)),
					PQerrorMessage(conn));
		return;
	}

	/* Drop FDWs. */
	for (i = 0; i < PQntuples(res); i++)
	{
		char	   *fdw_name = PQgetvalue(res, i, 0);

		drop_extension(fdw_name, conn);
	}
}

/*
 * Connect to PGSpider with admin user then drop extensions as log as possible.
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static void
drop_all_fdws_with_connect(nodes * nodes_data, child_node_list * child_node, int timeout)
{
	ReturnCode	rc;
	nodes	   *parent_node;
	PGconn	   *conn;

	parent_node = search_nodes(child_node->node_name, nodes_data);
	/* Already checked in set_pgspider_node_admin. */
	assert(parent_node != NULL);
	assert(strcmp(parent_node->fdw, "pgspider_fdw") == 0);

	rc = create_connection(&conn, parent_node, 1, timeout);
	if (rc == SETUP_OK)
	{
		drop_all_fdws(conn);
		PQfinish(conn);
	}
}

/*
 * Give a permission for allowing normal user to create schema.
 *
 * @param[in] username - User name given a permission
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static ReturnCode
give_database_permission(char *dbname, char *username, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "GRANT CREATE ON DATABASE %s TO %s;", dbname, username);
	return query_execute(conn, sql);
}

/*
 * Give a permission using a FDW to normal user.
 *
 * @param[in] fdwname - FDW name
 * @param[in] username - User name given a permission
 * @param[in] conn - Connection for PGSpider
 *
 * @return none
 */
static ReturnCode
give_fdw_permission(char *fdwname, char *username, PGconn *conn)
{
	char		sql[QUERY_LEN];

	sprintf(sql, "GRANT USAGE ON FOREIGN DATA WRAPPER %s TO %s;", fdwname, username);
	return query_execute(conn, sql);
}

/*
 * Set node data in keep-alive system table
 *
 * @param[in] conn - Connection for PGSpider
 * @param[in] node_data - Child node info
 *
 * @return none
 */
static ReturnCode
set_child_ip(PGconn *conn, nodes * node_data)
{
	char		query[QUERY_LEN];

	if (node_data->ip == NULL)
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','127.0.0.1');", node_data->nodename, node_data->fdw);
	else if (strcmp(node_data->fdw, "influxdb_fdw") == 0)
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','127.0.0.1');", node_data->nodename, node_data->fdw);
	else
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','%s');", node_data->nodename, node_data->fdw, node_data->ip);
	return query_execute(conn, query);
}

/*
 * Execute import foreign schema
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] server_name - Child node server name
 *
 * @return none
 */
static ReturnCode
import_schema(PGconn *conn, nodes * node_data)
{
	ReturnCode	rc;
	char		query[QUERY_LEN] = {0};

	rc = query_execute(conn, "DROP SCHEMA IF EXISTS temp_schema;");
	if (rc != SETUP_OK)
		return rc;

	rc = query_execute(conn, "CREATE SCHEMA temp_schema;");
	if (rc != SETUP_OK)
		return rc;

	if (strcmp(node_data->fdw, "mysql_fdw") == 0)
		sprintf(query, "IMPORT FOREIGN SCHEMA %s FROM server %s INTO temp_schema;", node_data->dbname, node_data->nodename);
	else
		sprintf(query, "IMPORT FOREIGN SCHEMA public FROM server %s INTO temp_schema;", node_data->nodename);

	rc = query_execute(conn, query);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

/*
 * List up file names in the directory(node_data->dirpath) and store them
 * into node_data->file_tables
 *
 * @param[in,out] node_data - Nodes data
 *
 * @return Return code
 */
static ReturnCode
list_up_files(nodes * node_data)
{
	ReturnCode	rc = SETUP_OK;
	DIR		   *dirp = NULL;
	struct dirent *p = NULL;
	file_fdw_tables *prev = NULL;

	if ((dirp = opendir(node_data->dirpath)) == NULL)
	{
		PRINT_ERROR("Error: Can't open directory %s\n", node_data->dirpath);
		return SETUP_IO_ERROR;
	}

	p = readdir(dirp);
	/* Read file name in directory */
	while (p != NULL)
	{
		char	   *dotp;
		file_fdw_tables *elem;

		if (p->d_type != DT_REG || DT_UNKNOWN)
		{
			p = readdir(dirp);
			continue;
		}

		/* Create new element. */
		elem = malloc(sizeof(file_fdw_tables));
		if (elem == NULL)
		{
			PRINT_ERROR("Error: out of memory\n");
			rc = SETUP_NOMEM;
			goto err_list_up_files;
		}
		elem->next = NULL;

		elem->filename = strdup(p->d_name);
		if (elem->filename == NULL)
		{
			PRINT_ERROR("Error: out of memory\n");
			rc = SETUP_NOMEM;
			goto err_list_up_files;
		}

		elem->tablename = strdup(p->d_name);
		if (elem->tablename == NULL)
		{
			PRINT_ERROR("Error: out of memory\n");
			rc = SETUP_NOMEM;
			goto err_list_up_files;
		}

		/* Remove a file extension if exists. */
		dotp = strchr(elem->tablename, '.');
		if (dotp != NULL)
			elem->tablename[dotp - elem->tablename] = '\0';

		/* Add the element into the tail of list. */
		if (prev)
			prev->next = elem;
		else
			node_data->file_tables = elem;

		p = readdir(dirp);
		prev = elem;
	}

	if (closedir(dirp) != 0)
	{
		PRINT_ERROR("Error: Can't close directory %s\n", node_data->dirpath);
		return SETUP_IO_ERROR;
	}

	return SETUP_OK;

err_list_up_files:
	closedir(dirp);
	return rc;
}

/*
 * Operations for file_fdw node by admin user.
 *  - Give pg_read_server_files permission to normal user.
 *  - Insert a record to pg_spd_node_info table.
 *
 * @param[in] conn - PGSpider connection
 * @param[in] node_data - Nodes data
 * @param[in] parent_server - Parent(pgspider) node name
 * @param[in] username - Normal user name
 *
 * @return Return code
 */
static ReturnCode
load_filefdw_admin(PGconn *conn, nodes * node_data, char *parent_server, char *username)
{
	ReturnCode	rc;
	char		query[QUERY_LEN];

	rc = list_up_files(node_data);
	if (rc != SETUP_OK)
		return rc;

	/*
	 * Give a pg_read_server_files permission to normal user for reading files
	 * located in the server.
	 */
	sprintf(query, "GRANT pg_read_server_files TO %s;", username);
	rc = query_execute(conn, query);
	if (rc != SETUP_OK)
		return rc;

	rc = set_child_ip(conn, node_data);

	return rc;
}

/*
 * Load and set file fdw tables.
 * File fdw parent table name is the table value in node_information.json.
 * Server name is node name in node_information.json.
 * Each file in directory is corresponding with a child table.
 * Child table name has format [tablename]__[nodename]__[sequencenumber]
 *
 * ex.
 * - Data in node_information.json:
 *	 {
 *		"nodename": "db3",
 *		"fdw": "file_fdw",
 *		"column": "c1 text, c2 bigint, c3 float8",
 *		"dirpath": "/tmp/test_setcluster1"
 *		"table":"tbl1"
 *	 }
 * - Folder /tmp/test_setcluster1 has 2 files: file1.csv, file2.csv
 * Result:
 * - Parent table name is tbl1
 * - Server name is db3
 * - Child table name are tbl1__db3__0 and tbl1__db3__1
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] node_data - Nodes data
 * @param[in] parent_server - Parent(pgspider) node name
 *
 * @return none
 */
static ReturnCode
load_filefdw(PGconn *conn, nodes * node_data, char *parent_server)
{
	ReturnCode	rc = SETUP_OK;
	char		query[QUERY_LEN];
	file_fdw_tables *elem;
	int			i = 0;

	/* CREATE parent table */
	sprintf(query, "CREATE FOREIGN TABLE IF NOT EXISTS \"%s\"(%s,__spd_url text) server %s;", node_data->table, node_data->column, parent_server);
	printf("file_fdw parent foreign table: %s\n", query);
	rc = query_execute(conn, query);
	if (rc != SETUP_OK)
		return rc;

	/* Create a foreign server. */
	rc = node_set(node_data, conn);
	if (rc != SETUP_OK)
		return rc;

	elem = node_data->file_tables;
	while (elem)
	{
		/* Create a foreign table. */
		rc = mapping_set_file(node_data, conn, elem->filename, i);
		if (rc != SETUP_OK)
			return rc;

		elem = elem->next;
		i++;
	}

	return rc;
}

/*
 * Rename foreign table name
 * 1. Read all table name from "temp_schema" (Tables are imported by import_schema)
 * 2. ALTER TABLE RENAME child table to SERVERNAME__TABLENAME__0
 * 3. ALTER TABLE temp_schema to main schema
 * 4. Create parent table. Get all columns and CREATE TABLE with __spd_url column
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] server_name - Child node server name
 * @param[in] fdw - Child table's fdw
 * @param[in] parent_node_name - Parent(pgspider) node name
 *
 * @return none
*/
static ReturnCode
rename_foreign_table(PGconn *conn, char *server_name, char *fdw, char *parent_node_name)
{
	ReturnCode	rc;
	int			i,
				k;
	PGresult   *res;
	char		query[QUERY_LEN] = "SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema='temp_schema'";
	PGresult   *select_column_res = NULL;
	PGresult   *select_column_res_tmp = NULL;

	/* get table name from temp schema */
	res = PQexec(conn, query);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		PRINT_ERROR("Error: Can not find child tables %s \n%s \n%s\n",
					query,
					PQresStatus(PQresultStatus(res)),
					PQerrorMessage(conn));
		return SETUP_QUERY_FAILED;
	}

	/* change table name and schema */
	for (i = 0; i < PQntuples(res); i++)
	{
		char		select_column_query[QUERY_LEN];
		char		alter_query[QUERY_LEN];
		char		create_query[QUERY_LEN];
		char		newtable[QUERY_LEN];

		sprintf(newtable, "%s__%s__0", PQgetvalue(res, i, 0), server_name);
		sprintf(select_column_query, "SELECT c.oid,n.nspname,c.relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relname OPERATOR(pg_catalog.~) '^(%s)$' AND n.nspname OPERATOR(pg_catalog.~) '^(temp_schema)$' ORDER BY 2, 3;", PQgetvalue(res, i, 0));
#ifdef PRINT_DEBUG
		printf("select=%s \n", select_column_query);
#endif
		select_column_res_tmp = PQexec(conn, select_column_query);
		if (PQresultStatus(select_column_res_tmp) != PGRES_TUPLES_OK)
		{
			PRINT_ERROR("Error: %s\n", PQerrorMessage(conn));
			rc = SETUP_QUERY_FAILED;
			break;
		}
		sprintf(select_column_query, "SELECT a.attname,pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_catalog.pg_attribute a WHERE a.attrelid = '%s' AND a.attnum > 0 AND NOT a.attisdropped ORDER BY a.attnum;", PQgetvalue(select_column_res_tmp, 0, 0));
		select_column_res = PQexec(conn, select_column_query);
		if (PQresultStatus(select_column_res_tmp) != PGRES_TUPLES_OK)
		{
			PRINT_ERROR("Error: %s\n", PQerrorMessage(conn));
			rc = SETUP_QUERY_FAILED;
			break;
		}

		sprintf(alter_query, "ALTER TABLE temp_schema.\"%s\" RENAME TO \"%s\";", PQgetvalue(res, i, 0), newtable);
		rc = query_execute(conn, alter_query);
		if (rc != SETUP_OK)
			break;
		sprintf(alter_query, "ALTER TABLE temp_schema.\"%s\" SET schema public;", newtable);
		rc = query_execute(conn, alter_query);
		if (rc != SETUP_OK)
			break;
		/* griddb fdw does not add table name option. we add here. */
		if (strcmp(fdw, "griddb_fdw") == 0)
		{
			sprintf(alter_query, "ALTER FOREIGN TABLE \"%s\" OPTIONS (table_name '%s');", newtable, PQgetvalue(res, i, 0));
			rc = query_execute(conn, alter_query);
			if (rc != SETUP_OK)
				break;
		}

		/* Create parent table */
		sprintf(create_query, "CREATE FOREIGN TABLE IF NOT EXISTS \"%s\"(", PQgetvalue(res, i, 0));
		for (k = 0; k < PQntuples(select_column_res); k++)
		{
			if (strcmp(PQgetvalue(select_column_res, k, 0), "__spd_url") != 0)
			{
				if (k != 0)
					strcat(create_query, ",");
				strcat(create_query, PQgetvalue(select_column_res, k, 0));
				strcat(create_query, " ");
				strcat(create_query, PQgetvalue(select_column_res, k, 1));
			}
		}
		/* Add __spd_url */
		strcat(create_query, ",__spd_url text");
		strcat(create_query, " )server ");
		strcat(create_query, parent_node_name);
		rc = query_execute(conn, create_query);
		if (rc != SETUP_OK)
			break;

		PQclear(select_column_res);
		PQclear(select_column_res_tmp);
		select_column_res = NULL;
		select_column_res_tmp = NULL;
	}

	if (select_column_res != NULL)
		PQclear(select_column_res);
	if (select_column_res_tmp != NULL)
		PQclear(select_column_res_tmp);

	PQclear(res);
	return SETUP_OK;
}

/*
 * Malloc and copy node data(All data are string)
 *
 * @param[in] value - jansson value
 *
 * @return string value
 */
static char *
malloc_nodedata(const char *value)
{
	char	   *data = malloc(sizeof(char) * strlen(value) + 1);

	if (data == NULL)
		PRINT_ERROR("Error: out of memory\n");
	else
		strcpy(data, value);
	return data;
}

/*
 * Create an empty linked list node
 *
 * @return created empty node
 */
static nodes *
create_node()
{
	nodes	   *tempnode;

	tempnode = (nodes *) calloc(1, sizeof(nodes));
	if (tempnode == NULL)
	{
		PRINT_ERROR("Error: out of memory\n");
		return NULL;
	}
	tempnode->next = NULL;
	return tempnode;
}

/*
 * Append a node with value into linked list
 * If the list is empty, the added node is head node
 *
 * @param[in, out] head - head node of linked list
 * @param[in, out] node - appended node
 *
 * @return appended list
 */

static nodes *
add_node(nodes * head, nodes * node)
{
	nodes	   *tempnode;

	if (!node)
	{
		PRINT_ERROR("Error: Adding node data failed.\n");
		return NULL;
	}

	if (head == NULL)
		head = node;
	else
	{
		tempnode = head;
		while (tempnode->next != NULL)
			tempnode = tempnode->next;
		tempnode->next = node;
	}

	return head;
}


/*
 *  Search node information object from node list
 *
 * @param[in,out] nodename - searching name
 * @param[in,out] node - All node informations
 *
 * @return nodes
 */
static nodes *
search_nodes(char *nodename, nodes * node)
{
	nodes	   *tempnode = node;

	if (nodename == NULL || strcmp(nodename, "") == 0)
	{
		PRINT_ERROR("Error: Node name is not existed.\n");
		return NULL;
	}

	while (tempnode)
	{
		if (tempnode->nodename != NULL && strcmp(nodename, tempnode->nodename) == 0)
			return tempnode;
		tempnode = tempnode->next;
	}

	PRINT_ERROR("Error: Can not find \"%s\". Please check node name in node information file.\n", nodename);
	return NULL;
}

/*
 * Free all node infomation list
 *
 * @param[in,out] child_node - free child node list
 *
 * @return none
 */
static void
free_nodedata(nodes * node)
{
	nodes	   *pnext;

	if (node == NULL)
		return;

	while (node)
	{
		pnext = node;
		free(node->nodename);
		free(node->fdw);
		free(node->nodename);
		free(node->ip);
		free(node->port);
		free(node->user);
		free(node->pass);
		free(node->dbname);
		free(node->clustername);
		free(node->notification_member);
		free(node->dbpath);
		free(node->dirpath);
		free(node->column);
		free(node->servername);

		node = node->next;
		free(pnext);
	}
}

/*
 * Free child node list
 *
 * @param[in,out] child_node - free child node list
 *
 * @return none
 */
static void
free_childnode(child_node_list * child_node)
{
	child_node_list *p;
	int			i;

	if (!child_node)
		return;

	p = child_node->children;
	for (i = 0; i < child_node->child_nums; i++)
	{
		if (p[i].children)
			free_childnode(&p[i]);
		printf("free %s\n", p[i].node_name);
		free(p[i].node_name);
	}
	free(p);
}

/*
 * Parse json file and set child node settin
 *
 * @param[in] element - jansson other infomation element
 * @param[in,out] nodes_data - node information data list
 *
 * @return string value
 */
static ReturnCode
parse_conf(json_t * element, nodes * nodes_data)
{
	const char *key;
	json_t	   *value;

	switch (json_typeof(element))
	{
		case JSON_OBJECT:
			json_object_foreach(element, key, value)
			{
				char	   *data;

				/*
				 * Verify port number in case of JSON_INTEGER only for
				 * avoiding buffer overflow of sprintf(). For JSON_STRING, it
				 * is verified at creating connection to the database.
				 */
				if (strcasecmp(key, "port") == 0 &&
					json_typeof(value) == JSON_INTEGER &&
					(int) json_integer_value(value) >= PORT_NUMBER_MIN &&
					(int) json_integer_value(value) <= PORT_NUMBER_MAX)
				{
					data = malloc(sizeof(char) * PORT_NUMBER_MAX_LENGTH + 1);
					if (data == NULL)
					{
						PRINT_ERROR("Error: out of memory\n");
						return SETUP_NOMEM;
					}
					sprintf(data, "%d", (int) json_integer_value(value));
				}
				else if (json_string_value(value) == NULL)
				{
					PRINT_ERROR("Error: %s parameter is invalid.\n", key);
					return SETUP_INVALID_CONTENT;
				}
				else if ((data = malloc_nodedata(json_string_value(value))) == NULL)
				{
					PRINT_ERROR("Error: out of memory\n");
					return SETUP_NOMEM;
				}
				if (strcasecmp(key, "nodename") == 0)
					nodes_data->nodename = data;
				else if (strcasecmp(key, "fdw") == 0)
					nodes_data->fdw = data;
				else if (strcasecmp(key, "ip") == 0)
					nodes_data->ip = data;
				else if (strcasecmp(key, "host") == 0)
					nodes_data->ip = data;
				else if (strcasecmp(key, "port") == 0)
					nodes_data->port = data;
				else if (strcasecmp(key, "username") == 0)
					nodes_data->user = data;
				else if (strcasecmp(key, "password") == 0)
					nodes_data->pass = data;
				else if (strcasecmp(key, "username_admin") == 0)
					nodes_data->user_admin = data;
				else if (strcasecmp(key, "password_admin") == 0)
					nodes_data->pass_admin = data;
				else if (strcasecmp(key, "dbname") == 0)
					nodes_data->dbname = data;
				else if (strcasecmp(key, "table") == 0)
					nodes_data->table = data;
				else if (strcasecmp(key, "dirpath") == 0)
					nodes_data->dirpath = data;
				else if (strcasecmp(key, "column") == 0)
					nodes_data->column = data;
				else if (strcasecmp(key, "dbpath") == 0)
					nodes_data->dbpath = data;
				else if (strcasecmp(key, "clustername") == 0)
					nodes_data->clustername = data;
				else if (strcasecmp(key, "notification_member") == 0)
					nodes_data->notification_member = data;
				else
				{
					PRINT_ERROR("Error: %s is not fdw parameter. \n", key);
					return SETUP_INVALID_CONTENT;
				}
			}
			break;
		default:
			PRINT_ERROR("Error: JSON element format is wrong. Only object appear here. \n");
			return SETUP_PARSE_FAILED;
	}

	return SETUP_OK;
}

/* Verify node name in node data
 * If any empty or duplicate node name, there is an error returned.
 *
 * @param[in] node_data - node information data list
 *
 * @return Return code
 */
static ReturnCode
verify_nodename(nodes * node_data)
{
	nodes	   *head_data = NULL,
			   *head2_data = NULL;
	ReturnCode	rc = SETUP_OK;

	if (node_data == NULL)
	{
		PRINT_ERROR("Error: Node data is not existed\n");
		return SETUP_INVALID_PARAM;
	}

	head_data = node_data;
	while (head_data)
	{
		if (!head_data->nodename || strcmp(head_data->nodename, "") == 0)
		{
			PRINT_ERROR("Error: Node name is not existed\n");
			return SETUP_INVALID_CONTENT;
		}

		head2_data = head_data->next;
		while (head2_data)
		{
			if (!head2_data->nodename || strcmp(head2_data->nodename, "") == 0)
			{
				PRINT_ERROR("Error: Node name is not existed\n");
				return SETUP_INVALID_CONTENT;
			}
			else if (strcasecmp(head_data->nodename, head2_data->nodename) == 0)
			{
				PRINT_ERROR("Error: Duplicate node name in node data: %s\n", head_data->nodename);
				return SETUP_INVALID_CONTENT;
			}
			head2_data = head2_data->next;
		}
		head_data = head_data->next;
	}

	return rc;
}

/* Get all child node for each node
 *
 * @param[in] parent_node - node in structure
 * @param[out] child_list - list of child nodes
 *
 * @return Return code
 */
static ReturnCode
get_all_child(child_node_list * parent_node, nodes * *child_list)
{
	ReturnCode	rc = SETUP_OK;
	child_node_list *p;
	nodes	   *new_child_data = NULL;
	nodes	   *new_list = NULL;
	int			i;

	p = parent_node->children;
	/* If node has no child, skip */
	if (p == NULL)
		return SETUP_OK;
	for (i = 0; i < parent_node->child_nums; i++)
	{
		rc = get_all_child(&p[i], &new_list);
		if (rc != SETUP_OK)
			return rc;
	}
	if (!p->node_name)
	{
		PRINT_ERROR("Error: Node name is not existed\n");
		return SETUP_INVALID_CONTENT;
	}
	new_child_data = create_node();
	new_child_data->nodename = malloc_nodedata(p->node_name);
	if (!new_child_data->nodename)
	{
		PRINT_ERROR("Error: out of memory\n");
		return SETUP_NOMEM;
	}
	new_list = add_node(new_list, new_child_data);
	if (new_list == NULL)
	{
		free_nodedata(new_child_data);
		return SETUP_PARSE_FAILED;
	}
	*child_list = new_list;
	return rc;
}

/* Detect if any child node have same server information with child node
 *
 * @param[in] parent_node - parent node
 * @param[in] child_list - child node list of parent node
 * @param[in] nodes_data - nodes information list
 *
 * @return Return code
 */
static ReturnCode
detect_loop(child_node_list * parent_node, nodes * child_list, nodes * nodes_data)
{
	nodes	   *child_data = NULL;
	nodes	   *parent_data = NULL;
	nodes	   *head_data = NULL;
	ReturnCode	rc = SETUP_OK;

	if (nodes_data == NULL)
	{
		PRINT_ERROR("Error: Node data is not existed\n");
		return SETUP_INVALID_PARAM;
	}

	parent_data = search_nodes(parent_node->node_name, nodes_data);
	if (!parent_data)
		return SETUP_INVALID_CONTENT;
	head_data = child_list;

	while (head_data)
	{
		if (!head_data->nodename || strcmp(head_data->nodename, "") == 0)
		{
			PRINT_ERROR("Error: Node name is not existed\n");
			return SETUP_INVALID_CONTENT;
		}
		child_data = search_nodes(head_data->nodename, nodes_data);
		if (!child_data)
			return SETUP_INVALID_CONTENT;

		/* Parent node and child node are PGSpider and have the same configuration */
		if (strcmp(parent_data->fdw, child_data->fdw) == 0
			&& strcmp(parent_data->fdw, "pgspider_fdw") == 0
			&& strcmp(parent_data->ip, child_data->ip) == 0
			&& strcmp(parent_data->port, child_data->port) == 0
			&& strcmp(parent_data->dbname, child_data->dbname) == 0)
		{
			PRINT_ERROR("Error: There is a loop in structure.\n");
			return SETUP_INVALID_CONTENT;
		}
		head_data = head_data->next;
	}
	return rc;
}

/* Verify the node structure
 * If any loop in the structure, there is an error returned.
 *
 * @param[in] node_data - node information data list
 * @param[in] node_list - node structure
 *
 * @return Return code
 */
static ReturnCode
verify_structure(nodes * nodes_data, child_node_list * node_list)
{
	child_node_list *p;
	nodes	   *child_list = NULL;
	ReturnCode	rc = SETUP_OK;
	int			i;

	p = node_list->children;
	if (p != NULL)
	{
		for (i = 0; i < node_list->child_nums; i++)
		{
			rc = verify_structure(nodes_data, &p[i]);
			if (rc != SETUP_OK)
				return rc;
		}
	}

	rc = get_all_child(node_list, &child_list);
	if (rc != SETUP_OK)
		return rc;

	rc = detect_loop(node_list, child_list, nodes_data);
	if (rc != SETUP_OK)
		return rc;

	return rc;
}

/* Parse json file for root part
 * Malloc and copy node data(All data are string)
 *
 * @param[in] element - jansson element
 * @param[in,out] nodes_data - node information data list
 *
 * @return none
 */
static ReturnCode
load_nodedata(json_t * element, nodes * *nodes_list)
{
	ReturnCode	rc = SETUP_OK;
	json_t	   *value;
	nodes	   *new_data;
	int			index = 0;
	nodes	   *nodes_data = NULL;

	if (nodes_list == NULL)
	{
		PRINT_ERROR("Error: Invalid nodes list parameter.\n");
		return SETUP_INVALID_PARAM;
	}
	switch (json_typeof(element))
	{
		case JSON_ARRAY:
			json_array_foreach(element, index, value)
			{
				new_data = create_node();
				/* parse options */
				rc = parse_conf(value, new_data);
				if (rc != SETUP_OK)
				{
					free_nodedata(new_data);
					return rc;
				}

				nodes_data = add_node(nodes_data, new_data);
				if (nodes_data == NULL)
				{
					free_nodedata(new_data);
					return SETUP_PARSE_FAILED;
				}
			}
			break;
		default:
			PRINT_ERROR("Error: JSON file format is invalid.\nOnly array is supported.\n");
			rc = SETUP_PARSE_FAILED;
	}
	*nodes_list = nodes_data;
	return rc;
}

/*
 * Read nodes parameter from nodes_data.
 * And execute CREATE EXTENSION by admin user in PGSpider.
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 * @param[in] timeout - Tineout time when retrying to connect to PGSpider
 *
 * @return Return code
 */
static ReturnCode
set_pgspider_node_admin(nodes * nodes_data, child_node_list * child_node, int timeout)
{
	ReturnCode	rc;
	nodes	   *parent_node,
			   *child_node_data;
	child_node_list *p;
	PGconn	   *conn = NULL;
	int			i;

	parent_node = search_nodes(child_node->node_name, nodes_data);
	if (parent_node == NULL)
		return SETUP_INVALID_CONTENT;

	if (strcmp(parent_node->fdw, "pgspider_fdw") != 0)
	{
		if (child_node->child_nums != 0)
		{
			PRINT_ERROR("Error: root node %s is not pgspider fdw, %s\n", child_node->node_name, parent_node->fdw);
			return SETUP_INVALID_CONTENT;
		}
		return SETUP_OK;
	}

	/* Connect to PGSpider with admin user. */
	rc = create_connection(&conn, parent_node, 1, timeout);
	if (rc != SETUP_OK)
		return rc;

	/* Begin transaction. */
	rc = query_execute(conn, "BEGIN;");
	if (rc != SETUP_OK)
	{
		PQfinish(conn);
		return rc;
	}

	/*
	 * Delete all existing settings with extensions and records in
	 * pg_spd_node_info.
	 */
	rc = query_execute(conn, "DELETE FROM pg_spd_node_info;");
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	rc = drop_extensions(conn);
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	/* Create extension in parent node. */
	rc = create_extension("pgspider_core_fdw", conn);
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	/* Give a permission for allowing normal user to create schema. */
	rc = give_database_permission(parent_node->dbname, parent_node->user, conn);
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	/* Give a permission using the FDW to normal user. */
	rc = give_fdw_permission("pgspider_core_fdw", parent_node->user, conn);
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	/*
	 * Set child node foreign server and import child schema. This routine
	 * include create parent foreign table.
	 */
	p = child_node->children;
	for (i = 0; i < child_node->child_nums; i++)
	{
		child_node_data = search_nodes(p[i].node_name, nodes_data);
		if (child_node_data == NULL)
		{
			rc = SETUP_INVALID_CONTENT;
			goto err_set_pgspider_node_admin;
		}

		if (child_node_data->fdw == NULL)
		{
			PRINT_ERROR("Error: Invalid JSON text. Can not find 'FDW'\n");
			rc = SETUP_INVALID_CONTENT;
			goto err_set_pgspider_node_admin;
		}

		/* Create extension. */
		rc = create_extension(child_node_data->fdw, conn);
		if (rc != SETUP_OK)
			goto err_set_pgspider_node_admin;

		if (strcasecmp(child_node_data->fdw, "file_fdw") == 0)
		{
			char	   *missing_content = NULL;

			if (child_node_data->dirpath == NULL)
				missing_content = "dirpath";
			else if (child_node_data->table == NULL)
				missing_content = "table";

			if (missing_content != NULL)
			{
				PRINT_ERROR("Error: %s is not specified for file_fdw. \n", missing_content);
				rc = SETUP_INVALID_CONTENT;
				goto err_set_pgspider_node_admin;
			}

			rc = load_filefdw_admin(conn, child_node_data, child_node->node_name, parent_node->user);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node_admin;
		}
		else
		{
			/* Set table data for keep alive. */
			rc = set_child_ip(conn, child_node_data);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node_admin;
		}

		/* Give a permission using the FDW to normal user. */
		rc = give_fdw_permission(child_node_data->fdw, parent_node->user, conn);
		if (rc != SETUP_OK)
			goto err_set_pgspider_node_admin;
	}

	rc = query_execute(conn, "COMMIT;");
	if (rc != SETUP_OK)
		goto err_set_pgspider_node_admin;

	PQfinish(conn);

	return SETUP_OK;

err_set_pgspider_node_admin:
	query_execute(conn, "ROLLBACK;");
	drop_all_fdws(conn);
	PQfinish(conn);
	return rc;
}

/*
 * Read nodes parameter from nodes_data.
 * And execute CREATE SERVER, USER MAPPING, IMPORT FOREIGN SCHEMA by normal user in PGSpider.
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 * @param[in] timeout - Tineout time when retrying to connect to PGSpider
 *
 * @return none
 */
static ReturnCode
set_pgspider_node(nodes * nodes_data, child_node_list * child_node, int timeout)
{
	ReturnCode	rc;
	nodes	   *parent_node,
			   *child_node_data;
	child_node_list *p;
	PGconn	   *conn = NULL;
	int			i;

	parent_node = search_nodes(child_node->node_name, nodes_data);
	/* Already checked in set_pgspider_node_admin. */
	assert(parent_node != NULL);

	if (strcmp(parent_node->fdw, "pgspider_fdw") != 0)
		return SETUP_OK;

	/* Connect to PGSpider with normal user. */
	rc = create_connection(&conn, parent_node, 0, timeout);
	if (rc != SETUP_OK)
		return rc;

	/* Start a transaction for operations of normal user. */
	rc = query_execute(conn, "BEGIN;");
	if (rc != SETUP_OK)
	{
		PQfinish(conn);
		return rc;
	}

	/* Set foreign server in parent node  */
	rc = node_set_spdcore(parent_node, conn);
	if (rc != SETUP_OK)
		goto err_set_pgspider_node;

	/*
	 * Set child node foreign server and import child schema. This routine
	 * include create parent foreign table.
	 */
	p = child_node->children;
	for (i = 0; i < child_node->child_nums; i++)
	{
		child_node_data = search_nodes(p[i].node_name, nodes_data);
		/* Already checked in set_pgspider_node_admin. */
		assert(child_node_data != NULL);
		assert(child_node_data->fdw != NULL);

		if (strcasecmp(child_node_data->fdw, "file_fdw") == 0)
		{
			rc = load_filefdw(conn, child_node_data, child_node->node_name);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node;
		}
		else
		{
			rc = node_set(child_node_data, conn);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node;
			rc = import_schema(conn, child_node_data);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node;
			rc = rename_foreign_table(conn, child_node_data->nodename, child_node_data->fdw, parent_node->nodename);
			if (rc != SETUP_OK)
				goto err_set_pgspider_node;
		}
	}
	rc = query_execute(conn, "COMMIT;");
	if (rc != SETUP_OK)
		goto err_set_pgspider_node;

	PQfinish(conn);
	printf("FINISH %s \n", parent_node->nodename);

	return SETUP_OK;

err_set_pgspider_node:
	query_execute(conn, "ROLLBACK;");
	PQfinish(conn);
	return rc;
}

/*
 * Execute set_pgspider_node_all() recursively.(depth-first search)
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 * @param[in] timeout - Tineout time when retrying to connect to PGSpider
 *
 * @return none
 */
static ReturnCode
set_pgspider_node_walker(nodes * nodes_data, child_node_list * child_node, char isAdmin, int timeout)
{
	ReturnCode	rc;
	int			i;
	child_node_list *p;

	p = child_node->children;
	if (p != NULL)
	{
		for (i = 0; i < child_node->child_nums; i++)
		{
			rc = set_pgspider_node_walker(nodes_data, &p[i], isAdmin, timeout);
			if (rc != SETUP_OK)
				return rc;
		}
	}
#ifdef PRINT_DEBUG
	printf("set node %s\n", child_node->node_name);
#endif
	if (isAdmin == 0)
	{
		rc = set_pgspider_node(nodes_data, child_node, timeout);
		if (rc != SETUP_OK)
			drop_all_fdws_with_connect(nodes_data, child_node, timeout);
		return rc;
	}
	else
		return set_pgspider_node_admin(nodes_data, child_node, timeout);
}

/*
 * Execute set_pgspider_node_all() recursively.(depth-first search)
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 * @param[in] timeout - Tineout time when retrying to connect to PGSpider
 *
 * @return none
 */
static ReturnCode
set_pgspider_node_all(nodes * nodes_data, child_node_list * child_node, int timeout)
{
	ReturnCode	rc;

	rc = set_pgspider_node_walker(nodes_data, child_node, 1, timeout);
	if (rc != SETUP_OK)
		return rc;

	rc = set_pgspider_node_walker(nodes_data, child_node, 0, timeout);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

/*
 * Load tier list json file (depth-first search)
 * Firstly, set pgspider table in leaf-node.
 * Next, set table in parent leaf node.
 * Order of setting is following.
 *		    ---
 *		   | 7 |
 *	        ---
 *     ------|-------
 *	   |             |
 * 	  ---           ---
 *	 | 3 |         | 6 |
 *    ---           ---
 *     |             |
 *   --- ---       --- ---
 *  |       |      |      |
 *  ---	   ---    ---    ---
 * | 1 |  | 2 |  | 4 |  | 5 |
 *  ---    ---    ---    ---
 *
 * child_node_list is array.
 * child_node_list->next is child nodes array head pointer.
 *
 *          ---
 *         | 7 |
 *          ---
 *         |
 *        -------
 *       | 3 | 6 |
 *        -------
 *    -----|   |-----
 *   |              |
 *  -------         -------
 * | 1 | 2 |       | 4 | 5 |
 *  -------         -------
 *
 * @param[in] element - jansson element
 * @param[in,out] child_node - child node list
 *
 * @return none
 */
static ReturnCode
load_tier_json(json_t * element, child_node_list * node_list)
{
	const char *key;
	json_t	   *value;
	json_t	   *value2;
	int			i = 0;
	child_node_list *p;
	child_node_list *new_child_node_list = NULL;

	json_object_foreach(element, key, value)
	{
		switch (json_typeof(value))
		{
			case JSON_ARRAY:

				/*
				 * When child node is pgspider fdw, pgspider node has "Nodes"
				 * TAG. There are child node setting.
				 */
				new_child_node_list = malloc(sizeof(child_node_list) * json_array_size(value));
				if (new_child_node_list == NULL)
				{
					PRINT_ERROR("Error: out of memory\n");
					return SETUP_NOMEM;
				}
				memset(new_child_node_list, 0, sizeof(child_node_list) * json_array_size(value));
				node_list->children = new_child_node_list;
				node_list->child_nums = json_array_size(value);
				p = new_child_node_list;
				json_array_foreach(value, i, value2)
				{
					ReturnCode	rc;

					p->node_name = NULL;
					p->children = NULL;
					p->child_nums = 0;
					rc = load_tier_json(value2, p);
					if (rc != SETUP_OK)
						return rc;
					p++;
				}
				break;
			case JSON_STRING:
				if (strcasecmp(key, NODENAME) == 0)
				{
					node_list->node_name = malloc_nodedata(json_string_value(value));
					if (node_list->node_name == NULL)
					{
						PRINT_ERROR("Error: out of memory \n");
						return SETUP_NOMEM;
					}
				}
				/* firstly, create child node list with recursive call */
				else if (strcasecmp(key, NODES) == 0)
				{
					/* skip json array, nothing to do */
				}
				else
				{
					PRINT_ERROR("Error: JSON format is wrong. Invalid TAG is %s.\n Only \"Nodename\" or \"Nodes\" are allowed.\n", key);
					return SETUP_PARSE_FAILED;
				}
				break;
			default:
				PRINT_ERROR("Error: JSON format is wrong. \n");
				return SETUP_PARSE_FAILED;
		}
	}

	return SETUP_OK;
}

#ifdef PRINT_DEBUG
/*
 * Print node structure for debug.
 *
 * @param[in] node_list - Child node list
 * @param[in] tier - Node depth
 *
 * @return none
 */
static void
print_struct(child_node_list * node_list, int tier)
{
	child_node_list *p = node_list->children;
	int			i;

	for (i = 0; i < tier; i++)
		printf(" ");
	printf("%d %s \n", tier, node_list->node_name);
	if (p != NULL)
	{
		for (i = 0; i < node_list->child_nums; i++)
		{
			print_struct(&p[i], tier + 1);
		}
	}
}
#endif

int
main(int argc, char **argv)
{
	ReturnCode	rc = SETUP_OK;
	int			fd = 0;
	char		buf[READBUF_REN];
	json_error_t error;
	json_t	   *root = NULL;
	json_t	   *root2 = NULL;
	nodes	   *nodes_data = NULL;
	child_node_list *node_list = NULL;
	config_params params = {0};
	char		info_file[PATH_MAX] = {0};
	char		str_file[PATH_MAX] = {0};

	/* Get parameters from arguments and environmental variables. */
	analyze_env(&params);

	rc = analyze_arguments(argc, argv, &params);
	if (rc != SETUP_OK)
		return rc;

	rc = checkConfig(&params);
	if (rc != SETUP_OK)
		return rc;

	printConfig(params);

	/* load config file and create all db information list */
	getFilePath(params.config_dir, params.node_info_file, info_file);
	fd = open(info_file, O_RDONLY);
	if (fd < 0)
	{
		PRINT_ERROR("Error: Can not open file %s\n", info_file);
		return SETUP_IO_ERROR;
	}
	if (read(fd, buf, READBUF_REN - 1) == 0)
	{
		PRINT_ERROR("Error: Can not read file %s \n", info_file);
		rc = SETUP_IO_ERROR;
		goto end_main;
	}

	root = json_loads(buf, 0, &error);
	if (root == NULL)
	{
		PRINT_ERROR("Error: %s is invalid json file \n", info_file);
		rc = SETUP_PARSE_FAILED;
		goto end_main;
	}
	rc = load_nodedata(root, &nodes_data);
	if (rc != SETUP_OK)
		goto end_main;

	/* Verify the non-unique node name */
	rc = verify_nodename(nodes_data);
	if (rc != SETUP_OK)
		goto end_main;

	json_decref(root);
	root = NULL;
	close(fd);
	fd = 0;

	/* load structure file and create list */
	getFilePath(params.config_dir, params.node_struct_file, str_file);
	fd = open(str_file, O_RDONLY);
	if (fd < 0)
	{
		PRINT_ERROR("Error: Can not open file %s \n", str_file);
		rc = SETUP_IO_ERROR;
		goto end_main;
	}

	memset(buf, 0, READBUF_REN);
	read(fd, buf, READBUF_REN - 1);
	if (read(fd, buf, READBUF_REN - 1))
	{
		PRINT_ERROR("Error: Can not read file %s \n", str_file);
		rc = SETUP_IO_ERROR;
		goto end_main;
	}

	root2 = json_loads(buf, 0, &error);
	if (root2 == NULL)
	{
		PRINT_ERROR("Error: %s is invalid json file \n", str_file);
		rc = SETUP_PARSE_FAILED;
		goto end_main;
	}
	node_list = calloc(1, sizeof(child_node_list));
	if (node_list == NULL)
	{
		PRINT_ERROR("Error: out of memory\n");
		rc = SETUP_NOMEM;
		goto end_main;
	}
	rc = load_tier_json(root2, node_list);
	if (rc != SETUP_OK)
		goto end_main;

	/* Verify the structure */
	rc = verify_structure(nodes_data, node_list);
	if (rc != SETUP_OK)
		goto end_main;

#ifdef PRINT_DEBUG
	print_struct(node_list, 0);
#endif

	/* create foreign server and foreign table on pgspider */
	rc = set_pgspider_node_all(nodes_data, node_list, params.timeout);
	if (rc != SETUP_OK)
		goto end_main;

end_main:
	if (fd > 0)
		close(fd);
	if (root != NULL)
		json_decref(root);
	if (root2 != NULL)
		json_decref(root2);
	free_nodedata(nodes_data);
	free_childnode(node_list);

	if (rc == SETUP_OK)
		printf("Success to create pgspider tables.\n");

	return rc;
}
