hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Alters Imp to simply be a 50% damage output nerf

; The following simply bypasses several points where commands get greyed out if the
; active character is Imped.
; Changes a spell pointer to SOS: Safe doesn't become SOS: Imp
; Changes the spell pointer for float
; Note that a lot of the original code has been re-written by brushless_sketch.ips, so
; the following offsets may be relative to that.

org $C202A0
PLA
RTS

; 58 bytes of free space starting at C2/02A2

org $C252B0
BRA Skip2

org $C252BA
Skip2:

org $C2101C
BRA Skip3

org $C21031
Skip3:

;org $C229BB		; This jump now handled in blind.asm, as the entire function was re-written.
;BRA Skip4			; Kept here for documentation purposes.

;org $C229C2
;Skip4:

;org $C22A29		; This jump now handled in blind.asm, as the entire function was re-written.
;BRA Skip5			; Kept here for documentation purposes.

;org $C22A36
;Skip5:

org $C2320D
BRA Skip6

org $C23225
Skip6:

org $C233EA
BRA Skip7

org $C233F2
Skip7:

org $C257B0
BRA Skip8

org $C257BB
Skip8:

org $C245E2
JMP $464C

; Allows Imp to be used outside of battle

org $C32C36
CMP #$1F

;org $C35197
;CMP #$1C

org $C3518D
BRA No_Imp

org $C3519B
No_Imp:

; The following applies the 50% damage output nerf

org $C233A3		; Arbitrarily-chosen entry point
JSR Imp_Nerf

org $C241E6
Imp_Nerf:
LDA $B5
CMP #$01
BEQ Exit		; If command is Item, exit
LDA $3EE4,X		; Status byte 1
BIT #$20
BEQ Exit		; If not Imp'd, branch
LSR $11B1
ROR $11B0		; Else, cut damage output in half

Exit:
JMP $14AD		; Displaced code from JSR above

; Changes the spell pointer for SOS: Shell

org $C20A6A
LDA #$23

; Changes the spell pointer for SOS: Safe

org $C20A78
LDA #$22

; Changes the spell pointer for Float so it can be used outside of battle

org $C32C32
CMP #$29

; EOF
