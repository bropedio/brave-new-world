arch 65816
hirom
table "menu.tbl", ltr

!EL = $1D10
!EP = $1CF8
!EP_Chart = $ED8BCA
!Ramuh_Chk = $F392
!Char_Chk = $F399
!EL_bank = $1D1C

; ----------------------------------------------------------------------
org $C3499B
	dw #ShowDelay


org $c370c5
	jsr f45e
; ----------------------------------------------------------------------
org $C1FFE5

; ----------------------------------------------------------------------
; During NMI, if Select button pressed, swap gauge display

CheckSel:
  JSL SwapGauge  ; (in $C3)
; -------------------------------------------------------------------------
; Modify the status screen to display EP and esper level to the player
; Change total exp display to exp to next level
org $C36068
  JSR $60A0         ; get experience needed to level
  JSR $0582         ; convert to digit tiles
  LDX #$7CD7        ; tilemap position
  JSR $04A3         ; write experience needed to status screen
  JSR EL_Status     ; draw "Total EP" label

; #########################################################################
; Draw Item Row (used in item menu and colosseum)

org $C37FD0 : JMP ItemNameFork ; hook for colosseum item row

; #########################################################################
; Draw Esper

org $C32937 : JMP DrawEsperHook ; include esper equip bonuses
  
; #########################################################################
; Character Lineup
org $C3797D : JSR EL_Party  ; draw EL after LV in party select screen
org $C379E6 : dw $3A75      ; shift LV label to make room for EL display

; #########################################################################
; Character Display

; Change position of LV to make room for EL
; If espers have been acquired, write EL label after LV label
org $C33303 : JSR EL_Main_1 ; Main menu, character 1
org $C3332D : dw $39A5
org $C3334F : JSR EL_Main_2 ; Main menu, character 2
org $C33379 : dw $3B25
org $C3339B : JSR EL_Main_3 ; Main menu, character 3
org $C333C5 : dw $3CA5
org $C333E7 : JSR EL_Main_4 ; Main menu, character 4
org $C33411 : dw $3E25

org $C34EEA : JSR EL_Skill  ; draw EL in skills display
org $C35A3B : JSR Unspent_EL ; add unspent EL draw to esper bonus draw
; ------------------------------------------------------------------------
; Colosseum Item Row drawing helpers
; Include prize item on line with item row

org $C3F1B8
ItemNameFork:
  LDA $26                 ; current system op
  CMP #$71                ; "Init Colosseum Item Selection"
  BEQ .colosseum_menu     ; branch if ^
  CMP #$72                ; "Sustain Colosseum Item Selection"
  BEQ .colosseum_menu     ; branch if ^
  JSR $80B9               ; else, do regular "Item Menu" rows
  JSR $7FD9               ; display text
  JMP $7FE6               ; display item type
.colosseum_menu
colosseum_menu:
  JSR colosseum_setup     ; setup colosseum variables  
  JMP check_reward_item	  ; check if the item to print return a prize
string_init_adress:
  JSR string_init         ; init the string
  JSR string_bet          ; display bet item
  JSR string_display      ; display the string
  JSR position_advance_1A ; advance position for next display
  JSR string_init         ; init the string
  JSR string_delimiter    ; dislay delimiter
  JSR string_display      ; display the string
  JSR position_advance_02 ; advance position for next display
  JSR string_init         ; init the string
  JSR string_reward       ; display reward item
  JSR string_display      ; display the string
  JSR position_advance_1A ; advance position for next display
  RTS

check_reward_item:
  LDA $0207				  ; load "-" value (means no prize item)
  CMP #$BC                ; check if item don't have a prize
  BNE .jmp                ; jump if have
  INC $E5                 ; increment row index 
  JMP colosseum_menu      ; go back to the next item
.jmp
  JMP string_init_adress  ; go on the routine and print
  
colosseum_setup:
  TDC                     ; zero A/B
  LDA $E5                 ; row index in menu
  TAY                     ; index it
  LDA $1869,Y             ; item ID in slot
  STA $0205               ; save item to bet
  JSR $B22C               ; setup Colosseum variables
  RTS

string_init:
  LDX #$9E8B              ; start of text in WRAM buffer
  STX $2181               ; set WRAM destination
  RTS

string_display:
  JSR $7FD9               ; draw string [TODO: remove needless wrapper]
  RTS

