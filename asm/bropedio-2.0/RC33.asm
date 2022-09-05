hirom
; header

; BNW - Bropatch
; Bropedio (December 31, 2019)
;
; This master file includes all bugfixes and patches for RC33
; of Brave New World 2.0.

incsrc equipdesc-bnw.asm
incsrc status-screen.asm            ; requires "equipdesc-bnw" (I think)
incsrc random-party.asm
incsrc palidor-redux.asm
incsrc stray-fix.asm
incsrc mug-better.asm               ; requires "inform-miss-3", "xkill-anim"
incsrc jump-better.asm              ; requires "mug-better"
incsrc parry-counter-cross.asm      ; requires "inform-miss-3"
incsrc roll-better.asm
incsrc lagomorph-msg.asm
incsrc morph-tier-fix.asm
incsrc hidon-always.asm
incsrc rich-man-hang.asm
incsrc init-dead-status.asm
incsrc umaro-charge-row.asm
incsrc doggy-miss-bug.asm
incsrc mimic-mimic.asm
incsrc petrify-morph-immunes.asm
incsrc poison-ticks.asm
incsrc version.asm
incsrc shock-display.asm
incsrc ep-gain-bug.asm              ; requires "parry-counter-cross"
incsrc ancient-basement.asm

; New/Updated in RC33
incsrc checksum.asm
