#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/dir.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <limits.h>
#include <libpq-fe.h>

bool readconf();
void initdata();
bool connect_to_server(char *);
void writelog(char *);
void setpermission();
void killclientprocess();
void runtestsqlfile(char *, char *, int, int);
void workInDirectory(char *, int);
int systemCall(const char *command);
void restart_server();
void turn_off_server_restart();

#define CONFIGFILE "conf.txt"

#define NODE_STRUCTURE_1 "{\n\"Nodename\":\"pgspider1\",\n\"Nodes\":[\n{\n\"Nodename\":\"sqlite1\"\n},\n{\n\"Nodename\":\"sqlite2\"\n},\n{\n\"Nodename\":\"tinybrace1\"\n},\n{\n\"Nodename\":\"tinybrace2\"\n},\n{\n\"Nodename\":\"mysql1\"\n},\n{\n\"Nodename\":\"mysql2\"\n},\n{\n\"Nodename\":\"post1\"\n},\n{\n\"Nodename\":\"post2\"\n},\n{\n\"Nodename\":\"influx1\"\n},\n{\n\"Nodename\":\"influx2\"\n},\n{\n\"Nodename\":\"grid1\"\n},\n{\n\"Nodename\":\"grid2\"\n},\n{\n\"Nodename\":\"file11\"\n},\n{\n\"Nodename\":\"file12\"\n},\n{\n\"Nodename\":\"file15\"\n},\n{\n\"Nodename\":\"file_max_range\"\n}\n]\n}"
#define NODE_INFORMATION_1 "{\n\"pgspider1\":{\n\"FDW\":\"pgspider_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"%s\",\n\"user\":\"tsdv\",\n\"password\":\"1\",\n\"dbname\":\"pgspider\"\n},\n\"sqlite1\":{\n\"FDW\":\"sqlite_fdw\",\n\"dbname\":\"/tmp/sqlite_enhance_1.db\"\n},\n\"sqlite2\":{\n\"FDW\":\"sqlite_fdw\",\n\"dbname\":\"/tmp/sqlite_enhance_2.db\"\n},\n\"tinybrace1\":{\n\"FDW\":\"tinybrace_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"5100\",\n\"User\":\"user\",\n\"Password\":\"testuser\",\n\"dbname\":\"tinybrace_enhance_1.db\"\n},\n\"tinybrace2\":{\n\"FDW\":\"tinybrace_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"5100\",\n\"User\":\"user\",\n\"Password\":\"testuser\",\n\"dbname\":\"tinybrace_enhance_2.db\"\n},\n\"mysql1\":{\n\"FDW\":\"mysql_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"3306\",\n\"User\":\"root\",\n\"Password\":\"Mysql_1234\",\n\"dbname\":\"enhance_mysql_1\"\n},\n\"mysql2\":{\n\"FDW\":\"mysql_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"3306\",\n\"User\":\"root\",\n\"Password\":\"Mysql_1234\",\n\"dbname\":\"enhance_mysql_2\"\n},\n\"file11\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t11\",\n\"column\":\"c1 bigint, c2 bit(10), c3 varbit(10), c4 bool, c5 box, c6 bytea, c7 char(10), c8 varchar(10), c9 cidr, c10 circle, c11 date, c12 float8, c13 inet, c14 int, c15 interval, c18 line, c19 lseg, c20 macaddr, c21 money, c22 numeric, c23 path, c24 pg_lsn, c25 point, c26 polygon, c27 real, c28 smallint, c29 text, c30 time, c31 timetz, c32 timestamp, c33 timestamptz, c34 tsquery, c35 tsvector, c36 txid_snapshot, c37 uuid\"\n},\n\"file12\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t12\",\n\"column\":\"c1 text, c2 float8, c3 date, c4 money, c5 varchar(10)\"\n},\n\"file15\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t15\",\n\"column\":\"c1 timestamp, c2 text, c3 bigint, c4 double precision\"\n},\n\"file_max_range\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/file_max_range\",\n\"column\":\"c1 bigint, c2 date, c3 float8, c4 int, c5 real, c6 smallint, c7 time, c8 timetz, c9 timestamp, c10 timestamptz\"\n},\n\"post1\":{\n\"FDW\":\"postgres_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"15432\",\n\"dbname\":\"enhance_post_db1\",\n\"user\":\"tsdv\",\n\"password\":\"1\"\n},\n\"post2\":{\n\"FDW\":\"postgres_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"15432\",\n\"dbname\":\"enhance_post_db2\",\n\"user\":\"tsdv\",\n\"password\":\"1\"\n},\n\"influx1\":{\n\"FDW\":\"influxdb_fdw\",\n\"IP\":\"http://127.0.0.1\",\n\"Port\":\"8086\",\n\"dbname\":\"influx1\"\n},\n\"influx2\":{\n\"FDW\":\"influxdb_fdw\",\n\"IP\":\"http://127.0.0.1\",\n\"Port\":\"8086\",\n\"dbname\":\"influx2\"\n},\n\"grid1\":{\n\"FDW\":\"griddb_fdw\",\n\"IP\":\"239.0.0.1\",\n\"Port\":\"31999\",\n\"clustername\":\"griddbfdwTestCluster\",\n\"User\":\"admin\",\n\"Password\":\"testadmin\"\n},\n\"grid2\":{\n\"FDW\":\"griddb_fdw\",\n\"IP\":\"239.0.0.1\",\n\"Port\":\"31999\",\n\"clustername\":\"griddbfdwTestCluster\",\n\"User\":\"admin\",\n\"Password\":\"testadmin\"\n}\n}"
#define NODE_STRUCTURE_2 "{\n\"Nodename\":\"pgspider1\",\n\"Nodes\":[\n{\n\"Nodename\":\"pgspider2\",\n\"Nodes\":[\n{\n\"Nodename\":\"mysql1\"\n},\n{\n\"Nodename\":\"mysql2\"\n},\n{\n\"Nodename\":\"tinybrace1\"\n},\n{\n\"Nodename\":\"tinybrace2\"\n},\n{\n\"Nodename\":\"influx1\"\n},\n{\n\"Nodename\":\"influx2\"\n}\n]\n},\n{\n\"Nodename\":\"pgspider3\",\n\"Nodes\":[\n{\n\"Nodename\":\"post1\"\n},\n{\n\"Nodename\":\"post2\"\n},\n{\n\"Nodename\":\"file11\"\n},\n{\n\"Nodename\":\"file12\"\n},\n{\n\"Nodename\":\"file15\"\n},\n{\n\"Nodename\":\"file_max_range\"\n},\n{\n\"Nodename\":\"sqlite1\"\n},\n{\n\"Nodename\":\"sqlite2\"\n},\n{\n\"Nodename\":\"grid1\"\n},\n{\n\"Nodename\":\"grid2\"\n}\n]\n}\n]\n}"
#define NODE_INFORMATION_2 "{\n\"pgspider1\":{\n\"FDW\":\"pgspider_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"%s\",\n\"user\":\"tsdv\",\n\"password\":\"1\",\n\"dbname\":\"pgspider\"\n},\n\"pgspider2\":{\n\"FDW\":\"pgspider_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"%s\",\n\"user\":\"tsdv\",\n\"password\":\"1\",\n\"dbname\":\"pgspider\"\n},\n\"pgspider3\":{\n\"FDW\":\"pgspider_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"%s\",\n\"user\":\"tsdv\",\n\"password\":\"1\",\n\"dbname\":\"pgspider\"\n},\n\"sqlite1\":{\n\"FDW\":\"sqlite_fdw\",\n\"dbname\":\"/tmp/sqlite_enhance_1.db\"\n},\n\"sqlite2\":{\n\"FDW\":\"sqlite_fdw\",\n\"dbname\":\"/tmp/sqlite_enhance_2.db\"\n},\n\"tinybrace1\":{\n\"FDW\":\"tinybrace_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"5100\",\n\"User\":\"user\",\n\"Password\":\"testuser\",\n\"dbname\":\"tinybrace_enhance_1.db\"\n},\n\"tinybrace2\":{\n\"FDW\":\"tinybrace_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"5100\",\n\"User\":\"user\",\n\"Password\":\"testuser\",\n\"dbname\":\"tinybrace_enhance_2.db\"\n},\n\"mysql1\":{\n\"FDW\":\"mysql_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"3306\",\n\"User\":\"root\",\n\"Password\":\"Mysql_1234\",\n\"dbname\":\"enhance_mysql_1\"\n},\n\"mysql2\":{\n\"FDW\":\"mysql_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"3306\",\n\"User\":\"root\",\n\"Password\":\"Mysql_1234\",\n\"dbname\":\"enhance_mysql_2\"\n},\n\"file11\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t11\",\n\"column\":\"c1 bigint, c2 bit(10), c3 varbit(10), c4 bool, c5 box, c6 bytea, c7 char(10), c8 varchar(10), c9 cidr, c10 circle, c11 date, c12 float8, c13 inet, c14 int, c15 interval, c18 line, c19 lseg, c20 macaddr, c21 money, c22 numeric, c23 path, c24 pg_lsn, c25 point, c26 polygon, c27 real, c28 smallint, c29 text, c30 time, c31 timetz, c32 timestamp, c33 timestamptz, c34 tsquery, c35 tsvector, c36 txid_snapshot, c37 uuid\"\n},\n\"file12\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t12\",\n\"column\":\"c1 text, c2 float8, c3 date, c4 money, c5 varchar(10)\"\n},\n\"file15\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/t15\",\n\"column\":\"c1 timestamp, c2 text, c3 bigint, c4 double precision\"\n},\n\"file_max_range\":{\n\"FDW\":\"file_fdw\",\n\"dirpath\":\"/tmp/file_max_range\",\n\"column\":\"c1 bigint, c2 date, c3 float8, c4 int, c5 real, c6 smallint, c7 time, c8 timetz, c9 timestamp, c10 timestamptz\"\n},\n\"post1\":{\n\"FDW\":\"postgres_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"15432\",\n\"dbname\":\"enhance_post_db1\",\n\"user\":\"tsdv\",\n\"password\":\"1\"\n},\n\"post2\":{\n\"FDW\":\"postgres_fdw\",\n\"IP\":\"127.0.0.1\",\n\"Port\":\"15432\",\n\"dbname\":\"enhance_post_db2\",\n\"user\":\"tsdv\",\n\"password\":\"1\"\n},\n\"influx1\":{\n\"FDW\":\"influxdb_fdw\",\n\"IP\":\"http://127.0.0.1\",\n\"Port\":\"8086\",\n\"dbname\":\"influx1\"\n},\n\"influx2\":{\n\"FDW\":\"influxdb_fdw\",\n\"IP\":\"http://127.0.0.1\",\n\"Port\":\"8086\",\n\"dbname\":\"influx2\"\n},\n\"grid1\":{\n\"FDW\":\"griddb_fdw\",\n\"IP\":\"239.0.0.1\",\n\"Port\":\"31999\",\n\"clustername\":\"griddbfdwTestCluster\",\n\"User\":\"admin\",\n\"Password\":\"testadmin\"\n},\n\"grid2\":{\n\"FDW\":\"griddb_fdw\",\n\"IP\":\"239.0.0.1\",\n\"Port\":\"31999\",\n\"clustername\":\"griddbfdwTestCluster\",\n\"User\":\"admin\",\n\"Password\":\"testadmin\"\n}\n}"
///TODO(BINHNV): Change check timeout by fork to timeout command. Keep time out as 10 seconds
#if 0
#define SHELLSCRIPT "\
#/bin/bash \n\
%s \n\
"
#else
#define SHELLSCRIPT "\
#/bin/bash \n\
export LD_LIBRARY_PATH=:%s: \n\
timeout -s KILL 100s %s \n\
"
#endif

char PGSPIDER_FOLDER[512];
char SETUPCLUSTER_FOLDER[512];
char DESTINATION_FOLDER[512];
char LD_LIBRARY_PATH[512];

char PGSPIDER_LOGFILE[512];
char currentdir[512];
char    port1[5] = "";
char    port2[5] = "";
char    port3[5] = "";

int main(int argc, char **argv)
{
    char workdir[512];
    char command[255];

    // get current dir
    if (getcwd(currentdir, sizeof(currentdir)) != NULL) {
       sprintf(PGSPIDER_LOGFILE, "%s/%s", currentdir, "pgspider_test.log");
    } else {
       perror("Get current dir error");
       return 0;
    }
    // Set permission for shell script
    setpermission();
    sprintf(command, "touch %s", PGSPIDER_LOGFILE);
    systemCall(command);

    // read config file: PGSPIDER_FOLDER, SETUPCLUSTER_FOLDER, DESTINATION_FOLDER
    if (readconf() == false){
        printf("Read config file error");
        return 0;
    }
    // Delete DESTINATION_FOLDER
    sprintf(command, "rm -Rf %s", DESTINATION_FOLDER);
    systemCall(command);
    sprintf(command, "mkdir %s", DESTINATION_FOLDER);
    systemCall(command);

    // Currently, only execute test for ./basic/stablesql/ and ./basic/BugListTestcase/
    // The other tests (basic, multi, node_location) are disabled until PGSpider is stable

    // test all file in ./basic/stablesql
    //sprintf(workdir, "%s/basic/stablesql", currentdir);
    //workInDirectory(workdir, 1);

    // test all file in ./basic/BugListTestcase
    //sprintf(workdir, "%s/basic/BugListTestcase", currentdir);
    //workInDirectory(workdir, 1);

    // test all file in ./basic
    sprintf(workdir, "%s/basic", currentdir);
    workInDirectory(workdir, 1);

    // test all file in ./multi
    //sprintf(workdir, "%s/multi", currentdir);
    //workInDirectory(workdir, 2);

    // test all file in ./node_location
    //sprintf(workdir, "%s/node_location", currentdir);
    //workInDirectory(workdir, 3);

    return 1;
}

bool readconf(){
    char chline[1024];
    char * pch;

    FILE * pFile = fopen (CONFIGFILE , "r");
    if (pFile == NULL){
        writelog ("Error opening config file");
        return false;
    }
    int i = 0;
    while(fgets(chline, 1024, pFile) != NULL) {
        if (strncmp(chline, "#", 1) == 0)
            continue;
        if (strncmp(chline, "PGSPIDER_FOLDER", 15) == 0){
            i++;
            strcpy(PGSPIDER_FOLDER, chline + 16);

            pch=strrchr(PGSPIDER_FOLDER,'\n');
            if (pch != NULL)
                PGSPIDER_FOLDER[pch - PGSPIDER_FOLDER - 1] = 0;
        }

        if (strncmp(chline, "SETUPCLUSTER_FOLDER", 19) == 0){
            i++;
            strcpy(SETUPCLUSTER_FOLDER, chline + 20);

            pch=strrchr(SETUPCLUSTER_FOLDER,'\n');
            if (pch != NULL)
                SETUPCLUSTER_FOLDER[pch - SETUPCLUSTER_FOLDER - 1] = 0;
        }

        if (strncmp(chline, "DESTINATION_FOLDER", 18) == 0){
            i++;
            strcpy(DESTINATION_FOLDER, chline + 19);

            pch=strrchr(DESTINATION_FOLDER,'\n');
            if (pch != NULL)
                DESTINATION_FOLDER[pch - DESTINATION_FOLDER - 1] = 0;
        }
    }

    if (i >= 3)
        return true;
    return false;
}

