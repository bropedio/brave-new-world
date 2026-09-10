hirom

; Patch: Bridge Correction
; Author: Gi Nattak
; From: bridge-correction.ips
;
; This obscure patch corrects two small, rather hard to notice
; graphical issues with the Sealed Gate battle background

org $E8B1F3 : db $BD
org $E8B2B8 : db $2B
org $E8B2BF : db $65
org $E8B2C7 : incbin bin/bridge-correction.bin : warnpc $E8B8B0
