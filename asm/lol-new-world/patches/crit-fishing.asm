org $C21610
  SkipDA:             ; convenience label

org $C215E9           ; Putting some DA-related code back in its original position
  JSR $4B5A           ; Random number 0 to 255
  AND #$0F            ; 0 to 15
  BNE SkipDA          ; 1 in 16 chance for DA
  LDA $3018,Y         ; Current character bit

org $C233FC
  rep 4 : NOP         ; allow crits against party members

org $C4A4CB
MeritCheck:           ; convenience label

org $C4A4D1
  LDA $3B19,X         ; Speed
  LSR                 ; Speed ÷ 2
  PHA                 ; store it
  JSR MeritCheck
  BEQ +
  PLA
  CLC
  ADC #$10            ; Add 16 to SPD if merit award flag present
  PHA
+ JSR $A4C0           ; local RNG(0..255)
  CMP $01,S           ; critical hit if RNG <= modified SPD
  PLA                 ; SPD from stack, discard
  RTL

padbyte $FF
pad $C4A4F8           ; reclaim the rest of this chunk
