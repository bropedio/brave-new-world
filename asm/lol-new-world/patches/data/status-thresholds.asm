; MSB to LSB for each byte

; These definitions may be re-ordered as you like, to
; make it easier to edit it an organized fashion.

; hard
!ST_Sap        = $80
!ST_Slow       = $80
!ST_Death      = $80
!ST_Freeze     = $80
!ST_Zombie     = $80

; medium
!ST_Condemned  = $68
!ST_Petrify    = $68
!ST_Muddle     = $68
!ST_Berserk    = $68
!ST_Sleep      = $68

; easy
!ST_Stop       = $50
!ST_Poison     = $50
!ST_Mute       = $50
!ST_Blind      = $50
!ST_Imp        = $50


; Everything else is either a positive status, or is not
; inflicted by anything. Default threshold, in either case.

!ST_Vanish     = $80
!ST_Magitek    = $80
!ST_Image      = $80
!ST_NearFatal  = $80
!ST_Reflect    = $80
!ST_Safe       = $80
!ST_Shell      = $80
!ST_Haste      = $80
!ST_Regen      = $80
!ST_Float      = $80
!ST_DogBlock   = $80
!ST_Hide       = $80
!ST_Control    = $80
!ST_Morph      = $80
!ST_Life3      = $80
!ST_Dance      = $80
!ST_Rage       = $80


; +===============================+
; | DO NOT REARRANGE THESE THOUGH |
; +===============================+

; Byte 1
db #!ST_Death
db #!ST_Petrify
db #!ST_Imp
db #!ST_Vanish
db #!ST_Magitek
db #!ST_Poison
db #!ST_Zombie
db #!ST_Blind

; Byte 2
db #!ST_Sleep
db #!ST_Sap
db #!ST_Muddle
db #!ST_Berserk
db #!ST_Mute
db #!ST_Image
db #!ST_NearFatal
db #!ST_Condemned

; Byte 3
db #!ST_Reflect
db #!ST_Safe
db #!ST_Shell
db #!ST_Stop
db #!ST_Haste
db #!ST_Slow
db #!ST_Regen
db #!ST_Dance

; Byte 4
db #!ST_Float
db #!ST_DogBlock
db #!ST_Hide
db #!ST_Control
db #!ST_Morph
db #!ST_Life3
db #!ST_Freeze
db #!ST_Rage
