; ========================================================================
; Battle RAM
; ========================================================================

; ------------------------------------------------------------------------
; Freed battle RAM $3E61-3E88 (30 bytes) [quasi status bytes]
; First quasi status byte repurposed for delayed status removal
!died_flag = $3E60 ; 1 RAM byte to track status removal needs

; ------------------------------------------------------------------------
!unequip = $2E6E ; (1 byte) - Bitmask for which characters are unequipping
; $2E6F $2E70 $2E71 (3 bytes) - Free. Was for genji effect

; ------------------------------------------------------------------------
; Used by dn's aura cycling hack (1 byte per character)
!aura_cycle = $2EA9 ; $2EC9 ; $2EE9 ; $2F09

; ------------------------------------------------------------------------
; Mind Blast targets (new location for more targets
; Old Mind Blast RAM unused: $3A5C - $3A63
!blast = $3F54 ; $3F55 $3F56 $3F57 $3F58 $3F59 $3F5A $3F5B $3F5C $3F5D

; ========================================================================
; SRAM
; ========================================================================

; ------------------------------------------------------------------------
; Esper Levels, Esper Experience, and Spell Bank
!EP = $1CF8  ; (through $1D0F) - 2 bytes per character
!EL = $1D10  ; (through $1D1B) - 1 byte per character
!EL_bank = $1D1C    ; (through $1D27) - 1 byte per character
!spell_bank = $1E1D ; (through $1E28) - 1 byte per character
