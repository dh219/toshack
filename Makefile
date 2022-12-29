all: ttramdetect altramadd patcher maketos

ttramdetect:
	vasmm68k_mot -Fbin -o ttramdetect.img ttramdetect.S
   
test:
	vasmm68k_mot -Fbin -o test.img test.S

altramadd:
	vasmm68k_mot -Fbin -o altramadd.img altramadd.S

patcher: patcher.c
	gcc -o patcher patcher.c
	
maketos: patcher
	./patcher

