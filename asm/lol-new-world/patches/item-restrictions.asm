C1/4CC3:  20 73 4B    JSR $4B73        ; get item palette color

  LDX $62CA           ; active character index
  LDA $C11A01,X       ; active character bitmask