    .include "start.s"
    .include "crc.s"
    .include "fat32.s"
    
    .bss
string_buffer .ds FAT32_MAX_PATH
data_buffer .ds 256

    .zp
txt_x .ds 1
txt_y .ds 1

    .code
_main:
    jsr    gfx_init
    
    stz    <txt_x
    stz    <txt_y
    jsr    set_cursor

    ; setup internal buffers address for data/directory entries and FAT    
    stw    #$3000, fat32.data_buffer
    stw    #$3200, fat32.fat_buffer

    ; read MBR
    jsr    fat32_read_mbr
    phx
    
    jsr    print_fat32_mbr_infos    
    
    plx
    cpx    #FAT32_OK
    bne    .loop
    
    ; mount partition #0
    lda    #0
    jsr    fat32_mount
    
    phx
    
    jsr    print_fat32_partition_infos
    
    plx
    cpx    #FAT32_OK
    bne    .loop
    
    ; print root directory entries
    jsr    newline
    
	stw    #str.dir, <_si
    jsr    print_string_raw

    lda    #$4
    sta    <txt_x
@l0:
    ; get and print the current valid directory entry
    jsr    fat32_read_entry
    bcc    @end

    phw    <_si 
    jsr    print_filename
    plw    <_si
    
    bra    @l0
@end:

    jsr    newline

    lda    #0
    sta    <txt_x

    ; find the directory entry for "/0001/hudson.pal"
    stw    #filename, <_r1
    stw    #string_buffer, <_dx
    jsr    fat32_find_file
    stw    <_si, <_dx
    
    jsr    print_find_status
    
    cpx    #FAT32_OK
    bne    @end

    ; open and print file data
    stw    <_dx, <_si
    jsr    fat32_open
    jsr    print_data

.loop:
    bra    .loop
    
; Initializes vdc and loads font.
gfx_init:
    lda    #VDC_BG_64x32
    jsr    vdc_set_bat_size    
    jsr    vdc_xres_320
    
    ; load font
    stw    #$2000, <_di 
    lda    #.bank(font_8x8)
    sta    <_bl
    stw    #font_8x8, <_si
    stw    #(FONT_8x8_COUNT*8), <_cx
    jsr    font_load
    ; set font palette index
    lda    #$00
    jsr    font_set_pal
    ; load tile palettes
    stb    #bank(palette), <_bl
    stw    #palette, <_si
    jsr    map_data
    cla
    ldy    #$10
    jsr    vce_load_palette
 
    ; enable background display
    vdc_reg  #VDC_CR
    vdc_data #VDC_CR_BG_ENABLE
    
    rts
    
palette:
    .dw VCE_BLACK, VCE_WHITE, VCE_BLACK, $0000, $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

filename: .db "/0001/hudson.pal", 0

str.mbr_status:   .db "MBR:", 0
str.partition:    .db "Partition #", 0
str.mount:        .db "Mount partition #", 0
str.fat_sector:   .db "FAT sector:", 0
str.root_sector:  .db "Root sector:", 0
str.dir:          .db "Dir:", 0
str.file          .db "file ", 0
str.directory     .db "dir  ", 0
str.open:         .db "Open: ", 0

str.ok:                   .db "Ok", 0
str.read_error:           .db "read error", 0
str.invalid_mbr:          .db "invalid mbr", 0
str.no_partitions:        .db "no partition found", 0
str.invalid_volume_id:    .db "invalid volume id", 0
str.invalid_partition_id: .db "invalid partition id", 0
str.not_found:            .db "not found", 0

str.status_msg:
    .dw str.ok
    .dw str.read_error
    .dw str.invalid_mbr
    .dw str.no_partitions
    .dw str.invalid_volume_id
    .dw str.invalid_partition_id
    .dw str.not_found 

; print a message describing the last error/status stored in X.
print_fat32_status:
    txa
    asl    A
    tax
    lda    str.status_msg, X
    sta    <_si
    inx
    lda    str.status_msg, X
    sta    <_si+1
    jsr    print_string_raw
    
    rts

