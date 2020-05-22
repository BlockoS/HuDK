#ifndef _VGM_H_
#define _VGM_H_

#asm
  .include "vgm.s"
#endasm

void __fastcall vgm_setup(char far* song<_bl:_si>, int loop_offset<_cx>, unsigned char loop_bank<acc>);
void __fastcall vgm_update();

#endif // _VGM_H_
