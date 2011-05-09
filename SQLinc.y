/* ----------------------------------------------
 * Ramo: Recuperacion de la Informacion
 * Nombre: Luis Alberto Ortega Araneda
 * Rol: 2266047-0
 * Tarea: 1
 * ----------------------------------------------
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#define YYSTYPE char *

void yyerror(const char *str)
{
    fprintf(stderr,"error: %s\n",str);
}
FILE *database = NULL;
FILE *schemedatabase = NULL;
char *extension_archivo = ".schema";

int yywrap()
{
    return 1;
}

main()
{
    yyparse();
}
%}

%union{
    int val;
    char * txt;
    short op;
}

%token <txt> WORD
%token <txt> TYPE
%token CREATE
%token INSERT
%token INTO
%token VALUES
%token TABLE 
%token COMMA
%token SEMICOLON
%token PO
%token PC
%token ALL
%token WHERE
%token EQUAL
%token SELECT
%token FROM

%%

queries: 
       | queries query
;

query: createquery
     | insertquery
     | selectquery
; 

selectquery: SELECT ALL FROM table_name where_query end_query 
;

where_query: WHERE WORD EQUAL WORD
             {
                 //printf("Tercer token: %s\n", $4);
                 char buffer[255];
                 char *result = NULL;
                 char *tipo = NULL;
                 char *ntipo = NULL;
                 char varTexto[255];
                 char buf[255];
                 char lineaRespuesta[255];
                 int comodin=0;
                 int largo = 1;
                 int i=0;
                 int SELECTEXITOSO = 0;

                //Obtener la consulta
                char *nomCon = NULL;
                char *valCon = NULL;
                
                    nomCon = strtok($2,"=");
                    valCon = strtok(NULL," ");
                
                printf("SELECT: %s con el valor: %s\n",nomCon, valCon);
                //=======================

                 //SELECTEXITOSO = 0;
                 while(fgets(buffer,255,schemedatabase)!=NULL){
                     
                     i=0;
                     while(varTexto[i]!='\0'){
                         varTexto[i] = '\0';
                         i++;
                     }
                     
                     result = strtok(buffer," ");
                     tipo = strtok(NULL, "(");
                     ntipo = tipo;
                     //printf("TIPO %s\n", ntipo);                        
                     tipo = strtok(NULL, ")");
                     if (tipo == NULL){ tipo = "1";  }
                     largo = atoi(tipo);
                     //Largo contiene el largo del dato a leer de database
                     //printf("%-14s %d: ", result, largo);
                     sprintf(buf,"%-14s %d: ", result, largo);
                     
                     strcat(lineaRespuesta,buf);

                     // largo tiene el largo y ntipo el tipo
                     if( strcmp(ntipo,"CHAR\n") == 0 || strcmp(ntipo,"CHAR") == 0 ){

                         fread(varTexto,sizeof(char),largo,database);
                         //printf("%-14s\n", varTexto);
                         sprintf(buf,"%-14s\n", varTexto);
                         strcat(lineaRespuesta,buf);
                         if((strcmp(result,nomCon)==0) && (strcmp(varTexto,valCon)==0))
                         {
                            SELECTEXITOSO = 1;
                         }
                     }
                     if(strcmp(ntipo,"VARCHAR")==0){

                         fread(varTexto,sizeof(char),1,database);
                         comodin = atoi(varTexto);
                         //printf("===%d==", comodin);
                         i=0;
                         while(varTexto[i]!='\0'){
                             varTexto[i] = '\0';
                             i++;
                         }


                         fread(varTexto,sizeof(char),comodin,database);
                         //printf("%-14s \n", varTexto);
                         sprintf(buf,"%-14s \n", varTexto);

                         if((strcmp(result,nomCon)==0) && (strcmp(varTexto,valCon)==0))
                         {
                            SELECTEXITOSO = 1;
                         }

                         strcat(lineaRespuesta,buf);
                         comodin = largo - comodin;
                         fread(varTexto,sizeof(char),comodin,database);
                     }
                     if(strcmp(ntipo,"INTEGER\n")==0){

                         fread(varTexto,sizeof(char),2,database);
                         //printf("%-14s", varTexto);
                         sprintf(buf,"%-14s", varTexto);


                         if((strcmp(result,nomCon)==0) && (strcmp(varTexto,valCon)==0))
                         {
                            SELECTEXITOSO = 1;
                         }


                         strcat(lineaRespuesta,buf);


                     }
                     
                 }
                 printf("\n");

                 if(SELECTEXITOSO == 1){
                     printf("%s\n",lineaRespuesta);
                 }
                 i=0;
                 while(lineaRespuesta[i]!='\0'){
                             lineaRespuesta[i] = '\0';
                             i++;
                 }
                 
             }
;


insertquery: insert_into_table VALUES PO valuelist PC end_query
;

createquery: create_table table_name PO word words PC end_query 
;

insert_into_table: INSERT INTO table_name
;

valuelist: insert_word COMMA valuelist
         | insert_word
;


insert_word: WORD
           {
               char buffer[255];
               char *result = NULL;
               int resultnumerico = 1;

               fgets(buffer,255,schemedatabase);
               //printf("la línea dice: %s\n", buffer);

               //Aqui se parsea el largo del valor a escribir.
               result = strtok(buffer, "(");
               result = strtok(NULL, ")");
               if(result != NULL){
                   resultnumerico = atoi(result);
               }

               result = strtok(buffer, " ");
               result = strtok(NULL, "("); 
               printf("El tipo de dato es:%s\n", result);
               printf("el largo es: %d\n", resultnumerico);
               if( strcmp(result,"CHAR\n") == 0 || strcmp(result,"CHAR") == 0 ){
                   fwrite($1, sizeof(char),resultnumerico,database);         
               }
               if( strcmp(result,"VARCHAR") == 0 ){
                   char str[1];
                   int i;
                   int largoBasura = 0;
                   i = strlen($1);
                   sprintf(str, "%d", i);
                   printf("El largo del string es: %s\n", str);
                   fwrite(str, sizeof(char),1,database);     
                   fwrite($1, sizeof(char),i,database);
                   largoBasura = resultnumerico - i;
                   for(i=0; i< largoBasura; i++){
                       fwrite("0", sizeof(char),1,database);
                   }
               }
               if( strcmp(result,"INTEGER\n") == 0){
                   fwrite($1, sizeof(char),2,database);     
               }
           }
;

end_query: SEMICOLON
           {
                fclose(database);
                fclose(schemedatabase);
           }
;

create_table: CREATE TABLE
;

table_name: WORD
            {
                //printf("nombre de la tabla: %s\n", $1);
                char *both = malloc(strlen($1) + strlen(extension_archivo) + 2);
                strcat(both,$1);
                strcat(both,extension_archivo); 
                schemedatabase = fopen(both,"a+");
                database = fopen($1,"a+");
            }
;

words: COMMA word words
     | 
;

word:
    | WORD TYPE
      { 
          //printf("\nnombre_word:%s y el segundo es: %s\n", $1, $2);
          //char *both = malloc(strlen($1) + strlen($2) + 2);
          char *both = malloc(strlen($1)+2);
          strcat(both,$1);
          strcat(both,"\n");
          //strcat(both,$2);
          fwrite(both, sizeof(char),strlen(both),schemedatabase);
      }
;
























%%
