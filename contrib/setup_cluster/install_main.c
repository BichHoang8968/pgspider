/* -------------------------------------------------------------------------
 *
 * pgspider_install.c
 * Copyright (c) 2019, TOSHIBA
 *
 * -------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include "libpq-fe.h"
#include <unistd.h>
#include <fcntl.h>

#include <assert.h>
#include <string.h>
#include <memory.h>
#include <jansson.h>
#include <dirent.h>
#include <sys/stat.h>

#include "install_util.h"
#include "pgspider_node.h"

static void parse_conf(const char *name, json_t * element, nodes * nodes_data, int *numconf);

typedef struct child_node_list
{
	char	   *node_name;
	struct child_node_list *children;
	int			child_nums;
}			child_node_list;


/*
 * drop extensions
 *
 * @param[in] conn - Connection for pgspider
 *
 * @return none
 */
static void
drop_extension(PGconn *conn)
{
	char		query[QUERY_LEN];
	int			i;

	for (i = 0; i < extension_size; i++)
	{
		sprintf(query, "DROP EXTENSION IF EXISTS %s CASCADE;", spd_func[i].name);
		query_execute(conn, query);
	}
}

/*
 * Set node data in keep-alive system table
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] node_data - Child node info
 *
 * @return none
 */
static void
set_child_ip(PGconn *conn, nodes * node_data)
{
	char		query[QUERY_LEN];

	if (node_data->ip == NULL)
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','127.0.0.1');", node_data->name, node_data->fdw);
	else if(strcmp(node_data->fdw,"influxdb_fdw")==0)
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','127.0.0.1');", node_data->name, node_data->fdw);
	else
		sprintf(query, "INSERT INTO pg_spd_node_info VALUES(0,'%s','%s','%s');", node_data->name, node_data->fdw, node_data->ip);
	query_execute(conn, query);
}

/*
 * replace '/' to '_'. This is for file fdw
 *
 * @param[in] str - directory path
 *
 * @return replace string
 */
static char *
replace_sla(char *str)
{
	char	   *result;
	char	   *p;
	int			len;
	int         start=0,end=0;

	if(str==NULL)
		exit(1);
	len=strlen(str) + 1;
	result = malloc(sizeof(char) * len);
	if (result == NULL)
		exit(1);
	if(str[0]=='/')
		start=1;
	if(str[len-2]=='/')
		end=1;
	strncpy(result, str+start,len - 1 - start- end);
	result[len - 1-start- end]='\0';
	p = strchr(result, '/');
	while (p)
	{
		*p = '_';
		p = strchr(p+1, '/');
	}
	return result;
}

/*
 * Execute import foreign schema
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] server_name - Child node server name
 *
 * @return none
 */
static void
import_schema(PGconn *conn, nodes *node_data)
{
	char		query[QUERY_LEN] = {0};

	sprintf(query, "DROP SCHEMA IF EXISTS temp_schema;");
	query_execute(conn, query);
	sprintf(query, "CREATE SCHEMA temp_schema;");
	query_execute(conn, query);
	if(strcmp(node_data->fdw,"mysql_fdw")==0)
		sprintf(query, "IMPORT FOREIGN SCHEMA %s FROM server %s INTO temp_schema;",node_data->dbname, node_data->name);
	else
		sprintf(query, "IMPORT FOREIGN SCHEMA public FROM server %s INTO temp_schema;", node_data->name);

	query_execute(conn, query);
}


/*
 * Load and set file fdw tables.
 * File fdw table name is directory path.
 * Same directory data is same table.
 *
 * ex.
 * /csv/data/data1.csv, /csv/data/data2.csv
 * Parent table name is csv_data
 * Child table name are csv_data__data1__0 and csv_data__data2__0
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] node_data - Nodes data
 * @param[in] parent_server - Parent(pgspider) node name
 *
 * @return none
 */
