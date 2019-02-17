;;
;; Title: FAT 32 driver.
;;

;;
;; ushort: FAT32_MAX_PATH
;; Maximum character length of a path.
;;
FAT32_MAX_PATH = 260
;;
;; ubyte: FAT32_MAX_PARTITION_COUNT
;; Maximum number of msdos partitions.
;;
FAT32_MAX_PARTITION_COUNT = 4
;;
;; ushort: FAT32_MBR_SIGNATURE
;; Master Boot Record signature.
;;
FAT32_MBR_SIGNATURE = $AA55
;;
;; ubyte: FAT32_PARTITION
;;
FAT32_PARTITION = $0b
;;
;; ubyte: FAT32_INT13_PARTITION
;;
FAT32_INT13_PARTITION = $0c
;;
;; ubyte: FAT32_BOOT_JMP
;; JMP opcode (x86).
;;
FAT32_BOOT_JMP = $EB
;;
;; ubyte: FAT32_BOOT_NOP
;; NOP opcode (x86).
;;
FAT32_BOOT_NOP = $90
;;
;; ubyte: FAT32_MEDIA_TYPE
;;
FAT32_MEDIA_TYPE = $f8
;;
;; ubyte: FAT32_BYTES_PER_SECTOR
;; Number of bytes per sector.
;;
FAT32_BYTES_PER_SECTOR = $200
;;
;; ubyte: FAT32_FAT_COUNT
;; Maximum number of File Attribute Tables.
;;
FAT32_FAT_COUNT = $02

;;
;; Group: FAT32 directory entry attribute flag
;;

;;
;; ubyte: FAT32_READ_ONLY
;;
FAT32_READ_ONLY = %0000_0001
;;
;; ubyte: FAT32_HIDDEN
;;
FAT32_HIDDEN    = %0000_0010
;;
;; ubyte: FAT32_SYSTEM
;;
FAT32_SYSTEM    = %0000_0100
;;
;; ubyte: FAT32_VOLUME_ID
;;
FAT32_VOLUME_ID = %0000_1000
;;
;; ubyte: FAT32_DIRECTORY
;;
FAT32_DIRECTORY = %0001_0000
;;
;; ubyte: FAT32_ARCHIVE
;;
FAT32_ARCHIVE   = %0010_0000
;;
;; ubyte: FAT32_LONG_NAME
;;
FAT32_LONG_NAME = $0f

FAT32_LONG_NAME_MASK = (FAT32_ARCHIVE | FAT32_DIRECTORY | FAT32_VOLUME_ID | FAT32_SYSTEM | FAT32_HIDDEN | FAT32_READ_ONLY)

FAT32_LAST_LONG_ENTRY = $40

    .rsset $00
fat32_mbr.boot_code   .rs 446
fat32_mbr.partition_0 .rs 16
fat32_mbr.partition_1 .rs 16
fat32_mbr.partition_2 .rs 16
fat32_mbr.partition_3 .rs 16
fat32_mbr.signature   .rs 2

    .rsset $00
fat32_partition.boot         .rs 1
fat32_partition.head_begin   .rs 3
fat32_partition.type_code    .rs 1
fat32_partition.head_end     .rs 3
fat32_partition.lba_begin    .rs 4
fat32_partition.sector_count .rs 4

    .rsset $00
fat32_boot_sector.jump                 .rs 3
fat32_boot_sector.oem_id               .rs 8
fat32_boot_sector.bytes_per_sector     .rs 2
fat32_boot_sector.sectors_per_cluster  .rs 1
fat32_boot_sector.reserved_sectors     .rs 2
fat32_boot_sector.fat_count            .rs 1
fat32_boot_sector.root_dir_entry_count .rs 2
fat32_boot_sector.total_sectors16      .rs 2
fat32_boot_sector.media_type           .rs 1
fat32_boot_sector.sectors_per_fat16    .rs 2
fat32_boot_sector.sectors_per_tracks   .rs 2
fat32_boot_sector.head_count           .rs 2
fat32_boot_sector.hidden_sectors       .rs 4
fat32_boot_sector.total_sectors32      .rs 4
fat32_boot_sector.sectors_per_fat32    .rs 4
fat32_boot_sector.flags                .rs 2
fat32_boot_sector.version              .rs 2
fat32_boot_sector.root_dir_1st_cluster .rs 4
fat32_boot_sector.fs_info              .rs 2
fat32_boot_sector.back_boot_block      .rs 2
fat32_boot_sector.reserved             .rs 12
fat32_boot_sector.drive_number         .rs 1
fat32_boot_sector.reserved_nt          .rs 1
fat32_boot_sector.boot_signature       .rs 1
fat32_boot_sector.serial_number        .rs 4
fat32_boot_sector.label                .rs 11
fat32_boot_sector.file_system_type     .rs 8
fat32_boot_sector.boot_code            .rs 420
fat32_boot_sector.signature            .rs 2

    .rsset $00
fat32_dir_entry.name               .rs 11
fat32_dir_entry.attributes         .rs 1
fat32_dir_entry.reserved_nt        .rs 1
fat32_dir_entry.creation_time_10th .rs 1
fat32_dir_entry.creation_time      .rs 2
fat32_dir_entry.creation_date      .rs 2
fat32_dir_entry.last_access_date   .rs 2
fat32_dir_entry.first_cluster_hi   .rs 2
fat32_dir_entry.last_write_time    .rs 2
fat32_dir_entry.last_write_data    .rs 2
fat32_dir_entry.first_cluster_lo   .rs 2
fat32_dir_entry.file_size          .rs 4

