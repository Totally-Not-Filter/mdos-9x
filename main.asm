
	include	"memory.asm"
	include	"equates.asm"
	include	"macros.asm"

; Set this to 1 to enable the standard ICD_BLK4.PRG setup
startupstandard	equ 0

; Set this to 1 to set the program as an unreleased dev version
unreleasedver equ 1

vectortable:
	dc.l	memory_stack
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
	dc.l	0	; IRQ level 4 (horizontal retrace interrupt)
	dc.l	errortrap
	dc.l	vint_loc	; IRQ level 6 (vertical retrace interrupt)
	dc.l	errortrap
	dc.l	errortrap	; TRAP #00 exception
	dc.l	errortrap	; TRAP #01 exception
	dc.l	errortrap	; TRAP #02 exception
	dc.l	errortrap	; TRAP #03 exception
	dc.l	errortrap	; TRAP #04 exception
	dc.l	errortrap	; TRAP #05 exception
	dc.l	errortrap	; TRAP #06 exception
	dc.l	errortrap	; TRAP #07 exception
	dc.l	errortrap	; TRAP #08 exception
	dc.l	errortrap	; TRAP #09 exception
	dc.l	errortrap	; TRAP #10 exception
	dc.l	errortrap	; TRAP #11 exception
	dc.l	errortrap	; TRAP #12 exception
	dc.l	errortrap	; TRAP #13 exception
	dc.l	errortrap	; TRAP #14 exception
	dc.l	errortrap	; TRAP #15 exception
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
	dc.b	"OS XXXXXXXX-XX"
	dc.w	0
	dc.b	"J6MKCF          "
	dc.l	0
	dc.l	-1
	dc.l	memory_start
	dc.l	memory_end-1
	dc.b	"RA",$F8,$20
	dc.l	sram_start
	dc.l	sram_end
	dc.b	"                                                    "
	dc.b	"JUE             "
	
errortrap:
	bra.s	errortrap
	
startprogram:
	if startupstandard
	include	"mdsrc/ICD_BLK4.PRG"
	else
	moveq	#$F,d0
	and.b	(z80_version).l,d0
	beq.s	TMSSLESS
	move.l	#"SEGA",(security_addr).l	; unlock Video Display Ports
	
TMSSLESS:
	; clear PSG
	lea	(psg_input).l,a0
	move.b	#$9F,(a0)
	move.b	#$BF,(a0)
	move.b	#$DF,(a0)
	move.b	#$FF,(a0)
	
	lea	(VdpData).l,a0
	lea	VdpCtrl-VdpData(a0),a1
	
	; clear VRAM
	move.l	#VRAM_ADDR_CMD,(a1)
	moveq	#0,d0
	move.w	#(VRAM_SIZE/4)-1,d1
	
@clearvram:
	move.l	d0,(a0)
	dbf	d1,@clearvram
	
	; clear CRAM
	move.l	#CRAM_ADDR_CMD,(a1)
	moveq	#(CRAM_SIZE/4)-1,d1
	
@clearcram:
	move.l	d0,(a0)
	dbf	d1,@clearcram
	
	; clear VSRAM
	move.l	#VSRAM_ADDR_CMD,(a1)
	moveq	#(VSRAM_SIZE/4)-1,d1
	
@clearvsram:
	move.l	d0,(a0)
	dbf	d1,@clearvsram
	
	; low color mode is default
	move.l	#($8000+%00000000)<<16|$8100+%01010100,(a1)
	move.l	#($8200+(plane_a>>10))<<16|$8300+(plane_w>>10),(a1)
	move.l	#($8400+(plane_b>>13))<<16|$8500+(spritetable>>9),(a1)
	move.w	#$8C00+%10000001,(a1)
	move.l	#($8F00+%00000010)<<16|$9000+%00010001,(a1)

	; clear all registers (d0 to user stack pointer)
	; there's probably a way better way to do this but this is the best I've got for now
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d0,a0
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	move.l	a6,usp
	endif
	
	lea	(memory_start).l,a0
	moveq	#0,d0
	move.w	#(memory_stack-memory_start)/4-1,d1
	
@clearmemory:
	move.l	d0,(a0)+
	dbf	d1,@clearmemory
	
	move.w	#$4EF9,(vint_jmp).w
	move.l	#vint1,(vint_loc).w

	move.l	#bootscreen,(gamemode).w

gamemodeloop:
	movea.l	(gamemode).w,a0
	jsr	(a0)
	bra.s	gamemodeloop
	
vint1:
	rte
	
	include	"mdtool\KosinskiPlus.asm"
	
ASCIIArtSize:	equ $660 ; size of uncompressed ASCIIArt.

