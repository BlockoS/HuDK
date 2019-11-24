;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2019 MooZ
;;

    .include "start.s"
    .include "bram.s"
   
MAIN_MENU   = 0
FILE_MENU   = 1
EDITOR_MENU = 2

    .zp
cursor_x .ds 1
cursor_y .ds 1

entry_count .ds 1

menu_id   .ds 1
action_id .ds 1
file_id   .ds 1

navigation_state .ds 1

file_ptr .ds 2

joybtn    .ds 1
joybtn_id .ds 1

menu_callbacks .ds 2
callback       .ds 2

color_index .ds 1

bm_capacity      .ds 2
bm_available     .ds 2
bm_entry.size    .ds 2
bm_entry.start   .ds 2
bm_entry.offset  .ds 2
bm_entry.edit    .ds 1
bm_entry.backup  .ds 1
bm_entry.value   .ds 1
bm_entry.palette .ds 1

    .bss
bm_namebuf       .ds 16
current_menu     .ds 1
bm_data          .ds 1024

    .code
_main:
    ; switch resolution to 512x224
    jsr    vdc_xres_512
    jsr    vdc_yres_224
    
    ; clear palettes
    stwz   color_reg
    clx
@clear_palettes:
    stwz   color_data
    stwz   color_data
    inx
    bne    @clear_palettes
    
    ; load default font
    stw    #$2000, <_di 
    lda    #.bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load

    lda    #$00
    jsr    font_set_pal

    ; load palette
    lda    #bank(palette)
    sta    <_bl
    stw    #palette, <_si
    jsr    map_data
    cla
    ldy    #$03
    jsr    vce_load_palette
        
    jsr    main_menu

    stz    <irq_m
    ; set vsync vec
    irq_on #INT_IRQ1
    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #vsync_proc
    
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #(VDC_CR_BG_ENABLE | VDC_CR_VBLANK_ENABLE)
        
    cli 
@loop:
    vdc_wait_vsync
    jsr    joypad_callback
    bra    @loop

; Clear the screen with the space character.
clear_screen:
    ; fill BAT with space character
    lda    #' '
    sta    <_bl
    lda    vdc_bat_width
    sta    <_al
    lda    vdc_bat_height
    sta    <_ah
    ldx    #$00
    lda    #$00
    jsr    print_fill
    rts

; Display the list of BRAM entries.
display_file_list:
    ldx    #bm_file_list_x0
    lda    #bm_file_list_y
    jsr    set_cursor

    stz    bm_namebuf+13
    stz    bm_namebuf+14

    stz    <entry_count
    stw    #bm_entry, <_bp
@list:
        lda    #high(bm_namebuf)
        ldx    #low(bm_namebuf)
        jsr    bm_getptr.2
        bcs    @end
        sta    <_bp+1
        stx    <_bp

        jsr    print_entry_description
        inc    <entry_count

        bbr0   <entry_count, @newline
@next_column:
        ldx    #bm_file_list_x1
        bra    @set_cursor
@newline:
        ldx    #bm_file_list_x0
        inc    <cursor_y
@set_cursor:
        lda    <cursor_y
        jsr    set_cursor
        bra    @list
@end:
    rts

; VSync callback
vsync_proc:
    jsr    gradient_loop
    jsr    joypad_read
    rts

; make the 2nd color of the 2nd palette loops through gradient palette.
gradient_loop:
    lda    <color_index
    inc    A
    and    #$1f
    sta    <color_index
    lsr    A
    tax
    lda    #$12
    sta    color_reg_lo
    stz    color_reg_hi
    lda    gradient_lo, X
    sta    color_data_lo
    lda    gradient_hi, X
    sta    color_data_hi
    rts

; trigger callback according to joystick state and current menu
joypad_callback:
    stz    <joybtn_id
    lda    joytrg
    sta    <joybtn
@loop:
    lsr    <joybtn
    bcs    @run
    bne    @next
@end:
    rts