fat32_long_dir_entry.name_1.len = 10
fat32_long_dir_entry.name_2.len = 12
fat32_long_dir_entry.name_3.len = 4

    .rsset $00
fat32_long_dir_entry.order      .rs 1
fat32_long_dir_entry.name_1     .rs fat32_long_dir_entry.name_1.len
fat32_long_dir_entry.attributes .rs 1
fat32_long_dir_entry.type       .rs 1
fat32_long_dir_entry.checksum   .rs 1
fat32_long_dir_entry.name_2     .rs fat32_long_dir_entry.name_2.len
fat32_long_dir_entry.zero       .rs 1
fat32_long_dir_entry.name_3     .rs fat32_long_dir_entry.name_3.len

    .rsset $00
FAT32_OK                   .rs 1
FAT32_READ_ERROR           .rs 1
FAT32_INVALID_MBR          .rs 1
FAT32_NO_PARTITIONS        .rs 1
FAT32_INVALID_VOLUME_ID    .rs 1
FAT32_INVALID_PARTITION_ID .rs 1
FAT32_NOT_FOUND            .rs 1

    .bss
fat32.partition.count   .ds 1
fat32.partition.sector  .ds 4*FAT32_MAX_PARTITION_COUNT
fat32.partition.current .ds 4

fat32.sectors_per_cluster .ds 1
fat32.sectors_per_fat     .ds 4
fat32.root_dir_cluster    .ds 4

fat32.fat_begin_lba .ds 4
fat32.cluster_begin_lba .ds 4

fat32.current_cluster .ds 4
fat32.current_sector  .ds 4
fat32.sector_offset   .ds 1
fat32.data_size       .ds 4
fat32.data_pointer    .ds 4
fat32.data_offset     .ds 2

fat32.fat_sector .ds 4
fat32.fat_entry  .ds 2

    .zp
fat32.fat_buffer  .ds 2
fat32.data_buffer .ds 2

fat32.src .ds 2
fat32.dst .ds 2
fat32.r0  .ds 2
fat32.r1  .ds 2
fat32.r2  .ds 2
fat32.r3  .ds 2

    .code

;;
;; Group: FAT32 routines
;;

;;
;; function: fat32_read_sector
;; Copies 512 bytes from the specified sector to the destination
;; buffer.
;;
;; Note:
;; This is a user-defined routine.
;;
;; Parameters:
;;   _ax : sector id bytes 0 and 1
;;   _bx : sector id bytes 2 and 3
;;   _di : output buffer
;;
;; Return:
;;   Carry flag - Set if the sector was successfully read.
;;

;;
;; function: fat32_read_mbr
;; Reads partition table from sector.
;;
;; Parameters:
;;   fat32.data_buffer - address of sector buffer.
;;
;; Return:
;;    fat32.partition.sector - Partitions sector address.
;;    fat32.partition.count  - Number of active partitions.
;;    X - FAT32_OK on success.
;;
fat32_read_mbr:
    ; read first sector
    stw    <fat32.data_buffer, <_di
    stwz   <_ax
    stwz   <_bx
    jsr    fat32_read_sector
    bcc    @read_error
    
    ; check mbr signature
    addw   <fat32.data_buffer, #fat32_mbr.signature, <fat32.src
    lda    [fat32.src]
    cmp    #low(FAT32_MBR_SIGNATURE)
    bne    @invalid_mbr
    
    ldy    #$01
    lda    [fat32.src], Y
    cmp    #high(FAT32_MBR_SIGNATURE)
    beq    @find_partitions

@invalid_mbr:
    ldx    #FAT32_INVALID_MBR
    rts
    
@find_partitions:
    addw   <fat32.data_buffer, #fat32_mbr.partition_0, <fat32.src
    stz    fat32.partition.count
    
    clx
@get_partition:
    ldy    #fat32_partition.type_code
    lda    [fat32.src], Y
    cmp    #FAT32_PARTITION
    beq    @add_partition
    cmp    #FAT32_INT13_PARTITION
    bne    @next_partition
@add_partition:
        phx
        
        lda    fat32.partition.count
        asl    A
        asl    A
        tax
        
        ldy    #fat32_partition.lba_begin
        lda    [fat32.src], Y
        sta    fat32.partition.sector, X
        
        iny
        lda    [fat32.src], Y
        sta    fat32.partition.sector+1, X
        
        iny
        lda    [fat32.src], Y
        sta    fat32.partition.sector+2, X
        
        iny
        lda    [fat32.src], Y
        sta    fat32.partition.sector+3, X
        
        plx
        
        inc    fat32.partition.count

@next_partition:
    addw   #16, <fat32.src
    inx
    cpx    #FAT32_MAX_PARTITION_COUNT
    bne    @get_partition
    
    lda    fat32.partition.count
    bne    @ok
@no_fat32_partition:
    ldx    #FAT32_NO_PARTITIONS
    rts
@read_error
    ldx    #FAT32_READ_ERROR
    rts
