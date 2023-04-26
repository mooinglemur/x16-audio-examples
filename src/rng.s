.export rng

; galois 16
.proc rng: near
	ldy #8
	lda seed+0
:
	asl        ; shift the register
	rol seed+1
	bcc :+
	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne :--
	sta seed+0
	cmp #0     ; reload flags
	rts
seed:
    .word $1337
.endproc
