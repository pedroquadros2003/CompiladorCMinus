/****************************************************/
/* File: cgen.c                                     */
/* Gerador de codigo TM para o compilador C-        */
/* Adaptado de Compiler Construction: Principles    */
/* and Practice, Kenneth C. Louden                  */
/****************************************************/

/* Organizacao da memoria de dados:
 *
 *   globais: gp+0, gp+1, ...  (gp = 0)
 *   pilha:   cresce para baixo a partir do maxaddress;
 *            mp aponta para o proximo slot livre.
 *
 * Registro de ativacao (relativo a fp):
 *    0       fp do chamador
 *   -1       endereco de retorno
 *   -2 ...   parametros (vetor: endereco absoluto do 1o elemento)
 *   abaixo   locais de todos os blocos da funcao
 *
 * Os blocos aninhados nao criam registro proprio: cada declaracao
 * recebe um deslocamento fixo no frame da funcao, e blocos irmaos
 * reaproveitam o mesmo espaco.
 */

#include "cgen.h"
#include "code.h"
#include "globals.h"

typedef enum { SymVar, SymArray, SymArrayParam, SymFunc } SymKind;

typedef struct SymRec {
  char *name;
  SymKind kind;
  int isGlobal;
  int loc; /* deslocamento na memoria ou endereco de entrada da funcao */
  struct SymRec *next;
} Sym;

/* Pilha de simbolos visiveis; o topo e o escopo mais interno */
static Sym *symbols = NULL;

static int inFunction = FALSE;
static int globalOffset = 0; /* proxima posicao livre dos globais */
static int localOffset;      /* proxima posicao livre no frame */
static int frameBottom;      /* menor localOffset alcancado na funcao */

static char comment[256];

static void cGen(TreeNode *t);
static void genNode(TreeNode *t);

/********** Tabela de simbolos da geracao **********/

static Sym *symInsert(char *name, SymKind kind, int loc) {
  Sym *s = malloc(sizeof(Sym));
  if (s == NULL) {
    pce("Out of memory error during code generation\n");
    exit(1);
  }
  s->name = name;
  s->kind = kind;
  s->isGlobal = !inFunction;
  s->loc = loc;
  s->next = symbols;
  symbols = s;
  return s;
}

static Sym *symLookup(char *name) {
  Sym *s;
  for (s = symbols; s != NULL; s = s->next)
    if (strcmp(s->name, name) == 0)
      return s;
  pce("Code generation error: '%s' not found\n", name);
  exit(1);
}

/* Fecha um escopo: descarta os simbolos acima de mark e
 * libera o espaco que eles ocupavam no frame */
static void scopeClose(Sym *mark, int savedOffset) {
  while (symbols != mark) {
    Sym *s = symbols;
    symbols = s->next;
    free(s);
  }
  localOffset = savedOffset;
}

/* Reserva size posicoes e devolve o endereco da mais baixa */
static int allocate(int size) {
  if (!inFunction) {
    int loc = globalOffset;
    globalOffset += size;
    return loc;
  }
  localOffset -= size;
  if (localOffset < frameBottom)
    frameBottom = localOffset;
  return localOffset + 1;
}

static int baseReg(Sym *s) { return s->isGlobal ? gp : fp; }

/********** Pilha de temporarios **********/

static void push(int reg) {
  emitRM("ST", reg, 0, mp, "push");
  emitRM("LDA", mp, -1, mp, "");
}

static void pop(int reg) {
  emitRM("LDA", mp, 1, mp, "pop");
  emitRM("LD", reg, 0, mp, "");
}

/********** Expressoes **********/

/* Coloca em reg o endereco do primeiro elemento do vetor s */
static void genArrayBase(Sym *s, int reg) {
  if (s->kind == SymArrayParam)
    emitRM("LD", reg, s->loc, fp, "endereco do vetor (parametro)");
  else
    emitRM("LDA", reg, s->loc, baseReg(s), "endereco do vetor");
}

/* Coloca em ac o endereco de s[index] */
static void genElementAddress(Sym *s, TreeNode *index) {
  cGen(index);
  genArrayBase(s, ac1);
  emitRO("ADD", ac, ac1, ac, "endereco do elemento");
}