@run:
        lda    <joybtn_id
        asl    A
        tay
        lda    [menu_callbacks], Y
        sta    <callback
        iny
        lda    [menu_callbacks], Y
        sta    <callback+1
        jsr    run_callback
@next:
        inc    <joybtn_id
        bra    @loop

run_callback:
    jmp     [callback]

callback_table:
    .dw    main_menu_callbacks
    .dw    file_menu_callbacks
    .dw    editor_menu_callbacks

main_menu_callbacks:
    .dw main_menu_I, do_nothing,      do_nothing, do_nothing
    .dw do_nothing,  main_menu_right, do_nothing, main_menu_left

file_menu_callbacks:
    .dw file_menu_I,  file_menu_II,    file_menu_SEL,  file_menu_RUN
    .dw file_menu_up, file_menu_right, file_menu_down, file_menu_left

editor_menu_callbacks:
    .dw editor_menu_I,  editor_menu_II,    editor_menu_SEL,  editor_menu_RUN
    .dw editor_menu_up, editor_menu_right, editor_menu_down, editor_menu_left

; Swicth menu.
menu_set:
    sta    <menu_id
    asl    A
    tay
    lda    callback_table, Y
    sta    <menu_callbacks
    iny
    lda    callback_table, Y
    sta    <menu_callbacks+1
    rts

do_nothing:
    rts

main_menu_I:
    lda    <entry_count
    bne    @l0
        rts
@l0:
    lda    #$02
    sta    <_al
    jsr    main_menu_highlight

    lda    #FILE_MENU
    jsr    menu_set
    
    stz    <file_id
    
    ldx    #bm_file_list_x0
    stx    <cursor_x
    
    lda    #bm_file_list_y
    sta    <cursor_y

    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    vdc_set_read
    
    ldy    #$02
    lda    #$01
    jsr    highlight_span

    rts

main_menu_left:
    stz    <_al
    jsr    main_menu_highlight
    
    ldy    <action_id
    dey
    bpl    @l0
        ldy    #$03
@l0:
    inc    <_al
    sty    <action_id

    jsr    main_menu_highlight
    rts

main_menu_right:
    stz    <_al
    
    jsr    main_menu_highlight

    ldy    <action_id
    iny
    cpy    #$04
    bne    @l0
        cly
@l0:
    inc    <_al
    sty    <action_id

    jsr    main_menu_highlight
    rts
    
main_menu_highlight:
    ldy    <action_id
    lda    bm_main_menu_x, Y
    tax
    lda    bm_main_menu_y, Y
    jsr    set_cursor
    jsr    vdc_set_read
    
    lda    bm_main_menu_w, Y
    tay
    lda    <_al
    jsr    highlight_span
    rts

main_file_highlight:
    rts

file_menu_I:
    bbs0   <navigation_state, @end
    
    lda    <action_id
    asl    A
    tax
    jmp    [@jump_table, X]
@end:
    rts
@jump_table:
    .dw edit_entry
    .dw bm_backup
    .dw confirm_restore
    .dw confirm_delete
    
file_menu_II:
    bbs0   <navigation_state, @end
    
    lda    #MAIN_MENU
    jsr    menu_set

    stz    <_ah
    jsr    highlight_id

    lda    #$01
    sta    <_al
    
    jsr    main_menu_highlight
@end:
    rts
    
file_menu_SEL:
    bbr0   <navigation_state, @end

    jsr    clear_msg_box
    rmb0   <navigation_state

    jmp    file_menu_II
@end:
    rts

file_menu_RUN:
    bbr0   <navigation_state, @end
    
    rmb0   <navigation_state

    lda    <action_id
    asl    A
    tax
    jmp    [@jump_table, X]
@end:
    rts
@jump_table:
    .dw do_nothing
    .dw do_nothing
    .dw bm_restore
    .dw bm_delete.2
    
