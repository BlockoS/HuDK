#ifndef HUDK_H_
#define HUDK_H_

void __fastcall__ VDC_setVSyncHandler( void (*handler) (void) );
void __fastcall__ VDC_setHSyncHandler( void (*handler) (void) );

void __fastcall__ VCE_loadPal( void (*handler) (void) );

#endif