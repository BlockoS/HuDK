sectors:
    .dw $0000,$0800,$0801,$0806,$0820,$0a87,$0cee,$0cef
    .dw $0cf0,$0cf1,$0cf2,$0cf3,$0cf4,$0cf5,$0cf6,$0cf7
    .dw $0cf8,$0cf9,$0cfa,$0cfb,$0cfc,$0cfd,$0cfe,$0cff
    .dw $0d00,$0d01,$0d02,$0d03,$0d04,$0d05,$0d06,$0d07
    .dw $0d08,$0d09,$0d0a

    .bank $02
    .org  $4000
bank_0000:
    .incbin "bank_0000"

    .bank $03
    .org  $4000
bank_0001:
    .incbin "bank_0001"

sector_count = 81920
sector_used = 35