static void
load_filefdw(PGconn *conn, nodes * node_data, char *parent_server)
{
	DIR		   *dirp={0};
	struct dirent *p={0};
	char		query[QUERY_LEN];
	char		filename[QUERY_LEN];
	char		tablename[QUERY_LEN];
	char	   *dotp=NULL;

	if ((dirp = opendir(node_data->dirpath)) == NULL)
	{
		ERROR("Error: Can't open directory %s\n", node_data->dirpath);
		exit_error(conn);
	}
	/* CREATE parent table */
	sprintf(query, "CREATE FOREIGN TABLE IF NOT EXISTS %s(%s,__spd_url text) server %s;", node_data->nodename, node_data->column, parent_server);
	query_execute(conn, query);
	p = readdir(dirp);
	/* read file name in directory */
	while (p != NULL)
	{
		if (p->d_type != DT_REG || DT_UNKNOWN)
		{
			p = readdir(dirp);
			continue;
		}
		if(dirp == NULL) break;
		strcpy(filename, p->d_name);
		dotp = strchr(p->d_name, '.');
		if(dotp==NULL)
			strcpy(tablename, p->d_name);
		else{
			strncpy(tablename, p->d_name, (dotp - p->d_name));
			tablename[dotp - p->d_name] = '\0';
		}
		node_data->tablename = p->d_name;
		sprintf(node_data->name, "%s", tablename);
		/* set table data for keep alive */
		set_child_ip(conn, node_data);
		/* set foreign server */
		node_set(node_data, conn);
		/* set foreign table */
		mapping_set_file(node_data, conn, filename);
		p = readdir(dirp);
	}
	if (closedir(dirp) != 0)
	{
		ERROR( "Error:Can't close directory %s\n", node_data->dirpath);
		exit_error(conn);
	}
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
static void
rename_foreign_table(PGconn *conn, char *server_name, char *fdw, char *parent_node_name)
{
	int			i,
				k;
	PGresult   *res;
	char		query[QUERY_LEN] = "SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema='temp_schema'";

	/* get table name from temp schema */
	res = PQexec(conn, query);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		ERROR( "Can not find child tables %s \n%s \n%s\n",
			   query,
				PQresStatus(PQresultStatus(res)),
				PQerrorMessage(conn));
		exit_error(conn);
	}

	/* change table name and schema */
	for (i = 0; i < PQntuples(res); i++)
	{
		char		select_column_query[QUERY_LEN];
		char		alter_query[QUERY_LEN];
		char		create_query[QUERY_LEN];
		PGresult   *select_column_res;
		PGresult   *select_column_res_tmp;
		char		newtable[QUERY_LEN];
		int			spd_flag = 0;

		sprintf(newtable, "%s__%s__0", PQgetvalue(res, i, 0), server_name);
		sprintf(select_column_query, "SELECT c.oid,n.nspname,c.relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relname OPERATOR(pg_catalog.~) '^(%s)$' AND n.nspname OPERATOR(pg_catalog.~) '^(temp_schema)$' ORDER BY 2, 3;", PQgetvalue(res, i, 0));
#ifdef PRINT_DEBUG
		printf("select=%s \n",select_column_query);
#endif
		select_column_res_tmp = PQexec(conn, select_column_query);
		if (PQresultStatus(select_column_res_tmp) != PGRES_TUPLES_OK)
		{
		    ERROR("%s\n", PQerrorMessage(conn));
			exit_error(conn);
		}
		sprintf(select_column_query, "SELECT a.attname,pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_catalog.pg_attribute a WHERE a.attrelid = '%s' AND a.attnum > 0 AND NOT a.attisdropped ORDER BY a.attnum;", PQgetvalue(select_column_res_tmp, 0, 0));
		select_column_res = PQexec(conn, select_column_query);
		if (PQresultStatus(select_column_res_tmp) != PGRES_TUPLES_OK)
		{
		    ERROR("%s\n", PQerrorMessage(conn));
			exit_error(conn);
		}
		
		sprintf(alter_query, "ALTER TABLE temp_schema.%s RENAME TO %s;", PQgetvalue(res, i, 0), newtable);
		query_execute(conn, alter_query);
		sprintf(alter_query, "ALTER TABLE temp_schema.%s SET schema public;", newtable);
		query_execute(conn, alter_query);
		/* griddb fdw does not add table name option. we add here. */
		if(strcmp(fdw,"griddb_fdw")==0){
			sprintf(alter_query, "ALTER FOREIGN TABLE %s OPTIONS (table_name '%s');",newtable,PQgetvalue(res, i, 0));
			query_execute(conn, alter_query);
		}

		/* Create parent table */
		sprintf(create_query, "CREATE FOREIGN TABLE IF NOT EXISTS %s(", PQgetvalue(res, i, 0));
		for (k = 0; k < PQntuples(select_column_res); k++)
		{
			if (strcmp(PQgetvalue(select_column_res, k, 0), "__spd_url") == 0){
				spd_flag = 1;
			}
			else{
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
		query_execute(conn, create_query);
		PQclear(select_column_res);
		PQclear(select_column_res_tmp);
	}
	PQclear(res);
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
	{
		ERROR( "Error: out of memory\n");
		exit(1);
	}
	strcpy(data, value);
	return data;
}

/*
 *  Search node information object from node list
 *
 * @param[in,out] nodename - searching name
 * @param[in,out] node - All node informations
 *
 * @return nodes
 */
static nodes * search_nodes(char *nodename, nodes * node)
{
	nodes	   *tempnode = node;

	while (tempnode)
	{
		if (tempnode->name != NULL && strcmp(nodename, tempnode->name) == 0)
			return tempnode;
		tempnode = tempnode->next;
	}
	ERROR( "Error:Can not find \"%s\" in %s. Please check node name in %s.\n", nodename,INFOFILENAME,STRFILENAME);
	exit(1);
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

	pnext = node->next;
	while (pnext)
	{
		free(pnext->nodename);
		free(pnext->fdw);
		free(pnext->name);
		free(pnext->ip);
		free(pnext->port);
		free(pnext->user);
		free(pnext->pass);
		free(pnext->dbname);
		free(pnext->clustername);
		free(pnext->notification_member);
		free(pnext->dbpath);
		free(pnext->dirpath);
		free(pnext->column);
		free(pnext->servername);

		node->next = pnext->next;
		free(pnext);
		pnext = node->next;
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

	p = child_node->children;
	for (i = 0; i < child_node->child_nums; i++){
		if(p[i].children)
			free_childnode(&p[i]);
		printf("free %s\n",p[i].node_name);
		free(p[i].node_name);
	}
	free(p);
}

/*
 * Parse json file and set child node settin
 *
 * @param[in] name - jansson dbname element
 * @param[in] element - jansson other infomation element
 * @param[in,out] nodes_data - node information data list
 * @param[in,out] numconf - number of options
 *
 * @return string value
 */
static void
parse_conf(const char *name, json_t * element, nodes * nodes_data, int *numconf)
{
	const char *key;
	json_t	   *value;

	nodes_data->name = malloc_nodedata(name);
	switch (json_typeof(element))
	{
		case JSON_OBJECT:
			json_object_foreach(element, key, value)
			{
				if (json_string_value(value) == NULL)
				{
					ERROR( "error: %s is NULL parameter. \n", key);
					exit(1);
				}
				if (strcasecmp(key, "fdw") == 0)
					nodes_data->fdw = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "ip") == 0)
					nodes_data->ip = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "host") == 0)
					nodes_data->ip = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "port") == 0)
					nodes_data->port = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "user") == 0)
					nodes_data->user = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "password") == 0)
					nodes_data->pass = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "dbname") == 0)
					nodes_data->dbname = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "dirpath") == 0)
					nodes_data->dirpath = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "column") == 0)
					nodes_data->column = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "dbpath") == 0)
					nodes_data->dbpath = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "clustername") == 0)
					nodes_data->clustername = malloc_nodedata(json_string_value(value));
				else if (strcasecmp(key, "notification_member") == 0)
					nodes_data->notification_member = malloc_nodedata(json_string_value(value));
				else
				{
					ERROR( "Error: %s is not fdw parameter. \n", key);
					exit(1);
				}
			}
			nodes_data++;
			*(numconf) += 1;
			break;
		default:
			ERROR( "Error: Json format is wrong. Only object appear here. \n");
			exit(1);
	}
}

