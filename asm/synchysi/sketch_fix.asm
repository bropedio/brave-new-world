hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Alters Sketch to use the attacker's stats rather than the target's
; All locations have only been tested in FF3US ROM version 1.0

org $C22C25
JSR SketchFixMag		; Interrupting a check to look for a sketcher

;org $C229CE
;JSR SketchFixPhys		; Interrupting battle power loading to check for a sketcher
						; Actual jump handled in blind.asm, as that function was re-written

org $C26631
SketchFixMag:
BMI NoSketch1			; Branch if there is no sketcher
TAX						; If there's a valid sketcher, use their stats
LDA $11A2
LSR						; If it's a physical attack, carry will be set
LDA $3B41,X				; Get sketcher's magic power
BCC Mag_Atk
ASL						; Double magic power, since it effectively gets halved
						; for physical attacks
Mag_Atk:
STA $11AE				; Use sketcher's magic power in damage calculation

NoSketch1:
RTS

;SketchFixPhys:
BCS NoSketch2			; If the carry is set, it's either a special attack or an attack
						; with the left hand. Either way, branch.
SketchChk2:
LDA $3417				; Checking for a sketched attack yet again
BMI NoSketch2			; If not, exit
PHX						; Preserve X
TAX						; Use the sketcher as the attacker
LDA $3B68,X				; Load sketcher's battle power
PLX						; Restore X
BRA NoSketch1

NoSketch2:
CMP #$06				; If it's a special attack, A will be 06, which we still need to
BEQ SketchChk2			; use the Sketcher's stats for.
LDA $3B68,X				; Else, load up the attacker's battle power and move on.
RTS

; EOF
