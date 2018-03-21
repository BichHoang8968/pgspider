/*-------------------------------------------------------------------------
 *
 * connection.c
 * 		Foreign-data wrapper for remote Tinybrace servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 		connection.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "tinybrace_fdw.h"

#include "access/xact.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "utils/hsearch.h"
#include "utils/memutils.h"
#include "utils/resowner.h"

/* Length of host */
#define HOST_LEN 256

/*
 * Connection cache hash table entry
 *
 * The lookup key in this hash table is the foreign server OID plus the user
 * mapping OID.  (We use just one connection per user per foreign server,
 * so that we can ensure all scans use the same snapshot during a query.)
 */
typedef struct ConnCacheKey
{
	Oid			serverid;		/* OID of foreign server */
	Oid			userid;			/* OID of local user whose mapping we use */
	Oid         threadid;
} ConnCacheKey;

typedef struct ConnCacheEntry
{
	ConnCacheKey key;       /* hash key (must be first) */
	TBC_CLIENT_HANDLE *conn;            /* connection to foreign server, or NULL */
	int			xact_depth;		/* 0 = no xact open, 1 = main xact open, 2 =
								 * one level of subxact open, etc */
	bool		invalidated;	/* true if reconnect is pending */
	uint32		server_hashvalue;	/* hash value of foreign server OID */
	uint32		mapping_hashvalue;	/* hash value of user mapping OID */
} ConnCacheEntry;

/*
 * Connection cache (initialized on first use)
 */
static HTAB *ConnectionHash = NULL;
/* tracks whether any work is needed in callback functions */
static bool xact_got_connection = false;


static void
begin_remote_xact(ConnCacheEntry *entry);

static void
tinybracefdw_xact_callback(XactEvent event, void *arg);

/*
 * tinybrace_get_connection:
 * 			Get a connection which can be used to execute queries on
 * the remote Tinybrace server with the user's authorization. A new connection
 * is established if we don't already have a suitable one.
 */
TBC_CLIENT_HANDLE*
tinybrace_get_connection(ForeignServer *server, UserMapping *user, tinybrace_opt *opt)
{
	bool found;
	ConnCacheEntry *entry;
	ConnCacheKey key;
	TBC_RTNCODE rtn;
	/* First time through, initialize connection cache hashtable */

	if (ConnectionHash == NULL)
	{
		HASHCTL	ctl;
		MemSet(&ctl, 0, sizeof(ctl));
		ctl.keysize = sizeof(ConnCacheKey);
		ctl.entrysize = sizeof(ConnCacheEntry);
		ctl.hash = tag_hash;

		/* allocate ConnectionHash in the cache context */
		ctl.hcxt = CacheMemoryContext;
		ConnectionHash = hash_create("tinybrace_fdw connections", 8,
									&ctl,
									HASH_ELEM | HASH_FUNCTION | HASH_CONTEXT);
		RegisterXactCallback(tinybracefdw_xact_callback, NULL);
	}

	/* Set flag that we did GetConnection during the current transaction */
	xact_got_connection = true;

	/* Create hash key for the entry.  Assume no pad bytes in key struct */
	key.serverid = server->serverid;
	key.userid = user->userid;
	key.threadid = pthread_self();

	/*
	 * Find or create cached entry for requested connection.
	 */
	entry = hash_search(ConnectionHash, &key, HASH_ENTER, &found);
	if (!found)
	{
		/* initialize new hashtable entry (key is already filled in) */
		entry->conn = NULL;
	}
	if(entry->conn == NULL){
	    entry->conn = (TBC_CLIENT_HANDLE *)
			MemoryContextAlloc(
				TopMemoryContext,
				sizeof(TBC_CLIENT_HANDLE));
		rtn = TBC_init((TBC_CLIENT_HANDLE*)entry->conn);
		if(rtn != TBC_OK){
			ereport(ERROR,
					(errcode(ERRCODE_FDW_OUT_OF_MEMORY),
					 errmsg("TBC init failed %d\n",rtn)
						));
		}
		rtn = TBC_connect(opt->svr_address,opt->svr_port,opt->svr_username,opt->svr_password, (TBC_CLIENT_HANDLE*)entry->conn);
		fprintf(stderr,"add = %s, port = %d, user=%s pass=%s",opt->svr_address,opt->svr_port,opt->svr_username,opt->svr_password);
		if(rtn != TBC_OK){
			ereport(ERROR,
					(errcode(ERRCODE_FDW_OUT_OF_MEMORY),
					 errmsg("TBC connect failed %d\n",rtn)
						));
		}
		rtn = TBC_select_db(entry->conn->connect, opt->svr_database);
		if (rtn != TBC_OK) {
			ereport(ERROR,
					(errcode(ERRCODE_FDW_OUT_OF_MEMORY),
					 errmsg("TBC select database failed %d\n",rtn)
						));
		}
		fprintf(stderr,"success to connect \n");
	}

	begin_remote_xact(entry);

	return entry->conn;
}

