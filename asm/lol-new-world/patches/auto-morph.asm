org $C25414           ; Morph command Phunbaba bit check
  JMP AutomorphCmd

org $C22683           ; Permamorph Phunbaba bit check
  LDA #$04
  JML AutomorphImmune
  NOP

org !Automorph_freeC2
AutomorphCmd:
  JML AutomorphCmdLong
.return
  RTS

org !Automorph_freeXX
AutomorphCmdLong:
  BIT $3EBB
  BNE +                       ; if phunbaba, disable command; otherwise, continue checking
  LDA $05, S
  TAX
  LDA $3C59,X                 ; permamorph flag from equipment in bit $40
  ASL
  ASL
  BCS +                       ; disable command if permamorph set 
  JML AutomorphCmd_return     ; otherwise, return and keep command enabled
+ JML $C25419                 ; disable morph command

AutomorphImmune:
  BIT $3EBB
  BNE +               ; branch to morph if phunbaba
  LDA $3C59,X         ; permamorph flag from equipment in bit $40
  ASL
  ASL
  BCS +               ; branch to morph if permamorph set
  JML $C2268E         ; skip
+ JML $C2268A         ; set morph immunity

Automorph_EOF:

