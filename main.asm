
	include	"memory.asm"
	include	"equates.asm"

vectortable:
	dc.l	0
	dc.l	startprogram
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	0		; IRQ level 4 (horizontal retrace interrupt)
	dc.l	errortrap
	dc.l	0		; IRQ level 6 (vertical retrace interrupt)
	dc.l	errortrap
	dc.l	errortrap		; TRAP #00 exception
	dc.l	errortrap		; TRAP #01 exception
	dc.l	errortrap		; TRAP #02 exception
	dc.l	errortrap		; TRAP #03 exception
	dc.l	errortrap		; TRAP #04 exception
	dc.l	errortrap		; TRAP #05 exception
	dc.l	errortrap		; TRAP #06 exception
	dc.l	errortrap		; TRAP #07 exception
	dc.l	errortrap		; TRAP #08 exception
	dc.l	errortrap		; TRAP #09 exception
	dc.l	errortrap		; TRAP #10 exception
	dc.l	errortrap		; TRAP #11 exception
	dc.l	errortrap		; TRAP #12 exception
	dc.l	errortrap		; TRAP #13 exception
	dc.l	errortrap		; TRAP #14 exception
	dc.l	errortrap		; TRAP #15 exception
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.l	errortrap
	dc.b	"SEGA MEGA DRIVE "
	dc.b	"THISDOESNTEXIST "
	dc.b	"MEGA DRIVE OPERATING SYSTEM 9X                  "
	dc.b	"MEGA DRIVE OPERATING SYSTEM 9X                  "
	dc.b	"GM XXXXXXXX-XX"
	dc.w	0
	dc.b	"J6              "
	dc.l	0
	dc.l	-1
	dc.l	memory_start
	dc.l	memory_end-1
	dc.b	"R","A",$A0,$20
	dc.l	sram_start
	dc.l	sram_end
	dc.b	"                                                    "
	dc.b	"JUE             "
	
errortrap:
	bra.s	errortrap
	
startprogram:
	moveq	#$F,d0
	and.b	(z80_version).l,d0
	beq.s	TMSSLESS
	move.l	#"SEGA",(security_addr).l	; unlock Video Display Ports
	
TMSSLESS:
	moveq	#0,d0
	movea.l	d0,a0
	movep.l	0(a0),d0
	
	; clear PSG
	lea	(psg_input).l,a0
	move.b	#$9F,(a0)
	move.b	#$BF,(a0)
	move.b	#$DF,(a0)
	move.b	#$FF,(a0)
	
	lea	(VdpData).l,a0
	tst.w	VdpCtrl-VdpData(a0) ; test control port
	
	; clear VRAM
	move.l	#VRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	moveq	#0,d0
	move.w	#(VRAM_SIZE/4)-1,d1
	
@clearvram:
	move.l	d0,(a0)
	dbf	d1,@clearvram
	
	; clear CRAM
	move.l	#CRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	moveq	#0,d0
	moveq	#(CRAM_SIZE/4)-1,d1
	
@clearcram:
	move.l	d0,(a0)
	dbf	d1,@clearcram
	
	; clear VSRAM
	move.l	#VSRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	moveq	#0,d0
	moveq	#(VSRAM_SIZE/4)-1,d1
	
@clearvsram:
	move.l	d0,(a0)
	dbf	d1,@clearvsram

	move.l	#bluescreen,(gamemode).w

gamemodeloop:
	movea.l	(gamemode).w,a0
	jsr	(a0)
	bra.s	gamemodeloop
	
whitescreen:
	lea	(VdpData).l,a0
	lea	VdpCtrl-VdpData(a0),a1
	move.l	#($8000+%00000100)<<16|$8100+%00010100,(a1)
	move.l	#($8C00+%10000001)<<16|$8F00+%00000010,(a1)
	move.l	#CRAM_ADDR_CMD,(a1)
	move.l	#$0EEE<<16|$0EEE,d0
	moveq	#(CRAM_SIZE/4)-1,d1
	
@loadwhite:
	move.l	d0,(a0)
	dbf	d1,@loadwhite
	
@loop:
	bra.s	@loop
	
bluescreen:
	lea	(VdpData).l,a0
	lea	VdpCtrl-VdpData(a0),a1
	move.l	#($8000+%00000100)<<16|$8100+%00010100,(a1)
	move.l	#($8C00+%10000001)<<16|$8F00+%00000010,(a1)
	move.l	#CRAM_ADDR_CMD,(a1)
	move.l	#$0A00<<16|$0EEE,(a0)
	move.w	#$0AAA,(a0)
	
@loop:
	bra.s	@loop
	
bootscreen:
	lea	(VdpData).l,a0
	lea	VdpCtrl-VdpData(a0),a1
	move.l	#($8000+%00000100)<<16|$8100+%00010100,(a1)
	move.l	#($8C00+%10000001)<<16|$8F00+%00000010,(a1)
	move.l	#CRAM_ADDR_CMD,(a1)
	move.l	#$0000<<16|$00E0,(a0)
	
@loop:
	bra.s	@loop