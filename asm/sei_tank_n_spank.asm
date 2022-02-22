;Tank & Spank (previously Cover Knight and Smart Cover)
;by Seibaby
;v1.01 - Fixed a bug with Love Token being prevented by Image, Dark, and Berserk
;v1.0 - Only allows back row targets for Stamina-based cover
;       Disables Cover when Dancing
;v0.9 - Disables Interceptor and halves Evasion when Covering
;v0.7 - Fixes a bug where Knight wouldn't reset Defending stance when Covering
;v0.6 - New Smart Cover logic
;       Some Cover nerfs
;v0.5 - Fixes an issue with Knights not taking targets' statuses into
;       account (Image and Clear, but also Zombie and Petrify)
;v0.4 - Fixes a bug causing Knights to Cover monsters attacking other
;       monsters
;v0.3 - Adds an exception to not trigger Cover if the Knight is Near Fatal
;       and the target is healthy.
;v0.2 - Fixes a bug that caused the wrong statuses (on the target) to be
;       considered for whether or not to disable True Knight.
    ;Changes the True Knight effect to trigger with a Stamina / 192 chance even if
;the target isn't in Near Fatal status.
    ;New Smart Cover patch, which disables True Knight for all attacks
;originating from a player character, unless that character is uncontrollable,
;in which case it will only disable it if the attack comes from a healing weapon,
;or if the weapon is elemental and the target absorbs/nullifies that element.
;It also considers a few extra statuses for purposes of disabling True Knight.
;ON TARGET: Death, Petrify, Zombie, Magitek, and Image
;           (in addition to Clear)
;ON KNIGHT: Dark, Magitek, Image, Berserk
;           (in addition to Death, Petrify, Clear, Zombie, Sleep, and Muddled)
    
;xkas 0.06
hirom
header
!smartCover = $C2FAD0       ;Requires 114 bytes of free space
;!halveEvade = ;Requires 20 bytes of free space
;!noDogBlock = ;Requires 9 bytes of free space
    ;A few notes on the changes made to these functions:
;Entering this function, A is 16-bit and X/Y are 8-bit. Register width is
;never changed and the call following this function doesn't care about Carry,
;so I have removed a bunch of useless PHP/PLP and REP #$20 throughout, to make
;room for the new code.
;I have also removed some code related to monsters using True Knight, which was
;supported in vanilla, but unused (and remains so in BNW). The check for if the
;bodyguard was Controlled was also removed (doubly useless).
    org $C2123A
exit:
    ;True Knight and Love Token
org $C2123B
trueKnightAndLoveToken:
        PHX
        LDA $B2
        BIT #$0002          ;Is "No critical and Ignore True Knight" set?
        BNE .exit           ;Exit if so
        LDA $B8             ;intended target(s).  to my knowledge, there's only
                            ;one intended target set if we call this function..
        JMP smartCover
        macro smartCover()
        print "Writing smartCover() to ",pc
        reset bytes
        smartCover:
        BEQ .exit           ;Exit if none
        LDY #$FF    
        STY $F4             ;default to no bodyguards.
        JSR $51F9           ;Y = index of our highest intended target.
                            ;0, 2, 4, or 6 for characters.  8, 10, 12, 14, 16,
                            ;or 18 for monsters.
        STY $F8             ;save target index
        STZ $F2             ;Highest Bodyguard HP So Far = 0.  this makes the
                            ;first eligible bodyguard we check get accepted.
                            ;later ones may replace him/her if they have more
                            ;HP.
        PHX     
        LDX $336C,Y         ;Love Token - which target takes damage for you
        BMI .noLove         ;Branch if none do
        JSR evalKnight_skip ;consider this target as a bodyguard (skip Stamina
                            ;and Near Fatal checks)
        JSR newTarget       ;if it was valid, make it intercept the attack  
