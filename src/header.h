#ifndef header
#define header
#include <x86.h>


#define io_hlt() asm("hlt")


#define io_cli() asm("cli")
#define io_sti() asm("sti")


#endif
