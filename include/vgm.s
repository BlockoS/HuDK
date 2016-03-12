;;
;; Title: VGM replay.
;;
;; Example:
;; >    lda    #low(song_base_address)
;; >    sta    <vgm_base
;; >    sta    <vgm_ptr
;; >
;; >    lda    #high(song_base_address)
;; >    sta    <vgm_base+1
;; >    sta    <vgm_ptr+1
;; >
;; >    lda    #song_bank
;; >    sta    <vgm_bank
;; >    sta    <vgm_loop_bank
;; >
;; >    lda    <vgm_base+1
;; >    clc
;; >    adc    #$20
;; >    sta    <vgm_end
;; > 
;; >    stw    #song_loop, <vgm_loop_ptr
;; >
;; > ; [...]
;; >
;; > vsync_hook:
;; >    jsr    vgm_update
;; >    ; [...]
;; >    rts
;;

;;
;; ubyte: vgm_mpr
;; MPR used to map VGM data.
;;
vgm_mpr = 6

    .zp
;;
;; uword: vgm_base
;; VGM data base pointer.
;;
vgm_base .ds 2
;;
;; ubyte: vgm_bank
;; First ROM bank of the VGM data.
;; 
vgm_bank .ds 1
;;
;; uword: vgm_ptr
;; Current VGM data pointer.
;;
vgm_ptr  .ds 2
;;
;; ubyte: vgm_end
;; VGM data upper bound. 
;;
vgm_end  .ds 1
;;
;; ubyte: vgm_loop_bank
;; Bank of the VGM loop address.
;;
vgm_loop_bank .ds 1
;;
;; ubyte: vgm_loop_ptr
;; VGM loop address.
;;
vgm_loop_ptr  .ds 2

    .code
;;
;; Macro: vgm_map
;; Map VGM data to MPR 6.
;;
  .macro vgm_map
    tma6
    pha
    lda    <vgm_bank
    tam6
  .endmacro

;;
;; Macro: vgm_unmap
;; Restore the value of MPR 6.
;;
  .macro vgm_unmap
    pla
    tam6
  .endmacro

;;
;; Function: vgm_next_byte
;; Increment VGM data pointer.
;;
;; If the VGM data pointer crosses the MPR boundary, the address is reseted and
;; the next bank is mapped. 
;;
;; This routine may be called after each VSYNC.
;;
vgm_next_byte:
    inc    <vgm_ptr
    bne    .l0
        inc    <vgm_ptr+1
        lda    <vgm_ptr+1
        cmp    <vgm_end
        bcc    .l0
            stw    <vgm_base, <vgm_ptr
            inc    <vgm_bank
            lda    <vgm_bank
            tam6
.l0:
    rts

;;
;; Function: vgm_update
;; Read VGM frame data.
;;
vgm_update:
    vgm_map
.loop
    lda    [vgm_ptr]
    cmp    #$f0
    bcs    .check_end
        tax
        jsr    vgm_next_byte

        lda    [vgm_ptr] 
        sta    psgport, X

        jsr    vgm_next_byte

        bra    .loop
.check_end:
    cmp    #$ff
    bne    .frame_end
        vgm_unmap
        lda    <vgm_loop_bank
        sta    <vgm_bank
        stw    <vgm_loop_ptr, <vgm_ptr
        rts
.frame_end:
    jsr    vgm_next_byte
    vgm_unmap
    rts