.noLove PLX
        LDA $3A36
        BNE .exit           ;Exit if Golem is active
        CPX #$08            ;Check attacker
        BCS .status         ;Branch if attacker is a monster
        CPX $F8
        BEQ .exit           ;Exit if Attacker = Target
        LDA $3EE4,X         ;Attacker status byte 1-2
        BIT #$2002
        BNE .heals          ;Branch if Muddled or Zombied
        LDA $3394,X         ;Check if Attacker is Charmed
        BMI .exit           ;If not Muddled, Zombied, or Charmed, this
                            ;attack was initiated by the player, so exit
.heals  LDA $11A9           ;Special weapon property
        AND #$00FF          ;Isolate bottom byte
        CMP #$0018          ;Check "Curative Attributes"
        BEQ .exit           ;Exit if set
        SEP #$20         
        LDA $11A1           ;Attack element(s)
        PHA
        XBA
        PLA                 ;Copy to high byte
        REP #$20
        AND $3BCC,Y         ;Target absorbed/immune elements
        BNE .exit           ;If any absorbed or nullified, exit
.status LDA $3EE4,Y         ;Target status byte 1-2
        BIT #$04DA
        BNE .exit           ;Branch if Death, Petrify, Clear, Zombie, Magitek,
                            ;or Image
.seize  LDA $3358,Y         ;$3359 = who is Seizing you
        BPL .exit           ;Branch if target is seized
        LDA #$000F          ;Load all characters as potential bodyguards        
	.cover  CPY #$08
        BCC .saveBg         ;Branch if target is character
        TDC                 ;Null all potential bodyguards
.saveBg STA $F0             ;Save potential bodyguards
        LDA $3018,Y         ;bit representing target
        ORA $3018,X         ;bit representing attacker
        TRB $F0             ;Clear attacker and target from potential
                            ;bodyguards
        
        JMP trueKnightAndLoveToken_contd
.exit   PLX
        RTS
        print "smartCover: ",bytes," bytes written, ending at ",pc
        endmacro
	.contd  LDX #$12
.loop   LDA $3C57,X         ;High byte = Relic Effects 3
        ASL #2              ;Check bit 6 (True Knight)
        BCC .next           ;Branch if no True Knight effect                
        LDA $3018,X
        BIT $F0
        BEQ .next           ;Branch if this candidate isn't on the same
                            ;team as the target
        JSR evalKnight      ;consider them as candidate bodyguard.  if they're
                            ;valid and their HP is >= past valid candidates,
                            ;they become the new frontrunner.
.next   DEX
        DEX
        BPL .loop           ;Do for all characters and monsters
        LDA $F2
        BEQ .exit           ;Exit if no bodyguard found [or if the selfless
                            ;soul has 0 HP, which shouldn't be possible outside
                            ;of bugs].
        JSR newTarget       ;make chosen bodyguard -- provided there was one --
                            ;intercept attack.  if somebody's already been
                            ;slated to intercept it [i.e. due to Love Token],
                            ;the True Knight will sensibly defer to them.
.exit   PLX
        RTS
    
;Make chosen bodyguard intercept attack, provided one hasn't been marked to do
;so already.
    newTarget:
        LDX $F4
        BMI .exit           ;exit if no bodyguard found
        CPY $F8
        BNE .exit           ;exit if $F8 no longer points to the original
                            ;target, which means we've already assigned a
                            ;bodyguard with this function.
        STX $F8             ;save bodyguard's index
        STY $A8             ;save intended target's index
        LSR $A8             ;.. but for the latter, use 0,1,2,etc rather
                            ;than 0,2,4,etc
        LDA $3018,X
        STA $B8             ;save bodyguard as the new target of attack
        SEP #$20
        LDA $3AA1,X
        BIT #$02
        BEQ .noDef          ;Branch if not Defending
        JSR $0A41           ;Clear Defending flag
        JSR $0A3C           ;Relax Defending pose
.noDef  REP #$20
.exit   RTS
    
