#include <gridstore.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#define STRING_MAX_LENGTH 1000

typedef struct
{
	GSContainer *container;
	GSContainerInfo info;
}			table_info;

GSResult	set_tableInfo(GSGridStore * store,
						  const GSChar * tbl_name,
						  table_info * tbl_info,
						  size_t column_count,...);

GSResult	insert_recordsFromTSV(GSGridStore * store,
								  table_info * tbl_info,
								  char *file_path);

GSResult	griddb_init(const char *notification_member,
						const char *cluster_name,
						const char *user,
						const char *passwd);

/**
 *	Create table info
 *	Arguments: GridStore instance, table name, table info, number of column, [ column1_name, column1_type, column1_options, column2_name, column2_type, column2_options,...
 */
GSResult
set_tableInfo(GSGridStore * store,
			  const GSChar * tbl_name,
			  table_info * tbl_info,
			  size_t column_count,...)
{
	GSResult	ret = GS_RESULT_OK;
	int			i;
	va_list		valist;

	/* Set column info */
	GSColumnInfo column_info = GS_COLUMN_INFO_INITIALIZER;
	GSColumnInfo *column_info_list = calloc(column_count, sizeof(GSColumnInfo));

	tbl_info->info = (GSContainerInfo) GS_CONTAINER_INFO_INITIALIZER;
	tbl_info->info.type = GS_CONTAINER_COLLECTION;
	tbl_info->info.name = tbl_name;
	tbl_info->info.columnCount = column_count;
	va_start(valist, column_count);
	for (i = 0; i < column_count; i++)
	{
		column_info.name = va_arg(valist, GSChar *);
		column_info.type = va_arg(valist, GSType);
		column_info.options = va_arg(valist, GSTypeOption);
		column_info_list[i] = column_info;
	}
	va_end(valist);
	tbl_info->info.columnInfoList = column_info_list;
	tbl_info->info.rowKeyAssigned = GS_TRUE;
	/* Drop the old container if it existed */
	ret = gsDropContainer(store, tbl_info->info.name);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Can not drop container \"%s\"\n", tbl_name);
		return ret;
	}
	/* Create a Collection (Delete if schema setting is NULL) */
	ret = gsPutContainerGeneral(store, NULL, &(tbl_info->info), GS_FALSE, &(tbl_info->container));
	if (!GS_SUCCEEDED(ret))
	{
		printf("Create container \"%s\" failed\n", tbl_name);
		return ret;
	}
	/* Set the autocommit mode to OFF */
	ret = gsSetAutoCommit(tbl_info->container, GS_FALSE);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Set autocommit for container %s failed\n", tbl_name);
		return ret;
	}

	return GS_RESULT_OK;
}

/**
 *	Create table info
 *	Arguments: GridStore instance, table name, table info, number of column, [ column1_name, column1_type, column1_options, column2_name, column2_type, column2_options,...
 */
GSResult
set_tableInfo_timeseries(GSGridStore * store,
						 const GSChar * tbl_name,
						 table_info * tbl_info,
						 size_t column_count,...)
{
	GSResult	ret = GS_RESULT_OK;
	int			i;
	va_list		valist;

	/* Set column info */
	GSColumnInfo column_info = GS_COLUMN_INFO_INITIALIZER;
	GSColumnInfo *column_info_list = calloc(column_count, sizeof(GSColumnInfo));

	tbl_info->info = (GSContainerInfo) GS_CONTAINER_INFO_INITIALIZER;
	tbl_info->info.type = GS_CONTAINER_TIME_SERIES;
	tbl_info->info.name = tbl_name;
	tbl_info->info.columnCount = column_count;
	va_start(valist, column_count);
	for (i = 0; i < column_count; i++)
	{
		column_info.name = va_arg(valist, GSChar *);
		column_info.type = va_arg(valist, GSType);
		column_info.options = va_arg(valist, GSTypeOption);
		column_info_list[i] = column_info;
	}
	va_end(valist);
	tbl_info->info.columnInfoList = column_info_list;
	tbl_info->info.rowKeyAssigned = GS_TRUE;
	/* Drop the old container if it existed */
	ret = gsDropContainer(store, tbl_info->info.name);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Can not drop container \"%s\"\n", tbl_name);
		return ret;
	}
	/* Create a Collection (Delete if schema setting is NULL) */
	ret = gsPutContainerGeneral(store, NULL, &(tbl_info->info), GS_FALSE, &(tbl_info->container));
	if (!GS_SUCCEEDED(ret))
	{
		printf("Create container \"%s\" failed\n", tbl_name);
		return ret;
	}
	/* Set the autocommit mode to OFF */
	ret = gsSetAutoCommit(tbl_info->container, GS_FALSE);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Set autocommit for container %s failed\n", tbl_name);
		return ret;
	}

	return GS_RESULT_OK;
}

