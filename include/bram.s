;;
;; Title: Backup RAM.
;;
;; Description:
;; The Tennokoe 2, IFU-30 and DUO systems provided an extra 2KB of battery
;; powered back up memory.
;;
;; The backup ram (BRAM for short) "file system" is organized as follows :
;; 
;; BRAM Header (16 bytes):
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
; Current error code
bm_error .ds 1

; Backup of mpr #4 
_bm_mpr4 .ds 1

    .code

_bm_id: .db 'H','U','B','M'
        .dw $8800 ; pointer to the first byte after BRAM
        .dw $8010 ; pointer to the next available BRAM slot
                  ; here this value is for a freshly formatted BRAM

;;
;; function: bm_bind
;; Unlock and map BRAM to mpr #4.
;;
;; Warning:
;; This routine switches the CPU to slow mode.
;; 
bm_bind:
    tma4                    ; save mpr4 segment
    sta    _bm_mpr4

    lda    #BM_SEGMENT      ; map BRAM to mpr #4
    tam4

    csl                     ; switch to slow mode

    lda    #$48             ; unlock BRAM
    sta    bm_unlock
    lda    #$75
    sta    bm_unlock
    lda    #$80 
    sta    bm_unlock
    rts

;;
;; function: bm_unbind
;; Lock BRAM and restore mpr #4.
;;
;; Warning:
;; This routines switches the CPU to fast mode.
;;
bm_unbind:
    lda    _bm_mpr4         ; restore mpr #4
    tam4

    lda    bm_lock          ; lock BRAM
    
    csh                     ; switch to fast mode

    rts

;;
;; function: bm_test
;; Test if data can safely be written to BRAM.
;;
;; Warning:
;;   bm_bind must have been previously called.
;;
;; Return:
;;   The carry flag is cleared if the backup RAM storage is valid.
;;
bm_test:
    ldx    #$07
@l0:
        lda    bm_addr, X   ; read a bytes from BRAM
        eor    #$ff         ; invert it
        sta    <_ax, X      ; save it in RAM 
        sta    bm_addr, X   ; and finally write it back to BRAM
        dex
        bpl    @l0
    ldx    #$07 
@l1:
        lda    bm_addr, X   ; check if what we have just written was
        cmp    <_ax, X      ; correctly stored to BRAM
        bne    @err
        eor    #$ff         ; restore BRAM data
        sta    bm_addr, X
        dex
        bpl    @l1
    clc
    rts
@err:
    sec
    rts

;;
;; function: bm_check_header
;; Checks if the BRAM header is valid.
;;
;; Warning:
;;   bm_bind must have been previously called.
;;
;; Return:
;;   The carry flag is cleared and A is set to 0 if the header is valid.
;;   Otherwise the carry flag is set and A is set to $ff.
;;
bm_check_header:
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
;; function: bm_detect
;; Detect if a BRAM is present on the system.
;; 
;; Return:
;; The carry flag is set if an error occured and the value of bm_error
;; is set as follow:
;;   0 - BRAM is present and fully formated.
;;   1 - BRAM is present but not formatted.
;;   2 - no BRAM was found.
;;
bm_detect:
    stz    bm_error

    jsr    bm_bind
    
    stw    #bm_header, <_di
    jsr    bm_test
    bcs    @not_found

    jsr    bm_check_header
    bcs    @not_formatted

@ok:
    jsr    bm_unbind
    clc
    rts

@not_found:
    inc    bm_error
@not_formatted:
    inc    bm_error
    jsr    bm_unbind
    sec
    rts

;;
;; function: bm_size
;; Get the storage capacity in bytes of the backup RAM.
;; Standard value is 2KB, but it can go up to 8KB.
;;
;; Return:
;;   _cx - BRAM total storage size (in bytes).
;;   bm_error - Error code. 
;;
;; Error value:
;;   $00 - Success.
;;   $ff - BRAM not formatted.
;;   
bm_size:
    jsr    bm_bind
    jsr    bm_check_header
    bcs    @err0
        stw    bm_end, <_cx
        subw   #bm_addr, <_cx
        lda    <_ch
        cmp    #$21
        bcs    @err1
        lda    <_ch
        bpl    @end
            stwz   <_cx
