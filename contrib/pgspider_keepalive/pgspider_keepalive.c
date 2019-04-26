/* -------------------------------------------------------------------------
 *
 * pgspider_keepalive.c
 * Copyright (c) 2019, TOSHIBA
 *
 * -------------------------------------------------------------------------
 */
#include "postgres.h"
#include "pgspider_keepalive.h"

/* These are always necessary for a bgworker */

/* these headers are used by this particular worker's code */
#include "commands/defrem.h"
#include "nodes/nodeFuncs.h"
#include "utils/dynahash.h"
#include "utils/memutils.h"
#include "unistd.h"

#ifdef ORACLE
#include <oci.h>
#endif

PG_MODULE_MAGIC;

void		_PG_init(void);
void		worker_spi_main(Datum) pg_attribute_noreturn();

/* flags set by signal handlers */
static volatile sig_atomic_t got_sighup = false;
static volatile sig_atomic_t got_sigterm = false;

/* postgresql.conf value */
static int	max_child_nodes;
static int	checknodes_interval;
static int	timeout_time;
static int	keepalive_time;

static pthread_t *threads;
static int	svrnum;
static int	createnum;
static bool join_flag;
static HTAB *keepshNodeHash;

static void join_childs();
static void InitSharedMemoryKeepalives();
static void create_child_threads();
static void create_child_info();
static shmem_startup_hook_type shmem_startup_prev = NULL;
static int	get_server_list(NODEINFO * *nodeinfo, char ***fdwname);
void		worker_pgspider_keepalive(Datum main_arg);
void		InitSharedMemoryKeepalives();

pthread_mutex_t hash_mutex = PTHREAD_MUTEX_INITIALIZER;

/*
 * Signal handler for SIGTERM
 *		Set a flag to let the main loop to terminate, and set our latch to wake
 *		it up.
 */
static void
pgspider_keepalive_sigterm(SIGNAL_ARGS)
{
	int			save_errno = errno;

	got_sigterm = true;
	SetLatch(MyLatch);

	errno = save_errno;
}

/*
 * Signal handler for SIGHUP
 *		Set a flag to tell the main loop to reread the config file, and set
 *		our latch to wake it up.
 */
static void
pgspider_keepalive_sighup(SIGNAL_ARGS)
{
	int			save_errno = errno;

	got_sighup = true;
	SetLatch(MyLatch);

	errno = save_errno;
}


/*
 * Threads execute this function. ping to child node and update hash table.
 */
static void *
pgspider_check_childnnode(void *arg)
{
	/* initialize */
	bool		latest_isAlive = TRUE;
	bool		current_isAlive = TRUE;
	NODEINFO   *nodeInfo = (NODEINFO *) arg;
	char		cmd[CMDLEN];
	int			ret;
	int			i;
	nodeinfotag key;

	strcpy(key.nodeName, nodeInfo->tag.nodeName);
	strcpy(key.ip, nodeInfo->tag.ip);
	sprintf(cmd, "ping %s -c 1 -t %d > /dev/null 2>&1 ", nodeInfo->tag.ip, timeout_time);

	elog(LOG, "INFO: KeepAlive threads start '%s %s' ", nodeInfo->tag.nodeName, nodeInfo->tag.ip);

	/*
	 * If IP = "", it is nothing ip case(e.g. file_fdw).It doesn't change
	 * alive flag
	 */
	if (strcmp("", nodeInfo->tag.ip) != 0)
	{
		while (1)
		{
			/* Check child nodes using ping */
			ret = system(cmd);
			if (ret != 0)
				current_isAlive = FALSE;
			else
				current_isAlive = TRUE;
			/* Update hash if necessary */
			if (current_isAlive != latest_isAlive)
			{
				NODEINFO   *entry;
				bool		found;

				elog(LOG, "INFO: Node '%s' status is changed: [%d] -> [%d]", key.nodeName, latest_isAlive, current_isAlive);
				pthread_mutex_lock(&hash_mutex);
				entry = hash_search(keepshNodeHash, &key, HASH_REMOVE, &found);
				if (!found)
					elog(LOG, "ERROR: Not find same hash in pgspider_keepalive %s", key.nodeName);
				entry = hash_search(keepshNodeHash, &key, HASH_ENTER, &found);
				entry->isAlive = current_isAlive;
				pthread_mutex_unlock(&hash_mutex);
				nodeInfo->isAlive = current_isAlive;
			}
			latest_isAlive = current_isAlive;
			for (i = 0; i < keepalive_time; i++)
			{
				sleep(1);
				/* Check finishing flag */
				if (join_flag == TRUE)
					return 0;
			}
		}
	}
	else
	{
		/* Nothing IP case */
		while (1)
		{
			if (join_flag == TRUE)
				return 0;
			sleep(1);
		}
	}
}

