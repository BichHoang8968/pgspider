
#include "spd_util.h"
#include "postgres.h"
char *
getDelimiter(char *query)
{
	char	   *delimptr;

	delimptr = strcasestr(query, "string_agg");
	delimptr = strcasestr(delimptr, "\'");
	delimptr += 1;
	if (*delimptr == '\'')
	{
		delimptr = pstrdup("");
	}
	else
	{
		delimptr = strtok(delimptr, "\'");
		delimptr = pstrdup(delimptr);
	}
	return delimptr;
}
