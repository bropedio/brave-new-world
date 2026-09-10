hirom

; E8 Bank

; ########################################################################
; Fix two Sealed Gate battle bridge tiles (from bridge-correction.ips)

org $E8B1F3 : db $BD
org $E8B2B8 : db $2B
org $E8B2BF : db $65
org $E8B2C7 : incbin bin/bridge-correction.bin : warnpc $E8B8B0
