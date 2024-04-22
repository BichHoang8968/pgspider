#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include "libpq-fe.h"
#include "install_util.h"
#include "error_codes.h"

#ifdef _MSC_VER
#include <Windows.h>

static double
calc_time_diff(LARGE_INTEGER start, LARGE_INTEGER end)
{
	LARGE_INTEGER freq;

	QueryPerformanceFrequency(&freq);
	return (double) (end.QuadPart - start.QuadPart) / freq.QuadPart;
}

typedef LARGE_INTEGER MyTimer;
#define PerformanceCounter(value) \
	QueryPerformanceCounter(value)
#define PerformanceTime(start, end) \
	calc_time_diff(start, end)
#else
typedef struct timespec MyTimer;
#define PerformanceCounter(value) \
	clock_gettime(CLOCK_REALTIME, value)
#define PerformanceTime(start, end) \
	(end.tv_sec - start.tv_sec)
#endif

void		err_msg(const char *file, const char *function, int line, const char *fmt,...) __attribute__((format(printf, 4, 5)));
static void append_string_info_char(string_info str, char ch);
static void enlarge_string_info(string_info str);

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
 * Create connections for PGSpider
 *
 * @param[in,out] conn - Connection for pgspider
 * @param[in] node - Information of connection node
 * @param[in] timeout - Tineout time when retrying to connect
 *
 * @return none
 */
ReturnCode
create_connection(PGconn **pConn, nodes * node, char isAdmin, int timeout)
{
	PGconn	   *conn;
	MyTimer		ts_start;
	char	   *user;
	char	   *pass;
	char	   *item_name;

	if (isAdmin == 0)
	{
		user = node->user;
		pass = node->pass;
		item_name = "username";
	}
	else
	{
		user = node->user_admin;
		pass = node->pass_admin;
		item_name = "username_admin";
	}

	if (strcmp(user, "") == 0)
	{
		PRINT_ERROR("Error: user name is not specified. Please confirm \'%s\' in pgspider node information\n", item_name);
		return SETUP_INVALID_CONTENT;
	}

	PerformanceCounter(&ts_start);

	do
	{
		MyTimer		ts_now;

		conn = PQsetdbLogin(
							node->ip,
							node->port,
							NULL,
							NULL,
							node->dbname,
							user,
							pass
			);

		if (PQstatus(conn) == CONNECTION_OK)
		{
			break;
		}

		PerformanceCounter(&ts_now);

		/* Jedge whether we should retry. */
		if (timeout == 0 || (timeout > 0 && PerformanceTime(ts_now, ts_start) > timeout))
		{
			PRINT_ERROR("Error:%s\n", PQerrorMessage(conn));
			return SETUP_CANNOT_CONNECT;
		}
		else
		{
			MY_SLEEP(RETRY_INTERVAL);
		}
	} while (1);

	*pConn = conn;

	return SETUP_OK;
}

/*
 * Execute query
 *
 * @param[in] conn - Connection for pgspider
 * @param[in] query - Query string
 *
 * @return none
 */
ReturnCode
query_execute(PGconn *conn, char *query)
{
	PGresult   *res;

	res = PQexec(conn, query);
#ifdef PRINT_DEBUG
	printf("%s\n", query);
#endif
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		PRINT_ERROR("%s failed :%s\n", query, PQerrorMessage(conn));
		return SETUP_QUERY_FAILED;
	}
	return SETUP_OK;
}

/*
 * Make a SQL string literal representing "val".
 * Referenced from the function deparseStringLiteral() of PostgreSQL FDW 16.0
 */
void
deparse_string_literal(string_info buf, const char *val)
{
	const char *valptr;

	/*
	 * According to PostgreSQL specification, PostgreSQL accepts “escape” string constants, which are an extension
	 * to the SQL standard. An escape string constant is specified by writing the letter E (upper or lower case)
	 * just before the opening single quote, e.g., E'foo'. Backslash (\) and single quote (') are allowed in
	 * SQL string, so to include these characters, append a backslash before them like this \\ and \'.
	 */
	if (strchr(val, '\\') != NULL)
		append_string_info_char(buf, ESCAPE_STRING_SYNTAX);
	append_string_info_char(buf, '\'');
	for (valptr = val; *valptr; valptr++)
	{
		char		ch = *valptr;

		if (SQL_STR_DOUBLE(ch, TRUE))
			append_string_info_char(buf, ch);
		append_string_info_char(buf, ch);
	}
	append_string_info_char(buf, '\'');
}

/*
 * append_string_info_char
 *
 * Append a character to string.
 */
static void
append_string_info_char(string_info str, char ch)
{
	/* Make more room if needed */
	if (str->len + 1 >= str->maxlen)
		enlarge_string_info(str);

	/* OK, append the character */
	str->data[str->len] = ch;
	str->len++;
	str->data[str->len] = '\0';
}

/*
 * enlarge_string_info
 *
 * enlarge string if it has not enough space
 */
static void
enlarge_string_info(string_info str)
{
	int			newlen = 2 * str->maxlen;

	str->data = (char *) realloc(str->data, newlen);

	if (str->data == NULL)
		PRINT_ERROR("Error: Not enough memory");

	str->maxlen = newlen;
}

/*
 * init_string_info
 *
 * Initialize a string with default values.
 */
void
init_string_info(string_info str)
{
	int			size = 1024;	/* initial default buffer size */

	str->data = (char *) malloc(size);
	if (str->data == NULL)
		PRINT_ERROR("Error: Not enough memory");

	str->maxlen = size;
	str->data[0] = '\0';
	str->len = 0;
}

/*
 * Lower string
 */
char*
to_lower(char *str)
{
	int i;

	for(i = 0; str[i]; i++)
	{
		str[i] = tolower(str[i]);
	}

	return str;
}
