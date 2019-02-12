/*-------------------------------------------------------------------------
 *
 * option.c
 *		  FDW option handling for ddsf_fdw
 *
 * Portions Copyright (c) 2012-2015, PostgreSQL Global Development Group
 *
 * IDENTIFICATION
 *		  contrib/ddsf_fdw/option.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "ddsf_fdw.h"

#include "access/reloptions.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_foreign_table.h"
#include "catalog/pg_user_mapping.h"
#include "commands/defrem.h"
#include "executor/spi.h"
#include "fmgr.h"
#include "utils/hsearch.h"


void
			DdsfFdwCreateSpi(char *sql_text, int expect_ret);


/*
 * Describes the valid options for objects that this wrapper uses.
 */
typedef struct DdsfFdwOption
{
	const char *keyword;
	Oid			optcontext;		/* OID of catalog in which option may appear */
	bool		is_libpq_opt;	/* true if it's used in libpq */
}			DdsfFdwOption;

/*
 * Valid options for ddsf_fdw.
 * Allocated and filled in InitDdsfFdwOptions.
 */
static DdsfFdwOption * ddsf_fdw_options;

/*
 * Valid options for libpq.
 * Allocated and filled in InitDdsfFdwOptions.
 */
static PQconninfoOption * libpq_options;

/*
 * Helper functions
 */
static void InitDdsfFdwOptions(void);
static bool is_valid_option(const char *keyword, Oid context);
static bool is_libpq_option(const char *keyword);


typedef struct hashkey
{
	int			num;
}			HashKey;

typedef struct list_column
{
	char	   *column_name;
	char	   *column_type;
}			list_column;


typedef struct list_tables
{
	char	   *dist_table_name;	/* source table name */
	char	   *db_name;		/* */
	char	   *table_name;		/* */
	List	   *columns;
}			list_tables;

typedef struct list_ds
{
	char	   *datasource;
	char	   *driver;
	char	   *host;
	char	   *port;
	char	   *user;
	char	   *pass;
	List	   *listtables;		/* list of tables */
}			list_ds;



/*
 * Validate the generic options given to a FOREIGN DATA WRAPPER, SERVER,
 * USER MAPPING or FOREIGN TABLE that uses ddsf_fdw.
 *
 * Raise an ERROR if the option or its value is considered invalid.
 */
