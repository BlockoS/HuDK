## How to recreate the fat32 files used for the fake SD card 

### Regenerate the fat32 image
- `dd if=/dev/zero of=/tmp/fat32.img bs=1M count=40`
- `sync`
- `sudo losetup loop0 fat32.img`
- `sudo -H gparted /dev/loop0`
  - create a msdos partition table
  - create a fat32 partition
  - don't forget to apply changes
  - quit
 - `mkdir /tmp/fat32.0`
- `sudo mount /dev/loop0p1 /tmp/fat32.0`
- `mkdir /tmp/fat32.0/0000`
- `sudo cp $HUDK_PATH/example/data/hudk.dat /tmp/fat32.0/0000/`
- `sudo cp $HUDK_PATH/example/data/hudk.pal /tmp/fat32.0/0000/`
- `sudo mkdir /tmp/fat32.0/0001`
- `sudo cp $HUDK_PATH/example/data/hudson.dat /tmp/fat32.0/0001/`
- `sudo cp $HUDK_PATH/example/data/hudson.pal /tmp/fat32.0/0001/`
- `sync`
- `sudo umount /tmp/fat32.0`
- `sudo losetup -d /dev/loop0`

#### Extract non-empty sectors and generate assembly file
`img_slice` is a simple C program that will append every-non empty sectors in 8kB files and output an asm file listing the used sectors and data files.
Simply run
- `gcc -Wall img_slice && ./a.out fat32.img`

If you generated the `fat32.img` as specified above you'll get the following files:
 - bank_0000
 - bank_0001
 - bank_0002
 - fat32.img.inc

The last file will contains the list of "used" sectors, bank files and the total number of sectors and "used" sectors.
```
sectors:
    .db $00,$00,$00,$00,$00,$08,$00,$00,$01,$08,$00,$00,$06,$08,$00,$00
    .db $20,$08,$00,$00,$87,$0a,$00,$00,$ee,$0c,$00,$00,$ef,$0c,$00,$00
    .db $f0,$0c,$00,$00,$f1,$0c,$00,$00,$f2,$0c,$00,$00,$f3,$0c,$00,$00
    .db $f4,$0c,$00,$00,$f5,$0c,$00,$00,$f6,$0c,$00,$00,$f7,$0c,$00,$00
    .db $f8,$0c,$00,$00,$f9,$0c,$00,$00,$fa,$0c,$00,$00,$fb,$0c,$00,$00
    .db $fc,$0c,$00,$00,$fd,$0c,$00,$00,$fe,$0c,$00,$00,$ff,$0c,$00,$00
    .db $00,$0d,$00,$00,$01,$0d,$00,$00,$02,$0d,$00,$00,$03,$0d,$00,$00
    .db $04,$0d,$00,$00,$05,$0d,$00,$00,$06,$0d,$00,$00,$07,$0d,$00,$00
    .db $08,$0d,$00,$00,$09,$0d,$00,$00,$0a,$0d,$00,$00

    .bank $02
    .org  $4000
bank_0000:
    .incbin "data/fat32/bank_0000"

    .bank $03
    .org  $4000
bank_0001:
    .incbin "data/fat32/bank_0001"

    .bank $04
    .org  $4000
bank_0002:
    .incbin "data/fat32/bank_0002"

sector_count = 81920
sector_used = 35
```
