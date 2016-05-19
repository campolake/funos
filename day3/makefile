addr=0xc400
OBJDIR=.

CFLAGS := $(CFLAGS) -O1 -fno-builtin -I$(OBJDIR) -MD                                                                                        
CFLAGS += -fno-omit-frame-pointer
CFLAGS +=  -Wno-format -Wno-unused -Werror -gstabs -m32


LDFLAGS=-m elf_i386

kernelImg:entry.o  main.o screen.o
	ld $(LDFLAGS) -N -e start -Ttext $(addr) -o $@.out $^
	objdump -S $@.out >$@.asm
	objcopy -S -O binary -j .text $@.out $@

entry.o: boot/boot.S
	gcc -nostdinc $(CFLAGS) -c -o $@ $<
main.o: init/main.c 
	@#对应《30天》中的bootpack.c
	gcc -nostdinc $(CFLAGS) -Os -c -o $@ $<
screen.o: dev/chr_dev/screen.c
	gcc -nostdinc $(CFLAGS) -Os -c -o $@ $<


clean:
	@rm -f *.o  *.d *.out  bootloader  funos.img
	@rm -f kernelImg
	@rm -f kernelImg.asm

all:kernelImg
	nasm -o bootloader boot/boot.S

img:all
	dd if=bootloader of=funos.img bs=512 count=1
	dd if=/dev/zero of=funos.img bs=512 seek=1 skip=1 count=2879

copy:img
	mkdir -p /tmp/floppy
	mount -o loop funos.img /tmp/floppy -o fat=12
	sleep 1
	cp kernelImg /tmp/floppy
	sleep 1
	umount /tmp/floppy
run:
	qemu-system-i386 -drive file=funos.img,if=floppy


