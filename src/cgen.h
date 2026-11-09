/****************************************************/
/* File: cgen.h                                     */
/* Interface do gerador de codigo TM                */
/* para o compilador C-                             */
/* Adaptado de Compiler Construction: Principles    */
/* and Practice, Kenneth C. Louden                  */
/****************************************************/

#ifndef _CGEN_H_
#define _CGEN_H_

#include "globals.h"

/* Gera o codigo TM da arvore sintatica no arquivo _gen.tm */
void codeGen(TreeNode *syntaxTree);

#endif
