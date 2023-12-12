simples: utils.c lexico.l sintatico.y;
		flex -o lexico.c lexico.l;\
		bison -o sintatico.c sintatico.y -v -d;\
		gcc sintatico.c -o simples;

limpa: ;
		rm lexico.c sintatico.c sintatico.h sintatico.output simples