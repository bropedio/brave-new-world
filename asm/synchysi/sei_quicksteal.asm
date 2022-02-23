;Quicksteal - a successful Steal attempt doesn't deplete the ATB bar.

;NOTE: makes use of bit 3 of $3AA1,index as a flag to tell the ATB ticker
;function to just go ahead and set ATB state to "ready".

;All the code except the calls to the new functions is unchanged and just
;there for context.

; Modified by Synchysi to split and move code around.

hirom
header
!freespaceSet = $C23CB8            ;Requires 12 bytes in C2
!freespaceChk = $C267B0            ;Requires 21 bytes in C2

;Successful Steal attempt
org $C239E9
C239E9: STA $2F35               ;Save Item stolen for message purposes in
                                ;parameter 1, bottom byte
C239EC: STA $32F4,X             ;Store in "Acquired item"
C239EF: JSR setCantrip          ;(LDA $3018,X)
        macro setCantrip()
        reset bytes
        setCantrip:
        LDA $3AA1,X
        ORA #$08
        STA $3AA1,X             ;Use bit 3 of $3AA1 as cantrip flag, it seems
                                ;to be unused. $3AA0 has a flag that sort of
                                ;does the opposite (resets ATB, used when
                                ;waking from Sleep), so it seems appropriate.
        LDA $3018,X
        RTS
        print "setCantrip is ",bytes," bytes"
        endmacro
C239F2: TSB $3A8C               ;Flag character to have any applicable item in
                                ;$32F4,X added to inventory when turn is over.

;Update ATB timer
org $C211BB
C211BB: REP #$21
C211BD: LDA $3218,X             ;current ATB timer count
C211C0: ADC $3AC8,X             ;amount to increase timer by
C211C3: JSR checkCantrip        ;(STA $3218,X)
        macro checkCantrip()
        reset bytes
        checkCantrip:
        PHA                     ;Save A
        LDA $3AA1,X
        BIT #$0008
        BEQ .exit               ;Exit if cantrip flag not set
        AND #$FFF7
        STA $3AA1,X             ;Clear cantrip flag
        SEC                     ;Set ATB to fill immediately
        .exit
        PLA                     ;Restore A
        STA $3218,X             ;Save updated timer
        RTS
        print "checkCantrip is ",bytes," bytes"
        endmacro

org !freespaceSet
%setCantrip()

org !freespaceChk
%checkCantrip()
