* GERACAO CODIGO ASSEMBLY TM
* A posicao 0 comeca com o maxaddress
  0:     LD  6,0(0) 	Salvar o maxaddress em MP
  1:     LD  2,0(0) 	Salvar o maxaddress em FP
  2:     ST  0,0(0) 	Limpar a posicao 0
* INICIO DA EXECUCAO
  3:    LDA  7,0(7) 	Pular para a main
* -> FUNCAO (main)
  4:    LDA  6,-1(6) 	Posicao do endereco de retorno
* -> Declarando variavel
  5:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
  6:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
  7:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> Declarando variavel
  8:    LDA  6,-1(6) 	Deixando MP no final do frame
* <- Declarando variavel
* -> If
* -> Op
* -> Id
  9:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 10:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 11:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 12:     LD  0,-4(2) 	Carregar valor de ID em AC
* <- Id
*                       Direita da operacao em AC
 13:     LD  1,0(6) 	Esquerda da operacao em AC1
 14:    LDA  6,1(6) 	Livrar o espaco usado
 15:    SUB  0,1,0     op ==
 16:    JEQ  0,2(7) 	Se verdadeiro PC pula 2
 17:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 18:    LDA  7,1(7) 	PC pula para o fim
 19:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Constante
 21:    LDC  0,0(0) 	Salvando constante em AC
* <- Constante
 22:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 23:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
* ELSE branch
 20:    JEQ  0,4(7) 	Se AC == 0, pular para else/end
* -> Constante
 25:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
 26:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 27:     ST  4,-2(2) 	Armazenando valor na variável
* <- Atribuicao
 24:    LDA  7,3(7) 	jmp to end
* <- If
* -> If
* -> Op
* -> Id
 28:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 29:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 30:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 31:     LD  0,-4(2) 	Carregar valor de ID em AC
* <- Id
*                       Direita da operacao em AC
 32:     LD  1,0(6) 	Esquerda da operacao em AC1
 33:    LDA  6,1(6) 	Livrar o espaco usado
 34:    SUB  0,1,0      op <
 35:    JLT  0,2(7) 	Se verdadeiro PC pula 2
 36:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 37:    LDA  7,1(7) 	PC pula para o fim
 38:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Novo Bloco
 40:    LDA  6,-1(6) 	Posicao do novo FP
 41:     ST  2,0(6) 	Salvar FP antigo
 42:    LDA  2,0(6) 	FP atualizado
* -> Op
* -> Id
 43:    LDA  3,0(2) 	Salvando FP em R3
 44:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 45:     LD  0,-4(2) 	Carregar valor de ID em AC
 46:    LDA  2,0(3) 	Restaurando FP
* <- Id
 47:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 48:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 49:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 50:     LD  1,0(6) 	Esquerda da operacao em AC1
 51:    LDA  6,1(6) 	Livrar o espaco usado
 52:    ADD  0,1,0      op +
* <- Op
 53:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 54:    LDA  3,0(2) 	Salvando FP em R3
 55:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 56:     ST  4,-3(2) 	Armazenando valor na variável
 57:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Op
* -> Id
 58:    LDA  3,0(2) 	Salvando FP em R3
 59:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 60:     LD  0,-4(2) 	Carregar valor de ID em AC
 61:    LDA  2,0(3) 	Restaurando FP
* <- Id
 62:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 63:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Op
* -> Constante
 64:    LDC  0,3(0) 	Salvando constante em AC
