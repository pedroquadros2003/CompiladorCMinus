* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
  3:    LDA  7,0(7) 	Pular para a main
* -> FUNCAO (main)
  4:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando vetor
  5:    LDA  0,-2(2) 	Colocando endereco do vetor em AC
  6:     ST  0,-2(2) 	salvando endereco do vetor no primeiro slot do vetor
  7:    LDA  6,-12(2) 	Deixando MP no final do frame
* <- Declarando vetor
* -> Declarando vetor
  8:    LDA  0,-13(2) 	Colocando endereco do vetor em AC
  9:     ST  0,-13(2) 	salvando endereco do vetor no primeiro slot do vetor
 10:    LDA  6,-23(2) 	Deixando MP no final do frame
* <- Declarando vetor
* -> Declarando vetor
 11:    LDA  0,-24(2) 	Colocando endereco do vetor em AC
 12:     ST  0,-24(2) 	salvando endereco do vetor no primeiro slot do vetor
 13:    LDA  6,-34(2) 	Deixando MP no final do frame
* <- Declarando vetor
* -> Declarando variavel
 14:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Constante
 15:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
 16:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 17:     ST  4,-35(2) 	Armazenando valor na variável
* <- Atribuicao
* -> while
* Verificando condicao do while
* -> Op
* -> Id
 18:     LD  0,-35(2) 	Carregar valor de ID em AC