@end:
    jsr    bm_unbind
    stz    bm_error
    clc
    rts
@err1:
    lda    #$ff
    sta    bm_error
@err0:
    jsr    bm_unbind
    clc
    rts

;;
;; function: bm_format
;; Initialize backup memory.
;; Set header info and and limit of BRAM to the maximum amount of memory
;; available on this hardware.
;;
bm_format:
    jsr    bm_bind          ; bind BRAM
    jsr    bm_check_header  ; and check if the header is valid
    bcc    @ok              ; do not format if the header is ok

@format:
    ldx    #$07             ; format BRAM header
@l0:
    lda    _bm_id, X
    sta    bm_header, X
    dex
    bpl    @l0

    stwz   bm_entry         ; set the size of the first entry to 0

    ; Determine the size of the writeable area by walking every 256 
    ; bytes and checking if the 8 first bytes are writeable.
    ; Note that BRAM can go from 2k to 8k.
    stw    #bm_header, <_di
@l1:
    jsr    bm_test
    bcs    @l2
    lda    <_di+1
    cmp    #$a0             ; stop at the next bank.
    beq    @l2
    inc    <_di+1           ; check the next 256 bytes block.
    bra    @l1
@l2:
    lda    <_di+1           ; update the address of the last BRAM byte in the 
    sta    bm_end+1         ; header.
    stz    bm_end

@ok:
    jmp    bm_unbind

;;
;; function: bm_free
;; Returns the number of free bytes.
;;
;; Returns:
;;    carry flag - 1 upon success or 0 if an error occured.
;;    _cx - Number of free bytes.
;;    bm_error - Error code. 
;;
;; Error Value:
;;   $00 - Success. 
;;   $ff - Error.
;;
bm_free:
    jsr    bm_bind          ; bind BRAM
    jsr    bm_check_header  ; and check if the header is valid
    bcs    @err
@compute:
    lda    bm_end
    sec
    sbc    bm_next
    tax
    lda    bm_end+1
    sbc    bm_next+1
    sax
    sec
    sbc    #$12
    sta    <_cl
    sax
    sbc    #$00
    bpl    @ok
@reset:
    stz    <_cl
    cla
@ok:
    sta    <_ch
    jsr    bm_unbind
    stz    bm_error  
    clc
    rts
@err:
    sta    bm_error  
    jsr    bm_unbind
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
    sbc    #$00
    sta    <_ch

    stw    <_si, <_bx       ; compute checksum
    ldy    #$04
    stwz   <_dx
@compute:
    lda    [_bx], Y
    clc
    adc    <_dl
    sta    <_dl
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
    bpl    @compute
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
;;   bm_error - Error code.
;;   _si - Pointer to the beginning of the first matching BRAM entry.
;;   _dx - Pointer to the next BRAM entry.
;;   _cx - Entry size.
;;
;; Error code values:
;;   $01 - File not found
;;   $03 - Directory is corrupted.
;;   $04 - Empty file
;;   $ff - BRAM is not formatted
;;
bm_open:
    jsr    bm_bind              ; bind BRAM
    jsr    bm_check_header      ; and check if the header is valid
    bcs    @end
    
    stw    #bm_entry, <_si
@find:
    lda    [_si]
    sta    <_cl
    ldy    #$01
    lda    [_si], Y
    sta    <_ch
    ora    <_cl
    beq    @not_found
        addw   <_si, <_cx, <_dx ; Compute the address of the next entry.
        cmp    bm_end+1         ; Check if it does not go out of the
        bcc    @l0              ; BRAM area.
        bne    @directory_corrupted
        cmp    bm_end
        bcs    @directory_corrupted
@l0:
        lda    <_ch             ; Entry must be a least 16 bytes long.
        bne    @l1
        lda    <_cl
        cmp    #$10
        bcc    @directory_corrupted