@ok:
    ldx    #FAT32_OK
    rts

;;
;; function: fat32_mount
;; Mount a FAT32 partition and opens its root directory.
;;
;; Parameters:
;;   A - Id of the partition to mount.
;;
;; Return:
;;   fat32.partition.current - Partition id.
;;   fat32.sectors_per_cluster - Number of sectors per cluster.
;;   fat32.sectors_per_fat - Number of sectors stored in FAT.
;;   fat32.root_dir_cluster - 1st cluster of the root directory.
;;   fat32.fat_begin_lba - 1st FAT sector.
;;   fat32.cluster_begin_lba - 1st data cluster.
;;   fat32.current_cluster - 1st cluster of the root directory.
;;   fat32.current_sector - 1st sector of the root directory.
;;   fat32.fat_sector - Current FAT sector.
;;   fat32.fat_entry - Current FAT entry.
;;   X - FAT32_OK if the partition was successfully mounted.
;;
fat32_mount:
    cmp    fat32.partition.count
    bcc    @mount
        ldx    #FAT32_INVALID_PARTITION_ID
        rts
@mount:
    sta    fat32.partition.current
    asl    A
    asl    A
    tay
    
    lda    fat32.partition.sector, Y 
    sta    <_ax
    
    lda    fat32.partition.sector+1, Y 
    sta    <_ax+1
    
    lda    fat32.partition.sector+2, Y 
    sta    <_bx
    
    lda    fat32.partition.sector+3, Y 
    sta    <_bx+1
    
    jsr    _fat32_read_boot_sector
    beq    _fat32_open_root_dir
        rts
;;
;; function: _fat32_open_root_dir
;; Opens root directory of current partition.
;;
;; Parameters:
;;    fat32.root_dir_cluster - 1st cluster of the root directory.
;;    fat32.fat_buffer - Address of the FAT RAM buffer.
;;    fat32.data_buffer - Address of the data RAM buffer.
;;
;; Return:
;;    fat32.current_cluster - 1st cluster of the root directory.
;;    fat32.current_sector - 1st sector of the root directory.
;;    fat32.fat_sector - Current FAT sector.
;;    fat32.fat_entry - Current FAT entry.
;;    X - FAT32_OK on success.
;;
_fat32_open_root_dir:
    ; Read first root directory sector
    stw    fat32.root_dir_cluster, fat32.current_cluster
    stw    fat32.root_dir_cluster+2, fat32.current_cluster+2
    jsr    _fat32_sector_address
 
    stw    <fat32.data_buffer, <_di
    stw    fat32.current_sector, <_ax
    stw    fat32.current_sector+2, <_bx
    jsr    fat32_read_sector
    bcc    @read_error.0
    
    stz    fat32.sector_offset
    stwz   fat32.data_size
    stwz   fat32.data_size+2
    stwz   fat32.data_pointer
    stwz   fat32.data_pointer+2
    stwz   fat32.data_offset

    ; Read first FAT sector
    lda    fat32.fat_begin_lba
    sta    fat32.fat_sector
    sta    <_ax

    lda    fat32.fat_begin_lba+1
    sta    fat32.fat_sector+1
    sta    <_ax+1

    lda    fat32.fat_begin_lba+2
    sta    fat32.fat_sector+2
    sta    <_bx
    
    lda    fat32.fat_begin_lba+3
    sta    fat32.fat_sector+3
    sta    <_bx+1

    stw    <fat32.fat_buffer, <_di
    jsr    fat32_read_sector
    bcc    @read_error.0
    
    stw    #(2*4), fat32.fat_entry

    ldx    #FAT32_OK
    rts
@read_error.0:
    ldx    #FAT32_READ_ERROR
    rts
;;
;; function: _fat32_read_boot_sector
;; Reads FAT32 boot sector.
;;
;; Parameters:
;;   fat32.data_buffer - address of sector buffer.
;;
;; Return:
;;   fat32.sectors_per_cluster - Number of sectors per cluster.
;;   fat32.sectors_per_fat - Number of sectors stored in FAT.
;;   fat32.root_dir_cluster - 1st cluster of the root directory.
;;   fat32.fat_begin_lba - 1st FAT sector.
;;   fat32.cluster_begin_lba - 1st data cluster.
;;   X - FAT32_OK if a valid FAT32 boot sector was read.
;;
_fat32_read_boot_sector:
    stw    <fat32.data_buffer, <_di
    jsr    fat32_read_sector
    bcc    @read_error.1
    
    ; check if we have a valid fat32 volume
    ; 1. jump instruction (JMP XX NOP (x86))
    ldy    #fat32_boot_sector.jump
    lda    [fat32.data_buffer], Y
    cmp    #FAT32_BOOT_JMP
    bne    @invalid_boot_sector
    ldy    #fat32_boot_sector.jump+2
    lda    [fat32.data_buffer], Y
    cmp    #FAT32_BOOT_NOP
    bne    @invalid_boot_sector
    
    ; 2. media type
    ldy    #fat32_boot_sector.media_type
    lda    [fat32.data_buffer], Y
    cmp    #FAT32_MEDIA_TYPE
    bne    @invalid_boot_sector
    
    ; 3. bytes per sector (512)
    ldy    #fat32_boot_sector.bytes_per_sector
    lda    [fat32.data_buffer], Y
    cmp    #low(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_boot_sector
    
    iny
    lda    [fat32.data_buffer], Y
    cmp    #high(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_boot_sector

    ; 4. number of fats (2)
    ldy    #fat32_boot_sector.fat_count
    lda    [fat32.data_buffer], Y
    cmp    #FAT32_FAT_COUNT
    bne    @invalid_boot_sector
    
    ; 5. check signature
    addw   <fat32.data_buffer, #fat32_boot_sector.signature, <fat32.src
    lda    [fat32.src]
    cmp    #low(FAT32_MBR_SIGNATURE)
    bne    @invalid_boot_sector
    
    ldy    #$01
    lda    [fat32.src], Y
    cmp    #high(FAT32_MBR_SIGNATURE)
    beq    @get_root_directory

