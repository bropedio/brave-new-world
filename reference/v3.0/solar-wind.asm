hirom

; Patch: Solar Wind
; Author: Leet Sketcher
; From: solar-wind.ips
;
; $D03188:$D03200 - Battle Animation Scripts ~ "Solar Wind"
; $D1EE16:$D1EE19 - Battle Animation Pointers ~ "Solar Wind"
;
; W Wind and Spiraler both show a tornado as part of their animations.
; The Lore Quasar has a glitch wherein if you cast it before using
; either W Wind or Spiraler, the tornado will be messed up and come out
; looking like a wavy stripe pattern. This patch fixes that glitch.
; (the bug was in bnw even if triggered differently)

; These changes are from "Solar Wind", which tweaks FlareStar to make some
; extra room, then adds a single word "$8025" to the Quasar animation script
; to ensure HDMA scroll data is cleared properly

; NOTE: Animation starts at $D0313C, from pointer at $D1EE24 (#422)
org $D03188 : incbin 'solar-wind.bin' : warnpc $D03200
org $D1EE16
  dw $3198 ; (from 319A)
  dw $31A9 ; (from 31AB)
