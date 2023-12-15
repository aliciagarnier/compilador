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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c"
#include "utils.c"

int contaVar = 0;
int rotulo = 0;
int ehRegistro = 0;
int end;
int tipo;
int tam; 
int pos;
int posTabelaSimbolos = 1; 
int des = 0; 
int tamregistro; 
  
struct no *L; 

%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQUANTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa


%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%% // regras 

programa 
   : cabecalho definicoes variaveis 
        { 
         
            mostraTabela();
            empilha (contaVar);
            if (contaVar)
               fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
        }
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if (conta)
               fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
   ;

cabecalho
   : T_PROGRAMA T_IDENTIF
       { fprintf(yyout, "\tINPP\n"); 
         iniciaTabela();
       }
   ;

tipo
   : T_LOGICO
         { 
            // #TODO 1 - FEITO
            // Além do tipo, precisa guardar o TAM (tamanho) do
            // tipo e a POS (posição) do tipo na tab. símbolos
            tipo = LOG; 
            tam = 1; 
            pos = 1;
           
         }
   | T_INTEIRO
         { 
            tipo = INT;
            tam = 1; 
            pos = 0; 
           
        }
   | T_REGISTRO T_IDENTIF
         { 
            // TODO #2 - FEITO
            // Aqui tem uma chamada de buscaSimbolo para encontrar
            // as informações de TAM e POS do registro. 
            int i = buscaSimbolo(atomo);
            tipo = REG; 
            tam = tabSimb[i].tam;
            pos = tabSimb[i].pos; 
            
         }
   ;

definicoes
   : define definicoes
   | /* vazio */
   ;

define 
   : T_DEF
        {
            // TODO #3 - FEITO
            L = NULL; 
        } 
   definicao_campos T_FIMDEF T_IDENTIF
       {
           // TODO #4 - FEITO
           // Inserir esse novo tipo na tabela de simbolos
           // com a lista que foi montada
            strcpy(elemTab.id, atomo);
            elemTab.endereco = -1; 
            elemTab.tipo = REG; 
            elemTab.tam = tamregistro;
            elemTab.pos = ++posTabelaSimbolos;
            elemTab.lista_campos = L;
            insereSimbolo(elemTab);

            L = NULL; 
            tamregistro = 0; 
            des = 0; 
       }
   ;

definicao_campos
   : tipo lista_campos definicao_campos
   | tipo lista_campos
   ;

lista_campos
   : lista_campos T_IDENTIF
      {
         // TODO #5 - FEITO
         // acrescentar esse campo na lista de campos que
         // esta sendo construida
         // o deslocamento (endereço) do próximo campo
         // será o deslocamento anterior mais o tamanho desse campo   
         L = insere(L, atomo, tipo, pos, des, tam);
         des = des + tam; 
         tamregistro = tamregistro + tam;  
           
      }
   | T_IDENTIF
      {
       L = insere(L, atomo, tipo, pos, des, tam);
       des = des + tam; 
       tamregistro = tamregistro + tam; 
      }
   ;

variaveis
   : /* vazio */
   | declaracao_variaveis
   ;

declaracao_variaveis
   : tipo lista_variaveis declaracao_variaveis
   | tipo lista_variaveis
   ;

lista_variaveis
   : lista_variaveis
     T_IDENTIF 
        { 

             // TODO #6 - FEITO
            // Tem outros campos para acrescentar na tab. símbolos
            strcpy(elemTab.id, atomo);
            elemTab.endereco = contaVar; 
            elemTab.tipo = tipo;
            elemTab.tam = tam; 
            elemTab.pos = pos; 
            elemTab.lista_campos = tabSimb[pos].lista_campos; 
            insereSimbolo(elemTab);
            
            // TODO #7 - FEITO
            // Se a variavel for registro
            // contaVar = contaVar + TAM (tamanho do registro)
            if (tipo == REG) 
            {
            contaVar = contaVar + tam; 
            } else {
             contaVar++;
            }
        }
   | T_IDENTIF
       { 
            strcpy(elemTab.id, atomo);
            elemTab.endereco = contaVar; 
            elemTab.tipo = tipo;
            elemTab.tam = tam; 
            elemTab.pos = pos; 
            elemTab.lista_campos = tabSimb[pos].lista_campos; 
            insereSimbolo(elemTab);

           if (tipo == REG) 
           {
            contaVar = contaVar + tam; 
           } else {
            contaVar++;
           }
         
       }
   ;

lista_comandos
   : /* vazio */
   | comando lista_comandos
   ;

comando
   : entrada_saida
   | atribuicao
   | selecao
   | repeticao
   ;

entrada_saida
   : entrada
   | saida 
   ;

entrada
   : T_LEIA expressao_acesso
       { 
          // TODO #8 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de leituras
            for(int i = 0; i < tam; i++) 
            {
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", des + i);
           
       }
    }
   ;

saida
   : T_ESCREVA expressao
       {  
         // TODO #9 - FEITO
         // Se for registro, tem que fazer uma repetição do
         // TAM do registro de escritas
         int tip = desempilha(); 
            if(tip == REG) {

               for(int i = 0; i < tam; i++) 
               {
                  fprintf(yyout, "\tESCR\n"); 
               }

            } else {
             fprintf(yyout, "\tESCR\n"); 
            }
      }
   ;