* <- Id
 19:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 20:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 21:    LDC  0,10(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 22:     LD  1,0(6) 	Esquerda da operacao em AC1
 23:    LDA  6,1(6) 	Livrar o espaco usado
 24:    SUB  0,1,0      op <
 25:    JLT  0,2(7) 	Se verdadeiro PC pula 2
 26:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 27:    LDA  7,1(7) 	PC pula para o fim
 28:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* -> Novo Bloco
 30:    LDA  6,-1(6) 	Posicao do novo FP
 31:     ST  2,0(6) 	Salvar FP antigo
 32:    LDA  2,0(6) 	FP atualizado
* -> Constante
 33:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 34:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
* -> Id
 35:    LDA  3,0(2) 	Salvando FP em R3
 36:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 37:     LD  0,-35(2) 	Carregar valor de ID em AC
 38:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       AC tem o index
 39:    LDA  3,0(2) 	Salvando FP em R3
 40:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 41:     LD  1,-13(2) 	AC1 = endereco base do array
 42:    LDA  2,0(3) 	Restaurando FP
 43:    SUB  0,1,0      AC tem o endereco - 1
 44:    LDC  1,1(0) 	load 1 em AC1
 45:    SUB  0,0,1      AC tem o endereco
 46:     ST  4,0(0) 	Colocando R4 no endereco do array
* <- Atribuicao
* -> Constante
 47:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 48:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
* -> Id
 49:    LDA  3,0(2) 	Salvando FP em R3
 50:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 51:     LD  0,-35(2) 	Carregar valor de ID em AC
 52:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       AC tem o index
 53:    LDA  3,0(2) 	Salvando FP em R3
 54:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 55:     LD  1,-24(2) 	AC1 = endereco base do array
 56:    LDA  2,0(3) 	Restaurando FP
 57:    SUB  0,1,0      AC tem o endereco - 1
 58:    LDC  1,1(0) 	load 1 em AC1
 59:    SUB  0,0,1      AC tem o endereco
 60:     ST  4,0(0) 	Colocando R4 no endereco do array
* <- Atribuicao
* -> Op
* -> Id
 61:    LDA  3,0(2) 	Salvando FP em R3
 62:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 63:     LD  0,-35(2) 	Carregar valor de ID em AC
 64:    LDA  2,0(3) 	Restaurando FP
* <- Id
 65:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 66:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 67:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 68:     LD  1,0(6) 	Esquerda da operacao em AC1
 69:    LDA  6,1(6) 	Livrar o espaco usado
 70:    ADD  0,1,0      op +
* <- Op
 71:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 72:    LDA  3,0(2) 	Salvando FP em R3
 73:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 74:     ST  4,-35(2) 	Armazenando valor na variável
 75:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
 76:    LDA  6,1(2) 	Atualizando MP para o frame anterior
 77:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
 78:    LDA  7,-61(7) 	Voltando para checar a condicao do while
 29:    JEQ  0,49(7) 	Fim do while, se AC = 1 volta para o while, se AC = 0 continua
* <- while
* -> while
* Verificando condicao do while
* -> Op
* -> Id
 79:     LD  0,-35(2) 	Carregar valor de ID em AC
* <- Id
 80:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 81:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 82:    LDC  0,10(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 83:     LD  1,0(6) 	Esquerda da operacao em AC1
 84:    LDA  6,1(6) 	Livrar o espaco usado
 85:    SUB  0,1,0      op <
 86:    JLT  0,2(7) 	Se verdadeiro PC pula 2
 87:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 88:    LDA  7,1(7) 	PC pula para o fim
 89:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* -> Novo Bloco
 91:    LDA  6,-1(6) 	Posicao do novo FP
 92:     ST  2,0(6) 	Salvar FP antigo
 93:    LDA  2,0(6) 	FP atualizado
* -> Op
* -> Id
* -> Id
 94:    LDA  3,0(2) 	Salvando FP em R3
 95:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 96:     LD  0,-35(2) 	Carregar valor de ID em AC
 97:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       AC tem o index
 98:    LDA  3,0(2) 	Salvando FP em R3
 99:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
100:     LD  1,-13(2) 	AC1 = endereco base do array
101:    LDA  2,0(3) 	Restaurando FP
102:    SUB  0,1,0      AC tem o endereco - 1
103:    LDC  1,1(0) 	load 1 em AC1
104:    SUB  0,0,1      AC tem o endereco
105:     LD  0,0(0) 	Obter o valor do elemento do array em AC
* <- Id
106:    LDA  6,-1(6) 	Espaco para salvar a esquerda
107:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
* -> Id
108:    LDA  3,0(2) 	Salvando FP em R3
109:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
110:     LD  0,-35(2) 	Carregar valor de ID em AC
111:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       AC tem o index
112:    LDA  3,0(2) 	Salvando FP em R3
113:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
114:     LD  1,-24(2) 	AC1 = endereco base do array
115:    LDA  2,0(3) 	Restaurando FP
116:    SUB  0,1,0      AC tem o endereco - 1
117:    LDC  1,1(0) 	load 1 em AC1
118:    SUB  0,0,1      AC tem o endereco
119:     LD  0,0(0) 	Obter o valor do elemento do array em AC
* <- Id
*                       Direita da operacao em AC
120:     LD  1,0(6) 	Esquerda da operacao em AC1
121:    LDA  6,1(6) 	Livrar o espaco usado
122:    ADD  0,1,0      op +
* <- Op
123:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
* -> Id
124:    LDA  3,0(2) 	Salvando FP em R3
125:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
126:     LD  0,-35(2) 	Carregar valor de ID em AC
127:    LDA  2,0(3) 	Restaurando FP
* <- Id
*                       AC tem o index
128:    LDA  3,0(2) 	Salvando FP em R3
129:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
130:     LD  1,-2(2) 	AC1 = endereco base do array
131:    LDA  2,0(3) 	Restaurando FP
132:    SUB  0,1,0      AC tem o endereco - 1
133:    LDC  1,1(0) 	load 1 em AC1
134:    SUB  0,0,1      AC tem o endereco
135:     ST  4,0(0) 	Colocando R4 no endereco do array
* <- Atribuicao
136:    LDA  6,1(2) 	Atualizando MP para o frame anterior
137:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
138:    LDA  7,-60(7) 	Voltando para checar a condicao do while
 90:    JEQ  0,48(7) 	Fim do while, se AC = 1 volta para o while, se AC = 0 continua
* <- while
* FIM DA EXECUCAO
139:   HALT  0,0,0          
* <- Function exit
