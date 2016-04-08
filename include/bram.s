;;
;; Title: Backup RAM.
;;
;; Description:
;; The Tennokoe 2, IFU-30 and DUO systems provided an extra 2KB of battery
;; powered back up memory.
;;
;; The backup ram (BRAM for short) "file system" is organized as follows :
;; 
;; BRAM Header ($10 bytes):
;;
;;   00-03 - Header tag (equals to "HUBM")
;;   04-05 - Pointer to the first byte after BRAM.
;;   06-07 - Pointer to the next available BRAM slot (first unused byte).
;;   08-0f - Reserved (set to 0).
;;
;; BRAM Entry Header:
;;   00-01 - Entry size. This size includes the $10 bytes of the entry header.
;;   02-03 - Checksum. The checksum is the sum of the entry bytes starting from
;;           byte #4 (i.e all bytes except the entry size and checksum). The
;;           value stored is the opposite of the computed checksum. This way
;;           the consistency check only consists in adding the ssum the stored
;;           checksum and the newly computed one. If this sum is 0, the entry is
;;           valid.
;;   04-0f - Entry name. 
;;
;; BRAM Entry name:
;;   00-01 - Unique ID.
;;   02-0b - ASCII name (padded with spaces).
;;
;; BRAM Entry Data:
;;   Miscenalleous data which size is given in the BRAM Entry Header.
;;
;; BRAM Entry Trailer (2 bytes):
;;   This 2 bytes are set to zeroes. They are not part of the BRAM "used area".
;;   It is used as a linked list terminator.
;;
;; For CD-ROM programs, the following BRAM routines are provided from the System
;; Card:
;;   - bm_format
;;   - bm_free 
;;   - bm_read
;;   - bm_write
;;   - bm_delete
;;   - bm_files
;;

BM_SEGMENT = $F7

bm_addr   = $8000
bm_entry  = bm_addr+$10

  .rsset bm_addr
bm_header   .rs 4
bm_end      .rs 2
bm_next     .rs 2
bm_reserved .rs 8

   .rsset $00
bm_entry_size     .rs 2
bm_entry_checksum .rs 2
bm_entry_name     .rs 12

bm_lock   = $1803
bm_unlock = $1807

    .bss
;;
;; byte: bm_error
;; Error code.
;;
bm_error .ds 1

; Backup of mpr #4 
_bm_mpr4 .ds 1

    .code

_bm_id: .db 'H','U','B','M'
        .dw $8800 ; pointer to the first byte after BRAM
        .dw $8010 ; pointer to the next available BRAM slot
                  ; here this value is for a freshly formatted BRAM

;;
;; function: bm_lock
;; Unlock and map BRAM to mpr #4.
;;
;; Warning:
;; This routine disables interrupts and switches the CPU to slow mode.
;; 
bm_lock:
    sei                     ; disable interrupts

    tma4                    ; save mpr4 segment
    sta    _bm_mpr4

    lda    #BM_SEGMENT      ; map BRAM to mpr #4
    tam4

    csl                     ; switch to slow mode

    lda    #$80             ; unlock BRAM
    sta    bm_unlock 
    rts

;;
;; function: bm_enable
;; Unlock and map BRAM to mpr #4. It also checks if the header is valid.
;;
;; Warning:
;; This routine disables interrupts and switches the CPU to slow mode.
;;
;; Return:
;;   The carry flag is cleared and A is set to 0 if the header is valid.
;;   Otherwise the carry flag is set and A is set to $ff.
;;
bm_enable:
    bsr    bm_lock          ; unlock and map BRAM
    ldx    #3               ; check if the BRAM starts with "HUBM"
@loop:
        lda    bm_header, X
        cmp    _bm_id, X
        bne    @invalid
        dex
        bpl    @loop
@ok:
    cla
    clc
    rts
@invalid:
    lda    #$ff
    sec
    rts

;;
;; function: bm_disable
;; Lock BRAM and restore mpr #4.
;;
;; Warning:
;; This routines switches the CPU to fast mode and enables interrupts.
;;
bm_disable:
    lda    _bm_mpr4         ; restore mpr #4
    tam4

    lda    bm_lock          ; lock BRAM
    
    csh                     ; switch to fast mode
    cli                     ; enable interrupts

    rts

;;
;; function: bm_check_write
;; Check if we can safely write to BRAM.
;;
;; Only the first 8 bytes are tested.
;;
;; Parameters:
;;   _di - current BRAM address
;;
;; Return:
;;   The carry flag is set if an error occured.
;;
bm_check_write:
    ldy    #$07
@l0:
    lda    [_di], Y         ; read byte from BRAM
    eor    #$ff             ; invert it
    sta    _ax, Y           ; save it for latter 
    sta    [_di], Y         ; write it back to BRAM
    dey
    bpl    @l0
    
    ldy    #$07
@l1:
    lda    [_di], Y         ; re-read byte from BRAM
    cmp    _ax, Y           ; check if it is what was written in the previous
    bne    @err             ; loop
    eor    #$ff             ; restore BRAM value
    sta    [_di], Y
    dey
    bpl    @l1
@ok:
    clc
    rts
@err:
    sec
    rts

;;
;; function: bm_format
;; Initialize backup memory.
;; Set header info and and limit of BRAM to the maximum amount of memory
;; available on this hardware.
;;
bm_format:
    jsr    bm_enable        ; enable BRAM and check if the header is valid
    bcc    @ok              ; do not format if the header is ok