@l1:
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
        lda    <_cl
        cmp    #$10
        beq    @empty_file
@ok:
    stz    bm_error
    clc
    rts 
@next:
    stw    <_dx, <_si
    bra    @find

@empty_file:
    lda    #$04
    bra    @end
@directory_corrupted:
    lda    #$03
    bra    @end
@not_found:
    lda    #$01
@end:
    sta    bm_error
    jsr    bm_unbind
    sec
    rts

;;
;; function: bm_adjust_pointer
;;
;; Parameters:
;;   _si - pointer to BRAM entry.
;;   _bp - offset (in bytes) in BRAM entry data.
;;   _ax - number of byte to read from BRAM.
;;
;; Return:
;;    The carry flag is cleared is the BRAM pointer was succesfully
;;    adjusted to point to the requested BRAM entry data area. It is set
;;    if the requested size is zero or if the requested area to read is
;;    out the entry bounds.
;;
;;    <_ax, <_cx - adjusted size
;;    <_dx - entry pointer
;; 
bm_adjust_pointer:
    lda    <_al             ; test if the requested size is zero
    ora    <_ah
    beq    @err
    addw   #16, <_bp, <_bx
    ldy    #1                ; check if the offset does not cross entry
    lda    <_bh
    cmp    [_si], Y          ; limits
    bne    @l0
    lda    <_bl
    cmp    [_si]
@l0:
    bcc    @l1
@err:
    sec
    rts
@l1:
    addw   <_bx, <_si, <_dx
    addw   <_ax, <_bx       ; adjust length
    lda    [_si]
    sec
    sbc    <_bl
    sta    <_bl
    lda    [_si], Y
    sbc    <_bh
    sta    <_bh
    bpl    @ok
        addw    <_bx, <_ax
@ok:
    stw    <_ax, <_cx
    clc
    rts
    
;;
;; function: bm_read
;; Read entry data.
;;
;; Parameters:
;;   _di - pointer to the output buffer.
;;   _bx - pointer to the BRAM entry name.
;;   _bp - offset (in bytes) in BRAM entry data.
;;   _ax - number of bytes to read from BRAM.
;;
;; Return:
;;   _ax - number of bytes to read from BRAM.
;;   _dx - entry pointer
;;   bm_error - Error code.
;;
;; Error values:
;;   $02 - invalid checksum.
;;
bm_read:
    jsr    bm_open
    bcs    @error
    jsr    bm_checksum              ; verify checksum
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
    jsr    bm_adjust_pointer
    bcs    @ok
    cly
@copy:
        lda    [_dx], Y
        sta    [_di], Y
        iny
        bne    @next
            inc    <_dx+1
            inc    <_di+1
@next:
        dec    <_cl
        bne    @copy
        dec    <_ch
        bpl    @copy
@ok:
    jsr    bm_unbind
    stz    bm_error
    clc
    rts
@checksum_error:
    lda    #$02
    sta    bm_error
    jsr    bm_unbind
    sec
@error:
    rts

;;
;; function: bm_write
;; Update entry data.
;;
;; Warning:
;; The entry will not be resized if the offset and size exceed the
;; current entry area.
;;
;; Parameters:
;;   _di - pointer to the input buffer.
;;   _bx - pointer to the BRAM entry name.
;;   _bp - offset (in bytes) in BRAM entry data.
;;   _ax - number of bytes to write BRAM.
;;
;; Return:
;;   bm_error - Error code.
;;
;; Error values:
;;   $01 - File not found
;;   $03 - Directory is corrupted.
;;   $04 - Empty file
;;   $ff - BRAM is not formatted
;;
bm_write:
    jsr    bm_open
    bcs    @end
    jsr    bm_adjust_pointer
    bcs    @ok
    cly
@copy:
        lda    [_di], Y
        sta    [_dx], Y
        iny
        bne    @next
            inc    <_dx+1
            inc    <_di+1
@next:
        dec    <_cl
        bne    @copy
        dec    <_ch
        bpl    @copy