@invalid_boot_sector:
    ldx    #FAT32_INVALID_VOLUME_ID
    rts
@read_error.1:
    ldx    #FAT32_READ_ERROR
    rts
    
@get_root_directory:
    ldy    #fat32_boot_sector.sectors_per_cluster
    lda    [fat32.data_buffer], Y
    sta    fat32.sectors_per_cluster

    ldy    #fat32_boot_sector.sectors_per_fat32
    lda    [fat32.data_buffer], Y
    sta    fat32.sectors_per_fat
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.sectors_per_fat+1
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.sectors_per_fat+2
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.sectors_per_fat+3
    
    ldy    #fat32_boot_sector.reserved_sectors
    lda    [fat32.data_buffer], Y
    sta    <fat32.src
    iny
    lda    [fat32.data_buffer], Y
    sta    <fat32.src+1

    ldy    #fat32_boot_sector.root_dir_1st_cluster
    lda    [fat32.data_buffer], Y
    sta    fat32.root_dir_cluster
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.root_dir_cluster+1
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.root_dir_cluster+2
    iny
    lda    [fat32.data_buffer], Y
    sta    fat32.root_dir_cluster+3

    ; fat32.fat_begin_lba = fat32.current_partition + fat32.reserved_sectors
    lda    fat32.partition.current
    asl    A
    asl    A
    tay
    clc
    lda    fat32.partition.sector,Y
    adc    <fat32.src
    sta    fat32.fat_begin_lba
    lda    fat32.partition.sector+1,Y
    adc    <fat32.src+1
    sta    fat32.fat_begin_lba+1
    lda    fat32.partition.sector+2,Y
    adc    #$00
    sta    fat32.fat_begin_lba+2
    lda    fat32.partition.sector+3,Y
    adc    #$00
    sta    fat32.fat_begin_lba+3

    ; fat32.cluster_begin_lba = fat32.fat_begin_lba + (number_of_fats * fat32.sectors_per_fat)
    ; number_of_fats = 2
    lda    fat32.sectors_per_fat
    asl    A
    sta    fat32.cluster_begin_lba
    lda    fat32.sectors_per_fat+1
    rol    A
    sta    fat32.cluster_begin_lba+1
    lda    fat32.sectors_per_fat+2
    rol    A
    sta    fat32.cluster_begin_lba+2
    lda    fat32.sectors_per_fat+3
    rol    A
    sta    fat32.cluster_begin_lba+3
 
    addw   fat32.fat_begin_lba, fat32.cluster_begin_lba
    adcw   fat32.fat_begin_lba+2, fat32.cluster_begin_lba+2

    ldx    #FAT32_OK
    rts

;;
;; function: _fat32_sector_address
;; Computes the sector id of a cluster.
;;
;; Parameters:
;;    fat32.current_cluster - cluster number.
;;
;; Return:
;;    fat32.current_sector - sector number.
;;
_fat32_sector_address:
    ; sector = fat32.cluster_begin_lba + (cluster_number - 2) * fat32.sectors_per_cluster

    ; fat32.r2 = cluster_number - 2
    subw   #$0002, fat32.current_cluster, <fat32.r2
    sbcw   #$0000, fat32.current_cluster+2, <fat32.r3

    ; fat32.current_sector = _r2 * fat32.sectors_per_cluster
    lda    fat32.sectors_per_cluster
    sta    fat32.current_sector+3
    stz    fat32.current_sector+2
    stz    fat32.current_sector+1
    
    cla
    ldy    #$08
@loop:
    asl    A
    rol    fat32.current_sector+1
    rol    fat32.current_sector+2
    rol    fat32.current_sector+3
    bcc    @next
        clc
        adc    <fat32.r2
        pha

        lda    fat32.current_sector+1
        adc    <fat32.r2+1
        sta    fat32.current_sector+1
        lda    fat32.current_sector+2
        adc    <fat32.r3
        sta    fat32.current_sector+2
        lda    fat32.current_sector+3
        adc    <fat32.r3+1
        sta    fat32.current_sector+3
        
        pla
@next:
    dey
    bne    @loop
    sta    fat32.current_sector
    
    ; _ax += fat32.cluster_begin_lba
    addw   fat32.cluster_begin_lba, fat32.current_sector
    adcw   fat32.cluster_begin_lba+2, fat32.current_sector+2
    
    rts