/*
 * This is initializing for keep alive shared hash in postmaster.
 */
static void
InitKeepaliveShm()
{
	HASHCTL		info;
	long		init_table_size,
				max_table_size;

	max_table_size = hash_estimate_size(max_child_nodes, sizeof(NODEINFO));
	init_table_size = max_table_size / 2;

	/*
	 * Allocate hash table for LOCK structs.  This stores per-locked-object
	 * information.
	 */
	MemSet(&info, 0, sizeof(info));
	info.keysize = sizeof(nodeinfotag);
	info.entrysize = sizeof(NODEINFO);
	info.num_partitions = 4;

	keepshNodeHash = ShmemInitHash("keep alive",
								   init_table_size,
								   max_table_size,
								   &info,
								   HASH_ELEM | HASH_BLOBS | HASH_PARTITION);
}


/*
 * Get server list from information_schema with SPI.
 */
static int
get_server_list(NODEINFO * *nodeinfo, char ***fdwname)
{
	char	   *sql1 = "SELECT foreign_server_name,foreign_data_wrapper_name FROM information_schema.foreign_servers WHERE foreign_data_wrapper_name != 'pgspider_core_fdw'";
	int			ret;
	MemoryContext oldcontext;
	MemoryContext spicontext;

	oldcontext = CurrentMemoryContext;

	SetCurrentStatementStartTimestamp();
	StartTransactionCommand();
	SPI_connect();
	PushActiveSnapshot(GetTransactionSnapshot());
	/* get server info */
	/* We can now execute queries via SPI */
	SetCurrentStatementStartTimestamp();
	ret = SPI_execute(sql1, false, 0);
	if (ret != SPI_OK_SELECT)
		elog(FATAL, "SPI_execute failed: error code %d", ret);
	/* create alive list */
	sleep(1);
	if (SPI_processed > 0)
	{
		int			i;

		spicontext = MemoryContextSwitchTo(oldcontext);
		*fdwname = palloc(SPI_processed * sizeof(char *));
		*nodeinfo = palloc(SPI_processed * sizeof(NODEINFO));
		MemoryContextSwitchTo(spicontext);
		for (i = 0; i < SPI_processed; i++)
		{
			char	   *val1,
					   *val2;

			spicontext = MemoryContextSwitchTo(oldcontext);
			(*fdwname)[i] = (char *) palloc(NAMEDATALEN * sizeof(char));
			MemoryContextSwitchTo(spicontext);
			val1 = SPI_getvalue(SPI_tuptable->vals[i],
								SPI_tuptable->tupdesc,
								1);
			val2 = SPI_getvalue(SPI_tuptable->vals[i],
								SPI_tuptable->tupdesc,
								2);
			if (strlen(val1) > NAMEDATALEN || strlen(val2) > NAMEDATALEN)
			{
				elog(LOG, "srvname is invalid.");
				proc_exit(1);
			}
			strcpy((*nodeinfo)[i].tag.nodeName, val1);
			strcpy((*fdwname)[i], val2);
		}
	}
	return SPI_processed;
}

