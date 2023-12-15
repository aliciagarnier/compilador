%{
/*
-|--------------------------------------------------|-
 |    UNIFAL - Universidade Federal de Alfenas.
        BACHARELADO EM CIÊNCIA DA COMPUTAÇÃO.
 |Trabalho....: Registro e verificação de tipos
 |Disciplina..: Teoria de Linguagens e Compiladores
 |Professor...: Luiz Eduardo da Silva
 |Aluno.......: Alicia Garnier Duarte Franco  
 |Data........: 15/12/2023
-|--------------------------------------------------|-
*/

#include "sintatico.h" 

int erro (char *s); 
int yyerror(char *s); 
char atomo[100];
int numLinha = 1;

%}


identificador      [a-zA-Z]([a-zA-Z0-9])*
numero             [0-9]+
espaco             [ \t]+
novalinha          [\n]

%x coment

%option noyywrap

%%

programa              return T_PROGRAMA;
inicio                return T_INICIO;
fimprograma           return T_FIM;

leia                  return T_LEIA;
escreva               return T_ESCREVA;

se                    return T_SE;
entao                 return T_ENTAO;
senao                 return T_SENAO;
fimse                 return T_FIMSE;

enquanto              return T_ENQUANTO;
faca                  return T_FACA;
fimenquanto           return T_FIMENQUANTO;

inteiro               return T_INTEIRO;
logico                return T_LOGICO;

"+"                   return T_MAIS;
"-"                   return T_MENOS;
"*"                   return T_VEZES;
"<-"                  return T_ATRIB;
div                   return T_DIV;
">"                   return T_MAIOR;
"<"                   return T_MENOR;
"="                   return T_IGUAL;

e                     return T_E;
ou                    return T_OU;
nao                   return T_NAO;

"("                   return T_ABRE;
")"                   return T_FECHA;

"V"                   return T_V;
"F"                   return T_F;

def                   return T_DEF;
fimdef                return T_FIMDEF;
registro              return T_REGISTRO;

{identificador}       { strcpy(atomo, yytext); return T_IDENTIF;}
{identificador}"."    { 
                          strcpy(atomo, yytext);
                          atomo[strlen(atomo)-1] = 0;
                          return T_IDPONTO;
                      }

{numero}              { strcpy(atomo, yytext); return T_NUMERO;}
{espaco}         
{novalinha}           {numLinha++;}  

"//".*                 ;
"/*"                   BEGIN(coment);
<coment>"*/"           BEGIN(INITIAL);
<coment>.              ;
<coment>\n             {numLinha++;}


.                      erro(">>Erro léxico<<");
%%
