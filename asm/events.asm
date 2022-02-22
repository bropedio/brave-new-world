hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Various event hacks

; Space freed up:
;	7 bytes at CC/FE1A
;	27 bytes at CC/FF9C
; 	20 bytes at CC/5216
;	216 bytes at CC/3434
;	18 bytes at CC/6633

; Event bits freed up:
;	DB $D6,$6F					; Set event bit $1E80($36F) [$1EF0, bit 7]
;	DB $D6,$A1					; Set event bit $1E80($3A1) [$1EF4, bit 1]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First thing's first, deprecate the auction house with $FF byte padding

org $CB4E5E
padbyte $FF : pad $CB5EC5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Fig's Kagenui fix that does something I guess

!free = $CB52E4
!postIntangir = $CB7A7C

org !postIntangir
db $B2,$E4,$52,$01         ; jump to subroutine: $CB52E4
                             
org !free
; displaced from above
db $42,$14                 ; hide NPC $14 (Intangir)
db $3E,$14                 ; delete NPC $14 (Intangir)

; new event code
db $C0,$A3,$00,$F2,$52,$01 ; skip if Shadow alive
db $81,$29                 ; remove item: Kagenui1
db $80,$02                 ; give item: Kagenui2
db $FE                     ; return from subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Modifies a map in South Figaro to make the basement inaccessible until Locke's scenario

org $CB51A5
DB $C0,$19,$80,$AC,$EC,$00	; If ($1E80($019) [$1E83, bit 1] is set), branch to CA/ECAC

; Map changes follow.
DB $73,$1D,$09,$01,$01,$57
DB $FE

; 13 bytes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Ghost shop in Cyan's Nightmare

org $CB51B2
DB $9B,$56					; Invoke shop $56
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Lowers the price for hiring Shadow at Kohlingen to 1000 GP.

org $CC7001
DB $85,$E8,$03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Overwrites a completely pointless 1-byte jump to flag Cyan as having joined the party once recruited in Sabin's scenario. This wasn't done in vanilla for some reason.

org $CB1641
DB $D4,$F2					; Set event bit $1E80($2F2) [1EDE, bit 2]
DB $FD,$FD,$FD				; NOP x3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Hides the imp in the "Choose a scenario" map when a scenario is chosen.

; Hide Locke
org $CAADC9
DB $42,$16					; Hide the imp
DB $C0,$29,$03,$B3,$5E,$00	; Return if Locke's scenario is complete.
DB $42,$10					; Hide Locke's sprite
DB $45,$FE					; Refresh objects, and return

; Hide Terra, Edgar, and Banon
DB $42,$16					; Hide the imp
DB $C0,$2B,$03,$B3,$5E,$00	; Return if Terra's scenario is complete.
DB $42,$12					; Hide Terra's sprite
DB $42,$13					; Hide Edgar's sprite
DB $42,$14					; Hide Banon's sprite
DB $45,$FE					; Refresh objects, and return

; Hide Sabin
DB $42,$16					; Hide the imp
DB $C0,$29,$03,$B3,$5E,$00	; Return if Sabin's scenario is complete.
DB $42,$11					; Hide Sabin's sprite
DB $45,$FE					; Refresh objects, and return

; If the above instructions end up causing problems, they should be removed, and everything below uncommented. This a tentative fix for hiding the imp for the last scenario chosen. It overwrites an instruction to hide object $31 - I'm not sure what object $31 is, and preliminary testing shows that removing that line doesn't affect anything in the scenario select.

;org $CAADD1
;DB $42,$16					; Hide the imp
;DB $45,$FE

; The following is documented in the event dump starting at CA/ADD5, but transferred here to make room for hiding the imp. Therefore, it's not commented.

; CAADD7
;DB $C0,$2B,$03,$B3,$5E,$00,$42,$12,$42,$13,$42,$14,$42,$31,$42,$16,$45,$FE

; CAADE9
;DB $C0,$2A,$03,$B3,$5E,$00,$42,$11,$42,$31,$42,$16,$45,$FE

; Repointing jumps to adjust for shifted code above.

;org $CA84CF
;DB $B2,$D7,$AD,$00
;DB $B2,$E9,$AD,$00

;org $CB0A22
;DB $B2,$D7,$AD,$00

;org $CB0954
;DB $B2,$E9,$AD,$00

; Repoints a dialogue pointer that was overwritten by expanding the above events.

org $CC342A
DB $C0,$55,$80,$FB,$AD,$00,$4B,$90,$04,$FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Corrects NPC behavior in Mobliz resulting from the execution of derpkid.

; Various NPC movements - no need for commentary
org $CC65F8
DB $1B,$1E,$C1,$87,$E0,$0C,$8D,$E0,$0C,$82,$E0,$10,$80,$E0,$0C,$84,$E0,$10,$86,$C2,$83,$DC,$87,$E0,$0C,$C1,$81,$E0,$0C,$FC,$1B,$FF,$1D,$18,$CF,$E0,$10,$CE,$E0,$20,$CD,$E0,$20,$CE,$E0,$08,$CD,$E0,$10,$CE,$E0,$04,$CF,$E0,$20,$FC,$15,$FF,$FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Gives a background to caption 3037

org $CA2B99
DB $4B,$DE,$0B

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes most items Locke has from the Phoenix Cave, just leaving a Phoenix Tear

org $CC3282
DB $80,$F9					; Adds Phoenix Tear to party inventory
DB $FD,$FD,$FD,$FD,$FD
DB $FD,$FD,$FD,$FD,$FD		; NOPing out the rest of the items he gives

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Axes a dialogue choice from the beginner's school

org $CC367A
DB $FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Axes the "aura" dialogue from the NPC in the Beginner's School

org $CC3429
DB $FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the thief that sell bogus info at the base of the Fanatics' Tower to sell the Alexandr esper for 32,768

org $CC51FF
DB $C0,$E5,$00,$09,$52,$02	; If ($1E80($0E5) [$1E9C, bit 5] is clear), branch to $CC5209
DB $4B,$E6,$09,$FE			; Call caption 2533, then RTS
DB $4B,$C8,$08,$B6			; Call caption 2247, then set up the choice branch below
DB $13,$52,$02,$B3,$5E,$00	; Branch to CC5213 (yes), CA5EB3 (no)
DB $85,$00,$80				; Deduct 32,768 GP from party
DB $C0,$BE,$81,$FF,$69,$01	; If they don't have enough money, branch
DB $86,$46					; Give Alexandr to the party
DB $D0,$E5					; Set event bit $1E80($0E5) [1E9C, bit 5]
DB $4B,$C9,$08,$FE			; Call caption 2248, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Optimizes Terra and Edgar during their raft trip down the Lete River with Banon

org $CB0999
DB $B2,$DB,$52,$01			; JSR $CB52DB

org $CB52DB
DB $B2,$95,$CB,$00			; Displaced code from JSR above
DB $9C,$00					; Optimize Terra
DB $9C,$04					; Optimize Edgar
DB $FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Remove the Magitek status from that portion of Cyan's dream.

org $CB93D7
DB $C0,$27,$01,$E6,$93,$01	; Branch to CB/93E6, thus not applying the M-Tek status and staying on-foot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Adds a line from Gau during the first meeting with Setzer on the Blackjack

org $CB1D97
DB $B2,$FC,$9A,$02			; JSR $CC9AFC

org $CC9AFC
DB $4B,$F8,$04,$92			; Call caption #1271 and pause for 30 units
DB $DE						; Load caseword with active party
DB $C0,$AB,$01,$0B,$9B,$02	; If Gau is not in the party, branch to $CC9B0B
DB $4B,$66,$0A,$92			; Call caption #2661 and pause for 30 units
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shifting the dialogue of some Narshe NPCs to free up dialogue space
org $CCD207
DB $4B,$99,$03,$FE

org $CCD23F
DB $4B,$9D,$03,$FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Alters Setzer's WoR recruitment scene

org $CC3C5A
DB $4B,$91,$09,$91			; Call caption 2448, then pause
DB $06,$03,$A3,$8B,$FF,$92	; Action queue for Celes
DB $4B,$92,$09,$92			; Call caption 2449, then pause
DB $06,$02,$CD,$FF,$92		; Action queue for Celes
DB $48,$93,$09,$93			; Call caption 2450
DB $06,$05,$80,$89,$80
DB $CD,$FF,$F2,$A0,$49		; Action queue for Celes, fade out song, and pause
DB $F0,$10					; Play Setzer's theme
DB $15,$08,$CF,$E0,$06
DB $CE,$E0,$08,$23,$FF,$94	; Action queue for Setzer, and pause
DB $4B,$94,$09,$F0,$10		; Call caption 2451, then play Setzer's theme

org $CC3CBE
DB $4B,$B2,$0A				; Call caption 2738

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Moves the dialogue between Kefka and the party at the Sealed Gate to before the battle

