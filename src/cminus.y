/****************************************************/
/* File: cminus.y                                   */
/* Bison/Yacc specification file for C-             */
/* Project for CES41: Compiladores                  */
/****************************************************/
%{
#define YYPARSER /* distinguishes Bison output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName;            /* name captured right after an ID is scanned */
static int savedLineNo;             /* line number of the saved name */
static int savedNumber;             /* value captured right after a NUM is scanned */
static TreeNode * savedTree = NULL; /* stores the syntax tree for later return */

static int yylex(void);
int yyerror(char * message);
%}

%token IF ELSE INT RETURN VOID WHILE
%token ID NUM
%token PLUS MINUS TIMES OVER
%token LT LTE GT GTE EQ NE
%token ASSIGN SEMI COMMA
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token ERROR

/* Resolution of the classic dangling-else shift/reduce conflict:
 * ELSE has higher precedence than a plain IF, so the parser shifts
 * ELSE (binding it to the nearest IF) instead of reducing. */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%% /* Grammar for C- */

program
    : declaration_list
        { savedTree = $1; }
    ;

declaration_list
    : declaration_list declaration
        { YYSTYPE t = $1;
          if (t != NULL) {
            while (t->sibling != NULL) t = t->sibling;
            t->sibling = $2;
            $$ = $1;
          } else $$ = $2;
        }
    | declaration
        { $$ = $1; }
    ;

declaration
    : var_declaration { $$ = $1; }
    | fun_declaration { $$ = $1; }
    ;

/* Every use of the ID token goes through this nonterminal. Because ID
 * appears nowhere else, the state after shifting ID has a single (default)
 * reduction, so no lookahead is fetched and tokenString still holds the
 * identifier lexeme when we copy it. */
id
    : ID { savedName = copyString(tokenString); savedLineNo = lineno; }
    ;

/* Same idea as "id", for numeric literals. */
num
    : NUM { savedNumber = atoi(tokenString); savedLineNo = lineno; }
    ;

/* type_specifier yields a throwaway node whose only purpose is to carry
 * the declared type up to the declaration rule via $1->type. */
type_specifier
    : INT  { $$ = newExpNode(ConstK); $$->type = Integer; }
    | VOID { $$ = newExpNode(ConstK); $$->type = Void; }
    ;

var_declaration
    : type_specifier id SEMI
        { $$ = newStmtNode(VarDeclK);
          $$->attr.name = savedName;
          $$->type = $1->type;
          $$->lineno = savedLineNo;
        }
    | type_specifier id LBRACKET num RBRACKET SEMI
        { $$ = newStmtNode(VarDeclArrK);
          $$->attr.name = savedName;
          $$->type = Integer;
          $$->lineno = savedLineNo;
          $$->child[0] = newExpNode(ConstK);
          $$->child[0]->attr.val = savedNumber;
        }
    ;

fun_declaration
    : type_specifier id LPAREN
        /* Build the node now, while savedName still holds the function
         * name (the parameter names would overwrite it below). */
        { $$ = newStmtNode(FunctionK);
          $$->attr.name = savedName;
          $$->type = $1->type;
          $$->lineno = savedLineNo;
        }
      params RPAREN compound_stmt
        { $$ = $4;
          $$->child[0] = $5;   /* parameter list (chained by sibling) */
          $$->child[1] = $7;   /* function body: raw list, no Block node */
        }
    ;

params
    : param_list { $$ = $1; }
    | VOID { $$ = NULL; }
    ;

param_list
    : param_list COMMA param
        { YYSTYPE t = $1;
          if (t != NULL) {
            while (t->sibling != NULL) t = t->sibling;
            t->sibling = $3;
            $$ = $1;
          } else $$ = $3;
        }
    | param { $$ = $1; }
    ;

param
    : type_specifier id
        { $$ = newStmtNode(ParamK);
          $$->attr.name = savedName;
          $$->type = Integer;
          $$->lineno = savedLineNo;
        }
    | type_specifier id LBRACKET RBRACKET
        { $$ = newStmtNode(ParamArrK);
          $$->attr.name = savedName;
          $$->type = Integer;
          $$->lineno = savedLineNo;
        }
    ;

/* Function body: returns the raw chained list (no Block node). */
compound_stmt
    : LBRACE local_list RBRACE
        { $$ = $2; }
    ;

/* Extension 1: local declarations and statements may be interleaved. */
local_list
    : local_list local_item
        { if ($1 == NULL) $$ = $2;
          else if ($2 == NULL) $$ = $1;
          else { YYSTYPE t = $1;
                 while (t->sibling != NULL) t = t->sibling;
                 t->sibling = $2;
                 $$ = $1;
               }
        }
    | /* empty */ { $$ = NULL; }
    ;

local_item
    : var_declaration { $$ = $1; }
    | statement { $$ = $1; }
    ;

