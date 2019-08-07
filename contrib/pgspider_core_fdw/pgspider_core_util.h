/*-------------------------------------------------------------------------
 *
 * pgspd util
 * contrib/pgspider_core_fdw/pgspider_core_fdw.h
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPERATION
 *
 *-------------------------------------------------------------------------
 */

#ifndef PG_UTIL_H
#define PG_UTIL_H

typedef struct SlotListCell
{
	struct SlotListCell *next;
	int			colid;
	char		val[FLEXIBLE_ARRAY_MEMBER];	/* variable length string */
}			SlotListCell;

typedef struct SlotList
{
	SlotListCell *head;
	SlotListCell *tail;
}			SlotList;

void slot_list_append(SlotList * list, const char *val, int colid);
char* slot_list_nth(SlotList * list, int colid);
void remove_duplicate_item(int *arr, int *size);

#endif	 /*PG_UTIL_H*/
