/* -------------------------------------------------------------------------
 *
 * pgspider_node.c
 * Copyright (c) 2019, TOSHIBA
 *
 * -------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <libpq-fe.h>
#include "pgspider_node.h"
#include "error_codes.h"

static ReturnCode tinybrace_fdw(nodes *option, PGconn *conn);
static ReturnCode file_fdw(nodes *option, PGconn *conn);
static ReturnCode pgspider_fdw(nodes *option, PGconn *conn);
static ReturnCode postgres_fdw(nodes *option, PGconn *conn);
static ReturnCode sqlite_fdw(nodes *option, PGconn *conn);
static ReturnCode mysql_fdw(nodes *option, PGconn *conn);
static ReturnCode griddb_fdw(nodes *option, PGconn *conn);
static ReturnCode influxdb_fdw(nodes *option, PGconn *conn);
static ReturnCode parquet_s3_fdw(nodes *option, PGconn *conn);
static ReturnCode mongo_fdw(nodes *option, PGconn *conn);
static ReturnCode oracle_fdw(nodes *option, PGconn *conn);
static ReturnCode postgrest_fdw(nodes *option, PGconn *conn);
static ReturnCode dynamodb_fdw(nodes *option, PGconn *conn);
static ReturnCode sqlumdashcs_fdw(nodes *option, PGconn *conn);
static ReturnCode odbc_fdw(nodes *option, PGconn *conn);
static ReturnCode jdbc_fdw(nodes *option, PGconn *conn);
static ReturnCode objstorage_fdw(nodes *option, PGconn *conn);
static ReturnCode gitlab_fdw(nodes *option, PGconn *conn);
static ReturnCode redmine_fdw(nodes *option, PGconn *conn);

/* Helpful functions */
static void appendOption(char *sql, char *option_name, char *option_value, bool need_delimiter);

const		spd_function spd_func[] = {
	{"file_fdw", file_fdw},
	{"pgspider_fdw", pgspider_fdw},
	{"postgres_fdw", postgres_fdw},
	{"sqlite_fdw", sqlite_fdw},
	{"tinybrace_fdw", tinybrace_fdw},
	{"mysql_fdw", mysql_fdw},
	{"griddb_fdw", griddb_fdw},
	{"influxdb_fdw", influxdb_fdw},
	{"parquet_s3_fdw", parquet_s3_fdw},
	{"mongo_fdw", mongo_fdw},
	{"oracle_fdw", oracle_fdw},
	{"postgrest_fdw", postgrest_fdw},
	{"odbc_fdw", odbc_fdw},
	{"jdbc_fdw", jdbc_fdw},
	{"dynamodb_fdw", dynamodb_fdw},
	{"sqlumdashcs_fdw", sqlumdashcs_fdw},
	{"objstorage_fdw", objstorage_fdw},
	{"gitlab_fdw", gitlab_fdw},
	{"redmine_fdw", redmine_fdw},
	{"pgspider_core_fdw", node_set_spdcore}
};

const int	extension_size = sizeof(spd_func) / sizeof(*spd_func);
const char	*sqlTail = ");\n";


ReturnCode
node_set_spdcore(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option->nodename, "pgspider_core_fdw", option->ip, option->port);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}


static ReturnCode
tinybrace_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->nodename, "tinybrace_fdw", option->ip, option->port, option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
mysql_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option->nodename, "mysql_fdw", option->ip, option->port);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
postgres_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s',dbname '%s');\n", option->nodename, "postgres_fdw", option->ip, option->port, option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
pgspider_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->nodename, "pgspider_fdw", option->ip, option->port, option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
sqlite_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(database '%s');\n", option->nodename, "sqlite_fdw", option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
file_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s;", option->nodename, "file_fdw");
	printf("file_fdw server: %s\n", sql);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}

