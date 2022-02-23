; unfinished and untested

hirom
;header
!newCode     = $C0D79E
!esperStruct = $C0D690

; ESPER JUNCTION STRUCT

; Immunity 1		Immunity 2			Status 1		Special				Elem-half
; $80: Death		$80: Sleep			$80: Reflect    $80: MP +12.5%		$80: Water
; $40: Petrify  	$40: Seizure        $40: Safe       $40: MP +50%        $40: Earth
; $20: Imp	    	$20: Muddle         $20: Shell      $20: MP +25%        $20: Pearl
; $10: Clear    	$10: Berserk        $10: Stop       $10: HP +12.5%      $10: Wind
; $08: MagiTek  	$08: Mute           $08: Haste      $08: HP +50%        $08: Poison
; $04: Poison   	$04: Image          $04: Slow       $04: HP +25%        $04: Bolt
; $02: Zombie   	$02: Near Fatal     $02: Regen      $02: MDamage +25%   $02: Ice
; $01: Dark	    	$01: Condemned      $01: Float      $01: PDamage +25%   $01: Fire

; Speed/Vigor		Magic/Stamina		Defense			MDef				Mblock/Evade
; $x0: Speed		$x0: Magic			$xx: Defense    $xx: Mdef			$x0: Mblock
; $x0: Speed		$x0: Magic    		$xx: Defense    $xx: Mdef			$x0: Mblock
; $x0: Speed		$x0: Magic    		$xx: Defense    $xx: Mdef			$x0: Mblock
; $x0: Speed		$x0: Magic    		$xx: Defense    $xx: Mdef			$x0: Mblock
; $0x: Vigor	  	$0x: Stamina   		$xx: Defense    $xx: Mdef			$0x: Evade
; $0x: Vigor	   	$0x: Stamina   		$xx: Defense    $xx: Mdef			$0x: Evade
; $0x: Vigor	   	$0x: Stamina   		$xx: Defense    $xx: Mdef			$0x: Evade
; $0x: Vigor	   	$0x: Stamina   		$xx: Defense    $xx: Mdef			$0x: Evade

org !esperStruct
db $00									; Ramuh: Status immunity 1
db $00									; Ramuh: Status immunity 2
db $00									; Ramuh: Innate status
db $00									; Ramuh: Damage & HP%/MP% bonuses
db $04									; Ramuh: Elemental resistance
db $00									; Ramuh: Speed & Vigor
db $00									; Ramuh: Magic & Stamina
db $00									; Ramuh: Defense
db $00									; Ramuh: Magic Defense
db $00									; Ramuh: M.Block & Evade

db $00,$00,$00,$00,$01,$00,$00,$00,$00,$00		; Ifrit
db $00,$00,$00,$00,$02,$00,$00,$00,$00,$00		; Shiva
db $01,$28,$00,$00,$00,$00,$00,$00,$00,$00		; Siren
db $00,$00,$00,$00,$40,$00,$00,$00,$00,$00		; Terrato
db $00,$00,$00,$00,$00,$00,$05,$00,$00,$00		; Shoat
db $00,$00,$00,$00,$10,$00,$00,$00,$00,$00		; Maduin
db $00,$00,$00,$00,$80,$00,$00,$00,$00,$00		; Bismark
db $24,$10,$00,$00,$00,$00,$00,$00,$00,$00		; Stray
db $00,$00,$08,$00,$00,$00,$00,$00,$00,$00		; Palidor
db $00,$00,$20,$00,$00,$00,$00,$00,$00,$00		; Tritoch
db $00,$00,$00,$00,$00,$50,$00,$00,$00,$00		; Odin
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00		; Raiden
db $00,$00,$40,$00,$00,$00,$00,$00,$00,$00		; Bahamut
db $00,$00,$80,$00,$00,$00,$00,$00,$00,$00		; Crusader
db $00,$00,$00,$02,$00,$00,$00,$00,$00,$00		; Ragnarok
db $00,$00,$00,$01,$00,$00,$00,$00,$00,$00		; Alexandr
db $00,$00,$00,$00,$00,$00,$50,$00,$00,$00		; Kirin
db $00,$00,$00,$00,$00,$00,$00,$00,$0A,$00		; Zoneseek
db $00,$00,$02,$00,$00,$00,$00,$00,$00,$00		; Carbunkl
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$A0		; Phantom
db $C0,$80,$00,$00,$00,$00,$00,$00,$00,$00		; Seraph
db $00,$00,$00,$00,$00,$00,$00,$0A,$00,$00		; Golem
db $00,$00,$00,$00,$00,$05,$00,$00,$00,$00		; Unicorn
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$0A		; Fenrir
db $00,$00,$00,$20,$00,$00,$00,$00,$00,$00		; Starlet
db $00,$00,$00,$04,$00,$00,$00,$00,$00,$00		; Phoenix

org $C20EF3
      JSL newfunc
      NOP

org $C32937
      JMP $F43B

org $C3F43B
      JSR $9110         ; Recalculate numbers
      JSR $4EED         ; Properly update display
      JMP $4F08

org !newCode
newfunc:
        LDA $15FB,X       ; Load equipped esper
        BPL .bra1         ; If no esper just skip
        JMP $D821         ; Skip
.bra1   XBA 
        LDA #$0A          ; Size of an esper item block
        REP #$20
        STA $004202       ; Get ready to multiply
        PHX
        PHY
        NOP               ; Gotta wait a bit longer
        LDA $004216       ; Load the result
        TAX               ; Store the index to go to
        LDA $C0D690,X     ; Status protection
        TSB $11D2
        LDA $C0D692,X     ; Innate statuses and percent bonuses
        TSB $11D4
        LDA $C0D695,X     ; Stat bonuses
        LDY #$0006
.loop   PHA
        AND #$000F        ; Get bottom nibble
        CLC
        ADC $11A0,Y
        STA $11A0,Y       ; Adjust relevant stat
        PLA
        LSR
        LSR
        LSR
        LSR
        DEY
        DEY
        BPL .loop         ; Loop until every stat is extracted
        SEP #$20          ; Set 8-bit A
        LDA $C0D699,X     ; Evade & Mblock
        PHA
        AND #$0F
        ADC $11A8         ; Load Evade
        STA $11A8         ; Store Evade
        PLA
        LSR
        LSR
        LSR
        LSR
        AND #$0F          ; Now it's Mblock
        ADC $11AA         ; Load Mblock
        STA $11AA         ; Store Mblock
        LDA $C0D694,X     ; Elemental resistances
        TSB $11B9         ; Store elemental resistances
        LDA $C0D697,X     ; Defense
        ADC $11BA
        BCC .noCap1
        LDA #$FF          ; Load 255 if it goes over cap
.noCap1 STA $11BA
        LDA $C0D698,X     ; M.Def
        ADC $11BB
        BCC .noCap2
        LDA #$FF
.noCap2 STA $11BB
        PLY
        PLX

; Code replaced at C2/0EF3
        LDA $15ED,X
        AND #$3F
        RTL