void initdata(){
    char initdir[512];
    sprintf(initdir, "%s/../init_table", currentdir);
    chdir(initdir);
    systemCall("chmod +x init.sh");
    systemCall("./init.sh --start");
}

void setpermission(){   
    char    command[1024] = "";

    sprintf(command, "chmod +x %s/setuppgspider.sh", currentdir);
    systemCall(command);

    sprintf(command, "chmod +x %s/setupcluster.sh", currentdir);
    systemCall(command);

    sprintf(command, "chmod +x %s/restart_server.sh", currentdir);
    systemCall(command);
}

void workInDirectory(char *dirname, int imodel){
    DIR *           dir;
    struct dirent * dirp;
    int             iserver = 0;
    char            newdir[512];

    // go to dirname
    dir = opendir(dirname);
    if( dir == NULL )
        return;
    chdir(dirname);

    while((dirp=readdir(dir)) != NULL){
        if(dirp->d_type == 4){
            // go to child folder
            if(strcmp(dirp->d_name, ".") == 0 || strcmp(dirp->d_name, "..") == 0){
                continue;
            }
            sprintf(newdir, "%s/%s", dirname, dirp->d_name);
            workInDirectory(newdir, imodel);
        }
        else{
            // Read file and run query
            // skip if file is *.sql.txt
            if (strstr(dirp->d_name, ".sql.txt"))
                continue;

            if (strstr(dirp->d_name, ".sql")){
                iserver++;
                int pid;
#if 1
                // run on this process
                runtestsqlfile(dirname, dirp->d_name, imodel, iserver);
#else
                // run on other process
                if ((pid = fork()) == 0){
                    runtestsqlfile(dirname, dirp->d_name, imodel, iserver);
                    exit(0);
                }

                if (imodel == 1)
                    sleep(60*9);
                else if (imodel == 2)
                    sleep(60*16);
                else {
                    if (iserver == 1)
                        sleep(60*20);
                    else
                        sleep(60);
                }
#endif
            }
        }
    }

    chdir("..");
    closedir(dir);
}