statement
    : expression_stmt { $$ = $1; }
    /* Extension 2: a nested { ... } used as a statement becomes a Block node. */
    | compound_stmt   { $$ = newStmtNode(BlockK); $$->child[0] = $1; }
    | selection_stmt  { $$ = $1; }
    | iteration_stmt  { $$ = $1; }
    | return_stmt     { $$ = $1; }
    ;

expression_stmt
    : expression SEMI { $$ = $1; }
    | SEMI { $$ = NULL; }
    ;

selection_stmt
    : IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
        { $$ = newStmtNode(IfK);
          $$->child[0] = $3;
          $$->child[1] = $5;
        }
    | IF LPAREN expression RPAREN statement ELSE statement
        { $$ = newStmtNode(IfK);
          $$->child[0] = $3;
          $$->child[1] = $5;
          $$->child[2] = $7;
        }
    ;

iteration_stmt
    : WHILE LPAREN expression RPAREN statement
        { $$ = newStmtNode(WhileK);
          $$->child[0] = $3;
          $$->child[1] = $5;
        }
    ;

return_stmt
    : RETURN SEMI
        { $$ = newStmtNode(ReturnK); }
    | RETURN expression SEMI
        { $$ = newStmtNode(ReturnK);
          $$->child[0] = $2;
        }
    ;

expression
    : var ASSIGN expression
        { if ($1->child[0] == NULL) {       /* scalar: var = exp */
            $$ = newStmtNode(AssignK);
            $$->attr.name = $1->attr.name;
            $$->lineno = $1->lineno;
            $$->child[0] = $3;
          } else {                           /* array: var[idx] = exp */
            $$ = newStmtNode(AssignArrK);
            $$->attr.name = $1->attr.name;
            $$->lineno = $1->lineno;
            $$->child[0] = $1->child[0];     /* index */
            $$->child[1] = $3;               /* value */
          }
        }
    | simple_expression { $$ = $1; }
    ;

var
    : id
        { $$ = newExpNode(IdK);
          $$->attr.name = savedName;
          $$->lineno = savedLineNo;
        }
    | id LBRACKET
        /* Capture the array name now, before the index expression
         * (which may contain other identifiers) overwrites savedName. */
        { $$ = newExpNode(IdK);
          $$->attr.name = savedName;
          $$->lineno = savedLineNo;
        }
      expression RBRACKET
        { $$ = $3;
          $$->child[0] = $4;   /* index expression */
        }
    ;

simple_expression
    : additive_expression LT  additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = LT; }
    | additive_expression LTE additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = LTE; }
    | additive_expression GT  additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = GT; }
    | additive_expression GTE additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = GTE; }
    | additive_expression EQ  additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = EQ; }
    | additive_expression NE  additive_expression
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = NE; }
    | additive_expression { $$ = $1; }
    ;

additive_expression
    : additive_expression PLUS  term
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = PLUS; }
    | additive_expression MINUS term
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = MINUS; }
    | term { $$ = $1; }
    ;

term
    : term TIMES factor
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = TIMES; }
    | term OVER  factor
        { $$ = newExpNode(OpK); $$->child[0] = $1; $$->child[1] = $3; $$->attr.op = OVER; }
    | factor { $$ = $1; }
    ;

factor
    : LPAREN expression RPAREN { $$ = $2; }
    | var  { $$ = $1; }
    | call { $$ = $1; }
    | num  { $$ = newExpNode(ConstK); $$->attr.val = savedNumber; }
    /* Extension 3: unary minus. child[1] stays NULL, which printTree uses
     * to distinguish it from binary minus ("Op: - (unario)"). */
    | MINUS factor
        { $$ = newExpNode(OpK);
          $$->attr.op = MINUS;
          $$->child[0] = $2;
        }
    ;

call
    : id LPAREN
        /* Capture the call name now, before the arguments overwrite savedName. */
        { $$ = newExpNode(CallK);
          $$->attr.name = savedName;
          $$->lineno = savedLineNo;
        }
      args RPAREN
        { $$ = $3;
          $$->child[0] = $4;   /* argument list (chained by sibling) */
        }
    ;

args
    : arg_list { $$ = $1; }
    | /* empty */ { $$ = NULL; }
    ;

arg_list
    : arg_list COMMA expression
        { YYSTYPE t = $1;
          if (t != NULL) {
            while (t->sibling != NULL) t = t->sibling;
            t->sibling = $3;
            $$ = $1;
          } else $$ = $3;
        }
    | expression { $$ = $1; }
    ;

%%

int yyerror(char * message)
{ pce("Syntax error at line %d: %s\n", lineno, message);
  pce("Current token: ");
  printToken(yychar, tokenString);
  Error = TRUE;
  return 0;
}

/* yylex bridges Bison to the Flex scanner through getToken() */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}
