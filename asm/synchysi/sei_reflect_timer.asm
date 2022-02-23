; Disable Reflect timer and randomly remove Reflect when triggered
; by Seibaby (2018-12-01)
hirom
header
!freespace = $C20AE6    ; Requires 9 bytes of free space in C2
	; The hook offset for the new code depends on whether you have Terii's
; Vanish/Doom patch applied or not.
;!hook = $C22248         ; Vanilla
!hook = $C22256         ; Vanish/Doom patch applied
	; Disable Reflect timer
org $C2469B
nothing: RTS
	org $C246DE
      dw nothing        ; Action when setting Rflect
	; Hook Hit Determination to call new code
org !hook
JMP remove_reflect      ; Make attack miss if reflecting
	; The purpose of the following modifications are to make room for the
; new code. The Reflect timer is no longer used, so it's safe to remove
; both the code that sets the timer, and the code that checks whether it
; has run out. This frees up enough space for the new code.
	; This new code replaces the code that set the Reflect timer (10 bytes)
org $C24687
remove_reflect:
         SEP #$20       ; 8-bit A
         JSR $4B5A      ; RNG: 0..255
         CMP #$55       ; 1 in 3 chance to clear Rflect status
         JMP remove_reflect2  ; (continued...)
	; The following code handles timers and status removal upon expiry.
; The code that handled the Reflect timer was removed, and the second part
; of the new code was inserted at the end of the function.
org $C25AE9
exit:
         RTS
	org $C25B06
C25B06:                 ; (Code relevant to the Reflect timer was
                        ;  removed from the start of this block)
         STA $B8
         LDA $3F0D,X    ; Time until Freeze wears off
         BEQ .sleep     ; Branch if timer not active
         DEC $3F0D,X    ; Decrement Freeze timer
         BNE .sleep
         LDA #$04
         TSB $B8        ; If Freeze timer reached 0 on this tick,
                        ; Set to remove Freeze
.sleep   LDA $3CF9,X    ; Time until Sleep wears off
         BEQ .end       ; Branch if timer not active
         DEC $3CF9,X    ; Decrement Sleep timer
         BNE .end
         LDA #$08
         TSB $B8        ; If Sleep timer reached 0 on this tick,
                        ; Set to remove Sleep
.end     LDA $B8
         BEQ exit       ; Exit if we haven't marked any of the
                        ; Statuses to be auto-removed
         LDA #$29
         JMP $4E91      ; Queue the status removal
	; New code (continued)
; Replaces the code that handled the Reflect timer (14 bytes)
remove_reflect2:
         BCS .end       ; Exit 2/3 times
         LDA $3330,Y    ; Blocked status 3
         BPL .end       ; No removal if permanent Reflect
         JSR remove_reflect3
.end     JMP $22E5      ; Make attack miss
         NOP            ; (Padding)
	; The space freed up by excising the Reflect timer isn't enough to
; handle the message boxes, so here's dipping into free space.
org !freespace
reset bytes
remove_reflect3:
         LDA $3E10,Y    ; Status to clear 3
         ORA #$80       ; Bit 7 = Rflect
         STA $3E10,Y    ; Mark Rflect to be cleared
         RTS
print bytes," bytes added"
