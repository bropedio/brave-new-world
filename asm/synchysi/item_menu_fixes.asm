hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Allows Remedy to cure Imp on the status screen
; Allows Slim Jims and Red Bull to be used from the field menu screen
; Allows the newly-introduced Green Cherries to toggle Imp status

org $C32C67			; Remedy spell
AND #$65

org $C38B7B			; Slim Jim (was Green Cherry)
CMP #$FC
BEQ Heal

org $C38BA0			; Soft execution (hijacking for Snake Oil)
JSR Heal
BCC Remedy

org $C38BB2
Remedy:

org $C38BC4
Heal:

org $C38B81
JMP More_Checks
RTS					; Just in case

org $C3F197
More_Checks:
BEQ Sleeping_Bag
CMP #$FB
BEQ Red_Bull

Bzzt:
JMP $8BD0

Sleeping_Bag:
JMP $8BD2

Red_Bull:
JMP Heal

; EOF
