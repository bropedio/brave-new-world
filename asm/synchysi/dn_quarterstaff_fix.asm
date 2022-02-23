hirom
header

org $c2381d
    jsl targetting
    
org $c4b9d0
targetting:
    lda #$02                ; auto-crit
    bit $b3                    ; check if true
    bne end                    ; ignore if not
    lda $b6                    ; spell #
    cmp #$17                ; is it quartr?
    beq change_q            ; branch if so
    cmp #$0d                ; is it doom?
    beq change_d            ; branch if so
end:
    lda #$40                ; original targetting values
    sta $bb                    ; targetting RAM
    rtl
change_d:
    lda #$12
    sta $b6
change_q:
    lda #$6e                ; change targetting
    sta $bb                    ; targetting RAM
    lda #$40                ; set to randomize (why? this shouldn't be necessary. shitty code.)
    tsb $ba                    ; apply
    stz $11a9
    stz $341a
    rtl
