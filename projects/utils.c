
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
#include <string.h>


#define TAM_TAB 100
#define TAM_PIL 100

enum
{
    INT,
    LOG,
    REG
};

char nomeTipo[3][4] = {"INT", "LOG", "REG"};


//pilha semantica
int Pilha[TAM_PIL];
int topo = -1;


typedef struct no *ptno;

struct no {
  char nome[20]; 
  int tipo; 
  int pos;
  int desl; 
  int tam; 
  ptno prox; 
} no;


ptno insere(ptno L, char nome[], int tipo, int pos, int desl, int tam) {
  ptno p, new; 

  new = (ptno) malloc(sizeof(struct no)); 
  strcpy(new->nome, nome); 
  new->tipo = tipo; 
  new->pos = pos; 
  new->desl = desl;
  new->tam = tam; 
  new->prox = NULL; 
  p = L;  // INICIO 

    while(p && p->prox) {
      p = p->prox; 
    }

     if(p) 
     { 
          p->prox = new;
     } else {
      L = new; 
     }

  return L; 
}


ptno buscaCampo(ptno L, char *nome) {

    while(L && strcmp(L->nome, nome) != 0) 
    {
      L = L->prox; 
    }
    
    return L; 
   
}

// Tabela de símbolos
struct elem_tab_simbolos {
    char id[100];
    int endereco;
    int tipo;
    int tam; 
    int pos; 
    ptno lista_campos; 
} tabSimb[TAM_TAB], elemTab; 
int pos_tab = 0;

// Manutenção da pilha semântica
void empilha(int valor){
  if(topo == TAM_PIL)
    erro("Pilha cheia!");
  Pilha[++topo] = valor;
}

int desempilha(){
  if(topo == -1)
    erro("Pilha vazia!");
  return Pilha[topo--];
}



int buscaSimbolo(char *id){
  int i = pos_tab -1;
  for(; strcmp(tabSimb[i].id, id) && i >= 0; i--)
    ;
  return i;
}

void insereSimbolo(struct elem_tab_simbolos elem){
  int i;
  if (pos_tab == TAM_TAB)
    erro("Tabela de simbolos cheia!");
  i = buscaSimbolo(elem.id);
  if(i != -1)
    erro("Identificador duplicado");
  tabSimb[pos_tab++] = elem;
}

void iniciaTabela() {
    struct elem_tab_simbolos elemTab1;
    strcpy(elemTab1.id, "inteiro");
    elemTab1.endereco = -1;
    elemTab1.tipo = 0;
    elemTab1.pos = 0;
    elemTab1.tam = 1;
    elemTab1.lista_campos = NULL;
    insereSimbolo(elemTab1);

    struct elem_tab_simbolos elemTab2;
    strcpy(elemTab2.id, "logico");
    elemTab2.endereco = -1;
    elemTab2.tipo = 1;
    elemTab2.pos = 1;
    elemTab2.tam = 1;
    elemTab2.lista_campos = NULL;
    insereSimbolo(elemTab2);
}

void testaTipo(int tipo1, int tipo2, int ret){
    int t1 = desempilha();
    int t2 = desempilha();

    if(t1 != tipo1 || t2 != tipo2)
        erro("Incompatibilidade de tipo!");
    empilha(ret);
    
}


void mostraCampos(ptno L) {
  ptno p =  L; 

  if(p)  
  {
    while(p->prox) {
    printf("(%s, %3s, %d, %d, %d)=>", p->nome, p->tipo == INT? "INT" : p->tipo == LOG ? "LOG" : "REG", p->pos, p->desl, p->tam);
    p = p->prox;
    }
  printf(" (%s, %3s, %d, %d, %d)", p->nome, p->tipo == INT? "INT" : p->tipo == LOG ? "LOG" : "REG", p->pos, p->desl, p->tam);
  }

}

void mostraTabela(){
  int i;
  puts("------------------------------------------TABELA DE SÍMBOLOS----------------------------------------");
  printf("\n%3s | %30s | %s | %s | %s | %s | %s \n", "#", "ID", "END", "TIP", "TAM", "POS", "CAMPOS");
  for(i = 0; i<50; i++)
    printf("--");
  for(i = 0; i<pos_tab; i++) 
  {
    printf("\n%3d | %30s | %3d | %3s | %d | %d | ", i, tabSimb[i].id, tabSimb[i].endereco,
    tabSimb[i].tipo == INT? "INT" : tabSimb[i].tipo == LOG ? "LOG" : "REG", tabSimb[i].tam, tabSimb[i].pos);
    mostraCampos(tabSimb[i].lista_campos); 
  }
  puts("\n");
}