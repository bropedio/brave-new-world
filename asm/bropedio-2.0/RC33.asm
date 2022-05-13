hirom
; header

; BNW - Bropatch
; Bropedio (December 31, 2019)
;
; This master file includes all bugfixes and patches for RC33
; of Brave New World 2.0.

incsrc formation-randomness.asm
incsrc run-fast-2.asm
incsrc gau-stepping.asm
incsrc phantom-bug.asm
incsrc scan-free.asm
incsrc atb-draw-fix.asm
incsrc quickfill.asm
incsrc double-gp.asm
incsrc palidor-bug.asm              ; uses freespace from "esper-level-simplify"
incsrc weapon-swap-complete.asm
incsrc death-counter-status.asm
incsrc inform-miss-3.asm            ; requires "mind-blast"
incsrc chainsaw-fix.asm             ; requires "inform-miss-3"
incsrc overcast-ring.asm
incsrc sos-relics.asm
incsrc inventory-count.asm
incsrc x-fight-retarget.asm
incsrc proc-bug.asm
incsrc gau-targeting.asm
incsrc review-screen-esper.asm
incsrc drain-swirly.asm
incsrc rage-dance-descriptions.asm
incsrc skip-criticals-flag.asm
incsrc xkill-anim.asm               ; requires "chainsaw-fix", uses freespace from "skip-criticals-flag"
incsrc brush-retarget-4.asm         ; uses freespace from "x-fight-crits"
incsrc item-save.asm
incsrc quartrstaff-boss-fix.asm
incsrc rod-break-clear.asm
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
