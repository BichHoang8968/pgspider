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
typedef enum
{
	STATUSOK = 0,
	STATUSITERATIONEND = 1,
	STATUSBADCONNECTION = 2
}ForeignScanStatus;

typedef struct ForeignDataWrapper
{
	Oid			fdwid;			/* FDW Oid */
	Oid			owner;			/* FDW owner user Oid */
	char	   *fdwname;		/* Name of the FDW */
	Oid			fdwhandler;		/* Oid of handler function, or 0 */
	Oid			fdwvalidator;	/* Oid of validator function, or 0 */
	List	   *options;		/* fdwoptions as DefElem list */
} ForeignDataWrapper;

typedef struct ForeignServer
{
	Oid			serverid;		/* server Oid */
	Oid			fdwid;			/* foreign-data wrapper */
	Oid			owner;			/* server owner user Oid */
	char	   *servername;		/* name of the server */
	char	   *servertype;		/* server type, optional */
	char	   *serverversion;	/* server version, optional */
	List	   *options;		/* srvoptions as DefElem list */
} ForeignServer;

typedef struct UserMapping
{
	Oid			umid;			/* Oid of user mapping */
	Oid			userid;			/* local user Oid */
	Oid			serverid;		/* server Oid */
	List	   *options;		/* useoptions as DefElem list */
} UserMapping;

typedef struct ForeignTable
{
	Oid			relid;			/* relation Oid */
	Oid			serverid;		/* server Oid */
	List	   *options;		/* ftoptions as DefElem list */
} ForeignTable;
#define MAX_QUERY_PER_AGG (2)

typedef struct ForeignServerMapping
{
	ForeignServer *server;
	UserMapping *mapping;
}	ForeignServerMapping;

typedef enum
{
	AGG_AVG = 1,				/* Average Type */
	AGG_SUM,					/* Sum Type */
	AGG_COUNT,					/* Count Type */
	AGG_MAX,					/* Max Type */
	AGG_MIN,					/* Min Type */
	AGG_BIT_AND,				/* Bit AND Type */
	AGG_BIT_OR,					/* Bit OR Type */
	AGG_BOOL_AND,				/* Bool AND Type */
	AGG_BOOL_OR,				/* Bool OR Type */
	AGG_EVERY,					/* EVERY Type */
	AGG_STRING_AGG,				/* String Agg Type */
	AGG_VAR,					/* Variance Type */
	AGG_STDDEV,					/* stddev Type */
	AGG_DEFAULT					/* Undefined Agg Type */

}	DdsfAggType;

typedef struct ForeignDdsfSum
{
	float8		value;
	/* For double precision */
	float4		realType;
	/* For real data type */
	int64		bigint_val;
}	ForeignDdsfSum;

typedef struct ForeignDdsfCount
{
	int64		value;
}	ForeignDdsfCount;

typedef struct ForeignDate
{
	int32		year;
	int32		mon;
	int32		mday;
}	ForeignDate;
typedef struct ForeignMaxMin
{
	int64		value;
	Oid			enumOid;
	ForeignDate fDate;
	float4		realVal;
	float8		dpVal;
	char		strMinMax[MAX_CHAR];
}	ForeignDdsfMaxMin;

typedef struct ForeignDdsfVariance
{
	long double value;
}	ForeignDdsfVariance;

/* Not needed till variance is directly used for calculating stddev*/
typedef struct ForeignDdsfStddev
{
	long double value;
}	ForeignDdsfStddev;

typedef struct ForeignDdsfAverage
{
	ForeignDdsfSum sum;
	ForeignDdsfCount count;
}	ForeignDdsfAverage;
typedef struct ForeignDdsfBitAndBitor
{
	int64		bitall;			/* Store the value of DDSF query */
}	ForeignDdsfBitAndBitor;

typedef struct ForeignDdsfBoolAndBoolOrEvery
{
	bool		boolall;		/* Store the bool value of DDSF query */
}	ForeignDdsfBoolAndBoolOrEvery;

