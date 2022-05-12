org !TieredStatus_freeC2
RNGlong:            ; 4 bytes
  JSR $4B65         ; RNG 0 to (accumulator - 1)
  RTL

org $C223B2
  JSL StamCheck
  NOP

org !TieredStatus_freeXX
StamCheck:
  PHX
  PHY

  CPY #$08
  BCS .default      ; Use default threshold for enemies

  LDY $00
  LDA $00
  PHA               ; Store initial threshold of 0

  ; for each attack status byte:
  - LDA $11AA,Y       ; Attack status byte
    BEQ +             ; Skip to next status byte if none on this byte
    LDX $00

    ; for each bit in current status byte (MSB to LSB):
    .byteloop
      ASL               ; Roll status flag onto carry
      BCC .nextloop     ; Skip if status flag unset
      PHA               ; Store attack status bits
      PHX               ; Store bit index
      TYA               ; Get byte index
      rep 3 : ASL       ; x8
      CLC
      ADC $01,S         ; Add bit index
      TAX
      LDA.l StamVals,X  ; Get threshold for status
      CMP $03,S         ; Compare with stored threshold
      BCC .nostore      ; Skip if stored threshold already higher
      STA $03,S         ; Store new threshold
    .nostore
      PLX               ; Restore bit index
      PLA               ; Restore attack status bits
    .nextloop
      INX
      CPX #$08
      BNE .byteloop     ; Check all 8 bits

  + INY
    CPY #$04          
    BNE -             ; Check all 4 status bytes

  PLA               ; Retrieve stashed threshold
  BNE +
.default
  LDA #$80          ; Default threshold of 128 if no status threshold found
+ PLY
  PLX
  JSL RNGlong       ; Get random number from 0 to threshold-1
  RTL              

StamVals:
  incsrc "data/status-thresholds.asm"

TieredStatus_EOF:

