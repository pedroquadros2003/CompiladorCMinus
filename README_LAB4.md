# Laboratório 4: Geração de Código para a Máquina TM

## 1. Objetivo

Gerar, a partir da AST já validada pelas fases 1–3, código para o simulador `tm`. O resultado é gravado em `alunodetail/<exemplo>_gen.tm`.

Conforme `instructions/regras_versoes260812.txt` (seção 5):

* a comparação com `diff` é irrelevante nesta fase; o que importa é o código compilado executar corretamente os exemplos funcionais;
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
| `src/main.c` | `NO_CODE` passa a `FALSE`; após `doneTABstartGEN()`, se não houve erro, chama `codeGen()`. A emissão é controlada por `TraceCode` (comentários no `.tm`). |
| `tools/gets_compat.c` | Reimplementa `gets()` (mesmo `LINESIZE` de `tm.c`). |
| `CMakeLists.txt` (alvo `tm`) | Compila `tm.c` + `tools/gets_compat.c` com `-std=gnu89 -w`. |
| `scripts/runtm` | Executa um `_gen.tm` no simulador com entradas fornecidas. |
| `scripts/rungen` | Compila os exemplos, roda no `tm` e compara as saídas `OUT` com o esperado. |

`tm.c` não foi modificado. O motivo do `gets_compat.c`: `tm.c` usa `gets()`, removida das glibc recentes (C11); sem a shim o simulador não linka. Fornecê-la em arquivo separado evita editar o código do professor.

## 3. Convenções de geração

### 3.1 Registradores

| Reg | Nome | Uso |
|---|---|---|
| 0 | `ac` | Acumulador; resultado de toda expressão. |
| 1 | `ac1` | Segundo operando / temporário. |
| 2 | `fp` | Base do registro de ativação corrente. |
| 5 | `gp` | Base das globais (valor 0). |
| 6 | `mp` | Topo da pilha: próximo slot livre. |
| 7 | `PC` | Contador de programa. |

### 3.2 Memória

* Globais: a partir de `gp = 0`, endereços crescentes na ordem de declaração.
* Pilha: cresce para baixo a partir de `maxaddress` (lido de `dMem[0]` no preâmbulo: `LD mp,0(ac)`, `LDA fp,0(mp)`, `ST ac,0(ac)`).
* Temporários de expressão: empilhados em `mp` (`push`: `ST r,0(mp)` + `LDA mp,-1(mp)`; `pop`: `LDA mp,1(mp)` + `LD r,0(mp)`).

### 3.3 Registro de ativação (relativo a `fp`)

| Deslocamento | Conteúdo |
|---|---|
| `0` | `fp` do chamador |
| `-1` | endereço de retorno |
| `-2, -3, ...` | parâmetros, na ordem de declaração (vetor: endereço do 1º elemento) |
| abaixo dos parâmetros | locais de todos os blocos da função |

### 3.4 Chamada

Emitida em `genCall`, na ordem:

```
ST   fp,0(mp)        salva fp do chamador
LDA  mp,-2(mp)       reserva fp antigo e retorno
  (para cada argumento, em ordem: avalia em ac; push)
LDA  fp,2+n(mp)      fp do novo frame (n = número de argumentos)
LDA  ac,2(PC)        endereço de retorno
ST   ac,-1(fp)       salva endereço de retorno
LDC  PC,<entrada>(0) salta para a função
```

Prólogo da função (backpatch, depois que se conhece o tamanho do frame):

```
LDA  mp,<frameBottom>(fp)   reserva as variáveis locais
```

### 3.5 Retorno

Valor (se houver) já está em `ac`:

```
LDA  mp,0(fp)        desempilha o frame
LD   ac1,-1(fp)      endereço de retorno
LD   fp,0(fp)        restaura fp do chamador
LDA  PC,0(ac1)       retorna
```

`genFunction` emite esse mesmo retorno ao fim do corpo, cobrindo funções `void` sem `return`.

### 3.6 Vetores

* Vetor global ou local: `LDA reg,loc(gp|fp)` produz o endereço do 1º elemento.
* Vetor como parâmetro: passa-se o endereço do 1º elemento (referência). Dentro da função, `LD reg,loc(fp)` recupera esse endereço.
* `v[i]`: avalia `i` em `ac`, carrega a base em `ac1`, `ADD ac,ac1,ac`; depois `LD ac,0(ac)` (leitura) ou `ST` (escrita, com o endereço empilhado enquanto o lado direito é avaliado).
* Ao passar `v` como argumento (sem índice) é enviado apenas o endereço base, seja `v` local, global ou parâmetro.

### 3.7 Blocos aninhados

Não há static chain nem frame por bloco. Cada declaração local recebe um deslocamento fixo no frame da função; ao fechar um bloco (`scopeClose`), o deslocamento é restaurado, de modo que blocos irmãos reutilizam o mesmo espaço. O tamanho final do frame (`frameBottom`) é o menor deslocamento atingido e vai no prólogo. O sombreamento é resolvido por uma pilha de símbolos própria do gerador, com a mesma regra de escopo da análise semântica (if, while e blocos abrem escopo).

### 3.8 Expressões

Operação binária: avalia o operando esquerdo, `push`; avalia o direito; `pop` em `ac1`; aplica `ADD/SUB/MUL/DIV ac,ac1,ac`. A ordem esquerda-direita é preservada (importa para `-` e `/`).

Relacionais produzem 0 ou 1 em `ac`:

```
SUB  ac,ac1,ac
Jxx  ac,2(PC)       Jxx = JLT, JLE, JGT, JGE, JEQ, JNE
LDC  ac,0(0)        falso
LDA  PC,1(PC)
LDC  ac,1(0)        verdadeiro
```

### 3.9 if e while (backpatch)

* `if`: avalia a condição; reserva 1 slot (`emitSkip(1)`); gera o `then`; se há `else`, reserva outro slot para o salto sobre ele. Os slots são preenchidos depois com `JEQ ac,<destino>` e `LDA PC,<destino>` (`emitBackup`, `emitRM_Abs`, `emitRestore`).
* `while`: guarda o endereço do teste; reserva um slot para o `JEQ` de saída; gera o corpo; emite `LDA PC,<teste>`; faz o backpatch do `JEQ` para a instrução seguinte.

## 4. Menos unário

Em vários pontos o gabarito (`detail/mdc2_gen.tm`) emite `LDA 0,0,0` com o comentário "unario: AC = -AC". Essa instrução não nega o acumulador, e por isso o `mdc2` do gabarito imprime `0 1 2 9 4 -5 6 ...` em vez de `0 1 2 3 4 5 6 ...`. Aqui a negação é feita sempre carregando 0 em `ac1` e subtraindo:

```
LDC  ac1,0(0)
SUB  ac,ac1,ac      ac = 0 - ac
```

Como `SUB r,s,t` calcula `r = s - t`, o resultado é `-ac`. Verificação em `example/mdc2.cm`:

```
output(-(gdc(13,19)-1));     // 0
output(-(-(gdc(1,10))));     // 1
output(-gdc(-44,-46));       // 2 (gdc = -2)
```

Essas linhas fazem parte da saída esperada de `mdc2` (seção 6); qualquer erro no menos unário altera os valores impressos.

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
