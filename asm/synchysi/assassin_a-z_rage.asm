hirom
header

; Written by assassin
; Modified by Synchysi for use with BNW

;(Generates alphabetical in-battle Rage menu.  Much like the original, enemies with
; undiscovered rages and enemy #255 are skipped entirely.  While it may seem harmless enough
; to just go and output the null entry for Pugs, this would lead to two bad things:

; - If you've found all 256 rages, the $3A9A counter overflows, which prevents the game
;   from being able to correctly choose a random Rage when a character's muddled.
; - The code that chooses a random Rage dislikes null entries in the middle of the list for
;   some reason, and will deliberately seek them out.  If you had a blank spot corresponding
;   to Pugs in an alphabetical list, nobody from Punisher onward would ever get selected,
;   with Guard [enemy #0] taking their place. )

org $C2580C
TDC
LDA $1CF7
JSR $520E			;(Number of bits set in $1CF7)
DEX 
STX $2020
TDC 
LDA $1D28
JSR $520E
STX $3A80
LDA $1D4C
STA $EE
LDX #$07

branch2:
ASL $EE
LDA #$FF
BCC branch1
TXA

branch1:
STA $267E,X
DEX 
BPL branch2
REP #$20			;(Set 16-bit Accumulator)
LDA #$257E			;(will store list at $7E:257E ?)
STA $002181
SEP #$20			;(Set 8-bit Accumulator)

;(X and Y should be 8-bit coming in..)

TDC
TAX					;(X is our loop iterator)
STA $002183

branch4:
LDA RageList,X		;(get monster # alphabetically - huge ass FF-block, may pick new location later)
TAY
PHX
CLC					;(don't want carry adding into X )
JSR $5217			;( X = A DIV 8, A = 1 SHL (A MOD 8) )
BIT $1D2C,X			;(compare to current rage byte - 32 bytes total, 8 rages per byte)
BEQ branch3			;(if bit wasn't set, rage wasn't found, so don't display it)
TYA
INC $3A9A
STA $002180			;(store rage in menu)

branch3:
PLX
INX					;(advance to next menu position)

CPX #$40
BNE branch4			;(loop for all enemies, 0 to 3F)
RTS 

;----------------------------------------------------------------------

;(alphabetical list of enemies 0-254.  this array is ordered to represent
; the Rage menu, with each element being the enemy number stored at a
; given position)

org $C4A7E0
RageList:
db $1D,$22,$E9,$5D,$20,$91,$4F,$4A,$58,$96,$3D,$1F,$08,$62,$7B,$39
db $63,$47,$0C,$89,$D4,$2E,$FE,$48,$EE,$17,$0F,$D0,$55,$D2,$61,$21
db $CE,$03,$41,$70,$6B,$28,$DF,$F1,$75,$72,$5C,$8E,$0B,$13,$05,$01
db $0E,$18,$42,$66,$F2,$5B,$34,$27,$DD,$46,$88,$93,$F8,$87,$F7,$82

;----------------------------------------------------------------------

;(intermediate function to call C2/5217 from Bank C3)
org $C2FCCD
C2_Jump:
JSR $5217			;( X = A DIV 8, A = 1 SHL (A MOD 8) )
RTL

;----------------------------------------------------------------------

;(Generates alphabetical Rage list under the Skills menu.  Loops for all 256 enemies.
; Function C3/5418 still needs to process this list to display the names.  I tweaked that
; routine to make sure it preserves the ordering established here.)

org $C353C1
LDX #$9D89			;(will store list at $7E:9D89 ?)
STX $2181
SEP #$10			;(8-bit X and Y)
LDX $00				;(X=0?  $00:0000 holds zero in every trace i've seen..) - (X is our loop iterator)

branch7:
LDA RageList,X		;(get monster # alphabetically huge ass FF-block, may pick new location later)
TAY
PHX
CLC					;(don't want carry adding into X )
JSL C2_Jump			;(call C2/5217 indirectly, since it expects a near call. X = A DIV 8, A = 1 SHL (A MOD 8) )
BIT $1D2C,X			;(compare to current rage byte - 32 bytes total, 8 rages per byte)
BEQ branch5			;(if bit wasn't set, rage wasn't found, so display a null entry in its place)
TYA
BRA branch6

branch5:
LDA #$FF			;(store FFh when there's no rage, indicating a null menu item.  Pugs is unfortunate enough to be enemy #255, which is why you can never choose its Rage. *somebody* had to be in that slot, and there's no way i can think of to fix this besides implementing a 16-bit menu handler)

branch6:
STA $2180			;(store rage in menu)
PLX
INX					;(advance to next menu position)
BNE branch7			;(loop for all enemies, 0 to 255)
REP #$10			;(restore 16-bit X and Y)
RTS					;(yes, that's 4 bytes of free space you see below. and the list is alphabetized.  oh ho, i'm that damned good.)
NOP #3
RTS

;--------------------------------------------------------------------------------------

;(Process the rage list.  Partially commented, as I don't understand most of it.  What it
; basically does is: 

; -If a given menu slot holds FFh, display a blank string in place of the enemy's name.
; -If the slot holds 0-FEh, display the name of the enemy whose number matches the current
;    menu slot's *contents*.  This is a change from the original code, which used the
;    enemy number equal to the slot's position.  The home of that rowdy second "LDA $E5" is
;    now inhabited by peaceful NOPs.

; Note: This function is called when you use the up or down arrows to scroll through the list,
; while both 53C1 and this are used if you press the L/R buttons.  Curious.)

org $C35418
LDA $E6
INC 
JSR $809F
REP #$20
TXA 
STA $7E9E89
SEP #$20
TDC 
LDA $E5
TAX 
LDA $7E9D89,X			;(get contents of menu slot - i.e. an enemy number under the Rage list in the Skills menu)
CMP #$FF				;(if it's null, the Rage hasn't been acquired, or it's the unusable Pugs.  go output null characters to display an empty string)
BEQ branch8
NOP						;(previously put the menu position in A.  i have replaced
NOP						;(the meddling instruction with something more useful. let that be a lesson to the rest of you opcodes!@)
JSR $8467				;(go output an enemy name based on our current menu slot's contents)
JMP $7FD9

branch8:
LDY #$000A				;(enemy names are 10 characters long)
LDX #$9E8B
STX $2181
LDA #$FF

branch9:
STA $2180				;(store null character?)
DEY 
BNE branch9				;(loop 10 times)
STZ $2180				;(zero-terminate the string?)
JMP $7FD9
JSR $6A15				;(don't think this is even reached from the above.. curse my insistence on pasting entire functions! :P )
LDA #$20
STA $29
JSR $546C
LDA #$2C
STA $29
LDY #$5CA7
JSR $02F9
JSR $61AC
JMP $0F4D
JSR $5486
JSR $83F7
LDY #$0008

branch10:
PHY 
JSR $54E3
LDA $E6
INC 
INC 
AND #$1F
STA $E6
PLY 
DEY 
BNE branch10
RTS 

; Re-sorts the Rage list to account for only having 64 total rages
; Hack by dn

org $c321ad
;fix arrow
lda #$03f0

org $C321C3
;Fix rage screen in skills menu
lda #$18

; Does the same as above, but in-battle

org $C184F9
CMP #$1C			; (64 rages / 2) - 4