static void
get_oracle_ip(char *ipstr, char *srvname, char *sql)
{
	char		message[IPV6LEN] = "";
#ifdef ORACLE
	sword		status = OCI_SUCCESS;
	OCIEnv	   *envhp;
	OCIError   *errhp;
	OCISvcCtx  *svchp;
	OCIStmt    *stmtp;
	OCIDefine  *dfnp;
	char		username[NAMEDATALEN];
	char		password[NAMEDATALEN];
	char	   *dbserver = ipstr;
	char	   *stmt = "SELECT SYS_CONTEXT('USERENV','IP_ADDRESS') from dual;";
	char		sql2[1024];
	int			i;

	SPI_finish();
	PopActiveSnapshot();
	CommitTransactionCommand();

	/* get user and password from user mapping */
	sprintf(sql2, "SELECT option_name,option_value FROM (SELECT distinct srvopt.foreign_server_name,srvopt.option_name, srvopt.option_value FROM information_schema.user_mapping_options AS srvopt,information_schema.foreign_tables AS srv WHERE srvopt.foreign_server_name = srv.foreign_server_name) AS foo where foo.foreign_server_name = '%s';", srvname);
	SetCurrentStatementStartTimestamp();

	ret = SPI_execute(sql2, false, 0);
	for (i = 0; i < SPI_processed; i++)
	{
		int			j;
		char	   *val1 = SPI_getvalue(SPI_tuptable->vals[i],
										SPI_tuptable->tupdesc,
										1);
		char	   *val2 = SPI_getvalue(SPI_tuptable->vals[i],
										SPI_tuptable->tupdesc,
										2);

		if (strcmp(val1, "user") == 0)
		{
			strcpy(username, val1);
		}
		else if (val1, "password")
		{
			strcpy(password, val2);
		}
		else
		{
			goto END;
		}
	}
	/* connect and get IP from ORACLE */
	status = OCIEnvCreate(&envhp, OCI_DEFAULT, 0, 0, 0, 0, 0, 0);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCIHandleAlloc(envhp, (dvoid * *) & errhp, OCI_HTYPE_ERROR, 0, 0);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCILogon(envhp, errhp, &svchp, (OraText *) username, strlen(username),
					  (OraText *) password, strlen(password), (OraText *) dbserver, strlen(dbserver));
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCIHandleAlloc(envhp, (dvoid * *) & stmtp, OCI_HTYPE_STMT, 0, 0);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCIStmtPrepare(stmtp, errhp, (OraText *) stmt, strlen(stmt), OCI_NTV_SYNTAX, OCI_DEFAULT);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCIDefineByPos(stmtp, &dfnp, errhp, 1, message, sizeof(message), SQLT_STR, 0, 0, 0, OCI_DEFAULT);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}

	status = OCIStmtExecute(svchp, stmtp, errhp, 1, 0, NULL, NULL, OCI_DEFAULT);
	if (status != OCI_SUCCESS)
	{
		goto END;
	}
	while (status == OCI_SUCCESS)
	{
		status = OCIStmtFetch2(stmtp, errhp, 1, OCI_FETCH_NEXT, 0, OCI_DEFAULT);
	}

	OCIHandleFree(stmtp, OCI_HTYPE_STMT);
	OCILogoff(svchp, errhp);
	OCIHandleFree(errhp, OCI_HTYPE_ERROR);

	/* re execute SQL */
END:
	SPI_finish();
	PopActiveSnapshot();
	CommitTransactionCommand();
	SetCurrentStatementStartTimestamp();
	ret = SPI_execute(sql, false, 0);
#endif
	strcpy(ipstr, message);
}

/*
 * For multicorn style, host information save in table options.
 * If fdw is multicorn, then get server's table options and distinct with IP.
 * so we can reduce.
 * (If tables are NOT same IP, it means user use some of the Server)
 */
static void
load_multicorn_from_table(NODEINFO * *nodeInfo, char *srvName, char *sql)
{
	int			ret;
	int			i;

	/* Firstly, stop another SPI transaction */
	SPI_finish();
	PopActiveSnapshot();
	CommitTransactionCommand();

	SetCurrentStatementStartTimestamp();
	ret = SPI_execute("SELECT distinct option_value FROM (SELECT distinct srvopt.foreign_table_name,srvopt.option_name, srvopt.option_value FROM information_schema.foreign_table_options AS srvopt,information_schema.foreign_tables AS srv WHERE srvopt.foreign_table_name = srv.foreign_table_name AND (srvopt.option_name = 'host' OR srvopt.option_name = 'hosts' OR srvopt.option_name = 'dbserver')) as foo;;", false, 0);
	if (ret != SPI_OK_SELECT)
		elog(LOG, "SPI_execute failed: error code %d", ret);
	for (i = 0; i < SPI_processed; i++)
	{
		char	   *ipstr;

		ipstr = SPI_getvalue(SPI_tuptable->vals[i],
							 SPI_tuptable->tupdesc,
							 1);
		strcpy((*nodeInfo)[i + svrnum].tag.ip, ipstr);
		strcpy((*nodeInfo)[i + svrnum].tag.nodeName, srvName);
	}
	createnum += SPI_processed;

	/* re-execute SQL */
	SPI_finish();
	PopActiveSnapshot();
	CommitTransactionCommand();
	SetCurrentStatementStartTimestamp();
	ret = SPI_execute(sql, false, 0);
}


