#include<stdio.h>
#include<stdlib.h>
#include <stdbool.h>
#include<sys/types.h>
#include<sys/dir.h>
#include<dirent.h>
#include<fcntl.h>
#include<unistd.h>
#include<string.h>
#include <time.h>
#include <signal.h>
#include <limits.h>
#include <libpq-fe.h>

bool connect_to_server();
void writelog(char *);
void readsqlfile(char *);
void searchInDirectory(char*);

static char* PGSPIDER_BIN;
static char* PGSPIDER_HOST;
static char* PGSPIDER_PORT;
static char* PGSPIDER_DATABASE;
static char PGSPIDER_LOGFILE[PATH_MAX];


#define SHELLSCRIPT "\
#/bin/bash \n\
%s \n\
"

int main(int argc, char **argv)
{
    if (argc != 5){
        printf("PGSpider Auto Test\r\n\r\nUsage:\r\n\tpgspider_test [PGSPIDER_BIN_FOLDER] [HOST] [PORT] [DATABASE]\r\n");
        return 0;
    }

    PGSPIDER_BIN        = argv[1];
    PGSPIDER_HOST       = argv[2];
    PGSPIDER_PORT       = argv[3];
    PGSPIDER_DATABASE   = argv[4];

   if (getcwd(PGSPIDER_LOGFILE, sizeof(PGSPIDER_LOGFILE)) != NULL) {
       sprintf(PGSPIDER_LOGFILE, "%s/%s", PGSPIDER_LOGFILE, "getexpected.log");
   } else {
       perror("Get current dir error");
       return 0;
   }

    writelog("---------------------Begin---------------------\r\n");
    searchInDirectory("./basic");
    writelog("---------------------Exit---------------------\r\n");
    return 1;
}

void searchInDirectory(char *dirname){
    DIR *           dir;
    struct dirent * dirp;

    dir = opendir(dirname);
    chdir(dirname);

    while((dirp=readdir(dir)) != NULL){
        if(dirp->d_type == 4){
            if(strcmp(dirp->d_name, ".") == 0 || strcmp(dirp->d_name, "..") == 0){
                continue;
            }
            searchInDirectory(dirp->d_name);
        }
        else{
            //Read file and run query

            if (strstr(dirp->d_name, ".sql.txt"))
                continue;
            if (strstr(dirp->d_name, ".sql")){
                readsqlfile(dirp->d_name);
            }
        }
    }
    chdir("..");
    closedir(dir);
}

void readsqlfile(char *filename){
    FILE *  pFile;
    FILE *  tmp_query;
    char    chline [1024];
    char    query [2048];
    char    tmpfile[] = "/tmp/tmp_query.txt";
    char    settimezone[] = "set timezone to +00;";
    char    command[1024] = "";
    char    shellcommand[1024] = "";
    char    msg[256];

    pFile = fopen (filename , "r");
    if (pFile == NULL){
        writelog ("Error opening sql file\r\n");
        return;
    }

    sprintf(msg, "SQL File: %s\r\n", filename);
    writelog(msg);

    while(fgets(chline, 1024, pFile) != NULL) {

        if (strstr(chline, "Testcase"))
        {
            if (fgets(query, 2048, pFile) != NULL){
                
                if (!connect_to_server())
                    continue;

                tmp_query = fopen(tmpfile, "w");

                if(tmp_query==NULL)
                {
                    writelog("Could not open tmp_query file\n");
                    continue;
                }

                printf(chline);
                chline[strlen(chline) - 1] = '\0';
                fprintf(tmp_query, "%s\n%s\n%s", settimezone, chline, query);

                fclose(tmp_query);

                sprintf(command, "%s/psql --host=%s --port=%s  --dbname=%s -a -f %s >> ../results/%s.txt 2>&1", PGSPIDER_BIN, PGSPIDER_HOST, PGSPIDER_PORT, PGSPIDER_DATABASE, tmpfile, filename);

                sprintf(shellcommand, SHELLSCRIPT, command);
                system(shellcommand);
            }
        }

    }

    fclose (pFile);
    return;
}

bool connect_to_server(){
    char msg[128] = "";
    PGconn  *conn;
    conn = PQsetdbLogin(
                     PGSPIDER_HOST,
                     PGSPIDER_PORT,
                     NULL,
                     NULL,
                     PGSPIDER_DATABASE,
                     NULL,
                     NULL
    );

    int i = 0;
    while (PQstatus(conn) == CONNECTION_BAD) {
        if (i++ == 25)
            break;
        PQfinish(conn);
        usleep(200*1000);
        conn = PQsetdbLogin(
                         PGSPIDER_HOST,
                         PGSPIDER_PORT,
                         NULL,
                         NULL,
                         PGSPIDER_DATABASE,
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

void writelog(char *msg){
    FILE        *logfile;
    time_t      rawtime;
    struct tm * timeinfo;

    time( &rawtime );
    timeinfo = localtime( &rawtime );

    logfile = fopen (PGSPIDER_LOGFILE, "a");
    fprintf(logfile, "%02d-%02d-%02d %02d:%02d:%02d: %s", timeinfo->tm_mday, timeinfo->tm_mon + 1, timeinfo->tm_year + 1900, timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec, msg);
    
    fclose(logfile);
    return;
}