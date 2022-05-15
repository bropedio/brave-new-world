hirom

; C4 Bank

; #########################################################################
; Tile Graphics for new Status Text tiles (Sap/Regen/Rerise)

org $C481C0
  db $F0,$E0,$F8,$90,$DB,$93,$FF,$E4,$F7,$A7,$FF,$94,$DF,$93,$DB,$00
  db $00,$00,$00,$00,$9C,$18,$FF,$A5,$F7,$25,$BF,$1D,$DF,$84,$DE,$18
  db $00,$00,$00,$00,$EF,$CA,$FF,$2D,$FF,$C9,$ED,$09,$FD,$E9,$FD,$00
  db $00,$00,$00,$00,$00,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00
  db $70,$70,$F0,$80,$C3,$83,$F7,$64,$7E,$14,$1E,$14,$FF,$E3,$F3,$00
  db $00,$00,$00,$00,$9E,$1C,$DF,$92,$DB,$92,$DF,$9C,$FE,$50,$78,$10
  db $00,$00,$03,$02,$BF,$28,$FF,$B2,$FB,$22,$33,$22,$F3,$A2,$F3,$00
  db $00,$00,$00,$00,$7B,$73,$FF,$84,$77,$67,$7F,$14,$FF,$E3,$F3,$00
  db $00,$00,$00,$00,$80,$00,$C0,$80,$C0,$00,$00,$00,$C0,$80,$C0,$00
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; #########################################################################
; Summon Descriptions LUT and Text (in freespace)

org $C48270           ; big ol' chunk of freespace :D

InitEsperDataSlice:
  LDA #$10            ; Reset/Stop desc
  TSB $45             ; Set menu flag
  LDA $49             ; Top BG1 write row
  STA $5F             ; Save for return
  RTL

EsperDescPointers:
  dw Ramuh
  dw Ifrit
  dw Shiva
  dw Siren
  dw Terrato
  dw Shoat
  dw Maduin
  dw Bismark
  dw Stray
  dw Palidor
  dw Tritoch
  dw Odin
  dw Loki
  dw Bahamut
  dw Crusader
  dw Ragnarok
  dw Alexandr
  dw Kirin
  dw Zoneseek
  dw Carbunkl
  dw Phantom
  dw Seraph
  dw Golem
  dw Unicorn
  dw Fenrir
  dw Starlet
  dw Phoenix

Ramuh: db "Bolt damage - all foes",$00
Ifrit: db "Fire damage - all foes",$00
Shiva: db "Ice damage - all foes",$00
Siren: db "Sets `Bserk^ - all foes",$00
Terrato: db "Earth damage - all foes",$00
Shoat: db "Sets `Petrify^ - all foes",$00
Maduin: db "Wind damage - all foes|Ignores def.",$00
Bismark: db "Water damage - all foes",$00
Stray: db "Stamina-based cure - party|Sets `Regen^",$00
Palidor: db "Party attacks with `Jump^",$00
Tritoch: db "Fire",$C0,"Ice",$C0,"Bolt damage - all foes",$00
Odin: db "Non-elemental dmg - all foes|Stamina-based; ignores def.",$00
Loki: db $00
Bahamut: db "Non-elemental dmg - all foes|Ignores def.",$00
Crusader: db "Dark damage - all foes",$00
Ragnarok: db "9999 damage - one foe",$00
Alexandr: db "Holy damage - all foes",$00
Kirin: db "Cures HP - party|Revives fallen allies",$00
Zoneseek: db "Sets `Shell^ - party",$00
Carbunkl: db "Sets `Rflect^ - party",$00
Phantom: db "Sets `Vanish^ - party",$00
Seraph: db "Sets `Rerise^ - party",$00
Golem: db "Blocks physical attacks|(Durability = caster*s max HP)",$00
Unicorn: db "Stamina-based cure - party|Lifts most bad statuses",$00
Fenrir: db "Sets `Image^ - party",$00
Starlet: db "Cures HP to max - party|Lifts all bad statuses",$00
Phoenix: db "Revives fallen allies - party|(HP = max)",$00