* <- Constante
 65:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 66:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 67:    LDC  0,5(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 68:     LD  1,0(6) 	Esquerda da operacao em AC1
 69:    LDA  6,1(6) 	Livrar o espaco usado
 70:    MUL  0,1,0      op *
* <- Op
 71:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 72:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
 73:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
 74:     LD  1,0(6) 	Esquerda da operacao em AC1
 75:    LDA  6,1(6) 	Livrar o espaco usado
 76:    DIV  0,1,0      op /
* <- Op
*                       Direita da operacao em AC
 77:     LD  1,0(6) 	Esquerda da operacao em AC1
 78:    LDA  6,1(6) 	Livrar o espaco usado
 79:    ADD  0,1,0      op +
* <- Op
 80:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
 81:    LDA  3,0(2) 	Salvando FP em R3
 82:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
 83:     ST  4,-4(2) 	Armazenando valor na variável
 84:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
 85:    LDA  6,1(2) 	Atualizando MP para o frame anterior
 86:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
 39:    JEQ  0,47(7) 	Se AC == 0, pular para else/end
* <- If
* -> If
* -> Op
* -> Id
 87:     LD  0,-3(2) 	Carregar valor de ID em AC
* <- Id
 88:    LDA  6,-1(6) 	Espaco para salvar a esquerda
 89:     ST  0,0(6) 	Armazenando valor da variável
* -> Id
 90:     LD  0,-4(2) 	Carregar valor de ID em AC
* <- Id
*                       Direita da operacao em AC
 91:     LD  1,0(6) 	Esquerda da operacao em AC1
 92:    LDA  6,1(6) 	Livrar o espaco usado
 93:    SUB  0,1,0      op >
 94:    JGT  0,2(7) 	Se verdadeiro PC pula 2
 95:    LDC  0,0(0) 	Se falso, coloca 0 em AC
 96:    LDA  7,1(7) 	PC pula para o fim
 97:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* THEN branch
* -> Novo Bloco
 99:    LDA  6,-1(6) 	Posicao do novo FP
100:     ST  2,0(6) 	Salvar FP antigo
101:    LDA  2,0(6) 	FP atualizado
* -> Constante
102:    LDC  0,8(0) 	Salvando constante em AC
* <- Constante
103:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
104:    LDA  3,0(2) 	Salvando FP em R3
105:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
106:     ST  4,-3(2) 	Armazenando valor na variável
107:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
108:    LDA  6,1(2) 	Atualizando MP para o frame anterior
109:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
* ELSE branch
 98:    JEQ  0,12(7) 	Se AC == 0, pular para else/end
* -> Novo Bloco
111:    LDA  6,-1(6) 	Posicao do novo FP
112:     ST  2,0(6) 	Salvar FP antigo
113:    LDA  2,0(6) 	FP atualizado
* -> Constante
114:    LDC  0,75(0) 	Salvando constante em AC
* <- Constante
115:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
116:    LDA  3,0(2) 	Salvando FP em R3
117:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
118:     ST  4,-4(2) 	Armazenando valor na variável
119:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Op
* -> Op
* -> Id
120:    LDA  3,0(2) 	Salvando FP em R3
121:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
122:     LD  0,-4(2) 	Carregar valor de ID em AC
123:    LDA  2,0(3) 	Restaurando FP
* <- Id
124:    LDA  6,-1(6) 	Espaco para salvar a esquerda
125:     ST  0,0(6) 	Armazenando valor da variável
* -> Op
* -> Constante
126:    LDC  0,5(0) 	Salvando constante em AC
* <- Constante
127:    LDA  6,-1(6) 	Espaco para salvar a esquerda
128:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
129:    LDC  0,3(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
130:     LD  1,0(6) 	Esquerda da operacao em AC1
131:    LDA  6,1(6) 	Livrar o espaco usado
132:    DIV  0,1,0      op /
* <- Op
*                       Direita da operacao em AC
133:     LD  1,0(6) 	Esquerda da operacao em AC1
134:    LDA  6,1(6) 	Livrar o espaco usado
135:    MUL  0,1,0      op *
* <- Op
136:    LDA  6,-1(6) 	Espaco para salvar a esquerda
137:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
138:    LDC  0,7(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
139:     LD  1,0(6) 	Esquerda da operacao em AC1
140:    LDA  6,1(6) 	Livrar o espaco usado
141:    ADD  0,1,0      op +
* <- Op
142:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
143:    LDA  3,0(2) 	Salvando FP em R3
144:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
145:     ST  4,-3(2) 	Armazenando valor na variável
146:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
147:    LDA  6,1(2) 	Atualizando MP para o frame anterior
148:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
110:    LDA  7,38(7) 	jmp to end
* <- If
* -> while
* Verificando condicao do while
* -> Op
* -> Id
149:     LD  0,-5(2) 	Carregar valor de ID em AC
* <- Id
150:    LDA  6,-1(6) 	Espaco para salvar a esquerda
151:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
152:    LDC  0,10(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
153:     LD  1,0(6) 	Esquerda da operacao em AC1
154:    LDA  6,1(6) 	Livrar o espaco usado
155:    SUB  0,1,0     op <=
156:    JLE  0,2(7) 	Se verdadeiro PC pula 2
157:    LDC  0,0(0) 	Se falso, coloca 0 em AC
158:    LDA  7,1(7) 	PC pula para o fim
159:    LDC  0,1(0) 	Se verdadeiro, coloca 1 em AC
* <- Op
* -> Novo Bloco
161:    LDA  6,-1(6) 	Posicao do novo FP
162:     ST  2,0(6) 	Salvar FP antigo
163:    LDA  2,0(6) 	FP atualizado
* -> Op
* -> Id
164:    LDA  3,0(2) 	Salvando FP em R3
165:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
166:     LD  0,-5(2) 	Carregar valor de ID em AC
167:    LDA  2,0(3) 	Restaurando FP
* <- Id
168:    LDA  6,-1(6) 	Espaco para salvar a esquerda
169:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
170:    LDC  0,2(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
171:     LD  1,0(6) 	Esquerda da operacao em AC1
172:    LDA  6,1(6) 	Livrar o espaco usado
173:    MUL  0,1,0      op *
* <- Op
174:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
175:    LDA  3,0(2) 	Salvando FP em R3
176:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
177:     ST  4,-4(2) 	Armazenando valor na variável
178:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Op
* -> Id
179:    LDA  3,0(2) 	Salvando FP em R3
180:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
181:     LD  0,-4(2) 	Carregar valor de ID em AC
182:    LDA  2,0(3) 	Restaurando FP
* <- Id
183:    LDA  6,-1(6) 	Espaco para salvar a esquerda
184:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
185:    LDC  0,4(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
186:     LD  1,0(6) 	Esquerda da operacao em AC1
187:    LDA  6,1(6) 	Livrar o espaco usado
188:    ADD  0,1,0      op +
* <- Op
189:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
190:    LDA  3,0(2) 	Salvando FP em R3
191:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
192:     ST  4,-3(2) 	Armazenando valor na variável
193:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
* -> Op
* -> Id
194:    LDA  3,0(2) 	Salvando FP em R3
195:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
196:     LD  0,-5(2) 	Carregar valor de ID em AC
197:    LDA  2,0(3) 	Restaurando FP
* <- Id
198:    LDA  6,-1(6) 	Espaco para salvar a esquerda
199:     ST  0,0(6) 	Armazenando valor da variável
* -> Constante
200:    LDC  0,1(0) 	Salvando constante em AC
* <- Constante
*                       Direita da operacao em AC
201:     LD  1,0(6) 	Esquerda da operacao em AC1
202:    LDA  6,1(6) 	Livrar o espaco usado
203:    ADD  0,1,0      op +
* <- Op
204:    LDA  4,0(0) 	Copia o valor de AC para R4
* -> Atribuicao
205:    LDA  3,0(2) 	Salvando FP em R3
206:     LD  2,0(2) 	Voltando um escopo na pilha de execucao
207:     ST  4,-5(2) 	Armazenando valor na variável
208:    LDA  2,0(3) 	Restaurando FP
* <- Atribuicao
209:    LDA  6,1(2) 	Atualizando MP para o frame anterior
210:     LD  2,0(2) 	FP volta para o escopo pai (fim do bloco)
* <- Fim de Bloco
211:    LDA  7,-63(7) 	Voltando para checar a condicao do while
160:    JEQ  0,51(7) 	Fim do while, se AC = 1 volta para o while, se AC = 0 continua
* <- while
* FIM DA EXECUCAO
212:   HALT  0,0,0          
* <- Function exit
