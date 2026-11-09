/****************************************************/
/* File: symtab.c                                   */
/* Symbol table implementation for the TINY compiler*/
/* (allows only one symbol table)                   */
/* Symbol table is implemented as a chained         */
/* hash table                                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "symtab.h"
#include "log.h"
#include <stdlib.h>
#include <string.h>

/* SIZE is the size of the hash table */
#define SIZE 211

#define MAX_SCOPE_DEPTH 32

/* SHIFT is the power of two used as multiplier
   in hash function  */
#define SHIFT 4

/* the hash function */
static int hash(char *key) {
  int temp = 0;
  int i = 0;
  while (key[i] != '\0') {
    temp = ((temp << SHIFT) + key[i]) % SIZE;
    ++i;
  }
  return temp;
}

/* the hash table */
static BucketList hashTable[SIZE];

static char *scopeStack[MAX_SCOPE_DEPTH];

static int scopeTop = -1;

/* Procedure st_init initializes the symbol table,
 * inserting input and output functions.
 */
void st_init(void) {
  int i;
  for (i = 0; i < SIZE; ++i) {
    hashTable[i] = NULL;
  }
  scopeTop = 0;
  scopeStack[0] = "";
  st_insert("input", "", FUN_ID, Integer, 0, 0);
  st_insert("output", "", FUN_ID, Void, 0, 0);
}

/* Procedure st_push_scope adds a new scope
 * to the symbol table.
 */
void st_push_scope(char *scope) {
  if (scopeTop < MAX_SCOPE_DEPTH - 1) {
    scopeStack[++scopeTop] = scope;
  }
}

/* Procedure st_pop_scope removes the current
 * scope from the symbol table.
 */
void st_pop_scope(void) {
  if (scopeTop > 0) {
    scopeTop--;
  }
}

/* Procedure st_current_scope returns the
 * current scope.
 */
char *st_current_scope(void) {
  if (scopeTop >= 0)
    return scopeStack[scopeTop];
  return "";
}

/* Procedure st_insert inserts scope, line numbers, IDType,
 * ExpType and memory locations into the symbol table.
 */
void st_insert(char *name, char *scope, IDType idType, ExpType expType,
               int lineno, int loc) {
  int h = hash(name);
  BucketList l = hashTable[h];
  while ((l != NULL) &&
         ((strcmp(name, l->name) != 0) || (strcmp(scope, l->scope) != 0)))
    l = l->next;
  if (l == NULL) /* variable not yet in table */
  {
    l = (BucketList)malloc(sizeof(struct BucketListRec));
    l->name = name;
    l->scope = scope;
    l->idType = idType;
    l->dataType = expType;
    if (lineno > 0) {
      l->lines = (LineList)malloc(sizeof(struct LineListRec));
      l->lines->lineno = lineno;
      l->lines->next = NULL;
    } else {
      l->lines = NULL;
    }
    l->memloc = loc;
    l->next = hashTable[h];
    hashTable[h] = l;
  } else if (lineno > 0) /* found in table, so just add line number */
  {
    st_add_lineno(l, lineno);
  }
} /* st_insert */

/* Procedure st_add_lineno adds a line number to the
 * line list of a BucketListRec object.
 */
void st_add_lineno(BucketList l, int lineno) {
  if (l == NULL || lineno <= 0)
    return;
  LineList t = l->lines;
  if (t == NULL) {
    l->lines = (LineList)malloc(sizeof(struct LineListRec));
    l->lines->lineno = lineno;
    l->lines->next = NULL;
  } else {
    while (t->next != NULL)
      t = t->next;
    if (t->lineno != lineno) { /* evita duplicar linha consecutiva */
      t->next = (LineList)malloc(sizeof(struct LineListRec));
      t->next->lineno = lineno;
      t->next->next = NULL;
    }
  }
}

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * in all the active scopes.
 */
BucketList st_lookup(char *name) {
  int h = hash(name);
  int i;
  /* Procura do escopo mais interno (scopeTop) até o global (0) */
  for (i = scopeTop; i >= 0; i--) {
    char *sc = scopeStack[i];
    BucketList l = hashTable[h];
    while (l != NULL) {
      if ((strcmp(name, l->name) == 0) && (strcmp(sc, l->scope) == 0))
        return l; /* achou no escopo ativo mais interno! */
      l = l->next;
    }
  }
  return NULL;
}

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * only in the current (top) scope.
 */
BucketList st_lookup_top(char *name) {
  int h = hash(name);
  char *sc = st_current_scope();
  BucketList l = hashTable[h];
  while (l != NULL) {
    if ((strcmp(name, l->name) == 0) && (strcmp(sc, l->scope) == 0))
      return l;
    l = l->next;
  }
  return NULL;
}

/* Function st_lookup returns a pointer to
 * a BucketListRec object named "name", searching
 * only in the global scope.
 */
BucketList st_lookup_global(char *name) {
  int h = hash(name);
  BucketList l = hashTable[h];
  while (l != NULL) {
    if ((strcmp(name, l->name) == 0) && (strcmp("", l->scope) == 0))
      return l;
    l = l->next;
  }
  return NULL;
}

static char *idTypeToStr(IDType id) {
  switch (id) {
  case VAR_ID:
    return "var";
  case ARRAY_ID:
    return "array";
  case FUN_ID:
    return "fun";
  default:
    return "";
  }
}

static char *dataTypeToStr(ExpType dt) {
  switch (dt) {
  case Integer:
    return "int";
  case Void:
    return "void";
  default:
    return "";
  }
}

/* Procedure printSymTab prints a formatted
 * list of the symbol table contents
 */
void printSymTab(void) {
  int i;
  pc("Variable Name  Scope     ID Type  Data Type  Line Numbers\n");
  pc("-------------  --------  -------  ---------  -------------------------\n");
  for (i = 0; i < SIZE; ++i) {
    if (hashTable[i] != NULL) {
      BucketList l = hashTable[i];
      while (l != NULL) {
        LineList t = l->lines;
        pc("%-14s ", l->name);
        pc("%-10s", l->scope);
        pc("%-9s", idTypeToStr(l->idType));
        pc("%-11s", dataTypeToStr(l->dataType));
        while (t != NULL) {
          pc("%2d ", t->lineno);
          t = t->next;
        }
        pc("\n");
        l = l->next;
      }
    }
  }
}
