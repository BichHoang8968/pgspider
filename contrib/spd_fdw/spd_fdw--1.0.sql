/* contrib/spd_fdw/spd_fdw--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION spd_fdw" to load this file. \quit

CREATE FUNCTION spd_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION spd_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER spd_fdw
  HANDLER spd_fdw_handler
  VALIDATOR spd_fdw_validator;
