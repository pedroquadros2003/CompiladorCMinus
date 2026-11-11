# Laboratório 4: Geração de Código para a Máquina TM

## 1. Objetivo

Gerar, a partir da AST já validada pelas fases 1–3, código para o simulador `tm`. O resultado é gravado em `alunodetail/<exemplo>_gen.tm`.

Conforme `instructions/regras_versoes260812.txt` (seção 5):

* a comparação com `diff` é irrelevante nesta fase; o que importa é o código compilado executar corretamente os exemplos funcionais (mesmo assim, o gerador segue as convenções do gabarito; veja as seções 3 e 4);
* convenções diferentes das do gabarito são permitidas, desde que a execução seja correta;
* o gabarito pode não implementar tudo o que é pedido neste ano;
* o `diff` das fases anteriores (`make ddiff`) continua obrigatório;
* programas com erro devem ser rejeitados com mensagem, sem necessidade de gerar código.

`input` e `output` são mapeadas diretamente nas instruções `IN` e `OUT` da TM.

## 2. Arquivos da fase

| Arquivo | Função |
|---|---|
| `src/code.c`, `src/code.h` | Utilitários de emissão: `emitRO`, `emitRM`, `emitRM_Abs`, `emitSkip`, `emitBackup`, `emitRestore`, `emitComment`; define os registradores. |
| `src/cgen.c`, `src/cgen.h` | Gerador: `codeGen(TreeNode *)`. Percorre a AST e emite as instruções. |
| `src/cminus.y`, `src/globals.h` | Campo `braced`: marca corpos de `if`/`else`/`while` escritos com chaves, que abrem um registro de bloco. |
| `src/main.c` | `NO_CODE` passa a `FALSE`; após `doneTABstartGEN()`, se não houve erro, chama `codeGen()`. A emissão é controlada por `TraceCode` (comentários no `.tm`). |
| `tools/gets_compat.c` | Reimplementa `gets()` (mesmo `LINESIZE` de `tm.c`). |
| `CMakeLists.txt` (alvo `tm`) | Compila `tm.c` + `tools/gets_compat.c` com `-std=gnu89 -w`. |
| `scripts/runtm` | Executa um `_gen.tm` no simulador com entradas fornecidas. |
| `scripts/rungen` | Compila os exemplos, roda no `tm` e compara as saídas `OUT` com o esperado. |

`tm.c` não foi modificado. O motivo do `gets_compat.c`: `tm.c` usa `gets()`, removida das glibc recentes (C11); sem a shim o simulador não linka. Fornecê-la em arquivo separado evita editar o código do professor.

## 3. Convenções de geração

Embora o `diff` seja irrelevante nesta fase, o gerador reproduz as convenções do gabarito (`detail/*_gen.tm`), inclusive os textos dos comentários. Assim o `make ddiff` sai limpo (seção 4). O comportamento é sempre o correto: o bug do menos unário do gabarito não foi copiado, e os casos que os exemplos não cobrem (seção 3.8) seguem o mesmo estilo, sem os erros latentes do gabarito.

### 3.1 Registradores

| Reg | Uso |
|---|---|
| 0 | `ac`: acumulador, resultado de toda expressão. |
| 1 | `ac1`: segundo operando / temporário. |
| 2 | `fp`: base do registro de ativação corrente (função ou bloco). |
| 3 | Cópia do `fp` enquanto se sobe pela cadeia de registros. |
| 4 | Valor a armazenar numa atribuição. |
| 5 | `gp`: base das globais (sempre 0, nunca escrito). |
| 6 | `mp`: topo da pilha (último slot ocupado). |
| 7 | `PC`. |

### 3.2 Memória

* Preâmbulo: `LD 6,0(0)`, `LD 2,0(0)` (mp = fp = maxaddress), `ST 0,0(0)`.
* Globais: a partir do endereço 0. O código das declarações globais é emitido antes de todas as funções, seguido do salto `LDA 7,N(7) Pular para a main`, preenchido por backpatch ao chegar em `main`.
* Todo vetor tem um **slot ponteiro** que guarda o próprio endereço. Os elementos ficam abaixo dele: `v[i]` está em `base - i - 1`.
  * Vetor global de tamanho n: ponteiro em `P = próximo + n + 1`, elementos em `P-1 ... P-n`.
  * Vetor local: ponteiro no deslocamento corrente `K`, elementos em `K-1 ... K-n`.
  * Por isso vetor global, local e parâmetro são tratados igual: a base é sempre um `LD` do slot.