/* Parse json file for root part
 * Malloc and copy node data(All data are string)
 *
 * @param[in] element - jansson element
 * @param[in,out] nodes_data - node information data list
 * @param[in,out] numconf - number of options
 *
 * @return none
 */
static void
load_nodedata(json_t * element, nodes * nodes_data, int *numconf)
{
	const char *key;
	json_t	   *value;
	nodes	   *new_data,
			   *p;

	p = nodes_data;
	while (p->next != NULL)
		p = p->next;
	switch (json_typeof(element))
	{
		case JSON_OBJECT:
			json_object_foreach(element, key, value)
			{
				new_data = malloc(sizeof(nodes));
				memset(new_data,0,sizeof(nodes));
				if (!new_data)
				{
					ERROR( "Error: out of memory\n");
					exit(1);
				}
				p->next = new_data;
				p = new_data;
				/* parse options */
				parse_conf(key, value, p, numconf);
			}
			break;
		case JSON_ARRAY:
			break;
		case JSON_STRING:
			break;
		default:
			ERROR( "error: Json File is broken.\n");
			exit(1);
	}
}


/*
 * Read nodes parameter from nodes_data.
 * And execute CREATE SERVER, USER MAPPING, IMPORT FOREIGN SCHEMA.
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 *
 * @return none
 */

