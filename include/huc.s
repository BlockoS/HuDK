;
; HUC.ASM  -  HuC Internal Library
;

; ----
; local variables

		.zp
__sign:		.ds 1
__remain:	.ds 2

		.code
		.mlist

; ----
; eq
; ----
; test egality of two words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X equals 0 is the two args are egals
;	else non nul
; ----
; REMARK : signed compatible
; ----

eq:
	sax
	cmp [__stack]
	bne eq_endno

	ldy #1
	sax
	cmp [__stack],Y
	bne eq_endno

eq_endyes:
	__addmi	2,__stack	; don't push A/X; they are thrown away
	ldx #1
	cla
	rts

eq_endno:
	__addmi	2,__stack
	clx
	cla
	rts

eqb:
	txa
	cmp [__stack]
	bne eq_endno
	bra eq_endyes

; streamlined version - uses zp ( <__temp ) instead of stack
; returns A:X = 0 if false, 1 if true

eqzp:
	cmp	<__temp+1
	bne	.x_ne
	sax
	cmp	<__temp
	bne	.x_ne
	cla
	ldx	#1	; ensure Z flag not set
	rts
.x_ne:
	cla
	clx
	rts

eqbzp:
	txa
	cmp	<__temp
	cla
	bne	.x_ne
	ldx	#1
	rts
.x_ne:
	clx
	rts

; ----
; lt
; ----
; compare two words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is strictly lower than
;	the word in A:X else nul
; ----

ltb:	; XXX: missing optimized byte version
lt:	; signed version
	ldy #1
	cmp #$80
	bcs lt_primary_minus

	; if here, the A:X value is positive

	sta <__temp
	lda [__stack], Y
	bmi cmp_ok	; stack value is negative, so reply OK

	lda <__temp	; stack value is also positive, so just go for the unsigned version
	bra ult_y1

lt_primary_minus:

	; if here, the A:X value is negative

	sta <__temp
	lda [__stack], Y
	bmi getA_ult ; stack value is also negative, so restore A val from
			; __temp and call ult

cmp_false:
	__addmi	2,__stack
	ldx	#0
	cla
	rts

getA_ult:
	lda <__temp

ult:	; unsigned version
	ldy #1	; false by default

ult_y1: ; same thing but Y is assumed to be equal to 1

	cmp [__stack],Y
	beq .lt_must_test_lobyte
	bcs cmp_ok
	bra .lt_end ; hibyte of the reg var < hibyte of the pushed var

.lt_must_test_lobyte:
	sax
	cmp [__stack]
	beq .lt_end
	bcs cmp_ok	; set result to true
	; lobyte of the reg var < lobyte of the pushed var

.lt_end:
	tya		; __addmi does not preserve Y
	__addmi	2,__stack
			; if Y was 1, return A=X=0 -> false
	eor #$ff	; if Y was 0, return A=0, X=1 -> true
	inc a
	inc a
	tax
	cla
	rts

ublt:	; unsigned version
	txa
	cmp [__stack]
	beq .lt_end
	bcs cmp_ok	; set result to true
	; lobyte of the reg var < lobyte of the pushed var

.lt_end:
	__addmi	2,__stack
	ldx	#0
	cla
	rts



; ----
; gt
; ----
; compare two words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is strictly greater than
;	the word in A:X else nul
; ----

gtb:	; XXX: missing optimized byte version
gt:	; signed version of >
	ldy #1
	cmp #$80
	bcs .gt_primary_minus

	; if here, the A:X value is positive

	sta <__temp
	lda [__stack], Y
	bmi cmp_false ; stack value is negative, so reply False

	lda <__temp	; stack value is also positive, so just go for the unsigned version
	bra ugt_y1	; we spare one instruction, since we already have Y=1

.gt_primary_minus:

	; if here, the A:X value is negative

	sta <__temp
	lda [__stack], Y
	bmi getA_ugt ; stack value is also negative, so restore A val from
			; __temp and call ugt

cmp_ok:
	__addmi	2,__stack
	ldx #1
	cla
	rts

getA_ugt:	; we grab back the value of A before entering the unsigned
		; version of >
	lda <__temp

ugt:	; unsigned version of >

	ldy #1

ugt_y1: ; unsigned version of >, assuming Y = 1

	cmp [__stack],Y
	beq .gt_must_test_lobyte
	bcs .gt_end ; hibyte of the reg var >= hibyte of the pushed var
	cly
	bra .gt_end

