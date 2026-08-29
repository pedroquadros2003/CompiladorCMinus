# Guia de Laboratório: Analisador Léxico (Scanner) para C-

Este documento apresenta uma explicação detalhada sobre a estrutura do laboratório de compiladores, o funcionamento dos scripts fornecidos e um guia passo a passo de como proceder para construir o analisador léxico (scanner) da linguagem **C-**.

---

## 1. O que está acontecendo neste Laboratório?

O objetivo deste laboratório é construir um compilador para a linguagem **C-** (C Minus), que é um subconjunto simplificado da linguagem C (definida no Apêndice A do livro *Compiler Construction: Principles and Practice* de Kenneth C. Louden).

Atualmente, o projeto contém a estrutura de um compilador de outra linguagem chamada **TINY** (do mesmo livro). O seu trabalho é adaptar essa base para suportar a linguagem **C-**.

A primeira fase, na qual você se encontra, é a **Análise Léxica (Scanner)**. Nela, você deve ler um arquivo fonte `.cm` e transformá-lo em uma sequência de tokens (palavras-chave, identificadores, números, símbolos especiais), ignorando espaços em branco e comentários, além de identificar caracteres inválidos (erros léxicos).

---

## 2. Especificação Léxica da Linguagem C-

Para a análise léxica da linguagem C-, você deve reconhecer os seguintes elementos:

*   **Palavras-chave (case-sensitive, em minúsculas):**
    `else`, `if`, `int`, `return`, `void`, `while`.
*   **Símbolos Especiais:**
    *   Aritméticos: `+`, `-`, `*`, `/`
    *   Relacionais: `<`, `<=`, `>`, `>=`, `==`, `!=`
    *   Atribuição: `=`
    *   Pontuação: `;`, `,`
    *   Delimitadores: `(`, `)`, `[`, `]`, `{`, `}`
*   **Identificadores (ID):** Uma ou mais letras (ex: `[a-zA-Z]+`).
*   **Números (NUM):** Um ou mais dígitos (ex: `[0-9]+`).
*   **Comentários:** Devem ser delimitados por `/*` e `*/`.
    > [!IMPORTANT]
    > Diferente da linguagem TINY (que usa comentários entre chaves `{ ... }` em uma única linha), os comentários em C- podem ocupar **múltiplas linhas** e não podem ser aninhados.
*   **Espaços em Branco:** Espaços (` `), tabulações (`\t`) e quebras de linha (`\n`) devem ser ignorados, mas as quebras de linha precisam ser contadas para sabermos a linha correta (`lineno`) em que os tokens e erros ocorrem.

---

## 3. Estrutura de Arquivos e Diretórios

Os principais arquivos que você precisará entender e modificar estão na pasta `src/`:

