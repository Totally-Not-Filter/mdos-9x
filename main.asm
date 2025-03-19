
; Set this to 1 to make the source compatible with asm68k
asm68k equ 0

; Set this to 1 to make the source compatible with vasm
vasm equ 1

	include	"memory.asm"
	include	"equates.asm"
	include	"macros.asm"

; Set this to 1 to enable the standard ICD_BLK4.PRG setup
startupstandard	equ 0

; Set this to 1 to set the program as an unreleased dev version
devversion equ 1

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
	dc.l	hint_loc	; IRQ level 4 (horizontal retrace interrupt)
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
	
.clearvram:
	move.l	d0,(a0)
	dbf	d1,.clearvram
	
	; clear CRAM
	move.l	#CRAM_ADDR_CMD,(a1)
	moveq	#(CRAM_SIZE/4)-1,d1
	
.clearcram:
	move.l	d0,(a0)
	dbf	d1,.clearcram
	
	; clear VSRAM
	move.l	#VSRAM_ADDR_CMD,(a1)
	moveq	#(VSRAM_SIZE/4)-1,d1
	
.clearvsram:
	move.l	d0,(a0)
	dbf	d1,.clearvsram
	
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
	
.clearmemory:
	move.l	d0,(a0)+
	dbf	d1,.clearmemory
	
	move.w	#$4EF9,(vint_jmp).w
	move.l	#vint1,(vint_loc).w
	move.w	#$4EF9,(hint_jmp).w
	move.l	#hint1,(hint_loc).w

	move.l	#bootscreen,(gamemode).w

gamemodeloop:
	movea.l	(gamemode).w,a0
	jsr	(a0)
	bra.s	gamemodeloop
	
vint1:
	rte
	
hint1:
	rte
	
	include	"mdtool\KosinskiPlus.asm"
	
ASCIIArtSize:	equ $740 ; size of uncompressed ASCIIArt.

	include	"mdtool\ASCII2Plane.asm"

bluescreen:
	lea	(VdpData).l,a0
	move.l	#CRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	move.l	#$A00<<16|$EEE,(a0)
	move.w	#$AAA,(a0)
	
	lea	ASCIIArt(pc),a0
	lea	(buffer).l,a1
	bsr.w	KosPlusDec

	VRAMwrite	buffer,ASCIIArtSize,$20
	
	lea	BScreenASCII(pc),a0
	move.l	#$40000000+(((plane_a+$604)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(BScreenASCII_end-BScreenASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	lea	ErrorTypeASCII(pc),a0
	move.l	#$40000000+(((plane_a+$704)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(ErrorTypeASCII_end-ErrorTypeASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	moveq	#0,d0
	move.b	(errortype).w,d0
	add.b	ErrorTypeIndex(pc,d0.w),d3
	
	
.loop:
	bra.s	.loop
	
BScreenASCII:
	dc.b	"AN ERROR HAS OCCURRED AT 0X"
BScreenASCII_end:

ErrorTypeASCII:
	dc.b	"ERROR TYPE:"
ErrorTypeASCII_end:

ErrorTypeIndex:
	dc.b	BusError-ErrorTypeIndex
	dc.b	AddressError-ErrorTypeIndex
	dc.b	IllegalError-ErrorTypeIndex
	dc.b	DivideError-ErrorTypeIndex
	dc.b	CHKError-ErrorTypeIndex
	dc.b	TrapVError-ErrorTypeIndex
	dc.b	PrivError-ErrorTypeIndex
	dc.b	TraceError-ErrorTypeIndex
	dc.b	Line1010Error-ErrorTypeIndex
	dc.b	Line1111Error-ErrorTypeIndex
BusError:	dc.b	"BUS"
AddressError:	dc.b	"ADDRESS"
IllegalError:	dc.b	"ILLEGAL"
DivideError:	dc.b	"DIVIDE"
CHKError:	dc.b	"CHK"
TrapVError:	dc.b	"TRAPV"
PrivError:	dc.b	"PRIV"
TraceError:	dc.b	"TRACE"
Line1010Error:	dc.b	"LINE1010"
Line1111Error:	dc.b	"LINE1111"
	
bootscreen:
	lea	(VdpData).l,a0
	move.l	#CRAM_ADDR_CMD,VdpCtrl-VdpData(a0)
	move.l	#$000<<16|$0E0,(a0)

	lea	ASCIIArt(pc),a0
	lea	(buffer).l,a1
	bsr.w	KosPlusDec

	VRAMwrite	buffer,ASCIIArtSize,$20
	
	lea	BOOTScreenTitleASCII(pc),a0
	move.l	#$40000000+(((plane_a+$10C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(BOOTScreenTitleASCII_end-BOOTScreenTitleASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	lea	VersionNumASCII(pc),a0
	move.l	#$40000000+(((plane_a+$20C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(VersionNumASCII_end-VersionNumASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	lea	VersionNumASCII(pc),a0
	move.l	#$40000000+(((plane_a+$20C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(VersionNumASCII_end-VersionNumASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	lea	CompilerTypeASCII(pc),a0
	move.l	#$40000000+(((plane_a+$30C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(CompilerTypeASCII_end-CompilerTypeASCII)-1,d1
	bsr.w	ASCIIToPlane
	
	lea	DateOfCompileASCII(pc),a0
	move.l	#$40000000+(((plane_a+$40C)&$3FFF)<<16)+(((plane_a)&$C000)>>14),d0
	moveq	#(DateOfCompileASCII_end-DateOfCompileASCII)-1,d1
	bsr.w	ASCIIToPlane
	
.loop:
	bra.s	.loop
	
BOOTScreenTitleASCII:
	dc.b	"MEGA DRIVE OPERATING SYSTEM"
BOOTScreenTitleASCII_end:

VersionNumASCII:
	dc.b	"VERSION: R1"
	if devversion
	dc.b	"X"
	endif
VersionNumASCII_end:

CompilerTypeASCII:
	dc.b	"COMPILED WITH: "
	if vasm
	dc.b	"VASM PSI-X"
	endif
	if asm68k
	dc.b	"ASM68K"
	endif
CompilerTypeASCII_end:

DateOfCompileASCII:
	dc.b	"DATE: "
	dc.b	"\#_month/\#_day/\#_year \#_hours:\#_minutes:\#_seconds"
DateOfCompileASCII_end:
	
ASCIIArt:
	incbin	"art\ASCII.kosp"
	
	; pad to 16kb
	cnop	0,$4000