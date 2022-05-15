;Leap Anywhere

;This enables Gau's Leap command everywhere, not only on the Veldt,
;and changes the Leap command to only remove Gau from battle - not
;from the active party. Leap will only be enabled on formations
;that actually appear on the Veldt.

;xkas 0.06
hirom
;header
!freespace = $C26591

;Enable Leap everywhere (unchanged)
; TODO: Bropedio note: This code is commented out because it is not
; present in the current 2.1 version of BNW. Unsure why it was not
; assembled correctly. We should probably uncomment this code for a
; bugfix release
org $C25432
C25432:
  ;BNE .exit		;Dance and Leap jumps here
  ;LDA #$FF
	;STA $03,S		;Replace current command with empty
;.exit
  ;RTS 

;Leap availability check
org $C2543E
C2543E: JSR checkLeap
        macro checkLeap()
        checkLeap:
        LDA $2F4B
        EOR #$02
        RTS
        endmacro
		BIT #$02		;Does formation appear on the Veldt?
		BRA C25432		;If not, menu entry will be nulled after branch

;Change Leap behaviour
org $C23B71
reset bytes
print "Writing Leap function to ",pc, "(vanilla: C23B71)"
C23B71: LDA $3A76		;Number of present and living characters in party
        CMP #$02			
        BCC .miss		;If less than 2, then miss w/ text
		LDA $05,S
		TAX
		LDA $3DE9,X
		ORA #$20
		STA $3DE9,X    	;Mark Hide status to be set in attacker
		LDA $3018,X
		TSB $2F4C      	;Mark caster to be removed from the battlefield
		JSR $4A07 		;Learn rages
.exit	RTS

	
.miss	LDA #$05	
		JMP $3B18      	;Miss target
print "Leap function ends at ",pc, " (vanilla ends at C23B97)"
print "Leap function is ",bytes," bytes long (vanilla is 39 bytes)"

reset bytes
print "Writing checkLeap to ",pc
		%checkLeap()
print "checkLeap ends at ",pc
print "checkLeap is ",bytes," bytes long"
