#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libpq-fe.h>


#define ARG_INVALID(...) (fprintf(stderr, __VA_ARGS__))

int
pqexe_wrp(PGconn * conn, char *sql)
{
	PGresult   *res;

	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		printf("%s", PQerrorMessage(conn));
		return -1;
	}
	else
	{
		PQclear(res);
		return 0;
	}
}

void
print_usage()
{
#ifdef SET_NODE
	printf("Usage:./spd_node_set ParentIP ParentPort ParentUserName ParentPassword spd|postgres|mysql|tinybrace|sqlite|file .. \n \
 spd       : ChildNodeName	ChildNodeIp	ChildNodePort	ChildNodeUser	ChildNodePass \n \
 postgres  : ChildNodeName	ChildNodeIp	ChildNodePort	ChildNodeUser	ChildNodePass \n \
 mysql     : ChildNodeName	ChildNodeIp	ChildNodePort	ChildNodeUser	ChildNodePass \n \
 tinybrace : ChildNodeName	ChildNodeIp	ChildNodePort	ChildNodeUser	ChildNodePass	ChildNodeDBName \n \
 sqlite    : ChildNodeName	ChildNodeDBPath \n \
 file      : ChildNodeName\n");
#endif
#ifdef GET_NODE
	printf("Usage: ./spd_node_get ParentIP ParentPort ParentUserName ParentPassword\n");
#endif
#ifdef DEL_NODE
	printf("Usage: ./spd_node_del ParentIP ParentPort ParentUserName ParentPassword ParentNodeName\n");
#endif
#ifdef GET_TABLE
	printf("Usage: ./spd_table_get ParentIP ParentPort ParentUserName ParentPassword\n");
#endif
#ifdef SET_TABLE
	printf("Usage: ./spd_table_set ParentIP ParentPort ParentUserName ParentPassword ParentTableName ColumnInfo\n");
#endif
#ifdef DEL_TABLE
	printf("Usage: ./spd_table_del ParentIP ParentPort ParentUserName ParentPassword ParentTableName\n");
#endif
#ifdef SET_MAPPING
	printf("Usage: ./spd_mapping_set ParentIP ParentPort ParentUserName ParentPassword ParentTableName ParentTableName ColumnInfo .. \n \
 spd       : ChildNodeName	ChildNodeTableName \n \
 postgres  : ChildNodeName	ChildNodeTableName \n \
 mysql     : ChildNodeName	ChildNodeTableName\tChildNodeDBName \n \
 tinybrace : ChildNodeName	ChildNodeTableName \n \
 sqlite    : ChildNodeName	ChildNodeTableName \n \
 file      : ChildNodeName	ChildNodFilePath\tFileFormat \n");
#endif
#ifdef DEL_MAPPING
	printf("./spd_mapping_del ParentIP ParentPort ParentUserName ParentPassword TableName ChildNodeName\n");
#endif
}

int
pqexe_wrp_nocheck(PGconn * conn, char *sql, char *option[])
{
	PGresult   *res;

	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		/* reconnect if failed */
		PQclear(res);
		PQreset(conn);
	}
	else
	{
		PQclear(res);
	}
	return 0;
}


int
create_connection(PGconn * *conn, char *option[])
{
	*conn = PQsetdbLogin(
						 option[0],
						 option[1],
						 NULL,
						 NULL,
						 option[2],
						 option[2],
						 option[3]
		);
	if (PQstatus(*conn) == CONNECTION_BAD)
	{
		printf("%s", PQerrorMessage(*conn));
		return -1;
	}
	return 0;
}

int
node_get(char *option[], PGconn * conn, int option_length)
{
	PGresult   *resp;
	char		sql[1024];
	int			resp_cnt = 0;
	int			loop = 0;

	if (option_length != 4)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 4);
		print_usage();
		return -1;
	}

	sprintf(sql, "select a.foreign_server_name,a.foreign_data_wrapper_name,a.srvoptions,b.umoptions FROM information_schema._pg_foreign_servers as a left outer join information_schema._pg_user_mappings as b on a.foreign_server_name=b.foreign_server_name;");
	resp = PQexec(conn, &sql[0]);
	if (PQresultStatus(resp) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(resp));
		return (-1);
	}
	resp_cnt = PQntuples(resp);

	printf("%-30s | %-30s | %-30s | %-30s\n", "node name", "node fdw", "node info", "node user info");
	printf("---------------------------------------------------------------------------------------------------------------------------------\n");
	for (loop = 0; loop < resp_cnt; loop++)
	{
		printf("%-30s | %-30s | %-30s | %-30s\n",
			   PQgetvalue(resp, loop, 0),
			   PQgetvalue(resp, loop, 1),
			   PQgetvalue(resp, loop, 2),
			   PQgetvalue(resp, loop, 3)
			);
	}
	return (0);
}