/*
 * cleanup_connection:
 * Delete all the cache entries on backend exists.
 */
void
tinybrace_cleanup_connection(void)
{
	HASH_SEQ_STATUS	scan;
	ConnCacheEntry *entry;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		if (entry->conn == NULL)
			continue;
		fprintf(stderr,"clean connection\n");
		TBC_close(entry->conn->connect);
		TBC_clean(entry->conn);
		entry->conn = NULL;
	}
}

/*
 * Release connection created by calling GetConnection.
 */
void
tinybrace_rel_connection(TBC_CLIENT_HANDLE *conn)
{
	HASH_SEQ_STATUS	scan;
	ConnCacheEntry *entry;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		if (entry->conn == NULL)
			continue;

		if (entry->conn == conn)
		{
			elog(DEBUG1, "disconnecting tinybrace_fdw connection %p", entry->conn);
			TBC_close(entry->conn->connect);
			TBC_clean(entry->conn);
			entry->conn = NULL;
			fprintf(stderr,"cloase connection\n");
			hash_seq_term(&scan);
			break;
		}
	}
}

/*
 * Convenience subroutine to issue a non-data-returning SQL command to remote
 */
static void
do_sql_command(TBC_CLIENT_HANDLE *conn, const char *sql)
{
	TBC_QUERY_HANDLE qHdl = 0;
	TBC_RTNCODE rtn;

	rtn = TBC_query(conn->connect,sql,&qHdl);
	if (rtn != TBC_OK){
		elog(WARNING,"TinyBrace failed to execute %s: rtn = %d",sql,rtn);
		return false;
	}
	return true;
}

/*
 * Start remote transaction or subtransaction, if needed.
 *
 * Note that we always use at least REPEATABLE READ in the remote session.
 * This is so that, if a query initiates multiple scans of the same or
 * different foreign tables, we will get snapshot-consistent results from
 * those scans.  A disadvantage is that we can't provide sane emulation of
 * READ COMMITTED behavior --- it would be nice if we had some other way to
 * control which remote queries share a snapshot.
 */
static void
begin_remote_xact(ConnCacheEntry *entry)
{
	int			curlevel = GetCurrentTransactionNestLevel();
	/* Start main transaction if we haven't yet */
	if (entry->xact_depth <= 0)
	{
		const char *sql;

		elog(DEBUG1, "starting remote transaction on connection %p",
			 entry->conn);

		sql = "BEGIN";
		do_sql_command(entry->conn, sql);
		entry->xact_depth = 1;
	}
}

/*
 * pgfdw_xact_callback --- cleanup at main-transaction end.
 */
static void
tinybracefdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	int autocommit;
	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	/*
	 * Scan all connection cache entries to find open remote transactions, and
	 * close them.
	 */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore cache entry if no open connection right now */
		if (entry->conn == NULL)
			continue;

		/* If it has an open remote transaction, try to close it */
		if (entry->xact_depth > 0)
		{
			bool		abort_cleanup_failure = false;

			elog(DEBUG1, "closing remote transaction on connection %p",
				 entry->conn);

			switch (event)
			{
				case XACT_EVENT_PARALLEL_PRE_COMMIT:
				case XACT_EVENT_PRE_COMMIT:
					do_sql_command(entry->conn, "COMMIT TRANSACTION");
					break;
				case XACT_EVENT_PRE_PREPARE:
					/*
					 * We disallow remote transactions that modified anything,
					 * since it's not very reasonable to hold them open until
					 * the prepared transaction is committed.  For the moment,
					 * throw error unconditionally; later we might allow
					 * read-only cases.  Note that the error will cause us to
					 * come right back here with event == XACT_EVENT_ABORT, so
					 * we'll clean up the connection state at that point.
					 */
					ereport(ERROR,
							(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
							 errmsg("cannot prepare a transaction that modified remote tables")));
					break;
				case XACT_EVENT_PARALLEL_COMMIT:
				case XACT_EVENT_COMMIT:
				case XACT_EVENT_PREPARE:
					/* Pre-commit should have closed the open transaction */
					elog(ERROR, "missed cleaning up connection during pre-commit");
					break;
				case XACT_EVENT_PARALLEL_ABORT:
				case XACT_EVENT_ABORT:
					/* Assume we might have lost track of prepared statements */
					//entry->have_error = true;
					TBC_get_autocommit(entry->conn->connect, &autocommit);
					if (!autocommit)
						do_sql_command(entry->conn, "ROLLBACK");

					break;
			}
		}

		/* Reset state to show we're out of a transaction */
		entry->xact_depth = 0;
	}

	/*
	 * Regardless of the event type, we can now mark ourselves as out of the
	 * transaction.  (Note: if we are here during PRE_COMMIT or PRE_PREPARE,
	 * this saves a useless scan of the hashtable during COMMIT or PREPARE.)
	 */
	xact_got_connection = false;

	/* Also reset cursor numbering for next transaction */
	//cursor_number = 0;
}
