hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Allows Runic to always absorb MP even if the Runicker is immune to or absorbs
; the casted element.
; This also modifies combat functions to keep spells cast from characters with
; magic damage-boosting relics from restoring 25% more MP than their base cost.
; This check is done in place of the old Air Anchor code.

;org $C23598
;JSR Runic		; The JSR is now part of sei_repo_hacks.asm

org $C2FAB4
Runic:
STZ $3414		; Skip damage modification
STZ $11A1		; Zero out elemental properties
LDA #$80
STA $11A7		; Zero out special byte 3
RTS

; EOF
