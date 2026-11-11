/****************************************************/
/* File: cgen.c                                     */
/* Gerador de codigo TM para o compilador C-        */
/* Adaptado de Compiler Construction: Principles    */
/* and Practice, Kenneth C. Louden                  */
/****************************************************/

/* Convencoes (as mesmas do codigo de referencia do curso):
 *
 * Registradores: 0 AC, 1 AC1, 2 FP, 3 copia do FP ao subir escopos,
 *   4 valor a armazenar, 5 base dos globais (sempre 0), 6 MP (aponta
 *   para o ultimo slot ocupado da pilha), 7 PC.
 *
 * Globais: a partir do endereco 0. Um vetor de tamanho n ocupa n+1
 *   posicoes: o slot ponteiro P (que guarda o proprio endereco) e os
 *   elementos P-1 ... P-n. Elemento i fica em base - i - 1.
 *
 * Registro de ativacao de funcao (relativo a FP):
 *    0      FP do chamador
 *   -1      endereco de retorno
 *   -2 ...  parametros (vetor: endereco do slot ponteiro), depois locais
 *
 * Cada bloco entre chaves (bloco aninhado ou corpo de if/else/while
 * escrito com chaves) abre um registro proprio: 0 = FP de fora e os
 * locais a partir de -1. Uma variavel declarada k registros acima e
 * acessada subindo k vezes pela cadeia de FPs; durante a avaliacao
 * dos argumentos de uma chamada o FP ja aponta para o registro novo,
 * o que conta como mais um nivel.
 */

#include "cgen.h"
#include "code.h"
#include "globals.h"

#define fpsave 3 /* copia do FP durante a subida de escopos */
#define valreg 4 /* valor a armazenar numa atribuicao */

#define STR_VARIAVEL "vari\xc3\xa1vel"

typedef enum { SymVar, SymArray } SymKind;

typedef struct SymRec {
  char *name;
  SymKind kind;
  int level; /* 0 = global, 1 = funcao, 2+ = blocos aninhados */
  int loc;   /* deslocamento (relativo a FP ou a gp) */
  struct SymRec *next;
} Sym;

typedef struct FunRec {
  char *name;
  int entry;
  struct FunRec *next;
} Fun;

/* Chamada a uma funcao definida mais adiante: salto a corrigir */
typedef struct FixRec {
  char *name;
  int loc;
  struct FixRec *next;
} Fix;

static Sym *symbols = NULL; /* pilha de simbolos visiveis */
static Fun *functions = NULL;
static Fix *fixups = NULL;

static int level = 0;      /* nivel do registro corrente */
static int callDepth = 0;  /* chamadas com argumentos em avaliacao */
static int nextOffset = 0; /* proximo deslocamento livre no registro */
static int globalNext = 0; /* proximo endereco livre dos globais */
static int inMain = FALSE;
static int mainJump = 0;

static void genExp(TreeNode *t);
static void genStmtList(TreeNode *t);

/********** Utilitarios **********/

static void *xmalloc(size_t size) {
  void *p = malloc(size);
  if (p == NULL) {
    pce("Out of memory error during code generation\n");
    exit(1);
  }
  return p;
}

static void declare(char *name, SymKind kind, int loc) {
  Sym *s = xmalloc(sizeof(Sym));
  s->name = name;
  s->kind = kind;
  s->level = level;
  s->loc = loc;
  s->next = symbols;
  symbols = s;
}

static Sym *lookup(char *name) {
  Sym *s;
  for (s = symbols; s != NULL; s = s->next)
    if (strcmp(s->name, name) == 0)
      return s;
  pce("Code generation error: '%s' not found\n", name);
  exit(1);
}

/* Descarta os simbolos declarados depois de mark */
static void popScope(Sym *mark) {
  while (symbols != mark) {
    Sym *s = symbols;
    symbols = s->next;
    free(s);
  }
}

static Fun *findFunction(char *name) {
  Fun *f;
  for (f = functions; f != NULL; f = f->next)
    if (strcmp(f->name, name) == 0)
      return f;
  return NULL;
}