//port: 4xyy: x: model, y: iserver
void runtestsqlfile(char * dirname, char *filename, int imodel, int iserver){
    FILE *  pFile;
    FILE *  outFile;
    FILE *  tmp_query;
    FILE *  nodeFile;
    char    chline [1024];
    char    testCase[256];
    char    query [2048];
    char    tmpfile[64];
    char    settimezone[] = "set timezone to +00;";
    char    command[1024] = "";
    char    outputFile[255] = "";
    char    shellcommand[1024] = "";
    char    msg[256];
    char    destSetup_cluster[512];
    char    tmpchar[512];
    int rc = -1;

    //init table data using init.sh
    initdata();

    sprintf(msg, "Start SQL File: %s/%s - %d", dirname, filename, imodel);
    writelog(msg);
    printf("%s\n", msg);

    // imode = 1 : basic
    // imode = 2 : multi
    // imode = 3 : node_location
    if (imodel == 3){
        //port
        sprintf(port1, "430%d", 1);
        sprintf(port2, "430%d", 2);
        sprintf(port3, "430%d", 3);
    }

    //create server and setup cluster
    if (imodel == 1){
        //BasicFeature
        //port
        if (iserver < 10)
            sprintf(port1, "410%d", iserver);
        else
            sprintf(port1, "41%d", iserver);
        //create server
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port1, DESTINATION_FOLDER);
        systemCall(command);
        //setup cluster
        //copy folder
        sprintf(command, "mkdir -p %s/PGS%s/Setup_cluster/", DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(command, "cp -Rf %s %s/PGS%s/Setup_cluster/", SETUPCLUSTER_FOLDER, DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(destSetup_cluster, "%s/PGS%s/Setup_cluster/PGSpider/contrib/setup_cluster", DESTINATION_FOLDER, port1);
        //node_structure
        sprintf(tmpchar, "%s/node_structure.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, "%s", NODE_STRUCTURE_1);
        fclose(nodeFile);
        //node_information
        sprintf(tmpchar, "%s/node_information.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, NODE_INFORMATION_1, port1);
        fclose(nodeFile);
        //run setup cluster
        sprintf(command, "%s/setupcluster.sh %s", currentdir, destSetup_cluster);
        systemCall(command);
        //view
        sprintf(command, "export LD_LIBRARY_PATH=:%s/PGS%s/lib/: ;%s/PGS%s/bin/psql -p %s --dbname=pgspider -f %s/createview.sql", DESTINATION_FOLDER, port1, DESTINATION_FOLDER, port1, port1, currentdir);
        printf("Create view: %s", command);
        systemCall(command);
    }
    else if (imodel == 2){
        //MultiLayer
        //port
        iserver = iserver * 3 - 2;
        if (iserver < 10){
            sprintf(port1, "420%d", iserver);
        }
        else{
            sprintf(port1, "42%d", iserver);
        }
        if (iserver + 1 < 10){
            sprintf(port2, "420%d", iserver + 1);
        }
        else{
            sprintf(port2, "42%d", iserver + 1);
        }
        if (iserver + 2 < 10){
            sprintf(port3, "420%d", iserver + 2);
        }
        else{
            sprintf(port3, "42%d", iserver + 2);
        }
        //create server
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port1, DESTINATION_FOLDER);
        systemCall(command);
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port2, DESTINATION_FOLDER);
        systemCall(command);
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port3, DESTINATION_FOLDER);
        systemCall(command);
        //setup cluster
        //copy folder
        sprintf(command, "mkdir -p %s/PGS%s/Setup_cluster/", DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(command, "cp -Rf %s %s/PGS%s/Setup_cluster/", SETUPCLUSTER_FOLDER, DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(destSetup_cluster, "%s/PGS%s/Setup_cluster/PGSpider/contrib/setup_cluster", DESTINATION_FOLDER, port1);
        //node_structure
        sprintf(tmpchar, "%s/node_structure.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, "%s", NODE_STRUCTURE_2);
        fclose(nodeFile);
        //node_information
        sprintf(tmpchar, "%s/node_information.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, NODE_INFORMATION_2, port1, port2, port3);
        fclose(nodeFile);
        //run setup cluster
        sprintf(command, "%s/setupcluster.sh %s", currentdir, destSetup_cluster);
        systemCall(command);
        //view
        sprintf(command, "export LD_LIBRARY_PATH=:%s/PGS%s/lib/: ;%s/PGS%s/bin/psql -p %s --dbname=pgspider -f %s/createview.sql", DESTINATION_FOLDER, port1, DESTINATION_FOLDER, port1, port1, currentdir);
        printf("Create view: %s", command);
        systemCall(command);
    }
    else if (imodel == 3 && iserver == 1){
        //Node_Location
        //create server
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port1, DESTINATION_FOLDER);
        systemCall(command);
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port2, DESTINATION_FOLDER);
        systemCall(command);
        sprintf(command, "%s/setuppgspider.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port3, DESTINATION_FOLDER);
        systemCall(command);
        //setup cluster
        sprintf(command, "mkdir -p %s/PGS%s/Setup_cluster/", DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(command, "cp -Rf %s %s/PGS%s/Setup_cluster/", SETUPCLUSTER_FOLDER, DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(destSetup_cluster, "%s/PGS%s/Setup_cluster/PGSpider/contrib/setup_cluster", DESTINATION_FOLDER, port1);
        //node_structure
        sprintf(tmpchar, "%s/node_structure.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, "%s", NODE_STRUCTURE_2);
        fclose(nodeFile);
        //node_information
        sprintf(tmpchar, "%s/node_information.json", destSetup_cluster);
        nodeFile = fopen(tmpchar, "w");
        fprintf(nodeFile, NODE_INFORMATION_2, port1, port2, port3);
        fclose(nodeFile);
        //run setup cluster
        sprintf(command, "%s/setupcluster.sh %s", currentdir, destSetup_cluster);
        systemCall(command);
    }

    chdir(dirname);
    pFile = fopen (filename , "r");
    if (pFile == NULL){
        writelog ("Error opening sql file");
        return;
    }

    //sprintf(tmpfile, "/tmp/tmp_query_%d_%d.txt", imodel, iserver);
    // Open "/tmp/tmp_query_all.txt" and write expected input
    tmp_query = fopen("/tmp/tmp_query_all.txt", "w");
    strcpy(tmpfile, "/tmp/tmp_query.txt");
    if(tmp_query==NULL)
    {
        writelog("Could not open tmp_query_all.txt file");
        return;
    }
    while(fgets(chline, 1024, pFile) != NULL) {
        if (strstr(chline, "Testcase"))
        {
            // chline -> "Testcase"
            // query -> SQL query after "Testcase"
            if (fgets(query, 2048, pFile) != NULL){
                printf(chline);
                chline[strlen(chline) - 1] = '\0';
                // output Set timezone + Test case + SQL to file /tmp/tmp_query_all.txt
                fprintf(tmp_query, "%s\n%s\n%s", settimezone, chline, query);
            }
        }
    }
    fclose(tmp_query);

    // Move /tmp/tmp_query_all.txt -> /tmp/tmp_query.txt
    systemCall("cp /tmp/tmp_query_all.txt /tmp/tmp_query.txt");
    rc = -1;
    sprintf(outputFile, "%s/../results/%s.txt", dirname, filename);
    while( 1 ){
        // Execute tmp_query.txt
        if (imodel == 1){
            if (!connect_to_server(port1))
                continue;
            sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, outputFile);
        }
        else if (imodel == 2){
            if (!connect_to_server(port1))
                continue;
            sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, outputFile);
        }
        else if (imodel == 3){
            if (strstr(filename, "PGSpider1")){
                if (!connect_to_server(port1))
                    continue;
                sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, outputFile);
            }
            else if (strstr(filename, "PGSpider2")){
                if (!connect_to_server(port2))
                    continue;
                sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s 2>&1", DESTINATION_FOLDER, port2, port2, tmpfile, outputFile);
            }
            else if (strstr(filename, "PGSpider3")){
                if (!connect_to_server(port3))
                    continue;
                sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s 2>&1", DESTINATION_FOLDER, port3, port3, tmpfile, outputFile);
            }
        }
 
        sprintf(LD_LIBRARY_PATH, "%s/PGS%s/lib", DESTINATION_FOLDER, port1);
        sprintf(shellcommand, SHELLSCRIPT, LD_LIBRARY_PATH, command);
#if 1
        printf("Execute [%s]\n", shellcommand);
        rc = system(shellcommand);
        if (rc == 137) {
            printf(" is time out\n");
        } else if (rc == 512) {
            printf(" is fails ret code : %d\n", rc);
            restart_server();
        } else if (rc != 0) {
            printf(" is fails ret code : %d\n", rc);
        }
        // If it return failure --> create new /tmp/tmp_query.txt and execute again until it return 0
        if (1) {
            int foundTestCase = 0;
            int testCaseCount = 0;
            // get last executed test case in output file
            tmp_query = fopen(outputFile, "r");
            if(tmp_query==NULL)
            {
                writelog("Output file does not exists:");
                writelog(outputFile);
                return;
            }
            strcpy(testCase, "");
            while(fgets(chline, 1024, tmp_query) != NULL) {
                if (strstr(chline, "Testcase"))
                {
                    strcpy(testCase, chline);
                }
            }
            fclose(tmp_query);
            printf("Last executed test case is: [%s]\n", testCase);
            if(strcmp(testCase, "")==0) {
                writelog("Cannot find last executed test case in ");
                writelog(outputFile);
                return;
            }
            // create new tmp_query.txt file from last executed test case --> end of file
            tmp_query = fopen("/tmp/tmp_query_all.txt", "r");
            if(tmp_query==NULL)
            {
                writelog("Could not open tmp_query_all.txt file");
                return;
            }
            outFile = fopen("/tmp/tmp_query.txt", "w");
            if(outFile==NULL)
            {
                writelog("Could not open /tmp/tmp_query.txt file for writing");
                return;
            }
            foundTestCase = -1;
            testCaseCount = 0;
            while(fgets(chline, 1024, tmp_query) != NULL) {
                if(foundTestCase == 1) 
                {
                    if (strstr(chline, settimezone)){
                        testCaseCount++;
                        if(testCaseCount >= 20) {
                            // only output 20 test case
                            break;
                        }
                    }
                    fprintf(outFile, "%s", chline);
                }
                else if (strstr(chline, "Testcase"))
                {
                    if (foundTestCase == 0) {
                        foundTestCase = 1;
                        testCaseCount++;
                        fprintf(outFile, "%s\n", settimezone);
                        fprintf(outFile, "%s", chline);
                    } else {
                        // printf("strcmp [%s] [%s]\n", chline, testCase);
                        if (strcmp(chline, testCase) == 0){
                            foundTestCase = 0;
                            printf("FOUND last executed test case [%s]\n", testCase);
                        }
                    }
                }
            }
            if(foundTestCase != 1) {
                 printf("Test case not found: %s\n", testCase);
            }
            fclose(outFile);
            fclose(tmp_query);
            if(testCaseCount==0) {
                break;
            }
            usleep(100);
        }
#endif
    }
//    strcpy(tmpfile, "/tmp/tmp_query.txt");
//    while(fgets(chline, 1024, pFile) != NULL) {
//        if (strstr(chline, "Testcase"))
//        {
//            if (fgets(query, 2048, pFile) != NULL){
//                tmp_query = fopen(tmpfile, "w");
//
//                if(tmp_query==NULL)
//                {
//                    writelog("Could not open tmp_query file");
//                    continue;
//                }
//
//                printf(chline);
//                chline[strlen(chline) - 1] = '\0';
//                fprintf(tmp_query, "%s\n%s\n%s", settimezone, chline, query);
//                fclose(tmp_query);
//                if (imodel == 1){
//                    if (!connect_to_server(port1))
//                        continue;
//                    sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s/../results/%s.txt 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, dirname, filename);
//                }
//                else if (imodel == 2){
//                    if (!connect_to_server(port1))
//                        continue;
//                    sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s/../results/%s.txt 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, dirname, filename);
//                }
//                else if (imodel == 3){
//                    if (strstr(filename, "PGSpider1")){
//                        if (!connect_to_server(port1))
//                            continue;
//                        sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s/../results/%s.txt 2>&1", DESTINATION_FOLDER, port1, port1, tmpfile, dirname, filename);
//                    }
//                    else if (strstr(filename, "PGSpider2")){
//                        if (!connect_to_server(port2))
//                            continue;
//                        sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s/../results/%s.txt 2>&1", DESTINATION_FOLDER, port2, port2, tmpfile, dirname, filename);
//                    }
//                    else if (strstr(filename, "PGSpider3")){
//                        if (!connect_to_server(port3))
//                            continue;
//                        sprintf(command, "%s/PGS%s/bin/psql --host=127.0.0.1 --port=%s  --dbname=pgspider -a -f %s >> %s/../results/%s.txt 2>&1", DESTINATION_FOLDER, port3, port3, tmpfile, dirname, filename);
//                    }
//                }
//
//                sprintf(LD_LIBRARY_PATH, "%s/PGS%s/lib", DESTINATION_FOLDER, port1);
//                sprintf(shellcommand, SHELLSCRIPT, LD_LIBRARY_PATH, command);
//#if 1
//                // printf("Execute [%s]\n", shellcommand);
//                int ret = system(shellcommand);
//                if (ret == 137) {
//                    printf(" is time out\n");
//                } else if (ret == 512) {
//                    printf(" is fails ret code : %d\n", ret);
//                    restart_server();
//                } else if (ret != 0) {
//                    printf(" is fails ret code : %d\n", ret);
//                }
//                killclientprocess();
//                usleep(100);
//#else
//                int timeout = 200;
//                int pid;
//                if ((pid = fork()) == 0){
//                    systemCall(shellcommand);
//                    printf(".");
//                    exit(1);
//                }
//                else{
//                    signal(SIGCHLD,SIG_IGN); 
//                    int waittime = 0;
//                    int Stat, wpid;
//                    do {
//                        wpid = waitpid(pid, &Stat, WNOHANG);
//                        if (wpid == 0) {
//                            if (waittime++ < timeout) {
//                                usleep(100*1000);
//                            }
//                            else {
//                                int countid = 1;
//                                FILE *fp;
//                                char processname[255];
//                                while(1){
//                                    sprintf(command, "ps -p %d -o args=", pid + countid);
//                                    fp = popen(command, "r");
//                                    if (fp != NULL) {
//                                        fgets(processname, sizeof(processname)-1, fp);
//                                        if (strstr(processname, "postgres") != NULL && strstr(processname, "SELECT") != NULL){
//                                            sprintf(command, "kill -9 %d", pid + countid);
//                                            systemCall(command);
//                                            break;
//                                        }
//                                    }
//                                    if ( countid++ > 30)
//                                        break;
//                                }
//
//                                pclose(fp);
//                            }
//                        }
//                    } while (wpid == 0 && waittime <= timeout);
//                }
//#endif
//            }
//        }
//        usleep(10);
//    }

    sprintf(msg, "Done SQL File: %s - %d", filename, imodel);
    writelog(msg);
    printf("%s\n", msg);
    //Delete folder server
    if (imodel == 1){
        sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port1);
        systemCall(command);
    }
    else if (imodel == 2){
        // Step server 1
        sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port1);
        systemCall(command);
        sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port1);
        systemCall(command);
        // Step server 2
        sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port2);
        systemCall(command);
        sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port2);
        systemCall(command);
        // Step server 3
        sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port3);
        systemCall(command);
        sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port3);
        systemCall(command);
    }
    else if (imodel == 3){
        if (iserver == 3){
            // Step server 1
            sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port1);
            systemCall(command);
            sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port1);
            systemCall(command);

            // Step server 2
            sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port2);
            systemCall(command);
            sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port2);
            systemCall(command);

            // Step server 3
            sprintf(command, "cd %s/PGS%s/bin ; ./pg_ctl -D ../databases stop ; cd -", DESTINATION_FOLDER, port3);
            systemCall(command);
            sprintf(command, "rm -Rf %s/PGS%s", DESTINATION_FOLDER, port3);
            systemCall(command);
        }
    }
    fclose (pFile);
    return;
}

