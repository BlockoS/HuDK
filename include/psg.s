;;
;; Title: PSG Functions.
;;
  .ifdef CA65
    .include "ca65/psg.s"   
  .endif

  .code
;;
;; function: psg_init
;; Initialize PSG.
;;
;; Details:
;; Mute and disable all audio channels.
;;
;; Parameters:
;; *none* 
;;
psg_init:
   stz    psg_mainvol        ; set main volume to zero
   stz    psg_lfoctrl        ; disable LFO

   lda    #(PSG_CHAN_COUNT-1)
@loop:
   sta    psg_chn            ; set channel to use
   stz    psg_ctrl           ; disable channel
   stz    psg_pan            ; mute channel
   dec    A
   bpl    @loop

   lda    #4                 ; disable noise for the last 2 channels
   sta    psg_chn
   stz    psg_noise
   lda    #5
   sta    psg_chn
   stz    psg_noise

   rts