static int isGlobal(Sym *s) { return s->level == 0; }
static int baseReg(Sym *s) { return isGlobal(s) ? gp : fp; }

/* Quantos registros subir para alcancar o de s */
static int walkCount(Sym *s) { return level - s->level + callDepth; }

static void walkUp(int n) {
  int i;
  if (n <= 0)
    return;
  emitRM("LDA", fpsave, 0, fp, "Salvando FP em R3");
  for (i = 0; i < n; i++)
    emitRM("LD", fp, 0, fp, "Voltando um escopo na pilha de execucao");
}

static void walkBack(int n) {
  if (n > 0)
    emitRM("LDA", fp, 0, fpsave, "Restaurando FP");
}

/********** Expressoes **********/

static void genConst(TreeNode *t) {
  emitComment("-> Constante");
  emitRM("LDC", ac, t->attr.val, 0, "Salvando constante em AC");
  emitComment("<- Constante");
}

/* Calcula em AC o endereco de s[index] */
static void genElemAddr(Sym *s, TreeNode *index) {
  genExp(index);
  emitComment("                      AC tem o index");
  if (isGlobal(s)) {
    emitRM("LD", ac1, s->loc, gp, "AC1 = endereco base do array (global)");
  } else {
    int n = walkCount(s);
    walkUp(n);
    emitRM("LD", ac1, s->loc, fp, "AC1 = endereco base do array");
    walkBack(n);
  }
  emitRO("SUB", ac, ac1, ac, "AC tem o endereco - 1");
  emitRM("LDC", ac1, 1, 0, "load 1 em AC1");
  emitRO("SUB", ac, ac, ac1, "AC tem o endereco");
}

static void genId(TreeNode *t) {
  Sym *s = lookup(t->attr.name);
  emitComment("-> Id");
  if (t->child[0] != NULL) {
    genElemAddr(s, t->child[0]);
    emitRM("LD", ac, 0, ac, "Obter o valor do elemento do array em AC");
  } else {
    /* escalar, ou vetor inteiro (endereco guardado no slot ponteiro) */
    int n = walkCount(s);
    walkUp(n);
    emitRM("LD", ac, s->loc, baseReg(s), "Carregar valor de ID em AC");
    walkBack(n);
  }
  emitComment("<- Id");
}

static char *opSymbol(TokenType op) {
  switch (op) {
  case PLUS:  return "+";
  case MINUS: return "-";
  case TIMES: return "*";
  case OVER:  return "/";
  case LT:    return "<";
  case LTE:   return "<=";
  case GT:    return ">";
  case GTE:   return ">=";
  case EQ:    return "==";
  case NE:    return "!=";
  default:    return "?";
  }
}

static void genRelational(char *jump, char *comment) {
  emitRO("SUB", ac, ac1, ac, comment);
  emitRM(jump, ac, 2, PC, "Se verdadeiro PC pula 2");
  emitRM("LDC", ac, 0, 0, "Se falso, coloca 0 em AC");
  emitRM("LDA", PC, 1, PC, "PC pula para o fim");
  emitRM("LDC", ac, 1, 0, "Se verdadeiro, coloca 1 em AC");
}

