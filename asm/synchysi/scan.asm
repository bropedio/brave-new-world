hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Branches past HP/MP displays for scan

org $C250F2
BRA Scan

org $C25138
Scan:

; The following overwrites part of dn's bnw_scan_status.ips hack, modification by Seibaby

org $C23C5B
TYX
LDA #$27
STZ $341A		; Seibaby's modification - prevents enemies from countering scan
JMP $4E91

; EOF