static ReturnCode
griddb_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];
	char		tmp_sql[QUERY_LEN];

	if (strcmp(option->notification_member, "") == 0)
		sprintf(tmp_sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER griddb_fdw OPTIONS(host '%s',port '%s', clustername '%s'", option->nodename, option->ip, option->port, option->clustername);
	else
		sprintf(tmp_sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER griddb_fdw OPTIONS(notification_member '%s', clustername '%s'", option->nodename, option->notification_member, option->clustername);
	/* set dbname */
	if (strcmp(option->dbname, "") == 0)
	{
		if (!IS_VALID_LENGTH(QUERY_LEN, "%s);", tmp_sql))
		{
			PRINT_ERROR("Error: query length exceeded max length %d", QUERY_LEN);
			return SETUP_QUERY_FAILED;
		}
		snprintf(sql, QUERY_LEN, "%s);", tmp_sql);
	}
	else
	{
		if (!IS_VALID_LENGTH(QUERY_LEN, "%s,dbname '%s');", tmp_sql, option->dbname))
		{
			PRINT_ERROR("Error: query length exceeded max length %d", QUERY_LEN);
			return SETUP_QUERY_FAILED;
		}
		snprintf(sql, QUERY_LEN, "%s,dbname '%s');", tmp_sql, option->dbname);
	}
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(username '%s',password '%s');\n", option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	return SETUP_OK;
}


static ReturnCode
influxdb_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	/* CXX version 1 */
	if (strcmp(option->influxdb_version, "1") == 0)
	{
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s', version '%s');\n", option->nodename, "influxdb_fdw", option->ip, option->port, option->dbname, option->influxdb_version);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;

		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n",
				option->nodename, option->user, option->pass);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;
	}
	/* CXX version 2 */
	else if (strcmp(option->influxdb_version, "2") == 0)
	{
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s', version '%s');\n", option->nodename, "influxdb_fdw", option->ip, option->port, option->dbname, option->influxdb_version);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;

		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(auth_token '%s');\n", option->nodename, option->token);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;
	}
	/* Go client or CXX client wihout version option */
	else if (strcmp(option->influxdb_version, "") == 0)
	{
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s', dbname '%s');\n", option->nodename, "influxdb_fdw", option->ip, option->port, option->dbname);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;

		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n",
				option->nodename, option->user, option->pass);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;
	}
	else
	{
		/* Shouldn't be here */
		rc = SETUP_INVALID_PARAM;
	}

	return SETUP_OK;
}

static ReturnCode
parquet_s3_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	if (IS_S3_PATH(option->dirpath))
	{
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(use_minio '%s', endpoint '%s', region '%s');\n",
				option->nodename, "parquet_s3_fdw", option->useminio, option->endpoint, option->region);
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;

		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n",
				option->nodename, option->user, option->pass);
		rc = query_execute(conn, sql);
	}
	else
	{
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s;\n", option->nodename, "parquet_s3_fdw");
		rc = query_execute(conn, sql);
		if (rc != SETUP_OK)
			return rc;

		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s;\n", option->nodename);
		rc = query_execute(conn, sql);
	}

	return rc;
}

static ReturnCode
oracle_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(dbserver '%s'", option->nodename, "oracle_fdw", option->dbserver);
	if (strlen(option->isolation_level) > 0)
	{
		char tmpOpt[ORACLE_OPTION_LEN];
		sprintf(tmpOpt, ", isolation_level '%s'", option->isolation_level);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->nchar) > 0)
	{
		char tmpOpt[ORACLE_OPTION_LEN];
		sprintf(tmpOpt, ", nchar '%s'", option->nchar);
		strcat(sql, tmpOpt);
	}

	strcat(sql, sqlTail);

	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}

static ReturnCode
mongo_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(address '%s', port '%s'", option->nodename, "mongo_fdw", option->ip, option->port);

	if (strlen(option->use_remote_estimate) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", use_remote_estimate '%s'", option->use_remote_estimate);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->enable_join_pushdown) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", enable_join_pushdown '%s'", option->enable_join_pushdown);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->authentication_database) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", authentication_database '%s'", option->authentication_database);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->replica_set) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", replica_set '%s'", option->replica_set);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->read_preference) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", read_preference '%s'", option->read_preference);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->ssl) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", ssl '%s'", option->ssl);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->pem_file) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", pem_file '%s'", option->pem_file);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->pem_pwd) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", pem_pwd '%s'", option->pem_pwd);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->ca_file) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", ca_file '%s'", option->ca_file);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->ca_dir) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", ca_dir '%s'", option->ca_dir);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->crl_file) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", crl_file '%s'", option->crl_file);
		strcat(sql, tmpOpt);
	}

	if (strlen(option->weak_cert_validation) > 0)
	{
		char tmpOpt[MONGO_OPTION_LEN];
		sprintf(tmpOpt, ", weak_cert_validation '%s'", option->weak_cert_validation);
		strcat(sql, tmpOpt);
	}

	strcat(sql, sqlTail);

	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(username '%s',password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}

