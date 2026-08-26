hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Further manipulates Setzer's slots, while de-rigging them
; Moves the pointer for Joker Doom's animation
; Removes the possibility of 7-7-Bar slot result
; Detaches Jackpot from Dispatch to correct targeting
; All locations have only been tested in FF3US ROM version 1.0

; De-rigs the slots
org $C1806D
BRA Skip_R2_Rig

org $C18089
Skip_R2_Rig:

org $C180A6
BRA Skip_R3_Rig

org $C180D7
Skip_R3_Rig:

; Disables 7-7-Bar results
org $C2B4AF		; 12 bytes freed up at $C2B4B2
LDA #$07
RTL

; Detaches Joker Doom (now Jackpot) from Dispatch's spell slot
org $C2172C
BRA Cont

org $C21734
Cont:

org $C236D2
DB $87,$36

org $C24DBF
BRA No_JD

org $C24DD2
No_JD:

org $C24E4A
DB $97,$97		; More Joker Doom pointers

; Adds Odin and Raiden to Bar-Bar-Bar results, and removes Phoenix
org $C237DC
LDA #$1A
JSR $4B65
CLC
ADC #$36
RTS

; Sets the layout of the reels.
org $C2A800

; 00 00 = 7
; 01 00 = Bahamut
; 02 00 = Bar
; 03 00 = Blackjack
; 04 00 = Chocobo
; 05 00 = Diamond

; Reel 1
DB $00,$00
DB $02,$00
DB $04,$00
DB $04,$00
DB $04,$00
DB $02,$00
DB $02,$00
DB $05,$00
DB $05,$00
DB $05,$00
DB $02,$00
DB $02,$00
DB $03,$00
DB $03,$00
DB $03,$00
DB $02,$00

; Reel 2
DB $00,$00
DB $02,$00
DB $03,$00
DB $03,$00
DB $03,$00
DB $02,$00
DB $02,$00
DB $04,$00
DB $04,$00
DB $04,$00
DB $02,$00
DB $02,$00
DB $05,$00
DB $05,$00
DB $05,$00
DB $02,$00

; Reel 3
DB $00,$00
DB $02,$00
DB $05,$00
DB $05,$00
DB $05,$00
DB $02,$00
DB $02,$00
DB $03,$00
DB $03,$00
DB $03,$00
DB $02,$00
DB $02,$00
DB $04,$00
DB $04,$00
DB $04,$00
DB $02,$00

; EOF
