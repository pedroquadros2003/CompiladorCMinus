/****************************************************/
/* File: analyze.c                                  */
/* Semantic analyzer implementation                 */
/* for the C- compiler                              */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "analyze.h"
#include "globals.h"
#include "log.h"
#include "symtab.h"
#include "util.h"

static char *currentFuncName = NULL;
static ExpType currentFuncReturnType = Void;

/* Procedure traverse is a generic recursive
 * syntax tree traversal routine:
 * it applies preProc in preorder and postProc
 * in postorder to tree pointed to by t
 */
static void traverse(TreeNode *t, void (*preProc)(TreeNode *),
                     void (*postProc)(TreeNode *)) {
  if (t != NULL) {
    preProc(t);
    {
      int i;
      for (i = 0; i < MAXCHILDREN; i++)
        traverse(t->child[i], preProc, postProc);
    }
    postProc(t);
    traverse(t->sibling, preProc, postProc);
  }
}

/* Procedure insertNode inserts
 * identifiers stored in t into
 * the symbol table
 */
static void insertNode(TreeNode *t) {
  switch (t->nodekind) {
  case StmtK:
    switch (t->kind.stmt) {
    case FunctionK: {
      if (st_lookup_global(t->attr.name) != NULL) {
        /* Erro ser9: função com o mesmo nome já declarada */
        pce("Semantic error at line %d: Func Decl Error, Already Declared!\n",
            t->lineno);
        Error = TRUE;
      } else {
        /* Insere nova função no escopo global "" */
        st_insert(t->attr.name, "", FUN_ID, t->type, t->lineno, 0);
      }
      currentFuncName = t->attr.name;
      currentFuncReturnType = t->type;
      st_push_scope(currentFuncName);
      break;
    }
    case BlockK:
    case WhileK:
    case IfK: {
      char scopeName[64];
      sprintf(scopeName, "%s:%d", currentFuncName, t->lineno);
      st_push_scope(copyString(scopeName));
      break;
    }

    case VarDeclK:
    case VarDeclArrK: {
      if (t->type == Void) {
        pce("Semantic error at line %d: variable declared void\n", t->lineno);
        Error = TRUE;
      } else {
        BucketList g = st_lookup_global(t->attr.name);
        if (g != NULL && g->idType == FUN_ID) {
          pce("Semantic error at line %d: '%s' was already declared as a "
              "function\n",
              t->lineno, t->attr.name);
          Error = TRUE;
        } else {
          if (st_lookup_top(t->attr.name) != NULL) {
            pce("Semantic error at line %d: '%s' was already declared as a "
                "variable\n",
                t->lineno, t->attr.name);
            Error = TRUE;
          } else {
            st_insert(t->attr.name, st_current_scope(),
                      t->kind.stmt == VarDeclK ? VAR_ID : ARRAY_ID, t->type,
                      t->lineno, 0);
          }
        }
      }
      break;
    }

    case ParamK:
    case ParamArrK: {
      if (t->type == Void) {
        pce("Semantic error at line %d: variable declared void\n", t->lineno);
        Error = TRUE;
      } else {
        if (st_lookup_top(t->attr.name) != NULL) {
          pce("Semantic error at line %d: '%s' was already declared as a "
              "variable\n",
              t->lineno, t->attr.name);
          Error = TRUE;
        } else {
          st_insert(t->attr.name, currentFuncName,
                    t->kind.stmt == ParamK ? VAR_ID : ARRAY_ID, t->type,
                    t->lineno, 0);
        }
      }
      break;
    }

    case AssignK:
    case AssignArrK: {
      BucketList l = st_lookup(t->attr.name);
      if (l == NULL) {
        pce("Semantic error at line %d: '%s' was not declared in "
            "this scope\n",
            t->lineno, t->attr.name);
        Error = TRUE;
      } else {
        st_add_lineno(l, t->lineno);
        t->type = l->dataType;
      }
      break;
    }

    default:
      break;
    }
    break;

  case ExpK:
    switch (t->kind.exp) {
    case IdK: {
      BucketList l = st_lookup(t->attr.name);
      if (l == NULL) {
        pce("Semantic error at line %d: '%s' was not declared in "
            "this scope\n",
            t->lineno, t->attr.name);
        Error = TRUE;
      } else {
        st_add_lineno(l, t->lineno);
        t->type = l->dataType;
      }
      break;
    }

    default:
      break;
    }
    break;

  default:
    break;
  }
}

/* Procedure leaveScope pops scopes in postorder
 * during the first traversal
 */
static void leaveScope(TreeNode *t) {
  if (t->nodekind == StmtK) {
    switch (t->kind.stmt) {
    case FunctionK:
      st_pop_scope();
      currentFuncName = NULL;
      break;
    case BlockK:
    case WhileK:
    case IfK:
      st_pop_scope();
      break;
    default:
      break;
    }
  }
}

/* Function buildSymtab constructs the symbol
 * table by preorder traversal of the syntax tree
 */
void buildSymtab(TreeNode *syntaxTree) {
  st_init();
  currentFuncName = NULL;
  traverse(syntaxTree, insertNode, leaveScope);
  if (st_lookup_global("main") == NULL) {
    pce("Semantic error: undefined reference to 'main'\n");
    Error = TRUE;
  }
}

/* Pre-order callback for typeCheck: tracks current function return type */
static void preCheckNode(TreeNode *t) {
  if (t != NULL && t->nodekind == StmtK && t->kind.stmt == FunctionK) {
    currentFuncReturnType = t->type;
  }
}

/* Procedure checkNode performs
 * type checking at a single tree node
 */
static void checkNode(TreeNode *t) {
  switch (t->nodekind) {
  case ExpK:
    switch (t->kind.exp) {
    case CallK: {
      BucketList l = st_lookup_global(t->attr.name);
      if (l == NULL || l->idType != FUN_ID) {
        pce("Semantic error at line %d: '%s' was not declared in this scope\n",
            t->lineno, t->attr.name);
        Error = TRUE;
        t->type = Integer;
      } else {
        st_add_lineno(l, t->lineno);
        t->type = l->dataType;
      }
      break;
    }

    case OpK:
    case ConstK:
    case IdK:
      t->type = Integer;
      break;

    default:
      break;
    }
    break;

  case StmtK:
    switch (t->kind.stmt) {
    case AssignK: {
      if (t->child[0] != NULL && t->child[0]->type == Void) {
        pce("Semantic error at line %d: invalid use of void expression\n",
            t->lineno);
        Error = TRUE;
      }
      break;
    }

    case AssignArrK: {
      if (t->child[1] != NULL && t->child[1]->type == Void) {
        pce("Semantic error at line %d: invalid use of void expression\n",
            t->lineno);
        Error = TRUE;
      }
      break;
    }

    case ReturnK: {
      if (currentFuncReturnType == Integer && t->child[0] == NULL) {
        pce("Semantic error at line %d: Function should return!\n", t->lineno);
        Error = TRUE;
      }
      break;
    }

    default:
      break;
    }
    break;

  default:
    break;
  }
}

/* Procedure typeCheck performs type checking
 * by a postorder syntax tree traversal
 */
void typeCheck(TreeNode *syntaxTree) {
  traverse(syntaxTree, preCheckNode, checkNode);

  if (TraceAnalyze) {
    pc("\nSymbol table:\n\n");
    printSymTab();
  }
}
