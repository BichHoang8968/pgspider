#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include "config.h"
#include "install_util.h"
#include "error_codes.h"

/*
 * Display the usage of this program.
 *
 * @param[in] cmd_name - Program name. argv[0] should be given.
 */
void
printUsage(char *cmd_name)
{
	printf("Usage: %s [Options]\n", cmd_name);
	printf("  -d DIR\tDirectory path having config files.\n");
	printf("        \tIf not specified, refer the environment variable SPD_SETUP_CONF_DIR.\n");
	printf("        \tThe default is a current directory.\n\n");
	printf("  -i FILE\tFile name of node information.\n");
	printf("         \tIf not specified, refer the environment variable SPD_SETUP_NODE_INFO.\n");
	printf("         \tThe default is '%s'.\n\n", DEFAULT_INFOFILENAME);
	printf("  -s FILE\tFile name of node structure.\n");
	printf("         \tIf not specified, refer the environment variable SPD_SETUP_NODE_STRUCT.\n");
	printf("         \tThe default is '%s'.\n\n", DEFAULT_STRFILENAME);
	printf("  -t NUM\tTimeout time in seconds to wait PGSpider wake-up.\n");
	printf("        \tnegative value is unlimit, 0 is give-up immediately.\n");
	printf("        \tThe default is 0.\n");
}

/*
 * Read environment variables and memorize those values as a configuration
 * parameter.
 *
 * @param[out] params - Configuration parameters.
 */
void
analyze_env(config_params * params)
{
	char	   *time;

	params->config_dir = getenv("SPD_SETUP_CONF_DIR");
	params->node_info_file = getenv("SPD_SETUP_NODE_INFO");
	params->node_struct_file = getenv("SPD_SETUP_NODE_STRUCT");
	time = getenv("SPD_SETUP_TIMEOUT");
	if (time)
	{
		params->timeout = atoi(time);
	}
}

/*
 * Read arguments of the program and memorize those values as a configuration
 * parameter.
 *
 * @param[out] params - Configuration parameters.
 */
ReturnCode
analyze_arguments(int argc, char *argv[], config_params * params)
{
	int			opt;

	while ((opt = getopt(argc, argv, "d:hi:s:t:")) != -1)
	{
		switch (opt)
		{
			case 'd':
				params->config_dir = optarg;
				break;
			case 'i':
				params->node_info_file = optarg;
				break;
			case 's':
				params->node_struct_file = optarg;
				break;
			case 't':
				params->timeout = atoi(optarg);
				break;
			case 'h':
				printUsage(argv[0]);
				exit(0);
			default:
				PRINT_ERROR("Error : Invalid argument '%c'\n", opt);
				return SETUP_INVALID_PARAM;
		}
	}

	return SETUP_OK;
}

/*
 * Display configuration parameters.
 *
 * @param[in] params - Configuration parameters.
 */
void
printConfig(config_params params)
{
	printf("Config directory: %s\n", params.config_dir);
	printf("Node information file: %s\n", params.node_info_file);
	printf("Node structure file: %s\n", params.node_struct_file);
	printf("Timeout: %d\n", params.timeout);
}

/*
 * Check iwhether configuration parameters are valid or not.
 * File path will be checked when reading it.
 *
 * @param[in] params - Configuration parameters.
 */
ReturnCode
checkConfig(config_params * params)
{
	/* Set default values if parameters are not specified. */
	if (!params->config_dir || params->config_dir[0] == '\0')
	{
		params->config_dir = "./";
	}
	if (!params->node_info_file || params->node_info_file[0] == '\0')
	{
		params->node_info_file = DEFAULT_INFOFILENAME;
	}
	if (!params->node_struct_file || params->node_struct_file[0] == '\0')
	{
		params->node_struct_file = DEFAULT_STRFILENAME;
	}

	if (params->timeout < 0)
	{
		PRINT_ERROR("Error: Invalid value of timeout time: %d.\n", params->timeout);
		PRINT_ERROR("Please confirm values of argument 't' and the environment variable 'SPD_SETUP_TIMEOUT'.\n");
		return SETUP_INVALID_PARAM;
	}

	return SETUP_OK;
}

/*
 * Generate a file path by concatinating a directory path and a file name.
 *
 */
void
getFilePath(const char *dir, const char *file, char path[PATH_MAX])
{
	if (dir[strlen(dir) - 1] != '/')
	{
		sprintf(path, "%s/%s", dir, file);
	}
	else
	{
		sprintf(path, "%s%s", dir, file);
	}
}
