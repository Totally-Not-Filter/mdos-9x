; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the VRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

VRAMwrite:	macro source,size,destination
		lea	(VdpCtrl).l,a0
		move.l	#$94000000+((((size)>>1)&$FF00)<<8)|$9300+(((size)>>1)&$FF),(a0)
		move.l	#$96000000+(((source>>1)&$FF00)<<8)|$9500+((source>>1)&$FF),(a0)
		move.w	#$9700+((((source>>1)&$FF0000)>>16)&$7F),(a0)
		move.w	#$4000+((destination)&$3FFF),(a0)
		move.w	#$80+(((destination)&$C000)>>14),(a0)
		endm