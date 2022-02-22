hirom
header

;BNW Stam-based counter rate

!freespace = $C267F2        ;Requires 14 bytes of free space

org $C24CC2
exit:

;Black Belt counter
org $C24D03
C24D03:	JSR newfunc
        macro newfunc()
        reset bytes
        newfunc:
        LDA $3B40,X	        ;Stamina
        CLC                 ;(SHOULD always be clear here...)
        ADC #$20            ;Stamina + 32
        STA $10             ;Store it in scratch RAM
        LDA #$81            ;129
        JSR $4B65           ;Random: 0 to 128
        RTS
        print bytes," bytes written"
        endmacro
C24D06:	CMP $10
C24D08:	BCS exit	        ;Exit if (0..128) was larger than (Stam + 32)

org !freespace
reset bytes
%newfunc()
print bytes, " bytes written to free space"