file_menu_up:
    bbs0   <navigation_state, @end
    
    stz    <_ah
    jsr    highlight_id

    lda    <file_id
    cmp    #$02
    bcc    @l0
        sec
        sbc    #$02
        sta    <file_id
        dec    <cursor_y
@l0:
    inc    <_ah
    jsr    highlight_id
@end:
    rts

file_menu_down:
    bbs0   <navigation_state, @end
    
    stz    <_ah
    jsr    highlight_id

    lda    <file_id
    clc
    adc    #$02
    cmp    <entry_count
    bcs    @l0
        sta    <file_id
        inc    <cursor_y
@l0:
    inc    <_ah
    jsr    highlight_id
@end:
    rts

file_menu_right:
    bbs0   <navigation_state, @end
    
    stz    <_ah
    jsr    highlight_id

    lda    <file_id
    cmp    <entry_count
    bcs    @l0
    bit    #$01
    bne    @l0
        inc    <file_id
        lda    #bm_file_list_x1
        sta    <cursor_x
@l0:
    inc    <_ah
    jsr    highlight_id
@end:
    rts

file_menu_left:
    bbs0   <navigation_state, @end
    
    stz    <_ah
    jsr    highlight_id
    lda    <file_id
    and    #$01
    beq    @l0
        dec    <file_id
        lda    #bm_file_list_x0
        sta    <cursor_x
@l0:
    inc    <_ah
    jsr    highlight_id
@end:
    rts

highlight_id:
    ldx    <cursor_x
    lda    <cursor_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    vdc_set_read
    
    ldy    #$02
    lda    <_ah
    jsr    highlight_span
    rts

set_cursor:
    stx    <cursor_x
    sta    <cursor_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    rts

next_line:
    inc    <cursor_y
    ldx    <cursor_x
    lda    <cursor_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    rts

highlight_span:
    asl    A
    asl    A
    asl    A
    asl    A
    sta    <_al
@loop:
    ldx    video_data_l
    lda    video_data_h
    stx    video_data_l
    and    #$0f
    ora    <_al
    sta    video_data_h
    dey
    bne    @loop
    rts

; Print entry description (entry number, size, file id, name)
print_entry_description:
    ; entry number
    lda    <entry_count
    jsr    print_hex_u8
    
    ; spacing
    lda    #' '
    jsr    print_char

    ; print size
    ldx    <_cl
    lda    <_ch
    jsr    print_dec_u16

    ; spacing
    lda    #' '
    jsr    print_char

    ; print user id
    ldx    bm_namebuf
    lda    bm_namebuf+1
    jsr    print_hex_u16

    ; spacing
    lda    #' '
    jsr    print_char

    ; print name
    stw    #bm_namebuf+2, <_si
    jsr    print_string_raw
    rts

;
; Display an error message
;
; Parameters:
;   X - error id
;
print_error_msg:
    lda    bm_err_msg.lo, X
    sta    <_si
    lda    bm_err_msg.hi, X
    sta    <_si+1

    ldx    #bm_msg_x
    lda    #bm_msg_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    
    jsr    print_string_raw
    rts
;
; Display confirmation message
;
; Parameters:
;    X - confirmation message id
;  _bx - entry name
;
print_confirmation_msg:
    ; set string
    lda    bm_confirm_msg.lo, X
    sta    <_si
    lda    bm_confirm_msg.hi, X
    sta    <_si+1

    ; print message    
    ldx    #bm_msg_x
    lda    #bm_msg_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    print_string_raw
    
    ; entry name
    stw    <_bx, <_si
    ldx    #10
    jsr    print_string_n
    
    ; ?
    lda    #'?'
    jsr    print_char
    
    ; next line
    addw   vdc_bat_width, <_di
    
    ; print confirmation
    jsr    vdc_set_write
    stw    #bm_confirmation_msg, <_si
    jsr    print_string_raw

    rts

