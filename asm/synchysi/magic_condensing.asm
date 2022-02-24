;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Condensed Spell Lists v1.5
; Author: Gray Shadows (in.the.afterlight@gmail.com
; Applies to Final Fantasy 3/6us v1.0
;
; Urgency: Low - QoL enhancement
;
; Contributors: assassin (code support and optimisation)
;               seibaby (testing and problem solving)
;               Warrax (testing and bug identification)
;
; In vanilla FF6, because of the way the game builds spell lists in
; battle, if one character in battle knows a lot of spells and another
; character doesn't, that second character will have a lot of blank
; space in their Magic menu. Condensed Spell Lists adds some additional
; code to battle initialisation that takes a character's spell list
; and 'shuffles' it up, so that all of the blank spots are at the end.
; It also resorts the Lore list in the same manner.
;
; Version 1.5 update includes: bugfixes, including an error introduced
; wherein monster abilities were incorrectly costing MP, as well as a
; fatal crashing error caused by Interceptor counter-attacks. The hack
; should now properly account for all abilities that use the Magic
; command but do not cast from a character's spell list. (This should
; only be Interceptor counter-attacks, and possibly Desperation Attacks.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hirom
header

print " "

!freespace_C2_0 = $C265CE        ; 77 bytes needed, used through $C2A6A6
!freespace_C2_1 = $C26770        ; 64 bytes needed, used through $C2FAEF

org $C2256D                
JSR condenseSpellLists
; This was originally a JSR to modify available commands; we'll be JMPing to
; that at the end of the modified code so that RTS comes back to the right spot.

org $C24F24
print "Replacement Function updated_4F08 starts at: ",pc
reset bytes

updated_4F08:
XBA                ; high byte now holds the command ID
REP #$10
LDA $3A7B            ; and low byte now holds spell/attack ID
CPX #$0008
BCS fka_4F47
XBA                ; high is spell, low is command
CMP #$19
BEQ .summon
JMP calculateMPDeduction
NOP

.summon
CLC
TDC
REP #$20

print "Replacement Function updated_4F08 ends at: ",pc," and used ",bytes," bytes of space."
print " "

org $C24F47
fka_4F47:

; This jumps in the middle of a function at C2/4F08 that grabs the MP cost for
; a spell. A character's individual spell list in battle stores a modified MP
; cost based on modifying relics, and as we're reshuffling the list, we need to
; add additional code to make sure that the game looks for MP costs in the right
; location.



                            
org !freespace_C2_0
print "New function CondenseSpellLists starts at: ",pc
reset bytes

condenseSpellLists:
PHX                ;
PHP
LDY #$04        ; The 0 index in the list holds the equipped esper, which we're not touching.
                ; Each entry is four bytes long, so the spell list starts at Y = 4.
.noMoreSpells    ; We'll be branching back here to execute our Lore list
TYX                ; X is going to be our 'write-space' index, whereas Y is our 'read-space' index.
REP #$10

    .checkSpellLoop
    LDA ($F2),Y
    INC
    BNE .checkNextSpell

        .findNextSpell
        INY #4
        CPY #$00DC            ; If we've hit the first Lore slot, there are no more spells to copy back,
        BEQ .noMoreSpells    ; so jump out, reset X to start sorting the Lore list instead.
        CPY #$013C            ; This is after the last Lore slot, so if we've gone that far, there are
        BEQ .noMoreLores    ; no more spells to copy back and we can exit the function entirely.
        LDA ($F2),Y
        INC
        BEQ .findNextSpell

    PHY            ; we'll be pushing and pulling within the loop, but we need to know
                ; where it started so we can blank out the slot we copied from
    CLC
    REP #$20
    
        .copyNextSpell
        LDA ($F2),Y    
        PHY            ; This stores our Y location, i.e. the next slot with a spell learned
        TXY            ; and pulls our X, or the blank slot we're writing to.
        STA ($F2),Y
        PLY            ; back to our 'write from' location
        INY    #2        ; and gets the next bytes
        INX #2
        BCS .doneCopy
        SEC
        BPL .copyNextSpell    ; if we haven't done four bytes, loop back and grab the next
        .doneCopy
        
    SEP #$20    
    PLY            ; this is the first byte of the slot we copied from
    TDC
    STA ($F4),Y    ; this zeroes out the MP cost
    DEC
    STA ($F2),Y    ; and blanks out the spell we copied from
        
    BRA .weCopiedASpell
    .checkNextSpell
    INX #4
    .weCopiedASpell
    TXY                ; and then copy it over to Y for our next loop through
    CPY #$0138
    BNE .checkSpellLoop
    
.noMoreLores
PLP    
PLX
JMP $532C

print "CondenseSpellLists ends at: ",pc," and used ",bytes," bytes of space."
print " "



org !freespace_C2_1
calculateMPDeduction:

print "New function CalculateMPDeduction starts at: ",pc
reset bytes

CMP #$0C                ; coming in, low byte is command and high byte is spell ID
BEQ .calculateLore        ; (branch if it's Lore)

.calculateMagic
XBA                        ; (get attack #), high byte is now command and low byte is attack ID
CMP #$F0                ; is it a Desperation Attack or an Interceptor counter?
BCS .returnZero            ; if so, exit
STA $F0                    ; save our spell ID in scratch memory
TDC
LDA #$04                ; four bytes per index, and we're starting at the second index in
                        ; the list (i.e. the first Magic spell)

.loreEntersHere
REP #$20
CLC
ADC $302C,X                 ; get the start of our character's magic list (index #0 is esper)
STA $F2                        ; this points out our first Magic slot
INC #3
STA $F4                        ; and this points at our first MP cost slot
SEP #$20
PHY
LDY $00

    .findSpell
    LDA ($F2),Y
    CMP $F0
    BEQ .getMPCost
    INY #4
    BRA .findSpell
    
.getMPCost
LDA ($F4),Y
PLY
BRA .exitWithMP

.calculateLore
XBA                            ; (get attack #), high byte is command and low byte is attack ID
SEC
SBC #$8B                    ; turn our raw spell ID into a 0-23 Lore ID
STA $F0
TDC
LDA #$DC                    ; this is our first Lore slot in the character's spell list
BRA .loreEntersHere

.returnZero
TDC
.exitWithMP
JMP $4F54            ; (clean up stack and exit)


print "CalculateMPDeduction ends at: ",pc," and used ",bytes," bytes of space."
print " "