hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters the fuck out of esper bonuses
; Shifts around the checks for learning skills at level up (Celes, Terra, Cyan, Sabin)
; as well as the actual SwdTech and Blitz learning code to make room for the bonuses
; Introduces an alternate leveling system, using "esper points" to gain esper bonuses
; Creates a "bank" of magic points that allows players to "buy" spells

; Need to revisit the "Add_EP" label and see if it can be jumped to from elsewhere, to
; free up two bytes of SRAM

; HP+60					0
; MP+40					2
; HP+30/MP+15			4
; Vgr+1/HP+15			6
; Mag+1/MP+20			8
; Vgr+1/Spd+1			10
; Mag+1/Spd+1			12
; Vgr+1/Stam+1			14
; Mag+1/Stam+1			16
; Spd+1/Stam+1			18
; HP+30/Stam+1			20
; MP+25/Stam+1			22
; Vigor +2				24
; Speed +2				26
; Stamina +2			28
; Magic +2				30
; Empty					32

; Esper bonus pointer table - completely re-written

org $C2614E
DW HP_60		; HP +60
DW MP_40		; MP +40
DW HP_MP_Dual	; HP +30/MP +15
DW Vig_Dual		; Vigor +1/HP +20
DW Mag_Dual		; Magic +1/MP +20
DW Vig_Dual		; Vigor +1/Speed +1
DW Mag_Dual		; Magic +1/Speed +1
DW Vig_Dual		; Vigor +1/Stamina +1
DW Mag_Dual		; Magic +1/Stamina +1
DW Spd_Stam		; Speed +1/Stamina +1
DW HP_Stam		; HP +30/Stamina +1
DW MP_Stam		; MP +25/Stamina +1
DW Vig_Boost	; Vigor +2
DW Spd_Boost	; Speed +2
DW Sta_Boost	; Stamina +2
DW Mag_Boost	; Magic +2
DW End			; Free space

; HP/MP boosts

MP_15:
LDA #$0F
BRA MP_Prep

MP_20:
LDA #$14
BRA MP_Prep

MP_25:
LDA #$19
BRA MP_Prep

MP_40:
LDA #$28

MP_Prep:
INY
INY
INY
INY
BRA HPMP_Boost

HP_20:
LDA #$14
BRA HPMP_Boost

HP_30:
LDA #$1E
BRA HPMP_Boost

HP_60:
LDA #$3C

HPMP_Boost:
CLC
ADC $160B,Y
STA $160B,Y
TDC
ADC $160C,Y
STA $160C,Y

End:
RTS

; Dual bonuses

HP_MP_Dual:
PHY
JSR HP_30
PLY
JMP MP_15

Mag_Dual:
PHY				; Preserve Y, since it will get molested when boosting magic
JSR Mag_Boost
PLY				; Restore Y for potential future stat boosts
BRA Skip_Vig

Spd_Stam:
PHY				; Preserve Y, since it will get molested when boosting speed
JSR Spd_Boost
PLY				; Restore Y for potential future stat boosts
BRA Sta_Boost

Vig_Dual:
JSR Vig_Boost	; No need to preserve Y, as a vigor boost won't modify it

Skip_Vig:
CPX #$0008
BCC HP_20		; If X < 8, we're boosting HP +20 along with vigor
BEQ MP_20		; If X = 8, we're boosting MP +20 along with magic
CPX #$000E
BCC Spd_Boost	; If 8 < X < 14, we're boosting speed along with vigor/magic
BRA Sta_Boost	; Else, we're boosting stamina along with vigor/magic/HP/MP

HP_Stam:
PHY
JSR HP_30
PLY
BRA Sta_Boost

MP_Stam:
PHY
JSR MP_25
PLY
BRA Sta_Boost

; Stat bonus

Mag_Boost:
INY				; 3 INYs = boost magic power
Sta_Boost:
INY				; 2 INYs = boost stamina
Spd_Boost:
INY				; 1 INY = boost speed
Vig_Boost:		; 0 INYs = boost vigor
LDA $161A,Y		; Stat to raise, based on Y
INC
CPX #$0017		; If X > 22, we're boosting a single stat, which will be +2
BCC Store_Stat	; Otherwise, we're doing a dual stat bonus, which is +1
INC