.gt_must_test_lobyte
	sax
	cmp [__stack]
	bcs .gt_end	; lobyte of the reg var >= lobyte of the pushed var
	cly

.gt_end:
	tya
	__addmi	2,__stack
	eor #$ff
	inc a
	inc a
	tax
	cla
	rts

ubgt:	; unsigned byte version of >
	txa
	cmp [__stack]
	bcc .gt_true
	__addmi	2,__stack
	clx
	cla
	rts
.gt_true:
	__addmi	2,__stack
	ldx #1
	cla
	rts


; ----
; zero page versions of lt/gt/ult/ugt:
; ----

ltbzp:
ltzp:	; signed, zero page
	sta	<__temp+2
	eor	<__temp+1
	bpl	.geta_ult
	lda	<__temp+2
	bpl	.true
.false:	clx
	cla
	rts
.true:	ldx	#1
	cla
	rts
.geta_ult:
	lda	<__temp+2	; and fall through to unsigned test

ultzp:	cmp	<__temp+1
	beq	.test_lo
	bcc	.false
.true:	ldx	#1
	cla
	rts
.test_lo:
	sax
	cmp	<__temp
	beq	.false
	bcs	.true
.false:	clx
	cla
	rts

ubltzp:
	txa
	cmp	<__temp
	cla
	beq	.false
	bcc	.false
	ldx	#1
	rts
.false: clx
	rts

; ----
gtbzp:
gtzp:	; signed, zero page
	sta	<__temp+2
	eor	<__temp+1
	bpl	.geta_ugt
	lda	<__temp+2
	bpl	.false
.true:	ldx	#1
	cla
	rts
.false:	clx
	cla
	rts
.geta_ugt:
	lda	<__temp+2	; and fall through to unsigned test

ugtzp:
	cmp	<__temp+1
	beq	.test_lo
	bcs	.false
.true:	ldx	#1
	cla
	rts
.test_lo:
	sax
	cmp	<__temp
	beq	.false
	bcc	.true
.false:	clx
	cla
	rts

ubgtzp:
	txa
	cmp	<__temp
	cla
	beq	.false
	bcs	.false
	ldx	#1
	rts
.false:	clx
	rts


; ----
; ge
; ----
; compare two signed words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is greater or egal to
;	the word in A:X else nul
; ----

; XXX: can these be optimized?
ge:	; signed version of >
	jsr lt
	sax
	dec a
	dec a
	eor #$ff
	sax
	rts

geb:	; signed byte version of >
	jsr ltb
	sax
	dec a
	dec a
	eor #$ff
	sax
	rts

gezp:	jsr	ltzp
	sax
	dec a
	dec a
	eor	#$ff
	sax
	rts

gebzp:	jsr	ltbzp
	sax
	dec a
	dec a
	eor	#$ff
	sax
	rts

; ----
; uge
; ----
; compare two unsigned signed words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is greater or egal to
;	the word in A:X else nul
; ----

; XXX: can these be optimized?
uge:	; unsigned version of >
	jsr ult
	sax
	dec a
	dec a
	eor #$ff
	sax
	rts

ubge:	; unsigned byte version of >
	jsr ublt
	sax
	dec a
	dec a
	eor #$ff
	sax
	rts

ugezp:	jsr	ultzp
	sax
	dec a
	dec a
	eor	#$ff
	sax
	rts

ubgezp:	jsr	ubltzp
	sax
	dec a
	dec a
	eor	#$ff
	sax
	rts

; ----
; ne
; ----
; compare two words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non null if pushed word is different from
;	the word in A:X else null
; ----
; REMARK : signed compatible
; ----

	; previous version called 'eq' as subroutine and returned
	; opposite value; should be fully implemented for speed
	; since '!=' is such a common operator
ne:
	sax
	cmp [__stack]
	bne .ne_endne

	ldy #1
	sax
	cmp [__stack],Y
	bne .ne_endne

.ne_endeq:
	__addmi	2,__stack
	clx
	cla
	rts

.ne_endne:
	__addmi 2,__stack
	ldx	#1
	cla
	rts

neb:
	txa
	cmp [__stack]
	bne .ne_endne

.ne_endeq:
	__addmi	2,__stack
	clx
	cla
	rts

