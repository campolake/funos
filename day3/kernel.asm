
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
    c432:	e8 5d 00 be 81       	call   81bec494 <__bss_start+0x81bdfdd8>
  
  movw $try,%si
    c437:	c4                   	(bad)  
  call puts
    c438:	e8 57 00 fa fc       	call   fcfac494 <__bss_start+0xfcf9fdd8>

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
    c486:	72 79                	jb     c501 <clear_screen+0xb>
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
    c4e6:	e8 22 00 00 00       	call   c50d <color_screen>
	char *vram;/* 声明变量vram、用于BYTE [...]地址 */
	int xsize, ysize;

	init_palette();/* 设定调色板 */
    c4eb:	e8 75 00 00 00       	call   c565 <init_palette>
    c4f0:	83 c4 10             	add    $0x10,%esp
	// boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize -  4);
	// boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize -  3, xsize -  4, ysize -  3);
	// boxfill8(vram, xsize, COL8_FFFFFF, xsize -  3, ysize - 24, xsize -  3, ysize -  3);

	for (;;) {
		io_hlt();
    c4f3:	f4                   	hlt    
    c4f4:	eb fd                	jmp    c4f3 <HariMain+0x15>

0000c4f6 <clear_screen>:
#include<header.h>


void clear_screen(char color) //15:pure white
{
    c4f6:	55                   	push   %ebp
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c4f7:	b8 00 00 0a 00       	mov    $0xa0000,%eax
#include<header.h>


void clear_screen(char color) //15:pure white
{
    c4fc:	89 e5                	mov    %esp,%ebp
    c4fe:	8a 55 08             	mov    0x8(%ebp),%dl
	int i;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c501:	88 10                	mov    %dl,(%eax)


void clear_screen(char color) //15:pure white
{
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c503:	40                   	inc    %eax
    c504:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c509:	75 f6                	jne    c501 <clear_screen+0xb>
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c50b:	5d                   	pop    %ebp
    c50c:	c3                   	ret    

0000c50d <color_screen>:

void color_screen(char color) //15:pure white
{
    c50d:	55                   	push   %ebp
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c50e:	b8 00 00 0a 00       	mov    $0xa0000,%eax

	}
}

void color_screen(char color) //15:pure white
{
    c513:	89 e5                	mov    %esp,%ebp
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c515:	88 c2                	mov    %al,%dl

void color_screen(char color) //15:pure white
{
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c517:	40                   	inc    %eax
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c518:	83 e2 0f             	and    $0xf,%edx
    c51b:	88 50 ff             	mov    %dl,-0x1(%eax)

void color_screen(char color) //15:pure white
{
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c51e:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c523:	75 f0                	jne    c515 <color_screen+0x8>
	{
		write_mem8(i,i&0x0f);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c525:	5d                   	pop    %ebp
    c526:	c3                   	ret    

0000c527 <set_palette>:

void set_palette(int start, int end, unsigned char* rgb){
    c527:	55                   	push   %ebp
    c528:	89 e5                	mov    %esp,%ebp
    c52a:	56                   	push   %esi
    c52b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    c52e:	53                   	push   %ebx
    c52f:	8b 5d 08             	mov    0x8(%ebp),%ebx
//read eflags and write_eflags
static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
    c532:	9c                   	pushf  
    c533:	5e                   	pop    %esi
	int i, eflags;
	eflags = read_eflags();	//替代作者的io_load_eflags()
	io_cli();
    c534:	fa                   	cli    

// out:write a data to a port
static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    c535:	ba c8 03 00 00       	mov    $0x3c8,%edx
	outb(0x03c8, start);	//替代作者的io_out8()
    c53a:	0f b6 c3             	movzbl %bl,%eax
    c53d:	ee                   	out    %al,(%dx)
    c53e:	b2 c9                	mov    $0xc9,%dl
	for(i=start; i<=end; i++){
    c540:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    c543:	7f 1a                	jg     c55f <set_palette+0x38>
		outb(0x03c9,rgb[0]/4);
    c545:	8a 01                	mov    (%ecx),%al
    c547:	c0 e8 02             	shr    $0x2,%al
    c54a:	ee                   	out    %al,(%dx)
		outb(0x03c9,rgb[1]/4);
    c54b:	8a 41 01             	mov    0x1(%ecx),%al
    c54e:	c0 e8 02             	shr    $0x2,%al
    c551:	ee                   	out    %al,(%dx)
		outb(0x03c9,rgb[2]/4);
    c552:	8a 41 02             	mov    0x2(%ecx),%al
    c555:	c0 e8 02             	shr    $0x2,%al
    c558:	ee                   	out    %al,(%dx)
		rgb+=3;
    c559:	83 c1 03             	add    $0x3,%ecx
void set_palette(int start, int end, unsigned char* rgb){
	int i, eflags;
	eflags = read_eflags();	//替代作者的io_load_eflags()
	io_cli();
	outb(0x03c8, start);	//替代作者的io_out8()
	for(i=start; i<=end; i++){
    c55c:	43                   	inc    %ebx
    c55d:	eb e1                	jmp    c540 <set_palette+0x19>
}

static __inline void
write_eflags(uint32_t eflags)
{
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
    c55f:	56                   	push   %esi
    c560:	9d                   	popf   
		outb(0x03c9,rgb[2]/4);
		rgb+=3;
	}
	write_eflags(eflags);	//替代作者的io_store_eflags(eflags)
	return;
}
    c561:	5b                   	pop    %ebx
    c562:	5e                   	pop    %esi
    c563:	5d                   	pop    %ebp
    c564:	c3                   	ret    

0000c565 <init_palette>:


void init_palette(void){
    c565:	55                   	push   %ebp
    c566:	89 e5                	mov    %esp,%ebp
		0x00,0x00,0x84,   /*12:dark 青*/
		0x84,0x00,0x84,   /*13:dark purper*/
		0x00,0x84,0x84,   /*14:light blue*/
		0x84,0x84,0x84,   /*15:dark gray*/
	};  
	set_palette(0,15,table_rgb);
    c568:	68 8c c6 00 00       	push   $0xc68c
    c56d:	6a 0f                	push   $0xf
    c56f:	6a 00                	push   $0x0
    c571:	e8 b1 ff ff ff       	call   c527 <set_palette>
    c576:	83 c4 0c             	add    $0xc,%esp
	return;
}
    c579:	c9                   	leave  
    c57a:	c3                   	ret    

0000c57b <boxfill8>:

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
    c57b:	55                   	push   %ebp
    c57c:	89 e5                	mov    %esp,%ebp
    c57e:	8b 4d 18             	mov    0x18(%ebp),%ecx
    c581:	8b 45 0c             	mov    0xc(%ebp),%eax
    c584:	53                   	push   %ebx
    c585:	8a 5d 10             	mov    0x10(%ebp),%bl
    c588:	0f af c1             	imul   %ecx,%eax
    c58b:	03 45 08             	add    0x8(%ebp),%eax
	int x, y;
	for(y=y0; y<=y1; y++){
    c58e:	3b 4d 20             	cmp    0x20(%ebp),%ecx
    c591:	7f 14                	jg     c5a7 <boxfill8+0x2c>
    c593:	8b 55 14             	mov    0x14(%ebp),%edx
		for(x=x0; x<=x1; x++){
    c596:	3b 55 1c             	cmp    0x1c(%ebp),%edx
    c599:	7f 06                	jg     c5a1 <boxfill8+0x26>
			vram[y*xsize+x]=c;
    c59b:	88 1c 10             	mov    %bl,(%eax,%edx,1)
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
		for(x=x0; x<=x1; x++){
    c59e:	42                   	inc    %edx
    c59f:	eb f5                	jmp    c596 <boxfill8+0x1b>
	return;
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
    c5a1:	41                   	inc    %ecx
    c5a2:	03 45 0c             	add    0xc(%ebp),%eax
    c5a5:	eb e7                	jmp    c58e <boxfill8+0x13>
		for(x=x0; x<=x1; x++){
			vram[y*xsize+x]=c;
		}
	}
	return;
}
    c5a7:	5b                   	pop    %ebx
    c5a8:	5d                   	pop    %ebp
    c5a9:	c3                   	ret    
