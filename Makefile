CC = gcc
CFLAGS = -Wall -Wextra -O3 -flto
LDFLAGS = -lraylib -lm

all: cpu imager assembler font_maker

cpu: cpu.c
	$(CC) $(CFLAGS) -o cpu cpu.c $(LDFLAGS)

assembler: assembler.c
	$(CC) $(CFLAGS) -o assembler assembler.c

imager: imager.c
	$(CC) $(CFLAGS) -o imager imager.c

font_maker: font_maker.c
	$(CC) $(CFLAGS) -o font_maker font_maker.c

clean:
	rm -f cpu assembler imager font_maker *.vm *.bin