typedef struct ForeignDdsfStringAgg
{
	StringInfo	state;			/* Store the stringinfo state information of
								 * DDSF query */
}	ForeignDdsfStringAgg;
typedef struct ForeignDdsfVarianceCumltv		/* Cumulative variance struct */
{
	ForeignDdsfSum sum;
	ForeignDdsfCount count;
	ForeignDdsfVariance var;
}	ForeignDdsfVarianceCumltv;

typedef struct ForeignDdsfStddevCumltv
{
	ForeignDdsfSum sum;
	ForeignDdsfCount count;
	ForeignDdsfStddev stddev;
}	ForeignDdsfStddevCumltv;

typedef union ForeignDdsfValue
{
		ForeignDdsfAverage avg;
		ForeignDdsfSum sum;
		ForeignDdsfCount count;
		ForeignDdsfMaxMin maxmin;
		ForeignDdsfBitAndBitor bitvar;		/* used for Bit And and OR */
		ForeignDdsfBoolAndBoolOrEvery boolvar;		/* Used for Bool And, OR and
													 * every */
		ForeignDdsfStringAgg stringagg;		/* Used for string agg */
		ForeignDdsfStringAgg bit_op;
		ForeignDdsfVarianceCumltv var;
		ForeignDdsfStddevCumltv stddev;		/* Not needed till variance is
												 * directly used for calculating
												 * stddev */
}	ForeignDdsfValue;

typedef enum DdsfResStatus
{
	DDSF_FRG_ERROR = 0,
	DDSF_FRG_OK
}	DdsfResStatus;

typedef struct ForeignDdsfAggregate
{
	Oid			typid;
	DdsfAggType type;
	ForeignDdsfValue aggdata;
	DdsfResStatus status;
	Datum finalResult;
}	ForeignDdsfAggregate;

typedef struct ForeignAggInfo
{
	void	   *conn;
	ForeignServer *server;
	UserMapping *user;
	ForeignDdsfAggregate result[10];	/* return value */	
	char		transquery[1024];
	Oid			typid;
}	ForeignAggInfo;

typedef enum{
	DDSF_FS_STATE_INIT,
	DDSF_FS_STATE_BEGIN,
	DDSF_FS_STATE_ITERATE,
	DDSF_FS_STATE_END,
	DDSF_FS_STATE_FINISH,
	DDSF_FS_STATE_ERROR,
}DdsfForeignScanThreadState;
typedef struct ForeignScanThreadInfo
{
	struct FdwRoutine * fdwroutine; /* Foreign Data wrapper  routine */
	struct ForeignScanState *fsstate; /* ForeignScan state data */
	int eflags; /*it used to set on Plan nodes(bitwise OR of the flag bits )*/
	Oid serverId; /* use it for server id */
	bool iFlag; /* use it for iteration scan*/
	bool EndFlag; /* use it for end scan */
	bool queryRescan;
	struct TupleTableSlot *tuple;	/* use it for storing tuple, which is retrieved from the DS */
	ForeignScanStatus status; /* it store the status of the DS */
	int nodeIndex; /* Index of the node */
    MemoryContext threadMemoryContext;
	pthread_mutex_t nodeMutex; /* Use for ReScan call */
    DdsfForeignScanThreadState state;
	pthread_t me;
	ResourceOwner thrd_ResourceOwner;	
	void *private;
} ForeignScanThreadInfo;


typedef struct ForeignScanFlags
{
	bool iFlag; /* use it for iteration scan*/
	bool EndFlag; /* use it for end scan */
}ForeignScanFlags;


extern ForeignServer *GetForeignServer(Oid serverid);
extern ForeignServer *GetForeignServerByName(const char *name, bool missing_ok);
extern UserMapping *GetUserMapping(Oid userid, Oid serverid);
extern ForeignDataWrapper *GetForeignDataWrapper(Oid fdwid);
extern ForeignDataWrapper *GetForeignDataWrapperByName(const char *name,
							bool missing_ok);
extern ForeignTable *GetForeignTable(Oid relid);

extern List *GetForeignColumnOptions(Oid relid, AttrNumber attnum);

extern Oid	get_foreign_data_wrapper_oid(const char *fdwname, bool missing_ok);
extern Oid	get_foreign_server_oid(const char *servername, bool missing_ok);

#endif							/* FOREIGN_H */
