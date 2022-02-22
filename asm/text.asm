hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Various menu and battle text edits.
; All locations have only been tested in FF3US ROM version 1.0

; Kept for documentation, but deprecated by dn's config menu patch

;org $C349A3
;DB $BB,$C5,$B9,$81,$C4,$9E

; 81=B
; 9C=c
; B4=0
; B5=1
; B6=2
; B7=3
; B8=4
; B9=5
; BA=6
; BB=7
; BC=8
; BD=9
; C4=-
; C5=.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Some of the below text is handled by dn's scan_status.ips patch

org $C35CF7
; At level up -> EL Bonus
DB $FF,$84,$8B,$FF,$81,$A8,$A7,$AE,$AC,$C1,$FF,$FF,$FF,$FF

;org $C2AE27
; Dark -> Blind
;DB $81,$A5,$A2,$A7,$9D

;org $C2AE3B
; Seizure -> Sap
;DB $92,$9A,$A9,$FF,$FF,$FF,$FF

;org $D1F4F4
; Got [$10] EP
;DB $86,$A8,$AD,$FF,$10,$FF,$84,$8F,$07,$00

; [$12] gained an EL
;DB $12,$00,$FF,$A0,$9A,$A2,$A7,$9E,$9D,$FF,$9A,$A7,$FF,$84,$8B,$07,$00

;org $D1F389
;DB $92,$A9,$9E,$A5,$A5		; "Spell" (instead of "Magic") [for magic points]

org $C33819
DB $86,$8F					; GP (instead of Gp)

org $D1F114
DB $9D,$9A,$AB,$A4			; Replace "poison" with "dark"
DB $FF,$FF,$00				; Padding the rest of the line

;org $D1F127					; Debilitator
;DB $A1,$A8,$A5,$B2			; Text for "holy"
;DB $FF,$A9,$A8,$B0
;DB $9E,$AB,$BE,$FF			; Filling out the rest of the line

;org $D1F1FE					; Scan
;DB $A1,$A8,$A5,$B2,$FF		; Text for "holy"

;org $D1F309					; "Can't probe target!"
;DB $8D,$A8,$FF				; "No " (including trailing space)
;DB $B0,$9E,$9A,$A4,$A7,$9E,$AC,$AC,$9E,$AC,$BE	; "weaknesses!"
;DB $FF,$FF,$FF,$FF,$FF		; Filling out the rest of the line with spaces

; Getting rid of all the double exclamation points.
; Handled by scan_status.ips now

org $D1F007
DB $FF

org $D1F02F
DB $FF

org $D1F04E
DB $FF

;org $D1F05C
;DB $FF

;org $D1F067
;DB $FF

;org $D1F07D
;DB $FF

;org $D1F08E
;DB $FF

;org $D1F09D
;DB $FF

;org $D1F18F
;DB $FF

;org $D1F256
;DB $FF

;org $D1F307
;DB $FF

;org $D1F486
;DB $FF

;org $D1F4AB
;DB $FF

; EOF