Store_Stat:
CMP #$81		; If the stat is greater than 128, set it equal to 128
BCC Update_Stat
LDA #$80

Update_Stat:
STA $161A,Y		; Save updated stat
RTS

;;;;;;;; Displaced Code;;;;;;;;;;;;;;;;;;;;;;;;;
; The following code was overwritten by the new esper bonuses and had to be moved

; Checking to see if a new skill is learned at level

org $C260BC
JSR Level_Chk

org $C26659
Level_Chk:
LDX #$0000		; Beginning of Terra's magic learned at level up block
CMP #$00
BEQ Learn_Magic	; If Terra leveled, branch to see if she learns any spells
LDX #$0020		; Beginning of Celes' magic learned at level up block
CMP #$06
BEQ Learn_Magic	; If Celes leveled, branch to see if she learns any spells
LDX #$0000		; Beginning of Cyan's SwdTech learned at level up block
CMP #$02		; If Cyan leveled, check for any new SwdTechs
BNE Sabin		; Else, check for any new Blitzes for Sabin

; Cyan learning SwdTechs at level up

JSR $6222		; Are any SwdTechs learned at the current level?
BEQ Exit		; If not, exit
TSB $1CF7		; If so, enable the newly learnt SwdTech
BNE Exit		; If it was already enabled (finished the nightmare), exit
LDA #$40
TSB $F0
BNE Exit
LDA #$42
JMP $5FD4

; Sabin learning Blitzes at level up

Sabin:
LDX #$0008		; Beginning of Sabin's Blitzes learned at level up block
CMP #$05		; If Sabin leveled, check for any new Blitzes
BNE Exit		; If not, exit
JSR $6222		; Are any Blitzes learned at the current level?
BEQ Exit		; If not, exit
TSB $1D28		; If so, enable the newly learnt Blitz
BNE Exit		; If it was already enabled (Bum Rush), exit
LDA #$80
TSB $F0
BNE Exit
LDA #$33
JMP $5FD4

Learn_Magic:
JMP $61FC

Exit:
RTS

; Creating EP and esper bank systems
; EP will be stored in SRAM locations $1CF8 - $1D0F (2 bytes per character)
; EL will be stored in SRAM locations $1D10 - $1D1B (1 byte per character)
; Unspent EL will be stored in SRAM locations $1D1C - $1D27 (1 byte per character)
; SP will be stored in SRAM locations $1E1D - $1E28 (1 byte per character)

org $C0BDE2		; Initializes EP and EL SRAM variables, as well as Think's RNG seed
NOP
INC $01F1
LDX $00

EP_Loop:
STZ $1CF8,X
INX
CPX #$0030
BNE EP_Loop

org $C0BE03		; Initializes SP SRAM variables, and the set of variables after them for
CPX #$0077		; future expansion

org $C26236
JSR Add_EP		; Interrupts leveling routine to calculate EP
NOP
NOP

; Removes learning spells from post-combat routine
org $C25E6A
BRA No_Spells

org $C25E72
No_Spells:

; Makes EP and EL gains display after combat
org $C25E0B
JSR Show_EP

org $C25EAC
JSR Show_EL

org $C25E79		; The instruction here would seem to prevent the game from ever displaying
NOP				; magic point gains after battle, but that's clearly not the case in
NOP				; vanilla. For now, they're NOP'd until I can determine their function.

org $C2A674
Calc_EP:
PHP
SEP #$20
LDA $FB			; Spell points gained
STA $E8
BEQ Zero_SP		; Branch if the formation gives zero SP
REP #$20		; Set 16-bit A
LDA $2F35		; XP gained from battle
LSR
LSR
LSR				; XP gained / 8
JSR $47B7		; $E8 = 16-bit A * 8-bit $E8

Zero_SP:
PLP
RTS

Add_EP:
PHP
SEP #$20		; Set 8-bit A
LDA $161E,X
BMI No_EP		; If character has no esper equipped, prevent EP gain
TDC
LDA $3ED8,Y		; Load character index (00 = Terra, 01 = Locke, etc.)
PHY				; Preserve Y
TAY				; Y = character index
LDA $FB			; Spell points gained
CLC
ADC $1E1D,Y		; Add spell points gained to current SP bank
CMP #$1E
BCC No_SP_Cap	; If it's less than 30, branch
LDA #$1E		; Otherwise we're capped, so set SP banked to 30