static void genOp(TreeNode *t) {
  char comment[32];

  emitComment("-> Op");
  if (t->child[1] == NULL) { /* menos unario: AC = 0 - AC */
    genExp(t->child[0]);
    emitRO("SUB", ac, gp, ac, "unario: AC = -AC");
    emitComment("<- Calc (Unary)");
    return;
  }
  genExp(t->child[0]);
  emitRM("LDA", mp, -1, mp, "Espaco para salvar a esquerda");
  emitRM("ST", ac, 0, mp, "Armazenando valor da " STR_VARIAVEL);
  genExp(t->child[1]);
  emitComment("                      Direita da operacao em AC");
  emitRM("LD", ac1, 0, mp, "Esquerda da operacao em AC1");
  emitRM("LDA", mp, 1, mp, "Livrar o espaco usado");
  snprintf(comment, sizeof comment, "op %s", opSymbol(t->attr.op));
  switch (t->attr.op) {
  case PLUS:  emitRO("ADD", ac, ac1, ac, comment); break;
  case MINUS: emitRO("SUB", ac, ac1, ac, comment); break;
  case TIMES: emitRO("MUL", ac, ac1, ac, comment); break;
  case OVER:  emitRO("DIV", ac, ac1, ac, comment); break;
  case LT:    genRelational("JLT", comment); break;
  case LTE:   genRelational("JLE", comment); break;
  case GT:    genRelational("JGT", comment); break;
  case GTE:   genRelational("JGE", comment); break;
  case EQ:    genRelational("JEQ", comment); break;
  case NE:    genRelational("JNE", comment); break;
  default:    break;
  }
  emitComment("<- Op");
}

/* Nome do argumento usado no comentario da passagem de parametro */
static void argName(TreeNode *arg, char *buf, size_t size) {
  if (arg->nodekind == ExpK) {
    switch (arg->kind.exp) {
    case ConstK:
      snprintf(buf, size, "%d", arg->attr.val);
      return;
    case OpK:
      if (arg->child[1] == NULL)
        snprintf(buf, size, "- (unario)");
      else
        snprintf(buf, size, "%s", opSymbol(arg->attr.op));
      return;
    default:
      break;
    }
  }
  snprintf(buf, size, "%s", arg->attr.name);
}

static void genCall(TreeNode *t) {
  TreeNode *arg;
  Fun *f;
  char comment[256];

  if (strcmp(t->attr.name, "input") == 0) {
    emitComment("-> Call input");
    emitRO("IN", ac, 0, 0, "Lendo valor para AC");
    emitComment("<- Call input");
    return;
  }
  if (strcmp(t->attr.name, "output") == 0) {
    emitComment("-> Call output");
    genExp(t->child[0]);
    emitRO("OUT", ac, 0, 0, "Escrevendo valor de AC");
    emitComment("<- Call output");
    return;
  }

  snprintf(comment, sizeof comment, "-> Chamando a funcao (%s)", t->attr.name);
  emitComment(comment);
  emitRM("LDA", mp, -1, mp, "Posicao do novo FP");
  emitRM("ST", fp, 0, mp, "Salvar FP antigo");
  emitRM("LDA", fp, 0, mp, "FP atualizado");
  emitRM("LDA", mp, -1, mp, "Posicao do endereco de retorno");
  callDepth++;
  for (arg = t->child[0]; arg != NULL; arg = arg->sibling) {
    char name[128];
    genExp(arg);
    emitComment("-> Argumento da funcao");
    emitRM("LDA", mp, -1, mp, "Mover para proximo slot de parametro");
    argName(arg, name, sizeof name);
    snprintf(comment, sizeof comment, "Salvar parametro (%s) que esta em AC",
             name);
    emitRM("ST", ac, 0, mp, comment);
    emitComment("<- Argumento da funcao");
  }
  callDepth--;
  emitRM("ST", PC, -1, fp, "Guarda endereco de retorno");
  f = findFunction(t->attr.name);
  if (f != NULL) {
    emitRM_Abs("LDA", PC, f->entry, "Pular para a funcao");
  } else { /* funcao definida mais adiante */
    Fix *x = xmalloc(sizeof(Fix));
    x->name = t->attr.name;
    x->loc = emitSkip(1);
    x->next = fixups;
    fixups = x;
  }
  emitComment("<- Call");
}

/********** Comandos **********/

/* TRUE se avaliar t pode alterar R4 (chamada de funcao ou atribuicao) */
static int clobbersR4(TreeNode *t) {
  int i;
  for (; t != NULL; t = t->sibling) {
    if (t->nodekind == StmtK)
      return TRUE;
    if (t->kind.exp == CallK && strcmp(t->attr.name, "input") != 0 &&
        strcmp(t->attr.name, "output") != 0)
      return TRUE;
    for (i = 0; i < MAXCHILDREN; i++)
      if (clobbersR4(t->child[i]))
        return TRUE;
  }
  return FALSE;
}

