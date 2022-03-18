; Modified by GrayShadows

hirom  ; don't change this
;header

org $C12E4F  ; location in v1.0
C12E4F:    BRA reset_rotation ; $2B

org $C12E5C  ; location in v1.0
C12E5C:    BRA reset_rotation ; $1E

org $C12E69  ; location in v1.0
C12E69:    BRA reset_rotation ; $11


; Status checker for outline colours.
        LDA #$1E
        TRB $38         ; If Regen, ignore it
C12E6B:    LDA $2EA9,Y  ; get current outline rotation

main_loop:
C12E6E:    BIT $38  ; check against current status
C12E70:    BNE set_colour  ; branch if a match was found
C12E72:    LSR A  ; check next status
C12E73:    ADC #$00  ; maintain wait bit
C12E75:    STA $2EA9,Y  ; update outline colour rotation
C12E78:    CMP #$20  ; loop over 6 statuses
C12E7A:    BCS main_loop

reset_rotation:
C12E7C:    LDA #$80  ; no match found, reset to Rflect

update_rotation:
C12E7E:    STA $2EA9,Y
C12E81:    RTS

set_colour:
C12E82:    AND #$E0  ; clear wait bit
C12E84:    JSR $1A0F  ; v1.0 or v1.1
C12E87:    LDA.l outline_color_table,X  ; get outline colour
outline_color_table:
C12E8B:    BRA outline_control  ; implement

DB $04  ; Slow
DB $03  ; Haste
DB $07  ; Stop
DB $02  ; Shell
DB $01  ; Safe
DB $00  ; Rflect

rotate_outline:
C12E93:    LDA $2EA9,Y  ; current outline colour rotation

rotation_loop:
C12E96:    LSR A  ; move one step forward
C12E97: BCS reset_rotation  ; if wait bit set, clear it, reset and exit
C12E99:    AND #$FC  ; keep 6 bits
C12E9B:    BEQ reset_rotation  ; if all cleared, reset and exit

check_status:
C12E9D:    BIT $38  ; check current status
C12E9F:    BEQ rotation_loop  ; loop until match found
C12EA1:    BRA update_rotation  ; update outline rotation
        rts
           
           NOP
C12EA8:    NOP
C12EA9:    NOP
C12EAA:    NOP
C12EAB:    NOP
C12EAC:    NOP
C12EAD:    NOP
C12EAE:    NOP
C12EAF:    NOP
C12EB0:    NOP
C12EB1:    NOP
C12EB2:    NOP
exit:
C12EB4:    RTS

org $C12EC3  ; location in v1.0
outline_control:
C12EC3:    PHA
C12EC4:    LDA $0E
C12EC6:    STA $2C
C12EC8:    PLA
C12EC9:    PHA
C12ECA:    LDA $2C
C12ECC:    AND #$03
C12ECE:    TAX
C12ECF:    LDA.l $C2E3AA,X  ; v1.0 or v1.1
C12ED3:    CLC
C12ED4:    ADC $2C
C12ED6:    STA $36
C12ED8:    AND #$3C
C12EDA:    LSR A
C12EDB:    STA $2C
C12EDD:    STZ $2D
    LDA $36
    ASL A
    ASL A
    BCC colour_transition
    LDA #$1F
    SBC $2C
    STA $2C

colour_transition:
    LDA $2C
    CMP #$1F
    BNE continue_control
    JSR rotate_outline
    BRA continue_control
    NOP
continue_control:

org $C13043
    LDA $2EBF,x

org $C2307D  ; location in v1.0 or v1.1
C2307D:    PHX  ; preserve party member index
C2307E:    LDA $FE  ; get row
C23080:    STA $3AA1,X  ; save to special properties
C23083:    LDA $3ED9,X  ; preserve special sprite
C23086:    PHA
C23087:    LDA $05,S  ; get loop variable
C23089:    STA $3ED9,X  ; save to roster position
C2308C:    TDC
C2308D:    TXA
C2308E:    ASL A
C2308F:    ASL A
C23090:    ASL A
C23091:    ASL A
C23092:    TAX
C23093:    LDA #$06  ; 7-iteration loop
C23095:    STA $FE  ; initialize loop counter
C23097:    PHY  ; preserve Y-loop index

display_init_loop:
C23098:    LDA $1601,Y  ; get normal sprite & name characters

set_battle_sprite:
C2309B:    STA $2EAE,X  ; store to display variables
REPLACE3:  ; mass replacement, nothing after this
C2309E:    INX
C2309F:    INY
C230A0:    DEC $FE
C230A2:    BPL display_init_loop
C230A4:    PLY  ; restore Y-loop index
C230A5:    PLA  ; restore special sprite
C230A6:    CMP #$FF  ; is special sprite null?
C230A8: BEQ init_outline_rotation  ; if not...
C230AA:    STA $2EA7,X  ; ...overwrite sprite

init_outline_rotation:
C230AD:    LDA #$81  ; Rflect status, wait bit
C230AF:    STA $2EA2,X  ; initialize outline rotation
C230B2:    LDA $03,S  ; get character ID
C230B4:    STA $2EBF,X  ; save it
C230B7:    CMP #$0E  ; is it Banon or higher?
C230B9:    REP #$20  ; 16-bit A
C230BB:    TAX  ; move to X
