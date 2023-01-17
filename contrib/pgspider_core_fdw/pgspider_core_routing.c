/*-------------------------------------------------------------------------
 *
 * pgspider_core_routing.c
 *		  Management of insert target node
 *
 * Portions Copyright (c) 2022, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/pgspider_core_fdw/pgspider_core_routing.c
 *
 *-------------------------------------------------------------------------
 */
#ifndef OMIT_INSERT_ROUNDROBIN

#include <stddef.h>
#include "postgres.h"
#include "access/table.h"
#include "c.h"
#include "foreign/fdwapi.h"
#include "fmgr.h"
#include "lib/dshash.h"
#include "nodes/parsenodes.h"
#include "nodes/pg_list.h"
#include "pg_config_manual.h"
#include "pgspider_core_fdw.h"
#include "postgres_ext.h"
#include "utils/datum.h"
#include "utils/dsa.h"
#include "utils/elog.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/rel.h"
#include "utils/relcache.h"
#ifndef WITHOUT_KEEPALIVE
#include "pgspider_keepalive/pgspider_keepalive.h"
#endif
#include "pgspider_core_routing.h"

/* Structure for data stored in dsa. */
typedef struct SpdInststShared
{
	dshash_table_handle hash_handle;
	int			tranche_id;
}			SpdInststShared;

/* Structure for data stored in global variable. */
typedef struct SpdInststGlb
{
	SpdInststShared *shared;
	dsa_area   *area;
	dshash_table *hash;
}			SpdInststGlb;

typedef struct SpdInstgtElem
{
	Oid			parent;			/* Parent table oid: hash key (must be first) */
	Oid			child;			/* Child table oid */
	char		tablename[NAMEDATALEN]; /* Child table name */
}			SpdInstgtElem;

extern bool throwCandidateError;
static SpdInststGlb spd_instst_glb;

#define g_spd_instst_shared		(spd_instst_glb.shared)
#define g_spd_instst_area		(spd_instst_glb.area)
#define g_spd_instst_hash		(spd_instst_glb.hash)

static void
handle_datasource_error(MemoryContext ccxt, char *relname)
{
	int			elevel;
	MemoryContext ecxt = MemoryContextSwitchTo(ccxt);
	ErrorData  *errdata = CopyErrorData();
	char	   *message;

	/* Get an error message occurred in datasource FDW. */
	message = pstrdup(errdata->message);
	FreeErrorData(errdata);
	FlushErrorState();

	if (throwCandidateError)
	{
		elevel = ERROR;
		MemoryContextSwitchTo(ecxt);
	}
	else
		elevel = WARNING;

	ereport(elevel,
			(errcode(ERRCODE_FDW_ERROR),
			errmsg("could not know whether a child \"%s\"is updatable or not.",
					relname),
			errdetail_internal("%s", message)));
}

/**
 * check_candidate_count
 * 		Check the number of candidates is greater than 0.
 */
static void
check_candidate_count(ChildInfo * pChildInfo, int node_num)
{
	int			i;
	int			num_targets = 0;

	for (i = 0; i < node_num; i++)
	{
		if (pChildInfo[i].child_node_status == ServerStatusAlive)
			num_targets++;
	}
	if (num_targets == 0)
		ereport(ERROR, (errmsg("There is no candidate for insert.")));
}

/**
 * spd_inscand_updatable
 *
 */
static void
spd_inscand_updatable(ChildInfo * pChildInfo, int node_num)
{
	int			i;
	MemoryContext ccxt = CurrentMemoryContext;

	for (i = 0; i < node_num; i++)
	{
		int			updatable;
		ChildInfo  *pChild = &pChildInfo[i];
		Relation	rel = RelationIdGetRelation(pChild->oid);

		PG_TRY();
		{
			Oid			server_oid = spd_serverid_of_relation(pChild->oid);
			FdwRoutine *fdwroutine = GetFdwRoutineByServerId(server_oid);

			if (fdwroutine->IsForeignRelUpdatable)
				updatable = fdwroutine->IsForeignRelUpdatable(rel);
			else
				updatable = (1 << CMD_INSERT);
		}
		PG_CATCH();
		{
			char   *relname = RelationGetRelationName(rel);
			handle_datasource_error(ccxt, relname);
			pChild->child_node_status = ServerStatusNotTarget;
		}
		PG_END_TRY();

		RelationClose(rel);

		if ((updatable & (1 << CMD_INSERT)) == 0)
			pChild->child_node_status = ServerStatusNotTarget;
	}

	/* Check the number of candidates. */
	check_candidate_count(pChildInfo, node_num);
}

