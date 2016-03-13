;;
;; Title: VGM replay.
;;
;; Song format:
;; The VGM data used by the following replay routine is a stripped down version
;; of the VGM v1.61 format.
;;
;; First the 512 bytes header is removed.
;; Only the following commands are kepts.
;;
;; $b9 rr dd - HuC6280 command. *rr* is the index of the PSG register, 
;;             *dd* the byte to be written.
;; $62       - End of frame (wait for next vsync).
;; $66       - End of data.
;;
;; As there are only 10 PSG registers ($0800-$0809), the HuC6280 command byte is
;; omitted, and the register index and data are directly output.
;;
;; So if we read a value less to 10, we know that this is a register index and
;; the next byte is the data to be written to this register.
;; Otherwise it is either a "end of frame" or "end of data" special command.
;; The format is then.
;;
;; rr dd - *rr* is the index of the PSG register. Its value is between 0 and 9.
;;         *dd* is the data byte to be written to the register.
;; $f0   - End of frame.
;; $ff   - End of data.
;; 
;; Translated into pseudo-code, we will have :
;; > do
;; > {
;; >     A = vgm_read_byte
;; >     if (A < 10)
;; >     {   // PSG register index.
;; >         data = vgm_read_byte
;; >         psgport[A] = data
;; >     }
;; > } while (A < 10);
;; >
;; > if (A == 0xf0)
;; > {   // Nothing else to do for current frame.
;; > }
;; > else if (A == 0xff)
;; > {   // The song is finished.
;; > }
;; >
;;
;; Tool:
;; A small command line utility to strip down a standard VGM file is available
;; in the *tools* directory (*tools/vgmrip.c*).  
;; > vgmrip -b bb -o hhll input.vgm out 
;; The command line arguments are,
;;
;; -b, --bank - Specify the first ROM bank of the VGM data.
;; -o, --org  - Address of the VGM data.
;; input.vgm  - VGM (at least 1.61) song.
;; out        - Basename for output files.
;; 
;; *vgmrip* generates an assembly file containing the include directive and the
;; start bank and base address of the VGM data, as long as the bank and address
;; for song looping. The song data is split into files which size is at most 
;; 8192 bytes. 
;;
;; Example:
;; Let's suppose that the song data was generated using the *vgmrip* tool with
;; *song* as the output basename. The output assembly file will contain the 
;; following values,
;;
;;     song_bank         - The first ROM bank of the VGM data. 
;;     song_base_address - The base address of the VGM data.
;;     song_loop_bank    - ROM bank of the loop address.
;;     song_loop         - Loop address.
;;
;;
;; First the following ZP variables must be inialized,
;;
;;     vgm_base      - VGM data logical address.
;;     vgm_bank      - Current VGM data ROM bank.
;;     vgm_ptr       - Current VGM pointer.
;;     vgm_end       - Sentinal for the current VGM pointer. 
;;                     It is the MSB of ((vgm_mpr+1)<<13). 
;;     vgm_loop_bank - ROM bank of the loop.
;;     vgm_loop_ptr  - Logical address of the song loop.
;;
;;
;; Once these variables has been setup, the song is played by calling the 
;; *vgm_update* routine at each VSYNC. 
;;
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
;; >
;; >    lda    <vgm_base+1
;; >    clc
;; >    adc    #$20
;; >    sta    <vgm_end
;; > 
;; >    lda    #song_loop_bank
;; >    sta    <vgm_loop_bank
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