bluescreen:
	lea	(VdpData).l,a0
	move.l	#CRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	move.l	#$A00<<16|$EEE,(a0)
	move.w	#$AAA,(a0)
	
	lea	ASCIIArt(pc),a0
	lea	(buffer).l,a1
	bsr.w	KosPlusDec

	VRAMwrite	buffer,ASCIIArtSize,$20
	
	lea	VdpData-VdpCtrl(a0),a1
	move.l	#$40000000+(((plane_b+$51E)&$3FFF)<<16)+(((plane_b)&$C000)>>14),(a0)
	move.l	#$0031<<16|$002D,(a1) ; M
	move.l	#$002E<<16|$002F,(a1) ; DO
	move.l	#$0030<<16|$0031,(a1) ; S
	move.l	#$0032<<16|$0033,(a1) ; 9X
	move.w	#$0031,(a1)
	move.l	#$40000000+(((plane_a+$604)&$3FFF)<<16)+(((plane_a)&$C000)>>14),(a0)
	move.l	#$000B<<16|$0018,(a1) ; AN
	move.w	#$4000+((plane_a+$604+6)&$3FFF),(a0)
	move.l	#$000F<<16|$001C,(a1) ; ER
	move.l	#$001C<<16|$0019,(a1) ; RO
	move.w	#$001C,(a1) ; R
	move.w	#$4000+((plane_a+$604+$12)&$3FFF),(a0)
	move.l	#$0012<<16|$000B,(a1) ; HA
	move.w	#$001D,(a1) ; S
	move.w	#$4000+((plane_a+$604+$1A)&$3FFF),(a0)
	move.l	#$0019<<16|$000D,(a1) ; OC
	move.l	#$000D<<16|$001F,(a1) ; CU
	move.l	#$001C<<16|$001C,(a1) ; RR
	move.l	#$000F<<16|$000E,(a1) ; ED
	move.w	#$4000+((plane_a+$604+$2C)&$3FFF),(a0)
	move.l	#$000B<<16|$001E,(a1) ; AT
	move.w	#$4000+((plane_a+$604+$32)&$3FFF),(a0)
	move.l	#$0001<<16|$0022,(a1) ; 0X
	; here is where we soon get the error location
	move.w	#$4000+((plane_a+$604+$48)&$3FFF),(a0)
	move.w	#$0026,(a1) ; .
	
@loop:
	bra.s	@loop
	
bootscreen:
	lea	(VdpData).l,a0
	move.l	#CRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	move.l	#$000<<16|$0E0,(a0)

	lea	ASCIIArt(pc),a0
	lea	(buffer).l,a1
	bsr.w	KosPlusDec

	VRAMwrite	buffer,ASCIIArtSize-($1C+$20*6),$20
	
	lea	VdpData-VdpCtrl(a0),a1
	move.l	#$40000000+(((plane_a+$10C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),(a0)
	move.l	#$0017<<16|$000F,(a1) ; ME
	move.l	#$0011<<16|$000B,(a1) ; GA
	move.w	#$4000+((plane_a+$10C+$A)&$3FFF),(a0)
	move.l	#$000E<<16|$001C,(a1) ; DR
	move.l	#$0013<<16|$0020,(a1) ; IV
	move.w	#$000F,(a1) ; E
	move.w	#$4000+((plane_a+$10C+$16)&$3FFF),(a0)
	move.l	#$0019<<16|$001A,(a1) ; OP
	move.l	#$000F<<16|$001C,(a1) ; ER
	move.l	#$000B<<16|$001E,(a1) ; AT
	move.l	#$0013<<16|$0018,(a1) ; IN
	move.w	#$0011,(a1) ; G
	move.w	#$4000+((plane_a+$10C+$2A)&$3FFF),(a0)
	move.l	#$001D<<16|$0023,(a1) ; SY
	move.l	#$001D<<16|$001E,(a1) ; ST
	move.l	#$000F<<16|$0017,(a1) ; EM
	move.w	#$4000+((plane_a+$20C)&$3FFF),(a0)
	move.l	#$0020<<16|$000F,(a1) ; VE
	move.l	#$001C<<16|$001D,(a1) ; RS
	move.l	#$0013<<16|$0019,(a1) ; IO
	move.l	#$0018<<16|$002C,(a1) ; N:
	move.w	#$4000+((plane_a+$20C+$12)&$3FFF),(a0)
	if unreleasedver
	move.l	#$0001<<16|$0026,(a1) ; 0.
	move.l	#$0001<<16|$0002,(a1) ; 01
	move.w	#$0022,(a1) ; X
	else
	move.l	#$0001<<16|$0026,(a1) ; 0.
	move.l	#$0001<<16|$0002,(a1) ; 01
	endif
	move.w	#$4000+((plane_a+$30C)&$3FFF),(a0)
	move.l	#$000D<<16|$0019,(a1) ; CO
	move.l	#$0017<<16|$001A,(a1) ; MP
	move.l	#$0013<<16|$0016,(a1) ; IL
	move.l	#$000F<<16|$000E,(a1) ; ED
	move.w	#$4000+((plane_a+$30C+$12)&$3FFF),(a0)
	move.l	#$0021<<16|$0013,(a1) ; WI
	move.l	#$001E<<16|$0012,(a1) ; TH
	move.w	#$002C,(a1) ; :
	move.w	#$4000+((plane_a+$30C+$1E)&$3FFF),(a0)
	if asm68k
	move.l	#$000B<<16|$001D,(a1) ; AS
	move.l	#$0017<<16|$0007,(a1) ; M6
	move.l	#$0009<<16|$0015,(a1) ; 8K
	endif
	move.w	#$4000+((plane_a+$40C)&$3FFF),(a0)
	move.l	#$000E<<16|$000B,(a1) ; DA
	move.l	#$001E<<16|$000F,(a1) ; TE
	move.w	#$002C,(a1) ; :
	move.w	#$4000+((plane_a+$40C+$C)&$3FFF),(a0)
	; 03-14-2025
	move.l	#$0001<<16|$0004,(a1)
	move.l	#$0028<<16|$0002,(a1)
	move.l	#$0005<<16|$0028,(a1)
	move.l	#$0003<<16|$0001,(a1)
	move.l	#$0003<<16|$0006,(a1)
	
@loop:
	bra.s	@loop
	
ASCIIArt:
	incbin	"art\ASCII.kosp"
	
	; pad to 16kb
	cnop	0,$4000