No_SP_Cap:
STA $1E1D,Y
TYA				; A = character index again
ASL
TAY				; X = character index * 2
JSR Calc_EP
REP #$20
LDA $E8			; A = (XP gained / 8) * spell points gained
CLC
ADC $1CF8,Y
CMP #$C350
BCC No_EP_Cap
LDA #$C350

No_EP_Cap:
STA $1CF8,Y
PLY				; Restore Y

No_EP:
PLP
REP #$21
LDA $2F35		; Displaced code from JSR above
RTS

; C2/657E
Show_EL:
JSR $606D		; Displaced code from JSR above
PHP
PHX
PHY
TDC
SEP #$20		; Set 8-bit A
LDA #$2E
STA $F2

MultiLvlChk:
LDA $3ED8,Y		; Load character index (00 = Terra, 01 = Locke, etc.)
CMP #$0C
BCS No_Esper_Lvl; If the character is Gogo, no reason to do this, so exit
TAY
LDA $1D10,Y		; Load character esper level
CMP #$19
BCS No_Esper_Lvl; If esper level is >= 25, it's capped, so exit function
ASL
TAX
PHY				; Push character index (00 = Terra, 01 = Locke, etc.) to stack
TYA
ASL
TAY				; X = character index * 2
REP #$20		; Set 16-bit A
LDA $1CF8,Y		; Load character's total EP
CMP $ED8BCA,X	; Has the character gained enough EP to level?
PLX				; Pull character index (00 = Terra, 01 = Locke, etc.) from stack
BCC No_Esper_Lvl
INC $1D10,X		; EL + 1
INC $1D1C,X		; Available EL + 1
LDA $01,S
TAY
;REP #$10		; Set 16-bit X & Y
SEP #$20		; Set 8-bit A
;LDX $3010,Y		; Load offset to character info block
LDA $F2			; Variable used specifically to determine if "EL gained" message had been shown yet
BEQ Skip_Display
STZ $F2
LDA #$46
JSR $5FD4

Skip_Display:
;JSR Do_Esper_Lvl
BRA MultiLvlChk	; Check for multiple EL gains in one battle

No_Esper_Lvl:
PLY
PLX
PLP
RTS

Show_EP:
JSR $5FD4		; Displaced code from above
LDA $F1			; Will have bit 3 set if espers have been acquired
BEQ No_EP_Gain	; If it's not set, then no EP can be gained
JSR Calc_EP
LDA $E8			; A = EP gained
BEQ No_EP_Gain	; If it's zero, exit
LDA $2F35
PHA
LDA $2F37
PHA				; Preserve XP gained for later calculations
STZ $2F37
STZ $2F36		; Zero top two bytes of former XP display
LDA $E8
STA $2F35		; Store EP gained in former XP location to display later
LDA #$0045		; Text index pointer
JSR $5FD4
PLA
STA $2F37
PLA
STA $2F35		; Restore XP gained

No_EP_Gain:
;LDY #$0006		; Displaced code from above
RTS

; XP gain displayed at C2/5E0B (stored at $2F35 - 3 bytes)
; EP gain text at D1/F4F4 (XP at D1/F2B1) ($45 text location)
; SP gain displayed at C2/5E8C (stored at $FB - 1 byte)
; Lv gain displayed at C2/5EAC
; EL gain text ($46 text location)
; Item gain displayed at C2/5F72
; GP gain displayed at C2/5F97