; Clear main menu message box.
clear_msg_box:
    lda    #' '
    sta    <_bl
    lda    #bm_msg_w
    sta    <_al
    lda    #bm_msg_h
    sta    <_ah
    ldx    #bm_msg_x
    lda    #bm_msg_y
    jmp    print_fill

; This routine is supposed to test if the BRAM is fully functional.
bm_full_test:
    rts

;
; Main menu.
;
main_menu:
    jsr    clear_screen
    
    stwz   <bm_capacity
    stwz   <bm_available

    ; detect backup ram.
    jsr    bm_detect
    ; compute backup ram capacity.
    lda    bm_error
    bne    @l0
        jsr    bm_size
        bcs    @l1
            stw    <_cx, <bm_capacity
@l1:
    ; compute available memory size.
    jsr    bm_free
    bcs    @l0
        stw    <_cx, <bm_available
@l0:

    ; Print status row description.
    stw    #bm_info_txt, <_si
    stb    #bm_status_w, <_al
    stb    #bm_status_h, <_ah
    ldx    #bm_status_x
    lda    #bm_status_y
    jsr    print_string
    
    ; Print bram status.
    ldx    #bm_detect_msg_x
    lda    #bm_detect_msg_y
    jsr    set_cursor

    ldx    bm_error
    lda    bm_detect_msg.lo, X
    sta    <_si
    lda    bm_detect_msg.hi, X
    sta    <_si+1
    jsr    print_string_raw

    jsr   next_line
    ldx   <bm_capacity
    lda   <bm_capacity+1
    jsr   print_dec_u16

    jsr   next_line
    ldx   <bm_available
    lda   <bm_available+1
    jsr   print_dec_u16

    ; Display file list.
    jsr    display_file_list

    ; Display menu and cursor.
    ldx    bm_main_menu_x
    lda    bm_main_menu_y
    jsr    set_cursor

    stw    #bm_main_menu, <_si
    jsr    print_string_raw
    
    ; Reset navigation
    stz    <action_id
    stz    <navigation_state
    
    lda    #MAIN_MENU
    jsr    menu_set
    
    stz    <_ah
    jsr    highlight_id

    lda    #$01
    sta    <_al
    jsr    main_menu_highlight

    rts
    
;
; Load a complete backup entry to RAM.
; 
; Parameters:
;   file_id - id of the entry to load.
;
bm_load:
    stw    #bm_entry, <_bp
    ldy    <file_id
@next_entry:
    phy
    
    stw    <_bp, <file_ptr 
    
    lda    #high(bm_namebuf)
    ldx    #low(bm_namebuf)
    jsr    bm_getptr.2
    sta    <_bp+1
    stx    <_bp
    
    ply
    dey
    bpl    @next_entry

    jsr    bm_bind
    jsr    bm_check_header
    bcs    @end

    stw    <_cx, bm_entry.size
    memcpy_mode #SOURCE_INC_DEST_INC
    memcpy_args <file_ptr, #bm_data, <bm_entry.size
    jsr    memcpy

@end:
    jsr    bm_unbind
    rts

;
; Create a backup entry.
; A backup entry contains the complete original entry (even its header).
; The file id is $baca and the extension BAKn (with n starting at 1) is
; added to the original filename.
; Once the backup is finished the program jumps to the RESET vector.
;
; Parameters:
;   file_id - id of the entry to backup.
;
bm_backup:
    jsr    bm_load
    bcc    @ok
@err_load:
    ldx    #bm_err_load
    jmp    print_error_msg
@ok:
    ; clear checksum
    stwz   bm_namebuf+bm_entry_checksum
    ; set file id
    stw    #$BACA, bm_namebuf+4
    ; copy file name
    stw    bm_data+6,  bm_namebuf+6
    stw    bm_data+8,  bm_namebuf+8
    stw    bm_data+10, bm_namebuf+10
    ; add extension "BAK1"
    stw    #$4142, bm_namebuf+12
    stw    #$314B, bm_namebuf+14
    ; search for entry
