CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS = -lraylib -lm

all: cpu imager assembler launcher

cpu: cpu.c
	$(CC) $(CFLAGS) -o cpu cpu.c $(LDFLAGS)

assembler: assembler.c
	$(CC) $(CFLAGS) -o assembler assembler.c

imager: imager.c
	$(CC) $(CFLAGS) -o imager imager.c

launcher: launcher.c
	$(CC) $(CFLAGS) -o launcher launcher.c $(LDFLAGS)

clean:
	rm -f cpu assembler launcher imager *.vm
