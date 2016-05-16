
kernel.out:     file format elf32-i386


Disassembly of section .text:

0000c400 <start>:

  


  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    c400:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    c402:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    c404:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    c406:	8e d0                	mov    %eax,%ss
  
  movb $0x13,%al  # ;vga 320x200x8 位,color mode 
    c408:	b0 13                	mov    $0x13,%al
  movb $0x00,%ah
    c40a:	b4 00                	mov    $0x0,%ah
  int $0x10
    c40c:	cd 10                	int    $0x10
  
#save color mode in ram 0x0ff0
 movb $8,(VMODE)
    c40e:	c6 06 f2             	movb   $0xf2,(%esi)
    c411:	0f 08                	invd   
 movw $320,(SCRNX)
    c413:	c7 06 f4 0f 40 01    	movl   $0x1400ff4,(%esi)
 movw $200,(SCRNY)
    c419:	c7 06 f6 0f c8 00    	movl   $0xc80ff6,(%esi)
 movl $0x000a0000,(VRAM)
    c41f:	66 c7 06 f8 0f       	movw   $0xff8,(%esi)
    c424:	00 00                	add    %al,(%eax)
    c426:	0a 00                	or     (%eax),%al

 #get keyboard led status
 movb	$0x02,%ah 
    c428:	b4 02                	mov    $0x2,%ah
 int     $0x16			#keyboard interrupts
    c42a:	cd 16                	int    $0x16
 movb   %al,(LEDS)
    c42c:	a2 f1 0f be 65       	mov    %al,0x65be0ff1
		
		
		
#diplay something
  movw $msg,%si
    c431:	c4                   	(bad)  
  call puts
    c432:	e8 5d 00 be 81       	call   81bec494 <__bss_start+0x81bdfbb8>
  
  movw $try,%si
    c437:	c4                   	(bad)  
  call puts
    c438:	e8 57 00 fa fc       	call   fcfac494 <__bss_start+0xfcf9fbb8>

0000c43d <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this. 
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    c43d:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    c43f:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    c441:	75 fa                	jne    c43d <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    c443:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    c445:	e6 64                	out    %al,$0x64

