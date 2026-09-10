hirom

; Patch: Castle Party
; Author: Leet Sketcher
; From: castle-party.ips
;
; During the scene where Sabin infiltrates the Imperial Camp
; near Doma Castle, the game repeatedly switches back and forth
; between him in the camp and Cyan in Doma. As the game switches
; back from Cyan to Sabin, sometimes the game changes the order of
; the members of Sabin's party. This is especially poignant if
; Shadow is in Sabin's party. This patch ensures that the order of
; all members in both parties is always maintained.

; We no longer "assign character to party 1" or "remove from party"
; We now explicitly switch parties instead.
org $CB0BC4
  db $C0,$F3,$02,$CC,$0B,$01 ; [x] BRL target $CB0BCC
  db $3D,$03                 ; [=] Create Shadow:03
.CB0BCC
  db $3D,$05                 ; [>] Create Sabin:05
  db $3E,$02                 ; [>] Delete Cyan:02
  db $46,$01                 ; [+] make party 1 the current party
  db $47                     ; [>] make character in slot 0 the lead
  db $45                     ; [>] refresh objects
  db $5C                     ; [>] pause until fade in/out complete
  db $91                     ; [>] pause for 15 units
  db $6B,$75,$20,$24,$02,$C0 ; [>] Load Imperial Camp
  db $59,$08                 ; [>] unfade screen at speed $08
  db $31,$82                 ; [>] begin action queue for party char 0
  db $82                     ; [>] - move down 1 tile
  db $FF                     ; [>] - END
  db $3A                     ; [>] re-enable player movement
  db $FE                     ; [>] RTL
  db $FE,$FE,$FE,$FE         ; [x] Freespace
  db $FE,$FE,$FE             ; [x] Freespace
warnpc $CB0BEB

; It looks like the changes at top here are artifacts from a bad engine,
; as they just replace shorter movement instructions with longer ones.
; The first real *change* is at $CB133E -- the rest can likely be omitted
org $CB1317
  db $02,$88                 ; [x] Begin Cyan:02 action queue, 8 bytes long, wait
  db $C3                     ; [>] - Set speed to fast
  db $94                     ; [>] - Move up 6 tiles
  db $81,$81,$81             ; [x] - Move right 3 tiles ; TODO: Why not $89
  db $80,$80                 ; [x] - Move up 2 tiles    ; TODO: Why not $84
  db $FF                     ; [>] - END
  db $39                     ; [>] Free screen
  db $DA,$12,$DB,$11,$DB,$0B ; [>] Misc event bit stuff
  db $DA,$01,$D0,$32,$42,$31 ; [>] Misc event bit stuff
  db $C0,$F3,$02,$37,$13,$01 ; [>] If something, branch to $CB1337
  db $3D,$03                 ; [>] Create Shadow:03
  db $45                     ; [>] Refresh objects
                             ; [-] (assign Shadow:03 to party 1)
.CB1337
  db $3F,$02,$00             ; [=] Assign Cyan:02 to no-party
  db $3E,$02                 ; [=] Delete Cyan:02
  db $3D,$05                 ; [=] Create Sabin:05
                             ; [-] (refresh objects)
                             ; [-] (assign Sabin:05 to party 1)
  db $46,$01                 ; [+] Make party 1 the current party
  db $47                     ; [+] Make char in slot 1 the lead
  db $45                     ; [>] Refresh objects
warnpc $CB1342

; When recruiting/meeting Cyan, instead of removing Sabin and Shadow
; from party 1 for Cyan's scene, instead just add Cyan to party 2 and
; switch to that party.

org $CB9AAE
                              ; [-] (Load current party caseword)
                              ; [-] (If shadow in ^, remove him via $CBA3B9)
  db $40,$02,$02              ; [>] Cyan:02 <- Properties 2
  db $37,$02,$02              ; [>] Cyan:02 <- Graphics 2
  db $43,$02,$04              ; [>] Cyan:02 <- Palette 4
  db $3D,$02                  ; [>] Create Cyan:02
  db $3F,$02,$02              ; [x] Cyan:02 -> Party 2 (instead of 1)
  db $D4,$E2                  ; [>] Set event bit (Recruited Cyan)
                              ; [-] (Assign Sabin:05 to NoParty)
  db $3E,$03                  ; [+] Delete Shadow:03 (???: Safe w/o Shadow in party?)
  db $3E,$05                  ; [>] Delete Sabin:05
  db $46,$02                  ; [+] Make party 2 the current party
  db $B2,$C9,$9A,$01          ; [+] JSL $CB9AC9 (NOTE: Could NOP instead)
  db $FE                      ; [+] RTL
warnpc $CB9AC9

; When transitioning to "Doma Being Poisoned" scene, just switch to party 2
; instead of swapping out Sabin/Shadow for Cyan within party 1

org $CBA0EC
                        ; [-] (Load current party caseword)
                        ; [-] (If shadow in ^, remove him via $CBA3B9)
  db $3D,$02            ; [>] Create Cyan:02
  db $46,$02            ; [+] Make party 2 the current party
  db $47                ; [>] Make slot 0 character the lead
  db $3E,$03            ; [+] Delete Shadow:03
  db $3E,$05            ; [>] Delete Sabin:05
  db $45                ; [>] Refresh objects
  db $B2,$FE,$A0,$01    ; [+] JSL $CBA0FE (NOTE: Could NOP instead)
  db $FE                ; [+] RTL
  db $FE,$FE,$FE        ; [+] Freespace
warnpc $CBA0FE