int
node_set_spd(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn;

	if (option_length != 10)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 10);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION spd_fdw;");
	pqexe_wrp_nocheck(conn, sql, option);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option[5], "spd_fdw", option[6], option[7]);
	rtn = pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n", option[5], option[8], option[9]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}


int
node_set_tb(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn;

	if (option_length != 11)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 11);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION tinybrace_fdw;");
	pqexe_wrp_nocheck(conn, sql, option);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option[5],
			"tinybrace_fdw", option[6], option[7], option[10]);
	rtn = pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n",
			option[5], option[8], option[9]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
node_set_my(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn = 0;

	if (option_length != 10)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 10);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION mysql_fdw;");
	pqexe_wrp_nocheck(conn, sql, option);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option[5], "mysql_fdw", option[6], option[7]);
	rtn = pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n", option[5], option[8], option[9]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
node_set_pg(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn = 0;

	if (option_length != 10)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 10);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION postgres_fdw;");
	pqexe_wrp_nocheck(conn, sql, option);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option[5], "postgres_fdw", option[6], option[7]);
	pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}

	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(user '%s',password '%s');\n", option[5], option[8], option[9]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
node_set_sl(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn = 0;

	if (option_length != 7)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 7);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION sqlite_fdw;");
	rtn = pqexe_wrp_nocheck(conn, sql, option);
	if (rtn != 0)
	{
		return rtn;
	}

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(database '%s');\n", option[5], "sqlite_fdw", option[6]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
node_set_file(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn = 0;

	if (option_length != 6)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 6);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION file_fdw;");
	rtn = pqexe_wrp_nocheck(conn, sql, option);
	if (rtn != 0)
	{
		return rtn;
	}

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s;\n", option[5], "file_fdw");
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
node_set_griddb(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn;

	if (option_length != 11)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 11);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE EXTENSION tinybrace_fdw;");
	pqexe_wrp_nocheck(conn, sql, option);

	sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', clustername '%s');\n", option[5],
			"griddb_fdw", option[6], option[7], option[10]);
	rtn = pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}
	sprintf(sql, "CREATE USER MAPPING for public SERVER %s OPTIONS(username '%s',password '%s');\n",
			option[5], option[8], option[9]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}



int
node_set(char *option[], PGconn * conn, int option_length)
{

	int			rtn = 0;

	if (option_length < 6)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 6);
		print_usage();
		return -1;
	}

	if (strcasecmp(option[4], "spd") == 0)
	{
		rtn = node_set_spd(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "tinybrace") == 0)
	{
		rtn = node_set_tb(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "mysql") == 0)
	{
		rtn = node_set_my(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "postgres") == 0)
	{
		rtn = node_set_pg(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "sqlite") == 0)
	{
		rtn = node_set_sl(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "file") == 0)
	{
		rtn = node_set_file(option, conn, option_length);
	}
	else if (strcasecmp(option[4], "griddb") == 0)
	{
		rtn = node_set_griddb(option, conn, option_length);
	}
	else
	{
		fprintf(stdout, "Datasouce %s is not support. Supported spd/tinybrace/mysql/postgres/sqlite/file\n", option[4]);
		rtn = -1;
	}
	if (rtn != -1)
	{
		fprintf(stdout, "success : set node information\n");
	}
	return rtn;
}

int
node_del(char *option[], PGconn * conn, int option_length)
{
	PGresult   *res;
	char		sql[1024];
	int			resp_cnt = 0;
	int			loop = 0;
	int			rtn = 0;

	if (option_length != 5)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 5);
		print_usage();
		return -1;
	}
	sprintf(sql, "DROP SERVER %s CASCADE;\n", option[4]);
	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		printf("%s\n", PQerrorMessage(conn));
		return -1;
	}
	PQclear(res);
	fprintf(stdout, "success : delete node information\n");
	return 0;
}