@check_name:
    stw    #(bm_namebuf+4), <_bx
    jsr    bm_exists
    bcs    @not_found
        ; change name
        inc    bm_namebuf+15
        bra    @check_name
@not_found:
    ; set file size
    addw   #16, bm_data, bm_namebuf
    ; create entry
    stw    bm_data, <_ax
    stw    #(bm_namebuf+4), <_bx
    jsr    bm_create
    bcs    @err_create
    ; write data
    stw    #bm_data, <_di
    stw    #(bm_namebuf+4), <_bx
    stw    bm_data, <_ax
    stwz   <_bp
    jsr    bm_write
    bcs    @err_write
        jmp   _reset
@err_write:
    ldx    #bm_err_write
    jmp    print_error_msg
@err_create:
    ldx    #bm_err_full
    jmp    print_error_msg
    
;
; Display a confirmation message for entry deletion.
; Lock pad movement and buttons I, II.
; 
confirm_delete:
    smb0   <navigation_state

    stw    #bm_data, <_bx
    lda    <file_id
    inc    A
    sta    <_al
    jsr    bm_files
    ; [todo] error msg?

    stw    #(bm_data+6), <_bx
    ldx    #bm_confirm_delete
    jsr    print_confirmation_msg
    
    rts

;
; Delete entry and restart.
;
bm_delete.2:
    stw    #(bm_data+4), <_bx
    jsr    bm_delete
    jmp    _reset
    rts

;
; Check if the entry is a backup.
; Display a confirmation message.
; Lock pad movement and buttons I, II.
; 
confirm_restore:
    smb0   <navigation_state

    jsr    bm_load
    bcs    @err_load
    ; check if it is a backup
    lda    bm_data+4
    cmp    #$ca
    bne    @not_a_backup
    lda    bm_data+5
    cmp    #$ba
    bne    @not_a_backup
    ; check if the original file exists
    stw    #bm_data+20, <_bx
    jsr    bm_exists
    bcc    @ok
@orig_missing:
    jmp    bm_restore.ext
@ok:
    ; print message
    stw    #(bm_data+22), <_bx
    ldx    #bm_confirm_restore
    jsr    print_confirmation_msg
    rts
@err_load:
    ldx    #bm_err_load
    bra    @err
@not_a_backup:
    ldx    #bm_err_backup
@err:
    jsr    print_error_msg
    rmb0   <navigation_state
    rts

;
; Restore entry and restart.
;
bm_restore:
    ; delete original entry
    stw    #bm_data+20, <_bx
    jsr    bm_delete
    bcs    @err_delete
bm_restore.ext = *
    ; create a new entry
    subw   #$10, bm_data+16, <_ax
    stw    #bm_data+20, <_bx
    jsr    bm_create
    bcs    @err_create
    ; write entry data
    stw    #bm_data+32, <_di
    stw    #bm_data+20, <_bx
    stz    <_bp
    subw   #$10, bm_data+16, <_ax
    jsr    bm_write
    bcs    @err_write
    jmp    _reset
@err_delete:
    ldx    #bm_err_delete
    bra    @err
@err_create:
    ldx    #bm_err_create
    bra    @err
@err_write:
    ldx    #bm_err_write
@err:
    jsr    print_error_msg
    rmb0   <navigation_state
    rts

; [todo]
edit_entry:
    jsr    bm_load
    bcc    @ok
@err_load:
    ldx    #bm_err_load
    jsr    print_error_msg
    rts
@ok:
 
    ; remove header size
    subw   #16, <bm_entry.size

    jsr    clear_screen

    ; print filename
    ldx    #bm_status_x
    lda    #bm_status_y
    jsr    set_cursor
    ; 1. entry number
    lda    <file_id
    jsr    print_hex_u8
    ; 2. spacing
    lda    #' '
    jsr    print_char
    ; 3. filename
    stw    #bm_namebuf+2, <_si
    jsr    print_string_raw
    
    ; print message
    stw    #bm_edit_msg, <_si
    ldx    #0
    lda    #4
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    print_string_raw

    ; display entry
    stwz   <bm_entry.start
    stwz   <bm_entry.offset
    jsr    display_entry

    ; highlight entry byte
    stb    #01, <bm_entry.palette
    jsr    highlight_entry_byte

    lda    #EDITOR_MENU
    jsr    menu_set

    rts

