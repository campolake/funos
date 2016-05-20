
kernelImg.out:     file format elf32-i386


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
 movb  $10,(CYLS)
    c40e:	c6 06 f0             	movb   $0xf0,(%esi)
    c411:	0f 0a                	(bad)  
 movb $8,(VMODE)
    c413:	c6 06 f2             	movb   $0xf2,(%esi)
    c416:	0f 08                	invd   
 movw $320,(SCRNX)
    c418:	c7 06 f4 0f 40 01    	movl   $0x1400ff4,(%esi)
 movw $200,(SCRNY)
    c41e:	c7 06 f6 0f c8 00    	movl   $0xc80ff6,(%esi)
 movl $0x000a0000,(VRAM)
    c424:	66 c7 06 f8 0f       	movw   $0xff8,(%esi)
    c429:	00 00                	add    %al,(%eax)
    c42b:	0a 00                	or     (%eax),%al
  # movw $640,(SCRNX)
  # movw $480,(SCRNY)
  # movl $0xe0000000,(VRAM)

 #get keyboard led status
 movb	$0x02,%ah 
    c42d:	b4 02                	mov    $0x2,%ah
 int     $0x16			#keyboard interrupts
    c42f:	cd 16                	int    $0x16
 movb   %al,(LEDS)
    c431:	a2 f1 0f be 6a       	mov    %al,0x6abe0ff1
		
		
		
#diplay something
  movw $msg,%si
    c436:	c4                   	(bad)  
  call puts
    c437:	e8 5d 00 be 86       	call   86bec499 <__bss_start+0x86bddd55>
  
  movw $try,%si
    c43c:	c4                   	(bad)  
  call puts
    c43d:	e8 57 00 fa fc       	call   fcfac499 <__bss_start+0xfcf9dd55>

0000c442 <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this. 
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    c442:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    c444:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    c446:	75 fa                	jne    c442 <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    c448:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    c44a:	e6 64                	out    %al,$0x64

