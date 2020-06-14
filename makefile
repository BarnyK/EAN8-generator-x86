first: first.c second.s
	cc -m32 -std=c99 -c first.c
	nasm -f elf32 second.s
	cc -m32 -o first first.o second.o
	rm first.o second.o