;;
;; function: _fat32_end_of_fat
;; Checks if the last fat sector was reached.
;;
;; Parameters:
;;   _ax : sector id bytes 0 and 1
;;   _bx : sector id bytes 2 and 3
;;
;; Return:
;;    Carry flag - Set if the last fat sector was reached. 
;;
_fat32_end_of_fat:
    clc
    lda    fat32.sectors_per_fat
    adc    fat32.fat_begin_lba
    cmp    <_ax
    bne    @l0
    lda    fat32.sectors_per_fat+1
    adc    fat32.fat_begin_lba+1
    cmp    <_ax+1
    bne    @l0
    lda    fat32.sectors_per_fat+2
    adc    fat32.fat_begin_lba+2
    cmp    <_bx
    bne    @l0
    lda    fat32.sectors_per_fat+3
    adc    fat32.fat_begin_lba+3
    cmp    <_bx+1
    bne    @l0
        sec
        rts
@l0:
    clc
    rts
  
;;
;; function: _fat32_next_cluster
;; Retrieves the next data cluster from the File Allocation Table.
;;
;; Parameters:
;;    fat32.current_cluster - Current data cluster.
;;
;; Return:
;;    fat32.current_cluster - Next data cluster upon success. It's left unchanged if
;;                            the current cluster is the last one. 
;;    Carry flag - Set if the current cluster is the last cluster, cleared otherwise. 
;;
_fat32_next_cluster:
    ; Compute FAT sector to load.
    lda    fat32.current_cluster
    cmp    #$80
    lda    fat32.current_cluster+1
    rol    A
    sta    <fat32.r2
    lda    fat32.current_cluster+2
    rol    A
    sta    <fat32.r2+1
    lda    fat32.current_cluster+3
    rol    A
    sta    <fat32.r3
    cla
    rol    A
    sta    <fat32.r3+1

    addw   fat32.fat_begin_lba, <fat32.r2
    adcw   fat32.fat_begin_lba+2, <fat32.r3
    
    ; Get FAT entry.
    lda    fat32.current_cluster
    asl    A
    asl    A
    sta    fat32.fat_entry
    stz    fat32.fat_entry+1
    rol    fat32.fat_entry+1

    ; Check if we need to load a new FAT sector
    lda    <fat32.r3+1
    cmp    fat32.fat_sector+3
    bne    @load_needed

    lda    <fat32.r3
    cmp    fat32.fat_sector+2
    bne    @load_needed

    lda    <fat32.r2+1
    cmp    fat32.fat_sector+1
    beq    @get_sector
  
    lda    <fat32.r2
    cmp    fat32.fat_sector
    beq    @get_sector
       
@load_needed:
    stw    <fat32.r2, fat32.fat_sector
    stw    <fat32.r3, fat32.fat_sector+2
    jsr    _fat32_end_of_fat
    bcs    @err
    stw    <fat32.fat_buffer, <_di
    jsr    fat32_read_sector
    bcc    @err
@get_sector:
    lda    fat32.fat_entry
    clc
    adc    <fat32.fat_buffer
    sta    <fat32.src
    lda    fat32.fat_entry+1
    and    #$01                     ; high(0x1ff)
    adc    <fat32.fat_buffer+1
    sta    <fat32.src+1
   
    ; Check if the next cluster is == $xfffffff
    ; We try to be smart.
    ldy    #$01
    lda    [fat32.src], Y
    sta    fat32.r2
    cmp    #$ff             ; carry will be set if A >= #$ff
    iny
    lda    [fat32.src], Y
    tax
    iny
    lda    [fat32.src], Y
    and    #$0f
    tay
    lda    [fat32.src]
                            ; check if byte 1 >= #$ff
    bcc    @l0              ; the carry flag was preserved
    cmp    #$ff             ; byte 0
    bne    @l0
    cpx    #$ff             ; byte 2
    bne    @l0
    cpy    #$0f             ; byte 3
    bne    @l0
        ; We are already at the end of the cluster chain
        sec
        rts    
@l0:
    sta    fat32.current_cluster
    lda    <fat32.r2
    sta    fat32.current_cluster+1
    stx    fat32.current_cluster+2
    sty    fat32.current_cluster+3
    clc
@err:
    rts
    
;;
;; function: _fat32_next_sector
;; Reads next data sector and stores the data at the memory location
;; pointed by *fat32.data_buffer*.
;;
;; Parameters:
;;    fat32.sector_offset - Current cluster sector.
;;
;; Return:
;;    X - FAT32_OK on success.
;;
_fat32_next_sector:
    inc    fat32.sector_offset  
    lda    fat32.sector_offset
    cmp    fat32.sectors_per_cluster
    bne    @l3.1
        stz    fat32.sector_offset

        jsr    _fat32_next_cluster
        cpx    #FAT32_OK
        bne    @err
        
        jsr    _fat32_sector_address
        stw    fat32.current_sector, <_ax
        stw    fat32.current_sector+2, <_bx
        
@l3.1:
    stw    <fat32.data_buffer, <_di
    jsr    fat32_read_sector
    bcc    @read_error
    
    stwz   fat32.data_offset
    ldx    #FAT32_OK
    rts
@read_error:
    ldx    #FAT32_READ_ERROR
@err:
    rts

