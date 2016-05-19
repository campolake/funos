#ifndef SCREEN_H
#define SCREEN_H

//显示相关的一些启动参数
struct BootInfo
{
	char cyls,leds,vmode,reserve;
	short scrnx,scrny;
	char * vram;
};




#endif