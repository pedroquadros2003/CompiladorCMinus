* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> FUNCAO (funOne)
* -> Declarando variavel
  4:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
  5:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Op
* -> Constante
  6:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
  7:    LDA  6,-1(6) 	Espaco para salvar a esquerda
  8:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Op
* -> Constante
  9:    LDC  0,5(0) 	Salvando constante em AC
* <- Constante
 10:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 11:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 12:    LDC  0,7(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 13:     LD  1,0(6) 	Esquerda da operacao em AC1
 14:    LDA  6,1(6) 	Livrar o espaco usado
 15:    MUL  0,1,0      op *
* <- Op
 16:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 17:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 18:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 19:     LD  1,0(6) 	Esquerda da operacao em AC1
 20:    LDA  6,1(6) 	Livrar o espaco usado
 21:    DIV  0,1,0      op /
* <- Op
*                       Direita da operacao em AC
 22:     LD  1,0(6) 	Esquerda da operacao em AC1
 23:    LDA  6,1(6) 	Livrar o espaco usado
 24:    ADD  0,1,0      op +
* <- Op
 25:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 26:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Op
* -> Id
 27:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 28:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 29:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 30:    LDC  0,4(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 31:     LD  1,0(6) 	Esquerda da operacao em AC1
 32:    LDA  6,1(6) 	Livrar o espaco usado
 33:    ADD  0,1,0      op +
* <- Op
 34:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 35:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Return
 36:    LDA  1,0(2) 	Salvar FP em AC1
 37:     LD  2,0(2) 	FP volta para o escopo pai
 38:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 39:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 40:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  3:    LDA  7,37(7) 	Pular para a main
* -> FUNCAO (main)
 41:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 42:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 43:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Op
* -> Id
 44:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 45:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 46:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 47:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 48:     LD  1,0(6) 	Esquerda da operacao em AC1
 49:    LDA  6,1(6) 	Livrar o espaco usado
 50:    ADD  0,1,0      op +
* <- Op
 51:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 52:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* FIM DA EXECUCAO
 53:   HALT  0,0,0          
* <- Function exit