;;
;; function: fat32_read_entry
;; Retrieves the next valid directory entry and moves *fat32.data_offset* past it.
;;
;; Parameters:
;;    fat32.data_offset - Offset of the current directory entry.
;;
;; Return:
;;    _si - Address of the valid directory entry (file or directory).
;;    fat32.data_offset - Offset of the next directory entry.
;;    Carry flag - Set if a valid entry was found.
;; 
fat32_read_entry:
@l0:
    lda    fat32.data_offset+1
    cmp    #$02
    bne    @l1
        jsr    _fat32_next_sector
        bcc    @end
@l1:
    addw   fat32.data_offset, fat32.data_buffer, <_si
    
    lda    [_si]
    beq    @end
    
    ldy    #fat32_dir_entry.attributes
    lda    [_si], Y
    cmp    #FAT32_LONG_NAME
    bne    @l2
    jmp    @next
@l2:
    bit    #(FAT32_READ_ONLY | FAT32_DIRECTORY | FAT32_ARCHIVE)
    bne    @l3
    jmp    @next
@l3:
        addw   #$20, fat32.data_offset 
        sec
        rts
@next:    
    addw    #$20, fat32.data_offset
    bra     @l0
    
@end:
    clc
    rts
    
;;
;; function: _fat32_is_lfn
;; Checks if the current directory entry is a long filename (LFN) entry.
;;
;; Parameters:
;;    _si - directory entry address.
;;
;; Return:
;;    carry flag - 1 if the current directory entry is a LFN entry, 0 otherwise.
;;
_fat32_is_lfn:
    ldy    #fat32_long_dir_entry.attributes
    lda    [_si], Y
    and    #FAT32_LONG_NAME_MASK
    cmp    #FAT32_LONG_NAME
    bne    @nok
        sec
        rts
@nok:
    clc
    rts

;;
;; function: _fat32_checksum
;; Computes the directory entry checksum.
;;
;; Parameters:
;;
;; Return:
;;    A - checksum.
;;
_fat32_checksum:    
    cla
    cly
@l0:
    lsr    A
    bcc    @l1
        adc    #$7f
@l1:
    adc    [_si], Y
    iny
    cpy    #11
    bne    @l0
    rts
    
;;
;; function: fat32_lfn_get
;; Retrieves the directory entry long file name (if any).
;;
;; Parameters:
;;    _si - Address of the current short file name (SFN) directory entry.
;;    _di - string buffer address.
;;
;; Return:
;;   _r0 - directory entry checksum.
;;   Carry flag - Set if there is a LFN associated with the directory entry.
;;
fat32_lfn_get:
    jsr    _fat32_checksum
    sta    <_r0
@l0:
    subw   #$20, <_si

    jsr    _fat32_is_lfn
    bcc    @err

    ldy    #fat32_long_dir_entry.checksum
    lda    [_si], Y
    cmp    <_r0
    bne    @err

    ldy    #fat32_long_dir_entry.name_1
    ldx    #(fat32_long_dir_entry.name_1.len/2)
    bsr    @fat32_lfn_getch
        
    ldy    #fat32_long_dir_entry.name_2
    ldx    #(fat32_long_dir_entry.name_2.len/2)
    bsr    @fat32_lfn_getch
    
    ldy    #fat32_long_dir_entry.name_3
    ldx    #(fat32_long_dir_entry.name_3.len/2)
    bsr    @fat32_lfn_getch
    
    ldy    #fat32_long_dir_entry.order
    lda    [_si], Y
    bit    #FAT32_LAST_LONG_ENTRY
    beq    @l0
      
    sec
    rts
    
@err:
    clc
    rts
@fat32_lfn_getch:
    lda    [_si], Y
    bmi    @skip
        sta    [_di]
        incw   <_di
@skip:
    iny
    iny

    dex
    bne    @fat32_lfn_getch
    rts

;;
;; function: fat32_get_filename
;; Retrieves the directory entry file name.
;;
;; Parameters:
;;    _si - Address of the directory entry.
;;    _di - string buffer address.
;;
;; Return:
;;
fat32_get_filename:
    jsr    fat32_lfn_get
    bcs    @end
    
    addw   #$20, <_si
    
    cly
@name:
    lda    [_si], Y
    cmp    #' '
    beq    @ext

    sta    [_di], Y
    iny
    cpy    #8
    bne    @name
@ext:

    ldx    #8
@l0:
    sxy
    lda    [_si], Y    
    cmp    #' '
    beq    @end

    sxy
    sta    [_di], Y
    
    inx
    iny
    cpx    #11
    bne    @l0

@end:
    sxy
    cla
    sta    [_di], Y

    rts

