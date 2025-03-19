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
errortype:	rs.w	1
count:		rs.w	1
memory_stack:	rs.b	0
hint_jmp:	rs.w	1
hint_loc:	rs.l	1
vint_jmp:	rs.w	1
vint_loc:	rs.l	1
	rs.b	$7FEC
memory_end:	rs.b	0
	rsreset