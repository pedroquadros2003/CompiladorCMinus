* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> FUNCAO (gdc)
* -> If
* -> Op
* -> Id
  4:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
  5:    LDA  6,-1(6) 	Espaco para salvar a esquerda
  6:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
  7:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
  8:     LD  1,0(6) 	Esquerda da operacao em AC1
  9:    LDA  6,1(6) 	Livrar o espaco usado
 10:    SUB  0,1,0     op ==
 11:    JEQ  0,2(7) 	Se verdadeiro PC pula 2
 12:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 13:    LDA  7,1(7) 	PC pula para o fim
 14:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Return
* -> Id
 16:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 17:    LDA  1,0(2) 	Salvar FP em AC1
 18:     LD  2,0(2) 	FP volta para o escopo pai
 19:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 20:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 21:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* ELSE branch
 15:    JEQ  0,7(7) 	Se AC == 0, pular para else/end
* -> Return
* -> Chamando a funcao (gdc)
 23:    LDA  6,-1(6) 	Posicao do novo FP
 24:     ST  2,0(6) 	Salvar FP antigo
 25:    LDA  2,0(6) 	FP atualizado
 26:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 27:    LDA  3,0(2) 	Salvando FP em R3
 28:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 29:     LD  0,-3(2) 	Carregar valor de ID em AC
 30:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 31:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 32:     ST  0,0(6) 	Salvar parametro (v) que esta em AC
* <- Argumento da funcao
* -> Op
* -> Id
 33:    LDA  3,0(2) 	Salvando FP em R3
 34:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 35:     LD  0,-2(2) 	Carregar valor de ID em AC
 36:    LDA  2,0(3) 	Restaurando FP
* <- Id
 37:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 38:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Op
* -> Id
 39:    LDA  3,0(2) 	Salvando FP em R3
 40:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 41:     LD  0,-2(2) 	Carregar valor de ID em AC
 42:    LDA  2,0(3) 	Restaurando FP
* <- Id
 43:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 44:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 45:    LDA  3,0(2) 	Salvando FP em R3
 46:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 47:     LD  0,-3(2) 	Carregar valor de ID em AC
 48:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       Direita da operacao em AC
 49:     LD  1,0(6) 	Esquerda da operacao em AC1
 50:    LDA  6,1(6) 	Livrar o espaco usado
 51:    DIV  0,1,0      op /
* <- Op
 52:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 53:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 54:    LDA  3,0(2) 	Salvando FP em R3
 55:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 56:     LD  0,-3(2) 	Carregar valor de ID em AC
 57:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       Direita da operacao em AC
 58:     LD  1,0(6) 	Esquerda da operacao em AC1
 59:    LDA  6,1(6) 	Livrar o espaco usado
 60:    MUL  0,1,0      op *
* <- Op
*                       Direita da operacao em AC
 61:     LD  1,0(6) 	Esquerda da operacao em AC1
 62:    LDA  6,1(6) 	Livrar o espaco usado
 63:    SUB  0,1,0      op -
* <- Op
* -> Argumento da funcao
 64:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 65:     ST  0,0(6) 	Salvar parametro (-) que esta em AC
* <- Argumento da funcao
 66:     ST  7,-1(2) 	Guarda endereco de retorno
 67:    LDA  7,-64(7) 	Pular para a funcao
* <- Call
 68:    LDA  1,0(2) 	Salvar FP em AC1
 69:     LD  2,0(2) 	FP volta para o escopo pai
 70:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 71:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 72:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
 22:    LDA  7,50(7) 	jmp to end
* <- If
* <- Function exit
  3:    LDA  7,69(7) 	Pular para a main
* -> FUNCAO (main)
 73:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
 74:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
 75:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Call input
 76:     IN  0,0,0 Lendo valor para AC
* <- Call input
 77:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 78:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Call input
 79:     IN  0,0,0 Lendo valor para AC
* <- Call input
 80:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 81:     ST  4,-3(2) 	Armazenando valor na variável
* <- Atribuicao
* -> Call output
* -> Chamando a funcao (gdc)
 82:    LDA  6,-1(6) 	Posicao do novo FP
 83:     ST  2,0(6) 	Salvar FP antigo
 84:    LDA  2,0(6) 	FP atualizado
 85:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 86:    LDA  3,0(2) 	Salvando FP em R3
 87:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 88:     LD  0,-2(2) 	Carregar valor de ID em AC
 89:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 90:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 91:     ST  0,0(6) 	Salvar parametro (x) que esta em AC
* <- Argumento da funcao
* -> Id
 92:    LDA  3,0(2) 	Salvando FP em R3
 93:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 94:     LD  0,-3(2) 	Carregar valor de ID em AC
 95:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 96:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 97:     ST  0,0(6) 	Salvar parametro (y) que esta em AC
* <- Argumento da funcao
 98:     ST  7,-1(2) 	Guarda endereco de retorno
 99:    LDA  7,-96(7) 	Pular para a funcao
* <- Call
100:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* FIM DA EXECUCAO
101:   HALT  0,0,0          
* <- Function exit