static void genAssign(TreeNode *t) {
  Sym *s = lookup(t->attr.name);

  if (t->kind.stmt == AssignK) {
    int n;
    genExp(t->child[0]);
    emitRM("LDA", valreg, 0, ac, "Copia o valor de AC para R4");
    emitComment("-> Atribuicao");
    n = walkCount(s);
    walkUp(n);
    if (isGlobal(s))
      emitRM("ST", valreg, s->loc, gp,
             "Armazenando valor na " STR_VARIAVEL " (global)");
    else
      emitRM("ST", valreg, s->loc, fp, "Armazenando valor na " STR_VARIAVEL);
    walkBack(n);
    emitComment("<- Atribuicao");
  } else { /* AssignArrK: child[0] = indice, child[1] = valor */
    int save = clobbersR4(t->child[0]);
    genExp(t->child[1]);
    emitRM("LDA", valreg, 0, ac, "Copia o valor de AC para R4");
    emitComment("-> Atribuicao");
    if (save) {
      emitRM("LDA", mp, -1, mp, "Espaco para salvar R4");
      emitRM("ST", valreg, 0, mp, "Salvando R4");
    }
    genElemAddr(s, t->child[0]);
    if (save) {
      emitRM("LD", valreg, 0, mp, "Restaurando R4");
      emitRM("LDA", mp, 1, mp, "Livrar o espaco usado");
    }
    emitRM("ST", valreg, 0, ac, "Colocando R4 no endereco do array");
    emitComment("<- Atribuicao");
  }
}

static void genReturnSeq(void) {
  emitRM("LDA", ac1, 0, fp, "Salvar FP em AC1");
  emitRM("LD", fp, 0, fp, "FP volta para o escopo pai");
  emitRM("LDA", mp, 1, ac1, "MP volta ao topo do frame anterior");
  emitRM("LD", ac1, -1, ac1, "AC1 tem o endereco de retorno - 1");
  emitRM("LDA", PC, 1, ac1, "Retorna para onde foi chamado");
}

static void genReturn(TreeNode *t) {
  emitComment("-> Return");
  if (t->child[0] != NULL)
    genExp(t->child[0]);
  if (inMain) {
    emitRO("HALT", 0, 0, 0, "return em main: fim da execucao");
  } else {
    int i;
    /* sai dos blocos abertos antes de deixar a funcao */
    for (i = level; i > 1; i--)
      emitRM("LD", fp, 0, fp, "FP volta para o escopo pai (fim do bloco)");
    genReturnSeq();
  }
  emitComment("<- Return");
}

/* Abre um registro de bloco, gera a lista e o fecha */
static void genBlock(TreeNode *list) {
  Sym *mark = symbols;
  int savedOffset = nextOffset;

  emitComment("-> Novo Bloco");
  emitRM("LDA", mp, -1, mp, "Posicao do novo FP");
  emitRM("ST", fp, 0, mp, "Salvar FP antigo");
  emitRM("LDA", fp, 0, mp, "FP atualizado");
  level++;
  nextOffset = -1;
  genStmtList(list);
  level--;
  nextOffset = savedOffset;
  popScope(mark);
  emitRM("LDA", mp, 1, fp, "Atualizando MP para o frame anterior");
  emitRM("LD", fp, 0, fp, "FP volta para o escopo pai (fim do bloco)");
  emitComment("<- Fim de Bloco");
}

static int isEmptyBlock(TreeNode *t) {
  return t != NULL && t->nodekind == StmtK && t->kind.stmt == BlockK &&
         t->child[0] == NULL && t->sibling == NULL;
}

/* Corpo de if/else/while: com chaves abre um bloco */
static void genBody(TreeNode *t) {
  if (t == NULL || isEmptyBlock(t))
    return;
  if (t->braced)
    genBlock(t);
  else
    genStmtList(t);
}