; Esper level experience chart
org $ED8BCA
DB $20,$00		; Level 1 = 32
DB $40,$00		; Level 2 = 64
DB $C0,$00		; Level 3 = 192
DB $80,$01		; Level 4 = 384
DB $80,$02		; Level 5 = 640
DB $00,$04		; Level 6 = 1024
DB $00,$06		; Level 7 = 1536
DB $80,$08		; Level 8 = 2176
DB $80,$0B		; Level 9 = 2944
DB $00,$0F		; Level 10 = 3840
DB $00,$17		; Level 11 = 5888
DB $00,$1B		; Level 12 = 6912
DB $00,$20		; Level 13 = 8192
DB $00,$26		; Level 14 = 9728
DB $00,$2D		; Level 15 = 11520
DB $00,$35		; Level 16 = 13568
DB $00,$3E		; Level 17 = 15872
DB $00,$48		; Level 18 = 18432
DB $00,$53		; Level 19 = 21248
DB $00,$5F		; Level 20 = 24320
DB $00,$77		; Level 21 = 30464
DB $00,$85		; Level 22 = 34048
DB $00,$95		; Level 23 = 38144
DB $00,$A7		; Level 24 = 42752
DB $00,$BB		; Level 25 = 47872

; 16-bit divided by 16-bit - $B8F3

; Re-arranging level up function to separate levels from esper bonuses
org $C260DD
REP #$21		; Set 16-bit A, clear carry
LDA $160B,X		; Max HP
PHA
AND #$C000		; Isolate bits for HP boosts from gear
STA $EE
PLA				; Max HP again
AND #$3FFF		; Isolate max HP without equipment boosts
ADC $FC			; Add to HP gain for leveling
CMP #$2710
BCC $03			; Branch if new HP value is less than 10000
LDA #$270F		; Otherwise, set it to 9999
ORA $EE			; Combine with HP boosts from gear
STA $160B,X		; New max HP
CLC
LDA $160F,X		; Max MP
PHA
AND #$C000		; Isolate bits for MP boosts from gear
STA $EE
PLA				; Max MP again
AND #$3FFF		; Isolate max MP without equipment boosts
ADC $FE			; Add to MP gain for leveling
CMP #$03E8
BCC $03			; Branch if new MP value is less than 1000
LDA #$03E7		; Otherwise, set it to 999
ORA $EE			; Combine with MP boosts from gear
STA $160F,X		; New max MP
PLP
RTS

; Esper bonuses
Do_Esper_Lvl:
LDA #$25
XBA
TXA
LDX $4216		; Get start of esper info block
JSR $4781		; Character ID * 37
TAY
TDC
LDA $D86E0A,X	; Get esper bonus index
ASL
TAX				; X = bonus index * 2
JSR ($614E,X)	; Calculate bonus
RTL

; Modifies the esper menus to function properly as a bank

org $C35CE2
DB $31,$44,$FF,$FF,$92,$8F,$FF,$00						; "SP"
DB $25,$44,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00	; Blank text space, if needed

org $C359AC
JSR Blue_Bank_Txt

org $C358DB
JMP Pressed_A
NOP

org $C35B26
JSR No_Spell_In_Slot

org $C3F739
Blue_Bank_Txt:
LDA #$24
STA $29			; Set text color to blue
JSR $02F9		; Display "SP" in blue text
LDA #$20
STA $29			; Set text color to white
LDX $67
TDC
LDA $0000,X		; Get character's sprite set - doubles as the character ID
TAY
LDA $1E1D,Y		; Get character's banked SP
JSR $04E0		; Convert to displayable digits
LDX #$443B
JMP $04B6		; Write banked SP to screen

Finish_Esper_Txt:
LDA #$8F
STA $2180
LDA #$FF
STA $2180
STA $2180
STA $2180
LDA $AA
LSR
BCC Unknown_Spell
LDA #$CF
BRA Known_Spell

Unknown_Spell:
LDA #$FF

Known_Spell:
STA $2180
STZ $2180
JMP $7FD9

Learn_Chk:
STZ $AA
LDA $E0			; SP cost of the spell
PHA				; Preserve it, because C3/50A2 mutilates $E0
JSR Chk_Esper_Eq; Check if the current esper can be equipped
LDA $29
CMP #$28		; If not, text color will be gray. Branch.
BEQ Set_Txt_Color
LDA $E1			; Otherwise, check if the character knows the current spell
JSR $50A2
BEQ Not_Learned	; If it's 0, then the spell has not been learned. So branch
INC $AA			; Else, set a flag so a check mark will be written to indicate it has been learned.

Not_Learned:
LDA #$20		; Otherwise, turn it white

Set_Txt_Color:
STA $29
PLA				; A = SP cost of the spell
RTS