*   [`src/globals.h`](file:///home/peuqu/ctc41/src/globals.h): Define os tipos globais e o enum `TokenType`. Atualmente, contém os tokens do TINY. Você precisará alterar esse enum para refletir os tokens do C-.
*   [`src/util.c`](file:///home/peuqu/ctc41/src/util.c) (e [`util.h`](file:///home/peuqu/ctc41/src/util.h)): Contém funções auxiliares. A função `printToken` é responsável por formatar a saída dos tokens. Você precisará editá-la para reconhecer e imprimir os tokens de C- exatamente no formato do gabarito.
*   [`src/cminus.l`](file:///home/peuqu/ctc41/src/cminus.l): Especificação do Flex. É aqui que você escreve as expressões regulares para identificar cada token e a ação associada (retornar o token correspondente). Atualmente está idêntico ao do TINY.
*   [`src/main.c`](file:///home/peuqu/ctc41/src/main.c): Ponto de entrada do compilador. Na fase atual, o `#define NO_PARSE TRUE` está ativado, o que significa que o compilador executa apenas o loop de leitura de tokens (`getToken()`).

Outros diretórios importantes:
*   `example/`: Códigos de teste escritos em C- (`.cm`) com e sem erros.
*   `detailonlylex/`: O gabarito oficial da análise léxica. Contém a saída esperada dos tokens (`*_lex.txt`) e dos erros (`*_err.txt`) para cada caso de teste da pasta `example`.
*   `alunodetail/`: Onde o seu compilador salvará as saídas geradas por ele durante os testes (`*_lex.txt` e `*_err.txt`).
*   `alunoout/`: Onde são salvas as saídas da compilação e os arquivos `.diff` gerais.

---

## 4. O que os Scripts fazem?

O laboratório fornece scripts prontos em bash e python para automatizar a compilação e a comparação com o gabarito:

1.  [`killbuild`](file:///home/peuqu/ctc41/killbuild):
    Apaga as pastas temporárias de compilação (`build`), de saídas do aluno (`alunoout`) e de detalhes (`alunodetail`) e as recria do zero. É muito útil quando você quer garantir uma compilação totalmente limpa sem arquivos velhos.
2.  [`compLabAlunoLEX.bash`](file:///home/peuqu/ctc41/compLabAlunoLEX.bash):
    **Este é o script que você deve rodar agora.** Ele:
    *   Configura o CMake com `-DDOPARSE=FALSE` (indica que o Bison não será usado e estamos apenas compilando e testando o scanner/analisador léxico).
    *   Roda o comando `make lexdiff`, que compila o seu compilador (`mycmcomp`), executa-o sobre todos os arquivos da pasta `example/`, salvando as saídas detalhadas em `alunodetail/`, e depois executa um `diff` comparando as suas saídas léxicas contra o gabarito oficial em `detailonlylex/`.
3.  [`compLabAluno.bash`](file:///home/peuqu/ctc41/compLabAluno.bash):
    Usado em etapas futuras (análise sintática e semântica). Roda o cmake com `-DDOPARSE=TRUE` (habilita o parser do Bison) e compara os resultados contra a pasta `detail/` executando `make ddiff`.
4.  [`compLabProfLEX.bash`](file:///home/peuqu/ctc41/compLabProfLEX.bash) / [`compLabProf.bash`](file:///home/peuqu/ctc41/compLabProf.bash):
    Semelhantes aos scripts de aluno, mas aceitam um argumento com o caminho do diretório fonte do aluno. Utilizados pelo professor para automação da correção.
5.  `scripts/runcmcomp`:
    Roda o compilador compilado (`mycmcomp`) em cada arquivo `.cm` do diretório `example/` e salva o resultado.
6.  `scripts/runLEXdiff`:
    Roda a comparação `diff -ZbB` entre os arquivos `.txt` em `alunodetail/` e `detailonlylex/`, gerando arquivos de extensão `.diff`.
7.  [`compare_diffs.py`](file:///home/peuqu/ctc41/compare_diffs.py):
    Um script em Python usado na etapa de Tabela de Símbolos. Como a ordem dos símbolos na tabela pode variar, ele converte as saídas dos diffs em conjuntos (sets) e verifica se os elementos são os mesmos, ignorando apenas a ordenação de linhas.

---

## 5. Como o Formato do Log do Scanner Funciona?

O gabarito em `detailonlylex/` exige um formato exato de saída:
*   A linha original do código de entrada é exibida precedida pelo número da linha e dois pontos:
    `5:     int x@test = 99;`
*   Cada token detectado é impresso em uma nova linha com uma tabulação (`\t`), o número da linha correspondente, dois pontos, um espaço e a descrição do token:
    *   Palavras-chave: `\t5: reserved word: int`
    *   Identificadores: `\t5: ID, name= x`
    *   Números: `\t5: NUM, val= 99`
    *   Caracteres especiais (como `=`, `;`): `\t5: =` e `\t5: ;`
    *   Erros léxicos (caracteres inválidos): `\t5: ERROR: @`
    *   Fim do arquivo: `\t7: EOF`

Qualquer erro léxico também deve gerar uma mensagem na saída de erros (`stderr` / arquivo `_err.txt`) no formato:
`ERROR: @`

---

## 6. Passo a Passo para Fazer este Laboratório (Scanner)

Aqui está o roteiro ordenado que você deve seguir para implementar o seu scanner e passar nos testes:

### Passo 1: Limpeza Inicial do Ambiente
No terminal, execute o script de limpeza a partir da raiz do projeto para criar a estrutura necessária:
```bash
./killbuild
```

### Passo 2: Atualização dos Tokens Globais
Abra o arquivo [`src/globals.h`](file:///home/peuqu/ctc41/src/globals.h) e modifique o enum `TokenType`:
1.  Remova os tokens específicos do TINY que não existem em C- (como `THEN`, `END`, `REPEAT`, `UNTIL`, `READ`, `WRITE` e `ASSIGN` do tipo `:=`).
2.  Adicione as palavras-chave do C-: `RETURN` e `WHILE` (além de `IF`, `ELSE`, `INT`, `VOID`).
3.  Adicione os novos tokens de operadores e delimitadores: `LTE` (`<=`), `GTE` (`>=`), `EQ` (`==`), `NE` (`!=`), `COMMA` (`,`), `LBRACKET` (`[`), `RBRACKET` (`]`), `LBRACE` (`{`), `RBRACE` (`}`).

### Passo 3: Ajuste da Função de Impressão dos Tokens
Abra o arquivo [`src/util.c`](file:///home/peuqu/ctc41/src/util.c) e localize a função `printToken`:
1.  Atualize a lista de palavras-chave na estrutura `switch (token)` para corresponder às palavras-chave do C- e imprimi-las como `reserved word: %s\n`.
2.  Atualize os cases dos operadores existentes e adicione os novos (como `LTE` imprimindo `<=`, `NE` imprimindo `!=`, `LBRACE` imprimindo `{`, etc.), garantindo que os delimitadores e operadores especiais sejam impressos exatamente como o seu respectivo caractere (por exemplo, `[` deve imprimir `[\n` e `!=` deve imprimir `!=\n`).
3.  Garanta que o `case ERROR` continue usando `pce("ERROR: %s\n", tokenString)`. Isso faz com que erros sejam gravados tanto na saída léxica quanto no arquivo de log de erros.

### Passo 4: Implementação das Regras Léxicas no Flex
Abra o arquivo [`src/cminus.l`](file:///home/peuqu/ctc41/src/cminus.l). Esta é a parte mais importante:
1.  **Palavras-chave:** Substitua a lista de regras das palavras-chave do TINY pelas do C- (ex: `"return" {return RETURN;}`).
2.  **Operadores e Delimitadores:** Troque os operadores antigos pelos novos. Note que alguns caracteres como `*`, `(`, `)` precisam ser tratados com cuidado ou escapados se necessário, e operadores compostos como `<=` ou `==` devem vir antes dos operadores simples `<` ou `=` para que o Flex case o padrão mais longo primeiro.
3.  **Comentários:** Remova a regra de comentário antiga (`{ ... }`) e crie uma regra para reconhecer comentários no estilo C `/* ... */`.
    *   *Dica de implementação:* Você pode usar estados de inicialização do Flex (`%x COMMENT`) ou ler caracteres sequencialmente com `input()` em um laço em C, similar ao que era feito no TINY, mas buscando a sequência `*/`. Lembre-se de somar `lineno++` sempre que encontrar um caractere `\n` dentro do comentário!
4.  **Caracteres Inválidos:** A regra padrão `.` (ponto) ao final das regras deve capturar qualquer caractere que não tenha casado com as regras anteriores, copiá-lo para `tokenString` e retornar `ERROR`.
5.  **Quebras de Linha e Espaços:** Certifique-se de que a regra do `\n` incremente `lineno` e que espaços em branco sejam descartados corretamente.

### Passo 5: Compilação e Teste das Diferenças
Vá para a pasta de build e execute o script de teste de análise léxica:
```bash
cd build
../compLabAlunoLEX.bash
```
Isso compilará o compilador e gerará arquivos de diff na pasta `alunodetail/`.

### Passo 6: Análise de Diffs e Correção
Inspecione as diferenças geradas usando ferramentas de terminal ou visualizadores gráficos:
*   Para visualizar todas as diferenças de forma colorida pelo terminal:
    ```bash
    batcat ../alunodetail/*lex*.diff
    ```
*   Para comparar as pastas interativamente lado a lado:
    ```bash
    meld ../alunodetail/ ../detailonlylex/
    ```
*   Ajuste suas regras no `cminus.l` e a impressão no `util.c` até que o comando do **Passo 5** resulte em **diff zero** (nenhuma diferença de caracteres ou espaçamentos entre a sua saída e a do professor).

---

## 7. Dicas de Depuração e Debug (Recomendadas pelo Professor)

Para facilitar a detecção de bugs durante o desenvolvimento (especialmente falhas de segmentação ou erros de formatação), utilize as seguintes diretrizes:

### A. Depuração de Segfaults e Flush de Logs (`DEBUG_LOG_ALWAYS_FLUSH`)
Em C, a função `printf` e os gravadores de arquivos utilizam buffers na memória. Em caso de **Segmentation Fault (crash)** do compilador, o processo é encerrado de forma abrupta antes que os dados no buffer sejam impressos no terminal ou gravados nos arquivos de log. Isso dificulta saber exatamente até que linha o programa executou antes de quebrar.
*   **Como resolver temporariamente**: No arquivo [`lib/log.c`](file:///home/peuqu/ctc41/lib/log.c), localize a macro `#define DEBUG_LOG_ALWAYS_FLUSH` e mude seu valor de `0` para `1`.
*   **O que acontece**: Com esse valor definido como `1`, o logger forçará a limpeza imediata do buffer (`fflush`) em cada chamada das funções `pc()`, `pce()` e `pp()`, garantindo que todas as mensagens anteriores ao crash sejam salvas nos logs.
*   > [!WARNING]
    > Isso torna a gravação de arquivos muito mais lenta, pois acessa o disco a cada print. Certifique-se de reverter o valor da macro para `0` antes de submeter a versão final do seu laboratório.

### B. Depuração e Execução Manual (Fora dos Scripts de Teste)
Quando o compilador é rodado pelos scripts de automação, as saídas são redirecionadas e fica difícil visualizar mensagens de erro de segmentação. Para depurar um caso de teste individualmente em tempo real no terminal:
1. Vá até o diretório de build:
   ```bash
   cd build
   ```
2. Execute o compilador manualmente, passando o arquivo de teste C- desejado como argumento:
   ```bash
   ./mycmcomp ../example/mdc.cm
   ```
3. Todas as mensagens serão exibidas diretamente na tela. Os logs detalhados de cada fase ainda serão gerados automaticamente na pasta temporária `/tmp/` do sistema (ou você pode passar uma pasta alternativa como segundo argumento).

### C. Visualização Detalhada de Compilação (`VERBOSE=1`)
Se houver algum erro de linkagem ou compilação do seu próprio compilador com o GCC, adicione a opção `VERBOSE=1` na execução do `make` para imprimir no terminal os comandos do compilador na íntegra com todos os caminhos e flags:
```bash
make lexdiff VERBOSE=1
```

### D. Comandos úteis no Simulador TM (Geração de Código)
Para as etapas de geração de código, ao rodar o simulador `tm.c` compilado com `gcc -o tm tm.c`, você pode passar a flag `-h` para ver a ajuda das instruções. Os comandos principais de simulação no terminal do `tm` são:
*   `g` (go): Inicia a execução do programa compilado.
*   `c` (clear): Limpa a memória e os registradores para que você possa rodar o código novamente sem precisar fechar e reabrir o simulador.

### E. Ferramentas de Comparação de Diffs (`batcat` e `meld`)
O professor recomenda utilizar essas ferramentas para visualizar as diferenças entre os seus logs e o gabarito oficial de forma muito ágil:
*   **`batcat` (Visualizador de Terminal)**: Exibe arquivos com numeração de linhas e colorização de sintaxe.
    *   Ver todos os arquivos de diferenças de análise léxica de uma vez:
        ```bash
        batcat ../alunodetail/*lex*.diff
        ```
    *   Ver todas as saídas geradas em todas as fases para o arquivo `mdc`:
        ```bash
        batcat ../alunodetail/mdc_*txt
        ```
    *   Ver todos os diffs de todas as fases para o arquivo `mdc`:
        ```bash
        batcat ../alunodetail/mdc_*diff
        ```
*   **`meld` (Comparador Gráfico)**: Abre uma interface visual que destaca as diferenças lado a lado.
    *   Comparar os dois diretórios inteiros para identificar arquivos faltantes ou diferentes:
        ```bash
        meld ../alunodetail/ ../detailonlylex/
        ```

### F. Opções do Comando `diff` Clássico e Alerta do macOS
Os scripts de validação executam por baixo dos panos o comando `diff -ZbB`. Entenda o que cada flag faz:
*   `-Z` ou `--ignore-trailing-space`: Ignora espaços em branco ao final da linha.
*   `-b` ou `--ignore-space-change`: Ignora mudanças na quantidade de espaços em branco.
*   `-B` ou `--ignore-blank-lines`: Ignora linhas totalmente em branco.
*   > [!IMPORTANT]
    > **Atenção usuários de macOS (Mac)**: O comando `diff` do Mac **não suporta** a flag `-Z`. Se estiver compilando em um Mac, você precisará editar os scripts dentro da pasta `scripts/` (como `runLEXdiff`, `rundetaildiff`) e remover a opção `-Z` dos comandos `diff` para que funcionem sem erros.

---
*Bons estudos! Se precisar de ajuda para entender qualquer comportamento de regras do Flex ou trecho de lógica, basta perguntar.*
