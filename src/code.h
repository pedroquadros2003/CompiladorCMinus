/****************************************************/
/* File: code.h                                     */
/* Utilitarios de emissao de codigo TM              */
/* para o compilador C-                             */
/* Adaptado de Compiler Construction: Principles    */
/* and Practice, Kenneth C. Louden                  */
/****************************************************/

#ifndef _CODE_H_
#define _CODE_H_

/* pc = numero do registrador de program counter */
#define PC  7

/* mp = topo da pilha (proximo slot livre) */
#define mp  6

/* gp = base das variaveis globais */
#define gp  5

/* fp = frame pointer */
#define fp  2

/* ac = acumulador */
#define ac  0

/* ac1 = segundo acumulador */
#define ac1 1

/* Imprime uma linha de comentario no codigo (se TraceCode) */
void emitComment(char *c);

/* Emite uma instrucao TM register-only: op r,s,t */
void emitRO(char *op, int r, int s, int t, char *c);

/* Emite uma instrucao TM register-memoria: op r,d(s) */
void emitRM(char *op, int r, int d, int s, char *c);

/* Salta howMany posicoes para backpatch; retorna a posicao atual */
int emitSkip(int howMany);

/* Volta a posicao de emissao para loc (posicao previamente saltada) */
void emitBackup(int loc);

/* Restaura a posicao de emissao para a maior posicao ja alcancada */
void emitRestore(void);

/* Emite instrucao register-memoria com endereco absoluto a (convertido para PC-relativo) */
void emitRM_Abs(char *op, int r, int a, char *c);

#endif
