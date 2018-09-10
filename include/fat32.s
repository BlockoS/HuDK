FAT32_MBR_SIGNATURE = $AA55
FAT32_PARTITION = $0b
FAT32_INT13_PARTITION = $0c
FAT32_BOOT_JMP = $EB
FAT32_BOOT_NOP = $90
FAT32_MEDIA_TYPE = $f8
FAT32_BYTES_PER_SECTOR = $200
FAT32_FAT_COUNT = $02

; FAT32 directory entry attribute flag
FAT32_READ_ONLY = %0000_0001
FAT32_HIDDEN    = %0000_0010
FAT32_SYSTEM    = %0000_0100
FAT32_VOLUME_ID = %0000_1000
FAT32_DIRECTORY = %0001_0000
FAT32_ARCHIVE   = %0010_0000
FAT32_LONG_NAME = $0f

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

    .rsset $00
fat32_long_dir_entry.order      .rs 1
fat32_long_dir_entry.name_1     .rs 10
fat32_long_dir_entry.attributes .rs 1
fat32_long_dir_entry.type       .rs 1
fat32_long_dir_entry.checksum   .rs 1
fat32_long_dir_entry.name_2     .rs 12
fat32_long_dir_entry.zero       .rs 1
fat32_long_dir_entry.name_3     .rs 4

    .rsset $00
FAT32_OK                .rs 1
FAT32_INVALID_MBR       .rs 1
FAT32_NO_PARTITIONS     .rs 1
FAT32_INVALID_VOLUME_ID .rs 1

    .bss
fat32.partition_count .ds 1
fat32.partition_lba_0 .ds 4
fat32.partition_lba_1 .ds 4
fat32.partition_lba_2 .ds 4
fat32.partition_lba_3 .ds 4

fat32.current_partition    .ds 4
fat32.sectors_per_cluster  .ds 1
fat32.sectors_per_fat      .ds 4
fat32.reserved_sectors     .ds 2
fat32.root_dir_1st_cluster .ds 4

fat32.fat_begin_lba .ds 4
fat32.cluster_begin_lba .ds 4

    .code

;;
;; function: fat32_read_partitions
;; [todo]
;;
;; Parameters:
;,   _si : address of sector buffer
;;
;; Return:
;;
fat32_read_partitions:
    addw   <_si, #fat32_mbr.signature, <_ax
    lda    [_ax]
    cmp    #low(FAT32_MBR_SIGNATURE)
    bne    @invalid_mbr
    
    ldy    #$01
    lda    [_ax], Y
    cmp    #high(FAT32_MBR_SIGNATURE)
    beq    @find_partitions

@invalid_mbr:
    ldx    #FAT32_INVALID_MBR
    rts
    
@find_partitions:
    addw   <_si, #fat32_mbr.partition_0, <_ax
    stz    fat32.partition_count
    
    clx
@get_partition:
    ldy    #fat32_partition.type_code
    lda    [_ax], Y
    cmp    #FAT32_PARTITION
    beq    @add_partition
    cmp    #FAT32_INT13_PARTITION
    bne    @next_partition
@add_partition:
        phx
        
        lda    fat32.partition_count
        asl    A
        asl    A
        tax
        
        ldy    #fat32_partition.lba_begin
        lda    [_ax], Y
        sta    fat32.partition_lba_0, X
        
        iny
        inx
        lda    [_ax], Y
        sta    fat32.partition_lba_0, X
        
        iny
        inx
        lda    [_ax], Y
        sta    fat32.partition_lba_0, X
        
        iny
        inx
        lda    [_ax], Y
        sta    fat32.partition_lba_0, X
        
        plx
        
        inc    fat32.partition_count

@next_partition:
    addw   #16, <_ax
    inx
    cpx    #$04
    bne    @get_partition
    
    lda    fat32.partition_count
    bne    @ok
@no_fat32_partition:
    ldx    #FAT32_NO_PARTITIONS
    rts
@ok:
    ldx    #FAT32_OK
    rts

