altramadd:
	move.l  #$4000000,-(sp)
	move.l  #$1000000,-(sp)
	move.w  #$14,-(sp)
	trap    #1
	lea     $a(sp),sp
	moveq   #3,d0
	jmp     $e00bd2
    