PG_FUNCTION_INFO_V1(ddsf_fdw_validator);
#if 0
Datum
ddsf_fdw_parse_jansson(char *URI)
{
	char		js[65537] = {0};
	int			i;
	FILE	   *fp;
	const char *key;
	char		sql[512];
	jansson_t  *value;
	List	   *listds;
	ListCell   *l;
	ListCell   *lt;
	ListCell   *lc;

	/* read from file */
	if ((fp = fopen(URI, "r")) == NULL)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg("ddsf conf file is nothing in \"%s\"", URI)));
	}
	ereport(INFO,
			(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
			 errmsg("ddsf conf file is =  \"%s\"", URI)));
	fread(js, 65536, 1, fp);

	jansson_error_t error;
	jansson_t  *result = jansson_loads(js, 0, &error);
	jansson_t  *repositories = jansson_object_get(result, "datasources");
	void	   *iter = jansson_object_iter(repositories);

	/* printf("%s\n", jansson_string_value(repositories)); */
	listds = NIL;

	key = jansson_object_iter_key(iter);
	value = jansson_object_iter_value(iter);


	ereport(INFO,
			(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
			 errmsg("drivername =  \"%s\"", key)));

	/* Read datasouce information */
	while (iter)
	{
		key = jansson_object_iter_key(iter);
		value = jansson_object_iter_value(iter);
		jansson_t  *temp_obj = jansson_object_get(repositories, key);
		list_ds    *entry;

		entry = (list_ds *) palloc(sizeof(list_ds));
		entry->datasource = (char *) palloc(sizeof(char) * 100);
		entry->driver = (char *) palloc(sizeof(char) * 100);
		entry->host = (char *) palloc(sizeof(char) * 100);
		entry->port = (char *) palloc(sizeof(char) * 100);
		entry->user = (char *) palloc(sizeof(char) * 100);
		entry->pass = (char *) palloc(sizeof(char) * 100);
		entry->listtables = (List *) palloc(sizeof(List));
		sprintf(entry->datasource, "%s", key);
		sprintf(entry->driver, "%s", jansson_string_value(jansson_object_get(temp_obj, "driver")));
		sprintf(entry->host, "%s", jansson_string_value(jansson_object_get(temp_obj, "host")));
		sprintf(entry->port, "%s", jansson_string_value(jansson_object_get(temp_obj, "port")));
		sprintf(entry->user, "%s", jansson_string_value(jansson_object_get(temp_obj, "useroption")));
		sprintf(entry->pass, "%s", jansson_string_value(jansson_object_get(temp_obj, "passoption")));
		listds = lcons(entry, listds);

		/* Create server info */
/*
	sprintf(sql,"DROP USER MAPPING FOR PUBLIC SERVER %s;",entry->datasource);
	DdsfFdwCreateSpi(sql,SPI_OK_UTILITY);
	sprintf(sql,"DROP SERVER %s;",entry->datasource);
	DdsfFdwCreateSpi(sql,SPI_OK_UTILITY);
*/
		sprintf(sql, "CREATE SERVER %s FOREIGN DATA WRAPPER %s OPTIONS(host '%s', port '%s');", entry->datasource, entry->driver, entry->host, entry->port);
		printf("%s\n", sql);
/* 	DdsfFdwCreateSpi(sql,SPI_OK_UTILITY); */

		/* CREATE USER MAPPING */
		sprintf(sql, "CREATE USER MAPPING FOR PUBLIC SERVER %s OPTIONS(%s, %s)", entry->datasource, entry->user, entry->pass);
		printf("%s\n", sql);
/* 	DdsfFdwCreateSpi(sql,SPI_OK_UTILITY); */

		iter = jansson_object_iter_next(repositories, iter);
		ereport(INFO,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg("entry->datasource conf file is =  \"%s\"", entry->datasource)));
	}
	foreach(l, listds)
	{
		list_ds    *entry = (list_ds *) lfirst(l);

		ereport(INFO,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg("drivername =  \"%s\"", entry->driver)));
	}