;;
;; function: fat32_open
;; Opens the file whose directory entry is pointed by *_si* for reading.
;;
;; Parameters:
;;    _si - Memory location of the file entry.
;;
;; Return:
;;    X - FAT32_OK on success.
;;
fat32_open:
    ldy    #fat32_dir_entry.file_size+3
    lda    [_si], Y
    sta    fat32.data_size+3
    ldy    #fat32_dir_entry.file_size+2
    lda    [_si], Y
    sta    fat32.data_size+2
    ldy    #fat32_dir_entry.file_size+1
    lda    [_si], Y
    sta    fat32.data_size+1
    ldy    #fat32_dir_entry.file_size
    lda    [_si], Y
    sta    fat32.data_size
        
    ldy    #fat32_dir_entry.first_cluster_hi+1
    lda    [_si], Y
    sta    fat32.current_cluster+3
    ldy    #fat32_dir_entry.first_cluster_hi
    lda    [_si], Y
    sta    fat32.current_cluster+2
    
    ldy    #fat32_dir_entry.first_cluster_lo+1
    lda    [_si], Y
    sta    fat32.current_cluster+1
    ldy    #fat32_dir_entry.first_cluster_lo
    lda    [_si], Y
    sta    fat32.current_cluster
    
    jsr    _fat32_sector_address

    stz    fat32.sector_offset
    stwz   fat32.data_offset
    stwz   fat32.data_pointer
    stwz   fat32.data_pointer+2
    
    stw    <fat32.data_buffer, <_di
    stw    fat32.current_sector, <_ax
    stw    fat32.current_sector+2, <_bx
    jsr    fat32_read_sector
    bcc    @read_error
    ldx    #FAT32_OK
    rts
@read_error:
    ldx    #FAT32_READ_ERROR
    rts
    
;;
;; function: fat32_read
;; Reads *_cx* bytes from the currently opened file and stores them at the memory 
;; location given by *fat32.dst*.
;; 
;; Parameters:
;;    _cx - number of bytes to read from the currently opened file.
;;    fat32.dst - memory location where the read bytes will be stored.
;;
;; Return:
;;    _cx - number of bytes read.
;;
fat32_read:
    lda    <_cx+1
    pha
    lda    <_cx
    pha
@l0:
        lda    fat32.data_size+3
        cmp    fat32.data_pointer+3
        bne    @l1
        lda    fat32.data_size+2
        cmp    fat32.data_pointer+2
        bne    @l1
        lda    fat32.data_size+1
        cmp    fat32.data_pointer+1
        bne    @l1
        lda    fat32.data_size
        cmp    fat32.data_pointer
        bne    @l1
            jmp    @nread
@l1:
        lda    <_cx
        ora    <_cx+1
        bne    @l2
            jmp    @nread
@l2:
        lda    fat32.data_offset+1
        cmp    #$02
        bne    @l3

        jsr    _fat32_next_sector
        beq    @l3
            jmp    @nread
@l3:
        stwz   <fat32.r1
        lda    <_cx+1
        cmp    #$02
        bcc    @l4
            stw    #$200, <fat32.r1
            bra    @l5
@l4:
            stw    <_cx, <fat32.r1
@l5:
        lda    <fat32.r1
        clc
        adc    fat32.data_offset
        lda    <fat32.r1+1
        adc    fat32.data_offset+1
        cmp    #$02
        bcc    @l6
            subw   fat32.data_offset, #$200, <fat32.r1
@l6:
        subw   fat32.data_pointer, fat32.data_size, <fat32.r2
        subw   fat32.data_pointer+2, fat32.data_size+2, <fat32.r3
        lda    <fat32.r3
        ora    <fat32.r3+1
        bne    @l7
            lda    <fat32.r1+1
            cmp    <fat32.r2+1
            bcc    @l7
            bne    @l8
            lda    <fat32.r1
            cmp    <fat32.r2
            bcc    @l7
@l8:
                stw    <fat32.r2, <fat32.r1
@l7:
        memcpy_mode #SOURCE_INC_DEST_INC
        addw   fat32.data_buffer, fat32.data_offset, <fat32.src
        memcpy_args <fat32.src, <fat32.dst, <fat32.r1
        jsr    memcpy

        addw   <fat32.r1, <fat32.dst
        addw   <fat32.r1, fat32.data_offset
        addw   <fat32.r1, fat32.data_pointer
        subw   <fat32.r1, <_cx
    jmp    @l0
@nread:
    pla
    sec
    sbc    <_cx
    sta    <_cx
    pla
    sbc    <_cx+1
    sta    <_cx+1
    rts

; [todo] move to string utility functions
to_upper:
    cmp    #'a'
    bcc    @end
 
    cmp    #'z'
    beq    @l0
    bcs    @end
@l0:
    sec
    sbc    #$20             ; 'A' - 'a'
@end:
    rts

;;
;; function: _fat32_8.3_cmp
;; Checks it the 8.3 filename stored in a directory entry matches current string.
;;
;; Parameters:
;;    <_si - Directory entry filename.
;;    <_r1 - Input string.
;;
;; Return:
;;    Carry flag - Set if the entry filename matches.
;;
_fat32_8.3_cmp:
    cly
@name:
    lda    [_si], Y
    cmp    #' '
    beq    @l0

    lda    [_r1], Y
    bsr    to_upper
        
    cmp    [_si], Y
    bne    @neq
    
    iny
    cpy    #8
    bne    @name

@l0:
    lda    [_r1], Y
    beq    @check_end.0

    cmp    #'/'
    beq    @check_end.0
    
    iny
    cmp    #'.'
    bne    @neq
    
@extension:
    tya
    tax
@l1:
    cpy    #8
    beq    @l2

    lda    [_si], Y
    iny
    cmp    #' '
    beq    @l1
    bra    @neq
@l2:
    sxy
    lda    [_r1], Y
    beq    @check_end.1
    
    bsr    to_upper
    
    sxy
    cmp    [_si], Y
    bne    @neq
    
    inx
    iny
    cpy    #11
    bne    @l2
    
    bra    @eq
    