0000c447 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    c447:	e4 64                	in     $0x64,%al
  testb   $02,%al
    c449:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    c44b:	75 fa                	jne    c447 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    c44d:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    c44f:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT       this is vip ,but i don`t know it clearly now
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    c451:	0f 01 16             	lgdtl  (%esi)
    c454:	d8 c4                	fadd   %st(4),%st
  movl    %cr0, %eax
    c456:	0f 20 c0             	mov    %cr0,%eax
  orl     $CR0_PE_ON, %eax
    c459:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    c45d:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    c460:	ea a5 c4 08 00 0d 0a 	ljmp   $0xa0d,$0x8c4a5

0000c465 <msg>:
    c465:	0d 0a 0a 0d 6d       	or     $0x6d0d0a0a,%eax
    c46a:	79 20                	jns    c48c <try+0xb>
    c46c:	6b 65 72 6e          	imul   $0x6e,0x72(%ebp),%esp
    c470:	65                   	gs
    c471:	6c                   	insb   (%dx),%es:(%edi)
    c472:	20 69 73             	and    %ch,0x73(%ecx)
    c475:	20 72 75             	and    %dh,0x75(%edx)
    c478:	6e                   	outsb  %ds:(%esi),(%dx)
    c479:	69 6e 67 20 6a 6f 73 	imul   $0x736f6a20,0x67(%esi),%ebp
	...

0000c481 <try>:
    c481:	0d 0a 0a 0d 74       	or     $0x740d0a0a,%eax
    c486:	72 79                	jb     c501 <HariMain+0x23>
    c488:	20 69 74             	and    %ch,0x74(%ecx)
    c48b:	20 61 67             	and    %ah,0x67(%ecx)
    c48e:	61                   	popa   
    c48f:	69 6e 00 8a 04 83 c6 	imul   $0xc683048a,0x0(%esi),%ebp

0000c492 <puts>:
 try:
  .asciz "\r\n\n\rtry it again"

puts:

	movb (%si),%al
    c492:	8a 04 83             	mov    (%ebx,%eax,4),%al
	add $1,%si
    c495:	c6 01 3c             	movb   $0x3c,(%ecx)
	cmp $0,%al
    c498:	00 74 09 b4          	add    %dh,-0x4c(%ecx,%ecx,1)
	je over
	movb $0x0e,%ah
    c49c:	0e                   	push   %cs
	movw $15,%bx
    c49d:	bb 0f 00 cd 10       	mov    $0x10cd000f,%ebx
	int $0x10
	jmp puts
    c4a2:	eb ee                	jmp    c492 <puts>

0000c4a4 <over>:
over:
	ret	
    c4a4:	c3                   	ret    

0000c4a5 <protcseg>:
	
	
  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    c4a5:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    c4a9:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    c4ab:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    c4ad:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    c4af:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    c4b1:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    c4b3:	bc 00 c4 00 00       	mov    $0xc400,%esp
  call HariMain //这里调用C
    c4b8:	e8 21 00 00 00       	call   c4de <HariMain>

0000c4bd <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    c4bd:	eb fe                	jmp    c4bd <spin>
    c4bf:	90                   	nop

0000c4c0 <gdt>:
	...
    c4c8:	ff                   	(bad)  
    c4c9:	ff 00                	incl   (%eax)
    c4cb:	00 00                	add    %al,(%eax)
    c4cd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    c4d4:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

0000c4d8 <gdtdesc>:
    c4d8:	17                   	pop    %ss
    c4d9:	00 c0                	add    %al,%al
    c4db:	c4 00                	les    (%eax),%eax
	...

0000c4de <HariMain>:
#include "header.h"


void HariMain(void)
{
    c4de:	55                   	push   %ebp
    c4df:	89 e5                	mov    %esp,%ebp
    c4e1:	83 ec 14             	sub    $0x14,%esp

	color_screen(15);
    c4e4:	6a 0f                	push   $0xf
    c4e6:	e8 1f 02 00 00       	call   c70a <color_screen>
	char *vram;/* 声明变量vram、用于BYTE [...]地址 */
	int xsize, ysize;

	
    
	init_palette();/* 设定调色板 */
    c4eb:	e8 72 02 00 00       	call   c762 <init_palette>
	vram = (char *) 0xa0000;/* 地址变量赋值 */
	xsize = 320;
	ysize = 200;

	/* 根据 0xa0000 + x + y * 320 计算坐标 8*/
	boxfill8(vram, xsize, COL8_008484,  0,         0,          xsize -  1, ysize - 29);
    c4f0:	83 c4 0c             	add    $0xc,%esp
    c4f3:	68 ab 00 00 00       	push   $0xab
    c4f8:	68 3f 01 00 00       	push   $0x13f
    c4fd:	6a 00                	push   $0x0
    c4ff:	6a 00                	push   $0x0
    c501:	6a 0e                	push   $0xe
    c503:	68 40 01 00 00       	push   $0x140
    c508:	68 00 00 0a 00       	push   $0xa0000
    c50d:	e8 6b 02 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 28, xsize -  1, ysize - 28);
    c512:	83 c4 1c             	add    $0x1c,%esp
    c515:	68 ac 00 00 00       	push   $0xac
    c51a:	68 3f 01 00 00       	push   $0x13f
    c51f:	68 ac 00 00 00       	push   $0xac
    c524:	6a 00                	push   $0x0
    c526:	6a 08                	push   $0x8
    c528:	68 40 01 00 00       	push   $0x140
    c52d:	68 00 00 0a 00       	push   $0xa0000
    c532:	e8 46 02 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_FFFFFF,  0,         ysize - 27, xsize -  1, ysize - 27);
    c537:	83 c4 1c             	add    $0x1c,%esp
    c53a:	68 ad 00 00 00       	push   $0xad
    c53f:	68 3f 01 00 00       	push   $0x13f
    c544:	68 ad 00 00 00       	push   $0xad
    c549:	6a 00                	push   $0x0
    c54b:	6a 07                	push   $0x7
    c54d:	68 40 01 00 00       	push   $0x140
    c552:	68 00 00 0a 00       	push   $0xa0000
    c557:	e8 21 02 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 26, xsize -  1, ysize -  1);
    c55c:	83 c4 1c             	add    $0x1c,%esp
    c55f:	68 c7 00 00 00       	push   $0xc7
    c564:	68 3f 01 00 00       	push   $0x13f
    c569:	68 ae 00 00 00       	push   $0xae
    c56e:	6a 00                	push   $0x0
    c570:	6a 08                	push   $0x8
    c572:	68 40 01 00 00       	push   $0x140
    c577:	68 00 00 0a 00       	push   $0xa0000
    c57c:	e8 fc 01 00 00       	call   c77d <boxfill8>

	boxfill8(vram, xsize, COL8_FFFFFF,  3,         ysize - 24, 59,         ysize - 24);
    c581:	83 c4 1c             	add    $0x1c,%esp
    c584:	68 b0 00 00 00       	push   $0xb0
    c589:	6a 3b                	push   $0x3b
    c58b:	68 b0 00 00 00       	push   $0xb0
    c590:	6a 03                	push   $0x3
    c592:	6a 07                	push   $0x7
    c594:	68 40 01 00 00       	push   $0x140
    c599:	68 00 00 0a 00       	push   $0xa0000
    c59e:	e8 da 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_FFFFFF,  2,         ysize - 24,  2,         ysize -  4);
    c5a3:	83 c4 1c             	add    $0x1c,%esp
    c5a6:	68 c4 00 00 00       	push   $0xc4
    c5ab:	6a 02                	push   $0x2
    c5ad:	68 b0 00 00 00       	push   $0xb0
    c5b2:	6a 02                	push   $0x2
    c5b4:	6a 07                	push   $0x7
    c5b6:	68 40 01 00 00       	push   $0x140
    c5bb:	68 00 00 0a 00       	push   $0xa0000
    c5c0:	e8 b8 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_848484,  3,         ysize -  4, 59,         ysize -  4);
    c5c5:	83 c4 1c             	add    $0x1c,%esp
    c5c8:	68 c4 00 00 00       	push   $0xc4
    c5cd:	6a 3b                	push   $0x3b
    c5cf:	68 c4 00 00 00       	push   $0xc4
    c5d4:	6a 03                	push   $0x3
    c5d6:	6a 0f                	push   $0xf
    c5d8:	68 40 01 00 00       	push   $0x140
    c5dd:	68 00 00 0a 00       	push   $0xa0000
    c5e2:	e8 96 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_848484, 59,         ysize - 23, 59,         ysize -  5);
    c5e7:	83 c4 1c             	add    $0x1c,%esp
    c5ea:	68 c3 00 00 00       	push   $0xc3
    c5ef:	6a 3b                	push   $0x3b
    c5f1:	68 b1 00 00 00       	push   $0xb1
    c5f6:	6a 3b                	push   $0x3b
    c5f8:	6a 0f                	push   $0xf
    c5fa:	68 40 01 00 00       	push   $0x140
    c5ff:	68 00 00 0a 00       	push   $0xa0000
    c604:	e8 74 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_000000,  2,         ysize -  3, 59,         ysize -  3);
    c609:	83 c4 1c             	add    $0x1c,%esp
    c60c:	68 c5 00 00 00       	push   $0xc5
    c611:	6a 3b                	push   $0x3b
    c613:	68 c5 00 00 00       	push   $0xc5
    c618:	6a 02                	push   $0x2
    c61a:	6a 00                	push   $0x0
    c61c:	68 40 01 00 00       	push   $0x140
    c621:	68 00 00 0a 00       	push   $0xa0000
    c626:	e8 52 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_000000, 60,         ysize - 24, 60,         ysize -  3);
    c62b:	83 c4 1c             	add    $0x1c,%esp
    c62e:	68 c5 00 00 00       	push   $0xc5
    c633:	6a 3c                	push   $0x3c
    c635:	68 b0 00 00 00       	push   $0xb0
    c63a:	6a 3c                	push   $0x3c
    c63c:	6a 00                	push   $0x0
    c63e:	68 40 01 00 00       	push   $0x140
    c643:	68 00 00 0a 00       	push   $0xa0000
    c648:	e8 30 01 00 00       	call   c77d <boxfill8>

	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 24, xsize -  4, ysize - 24);
    c64d:	83 c4 1c             	add    $0x1c,%esp
    c650:	68 b0 00 00 00       	push   $0xb0
    c655:	68 3c 01 00 00       	push   $0x13c
    c65a:	68 b0 00 00 00       	push   $0xb0
    c65f:	68 11 01 00 00       	push   $0x111
    c664:	6a 0f                	push   $0xf
    c666:	68 40 01 00 00       	push   $0x140
    c66b:	68 00 00 0a 00       	push   $0xa0000
    c670:	e8 08 01 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize -  4);
    c675:	83 c4 1c             	add    $0x1c,%esp
    c678:	68 c4 00 00 00       	push   $0xc4
    c67d:	68 11 01 00 00       	push   $0x111
    c682:	68 b1 00 00 00       	push   $0xb1
    c687:	68 11 01 00 00       	push   $0x111
    c68c:	6a 0f                	push   $0xf
    c68e:	68 40 01 00 00       	push   $0x140
    c693:	68 00 00 0a 00       	push   $0xa0000
    c698:	e8 e0 00 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize -  3, xsize -  4, ysize -  3);
    c69d:	83 c4 1c             	add    $0x1c,%esp
    c6a0:	68 c5 00 00 00       	push   $0xc5
    c6a5:	68 3c 01 00 00       	push   $0x13c
    c6aa:	68 c5 00 00 00       	push   $0xc5
    c6af:	68 11 01 00 00       	push   $0x111
    c6b4:	6a 07                	push   $0x7
    c6b6:	68 40 01 00 00       	push   $0x140
    c6bb:	68 00 00 0a 00       	push   $0xa0000
    c6c0:	e8 b8 00 00 00       	call   c77d <boxfill8>
	boxfill8(vram, xsize, COL8_FFFFFF, xsize -  3, ysize - 24, xsize -  3, ysize -  3);
    c6c5:	83 c4 1c             	add    $0x1c,%esp
    c6c8:	68 c5 00 00 00       	push   $0xc5
    c6cd:	68 3d 01 00 00       	push   $0x13d
    c6d2:	68 b0 00 00 00       	push   $0xb0
    c6d7:	68 3d 01 00 00       	push   $0x13d
    c6dc:	6a 07                	push   $0x7
    c6de:	68 40 01 00 00       	push   $0x140
    c6e3:	68 00 00 0a 00       	push   $0xa0000
    c6e8:	e8 90 00 00 00       	call   c77d <boxfill8>
    c6ed:	83 c4 20             	add    $0x20,%esp

	for (;;) {
		io_hlt();
    c6f0:	f4                   	hlt    
    c6f1:	eb fd                	jmp    c6f0 <HariMain+0x212>

0000c6f3 <clear_screen>:
#include<header.h>


void clear_screen(char color) //15:pure white
{
    c6f3:	55                   	push   %ebp
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c6f4:	b8 00 00 0a 00       	mov    $0xa0000,%eax
#include<header.h>


void clear_screen(char color) //15:pure white
{
    c6f9:	89 e5                	mov    %esp,%ebp
    c6fb:	8a 55 08             	mov    0x8(%ebp),%dl
	int i;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c6fe:	88 10                	mov    %dl,(%eax)


void clear_screen(char color) //15:pure white
{
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c700:	40                   	inc    %eax
    c701:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c706:	75 f6                	jne    c6fe <clear_screen+0xb>
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c708:	5d                   	pop    %ebp
    c709:	c3                   	ret    

0000c70a <color_screen>:

void color_screen(char color) //15:pure white
{
    c70a:	55                   	push   %ebp
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c70b:	b8 00 00 0a 00       	mov    $0xa0000,%eax

	}
}

void color_screen(char color) //15:pure white
{
    c710:	89 e5                	mov    %esp,%ebp
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c712:	88 c2                	mov    %al,%dl

void color_screen(char color) //15:pure white
{
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c714:	40                   	inc    %eax
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c715:	83 e2 0f             	and    $0xf,%edx
    c718:	88 50 ff             	mov    %dl,-0x1(%eax)

void color_screen(char color) //15:pure white
{
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c71b:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c720:	75 f0                	jne    c712 <color_screen+0x8>
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c722:	5d                   	pop    %ebp
    c723:	c3                   	ret    

0000c724 <set_palette>:

void set_palette(int start, int end, unsigned char* rgb){
    c724:	55                   	push   %ebp
    c725:	89 e5                	mov    %esp,%ebp
    c727:	56                   	push   %esi
    c728:	8b 4d 10             	mov    0x10(%ebp),%ecx
    c72b:	53                   	push   %ebx
    c72c:	8b 5d 08             	mov    0x8(%ebp),%ebx
//read eflags and write_eflags
static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
    c72f:	9c                   	pushf  
    c730:	5e                   	pop    %esi
	int i, eflags;
	eflags = read_eflags();	//替代作者的io_load_eflags()
	io_cli();
    c731:	fa                   	cli    

// out:write a data to a port
static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    c732:	ba c8 03 00 00       	mov    $0x3c8,%edx
	outb(0x03c8, start);	//替代作者的io_out8()
    c737:	0f b6 c3             	movzbl %bl,%eax
    c73a:	ee                   	out    %al,(%dx)
    c73b:	b2 c9                	mov    $0xc9,%dl
	for(i=start; i<=end; i++){
    c73d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    c740:	7f 1a                	jg     c75c <set_palette+0x38>
		outb(0x03c9,rgb[0]/4);
    c742:	8a 01                	mov    (%ecx),%al
    c744:	c0 e8 02             	shr    $0x2,%al
    c747:	ee                   	out    %al,(%dx)
		outb(0x03c9,rgb[1]/4);
    c748:	8a 41 01             	mov    0x1(%ecx),%al
    c74b:	c0 e8 02             	shr    $0x2,%al
    c74e:	ee                   	out    %al,(%dx)
		outb(0x03c9,rgb[2]/4);
    c74f:	8a 41 02             	mov    0x2(%ecx),%al
    c752:	c0 e8 02             	shr    $0x2,%al
    c755:	ee                   	out    %al,(%dx)
		rgb+=3;
    c756:	83 c1 03             	add    $0x3,%ecx
void set_palette(int start, int end, unsigned char* rgb){
	int i, eflags;
	eflags = read_eflags();	//替代作者的io_load_eflags()
	io_cli();
	outb(0x03c8, start);	//替代作者的io_out8()
	for(i=start; i<=end; i++){
    c759:	43                   	inc    %ebx
    c75a:	eb e1                	jmp    c73d <set_palette+0x19>
}

static __inline void
write_eflags(uint32_t eflags)
{
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
    c75c:	56                   	push   %esi
    c75d:	9d                   	popf   
		outb(0x03c9,rgb[2]/4);
		rgb+=3;
	}
	write_eflags(eflags);	//替代作者的io_store_eflags(eflags)
	return;
}
    c75e:	5b                   	pop    %ebx
    c75f:	5e                   	pop    %esi
    c760:	5d                   	pop    %ebp
    c761:	c3                   	ret    

0000c762 <init_palette>:


void init_palette(void){
    c762:	55                   	push   %ebp
    c763:	89 e5                	mov    %esp,%ebp
		0x00,0x00,0x84,   /*12:dark 青*/
		0x84,0x00,0x84,   /*13:dark purper*/
		0x00,0x84,0x84,   /*14:light blue*/
		0x84,0x84,0x84,   /*15:dark gray*/
	};  
	set_palette(0,15,table_rgb);
    c765:	68 ac c8 00 00       	push   $0xc8ac
    c76a:	6a 0f                	push   $0xf
    c76c:	6a 00                	push   $0x0
    c76e:	e8 b1 ff ff ff       	call   c724 <set_palette>
    c773:	83 c4 0c             	add    $0xc,%esp
	return;
}
    c776:	c9                   	leave  
    c777:	c3                   	ret    

0000c778 <draw1>:


void draw1()
{
    c778:	55                   	push   %ebp
    c779:	89 e5                	mov    %esp,%ebp
		0x84,0x84,0x84,   /*15:dark gray*/
	};  


	
}
    c77b:	5d                   	pop    %ebp
    c77c:	c3                   	ret    

0000c77d <boxfill8>:

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
    c77d:	55                   	push   %ebp
    c77e:	89 e5                	mov    %esp,%ebp
    c780:	8b 4d 18             	mov    0x18(%ebp),%ecx
    c783:	8b 45 0c             	mov    0xc(%ebp),%eax
    c786:	53                   	push   %ebx
    c787:	8a 5d 10             	mov    0x10(%ebp),%bl
    c78a:	0f af c1             	imul   %ecx,%eax
    c78d:	03 45 08             	add    0x8(%ebp),%eax
	int x, y;
	for(y=y0; y<=y1; y++){
    c790:	3b 4d 20             	cmp    0x20(%ebp),%ecx
    c793:	7f 14                	jg     c7a9 <boxfill8+0x2c>
    c795:	8b 55 14             	mov    0x14(%ebp),%edx
		for(x=x0; x<=x1; x++){
    c798:	3b 55 1c             	cmp    0x1c(%ebp),%edx
    c79b:	7f 06                	jg     c7a3 <boxfill8+0x26>
			vram[y*xsize+x]=c;
    c79d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
		for(x=x0; x<=x1; x++){
    c7a0:	42                   	inc    %edx
    c7a1:	eb f5                	jmp    c798 <boxfill8+0x1b>
	
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
    c7a3:	41                   	inc    %ecx
    c7a4:	03 45 0c             	add    0xc(%ebp),%eax
    c7a7:	eb e7                	jmp    c790 <boxfill8+0x13>
		for(x=x0; x<=x1; x++){
			vram[y*xsize+x]=c;
		}
	}
	return;
}
    c7a9:	5b                   	pop    %ebx
    c7aa:	5d                   	pop    %ebp
    c7ab:	c3                   	ret    