.ne_endne:
	__addmi	2,__stack
	ldx	#1
	cla
	rts

; streamlined version - uses zp ( <__temp ) instead of stack
; returns A:X = 0 if false, 1 if true

nezp:
	cmp	<__temp+1
	bne	.x_ne
	sax
	cmp	<__temp
	bne	.x_ne
	cla
	clx
	rts
.x_ne:
	cla
	ldx	#1	; ensure Z flag not set
	rts

nebzp:
	txa
	cmp	<__temp
	cla
	bne	.x_ne
	clx
	rts
.x_ne:
	ldx	#1	; ensure Z flag not set
	rts

; ----
; le
; ----
; compare two signed words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is lower or egal to
;	the word in A:X else nul
; ----

; XXX: can these be optimized?
le:	; signed version
	jsr gt
	sax
	eor #$ff
	inc a
	inc a
	sax
	rts

leb:	; signed version
	jsr gtb
	sax
	eor #$ff
	inc a		; assuming that A=1 if true
	inc a
	sax
	rts

lezp:	jsr	gtzp
	sax
	eor	#$ff
	inc a
	inc a
	sax
	rts

lebzp:	jsr	gtbzp
	sax
	eor	#$ff
	inc a
	inc a
	sax
	rts

; ----
; ule
; ----
; compare two unsigned words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : word A:X is non nul if pushed word is lower or egal to
;	the word in A:X else nul
; ----

; XXX: can these be optimized?
ule:	; unsigned version
	jsr ugt
	sax
	eor #$ff
	inc A	; assuming that A=1 if true
	inc a
	sax
	rts

uble:	; unsigned byte version
	jsr ubgt
	sax
	eor #$ff
	inc A	; assuming that A=255 if true
	inc a
	sax
	rts

ulezp:	jsr	ugtzp
	sax
	eor	#$ff
	inc a
	inc a
	sax
	rts

ublezp:	jsr	ubgtzp
	sax
	eor	#$ff
	inc a
	inc a
	sax
	rts

; ----
; asl
; ----
; shift the pushed word left by the register word
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;	shifted left by A:X
; ----
; REMARK :	only the lower byte of the right operand is taken in account
;		signed compatible
; ----
asl:
	stx <__temp
	__ldwp __stack
	ldy <__temp
	beq .asl_end
	sta <__temp
	sax

.asl_begin
	asl a
	rol <__temp
	dey
	bne .asl_begin

	sax
	lda <__temp

.asl_end
	__addmi	2,__stack
	rts

aslzp:
	beq .asl_end
	sta <__temp
	sax

.asl_begin
	asl a
	rol <__temp
	dey
	bne .asl_begin

	sax
	lda <__temp
.asl_end
	rts


; ----
; asr
; ----
; shift the pushed word right by the register word
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;	shifted right by A:X
; ----
; REMARK :	only the lower byte of the right operand is taken in account
;		signed compatible
; ----
asr:
	stx <__temp
	__ldwp __stack
	ldy <__temp
	beq .asr_end
	sta <__temp
	sax

.asr_begin
	cpx #$80
	ror <__temp
	ror a

	dey
	bne .asr_begin

	sax
	lda <__temp

.asr_end
	__addmi	2,__stack
	rts

asrzp:
	beq .asr_end
	sta <__temp
	sax

.asr_begin
	cpx #$80
	ror <__temp
	ror a
	dey
	bne .asr_begin

	sax
	lda <__temp
.asr_end
	rts

lsr:
	stx <__temp
	__ldwp __stack
	ldy <__temp
	beq .lsr_end
	sta <__temp
	sax

.lsr_begin
	lsr <__temp
	ror a
	dey
	bne .lsr_begin

	sax
	lda <__temp

.lsr_end
	__addmi	2,__stack
	rts

lsrzp:
	beq .lsr_end
	sta <__temp
	sax

.lsr_begin
	lsr <__temp
	ror a
	dey
	bne .lsr_begin

	sax
	lda <__temp
.lsr_end
	rts

; ----
; smul
; ----
; multiply two SIGNED words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;	multiplied by A:X
; ----

smul:
	stz	<__sign	; until we call umul, sign keeps the sign parity
			; of operand
	cmp	#$80
	bcc	smul_no_invert_primary

	__negw

	inc	<__sign	; sign ++