static void
set_pgspider_node(nodes * nodes_data, child_node_list * child_node)
{
	nodes	   *parent_node,
			   *child_node_data;
	child_node_list *p;
	PGconn	   *conn = NULL;
	char	   *tablename;
	int			i;

	parent_node = search_nodes(child_node->node_name, nodes_data);
	if (strcmp(parent_node->fdw, "pgspider_fdw") != 0){
		if(child_node->child_nums!=0){
			ERROR("root node %s is not pgspider fdw, %s\n",child_node->node_name,parent_node->fdw);
			exit(1);
		}
		return;
	}
	create_connection(&conn, parent_node);

	/* begin, delete all previous settings with extensions. */
	query_execute(conn, "BEGIN;");
	query_execute(conn, "DELETE FROM pg_spd_node_info;");
	drop_extension(conn);

	/* set foreign server in parent node  */
	node_set_spdcore(parent_node, conn);
	/*
	 * Set child node foreign server and import child schema. This routine
	 * include create parent foreign table.
	 */
	p = child_node->children;
	for (i = 0; i < child_node->child_nums; i++)
	{
		child_node_data = search_nodes(p[i].node_name, nodes_data);
		if (child_node_data->fdw == NULL)
		{
			ERROR( "Error: Invalid JSON text. Can not find 'FDW'\n");
			query_execute(conn, "ROLLBACK;");
			exit(1);
		}
		else if (strcasecmp(child_node_data->fdw, "file_fdw") == 0)
		{
			tablename = replace_sla(child_node_data->dirpath);
			child_node_data->nodename = tablename;
			load_filefdw(conn, child_node_data, child_node->node_name);
		}
		else
		{
			node_set(child_node_data, conn);
			set_child_ip(conn, child_node_data);
			import_schema(conn, child_node_data);
			rename_foreign_table(conn, child_node_data->name, child_node_data->fdw, parent_node->name);
		}
	}
	query_execute(conn, "COMMIT;");
	PQfinish(conn);
	printf("FINISH %s \n", parent_node->name);
}

/*
 * Execute set_pgspider_node_all() recursively.(depth-first search)
 *
 * @param[in] nodes_data - node information data list
 * @param[in] child_node - child node list
 *
 * @return none
 */
