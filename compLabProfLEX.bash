# permite mudar o diretorio onde estao as fontes do aluno
cmake .. -DCES41_SRC:FILEPATH=$1 -DDOPARSE=FALSE
make lexdiff VERBOSE=1
