draw_ean8: first.c second.s
	cc -std=c99 -c first.c
	nasm -f elf64 second.s
	cc -no-pie -o draw_ean8_64 first.o second.o
	rm first.o second.o