;;
;; function: fat32_read_boot_sector
;; [todo]
;;
;; Parameters:
;;   _si : address of sector buffer
;;
;; Return:
;;
fat32_read_boot_sector:
    ; check if we have a valid fat32 volume
    ; 1. jump instruction (JMP XX NOP (x86))
    ldy    #fat32_boot_sector.jump
    lda    [_si], Y
    cmp    #FAT32_BOOT_JMP
    bne    @invalid_boot_sector
    ldy    #fat32_boot_sector.jump+2
    lda    [_si], Y
    cmp    #FAT32_BOOT_NOP
    bne    @invalid_boot_sector
    
    ; 2. media type
    ldy    #fat32_boot_sector.media_type
    lda    [_si], Y
    cmp    #FAT32_MEDIA_TYPE
    bne    @invalid_boot_sector
    
    ; 3. bytes per sector (512)
    ldy    #fat32_boot_sector.bytes_per_sector
    lda    [_si], Y
    cmp    #low(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_boot_sector
    
    iny
    lda    [_si], Y
    cmp    #high(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_boot_sector

    ; 4. number of fats (2)
    ldy    #fat32_boot_sector.fat_count
    lda    [_si], Y
    cmp    #FAT32_FAT_COUNT
    bne    @invalid_boot_sector
    
    ; 5. check signature
    addw   <_si, #fat32_boot_sector.signature, <_ax
    lda    [_ax]
    cmp    #low(FAT32_MBR_SIGNATURE)
    bne    @invalid_boot_sector
    
    ldy    #$01
    lda    [_ax], Y
    cmp    #high(FAT32_MBR_SIGNATURE)
    beq    @get_root_directory

@invalid_boot_sector:
    ldx    #FAT32_INVALID_VOLUME_ID
    rts
       
@get_root_directory:
    ldy    #fat32_boot_sector.sectors_per_cluster
    lda    [_si], Y
    sta    fat32.sectors_per_cluster

    ldy    #fat32_boot_sector.sectors_per_fat32
    lda    [_si], Y
    sta    fat32.sectors_per_fat
    iny
    lda    [_si], Y
    sta    fat32.sectors_per_fat+1
    iny
    lda    [_si], Y
    sta    fat32.sectors_per_fat+2
    iny
    lda    [_si], Y
    sta    fat32.sectors_per_fat+3
    
    ldy    #fat32_boot_sector.reserved_sectors
    lda    [_si], Y
    sta    fat32.reserved_sectors
    iny
    lda    [_si], Y
    sta    fat32.reserved_sectors+1

    ldy    #fat32_boot_sector.root_dir_1st_cluster
    lda    [_si], Y
    sta    fat32.root_dir_1st_cluster
    iny
    lda    [_si], Y
    sta    fat32.root_dir_1st_cluster+1
    iny
    lda    [_si], Y
    sta    fat32.root_dir_1st_cluster+2
    iny
    lda    [_si], Y
    sta    fat32.root_dir_1st_cluster+3

    ; fat32.fat_begin_lba = fat32.current_partition + fat32.reserved_sectors
    clc
    lda    fat32.current_partition
    adc    fat32.reserved_sectors
    sta    fat32.fat_begin_lba
    lda    fat32.current_partition+1
    adc    fat32.reserved_sectors+1
    sta    fat32.fat_begin_lba+1
    lda    fat32.current_partition+2
    adc    #$00
    sta    fat32.fat_begin_lba+2
    lda    fat32.current_partition+3
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
 
    adcw   fat32.fat_begin_lba, fat32.cluster_begin_lba
    addw   fat32.fat_begin_lba+2, fat32.cluster_begin_lba+2

    ldx    #$00
    rts

;;
;; function: fat32_sector_address
;; [todo]
;;
;; Parameters:
;;    _cx : cluster number
;;
;; Return:
;;    _ax : sector number
;;
fat32_sector_address:
    ; sector = fat32.cluster_begin_lba + (cluster_number - 2) * fat32.sectors_per_cluster

    ; _cx = cluster_number - 2
    subw   #$0002, <_cx
    sbcw   #$0000, <_cx+2

    ; _ax = _cx * fat32.sectors_per_cluster
    lda    fat32.sectors_per_cluster
    sta    <_ax+3
    stz    <_ax+2
    stz    <_ax+1
    
    cla
    ldy    #$08
@loop:
    asl    A
    rol    <_ax+1
    rol    <_ax+2
    rol    <_ax+3
    bcc    @next
        clc
        adc    <_cx
        pha

        lda    <_ax+1
        adc    <_cx+1
        sta    <_ax+1
        lda    <_ax+2
        adc    <_cx+2
        sta    <_ax+2
        lda    <_ax+3
        adc    <_cx+3
        sta    <_ax+3
        
        pla
@next:
    dey
    bne    @loop
    sta    <_ax
    
    ; _ax += fat32.cluster_begin_lba
    addw   fat32.cluster_begin_lba, <_ax
    adcw   fat32.cluster_begin_lba+2, <_ax+2
    
    rts
