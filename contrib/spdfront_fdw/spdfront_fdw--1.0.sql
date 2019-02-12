/* contrib/postgres_fdw/postgres_fdw--1.0.sql */

-- complain if script
	is sourced in psql, rather than via CREATE EXTENSION
			   \echo Use "CREATE EXTENSION spdfront_fdw" to load this file.\ quit

				CREATE FUNCTION spdfront_fdw_handler()
			RETURNS fdw_handler
			AS 'MODULE_PATHNAME'
			LANGUAGE C STRICT;

CREATE		FUNCTION
spdfront_fdw_validator(text[], oid)
RETURNS void
			AS 'MODULE_PATHNAME'
			LANGUAGE C STRICT;

CREATE		FOREIGN DATA WRAPPER spdfront_fdw
			HANDLER spdfront_fdw_handler
			VALIDATOR spdfront_fdw_validator;
