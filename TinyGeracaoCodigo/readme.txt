
# Instrucoes para compilacao manual do TinyCompiler
# DELETE PARSER.C PARSER.H AND LEXER.C AFTERWARDS, OR CMAKE WONT WORK! CMAKE GENERATES THEM INSIDE THE BUILD DIRECTORY
flex tiny.l
# bison output with the correct name
bison -d tiny.y -o parser.c
# DELETE PARSER.C PARSER.H AND LEXER.C AFTERWARDS, OR CMAKE WONT WORK! CMAKE GENERATES THEM INSIDE THE BUILD DIRECTORY
# gcc compiles all sources on this directory plus lib/log.c 
# -lfl links with the flex library
# -I../lib tells gcc to look for headers also in lib (log.h is there)
gcc *.c ../lib/log.c -o tiny -lfl -I../lib

##########################################################################
# DELETE PARSER.C PARSER.H AND LEXER.C AFTERWARDS, OR CMAKE WONT WORK!   #
# CMAKE GENERATES THEM INSIDE THE BUILD DIRECTORY                        #
# THERE IS ANOTHER FILE PARSE.H (NO 'R'). DO NOT DELETE IT.              #
##########################################################################

***************  OLD VERSION **************

# caveats and changes
# the default name of bison's output is tiny.tab.c and tiny.tab.h, but my cmake sets it to parser.h/c
# my cmake stores flex and bison output files in build. it will not work if other copies of them are in src
# final linking: -ly may be needed in older versions of flex OR without the %option noyywrap 

# flex tiny.l
# bison -d tiny.y
# gcc -c *.c
# gcc -o tiny *.o -lfl 