static void genId(TreeNode *t) {
  Sym *s = symLookup(t->attr.name);
  if (t->child[0] != NULL) {
    genElementAddress(s, t->child[0]);
    emitRM("LD", ac, 0, ac, "carrega elemento do vetor");
  } else if (s->kind == SymVar) {
    snprintf(comment, sizeof comment, "carrega %s", s->name);
    emitRM("LD", ac, s->loc, baseReg(s), comment);
  } else {
    genArrayBase(s, ac);
  }
}

static void genRelational(char *jump) {
  emitRO("SUB", ac, ac1, ac, "compara");
  emitRM(jump, ac, 2, PC, "verdadeiro: pula para LDC 1");
  emitRM("LDC", ac, 0, 0, "falso");
  emitRM("LDA", PC, 1, PC, "pula o caso verdadeiro");
  emitRM("LDC", ac, 1, 0, "verdadeiro");
}

static void genOp(TreeNode *t) {
  if (t->child[1] == NULL) {
    cGen(t->child[0]);
    emitRM("LDC", ac1, 0, 0, "menos unario");
    emitRO("SUB", ac, ac1, ac, "ac = -ac");
    return;
  }
  cGen(t->child[0]);
  push(ac);
  cGen(t->child[1]);
  pop(ac1);
  switch (t->attr.op) {
  case PLUS:  emitRO("ADD", ac, ac1, ac, "op +"); break;
  case MINUS: emitRO("SUB", ac, ac1, ac, "op -"); break;
  case TIMES: emitRO("MUL", ac, ac1, ac, "op *"); break;
  case OVER:  emitRO("DIV", ac, ac1, ac, "op /"); break;
  case LT:    genRelational("JLT"); break;
  case LTE:   genRelational("JLE"); break;
  case GT:    genRelational("JGT"); break;
  case GTE:   genRelational("JGE"); break;
  case EQ:    genRelational("JEQ"); break;
  case NE:    genRelational("JNE"); break;
  default:    emitComment("operador desconhecido"); break;
  }
}

static void genCall(TreeNode *t) {
  TreeNode *arg;
  Sym *s;
  int nargs = 0;

  if (strcmp(t->attr.name, "input") == 0) {
    emitRO("IN", ac, 0, 0, "input");
    return;
  }
  if (strcmp(t->attr.name, "output") == 0) {
    cGen(t->child[0]);
    emitRO("OUT", ac, 0, 0, "output");
    return;
  }

  s = symLookup(t->attr.name);
  snprintf(comment, sizeof comment, "-> chamada %s", s->name);
  emitComment(comment);
  emitRM("ST", fp, 0, mp, "salva fp do chamador");
  emitRM("LDA", mp, -2, mp, "reserva fp antigo e retorno");
  for (arg = t->child[0]; arg != NULL; arg = arg->sibling) {
    cGen(arg);
    push(ac);
    nargs++;
  }
  emitRM("LDA", fp, 2 + nargs, mp, "fp do novo frame");
  emitRM("LDA", ac, 2, PC, "endereco de retorno");
  emitRM("ST", ac, -1, fp, "salva endereco de retorno");
  emitRM("LDC", PC, s->loc, 0, "salta para a funcao");
  snprintf(comment, sizeof comment, "<- chamada %s", s->name);
  emitComment(comment);
}

/********** Comandos **********/

static void genAssign(TreeNode *t) {
  Sym *s = symLookup(t->attr.name);
  snprintf(comment, sizeof comment, "atribuicao a %s", s->name);
  if (t->kind.stmt == AssignK) {
    cGen(t->child[0]);
    emitRM("ST", ac, s->loc, baseReg(s), comment);
  } else {
    genElementAddress(s, t->child[0]);
    push(ac);
    cGen(t->child[1]);
    pop(ac1);
    emitRM("ST", ac, 0, ac1, comment);
  }
}

/* Retorno: o valor (se houver) ja esta em ac */
static void genReturn(void) {
  emitRM("LDA", mp, 0, fp, "desempilha o frame");
  emitRM("LD", ac1, -1, fp, "endereco de retorno");
  emitRM("LD", fp, 0, fp, "restaura fp do chamador");
  emitRM("LDA", PC, 0, ac1, "retorna");
}

static void genIf(TreeNode *t) {
  int jumpElse, jumpEnd = 0, here;
  emitComment("-> if");
  cGen(t->child[0]);
  jumpElse = emitSkip(1);
  genNode(t->child[1]);
  if (t->child[2] != NULL)
    jumpEnd = emitSkip(1);
  here = emitSkip(0);
  emitBackup(jumpElse);
  emitRM_Abs("JEQ", ac, here, "falso: pula o bloco do if");
  emitRestore();
  if (t->child[2] != NULL) {
    genNode(t->child[2]);
    here = emitSkip(0);
    emitBackup(jumpEnd);
    emitRM_Abs("LDA", PC, here, "pula o else");
    emitRestore();
  }
  emitComment("<- if");
}

