/* contrib/ddsf_fdw/ddsf_fdw--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ddsf_fdw" to load this file. \quit

CREATE FUNCTION ddsf_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION ddsf_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER ddsf_fdw
  HANDLER ddsf_fdw_handler
  VALIDATOR ddsf_fdw_validator;
