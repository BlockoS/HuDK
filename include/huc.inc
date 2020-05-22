;;
;; HuC macros and other utilises
;;

	.zp
__sp
__stack	.ds 2
__temp	.ds 4
__ptr	.ds 2
__fbank	.ds 1
__fptr	.ds 2
  
  .ifdef HAVE_LIB3
maplibfunc_hold_a	.ds 1
  .endif

;;
;; Macro: __farptr
;; Copy bank id and offset of a label.
;;
;; Assembly call:
;;   > __farptr label, bank_id, bank_offset
;;
;; Parameter:
;;   label - label to retrieve bank id and offset from.
;;   bank_id - id of the bank where the label was declared.
;;   bank_offset - offset of the label in the bank where it was declared.
;;
  .macro __farptr
    ldy    #bank(\1)
    sty    \2
    ldy    #low(\1)
    sty    \3
    ldy    #high(\1) & $1F
    sty    \3+1
  .endm

;;
;; Macro: __farptr_i
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __farptr_i
    sax
    add    #low(\1)
    .if (\# = 3)
        sta    <\3
    .else
        sta    <__fptr
    .endif
    sax
    adc    #high(\1) & $1F
    .if (\# = 3)
        sta    <\3+1
    .else
        tax
    .endif
    rol    A
    rol    A
    rol    A
    rol    A
    and    #$F
    add    #bank(\1)
    .if (\# = 3)
        sta    <\2
    .endif
  .endm

;;
;; Macro: __farptr_get
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __farptr_get
    stx    <\1
    ldy    #2
    lda    [__ptr], Y
    sta    <\2
    iny
    lda    [__ptr], Y
    sta    <\2+1
  .endm

;;
;; Macro: __fgetb
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __fgetb
    tam    #3
    txa
    and    #$1F
    ora    #$60
    sta    <__fptr+1
    lda    [__fptr]
    tax
    bpl    .x_\@
    dec    A
.x_\@:
  .endm

;;
;; Macro: __fgetb
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __fgetub
    tam    #3
    txa
    and    #$1F
    ora    #$60
    sta    <__fptr+1
    lda    [__fptr]
    tax
    cla
  .endm

;;
;; Macro: __phax
;; Push registers A and X onto the stack.
;;
  .macro __phax
    pha
    phx
  .endm

;;
;; Macro: __plax
;; Pull registers X and A from the stack.
;;
  .macro __plax
    plx
    pla
  .endm

;;
;; Macro: __plax
;; Pull registers A and X from the stack.
;;
  .macro __plxa
    pla
    plx
  .endm

;;
;; Macro: __ldb
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __ldb
  .if (\# = 2)
    clx
    lda    \1
    clc
    adc    #low(\2)
    sax
    adc    #high(\2)
  .else
    ldx    \1
    __extw
  .endif
  .endm

;;
;; Macro: __ldby
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __ldby
    ldx    \1, y
    __extw
  .endm

;;
;; Macro: __ldub
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __ldub
  .if (\# = 2)
    clx
    lda	\1
    clc
    adc	#low(\2)
    sax
  .else
    ldx	\1
    cla
  .endif
  .endm

;;
;; Macro: __ldbp
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __ldbp
    lda	[\1]
    tax
    __extw
  .endm

;;
;; Macro: __ldubp
;;
;; Assembly call:
;;
;; Parameter:
;;
  .macro __ldubp
    lda	[\1]
    tax
    cla
  .endm

__stbps	.macro
	__phax
	__ldwp	__stack
	__stw	<__ptr
	__plxa
	sta	[__ptr]
	sax
	__addmi	2,__stack
 .endm

__ldw	.macro
 .if (\# = 2)
	lda	\1
	clc
	adc	#low(\2)
	tax
	lda	\1+1
	adc	#high(\2)
.else
	ldx	\1
	lda	\1+1
 .endif
 .endm

__ldwp	.macro
	lda	[\1]
	tax
	ldy	#1
	lda	[\1],Y
 .endm

__ldwi	.macro
	ldx	#low(\1)
	lda	#high(\1)
 .endm

__stw	.macro
	stx	\1
	sta	\1+1
 .endm

__stwi	.macro
	ldx	#low(\2)
	stx	\1
	lda	#high(\2)
	sta	\1 + 1
 .endm

__stbi	.macro
	ldx	#low(\2)
	stx	\1
	cla
 .endm

__stwz	.macro
	stz	\1
	stz	\1 + 1
 .endm

__stwp	.macro
	sax
	sta	[\1]
	sax
	ldy	#1
	sta	[\1],Y
 .endm

__stbp	.macro
	sax
	sta	[\1]
	sax
 .endm

__stwps	.macro
	__phax
	__ldwp	__stack
	__stw	<__ptr
	__plax
	__stwp	__ptr
	__addmi	2,__stack
 .endm

__stwip	.macro
	__stw	__ptr
	lda	#low(\1)
	tax
	sta	[__ptr]
	lda	#high(\1)
	ldy	#1
	sta	[__ptr],Y
 .endm

__stbip	.macro
	__stw	__ptr
	lda	#low(\1)
	sta	[__ptr]
	tax
	cla
 .endm

__pushw	.macro
 .ifndef SMALL
	ldy	<__stack
	bne	.x_\@
	dec	<__stack + 1
 .endif
.x_\@:	dec	<__stack
	sta	[__stack]
 .ifndef SMALL
	bne	.y_\@
	dec	<__stack + 1
 .endif
.y_\@:	dec	<__stack
	sax
	sta	[__stack]
	sax
 .endm

__popw	.macro
	lda	[__stack]
	tax
	ldy	#1
	lda	[__stack],Y
	__addmi	2,__stack
 .endm

__calls	.macro
	pha
	ldy	#\1
	lda	[__stack],Y
	sta	<__ptr
 .ifndef SMALL
	incw	<__stack
.else
	inc	<__stack
 .endif
	lda	[__stack],Y
	sta	<__ptr+1
 .ifndef SMALL
	incw	<__stack
.else
	inc	<__stack
 .endif
	pla
	jsr	hook
 .endm

__swapw	.macro
	pha
	ldy	#1
	lda	[__stack],Y
	sta	<__temp
	lda	[__stack]
	sax
	sta	[__stack]
	pla
	sta	[__stack],Y
	lda	<__temp
 .endm


; TODO : check if we need pha/pla or not
__tstw	.macro
	; pha
	stx	<__temp
	ora	<__temp
	cla
	clx
	beq	.x_\@
	inx
.x_\@:
	; pla
 .endm

__lsrw	.macro
	lsr	A
	sax
	ror	A
	sax
 .endm

__aslw	.macro
	sax
	asl	A
	sax
	rol	A
 .endm

__aslwi	.macro
 .if (\1 = 1)
	__aslw
.else
 .if (\1 = 2)
	__aslw
	__aslw
.else
 .if (\1 = 8)
	txa
	clx
.else
	ldy	#\1
	jsr	aslzp
 .endif
 .endif
 .endif
 .endm

__aslws	.macro
	lda	[__stack]
	asl	a
	sta	[__stack]
	ldy	#1
	lda	[__stack],Y
	rol	a
	sta	[__stack],Y
 .endm

__asrw	.macro
	cmp	#$80
	ror	A
	sax
	ror	A
	sax
 .endm

__asrwi	.macro
 .if (\1 = 1)
	__asrw
.else
 .if (\1 = 2)
	__asrw
	__asrw
.else
 .if (\1 = 8)
	tax
	cmp	#$80
	cla
	bcc	.x_\@
	dec a
.x_\@:
.else
	ldy	#\1
	jsr	asrzp
 .endif
 .endif
 .endif
 .endm

__lsrwi	.macro
 .if (\1 = 1)
	__lsrw
.else
 .if (\1 = 2)
	__lsrw
	__lsrw
.else
 .if (\1 = 8)
	tax
	cla
.else
	ldy	#\1
	jsr	lsrzp
 .endif
 .endif
 .endif
 .endm

__extw	.macro
	txa	; signed
	cla
	bpl	.x_\@
	dec	A
.x_\@:
 .endm

__comw	.macro
	sax
	eor	#$FF
	sax
	eor	#$FF
 .endm

__negw	.macro
	sax
	eor	#$FF
	clc
	adc	#1
	sax
	eor	#$FF
	adc	#0
 .endm

__boolw	.macro
	stx	<__temp
	ora	<__temp
	clx
	beq	.x\@
	inx
.x\@	cla
 .endm

__notw	.macro
	stx	<__temp
	ora	<__temp
	clx
	bne	.x\@
	inx
.x\@	cla
 .endm

__addw	.macro
	clc
	sax
	adc	\1
	sax
	adc	\1+1
 .endm

__addb	.macro
	clc
	sax
	adc	\1
	sax
	ldy	\1
	bpl	.x\@
	dec a
.x\@:	adc	#0
 .endm

__addub	.macro
	clc
	sax
	adc	\1
	sax
	adc	#0
 .endm

__addwi	.macro
 .if (\1 = 1)
	cpx	#$ff
	inx
	adc	#0
.else
 .if (\1 = 2)
	cpx	#$fe
	inx
	inx
	adc	#0
.else
	clc
	sax
	adc	#low(\1)
	sax
	adc	#high(\1)
 .endif
 .endif
 .endm

; pceas workaround; the regular __addwi doesn't work if the argument is
; symbolic because the code size changes as it is resolved.
__addwi_sym	.macro
	clc
	sax
	adc	#low(\1)
	sax
	adc	#high(\1)
 .endm

__mulwi	.macro
 .if (\1 = 2)
	__aslw
.else
 .if (\1 = 3)
	__stw	<__temp
	__aslw
	__addw	<__temp
.else
 .if (\1 = 4)
	__aslw
	__aslw
.else
 .if (\1 = 5)
	__stw	<__temp
	__aslw
	__aslw
	__addw	<__temp
.else
 .if (\1 = 6)
	__aslw
	__stw	<__temp
	__aslw
	__addw	<__temp
.else
 .if (\1 = 7)
	__stw	<__temp
	__aslw
	__aslw
	__aslw
	__subw	<__temp
.else
 .if (\1 = 8)
	__aslw
	__aslw
	__aslw
.else
 .if (\1 = 9)
	__stw	<__temp
	__aslw
	__aslw
	__aslw
	__addw	<__temp
.else
 .if (\1 = 10)
	__aslw
	__stw	<__temp
	__aslw
	__aslw
	__addw	<__temp
.else
	__pushw
	__ldwi	\1
	jsr	umul
 .endif
 .endif
 .endif
 .endif
 .endif
 .endif
 .endif
 .endif
 .endif
 .endm

__addbi	.macro
 .if (\1 = 1)
	inx
.else
 .if (\1 = 2)
	inx
	inx
.else
 .if (\1 = 3)
	inx
	inx
	inx
.else
	clc
	txa
	adc	#low(\1)
	tax
 .endif
 .endif
 .endif
	cla
 .endm

  .ifdef SMALL
__addmi	.macro
 .if (\1 = 1)
	inc	<\2		; 6
.else
 .if (\1 = -1)
	dec	<\2		; 6
.else
 .if (\1 = -2)
	dec	<\2
	dec	<\2		; => 12
.else
 .if (\1 = 2)
	inc	<\2
	inc	<\2		; => 12
.else
	tay			; 2
	clc			; 2
	lda	<\2		; 4
	adc	#low(\1)	; 2
	sta	<\2		; 4
	tya			; 2 => 16
 .endif
 .endif
 .endif
 .endif
 .endm

__addmi_sym	.macro
	tay			; 2
	clc			; 2
	lda	<\2		; 4
	adc	#low(\1)	; 2
	sta	<\2		; 4
	tya			; 2 => 16
 .endm

.else ; SMALL

__addmi1	.macro		; 10(14)
	inc	<\1		; 6
	bne	.x\@		; 4(2)
	inc	<\1+1		; 0(6)
.x\@:
 .endm

__submi1	.macro		; 14(18)
	ldy	<\1		; 4
	bne	.x\@		; 4(2)
	dec	<\1+1		; 0(6)
.x\@:
	dec	<\1		; 6
 .endm

__addmi	.macro
 .if (\1 = 1)
	__addmi1	\2
.else
 .if (\1 = -1)
	__submi1	\2
.else
	tay			; 2
	clc			; 2
	lda	<\2		; 4
	adc	#low(\1)	; 2
	sta	<\2		; 4
 .if (\1 < 256) & (\1 >= 0)
	bcc	.x\@		; 4(2)
	inc	<\2+1		; 0(6)
.x\@:
.else
 .if (\1 >= -256) & (\1 < 0)
	bcs	.y\@		; 4(2)
	dec	<\2+1		; 0(6)
.y\@:
.else
	lda	<\2+1		; 4
	adc	#high(\1)	; 2
	sta	<\2+1		; 4
 .endif
 .endif
	tya			; 2 => 20(24) / 26
 .endif
 .endif
 .endm

__addmi_sym	.macro
	tay			; 2
	clc			; 2
	lda	<\2		; 4
	adc	#low(\1)	; 2
	sta	<\2		; 4
	lda	<\2+1		; 4
	adc	#high(\1)	; 2
	sta	<\2+1		; 4
	tya			; 2 => 20(24) / 26
 .endm

 .endif ; SMALL

__subw	.macro
	sec
	sax
	sbc	\1
	sax
	sbc	\1+1
 .endm

__subwi	.macro
 .if (\1 = 1)
	cpx	#1
	dex
	sbc	#0
.else
 .if (\1 = 2)
	cpx	#2
	dex
	dex
	sbc	#0
.else
	sec
	sax
	sbc	#low(\1)
	sax
	sbc	#high(\1)
 .endif
 .endif
 .endm

__submi	.macro
	pha
	sec
	lda	<\2
	sbc	#low(\1)
	sta	<\2
	lda	<\2+1
	sbc	#high(\1)
	sta	<\2+1
	pla
 .endm

__addws	.macro
	sax
	clc
	adc	[__stack]
	sax
	ldy	#1
	adc	[__stack],Y
	__addmi	2, __stack
 .endm

__addbs	.macro
	txa
	clc
	adc	[__stack]
	tax
	cla
	__addmi	2, __stack
 .endm

__subws	.macro
	stx	<__temp
	sta	<__temp+1
	sec
	lda	[__stack]
	sbc	<__temp
	tax
	ldy	#1
	lda	[__stack],Y
	sbc	<__temp+1
	__addmi	2, __stack
 .endm

__orws	.macro
	sax
	ora	[__stack]
	sax
	ldy	#1
	ora	[__stack],Y
	__addmi	2,__stack
 .endm

__orwi	.macro
	sax
	ora	#low(\1)
	sax
	ora	#high(\1)
 .endm

__orw	.macro
	sax
	ora	\1
	sax
	ora	\1+1
 .endm

__andws	.macro
	sax
	and	[__stack]
	sax
	ldy	#1
	and	[__stack],Y
	__addmi	2,__stack
 .endm

__andwi	.macro
	sax
	and	#low(\1)
	sax
	and	#high(\1)
 .endm

__andw	.macro
	sax
	and	\1
	sax
	and	\1+1
 .endm

__eorwi	.macro
	sax
	eor	#low(\1)
	sax
	eor	#high(\1)
 .endm

__eorws	.macro
	sax
	eor	[__stack]
	sax
	ldy	#1
	eor	[__stack],Y
	__addmi	2,__stack
 .endm

__lbra	.macro
	jmp	\1
 .endm

__lbran	.macro
	bra	\1
 .endm

__lbeq	.macro
	cpx	#0
	bne	.x\@
	jmp	\1
.x\@
 .endm

__lbeqn	.macro
	cpx	#0
	beq	\1
 .endm

__lbne	.macro
	cpx	#0
	beq	.x\@
	jmp	\1
.x\@
 .endm

__lbnen	.macro
	cpx	#0
	bne	\1
 .endm

__cmpwi_eq	.macro
	cpx	#low(\1)
	clx
	bne	.f\@
	cmp	#high(\1)
	bne	.f\@
	ldx	#1
.f\@:	cla
 .endm

__cmpwi_ne	.macro
	cpx	#low(\1)
	clx
	bne	.t\@
	cmp	#high(\1)
	beq	.f\@
.t\@:	ldx	#1
.f\@:	cla
 .endm

__call	.macro
	call	\1
 .endm

__map_callbank	.macro
 .if (PAGE(\1) = 5)	; user function
	tay
	tma	#4
	pha
	lda	#_call_bank
	tam	#4
	tya
 .endif
 .endm

__unmap_callbank	.macro
 .if (PAGE(\1) = 5)	; user function
	tay
	pla
	tam	#4
	tya
 .endif
 .endm

; optimized macros
; ----

; lea_s
;
.macro __lea_s
	; (bytes : 10, cycles : 16)
	lda	<__sp
	clc
	adc	#LOW(\1)
	tax
.ifndef SMALL
	lda	<__sp+1
	adc	#HIGH(\1)
.else
	lda	#$3f
.endif
.endm

; pea_s
;
.macro __pea_s
	; (bytes : 25, cycles : 44)
.ifndef SMALL
	lda	<__sp
	sec
	sbc	#2
	bcs	.x_\@
	dec	<__sp+1
.x_\@:	 sta	<__sp
	clc
	adc	#LOW(\1+2)
	sta	[__sp]
	tax
	lda	<__sp+1
	adc	#HIGH(\1+2)
	ldy	#1
	sta	[__sp],Y
.else
	lda	<__sp
	dec	a
	dec	a
	sta	<__sp
	clc
	adc	#LOW(\1+2)
	sta	[__sp]
	tax
	lda	#$3f
	ldy	#1
	sta	[__sp],Y
.endif
.endm

; ldb_s
;
.macro __ldb_s
.if (\1 < 256)
	; short index (bytes :  9, cycles : 13/17)
	ldy	#\1
	lda	[__sp],Y
	tax
	cla
	bpl	.x_\@	; signed
	dec	A
.x_\@:
.else
	; long index  (bytes : 20, cycles : 37/41)
	addw	#\1,<__sp,<__ptr	; 13,26
	lda	[__ptr]
	tax
	cla
	bpl	.x_\@	; signed
	dec	A
.x_\@:
.endif
.endm

; addb_s
;
.macro __addb_s
	; short index (bytes :  9, cycles : 13/17)
	stx	<__temp
	sta	<__temp+1
.if (\1 < 256)
	ldy	#\1
	lda	[__sp],Y
.else
	addw	#\1,<__sp,<__ptr	; 13,26
	lda	[__ptr]
.endif
	tax
	__extw
	sax
	clc
	adc	<__temp
	sax
	adc	<__temp+1
.endm

; ldub_s
;
.macro __ldub_s
.if (\1 < 256)
	; short index (bytes :  9, cycles : 13/17)
	ldy	#\1
	lda	[__sp],Y
	tax
	cla
.else
	; long index  (bytes : 20, cycles : 37/41)
	addw	#\1,<__sp,<__ptr	; 13,26
	lda	[__ptr]
	tax
	cla
.endif
.endm

; addub_s
;
.macro __addub_s
.if (\1 < 256)
	; short index (bytes :  9, cycles : 13/17)
	ldy	#\1
	sax
	clc
	adc	[__sp],Y
	sax
	adc	#0
.else
	; long index  (bytes : 20, cycles : 37/41)
	sta	<__temp
	addw	#\1,<__sp,<__ptr	; 13,26
	txa
	clc
	adc	[__ptr]
	tax
	lda	<__temp
	adc	#0
.endif
.endm

; ldb_p
;
.macro __ldb_p
	; (bytes : 11, cycles : 19/23)
	stx	<__ptr
	sta	<__ptr+1
	lda	[__ptr]
	tax
	cla
	bpl	.x_\@	; signed
	dec	A
.x_\@:
.endm

; addbi_p
.macro __addbi_p
	stx	<__ptr
	sta	<__ptr+1
	lda	[__ptr]
	clc
	adc	#\1
	sta	[__ptr]
	tax
	cla
.endm

; ldub_p
;
.macro __ldub_p
	; (bytes : 11, cycles : 19/23)
	stx	<__ptr
	sta	<__ptr+1
	lda	[__ptr]
	tax
	cla
.endm

; ldw_s
;
.macro __ldw_s
.if (\1 < 255)
	; short index (bytes :  7/8, cycles : 18/20)
.if (\1 = 0)
	lda	[__sp]
	tax
	ldy	#1
	lda	[__sp],Y
.else
	ldy	#\1
	lda	[__sp],Y
	tax
	iny
	lda	[__sp],Y
.endif
.else
	; long index  (bytes : 20, cycles : 44)
	addw	#\1,<__sp,<__ptr	; 13,26
	lda	[__ptr]
	tax
	ldy	#1
	lda	[__ptr],Y
.endif
.endm

; stbi_s
;
.macro __stbi_s
.if (\2 < 256)
	; short index (bytes :  8/ 9, cycles : 15)
	lda	#LOW(\1)
	ldy	#\2
	sta	[__sp],Y
	tax
	cla
.else
	; long index  (bytes : 19/20, cycles : 39)

	addw	#\2,<__sp,<__ptr	; 13,26
	lda	#LOW(\1)
	sta	[__ptr]
	tax
	cla
.endif
.endm

; stwi_s
;
.macro __stwi_s
.if (\2 < 255)
	; short index (bytes : 12, cycles : 24)
	lda	#LOW(\1)
	ldy	#\2
	sta	[__sp],Y
	tax
	lda	#HIGH(\1)
	iny
	sta	[__sp],Y
.else
	; long index  (bytes : 24, cycles : 48)
	addw	#\2,<__sp,<__ptr	; 13,26
	lda	#LOW(\1)
	sta	[__ptr]
	tax
	lda	#HIGH(\1)
	ldy	#1
	sta	[__ptr],Y
.endif
.endm

; stb_s
;
.macro __stb_s
.if (\1 < 255)
	; short index (bytes :  6, cycles : 13)
	sax
	ldy	#\1
	sta	[__sp],Y
	sax
.else
	; long index  (bytes : 18, cycles : 42)
	pha
	addw	#\1,<__sp,<__ptr	; 13,26
	txa
	sta	[__ptr]
	pla
.endif
.endm

; stw_s
;
.macro __stw_s
.if (\1 < 255)
	; short index (bytes :  9, cycles : 22)
	sax
	ldy	#\1
	sta	[__sp],Y
	sax
	iny
	sta	[__sp],Y
.else
	; long index  (bytes : 22, cycles : 51)
	pha
	addw	#\1,<__sp,<__ptr	; 13,26
	txa
	sta	[__ptr]
	pla
	ldy	#1
	sta	[__ptr],Y
.endif
.endm

; addw_s
;
.macro __addw_s
.if (\1 < 255)
	; short index (bytes : 10, cycles : 24)
	ldy	#\1
	clc
	sax
	adc	[__sp],Y
	sax
	iny
	adc	[__sp],Y
.else
	; long index  (bytes : 24, cycles : 55)
	pha				;  1, 3
	addw	#\1,<__sp,<__ptr	; 13,26
	pla				;  1, 4
	clc
	sax
	adc	[__ptr]
	sax
	ldy	#1
	adc	[__ptr],Y
.endif
.endm

; XXX: the semantics of this are ridiculous: It assumes the value of
; the incremented variable to be in AX, the memory location to
; be incremented and the previous value retained in AX, making it
; necessary to spill A.
; incw_s
;
.macro __incw_s
	; (bytes : 16, cycles : 24/40)
	pha
	ldy	#\1
	txa
	inc A
	sta	[__sp],Y
	bne	.x_\@
	iny
	lda	[__sp],Y
	inc A
	sta	[__sp],Y
.x_\@:
	pla
.endm

; incb_s
;
.macro __incb_s
	pha
	ldy	#\1
	txa
	inc A
	sta	[__sp],Y
	pla
.endm

; ldd_i
;
.macro __ldd_i
	stw	#(\1) & 0xFFFF,<\2
	stw	#(\1) >> 16,<\3
	ldx	#low(\2)
	lda	#high(\2)
.endm

; ldd_b
;
.macro __ldd_b
	lda	 \1
	sta	<\2
	stz	<\2+1
	stwz	<\3
	ldx	#low(\2)
	lda	#high(\2)
.endm

; ldd_w
;
.macro __ldd_w
	stw	 \1,<\2
	stwz	<\3
	ldx	#low(\2)
	lda	#high(\2)
.endm

; ldd_s_b
;
.macro __ldd_s_b
	__ldb_s	\1
	stx	<\2
	sta	<\2+1
	stwz	<\3
	ldx	#low(\2)
	lda	#high(\2)
.endm

; ldd_s_w
;
.macro __ldd_s_w
	__ldw_s	\1
	stx	<\2
	sta	<\2+1
	stwz	<\3
	ldx	#low(\2)
	lda	#high(\2)
.endm

    .rsset  0
START_BANK .rs  0
LIB1_BANK  .rs  1
LIB2_BANK  .rs  1
LIB3_BANK  .rs  1
CONST_BANK .rs  1
DATA_BANK  .rs  1

    .data
    .bank LIB2_BANK,"Base Library 2/Font"
    .org  $a000

    .code
    .bank	LIB3_BANK,"Base Library 3"
    .org	$a000

    .data
    .bank CONST_BANK,"Constants"
    .org  $4000

    .data
    .bank DATA_BANK,"User Program"
    .org  $6000

    .code
    .bank START_BANK,"Base Library 1"

