; Battle RAM

; Used by dn's aura cycling hack (1 byte per character)
!aura_cycle = $2EA9 ; $2EC9 ; $2EE9 ; $2F09

; SRAM

; Esper Levels, Esper Experience, and Spell Bank
!EP = $1CF8  ; (through $1D0F) - 2 bytes per character
!EL = $1D10  ; (through $1D1B) - 1 byte per character
!EL_bank = $1D1C    ; (through $1D27) - 1 byte per character
!spell_bank = $1E1D ; (through $1E28) - 1 byte per character