/*
 * Create server and IP list from information_schema with SPI.
 */
static void
create_alive_list(StringInfoData *buf, NODEINFO * *nodeInfo, char ***fdwname)
{
	int			ret;
	char	   *sql = "SELECT distinct srvopt.foreign_server_name,srvopt.option_name, srvopt.option_value FROM information_schema.foreign_server_options AS srvopt,information_schema.foreign_servers AS srv WHERE srvopt.foreign_server_name = srv.foreign_server_name AND (srvopt.option_name = 'host' OR srvopt.option_name = 'hosts' OR srvopt.option_name = 'dbserver');";

	createnum = 0;

	while (!got_sigterm)
	{
		int			i;

		svrnum = get_server_list(nodeInfo, fdwname);
		/* get foreign server options */
		SetCurrentStatementStartTimestamp();
		ret = SPI_execute(sql, false, 0);
		if (ret != SPI_OK_SELECT)
			elog(LOG, "SPI_execute failed: error code %d", ret);

		/*
		 * The complexity is N, not N*N. Because result and nodeinfo is sorted
		 * by srvname.
		 */
		for (i = 0; i < SPI_processed; i++)
		{
			char	   *srvname;
			char	   *ipstr;
			int			j;

			srvname = SPI_getvalue(SPI_tuptable->vals[i],
								   SPI_tuptable->tupdesc,
								   1);
			ipstr = SPI_getvalue(SPI_tuptable->vals[i],
								 SPI_tuptable->tupdesc,
								 3);
			for (j = 0; j < svrnum; j++)
			{
				if (strcmp(srvname, (*nodeInfo)[j].tag.nodeName) == 0)
				{
					if (strlen(ipstr) > IPV6LEN)
					{
						elog(LOG, "IP is invalid.");
						proc_exit(1);
					}
					if (strcmp((*fdwname)[j], "multicorn") == 0)
					{
						load_multicorn_from_table(nodeInfo, srvname, sql);
					}
					else if (strcmp((*fdwname)[j], "influxdb_fdw") == 0)
					{
						char	   *adr = strstr(ipstr, "//");

						if (adr != NULL)
							adr += 2;
						else
							adr = ipstr;
						strcpy((*nodeInfo)[j].tag.ip, adr);
					}
					else if (strcmp((*fdwname)[j], "oracle_fdw") == 0)
					{
						get_oracle_ip(ipstr, srvname, sql);
						if (ipstr != NULL)
							strcpy((*nodeInfo)[j].tag.ip, ipstr);
						else
							strcpy((*nodeInfo)[j].tag.ip, "");
					}
					else if (strcmp((*fdwname)[j], "griddb_fdw") == 0)
						strcpy((*nodeInfo)[j].tag.ip, "");
					else if (ipstr != NULL)
						strcpy((*nodeInfo)[j].tag.ip, ipstr);
					else
						strcpy((*nodeInfo)[j].tag.ip, "");
					j = svrnum;
				}
			}
		}
		break;
	}
	svrnum += createnum;
	SPI_finish();
	PopActiveSnapshot();
	CommitTransactionCommand();
	return;
}

/*
 * Create hash table on shared memory.
 */
static void
create_child_info(NODEINFO * nodeInfo)
{
	NODEINFO   *entry;
	int			i;
	bool		found;

	nodeInfo->isAlive = TRUE;
	threads = palloc(sizeof(pthread_t) * svrnum);
	for (i = 0; i < svrnum; i++)
	{
		nodeinfotag key = {};

		strcpy(key.nodeName, nodeInfo[i].tag.nodeName);
		strcpy(key.ip, nodeInfo[i].tag.ip);
		entry = hash_search(keepshNodeHash, &key, HASH_ENTER, &found);
		entry->isAlive = TRUE;
		if (found)
			elog(LOG, "ERROR: Find same hash in pgspider_keepalive");
	}
}

/*
 * Create child thread
 */
static void
create_child_threads(NODEINFO * nodeInfo)
{
	int			i;

	elog(LOG, "create_child_threads");
	for (i = 0; i < svrnum; i++)
	{
		pthread_create(&threads[i], NULL, &pgspider_check_childnnode, &nodeInfo[i]);
	}
}

