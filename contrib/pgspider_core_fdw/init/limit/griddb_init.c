#include "gridstore.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

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
  char charArray[STRING_MAX_LENGTH];
  char* data;
  char* str;
  char* strArray[STRING_MAX_LENGTH];
  GSBool boolArray[STRING_MAX_LENGTH];
  int8_t byteArray[STRING_MAX_LENGTH];
  int16_t shortArray[STRING_MAX_LENGTH];
  int32_t intArray[STRING_MAX_LENGTH];
  int64_t longArray[STRING_MAX_LENGTH];
  float floatArray[STRING_MAX_LENGTH];
  double doubleArray[STRING_MAX_LENGTH];
  GSTimestamp timestampArray[STRING_MAX_LENGTH];
  int offset;
  size_t size;
  FILE *infile;
  GSRow *row;
  GSResult ret;
  GSBlob gsblob;
  infile = fopen(file_path, "r");

  if (!infile) {
    printf("Couldn't open %s for reading\n", file_path);
    return;
  }

  while(fgets(line, sizeof(line), infile) != NULL) {
    while (line[strlen(line) - 1] == '\n' || line[strlen(line) - 1] == '\r')
      line[strlen(line) - 1] = '\0';

    data = line;
    i = 0;
    while (sscanf(data, "%[^\t]\t%n", record_cols[i], &offset) == 1) {
      data += offset;
      i++;
    }

    /* Prepare data for a Row */
    {
      gsCreateRowByStore(store, &(tbl_info->info), &row);
      for (i = 0; i < tbl_info->info.columnCount; i++) {
        switch (tbl_info->info.columnInfoList[i].type) {
          case GS_TYPE_STRING:
            if(strcmp("\"\"",record_cols[i]) == 0) {
              ret = gsSetRowFieldByString(row, i, "");
            } else {
              ret = gsSetRowFieldByString(row, i, record_cols[i]);
            }
            break;
          case GS_TYPE_BOOL:
            ret = gsSetRowFieldByBool(row, i, atoi(record_cols[i]));
            break;
          case GS_TYPE_BYTE:
            ret = gsSetRowFieldByByte(row, i, (int8_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_SHORT:
            ret = gsSetRowFieldByShort(row, i, (int16_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_INTEGER:
            ret = gsSetRowFieldByInteger(row, i, (int32_t)atoi(record_cols[i]));
            break;
          case GS_TYPE_LONG:
            ret = gsSetRowFieldByLong(row, i, (int64_t)atol(record_cols[i]));
            break;
          case GS_TYPE_FLOAT:
            ret = gsSetRowFieldByFloat(row, i, strtof(record_cols[i], NULL));
            break;
          case GS_TYPE_DOUBLE:
            ret = gsSetRowFieldByDouble(row, i, strtod(record_cols[i], NULL));
            break;
          case GS_TYPE_TIMESTAMP:
            ret = gsSetRowFieldByTimestamp(row, i, (int64_t)atol(record_cols[i]));
            break;
          case GS_TYPE_GEOMETRY:
            ret = gsSetRowFieldByGeometry(row, i, record_cols[i]);
            break;
          case GS_TYPE_BLOB:
            // format (2,ab)
            str = record_cols[i];
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            // get size
            sscanf(str, "%d", (int*)&size);
            gsblob.size = size;
            // get data
            str += strcspn(str, ",") + 1;
            gsblob.data = str;
            ret = gsSetRowFieldByBlob(row, i, &gsblob);
            break;
          case GS_TYPE_STRING_ARRAY:
            // format (abc,xyz,123)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[(int)strlen(str)-1]==')') str[(int)strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              strArray[size] = strdup(charArray);
              size++;
            }
            ret = gsSetRowFieldByStringArray(row, i, (const GSChar *const *)strArray, size);
            break;
          case GS_TYPE_BOOL_ARRAY:
            // format (1,0,1)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              boolArray[size] = atoi(charArray);
              size++;
            }
            ret = gsSetRowFieldByBoolArray(row, i, boolArray, size);
            break;
          case GS_TYPE_BYTE_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              byteArray[size] = (int8_t) atoi(charArray);
              size++;
            }
            ret = gsSetRowFieldByByteArray(row, i, byteArray, size);
            break;
          case GS_TYPE_SHORT_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              shortArray[size] = (int16_t) atoi(charArray);
              size++;
            }
            ret = gsSetRowFieldByShortArray(row, i, shortArray, size);
            break;
          case GS_TYPE_INTEGER_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              intArray[size] = (int32_t) atoi(charArray);
              size++;
            }
            ret = gsSetRowFieldByIntegerArray(row, i, intArray, size);
            break;
          case GS_TYPE_LONG_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              longArray[size] = (int64_t) atol(charArray);
              size++;
            }
            ret = gsSetRowFieldByLongArray(row, i, longArray, size);
            break;
          case GS_TYPE_FLOAT_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              floatArray[size] = strtof(charArray, NULL);
              size++;
            }
            ret = gsSetRowFieldByFloatArray(row, i, floatArray, size);
            break;
          case GS_TYPE_DOUBLE_ARRAY:
            // format (123,456,789)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              doubleArray[size] = strtod(charArray, NULL);
              size++;
            }
            ret = gsSetRowFieldByDoubleArray(row, i, doubleArray, size);
            break;
          case GS_TYPE_TIMESTAMP_ARRAY:
            // format (1577937354961,1577937354961)
            str = record_cols[i];
            size = 0;
            if(str[0]=='(') str++;
            if(str[strlen(str)-1]==')') str[strlen(str)-1]='\0';
            while (sscanf(str, " %[^,]%n", charArray, &offset) == 1) {
              str += offset+1;
              timestampArray[size] = (GSTimestamp)atol(charArray);
              size++;
            }
            ret = gsSetRowFieldByTimestampArray(row, i, (const GSTimestamp *)timestampArray, size);
            break;
          default:
            break;
        }
        if(ret != GS_RESULT_OK) {
           printf("SET ROW FIELD FAILED WITH CODE = [%d]\n", ret);
        }
      }
    }

    /* Adding row */
    ret = gsPutRow(tbl_info->container, NULL, row, NULL);
    if (ret != GS_RESULT_OK)
    {
      printf("ADDING ROW FAILED WITH CODE = [%d]\n", ret);
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
                        const char *passwd,
			char *file_path)
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

  table_info TEST_TB_T1;

  set_tableInfo(store, "tbl01", &TEST_TB_T1,
                  11,
                  "c1", GS_TYPE_STRING, GS_TYPE_OPTION_NOT_NULL,
                  "c2", GS_TYPE_STRING, GS_TYPE_OPTION_NULLABLE,
                  "c3", GS_TYPE_STRING, GS_TYPE_OPTION_NULLABLE,
                  "c4", GS_TYPE_INTEGER, GS_TYPE_OPTION_NULLABLE,
                  "c5", GS_TYPE_FLOAT, GS_TYPE_OPTION_NULLABLE,
                  "c6", GS_TYPE_BYTE, GS_TYPE_OPTION_NULLABLE,
                  "c7", GS_TYPE_STRING, GS_TYPE_OPTION_NULLABLE,
                  "c8", GS_TYPE_LONG, GS_TYPE_OPTION_NULLABLE,
                  "c9", GS_TYPE_DOUBLE, GS_TYPE_OPTION_NULLABLE,
                  "c10", GS_TYPE_SHORT, GS_TYPE_OPTION_NULLABLE,
                  "c11", GS_TYPE_TIMESTAMP, GS_TYPE_OPTION_NULLABLE
                  );
  insertRecordsFromTSV (store, &TEST_TB_T1, file_path);

  /* Release the resource */
  gsCloseGridStore(&store, GS_TRUE);
}

/* Main function */
void main(int argc, char *argv[])
{
  if(argc != 7) {
    printf("Wrong syntax!!!\nExpected: ./griddb_init $HOST $PORT $CLUSTER $USER $PASSWORDS $FILE_PATH\n");
    return;
  }
  // argv[1]=HOST, argv[2]=PORT, argv[3]=CLUSTER, argv[4]=USER, argv[5]=PASSWORDS
  griddb_preparation(argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
}
