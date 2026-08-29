* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> Declarando vetor
  3:    LDA  0,3(5) 	Colocando endereco do vetor em AC
  4:     ST  0,3(5) 	salvando endereco do vetor no primeiro slot do vetor
* <- Declarando vetor
* -> FUNCAO (f)
* -> Return
  6:    LDA  1,0(2) 	Salvar FP em AC1
  7:     LD  2,0(2) 	FP volta para o escopo pai
  8:    LDA  6,1(1) 	MP volta ao topo do frame anterior
  9:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 10:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  5:    LDA  7,5(7) 	Pular para a main
* -> FUNCAO (main)
 11:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 12:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 13:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 14:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 15:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 16:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Op
* -> Id
 17:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 18:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 19:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 20:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 21:     LD  1,0(6) 	Esquerda da operacao em AC1
 22:    LDA  6,1(6) 	Livrar o espaco usado
 23:    ADD  0,1,0      op +
* <- Op
 24:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 25:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Id
 26:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 27:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
* -> Constante
 28:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
*                       AC tem o index
 29:     LD  1,3(5) 	AC1 = endereco base do array (global)
 30:    SUB  0,1,0      AC tem o endereco - 1
 31:    LDC  1,1(0) 	load 1 em AC1
 32:    SUB  0,0,1      AC tem o endereco
 33:     ST  4,0(0) 	Colocando R4 no endereco do array
* <- Atribuicao
* -> Id
 34:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 35:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
* -> Constante
 36:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       AC tem o index
 37:     LD  1,3(5) 	AC1 = endereco base do array (global)
 38:    SUB  0,1,0      AC tem o endereco - 1
 39:    LDC  1,1(0) 	load 1 em AC1
 40:    SUB  0,0,1      AC tem o endereco
 41:     ST  4,0(0) 	Colocando R4 no endereco do array
* <- Atribuicao
* -> Chamando a funcao (f)
 42:    LDA  6,-1(6) 	Posicao do novo FP
 43:     ST  2,0(6) 	Salvar FP antigo
 44:    LDA  2,0(6) 	FP atualizado
 45:    LDA  6,-1(6) 	Posicao do endereco de retorno
 46:     ST  7,-1(2) 	Guarda endereco de retorno
 47:    LDA  7,-42(7) 	Pular para a funcao
* <- Call
* FIM DA EXECUCAO
 48:   HALT  0,0,0          
* <- Function exit