static bool
check_hashtable(DefElem *def, char *servername, bool *ret)
{
	nodeinfotag key = {};
	char	   *optstr = defGetString(def);
	bool		found;
	NODEINFO   *entry;

	if (strcmp(def->defname, "host") == 0 || strcmp(def->defname, "hosts") == 0 || strcmp(def->defname, "srvname") == 0)
	{
		strcpy(key.nodeName, servername);
		strcpy(key.ip, optstr);
		entry = hash_search(keepshNodeHash, &key, HASH_ENTER, &found);
		if (found)
		{
			*ret = entry->isAlive;
			return TRUE;
		}
		else
			return FALSE;
	}
	return FALSE;
}

/*
 * Checking server is exist in hash table.
 * This is called by pgspider_core_fdw.
 */
bool
check_server_ipname(ForeignServer *fs, ForeignTable *ft)
{
	ListCell   *lc;
	HASHCTL		info;
	long		init_table_size,
				max_table_size;

	max_table_size = hash_estimate_size(max_child_nodes, sizeof(NODEINFO));
	init_table_size = max_table_size / 2;

	/*
	 * attach shared memory
	 */
	MemSet(&info, 0, sizeof(info));
	info.keysize = sizeof(nodeinfotag);
	info.entrysize = sizeof(NODEINFO);
	info.num_partitions = 4;
	if (!keepshNodeHash)
	{
		keepshNodeHash = ShmemInitHash("keep alive",
									   init_table_size,
									   max_table_size,
									   &info,
									   HASH_ELEM | HASH_BLOBS | HASH_PARTITION);
	}
	/* check server options */
	foreach(lc, fs->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);
		bool		ret = TRUE;

		if (check_hashtable(def, fs->servername, &ret))
			return ret;
	}
	foreach(lc, ft->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);
		bool		ret = TRUE;

		if (check_hashtable(def, fs->servername, &ret))
			return ret;
	}
	return TRUE;
}

/*
 * Delete shared hash table elem
 */
static void
delete_oldhash(NODEINFO * nodeInfo)
{
	int			i;
	bool		found;

	for (i = 0; i < svrnum; i++)
	{
		nodeinfotag key;

		strcpy(key.nodeName, nodeInfo[i].tag.nodeName);
		strcpy(key.ip, nodeInfo[i].tag.ip);
		hash_search(keepshNodeHash, &key, HASH_REMOVE, &found);
		if (!found)
			elog(LOG, "ERROR: Find same hash in pgspider_keepalive");
	}
}

static void
join_childs()
{
	int			i;

	join_flag = TRUE;
	for (i = 0; i < svrnum; i++)
	{
		pthread_join(threads[i], NULL);
	}
}

/*
 * Get newest server infomation and compare current shared hash.
 * If it is not same, then re-create threads.
 */
static void
check_server_info(NODEINFO * latestNodeInfo, char **latestFdwName)
{
	NODEINFO   *curNodeInfo;
	char	  **curFdwName;
	int			curSvrNum = 0;
	int			i;
	int			rc;

	while (!got_sigterm)
	{
		curSvrNum = get_server_list(&curNodeInfo, &curFdwName);
		for (i = 0; i < curSvrNum; i++)
		{
			if (curSvrNum != svrnum || strcmp(curNodeInfo[i].tag.nodeName, latestNodeInfo[i].tag.nodeName) != 0 ||
				strcmp(curFdwName[i], latestFdwName[i]) != 0)
			{
				/* join child threads */
				join_childs();
				/* delete all hash table data */
				delete_oldhash(latestNodeInfo);

				for (i = 0; i < curSvrNum; i++)
				{
					pfree(curFdwName[i]);
				}
				pfree(curFdwName);
				pfree(curNodeInfo);
				SPI_finish();
				PopActiveSnapshot();
				CommitTransactionCommand();
				return;
			}
		}
		for (i = 0; i < curSvrNum; i++)
		{
			pfree(curFdwName[i]);
		}
		pfree(curFdwName);
		pfree(curNodeInfo);
		SPI_finish();
		PopActiveSnapshot();
		CommitTransactionCommand();
		rc = WaitLatch(MyLatch,
					   WL_LATCH_SET | WL_TIMEOUT | WL_POSTMASTER_DEATH,
					   keepalive_time * 1000L,
					   PG_WAIT_EXTENSION);
		if (!rc)
			proc_exit(1);
		ResetLatch(MyLatch);
	}
}

