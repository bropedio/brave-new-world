hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters the random variance formula to consider the target's vig/stam (phys/mag damage)
; in calculating the variance range
; Damage = (Damage * [(225 - 3/4 VigStam) .. (255 - VigStam)] / 225) + 1

; Note: A = Top end - bottom end
; RNG: 0 to A - 1
; Add: A + bottom end

org $C20CA6
SEP #$30		; 8-bit A, X, and Y

org $C20CB0
JMP New_Formula

org $C2A770
New_Formula:
LDA $11A4
LSR
BCS Old_Var		; If this is a healing spell, use the old variance formula
CPY #$08
BCS Old_Var		; If the target is an enemy, use the old variance formula
PHP
TDC
LDA $11A2		; Special byte 1
LSR				; If it's a physical attack, the carry will be set
LDA $3B40,Y		; Load target's stamina
BCC Mag_Atk		; If it's a magical attack, branch
LDA $3B2C,Y		; Else, load target's vigor
LSR				; It's stored as vigor * 2, so cut it in half

Mag_Atk:
PHA				; Preserve A

; --- Start new variance formula ---
ASL
ADC $01,S
LSR
LSR				; (Vig/Stam * 3) / 4
; --- End new variance formula and start old ---
;ASL				; Double vig/stam
;LDX #$03
;JSR $4792		; (Vig/Stam * 2) / 3
; --- End old variance formula ---

STA $E8
LDA #$E1
SEC
SBC $E8			; 225 - (result from above)
STA $E8
PLA				; Pull unmolested vig/stam from stack
EOR #$FF		; 255 - A
SEC
SBC $E8			; A = variance cap - floor
BCC Cap_is_Floor; If the floor is larger than the cap, than the variance should be equal to the floor
INC
JSR $4B65		; Random number 0 to A - 1
CLC
ADC $E8			; Add back in the floor to get the random variance value
STA $E8

Cap_is_Floor:
REP #$20		; 16-bit A
LDA $F0			; Load up maximum damage
JSR $47B7		; Max damage * random variance; product stored in 24-bit $E8
LDA $E8
PHX
LDX #$E1
JSR $4792		; Bottom two bytes of result from above / 225
STA $F0
CLC
LDX $EA
BEQ Exit		; If $EA = 0, then the multiplication above didn't overflow, so exit

Loop:
LDA #$0123		; Otherwise, add 291 (65536 / 225) to the current damage result
ADC $F0
STA $F0
DEX
BNE Loop

Exit:
INC $F0
PLX
PLP
JMP $0CBA

Old_Var:
JSR $4B5A
JMP $0CB3

; EOF