/**
 *
 */
static void
spd_inscand_alive(ChildInfo * pChildInfo, int node_num)
{
	int			i;
	MemoryContext ccxt = CurrentMemoryContext;

	for (i = 0; i < node_num; i++)
	{
		char		ip[NAMEDATALEN] = {0};
		Oid			server_oid;
		ForeignServer *fs;

		server_oid = spd_serverid_of_relation(pChildInfo[i].oid);
		fs = GetForeignServer(server_oid);

		spd_ip_from_server_name(fs->servername, ip);
#ifndef WITHOUT_KEEPALIVE
		if (check_server_ipname(fs->servername, ip))
		{
#endif

#ifndef WITHOUT_KEEPALIVE
		}
		else
		{
			Relation	rel = RelationIdGetRelation(pChildInfo[i].oid);
			char   *relname = RelationGetRelationName(rel);

			handle_datasource_error(ccxt, relname);
			pChildInfo[i].child_node_status = ServerStatusDead;
			RelationClose(rel);
		}
#endif
	}

	/* Check the number of candidates. */
}

/**
 * spd_inscand_get
 * 		Get a candidates of insert target on prepare phase.
 */
void
spd_inscand_get(ChildInfo * pChildInfo, int node_num)
{

	check_candidate_count(pChildInfo, node_num);

	spd_inscand_updatable(pChildInfo, node_num);

	spd_inscand_alive(pChildInfo, node_num);
}

/**
 * spd_get_spdurl_in_slot
 * 		Get SPDURL column value as string in slot.
 */
static char *
spd_get_spdurl_in_slot(TupleTableSlot *slot, TupleDesc tupdesc)
{
	int			attnum;			/* Attrnum of SPDURL column */
	Form_pg_attribute attr;
	Datum		value;
	bool		isnull;
	Oid			typefnoid;
	bool		isvarlena;
	FmgrInfo	flinfo;
	char	   *spdurl;

	/* Get SPDURL column value as Datum. */
	attnum = tupdesc->natts;
	attr = TupleDescAttr(tupdesc, attnum - 1);
	value = slot_getattr(slot, attnum, &isnull);

	/* Do nothing if SPDURL is NULL. */
	if (isnull)
		return NULL;

	/* Get SPDURL column value as string. */
	getTypeOutputInfo(attr->atttypid, &typefnoid, &isvarlena);
	fmgr_info(typefnoid, &flinfo);
	spdurl = OutputFunctionCall(&flinfo, value);

	return spdurl;
}

/**
 * spd_get_server_from_slot
 * 		Get a server name of SPDURL in slot.
 */
static const char *
spd_get_server_from_slot(TupleTableSlot *slot, TupleDesc tupdesc)
{
	char	   *spdurl;
	List	   *url_list;
	List	   *url_parse_list;
	const char *spdurl_server;

	/* Get SPDURL value. */
	spdurl = spd_get_spdurl_in_slot(slot, tupdesc);

	/* Do nothing if SPDURL is not specified. */
	if (spdurl == NULL)
		return NULL;

	/* Get a server name in SPDURL. */
	url_list = spd_ParseUrl(list_make1(spdurl));
	url_parse_list = (List *) list_nth(url_list, 0);
	spdurl_server = (char *) list_nth(url_parse_list, 0);

	return spdurl_server;
}

/**
 * spd_inscand_spdurl
 * 		Remove un-related tables from candidates based on SPDURL
 * 		column value.
 *
 * 		child_node_status will be set to ServerStatusNotTarget from ServerStatusAlive if un-related table.
 */