static void genWhile(TreeNode *t) {
  int top, jumpEnd, here;
  emitComment("-> while");
  top = emitSkip(0);
  cGen(t->child[0]);
  jumpEnd = emitSkip(1);
  genNode(t->child[1]);
  emitRM_Abs("LDA", PC, top, "volta ao teste");
  here = emitSkip(0);
  emitBackup(jumpEnd);
  emitRM_Abs("JEQ", ac, here, "falso: sai do while");
  emitRestore();
  emitComment("<- while");
}

static void genFunction(TreeNode *t) {
  TreeNode *p;
  Sym *mark;
  int prologue;

  snprintf(comment, sizeof comment, "-> funcao %s", t->attr.name);
  emitComment(comment);
  symInsert(t->attr.name, SymFunc, emitSkip(0));

  inFunction = TRUE;
  mark = symbols;
  localOffset = -2;
  for (p = t->child[0]; p != NULL; p = p->sibling)
    symInsert(p->attr.name,
              p->kind.stmt == ParamArrK ? SymArrayParam : SymVar,
              localOffset--);
  frameBottom = localOffset;

  prologue = emitSkip(1);
  genNode(t->child[1]);
  genReturn();

  emitBackup(prologue);
  emitRM("LDA", mp, frameBottom, fp, "reserva as variaveis locais");
  emitRestore();

  scopeClose(mark, localOffset);
  inFunction = FALSE;
  snprintf(comment, sizeof comment, "<- funcao %s", t->attr.name);
  emitComment(comment);
}

/* Gera um unico no (sem seguir os irmaos) */
static void cGen(TreeNode *t) {
  Sym *mark = symbols;
  int savedOffset = localOffset;

  if (t == NULL)
    return;
  if (t->nodekind == ExpK) {
    switch (t->kind.exp) {
    case ConstK: emitRM("LDC", ac, t->attr.val, 0, "constante"); break;
    case IdK:    genId(t); break;
    case OpK:    genOp(t); break;
    case CallK:  genCall(t); break;
    default:     break;
    }
    return;
  }
  switch (t->kind.stmt) {
  case FunctionK:
    genFunction(t);
    return;
  case VarDeclK:
    symInsert(t->attr.name, SymVar, allocate(1));
    return;
  case VarDeclArrK:
    symInsert(t->attr.name, SymArray, allocate(t->child[0]->attr.val));
    return;
  case AssignK:
  case AssignArrK:
    genAssign(t);
    return;
  case ReturnK:
    cGen(t->child[0]);
    genReturn();
    return;
  /* if, while e blocos abrem escopo, como na analise semantica */
  case IfK:    genIf(t); break;
  case WhileK: genWhile(t); break;
  case BlockK: genNode(t->child[0]); break;
  default:     return;
  }
  scopeClose(mark, savedOffset);
}

/* Gera um no e todos os seus irmaos */
static void genNode(TreeNode *t) {
  for (; t != NULL; t = t->sibling)
    cGen(t);
}

void codeGen(TreeNode *syntaxTree) {
  int callMain;
  Sym *mainSym;

  emitComment("Compilacao C- para TM");
  emitComment("Preludio");
  emitRM("LD", mp, 0, ac, "mp = maxaddress");
  emitRM("LDA", fp, 0, mp, "fp = maxaddress");
  emitRM("ST", ac, 0, ac, "limpa a posicao 0");

  emitComment("Chamada de main");
  emitRM("ST", fp, 0, mp, "salva fp");
  emitRM("LDA", mp, -2, mp, "reserva fp antigo e retorno");
  emitRM("LDA", fp, 2, mp, "fp do frame de main");
  emitRM("LDA", ac, 2, PC, "endereco de retorno");
  emitRM("ST", ac, -1, fp, "salva endereco de retorno");
  callMain = emitSkip(1);
  emitRO("HALT", 0, 0, 0, "fim do programa");

  genNode(syntaxTree);

  mainSym = symLookup("main");
  emitBackup(callMain);
  emitRM("LDC", PC, mainSym->loc, 0, "salta para main");
  emitRestore();
  emitComment("Fim do codigo");
}