; Display the content of the selected entry
display_entry:
    ldx    #bm_editor_data_x
    lda    #bm_editor_data_y
    jsr    set_cursor

    addw   #(bm_data+16), <bm_entry.start, <_si ; skip header
    stw    <bm_entry.size, <_cx
    
@line:

    cly
@hex:
    lda    [_si], Y
    jsr    print_hex_u8
    lda    #' '
    jsr    print_char

    subw   #1, <_cx
    lda    <_cl
    ora    <_ch
    beq    @hex_end

    iny
    cpy    #16
    bne    @hex
@hex_end:

    ldx    #bm_editor_data_char_x
    stx    <cursor_x
    lda    <cursor_y
    jsr    set_cursor

    iny
    sxy
    cly
@ascii:
    lda    [_si], Y
    jsr    print_char

    dex
    beq    @end

    iny
    cpy    #16
    bne    @ascii

    addw   #16, <_si

    ldx    #0
    inc    <cursor_y
    lda    <cursor_y
    cmp    #(bm_editor_data_y+bm_editor_data_h)
    beq    @end
    jsr    set_cursor

    bra    @line

@end:
    rts

; Compute the BAT position of a given entry byte
compute_entry_bat_pos:
    lda    <bm_entry.offset
    sec
    sbc    <bm_entry.start
    sta    <_dl
    sta    <_bl
    lda    <bm_entry.offset+1
    sbc    <bm_entry.start+1
    sta    <_dh

    lda    <_bl
    and    #15
    sta    <_bl
    asl    A
    clc
    adc    <_bl
    tax

    lsrw   <_dx
    lsrw   <_dx
    lsrw   <_dx
    lsrw   <_dx

    lda    <_dl
    clc
    adc    #bm_editor_data_y
    sta    <_dl

    rts

; Highlight the currently selected byte
highlight_entry_byte:
    jsr    compute_entry_bat_pos

    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    vdc_set_read

    ldy    #$02
    lda    <bm_entry.palette
    jsr    highlight_span

    lda    <_bl
    clc
    adc    #bm_editor_data_char_x
    tax
    lda    <_dl
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    jsr    vdc_set_read

    ldy    #$01
    lda    <bm_entry.palette
    jsr    highlight_span

    rts

; Redraw the current entry byte
update_entry_byte:
    jsr    compute_entry_bat_pos

    jsr    vdc_calc_addr 
    jsr    vdc_set_write

    lda    <bm_entry.value
    jsr    print_hex_u8
    
    lda    <_bl
    clc
    adc    #bm_editor_data_char_x
    tax
    lda    <_dl
    jsr    vdc_calc_addr 
    jsr    vdc_set_write

    lda    <bm_entry.value
    jsr    print_char

    jsr    highlight_entry_byte
    
    rts

editor_menu_I:
    addw   #(bm_data+16), <bm_entry.offset, <_si
    bbr0   <bm_entry.edit, @edit_start
        rmb0   <bm_entry.edit
        lda    <bm_entry.value
        sta    [_si]
        
        stb    #1, <bm_entry.palette
        bra    @exit
@edit_start:
    smb0   <bm_entry.edit
    lda    [_si]
    sta    <bm_entry.value
    sta    <bm_entry.backup

    stb    #2, <bm_entry.palette
@exit:
    jsr    highlight_entry_byte
    rts

editor_menu_II:
    bbr0   <bm_entry.edit, @exit
        rmb0   <bm_entry.edit
        lda    <bm_entry.backup
        sta    <bm_entry.value
        stb    #1, <bm_entry.palette
        jsr    update_entry_byte