static void
set_pgspider_node_all(nodes * nodes_data, child_node_list * child_node)
{
	int			i;
	child_node_list *p;

	p = child_node->children;
	if (p != NULL)
	{
		for (i = 0; i < child_node->child_nums; i++)
		{
			set_pgspider_node_all(nodes_data, &p[i]);
		}
	}
#ifdef PRINT_DEBUG
	printf("set node %s\n", child_node->node_name);
#endif
	set_pgspider_node(nodes_data, child_node);
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
static void
load_tier_json(json_t * element, child_node_list * node_list)
{
	const char *key;
	char	   *nodename = NULL;
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
				memset(new_child_node_list,0,sizeof(child_node_list) * json_array_size(value));
				if (new_child_node_list == NULL)
				{
					ERROR( "Error: out of memory\n");
					exit(1);
				}
				node_list->children = new_child_node_list;
				node_list->child_nums = json_array_size(value);
				p = new_child_node_list;
				json_array_foreach(value, i, value2)
				{
					p->node_name = NULL;
					p->children = NULL;
					p->child_nums = 0;
					load_tier_json(value2, p);
					p++;
				}
				break;
			case JSON_STRING:
				if (strcasecmp(key, NODENAME) == 0)
				{
					nodename = (char *) json_string_value(value);
					node_list->node_name = malloc(sizeof(char) * strlen(nodename) + 1);
					if(node_list==NULL)
					{
							ERROR( "Error : malloc error \n");
							exit(1);
					}
						strcpy(node_list->node_name, nodename);
				}
				/* firstly, create child node list with recursive call */
				else if (strcasecmp(key, NODES) == 0)
				{
					/* skip json array, nothing to do */
				}
				else
				{
					ERROR( "Error:JSON format is wrong. Invalid TAG is %s.\n Only \"Nodename\" or \"Nodes\" are allowed.\n", key);
					exit(1);
				}
				break;
			default:
				ERROR( "Error : Json format is wrong. \n");
				exit(1);
		}
	}
}

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

int
main(int argc, char **argv)
{
	int			fd;
	char		buf[READBUF_REN];
	json_error_t error;
	json_t	   *root;
	json_t	   *root2;
	int			numconf;
	nodes	   *nodes_data = NULL;
	child_node_list *node_list = NULL;

	/* load config file and create all db information list */
	fd = open(INFOFILENAME, O_RDONLY);
	if (fd == 0)
	{
		ERROR( "Error : Can not open file %s\n", INFOFILENAME);
		exit(1);
	}
	if (read(fd, buf, READBUF_REN - 1) == 0)
	{
		ERROR( "Error : Can not read file %s \n", INFOFILENAME);
		close(fd);
		exit(1);
	}

	root = json_loads(buf, 0, &error);
	if (root == NULL)
	{
		ERROR( "Error : %s is invalid json file \n", INFOFILENAME);
		close(fd);
		exit(1);
	}
	nodes_data = malloc(sizeof(nodes));
	if (nodes_data == NULL)
	{
		ERROR( "Error : malloc error \n");
		close(fd);
		exit(1);
	}
	memset(nodes_data,0,sizeof(nodes));
	load_nodedata(root, nodes_data, &numconf);
	json_decref(root);
	close(fd);

	/* load structure file and create list */
	fd = open(STRFILENAME, O_RDONLY);
	if (fd == 0)
	{
		ERROR( "Error : Can not open file %s \n", STRFILENAME);
		exit(1);
	}

	memset(buf, 0, READBUF_REN);
	read(fd, buf, READBUF_REN - 1);
	if (read(fd, buf, READBUF_REN - 1))
	{
		ERROR( "Error : Can not read file %s \n", STRFILENAME);
		close(fd);
		exit(1);
	}

	root2 = json_loads(buf, 0, &error);
	if (root2 == NULL)
	{
		ERROR( "Error : %s is invalid json file \n", STRFILENAME);
		close(fd);
		exit(1);
	}
	node_list = malloc(sizeof(child_node_list));
	if (node_list == NULL)
	{
		ERROR( "Error: out of memory\n");
		exit(1);
	}
	load_tier_json(root2, node_list);

#ifdef PRINT_DEBUG
	print_struct(node_list, 0);
#endif

	/* create foreign server and foreign table on pgspider */
	set_pgspider_node_all(nodes_data, node_list);

	json_decref(root);
	close(fd);
	free_nodedata(nodes_data);
	free_childnode(node_list);
	printf("Success to create pgspider tables.\n");
	return 0;
}
