#include "postgres.h"
#include "postgres_fdw/postgres_fdw.h"
#include "stdbool.h"
#include "access/htup_details.h"
#include "utils/syscache.h"
#include "catalog/pg_proc.h"
#include "parser/parsetree.h"
#include "catalog/pg_namespace.h"
#include "utils/lsyscache.h"
#include "pgspider_core_fdw_defs.h"
#include "catalog/pg_type.h"
#include "nodes/nodeFuncs.h"
#include "utils/builtins.h"

/*
 * Global context for foreign_expr_walker's search of an expression tree.
 */
typedef struct foreign_glob_cxt
{
	PlannerInfo *root;			/* global planner state */
	RelOptInfo *foreignrel;		/* the foreign relation we are planning for */
} foreign_glob_cxt;

/*
 * Local (per-tree-level) context for foreign_expr_walker's search.
 * This is concerned with identifying collations used in the expression.
 */
typedef enum
{
	FDW_COLLATE_NONE,			/* expression is of a noncollatable type, or
								 * it has default collation that is not
								 * traceable to a foreign Var */
	FDW_COLLATE_SAFE,			/* collation derives from a foreign Var */
	FDW_COLLATE_UNSAFE			/* collation is non-default and derives from
								 * something other than a foreign Var */
} FDWCollateState;

typedef struct foreign_loc_cxt
{
	Oid			collation;		/* OID of current collation, if any */
	FDWCollateState state;		/* state of current collation choice */
} foreign_loc_cxt;

/* Local function forward declarations */
static bool having_clause_tree_walker(Node *node, void *param);

/* Global function forward declarations */
bool is_foreign_expr2(PlannerInfo *, RelOptInfo *, Expr *);
bool is_having_safe(Node *node);
char *spd_deparse_type_name(Oid type_oid, int32 typemod);
void spd_deparse_const(Const *node, StringInfo buf, int showtype);

/*
 * Prevent push down of T_Param(Subquery Expressions) which PGSpider cannot bind
 */
static bool
is_valid_type(Oid type)
{
	switch (type)
	{
		case BOOLOID:
			return false;
		case INT2OID:
		case INT4OID:
		case INT8OID:
		case OIDOID:
		case FLOAT4OID:
		case FLOAT8OID:
		case NUMERICOID:
		case VARCHAROID:
		case TEXTOID:
		case TIMEOID:
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
			return true;
		default:
			elog(WARNING, "Found an unexpected case when check Param type. In default pushdown this case to PGSpider");
			return true;
	}
}

/*
 * Check if expression is safe to push down to remote fdw, and return true if so.
 *
 * This function was created based on deparse.c of other fdw.
 * TODO: This function is maybe missing some type of expression. 
 * It should be added more later.
 * 
 */