int
table_get(char *option[], PGconn * conn, int option_length)
{
	PGresult   *resp;
	PGresult   *resp_column;
	char		sql[1024];
	int			resp_cnt = 0;
	int			resp_cnt_col = 0;
	int			loop = 0;
	int			j;

	if (option_length != 4)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 4);
		print_usage();
		return -1;
	}
	sprintf(sql, "select foreign_table_name,foreign_server_name,ftoptions from information_schema._pg_foreign_tables order by foreign_table_name;");
	resp = PQexec(conn, &sql[0]);
	if (PQresultStatus(resp) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(resp));
		return -1;
	}
	resp_cnt = PQntuples(resp);
	printf("%-30s | %-30s | %-30s | %-30s \n", "child/parent table name", "node name", "other infomation", "column infomation");

	/*
	 * printf( "%s\t| %s\t| %s\t| %s\n","child/parent table name","node name",
	 * "other infomation", "column infomation");
	 */
	printf("------------------------------------------------------------------------------------------------------------------------------------------\n");
	for (loop = 0; loop < resp_cnt; loop++)
	{
		sprintf(sql, "select table_name,column_name,data_type from information_schema.columns where table_name = '%s';",
				PQgetvalue(resp, loop, 0));
		resp_column = PQexec(conn, &sql[0]);
		if (PQresultStatus(resp_column) != PGRES_TUPLES_OK)
		{
			printf("Can not execute node get. %d\n", PQresultStatus(resp_column));
			return -1;
		}
		resp_cnt_col = PQntuples(resp_column);
		printf("%-30s | %-30s | %-30s |",
			   PQgetvalue(resp, loop, 0),
			   PQgetvalue(resp, loop, 1),
			   PQgetvalue(resp, loop, 2)
			);
		for (j = 0; j < resp_cnt_col; j++)
		{
			printf(" %s %s", PQgetvalue(resp_column, j, 1), PQgetvalue(resp_column, j, 2));
			if (j + 1 < resp_cnt_col)
			{
				printf(",");
			}
		}
		printf("\n");
	}
	PQclear(resp);
	return 0;
}

int
table_set(char *option[], PGconn * conn, int option_length)
{
	char		sql[1024];
	int			rtn = 0;

	if (option_length != 6)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 6);
		print_usage();
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s(%s) SERVER spd OPTIONS(table_name '%s');\n", option[4], option[5], option[4]);
	rtn = pqexe_wrp(conn, sql);
	if (rtn != 0)
	{
		return rtn;
	}
	fprintf(stdout, "success : set table information\n");
	return rtn;
}

int
table_del(char *option[], PGconn * conn, int option_length)
{
	PGresult   *resp;
	char		sql[1024];
	char		temp_result[256][256];
	int			resp_cnt = 0;
	int			loop = 0;
	int			rtn = 0;

	if (option_length != 5)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 5);
		print_usage();
		return -1;
	}
	/* GET mapping table file name(child node tables name) */
	sprintf(sql, "select foreign_table_name from information_schema._pg_foreign_tables where foreign_table_name LIKE '%s' OR foreign_table_name LIKE '%s__%%' order by foreign_table_name;", option[4], option[4]);
	resp = PQexec(conn, &sql[0]);
	if (PQresultStatus(resp) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(resp));
		return -1;
	}
	resp_cnt = PQntuples(resp);
	if (resp_cnt == 0)
	{
		printf("Can not find foreign table : %s\n", option[4]);
		return -1;
	}
	for (loop = 0; loop < resp_cnt; loop++)
	{
		sprintf(temp_result[loop], "%s", PQgetvalue(resp, loop, 0));
		fprintf(stdout, "%s\n", temp_result[loop]);
	}
	PQclear(resp);
	for (loop = 0; loop < resp_cnt; loop++)
	{
		sprintf(sql, "DROP FOREIGN TABLE %s;", temp_result[loop]);
		rtn = pqexe_wrp(conn, sql);
		if (rtn != 0)
		{
			return rtn;
		}
	}
	fprintf(stdout, "success : delete table information\n");
	return rtn;
}

int
get_mapping_nums(PGconn * conn, char *option[])
{
	PGresult   *res;
	char		sql[1024];
	int			resp_cnt = 0;
	int			loop = 0;

	sprintf(sql, "select foreign_table_name from information_schema._pg_foreign_tables where foreign_table_name LIKE '%s__%s__%%' order by foreign_table_name;", option[4], option[6]);
	printf("%s\n", sql);
	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		printf("can not execute node get. %d\n", PQresultStatus(res));
		return -1;
	}
	resp_cnt = PQntuples(res);
	PQclear(res);
	return resp_cnt;
}