void
spd_inscand_spdurl(TupleTableSlot *slot, Relation rel, ChildInfo * pChildInfo, int node_num)
{
	TupleDesc	tupdesc;
	const char *spdurl_server;
	int			i;

	/* Get a server name. */
	tupdesc = RelationGetDescr(rel);
	spdurl_server = spd_get_server_from_slot(slot, tupdesc);

	/* Do nothing if server name is not specified. */
	if (spdurl_server == NULL)
		return;

	for (i = 0; i < node_num; i++)
	{
		char		srvname[NAMEDATALEN];
		ChildInfo  *pChild = &pChildInfo[i];

		if (pChild->child_node_status != ServerStatusAlive)
			continue;

		spd_servername_from_tableoid(pChild->oid, srvname);
		if (strcmp(spdurl_server, srvname) != 0)
			pChild->child_node_status = ServerStatusNotTarget;
	}

	/* Check the number of candidates. */
	check_candidate_count(pChildInfo, node_num);
}

/**
 * spd_instgt_last_table
 * 		Find the last insert target. If it is found, the 2nd argument will
 * 		be set to true. Even if the table has been renamed, the 2nd argument
 * 		will be set to false.
 * 		This function returns a hasn entry for the target.
 * 		Write lock for shared hash will be acquired.
 */
static SpdInstgtElem *
spd_instgt_last_table(Oid parent, bool *found)
{
	SpdInstgtElem *entry;
	char	   *relname;

	entry = dshash_find_or_insert(g_spd_instst_hash, &parent, found);

	if (!(*found))
		return entry;

	/* Get the current table name of child table. */
	relname = get_rel_name(entry->child);

	/* Check whether child table was renamed. */
	if (!relname || strcmp(relname, entry->tablename) != 0)
	{
		*found = false;
		return entry;
	}

	return entry;
}

/**
 * spd_instgt_choose
 * 		Choose one child table from candidate for insert.
 */
static int
spd_instgt_choose(char *prev_name, ModifyThreadInfo *mtThrdInfo,
				  ChildInfo * pChildInfo, int node_num)
{
	int			i;

	/*
	 * If the previous inserted table is memorized, search the position in
	 * candidates and choose the next one.
	 */
	if (prev_name != NULL)
	{
		for (i = 0; i < node_num; i++)
		{
			int			idx = mtThrdInfo[i].childInfoIndex;
			char	   *relname = get_rel_name(pChildInfo[idx].oid);
			int			cmp = strcmp(prev_name, relname);

			if (cmp >= 0)
				continue;

			if (pChildInfo[idx].child_node_status == ServerStatusAlive)
				return i;
		}

		/*
		 * Here, the previous table name is larget in candidates. So the first
		 * child table in candidate will be choosen.
		 */
	}

	/* Find the first child table in candidates. */
	for (i = 0; i < node_num; i++)
	{
		int			idx = mtThrdInfo[i].childInfoIndex;
		if (pChildInfo[idx].child_node_status == ServerStatusAlive)
			return i;
	}

	/* Should not reach here. */
	ereport(ERROR, (errmsg("Cannot find an insert target.")));
}

/**
 * spd_instst_get_target
 * 		Choose one child table from candidate for insert
 * 		and memorize it in shared memory.
 * 		This function returns an index of target in ModifyThreadInfo array.
 */
int
spd_instst_get_target(Oid parent, ModifyThreadInfo *mtThrdInfo,
					  ChildInfo * pChildInfo, int node_num)
{
	SpdInstgtElem *entry;
	bool		found;
	char	   *prev_name;
	int			i;
	int			idx;
	char	   *relname;

	/* Find the last target and get a lock for the shared hash. */
	entry = spd_instgt_last_table(parent, &found);

	/* Choose the insert target. */
	if (found)
		prev_name = entry->tablename;
	else
		prev_name = NULL;

	i = spd_instgt_choose(prev_name, mtThrdInfo, pChildInfo, node_num);

	/* Update target information in shared memory. */
	idx = mtThrdInfo[i].childInfoIndex;
	relname = get_rel_name(pChildInfo[idx].oid);
	entry->child = pChildInfo[idx].oid;
	strcpy(entry->tablename, relname);

	/* Release the lock. */
	dshash_release_lock(g_spd_instst_hash, entry);

	return i;
}