* Temporários de expressão: `LDA 6,-1(6)` + `ST 0,0(6)` para empilhar; `LD 1,0(6)` + `LDA 6,1(6)` para desempilhar.

### 3.3 Registros de ativação

Registro de função (relativo a `fp`):

| Deslocamento | Conteúdo |
|---|---|
| `0` | `fp` do chamador |
| `-1` | endereço de retorno |
| `-2, -3, ...` | parâmetros, na ordem de declaração (vetor: endereço do slot ponteiro) |
| abaixo | locais do corpo da função, alocados na declaração (`LDA 6,-1(6)`) |

* `main` não é chamada: o único prólogo é `LDA 6,-1(6) Posicao do endereco de retorno`, e o fim é `HALT`.
* Cada bloco entre chaves (bloco aninhado, ou corpo de `if`/`else`/`while` escrito com chaves) abre um registro próprio:
  * entrada: `LDA 6,-1(6)`, `ST 2,0(6)`, `LDA 2,0(6)`;
  * saída: `LDA 6,1(2)`, `LD 2,0(2)`;
  * os locais do bloco começam em `-1`.
* Um corpo sem chaves (`if (c) x = 0;`) não abre registro. Para distinguir os dois casos, o parser marca o primeiro nó de um corpo com chaves (`TreeNode.braced`, em `src/cminus.y`).

### 3.4 Acesso a variáveis

Uma variável declarada `k` registros acima do corrente é alcançada subindo pela cadeia de `fp`:

```
LDA  3,0(2)     Salvando FP em R3
LD   2,0(2)     Voltando um escopo na pilha de execucao   (k vezes)
LD   0,d(2)     Carregar valor de ID em AC
LDA  2,0(3)     Restaurando FP
```

* `k = nível atual − nível da variável + chamadas em andamento`. Enquanto os argumentos de uma chamada são avaliados, o `fp` já aponta para o registro novo, e isso conta como mais um nível.
* Globais usam a base `gp`. Elas também sobem, o que não tem efeito mas é o que o gabarito faz. A exceção é a base de um elemento de vetor global (`LD 1,P(5)`), que nunca sobe.

### 3.5 Chamada e retorno

```
LDA 6,-1(6)   Posicao do novo FP
ST  2,0(6)    Salvar FP antigo
LDA 2,0(6)    FP atualizado
LDA 6,-1(6)   Posicao do endereco de retorno
  (para cada argumento: avalia em ac; LDA 6,-1(6); ST 0,0(6))
ST  7,-1(2)   Guarda endereco de retorno
LDA 7,-N(7)   Pular para a funcao
```

O retorno (valor já em `ac`):

```
LDA 1,0(2)    Salvar FP em AC1
LD  2,0(2)    FP volta para o escopo pai
LDA 6,1(1)    MP volta ao topo do frame anterior
LD  1,-1(1)   AC1 tem o endereco de retorno - 1
LDA 7,1(1)    Retorna para onde foi chamado
```

* Funções `void` recebem esse retorno ao fim do corpo, sempre.
* Funções `int` o recebem só se o corpo puder chegar ao fim sem `return`.

### 3.6 Expressões e atribuições

* Binária: avalia a esquerda e empilha; avalia a direita; desempilha em `ac1`; aplica `ADD/SUB/MUL/DIV 0,1,0`.
* Relacionais: `SUB 0,1,0`, `Jxx 0,2(7)`, `LDC 0,0(0)`, `LDA 7,1(7)`, `LDC 0,1(0)`.
* Atribuição: avalia o lado direito, copia para R4 (`LDA 4,0(0)`) e então armazena com `ST 4,...`. Para vetor, calcula o endereço antes de armazenar: índice, base em `ac1`, `SUB 0,1,0`, `LDC 1,1(0)`, `SUB 0,0,1`.

### 3.7 if e while (backpatch)

* `if`: condição; reserva o `JEQ`; `THEN branch`. Com `else`: reserva o `jmp to end`, imprime `ELSE branch`, faz o backpatch do `JEQ`, gera o `else` e faz o backpatch do salto final. Sem `else`: backpatch do `JEQ` logo após o `then`.
* `while`: guarda o endereço do teste; reserva o `JEQ` de saída; gera o corpo; `LDA 7,<teste>`; backpatch do `JEQ`.