; #########################################################################
; Alphabetical Rage List (also in freespace)

org $C4A7E0
RageList:
db $1D,$22,$E9,$5D,$20,$91,$4F,$4A,$58,$96,$3D,$1F,$08,$62,$7B,$39
db $63,$47,$0C,$89,$D4,$2E,$FE,$48,$EE,$17,$0F,$D0,$55,$D2,$61,$21
db $CE,$03,$41,$70,$6B,$28,$DF,$F1,$75,$72,$5C,$8E,$0B,$13,$05,$01
db $0E,$18,$42,$66,$F2,$5B,$34,$27,$DD,$46,$88,$93,$F8,$87,$F7,$82
warnpc $C4A820+1

; #########################################################################
; Freespace

org $C4B9D0
AutoCritProcs:
  LDA #$02          ; "Auto Critical"
  BIT $B3           ; check attack flags for ^
  BNE .exit         ; branch if not ^
  LDA $B6           ; spell #
  CMP #$17          ; is it quartr?
  BEQ .quartr       ; branch if so
  CMP #$0D          ; is it doom?
  BEQ .doom         ; branch if so
.exit
  LDA #$40          ; [moved] single enemy targeting
  STA $BB           ; [moved] update targeting type ^
  RTL
.doom
  LDA #$12          ; "X-Zone"
  STA $B6           ; set ^ spell
.quartr
  LDA #$6E          ; all foes targeting
  STA $BB           ; update targeting type ^
  LDA #$40          ; "Randomize Targets" [TODO why?]
  TSB $BA           ; set ^ flag
  STZ $11A9         ; clear special effect
  STZ $341A         ; set "Cannot be Countered"
  RTL

; #########################################################################
; Freespace Helpers
;
; Includes helpers for dn's "Scan Status" hack. Note that the battle
; messages added for status effects are applied separately, via the ips
; patch `[d]bnw_scan_status.ips`

org $C4F1D0
ScanWeakness:
  LDA #$15         ; "Weak to Fire"
  STA $2D6F        ; set ^ message ID
  LDA $3BE0,X      ; weaknesses byte
  BEQ .no_weakness ; branch if empty
  STA $EE          ; else, save in scratch
  LDA $3BE1,X      ; resisted elements
  ORA $3BCC,X      ; absorbed elements
  ORA $3BCD,X      ; immune elements
  TRB $EE          ; remove all from weaknesses
  LDA #$01         ; "Fire"
.elem_loop
  BIT $EE          ; check weaknesses
  BEQ .next_elem   ; branch if not weak
  PHA              ; store element bit
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_a-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_a
  PLA              ; restore element bit
.next_elem
  INC $2D6F        ; point to next message
  ASL              ; advance bit to next element
  BCC .elem_loop   ; loop till done
  RTL
.no_weakness
  LDA #$2C         ; "No Weakness"
  STA $2D6F        ; set ^ message ID
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_b-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_b
  RTL

ScanStatus:
  REP #$20         ; 16-bit A
  LDA $3EE4,x      ; status-1/2
  BIT #$F825       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  LDA $3EF8,x      ; status-3/4
  BIT #$84FE       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  SEP #$20         ; 8-bit A
  LDA #$58         ; "No Status"
  STA $2D6F        ; set message ID ^
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_c-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_c
  RTL
.scan_away
  SEP #$20         ; 8-bit A
  LDA #$47         ; first status message ID
  STA $2D6F        ; set message ID ^

  LDA $3EE4,x      ; status-1
  BIT #$01         ; "Dark"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Poison"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Imp"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EE5,x      ; status-2
  BIT #$08         ; "Mute"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Bserk"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Muddle"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Sap"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Sleep"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EF8,x      ; status-3
  BIT #$02         ; "Regen"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Slow"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$08         ; "Haste"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Stop"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Shell"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Safe"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Reflect"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  LDA $3EF9,x      ; status-4
  BIT #$04         ; "Death Protection"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Float"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  RTL

TryScan:
  BEQ .next
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .next-1      ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.next
  INC $2D6F        ; point to next message ID
  RTS
warnpc $C4F2DB+1
