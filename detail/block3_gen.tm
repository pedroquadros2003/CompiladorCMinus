* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
* -> FUNCAO (binario)
* -> If
* -> Op
* -> Id
  4:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
  5:    LDA  6,-1(6) 	Espaco para salvar a esquerda
  6:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
  7:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
  8:     LD  1,0(6) 	Esquerda da operacao em AC1
  9:    LDA  6,1(6) 	Livrar o espaco usado
 10:    SUB  0,1,0      op <
 11:    JLT  0,2(7) 	Se verdadeiro PC pula 2
 12:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 13:    LDA  7,1(7) 	PC pula para o fim
 14:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Call output
* -> Id
 16:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 17:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
* ELSE branch
 15:    JEQ  0,3(7) 	Se AC == 0, pular para else/end
* -> Novo Bloco
 19:    LDA  6,-1(6) 	Posicao do novo FP
 20:     ST  2,0(6) 	Salvar FP antigo
 21:    LDA  2,0(6) 	FP atualizado
* -> Chamando a funcao (binario)
 22:    LDA  6,-1(6) 	Posicao do novo FP
 23:     ST  2,0(6) 	Salvar FP antigo
 24:    LDA  2,0(6) 	FP atualizado
 25:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Op
* -> Id
 26:    LDA  3,0(2) 	Salvando FP em R3
 27:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 28:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 29:     LD  0,-2(2) 	Carregar valor de ID em AC
 30:    LDA  2,0(3) 	Restaurando FP
* <- Id
 31:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 32:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 33:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 34:     LD  1,0(6) 	Esquerda da operacao em AC1
 35:    LDA  6,1(6) 	Livrar o espaco usado
 36:    DIV  0,1,0      op /
* <- Op
* -> Argumento da funcao
 37:    LDA  6,-1(6) 	Mover para proximo slot de parametro
 38:     ST  0,0(6) 	Salvar parametro (/) que esta em AC
* <- Argumento da funcao
 39:     ST  7,-1(2) 	Guarda endereco de retorno
 40:    LDA  7,-37(7) 	Pular para a funcao
* <- Call
* -> Call output
* -> Op
* -> Id
 41:    LDA  3,0(2) 	Salvando FP em R3
 42:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 43:     LD  0,-2(2) 	Carregar valor de ID em AC
 44:    LDA  2,0(3) 	Restaurando FP
* <- Id
 45:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 46:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Constante
 47:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
 48:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 49:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Id
 50:    LDA  3,0(2) 	Salvando FP em R3
 51:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 52:     LD  0,-2(2) 	Carregar valor de ID em AC
 53:    LDA  2,0(3) 	Restaurando FP
* <- Id
 54:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 55:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 56:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 57:     LD  1,0(6) 	Esquerda da operacao em AC1
 58:    LDA  6,1(6) 	Livrar o espaco usado
 59:    DIV  0,1,0      op /
* <- Op
*                       Direita da operacao em AC
 60:     LD  1,0(6) 	Esquerda da operacao em AC1
 61:    LDA  6,1(6) 	Livrar o espaco usado
 62:    MUL  0,1,0      op *
* <- Op
*                       Direita da operacao em AC
 63:     LD  1,0(6) 	Esquerda da operacao em AC1
 64:    LDA  6,1(6) 	Livrar o espaco usado
 65:    SUB  0,1,0      op -
* <- Op
 66:    OUT  0,0,0 Escrevendo valor de AC
* <- Call output
 67:    LDA  6,1(2) 	Atualizando MP para o frame anterior
 68:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
 18:    LDA  7,50(7) 	jmp to end
* <- If
* -> Return
 69:    LDA  1,0(2) 	Salvar FP em AC1
 70:     LD  2,0(2) 	FP volta para o escopo pai
 71:    LDA  6,1(1) 	MP volta ao topo do frame anterior
 72:     LD  1,-1(1) 	AC1 tem o endereco de retorno - 1
 73:    LDA  7,1(1) 	Retorna para onde foi chamado
* <- Return
* <- Function exit
  3:    LDA  7,70(7) 	Pular para a main
* -> FUNCAO (main)
 74:    LDA  6,-1(6) 	Posicao do endereco de retorno
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
* -> If
* -> Op
* -> Id
 79:     LD  0,-2(2) 	Carregar valor de ID em AC
* <- Id
 80:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 81:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 82:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 83:     LD  1,0(6) 	Esquerda da operacao em AC1
 84:    LDA  6,1(6) 	Livrar o espaco usado
 85:    SUB  0,1,0     op >=
 86:    JGE  0,2(7) 	Se verdadeiro PC pula 2
 87:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 88:    LDA  7,1(7) 	PC pula para o fim
 89:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Chamando a funcao (binario)
 91:    LDA  6,-1(6) 	Posicao do novo FP
 92:     ST  2,0(6) 	Salvar FP antigo
 93:    LDA  2,0(6) 	FP atualizado
 94:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Id
 95:    LDA  3,0(2) 	Salvando FP em R3
 96:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 97:     LD  0,-2(2) 	Carregar valor de ID em AC
 98:    LDA  2,0(3) 	Restaurando FP
* <- Id
* -> Argumento da funcao
 99:    LDA  6,-1(6) 	Mover para proximo slot de parametro
100:     ST  0,0(6) 	Salvar parametro (x) que esta em AC
* <- Argumento da funcao
101:     ST  7,-1(2) 	Guarda endereco de retorno
102:    LDA  7,-99(7) 	Pular para a funcao
* <- Call
* ELSE branch
 90:    JEQ  0,13(7) 	Se AC == 0, pular para else/end
* -> Chamando a funcao (binario)
104:    LDA  6,-1(6) 	Posicao do novo FP
105:     ST  2,0(6) 	Salvar FP antigo
106:    LDA  2,0(6) 	FP atualizado
107:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Op
* -> Id
108:    LDA  3,0(2) 	Salvando FP em R3
109:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
110:     LD  0,-2(2) 	Carregar valor de ID em AC
111:    LDA  2,0(3) 	Restaurando FP
* <- Id
112:    LDA  0,0,0 unario: AC = -AC
* <- Calc (Unary)
* -> Argumento da funcao
113:    LDA  6,-1(6) 	Mover para proximo slot de parametro
114:     ST  0,0(6) 	Salvar parametro (- (unario)) que esta em AC
* <- Argumento da funcao
115:     ST  7,-1(2) 	Guarda endereco de retorno
116:    LDA  7,-113(7) 	Pular para a funcao
* <- Call
103:    LDA  7,13(7) 	jmp to end
* <- If
* FIM DA EXECUCAO
117:   HALT  0,0,0          
* <- Function exit