smul_no_invert_primary:
	sta	<__temp
	ldy	#1
	lda	[__stack],Y
	cmp	#$80
	bcc	smul_no_invert_secondary

	inc	<__sign	; this time, no optimisation possible, IMHO :)
			; are you sure? :))
	stx	<__temp+1

	lda	[__stack]
	tax
	lda	[__stack],Y	; we assumed Y = 1 since we set it at the
				; beginning of smul_no_invert_primary
	__negw
	sta [__stack],Y
	sax
	sta [__stack]

	ldx <__temp+1

smul_no_invert_secondary:
	lda <__sign
	pha
	lda <__temp	; saved at the beginning of smul_no_invert_primary
			; where we're sure we passed

	jsr umul

	say
	pla
	and #$01
	beq smul_end

	say
	__negw
	rts

smul_end:
	say
	rts


; ----
; umul
; ----
; multiply two UNSIGNED words
; ----
; IN :  First word on the C stack
;	Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;       multiplied by A:X
; ----

umul:
	__stw	<__temp+2 ; bx
	__ldwp	__stack
	__stw	<__temp   ; ax
	  jsr	umul16
	__addmi	2,__stack
	__ldw	<__ptr
	  rts

umul16:
	  lda	<__temp+3
	  ora	<__temp+1
	  beq	umul8

	  stwz	<__ptr
	  ldy	#16

.l1:	  aslw	<__ptr
	  aslw	<__temp+2
	  bcc	.l2
	  addw	<__temp,<__ptr
.l2:	  dey
	  bne	.l1

	  rts

umul8:
	  lda	<__temp+2
	  sta	<__ptr+1
	  cla
	  ldy	#8

.l1:	  asl	A
	  rol	<__ptr+1
	  bcc	.l2
	  add	<__temp
	  bcc	.l2
	  inc	<__ptr+1
.l2:	  dey
	  bne	.l1

	  sta	<__ptr
	  rts


; ----
; sdiv
; ----
; divide two SIGNED words
; ----
; IN :  First word on the C stack
;       Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;       divided by A:X
; ----

sdiv:
	stz	<__sign	; until we call udiv, sign keeps the sign parity
			; of operand
	cmp	#$80
	bcc	sdiv_no_invert_primary

	__negw

	inc	<__sign	; sign ++

sdiv_no_invert_primary:
	sta	<__temp
	ldy	#1
	lda	[__stack],Y
	cmp	#$80
	bcc	sdiv_no_invert_secondary

	inc	<__sign

	stx	<__temp+1

	lda	[__stack]
	tax
	lda	[__stack],Y	; we assumed Y = 1 since we set it at the beginning of
				; sdiv_no_invert_primary
	__negw
	sta	[__stack],Y
	sax
	sta	[__stack]

	ldx	<__temp+1

sdiv_no_invert_secondary:
	lda	<__sign
	pha
	lda	<__temp	; saved at the beginning of sdiv_no_invert_primary
			; where we're sure we passed
	jsr	udiv

	say
	pla
	and	#$01
	beq	sdiv_end

	say
	__negw
	rts

sdiv_end:
	say
	rts


; ----
; udiv
; ----
; divide two UNSIGNED words
; ----
; IN :  First word on the C stack
;       Another word in A:X
; ----
; OUT : Register word egals the previous pushed value
;       divided by A:X
; ----

udiv:
	__stw	<__ptr
	__ldwp	__stack
	__stw	<__temp

	lda	#0
	sta	<__remain+1
	ldy	#16
.sdiv_begin:	asl	<__temp
	rol	<__temp+1
	rol	a
	rol	<__remain+1
	pha
	cmp	<__ptr
	lda	<__remain+1
	sbc	<__ptr+1
	bcc	.sdiv_end
	sta	<__remain+1
	pla
	sbc	<__ptr
	pha
	inc	<__temp
.sdiv_end:	pla
	dey
	bne	.sdiv_begin
	sta	<__remain

	__addmi	2,__stack
	__ldw	<__temp

	rts


; ----
; smod
; ----
; give the integer remainder of the two words
; ----
; IN :  First word on the C stack
;       Another word in A:X
; ----
; OUT : Register word egals the remainder of the division of the
;       pushed value by A:X
; ----

