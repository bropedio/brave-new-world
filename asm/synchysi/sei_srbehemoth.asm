	; Animation script $025C: Misc. Monster Animation $06: Characters Run Right to Left (bg1)
; Include a change to boss battle music
hirom
header
!freespace = $D0CF4A    ; Requires 18 bytes in bank D0
	; Relocate animation script
org !freespace
anim_script_025c:
        db $00,$20                ; speed 1, align to center of character/monster
        db $D1,$01                ; invalidate character/monster sprite priority
        db $C7,$0B,$10,$14,$FF    ; SPC command $10, $14, $FF (play boss music)
        db $89,$37                ; loop start (55 times)
        db $80,$79                ; command $80/$79
        db $0F                    ; [$0F]
        db $8A                    ; loop end
        db $80,$7B                ; command $80/$7B
        db $FF                    ; end of script
        
; Update the pointer
org $D1EF90
dw anim_script_025c