static bool
foreign_expr_walker(Node *node,
					foreign_glob_cxt *glob_cxt,
					foreign_loc_cxt *outer_cxt)
{
	foreign_loc_cxt inner_cxt;

	/* Need do nothing for empty subexpressions */
	if (node == NULL)
		return true;

	/* Set up inner_cxt for possible recursion to child nodes */
	inner_cxt.collation = InvalidOid;
	inner_cxt.state = FDW_COLLATE_NONE;

    switch (nodeTag(node))
	{
		case T_Var:
		{
			Var             *var = (Var *) node;
			char            *colname;
			RangeTblEntry   *rte;

			rte = planner_rt_fetch(var->varno, glob_cxt->root);
			colname = get_attname(rte->relid, var->varattno, false);

			/* Don't pushed down __spd_url */
			if (strcmp(colname, SPDURL) == 0)
			{
				return false;
			}
			break;
		}
		case T_Aggref:
		{
			Aggref 		*aggref = (Aggref*) node;
			HeapTuple 	tuple;
			char 		*opername = NULL;
			ListCell   *lc;

			if (aggref->aggdistinct != NIL)
			{
				return false;
			}

			/*
			 * Recurse to input args.
			 * Don't pushed down __spd_url.
			 */
			foreach(lc, aggref->args)
			{
				Node	   *n = (Node *) lfirst(lc);

				/* If TargetEntry, extract the expression from it */
				if (IsA(n, TargetEntry))
				{
					TargetEntry *tle = (TargetEntry *) n;

					n = (Node *) tle->expr;
				}

				if (!foreign_expr_walker(n, glob_cxt, &inner_cxt))
					return false;
			}

			/* Get function name and schema */
			tuple = SearchSysCache1(PROCOID, ObjectIdGetDatum(aggref->aggfnoid));
			if (!HeapTupleIsValid(tuple))
			{
				elog(ERROR, "cache lookup failed for function %u", aggref->aggfnoid);
			}
			opername = pstrdup(((Form_pg_proc) GETSTRUCT(tuple))->proname.data);
			ReleaseSysCache(tuple);

			/*
			 * The aggregate functions array_agg, json_agg, jsonb_agg, json_object_agg,
			 * jsonb_object_agg, as well as similar user-defined
			 * aggregate functions, produce meaningfully different result values depending
			 * on the order of the input values. It is hard to control the order of input
			 * value in PGSpider temp table. So, we change there aggregate functions to
			 * not pushdown to FDW
			 */
			if (strcmp(opername, "array_agg") == 0
				|| strcmp(opername, "json_agg") == 0
				|| strcmp(opername, "jsonb_agg") == 0
				|| strcmp(opername, "json_object_agg") == 0
				|| strcmp(opername, "jsonb_object_agg") == 0
			)
			{
				return false;
			}
			if (strcmp(opername, "string_agg") == 0
				|| strcmp(opername, "xmlagg") == 0
			)
			{
				/*
				 * The aggregate functions string_agg, and xmlagg, are not pushdown to FDW
				 * when has ORDER BY
				 */
				if (aggref->aggorder != NIL)
				{
					return false;
				}
			}
			break;
		}
		case T_List:
		{
			List	   *l = (List *) node;
			ListCell   *lc;

			/*
			 * Recurse to component subexpressions.
			 */
			foreach(lc, l)
			{
				if (!foreign_expr_walker((Node *) lfirst(lc), glob_cxt, &inner_cxt))
					return false;
			}
			break;
		}
		case T_FuncExpr:
		{
			FuncExpr	*func = (FuncExpr *) node;

			/* Not pushable Function Expression when it is called directly */
			if (func->funcformat == COERCE_EXPLICIT_CALL )
				return false;
			break;
		}
		case T_OpExpr:
		{
			OpExpr	   *oe = (OpExpr *) node;

			/*
			 * Recurse to input subexpressions.
			 */
			if (!foreign_expr_walker((Node *) oe->args, glob_cxt, &inner_cxt))
				return false;
			break;
		}
		case T_Param:
		{
			Param	   *p = (Param *) node;
			/* Check type of T_Param(Subquery Expressions) */
			if (!is_valid_type(p->paramtype))
				return false;
			break;
		}
		case T_BoolExpr:
		{
			BoolExpr   *b = (BoolExpr *) node;

			/*
			 * Recurse to input subexpressions.
			 */
			if (!foreign_expr_walker((Node *) b->args,
										glob_cxt, &inner_cxt))
				return false;
			break;
		}
		default:
			break;
	}

	/* It looks OK */
	return true;
}

bool
is_foreign_expr2(PlannerInfo *root, RelOptInfo *baserel, Expr *expr)
{
	foreign_glob_cxt glob_cxt;
	foreign_loc_cxt loc_cxt;
	
	/*
	 * Check that the expression consists of nodes that are safe to execute
	 * remotely.
	 */
	glob_cxt.root = root;
	glob_cxt.foreignrel = baserel;
	loc_cxt.collation = InvalidOid;
	loc_cxt.state = FDW_COLLATE_NONE;

	if (!foreign_expr_walker((Node *) expr, &glob_cxt, &loc_cxt))
		return false;

	return true;
}

/*
 * Append a SQL string literal representing "val" to buf.
 */
void
deparseStringLiteral(StringInfo buf, const char *val)
{
	const char *valptr;

	/*
	 * Rather than making assumptions about the remote server's value of
	 * standard_conforming_strings, always use E'foo' syntax if there are any
	 * backslashes.  This will fail on remote servers before 8.1, but those
	 * are long out of support.
	 */
	if (strchr(val, '\\') != NULL)
		appendStringInfoChar(buf, ESCAPE_STRING_SYNTAX);
	appendStringInfoChar(buf, '\'');
	for (valptr = val; *valptr; valptr++)
	{
		char		ch = *valptr;

		if (SQL_STR_DOUBLE(ch, true))
			appendStringInfoChar(buf, ch);
		appendStringInfoChar(buf, ch);
	}
	appendStringInfoChar(buf, '\'');
}

/*
 * having_clause_tree_walker
 *
 * Check if HAVING expression is safe to pass to child fdws.
 */
