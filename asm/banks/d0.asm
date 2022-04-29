hirom

; D0 Bank (includes battle events)

; -------------------------------------------------------------------------
; Speed up the aero animation

org $D015DE : db $89,$20
org $D015FC : db $89,$60
org $D01611 : db $89,$03

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
; Related to Ziegfried's heart attack on the Phantom Train (battle event) [?]

org $D0FE24 : db $FF,$FF,$FF,$FF,$FF