atribuicao
   : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tam);
          empilha(des);
          empilha(tipo);
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha();
          int tipvar = desempilha();
          int des = desempilha();
          int tam = desempilha();
          if (tipexp != tipvar)
             yyerror("Incompatibilidade de tipo!");
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
          for (int i = 0; i < tam; i++)
             fprintf(yyout, "\tARZG\t%d\n", des + i); 
       }
   ;

selecao
   : T_SE expressao T_ENTAO 
       {  
          int t = desempilha();
          if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
          fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
          empilha(rotulo);
       }
     lista_comandos T_SENAO 
       {  
           fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
           int rot = desempilha(); 
           fprintf(yyout, "L%d\tNADA\n", rot);
           empilha(rotulo); 
       }
     lista_comandos T_FIMSE
       {  
          int rot = desempilha();
          fprintf(yyout, "L%d\tNADA\n", rot);  
       }
   ;

repeticao
   : T_ENQUANTO
       { 
         fprintf(yyout, "L%d\tNADA\n", ++rotulo);
         empilha(rotulo);  
       }
     expressao T_FACA 
       {  
         int t = desempilha();
         if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
         fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
         empilha(rotulo);
       }
     lista_comandos T_FIMENQUANTO
       { 
          int rot1 = desempilha();
          int rot2 = desempilha();
          fprintf(yyout, "\tDSVS\tL%d\n", rot2);
          fprintf(yyout, "L%d\tNADA\n", rot1);  
       }
   ;

expressao
   : expressao T_VEZES expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");  }
   | expressao T_DIV expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tDIVI\n");  }
   | expressao T_MAIS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n");  }
   | expressao T_MENOS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");  }
   | expressao T_MAIOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");  }
   | expressao T_MENOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n");  }
   | expressao T_IGUAL expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n");  }
   | expressao T_E expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");  }
   | expressao T_OU expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");  }
   | termo
   ;

expressao_acesso
   : T_IDPONTO
       {   //--- Primeiro nome do registro
           if (!ehRegistro) {
              ehRegistro = 1;
              // TODO #12 - FEITO
              // 1. busca o simbolo na tabela de símbolos
              // 2. se não for do tipo registo tem erro
              // 3. guardar o TAM, POS e DES desse t_IDENTIF
              int posicao = buscaSimbolo (atomo); 
                  if(tabSimb[posicao].tipo != REG) 
                  {
                        yyerror("O identificador não é registro!");
                  } 
               tam = tabSimb[posicao].tam; 
               pos = tabSimb[posicao].pos; 
               L = tabSimb[posicao].lista_campos;
               des = tabSimb[posicao].endereco; 
              
               
           } else {
              //--- Campo que eh registro
              // 1. busca esse campo na lista de campos
              // 2. se não encontrar, erro
              // 3. se encontrar e não for registro, erro
              // 4. guardar o TAM, POS e DES desse CAMPO
              ptno campo = buscaCampo(L, atomo); 
                if (campo != NULL) 
                {
                    if(campo->tipo != REG) 
                    {
                       yyerror("O campo não é registro!");
                    }
                  tam = campo->tam;
                  pos = campo->pos; 
                  des = des + campo->desl; 
                  L  = tabSimb[pos].lista_campos; 
                } else {
                  yyerror("O campo não existe na estrutura");
                }
           }
       }
     expressao_acesso
   | T_IDENTIF
       {   
           if (ehRegistro) {
               // TODO #13 - FEITO
               // 1. buscar esse campo na lista de campos
               // 2. Se não encontrar, erro
               // 3. guardar o TAM, DES e TIPO desse campo.
               //    o tipo (TIP) nesse caso é a posição do tipo
               //    na tabela de simbolos

               ptno campo = buscaCampo(L, atomo); 
                  if(campo == NULL) 
                  { 
                     yyerror("O campo não existe na estrutura");
                  } 
                   tam = campo->tam; 
                   des = des + campo->desl; 
                   tipo = campo->pos; 

           }
           else {
              // TODO #14
              // guardar TAM, DES e TIPO dessa variável
              int posicao = buscaSimbolo (atomo);
                  if(posicao == -1) {
                     yyerror("Variável não declarada!");
                  }
              tam = tabSimb[posicao].tam;
              tipo = tabSimb[posicao].tipo;
              des = tabSimb[posicao].endereco;  
              
              
           }
           ehRegistro = 0;
       };

termo
   : expressao_acesso
       {
         // TODO #15 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de CRVG (em ondem inversa)
          if (tipo == REG) {
            for (int i = 0; i < tam; i++) 
            {
            fprintf(yyout, "\tCRVG\t%d\n", des + (tam - 1) - i);

            }
         } else {
          fprintf(yyout, "\tCRVG\t%d\n", des);  
          }

         empilha(tipo);
       }
   | T_NUMERO
       {  
          fprintf(yyout, "\tCRCT\t%s\n", atomo);  
          empilha(INT);
       }
   | T_V
       {  
          fprintf(yyout, "\tCRCT\t1\n");
          empilha(LOG);
       }
   | T_F
       {  
          fprintf(yyout, "\tCRCT\t0\n"); 
          empilha(LOG);
       }
   | T_NAO termo
       {  
          int t = desempilha();
          if (t != LOG)
              yyerror ("Incompatibilidade de tipo!");
          fprintf(yyout, "\tNEGA\n");
          empilha(LOG);
       }
   | T_ABRE expressao T_FECHA
   ;
%%


int erro(char *s) {
   printf("ERRO: %s\n", s); 
   exit(10); 
}

int yyerror(char *s) {
   erro(s); 
}


int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n\n");
    return 0;
}