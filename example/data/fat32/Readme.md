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
    .dw $0000,$0800,$0801,$0806,$0820,$0a87,$0cee,$0cef
    .dw $0cf0,$0cf1,$0cf2,$0cf3,$0cf4,$0cf5,$0cf6,$0cf7
    .dw $0cf8,$0cf9,$0cfa,$0cfb,$0cfc,$0cfd,$0cfe,$0cff
    .dw $0d00,$0d01,$0d02,$0d03,$0d04,$0d05,$0d06,$0d07
    .dw $0d08,$0d09,$0d0a

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
