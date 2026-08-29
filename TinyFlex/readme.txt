Apenas a analise lexica implementada para TinyC
Pode ser usado como base para implementar a analise lexica para Cminus, copiando estas fontes para o diretorio src. 
*********************************************
Cmake espera que neste diretorio exista a entrada do flex para TinyC, chamada tiny.l

MAS, NO SEU COMPILADOR DE Cminus, O CMAKE ESPERA UM ARQUIVO CHAMADO cminus.l
BASTA MUDAR O NOME DO ARQUIVO

**********************************************
ESTA INTEGRADO NO CMAKE NAO PRECISA COMPILAR NA MAO
MAS, SE QUISER compilar na mao, no prompt, neste mesmo diretorio:

$ flex tiny.l
$ gcc -o tiny *.c -lfl

(Em Mac pode ser que funcione com -ll no lugar de -lfl)

Executavel gerado -> tiny

*********** ATENÇÃO ********************
cmake nao compila se o codigo gerado pelo flex estiver neste diretorio 
(o cmake gera o codigo internamente no diretorio build)
o nome default do arquivo gerado é lex.yy.c 
portanto, se compilar manualmente e quiser executar o cmake depois, apague o lex.yy.c
*****************************************