static ReturnCode
postgrest_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s',port '%s');\n", option->nodename, "postgrest_fdw", option->ip, option->port);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS(user '%s',password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}


static ReturnCode
dynamodb_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (endpoint '%s');", option->nodename, "dynamodb_fdw", option->endpoint);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS (user '%s', password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}


static ReturnCode
sqlumdashcs_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (host '%s', port '%s', dbname '%s');",
			option->nodename, "sqlumdashcs_fdw", option->ip, option->port, option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS for public SERVER %s OPTIONS (username '%s', password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}

static ReturnCode
odbc_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (odbc_DRIVER '%s', odbc_SERVER '%s', odbc_PORT '%s', odbc_DATABASE '%s');\n",
			option->nodename, "odbc_fdw", option->dbdrivername, option->ip, option->port, option->dbname);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS(odbc_UID '%s', odbc_PWD '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}


static ReturnCode
jdbc_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (drivername '%s', url '%s', querytimeout '%s', jarfile '%s', maxheapsize '%s');\n",
			option->nodename, "jdbc_fdw", option->dbdrivername, option->dburl, option->querytimeout, option->driverpathjar, option->maxheapsize);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS(username '%s', password '%s');\n",
			option->nodename, option->user, option->pass);
	rc = query_execute(conn, sql);

	return rc;
}


static ReturnCode
objstorage_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];

	/* storage types need endpoint */
	if (strcmp(option->storage_type, "local") != 0 )
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (storage_type '%s', endpoint '%s');", option->nodename, "objstorage_fdw", option->storage_type, option->endpoint);
	else
		sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (storage_type '%s');", option->nodename, "objstorage_fdw", option->storage_type);
	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	/* storage types need username and password */
	if (strcmp(option->storage_type, "azure") == 0 || strcmp(option->storage_type, "s3") == 0)
		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS(user '%s', password '%s');\n",
			option->nodename, option->user, option->pass);
	else
		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s;\n", option->nodename);

	rc = query_execute(conn, sql);

	return rc;
}