#if 1

	/* get table information */
	repositories = jansson_object_get(result, "tables");
	iter = jansson_object_iter(repositories);
	while (iter)
	{
		key = jansson_object_iter_key(iter);	/* global table name */
		value = jansson_object_iter_value(iter);
		jansson_t  *temp_obj = jansson_object_get(repositories, key);

		printf("%s\n", key);
		void	   *iter2 = jansson_object_iter(temp_obj);

		iter2 = jansson_object_iter(temp_obj);
		list_column *listcolumn;

		listcolumn = (list_ds *) palloc(sizeof(list_column));
		char		column_str[512] = {0};

		while (iter2)
		{
			const char *key2;
			jansson_t  *value2;
			jansson_t  *temp_obj2;
			List	   *listtable;

			key2 = jansson_object_iter_key(iter2);
			value2 = jansson_object_iter_value(iter2);
			temp_obj2 = jansson_object_get(temp_obj, key2);
			printf("ite2 %s\n", key2);
			int			i = 0;

			if (strcmp(key2, "columns") == 0)
			{
				/* ite3 */
				jansson_t  *repository;
				void	   *iter3 = jansson_object_iter(temp_obj2);

				listcolumn = NIL;
				while (iter3)
				{
					if (i != 0)
					{
						break;
					}
					const char *key3;
					jansson_t  *value3;
					list_column *entry2;

					entry2 = (list_column *) palloc(sizeof(list_column));
					const char *key;
					jansson_t  *value;

					key3 = jansson_object_iter_key(iter3);
					value3 = jansson_object_iter_value(iter3);
					printf("columna %s %s\n", key3, jansson_string_value(value3));
					entry2->column_name = (char *) palloc(sizeof(char) * 100);
					entry2->column_type = (char *) palloc(sizeof(char) * 100);
					sprintf(entry2->column_name, "%s", key3);
					sprintf(entry2->column_type, "%s", value3);
					sprintf(column_str, "%s %s", key3, jansson_string_value(value3));
/*
				  if(value3 != NULL){
					  if(i == 0){
						  sprintf(column_str,"%s %s",entry2->column_name, entry2->column_type);
						  printf("columnb %s %s\n", entry2->column_name, entry2->column_type);
					  }
					  else{
						  char tmp[256]={0};
						  sprintf(tmp,",%s %s", entry2->column_name, entry2->column_type);
						  printf("column type %s %s\n", entry2->column_name, entry2->column_type);
						  strcat(column_str,tmp);
					  }
				  }
*/
					listcolumn = lcons(entry2, listcolumn);
					iter3 = jansson_object_iter_next(temp_obj2, iter3);
					i++;
				}
			}
			else if (strcmp(key2, "datasources") == 0)
			{
				const char *key4;
				jansson_t  *value4;
				void	   *iter4 = jansson_object_iter(temp_obj2);

				while (iter4)
				{
					key4 = jansson_object_iter_key(iter4);
					value4 = jansson_object_iter_value(iter4);
					jansson_t  *temp_obj3 = jansson_object_get(temp_obj2, key4);
					void	   *iter5 = jansson_object_iter(temp_obj3);
					int			flag = 0;

					/* check to dsname exist in list ds */
					foreach(l, listds)
					{
						list_ds    *entry = (list_ds *) lfirst(l);

						if (strcmp(entry->datasource, key4))
						{
							flag = 1;
							break;
						}
					}
					if (flag == 0)
					{
						ereport(ERROR,
								(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
								 errmsg("datasouce \"%s\" is nothing", key4)));
					}
					/* add table data into table list */
					while (iter5)
					{
						const char *key5;
						jansson_t  *value5;
						list_tables *entry;
						char		option[512];

						entry = (list_tables *) palloc(sizeof(list_tables));

						key5 = jansson_object_iter_key(iter5);
						entry->dist_table_name = (char *) palloc(sizeof(char) * 100);
						entry->table_name = (char *) palloc(sizeof(char) * 100);
						entry->db_name = (char *) palloc(sizeof(char) * 100);

						/* add table name and db name */
						sprintf(entry->dist_table_name, "%s", key5);
						value5 = jansson_string_value(jansson_object_get(temp_obj3, "table_name"));
						if (value5 != NULL)
						{
							sprintf(entry->table_name, "%s", value5);
							sprintf(option, "table_name '%s'", value5);
						}
						value5 = jansson_string_value(jansson_object_get(temp_obj3, "db_name"));
						if (value5 != NULL)
						{
							sprintf(entry->db_name, "%s", value5);
							char		temp[256];

							sprintf(temp, "dbname '%s'", value5);
							strcat(option, temp);
						}
						/* add column */
						entry->columns = listcolumn;
						listtable = lcons(entry, listtable);
						sprintf(sql, "CREATE FOREIGN TABLE %s_%s(%s)SERVER %s options(%s);", key, key4, column_str, key4, option);
						printf("%s\n", sql);
/* 					  DdsfFdwCreateSpi(sql,SPI_OK_UTILITY); */
						iter5 = jansson_object_iter_next(temp_obj3, iter5);
					}
					iter4 = jansson_object_iter_next(temp_obj2, iter4);
				}
			}
			iter2 = jansson_object_iter_next(temp_obj, iter2);
		}
		iter = jansson_object_iter_next(repositories, iter);
	}
#endif
	fclose(fp);
}
#endif

