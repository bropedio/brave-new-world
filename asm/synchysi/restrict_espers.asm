hirom   ; Don't change this.
header  ; Comment out if your ROM has no header.

; Restricts espers to be equippable only by certain characters set in the tables at the bottom.
; All locations have only been tested in FF3us ROM version 1.0, although it should work in version 1.1.
; This will likely not work in the Japanese version.
; Address range utilized: C3/F091 to C3/F136

; Loads the skills menu and gets the character ID. We interrupt this routine in order
; to store the character ID in scratchpad RAM location $A3 ($1D1E).

org $C31B61
JSR StChr

; Checks if any espers are already equipped. We come here just to create a label for
; ease of use and readability.

org $C35576
ChkEq:

; Sets text color to blue. This block is only executed if the esper in question is
; already equipped by someone else.

org $C35593
LDA #$2C		; #$2C for grey text with a blue shadow/#$24 for blue

; Sets text color of the current esper to be printed. As above, we only come here to
; create a label. If an esper can't be equipped because a character can't use it, the
; text will be gray. If an esper can't be equipped because someone else already has it,
; the text will be grey with blue shading. Otherwise, it'll be white.
; The game will later use the text color to determine whether to allow a character to
; use a particular esper.

org $C35595
SetTxtColor:

; This prints out the name of the person currently using the esper you're trying to
; equip, which was originally the only thing stopping someone from equipping a certain
; esper. We need to change this, as the name will be blank if the character simply
; can't equip it.

org $C355B2
JSR Uneq

; The following lines originally jumped to the subroutine for checking if espers were
; already equipped (C3/5574). This check obviously isn't necessary if the character is
; unable to equip the esper anyway.

org $C35524
JSR ChkEsp

org $C358E1
JSR ChkEsp

org $C359B1
JSR ChkEsp

; Checks if the text color is gray, and BZZTs the character if it is. Since we're also
; using blue to indicate an unequippable esper, we'll simply change the comparison from
; "if not gray, branch" to "if white, branch"

org $C358E8
CMP #$20
BEQ WhiteTxt

; Actions to perform if selecting anything in white text. We come here only to make
; a label

org $C35902
WhiteTxt:

; Custom functions follow.

org $C3F091			; Start of free space in bank C3.
StChr:				; Gets the ID of the current character and stores it for later use.
TAX
LDA $69,X
;STA $1D1E
STA $A3
RTS

ChkEsp:				; Checks if a character can use an esper before checking if someone else has it equipped.
PHX					; Preserve X.
STA $E0				; Preserve esper ID, which needs to be in $E0 anyway.
;TDC					; A = $0000
;LDA $E0				; Essentially clearing the top byte of A.
						; Two previous instructions commented out due to space constraints, and for being unnecessary in BNW.
LSR
LSR
LSR					; Four bytes per character, each with 8 espers. So divide by 8.
TAY					; Y = which byte the current esper is in.
LDA $A3				; Character ID
ASL
ASL					; 26 espers, so 4 bytes per character needed.
TAX					; X = which set of 4 bytes to check (i.e., character index).

Find_Esper_Byte:
CPY #$0000
BEQ Found_Esper_Byte; If Y = 0, then we've found the correct byte for the current esper. So branch.
DEY
INX					; Increment character table index, since we're now checking the next byte.
BRA Find_Esper_Byte	; Try again.

Found_Esper_Byte:
LDA $E0				; A = esper ID
AND #$07			; Get the bit that represents the current esper in the current byte
TAY
LDA EsperData,X		; Load the character byte we're checking for equippable espers

Get_Esper_Bit:
CPY #$0000			; If Y = 0, we've found our esper, so branch.
BEQ Found_Esper
LSR					; Otherwise, shift bits in A to the right. This way our desired esper will always be in bit 0 of A.
DEY
BNE Get_Esper_Bit

Found_Esper:
PLX					; Restore X, since it's no longer needed.
AND #$01
BEQ NoEq			; If bit 0 = 0, the esper is unequippable.
JMP ChkEq			; Otherwise, it can be equipped, so check if someone else already has it.

NoEq:
LDA #$28			; Grey text color.
JMP SetTxtColor

; Handles error messages in the case of trying to equip a grey esper.

Uneq:
LDA $1602,X			; Character's name.
CMP #$80			; If the first letter isn't blank, then someone has the esper equipped and we can go back to tell the player as much.
BCS Exit
PLX					; Else, the character can't equip the esper at all and we need to tell the player as much.
LDX $00

; Above: PLX because we no longer need to RTS to where this subroutine was called from.
; Sloppy, I know. BCS alone (instead of branching to an RTS) won't work because the branch is just too long.
; I'm looking for a way to streamline it.
; LDX $00 because it's necessary anyway as a counter for the next block.

; The following is identical to the code that prints "<Char> has it!",
; just altered slightly so it reads "Can't equip!"

LoadNoEqTxt:
LDA NoEqTxt,X
BEQ Null			; If the character (letter) being written is null ($00), end the line.
STA $2180			; Print the current letter.
INX					; Go to the next letter.
BRA LoadNoEqTxt

Exit:
RTS

Null:
STZ $2180			; End this string.
JMP $7FD9

; "Can't equip!" text.
NoEqTxt:
DB $82,$9A,$A7,$C3,$AD,$FF,$9E,$AA,$AE,$A2,$A9,$BE,$00

; Character esper data table. See below for specifics.
EsperData:
DB $C0,$84,$88,$04	; Terra
DB $03,$00,$02,$04	; Locke
DB $80,$40,$02,$00	; Cyan
DB $00,$00,$10,$01	; Shadow
DB $08,$02,$C0,$00	; Edgar
DB $10,$01,$40,$00	; Sabin
DB $0D,$40,$31,$00	; Celes
DB $04,$08,$0C,$00	; Strago
DB $02,$20,$04,$02	; Relm
DB $20,$00,$20,$02	; Setzer
DB $70,$02,$00,$00	; Mog
DB $00,$01,$00,$01	; Gau
DB $00,$00,$00,$00	; Gogo
DB $00,$00,$00,$00	; Umaro
DB $00,$00,$00,$00	; Slot 15
DB $00,$00,$00,$00	; Slot 16

; Byte 1			Byte 2			Byte 3			Byte 4
; $01: Ramuh		$01: Stray		$01: Alexandr	$01: Fenrir
; $02: Ifrit		$02: Palidor	$02: Kirin		$02: Starlet
; $04: Shiva		$04: Tritoch	$04: Zoneseek	$04: Phoenix
; $08: Siren		$08: Odin		$08: Carbunkle	$08: N/A
; $10: Terrato		$10: Raiden		$10: Phantom	$10: N/A
; $20: Shoat		$20: Bahamut	$20: Seraph		$20: N/A
; $40: Maduin		$40: Crusader	$40: Golem		$40: N/A
; $80: Bismark		$80: Ragnarok	$80: Unicorn	$80: N/A

; Any listed as N/A above are invalid or expanded espers and not explicitly supported by this hack

; EOF