Pressed_A:
LDA $4B			; Pointer index
BNE Chk_Spell	; If not zero, you're pointing at something we need to work with. So branch
JMP $C358DF		; Otherwise you're pointing at the esper, so check if it can be equipped

Chk_Spell:
LDA $99			; Load esper ID
STA $4202
JSR ChkEsp
TDC
LDA $29
CMP #$28		; If text color is grey, the bonus and all spells are off limits, so Bzzt them all.
BEQ Bzzt_Player
LDA #$0B		; 11
STA $4203
LDA $4B			; Load pointer index again
CMP #$06		; If the pointer index is 6, we're looking at the esper bonus,
BEQ Apply_Bonus	; so branch
DEC
ASL				; ($4B - 1) * 2 - more indexing purposes
CLC
;NOP				; One more cycle needed to finish multiplication above
REP #$20
ADC $4216
STA $A5
TAX
SEP #$20
LDA $D86E01,X	; Load spell ID the pointer is currently on
STA $E0
CMP #$FF		; If it's #$FF, then there's no spell in that slot, so exit
BEQ No_Spell_Slot
JSR $50A2		; Otherwise, check to see if the character has already learned it
BNE Bzzt_Player	; If known, branch. Otherwise, check to see if they have the banked SP necessary to buy it
LDX $A5
TDC
LDA $D86E00,X	; SP cost of the spell in question
STA $A4			; Scratchpad location
LDX $67			; Start of character info block
LDA $0000,X		; Get character's sprite set - doubles as the character ID
TAX
STA $4202
LDA $1E1D,X		; Character's banked SP
SEC
SBC $A4
BCC Bzzt_Player	; If the character has insufficient SP, branch
STA $1E1D,X		; Otherwise, learn the spell
LDA #$36
STA $4203
JSR $0ECE		; Makes "cha-ching" sound as if buying something
TDC
LDA $E0
REP #$20
CLC
ADC $4216		; $4216 = $4202 * $4203
TAX
SEP #$20
LDA #$FF
STA $1A6E,X
JMP $5913		; Exits back out to the general esper menu

Bzzt_Player:
JMP $0EC0		; Bzzt

Chk_Esper_Eq:
STA $4203		; Displaced from JSR above
LDA $99
JSR ChkEsp
LDA $29
CMP #$2C
BNE Draw_Spells
LDA #$20

Draw_Spells:
No_Spell_Slot:	; From separate function above
RTS

No_Spell_In_Slot:
LDX #$B492
STX $2181
LDA #$FF
STA $2180
STZ $2180
JMP $7FD9

Apply_Bonus:	; F834
LDX $67			; Start of character info block
LDA $0000,X		; Get character's sprite set - doubles as the character ID
TAX
LDA $1D1C,X		; Get character's available esper levels
BEQ Bzzt_Player	; If they have none, Bzzt the player
DEC $1D1C,X		; Otherwise, remove one from the available esper levels and grant the bonus
JSL Do_Esper_Lvl
JSR $0ECE		; Makes "cha-ching" sound as if buying something
JSR $4EED		; Updates the HP/MP on the status screen
JMP $5913		; Exits back out to the general esper menu

org $C311AD
NOP				; Removes an infinite loop that existed for some reason
NOP

org $C3F097
ChkEsp:			; Label only for ease of use above. Actual function in restrict_espers.asm

org $C35A84
JMP $7FD9		; Bypasses the function that writes spell progress to the esper screen

; Re-formats the esper screen to properly display SP cost
org $C35AFF
LDA #$FF
STA $2180
STA $2180
JSR Learn_Chk
JSR $04E0		; Turns A into displayable digits
LDA $F8
STA $2180
LDA $F9
STA $2180
LDA #$FF
STA $2180
LDA #$92
STA $2180
JMP Finish_Esper_Txt	; Above

;;;;;;;;;;; Everything below this is menu alterations for the EP/EL system

; Removes the spell learned display from the extended equipment screen
org $C38743
RTS