int
mapping_set_spd(char *option[], PGconn * conn, int option_length, char *table_name)
{
	PGresult   *res;
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return -1;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table_name '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7]);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_tb(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return rtn;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table_name '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_my(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 9)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 9);
		print_usage();
		return -1;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table_name '%s',dbname '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7], option[8]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_pg(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return -1;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table_name '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_sl(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return -1;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_file(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 9)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 6);
		print_usage();
		return -1;
	}
	resp_cnt = get_mapping_nums(conn, option);
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(filename '%s', format '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7], option[8]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set_griddb(char *option[], PGconn * conn, int option_length, char *table_name)
{
	char		sql[1024];
	int			resp_cnt = 0;
	int			rtn = 0;

	if (option_length != 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return rtn;
	}
	resp_cnt = get_mapping_nums(conn, option);
	if (resp_cnt == -1)
	{
		return -1;
	}
	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(table_name '%s');\n",
			option[4], option[6], resp_cnt, option[5], option[6], option[7]);
	sprintf(table_name, "%s__%s__%d", option[4], option[6], resp_cnt);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}


/* compare mapping table column to parent table column */
int
check_column(char *option[], PGconn * conn, char *table_name)
{
	PGresult   *res_par;
	PGresult   *res_chi;
	char		sql_par[1024];
	char		sql_chi[1024];
	int			resp_cnt_par = 0;
	int			resp_cnt_chi = 0;
	int			i;

	sprintf(sql_par, "select table_name,column_name,data_type from information_schema.columns where table_name = '%s';", option[4]);
	sprintf(sql_chi, "select table_name,column_name,data_type from information_schema.columns where table_name = '%s';", table_name);

	res_par = PQexec(conn, &sql_par[0]);
	res_chi = PQexec(conn, &sql_chi[0]);
	resp_cnt_par = PQntuples(res_par);
	resp_cnt_chi = PQntuples(res_chi);

	if (resp_cnt_par != resp_cnt_chi)
	{
		printf("mapping column num is invalid : Parent %d mapping %d\n", resp_cnt_par, resp_cnt_chi);
		return -1;
	}
	for (i = 0; i < resp_cnt_par; i++)
	{
		if (strcmp(PQgetvalue(res_par, i, 2), PQgetvalue(res_chi, i, 2)) != 0)
		{
			printf("Mapping column type is invalid : Parent '%s' Mapping '%s'\n", PQgetvalue(res_par, i, 2), PQgetvalue(res_chi, i, 2));
			return -1;
		}
	}
	return 0;
}

int
mapping_quick_drop(PGconn * conn, char *table_name)
{
	char		sql[1024];
	int			rtn = 0;

	sprintf(sql, "DROP FOREIGN TABLE %s;", table_name);
	rtn = pqexe_wrp(conn, sql);
	return rtn;
}

int
mapping_set(char *option[], PGconn * conn, int option_length)
{
	PGresult   *res;
	char		sql[1024];
	char		table_name[1024];
	char		temp_result[256][256];
	int			resp_cnt = 0;
	int			loop = 0;
	int			rtn = 0;

	if (option_length < 8)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 8);
		print_usage();
		return -1;
	}

	sprintf(sql, "select * from information_schema._pg_foreign_tables where foreign_table_name LIKE '%s';", option[4]);
	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(res));
		return -1;
	}
	if (PQntuples(res) == 0)
	{
		printf("Can not find Parent Table : %s \n", option[4]);
		return -1;
	}
	PQclear(res);

	sprintf(sql, "select foreign_server_name,foreign_data_wrapper_name from information_schema._pg_foreign_servers;");
	res = PQexec(conn, &sql[0]);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(res));
		return -1;
	}
	resp_cnt = PQntuples(res);

	/*
	 * check to server is exisit and fdw is same.
	 */
	for (loop = 0; loop < resp_cnt; loop++)
	{
		if (strcasecmp(option[6], PQgetvalue(res, loop, 0)) == 0)
		{
			if (strcasecmp(PQgetvalue(res, loop, 1), "spd_fdw") == 0)
			{
				rtn = mapping_set_spd(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "tinybrace_fdw") == 0)
			{
				rtn = mapping_set_tb(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "mysql_fdw") == 0)
			{
				rtn = mapping_set_my(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "postgres_fdw") == 0)
			{
				rtn = mapping_set_pg(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "sqlite_fdw") == 0)
			{
				rtn = mapping_set_sl(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "file_fdw") == 0)
			{
				rtn = mapping_set_file(option, conn, option_length, table_name);
			}
			else if (strcasecmp(PQgetvalue(res, loop, 1), "griddb_fdw") == 0)
			{
				rtn = mapping_set_griddb(option, conn, option_length, table_name);
			}
			else
			{
				fprintf(stdout, "%s is not support. Supported spd|tinybrace|mysql|postgres|sqlite|file\n", option[6]);
				return -1;
			}

			/* Firstly, check column and */
			rtn = check_column(option, conn, table_name);
			if (rtn == 0)
			{
				fprintf(stdout, "success : set mapping information\n");
			}
			else
			{
				mapping_quick_drop(conn, table_name);
				return -1;
			}
			return rtn;
		}
	}
	PQclear(res);
	fprintf(stdout, "can not find server. %s\n", option[6]);
	return -1;
}

