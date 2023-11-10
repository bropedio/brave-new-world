hirom

; Prelude School
; author: Bropedio
;
; Allow the prelude to play during the first visit to
; the beginner's school at the beginning of the game

!free = $C0FD5A ; 10 bytes
!warn = $C0FD64

; $C0034E - Update music on map load
org $C0035F : JSR GetSong ; get song when not allowed to change music

org !free
GetSong:
  LDA $053C          ; map's song
  CMP #$01           ; is it "Prelude"
  BEQ .exit          ; if so, override "current song"
  LDA $1F80          ; [displaced] get current song
.exit
  RTS
warnpc !warn
