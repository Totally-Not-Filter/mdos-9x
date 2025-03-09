; sram memory
	rsset	$200001
sram_start:	rs.b	0
	rs.b	$10000-2
sram_end:	rs.b	0
	rsreset

; system memory
	rsset	$FFFF0000
memory_start:	rs.b	0
buffer:	rs.b	$8000
gamemode:	rs.l	1
	rs.b	$7FFC
memory_end:	rs.b	0
	rsreset