* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> FUNCAO (f)
* -> Return
* -> Op
* -> Id
  4:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
  5:    LDA  6,-1(6) 	Espaco para salvar a esquerda
  6:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
  7:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
*                       Direita da operacao em AC
  8:     LD  1,0(6) 	Esquerda da operacao em AC1
  9:    LDA  6,1(6) 	Livrar o espaco usado
 10:    ADD  0,1,0      op +
* <- Op
 11:    LDA  1,0(2) 	Salvar FP em AC1
 12:     LD  2,0(2) 	FP volta para o escopo pai
 13:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 14:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 15:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
* -> FUNCAO (g)
* -> Return
* -> Op
* -> Id
 16:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 17:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 18:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 19:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 20:     LD  1,0(6) 	Esquerda da operacao em AC1
 21:    LDA  6,1(6) 	Livrar o espaco usado
 22:    ADD  0,1,0      op +
* <- Op
 23:    LDA  1,0(2) 	Salvar FP em AC1
 24:     LD  2,0(2) 	FP volta para o escopo pai
 25:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 26:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 27:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  3:    LDA  7,24(7) 	Pular para a main
* -> FUNCAO (main)
 28:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 29:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 30:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 31:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Chamando a funcao (f)
 32:    LDA  6,-1(6) 	Posicao do novo FP
 33:     ST  2,0(6) 	Salvar FP antigo
 34:    LDA  2,0(6) 	FP atualizado
 35:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 36:    LDA  3,0(2) 	Salvando FP em R3
 37:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 38:     LD  0,-2(2) 	Carregar valor de ID em AC
 39:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 40:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 41:     ST  0,0(6) 	Salvar parametro (a) que esta em AC
* <- Argumento da funcao
* -> Chamando a funcao (g)
 42:    LDA  6,-1(6) 	Posicao do novo FP
 43:     ST  2,0(6) 	Salvar FP antigo
 44:    LDA  2,0(6) 	FP atualizado
 45:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 46:    LDA  3,0(2) 	Salvando FP em R3
 47:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 48:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 49:     LD  0,-3(2) 	Carregar valor de ID em AC
 50:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 51:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 52:     ST  0,0(6) 	Salvar parametro (b) que esta em AC
* <- Argumento da funcao
 53:     ST  7,-1(2) 	Guarda endereco de retorno
 54:    LDA  7,-39(7) 	Pular para a funcao
* <- Call
* -> Argumento da funcao
 55:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 56:     ST  0,0(6) 	Salvar parametro (g) que esta em AC
* <- Argumento da funcao
 57:     ST  7,-1(2) 	Guarda endereco de retorno
 58:    LDA  7,-55(7) 	Pular para a funcao
* <- Call
 59:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 60:     ST  4,-4(2) 	Armazenando valor na variável
* <- Atribuicao
* FIM DA EXECUCAO
 61:   HALT  0,0,0          
* <- Function exit
