/****************************************************/
/* File: symtab.h                                   */
/* Symbol table interface for the TINY compiler     */
/* (allows only one symbol table)                   */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

#include "globals.h"

/* IDType is used to identify an ID with a variable, an array, or a functon */
typedef enum { VAR_ID, ARRAY_ID, FUN_ID } IDType;

/* the list of line numbers of the source
 * code in which an ID is referenced
 */
typedef struct LineListRec {
  int lineno;
  struct LineListRec *next;
} *LineList;

/* The record in the bucket lists for
 * each variable, including name,
 * assigned memory location, and
 * the list of line numbers in which
 * it appears in the source code
 */
typedef struct BucketListRec {
  char *name;
  char *scope;
  IDType idType;
  ExpType dataType;
  LineList lines;
  int memloc; /* memory location for variable */
  struct BucketListRec *next;
} *BucketList;

/* Procedure st_init initializes the symbol table,
 *  inserting input and output functions.
 */
void st_init(void);

/* Procedure st_insert inserts scope, line numbers, IDType,
 * ExpType and memory locations into the symbol table.
 */
void st_insert(char *name, char *scope, IDType idType, ExpType expType,
               int lineno, int loc);

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * in all the active scopes.
 */
BucketList st_lookup(char *name);

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * only in the current (top) scope.
 */
BucketList st_lookup_top(char *name);

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * only in the global scope.
 */
BucketList st_lookup_global(char *name);

/* Procedure st_add_lineno adds a line number to the
 * line list of a BucketListRec object.
 */
void st_add_lineno(BucketList l, int lineno);

/* Procedure st_push_scope adds a new scope
 * to the symbol table.
 */
void st_push_scope(char *scope);

/* Procedure st_pop_scope removes the current
 * scope from the symbol table.
 */
void st_pop_scope(void);

/* Procedure st_current_scope returns the
 * current scope.
 */
char *st_current_scope(void);

/* Procedure printSymTab prints a formatted
 * list of the symbol table contents.
 */
void printSymTab();

#endif