; Modifies the status screen to display EP and esper level to the player
; Changes total exp display to exp to next level
org $C36068
JSR $60A0		; Get experience needed to level
JSR $0582		; Format it into displayable digits, dropping leading zeroes
LDX #$7CD7		; Y,X screen position
JSR $04A3		; Write experience needed to status screen
JSR EL_Status
JSR Calc_EP_Status
BCC No_EP_Disp	; Skip displaying EP to level if the party has yet to meet Ramuh
JSR $0582
LDX #$7DD7
JSR $04A3

No_EP_Disp:
STZ $47
JSR $11B0
JMP $625B

; If espers have been acquired, writes character's esper level after level display
org $C30C81
JSR Esp_Lvl

org $C33303		; Main menu, character 1
JSR EL_Main_1

org $C3334F		; Main menu, character 2
JSR EL_Main_2

org $C3339B		; Main menu, character 3
JSR EL_Main_3

org $C333E7		; Main menu, character 4
JSR EL_Main_4

org $C34EEA		; Skill screen
JSR EL_Skill

;org $C36068	; Status screen - documentation purposes only. Actual jump made above (C3/6068)
;JSR EL_Status

org $C3797D		; Party select screen
JSR EL_Party

org $C35A3B
JSR Unspent_EL

; Changes "Your Exp:" to "Exp to lv. up:"
; And "For level up:" to "EP to lv. up:"
;org $C3646D
;DB $77,$F2
; Commented out because it doesn't appear to be necessary, but kept here just in case.

org $C36511
DB $4D,$7C,$84,$B1,$A9,$FF,$AD,$A8,$FF,$A5,$AF,$C5,$FF,$AE,$A9,$C1,$00

org $C3F277 ; originally F5B5
DB $4D,$7D,$84,$8F,$FF,$AD,$A8,$FF,$A5,$AF,$C5,$FF,$AE,$A9,$C1,$00
DB $4D,$7D,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00	; Blanks for Gogo+ characters
DB $DD,$7D,$FF,$FF,$FF,$FF,$FF,$00									; Blanks EP to level for Gogo+ characters

; Many instances of displaying the "EL" text
DB $AB,$39,$84,$8B,$00,$FF,$FF,$FF	; Three bytes of buffer space for indexing purposes
DB $2B,$3B,$84,$8B,$00,$FF,$FF,$FF	; Need to revisit this later
DB $AB,$3C,$84,$8B,$00,$FF,$FF,$FF
DB $2B,$3E,$84,$8B,$00,$FF,$FF,$FF
DB $3B,$42,$84,$8B,$00,$FF,$FF,$FF
DB $2B,$3A,$84,$8B,$00,$FF,$FF,$FF
DB $7B,$3A,$84,$8B,$00,$FF,$FF,$FF

; Location and text of spaces for blanking out the "EL" text
DB $AB,$39,$FF,$FF,$FF,$FF,$FF,$00
DB $2B,$3B,$FF,$FF,$FF,$FF,$FF,$00
DB $AB,$3C,$FF,$FF,$FF,$FF,$FF,$00
DB $2B,$3E,$FF,$FF,$FF,$FF,$FF,$00
DB $3B,$42,$FF,$FF,$FF,$FF,$FF,$00
DB $2B,$3A,$FF,$FF,$FF,$FF,$FF,$00
DB $7B,$3A,$FF,$FF,$FF,$FF,$FF,$00

; Location and text for "Unspent EL:" text
DB $94,$A7,$AC,$A9,$9E,$A7,$AD,$FF,$84,$8B,$C1,$00

Calc_EP_Status:
LDA $1E8A
AND #$08		; Event bit for meeting Ramuh
BEQ No_Disp_EP	; If you've not done so, you have no espers. So don't display EP
LDX $67
LDA $0000,X		; Get character's sprite set - doubles as the character ID
CMP #$0C		; Is it Gogo or above?
BCC Disp_EP		; If not, branch and display EP

No_Disp_EP:
LDY #$F297		; Pointer for spaces to blank out EP to next level display
JSR $02F9
LDY #$F287		; Pointer for spaces to blank out "EP to lv. up:" text display
JSR $02F9
CLC
RTS

