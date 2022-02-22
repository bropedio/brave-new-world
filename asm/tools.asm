hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters four tools:
; Drill - sets seizure, and forces it to consider attacker's row
; Chainsaw - allows the "hockey mask" proc to still deal damage as normal, and forces it to consider attacker's row
; Debilitator - changed to Defibrillator; item ID 167 now points to spell ID 157
; Air Anchor - changed to Mana Battery; item ID 169 now points to spell ID 158
; Autocrossbow - upgrades the attack power if a certain event bit is set
; All locations have only been tested in FF3US ROM version 1.0

; Removes an instruction that clears "can target dead/hidden targets" from all magic-based tools and scrolls. This is mainly for the Defibrillator's benefit, though it could adversely affect the Mana Battery.

org $C218FF
NOP
NOP

; Tools pointer table
; Note: Tools that use spells for their effects don't need a hard-coded effect here.

org $C21211
Noiseblaster:
LDA #$10
STA $11A4						; Set "stamina can block"
ASL
STA $11AB						; Sets muddle in attack data
STZ $11A2
RTS

org $C22B2F						; Coming here just to make a label for the below jumps
Return:

org $C22B1A
DW Noiseblaster
DW Return						; Bio Blaster - RTS
DW Return						; Flash - RTS
DW Chainsaw1
DW Return						; Defibrillator - RTS (old Debilitator)
DW Drill
DW Return						; Mana Battery - RTS (old Air Anchor)
DW Autocrossbow

Chainsaw1:						; Start of old Noiseblaster effect.
JSR $4B5A						; RNG 0-255
AND #$03
BNE Drill_Saw					; 75% chance of no hockey mask (i.e., branch).
LDA #$08
STA $B6							; Hockey mask animation.
LDA #$AC
STA $11A9						; Stores special effect for later use.

Drill_Saw:						; C22B40 - Drill enters here from below.
LDA #$20
TSB $11A2						; Set ignore defense - drill and chainsaw.
LSR								; A = $10
TSB $11A7						; Set to consider attacker's row - drill and chainsaw
RTS

Drill:
LDA #$40
STA $11AB						; Allows the Drill to set seizure.
BRA Drill_Saw

Autocrossbow:
LDA #$40
TSB $11A2						; Set no split damage
LDA $1EBB						; Event byte (1D8 - 1DF) - Rare items
BIT #$10						; Event bit 1DC - used for schematics
BEQ Exit						; If it's clear, exit
LDA #$E1						; Else, set battle power to 225
STA $11A6
LDA #$FF						; And set hit rate to 100%
STA $11A8

Exit:
RTS

; New special effect code for the Chainsaw
org $C23E79
DW Chainsaw2

org $C22C09						; Former Debilitator code - special effect $56
Chainsaw2:
LDA $3AA1,Y
BIT #$04						; If the target is immune to instant death, exit function. The
BNE End							; Chainsaw will still deal normal damage in this case.
STZ $11A6						; Zero battle power - this is instant death, so no need for damage.
LDA #$80
ORA $3DD4,Y
STA $3DD4,Y						; Mark Death status to be set.
LDA #$10
STA $11A4						; Set stamina can block.

End:
RTS

org $C23C2F
Tool_Data_1:
DB $A4,$A5,$A7,$A9,$AB,$AC,$AD	; Data - filched from $C22778 to add two tools.
Tool_Data_2:
DB $27,$27,$0D,$0E,$5A,$5A,$5A	; Data - filched from $C2277D to add two tools.

org $C22708						; This is where items that use spells for their effects
LDX #$06						; are determined. We come here to alter the number of
CMP Tool_Data_1,X				; times the check is run to account for the two new tools,
BNE No_Item_Spell				; as well as use the new data table location.
SBC Tool_Data_2,X

org $C22716
No_Item_Spell:

; EOF