string_fill:
  LDX #$000D              ; length of item name
.loop
  STA $2180               ; write fill character
  DEX                     ; decrement iterator
  BNE .loop               ; loop till all written
  STZ $2180               ; set EOL
  RTS

position_advance_02:
  LDX #$0002              ; advance $02 spaces
  BRA position_advance
position_advance_1A:
  LDX #$001A              ; advance $1A spaces
position_advance:
  REP #$20                ; 16-bit A
  TXA                     ; tiles to advance
  CLC                     ; clear carry
  ADC $7E9E89             ; add to text tilemap position
  STA $7E9E89             ; set new text tilemap position
  SEP #$20                ; 8-bit A
  RTS

string_reward:
  LDA $0209               ; mask flag
  BNE .case_mask          ; branch if hidden prize
  LDA $0205               ; bet item ID
  CMP #$FF                ; null?
  BEQ .case_empty         ; branch if empty item
.case_default
  LDA $0207               ; reward item
  JSR $C068               ; load item name [TODO JMP]
  RTS
.case_mask
  LDA #$BF                ; '?' character
  JSR string_fill         ; fill item name with '????'
  RTS
.case_empty
  LDA #$FF                ; ' ' character
  JSR string_fill         ; fill item name with '    '
  RTS

string_delimiter:
  LDA $0205               ; bet item ID
  CMP #$FF                ; null?
  BEQ .case_empty         ; branch if ^
.case_default
  LDA #$D5                ; '>' character (right-facing arrow)
  BRA .set_char           ; branch and write ^
.case_empty
  LDA #$FF                ; ' ' character
.set_char
  STA $2180               ; write chosen delimiter
  STZ $2180               ; end of string
  RTS

string_bet:
  LDA $0205               ; item ID to bet
  CMP #$FF                ; null?
  BEQ .case_empty         ; branch if ^
.case_default
  LDA $0205               ; item ID to bet [TODO: Redundant]
  JSR $C068               ; load item name [TODO: JMP]
  RTS
.case_empty
  LDA #$FF                ; space character
  JSR string_fill         ; fill item name with spaces
  RTS    

; ------------------------------------------------------------------------
; EL/EP/Spell bank text data and helpers
; Many new label and text positions and tiles
;org $C3F277
EPUpTxt:
  dw $7D4D : db "EP to lv. up:",$00
EPUpClr:
  dw $7D4D : db "             ",$00 ; 13 blanks for Gogo+
EPClear:
  dw $7DDD : db "     ",$00         ;  5 blanks for Gogo+ EP

; TODO: Lots of duplicated code here
; Many "EL" text positions, plus extra $FF buffer for indexing purposes
  dw $39AB : db "EL",$00,$FF,$FF,$FF
  dw $3B2B : db "EL",$00,$FF,$FF,$FF
  dw $3CAB : db "EL",$00,$FF,$FF,$FF
  dw $3E2B : db "EL",$00,$FF,$FF,$FF
  dw $423B : db "EL",$00,$FF,$FF,$FF
  dw $3A2B : db "EL",$00,$FF,$FF,$FF
  dw $3A7B : db "EL",$00,$FF,$FF,$FF

; TODO: Lots of duplicated code here
; Many "EL" text positions, but with spaces instead, to overwrite
  dw $39AB : db "     ",$00
  dw $3B2B : db "     ",$00
  dw $3CAB : db "     ",$00
  dw $3E2B : db "     ",$00
  dw $423B : db "     ",$00
  dw $3A2B : db "     ",$00
  dw $3A7B : db "     ",$00
UnspentTxt:
  db "Unspent EL:",$00

Calc_EP_Status:
  LDA $1E8A         ; event byte
  AND #$08          ; "met Ramuh"
  BEQ .no_ep        ; branch if not ^
  LDX $67           ; character data offset
  LDA $0000,X       ; character ID
  CMP #$0C          ; Gogo or above
  BCC .yes_ep       ; branch if not ^
.no_ep
  LDY #EPClear      ; pointer for spaces to blank out EP value
  JSR $02F9         ; draw ^
  LDY #EPUpClr      ; pointer for spaces to blank out "EP to lv. up"
  JSR $02F9         ; draw ^
  CLC               ; clear carry (hide EP needed)
  RTS
