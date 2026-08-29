* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> FUNCAO (teste)
* -> Call output
* -> Id
  4:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
  5:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* -> Call output
* -> Id
  6:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
  7:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* -> Novo Bloco
  8:    LDA  6,-1(6) 	Posicao do novo FP
  9:     ST  2,0(6) 	Salvar FP antigo
 10:    LDA  2,0(6) 	FP atualizado
* -> Declarando variavel
 11:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 12:    LDC  0,3(0) 	Salvando constante em AC
* <- Constante
 13:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 14:     ST  4,-1(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Declarando variavel
 15:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 16:    LDC  0,4(0) 	Salvando constante em AC
* <- Constante
 17:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 18:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Call output
* -> Id
 19:     LD  0,-1(2) 	Carregar valor de ID em AC
* <- Id
 20:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* -> Call output
* -> Id
 21:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 22:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
 23:    LDA  6,1(2) 	Atualizando MP para o frame anterior
 24:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
* -> Constante
 25:    LDC  0,5(0) 	Salvando constante em AC
* <- Constante
 26:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 27:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Call output
* -> Id
 28:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 29:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* -> Return
 30:    LDA  1,0(2) 	Salvar FP em AC1
 31:     LD  2,0(2) 	FP volta para o escopo pai
 32:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 33:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 34:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  3:    LDA  7,31(7) 	Pular para a main
* -> FUNCAO (main)
 35:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 36:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 37:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 38:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 39:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Declarando variavel
 40:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 41:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
 42:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 43:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Chamando a funcao (teste)
 44:    LDA  6,-1(6) 	Posicao do novo FP
 45:     ST  2,0(6) 	Salvar FP antigo
 46:    LDA  2,0(6) 	FP atualizado
 47:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 48:    LDA  3,0(2) 	Salvando FP em R3
 49:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 50:     LD  0,-2(2) 	Carregar valor de ID em AC
 51:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 52:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 53:     ST  0,0(6) 	Salvar parametro (a) que esta em AC
* <- Argumento da funcao
* -> Id
 54:    LDA  3,0(2) 	Salvando FP em R3
 55:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 56:     LD  0,-3(2) 	Carregar valor de ID em AC
 57:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 58:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 59:     ST  0,0(6) 	Salvar parametro (b) que esta em AC
* <- Argumento da funcao
 60:     ST  7,-1(2) 	Guarda endereco de retorno
 61:    LDA  7,-58(7) 	Pular para a funcao
* <- Call
* -> Call output
* -> Id
 62:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 63:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* -> Call output
* -> Id
 64:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 65:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* FIM DA EXECUCAO
 66:   HALT  0,0,0          
* <- Function exit
