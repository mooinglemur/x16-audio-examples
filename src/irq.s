.include "audio.inc"
.include "x16.inc"

.export register_handler
.export deregister_handler

.import rng

.macro AUDIO_CALL addr
    jsr X16::Kernal::JSRFAR_kernal_addr
    .word addr
    .byte $0A
.endmacro

.segment "BSS"
old_irq_handler:
    .res 2
.segment "CODE"

.proc register_handler: near
    php
    sei
    lda X16::Vec::IRQVec
    sta old_irq_handler
    lda X16::Vec::IRQVec+1
    sta old_irq_handler+1

    lda #<handler
    sta X16::Vec::IRQVec
    lda #>handler
    sta X16::Vec::IRQVec+1

    plp
    rts
.endproc

.proc deregister_handler: near
    php
    sei

    lda old_irq_handler
    sta X16::Vec::IRQVec
    lda old_irq_handler+1
    sta X16::Vec::IRQVec+1

    plp
    rts
.endproc

.proc handler: near
    ; play a note every 2 frames
    ; release on other frames
    lda frame
    inc
    cmp #2
    bcs :+
    sta frame
    lda #0
    AUDIO_CALL ym_release
    jmp end
:   stz frame

redo: ; get a random number between 125 and 234
    jsr rng
    and #$7f
    cmp #(234-125)
    bcs redo
    adc #125

    tax
    ldy #0
    AUDIO_CALL notecon_freq2fm
    clc
    lda #0
    AUDIO_CALL ym_playnote

end:
    jmp (old_irq_handler)
frame:
    .res 1
.endproc
