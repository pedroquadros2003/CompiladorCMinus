/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Project for CES41: Compiladores                  */
/****************************************************/

%option noyywrap 
/* opção noyywrap pode ser necessária para novas versões do flex
  limitação: não compila mais de um arquivo fonte de uma só vez (não precisamos disso)
  https://stackoverflow.com/questions/1480138/undefined-reference-to-yylex 
*/ 

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}
digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \r?\n
whitespace  [ \t\r]+
%%

  /* reserved words */
"if"            {return IF;}
"else"          {return ELSE;}
"int"           {return INT;}
"return"        {return RETURN;}
"void"          {return VOID;}
"while"         {return WHILE;}

  /* arithmetic symbols */
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}

  /* relational symbols */
"<"             {return LT;}
"<="            {return LTE;}
">"             {return GT;}
">="            {return GTE;}
"=="            {return EQ;}
"!="            {return NE;}

  /* attribution symbol */
"="             {return ASSIGN;}

  /* punctuation symbols */
","             {return COMMA;}
";"             {return SEMI;}

  /* delimitationg symbols */
"["             {return LBRACKET;}
"]"             {return RBRACKET;}
"{"             {return LBRACE;}
"}"             {return RBRACE;}
"("             {return LPAREN;}
")"             {return RPAREN;}

  /* multicharacter tokens */
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++; printLine(redundant_source);}
{whitespace}    {/* skip whitespace */}

"/*"             { char c;
                   int count_final_characters=0;
                  do
                  { c = input();
                    if (c == 'EOF') break;
                    else if (c == '\n') {lineno++; printLine(redundant_source);} 
                    else if (count_final_characters==0 && c == '*' ) count_final_characters=1;
                    else if (count_final_characters==1 && c == '/' ) count_final_characters=2;
                    else count_final_characters = 0;
                  } while (count_final_characters != 2);
                }
.               {return ERROR;}



%%
TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
    printLine(redundant_source);
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    pc("\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}