@exit:
    rts

editor_menu_SEL:
    jsr    main_menu
    rts

editor_menu_RUN:
    stw    #(bm_data+16), <_di
    stw    #(bm_data+4), <_bx
    stw    bm_entry.size, <_ax
    stwz    <_bp
    jsr    bm_write
    bcs    @err_write
        jmp    main_menu
@err_write:
    ldx    #bm_err_write
    jmp    print_error_msg

editor_menu_up:
    bbr0   <bm_entry.edit, @move
        dec    <bm_entry.value
        
        stb    #2, <bm_entry.palette
        jsr    update_entry_byte
        rts
@move:
    jsr    editor_menu_move_up
    rts

editor_menu_right:
    bbr0   <bm_entry.edit, @move
        lda    <bm_entry.value
        clc
        adc    #$10
        sta    <bm_entry.value

        stb    #2, <bm_entry.palette
        jsr    update_entry_byte
        rts
@move:
    jsr    editor_menu_move_right
    rts

editor_menu_left:
    bbr0   <bm_entry.edit, @move
        lda    <bm_entry.value
        sec
        sbc    #$10
        sta    <bm_entry.value
        
        stb    #2, <bm_entry.palette
        jsr    update_entry_byte
        rts
@move:
    jsr    editor_menu_move_left
    rts

editor_menu_down:
    bbr0   <bm_entry.edit, @move
        inc    <bm_entry.value

        stb    #2, <bm_entry.palette
        jsr    update_entry_byte
        rts
@move:
    jsr    editor_menu_move_down
    rts

editor_menu_move_up:
    lda    <bm_entry.offset+1
    bne    @ok
        lda    <bm_entry.offset
        cmp    #16
        bcs    @ok
            rts
@ok:

    stb    #0, <bm_entry.palette
    jsr    highlight_entry_byte

    subw   #16, <bm_entry.offset

    jsr    editor_menu_scroll_up

    stb    #1, <bm_entry.palette
    jsr    highlight_entry_byte
    
    rts

editor_menu_move_right:
    lda    <bm_entry.size
    sec
    sbc    #01
    tax
    lda    <bm_entry.size+1
    sbc    #00
    cmp    <bm_entry.offset+1
    bne    @ok
        cpx    <bm_entry.offset
        bne    @ok
            rts
@ok:
    stb    #0, <bm_entry.palette
    jsr    highlight_entry_byte
    
    incw   <bm_entry.offset

    jsr    editor_menu_scroll_down

    stb    #1, <bm_entry.palette
    jsr    highlight_entry_byte
    rts

editor_menu_move_down:
    lda    <bm_entry.offset
    clc
    adc    #16
    tax
    lda    <bm_entry.offset+1
    adc    #0
    cmp    <bm_entry.size+1
    bcc    @ok
    bne    @exit
        cpx    <bm_entry.size
        bcc    @ok
@exit
            rts
@ok:

    stb    #0, <bm_entry.palette
    jsr    highlight_entry_byte

    addw   #16, <bm_entry.offset

    jsr    editor_menu_scroll_down

    stb    #1, <bm_entry.palette
    jsr    highlight_entry_byte
    
    rts

editor_menu_move_left:
    lda    <bm_entry.offset
    ora    <bm_entry.offset+1
    bne    @ok
        rts
@ok:
    stb    #0, <bm_entry.palette
    jsr    highlight_entry_byte

    decw   <bm_entry.offset

    jsr    editor_menu_scroll_up

    stb    #1, <bm_entry.palette
    jsr    highlight_entry_byte

    rts

editor_menu_scroll_up:
    lda    <bm_entry.offset+1
    cmp    <bm_entry.start+1
    bcc    @scroll
    bne    @no_scroll
        lda    <bm_entry.offset
        cmp    <bm_entry.start
        bcs    @no_scroll
@scroll:
            subw  #16, <bm_entry.start
            jsr   display_entry
@no_scroll:
    rts