@check_end.0:
    tya
    tax
@check_end.1:
    sxy
@check_end:
    lda    [_si], Y
    cmp    #' '
    bne    @neq
    iny
    cpy   #11
    bne   @check_end
    
@eq:
    sec
    rts
@neq:
    clc
    rts
    
;;
;; function: fat32_find_file
;; Opens the file whose name is the string pointed to by *_r1*.
;;
;; Parameters:
;;    _r1 - File path address.
;;    _dx - Temporary buffer address.
;;
;; Return:
;;    X - FAT32_OK if the file was succesfully opened.
;; 
fat32_find_file:
    stw    <_dx, <fat32.r0
    lda    [_r1]
    cmp    #'/'
    bne    @relative
        jsr    _fat32_open_root_dir
        cpx    #FAT32_OK
        beq    @next
            rts
@next:
        incw   <_r1
@relative:
    ; [todo]
@loop:
    jsr    fat32_read_entry
    bcc    @not_found
    
    stw    <fat32.r0, <_di
    phw    <_si
    jsr    fat32_lfn_get
    plw    <_si
    
    cly
    bcs    @lfn
@sfn:
    jsr    _fat32_8.3_cmp
    bcc    @loop
    
    sxy
    bra    @found
    
@lfn:    
    stwz   <_r0
@cmp:
    lda    [_r1], Y
    beq    @l0
    cmp    #'/'
    beq    @l0
        cmp    [fat32.r0], Y
        bne    @loop
         
        iny
        cpy    <_r0
        bne    @cmp
        bra    @loop            
@l0:
    lda    [fat32.r0], Y
    cmp    <_r0+1
    beq    @found
    
    bra    @loop
@not_found:
    ldx    #FAT32_NOT_FOUND
    rts

@found:
    tya
    clc
    adc    <_r1
    sta    <_r1
    cla
    adc    <_r1+1
    sta    <_r1+1

    lda    [_r1]
    beq    @end
    
    cmp    #'/'
    bne    @open
    
    incw   <_r1
    lda    [_r1]
    bne    @open
@end:
    ldx    #FAT32_OK  
    rts
@open:
    jsr    fat32_open
    jmp    @loop

;;
;; function: fat32_free_cluster
;; Inspects the FAT in order to find the id of the first free cluster.
;;
;; Parameters:
;;
;; Return:
;;  _cx - Id of the first free cluster.
;;    X - FAT32_OK on success.
;;
fat32_free_cluster:
    stz    <_r0
    
    ; Search from start
    lda    fat32.fat_begin_lba+3
    cmp    fat32.fat_sector+3
    bne    @load
    lda    fat32.fat_begin_lba+2
    cmp    fat32.fat_sector+2
    bne    @load
    lda    fat32.fat_begin_lba+1
    cmp    fat32.fat_sector+1
    bne    @load
    lda    fat32.fat_begin_lba
    cmp    fat32.fat_sector
    beq    @l0
@load:
        smb0   <_r0
        stw    fat32.fat_begin_lba, <_ax
        stw    fat32.fat_begin_lba+2, <_bx
        stw    fat32.fat_buffer, <_di
        jsr    fat32_read_sector
        bcs    @l0
            ldx    #FAT32_READ_ERROR
            rts
@l0:
    stw    #4, <_cx
    stwz   <_dx
@loop:
    stz    <_ax
    lda    <_cx
    and    #$7f
    asl    A
    rol    <_ax
    asl    A
    rol    <_ax
    
    clc
    adc    fat32.fat_buffer
    sta    <_si
    lda    <_ax
    and    #$01             ; high(0x1ff)
    adc    fat32.fat_buffer+1
    sta    <_si+1
    
    cly
    lda    [_si]
    iny
    ora    [_si], Y
    iny
    ora    [_si], Y
    iny
    ora    [_si], Y
    bne    @l1
        ; empty fat entry found
        ldx    #FAT32_OK
        jmp    @end
@l1:

    incw   <_cx
    bne    @l2
        incw   <_dx
@l2:
    lda    <_cx
    and    #$7f
    bne    @loop
@load_needed:
        incw   <_ax
        bne    @l3
            incw   <_bx        
@l3:
        ; Did we reached the last fat sector?
        jsr    _fat32_end_of_fat
        bcc    @l4
            ; end of FAT reached
            ldx    #FAT32_NOT_FOUND
            bra    @end
@l4:
        smb0   <_r0
        stw    fat32.fat_buffer, <_di
        jsr    fat32_read_sector
        bcc    @read_error
    jmp    @loop
    
@end:
    bbr0   <_r0, @exit
@restore: 
        stw    fat32.fat_sector, <_ax
        stw    fat32.fat_sector+2, <_bx 
        stw    fat32.fat_buffer, <_di
        jsr    fat32_read_sector
        bcc    @read_error
@exit:
    rts
@read_error
    ldx    #FAT32_READ_ERROR
    rts
  
; [todo] fat32_find_file, fat32_lfn_get use fat32 zp vars
; [todo] fat32_write_sfn
; [todo] fat32_write_lfn
; [todo] fat32_alloc_cluster
; [todo] write file data

