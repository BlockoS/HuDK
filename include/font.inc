;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

;;
;; Title: 8x8 monochrome 1bpp font.
;;

;;
;; ubyte: FONT_8x8_COUNT
;; Number of characters embedded in the font.
FONT_8x8_COUNT=$80

;;
;; ubyte: FONT_8x8_ASCII_FIRST
;; ASCII code of the first font character.
;;
FONT_ASCII_FIRST=$00
;;
;; ubyte: FONT_8x8_ASCII_LAST
;; ASCII code of the last font character.
;;
FONT_ASCII_LAST =$9e

;;
;; ubyte: FONT_DIGIT_INDEX
;; Tile index of the first digit character ('0').
;;
FONT_DIGIT_INDEX=$30
;;
;; ubyte: FONT_UPPER_CASE_INDEX
;; Tile index of the first uppercase character ('A').
;;
FONT_UPPER_CASE_INDEX=$41
;;
;; ubyte: FONT_LOWER_CASE_INDEX
;; Tile index of the first lowercase character ('a').
;;
FONT_LOWER_CASE_INDEX=$61

;;
;; array: font_8x8
;; 8x8 1bpp font data.
;;
font_8x8:
    .byte $00,$00,$00,$00,$00,$00,$00,$00    ;empty
    .byte $00,$00,$00,$00,$00,$00,$00,$ff    ;  
    .byte $00,$00,$00,$00,$00,$00,$ff,$ff    ;
    .byte $00,$00,$00,$00,$00,$ff,$ff,$ff    ;
    .byte $00,$00,$00,$00,$ff,$ff,$ff,$ff    ;
    .byte $00,$00,$00,$ff,$ff,$ff,$ff,$ff    ;
    .byte $00,$00,$ff,$ff,$ff,$ff,$ff,$ff    ;
    .byte $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff    ;
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff    ;
    .byte $10,$38,$7c,$fe,$fe,$7c,$10,$38    ; ace of spaces
    .byte $00,$6c,$fe,$fe,$fe,$7c,$38,$10    ; ace of hearts
    .byte $00,$10,$38,$7c,$fe,$7c,$38,$10    ; ace of diamonds
    .byte $10,$38,$38,$7c,$fe,$7c,$10,$38    ; ace of clubs
    .byte $38,$7c,$fe,$fe,$fe,$7c,$38,$00    ; full circle
    .byte $38,$44,$82,$82,$82,$44,$38,$00    ; empty circle
    .byte $01,$02,$04,$08,$10,$20,$40,$80
    
    .byte $80,$40,$20,$10,$08,$04,$02,$01
    .byte $fe,$92,$92,$fe,$82,$82,$86,$82
    .byte $40,$7c,$90,$7c,$50,$fe,$10,$10
    .byte $7e,$42,$7e,$42,$7e,$42,$46,$82
    .byte $fe,$82,$82,$fe,$82,$82,$fe,$82
    .byte $08,$fc,$a8,$fe,$a4,$fc,$14,$0c
    .byte $10,$38,$6c,$c6,$7c,$24,$4c,$00
    .byte $00,$e8,$5a,$e8,$48,$ca,$64,$58
    .byte $01,$03,$07,$0f,$1f,$3f,$7f,$ff
    .byte $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff
    .byte $ff,$7f,$3f,$1f,$0f,$07,$03,$01
    .byte $ff,$fe,$fc,$f8,$f0,$e0,$c0,$80
    .byte $00,$04,$06,$ff,$06,$04,$00,$00
    .byte $00,$20,$60,$ff,$60,$20,$00,$00
    .byte $10,$38,$7c,$10,$10,$10,$10,$10
    .byte $10,$10,$10,$10,$10,$7c,$38,$10
    
    .byte $00,$00,$00,$00,$00,$00,$00,$00    ;SPACE
    .byte $cc,$cc,$cc,$88,$88,$00,$cc,$00    ;!
    .byte $6c,$6c,$d8,$00,$00,$00,$00,$00    ;"
    .byte $6c,$fe,$6c,$6c,$6c,$fe,$6c,$00    ;#
    .byte $10,$38,$40,$38,$04,$38,$10,$00    ;$
    .byte $42,$a4,$48,$10,$24,$4a,$84,$00    ;%
    .byte $20,$50,$20,$54,$88,$94,$62,$00    ;&
    .byte $18,$30,$60,$00,$00,$00,$00,$00    ;'
    .byte $18,$30,$60,$60,$60,$30,$18,$00    ;(
    .byte $30,$18,$0c,$0c,$0c,$18,$30,$00    ;)
    .byte $54,$38,$7c,$38,$54,$00,$00,$00    ;*
    .byte $00,$10,$10,$7c,$10,$10,$00,$00    ;+
    .byte $00,$00,$00,$18,$18,$08,$10,$00    ;,
    .byte $00,$00,$00,$78,$00,$00,$00,$00    ;-
    .byte $00,$00,$00,$00,$60,$60,$00,$00    ;.
    .byte $06,$0c,$18,$30,$60,$c0,$00,$00    ;/

    .byte $38,$4c,$c6,$c6,$c6,$64,$38,$00    ;0
    .byte $18,$78,$18,$18,$18,$18,$7e,$00    ;1
    .byte $7c,$c6,$0e,$3c,$78,$e0,$fe,$00    ;2
    .byte $fe,$0c,$18,$7c,$06,$c6,$7c,$00    ;3
    .byte $3c,$6c,$cc,$cc,$cc,$fe,$0c,$00    ;4
    .byte $fe,$c0,$fc,$06,$06,$c6,$7c,$00    ;5
    .byte $3c,$60,$c0,$fc,$c6,$c6,$7c,$00    ;6
    .byte $fe,$c6,$0c,$18,$30,$30,$30,$00    ;7
    .byte $7c,$c6,$c6,$7c,$c6,$c6,$7c,$00    ;8
    .byte $7c,$c6,$c6,$7e,$06,$0c,$78,$00    ;9
    .byte $00,$18,$18,$00,$18,$18,$00,$00    ;:
    .byte $00,$18,$18,$00,$18,$18,$30,$00    ;;
    .byte $0c,$18,$30,$60,$30,$18,$0c,$00    ;<
    .byte $00,$00,$7c,$00,$7c,$00,$00,$00    ;=
    .byte $60,$30,$18,$0c,$18,$30,$60,$00    ;>
    .byte $7c,$c6,$9e,$38,$20,$00,$30,$00    ;?

    .byte $3c,$42,$9a,$aa,$aa,$5c,$00,$00    ;@
    .byte $38,$6c,$c6,$c6,$fe,$c6,$c6,$00    ;A
    .byte $fc,$c6,$c6,$fc,$c6,$c6,$fc,$00    ;B
    .byte $3c,$66,$c0,$c0,$c0,$66,$3c,$00    ;C
    .byte $f8,$cc,$c6,$c6,$c6,$cc,$f8,$00    ;D
    .byte $fe,$c0,$c0,$fc,$c0,$c0,$fe,$00    ;E
    .byte $fe,$c0,$c0,$fc,$c0,$c0,$c0,$00    ;F
    .byte $3c,$66,$c0,$ce,$c6,$66,$3e,$00    ;G
    .byte $c6,$c6,$c6,$fe,$c6,$c6,$c6,$00    ;H
    .byte $7e,$18,$18,$18,$18,$18,$7e,$00    ;I
    .byte $06,$06,$06,$06,$06,$c6,$7c,$00    ;J
    .byte $c6,$cc,$d8,$f0,$d8,$cc,$c6,$00    ;K
    .byte $c0,$c0,$c0,$c0,$c0,$c0,$fe,$00    ;L
    .byte $82,$c6,$ee,$fe,$d6,$c6,$c6,$00    ;M
    .byte $86,$c6,$e6,$f6,$de,$ce,$c6,$00    ;N
    .byte $7c,$c6,$c6,$c6,$c6,$c6,$7c,$00    ;O

    .byte $fc,$c6,$c6,$c6,$fc,$c0,$c0,$00    ;P
    .byte $7c,$c6,$c6,$c6,$de,$cc,$76,$00    ;Q
    .byte $fc,$c6,$c6,$fc,$d8,$cc,$c6,$00    ;R
    .byte $7c,$c6,$f0,$7c,$1e,$c6,$7c,$00    ;S
    .byte $7e,$18,$18,$18,$18,$18,$18,$00    ;T
    .byte $c6,$c6,$c6,$c6,$c6,$c6,$7c,$00    ;U
    .byte $c6,$c6,$c6,$c6,$c6,$6c,$38,$00    ;V
    .byte $c6,$c6,$c6,$d6,$fe,$ee,$c6,$00    ;W
    .byte $c6,$ee,$7c,$38,$7c,$ee,$c6,$00    ;X
    .byte $66,$66,$66,$3c,$18,$18,$18,$00    ;Y
    .byte $fe,$0e,$1c,$38,$70,$e0,$fe,$00    ;Z
    .byte $78,$60,$60,$60,$60,$60,$78,$00    ;[
    .byte $c0,$60,$30,$18,$0c,$06,$00,$00    ; '\'
    .byte $3c,$0c,$0c,$0c,$0c,$0c,$3c,$00    ;]
    .byte $10,$28,$44,$00,$00,$00,$00,$00    ;^
    .byte $00,$00,$00,$00,$00,$00,$fe,$00    ;_

    .byte $00,$00,$00,$00,$00,$00,$00,$00    ; 
    .byte $00,$00,$3c,$06,$7e,$c6,$7e,$00    ;a
    .byte $c0,$c0,$fc,$c6,$c6,$c6,$fc,$00    ;b
    .byte $00,$00,$7c,$c6,$c0,$c6,$7c,$00    ;c
    .byte $06,$06,$7e,$c6,$c6,$c6,$7e,$00    ;d
    .byte $00,$00,$7c,$c6,$fc,$c0,$7e,$00    ;e
    .byte $3e,$60,$60,$f8,$60,$60,$60,$00    ;f
    .byte $00,$00,$7c,$c6,$c6,$7e,$06,$7c    ;g
    .byte $c0,$c0,$fc,$c6,$c6,$c6,$c6,$00    ;h
    .byte $18,$00,$18,$18,$18,$18,$18,$00    ;i
    .byte $0c,$0c,$00,$0c,$0c,$0c,$0c,$78    ;j
    .byte $c0,$c0,$d8,$f0,$e0,$f0,$d8,$00    ;k
    .byte $70,$30,$30,$30,$30,$30,$78,$00    ;l
    .byte $00,$00,$7c,$d6,$d6,$d6,$d6,$00    ;m
    .byte $00,$00,$7c,$66,$66,$66,$66,$00    ;n
    .byte $00,$00,$3c,$66,$66,$66,$3c,$00    ;o

    .byte $00,$00,$7c,$66,$66,$7c,$60,$60    ;p
    .byte $00,$00,$3e,$66,$66,$3e,$06,$06    ;q
    .byte $00,$00,$d8,$fc,$e0,$c0,$c0,$00    ;r
    .byte $00,$00,$3c,$60,$38,$0c,$78,$00    ;s
    .byte $30,$30,$78,$30,$30,$30,$1c,$00    ;t
    .byte $00,$00,$66,$66,$66,$66,$3e,$00    ;u
    .byte $00,$00,$c6,$c6,$6c,$38,$10,$00    ;v
    .byte $00,$00,$c6,$d6,$d6,$d6,$6c,$00    ;w
    .byte $00,$00,$c6,$6c,$10,$6c,$c6,$00    ;x
    .byte $00,$00,$66,$66,$66,$3e,$06,$3c    ;y
    .byte $00,$00,$fe,$0c,$38,$60,$fe,$00    ;z
    .byte $08,$10,$10,$20,$10,$10,$08,$00    ;{
    .byte $10,$10,$00,$00,$00,$10,$10,$00    ;|
    .byte $10,$08,$08,$04,$08,$08,$10,$00    ;}
    .byte $00,$00,$00,$32,$4c,$00,$00,$00    ;~
    .byte $81,$42,$24,$18,$18,$24,$42,$81    ;  

font_8x8_palette:
    .word VCE_GREEN, VCE_WHITE, VCE_BLACK, $0000, $0000, $0000, $0000, $0000
