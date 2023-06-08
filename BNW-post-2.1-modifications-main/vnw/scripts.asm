arch 65816
hirom

;------------------------------------------------------------------
;Dialogues
;------------------------------------------------------------------

check bankcross off

org $CCE600
	incbin "town_dialog.bin"

check bankcross on

warnpc $CEF100
;-------------------------------------------------------------------

org $CFDFE0
	incbin "short_battle_dialog.bin"

warnpc $CFF450
;-------------------------------------------------------------------

org $D0D000
	incbin "long_battle_dialog.bin"

warnpc $D0FD00