Datum
ddsf_fdw_validator(PG_FUNCTION_ARGS)
{
	List	   *options_list = untransformRelOptions(PG_GETARG_DATUM(0));
	Oid			catalog = PG_GETARG_OID(1);
	ListCell   *cell;

	/* Build our options lists if we didn't yet. */
	InitDdsfFdwOptions();

	/*
	 * Check that only options supported by ddsf_fdw, and allowed for the
	 * current object type, are given.
	 */
	foreach(cell, options_list)
	{
		DefElem    *def = (DefElem *) lfirst(cell);

		if (!is_valid_option(def->defname, catalog))
		{
			/*
			 * Unknown option specified, complain about it. Provide a hint
			 * with list of valid options for the object.
			 */
			DdsfFdwOption *opt;
			StringInfoData buf;

			initStringInfo(&buf);
			for (opt = ddsf_fdw_options; opt->keyword; opt++)
			{
				if (catalog == opt->optcontext)
					appendStringInfo(&buf, "%s%s", (buf.len > 0) ? ", " : "",
									 opt->keyword);
			}
			ereport(ERROR,
					(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
					 errmsg("invalid optiona \"%s\"", def->defname),
					 errhint("Valid options in this context are: %s",
							 buf.data)));
		}

		/*
		 * Validate option value, when we can do so without any context.
		 */
		if (strcmp(def->defname, "use_remote_estimate") == 0 ||
			strcmp(def->defname, "updatable") == 0)
		{
			/* these accept only boolean values */
			(void) defGetBoolean(def);
		}
		else if (strcmp(def->defname, "fdw_startup_cost") == 0 ||
				 strcmp(def->defname, "fdw_tuple_cost") == 0)
		{
			/* these must have a non-negative numeric value */
			double		val;
			char	   *endp;

			val = strtod(defGetString(def), &endp);
			if (*endp || val < 0)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("%s requires a non-negative numeric value",
								def->defname)));
		}
		else if (strcmp(def->defname, "config_file") == 0)
		{
#if 1
			char		sql[512];
			List	   *options_list;

			/* CREATE SERVER */
			ereport(INFO,
					(errcode(ERRCODE_SYNTAX_ERROR),
					 errmsg("config name = %s", sql)));
#else
			ddsf_fdw_parse_jansson(defGetString(def));
#endif
		}
	}

	PG_RETURN_VOID();
}

void
DdsfFdwCreateSpi(char *sql_text, int expect_ret)
{
	StringInfoData buf;
	int			ret;

	if ((ret = SPI_connect()) < 0)
		/* internal error */
		elog(ERROR, "SPI connect failure - returned %d", ret);

	initStringInfo(&buf);
	ereport(INFO,
			(errcode(ERRCODE_CARDINALITY_VIOLATION),
			 errmsg("create forreing another table")));
	appendStringInfoString(&buf, sql_text);
	ret = SPI_exec(buf.data, 1);
	pfree(buf.data);
	SPI_finish();
}

/*
 * Initialize option lists.
 */
