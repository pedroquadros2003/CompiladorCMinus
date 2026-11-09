/* gets() foi removida das glibc recentes; este arquivo a reimplementa
   para que o tm.c compile sem modificacoes. Mesmo LINESIZE do tm.c. */
#include <stdio.h>
#include <string.h>

#define LINESIZE 121

char *gets(char *s)
{
  if (fgets(s, LINESIZE, stdin) == NULL) return NULL;
  s[strcspn(s, "\n")] = '\0';
  return s;
}