/**
 *	Insert records from TSV file
 *	Arguments: GridStore instance, table info, TSV file path
 */
GSResult
insert_recordsFromTSV(GSGridStore * store,
					  table_info * tbl_info,
					  char *file_path)
{
	GSResult	ret = GS_RESULT_OK;
	int			i;
	char	  **record_cols;
	char		line[STRING_MAX_LENGTH];
	char	   *data;
	int			offset;
	FILE	   *infile;
	GSRow	   *row;

	/* Create an array to save a record */
	record_cols = (char **) malloc(tbl_info->info.columnCount * sizeof(char *));
	if (!record_cols)
	{
		printf("Couldn't allocate the array to save record\n");
		return !GS_RESULT_OK;
	}
	for (i = 0; i < tbl_info->info.columnCount; i++)
	{
		record_cols[i] = (char *) malloc(STRING_MAX_LENGTH * sizeof(char));
		if (!record_cols[i])
		{
			printf("Couldn't allocate the array to save record\n");
			return !GS_RESULT_OK;
		}
	}

	/* Open .data file (tab-separated values file) */
	infile = fopen(file_path, "r");
	if (!infile)
	{
		printf("Couldn't open \"%s\" file for reading\n", file_path);
		return !GS_RESULT_OK;
	}

	/* Get data from TSV file and save to the corresponding table */
	while (fgets(line, sizeof(line), infile) != NULL)
	{
		while (line[strlen(line) - 1] == '\n' || line[strlen(line) - 1] == '\r')
			line[strlen(line) - 1] = '\0';

		data = line;
		i = 0;
		while (sscanf(data, "%[^\t]\t%n", record_cols[i], &offset) == 1)
		{
			data += offset;
			i++;
		}

		/* Prepare data for a Row */
		ret = gsCreateRowByStore(store, &(tbl_info->info), &row);
		if (!GS_SUCCEEDED(ret))
		{
			printf("Create new GSRow with table \"%s\" failed\n", tbl_info->info.name);
			return ret;
		}
		for (i = 0; i < tbl_info->info.columnCount; i++)
		{
			switch (tbl_info->info.columnInfoList[i].type)
			{
				case GS_TYPE_STRING:
					ret = gsSetRowFieldByString(row, i, record_cols[i]);
					break;
				case GS_TYPE_BOOL:
					ret = gsSetRowFieldByBool(row, i, atoi(record_cols[i]));
					break;
				case GS_TYPE_BYTE:
					ret = gsSetRowFieldByByte(row, i, (int8_t) atoi(record_cols[i]));
					break;
				case GS_TYPE_SHORT:
					ret = gsSetRowFieldByShort(row, i, (int16_t) atoi(record_cols[i]));
					break;
				case GS_TYPE_INTEGER:
					ret = gsSetRowFieldByInteger(row, i, (int32_t) atoi(record_cols[i]));
					break;
				case GS_TYPE_LONG:
					ret = gsSetRowFieldByLong(row, i, atol(record_cols[i]));
					break;
				case GS_TYPE_FLOAT:
					ret = gsSetRowFieldByFloat(row, i, strtof(record_cols[i], NULL));
					break;
				case GS_TYPE_DOUBLE:
					ret = gsSetRowFieldByDouble(row, i, strtod(record_cols[i], NULL));
					break;
				case GS_TYPE_TIMESTAMP:
					{
						GSBool		status;
						GSTimestamp timestamp;

						status = gsParseTime(record_cols[i], &timestamp);
						if (status == GS_FALSE)
						{
							printf("failed convert timestamp: %s\n", record_cols[i]);
						}

						ret = gsSetRowFieldByTimestamp(row, i, timestamp);
						break;
					}
				default:
					break;
					/* if needed */
					/* case GS_TYPE_TIMESTAMP: */
					/* gsSetRowFieldByTimestamp(row, i, ); */
					/* break; */
					/* case GS_TYPE_GEOMETRY: */
					/* gsSetRowFieldByGeometry(row, i, ); */
					/* break; */
					/* case GS_TYPE_BLOB: */
					/* gsSetRowFieldByBlob(row, i, ); */
					/* break; */
			}

			if (!GS_SUCCEEDED(ret))
			{
				return ret;
			}
		}

		/* Add row to the corresponding table */
		ret = gsPutRow(tbl_info->container, NULL, row, NULL);
		if (!GS_SUCCEEDED(ret))
		{
			printf("Add new row to table \"%s\" failed\n", tbl_info->info.name);
			return ret;
		}

		gsCloseRow(&row);
	}

	/* Commit the transaction (Release the lock) */
	ret = gsCommit(tbl_info->container);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Commit data to the table \"%s\" failed\n", tbl_info->info.name);
		return ret;
	}

	return GS_RESULT_OK;
}

