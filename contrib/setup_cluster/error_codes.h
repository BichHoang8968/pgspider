#ifndef ERROR_CODES_H
#define ERROR_CODES_H

typedef enum ReturnCode 
{
	
	SETUP_OK = 0, 
	SETUP_NOMEM, /* No memory */ 
	SETUP_INVALID_PARAM, /* Configuration parameter is invalid */ 
	SETUP_IO_ERROR, /* Failed a file I/O */ 
	SETUP_CANNOT_CONNECT, /* Cannot connect to PGSpider */ 
	SETUP_PARSE_FAILED, /* Failed to parse JSON */ 
	SETUP_INVALID_CONTENT, /* JSON content is invalid */ 
	SETUP_QUERY_FAILED /* Failed to execute a query on PGSpider */ 
}			ReturnCode;


#endif /* ERROR_CODES_H */