0000c44c <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    c44c:	e4 64                	in     $0x64,%al
  testb   $02,%al
    c44e:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    c450:	75 fa                	jne    c44c <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    c452:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    c454:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT       this is vip ,but i don`t know it clearly now
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    c456:	0f 01 16             	lgdtl  (%esi)
    c459:	dc c4                	fadd   %st,%st(4)
  movl    %cr0, %eax
    c45b:	0f 20 c0             	mov    %cr0,%eax
  orl     $CR0_PE_ON, %eax
    c45e:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    c462:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    c465:	ea aa c4 08 00 0d 0a 	ljmp   $0xa0d,$0x8c4aa

0000c46a <msg>:
    c46a:	0d 0a 0a 0d 6d       	or     $0x6d0d0a0a,%eax
    c46f:	79 20                	jns    c491 <try+0xb>
    c471:	6b 65 72 6e          	imul   $0x6e,0x72(%ebp),%esp
    c475:	65                   	gs
    c476:	6c                   	insb   (%dx),%es:(%edi)
    c477:	20 69 73             	and    %ch,0x73(%ecx)
    c47a:	20 72 75             	and    %dh,0x75(%edx)
    c47d:	6e                   	outsb  %ds:(%esi),(%dx)
    c47e:	69 6e 67 20 6a 6f 73 	imul   $0x736f6a20,0x67(%esi),%ebp
	...

0000c486 <try>:
    c486:	0d 0a 0a 0d 74       	or     $0x740d0a0a,%eax
    c48b:	72 79                	jb     c506 <wmain+0x24>
    c48d:	20 69 74             	and    %ch,0x74(%ecx)
    c490:	20 61 67             	and    %ah,0x67(%ecx)
    c493:	61                   	popa   
    c494:	69 6e 00 8a 04 83 c6 	imul   $0xc683048a,0x0(%esi),%ebp

0000c497 <puts>:
 try:
  .asciz "\r\n\n\rtry it again"

puts:

	movb (%si),%al
    c497:	8a 04 83             	mov    (%ebx,%eax,4),%al
	add $1,%si
    c49a:	c6 01 3c             	movb   $0x3c,(%ecx)
	cmp $0,%al
    c49d:	00 74 09 b4          	add    %dh,-0x4c(%ecx,%ecx,1)
	je over
	movb $0x0e,%ah
    c4a1:	0e                   	push   %cs
	movw $15,%bx
    c4a2:	bb 0f 00 cd 10       	mov    $0x10cd000f,%ebx
	int $0x10
	jmp puts
    c4a7:	eb ee                	jmp    c497 <puts>

0000c4a9 <over>:
over:
	ret	
    c4a9:	c3                   	ret    

0000c4aa <protcseg>:
	
	
  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    c4aa:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    c4ae:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    c4b0:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    c4b2:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    c4b4:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    c4b6:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    c4b8:	bc 00 c4 00 00       	mov    $0xc400,%esp
  call wmain //这里调用C
    c4bd:	e8 20 00 00 00       	call   c4e2 <wmain>

0000c4c2 <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    c4c2:	eb fe                	jmp    c4c2 <spin>

0000c4c4 <gdt>:
	...
    c4cc:	ff                   	(bad)  
    c4cd:	ff 00                	incl   (%eax)
    c4cf:	00 00                	add    %al,(%eax)
    c4d1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    c4d8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

0000c4dc <gdtdesc>:
    c4dc:	17                   	pop    %ss
    c4dd:	00 c4                	add    %al,%ah
    c4df:	c4 00                	les    (%eax),%eax
	...

0000c4e2 <wmain>:
#include "header.h"
#include "dev/chr_dev/screen.h"
#include "dev/chr_dev/fontascii.h"

void wmain(void)
{
    c4e2:	55                   	push   %ebp
    c4e3:	89 e5                	mov    %esp,%ebp
    c4e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
    c4eb:	65 a1 14 00 00 00    	mov    %gs:0x14,%eax
    c4f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    c4f4:	31 c0                	xor    %eax,%eax

	chr_dev_init();
    c4f6:	e8 bd 00 00 00       	call   c5b8 <chr_dev_init>
	struct BootInfo *binfo = (struct BootInfo*) 0x0ff0;
	init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
    c4fb:	50                   	push   %eax
    c4fc:	0f bf 05 f6 0f 00 00 	movswl 0xff6,%eax
    c503:	50                   	push   %eax
    c504:	0f bf 05 f4 0f 00 00 	movswl 0xff4,%eax
    c50b:	50                   	push   %eax
    c50c:	ff 35 f8 0f 00 00    	pushl  0xff8
    c512:	e8 62 01 00 00       	call   c679 <init_screen>
	int mx, my;
	mx = (binfo->scrnx-16)/2;
	my = (binfo->scrny-28-16)/2;
    c517:	0f bf 05 f6 0f 00 00 	movswl 0xff6,%eax
    c51e:	b9 02 00 00 00       	mov    $0x2,%ecx
    c523:	83 e8 2c             	sub    $0x2c,%eax
    c526:	99                   	cltd   
    c527:	f7 f9                	idiv   %ecx
	char mcursor[256];
	// putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

	char s[10];
	sprintf(s, "(%d, %d)", mx, my);
    c529:	50                   	push   %eax

	chr_dev_init();
	struct BootInfo *binfo = (struct BootInfo*) 0x0ff0;
	init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
	int mx, my;
	mx = (binfo->scrnx-16)/2;
    c52a:	0f bf 05 f4 0f 00 00 	movswl 0xff4,%eax
    c531:	83 e8 10             	sub    $0x10,%eax
    c534:	99                   	cltd   
    c535:	f7 f9                	idiv   %ecx
	my = (binfo->scrny-28-16)/2;
	char mcursor[256];
	// putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

	char s[10];
	sprintf(s, "(%d, %d)", mx, my);
    c537:	50                   	push   %eax
    c538:	68 d0 c9 00 00       	push   $0xc9d0
    c53d:	8d 85 ea fe ff ff    	lea    -0x116(%ebp),%eax
    c543:	50                   	push   %eax
    c544:	e8 22 04 00 00       	call   c96b <sprintf>
	// putfonts8_asc(binfo->vram, binfo->scrnx, 16, 16, COL8_848400, s);
	
	
	init_mouse_cursor8(mcursor, COL8_848400);
    c549:	83 c4 18             	add    $0x18,%esp
    c54c:	6a 0b                	push   $0xb
    c54e:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
    c554:	50                   	push   %eax
    c555:	e8 27 03 00 00       	call   c881 <init_mouse_cursor8>
    c55a:	83 c4 10             	add    $0x10,%esp


	for (;;) {
		io_hlt();
    c55d:	f4                   	hlt    
    c55e:	eb fd                	jmp    c55d <wmain+0x7b>

0000c560 <clear_screen>:
	// char mcursor[256];
	// init_mouse_cursor8(mcursor, COL8_008484);
}

void clear_screen(char color) //15:pure white
{
    c560:	55                   	push   %ebp
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c561:	b8 00 00 0a 00       	mov    $0xa0000,%eax
	// char mcursor[256];
	// init_mouse_cursor8(mcursor, COL8_008484);
}

void clear_screen(char color) //15:pure white
{
    c566:	89 e5                	mov    %esp,%ebp
    c568:	8a 55 08             	mov    0x8(%ebp),%dl
	int i;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c56b:	88 10                	mov    %dl,(%eax)
}

void clear_screen(char color) //15:pure white
{
	int i;
	for(i=0xa0000;i<0xaffff;i++)
    c56d:	40                   	inc    %eax
    c56e:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c573:	75 f6                	jne    c56b <clear_screen+0xb>
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c575:	5d                   	pop    %ebp
    c576:	c3                   	ret    

0000c577 <color_screen>:

//用单一颜色设置屏幕
void color_screen(char color) //15:pure white
{
    c577:	55                   	push   %ebp
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c578:	b8 00 00 0a 00       	mov    $0xa0000,%eax
	}
}

//用单一颜色设置屏幕
void color_screen(char color) //15:pure white
{
    c57d:	89 e5                	mov    %esp,%ebp
    c57f:	8a 55 08             	mov    0x8(%ebp),%dl
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white
    c582:	88 10                	mov    %dl,(%eax)
//用单一颜色设置屏幕
void color_screen(char color) //15:pure white
{
	int i;
	color=color;
	for(i=0xa0000;i<0xaffff;i++)
    c584:	40                   	inc    %eax
    c585:	3d ff ff 0a 00       	cmp    $0xaffff,%eax
    c58a:	75 f6                	jne    c582 <color_screen+0xb>
	{
		write_mem8(i,color);  //if we write 15 ,all pixels color will be white,15 mens pure white ,so the screen changes into white

	}
}
    c58c:	5d                   	pop    %ebp
    c58d:	c3                   	ret    

0000c58e <set_palette>:

void set_palette(int start, int end, unsigned char* rgb){
    c58e:	55                   	push   %ebp
    c58f:	89 e5                	mov    %esp,%ebp
//read eflags and write_eflags
static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
    c591:	9c                   	pushf  
    c592:	59                   	pop    %ecx
	int i, eflags;
	eflags = read_eflags();	//替代作者的io_load_eflags()
	io_cli();
    c593:	fa                   	cli    

// out:write a data to a port
static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    c594:	ba c8 03 00 00       	mov    $0x3c8,%edx
	outb(0x03c8, start);	//替代作者的io_out8()
    c599:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
    c59d:	ee                   	out    %al,(%dx)
}

static __inline void
write_eflags(uint32_t eflags)
{
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
    c59e:	51                   	push   %ecx
    c59f:	9d                   	popf   
		// outb(0x03c9,rgb[2]/4);
		rgb+=3;
	}
	write_eflags(eflags);	//替代作者的io_store_eflags(eflags)
	return;
}
    c5a0:	5d                   	pop    %ebp
    c5a1:	c3                   	ret    

0000c5a2 <init_palette>:


void init_palette(void){
    c5a2:	55                   	push   %ebp
    c5a3:	89 e5                	mov    %esp,%ebp
		0x00,0x00,0x84,   /*12:dark 青*/
		0x84,0x00,0x84,   /*13:dark purper*/
		0x00,0x84,0x84,   /*14:light blue*/
		0x84,0x84,0x84,   /*15:dark gray*/
	};  
	set_palette(0,15,table_rgb);
    c5a5:	68 14 e7 00 00       	push   $0xe714
    c5aa:	6a 0f                	push   $0xf
    c5ac:	6a 00                	push   $0x0
    c5ae:	e8 db ff ff ff       	call   c58e <set_palette>
    c5b3:	83 c4 0c             	add    $0xc,%esp
	return;
}
    c5b6:	c9                   	leave  
    c5b7:	c3                   	ret    

0000c5b8 <chr_dev_init>:
#include<dev/chr_dev/screen.h>



void chr_dev_init()
{	
    c5b8:	55                   	push   %ebp
    c5b9:	89 e5                	mov    %esp,%ebp
	struct BootInfo * boot_info = (struct BootInfo*)0x0ff0;
	(*boot_info).scrnx = 320;
    c5bb:	66 c7 05 f4 0f 00 00 	movw   $0x140,0xff4
    c5c2:	40 01 
	(*boot_info).scrny = 200;
    c5c4:	66 c7 05 f6 0f 00 00 	movw   $0xc8,0xff6
    c5cb:	c8 00 
	init_palette();
    c5cd:	e8 d0 ff ff ff       	call   c5a2 <init_palette>
	color_screen(COL8_000000);//清空屏幕
    c5d2:	6a 00                	push   $0x0
    c5d4:	e8 9e ff ff ff       	call   c577 <color_screen>
    c5d9:	58                   	pop    %eax

	// char mcursor[256];
	// init_mouse_cursor8(mcursor, COL8_008484);
}
    c5da:	c9                   	leave  
    c5db:	c3                   	ret    

0000c5dc <draw1>:
	return;
}


void draw1()
{
    c5dc:	55                   	push   %ebp
    c5dd:	89 e5                	mov    %esp,%ebp
		0x84,0x84,0x84,   /*15:dark gray*/
	};  


	
}
    c5df:	5d                   	pop    %ebp
    c5e0:	c3                   	ret    

0000c5e1 <boxfill8>:

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
    c5e1:	55                   	push   %ebp
    c5e2:	89 e5                	mov    %esp,%ebp
    c5e4:	8b 4d 18             	mov    0x18(%ebp),%ecx
    c5e7:	8b 45 0c             	mov    0xc(%ebp),%eax
    c5ea:	53                   	push   %ebx
    c5eb:	8a 5d 10             	mov    0x10(%ebp),%bl
    c5ee:	0f af c1             	imul   %ecx,%eax
    c5f1:	03 45 08             	add    0x8(%ebp),%eax
	int x, y;
	for(y=y0; y<=y1; y++){
    c5f4:	3b 4d 20             	cmp    0x20(%ebp),%ecx
    c5f7:	7f 14                	jg     c60d <boxfill8+0x2c>
    c5f9:	8b 55 14             	mov    0x14(%ebp),%edx
		for(x=x0; x<=x1; x++){
    c5fc:	3b 55 1c             	cmp    0x1c(%ebp),%edx
    c5ff:	7f 06                	jg     c607 <boxfill8+0x26>
			vram[y*xsize+x]=c;
    c601:	88 1c 10             	mov    %bl,(%eax,%edx,1)
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
		for(x=x0; x<=x1; x++){
    c604:	42                   	inc    %edx
    c605:	eb f5                	jmp    c5fc <boxfill8+0x1b>
	
}

void boxfill8(char* vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1){
	int x, y;
	for(y=y0; y<=y1; y++){
    c607:	41                   	inc    %ecx
    c608:	03 45 0c             	add    0xc(%ebp),%eax
    c60b:	eb e7                	jmp    c5f4 <boxfill8+0x13>
		for(x=x0; x<=x1; x++){
			vram[y*xsize+x]=c;
		}
	}
	return;
}
    c60d:	5b                   	pop    %ebx
    c60e:	5d                   	pop    %ebp
    c60f:	c3                   	ret    

0000c610 <putfont>:



void putfont(char* vram, int xsize, int x, int y, char c, char *font){
    c610:	55                   	push   %ebp
    c611:	89 e5                	mov    %esp,%ebp
		if((d&0x20)!=0) p[2]=c;
		if((d&0x10)!=0) p[3]=c;
		if((d&0x08)!=0) p[4]=c;
		if((d&0x04)!=0) p[5]=c;
		if((d&0x02)!=0) p[6]=c;
		if((d&0x01)!=0) p[7]=c;
    c613:	8b 45 14             	mov    0x14(%ebp),%eax
    c616:	0f af 45 0c          	imul   0xc(%ebp),%eax
    c61a:	03 45 10             	add    0x10(%ebp),%eax
	return;
}



void putfont(char* vram, int xsize, int x, int y, char c, char *font){
    c61d:	8a 55 18             	mov    0x18(%ebp),%dl
		if((d&0x20)!=0) p[2]=c;
		if((d&0x10)!=0) p[3]=c;
		if((d&0x08)!=0) p[4]=c;
		if((d&0x04)!=0) p[5]=c;
		if((d&0x02)!=0) p[6]=c;
		if((d&0x01)!=0) p[7]=c;
    c620:	03 45 08             	add    0x8(%ebp),%eax
	return;
}



void putfont(char* vram, int xsize, int x, int y, char c, char *font){
    c623:	53                   	push   %ebx
	int i;
	char d, *p;
	for(i=0; i<16; i++){
    c624:	31 db                	xor    %ebx,%ebx
    c626:	83 c0 07             	add    $0x7,%eax
		d=font[i];
    c629:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
    c62c:	8a 0c 19             	mov    (%ecx,%ebx,1),%cl
		p=vram+(y+i)*xsize+x;
		if((d&0x80)!=0) p[0]=c;
    c62f:	84 c9                	test   %cl,%cl
    c631:	79 03                	jns    c636 <putfont+0x26>
    c633:	88 50 f9             	mov    %dl,-0x7(%eax)
		if((d&0x40)!=0) p[1]=c;
    c636:	f6 c1 40             	test   $0x40,%cl
    c639:	74 03                	je     c63e <putfont+0x2e>
    c63b:	88 50 fa             	mov    %dl,-0x6(%eax)
		if((d&0x20)!=0) p[2]=c;
    c63e:	f6 c1 20             	test   $0x20,%cl
    c641:	74 03                	je     c646 <putfont+0x36>
    c643:	88 50 fb             	mov    %dl,-0x5(%eax)
		if((d&0x10)!=0) p[3]=c;
    c646:	f6 c1 10             	test   $0x10,%cl
    c649:	74 03                	je     c64e <putfont+0x3e>
    c64b:	88 50 fc             	mov    %dl,-0x4(%eax)
		if((d&0x08)!=0) p[4]=c;
    c64e:	f6 c1 08             	test   $0x8,%cl
    c651:	74 03                	je     c656 <putfont+0x46>
    c653:	88 50 fd             	mov    %dl,-0x3(%eax)
		if((d&0x04)!=0) p[5]=c;
    c656:	f6 c1 04             	test   $0x4,%cl
    c659:	74 03                	je     c65e <putfont+0x4e>
    c65b:	88 50 fe             	mov    %dl,-0x2(%eax)
		if((d&0x02)!=0) p[6]=c;
    c65e:	f6 c1 02             	test   $0x2,%cl
    c661:	74 03                	je     c666 <putfont+0x56>
    c663:	88 50 ff             	mov    %dl,-0x1(%eax)
		if((d&0x01)!=0) p[7]=c;
    c666:	80 e1 01             	and    $0x1,%cl
    c669:	74 02                	je     c66d <putfont+0x5d>
    c66b:	88 10                	mov    %dl,(%eax)


void putfont(char* vram, int xsize, int x, int y, char c, char *font){
	int i;
	char d, *p;
	for(i=0; i<16; i++){
    c66d:	43                   	inc    %ebx
    c66e:	03 45 0c             	add    0xc(%ebp),%eax
    c671:	83 fb 10             	cmp    $0x10,%ebx
    c674:	75 b3                	jne    c629 <putfont+0x19>
		if((d&0x04)!=0) p[5]=c;
		if((d&0x02)!=0) p[6]=c;
		if((d&0x01)!=0) p[7]=c;
	}
	return;
}
    c676:	5b                   	pop    %ebx
    c677:	5d                   	pop    %ebp
    c678:	c3                   	ret    

0000c679 <init_screen>:

void init_screen(char *vram, int x, int y){
    c679:	55                   	push   %ebp
    c67a:	89 e5                	mov    %esp,%ebp
    c67c:	57                   	push   %edi
    c67d:	56                   	push   %esi
    c67e:	53                   	push   %ebx
    c67f:	83 ec 10             	sub    $0x10,%esp
    c682:	8b 75 10             	mov    0x10(%ebp),%esi
    c685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	boxfill8(vram, x, COL8_008484,  0,     0,      x -  1, y - 29);
    c688:	8d 46 e3             	lea    -0x1d(%esi),%eax
    c68b:	50                   	push   %eax
    c68c:	8d 7b ff             	lea    -0x1(%ebx),%edi
    c68f:	57                   	push   %edi
    c690:	6a 00                	push   $0x0
    c692:	6a 00                	push   $0x0
    c694:	6a 0e                	push   $0xe
    c696:	53                   	push   %ebx
    c697:	ff 75 08             	pushl  0x8(%ebp)
    c69a:	e8 42 ff ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 28, x -  1, y - 28);
    c69f:	8d 46 e4             	lea    -0x1c(%esi),%eax
    c6a2:	50                   	push   %eax
    c6a3:	57                   	push   %edi
    c6a4:	50                   	push   %eax
    c6a5:	6a 00                	push   $0x0
    c6a7:	6a 08                	push   $0x8
    c6a9:	53                   	push   %ebx
    c6aa:	ff 75 08             	pushl  0x8(%ebp)
    c6ad:	e8 2f ff ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_FFFFFF,  0,     y - 27, x -  1, y - 27);
    c6b2:	83 c4 38             	add    $0x38,%esp
    c6b5:	8d 46 e5             	lea    -0x1b(%esi),%eax
    c6b8:	50                   	push   %eax
    c6b9:	57                   	push   %edi
    c6ba:	50                   	push   %eax
    c6bb:	6a 00                	push   $0x0
    c6bd:	6a 07                	push   $0x7
    c6bf:	53                   	push   %ebx
    c6c0:	ff 75 08             	pushl  0x8(%ebp)
    c6c3:	e8 19 ff ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1);
    c6c8:	8d 46 ff             	lea    -0x1(%esi),%eax
    c6cb:	50                   	push   %eax
    c6cc:	57                   	push   %edi
    c6cd:	8d 46 e6             	lea    -0x1a(%esi),%eax
    c6d0:	50                   	push   %eax
    c6d1:	6a 00                	push   $0x0
    c6d3:	6a 08                	push   $0x8
    c6d5:	53                   	push   %ebx
    c6d6:	ff 75 08             	pushl  0x8(%ebp)

	boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24);
    c6d9:	8d 7e e8             	lea    -0x18(%esi),%edi

void init_screen(char *vram, int x, int y){
	boxfill8(vram, x, COL8_008484,  0,     0,      x -  1, y - 29);
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 28, x -  1, y - 28);
	boxfill8(vram, x, COL8_FFFFFF,  0,     y - 27, x -  1, y - 27);
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1);
    c6dc:	e8 00 ff ff ff       	call   c5e1 <boxfill8>

	boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24);
    c6e1:	83 c4 38             	add    $0x38,%esp
    c6e4:	57                   	push   %edi
    c6e5:	6a 3b                	push   $0x3b
    c6e7:	57                   	push   %edi
    c6e8:	6a 03                	push   $0x3
    c6ea:	6a 07                	push   $0x7
    c6ec:	53                   	push   %ebx
    c6ed:	ff 75 08             	pushl  0x8(%ebp)
    c6f0:	e8 ec fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_FFFFFF,  2,     y - 24,  2,     y -  4);
    c6f5:	8d 4e fc             	lea    -0x4(%esi),%ecx
    c6f8:	51                   	push   %ecx
    c6f9:	6a 02                	push   $0x2
    c6fb:	57                   	push   %edi
    c6fc:	6a 02                	push   $0x2
    c6fe:	6a 07                	push   $0x7
    c700:	53                   	push   %ebx
    c701:	ff 75 08             	pushl  0x8(%ebp)
    c704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
    c707:	e8 d5 fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_848484,  3,     y -  4, 59,     y -  4);
    c70c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    c70f:	83 c4 38             	add    $0x38,%esp
    c712:	51                   	push   %ecx
    c713:	6a 3b                	push   $0x3b
    c715:	51                   	push   %ecx
    c716:	6a 03                	push   $0x3
    c718:	6a 0f                	push   $0xf
    c71a:	53                   	push   %ebx
    c71b:	ff 75 08             	pushl  0x8(%ebp)
    c71e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    c721:	e8 bb fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_848484, 59,     y - 23, 59,     y -  5);
    c726:	8d 46 e9             	lea    -0x17(%esi),%eax
    c729:	89 c2                	mov    %eax,%edx
    c72b:	8d 46 fb             	lea    -0x5(%esi),%eax
	boxfill8(vram, x, COL8_000000,  2,     y -  3, 59,     y -  3);
    c72e:	83 ee 03             	sub    $0x3,%esi
	boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1);

	boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24);
	boxfill8(vram, x, COL8_FFFFFF,  2,     y - 24,  2,     y -  4);
	boxfill8(vram, x, COL8_848484,  3,     y -  4, 59,     y -  4);
	boxfill8(vram, x, COL8_848484, 59,     y - 23, 59,     y -  5);
    c731:	50                   	push   %eax
    c732:	6a 3b                	push   $0x3b
    c734:	52                   	push   %edx
    c735:	6a 3b                	push   $0x3b
    c737:	6a 0f                	push   $0xf
    c739:	53                   	push   %ebx
    c73a:	ff 75 08             	pushl  0x8(%ebp)
    c73d:	89 55 f0             	mov    %edx,-0x10(%ebp)
    c740:	e8 9c fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_000000,  2,     y -  3, 59,     y -  3);
    c745:	83 c4 38             	add    $0x38,%esp
    c748:	56                   	push   %esi
    c749:	6a 3b                	push   $0x3b
    c74b:	56                   	push   %esi
    c74c:	6a 02                	push   $0x2
    c74e:	6a 00                	push   $0x0
    c750:	53                   	push   %ebx
    c751:	ff 75 08             	pushl  0x8(%ebp)
    c754:	e8 88 fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_000000, 60,     y - 24, 60,     y -  3);
    c759:	56                   	push   %esi
    c75a:	6a 3c                	push   $0x3c
    c75c:	57                   	push   %edi
    c75d:	6a 3c                	push   $0x3c
    c75f:	6a 00                	push   $0x0
    c761:	53                   	push   %ebx
    c762:	ff 75 08             	pushl  0x8(%ebp)
    c765:	e8 77 fe ff ff       	call   c5e1 <boxfill8>

	boxfill8(vram, x, COL8_848484, x - 47, y - 24, x -  4, y - 24);
    c76a:	83 c4 38             	add    $0x38,%esp
    c76d:	57                   	push   %edi
    c76e:	8d 53 fc             	lea    -0x4(%ebx),%edx
    c771:	52                   	push   %edx
    c772:	57                   	push   %edi
    c773:	8d 43 d1             	lea    -0x2f(%ebx),%eax
    c776:	50                   	push   %eax
    c777:	6a 0f                	push   $0xf
    c779:	53                   	push   %ebx
    c77a:	ff 75 08             	pushl  0x8(%ebp)
    c77d:	89 55 e8             	mov    %edx,-0x18(%ebp)
    c780:	89 45 ec             	mov    %eax,-0x14(%ebp)
    c783:	e8 59 fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_848484, x - 47, y - 23, x - 47, y -  4);
    c788:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
    c78b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    c78e:	51                   	push   %ecx
    c78f:	50                   	push   %eax
    c790:	ff 75 f0             	pushl  -0x10(%ebp)
    c793:	89 45 f0             	mov    %eax,-0x10(%ebp)
    c796:	50                   	push   %eax
    c797:	6a 0f                	push   $0xf
    c799:	53                   	push   %ebx
    c79a:	ff 75 08             	pushl  0x8(%ebp)
    c79d:	e8 3f fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_FFFFFF, x - 47, y -  3, x -  4, y -  3);
    c7a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
    c7a5:	83 c4 38             	add    $0x38,%esp
    c7a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    c7ab:	56                   	push   %esi
    c7ac:	52                   	push   %edx
    c7ad:	56                   	push   %esi
    c7ae:	50                   	push   %eax
    c7af:	6a 07                	push   $0x7
    c7b1:	53                   	push   %ebx
    c7b2:	ff 75 08             	pushl  0x8(%ebp)
    c7b5:	e8 27 fe ff ff       	call   c5e1 <boxfill8>
	boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3);
    c7ba:	8d 43 fd             	lea    -0x3(%ebx),%eax
    c7bd:	56                   	push   %esi
    c7be:	50                   	push   %eax
    c7bf:	57                   	push   %edi
    c7c0:	50                   	push   %eax
    c7c1:	6a 07                	push   $0x7
    c7c3:	53                   	push   %ebx
    c7c4:	ff 75 08             	pushl  0x8(%ebp)
    c7c7:	e8 15 fe ff ff       	call   c5e1 <boxfill8>
    c7cc:	83 c4 38             	add    $0x38,%esp
	return;
}
    c7cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
    c7d2:	5b                   	pop    %ebx
    c7d3:	5e                   	pop    %esi
    c7d4:	5f                   	pop    %edi
    c7d5:	5d                   	pop    %ebp
    c7d6:	c3                   	ret    

0000c7d7 <putfont8>:


void putfont8(char *vram, int xsize, int x, int y, char c, char *font){
    c7d7:	55                   	push   %ebp
    c7d8:	89 e5                	mov    %esp,%ebp
		if ((d & 0x20) != 0) { p[2] = c; }
		if ((d & 0x10) != 0) { p[3] = c; }
		if ((d & 0x08) != 0) { p[4] = c; }
		if ((d & 0x04) != 0) { p[5] = c; }
		if ((d & 0x02) != 0) { p[6] = c; }
		if ((d & 0x01) != 0) { p[7] = c; }
    c7da:	8b 45 14             	mov    0x14(%ebp),%eax
    c7dd:	0f af 45 0c          	imul   0xc(%ebp),%eax
    c7e1:	03 45 10             	add    0x10(%ebp),%eax
	boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3);
	return;
}


void putfont8(char *vram, int xsize, int x, int y, char c, char *font){
    c7e4:	8a 55 18             	mov    0x18(%ebp),%dl
		if ((d & 0x20) != 0) { p[2] = c; }
		if ((d & 0x10) != 0) { p[3] = c; }
		if ((d & 0x08) != 0) { p[4] = c; }
		if ((d & 0x04) != 0) { p[5] = c; }
		if ((d & 0x02) != 0) { p[6] = c; }
		if ((d & 0x01) != 0) { p[7] = c; }
    c7e7:	03 45 08             	add    0x8(%ebp),%eax
	boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3);
	return;
}


void putfont8(char *vram, int xsize, int x, int y, char c, char *font){
    c7ea:	53                   	push   %ebx
	int i;
	char *p, d /* data */;
	for (i = 0; i < 16; i++) {
    c7eb:	31 db                	xor    %ebx,%ebx
    c7ed:	83 c0 07             	add    $0x7,%eax
		p = vram + (y + i) * xsize + x;
		d = font[i];
    c7f0:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
    c7f3:	8a 0c 19             	mov    (%ecx,%ebx,1),%cl
		if ((d & 0x80) != 0) { p[0] = c; }
    c7f6:	84 c9                	test   %cl,%cl
    c7f8:	79 03                	jns    c7fd <putfont8+0x26>
    c7fa:	88 50 f9             	mov    %dl,-0x7(%eax)
		if ((d & 0x40) != 0) { p[1] = c; }
    c7fd:	f6 c1 40             	test   $0x40,%cl
    c800:	74 03                	je     c805 <putfont8+0x2e>
    c802:	88 50 fa             	mov    %dl,-0x6(%eax)
		if ((d & 0x20) != 0) { p[2] = c; }
    c805:	f6 c1 20             	test   $0x20,%cl
    c808:	74 03                	je     c80d <putfont8+0x36>
    c80a:	88 50 fb             	mov    %dl,-0x5(%eax)
		if ((d & 0x10) != 0) { p[3] = c; }
    c80d:	f6 c1 10             	test   $0x10,%cl
    c810:	74 03                	je     c815 <putfont8+0x3e>
    c812:	88 50 fc             	mov    %dl,-0x4(%eax)
		if ((d & 0x08) != 0) { p[4] = c; }
    c815:	f6 c1 08             	test   $0x8,%cl
    c818:	74 03                	je     c81d <putfont8+0x46>
    c81a:	88 50 fd             	mov    %dl,-0x3(%eax)
		if ((d & 0x04) != 0) { p[5] = c; }
    c81d:	f6 c1 04             	test   $0x4,%cl
    c820:	74 03                	je     c825 <putfont8+0x4e>
    c822:	88 50 fe             	mov    %dl,-0x2(%eax)
		if ((d & 0x02) != 0) { p[6] = c; }
    c825:	f6 c1 02             	test   $0x2,%cl
    c828:	74 03                	je     c82d <putfont8+0x56>
    c82a:	88 50 ff             	mov    %dl,-0x1(%eax)
		if ((d & 0x01) != 0) { p[7] = c; }
    c82d:	80 e1 01             	and    $0x1,%cl
    c830:	74 02                	je     c834 <putfont8+0x5d>
    c832:	88 10                	mov    %dl,(%eax)


void putfont8(char *vram, int xsize, int x, int y, char c, char *font){
	int i;
	char *p, d /* data */;
	for (i = 0; i < 16; i++) {
    c834:	43                   	inc    %ebx
    c835:	03 45 0c             	add    0xc(%ebp),%eax
    c838:	83 fb 10             	cmp    $0x10,%ebx
    c83b:	75 b3                	jne    c7f0 <putfont8+0x19>
		if ((d & 0x04) != 0) { p[5] = c; }
		if ((d & 0x02) != 0) { p[6] = c; }
		if ((d & 0x01) != 0) { p[7] = c; }
	}
	return;
}
    c83d:	5b                   	pop    %ebx
    c83e:	5d                   	pop    %ebp
    c83f:	c3                   	ret    

0000c840 <putfonts8_asc>:


void putfonts8_asc(char* vram, int xsize, int x, int y, char c, char *s){
    c840:	55                   	push   %ebp
    c841:	89 e5                	mov    %esp,%ebp
    c843:	57                   	push   %edi
	//其实这就是一个简易版本的printf
	extern char hankaku[2048];
	for(; *s!=0x00; s++){
		putfont8(vram, xsize, x, y, c, hankaku+*s*16);
    c844:	0f be 7d 18          	movsbl 0x18(%ebp),%edi
	}
	return;
}


void putfonts8_asc(char* vram, int xsize, int x, int y, char c, char *s){
    c848:	56                   	push   %esi
    c849:	8b 75 10             	mov    0x10(%ebp),%esi
    c84c:	53                   	push   %ebx
    c84d:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	//其实这就是一个简易版本的printf
	extern char hankaku[2048];
	for(; *s!=0x00; s++){
    c850:	0f be 03             	movsbl (%ebx),%eax
    c853:	84 c0                	test   %al,%al
    c855:	74 22                	je     c879 <putfonts8_asc+0x39>
		putfont8(vram, xsize, x, y, c, hankaku+*s*16);
    c857:	c1 e0 04             	shl    $0x4,%eax


void putfonts8_asc(char* vram, int xsize, int x, int y, char c, char *s){
	//其实这就是一个简易版本的printf
	extern char hankaku[2048];
	for(; *s!=0x00; s++){
    c85a:	43                   	inc    %ebx
		putfont8(vram, xsize, x, y, c, hankaku+*s*16);
    c85b:	05 44 cd 00 00       	add    $0xcd44,%eax
    c860:	50                   	push   %eax
    c861:	57                   	push   %edi
    c862:	ff 75 14             	pushl  0x14(%ebp)
    c865:	56                   	push   %esi
		x+=8;
    c866:	83 c6 08             	add    $0x8,%esi

void putfonts8_asc(char* vram, int xsize, int x, int y, char c, char *s){
	//其实这就是一个简易版本的printf
	extern char hankaku[2048];
	for(; *s!=0x00; s++){
		putfont8(vram, xsize, x, y, c, hankaku+*s*16);
    c869:	ff 75 0c             	pushl  0xc(%ebp)
    c86c:	ff 75 08             	pushl  0x8(%ebp)
    c86f:	e8 63 ff ff ff       	call   c7d7 <putfont8>


void putfonts8_asc(char* vram, int xsize, int x, int y, char c, char *s){
	//其实这就是一个简易版本的printf
	extern char hankaku[2048];
	for(; *s!=0x00; s++){
    c874:	83 c4 18             	add    $0x18,%esp
    c877:	eb d7                	jmp    c850 <putfonts8_asc+0x10>
		putfont8(vram, xsize, x, y, c, hankaku+*s*16);
		x+=8;
	}
	return;
}
    c879:	8d 65 f4             	lea    -0xc(%ebp),%esp
    c87c:	5b                   	pop    %ebx
    c87d:	5e                   	pop    %esi
    c87e:	5f                   	pop    %edi
    c87f:	5d                   	pop    %ebp
    c880:	c3                   	ret    

0000c881 <init_mouse_cursor8>:

void init_mouse_cursor8(char *mouse,char bg){
    c881:	55                   	push   %ebp
    c882:	31 c9                	xor    %ecx,%ecx
    c884:	89 e5                	mov    %esp,%ebp
    c886:	8a 45 0c             	mov    0xc(%ebp),%al
    c889:	8b 55 08             	mov    0x8(%ebp),%edx
    c88c:	56                   	push   %esi
    c88d:	53                   	push   %ebx
    c88e:	89 c6                	mov    %eax,%esi
    c890:	31 c0                	xor    %eax,%eax
		".............***"
	};
	int x,y;
	for(y=0;y<16;y++){
		for(x=0;x<16;x++){
			switch (cursor[y][x]){
    c892:	8a 9c 01 dc c9 00 00 	mov    0xc9dc(%ecx,%eax,1),%bl
    c899:	80 fb 2e             	cmp    $0x2e,%bl
    c89c:	74 10                	je     c8ae <init_mouse_cursor8+0x2d>
    c89e:	80 fb 4f             	cmp    $0x4f,%bl
    c8a1:	74 12                	je     c8b5 <init_mouse_cursor8+0x34>
    c8a3:	80 fb 2a             	cmp    $0x2a,%bl
    c8a6:	75 11                	jne    c8b9 <init_mouse_cursor8+0x38>
				case '.':mouse[x+16*y]=bg;break;  //background
				case '*':mouse[x+16*y]=outline;break;   //outline
    c8a8:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    c8ac:	eb 0b                	jmp    c8b9 <init_mouse_cursor8+0x38>
	};
	int x,y;
	for(y=0;y<16;y++){
		for(x=0;x<16;x++){
			switch (cursor[y][x]){
				case '.':mouse[x+16*y]=bg;break;  //background
    c8ae:	89 f3                	mov    %esi,%ebx
    c8b0:	88 1c 02             	mov    %bl,(%edx,%eax,1)
    c8b3:	eb 04                	jmp    c8b9 <init_mouse_cursor8+0x38>
				case '*':mouse[x+16*y]=outline;break;   //outline
				case 'O':mouse[x+16*y]=inside;break;  //inside
    c8b5:	c6 04 02 02          	movb   $0x2,(%edx,%eax,1)
		"............*OO*",
		".............***"
	};
	int x,y;
	for(y=0;y<16;y++){
		for(x=0;x<16;x++){
    c8b9:	40                   	inc    %eax
    c8ba:	83 f8 10             	cmp    $0x10,%eax
    c8bd:	75 d3                	jne    c892 <init_mouse_cursor8+0x11>
    c8bf:	83 c1 10             	add    $0x10,%ecx
    c8c2:	83 c2 10             	add    $0x10,%edx
		"*..........*OOO*",
		"............*OO*",
		".............***"
	};
	int x,y;
	for(y=0;y<16;y++){
    c8c5:	81 f9 00 01 00 00    	cmp    $0x100,%ecx
    c8cb:	75 c3                	jne    c890 <init_mouse_cursor8+0xf>
				case '*':mouse[x+16*y]=outline;break;   //outline
				case 'O':mouse[x+16*y]=inside;break;  //inside
			}
		}
	}
}
    c8cd:	5b                   	pop    %ebx
    c8ce:	5e                   	pop    %esi
    c8cf:	5d                   	pop    %ebp
    c8d0:	c3                   	ret    

0000c8d1 <putblock8_8>:

void putblock8_8(char *vram,int xsize,int pxsize,int pysize,int px0,int py0,char *buf,int bxsize){
    c8d1:	55                   	push   %ebp
    c8d2:	89 e5                	mov    %esp,%ebp
    c8d4:	8b 45 1c             	mov    0x1c(%ebp),%eax
    c8d7:	56                   	push   %esi
	//显示鼠标,display_mouse 
	int x, y;
	for(y=0; y<pysize; y++){
    c8d8:	31 f6                	xor    %esi,%esi
			}
		}
	}
}

void putblock8_8(char *vram,int xsize,int pxsize,int pysize,int px0,int py0,char *buf,int bxsize){
    c8da:	53                   	push   %ebx
    c8db:	8b 5d 20             	mov    0x20(%ebp),%ebx
    c8de:	0f af 45 0c          	imul   0xc(%ebp),%eax
    c8e2:	03 45 18             	add    0x18(%ebp),%eax
    c8e5:	03 45 08             	add    0x8(%ebp),%eax
	//显示鼠标,display_mouse 
	int x, y;
	for(y=0; y<pysize; y++){
    c8e8:	3b 75 14             	cmp    0x14(%ebp),%esi
    c8eb:	7d 19                	jge    c906 <putblock8_8+0x35>
    c8ed:	31 d2                	xor    %edx,%edx
		for(x=0; x<pxsize; x++){
    c8ef:	3b 55 10             	cmp    0x10(%ebp),%edx
    c8f2:	7d 09                	jge    c8fd <putblock8_8+0x2c>
			vram[(py0+y)*xsize+(px0+x)]=buf[y*bxsize+x];
    c8f4:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
    c8f7:	88 0c 10             	mov    %cl,(%eax,%edx,1)

void putblock8_8(char *vram,int xsize,int pxsize,int pysize,int px0,int py0,char *buf,int bxsize){
	//显示鼠标,display_mouse 
	int x, y;
	for(y=0; y<pysize; y++){
		for(x=0; x<pxsize; x++){
    c8fa:	42                   	inc    %edx
    c8fb:	eb f2                	jmp    c8ef <putblock8_8+0x1e>
}

void putblock8_8(char *vram,int xsize,int pxsize,int pysize,int px0,int py0,char *buf,int bxsize){
	//显示鼠标,display_mouse 
	int x, y;
	for(y=0; y<pysize; y++){
    c8fd:	46                   	inc    %esi
    c8fe:	03 5d 24             	add    0x24(%ebp),%ebx
    c901:	03 45 0c             	add    0xc(%ebp),%eax
    c904:	eb e2                	jmp    c8e8 <putblock8_8+0x17>
		for(x=0; x<pxsize; x++){
			vram[(py0+y)*xsize+(px0+x)]=buf[y*bxsize+x];
		}
	}
}
    c906:	5b                   	pop    %ebx
    c907:	5e                   	pop    %esi
    c908:	5d                   	pop    %ebp
    c909:	c3                   	ret    

0000c90a <itoa>:

void itoa(int value,char *buf){
    c90a:	55                   	push   %ebp
	char tmp_buf[10] = {0};
    c90b:	31 c0                	xor    %eax,%eax
			vram[(py0+y)*xsize+(px0+x)]=buf[y*bxsize+x];
		}
	}
}

void itoa(int value,char *buf){
    c90d:	89 e5                	mov    %esp,%ebp
	char tmp_buf[10] = {0};
    c90f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			vram[(py0+y)*xsize+(px0+x)]=buf[y*bxsize+x];
		}
	}
}

void itoa(int value,char *buf){
    c914:	57                   	push   %edi
    c915:	56                   	push   %esi
    c916:	53                   	push   %ebx
    c917:	83 ec 10             	sub    $0x10,%esp
    c91a:	8b 55 08             	mov    0x8(%ebp),%edx
	char tmp_buf[10] = {0};
    c91d:	8d 7d ea             	lea    -0x16(%ebp),%edi
			vram[(py0+y)*xsize+(px0+x)]=buf[y*bxsize+x];
		}
	}
}

void itoa(int value,char *buf){
    c920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char tmp_buf[10] = {0};
    c923:	f3 aa                	rep stos %al,%es:(%edi)
    c925:	8d 7d ea             	lea    -0x16(%ebp),%edi
	char *tbp = tmp_buf;
	if((value >> 31) & 0x1){ // neg num 
    c928:	85 d2                	test   %edx,%edx
    c92a:	79 06                	jns    c932 <itoa+0x28>
		*buf++ = '-';
    c92c:	c6 03 2d             	movb   $0x2d,(%ebx)
		value = ~value + 1; 
    c92f:	f7 da                	neg    %edx

void itoa(int value,char *buf){
	char tmp_buf[10] = {0};
	char *tbp = tmp_buf;
	if((value >> 31) & 0x1){ // neg num 
		*buf++ = '-';
    c931:	43                   	inc    %ebx
    c932:	89 f9                	mov    %edi,%ecx
		value = ~value + 1; 
	}

	do{
		*tbp++ = ('0' + (char)(value % 10));
    c934:	be 0a 00 00 00       	mov    $0xa,%esi
    c939:	89 d0                	mov    %edx,%eax
    c93b:	41                   	inc    %ecx
    c93c:	99                   	cltd   
    c93d:	f7 fe                	idiv   %esi
    c93f:	83 c2 30             	add    $0x30,%edx
		value /= 10;
	}while(value);
    c942:	85 c0                	test   %eax,%eax
		*buf++ = '-';
		value = ~value + 1; 
	}

	do{
		*tbp++ = ('0' + (char)(value % 10));
    c944:	88 51 ff             	mov    %dl,-0x1(%ecx)
		value /= 10;
    c947:	89 c2                	mov    %eax,%edx
	}while(value);
    c949:	75 ee                	jne    c939 <itoa+0x2f>
    c94b:	89 de                	mov    %ebx,%esi
    c94d:	89 c8                	mov    %ecx,%eax
	while(tmp_buf != tbp--)
    c94f:	39 f8                	cmp    %edi,%eax
    c951:	74 0a                	je     c95d <itoa+0x53>
		*buf++ = *tbp;
    c953:	8a 50 ff             	mov    -0x1(%eax),%dl
    c956:	46                   	inc    %esi
    c957:	48                   	dec    %eax
    c958:	88 56 ff             	mov    %dl,-0x1(%esi)
    c95b:	eb f2                	jmp    c94f <itoa+0x45>
    c95d:	29 c1                	sub    %eax,%ecx
	*buf='\0';
    c95f:	c6 04 0b 00          	movb   $0x0,(%ebx,%ecx,1)
}
    c963:	83 c4 10             	add    $0x10,%esp
    c966:	5b                   	pop    %ebx
    c967:	5e                   	pop    %esi
    c968:	5f                   	pop    %edi
    c969:	5d                   	pop    %ebp
    c96a:	c3                   	ret    

0000c96b <sprintf>:


//实现可变参数的打印，主要是为了观察打印的变量。
void sprintf(char *str,char *format ,...){
    c96b:	55                   	push   %ebp
    c96c:	89 e5                	mov    %esp,%ebp
    c96e:	57                   	push   %edi
    c96f:	56                   	push   %esi
    c970:	53                   	push   %ebx
    c971:	83 ec 14             	sub    $0x14,%esp
    c974:	8b 5d 08             	mov    0x8(%ebp),%ebx

	int *var=(int *)(&format)+1; //得到第一个可变参数的地址
	char buffer[10];
	char *buf=buffer;
    c977:	8d 7d ea             	lea    -0x16(%ebp),%edi


//实现可变参数的打印，主要是为了观察打印的变量。
void sprintf(char *str,char *format ,...){

	int *var=(int *)(&format)+1; //得到第一个可变参数的地址
    c97a:	8d 55 10             	lea    0x10(%ebp),%edx
	char buffer[10];
	char *buf=buffer;
	while(*format){
    c97d:	8b 75 0c             	mov    0xc(%ebp),%esi
    c980:	8a 06                	mov    (%esi),%al
    c982:	84 c0                	test   %al,%al
    c984:	74 3d                	je     c9c3 <sprintf+0x58>
    c986:	8d 4e 01             	lea    0x1(%esi),%ecx
		if(*format!='%'){
    c989:	3c 25                	cmp    $0x25,%al
			*str++=*format++;
    c98b:	89 4d 0c             	mov    %ecx,0xc(%ebp)

	int *var=(int *)(&format)+1; //得到第一个可变参数的地址
	char buffer[10];
	char *buf=buffer;
	while(*format){
		if(*format!='%'){
    c98e:	74 05                	je     c995 <sprintf+0x2a>
			*str++=*format++;
    c990:	88 03                	mov    %al,(%ebx)
    c992:	43                   	inc    %ebx
			continue;
    c993:	eb e8                	jmp    c97d <sprintf+0x12>
		}
		else{
			format++;
			switch (*format){
    c995:	80 7e 01 64          	cmpb   $0x64,0x1(%esi)
    c999:	75 20                	jne    c9bb <sprintf+0x50>
				case 'd':itoa(*var,buf);while(*buf){*str++=*buf++;};var++;break;
    c99b:	57                   	push   %edi
    c99c:	ff 32                	pushl  (%edx)
    c99e:	89 55 e0             	mov    %edx,-0x20(%ebp)
    c9a1:	e8 64 ff ff ff       	call   c90a <itoa>
    c9a6:	58                   	pop    %eax
    c9a7:	5a                   	pop    %edx
    c9a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
    c9ab:	8a 07                	mov    (%edi),%al
    c9ad:	84 c0                	test   %al,%al
    c9af:	74 07                	je     c9b8 <sprintf+0x4d>
    c9b1:	43                   	inc    %ebx
    c9b2:	47                   	inc    %edi
    c9b3:	88 43 ff             	mov    %al,-0x1(%ebx)
    c9b6:	eb f3                	jmp    c9ab <sprintf+0x40>
    c9b8:	83 c2 04             	add    $0x4,%edx
				case 'x':break;
				case 's':break;
			}
			format++;
    c9bb:	83 c6 02             	add    $0x2,%esi
    c9be:	89 75 0c             	mov    %esi,0xc(%ebp)
    c9c1:	eb ba                	jmp    c97d <sprintf+0x12>
		}
	}
	*str='\0';
    c9c3:	c6 03 00             	movb   $0x0,(%ebx)
    c9c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
    c9c9:	5b                   	pop    %ebx
    c9ca:	5e                   	pop    %esi
    c9cb:	5f                   	pop    %edi
    c9cc:	5d                   	pop    %ebp
    c9cd:	c3                   	ret    