static void
InitDdsfFdwOptions(void)
{
	int			num_libpq_opts;
	PQconninfoOption *lopt;
	DdsfFdwOption *popt;

	/* non-libpq FDW-specific FDW options */
	static const DdsfFdwOption non_libpq_options[] = {
		{"schema_name", ForeignTableRelationId, false},
		{"dbname", ForeignTableRelationId, false},
		{"table_name", ForeignTableRelationId, false},
		{"column_name", AttributeRelationId, false},
		/* use_remote_estimate is available on both server and table */
		{"use_remote_estimate", ForeignServerRelationId, false},
		{"use_remote_estimate", ForeignTableRelationId, false},
		/* cost factors */
		{"fdw_startup_cost", ForeignServerRelationId, false},
		{"fdw_tuple_cost", ForeignServerRelationId, false},
		/* updatable is available on both server and table */
		{"updatable", ForeignServerRelationId, false},
		{"updatable", ForeignTableRelationId, false},
		{"config_file", ForeignServerRelationId, false},
		{"config_file", ForeignTableRelationId, false},
		{NULL, InvalidOid, false}
	};

	/* Prevent redundant initialization. */
	if (ddsf_fdw_options)
		return;

	/*
	 * Get list of valid libpq options.
	 *
	 * To avoid unnecessary work, we get the list once and use it throughout
	 * the lifetime of this backend process.  We don't need to care about
	 * memory context issues, because PQconndefaults allocates with malloc.
	 */
	libpq_options = PQconndefaults();
	if (!libpq_options)			/* assume reason for failure is OOM */
		ereport(ERROR,
				(errcode(ERRCODE_FDW_OUT_OF_MEMORY),
				 errmsg("out of memory"),
				 errdetail("could not get libpq's default connection options")));

	/* Count how many libpq options are available. */
	num_libpq_opts = 0;
	for (lopt = libpq_options; lopt->keyword; lopt++)
		num_libpq_opts++;

	/*
	 * Construct an array which consists of all valid options for ddsf_fdw, by
	 * appending FDW-specific options to libpq options.
	 *
	 * We use plain malloc here to allocate ddsf_fdw_options because it lives
	 * as long as the backend process does.  Besides, keeping libpq_options in
	 * memory allows us to avoid copying every keyword string.
	 */
	ddsf_fdw_options = (DdsfFdwOption *)
		malloc(sizeof(DdsfFdwOption) * num_libpq_opts +
			   sizeof(non_libpq_options));
	if (ddsf_fdw_options == NULL)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_OUT_OF_MEMORY),
				 errmsg("out of memory")));

	popt = ddsf_fdw_options;
	for (lopt = libpq_options; lopt->keyword; lopt++)
	{
		/* Hide debug options, as well as settings we override internally. */
		if (strchr(lopt->dispchar, 'D') ||
			strcmp(lopt->keyword, "fallback_application_name") == 0 ||
			strcmp(lopt->keyword, "client_encoding") == 0)
			continue;

		/* We don't have to copy keyword string, as described above. */
		popt->keyword = lopt->keyword;

		/*
		 * "user" and any secret options are allowed only on user mappings.
		 * Everything else is a server option.
		 */
		if (strcmp(lopt->keyword, "username") == 0 || strcmp(lopt->keyword, "user") == 0 || strchr(lopt->dispchar, '*'))
			popt->optcontext = UserMappingRelationId;
		else
			popt->optcontext = ForeignServerRelationId;
		popt->is_libpq_opt = true;

		popt++;
	}

	/* Append FDW-specific options and ddsf terminator. */
	memcpy(popt, non_libpq_options, sizeof(non_libpq_options));
}

/*
 * Check whether the given option is one of the valid ddsf_fdw options.
 * context is the Oid of the catalog holding the object the option is for.
 */
static bool
is_valid_option(const char *keyword, Oid context)
{
	DdsfFdwOption *opt;

	Assert(ddsf_fdw_options);	/* must be initialized already */

	for (opt = ddsf_fdw_options; opt->keyword; opt++)
	{
		ereport(INFO,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg("option name = \"%s\" key word = %s", opt->keyword, keyword)));
		if (context == opt->optcontext && strcmp(opt->keyword, keyword) == 0)
			return true;
	}

	return false;
}

/*
 * Check whether the given option is one of the valid libpq options.
 */
static bool
is_libpq_option(const char *keyword)
{
	DdsfFdwOption *opt;

	Assert(ddsf_fdw_options);	/* must be initialized already */

	for (opt = ddsf_fdw_options; opt->keyword; opt++)
	{
		if (opt->is_libpq_opt && strcmp(opt->keyword, keyword) == 0)
			return true;
	}

	return false;
}

/*
 * Generate key-value arrays which include only libpq options from the
 * given list (which can contain any kind of options).  Caller must have
 * allocated large-enough arrays.  Returns number of options found.
 */
int
ExtractConnectionOptions(List * defelems, const char **keywords,
						 const char **values)
{
	ListCell   *lc;
	int			i;

	/* Build our options lists if we didn't yet. */
	InitDdsfFdwOptions();

	i = 0;
	foreach(lc, defelems)
	{
		DefElem    *d = (DefElem *) lfirst(lc);

		if (is_libpq_option(d->defname))
		{
			keywords[i] = d->defname;
			values[i] = defGetString(d);
			i++;
		}
	}
	return i;
}
