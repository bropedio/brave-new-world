hirom

; D0 Bank (includes battle events)

; -------------------------------------------------------------------------
; Speed up the aero animation

org $D015DE : db $89,$20
org $D015FC : db $89,$60
org $D01611 : db $89,$03

; -------------------------------------------------------------------------
; Add X-Kill animation data back (changed in base BTB ips [?])

org $D08696 : db $FF,$FF,$7F,$02,$FF,$FF,$35,$35,$00,$CC,$1B,$FF,$FF,$10

; -------------------------------------------------------------------------
; Add Cleave death animation to Chainsaw

org $D0921C : db $0B  ; not sure how, but this byte sets cleave anim

; -------------------------------------------------------------------------
; Wrexsoul Event 1/2
; Battle script command: F7 08

org $D0A6B4
  db $11      ; Open dialogue window at the bottom of the screen
  db $01,$FB  ; Display caption 251
  db $10      ; Close dialogue window
  db $FF      ; End event

; -------------------------------------------------------------------------
; Kaiser's monologue before the encounter starts (battle event)
; Battle script command: F7 0B

org $D0A851
  db $11         ; Open dialogue window at the bottom of the screen
  db $01,$D4     ; Display caption 212
  db $01,$D5     ; Display caption 213
  db $01,$D6     ; Display caption 214
  db $10         ; Close dialogue window
  db $FF         ; End event


; -------------------------------------------------------------------------
; Ziegfried's heart attack on the Phantom Train (battle event)
; [Formerly the battle against Kefka at the Sealed Gate]

org $D0B4BA
  db $11         ; Open dialogue window at the bottom of the screen
  db $01,$D7     ; Display caption 215
  db $01,$D8     ; Display caption 216
  db $01,$FC     ; Display caption 252
  db $01,$FF     ; Display caption 255
  db $10         ; Close dialogue window
  db $FF         ; End event

; -------------------------------------------------------------------------
; Wrexsoul Event 2/2
; Battle script command: F7 19

org $D0C51D
  db $11      ; Open dialogue window at the bottom of the screen
  db $01,$FA  ; Display caption 250
  db $10      ; Close dialogue window
  db $FF      ; End event

; -------------------------------------------------------------------------
; Freespace
; Helper for Sr. Behemoth Battle Event Script

org $D0CF4A
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

; -------------------------------------------------------------------------
; Related to Ziegfried's heart attack on the Phantom Train (battle event) [?]

org $D0FE24 : db $FF,$FF,$FF,$FF,$FF