int
mapping_del(char *option[], PGconn * conn, int option_length)
{
	PGresult   *resp;
	char		sql[1024];
	char		temp_result[256][256];
	int			resp_cnt = 0;
	int			loop = 0;
	int			rtn = 0;

	if (option_length != 6)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args = ", option_length, "Expect = ", 6);
		print_usage();
		return -1;
	}
	sprintf(sql, "select foreign_table_name from information_schema._pg_foreign_tables where foreign_table_name LIKE '%s__%s__%%' order by foreign_table_name;", option[4], option[5]);
	resp = PQexec(conn, &sql[0]);
	if (PQresultStatus(resp) != PGRES_TUPLES_OK)
	{
		printf("Can not execute node get. %d\n", PQresultStatus(resp));
		return -1;
	}
	resp_cnt = PQntuples(resp);
	if (resp_cnt == 0)
	{
		printf("Can not find mapping information : table '%s', server '%s'\n", option[4], option[5]);
		return -1;
	}
	for (loop = 0; loop < resp_cnt; loop++)
	{
		sprintf(temp_result[loop], "%s", PQgetvalue(resp, loop, 0));
	}
	PQclear(resp);
	for (loop = 0; loop < resp_cnt; loop++)
	{
		sprintf(sql, "DROP FOREIGN TABLE %s;", temp_result[loop]);
		rtn = pqexe_wrp(conn, sql);
		if (rtn != 0)
		{
			return rtn;
		}
	}
	fprintf(stdout, "success : delete mapping information\n");
	return rtn;
}

int
main(int argc, char *argv[])
{
	int			elem_flag = 0;
	int			command_flag = 0;
	int			result;
	int			rtn;
	char	   *option[256];
	PGconn	   *conn = NULL;
	PGresult   *resp = NULL;

	/* check option */
	int			i = 0,
				option_length = 0;

	int			opt;

	while ((opt = getopt(argc, argv, "hv:")) != -1)
	{
		switch (opt)
		{
			case 'h':
				print_usage();
				return 0;
			default:
				break;
		}
	}

	for (; optind < argc; optind++)
	{
		option[i] = (char *) malloc(sizeof(char) * 100);
		sprintf(option[i], "%s", argv[optind]);
		i++;
	}
	option_length = i;
	if (i < 4)
	{
		ARG_INVALID("%s %d %s %d\n", "Invalid args : args =", option_length, "Expect >", 3);
		print_usage();
		return -1;
	}
	i = 0;
	/* create connection to parent node */
	rtn = create_connection(&conn, option);
	if (rtn != 0)
	{
		return -1;
	}
#ifdef GET_NODE
	rtn = node_get(option, conn, option_length);
#endif
#ifdef SET_NODE
	rtn = node_set(option, conn, option_length);
#endif
#ifdef DEL_NODE
	rtn = node_del(option, conn, option_length);
#endif
#ifdef GET_TABLE
	rtn = table_get(option, conn, option_length);
#endif
#ifdef SET_TABLE
	rtn = table_set(option, conn, option_length);
#endif
#ifdef DEL_TABLE
	rtn = table_del(option, conn, option_length);
#endif
#ifdef SET_MAPPING
	rtn = mapping_set(option, conn, option_length);
#endif
#ifdef DEL_MAPPING
	rtn = mapping_del(option, conn, option_length);
#endif
	return rtn;
}