org $CB3AA8
DB $92,$B2,$AC,$38,$01		; Pause for 30 units, then JSR $CB38AC
DB $00,$08,$20,$E0,$01
DB $CE,$E0,$01,$CC,$FF		; Action queue for Terra - nod, then face up
DB $92,$3F,$00,$00			; Pause, then remove Terra from the party
DB $4B,$60,$0A				; Call caption 2655
DB $49,$F4,$CD				; Play sound effect 205 (Kefka's laugh)
DB $B0,$06,$16,$82,$1D
DB $FF,$16,$82,$1E,$FF,$B1	; These two lines = Kefka laughing animation
DB $4B,$61,$0A				; Call caption 2656
DB $4B,$62,$0A				; Call caption 2657
DB $B2,$AB,$4F,$01			; JSR $CB4FAB
DB $FD,$FD					; NOPs two unused bytes

org $CB4FAB
DB $16,$02,$80,$FF			; Kefka steps up 1 tile
DB $4B,$63,$0A				; Call caption 2658
DB $31,$02,$82,$FF			; Character in slot 1 moves down 1 tile
DB $4B,$64,$0A				; Call caption 2659
DB $92						; Pause
DB $16,$04,$04,$C7,$82,$FF	; Kefka slides back 1 tile
DB $92,$B0,$04,$16,$84,$24
DB $E0,$01,$FF,$16,$84,$25
DB $E0,$01,$FF,$B1			; These three lines = Kefka finger wagging animation
DB $49,$F4,$CD				; Play sound effect 205 (Kefka's laugh)
DB $B0,$06,$16,$82,$1D
DB $FF,$16,$82,$1E,$FF,$B1	; These two lines = Kefka laughing animation
DB $4B,$65,$0A				; Call caption 2660
DB $40,$0F,$2A,$FE			; Set Kefka's properties and add him to the party, then RTS

org $CB3ADE
DB $3F						; Re-enables swoosh sound on transition to battle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Axes dialogue after the Holy Dragon fight - kept for posterity, but handled in the dragon statue event code

;org $CC5598
;DB $B2,$9F,$1F,$02			; Call subroutine $CC1F9F
;DB $3A,$FE					; Do something, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes a woman near Owzer's mansion to only call one caption

org $CB4592
DB $4B,$0B,$04,$FE			; Call caption 1034, then RTS

; 6 bytes free at $CB4596

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the black market merchant in Zozo to not call excessive captions

org $CA951D
DB $C0,$DB,$81,$2E,$95,$00	; If lube is in rare items, branch to $CA952E
DB $4B,$27,$04				; Call caption 1062
DB $B6,$32,$95,$00			; If yes, branch to $CA9532
DB $B3,$5E,$00,$FE			; Else exit, then RTS

; CA/952E
DB $4B,$26,$04,$FE			; Call caption 1061, then RTS

; CA/9532
DB $85,$E8,$03				; Take 1000 GP from the party
DB $C0,$BE,$81,$FF,$69,$01	; If not enough cash, branch to $CB69FF
DB $4B,$28,$04				; Call caption 1063
DB $D2,$DB,$FE				; Add lube to rare items inventory, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Alters the puzzle in Daryl's Tomb to grant Daryl's Soul as the reward for completion

org $CA413D
DB $80,$E4,$FD				; Add Daryl's Soul to party inventory, and NOP

org $CA4142
DB $FD						; NOPs something dealing with a removed caption display

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes for the coliseum guy to make him sell Golem and Zoneseek

org $CB4F27
DB $C0,$53,$00,$54,$78,$01	; If the party is yet to meet Ramuh, branch to $CB7854
DB $C0,$6D,$01,$3D,$4F,$01	; If the party hasn't obtained Golem, branch to $CB4F3D
DB $C0,$6C,$01,$5A,$4F,$01	; If the party hasn't obtained Zoneseek, branch to $CB4F5A
DB $4B,$59,$0A,$FE			; Display caption 2648, then RTS

; $CB4F3D
DB $4B,$56,$0A				; Display caption 2645
DB $B6,$47,$4F,$01			; If yes, branch to $CB4F47
DB $81,$4F,$01				; Else, branch to $CB4F81
DB $85,$10,$27				; Deduct 10k GP from the party
DB $C0,$BE,$81,$FF,$69,$01	; If the party doesn't have enough cash, branch to CB/69FF
DB $F4,$8D					; Play sound effect
DB $86,$4C					; Give Golem to the party
DB $4B,$C3,$0A				; Display caption 2754
DB $D2,$6D,$FE				; Set event bit for acquiring Golem, then RTS

; $CB4F5A
DB $C0,$6B,$00,$7D,$4F,$01	; If the party has not defeated the Cranes, branch to $CB4F7D
DB $4B,$56,$0A				; Display caption 2645
DB $B6,$6A,$4F,$01			; If yes, branch to $CB4F6A
DB $81,$4F,$01				; Else, branch to $CB4F81
DB $85,$10,$27				; Deduct 10k GP from the party
DB $C0,$BE,$81,$FF,$69,$01	; If the party doesn't have enough cash, branch to CB/69FF
DB $F4,$8D					; Play sound effect
DB $86,$48					; Give Zoneseek to the party
DB $4B,$C4,$0A				; Display caption 2755
DB $D2,$6C,$FE				; Set event bit for acquiring Zoneseek, then RTS

; $CB4F7D
DB $4B,$57,$0A,$FE			; Display caption 2646, then RTS

; $CB4F81
DB $4B,$58,$0A,$FE			; Display caption 2647, then RTS

; Coliseum guy in the WoR (Bob)

; $CB4F85
DB $C0,$6C,$81,$58,$78,$01	; If the party has obtained Zoneseek, branch to $CB7858
DB $C0,$6D,$01,$9C,$4F,$01	; If the party hasn't obtained Golem, branch to $CB4F9C
DB $4B,$5A,$0A				; Display caption 2649
DB $B6,$6A,$4F,$01			; If yes, branch $CB4F6A
DB $A7,$4F,$01,$FE			; Else, branch to $CB4FA5, then RTS

; $CB4F9C
DB $4B,$5A,$0A				; Display caption 2649
DB $B6,$47,$4F,$01			; If yes, branch $CB4F47
DB $A7,$4F,$01,$FE			; Else, branch to $CB4FA7, then RTS

; $CB4FA7
DB $4B,$55,$0A,$FE			; Display caption 2644, then RTS

; Shifting a dialogue block up four bytes to deprecate the usage of caption 2424
org $CB7858
DB $4B,$7A,$09,$FE			; Display caption 2425, then return.

; As a consequence of changing the auction house to the Advanced School, random douchebag in front of it needs a change
org $CB453F
DB $4B,$08,$04,$FE			; Display caption 1031, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes Ultros in the coliseum to the respec NPC

org $CB4E5E
DB $4B,$5B,$0A				; Display caption 2650
DB $C0,$DD,$81,$72,$4E,$01	; If the party has the receipt, branch to $CB4E72
DB $4B,$5C,$0A				; Display caption 2651
DB $B6,$7D,$4E,$01			; If yes, branch to $CB4E7D
DB $23,$4F,$01,$FE			; Else, branch to $CB4F23, then RTS

; $CB4E72
DB $4B,$5D,$0A				; Display caption 2652
DB $B6,$8D,$4E,$01			; If yes, branch to $CB4E8D
DB $23,$4F,$01,$FE			; Else, branch to $CB4F23, then RTS

; $CB4E7D
DB $85,$A8,$61				; Deduct 25k GP from the party
DB $C0,$BE,$81,$FF,$69,$01	; If the party doesn't have enough cash, branch to CB/69FF
DB $D2,$DD					; Give party Receipt rare item
DB $B2,$9F,$4E,$01,$FE		; JSR $CB4E9F, then RTS

; $CB4E8D
DB $85,$60,$EA				; Deduct 60000 GP from the party
DB $C0,$BE,$81,$FF,$69,$01	; If the party doesn't have enough cash, branch to CB/69FF
DB $85,$40,$9C				; Deduct 40000 GP from the party
DB $C0,$BE,$81,$BD,$51,$01	; If the party doesn't have enough cash, branch to CB/51BD

; $CB4E9F
DB $3B						; Ready-to-go stance for the on-screen character
DB $F4,$4F,$92,$F4,$4F,$92	; Sound effect 79, like when unequipping people
DB $DE						; Load caseword with active party
DB $C0,$A0,$01,$B1,$4E,$01	; If Terra is not in the party, branch to $CB4EB1
DB $8D,$00					; Unequip Terra
DB $67,$00					; Respec Terra
DB $C0,$A1,$01,$BB,$4E,$01	; If Locke is not in the party, branch to $CB4EBB
DB $8D,$01					; Unequip Locke
DB $67,$01					; Respec Locke
DB $C0,$A2,$01,$C5,$4E,$01	; If Cyan is not in the party, branch to $CB4EC5
DB $8D,$02					; Unequip Cyan
DB $67,$02					; Respec Cyan
DB $C0,$A3,$01,$CF,$4E,$01	; If Shadow is not in the party, branch to $CB4ECF
DB $8D,$03					; Unequip Shadow
DB $67,$03					; Respec Shadow
DB $C0,$A4,$01,$D9,$4E,$01	; If Edgar is not in the party, branch to $CB4ED9
DB $8D,$04					; Unequip Edgar
DB $67,$04					; Respec Edgar
DB $C0,$A5,$01,$E3,$4E,$01	; If Sabin is not in the party, branch to $CB4EE3
DB $8D,$05					; Unequip Sabin
DB $67,$05					; Respec Sabin
DB $C0,$A6,$01,$ED,$4E,$01	; If Celes is not in the party, branch to $CB4EED
DB $8D,$06					; Unequip Celes
DB $67,$06					; Respec Celes
DB $C0,$A7,$01,$F7,$4E,$01	; If Strago is not in the party, branch to $CB4EF7
DB $8D,$07					; Unequip Strago
DB $67,$07					; Respec Strago
DB $C0,$A8,$01,$01,$4F,$01	; If Relm is not in the party, branch to $CB4EF01
DB $8D,$08					; Unequip Relm
DB $67,$08					; Respec Relm
DB $C0,$A9,$01,$0B,$4F,$01	; If Setzer is not in the party, branch to $CB4F0B
DB $8D,$09					; Unequip Setzer
DB $67,$09					; Respec Setzer
DB $C0,$AA,$01,$15,$4F,$01	; If Mog is not in the party, branch to $CB4F15
DB $8D,$0A					; Unequip Mog
DB $67,$0A					; Respec Mog
DB $C0,$AB,$01,$1F,$4F,$01	; If Gau is not in the party, branch to $CB4F1F
DB $8D,$0B					; Unequip Gau
DB $67,$0B					; Respec Gau
DB $4B,$5E,$0A,$FE			; Display caption 2653, then RTS

; $CB4F23
DB $4B,$5F,$0A,$FE			; Display caption 2654, then RTS

org $CB51BD
DB $84,$60,$EA				; Grant 60000 GP to the party
DB $C0,$2F,$02,$FF,$69,$01	; If ($1E80($22F) [$1EC5, bit 7] is clear), branch to $CB69FF
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes a now-blank dialogue caption from the save point tutorial dude

org $CC33E4
DB $FE

; CC33E5 - CC33E7 are now free. Whoopdee-doo.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Ziegfried's heart attack on the Phantom Train (battle event - formerly the battle against Kefka at the Sealed Gate)

org $D0B4BA
DB $11						; Open dialogue window at the bottom of the screen
DB $01,$D7					; Display caption 215
DB $01,$D8					; Display caption 216
DB $01,$FC					; Display caption 252
DB $01,$FF					; Display caption 255
DB $10						; Close dialogue window
DB $FF						; End event

org $D0FE24
DB $FF,$FF,$FF,$FF,$FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Holds the player's hand like dear old grandma by needlessly restoring their HP after
; the IAF fight

org $CA5A5D
DB $B2,$56,$B1,$24			; JSR $EEB156

org $EEB156
DB $35,$30,$35,$31			; Displaced from JSR above
DB $B2,$BD,$CF,$00,$FE		; JSR $CACFBD, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prevents the NPC at the base of the Fanatics' Tower from jumping, since he's been killed

org $CC51E9
DB $FE

; CC/51EA to CC/51F6 is free space now

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Consolidates all the Grand Stairway treasures into one event

org $CB30DB
DB $4B,$97,$06				; Display caption 1686
DB $93						; 45 unit pause
DB $F4,$1B					; Sound effect
DB $4B,$7D,$06				; Display caption 1660
DB $80,$AB					; Add Fire Scroll to party inventory
DB $80,$AC					; Add Water Scroll to party inventory
DB $80,$AD					; Add Bolt Scroll to party inventory
DB $80,$43					; Add Ninja Star to party inventory
DB $D4,$4D,$FE				; Set event bit $24D, then return

; CB/30EF to CB/313F is free space now

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Re-writes the save point events to free up a bit of space
; Also introduces recovery points

org $CC9AEB
DB $C0,$B5,$81,$B3,$5E,$00	; If ($1E80($1B5) [$1EB6, bit 5] is set), branch to $CA5EB3
DB $F4,$D1					; Plays sound effect 209
DB $55,$80					; Flash screen blue
DB $D2,$B5					; Set event bit $1E80($1B5) [$1EB6, bit 5]
DB $D2,$BF					; Set event bit $1E80($1BF) [$1EB7, bit 7]
DB $3A						; Enable player to move while commands execute
;DB $C0,$33,$01,$01,$9B,$02	; If ($1E80($133) [$1EA6, bit 3] is clear), branch to $CC9B01
DB $FE						; RTS

;DB $D2,$33					; Set event bit $1E80($133) [$1EA6, bit 3]
;DB $4B,$0A,$00				; Display caption #9 with branch
;DB $B6,$0E,$9B,$02			; If top branch was selected, jump to $CC9B0E
;DB $B3,$5E,$00,$FE			; If bottom branch was selected, jump to $CA5EB3; RTS

;DB $4B,$D4,$06,$FE			; Call caption 1747, then RTS

org $CB51C7
DB $C0,$B5,$81,$B3,$5E,$00	; If ($1E80($1B5) [$1EB6, bit 5] is set), branch to $CA5EB3
DB $F4,$E9					; Play sound effect 233
DB $B2,$BD,$CF,$00			; JSR $CACFBD
DB $B2,$F3,$9A,$02,$FE		; JSR $CC9AF3, then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Stops the soldier on the right side of South Figaro from moving, and thus prevents
; an exploit allowing players to bypass most of Locke's scenario

org $CAEBC7
DB $C0,$27,$01,$DA,$EB,$00	; If ($1E80($127) [$1EA4, bit 7] is clear), branch to $CAEBDA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Adds a line for Locke after his "talk" with Celes at Albrook

org $CC624F
DB $B2,$D8,$51,$01			; JSR $CB51D8

org $CB51D8
DB $92						; Pause for 30 frames
DB $4B,$84,$05				; Call caption 1411
DB $94						; Pause for 60 frames
DB $B5,$10,$F2,$A0			; Displaced from JSR above
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Has Leeroy give Relm the Rainbow Brush and Czarina Gown after defeating Hidon

org $CB73DA
DB $B2,$E2,$51,$01			; JSR $CB51E2

org $CB51E2
DB $94,$4B,$62,$0B			; Displaced from JSR above
DB $80,$40					; Adds the Rainbow Brush to the party's inventory
DB $80,$99					; Adds the Czarina Gown to the party's inventory
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes Shadow's equipment at Baren Falls

org $CBC01E
DB $8D,$03					; Remove Shadow's equipment (replaces a 10-unit pause)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes Arvis' caption to act as an unequipper after the Battle of Narshe

org $CCD1E7
DB $4B,$DC,$06

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Trolls the player a bit by sending them back to the airship at the three switches
; if they skipped Myria or Inferno

org $CC19E8
DB $C0,$2F,$02,$EB,$51,$01	; If ($1E80($22F) [$1EC5, bit 7] is clear), branch to $CB51EB

org $CB51EB
DB $C9,$BD,$80,$74,$80		; If Inferno and Myria are dead (bits set)...
DB $7D,$05,$00				; ...branch to $CA057D

; Otherwise, boot the party back to the airship and call caption #11
DB $95,$B2,$04,$21,$02		; JSR $CC2104
DB $4B,$0C,$00,$FE			; Display caption #11

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Heals the party before the fight with Nimufu

org $CADA48
DB $B2,$4A,$B1,$24			; JSR $EEB14A
DB $FD,$FD,$FD				; NOP NOP NOP

org $EEB14A
DB $B2,$BD,$CF,$00			; JSR $CACFBD
DB $4D,$51,$3F				; Invoke Nimufu battle (displaced code)
DB $B2,$A9,$5E,$00,$FE		; JSR $CA5EA9 (displaced code), then RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Add the Imperial sword to the party's inventory during the escape from the FC
; and optimize it onto Celes. Then enable Shock via event bit.
; Clear the event bit after the escape sequence (technically done on Solitary Island)

org $CAE3F1
DB $B2,$36,$B1,$24			; JSR $EEB136

org $CA5334
DB $B2,$41,$B1,$24			; JSR $EEB141

org $EEB136
DB $F0,$1F,$D4,$BC			; Displaced code from JSR above
DB $80,$13					; Add Imperial sword to party's inventory
DB $9C,$06					; Optimize Celes' equipment
DB $D0,$E4					; Set event bit $1E80($0E4) [1E9C, bit 4]
DB $FE

; $EEB141
DB $B2,$4B,$4B,$01			; Displaced code from JSR above
DB $D1,$E4					; Clear event bit $1E80($0E4) [1E9C, bit 4]
DB $D6,$07					; Flag the cider merchant to reappear in the WoR
DB $FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Various dialogue and event changes for retrieving Leo's Crest

; Cider merchant
org $CB51FC
DB $B2,$B0,$B0,$24,$FE		; JSR $EEB0B0

org $EEB0B0
DB $C0,$A4,$00,$7D,$7D,$00	; If ($1E80($0A4) [$1E94, bit 4] is clear), branch to $CA7D7D
DB $4B,$F5,$00				; Display caption #244
DB $DE						; Load caseword with characters in current party
DB $C9,$A6,$81,$D0,$81		; If Celes is in the party and you have the Cider...
DB $C3,$B0,$24				; branch to $EEB0C3
DB $FE						; RTS

; $EEB0C3
DB $4B,$F7,$00				; Display caption #246
DB $F4,$8D					; Sound effect
DB $D3,$D0					; Lose the Cider
DB $D2,$E1					; Obtain Leo's Spirits
DB $FE						; Return

; Leo's grave
org $CC0977
DB $C9,$B4,$81,$B0,$81		; If you're facing up and pressing A...
DB $CD,$B0,$24,$FE			; branch to $EEB0CD

org $EEB0CD
DB $DE						; Load caseword with characters in current party
DB $C0,$A6,$01,$32,$B1,$24	; If Celes is not in the party, branch to $EEB132
DB $C0,$E1,$01,$26,$B1,$24	; If you don't have Leo's Spirits, branch to $EEB126
DB $B2,$AC,$C6,$00			; JSR $CAC6AC
DB $B2,$34,$2E,$01			; JSR $CB2E34
DB $3C,$06,$FF,$FF,$FF		; Set up party as follows: Celes, 3x empty
DB $32,$04,$C2,$82,$CC,$FF	; Move character $32 down/left, face up
DB $34,$04,$C2,$A2,$CC,$FF	; Move character $34 down, face up
DB $33,$04,$C2,$A1,$CC,$FF	; Move character $33 down/right, face up
DB $93						; Pause for 45 units
DB $06,$02,$21,$FF			; Celes bows her head
DB $94						; Pause for 60 units
DB $4B,$60,$0B				; Display caption #2911
DB $92						; Pause for 30 units
DB $06,$02,$1B,$FF			; Celes puts her hand up
DB $91						; Pause for 15 units
DB $F4,$E9					; Play sound effect
DB $94						; Pause for 60 units
DB $06,$02,$04,$FF			; Celes puts her hand back down
DB $92						; Pause for 30 units
DB $F4,$8D					; Sound effect
DB $4B,$61,$0B				; Display caption #2912
DB $80,$B0					; Add Leo's Crest to party's inventory
DB $D3,$E1					; Remove Leo's Spirits
DB $32,$02,$80,$FF			; Move character $32 up/right
DB $34,$02,$A0,$FF			; Move character $34 up
DB $33,$02,$A3,$FF			; Move character $33 up/left
DB $92						; Pause for 30 units
DB $4B,$29,$05				; Display caption #1320
DB $B2,$2B,$2E,$01			; JSR $CB2E2B
DB $B2,$95,$CB,$00			; JSR $CACB95
DB $FE						; RTS

; $EEB132
DB $4B,$45,$08,$FE			; Display caption #2116

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes a conditional for a scene during Gau's dress-up
; Also modifies the scenes to avoid clustering up the party.

org $CB5FB7
DB $B2,$87,$B0,$24			; JSR $EEB087

org $CB5FCB
DB $FD,$FD,$FD,$FD,$FD,$FD,$FD
DB $FD,$FD,$FD,$FD,$FD,$FD,$FD

org $CB60A4
DB $E1						; Load CaseWord with recruited characters
DB $C1,$A1,$01,$A4,$01		; If Locke or Edgar are absent...
DB $C0,$60,$01				; branch to $CB60C0
DB $FD,$FD,$FD,$FD,$FD		; Five NOPs
DB $15						; Change character action queue to NPC #5 (Edgar)

org $CB60B9
DB $12						; Change character action queue to NPC #2 (Locke)

org $CB61C8
DB $E1						; Load CaseWord with recruited characters

org $CB61F5
DB $15						; Change character action queue to NPC #5 (Edgar)

org $CB6203
DB $12						; Change character action queue to NPC #2 (Locke)

org $CB6214
DB $12						; Change character action queue to NPC #2 (Locke)

org $CB621D
DB $15						; Change character action queue to NPC #5 (Edgar)

org $CB622A
DB $12						; Change character action queue to NPC #2 (Locke)

org $CB623D
DB $12						; Change character action queue to NPC #2 (Locke)

org $CB6242
DB $15						; Change character action queue to NPC #5 (Edgar)

org $CB6246
DB $12						; Change character action queue to NPC #2 (Locke)

org $EEB087
DB $3F,$00,$00				; Remove Terra from party
DB $3F,$01,$00				; Remove Locke from party
DB $3F,$02,$00				; Remove Cyan from party
DB $3F,$03,$00				; Remove Shadow from party
DB $3F,$04,$00				; Remove Edgar from party
DB $3F,$06,$00				; Remove Celes from party
DB $3F,$07,$00				; Remove Strago from party
DB $3F,$08,$00				; Remove Relm from party
DB $3F,$09,$00				; Remove Setzer from party
DB $3F,$0A,$00				; Remove Mog from party
DB $3F,$0C,$00				; Remove Gogo from party
DB $3F,$0D,$00				; Remove Umaro from party
DB $B2,$AC,$C6,$00			; JSR $CAC6AC
DB $FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Unequips Umaro via airship NPCs

org $CC3591					; Unequip everyone
DB $B2,$53,$B0,$24			; JSR $EEB053
DB $92						; Pause for 30 units
DB $3A						; Enable player to move while event commands execute
DB $FE						; RTS

org $CC3664					; Unequip those not in the party
DB $B2,$66,$B0,$24			; JSR $EEB066
DB $92						; Pause for 30 units
DB $3A						; Enable player to move while event commands execute
DB $FE						; RTS

org $EEB053
DB $E1						; Load CaseWord with recruited characters
DB $C0,$AC,$01,$5C,$B0,$24	; If ($1E80($1AC) [$1EB5, bit 4] is clear), branch to $EEB05C
DB $8D,$0C					; Remove all equipment from character $0C (Gogo)
DB $E1						; Load CaseWord with recruited characters
DB $C0,$AD,$01,$B3,$5E,$00	; If ($1E80($1AD) [$1EB5, bit 4] is clear), branch to $CA5EB3
DB $8D,$0D					; Remove all equipment from character $0D (Umaro)
DB $FE						; RTS

; $EEB066
DB $E1						; Load CaseWord with recruited characters
DB $C0,$AC,$01,$76,$B0,$24	; If ($1E80($1AC) [$1EB5, bit 4] is clear), branch to $EEB076
DB $DE						; Load CaseWord with characters in active party
DB $C0,$AC,$81,$76,$B0,$24	; If ($1E80($1AC) [$1EB5, bit 4] is set), branch to $EEB076
DB $8D,$0C					; Remove all equipment from character $0C (Gogo)
DB $E1						; Load CaseWord with recruited characters
DB $C0,$AD,$01,$B3,$5E,$00	; If ($1E80($1AD) [$1EB5, bit 4] is clear), branch to $CA5EB3
DB $DE						; Load CaseWord with characters in active party
DB $C0,$AD,$81,$B3,$5E,$00	; If ($1E80($1AD) [$1EB5, bit 4] is set), branch to $CA5EB3
DB $8D,$0D					; Remove all equipment from character $0D (Umaro)
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the caption call for an NPC at the Beginner's School

org $CCE5F1
DB $4B,$86,$02,$FE			; Display caption #645

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Unequips all characters not in the party after events at Zozo.

org $CAAC86
DB $B2,$34,$B0,$24			; JSR $EEB048

org $EEB034
DB $B2,$95,$CB,$00			; JSR $CACB95 - displaced from JSR above
DB $B2,$A4,$35,$02			; JSR $CC35A4 - remove gear from non-party characters
DB $8D,$03					; Remove equipment from Shadow
DB $FE						; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Makes Locke required to receive either the Apocalypse or Illumina.

org $CC0B1E
DB $C0,$27,$01,$41,$AF,$24	; If ($1E80($127) [$1EA4, bit 7] is clear), branch to $EEAF41

org $EEAF41
DB $DE						; Load caseword with characters in current party
DB $C1,$B6,$80,$A1,$01		; If ($1E80($0B6) [$1E96, bit 6] is set) or ($1E80($1A1) [$1EB4, bit 1] is clear)...
DB $6C,$0B,$02				; ...branch to $CC0B6C
DB $C0,$27,$01,$24,$0B,$02	; If ($1E80($127) [$1EA4, bit 7] is clear), branch to $CC0B24

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A series of events to give Edgar the Autocrossbow schematics

; Chancellor breadcrumb
org $CA67F1
DB $BE,$01,$01,$52,$41		; If Edgar is in the current CaseWord, call subroutine $CB5201

org $CB5201
DB $C1,$DC,$81,$A4,$00		; If ($1E80($1DC) [$1EBB, bit 4] is set) or ($1E80($0A4) [$1E94, bit 4] is clear)...
DB $FF,$67,$00				; ...branch to $CA67FF
DB $4B,$75,$06,$FE			; Display caption 1652

; Soldier - grants the schematics in the WoR
; $CB520D
DB $C0,$A4,$00,$D8,$75,$00	; If ($1E80($0A4) [$1E94, bit 4] is clear), branch to $CA75D8
DB $4B,$84,$06				; Display caption 1667
DB $C0,$DC,$81,$B3,$5E,$00	; If ($1E80($1DC) [$1EBB, bit 4] is set, branch to $CA5EB3
DB $DE						; Load caseword with characters in current party
DB $C0,$A4,$01,$B3,$5E,$00	; If ($1E80($1A4) [$1EB4, bit 4] is clear), branch to $CA5EB3
DB $4B,$77,$06				; Call caption 1654
DB $D2,$DC,$FE				; Set event bit $1E80($1DC) [$1EBB, bit 4]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Doubles the effectiveness of the fish used to save Cid's life

org $CA539A					; Yummy fish
DB $E9,$07,$40,$00

org $CA53A6					; Just a fish
DB $E9,$07,$20,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes the magic only gimmick from the Fanatics' Tower

org $CC5173
DB $B9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes Locke's head nod when recruiting him in the WoR

org $CC2BC4
DB $FD,$FD,$FD,$FD
DB $FD,$FD,$FD,$FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Swaps the places of Fenrir and Palidor

org $CA55EF
DB $86,$4E					; Give Fenrir to the party

org $CC4ADA
DB $86,$3F					; Give Palidor to the party

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Adds an option to the Falcon's wheel to search out Doom Gaze

org $CA00CA
DB $B2,$29,$52,$01			; JSR $CB5229

org $CAF554					; Event called when at the helm of either airship
DB $C0,$70,$81,$30,$52,$01	; If ($1E80($170) [$1EAE, bit 0] is set), branch to $CB5230

org $CB5229
DB $D0,$E2					; Set event bit $1E80($0E2) [1E9C, bit 2]
DB $78,$31,$78,$12			; Displaced code
DB $FE						; RTS

; $CB5230
DB $C1,$E2,$80,$A4,$00		; If ($1E80($0E2) [$1E9C, bit 2] is set) or ($1E80($0A4) [$1E94, bit 4] is clear)...
DB $6E,$F5,$00				; ...branch to $CAF56E
DB $4B,$A5,$86				; Display caption 1700
DB $B6,$8D,$F5,$00			; If choice 1 was selected, take off
DB $46,$52,$01				; If choice 2 was selected, invoke combat against Doom Gaze
DB $B3,$5E,$00,$FE			; Else, just return

; $CB5246
DB $B2,$01,$AF,$24,$FE		; JSL $EEAF01

org $EEAF01
DB $6A,$01,$04,$9E,$33,$01	; Load map $0001 (World of Ruin) after fade out, (upper bits $0400), place party at (158, 51), facing up, party is in the airship
DB $29,$58,$0C,$30,$4C,$20
DB $2C,$10,$24,$10,$34,$10
DB $54,$10,$49,$24,$40,$A0
DB $24,$30,$34,$40,$54,$30
DB $40,$80,$49,$60,$40,$80
DB $24,$30,$D9				; Wild airship movement
DB $D2,$11,$36,$11,$08,$C0	; Load map $0011 (Falcon, upper deck), position (17, 08), mode $C0
DB $4D,$5D,$29				; Invoke battle against Doom Gaze
DB $B2,$A9,$5E,$00			; Check for death
DB $B7,$48,$E3,$00,$00		; If ($1DC9($048) [$1DD2, bit 0] is clear), branch to $CA00E3
DB $96						; Restore screen from fade
DB $C0,$27,$01,$9D,$00,$00	; If ($1E80($127) [$1EA4, bit 7] is clear), branch to $CA009D

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; During Locke's conversation with Celes at the Opera House, removes a check that would display an extra caption if the player viewed Locke's flashbacks in Kohlingen
; The extra caption is now displayed regardless

org $CABA8D
DB $FD,$FD,$FD,$FD,$FD,$FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Wrexsoul events

; Battle script command: F7 19

org $D0C51D
DB $11						; Open dialogue window at the bottom of the screen
DB $01,$FA					; Display caption 250
DB $10						; Close dialogue window
DB $FF						; End event

; Battle script command: F7 08

org $D0A6B4
DB $11						; Open dialogue window at the bottom of the screen
DB $01,$FB					; Display caption 251
DB $10						; Close dialogue window
DB $FF						; End event

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Makes game overs exit to the title screen

org $CCE5EC
DB $A9						; Call title screen
DB $AB						; Call loading screen
DB $4F						; Exit current location (seems to just exit the current event,
DB $FE						; like $FE without actually returning anywhere)
DB $FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes a dialogue branch that no longer exists

org $CB757F
DB $FE						; 7 bytes of free space after this return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes an encounter at Narshe from a dinosaur to two lobos

org $CC9BF1
DB $4D,$02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Blocks an exit so Atma is a required boss

org $CC18BE					; Atma sequence starts at $CC18B4
DB $B2,$4B,$52,$01			; JSR $CB524B

org $CB524B
DB $42,$10,$DD,$BD			; Displaced code from originating location
DB $D0,$E1					; Set event bit $1E80($0E1) [1E9C, bit 1]
DB $FE						; RTS

; $CB5252
DB $C0,$E1,$80,$5C,$13,$02	; If ($1E80($0E1) [$1E9C, bit 1] is set), branch to $CC135C
DB $31,$82					; Open action queue for on-screen character
DB $80,$FF					; Move character up 1 tile, end queue
DB $4B,$FB,$00				; Caption 250
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Extends opera house timer by one minute
; Disabled for now, but left here in case it needs to be re-instated

;org $CABA02
;DB $A0,$60,$54

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Kaiser's monologue before the encounter starts (battle event)

; Battle script command: F7 0B

org $D0A851
DB $11						; Open dialogue window at the bottom of the screen
DB $01,$D4					; Display caption 212
DB $01,$D5					; Display caption 213
DB $01,$D6					; Display caption 214
DB $10						; Close dialogue window
DB $FF						; End event

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Sabin suplexing the Soul Train event, ripped wholesale from the MMMMMMAGIC!? event.
; Terra = Sabin
; Edgar = Cyan
; Locke = Shadow

; 173 bytes long

; Battle script command: F7 22

;org $D09844
;DB $95,$E7					; Changes battle event pointer to $D0CF4A

;org $D095E7					; The below comments need confirming/cleaning up.
;DB $0E						; Begin action queue(s).
;DB $03,$02					; Queue for Cyan.
;DB $92,$9F					; Character move 5 tiles right/2 tiles down with a suprised face and finish his move with a jump.
;DB $04,$03					; Queue for Shadow.
;DB $BA,$9F					; Character jump once. After he has his "ready to fight" pose.
;DB $0F						; Execute queue(s).
;DB $0E						; Begin action queue(s).
;DB $03,$05					; Queue for Sabin.
;DB $98,$A1					; Character turn/face left.
;DB $04,$03					; Queue for Shadow.
;DB $C8,$9F					; Character jump 4 tiles right/ 1 tile down and bounce when he lands.
;DB $0F						; Execute queue(s).
;DB $11						; Open dialogue window at the bottom of the screen.
;DB $01,$1E					; Display message $1E at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$02					; Queue for Cyan.
;DB $E1,$9F					; Character turn 2 times on himself with arms raised.
;DB $0F						; Execute queue(s).
;DB $01,$2D					; Display message $2D at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $FF,$9F					; Character turn/face left and then turn/face right.
;DB $0F						; Execute queue(s).
;DB $01,$2E					; Display message $2E at the bottom of the screen.
;DB $01,$4F					; Display message $4F at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $17,$A0					; Character with a suprised face jump three times.
;DB $0F						; Execute queue(s).
;DB $01,$50					; Display message $50 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $29,$A0					; Character move 2 tiles up/1 tile right and face up.         
;DB $04,$02					; Queue for Cyan.
;DB $3F,$A0					; Character move 2 tiles up/1 tile left and face up.
;DB $0F						; Execute queue(s).
;DB $01,$51					; Display message $51 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$02					; Queue for Cyan.
;DB $55,$A0					; Character jumps 2 tiles left and face left.
;DB $04,$03					; Queue for Shadow.
;DB $98,$A1					; Character turn/face left.
;DB $0F						; Execute queue(s).
;DB $01,$53					; Display message $53 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$05					; Queue for Sabin.
;DB $6B,$A0					; Character move 4 tiles right/1 tile down with head down.
;DB $04,$02					; Queue for Cyan.
;DB $92,$A1					; Character turn/face down.
;DB $05,$03					; Queue for Shadow.
;DB $92,$A1					; Character turn/face down.
;DB $0F						; Execute queue(s).
;DB $01,$54					; Display message $54 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $83,$A0					; Character jump 1 tile left/move 2 tile down/face down.
;DB $04,$02					; Queue for Cyan.
;DB $A6,$A0					; Character turn right/fall down/get up and face down.
;DB $0F						; Execute queue(s).
;DB $01,$55					; Display message $55 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$02					; Queue for Cyan.
;DB $C7,$A0					; Character move down 3 tiles
;DB $0F						; Execute queue(s).
;DB $01,$56					; Display message $56 at the bottom of the screen.
;DB $01,$96					; Display message $96 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $DD,$A0					; Character jump 2 tiles down/2 tiles right/face left.
;DB $0F						; Execute queue(s).
;DB $01,$D7					; Display message $D7 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$05					; Queue for Sabin.
;DB $F3,$A0					; Character eyes blink.
;DB $0F						; Execute queue(s).
;DB $01,$D8					; Display message $D8 at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$05					; Queue for Sabin.
;DB $02,$A1					; Character eyes blink/character turn left.
;DB $0F						; Execute queue(s).
;DB $01,$FC					; Display message $FC at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $A4,$A1					; Character turn/face up.
;DB $04,$02					; Queue for Cyan.
;DB $A4,$A1					; Character turn/face up.  
;DB $05,$05					; Queue for Sabin.
;DB $4D,$A1					; Character move up 2 tiles/left 1 tile/face down/do a wink/jump left 3 tiles/face right. (jumps back to his postion in battle formation).*
;DB $0F						; Execute queue(s).  
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $11,$A1					; Character slowly go down 1 tile while keeping his "open mouth" pose (facing down).
;DB $04,$02					; Queue for Cyan.
;DB $11,$A1					; Character slowly go down 1 tile while keeping his "open mouth" pose (facing down).  
;DB $0F						; Execute queue(s).
;DB $01,$FD					; Display message $FD at the bottom of the screen.
;DB $0E						; Begin action queue(s).
;DB $03,$03					; Queue for Shadow.
;DB $31,$A1					; Character jumps 4 tiles up/5 tiles left with raised harms/face right. (jumps back to his position in battle formation).**
;DB $04,$02					; Queue for Cyan.
;DB $31,$A1					; Character jumps 5 tiles up/1 tile left with raised harms/face right. (jumps back to his position in battle formation).**
;DB $0F						; Execute queue(s).  
;DB $10						; Close dialogue window at the bottom of the screen.                
;DB $FF						; End of event.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Custom event when trying to enter Kefka's Tower

; Removes the Pendant from the party's rare items after the Floating Continent

org $CA4F40
DB $D3,$E3,$FD

; Removes the stupid hand up thing Edgar does on the airship

org $CA0258
DB $04,$84,$C2,$82,$CE,$FF

; Puts the Pendant in the party's rare items once the Gem Box chest has been looted

org $CC5440					; Originally the event in front of the Gem Box chest
DB $C0,$DA,$82,$B3,$5E,$00	; If ($1E80($2DA) [$1EDB, bit 2] is set), branch to $CA5EB3 (simply returns)
DB $B2,$60,$52,$01			; JSR $CB5260

org $CB5260
DB $F4,$A6					; Sound effect
DB $73,$07,$07,$01,$01,$12	; Opens the chest
DB $C0,$DA,$82,$14,$00,$00	; If ($1E80($2DA) [$1EDB, bit 3] is set), branch to $CA0014
DB $D2,$E3					; Adds Pendant to the player's rare items
DB $4B,$C1,$0A				; Caption 2752
DB $D4,$DA					; Set event bit $1E80($2DA) [$1EDB, bit 2]
DB $DC,$99					; Set event bit $1E80($699) [$1F53, bit 1]
DB $FE						; RTS

; Bits used:
; $127 - always clear, used to ensure branching 100% of the time
; $2DB - defeated the Magi Master at the top of the Fanatics' Tower
; $0E0 - witnessed the breadcrumb scene leading the party to the Fanatics' Tower

org $CA025E
DB $C0,$27,$01,$50,$AF,$24	; If $1E80($127) [$1EA4, bit 7] is clear, branch to $EEAF50

org $EEAF50
DB $4B,$A0,$0B,$92			; Dialogue and pause overwritten in initial branch
DB $C0,$E0,$80,$B8,$AF,$24	; If ($1E80($0E0) [$1E9C, bit 0] is set), branch to $EEAFB8
DB $C0,$DB,$82,$64,$02,$00	; If ($1E80($2DB) [$1EDB, bit 3] is set), branch to $CA0264
DB $09,$88,$CF,$E0,$12		; Action for Setzer
DB $CE,$E0,$04,$63,$FF,$92
DB $4B,$FC,$05				; Caption 1531
DB $04,$84,$E0,$04,$CF,$FF	; Action for Edgar
DB $06,$84,$E0,$04,$23,$FF	; Action for Celes
DB $4B,$FD,$05				; Caption 1532
DB $93
DB $06,$84,$E0,$02,$CF,$FF	; Action for Celes
DB $94
DB $09,$04,$E0,$10,$24,$FF	; Action for Setzer
DB $4B,$BD,$0A				; Caption 2748
DB $04,$07,$E0,$0B,$22		; Action for Edgar
DB $E0,$50,$04,$FF
DB $09,$04,$E0,$06,$63,$FF	; Action for Setzer
DB $4B,$9F,$06				; Caption 1694
DB $09,$84,$E0,$06,$47,$FF	; Action for Setzer
DB $06,$05,$E0,$1C			; Action for Celes
DB $01,$22,$FF
DB $4B,$A0,$06				; Caption 1695
DB $D0,$E0					; Set event bit $1E80($0E0) [1E9C, bit 0]
DB $95,$B2,$03,$21,$02,$FE	; JSR $CC2103

; $EEAFB8
DB $C0,$DB,$82,$FD,$AF,$24	; If ($1E80($2DB) [$1EDB, bit 3] is set), branch to $EEAFFD
DB $09,$08,$CF,$E0,$12		; Action for Setzer
DB $CE,$E0,$04,$63,$FF,$94
DB $04,$04,$E0,$30,$20,$FF	; Action for Edgar
DB $06,$04,$E0,$28,$1E,$FF	; Action for Celes
DB $93
DB $4B,$BE,$0A				; Caption 2749
DB $09,$02,$58,$FF			; Action for Setzer
DB $4B,$A2,$06				; Caption 1697
DB $93
DB $06,$07,$E0,$04,$01		; Action for Celes
DB $E0,$04,$18,$FF
DB $04,$07,$E0,$16,$04		; Action for Edgar
DB $E0,$30,$21,$FF			; Action for Edgar
DB $93
DB $4B,$A1,$06				; Caption 1696
DB $95,$B2,$03,$21,$02,$FE	; JSR $CC2103

; $EEAFFD
DB $04,$82,$CF,$FF			; Action for Edgar
DB $4B,$BF,$0A				; Caption 2750
DB $06,$05,$1F,$E0,$1A		; Action for Celes
DB $CF,$FF
DB $4B,$FF,$05				; Caption 1534
DB $94
DB $F6,$81,$02,$C0
DB $94
DB $F4,$50					; Play sound effect
DB $B2,$1B,$D0,$00,$B5,$0A	; Screen flash
DB $B2,$21,$D0,$00
DB $94
DB $F6,$81,$02,$FF
DB $06,$04,$E0,$4A,$22,$FF	; Action for Celes
DB $4B,$C0,$0A				; Caption 2751
DB $C0,$27,$01,$64,$02,$00	; If $1E80($127) [$1EA4, bit 7] is clear, branch to $CA0264

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Swap the order of the choices on the Blackjack so fly around is the first option

org $CAF582
DB $B6,$8D,$F5,$00
DB $17,$58,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Pops up Shadow's naming screen earlier in Sabin's scenario

org $CB0AA2
DB $FD,$FD,$FD,$FD			; Make it so Sabin doesn't face the camera for no reason

org $CB0AAE
DB $C0,$0B,$01
DB $BC,$0A,$01				; Branches to assigned Shadow caption

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the order of the yes/no choices for swapping party members on the airship

org $CAF5A0
DB $B6,$A8,$F5,$00,$B3,$5E,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Various dialogue reassignments

org $CA03B0
DB $4B,$93,$8B

org $CA759C
DB $4B,$63,$0B

org $CA4126
DB $4B,$C0,$09

org $CA411B
DB $4B,$BD,$09

org $CA4110
DB $4B,$BA,$09

org $CA40AD
DB $4B,$BB,$09

org $CB450F
DB $FE

org $CA5FAC
DB $4B,$63,$0B,$FE

org $CBFE4A
DB $4B,$AF,$0A

org $CBB1A7
DB $4B,$8A,$02

org $CB1FF9
DB $4B,$20,$05

org $CCC2BB
DB $4B,$28,$05

org $CCC241
DB $4B,$28,$05

org $CCD2A7
DB $4B,$8C,$03

org $CB78B0
DB $67,$65,$02

org $CB7D04
DB $4B,$E6,$09

org $CB4334
DB $4B,$90,$03

org $CB433C
DB $4B,$90,$03

org $CB45D7
DB $4B,$10,$04,$FE
DB $FD,$FD,$FD,$FD,$FD,$FD

org $CCC285
DB $4B,$90,$03

org $CB6698
DB $4B,$08,$0B

org $CA8FB4
DB $4B,$8F,$0B

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Emperor Gestahl's portrait dialogue change

org $CB4B6F
DB $81

org $CB4B83
DB $81

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Calls an alternate tentacle pack if Sabin has not been recruited

org $CA6AE4
DB $B2,$78,$52,$01			; JSR $CB5278
DB $FD

org $CB5278
DB $9C,$04					; Put optimum equipment on Edgar
DB $C0,$8A,$02,$84,$52,$01	; If $1E80($28A) [$1ED1, bit 2] is clear, branch to $CB5284
DB $4D,$54,$37				; Battle against tentacles with Sabin
DB $FE						; RTS

; $CB5284
DB $4D,$53,$37				; Battle against tentacles without Sabin
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Starts Relm with the dog block status in the WoR if Shadow is dead

org $CB4E25
DB $B2,$88,$52,$01			; JSR $CB5288

org $CB5288
DB $C0,$A3,$00,$92,$52,$01	; If $1E80($0A3) [$1E9F, bit 3] is clear, branch to $CB5292
DB $89,$08,$00,$40			; Inflict dog block status on Relm
DB $B2,$95,$CB,$00			; JSR $CACB95
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Starts the party with 5 dried meat rather than 2 sleeping bags

org $CCA00A
DB $B2,$97,$52,$01			; JSR $CB5297

org $CB5297
DB $80,$FE
DB $80,$FE
DB $80,$FE
DB $80,$FE
DB $80,$FE					; Add dried meat x5 to inventory
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prevents Shadow from randomly running off

org $CA96B7
DB $B8

org $CB1B03
DB $B8

org $CB3143
DB $B8

org $CB4A85
DB $B8

org $CBBE60
DB $B8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes the odd finger wag Edgar does at Sabin's cabin

org $CA81C3
DB $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes most cases of WoB level averaging
; Changes WoR level averaging to set character's level equal to 18 if under
; Uses event command $66, written in set_level.asm

org $CA4871	; Gau, WoR recruitment
DB $66

org $CA5304	; Celes, WoR recruitment
DB $66

org $CA6AD3	; Edgar, WoR recruitment
DB $66

org $CAA6A9	; Terra, after IMTRF
DB $FD,$FD

org $CAC466	; Gau, after IMTRF
DB $FD,$FD

org $CAC47A	; Cyan, after IMTRF
DB $FD,$FD

org $CAC48E	; Edgar, after IMTRF
DB $FD,$FD

org $CAC4A2	; Sabin, after IMTRF
DB $FD,$FD

org $CB4E0E	; Relm, WoR recruitment
DB $66

org $CB7954	; Shadow, WoR recruitment
DB $66

org $CC08E2	; Thamasa, after Leo dies (all absent characters)
DB $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD

org $CC093D	; Mog, after Leo dies (if recruited)
DB $FD,$FD

org $CC3188	; Locke, WoR recruitment
DB $66

org $CC3A32	; Mog, WoR recruitment
DB $66

org $CC3D52	; Setzer, WoR recruitment
DB $66

org $CC42A1	; Cyan, WoR recruitment
DB $66

org $CC4CD4	; Terra, before final battle against Phunbaba
DB $66

org $CC5047	; Terra, WoR recruitment
DB $66

org $CC541D	; Strago, WoR recruitment
DB $66

org $CC5AAD	; Sabin, WoR recruitment
DB $66

org $CC906C	; Locke and Terra, after banquet with Gestahl
DB $FD,$FD,$FD,$FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Adds the Kaiser Dragon to Kefka's Tower for group 1 to fight, provided all eight dragons have been defeated
; Removes esper reward from defeating all 8 dragons, and instead makes it another reward for beating Kaiser
; Requires corresponding map edit
; Adds a cutscene after each dragon is defeated to ruin their related statue in Kaiser's room

; Setting the event bit and executing the Kaiser spawning cutscene
; Also re-writes the dragon counting routine to add a fade to each result - code won't be commented here, but can be seen in the event dump

org $CC1F9F
DB $EB,$06,$08,$00,$C0,$A0,$01,$B3,$1F,$02,$4B,$DA,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC1FB3
DB $EB,$06,$07,$00,$C0,$A0,$01,$C7,$1F,$02,$4B,$DB,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC1FC7
DB $EB,$06,$06,$00,$C0,$A0,$01,$DB,$1F,$02,$4B,$DC,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC1FDB
DB $EB,$06,$05,$00,$C0,$A0,$01,$EF,$1F,$02,$4B,$DD,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC1FEF
DB $EB,$06,$04,$00,$C0,$A0,$01,$03,$20,$02,$4B,$DE,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC2003
DB $EB,$06,$03,$00,$C0,$A0,$01,$17,$20,$02,$4B,$DF,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC2017
DB $EB,$06,$02,$00,$C0,$A0,$01,$2B,$20,$02,$4B,$E0,$C5,$EA,$06,$01,$00,$97,$5C,$FE
; CC202B
DB $4B,$E1,$C5,$EA,$06,$01,$00	; Ported code - documented in the event dump at CC/202A. Other code removed as it seemed to add unnecessary bloat
DB $D6,$A3					; Set event bit $1E80($3A3) [$1EF4, bit 3]
DB $95,$97,$95				; Pause for 120 units; fade to black; pause for 120 units
DB $F4,$B9,$B5,$0C,$FE		; Play sound effect $B9, pause for 180 units; RTS

; The following clipped out because the music fade in would always start with the victory fanfare for some reason
;DB $95,$F2,$20,$97,$5C		; Pause for 120 units; fade out current song; fade to black; pause for 120 units
;DB $F3,$20,$FE				; Fade in current song; RTS

; CC203C - 12 bytes of free space to CC/2047

; Event execution
org $CB52C5
DB $4D,$9A,$3F				; Invoke battle against pack $9A (410) using default background
DB $B2,$A9,$5E,$00			; JSR $CA5EA9 - checks to see if a game over needs to be triggered
DB $42,$10					; Hides NPC $10 (dragon sprite, in this case)
DB $D7,$A3					; Clear event bit $1E80($3A3) [$1EF4, bit 3]
DB $96						; Restore screen from fade
DB $5C						; Pause execution until fade is complete
DB $4B,$E2,$C5				; Display caption $05E2 (1505)
DB $F4,$8D					; Play sound effect
DB $86,$45					; Add Crusader to party esper list
DB $3A						; Enable movement while events execute
DB $FE						; RTS

; Dragon cutscene jumps
org $CAB6E2					; Brown dragon
DB $B2,$A8,$50,$01			; JSR $CB50A8 - brown dragon statue destruction event defined below

org $CAB6F3
DB $4B,$DE,$01,$FE			; Bypass dragon-counting routine

org $CC43D0					; Purple dragon
DB $B2,$BF,$50,$01			; JSR $CB50BF - purple dragon statue destruction event defined below

org $CC43DC
DB $3A,$FE					; Bypass dragon-counting routine

org $CC558E					; White dragon
DB $B2,$E1,$50,$01			; JSR $CB50E1 - white dragon statue destruction event defined below

org $CC5598
DB $3A,$FE					; Bypassing vanilla dialogue and dragon-counting routine

org $CC36E2					; Silver dragon
DB $B2,$03,$51,$01			; JSR $CB5103 - silver dragon statue destruction event defined below

org $CC36EC
DB $3A,$FE					; Bypass dragon-counting routine

org $CC204B					; Red dragon
DB $B2,$25,$51,$01			; JSR $CB5125 - red dragon statue destruction event defined below

org $CC2055
DB $3A,$FE					; Bypass dragon-counting routine

org $CC205E					; Blue dragon
DB $B2,$49,$51,$01			; JSR $CB5149 - blue dragon statue destruction event defined below
DB $42,$13					; Hide blue dragon
DB $DD,$A1					; Clear event bit $1E80($6A1) [$1F54, bit 1]

org $CC2068
DB $3A,$FE					; Bypass dragon-counting routine

org $CC1923					; Green dragon
DB $B2,$6B,$51,$01			; JSR $CB516B - green dragon statue destruction event defined below

org $CC192D
DB $3A,$FE					; Bypass dragon-counting routine

org $CC18F6					; Gold dragon
DB $B2,$88,$51,$01			; JSR $CB5188 - gold dragon statue destruction event defined below

org $CC1900
DB $3A,$FE					; Bypass dragon-counting routine

; Kaiser's map modification - map ID 304
org $CB4FE5

; Rearranging the exit layout
DB $73,$57,$1E,$01,$04,$65,$75,$74,$71
DB $73,$4D,$1E,$01,$04,$65,$75,$75,$71
DB $73,$52,$1D,$01,$03,$65,$01,$35

; Adding the other four statue bases on L1 and ground tiles on L2
DB $73,$4D,$23,$01,$01,$6F
DB $73,$4D,$63,$01,$01,$85	; Brown dragon statue
DB $73,$57,$23,$01,$01,$6F
DB $73,$57,$63,$01,$01,$63	; Purple dragon statue
DB $73,$50,$20,$01,$01,$6F
DB $73,$50,$60,$01,$01,$88	; Green dragon statue
DB $73,$54,$20,$01,$01,$6F
DB $73,$54,$60,$01,$01,$8A	; Gold dragon statue

; Check for slain dragons and remove the L2 statue tile

; CB502F
DB $C0,$87,$03,$3B,$50,$01	; If ($1E80($387) [$1EF0, bit 7) is clear), branch to $CB503B
DB $73,$4D,$62,$01,$01,$5F	; If the brown dragon is still alive, draw the top of its statue
; CB503B
DB $C0,$9A,$82,$47,$50,$01	; If ($1E80($29A) [$1ED3, bit 2) is set), branch to $CB5047
DB $73,$57,$62,$01,$01,$5F	; If the purple dragon is still alive, draw the top of its statue
; CB5047
DB $C0,$94,$86,$53,$50,$01	; If ($1E80($694) [$1F52, bit 4) is set), branch to $CB5053
DB $73,$4F,$61,$01,$01,$00	; If the white dragon has been slain, remove the top of its statue
; CB5053
DB $C0,$95,$86,$5F,$50,$01	; If ($1E80($695) [$1F52, bit 5) is set), branch to $CB505F
DB $73,$55,$61,$01,$01,$00	; If the silver dragon has been slain, remove the top of its statue
; CB505F
DB $C0,$E3,$00,$6B,$50,$01	; If ($1E80($0E3) [$1E9C, bit 3) is clear), branch to $CB506B
DB $73,$50,$63,$01,$01,$00	; If the red dragon has been slain, remove the top of its statue
; CB506B
DB $C0,$A1,$86,$77,$50,$01	; If ($1E80($6A1) [$1F54, bit 1) is set), branch to $CB5077
DB $73,$54,$63,$01,$01,$00	; If the blue dragon has been slain, remove the top of its statue
; CB5077
DB $C0,$B4,$06,$83,$50,$01	; If ($1E80($6B4) [$1F56, bit 4) is clear), branch to $CB5083
DB $73,$50,$5F,$01,$01,$5F	; If the green dragon is still alive, draw the top of its statue
; CB5083
DB $C0,$B3,$06,$8F,$50,$01	; If ($1E80($6B3) [$1F56, bit 3) is clear), branch to $CB508F
DB $73,$54,$5F,$01,$01,$5F	; If the gold dragon is still alive, draw the top of its statue
; CB508F
DB $FE

; The following handles the eventing after each dragon is defeated

; Event bits	Brown Dragon	$387 ($1EF0, bit 7)Q	77,34 (4D,22)
; (clear if		Purple Dragon	$686 ($1F50, bit 6)S	87,34 (57,22)
; dragon was	White Dragon	$694 ($1F52, bit 4)Q	79,33 (4F,21)
; defeated)		Silver Dragon	$695 ($1F52, bit 5)S	85,33 (55,21)
;				Red Dragon		$69C ($1F53, bit 4)Q	80,35 (50,23)
;				Blue Dragon		$6A1 ($1F54, bit 1)S	84,35 (54,23)
; 				Green Dragon	$6B4 ($1F56, bit 4)Q	80,31 (50,1F)
;				Gold Dragon		$6B3 ($1F56, bit 3)S	84,31 (54,1F)

; CB5090 - common event
DB $B2,$A9,$5E,$00,$42,$31	; Displaced code from above; hide on-screen character
DB $6B,$30,$01,$52,$22,$40	; Load map 304 (Kaiser's room)
DB $B2,$E5,$4F,$01			; JSR $CB4FE5 - entrance event for Kaiser's room
DB $96,$5C,$94				; Restore screen from fade; pause execution until fade-in is complete; pause for 60 units
DB $58,$F1,$F4,$50,$FE		; Shake screen; play sound effect $50; RTS
; Fitting sound effects: $BB - original; $85 - Hidon; $19 - Fire 3; $50 - magicite breaking

; CB50A8 - destruction of the brown dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$4D,$62,$01,$01,$00	; Remove top of the brown dragon's statue
DB $93,$B2,$9F,$1F,$02		; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93,$41,$31,$FE	; Fade out music; pause for 45 units; show on-screen character; RTS

; CB50BF - destruction of the purple dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$57,$62,$01,$01,$00	; Remove top of the purple dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93				; Fade out music; pause for 45 units
DB $6B,$B3,$20,$29,$0F,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$85,$43,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB50E1 - destruction of the white dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$4F,$61,$01,$01,$00	; Remove top of the white dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93				; Fade out music; pause for 45 units
DB $6B,$70,$21,$07,$08,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$A3,$55,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB5103 - destruction of the silver dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$55,$61,$01,$01,$00	; Remove top of the silver dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93				; Fade out music; pause for 45 units
DB $6B,$22,$20,$16,$10,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$DC,$36,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB5125 - destruction of the red dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$50,$63,$01,$01,$00	; Remove top of the red dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93				; Fade out music; pause for 45 units
DB $D0,$E3					; Set event bit $1E80($0E3) [1E9C, bit 3]
DB $6B,$3B,$21,$14,$2C,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$3C,$24,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB5149 - destruction of the blue dragon's statue
DB $F2,$00					; Stop current song from playing
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$54,$63,$01,$01,$00	; Remove top of the blue dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $F2,$2D,$93				; Fade out music; pause for 45 units
DB $6B,$98,$21,$34,$2D,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$FD,$19,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB516B - destruction of the green dragon's statue
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$50,$5F,$01,$01,$00	; Remove top of the green dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $6B,$62,$21,$52,$22,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$41,$11,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

; CB5188 - destruction of the gold dragon's statue
DB $B2,$90,$50,$01			; JSR $CB5090 - common event to teleport to Kaiser's room and prep statue destruction
DB $73,$54,$5F,$01,$01,$00	; Remove top of the gold dragon's statue
DB $93,$B2,$9F,$1F,$02,$93	; Pause for 45 units; calls dragon count routine
DB $6B,$4F,$21,$52,$22,$C0	; Return to originating map at estimated position the player initiated combat against the dragon
DB $B2,$37,$11,$02			; Run entrance event for return map
DB $41,$31,$FE				; Show on-screen character; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Adds a line for Sabin if he's present while chasing Gerad

org $CA926C
DB $B2,$A2,$52,$01			; JSR $CB52A2

org $CB52A2
DB $BE,$01					; Checks the current caseword (active party membership), 1 check
DB $AC,$52,$51				; If Sabin is present, JSR $CB52AC
DB $32,$02					; Open action queue for character $32 (party character 1), 2 bytes long
DB $81						; Move right 1 tile
DB $FF						; End queue
DB $FE						; RTS
DB $91						; Pause for 15 units
DB $4B,$2A,$09				; Display caption $092A (2347)
DB $91						; Pause for 15 units
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the statue of Odin to drop the cracked stone rare item
; The queen's statue now turns the stone into the Odin magicite

; Gain cracked stone

org $CC1ED1
DB $D2,$E0					; Sets event bit $1E80($1E0) [$1EBC, bit 0]

; Lose cracked stone

org $CC1F81
DB $D3,$E0					; Clears event bit $1E80($1E0) [$1EBC, bit 0]

org $CC1F85
DB $86,$41					; Adds Odin to party esper list


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the options at the Narshe weapon shop to Apocalypse or Illumina, and adds a "Wait" option
; To free up space, removes one of the blue glow effects from the first part of the dialogue

org $CC0B2D
DB $41,$11					; Show object $11
DB $B2,$D5,$9A,$02			; JSR $CC9AD5
DB $4B,$EF,$05,$B6			; Display caption 1518 and set up the following branch
DB $42,$0B,$02				; Apocalypse - $CC0B42
DB $58,$0B,$02				; Illumina - $CC0B58
DB $B3,$5E,$00				; Wait - $CA5EB3
DB $FE						; RTS; probably unnecessary, but it's otherwise wasted space

org $CC0B53
DB $80,$1B					; Adds Apocalypse to party inventory

org $CC0B67
DB $80,$1A					; Adds Illumina to party inventory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes the items granted by the floating chests in Owzer's Mansion.

org $CB4A84
DB $84,$20,$4E				; Gives 20000 GP to the party

org $CB4AC4
DB $80,$EA					; Adds an X-Potion to party inventory

org $CB4B03
DB $80,$ED					; Adds an X-Ether to party inventory

org $CB4B42
DB $80,$EE					; Adds an Elixir to party inventory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Various event edits to prevent items from being added to party inventory
; Gauntlet replaced with a Safety Glove
; Genji glove replaced with a Barrier Cube

; Gauntlet

org $CAFB73
DB $80,$B8					; Adds a Safety Glove to party inventory

org $CAFB0B
DB $80,$B8					; Adds a Safety Glove to party inventory

; Genji glove

org $CAF975
DB $80,$B7					; Adds a Barrier Cube to party inventory

org $CAFFD2
DB $80,$B7					; Adds a Barrier Cube to party inventory

; Auto Crossbow

org $CA66B4
DB $FD,$FD					; NOP NOP

; Valiant Edge

org $CC328C
DB $FD,$FD					; NOP NOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Animates Terra when trying to take her to the Sealed Gate alone

org $CB260D
DB $B2,$B2,$52,$01			; JSR $CB52B2

org $CB52B2
DB $00,$02					; Open action queue for character $00 (Terra), 2 bytes long 
DB $18						; Angry stance
DB $FF						; End queue
DB $92						; Pause for 30 units
DB $4B,$60,$06				; Display caption $0660 (1633)
DB $92						; Pause for 30 units
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Easter egg allowing a personalized comment from Shadow during the meeting with Ramuh

org $CA998B
DB $BE,$07					; Checks the current caseword (active party membership), 7 checks
DB $EB,$AC,$10				; If Locke is present, JSR $CAACEB
DB $F3,$AC,$30				; If Shadow is present, JSR $CAACF3
DB $EF,$AC,$60				; If Celes is present, JSR $CAACEF
DB $EF,$AC,$50				; If Sabin is present, JSR $CAACEF
DB $EF,$AC,$20				; If Cyan is present, JSR $CAACEF
DB $EF,$AC,$40				; If Edgar is present, JSR $CAACEF
DB $F7,$AC,$B0				; If Gau is present, JSR $CAACF7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Splits a caption during the Lone Wolf "splat" event for better flow

org $CCD6B7
DB $B2,$BC,$52,$01			; JSR $CB52BC

org $CB52BC
DB $4B,$88,$06				; Display caption $0688 (1673)
DB $95						; Pause for 120 units
DB $31,$02					; Open action queue for character $31 (party character 0), 2 bytes long
DB $CC						; Turn character up
DB $FF						; End queue
DB $FE						; RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Changes a caption called for Cid at the beginning of the WoR

org $CA5284
DB $4B,$86,$06				; Call caption $0686 (1671)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Moves Gau's line up in the priority during the hammy speech before fighting Kefka

org $CA0884
DB $BE,$01,$7E,$3D,$B0		; If Gau is in the party, JSR $CA3D7E
DB $BE,$01,$76,$3D,$90		; If Setzer is in the party, JSR $CA3D76
DB $BE,$01,$7A,$3D,$A0		; If Mog is in the party, JSR $CA3D7A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Makes Locke look at Celes instead of Setzer during their first meeting on the Blackjack

org $CB2096
DB $01,$05					; Open action queue for character $01 (Locke), 5 bytes long
DB $C3						; Set movement speed to fast
DB $80						; Move up 1 tile
DB $87						; Move left 2 tiles
DB $63						; Look stage right
DB $FF						; End queue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Extends a pause to prevent the game from smashing two dialogue windows together during the end of the Phantom Train sequence

org $CBBD90
DB $94

; EOF