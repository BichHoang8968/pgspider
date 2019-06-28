#include "gridstore.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#define STRING_MAX_LENGTH 1000

typedef struct {
  GSContainer *container;
  GSContainerInfo info;
} table_info;

/**
 * Create table info
 * Arguments: GridStore instance, table name, table info, number of column, [ column1_name, column1_type, column1_options, column2_name, column2_type, column2_options,...
 */
void set_tableInfo (GSGridStore *store,
                    const GSChar *tbl_name,
                    table_info *tbl_info,
                    size_t column_count,...)
{
  GSResult ret;
  tbl_info->info = (GSContainerInfo)GS_CONTAINER_INFO_INITIALIZER;
  tbl_info->info.type = GS_CONTAINER_COLLECTION;
  tbl_info->info.name = tbl_name;
  tbl_info->info.columnCount = column_count;
  /* Set column info */
  GSColumnInfo column_info = GS_COLUMN_INFO_INITIALIZER;
  GSColumnInfo *column_info_list = calloc(column_count, sizeof(GSColumnInfo));
  int i;
  va_list valist;
  const GSChar *rowkey;
  va_start(valist, column_count);
  for (i = 0; i < column_count; i++) {
    column_info.name = va_arg(valist, GSChar*);
    if (i == 0) {
      rowkey = column_info.name;
    }
    column_info.type = va_arg(valist, GSType);
    column_info.options = va_arg(valist, GSTypeOption);
    column_info_list[i] = column_info;
  }
  va_end(valist);
  tbl_info->info.columnInfoList = column_info_list;
  tbl_info->info.rowKeyAssigned = GS_TRUE;
  /* Drop the old container if it existed */
  gsDropContainer(store, tbl_info->info.name);
  /* Create a Collection (Delete if schema setting is NULL) */
  ret = gsPutContainerGeneral(store, NULL, &(tbl_info->info), GS_FALSE, &(tbl_info->container));
  if (ret != GS_RESULT_OK) {
    printf("CREATE CONTAINER FAILED %s\n", tbl_name);
  }
  /* Set the autocommit mode to OFF */
  gsSetAutoCommit(tbl_info->container, GS_FALSE);
  /* Set an index on the Row-key Column */
  gsCreateIndex(tbl_info->container, rowkey, GS_INDEX_FLAG_DEFAULT);
}

/**
 * Insert records from TSV file
 * Arguments: GridStore instance, table info, TSV file path
 */
void insertRecordsFromTSV (GSGridStore *store, table_info *tbl_info, char* file_path)
{
  int i;
  // Create array to save a record
  char** record_cols = (char**) malloc(tbl_info->info.columnCount * sizeof(char*));

  for (i = 0; i < tbl_info->info.columnCount; i++) {
    record_cols[i] = (char*) malloc(STRING_MAX_LENGTH * sizeof(char));
  }

  // Open .data file (tab-separated values file)
  char line[STRING_MAX_LENGTH];
  char* data;
  int offset;
  FILE *infile;
  GSRow *row;
  GSResult ret;
  infile = fopen(file_path, "r");

  if (!infile) {
    printf("Couldn't open %s for reading\n", file_path);
    return;
  }

  while(fgets(line, sizeof(line), infile) != NULL) {
    data = line;
    i = 0;
    while (sscanf(data, " %[^\t^\n]%n", record_cols[i], &offset) == 1) {
      data += offset;
      i++;
    }

    /* Prepare data for a Row */
    {
      gsCreateRowByStore(store, &(tbl_info->info), &row);
      for (i = 0; i < tbl_info->info.columnCount; i++) {
        switch (tbl_info->info.columnInfoList[i].type) {
          case GS_TYPE_STRING:
            gsSetRowFieldByString(row, i, record_cols[i]);
            break;
          case GS_TYPE_BOOL:
            gsSetRowFieldByBool(row, i, atoi(record_cols[i]));
            break;
          case GS_TYPE_BYTE:
            gsSetRowFieldByByte(row, i, (int8_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_SHORT:
            gsSetRowFieldByShort(row, i, (int16_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_INTEGER:
            gsSetRowFieldByInteger(row, i, (int32_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_LONG:
            gsSetRowFieldByLong(row, i, atol(record_cols[i]));
            break;
          case GS_TYPE_FLOAT:
            gsSetRowFieldByFloat(row, i, strtof(record_cols[i], NULL));
            break;
          case GS_TYPE_DOUBLE:
            gsSetRowFieldByDouble(row, i, strtod(record_cols[i], NULL));
            break;
          default:
            break;
        }
      }
    }

    /* Adding row */
    ret = gsPutRow(tbl_info->container, NULL, row, NULL);
    if (ret != GS_RESULT_OK)
    {
      printf("ADDING ROW FAILED\n");
      return;
    }

    gsCloseRow(&row);
  }

  /* Commit the transaction (Release the lock) */
  ret = gsCommit(tbl_info->container);

  return;
}

/**
 * Connect to GridDB cluster and insert data to the database
 * Arguments: IP address, port, cluster name, username, password
 */
int griddb_preparation (const char *addr,
                        const char *port,
                        const char *cluster_name,
                        const char *user,
                        const char *passwd)
{
  static const GSBool update = GS_TRUE;
  GSColumnInfo* columnInfoList;
  GSGridStore *store;
  GSRow *row;
  GSQuery *query;
  GSRowSet *rs;
  GSResult ret;
  int count;
  int32_t id;
  const GSPropertyEntry props[] = {
      {"notificationAddress", addr},
      {"notificationPort", port},
      {"clusterName", cluster_name},
      {"user", user},
      {"password", passwd}};
  const size_t prop_count = sizeof(props) / sizeof(*props);
  /* Create a GridStore instance */
  gsGetGridStore(gsGetDefaultFactory(), props, prop_count, &store);

  table_info TEST_MULTI_TBL;

  set_tableInfo(store, "test_multi", &TEST_MULTI_TBL,
                  1,
                  "i", GS_TYPE_INTEGER, GS_TYPE_OPTION_NOT_NULL);

  insertRecordsFromTSV (store, &TEST_MULTI_TBL, "/tmp/griddb_core_multi.data");

  /* Release the resource */
  gsCloseGridStore(&store, GS_TRUE);
}

/* Main funtion */
void main(int argc, char *argv[])
{
  griddb_preparation(argv[1], argv[2], argv[3], argv[4], argv[5]);
}