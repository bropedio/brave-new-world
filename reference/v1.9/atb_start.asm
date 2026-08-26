	;More consistent starting ATB timers
	;for Brave New World
;by Seibaby
	;This changes the way ATB timers are initialized at the start of
;battle to make them more consistent with respect to Speed.
	;It reduces randomness and increases Speed's contribution to how
;quickly characters (and enemies) get their first turn.
	;The original formula was:
;([Speed..(Speed * 2 - 1)] + [(0..9) * 8] + [G * 16]) * 256 / 65535
;Where G = (10 - Number of entities in battle)
	;The new formula is:
;([(Speed * 2)..(Speed * 3 + 29)] + [(0..9) * 4] + G) * 256 / 65535
	hirom
;header
!freespace = $C2FAA4    ;requires 16 bytes of free space in C2
	;Initialize ATB Timers
org $C22575
C22575:  PHP
C22576:  STZ $F3        ;zero General Incrementor
C22578:  LDY #$12
C2257A:  LDA $3AA0,Y
C2257D:  LSR 
C2257E:  BCS C22587     ;branch if entity is present in battle?
C22580:  CLC 
C22581:  LDA #$01       ;#$10
C22583:  ADC $F3
C22585:  STA $F3        ;add 16 to $F3 [our General Incrementor] for
                        ;each entity shy of the possible 10
C22587:  DEY 
C22588:  DEY 
C22589:  BPL C2257A     ;loop for all 10 characters and monsters
C2258B:  REP #$20       ;Set 16-bit accumulator
C2258D:  LDA #$03FF     ;10 bits set, 10 possible entities in battle
C22590:  STA $F0
C22592:  LDY #$12
C22594:  LDA $F0
C22596:  JSR $522A      ;randomly choose one of the 10 bits [targets]
C22599:  TRB $F0        ;and clear it, so it won't be used for
                        ;subsequent iterations of loop
C2259B:  JSR $51F0      ;X = bit # of the chosen bit, thus a 0-9
                        ;target #
C2259E:  SEP #$20       ;Set 8-bit accumulator
C225A0:  TXA 
C225A1:  ASL 
C225A2:  ASL 
C225A3:  NOP            ;ASL 
C225A4:  STA $F2        ;save [0..9] * 4 in our Specific Incrementor
                        ;the result is that each entity is randomly
                        ;assigned a different value for $F2:
                        ;0, 4, 8, 12, 16, 20, 24, 28, 32, 36
C225A6:  LDA $3219,Y    ;get top byte of ATB Timer
C225A9:  INC 
C225AA:  BNE C225FA     ;skip to next target if it wasn't FFh
C225AC:  LDA $3EE1      ;FFh in every case, except for last 3 tiers
                        ;of final 4-tier multi-battle?
C225AF:  INC 
C225B0:  BNE C225FA     ;skip to next target if one of those 3 tiers
C225B2:  LDX $201F      ;get encounter type.  0 = front, 1 = back,
                        ;2 = pincer, 3 = side
C225B5:  LDA $3018,Y
C225B8:  BIT $3A40      ;is target a character acting as enemy?
C225BB:  BNE C225D1     ;branch if so
C225BD:  CPY #$08
C225BF:  BCS C225D1     ;branch if target is a monster
C225C1:  LDA $B0
C225C3:  ASL 
C225C4:  BMI C225FA     ;skip to next target if Preemptive Attack
C225C6:  DEX            ;decrement encounter type
C225C7:  BMI C225DE     ;branch if front attack
C225C9:  DEX 
C225CA:  DEX 
C225CB:  BEQ C225FA     ;skip to next target if side attack
C225CD:  LDA #$80
C225CF:  BRA C225F7     ;it's a back or pincer attack
                        ;go set top byte of ATB timer to $F2 + 1
C225D1:  LDA $B0        ;we'll reach here only if target is monster
                        ;or character acting as enemy
C225D3:  ASL 
C225D4:  BMI C225DA     ;branch if Preemptive Attack
C225D6:  CPX #$03       ;checking encounter type again
C225D8:  BNE C225DE     ;branch if not side attack
C225DA:  LDA #$01
C225DC:  BRA C225F3     ;go set top byte of ATB timer to 2
C225DE:  LDA $3B19,Y
C225E1:  ADC #$1E
C225E3:  JSR $4B65      ;random #: 0 to A - 1
C225E6:  JMP newfunc
         macro newfunc()
         newfunc:
          print "newfunc written to: ",pc
          reset bytes
          ADC $3B19,Y   ;A = random: Speed to (2 * Speed + 29)
          BCS .cap      ;branch if exceeded 255
          ADC $3B19,Y   ;A = random: (2 * Speed) to (3 * Speed + 29)
          BCS .cap      ;branch if exceeded 255
          JMP return
          .cap
          JMP $25F1
          print "wrote ",bytes," bytes"
         endmacro
return:
C225E9:  ADC $F2        ;add entity's Specific Incrementor, a
                        ;0,4,8,12,16,20,24,28,32,36 random boost
C225EB:  BCS C225F1     ;branch if exceeded 255
C225ED:  ADC $F3        ;add our General Incrementor,
                        ;10 - number of valid entities 
C225EF:  BCC C225F3     ;branch if byte didn't exceed 255
C225F1:  LDA #$FF       ;if it overflowed, set it to FFh [255d]
C225F3:  INC 
C225F4:  BNE C225F7
C225F6:  DEC            ;so A is incremented if it was < FFh
C225F7:  STA $3219,Y    ;save top byte of ATB timer
C225FA:  REP #$20
C225FC:  DEY 
C225FD:  DEY 
C225FE:  BPL C22594     ;loop for all 10 possible characters and
                        ;monsters
C22600:  PLP 
C22601:  RTS
	org !freespace
%newfunc()