;Consider candidate bodyguard for True Knight or Love Token
evalKnight:
        LDA #$0020
        BIT $3AA1,X
        BNE .exit           ;Exit if guard is in back row
        LDA $3EE5,Y         ;Low byte = Status byte 2
        LSR #2              ;Check bit 1 (Near Fatal)
        BCS .skip           ;Skip Stamina check if target Near Fatal        
        LDA $3AA1,Y
        BIT #$0020
        BEQ .exit           ;Exit if target is in back row
        LDA $3EE5,X         ;Knight's Status byte 2
        LSR #2              ;Check Near Fatal
        BCS .exit           ;If Knight is Near Fatal, exit
        SEP #$20                
        LDA #$C0            ;192
        JSR $4B65           ;Random: 0 to 191
        CMP $3B40,X         ;Stamina
        REP #$20
        BCS .exit           ;Exit if Stamina was lower
.skip                       ;Love Token enters here
        LDA $3AA0,X
        LSR     
        BCC .exit           ;Exit function if entity not present in battle?
        LDA $3358,X         ;$3359 = who is Seizing you
        BPL .exit           ;Exit if you're Seized
        LDA $336B,Y         ;Love Token - which target takes damage for you
        BMI .noLove         ;Branch if none do
        LDA $3EE4,X         ;Bodyguard's status
        BIT #$A0DA          ;Death, Petrify, Clear, Zombie, Sleep, Muddled,
                            ;Dark, Magitek, Image, Berserk
        BNE .exit
        BRA .love
.noLove LDA $3EE4,X         ;Bodyguard's status
        BIT #$B4DB          ;Death, Petrify, Clear, Zombie, Sleep, Muddled,
                            ;Dark, Magitek, Image, Berserk
        BNE .exit           ;Exit if any set
.love   LDA $3EF8,X     
        BIT #$3211          ;Dance, Stop, Freeze, Spell Chant, Hide
        BNE .exit           ;Exit if any set
        LDA $3018,X
        TSB $A6             ;make this potential guard jump in front of the
                            ;target, can accompany others
        LDA $3BF4,X         ;HP of this potential bodyguard
        CMP $F2         
        BCC .exit           ;branch if it's not >= the highest HP of the other
                            ;bodyguards considered so far for this attack.
        STA $F2             ;if it is, save this entity's HP as the highest
                            ;HP so far.
        STX $F4             ;and this entity becomes the new bodyguard.
.exit   RTS
    print "Cover function end: ",pc
print "Vanilla Cover ends: c212f4"
    ;Check for Covered attacks in Hit Determination
;Disable Dog Block if attack was Covered
org $C22282
checkDogBlock:
        LDA $3EF9,Y
        ASL
        BPL C22293            ;Branch if not dog block
        JSR skipDogBlock
        macro skipDogBlock()
        print "Writing skipDogBlock() to ",pc
        reset bytes
        skipDogBlock:
        CPY $F4             ;Is target = bodyguard?
        BNE .exit           ;If not, return
        CLC                 ;Otherwise, set carry = 0, ie.
        RTS
.exit   JMP $4B53           ;Random: carry 0 or 1          
        print "skipDogBlock: ",bytes," bytes written, ending at ",pc
        endmacro
;        BCC C22293          ;50% chance
;        LDA #$40      
;        STA $FE             ;Set dog block animation flag
org $C22293
C22293:
    ;Halve Evasion if attack was Covered
org $C22345
        JSR halveEvasion    ;Get Evade
        macro halveEvasion()
        print "Writing halveEvasion() to ",pc
        reset bytes
        halveEvasion:       ;Y = target of attack
        CPY $F4             ;Index of bodyguard ($FF if no bodyguard)
        BNE .exit           ;If not the same as target, exit
        LDA #$FF            ;255
        SEC
        SBC $3B54,Y         ;255 - (255 - Evade * 2 + 1)
                            ;(= Evade * 2 - 1)
        INC                 ;Evade * 2
        LSR                 ;Evade
        LSR                 ;Evade / 2
        JMP $2861           ;New blockvalue from halved Evade
.exit   LDA $3B54,Y         ;(255 - Evade * 2 + 1)
        RTS
        print "halveEvasion: ",bytes," bytes written, ending at ",pc
        endmacro
    org !smartCover
%smartCover()
;org !halveEvade
%halveEvasion()
;org !noDogBlock
%skipDogBlock()