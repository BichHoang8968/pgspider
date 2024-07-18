#ifndef CONFIG_H
#define CONFIG_H

#include <limits.h>
#include "error_codes.h"
#ifdef _MSC_VER
#include <Windows.h>
#define PATH_MAX MAX_PATH
#endif

#define DEFAULT_STRFILENAME "node_structure.json"
#define DEFAULT_INFOFILENAME "node_information.json"
#define DEFAULT_SCHEMA "public"
#define TEMP_SCHEMA "temp_schema"
#define DEFAULT_ON_CONFLICT_NONE "none"
#define DEFAULT_ON_CONFLICT_RECREATE "recreate"

typedef struct config_params 
{
	
	char *config_dir;
	
	char *node_info_file;
	
	char *node_struct_file;
	
	int timeout;

	char *schema;

	char *on_conflict;
	
}			config_params;



void printUsage(char *cmd_name);

void analyze_env(config_params * params);

ReturnCode analyze_arguments(int argc, char *argv[], config_params * params);

void printConfig(config_params params);

ReturnCode checkConfig(config_params * params);

void getFilePath(const char *dir, const char *file, char path[PATH_MAX]);

#endif /* CONFIG_H */
