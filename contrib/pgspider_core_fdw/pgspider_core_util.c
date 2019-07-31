/*-------------------------------------------------------------------------
 *
 * pgspd util
 * contrib/pgspider_core_fdw/pgspider_core_fdw.h
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPERATION
 *
 *-------------------------------------------------------------------------
 */
#include "postgres_fe.h"

#include "pgspider_core_util.h"

/*
 * Append a value to the list.
 *
 */
void slot_list_append(SlotList * list, const char *val, int colid)
{
	SlotListCell *cell;

	cell = (SlotListCell *)palloc0(sizeof(SlotListCell));
	cell->val = (char*)palloc0(strlen(val) + 1);

	cell->next = NULL;
	cell->colid = colid;
	strcpy(cell->val, val);

	if (list->tail)
		list->tail->next = cell;
	else
		list->head = cell;
	list->tail = cell;

}


/*
 * Get value in the list at colid
 *
 */
char *slot_list_nth(SlotList * list, int colid)
{
	SlotListCell *cell;

	for (cell = list->head; cell; cell = cell->next)
	{
		if (cell->colid == colid)
		{
			return cell->val;
		}
	}
	return NULL;
}

/* Remove duplicate item from an array */
void remove_duplicate_item(int *arr, int *size){
    int i, j, k;

	for(i = 0; i < *size; i++)
    {
        for(j = i+1; j < *size; j++)
        {
            if(arr[i] == arr[j])
            {
                for(k = j; k < *size; k++)
                    arr[k] = arr[k + 1];
                *size = *size - 1;
                j--;
            }
        }
    }
}

