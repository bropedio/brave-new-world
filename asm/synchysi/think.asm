hirom
header

; Collection of Think's BNW hacks that are unfortunately poorly commented, so I have no idea what they do or how they do it

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;hook
org $C23DC5
LDA #$20
TSB $11A2
RTS

org $C242EB
dw #$3DC5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Status Menu 'h' fix by GrayShadows included in below hack.

;hook
org $C35DC9
SEP #$20
LDA #$00
STA $2180
INC
STA $2180
INC
STA $2180
LDA #$05
STA $2180
LDA #$07
STA $2180
INC
STA $2180
INC
STA $2180
INC
STA $2180
INC
STA $2180
INC
STA $2180
INC
STA $2180
LDA #$0F
STA $2180
INC
STA $2180
LDA #$13
STA $2180
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

; New code to build final list:
C35E34:  LDX #$9D8A      ; 7E/9D8A
         STX $2181       ; Set WRAM LBs
         LDA #$FF        ; Cmd: Empty
         STA $2180       ; Add to list
         TDC             ; Clear A
         TAX             ; Cmd slot: 1
         TAY             ; Cmd count: 0
C35E42:  TDC             ; ...
         PHX             ; Save cmd slot
         LDA $7E9E09,X   ; Available cmd
         ;BMI C35E60      ; Skip if none
         ;CMP #$12        ; Mimic?
         ;BEQ C35E60      ; Skip if so
         ;STA $E0         ; Memorize it
         ;ASL A           ; Double it
         ;TAX             ; Index it
         ;LDA $CFFE00,X   ; Properties
         ;AND #$01        ; Gogo can use?
         ;BEQ C35E60      ; Skip if not
         ;LDA $E0         ; Command
         STA $2180       ; Add to list
         INY             ; Cmd count +1
C35E60:  PLX             ; Cmd slot
         INX             ; Cmd slot +1
         CPX #$000E      ; Done 16 x 4?
         BNE C35E42      ; Loop if not
         INY             ; Cmd count +1
         TYA             ; Put it in A
         STA $7E9D89     ; Set list size
         BRA c35e6d
         
org $C35E6D
c35e6d: 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Something about auto critting with a Gem Box? Handled in mp_for_crit.asm

;!freespace = $C265BE ;patch to this offset

;hook
;org $C23F25
;LDA $B2
;BIT #$02
;BNE exit
;LDA $3EC9
;BEQ exit
;TDC
;LDA $3B18,y
;LSR
;REP #$20
;STA $EE
;JSR newfunc
;LDA $3C08,y
;CMP $EE
;BCC exit
;SBC $EE
;STA $3C08,y
;LDA #$0200
;TRB $B2
;exit:
;RTS

;org !freespace
;newfunc:
;LDA $3C45,y
;BIT #$0020
;BEQ skip
;LSR $EE
;skip:
;RTS