void killclientprocess(){
    FILE *fp;
    char command[512] = { 0 };
    char processid[128] = { 0 };
    char buf[128] = { 0 };
    char * pch;

    strcpy(command, "pgrep -f \"tsdv pgspider\"");
    fp = popen(command, "r");
    if (fp != NULL) {
        fgets(buf, sizeof(buf)-1, fp);
        if (strlen(buf) != 0){
            pch = strchr(buf, '\n');
            while (pch != NULL){
                strncpy(processid, buf, pch - buf);
                sprintf(command, "kill -9 %s", processid);
                systemCall(command);
                printf("command: %s.\n", command);
                strcpy(buf, pch + 1);
                pch = strchr(buf, '\n');
            }
        }
        pclose(fp);
    }

    return;
}

/* 
** Execute ./restart_server PGSPIDER_FOLDER, port1, DESTINATION_FOLDER
** to restart pgspider server
*/
void restart_server(){
    char command[512] = { 0 };
    sprintf(command, "%s/restart_server.sh %s %s %s", currentdir, PGSPIDER_FOLDER, port1, DESTINATION_FOLDER);
    systemCall(command);
    printf("--- Done executing restart_server.sh ---\n");
}

/**
 ** 1. Kill all postgres process
 ** 2. run init.sh to restart postgresql server
 ** 3. run restart_server.sh to restart server
 **/