.yes_ep
  PHA               ; store character ID
  LDA #$2C          ; color: gray-blue
  STA $29           ; set text palette
  LDY #EPUpTxt      ; pointer for "EP to lv. up" text display
  JSR $02F9         ; draw ^
  TDC               ; zero A/B
  LDA #$20          ; color: white
  STA $29           ; set text palette
  PLA               ; restore character ID
  TAY               ; index it
  LDA !EL,Y         ; character's esper level
  CMP #$19          ; at max (25)
  BNE .needed_ep    ; branch if not ^
  SEC               ; set carry (show EP needed)
  JMP $60C3         ; display zero and exit
.needed_ep
  ASL               ; EL x2
  TAX               ; index to EP lookup
  TYA               ; character ID
  ASL               ; x2
  TAY               ; index it
  REP #$30          ; 16-bit A, X/Y
  LDA !EP,Y         ; character's total EP
  STA $F1           ; store ^
  LDA !EP_Chart,X    ; EP needed for next level
  SEC               ; set carry
  SBC $F1           ; EP needed - total EP
  STA $F1           ; store ^
  SEP #$20          ; 8-bit A
  SEC               ; set carry (show EP needed)
  RTS
org $C3F36F
Esp_Lvl:
  JSR $04B6         ; [displaced] draw two digits
  JSR Ramuh_Chk     ; check if optained espers yet
  BEQ .exit         ; exit if not ^
  JSR Char_Chk      ; check if Gogo or above
  BCS .exit         ; exit if ^
  TAY               ; index character ID
  LDA !EL,Y         ; character's esper level
  JSR $04E0         ; turn into digit tiles
  REP #$20          ; 16-bit A
  LDA [$EF]         ; tilemap position for level display
  CLC               ; clear carry
  ADC #$000C        ; move X position for esper level display
  TAX               ; index it
  SEP #$20          ; 8-bit A
  JMP $04B6         ; write esper level to screen
.exit
  RTS

Ramuh_Chk:
  TDC               ; zero A/B
  LDA $1E8A         ; event byte
  AND #$08          ; "met Ramuh"
  RTS

Char_Chk:
  LDX $67           ; character data offset
  TDC               ; zero A/B
  LDA $0000,X       ; character ID
  CMP #$0C          ; carry: Gogo or higher
  RTS

EL_Main_1:
  LDA #$00          ; slot 1 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_2:
  LDA #$08          ; slot 2 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_3:
  LDA #$10          ; slot 3 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_4:
  LDA #$18          ; slot 4 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Skill:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDA #$20          ; offset for "EL" label in skills menu
  PHA               ; store ^
  BRA Stat_Skill_Ent ; draw "EL" label

EL_Status:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDA #$28          ; offset for "EL" label in status menu
  PHA               ; store ^
  BRA Stat_Skill_Ent ; draw "EL" label

EL_Party:
  LDA #$30          ; offset for EL label in party lineup menu
  PHA               ; store ^
Write_Text:
  JSR $69BA         ; [displaced] draw multiple strings

Stat_Skill_Ent:
  JSR Ramuh_Chk     ; obtained espers
  BEQ No_Ramuh      ; branch if not ^
  JSR Char_Chk      ; Gogo check
  PLA               ; restore text offset
  PHP               ; store flags
  REP #$20          ; 16-bit A
  BCS Gogo          ; branch if Gogo or higher
  ADC #$F29F        ; else, add "EL" text location
  BRA Write_EL      ; branch to write ^

No_Ramuh:
  PLA               ; restore text offset
  PHP               ; store flags
  REP #$20          ; 16-bit A

Gogo:
  CLC               ; clear carry
  ADC #$F2D7        ; add black spaces text location

Write_EL:
  TAY               ; index text source
  PLP               ; restore flags
  JMP $02F9         ; draw source text

; Adds "Unspent EL" display under the esper bonuses
Unspent_EL:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDY #$4791        ; tilemap position to write to
  JSR $3519         ; initialize WRAM buffer with ^
  LDX $00           ; zero X
.write_uel
  LDA UnspentTxt,X  ; get "Unspent EL:" tile
  BEQ .finish       ; break if EOL
  STA $2180         ; else, write to WRAM
  INX               ; next tile index
  BRA .write_uel    ; loop till EOL ($00)