static void genIf(TreeNode *t) {
  int jumpElse, jumpEnd, here;

  emitComment("-> If");
  genExp(t->child[0]);
  jumpElse = emitSkip(1);
  emitComment("THEN branch");
  genBody(t->child[1]);
  if (t->child[2] != NULL) {
    jumpEnd = emitSkip(1);
    emitComment("ELSE branch");
    here = emitSkip(0);
    emitBackup(jumpElse);
    emitRM_Abs("JEQ", ac, here, "Se AC == 0, pular para else/end");
    emitRestore();
    genBody(t->child[2]);
    here = emitSkip(0);
    emitBackup(jumpEnd);
    emitRM_Abs("LDA", PC, here, "jmp to end");
    emitRestore();
  } else {
    here = emitSkip(0);
    emitBackup(jumpElse);
    emitRM_Abs("JEQ", ac, here, "Se AC == 0, pular para else/end");
    emitRestore();
  }
  emitComment("<- If");
}

static void genWhile(TreeNode *t) {
  int top, jumpEnd, here;

  emitComment("-> while");
  emitComment("Verificando condicao do while");
  top = emitSkip(0);
  genExp(t->child[0]);
  jumpEnd = emitSkip(1);
  genBody(t->child[1]);
  emitRM_Abs("LDA", PC, top, "Voltando para checar a condicao do while");
  here = emitSkip(0);
  emitBackup(jumpEnd);
  emitRM_Abs("JEQ", ac, here,
             "Fim do while, se AC = 1 volta para o while, se AC = 0 continua");
  emitRestore();
  emitComment("<- while");
}

static void genLocalDecl(TreeNode *t) {
  if (t->kind.stmt == VarDeclK) {
    emitComment("-> Declarando variavel");
    emitRM("LDA", mp, -1, mp, "Deixando MP no final do frame");
    emitComment("<- Declarando variavel");
    declare(t->attr.name, SymVar, nextOffset--);
  } else {
    int size = t->child[0]->attr.val;
    int k = nextOffset;
    emitComment("-> Declarando vetor");
    emitRM("LDA", ac, k, fp, "Colocando endereco do vetor em AC");
    emitRM("ST", ac, k, fp,
           "salvando endereco do vetor no primeiro slot do vetor");
    emitRM("LDA", mp, k - size, fp, "Deixando MP no final do frame");
    emitComment("<- Declarando vetor");
    declare(t->attr.name, SymArray, k);
    nextOffset -= size + 1;
  }
}

static void genGlobalDecl(TreeNode *t) {
  if (t->kind.stmt == VarDeclK) {
    emitComment("-> Declarando variavel global");
    declare(t->attr.name, SymVar, globalNext++);
    emitComment("<- Declarando variavel global");
  } else {
    int size = t->child[0]->attr.val;
    int p = globalNext + size + 1;
    emitComment("-> Declarando vetor");
    emitRM("LDA", ac, p, gp, "Colocando endereco do vetor em AC");
    emitRM("ST", ac, p, gp,
           "salvando endereco do vetor no primeiro slot do vetor");
    emitComment("<- Declarando vetor");
    declare(t->attr.name, SymArray, p);
    globalNext = p + 1;
  }
}

static void genStmt(TreeNode *t) {
  if (t->nodekind == ExpK) { /* comando-expressao, ex.: f(x); */
    genExp(t);
    return;
  }
  switch (t->kind.stmt) {
  case VarDeclK:
  case VarDeclArrK:
    genLocalDecl(t);
    break;
  case AssignK:
  case AssignArrK:
    genAssign(t);
    break;
  case ReturnK:
    genReturn(t);
    break;
  case IfK:
    genIf(t);
    break;
  case WhileK:
    genWhile(t);
    break;
  case BlockK:
    if (t->child[0] != NULL)
      genBlock(t->child[0]);
    break;
  default:
    break;
  }
}

static void genStmtList(TreeNode *t) {
  for (; t != NULL; t = t->sibling)
    genStmt(t);
}

