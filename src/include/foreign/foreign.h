/*-------------------------------------------------------------------------
 *
 * foreign.h
 *	  support for foreign-data wrappers, servers and user mappings.
 *
 *
 * Portions Copyright (c) 1996-2017, PostgreSQL Global Development Group
 *
 * src/include/foreign/foreign.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef FOREIGN_H
#define FOREIGN_H

#include "nodes/parsenodes.h"
#include "lib/stringinfo.h"
#include "utils/resowner.h"
#include <pthread.h>

/* Helper for obtaining username for user mapping */
#define MappingUserName(userid) \
	(OidIsValid(userid) ? GetUserNameFromId(userid, false) : "public")

#define MAX_CHAR 1024
/*
 * Generic option types for validation.
 * NB! These are treated as flags, so use only powers of two here.
 */
typedef enum
{
	ServerOpt = 1,				/* options applicable to SERVER */
	UserMappingOpt = 2,			/* options for USER MAPPING */
	FdwOpt = 4					/* options for FOREIGN DATA WRAPPER */
} GenericOptionFlags;

typedef struct ForeignDataWrapper
{
	Oid			fdwid;			/* FDW Oid */
	Oid			owner;			/* FDW owner user Oid */
	char	   *fdwname;		/* Name of the FDW */
	Oid			fdwhandler;		/* Oid of handler function, or 0 */
	Oid			fdwvalidator;	/* Oid of validator function, or 0 */
	List	   *options;		/* fdwoptions as DefElem list */
}			ForeignDataWrapper;

typedef struct ForeignServer
{
	Oid			serverid;		/* server Oid */
	Oid			fdwid;			/* foreign-data wrapper */
	Oid			owner;			/* server owner user Oid */
	char	   *servername;		/* name of the server */
	char	   *servertype;		/* server type, optional */
	char	   *serverversion;	/* server version, optional */
	List	   *options;		/* srvoptions as DefElem list */
}			ForeignServer;

typedef struct UserMapping
{
	Oid			umid;			/* Oid of user mapping */
	Oid			userid;			/* local user Oid */
	Oid			serverid;		/* server Oid */
	List	   *options;		/* useoptions as DefElem list */
}			UserMapping;

typedef struct ForeignTable
{
	Oid			relid;			/* relation Oid */
	Oid			serverid;		/* server Oid */
	List	   *options;		/* ftoptions as DefElem list */
}			ForeignTable;

typedef enum
{
	SPD_FS_STATE_INIT,
	SPD_FS_STATE_BEGIN,
	SPD_FS_STATE_ITERATE,
	SPD_FS_STATE_END,
	SPD_FS_STATE_FINISH,
	SPD_FS_STATE_ERROR,
}			SpdForeignScanThreadState;

typedef struct ForeignScanThreadInfo
{
	struct FdwRoutine *fdwroutine;	/* Foreign Data wrapper  routine */
	struct ForeignScanState *fsstate;	/* ForeignScan state data */
	int			eflags;			/* it used to set on Plan nodes(bitwise OR of
								 * the flag bits ) */
	Oid			serverId;		/* use it for server id */
	bool		iFlag;			/* use it for iteration scan */
	bool		EndFlag;		/* use it for end scan */
	bool		queryRescan;
	struct TupleTableSlot *tuple;	/* use it for storing tuple, which is
									 * retrieved from the DS */
	ForeignScanStatus status;	/* it store the status of the DS */
	int			nodeIndex;		/* Index of the node */
	MemoryContext threadMemoryContext;
	pthread_mutex_t nodeMutex;	/* Use for ReScan call */
	SpdForeignScanThreadState state;
	pthread_t	me;
	ResourceOwner thrd_ResourceOwner;
	void	   *private;
}			ForeignScanThreadInfo;



extern ForeignServer * GetForeignServer(Oid serverid);
extern ForeignServer * GetForeignServerByName(const char *name, bool missing_ok);
extern UserMapping * GetUserMapping(Oid userid, Oid serverid);
extern ForeignDataWrapper * GetForeignDataWrapper(Oid fdwid);
extern ForeignDataWrapper * GetForeignDataWrapperByName(const char *name,
														bool missing_ok);
extern ForeignTable * GetForeignTable(Oid relid);

extern List * GetForeignColumnOptions(Oid relid, AttrNumber attnum);

extern Oid get_foreign_data_wrapper_oid(const char *fdwname, bool missing_ok);
extern Oid get_foreign_server_oid(const char *servername, bool missing_ok);

#endif							/* FOREIGN_H */