/**
 *	Connect to GridDB cluster and insert data to the database
 *	Arguments: IP address, port, cluster name, username, password
 */
GSResult
griddb_init(const char *notification_member,
			const char *cluster_name,
			const char *user,
			const char *passwd)
{
	GSGridStore *store;
	GSResult	ret = GS_RESULT_OK;

	table_info	tntbl2,
				tntbl21,
				tntbl3;
	const		GSPropertyEntry props[] = {
		{"notificationMember", notification_member},
		{"clusterName", cluster_name},
		{"user", user},
		{"password", passwd}
	};
	const size_t prop_count = sizeof(props) / sizeof(*props);

	/* Create a GridStore instance */
	ret = gsGetGridStore(gsGetDefaultFactory(), props, prop_count, &store);
	if (!GS_SUCCEEDED(ret))
	{
		printf("Get GridDB instance failed\n");
		goto EXIT;
	}

	ret = set_tableInfo(store, "tntbl2", &tntbl2,
						6,
						"_id", GS_TYPE_STRING, GS_TYPE_OPTION_NOT_NULL,
						"c1", GS_TYPE_INTEGER, GS_TYPE_OPTION_NULLABLE,
						"c2", GS_TYPE_STRING, GS_TYPE_OPTION_NULLABLE,
						"c3", GS_TYPE_BOOL, GS_TYPE_OPTION_NULLABLE,
						"c4", GS_TYPE_DOUBLE, GS_TYPE_OPTION_NULLABLE,
						"c5", GS_TYPE_LONG, GS_TYPE_OPTION_NULLABLE);
	if (!GS_SUCCEEDED(ret))
		goto EXIT;

	ret = set_tableInfo(store, "tntbl21", &tntbl21,
						6,
						"_id", GS_TYPE_STRING, GS_TYPE_OPTION_NOT_NULL,
						"c1", GS_TYPE_INTEGER, GS_TYPE_OPTION_NULLABLE,
						"c2", GS_TYPE_STRING, GS_TYPE_OPTION_NULLABLE,
						"c3", GS_TYPE_BOOL, GS_TYPE_OPTION_NULLABLE,
						"c4", GS_TYPE_DOUBLE, GS_TYPE_OPTION_NULLABLE,
						"c5", GS_TYPE_LONG, GS_TYPE_OPTION_NULLABLE);
	if (!GS_SUCCEEDED(ret))
		goto EXIT;

	ret = set_tableInfo(store, "tntbl3", &tntbl3,
								   5,
								   "_id", GS_TYPE_STRING, GS_TYPE_OPTION_NOT_NULL,
								   "c1", GS_TYPE_INTEGER, GS_TYPE_OPTION_NULLABLE,
								   "c2", GS_TYPE_FLOAT, GS_TYPE_OPTION_NULLABLE,
								   "c3", GS_TYPE_DOUBLE, GS_TYPE_OPTION_NULLABLE,
								   "c4", GS_TYPE_LONG, GS_TYPE_OPTION_NULLABLE);
	if (!GS_SUCCEEDED(ret))
		goto EXIT;

EXIT:
	/* Release the resource */
	gsCloseGridStore(&store, GS_TRUE);
	return ret;
}

/* Main funtion */
GSResult
main(int argc, char *argv[])
{
	GSResult	ret = !GS_RESULT_OK;
	int			i = 0;
	char	   *key,
			   *value;
	char	   *notification_member,
			   *cluster,
			   *user,
			   *passwd;

	if (argc < 5)
	{
		printf("Missing arguments\n");
		goto TERMINATE;
	}
	else
	{
		for (i = 1; i < argc; i++)
		{
			/* Argument format: key=value */
			key = strtok(argv[i], "=");
			value = strtok(NULL, " ");
			if (value == NULL)
			{
				printf("Invalid options\n"
					   "Usage:\n    ./griddb_init notification_member=a cluster=b user=c passwd=d\n");
				goto TERMINATE;
			}
			else
			{
				if (strcmp(key, "notification_member") == 0)
				{
					notification_member = value;
				}
				else if (strcmp(key, "cluster") == 0)
				{
					cluster = value;
				}
				else if (strcmp(key, "user") == 0)
				{
					user = value;
				}
				else if (strcmp(key, "passwd") == 0)
				{
					passwd = value;
				}
				else
				{
					printf("Invalid options\n"
						   "Usage:\n    ./griddb_init notification_member=a cluster=b user=c passwd=d\n");
					goto TERMINATE;
				}
			}
		}
	}
	ret = griddb_init(notification_member, cluster, user, passwd);
	if (GS_SUCCEEDED(ret))
	{
		printf("Initialize all containers sucessfully.\n");
	}
	else
	{
		printf("Initializer has some problems!\n");
	}
TERMINATE:
	return ret;
}

