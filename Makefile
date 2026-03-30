CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS = -lm

all: cpu assembler

cpu: cpu.c
	$(CC) $(CFLAGS) -o cpu cpu.c $(LDFLAGS)

assembler: assembler.c
	$(CC) $(CFLAGS) -o assembler assembler.c

clean:
	rm -f cpu assembler *.vm
