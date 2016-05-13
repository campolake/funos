addr=0xc400
OBJDIR=.

CFLAGS := $(CFLAGS) -O1 -fno-builtin -I$(OBJDIR) -MD                                                                                        
CFLAGS += -fno-omit-frame-pointer
CFLAGS +=  -Wno-format -Wno-unused -Werror -gstabs -m32


LDFLAGS=-m elf_i386

kernel:entry.o  main.o screen.o
	ld $(LDFLAGS) -N -e start -Ttext $(addr) -o $@.out $^
	objdump -S $@.out >$@.asm
	objcopy -S -O binary -j .text $@.out $@

entry.o:entry.S
	gcc -nostdinc $(CFLAGS) -c -o $@ $<
main.o:main.c 
	@#对应《30天》中的bootpack.c
	gcc -nostdinc $(CFLAGS) -Os -c -o $@ $<
screen.o:screen.c
	gcc -nostdinc $(CFLAGS) -Os -c -o $@ $<

nasmfun.o:nasmfun.S
	gcc -nostdinc $(CFLAGS) -c -o $@ $<

clean:
	@rm -f *.o  *.d *.out  bootloader  myos.img

all:kernel
	nasm -o bootloader ipl10.nas

img:all
	dd if=bootloader of=myos.img bs=512 count=1
	dd if=/dev/zero of=myos.img bs=512 seek=1 skip=1 count=2879

copy:img
	mkdir -p /tmp/floppy
	mount -o loop myos.img /tmp/floppy -o fat=12
	sleep 1
	cp kernel /tmp/floppy
	sleep 1
	umount /tmp/floppy
run:
	qemu-system-i386 -drive file=myos.img,if=floppy