@format:
    ldx    #$07             ; format BRAM header
@l0:
    lda    _bm_id, X
    sta    bm_header, X
    dex
    bpl    @l0

    stwz   bm_entry         ; set the size of the first entry to 0

    ; Determine the size of the writeable area by walking every 256 bytes and
    ; checking the 8 first bytes are writeable.
    ; Note that BRAM can go from 2k to 8k.
    stw    #bm_header, <_di
@l1:
    bsr    bm_check_write
    bcs    @l2
    lda    <_di+1
    cmp    #$a0             ; stop at the next bank.
    beq    @l2
    inc    <_di+1           ; check the next 256 bytes block.
    bra    @l1
@l1:
    lda    <_di+1           ; update the address of the last BRAM byte in the 
    sta    bm_end+1         ; header.
    stz    bm_end

@ok:
    jmp    bm_disable

;;
;; function: bm_free
;; Returns the number of free bytes.
;;
;; Returns:
;;    carry flag - 1 upon success or 0 if an error occured.
;;    A - MSB of the number of free bytes or $ff if an error occured.
;;    X - LSB of the number of free bytes or $ff if an error occured.
;;    bm_error - Error code ($00: success, $ff: error).
;;
bm_free:
    jsr    bm_enable
    bcs    @err
@compute:
    sec
    lda    bm_end
    sbc    bm_next
    tax
    lda    bm_end+1
    sbc    bm_next+1
    sax
    sec
    sbc    #$12
    sax
    sbc    #$00
    bpl    @ok
@reset:
        cla
        clx
@ok:
    pha
    jsr    bm_disable
    pla
    stz    bm_error  
    clc
    rts
@err:
    sta    bm_error  
    jsr    bm_disable
    lda    #$ff
    tax
    sec
    rts

;;
;; function: bm_checksum
;; Compute checksum. The checksum is the sum of all entry bytes except the first
;; 4 ones (file size and checksum).
;;
;; Parameters:
;;   _si - BRAM file entry pointer.
;;
;; Return:
;;   _dx - checksum
;;
bm_checksum:
    lda    [_si]            ; get file size.
    sec                     ; and substract the size of "file size" and checksum
    sbc    #$04
    sta    <_cl
    ldy    #$01
    lda    [_si], Y
    sbc    #$01
    sta    <_ch

    stw    <_si, <_bx       ; compute checksum
    ldy    #$04
    stwz   <_dx
@compute:
    lda    [_bx], Y
    clc
    adc    <_dl
    sta    <_cl
    bcc    @l1
        inc    <_dh
@l1:
    iny
    bne    @l2
        inc    <_bh
@l2:
    dec    <_cl
    bne    @compute
    dec    <_ch
    bne    @compute
    rts

;;
;; function: bm_open
;; Finds the BRAM entry whose name is given as argument.
;; 
;; Parameters:
;;   _bx - pointer to the BRAM entry name.
;;
;; Return:
;;   carry flag - 1 upon success or 0 if an error occured.
;;   _si - Pointer to the beginning of the first matching BRAM entry.
;;   bm_error - Error code.
;;
;; Error code values:
;;   $01 - file not found
;;   $04 - empty file
;;   $ff - invalid header
;;
bm_open:
    jsr    bm_enable
    bcs    @end
    stw    bm_entry, <_si
@find:
    lda    [_si]                ; The last entry is a sentinel with a size of 0.
    sta    <_cl                 ; This means that we did not find our entry.
    ldy    #$01
    lda    [_si], Y
    sta    <_ch
    ora    <_cl
    beq    @not_found
        cly
        ldx    #bm_entry_name   ; Check entry name.
@cmp_name:
        lda    [_bx], Y
        sxy
        cmp    [_si], Y
        bne    @next
            sxy
            inx
            iny
            cpy    #12
            bcc    @cmp_name
@check_size:
        lda    <_ch
        bne    @ok
        lda    <_ch
        cmp    #$10
        bcc    @empty_file
@next:
    addw   <_cx, <_si
    bra    @find
@ok:
    stz    bm_error
    clc
    rts 
@empty_file:
    lda    #$04
    bra    @end
@not_found:
    lda    #$01
@end:
    sta    bm_error
    jsr    bm_disable
    sec
    rts

;;
;; function: bm_read
;; Read entry data.
;;
;; Parameters:
;;   _bx - pointer to the BRAM entry name.
;;
bm_read:
    jsr    bm_open
    bcs    @error
    jsr    bm_checkcum              ; verify checksum
    bcs    @error
    ldy    #bm_entry_checksum
    lda    [_si], Y
    clc
    adc    <_dl
    bne    @checksum_error
    iny
    lda    [_si], Y
    clc
    adc    <_dh
    bne    @checksum_error
@read:
    ; [todo]
    jsr    bm_disable
    clc
    rts
@checksum_error:
    ; [todo]
    jsr    bm_disable
    sec
    rts
@error:
    rts
;;
;; function: bm_write
;; Write data.
;;
bm_write:
    rts
;;
;; function: bm_delete
;; Delete the specified entry.
;; 
bm_delete:
    rts
;;
;; function: bm_files
;; 
bm_files:
    rts
