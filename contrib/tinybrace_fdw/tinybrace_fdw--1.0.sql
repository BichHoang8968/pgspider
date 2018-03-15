/*-------------------------------------------------------------------------
 *
 * mysql_fdw--1.0.sql
 * 			Foreign-data wrapper for remote MySQL servers
 *
 * Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
 *
 * IDENTIFICATION
 * 			mysql_fdw--1.0.sql
 *
 *-------------------------------------------------------------------------
 */


CREATE FUNCTION tinybrace_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION tinybrace_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER tinybrace_fdw
  HANDLER tinybrace_fdw_handler
  VALIDATOR tinybrace_fdw_validator;
