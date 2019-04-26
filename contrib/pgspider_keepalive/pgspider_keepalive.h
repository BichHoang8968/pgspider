#ifndef SPD_FDW_H
#define SPD_FDW_H

/* These are always necessary for a bgworker */
#include "miscadmin.h"
#include "postmaster/bgworker.h"
#include "storage/ipc.h"
#include "storage/latch.h"
#include "storage/lwlock.h"
#include "storage/proc.h"
#include "storage/shmem.h"

/* these headers are used by this particular worker's code */
#include "access/xact.h"
#include "executor/spi.h"
#include "fmgr.h"
#include "lib/stringinfo.h"
#include "pgstat.h"
#include "utils/builtins.h"
#include "utils/snapmgr.h"
#include "tcop/utility.h"
#include "pthread.h"

#include "foreign/foreign.h"

#define IPV6LEN 45
#define CMDLEN 50 + IPV6LEN

typedef struct nodeinfotag
{
	char		nodeName[NAMEDATALEN];
	char		ip[IPV6LEN];
}			nodeinfotag;

typedef struct NODEINFO
{
	/* tag */
	nodeinfotag tag;

	/* data */
	bool		isAlive;
}			NODEINFO;

extern HTAB *InitPredicateKeepalives();
extern bool check_server_ipname(ForeignServer *fs, ForeignTable *ft);

#endif
