hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; If a certain bit is enabled, prevents enemies from dying at 0 HP to avoid improper deaths
; Utilizes bit 6 of $3C95, formerly "Auto crit if imp"

org $C213A1
JMP Bit_Check

org $C203B6
Bit_Check:
LDA $3C95,Y
AND #$0040		; Check bit 6 of $3C96
BEQ Normal_Death; If it's not set, branch and kill the target as normal
RTS				; Else, end function. Death status will not be set in this case

Normal_Death:
LDA #$0080
JMP $0E32		; Set death status

; EOF