#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "libpq-fe.h"
#include "install_util.h"


void
err_msg(const char *file, const char *function, int line, const char *fmt,...)
{

	va_list		ap;

	fprintf(stderr, "File:%s Function:%s L:%d Msg:", file, function, line);

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

}

/*
 * execute query
 *
 * @param[in,out] conn - Connection for pgspider
 * @param[in] node - Information of connection node
 *
 * @return none
 */

void
create_connection(PGconn **conn, nodes * node)
{
	*conn = PQsetdbLogin(
						 node->ip,
						 node->port,
						 NULL,
						 NULL,
						 node->dbname,
						 node->user,
						 node->pass
		);
	if (PQstatus(*conn) == CONNECTION_BAD)
	{
		ERROR("Error:%s\n", PQerrorMessage(*conn));
		exit(1);
	}
}

/*
 * Close connection and exit
 *
 * @param[in] conn - Connection for pgspider
 *
 * @return none
 */
void
exit_error(PGconn *conn)
{
	PQfinish(conn);
	exit(1);
}

/*
 * Execute query
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] query - Query string
 *
 * @return none
 */

void
query_execute(PGconn *conn, char *query)
{
	PGresult   *res;

	res = PQexec(conn, query);
#ifdef PRINT_DEBUG
	printf("%s\n", query);
#endif
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		ERROR("%s failed :%s\n", query, PQerrorMessage(conn));
		exit_error(conn);
	}
}