; move cursor to the next line
newline:
    inc    <txt_y
; set cursor to a given BAT coordinate
set_cursor:
    ldx    <txt_x
    lda    <txt_y
    jsr    vdc_calc_addr 
    jsr    vdc_set_write
    rts

; print MBR infos
print_fat32_mbr_infos:
    stx   <_bl
    
	stw    #str.mbr_status, <_si
    jsr    print_string_raw
        
    ldx    <_bl
    jsr    print_fat32_status
    
    ldx    <_bl
    beq    @l0
        rts
@l0:

    clx    
@print_partition_sectors:
    phx

    jsr    newline

    stw    #str.partition, <_si
    jsr    print_string_raw

    plx
    jsr    print_hex_u8
    
    lda    #':'
    jsr    print_char

    txa
    asl    A
    asl    A
    tay
    lda    fat32.partition.sector+3, Y
    jsr    print_hex_u8    
    lda    fat32.partition.sector+2, Y
    jsr    print_hex_u8    
    lda    fat32.partition.sector+1, Y
    jsr    print_hex_u8    
    lda    fat32.partition.sector, Y
    jsr    print_hex_u8
    
    inx
    cpx    fat32.partition.count
    bne    @print_partition_sectors
    
    rts

; print partition infos (mount status, fat sector, root dir sector)
print_fat32_partition_infos:
    stx    <_bl
    
    jsr    newline
    
	stw    #str.mount, <_si
    jsr    print_string_raw
    
    lda    fat32.partition.current
    jsr    print_hex_u8
    
    lda    #':'
    jsr    print_char
    
    ldx    <_bl
    jsr    print_fat32_status

    jsr    newline
    
	stw    #str.fat_sector, <_si
    jsr    print_string_raw
    
    lda    fat32.fat_sector+3
    jsr    print_hex_u8
    lda    fat32.fat_sector+2
    jsr    print_hex_u8
    lda    fat32.fat_sector+1
    jsr    print_hex_u8
    lda    fat32.fat_sector
    jsr    print_hex_u8    

    jsr    newline

	stw    #str.root_sector, <_si
    jsr    print_string_raw

    lda    fat32.current_sector+3
    jsr    print_hex_u8
    lda    fat32.current_sector+2
    jsr    print_hex_u8
    lda    fat32.current_sector+1
    jsr    print_hex_u8
    lda    fat32.current_sector
    jsr    print_hex_u8    
    
    rts

print_filename:
    jsr    newline

    phw    <_si
    ldy    #fat32_dir_entry.attributes
    lda    [_si], Y
    bit    #FAT32_DIRECTORY
    beq    @file
@directory:
    stw    #str.directory, <_si
    bra    @l1
@file:
    stw    #str.file, <_si
@l1:
    jsr    print_string_raw

@name:  
    plw    <_si
    stw    #string_buffer, <_di
    jsr    fat32_get_filename

    stw    #string_buffer, <_si
    jsr    print_string_raw
    
    rts

print_find_status:
    phx
    phx
        
    jsr    newline    
    
    lda    #$00
    sta    <txt_x
    stw    #str.open, <_si
    jsr    print_string_raw

    stw    #filename, <_si
    jsr    print_string_raw

    lda    #' '
    jsr    print_char

    plx
    jsr    print_fat32_status

    plx
    rts
    
print_data:
@l0:
    stw    #data_buffer, <fat32.dst
    stw    #$10, <_cx
    jsr    fat32_read
    
    lda    <_cx
    ora    <_cx+1
    beq    @end
    
    jsr    newline

    cly
@l1:
    lda    data_buffer, Y
    jsr    print_hex_u8

    iny
    cpy    <_cx
    bne    @l1

    bra    @l0
@end:
    rts

    .include "data/fat32/read_sector.s"
    .include "data/fat32/fat32.img.inc"
    
fat32_read_sector = read_sector