smod:
	stz	<__sign
	__stw	<__ptr
	__ldwp	__stack
	cmp	#$80
	bcc	.skip1
	inc	<__sign
	__negw
	__stwp	__stack
.skip1:	__ldw	<__ptr
	cmp	#$80
	bcc	.skip2
	__negw
.skip2:	jsr	umod
	ldy	<__sign
	beq	.noinv
	__negw
.noinv:	rts

umod:
	__stw	<__ptr
	__ldwp	__stack
	__stw	<__temp

	lda	#0
	sta	<__remain+1
	ldy	#16
.umod_begin:	asl	<__temp
	rol	<__temp+1
	rol	a
	rol	<__remain+1
	pha
	cmp	<__ptr
	lda	<__remain+1
	sbc	<__ptr+1
	bcc	.umod_end
	sta	<__remain+1
	pla
	sbc	<__ptr
	pha
	inc	<__temp
.umod_end:	pla
	dey
	bne	.umod_begin
	sta	<__remain

	__addmi	2,__stack
	__ldw	<__remain

	rts

; ----
; ___case
; ----
; implement a switch instruction in C
; ----
; IN :  primary register (A:X) contain the discriminant value
;       i.e. the one that will be checked against those indicated in the
;       various case instructions
;       On the stack, a pointer is passed
;       This is a pointer toward an array
;       Each item of this array is a 4 bytes long structure
;       The structure is the following :
;         WORD value_to_check
;         WORD label_to_jump_to
;       We have to parse the whole array in order to compare the primary
;       register with all the 'value_to_check' field. If we ever find that
;       the primary register is egal to such a value, we must jump to the
;       corresponding 'label_to_jump_to'.
;       The default value (which also means that we reached the end of the
;       array) can be recognized with its 'label_to_jump_to' field set to 0.
;       Then the 'value_to_check' field become the default label we have to
;       use for the rest of the execution.
; ----
; OUT : The execution goes to another place
; ----
; REMARK : Also use remain variable as a temporary value
; ----

___case:
	__stw	<__remain		; store the value to check to
	__ldwp	__stack
	__stw	<__ptr		; __ptr contain the address of the array

	__addmi	2,__stack

	cly
	bra	.begin_case

.next_case_lo:
	iny
.next_case_hi:
	iny
.begin_case:
	iny			; skip func lo-byte
	lda	[__ptr],y	; test func hi-byte
	beq	.case_default
	iny
	lda	[__ptr],y
	cmp	<__remain+0
	bne	.next_case_lo
	iny
	lda	[__ptr],y
	cmp	<__remain+1
	bne	.next_case_hi
	dey			; found match
	dey
.case_vector:
	lda	[__ptr],y	; read func hi-byte
	sta	<__temp+1
	dey
	lda	[__ptr],y	; read func lo-byte
	sta	<__temp+0
	jmp	[__temp]
.case_default:
	iny
	iny
	bra	.case_vector


; ----
; hook
; ----
; indirect call to sub-routine
; ----
; IN :  sub-routine addr in __ptr
; ----

hook:
	jmp	[__ptr]

; ----
; setvdc
; ----
; set a vdc register
; ----
; IN : - reg index on the C stack
;      - value in A:X
; ----

setvdc:	tay
	lda	[__sp]
	lsr	a
	cmp	#$09
	beq	.l3

.l1:	sta	<vdc_ri
	sta	video_reg
	stx	video_data_l
	sty	video_data_h
.l2:	__addmi	2,__sp
	rts
	; -- reg $09
.l3:	txa
	and	#$70
	lsr	A
	lsr	A
	lsr	A
	lsr	A
	jsr	vdc_set_bat_size
	bra	.l2

; ----
; getvdc
; ----
; get vdc register content
; ----
; IN : reg index in A:X
; ----
; OUT: vdc register in A:X
; ----

getvdc:	cpx	#4
	bne	.l1
	lda	#2
	sta	<vdc_ri
	sta	video_reg
	ldx	video_data_l
	lda	video_data_h
	rts
.l1:    clx
	cla
	rts

_irq_enable.1:
    txa
    eor    #$ff
    sei
    and    irq_disable
    sta    irq_disable
    cli
    rts

_irq_disable.1:
    txa
    sei
    ora    irq_disable
    sta    irq_disable
    cli
    rts

_vdc_wait_vsync:
    vdc_wait_vsync
    rts
