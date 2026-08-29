/****************************************************/
/* File: main.c                                     */
/* Main program for TINY compiler                   */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"

/* set NO_PARSE to TRUE to get a scanner-only compiler */
#define NO_PARSE TRUE
/* set NO_ANALYZE to TRUE to get a parser-only compiler */
#define NO_ANALYZE FALSE

/* set NO_CODE to TRUE to get a compiler that does not
 * generate code
 */
#define NO_CODE FALSE

#include "util.h"
#if NO_PARSE
#include "scan.h"
#else
#include "parse.h"
#if !NO_ANALYZE
#include "analyze.h"
#if !NO_CODE
#include "cgen.h"
#endif
#endif
#endif

/* allocate global variables */
int lineno = 0;
FILE * source;
FILE * listing;
FILE * code;

/* allocate and set tracing flags */
int EchoSource = TRUE;
int TraceScan = TRUE;
int TraceParse = FALSE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

int main( int argc, char * argv[] )
{
    TreeNode * syntaxTree;
  
    //// opening sources ////
    char pgm[120]; /* source code file name */
    if ((argc < 2) || (argc > 3))
    { fprintf(stderr,"usage: %s <filename> [<detailpath>]\n",argv[0]);
      exit(1);
    }
    strcpy(pgm,argv[1]);
    if (strchr (pgm, '.') == NULL)
        strcat(pgm,".cm");// if no extension is given, append .cm (c minus) to the filename
    source = fopen(pgm,"r");
    //redundant_source = fopen(pgm, "r"); <- use redundant_source to print whole lines in lex output
    if (source==NULL)
    { fprintf(stderr,"File %s not found\n",pgm);
        exit(1);
    }
    
    char detailpath[200];
    if (3 == argc) {
        strcpy(detailpath,argv[2]);
    } else strcpy(detailpath,"/tmp/");// default detailpath is /tmp. Check there if you called by hand.
    //// end opening sources ////
    
    listing = stdout; /* send messages from main() to screen */
    initializePrinter(detailpath, pgm, LER);// init logger in /lib/log.c
    // for the lexical analysis, you might change LOGALL to LER, to generate only lex and err outputs.
    
  fprintf(listing,"\nCOMPILATION: %s\n",pgm); // messages on stderr are useful only when calling the compiler manually.
#if NO_PARSE
  while (getToken()!=ENDFILE);// getToken is in the .l file
#else
  syntaxTree = parse();
  if (TraceParse) {
    fprintf(listing,"\nSyntax tree:\n");
    printTree(syntaxTree);
  }
#if !NO_ANALYZE
  if (! Error)
  { if (TraceAnalyze) fprintf(listing,"\nBuilding Symbol Table...\n");
    buildSymtab(syntaxTree);
    if (TraceAnalyze) fprintf(listing,"\nChecking Types...\n");
    typeCheck(syntaxTree);
    if (TraceAnalyze) fprintf(listing,"\nType Checking Finished\n");
  }
#if !NO_CODE
  if (! Error)
  { char * codefile;
    int fnlen = strcspn(pgm,".");
    codefile = (char *) calloc(fnlen+4, sizeof(char));
    strncpy(codefile,pgm,fnlen);
    strcat(codefile,".tm");
    code = fopen(codefile,"w");
    if (code == NULL)
    { printf("Unable to open %s\n",codefile);
      exit(1);
    }
    codeGen(syntaxTree,codefile);
    fclose(code);
  }
#endif
#endif
#endif
  fclose(source);
  closePrinter();
  return 0;
}

