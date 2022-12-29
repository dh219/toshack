; Based on work (C) Anders Granlund, 2019, released under the GPLv2
; Modified by D Henderson, 2022
;--------------------------------------------------------------
TTRL_MEMBOTTOM		EQU	$01000000
TTRL_MEMMAXSIZE		EQU	128
TTRL_FASTRAMMAGIC	EQU	$1357bd13
TTRL_FASTRAMCOOKIE	EQU	$5f465242

_membot             EQU $00000432
LOC_RAMVALID        EQU $000005a8
LOC_RAMTOP          EQU $000005a4

;a6 old stack
;a5 ramtop

    ORG $E7AB00

    movem.l d0-d7/a0-a6,-(sp)    ;back up all registers
    move.l #0,($5a8) ; mark RAMVALID as false
    jsr TTRAM_Detect
    ; now add detected altram
    cmp.l #0,d0
    beq finished
altramadd:
	move.l  d0,-(sp)
	move.l  #$1000000,-(sp)
	move.w  #$14,-(sp)
	trap    #1
	lea     $a(sp),sp
setramtop:
    move.l #$1357bd13,($5a8)    ; mark RAMVALID as true
    move.l d1,($5a4)            ; set RAMTOP
hardcodecookie:
    ; do an mxalloc this time
    move.w #0,-(sp)             ; stram only
    move.l #$10000,-(sp)        ; 64k
    move.w #68,-(sp)            ; Mxalloc
    trap #1                     ; GEMDOS
    addq.l #8,sp                ; correct stack
    ;
    move.l #TTRL_FASTRAMCOOKIE,($9c8)
    move.l d0,($9cc)
    move.l #0,($9d0)        ; fake null cookie
    move.l #32,($9d4)       ; indicating jar size of 32
clearfrb:   ; to make sure we've not shat all over something, I'm going to clear FRB
    move.l d0,a0
    move.w #$FFFF,d0
clearfrb_loop:
    move.l #55,(a0)+
    dbra.w d0,clearfrb_loop
finished:
    movem.l (sp)+,d0-d7/a0-a6    ;restore registers
    jmp     $e00bd2             ; return to where we left off

;--------------------------------------------------------------
TTRAM_Detect:
; returns:
;	d0: size
;	d1: ram top
;	d2: ram bottom
;--------------------------------------------------------------
	bsr 	.probe
	cmp.l	#TTRL_MEMBOTTOM,a5
	ble		.fail
	move.l	#TTRL_MEMBOTTOM,d2		; d2 = ram bottom
	move.l	a5,d1			; d1 = ram top
	move.l	d1,d0
	sub.l	d2,d0				; d0 = size
	rts
.fail:
	move.l	#0,d0
	move.l	#0,d1
	move.l	#0,d2	
	rts
.probe:
	move.l	sp,a6				; save old stack pointer
	move.l	$8,a4 ;gTTRL_BushandlerOld		; save old bus handler
	move.l	#.err,$8			; install new bus handler
	move.l	#TTRL_MEMBOTTOM,a5
	move.w	#TTRL_MEMMAXSIZE,d3
.loop:
	movea.l	a5,a2
	move.l	(a2),d4				; bus error test

	add.l	#1234,d4			; write/readback test
	move.l	d4,(a2)
	dc.b	$4e,$7a,$00,$02			; get cache register
	or.l	#$808,d0			; clear cache
	dc.b	$4e,$7b,$00,$02			; set cache register	
	cmp.l	(a2),d4
	bne		.done

	add.l	#$00100000,a5		; check 1MB intervals
	sub.w	#1,d3
	tst.w	d3
	bne		.loop
.done:
	move.l	a4,$8		; restore bus handler
	rts
.err:
	move.l	a6,sp				; restore stack to before bus error
	bra		.done				; stop probing for memory