static ReturnCode
gitlab_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];
	bool		need_delimiter = false;

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (", option->nodename, "gitlab_fdw");

	/*
	 * FDW accepts empty value however should not add empty value
	 * because connection will be always failed.
	 */
	if (strlen(option->endpoint) > 0)
	{
		appendOption(sql, "endpoint", option->endpoint, need_delimiter);
		need_delimiter = true;
	}

	/*
	 * Default value is always 0 setting by FDW.
	 * Only add this option if it is greater than 0
	 */
	if (atoi(option->timeout) > 0)
	{
		appendOption(sql, "timeout", option->timeout, need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	/*
	 * FDW accepts empty value however should not add empty value
	 * because connection will be always failed.
	 */
	if (strlen(option->proxy) > 0)
	{
		appendOption(sql, "proxy", option->proxy, need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	/* Check dependencies of ssl_verifypeer, ca_file and ca_path */
	if (strcmp(to_lower(option->ssl_verifypeer), "true") == 0)
	{
		if (strlen(option->ca_file) == 0 || strlen(option->ca_path) == 0)
		{
			PRINT_ERROR("ERROR: ca file and ca path must be set\n");
			return SETUP_INVALID_CONTENT;
		}

		appendOption(sql, "ssl_verifypeer", to_lower(option->ssl_verifypeer), need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;

		appendOption(sql, "ca_file", option->ca_file, need_delimiter);
		appendOption(sql, "ca_path", option->ca_path, need_delimiter);
	}
	else
	{
		appendOption(sql, "ssl_verifypeer", "false", need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	strcat(sql, sqlTail);

	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS (access_token '%s');\n",
			option->nodename, option->access_token);
	rc = query_execute(conn, sql);

	return rc;
}

static ReturnCode
redmine_fdw(nodes *option, PGconn *conn)
{
	ReturnCode	rc;
	char		sql[QUERY_LEN];
	bool		need_delimiter = false;

	sprintf(sql, "CREATE SERVER IF NOT EXISTS %s FOREIGN DATA WRAPPER %s OPTIONS (", option->nodename, "redmine_fdw");

	/*
	 * FDW accepts empty value however should not add empty value
	 * because connection will be always failed.
	 */
	if (strlen(option->endpoint) > 0)
	{
		appendOption(sql, "endpoint", option->endpoint, need_delimiter);
		need_delimiter = true;
	}

	/*
	 * Default value is always 0 setting by FDW.
	 * Only add this option if it is greater than 0
	 */
	if (atoi(option->timeout) > 0)
	{
		appendOption(sql, "timeout", option->timeout, need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	/*
	 * FDW accepts empty value however we should not add empty value
	 * because connection will always be failed.
	 */
	if (strlen(option->proxy) > 0)
	{
		appendOption(sql, "proxy", option->proxy, need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	/* Check dependencies of ssl_verifypeer, ca_file and ca_path */
	if (strcmp(to_lower(option->ssl_verifypeer), "true") == 0)
	{
		if (strlen(option->ca_file) == 0 || strlen(option->ca_path) == 0)
		{
			PRINT_ERROR("ERROR: ca file and ca path must be set\n");
			return SETUP_INVALID_CONTENT;
		}

		appendOption(sql, "ssl_verifypeer", to_lower(option->ssl_verifypeer), need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;

		appendOption(sql, "ca_file", option->ca_file, need_delimiter);
		appendOption(sql, "ca_path", option->ca_path, need_delimiter);
	}
	else
	{
		appendOption(sql, "ssl_verifypeer", "false", need_delimiter);

		if (need_delimiter == false)
			need_delimiter = true;
	}

	/* close OPTIONS */
	strcat(sql, sqlTail);

	rc = query_execute(conn, sql);
	if (rc != SETUP_OK)
		return rc;

	/*
	 * FDW accepts the empty value however api_key should not be NULL/empty
	 * because connection will be failed
	 */
	if (strlen(option->api_key) > 0)
		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS (api_key '%s');\n", option->nodename, option->api_key);
	else
		sprintf(sql, "CREATE USER MAPPING IF NOT EXISTS FOR public SERVER %s OPTIONS (user '%s', password '%s');\n", option->nodename, option->user, option->pass);

	rc = query_execute(conn, sql);

	return rc;
}

ReturnCode
node_set(nodes *option, PGconn *conn)
{
	int			i;

	for (i = 0; i < extension_size; i++)
	{
		if (strcasecmp(spd_func[i].name, option->fdw) == 0)
		{
			ReturnCode	rc = (*spd_func[i].func) (option, conn);

			if (rc != SETUP_OK)
				return rc;
		}
	}

	return SETUP_OK;
}

ReturnCode
mapping_set_file(nodes *option, PGconn *conn, char *filename, int seqnum)
{
	char		sql[QUERY_LEN];
	char		table_path[512];

	if (option->dirpath[strlen(option->dirpath) - 1] == '/')
		sprintf(table_path, "%s%s", option->dirpath, filename);
	else
		sprintf(table_path, "%s/%s", option->dirpath, filename);

	sprintf(sql, "CREATE FOREIGN TABLE %s__%s__%d(%s) SERVER %s OPTIONS(filename '%s', format 'csv');\n",
			option->table, option->nodename, seqnum, option->column, option->nodename, table_path);
	printf("file_fdw child foreign table: %s\n", sql);

	return query_execute(conn, sql);
}


/* Helpful functions */
static void appendOption(char *sql, char *option_name, char *option_value, bool need_delimiter)
{
	char		tmpOpt[CONFIG_LEN];
	string_info_data buf;

	init_string_info(&buf);

	if (strlen(option_name) == 0)
		return;

	deparse_string_literal(&buf, option_value);

	sprintf(tmpOpt, "%s %s %s", need_delimiter?",":"", option_name, buf.data);
	strcat(sql, tmpOpt);

	/* Free memory */
	if (buf.data != NULL)
		free(buf.data);
}
