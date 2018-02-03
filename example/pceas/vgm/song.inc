song_bank=$01
song_base_address=$c000
song_loop_bank=$01
song_loop=$c003
    .bank $01
    .org $c000
    .incbin "data/song0000.bin"
    .bank $02
    .org $c000
    .incbin "data/song0001.bin"
    .bank $03
    .org $c000
    .incbin "data/song0002.bin"
    .bank $04
    .org $c000
    .incbin "data/song0003.bin"
    .bank $05
    .org $c000
    .incbin "data/song0004.bin"
    .bank $06
    .org $c000
    .incbin "data/song0005.bin"
    .bank $07
    .org $c000
    .incbin "data/song0006.bin"
