; New parameters for FC 05 - Melee counter and MP damage counter
    ; Updated to fix a bug where MP damage would trigger melee counters. The checkParams code is now 1 byte longer.
	; AI Script commands:
; FC 05 00 00 = counterattack all damage, as usual
; FC 05 00 01 = counterattack ONLY damage that's both physical and row-respecting
; FC 05 00 02 = counterattack ONLY MP damage
	hirom
header
!freespace = $C21BD1        ; Requires 5 bytes of free space in C2
!freespacelong = $C3F577    ; Requires 67 bytes of free space anywhere
	; Preparation:
; Hook functon C2/35E3 (Initialize several variables for counterattack purposes)
org $C235E9
      JSL initAttackVars  ; (initialize new var $327D,index containing bitflags for
                          ;  physical damage, respects row, and MP damage in bit 0,
                          ;  bit 5, and bit 7 respectively)
      macro initAttackVars()
      initAttackVars:
      TXA                            ; (displaced code)
      STA $3290,Y              ; (displaced code)
      LDA $B3                  ; If Bit 5 is set it ignores attacker row
      EOR #$FF                 ; Invert it so bit 5 is set if melee
      LSR                      ; Shift it to bit 4
      ORA $11A7                ; Merge with bit 4 of $11A7 ("respects row")
      AND #$10                  ; Isolate bit 4 (1 = respects row)
      PHA        
      LDA $11A2                  ; Bit 0 = physical damage if set
      LSR                   ; Carry = 1 if physical damage
      PLA        
      ROL                   ; Bit 1 = physical
                          ; Bit 5 = melee
      ASL                   ; Shift again
      PHA        
      LDA $11A3        
      ROL                            ; Carry = 1 if affects MP
      PLA        
      ROR                            ; A: bit 1 = physical damage
                        ;    bit 5 = melee attack
                        ;    bit 7 = affects MP    
                        ; (all other bits are 0)
      STA $327D,Y                ; Save attack properties to unused var $327D,index
.exit    RTL
      endmacro
        
; Execution:
; FC command $05 (Counter if damaged)
org $C21C70
doCounter:                    ; (vanilla FC 05 code)
	; Redirect pointer for FC command $05 to new code
org $C21D5F
      dw checkParams
	org !freespace
checkParams:
      JML checkParamsLong
      macro checkParamsLong()
      checkParamsLong:
      LDA $3A2F            ; Script command byte 4
      LSR                    ; Check if it's 1 (melee counter)
      BCS .melee        
      LSR                    ; Check if it's 2 (MP damage counter)
      BCC .omni            ; If not set, it's a normal counter
      LDA $327D,Y        
      CMP #$80            ; Check if attack affects MP
      BNE .exit            ; Exit if not
      BRA .omni            ; Counter if attack affects MP
                
.melee    LDA $327D,Y            ; Attack properties
      CMP #$21            ; Check respect row, physical
      BNE .exit            ; Exit if not both are set
.omni    JML doCounter
.exit    CLC
		JML noCounter
      endmacro
noCounter:
      RTS
    
org !freespacelong
reset bytes
%initAttackVars()
%checkParamsLong()
print "New code requires ",bytes," bytes of free space anywhere"