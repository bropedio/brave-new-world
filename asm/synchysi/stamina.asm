hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Changes the enemy stamina value to 1-32
; Utilizes an unused bit for stamina-based attacks (bit 3 of special effect byte 3)
; Modifies the stamina check to only strip statuses from an attack if it succeeds

org $C22CE9
NOP
CMP #$20		; Compares stamina to 32
BCC AddStam		; If stamina is less than 31, branch
LDA #$1E		; Otherwise, set stamina equal to 30

AddStam:
ADC #$01		; Add 1 to stamina (or 2 if the carry is set from above)

; Tests a bit to determine if an action should be stamina-based.
; Physical attacks do not make this check, since there are no stamina-based physical attacks in the game.
org $C22955		; C22B69 - No idea what this note means
LDA $3B2C,X		; Load vigor * 2
BCS Phys_Atk	; Branch if it's a physical attack
JSR Stam_Test	; Otherwise, check to see if it should be stamina-based
Phys_Atk:

org $C222EC
Stam_Test:
LDA $11A7		; Load special byte 3
BIT #$04		; Test if bit 3 is set (use stam instead of magic power)
BEQ NoStam
LDA $3B40,X		; Load stamina
RTS

NoStam:
LDA $3B41,X		; Load magic power
RTS

; Alters the stamina check to simply strip statuses if the check succeeds, or flag a miss
; if the attack does no damage anyway.
org $C222A8		; Where the old L? spells were handled
BIT #$10		; Check for stamina involved in evasion
BEQ Check_Hit	; If not, branch to normal hit determination
JSR Stam_Chk	; If so, run the stamina check
BCS Missed		; If the target's stam check succeeded and the attack has no damage component, branch
BRA Check_Hit	; Else, branch to normal hit determination

org $C222B5
Missed:

org $C222FB
Check_Hit:

org $C267C5
Stam_Chk:
JSR $4B5A		; RNG 0-255
AND #$7F		; 0-127
STA $EE
LDA $3B40,Y		; Target's stamina
CMP $EE
BCC Stam_Fail	; If the check failed, nothing further is needed, so exit
LDA $11A6		; Else, see if the attack has a damage component by checking its BP
BEQ Atk_Miss	; If it doesn't, branch
LDA $11A4
AND #$84		; Is the attack fractional or a drain?
BNE Atk_Miss	; If so, branch and just force the attack to miss
LDA $11A3
AND #$80		; Does the attack concern MP?
BNE Atk_Miss	; If so, branch and just force the attack to miss
LDX #$03		; Else, carry on with stripping statuses off the attack

Loop:
STZ $11AA,X		; Else, strip all status effects from the attack and proceed with
DEX				; normal hit determination for the damage component
BPL Loop
CLC				; Clear carry so the attack will go through normal hit determination for the damage component
RTS

Atk_Miss:
SEC				; Carry set = attack misses completely

Stam_Fail:
RTS

; 5 free bytes

; Sets enemy specials that alter status to consider stamina
org $C2334B
JSR Chk_Death_Prot

org $C26761			; Think's patch to prevent enemy specials from ignoring instant death protection
Chk_Death_Prot:
PHA
BIT #$80			; get if it sets death
BEQ Think_BRA		; skip past if not
LDA #$02			; load the flag for miss if death prot
TSB $11A2			; set that flag

Think_BRA:
PLA
JSR Stam_Special
RTS					; End Think's patch

org $C261E9
Stam_Special:
STA $11AA,X			; Displaced from JSR above
LDA #$10
TSB $11A4
RTS

; EOF
