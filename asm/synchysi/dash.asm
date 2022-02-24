hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Allows dashing if the B button is held down
; Original hack by Master ZED
; Modified by Synchysi to consider events where sprinting is disabled
; Further modified by Synchysi to have B-Button walk/run toggled on the config screen

org $C04E28
JSR Dash
NOP
NOP
BCC No_Dash		; If carry is clear, don't dash

org $C04E33
No_Dash:

org $C04A67
Dash:
LDA $4219		; Load second byte for controller 1
ROL				; Place highest bit in carry
LDA $1D4E		; Load B Button dash/walk setting
BIT #$10
BEQ B_Dash		; If B Button Dash is selected, branch
BCC B_Walk_Run	; Else, check if we're pressing the B button
CLC				; If we are, we should be walking, so clear the carry
RTS

B_Walk_Run:
SEC				; If not, we should be dashing, so set the carry

B_Dash:
RTS

org $C34959
DB $25,$3D
DB $83,$9A,$AC,$A1,$00,$00,$00	; "Dash" text

; Moving some data around to make room for "B Button"
org $C349E7
DB $0F,$3D
DB $81,$FF,$81,$AE,$AD,$AD,$A8,$A7,$00	; "B Button" text
DB $E5,$39,$8E,$9F,$9F,$00,$00,$00,$00	; "Off" (formerly "Active"; see no_exp_option.asm)
DB $25,$3B,$96,$A2,$A7,$9D,$A8,$B0,$00
DB $A5,$3C,$91,$9E,$AC,$9E,$AD,$00
DB $35,$3D,$96,$9A,$A5,$A4,$00			; "Walk" text

; Redirecting some pointers to fit the new text locations above
org $C33BA7
LDY #$49F2

org $C33C55
LDY #$49FB

org $C33CCB
LDY #$4A04

org $C33CFF
LDY #$4A0C

; EOF