/*
 * This is keep alive main thread.
 */
void
worker_pgspider_keepalive(Datum main_arg)
{
	int			i;
	StringInfoData buf;
	NODEINFO   *nodeInfo;
	char	  **fdwName;

	/* Establish signal handlers before unblocking signals. */
	pqsignal(SIGHUP, pgspider_keepalive_sighup);
	pqsignal(SIGTERM, pgspider_keepalive_sigterm);

	/* We're now ready to receive signals */
	BackgroundWorkerUnblockSignals();

	/* Connect to our database */
	BackgroundWorkerInitializeConnection("postgres", NULL);

	pthread_mutex_init(&hash_mutex, NULL);

	/*
	 * Main loop: do this until the SIGTERM handler tells us to terminate
	 */
	while (!got_sigterm)
	{
		join_flag = FALSE;

		CHECK_FOR_INTERRUPTS();

		/*
		 * In case of a SIGHUP, just reload the configuration.
		 */
		if (got_sighup)
		{
			got_sighup = false;
			ProcessConfigFile(PGC_SIGHUP);
		}
		SetCurrentStatementStartTimestamp();

		/* Create child nodeinfo */
		create_alive_list(&buf, &nodeInfo, &fdwName);

		/* Create hash table in shared memory */
		create_child_info(nodeInfo);

		/* Create child threads */
		create_child_threads(nodeInfo);

		/*
		 * check server info. If server information is changed, then return
		 * this routine
		 */
		check_server_info(nodeInfo, fdwName);

		/* initialize */
		for (i = 0; i < svrnum; i++)
		{
			pfree(fdwName[i]);
		}
		pfree(fdwName);
		pfree(nodeInfo);
		pfree(threads);
	}
	proc_exit(1);
}

static void
InitSharedMemoryKeepalives()
{
	Size		size = hash_estimate_size(max_child_nodes, sizeof(NODEINFO) + 10000);

	RequestAddinShmemSpace(size);
}


/*
 * Entrypoint of this module.
 *
 * We register more than one worker process here, to demonstrate how that can
 * be done.
 */
void
_PG_init(void)
{
	BackgroundWorker worker;

	if (!process_shared_preload_libraries_in_progress)
		return;

	/* get the configuration */
	DefineCustomIntVariable("pgspider_keepalive.timeout_time",
							"polling time to child node ",
							NULL,
							&timeout_time,
							10,
							1,
							INT_MAX,
							PGC_POSTMASTER,
							0,
							NULL,
							NULL,
							NULL);

	DefineCustomIntVariable("pgspider_keepalive.keepalive_interval",
							"keep alive interval.",
							NULL,
							&keepalive_time,
							10,
							1,
							INT_MAX,
							PGC_POSTMASTER,
							0,
							NULL,
							NULL,
							NULL);
	DefineCustomIntVariable("pgspider_keepalive.checknodes_interval",
							"Number of workers.",
							NULL,
							&checknodes_interval,
							10,
							1,
							INT_MAX,
							PGC_POSTMASTER,
							0,
							NULL,
							NULL,
							NULL);
	DefineCustomIntVariable("pg_promoter.max_child_nodes",
							"Connection information for primary server",
							NULL,
							&max_child_nodes,
							1024,
							1,
							INT_MAX,
							PGC_POSTMASTER,
							0,
							NULL,
							NULL,
							NULL);
	/* Alloc shared memory */
	InitSharedMemoryKeepalives();
	/* set up common data for all our workers */
	memset(&worker, 0, sizeof(worker));
	worker.bgw_flags = BGWORKER_SHMEM_ACCESS |
		BGWORKER_BACKEND_DATABASE_CONNECTION;
	worker.bgw_start_time = BgWorkerStart_ConsistentState;
	worker.bgw_restart_time = BGW_NEVER_RESTART;
	sprintf(worker.bgw_name, "pgspider_keepalive");
	sprintf(worker.bgw_library_name, "pgspider_keepalive");
	sprintf(worker.bgw_function_name, "worker_pgspider_keepalive");
	worker.bgw_notify_pid = 0;

	/*
	 * Now fill in worker-specific data, and do the actual registrations.
	 */
	shmem_startup_prev = shmem_startup_hook;
	shmem_startup_hook = InitKeepaliveShm;

	RegisterBackgroundWorker(&worker);
}
