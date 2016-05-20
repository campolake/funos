#include "header.h"
#include "dev/chr_dev/screen.h"
#include "dev/chr_dev/fontascii.h"

void wmain(void)
{

	chr_dev_init();
	struct BootInfo *binfo = (struct BootInfo*) 0x0ff0;
	init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
	int mx, my;
	mx = (binfo->scrnx-16)/2;
	my = (binfo->scrny-28-16)/2;
	char mcursor[256];
	// putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

	char s[10];
	sprintf(s, "(%d, %d)", mx, my);
	// putfonts8_asc(binfo->vram, binfo->scrnx, 16, 16, COL8_848400, s);
	
	
	init_mouse_cursor8(mcursor, COL8_848400);


	for (;;) {
		io_hlt();
	}
}

