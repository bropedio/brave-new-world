hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Disables the Optimize option in the menu
; All locations have only been tested in FF3US ROM version 1.0

org $C31C1D
NOP #3

org $C39685
NOP #3

; Bypasses all relic checks for optimizing - frees up a bunch of space in C3.
org $C39F5C
BRA End

org $C39FA9
End:

; The following is a hack written by assassin17 to fix the optimize routine to prevent the game form optimizing items into the wrong slot (i.e., dried meat in the off-hand)

; look for "FF6j = " throughout for FF6j patch differences.

; ------ Rest of function C3/96D2 until this point unchanged. ---------

org $C396E9
; FF6j = org $C39ED8

NOP
NOP
NOP            ; waste, begone!

; ----- Remainder of function unchanged. ------

; C3/96EC: 20 F0 96     JSR $96F0      (Optimum command - fully equips standard equipment)
; C3/96EF: 6B           RTL


; Optimum command

; ----- Everything up until next dotted line unchanged. ---------

; C3/96F0: 20 10 91     JSR $9110      (Checks equipment by jumping to C2/0E77)
; C3/96F3: 20 A8 96     JSR $96A8      (Empty command - Removes standard equipment)
; C3/96F6: 20 F2 93     JSR $93F2      (get character index)
; C3/96F9: 84 F3        STY $F3        (store character index)
; C3/96FB: AD D8 11     LDA $11D8
; C3/96FE: 29 08        AND #$08       (Check "attack with 2 hands" bit)
; C3/9700: F0 18        BEQ no_gaunt   (branch if not set)

; ----- My changes to this function start here. -------

org $C39702
; FF6j = org $C39EF1

NOP
NOP            ; here so the "JSR $983F" instruction isn't shifted, and
               ;  i don't need to take special steps to coexist with the
               ;  other "Equip Anything" fix.
JSR do_9B72    ; generate list of equippable Weapons and Shields.
               ;  98% sure it's pointless, given next instruction.

; --------- Everything until next dotted line unchanged. ------------

; C3/9707: 20 95 97     JSR $9795      (generate list of equippable Weapons)
; C3/970A: 20 50 A1     JSR $A150      (sort list of eligible weapons by Battle Power)
; C3/970D: 20 3F 98     JSR $983F      (pick best weapon that's compatible with Optimum,
;                                       and preferably supported by Gauntlet.)
; C3/9710: A4 F3        LDY $F3        (load character index)
; C3/9712: 99 1F 00     STA $001F,Y    (store to right hand)
; C3/9715: 20 97 9D     JSR $9D97      (Remove item from inventory)

; -------- Changes resume here. -------------

org $C39718
; FF6j = org $C39F07

BRA do_helmet  ; advance to the helmet slot
no_gaunt:
JSR wpn_common ; generate list of equippable Weapons and Shields,
               ;  generate list of equippable Weapons, sort list
               ;  of weapons by Battle Power, then pick the best
               ;  one that's compatible with Optimum
STA $001F,Y    ; store to right hand
JSR $9D97      ; Remove item from inventory
; FF6j = JSR $A5A5
LDA $11D8
AND #$10       ; Check "can equip a weapon in each hand" bit
BNE genji_glv  ; branch if set
JSR do_9B72    ; generate list of equippable Weapons and Shields.
               ;  98% sure it's pointless, given next instruction.
JSR $97D7      ; generate list of equippable Shields
; FF6j = JSR $9FC6
JSR common     ; sort list of shields by Defense, then pick the
               ;  best one that's compatible with Optimum
STA $0020,Y    ; store to left hand
JSR $9D97      ; Remove item from inventory
; FF6j = JSR $A5A5
BRA do_helmet  ; do the helmet slot now

               ; you are here only if you can equip a weapon in both hands

genji_glv:
JSR wpn_common ; generate list of equippable Weapons and Shields,
               ;  generate list of equippable Weapons, sort list
               ;  of weapons by Battle Power, then pick the best
               ;  one that's compatible with Optimum
STA $0020,Y    ; store to left hand
JSR $9D97      ; Remove item from inventory
; FF6j = JSR $A5A5
do_helmet:
JSR stuff_9B59 ; do early parts of Function C3/9B59
JSR $9BB2      ; generate list of equippable Helmets
; FF6j = JSR $A3A1
JSR common     ; sort list of helmets by Defense, then pick the
               ;  best one that's compatible with Optimum
STA $0021,Y    ; store to head
JSR $9D97      ; Remove item from inventory
; FF6j = JSR $A5A5
JSR stuff_9B59 ; do early parts of Function C3/9B59
JSR $9BEE      ; generate list of equippable Armors
; FF6j = JSR $A3DD
JSR common     ; sort list of armors by Defense, then pick the
               ;  best one that's compatible with Optimum
STA $0022,Y    ; store to body
JMP $9D97      ; Remove item from inventory
; FF6j = JMP $A5A5


wpn_common:
JSR do_9B72    ; generate list of equippable Weapons and Shields.
               ;  98% sure it's pointless, given next instruction.
JSR $9795      ; generate list of equippable Weapons
; FF6j = JSR $9F84
common:
JSR $A150      ; sort list of eligible gear by Battle Power or Defense
; FF6j = JSR $A95E
LDY $F3        ; load character index
JMP $9819      ; pick best gear that's compatible with Optimum,
               ;  loading from slot FFh as a fallback.
; FF6j = JMP $A008


stuff_9B59:
JSR $9C2A      ; Generate fallback list of 9 FFs, in case no
               ;  Optimum-compatible equipment is found
; FF6j = JSR $A419
JSR $9C41      ; Setup equippability word
; FF6j = JSR $A430
LDA #$20
STA $29        ; set text color to white.  99.5% sure it's pointless here,
               ;  but i'm just being thorough in replicating early C3/9B59.
RTS


do_9B72:
JSR stuff_9B59 ; do early parts of Function C3/9B59
JMP $9B72      ; generate list of equippable Weapons and Shields.
               ;  98% sure it's pointless, given caller's next instruction.
; FF6j = JMP $A361


NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP            ; 20 bytes to spare!  you stud!!


; EOF