Como `code.c` imprime cada instrução na hora em que é emitida, a ordem dos backpatches define a ordem das linhas no `.tm`. Ela segue a do gabarito.

### 3.8 Casos não cobertos pelos exemplos

Testados com programas avulsos no simulador:

* `return` dentro de bloco: antes do retorno, sai dos blocos abertos (`LD 2,0(2)` por nível). O gabarito trataria o registro do bloco como o da função.
* `return` em `main`: `HALT`.
* Chamada de função definida mais adiante: o salto é corrigido por backpatch quando a função é gerada.
* Índice de atribuição a vetor que contém chamada ou atribuição: R4 é salvo na pilha durante o cálculo do índice.
* Atribuição usada como expressão (`x = y = 3`, `a[0] = a[1] = 4`).
* Corpos vazios `{}`, globais escalares e vetores misturados, vetor repassado como parâmetro.

## 4. Menos unário e resultado do `make ddiff`

O gabarito emite `LDA 0,0,0` com o comentário "unario: AC = -AC". Essa instrução não nega o acumulador, e por isso o `mdc2` do gabarito imprime `0 1 2 9 4 -5 6 ...` em vez de `0 1 2 3 4 5 6 ...`. Aqui a mesma posição recebe:

```
SUB  0,5,0      unario: AC = -AC      (R5 = 0, logo ac = 0 - ac)
```

Isso mantém a numeração e todas as outras linhas idênticas às do gabarito. Verificação em `example/mdc2.cm`:

```
output(-(gdc(13,19)-1));     // 0
output(-(-(gdc(1,10))));     // 1
output(-gdc(-44,-46));       // 2 (gdc = -2)
```

Resultado do `../compLabAluno.bash`:

* `_lex`, `_syn`, `_tab`, `_err`: todos os diffs vazios.
  * Os de `_tab` ficaram vazios porque `printSymTab` (`src/symtab.c`) passou a imprimir os escopos na ordem do gabarito: global; depois os escopos não alcançáveis a partir de `main`, em ordem de criação; depois `main` e as funções que ela chama, em profundidade. Chamadas dentro de `if` não contam.
* `_gen`: vazios, exceto `block3`, `sort` e `mdc2`, que diferem só nas linhas do menos unário (1, 3 e 12 linhas).

## 5. Compilar e executar

```bash
cd build
cmake .. -DDOPARSE=TRUE
make                              # gera mycmcomp e tm
../compLabAluno.bash              # make ddiff das fases anteriores (obrigatório)

./mycmcomp ../example/mdc2.cm ../alunodetail/   # gera alunodetail/mdc2_gen.tm
./tm ../alunodetail/mdc2_gen.tm
```

Comandos do simulador (`h` lista todos):

| Comando | Efeito |
|---|---|
| `g` | executa até `HALT`; `IN` pede os valores, `OUT` imprime |
| `c` | reseta a simulação para rodar de novo sem reabrir o `tm` |
| `s <n>` | executa n instruções |
| `r` | imprime os registradores |
| `i <b> <n>` / `d <b> <n>` | imprime memória de instruções / dados |
| `t` | liga/desliga o trace de instruções |
| `p` | liga/desliga a contagem de instruções |
| `h` | ajuda |
| `q` | sai |

Scripts (a partir da raiz do repositório, com `build/` já compilado):

```bash
scripts/runtm mdc2 12 18          # roda alunodetail/mdc2_gen.tm com as entradas dadas
scripts/rungen                    # compila e confere todos os casos; sai com 0 se todos passam
```

`scripts/runtm` não recompila: usa o `_gen.tm` existente. `scripts/rungen` recompila cada exemplo e compara as linhas `OUT instruction prints:` com a saída esperada.

## 6. Saídas esperadas

| Programa | Entradas | Saída |
|---|---|---|
| `block2` | (nenhuma) | `2 1 3 4 5 1 2` |
| `mdc2` | `12 18` | `0 1 2 3 4 5 6 6 1 1 0` |
| `mdc2` | `-12 -18` | `0 1 2 3 4 5 6 -6 1 1 0` |
| `sort` | `5 3 9 1 7` | `-6 -2 -2 0 0 0 1 2 2 5 1 3 5 7 9` |