.finish
  STZ $2180         ; write EOL
  JSR $7FD9         ; draw string from WRAM buffer
  LDA #$20          ; color: white
  STA $29           ; set palette
  JSR Char_Chk      ; current character's ID
  TAY               ; index it
  LDA !EL_bank,Y    ; available ELs for character to spend
  JSR $04E0         ; turn into digit tiles
  LDY #$47A9        ; tilemap position to write to
  JSR $3519         ; initialize WRAM buffer with ^
  LDA $F8           ; tens digit of ELs
  STA $2180         ; write ^
  LDA $F9           ; ones digit of ELs
  STA $2180         ; write ^
  STZ $2180         ; write EOL
  JSR $7FD9         ; draw string from WRAM buffer
  LDY #$470F        ; next tilemap position (shifted left 2 spaces)
  RTS

; ---------------------------------------------------------
; Esper Equip Bonus Drawing helper

;org $C3F43B
DrawEsperHook:
  JSR $9F06         ; Recalculate numbers
  JSR $4EED         ; Properly update display
  JMP $4F08         ; draw esper name [?]

; ---------------------------------------------------------
; Handle in-battle gauge mode toggle via Select button

;org $C3F444
SwapGauge:
  STZ $2021
  LDA $0B
  ASL
  ASL
  BMI .exit
  DEC $2021
.exit
  RTL

ShowDelay:
	dw $3B8F : db "Show Delay",$00
f45e:
	lda #$80 
	sta $1d4e
	rts      
warnpc $C3F480

; Load item description in Colosseum menu
org $C3FF00
	JSR $8308      ; Set desc ptrs
	TDC            ; Clear A
	LDA $4B        ; Cursor slot
	TAY            ; Index it
	JSR change_for_reward
	JSR $5738     ; Load description
	JSR $8356     ; Count items
	LDA #$20       ; Palette 0
	STA $29        ; Color: User's
	JMP $837A     ; Draw item count

change_for_reward:
;	LDY $0110
.next
	TDC
	LDA $1869,Y    ; Item in slot  
	REP #$20       ; 16-bit A		
	ASL A          ; x2				 
	ASL A          ; x4				
	TAX            ; Index it		
	PHX
	SEP #$20       ; 8-bit A	  
	INY
	LDA $DFB602,X  ; Prize
	PLX
	CMP #$BC
	BEQ .next
	INY 
	STY $4B
	INC $4F
	REP #$20
	TXA 
	LSR
	LSR
	SEP #$20
	RTS
	
; 71: Initialize Colosseum item menu
org $C3ACAA  
	STZ $0201      ; Face Shadow: No
	LDA $0205      ; Empty item...
	JSR $9D5E      ; Add to stock...
	JSR $1AE2      ; Init list vars
	JSR $7D25      ; Relocate cursor
	JSR $AD27      ; Draw/Upload menu
	TDC            ; Gradient set: 0
	JSL $D4CA1D    ; Create gradient
	JSR $1B0E      ; Shift & OBJ & Fade
	JSR $3F99      ; Apply user font
	LDA #$01       ; CGRAM: Refresh
	TSB $45        ; Set NMI flag
	JSR $1368      ; Refresh screen
	LDA #$72       ; C3/ACDC
	STA $27        ; Queue: Sustain menu
	LDA #$02       ; Main cursor: On
	STA $46        ; Bar/Blinker: Off
	JSR $07B0      ; Queue cursor OAM
	JMP $3541      ; BRT:1 + NMI

; 72: Sustain Colosseum item menu
org $C3ACED
	JSR $FF00      ; Load description

;; Fork: Handle A
;org $C3ACF0  
;	LDA $08         ; No-autofire keys
;	BIT #$80        ; Pushing A?
;	BEQ $AD14       ; Branch if not
;	TDC             ; Clear A
;	LDA $4B         ; Selected slot
;	TAX             ; Index it
;	LDA $1869,X     ; Item in slot
;	CMP #$FF        ; None?
;	BEQ C3AD0E      ; Fail if so
;	STA $0205       ; Set item bet
;	JSR C30EB2      ; Sound: Click
;	LDA #$75        ; C3/ADB7
;	STA $27         ; Queue: Matchup
;	STZ $26         ; Next: Fade-out
;	RTS