sqlc: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o SQLinc

lex.yy.c: SQLinc.l
	lex SQLinc.l

y.tab.c: SQLinc.y
	yacc -d SQLinc.y

clean:
	rm lex.yy.c y.tab.c y.tab.h
