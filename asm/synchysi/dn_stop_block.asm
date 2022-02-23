hirom
header

org $c2265b
jsr $3c04 ; old rippler space

org $c23c04
pha            ; save A
lda $3330,x
and #$EF
sta $3330,x
pla
ora #$80
xba
rts 