static bool having_clause_tree_walker(Node *node, void *param)
{
	/* Need do nothing for empty subexpression. */
	if (node == NULL)
		return false;

	switch (nodeTag(node))
	{
		case T_Aggref:
		{
			Aggref		*agg = (Aggref *) node;
			char		*opername = NULL;
			HeapTuple	tuple;

			/* Get function name */
			tuple = SearchSysCache1(PROCOID, ObjectIdGetDatum(agg->aggfnoid));
			if (!HeapTupleIsValid(tuple))
			{
				elog(ERROR, "cache lookup failed for function %u", agg->aggfnoid);
			}
			opername = pstrdup(((Form_pg_proc) GETSTRUCT(tuple))->proname.data);
			ReleaseSysCache(tuple);

			/* These functions can not be passed to child FDW. */
			if (strcmp(opername, "avg") == 0
				|| strcmp(opername, "stddev") == 0
				|| strcmp(opername, "variance") == 0)
			{
				return true;
			}
			break;
		}
		case T_FuncExpr:
		case T_OpExpr:
		{
			List		*args = NIL;
			ListCell	*lc;

			if (IsA(node, FuncExpr))
				args = ((FuncExpr *) node)->args;
			else
				args = ((OpExpr *) node)->args;

			foreach(lc, args)
			{
				Expr *arg = (Expr *)lfirst(lc);

				if (!(IsA(arg, BoolExpr) || IsA(arg, FuncExpr) || IsA(arg, List)))
				{
					if (!(IsA(arg, Aggref) || IsA(arg, Var) || IsA(arg, Const)))
						return true;
				}
			}
			break;
		}
		default:
			break;
	}

	return expression_tree_walker(node, having_clause_tree_walker, (void *) param);
}

/*
 * is_having_safe
 *
 * Check every conditions whether expression
 * is safe to pass to child FDW or not.
 */
bool is_having_safe(Node *node)
{
	return (!having_clause_tree_walker(node, NULL));
}


/*
 *	Convert type OID + typmod info into a type name
 */
char *spd_deparse_type_name(Oid type_oid, int32 typemod)
{
	bits16		flags = FORMAT_TYPE_TYPEMOD_GIVEN;

	return format_type_extended(type_oid, typemod, flags);
}


/*
 * Deparse given constant value into buf.
 *
 * This function has to be kept in sync with ruleutils.c's get_const_expr.
 * As for that function, showtype can be -1 to never show "::typename" decoration,
 * or +1 to always show it, or 0 to show it only if the constant wouldn't be assumed
 * to be the right type by default.
 */
void spd_deparse_const(Const *node, StringInfo buf, int showtype)
{
	Oid			typoutput;
	bool		typIsVarlena;
	char		*extval;
	bool		isfloat = false;
	bool		needlabel;

	if (node->constisnull)
	{
		appendStringInfoString(buf, "NULL");
		if (showtype >= 0)
			appendStringInfo(buf, "::%s",
							 spd_deparse_type_name(node->consttype,
											   node->consttypmod));
		return;
	}

	getTypeOutputInfo(node->consttype,
					  &typoutput, &typIsVarlena);
	extval = OidOutputFunctionCall(typoutput, node->constvalue);

	switch (node->consttype)
	{
		case INT2OID:
		case INT4OID:
		case INT8OID:
		case OIDOID:
		case FLOAT4OID:
		case FLOAT8OID:
		case NUMERICOID:
			{
				/*
				 * No need to quote unless it's a special value such as 'NaN'.
				 * See comments in get_const_expr().
				 */
				if (strspn(extval, "0123456789+-eE.") == strlen(extval))
				{
					if (extval[0] == '+' || extval[0] == '-')
						appendStringInfo(buf, "(%s)", extval);
					else
						appendStringInfoString(buf, extval);
					if (strcspn(extval, "eE.") != strlen(extval))
						isfloat = true; /* it looks like a float */
				}
				else
					appendStringInfo(buf, "'%s'", extval);
			}
			break;
		case BITOID:
		case VARBITOID:
			appendStringInfo(buf, "B'%s'", extval);
			break;
		case BOOLOID:
			if (strcmp(extval, "t") == 0)
				appendStringInfoString(buf, "true");
			else
				appendStringInfoString(buf, "false");
			break;
		default:
			deparseStringLiteral(buf, extval);
			break;
	}

	pfree(extval);

	if (showtype < 0)
		return;

	/*
	 * For showtype == 0, append ::typename unless the constant will be
	 * implicitly typed as the right type when it is read in.
	 *
	 * XXX this code has to be kept in sync with the behavior of the parser,
	 * especially make_const.
	 */
	switch (node->consttype)
	{
		case BOOLOID:
		case INT4OID:
		case UNKNOWNOID:
			needlabel = false;
			break;
		case NUMERICOID:
			needlabel = !isfloat || (node->consttypmod >= 0);
			break;
		default:
			needlabel = true;
			break;
	}
	if (needlabel || showtype > 0)
		appendStringInfo(buf, "::%s",
						 spd_deparse_type_name(node->consttype,
										   node->consttypmod));
}