void turn_off_server_restart(){
    char command[100] = { 0 };
    sprintf(command, "pkill -9 postgres");
    systemCall(command);
    initdata();
    restart_server();
}

bool connect_to_server(char * port){
    char msg[256] = "";
    PGconn  *conn;
    int count=0;
    conn = PQsetdbLogin(
                     "127.0.0.1",
                     port,
                     NULL,
                     NULL,
                     "pgspider",
                     NULL,
                     NULL
    );

    while (PQstatus(conn) == CONNECTION_BAD) {
        if(++count > 100){
            count = 0;
            turn_off_server_restart();
        }
        PQfinish(conn);
        usleep(200*1000);
        conn = PQsetdbLogin(
                         "127.0.0.1",
                         port,
                         NULL,
                         NULL,
                         "pgspider",
                         NULL,
                         NULL
        );
    }

    if (PQstatus(conn) == CONNECTION_BAD){
        printf("Connection to database failed: %s\n", PQerrorMessage(conn));
        sprintf(msg, "Connection to database failed: %s", PQerrorMessage(conn));
        writelog(msg);
        PQfinish(conn);
        return false;
    }

    PQfinish(conn);
    return true;
}

int systemCall(const char *command) {
    printf("System Call CMD: %s\n", command);
    return system(command);
}

void writelog(char *msg){
    FILE        *logfile;
    time_t      rawtime;
    struct tm * timeinfo;

    time( &rawtime );
    timeinfo = localtime( &rawtime );

    logfile = fopen (PGSPIDER_LOGFILE, "a");
    fprintf(logfile, "%02d-%02d-%02d %02d:%02d:%02d: %s\n", timeinfo->tm_mday, timeinfo->tm_mon + 1, timeinfo->tm_year + 1900, timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec, msg);
    
    fclose(logfile);
    return;
}