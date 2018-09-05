FAT32_MBR_SIGNATURE = $AA55
FAT32_PARTITION = $0b
FAT32_INT13_PARTITION = $0c
FAT32_MEDIA_TYPE = $f8
FAT32_BYTES_PER_SECTOR = $200
FAT32_FAT_COUNT = $02

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
fat32_volume_id.jump                 .rs 3
fat32_volume_id.oem_id               .rs 8
fat32_volume_id.bytes_per_sector     .rs 2
fat32_volume_id.sectors_per_cluster  .rs 1
fat32_volume_id.reserved_sectors     .rs 2
fat32_volume_id.fat_count            .rs 1
fat32_volume_id.root_dir_entry_count .rs 2
fat32_volume_id.total_sectors16      .rs 2
fat32_volume_id.media_type           .rs 1
fat32_volume_id.sectors_per_fat16    .rs 2
fat32_volume_id.sectors_per_tracks   .rs 2
fat32_volume_id.head_count           .rs 2
fat32_volume_id.hidden_sectors       .rs 4
fat32_volume_id.total_sectors32      .rs 4
fat32_volume_id.sectors_per_fat32    .rs 4
fat32_volume_id.flags                .rs 2
fat32_volume_id.version              .rs 2
fat32_volume_id.root_dir_1st_cluster .rs 4
fat32_volume_id.fs_info              .rs 2
fat32_volume_id.back_boot_block      .rs 2
fat32_volume_id.reserved             .rs 12
fat32_volume_id.drive_number         .rs 1
fat32_volume_id.reserved_nt          .rs 1
fat32_volume_id.boot_signature       .rs 1
fat32_volume_id.serial_number        .rs 4
fat32_volume_id.label                .rs 11
fat32_volume_id.file_system_type     .rs 8
fat32_volume_id.boot_code            .rs 420
fat32_volume_id.signature            .rs 2

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

fat32.sectors_per_cluster  .ds 1
fat32.sectors_per_fat      .ds 4
fat32.reserved_sectors     .ds 2
fat32.root_dir_1st_cluster .ds 4

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
;; function: fat32_read_volume_id
;; [todo]
;;
;; Parameters:
;,   _si : address of sector buffer
;;
;; Return:
;;
fat32_read_volume_id:
    ; check if we have a valid fat32 volume
    ; 1. media type
    ldy    #fat32_volume_id.media_type
    lda    [_si], Y
    cmp    #FAT32_MEDIA_TYPE
    bne    @invalid_volume_id
    
    ; 2. bytes per sector (512)
    ldy    #fat32_volume_id.bytes_per_sector
    lda    [_si], Y
    cmp    #low(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_volume_id
    
    iny
    lda    [_si], Y
    cmp    #high(FAT32_BYTES_PER_SECTOR)
    bne    @invalid_volume_id

    ; 3. number of fats (2)
    ldy    #fat32_volume_id.fat_count
    lda    [_si], Y
    cmp    #FAT32_FAT_COUNT
    bne    @invalid_volume_id
    
    ; 4. check signature
    addw   <_si, #fat32_volume_id.signature, <_ax
    lda    [_ax]
    cmp    #low(FAT32_MBR_SIGNATURE)
    bne    @invalid_volume_id
    
    ldy    #$01
    lda    [_ax], Y
    cmp    #high(FAT32_MBR_SIGNATURE)
    beq    @get_root_directory

    ; there may be other things to check like extended boot signature, jump code, etc...

@invalid_volume_id:
    ldx    #FAT32_INVALID_VOLUME_ID
    rts
       
@get_root_directory:
    ldy    #fat32_volume_id.sectors_per_cluster
    lda    [_si], Y
    sta    fat32.sectors_per_cluster

    ldy    #fat32_volume_id.sectors_per_fat32
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
    
    ldy    #fat32_volume_id.reserved_sectors
    lda    [_si], Y
    sta    fat32.reserved_sectors
    iny
    lda    [_si], Y
    sta    fat32.reserved_sectors+1

    ldy    #fat32_volume_id.root_dir_1st_cluster
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

    ldx    #$00
    rts


