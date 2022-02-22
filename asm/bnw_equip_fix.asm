hirom
header

; Written by dn

ORG $C38E5F
;Hotspot data for Equip screen functions
DB $01,$00,$00,$03,$01
;Finger positioning for "EQUIP, OPTIMUM, REMOVE, EMPTY"
DW $1018
DW $1058
DW $10A0
DW $FFFF


ORG $C3966C
;pointers to Equip screen functions
DW $9674					; equip
DW $968E					; Remove
DW $969F					; None

ORG $C3A31A
equip:
DB $13,$79,$84,$90,$94,$88,$8F,$00			; EQUIP
remove:
DB $23,$79,$91,$84,$8C,$8E,$95,$84,$00     	; REMOVE
empty:
DB $35,$79,$84,$8C,$8F,$93,$98,$00				; None

ORG $C3A2A6
DW equip
DW remove
DW empty

ORG $C39055
LDY #$0006

;relic menu adjustment
ORG $C38ED1
DW $1028
DW $1088

ORG $C3A33C
DW $7917
ORG $C3A344
DW $792F