@checksum:
    jsr    bm_checksum
    ldy    #bm_entry_checksum
    cla
    sec
    sbc    <_dl
    sta    [_si], Y
    iny
    cla
    sbc    <_dh
    sta    [_si], Y
@ok:
    jsr    bm_unbind
    stz    bm_error
    clc
@end:
    rts

;;
;; function: bm_delete
;; Delete the specified entry.
;;
;; Parameters:
;;   _bx - pointer to the BRAM entry name.
;; 
bm_delete:
    jsr    bm_open
    bcs    @ok
    stw    bm_next, <_bx    ; address of the byte after the last entry 
    subw   <_dx, <_bx       ; #bytecount = end - next + 2
    addw   #2, <_bx
    memcpy_mode #SOURCE_INC_DEST_INC
    memcpy_args <_dx, <_si, <_bx
    jsr    memcpy
    subw   <_cx, bm_next    ; adjust the address 
    jsr    bm_unbind
    stz    bm_error
    clc
@ok:
    rts

;;
;; function: bm_files
;; Get file by index and store the information in a buffer.
;;
;; Entry format:
;;
;;   00-01 - User ID.
;;   02-0f - Entry name.
;;   10-11 - Entry size.
;;
;; Parameters:
;;   _bx - Address to the buffer where the entry informations will be 
;;         stored.
;;   _al - File index (starts at 1).
;;
;; Return:
;;   _si - Entry address
;;   bm_error - Error code.
;;
;; Error values:
;;   $00 - Success.
;;   $01 - Cannot find file.
;;   $ff - BRAM is not formatted.
;;
bm_files:
    jsr    bm_bind          ; bind BRAM
    jsr    bm_check_header  ; and check if the header is valid
    bcs    @end
    
    stw    #bm_entry, <_si
    clx
@loop:
        ; check if we crossed the end of the "used" area
        lda    <_si+1
        cmp    bm_next+1
        bcc    @next
        bne    @not_found
        lda    <_si
        cmp    bm_next
        bcs    @not_found
@next:
        inx
        cpx    <_al
        beq    @copy
        
        ; jump to next entry
        ldy    #bm_entry_size
        lda    [_si], Y
        clc
        adc    <_si
        pha
        iny
        lda    [_si], Y
        adc    <_si+1
        sta    <_si+1
        pla
        sta    <_si
        bra    @loop

    ldy    #bm_entry_name       ; copy entry user ID + entry name
    subw   #02, <_bx
@copy:
    lda    [_si], Y
    sta    [_bx], Y
    iny
    cpy    #$10
    bne    @copy
    
    addw   #$12, <_bx            ; copy entry size
    lda    [_si]
    sta    [_bx]
    ldy    #$01
    lda    [_si], Y
    sta    [_bx], Y

@ok:
    stx    <_al
    jsr    bm_unbind
    stz    bm_error
    clc
@end:
    rts
@not_found:
    stx    <_al
    jsr    bm_unbind
    lda    #$01
    sta    bm_error
    sec
    rts

;;
;; function: bm_getptr.2
;; Given a pointer to the BRAM, obtain the name of the entry and the
;; pointer to the next entry.
;;
;; Set _bp to bm_entry for the first entry.
;;
;; Parameters:
;;   _bp - Address of the current entry.
;;   A - MSB of the destination address for the entry name.
;;   X - LSB of the destination address for the entry name.
;;
;; Return:
;;   A - MSB of the next entry address.
;;   X - LSB of the next entry address.
;;   _cx - Entry size.
;;   bm_error - Error code.
;;   carry flag - Set if an error occured.
;;
;; Error values:
;;   $00 - Success.
;;   $01 - Cannot find file. _bp is past the last entry.
;;   $ff - BRAM is not formatted.
;;
bm_getptr.2:
    sta    <_di+1
    stx    <_di
    jsr    bm_bind
    jsr    bm_check_header
    bcs    @end
    
    lda    <_bp+1
    cmp    bm_next+1
    bcc    @l0
    bne    @not_found
    lda    <_bp
    cmp    bm_next
    bcs    @not_found
