/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token
 * and its lexeme
 */
void printToken(TokenType token, const char *tokenString) {
  switch (token) {

  case ENDFILE:
    pc("EOF\n");
    break;
  case ERROR: // errors are printed with pce
    pce("ERROR: %s\n", tokenString);
    break;

  /* reserved words */
  case IF:
  case ELSE:
  case INT:
  case RETURN:
  case VOID:
  case WHILE:
    pc("reserved word: %s\n", tokenString);
    break;

  /* multicharacter tokens */
  case NUM:
    pc("NUM, val= %s\n", tokenString);
    break;
  case ID:
    pc("ID, name= %s\n", tokenString);
    break;

  /* arithmetic symbols */
  case PLUS:
    pc("+\n");
    break;
  case MINUS:
    pc("-\n");
    break;
  case TIMES:
    pc("*\n");
    break;
  case OVER:
    pc("/\n");
    break;

  /* relational symbols */
  case LT:
    pc("<\n");
    break;
  case LTE:
    pc("<=\n");
    break;
  case GT:
    pc(">\n");
    break;
  case GTE:
    pc(">=\n");
    break;
  case EQ:
    pc("==\n");
    break;
  case NE:
    pc("!=\n");
    break;

  /* attribution symbol */
  case ASSIGN:
    pc("=\n");
    break;

  /* punctuation symbols */
  case COMMA:
    pc(",\n");
    break;
  case SEMI:
    pc(";\n");
    break;

    /* delimitationg symbols */
  case LBRACKET:
    pc("[\n");
    break;
  case RBRACKET:
    pc("]\n");
    break;
  case LBRACE:
    pc("{\n");
    break;
  case RBRACE:
    pc("}\n");
    break;
  case LPAREN:
    pc("(\n");
    break;
  case RPAREN:
    pc(")\n");
    break;

  default: /* should never happen */
    pce("Unknown token: %d\n", token);
  }
}

/* Procedure printLine prints a full line
 * of the source code, with its number
 * reduntand_source is ANOTHER instance 
 * of file pointer opened with the source code.
 */
void printLine(FILE *redundant_source) {
  char line[1024];
  char *ret = fgets(line, 1024, redundant_source);
  if (ret) {
    pc("%d: %-1s", lineno, line);
    if (feof(redundant_source)) {
      pc("\n");
    }
  }
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode *newStmtNode(StmtKind kind) {
  TreeNode *t = (TreeNode *)malloc(sizeof(TreeNode));
  int i;
  if (t == NULL) /// again, errors printed with pce
    pce("Out of memory error at line %d\n", lineno);
  else {
    for (i = 0; i < MAXCHILDREN; i++)
      t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

/* Function newExpNode creates a new expression
 * node for syntax tree construction
 */
TreeNode *newExpNode(ExpKind kind) {
  TreeNode *t = (TreeNode *)malloc(sizeof(TreeNode));
  int i;
  if (t == NULL)
    pce("Out of memory error at line %d\n", lineno);
  else {
    for (i = 0; i < MAXCHILDREN; i++)
      t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char *copyString(char *s) {
  int n;
  char *t;
  if (s == NULL)
    return NULL;
  n = strlen(s) + 1;
  t = malloc(n);
  if (t == NULL)
    pce("Out of memory error at line %d\n", lineno);
  else
    strcpy(t, s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static int indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno += 4
#define UNINDENT indentno -= 4

/* printSpaces indents by printing spaces */
static void printSpaces(void) {
  int i;
  for (i = 0; i < indentno; i++)
    pc(" ");
}

/* procedure printTree prints a syntax tree
 * using indentation to indicate subtrees
 */
void printTree(TreeNode *tree) {
  int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind == StmtK) {
      switch (tree->kind.stmt) {
      /* declarations */
      case FunctionK:
        pc("Declare function (return type \"%s\"): %s\n",
           (tree->type == Integer) ? "int" : "void", tree->attr.name);
        break;
      case VarDeclK:
        pc("Declare %s var: %s\n",
           (tree->type == Integer) ? "int" : "void", tree->attr.name);
        break;
      case VarDeclArrK:
        pc("Declare int array: %s\n", tree->attr.name);
        break;
      case ParamK:
        pc("Function param (int var): %s\n", tree->attr.name);
        break;
      case ParamArrK:
        pc("Function param (int array): %s\n", tree->attr.name);
        break;
      /* commands */
      case IfK:
        pc("Conditional selection\n");
        break;
      case WhileK:
        pc("Iteration (loop)\n");
        break;
      case ReturnK:
        pc("Return\n");
        break;
      case AssignK:
        pc("Assign to var: %s\n", tree->attr.name);
        break;
      case AssignArrK:
        pc("Assign to array: %s\n", tree->attr.name);
        break;
      case BlockK:
        pc("Block:\n");
        break;
      default:
        pce("Unknown StmtNode kind\n");
        break;
      }
    } else if (tree->nodekind == ExpK) {
      switch (tree->kind.exp) {
      case OpK:
        if (tree->attr.op == MINUS && tree->child[1] == NULL) {
          pc("Op: - (unario)\n");
        } else {
          pc("Op: ");
          printToken(tree->attr.op, "\0");
        }
        break;
      case ConstK:
        pc("Const: %d\n", tree->attr.val);
        break;
      case IdK:
        pc("Id: %s\n", tree->attr.name);
        break;
      case CallK:
        pc("Function call: %s\n", tree->attr.name);
        break;
      default:
        pce("Unknown ExpNode kind\n");
        break;
      }
    } else
      pce("Unknown node kind\n");
    for (i = 0; i < MAXCHILDREN; i++)
      printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