static dshash_parameters
spd_instgt_dshash_params(int tranche_id)
{
	dshash_parameters params = {
		sizeof(Oid),
		sizeof(SpdInstgtElem),
		dshash_memcmp,
		dshash_memhash,
		tranche_id
	};

	return params;
}

/**
 * spd_instgt_init_dsa
 * 		Create a dynamic shared memory area and a shared data in it.
 *		The location for the shared data is stored in the first argument.
 *		One of the shared data is a hash table which manages an insert target.
 */
static void
spd_instgt_init_dsa(SpdInstgtLocation * location)
{
	dsa_area   *area;
	dsa_pointer dp;
	SpdInststShared *its;
	int			tranche_id;
	dshash_parameters hash_params;
	MemoryContext oldMemoryContext;

	/*
	 * Use the top memory context to keep global variables during a worker
	 * process alive.
	 */
	oldMemoryContext = MemoryContextSwitchTo(TopMemoryContext);

	/*
	 * Create a duynamic shared memory area. This area is kept even if backend
	 * is detached or query is finished.
	 */
	area = dsa_create(LWLockNewTrancheId());
	dsa_pin(area);
	dsa_pin_mapping(area);

	/* Set the global variable. */
	g_spd_instst_area = area;

	/* Create the hash table. */
	tranche_id = LWLockNewTrancheId();
	hash_params = spd_instgt_dshash_params(tranche_id);
	g_spd_instst_hash = dshash_create(area, &hash_params, NULL);

	MemoryContextSwitchTo(oldMemoryContext);

	/* Create and set shared variables. */
	dp = dsa_allocate0(area, sizeof(SpdInststShared));
	its = (SpdInststShared *) dsa_get_address(area, dp);
	its->hash_handle = dshash_get_hash_table_handle(g_spd_instst_hash);
	its->tranche_id = tranche_id;

	/* Register the location of shared variables in shared memory. */
	location->handle = dsa_get_handle(area);
	location->pointer = dp;
}

/**
 * spd_instgt_init_shm
 *		Initialize a shared memory for insert target. The shared memory stores
 *		a location for a dynamic shared memory for insert target.
 *
 *		Node:
 *			RequestAddinShmemSpace(sizeof(SpdInstgtLocation)); should be
 *			called in CreateSharedMemoryAndSemaphores() during server
 *			initialization.
 */
void
spd_instgt_init_shm(void)
{
	SpdInstgtLocation *location;
	bool		found;

	/* Get a lock for use of shared memory. */
	LWLockAcquire(AddinShmemInitLock, LW_EXCLUSIVE);

	location = (SpdInstgtLocation *) ShmemInitStruct("location of insert target",
													 sizeof(SpdInstgtLocation),
													 &found);

	if (!found)
	{
		/* Initialize the variable in dynamic shared memory. */
		spd_instgt_init_dsa(location);

		/* Set the global variable. */
		g_spd_instst_shared = (SpdInststShared *) dsa_get_address(g_spd_instst_area, location->pointer);
	}
	else
	{
		dshash_parameters hash_params;
		MemoryContext oldMemoryContext;

		oldMemoryContext = MemoryContextSwitchTo(TopMemoryContext);

		/* Set global variables. */
		g_spd_instst_area = dsa_attach(location->handle);
		dsa_pin_mapping(g_spd_instst_area);

		g_spd_instst_shared = (SpdInststShared *) dsa_get_address(g_spd_instst_area, location->pointer);
		hash_params = spd_instgt_dshash_params(g_spd_instst_shared->tranche_id);

		g_spd_instst_hash = dshash_attach(g_spd_instst_area, &hash_params, g_spd_instst_shared->hash_handle, NULL);

		MemoryContextSwitchTo(oldMemoryContext);
	}

	LWLockRelease(AddinShmemInitLock);
}

#endif							/* OMIT_INSERT_ROUNDROBIN */