@l0:
    lda    <_bp
    ora    <_bp+1
    beq    @end
    
    lda    [_bp]            ; _cx will contain the length of the entry
    sta    <_cl
    ldy    #1
    lda    [_bp], Y
    sta    <_ch
    
    ora    <_cl             ; test if the entry is empty
    beq   @empty
        ; <_si now points to the name of the entry
        addw   #4, <_bp, <_si
        ldy    #11
@copy:
        lda    [_si], Y
        sta    [_di], Y
        dey
        bpl    @copy
        
        addw   <_cx, <_bp, <_ax ; next pointer
        jsr    bm_unbind
        stz    bm_error
        lda    <_ah
        ldx    <_al
        clc
        rts
@empty:
    cla
    bra    @end
@not_found:
    lda    #$01
@end:
    sta    bm_error
    jsr    bm_unbind
    cla
    clx
    sec
    rts

;;
;; function: bm_create
;; Create a new entry at the end of current storage.
;;
;; Parameters:
;;   _bx - pointer to the entry name.
;;   _ax - entry size.
;;
;; Return:
;;   bm_error - Error code.
;;   carry flag - Set if an error occured.
;;
;; Error values:
;;   $00 - Success.
;;   $01 - Cannot find file. _bp is past the last entry.
;;   $05 - Not enough space for entry.
;;   $ff - BRAM is not formatted.
;;
bm_create:
    jsr    bm_bind
    jsr    bm_check_header
    bcc    @ok
    bra    @end
@err:
    lda    #$05
@end:
    sta    bm_error
    jsr    bm_unbind
    cla
    clx
    sec
    rts
@ok:
    ; check if there is enough space.
    addw   #$12, bm_next, <_dx
    addw   <_ax, <_dx
    lda    bm_end+1
    cmp    <_dh
    bcc    @err
    bne    @create_file
    lda    bm_end
    cmp    <_dl
    bcc    @err
@create_file:
    ; compute offset of the unused area
    stw    bm_next, <_si
    lda    <_al
    clc
    adc    #$10
    sta    [_si]
    lda    <_ah
    adc    #$00
    ldy    #1
    sta    [_si],Y
    ; store it
    lda    bm_next
    clc
    adc    [_si]
    sta    <_dl
    sta    bm_next
    lda    bm_next+1
    adc    [_si],Y
    sta    <_dh
    sta    bm_next+1
    ; initialize sentinel
    cla
    sta    [_dx]
    sta    [_dx], Y
    ; copy entry name
    clx
    ldy    #4
@copy:
    sxy
    lda    [_bx], Y
    sxy
    sta    [_si], Y
    iny
    inx
    cpx    #12
    bne    @copy
    ; clear file
    lda    <_al
    ora    <_ah
    beq    @checksum
    stw    <_si, <_bx
    ldy    #$10
    cla
@l0:
    sta    [_bx], Y
    iny
    bne    @l1
        inc    <_bh
@l1:
    dec    <_al
    bne    @l0
    dec    <_ah
    bpl    @l0
@checksum:
    jsr    bm_checksum
    ldy    #$02
    cla
    sec
    sbc    <_dl
    sta    [_si], Y
    iny
    cla
    sbc    <_dh
    sta    [_si], Y
@success:
    stz    bm_error
    jsr    bm_unbind
    clc
    rts

;;
;; function: bm_exists
;; Check if there is an entry which name matches the one given as
;; parameter.
;;
;; Parameters:
;;   _bx - pointer to the entry name.
;;
;; Return:
;;   X - 1 if a matching entry exists, 0 otherwise.
;;   carry flag - Cleared if a matching entry exists.
;;   bm_error - Error code.
;;
;; Error values:
;;   $00 - Success.
;;   $01 - Cannot find file. _bp is past the last entry.
;;   $ff - BRAM is not formatted.
;;
bm_exists:
    jsr    bm_open
    bcs    @err
@ok:
    jsr    bm_unbind
    ldx    #$01
    lda    bm_error
    clc
    rts
@err:
    cla
    clx
    rts
