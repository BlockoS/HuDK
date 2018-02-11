  .include "word.inc"
  .include "system.inc"
  .include "irq.inc"

  .code
  .import unmap_data
  .import remap_data
  .import map_data

  .export vdc_init	
  .export _VDC_setVSyncHandler
  .export _VDC_setHSyncHandler

_VDC_setVSyncHandler:
; TODO : update irq_m
; TODO : check ax=0 (check X only since if X = 0, A is ZP address...no possible)
	stw #no_hook, vsync_hook
	rts
	
_VDC_setHSyncHandler:
; TODO : update irq_m
; TODO : check ax=0 (check X only since if X = 0, A is ZP address...no possible)
    stw #no_hook, hsync_hook
	rts