static void genExp(TreeNode *t) {
  if (t == NULL)
    return;
  if (t->nodekind == StmtK) { /* atribuicao usada como expressao */
    genAssign(t);
    if (t->kind.stmt == AssignArrK)
      emitRM("LDA", ac, 0, valreg, "Valor atribuido em AC");
    return;
  }
  switch (t->kind.exp) {
  case ConstK: genConst(t); break;
  case IdK:    genId(t); break;
  case OpK:    genOp(t); break;
  case CallK:  genCall(t); break;
  default:     break;
  }
}

/* TRUE se a lista sempre executa um return */
static int listReturns(TreeNode *t) {
  for (; t != NULL; t = t->sibling) {
    if (t->nodekind != StmtK)
      continue;
    switch (t->kind.stmt) {
    case ReturnK:
      return TRUE;
    case IfK:
      if (t->child[2] != NULL && listReturns(t->child[1]) &&
          listReturns(t->child[2]))
        return TRUE;
      break;
    case BlockK:
      if (listReturns(t->child[0]))
        return TRUE;
      break;
    default:
      break;
    }
  }
  return FALSE;
}

static void genFunction(TreeNode *t) {
  char comment[256];
  Fun *f;
  Fix **px;
  TreeNode *p;
  Sym *mark = symbols;

  inMain = strcmp(t->attr.name, "main") == 0;
  if (inMain) {
    int here = emitSkip(0);
    emitBackup(mainJump);
    emitRM_Abs("LDA", PC, here, "Pular para a main");
    emitRestore();
  }
  snprintf(comment, sizeof comment, "-> FUNCAO (%s)", t->attr.name);
  emitComment(comment);

  f = xmalloc(sizeof(Fun));
  f->name = t->attr.name;
  f->entry = emitSkip(0);
  f->next = functions;
  functions = f;

  /* corrige as chamadas feitas antes desta definicao */
  px = &fixups;
  while (*px != NULL) {
    Fix *x = *px;
    if (strcmp(x->name, f->name) == 0) {
      emitBackup(x->loc);
      emitRM_Abs("LDA", PC, f->entry, "Pular para a funcao");
      emitRestore();
      *px = x->next;
      free(x);
    } else {
      px = &x->next;
    }
  }

  level = 1;
  nextOffset = -2;
  for (p = t->child[0]; p != NULL; p = p->sibling)
    declare(p->attr.name, p->kind.stmt == ParamArrK ? SymArray : SymVar,
            nextOffset--);

  if (inMain)
    emitRM("LDA", mp, -1, mp, "Posicao do endereco de retorno");

  if (!isEmptyBlock(t->child[1]))
    genStmtList(t->child[1]);

  if (inMain) {
    emitComment("FIM DA EXECUCAO");
    emitRO("HALT", 0, 0, 0, "");
  } else if (t->type == Void || !listReturns(t->child[1])) {
    emitComment("-> Return");
    genReturnSeq();
    emitComment("<- Return");
  }
  emitComment("<- Function exit");

  popScope(mark);
  level = 0;
  inMain = FALSE;
}

void codeGen(TreeNode *syntaxTree) {
  TreeNode *t;

  emitComment("GERACAO CODIGO ASSEMBLY TM");
  emitComment("A posicao 0 comeca com o maxaddress");
  emitRM("LD", mp, 0, ac, "Salvar o maxaddress em MP");
  emitRM("LD", fp, 0, ac, "Salvar o maxaddress em FP");
  emitRM("ST", ac, 0, ac, "Limpar a posicao 0");
  emitComment("INICIO DA EXECUCAO");

  /* os globais sao alocados antes de qualquer funcao */
  for (t = syntaxTree; t != NULL; t = t->sibling)
    if (t->nodekind == StmtK &&
        (t->kind.stmt == VarDeclK || t->kind.stmt == VarDeclArrK))
      genGlobalDecl(t);

  mainJump = emitSkip(1);

  for (t = syntaxTree; t != NULL; t = t->sibling)
    if (t->nodekind == StmtK && t->kind.stmt == FunctionK)
      genFunction(t);
}
