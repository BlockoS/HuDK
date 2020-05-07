;;
;; This file is part of HuDK.
;; ASM and C open source software development kit for the NEC PC Engine.
;; Licensed under the MIT License
;; (c) 2016-2020 MooZ
;;

  .ifdef HUC
; char* __fastcall memcpy(char* dst<_di>, char* src<_si>, int len<acc>);
_memcpy.3:
    phx
    tax
    beq    @done_pages
    ; first copy by chunk of 256 bytes
    cly
@copy_pages:
        lda    [_si], Y
        sta    [_di], Y
        iny
        bne    @copy_pages
    inc    <_si+1
    inc    <_di+1
    dex
    bne    @copy_pages

@done_pages:
    plx
    beq    @done
    
    cly
@copy_bytes:
        lda    [_si], Y
        sta    [_di], Y
        iny
        dex
        bne    @copy_bytes
@done:
    tya
    clc
    adc    <_di
    tax
    lda    <_di+1
    adc    #$00
    rts

; char* __fastcall memset(char* dst<_di>, int c<_bx>, int len<acc>);
_memset.3:
    phx
    tax
    lda    <_bx
    beq    @done_pages
    ; first copy by chunk of 256 bytes
    cly
@copy_pages:
        sta    [_di], Y
        iny
        bne    @copy_pages
    inc    <_si+1
    inc    <_di+1
    dex
    bne    @copy_pages

@done_pages:
    plx
    beq    @done
    
    cly
@copy_bytes:
        sta    [_di], Y
        iny
        dex
        bne    @copy_bytes
@done:
    tya
    clc
    adc    <_di
    tax
    lda    <_di+1
    adc    #$00
    rts

; int __fastcall memcmp(char* dst<_di>, char* src<_si>, int len<acc>);
_memcmp.3:
    stx    <_bl
    tax
    beq    @done_pages
    cly
@test_pages:
            lda    [_di], Y
            cmp    [_si], Y
            bmi    @minus
            bne    @plus
            iny
            bne    @test_pages
        inc    <_si+1
        inc    <_di+1
        dex
        bne    @test_pages
@done_pages:
    cly
    ldx    <_bl
@test_bytes:
        lda    [_di], Y
        cmp    [_si], Y
        bmi    @minus
        bne    @plus
        iny
        dex
        bne    @test_bytes
    
@equal:
    clx
    cla
    rts
@minux:
    ldx    #$ff
    cla
    rts
@plus:
    ldx    #$01
    cla
    rts

  .endif