Disp_EP:
PHA				; Preserve A
LDA #$2C
STA $29			; Make text blue
LDY #$F277		; Pointer for "EP to lv. up:" text display, to show it if browsing status windows
JSR $02F9
TDC
LDA #$20
STA $29			; Set text color to white
PLA				; Restore A
TAY
LDA $1D10,Y		; Load character's esper level
CMP #$19
BNE Not_Capped	; If esper level is not 25, calculate how much EP to next level
SEC
JMP $60C3		; Else, set display to zero and exit function

Not_Capped:
ASL
TAX				; Double esper level for indexing purposes and move it to X
TYA
ASL
TAY				; Y now holds character ID * 2
REP #$30
LDA $1CF8,Y		; Character's total EP
STA $F1
LDA $ED8BCA,X	; EP needed for next level
SEC
SBC $F1			; (EP to next level - total EP)
STA $F1
SEP #$20
SEC
RTS

Esp_Lvl:
JSR $04B6		; Displaced code from above
JSR Ramuh_Chk
BEQ Return		; If you've not met Ramuh, exit
JSR Char_Chk
BCS Return		; If the character is Gogo or above, exit
TAY
LDA $1D10,Y		; Load character's esper level
JSR $04E0		; Truncate any leading zeroes
REP #$20
LDA [$EF]		; Tilemap position for level display
CLC
ADC #$000C		; Move X position for esper level display
TAX
SEP #$20
JMP $04B6		; Write esper level to screen

Return:
RTS

Ramuh_Chk:
TDC
LDA $1E8A
AND #$08		; Event bit for meeting Ramuh
RTS

Char_Chk:
LDX $67
TDC
LDA $0000,X		; Get character's sprite set - doubles as the character ID
CMP #$0C		; Is it Gogo or above?
RTS

EL_Main_1:
LDA #$00		; Offset for EL
PHA
BRA Write_Text

EL_Main_2:
LDA #$08		; Offset for EL
PHA
BRA Write_Text

EL_Main_3:
LDA #$10		; Offset for EL
PHA
BRA Write_Text

EL_Main_4:
LDA #$18		; Offset for EL
PHA
BRA Write_Text

EL_Skill:
LDA #$24
STA $29			; Set text color to blue
LDA #$20		; Offset for EL
PHA
BRA Stat_Skill_Ent

EL_Status:
LDA #$24
STA $29			; Set text color to blue
LDA #$28		; Offset for EL
PHA
BRA Stat_Skill_Ent

EL_Party:
LDA #$30		; Offset for EL
PHA

Write_Text:
JSR $69BA

Stat_Skill_Ent:
JSR Ramuh_Chk
BEQ No_Ramuh	; Branch if the player has yet to meet Ramuh
JSR Char_Chk
PLA
PHP
REP #$20
BCS Gogo		; Branch if the character is Gogo or above
ADC #$F29F		; Added to offset to get EL
BRA Write_EL

No_Ramuh:
PLA
PHP
REP #$20

Gogo:
CLC
ADC #$F2D7		; Added to offset to get blanks to overwrite EL

Write_EL:
TAY
PLP
JMP $02F9

; Adds "Unspent EL" display under the esper bonuses
Unspent_EL:
LDA #$24
STA $29			; Set text color to blue
LDY #$4795
JSR $3519
LDX $00

Write_UEL:
LDA $C3F30F,X	; Get "Unspent EL:" text
BEQ End_UEL_String; If null, end string
STA $2180
INX
BRA Write_UEL	; Loop if we're not done writing the text

End_UEL_String:
STZ $2180
JSR $7FD9
LDA #$20
STA $29			; Set text color to white
JSR Char_Chk	; Get current character's ID
TAY
LDA $1D1C,Y		; Get available ELs for character to spend
JSR $04E0		; Truncate leading zeroes and format it in displayable digits
LDY #$47AD
JSR $3519
LDA $F8
STA $2180		; Write tens digit
LDA $F9
STA $2180		; Write ones digit
STZ $2180		; End this string
JSR $7FD9
LDY #$4713		; Displaced from JSR way above
RTS

; Changing the position of the level display to make room for EL display.
org $C3332D
DB $A5,$39

org $C33379
DB $25,$3B

org $C333C5
DB $A5,$3C

org $C33411
DB $25,$3E

org $C34F12
DB $35,$42

org $C36096
DB $25,$3A

org $C379E6
DB $75,$3A

; EOF
