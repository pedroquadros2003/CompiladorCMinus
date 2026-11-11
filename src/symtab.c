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

/* Registro de todos os escopos ja criados, na ordem da primeira
 * abertura, e das chamadas entre funcoes. Usados apenas para
 * definir a ordem de impressao da tabela (igual ao gabarito). */
#define MAX_SCOPES 512
#define MAX_CALLS 2048

static char *scopeNames[MAX_SCOPES];
static int scopeIsFunc[MAX_SCOPES];
static int nScopes = 0;

static char *callCaller[MAX_CALLS];
static char *callCallee[MAX_CALLS];
static int nCalls = 0;

static int scopeIndex(char *scope) {
  int i;
  for (i = 0; i < nScopes; i++)
    if (strcmp(scopeNames[i], scope) == 0)
      return i;
  return -1;
}

static void registerScope(char *scope, int isFunc) {
  if (scopeIndex(scope) < 0 && nScopes < MAX_SCOPES) {
    scopeNames[nScopes] = scope;
    scopeIsFunc[nScopes] = isFunc;
    nScopes++;
  }
}

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
  nScopes = 0;
  nCalls = 0;
  registerScope("", FALSE);
  st_insert("input", "", FUN_ID, Integer, 0, 0);
  st_insert("output", "", FUN_ID, Void, 0, 0);
}

/* Procedure st_push_scope adds a new scope
 * to the symbol table.
 */
void st_push_scope(char *scope) {
  /* escopo de funcao e o primeiro empilhado sobre o global */
  registerScope(scope, scopeTop == 0);
  if (scopeTop < MAX_SCOPE_DEPTH - 1) {
    scopeStack[++scopeTop] = scope;
  }
}

/* Procedure st_add_call records that function caller
 * calls function callee (in source order).
 */
void st_add_call(char *caller, char *callee) {
  if (nCalls < MAX_CALLS) {
    callCaller[nCalls] = caller;
    callCallee[nCalls] = callee;
    nCalls++;
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

static void printRecord(BucketList l) {
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
}

/* Imprime os registros de um escopo, na ordem dos buckets */
static void printScope(char *scope) {
  int i;
  BucketList l;
  for (i = 0; i < SIZE; ++i)
    for (l = hashTable[i]; l != NULL; l = l->next)
      if (strcmp(l->scope, scope) == 0)
        printRecord(l);
}

/* Visita em profundidade (pre-ordem) as funcoes alcancaveis
 * a partir de scopes[s], seguindo as chamadas na ordem do codigo */
static void visitCalls(int s, int *reached, int *order, int *n) {
  int c;
  reached[s] = TRUE;
  order[(*n)++] = s;
  for (c = 0; c < nCalls; c++) {
    if (strcmp(callCaller[c], scopeNames[s]) == 0) {
      int callee = scopeIndex(callCallee[c]);
      if (callee >= 0 && scopeIsFunc[callee] && !reached[callee])
        visitCalls(callee, reached, order, n);
    }
  }
}

/* Procedure printSymTab prints a formatted
 * list of the symbol table contents.
 * Ordem dos escopos (a mesma do gabarito):
 *   1. o escopo global;
 *   2. os escopos nao alcancaveis a partir de main, na ordem
 *      de criacao (blocos aninhados e funcoes nao chamadas);
 *   3. main e as funcoes alcancaveis por ela, em profundidade.
 * Dentro de cada escopo, a ordem e a dos buckets da hash.
 */
void printSymTab(void) {
  int reached[MAX_SCOPES];
  int order[MAX_SCOPES];
  int nOrder = 0;
  int i, mainIdx;
  BucketList l;

  pc("Variable Name  Scope     ID Type  Data Type  Line Numbers\n");
  pc("-------------  --------  -------  ---------  -------------------------\n");

  for (i = 0; i < nScopes; i++)
    reached[i] = FALSE;
  mainIdx = scopeIndex("main");
  if (mainIdx >= 0 && scopeIsFunc[mainIdx])
    visitCalls(mainIdx, reached, order, &nOrder);

  for (i = 0; i < nScopes; i++)
    if (!reached[i])
      printScope(scopeNames[i]);
  for (i = 0; i < nOrder; i++)
    printScope(scopeNames[order[i]]);

  /* seguranca: registros cujo escopo nao foi registrado */
  for (i = 0; i < SIZE; ++i)
    for (l = hashTable[i]; l != NULL; l = l->next)
      if (scopeIndex(l->scope) < 0)
        printRecord(l);
}
