* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> Declarando variavel global
* <- Declarando variavel global
* -> FUNCAO (atualizaglobal)
* -> Op
* -> Id
  4:    LDA  3,0(2) 	Salvando FP em R3
  5:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
  6:     LD  0,0(5) 	Carregar valor de ID em AC
  7:    LDA  2,0(3) 	Restaurando FP
* <- Id
  8:    LDA  6,-1(6) 	Espaco para salvar a esquerda
  9:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 10:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
*                       Direita da operacao em AC
 11:     LD  1,0(6) 	Esquerda da operacao em AC1
 12:    LDA  6,1(6) 	Livrar o espaco usado
 13:    ADD  0,1,0      op +
* <- Op
 14:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 15:    LDA  3,0(2) 	Salvando FP em R3
 16:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 17:     ST  4,0(5) 	Armazenando valor na variável (global)
 18:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Return
 19:    LDA  1,0(2) 	Salvar FP em AC1
 20:     LD  2,0(2) 	FP volta para o escopo pai
 21:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 22:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 23:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* -> Return
 24:    LDA  1,0(2) 	Salvar FP em AC1
 25:     LD  2,0(2) 	FP volta para o escopo pai
 26:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 27:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 28:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  3:    LDA  7,25(7) 	Pular para a main
* -> FUNCAO (main)
 29:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 30:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 31:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 32:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
 33:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 34:    LDA  3,0(2) 	Salvando FP em R3
 35:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 36:     ST  4,0(5) 	Armazenando valor na variável (global)
 37:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Constante
 38:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 39:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 40:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Call input
 41:     IN  0,0,0 Lendo valor para AC
* <- Call input
 42:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 43:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> while
* Verificando condicao do while
* -> Op
* -> Id
 44:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 45:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 46:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 47:    LDC  0,10(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 48:     LD  1,0(6) 	Esquerda da operacao em AC1
 49:    LDA  6,1(6) 	Livrar o espaco usado
 50:    SUB  0,1,0      op <
 51:    JLT  0,2(7) 	Se verdadeiro PC pula 2
 52:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 53:    LDA  7,1(7) 	PC pula para o fim
 54:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* -> Novo Bloco
 56:    LDA  6,-1(6) 	Posicao do novo FP
 57:     ST  2,0(6) 	Salvar FP antigo
 58:    LDA  2,0(6) 	FP atualizado
* -> Chamando a funcao (atualizaglobal)
 59:    LDA  6,-1(6) 	Posicao do novo FP
 60:     ST  2,0(6) 	Salvar FP antigo
 61:    LDA  2,0(6) 	FP atualizado
 62:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 63:    LDA  3,0(2) 	Salvando FP em R3
 64:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 65:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 66:     LD  0,-2(2) 	Carregar valor de ID em AC
 67:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 68:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 69:     ST  0,0(6) 	Salvar parametro (i) que esta em AC
* <- Argumento da funcao
 70:     ST  7,-1(2) 	Guarda endereco de retorno
 71:    LDA  7,-68(7) 	Pular para a funcao
* <- Call
* -> Op
* -> Id
 72:    LDA  3,0(2) 	Salvando FP em R3
 73:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 74:     LD  0,-2(2) 	Carregar valor de ID em AC
 75:    LDA  2,0(3) 	Restaurando FP
* <- Id
 76:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 77:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 78:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 79:     LD  1,0(6) 	Esquerda da operacao em AC1
 80:    LDA  6,1(6) 	Livrar o espaco usado
 81:    ADD  0,1,0      op +
* <- Op
 82:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 83:    LDA  3,0(2) 	Salvando FP em R3
 84:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 85:     ST  4,-2(2) 	Armazenando valor na variável
 86:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
 87:    LDA  6,1(2) 	Atualizando MP para o frame anterior
 88:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
 89:    LDA  7,-46(7) 	Voltando para checar a condicao do while
 55:    JEQ  0,34(7) 	Fim do while, se AC = 1 volta para o while, se AC = 0 continua
* <- while
* -> Call output
* -> Id
 90:    LDA  3,0(2) 	Salvando FP em R3
 91:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 92:     LD  0,0(5) 	Carregar valor de ID em AC
 93:    LDA  2,0(3) 	Restaurando FP
* <- Id
 94:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* FIM DA EXECUCAO
 95:   HALT  0,0,0          
* <- Function exit
