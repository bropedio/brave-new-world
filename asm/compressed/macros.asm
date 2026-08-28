; Common macros for compressed code

; Include symbols here to ensure they are available to all compressed asm
incsrc ../symbols.autogen.asm

; Set mapping mode to None for compressed asm
norom

; Global variable to store the active WRAM origin
!__CURRENT_RAM_BASE__ = $000000

; 1. Set the RAM Base origin for the file
macro baseSet(ram_base)
  !__CURRENT_RAM_BASE__ = <ram_base>
endmacro

; 2. WRAM org macro (automatically uses !__CURRENT_RAM_BASE__)
macro baseOrg(address)
  org <address>-!__CURRENT_RAM_BASE__
  base <address>
endmacro
