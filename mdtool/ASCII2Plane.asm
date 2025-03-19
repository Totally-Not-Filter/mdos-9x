; Usage is below:
; a0 = source
; d0 = plane
; d1 = size

ASCIIToPlane:
	lea	(VdpData).l,a1
	move.l	d0,VdpCtrl-VdpData(a1)

.loadplanes:
	moveq	#0,d2	; clear d1
	move.b	(a0)+,d2	; move byte to d1
	subi.w	#" ",d2	; subtraction value
	move.w	d2,(a1)	; write to the data port
	dbf	d1,.loadplanes
	rts