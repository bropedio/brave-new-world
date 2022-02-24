; Alters the coliseum item selection screen to also display the reward.
; Original hack by HatZen08.
; Modified by Synchysi simply to change a location so it plays nicely with BNW,
; and to change the colon delimiter to something else.
; My comments in parentheses, otherwise commentary is by HatZen08.

;-------------------------------------------------------------------------------
;reward display 1.1
;
;display reward items in Colosseum item screen
;-------------------------------------------------------------------------------

header
hirom

;-------------------------------------------------------------------------------
;main link
;-------------------------------------------------------------------------------
org     $C37FD0
    JMP selection       ;select text to display
;warnpc  $C37FD3		; (asar stuff, I assume)

;-------------------------------------------------------------------------------
;selection
;
;select between normal text display or new Colosseum setup display
;-------------------------------------------------------------------------------
org     $C3F1B8         ;(*) change for any free space
;print   "seg start: ", pc	; (more asar stuff)

selection:

    ;check system event
    LDA $26             ;system event
    CMP #$71            ;to init colloseum screen (item selection)
    BEQ bet_display
    CMP #$72            ;to mantain colosseum screen (item selection)
    BEQ bet_display

    ;old code for no-Colosseum events
    JSR $80B9           ;build string for item name
    JSR $7FD9           ;display text. (Y=location in rom)
    JMP $7FE6           ;display item type

;-------------------------------------------------------------------------------
;bet display
;
;setup and display formated strings for the new Colosseum setup 
;-------------------------------------------------------------------------------
bet_display:

    JSR colosseum_setup     ;setup colosseum variables

    JSR string_init         ;init the string
    JSR string_bet          ;display bet item
    JSR string_display      ;display the string
    JSR position_advance_1A ;advance position for next display

    JSR string_init         ;init the string
    JSR string_delimiter    ;dislay delimiter
    JSR string_display      ;display the string
    JSR position_advance_02 ;advance position for next display

    JSR string_init         ;init the string
    JSR string_reward       ;display reward item
    JSR string_display      ;display the string
    JSR position_advance_1A ;advance position for next display
    
    RTS

;-------------------------------------------------------------------------------
;colosseum_setup
;
;setup variables for colosseum
;-------------------------------------------------------------------------------
colosseum_setup:

    ;discovery item ID in window
    TDC
    LDA $E5             ;index in window
    TAY
    LDA $1869,Y         ;item in window index

    ;calculate variables
    STA $0205           ;save item to bet
    JSR $B22C           ;setup Colosseum variables

    ;exit
    RTS

;-------------------------------------------------------------------------------
;string init
;
;init transfer of $2180 to build the string
;-------------------------------------------------------------------------------
string_init:

    ;setup transfer
    LDX #$9E8B
    STX $2181

    ;exit
    RTS

;-------------------------------------------------------------------------------
;string display
;
;display string stored at $2180
;-------------------------------------------------------------------------------
string_display:

    JSR $7FD9
    RTS

;-------------------------------------------------------------------------------
;string fill
;
;fill the string with the character in A
;-------------------------------------------------------------------------------
string_fill:
    
    ;init
    LDX #$000D

    .loop
    STA $2180
    DEX
    BNE .loop

    ;end string
    STZ $2180

    ;exit
    RTS

;-------------------------------------------------------------------------------
;position advance
;
;advance the position onscreen of the string
;-------------------------------------------------------------------------------
position_advance_02:

    LDX #$0002
    BRA position_advance_main

position_advance_1A:

    LDX #$001A

position_advance_main:

    ;advance position
    REP #$20            ;set C
    TXA                 ;get position to advance
    CLC
    ADC $7E9E89         ;sum with existing one
    STA $7E9E89         ;save position
    SEP #$20            ;set A

    ;exit
    RTS

;-------------------------------------------------------------------------------
;string reward
;
;build the string for the reward item
;-------------------------------------------------------------------------------
string_reward:

    ;select
    LDA $0209           ;mask flag
    BNE .case_mask
    LDA $0205           ;bet item
    CMP #$FF            ;empty item
    BEQ .case_empty

    .case_default
    LDA $0207           ;reward item
    JSR $C068           ;setup item string
    RTS

    .case_mask
    LDA #$BF            ;'?' character
    JSR string_fill
    RTS

    .case_empty
    LDA #$FF            ;space character
    JSR string_fill
    RTS

;-------------------------------------------------------------------------------
;string delimiter
;
;build the string for the delimiter character
;-------------------------------------------------------------------------------
string_delimiter:

    ;select
    LDA $0205           ;bet item
    CMP #$FF            ;empty item
    BEQ .case_empty

    .case_default
    LDA #$D5            ;':' character (replaced with a right-facing arrow by me)
    BRA .set_char

    .case_empty
    LDA #$FF            ;space character

    .set_char
    STA $2180
    STZ $2180           ;end of string
    RTS

;-------------------------------------------------------------------------------
;string bet
;
;build the string for the bet item
;-------------------------------------------------------------------------------
string_bet:

    LDA $0205           ;item to bet
    CMP #$FF            ;empty item
    BEQ .case_empty

    .case_default
    LDA $0205           ;item to bet
    JSR $C068           ;setup item string
    RTS

    .case_empty
    LDA #$FF            ;space character
    JSR string_fill
    RTS    

;print   "seg end  : ", pc	; asar again

; EOF