editor_menu_scroll_down:
    lda    <bm_entry.offset
    sec
    sbc    <bm_entry.start
    tax
    lda    <bm_entry.offset+1
    sbc    <bm_entry.start+1
    cmp    #high(bm_editor_data_h*16)
    bcc    @no_scroll
    bne    @scroll
        cpx    #low(bm_editor_data_h*16)
        bcc    @no_scroll
@scroll:
            addw  #16, <bm_entry.start
            jsr   display_entry
@no_scroll:
    rts

bm_detect_msg_x = 11
bm_detect_msg_y = 1

bm_detect_msg.lo:
    .dwl bm_detect_msg00, bm_detect_msg01, bm_detect_msg02
bm_detect_msg.hi:
    .dwh bm_detect_msg00, bm_detect_msg01, bm_detect_msg02

bm_detect_msg00: .db "ok", 0
bm_detect_msg01: .db "not found", 0
bm_detect_msg02: .db "not formatted", 0

bm_info_txt: .db "   Status:\n"
             .db "     Size:\n"
             .db "Available:", 0

bm_main_menu:
    .db "     EDIT     ",$a9,"    BACKUP    ",$a9
    .db "    RESTORE   ",$a9,"    DELETE    ",$00
bm_main_menu_x:
    .db 02, 17, 32, 47
bm_main_menu_y:
    .db 26, 26, 26, 26
bm_main_menu_w:
    .db 14, 14, 14, 14

bm_status_x = 1
bm_status_y = 1
bm_status_w = 32
bm_status_h = 3

bm_file_list_x0 = 6
bm_file_list_x1 = 34
bm_file_list_y  = 8

bm_msg_x = 1
bm_msg_y = 5
bm_msg_w = 62
bm_msg_h = 2

bm_editor_data_x = 0
bm_editor_data_y = 6
bm_editor_data_w = 64
bm_editor_data_h = 20
bm_editor_data_char_x = 48

    .rsset 0
bm_err_write  .rs 1
bm_err_create .rs 1
bm_err_delete .rs 1
bm_err_load   .rs 1
bm_err_full   .rs 1
bm_err_backup .rs 1

bm_err_msg.lo:
    .dwl bm_err_write_msg, bm_err_create_msg, bm_err_delete_msg
    .dwl bm_err_load_msg, bm_err_full_msg, bm_err_backup_msg
bm_err_msg.hi:
    .dwh bm_err_write_msg, bm_err_create_msg, bm_err_delete_msg
    .dwh bm_err_load_msg, bm_err_full_msg, bm_err_backup_msg
bm_err_write_msg:  .db "**** BRAM write failed! ****", 0
bm_err_create_msg: .db "**** Failed to create file! ****", 0
bm_err_delete_msg: .db "**** Failed to delete file! ****", 0
bm_err_load_msg:   .db "**** Failed to load file! ****", 0
bm_err_full_msg:   .db "**** Not enough space! ****", 0
bm_err_backup_msg: .db "**** Not a backup file! ****", 0

    .rsset 0
bm_confirm_delete  .rs 1
bm_confirm_restore .rs 1

bm_confirm_msg.lo:
    .dwl bm_confirm_delete_msg, bm_confirm_restore_msg
bm_confirm_msg.hi:
    .dwh bm_confirm_delete_msg, bm_confirm_restore_msg 

bm_confirm_delete_msg:
    .db "Do you really want to delete ", 0
bm_confirm_restore_msg:
    .db "Do you want to restore ", 0
bm_confirmation_msg:
    .db "Press SELECT to CANCEL / RUN to CONFIRM.", 0
bm_edit_msg:
    .db "Press SELECT to CANCEL / RUN to save.", 0

palette:
    .db $00,$00,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$ff,$01,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

gradient_lo:
    .db $79,$38,$30,$28,$20,$18,$10,$08,$00,$08,$10,$18,$20,$28,$30,$38
gradient_hi:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    