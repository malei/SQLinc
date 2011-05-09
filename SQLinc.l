/* ----------------------------------------------
 * Ramo: Recuperacion de la Informacion
 * Nombre: Luis Alberto Ortega Araneda
 * Tarea: 1
 * ----------------------------------------------
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}
%%
INSERT              return INSERT;
INTO                return INTO;
VALUES              return VALUES;
CREATE              return CREATE;
TABLE               return TABLE;
INTEGER             return TYPE;
CHAR                return TYPE;
WHERE               return WHERE;
SELECT              return SELECT;
FROM                return FROM;
"="                 return EQUAL;            
[a-zA-Z]+\([0-9]+\) return TYPE;
\(                  return PO;
\)                  return PC;
,                   return COMMA;
\*                  return ALL;
;                   return SEMICOLON;
[a-zA-Z]+           yylval.txt=yytext; return WORD;
[0-9]+              yylval.txt=yytext; return WORD;
\n		            /* ignore end of line */;
[ \t]+		        /* ignore whitespace */;
%%
