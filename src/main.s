.include "x16.inc"
.include "audio.inc"

.import register_handler
.import deregister_handler

.macro AUDIO_CALL addr
    jsr X16::Kernal::JSRFAR_kernal_addr
    .word addr
    .byte $0A
.endmacro

.segment "LOADADDR"
.word $0801

.segment "BASICSTUB"
.word entry-2
.byte $00,$00,$9e
.byte "2061"
.byte $00,$00,$00
.proc entry
    jmp RESET
.endproc

.segment "STARTUP"

.proc RESET
    jsr init_audio
    jsr register_handler
    jsr main_loop
    jsr deregister_handler
    jsr init_audio

    rts
.endproc

.segment "CODE"

.proc main_loop
    lda #255
    sta frames
loop:
    wai
    dec frames
    bne loop
end:
    rts
frames:
    .res 1
.endproc

.proc init_audio
    ; fully init audio subsystem and stop playback of all notes
    AUDIO_CALL audio_init

    ; load Triangle patch from built-in patches
    ; into channel/voice 0
    lda #0
    ldx #82
    sec
    AUDIO_CALL ym_loadpatch

    ; modify C2's ADSR
    ldx #$98 ; AR
    lda #$11 ; 24.92 ms
    AUDIO_CALL ym_write
    ldx #$b8 ; D1R (first decay)
    lda #$00 ; infinite
    AUDIO_CALL ym_write
    ldx #$d8 ; D2R (second decay)
    lda #$16 ; 6.23ms
    AUDIO_CALL ym_write
    ldx #$f8 ; D1L (sustain), Release rate
    lda #$fb ; max, and 6.23ms
    AUDIO_CALL ym_write


    rts
.endproc

.segment "BSS"
