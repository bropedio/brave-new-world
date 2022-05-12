hirom

; C2 freespace fragments utilized:
!Automorph_freeC2 = $C2FC10     ; uses 5/7 bytes
!TieredStatus_freeC2 = $C2515D  ; uses 4/4 bytes
!StamDogBlock_freeC2 = $C23C6E  ; uses 5/7 bytes


!free = $EFFBDA ; point this at a big chunk


; patches utilizing consecutive freespace:

!TieredStatus_freeXX = !free
incsrc "patches/tiered-status.asm"

!Automorph_freeXX = TieredStatus_EOF
incsrc "patches/auto-morph.asm"

!HalfTurnBrushes_freespace = Automorph_EOF
incsrc "patches/half-atb-brushes.asm"

!HalfTurnStumble_freespace = HalfTurnBrushes_EOF
incsrc "patches/half-atb-stumble.asm"

!StamDogBlock_freeXX = HalfATBStumble_EOF
incsrc "patches/stam-dog-block.asm"

!RunicCounter_freespace = StamDogBlock_EOF
incsrc "patches/runic-counter.asm"

!HalfTurnBlitz_freespace = RunicCounter_EOF
incsrc "patches/half-atb-blitz-failure.asm"

!MorphMPTurbo_freespace = HalfATBBlitzFailure_EOF
incsrc "patches/morph-mp-turbo.asm"

!IndividulReprisal_freespace = MorphMPTurbo_EOF
incsrc "patches/individual-reprisal.asm"

!HalfTurnItemFlag_freespace = IndividualReprisal_EOF
incsrc "patches/half-turn-item-flag.asm"

; next = HalfTurnItemFlag_EOF


; inline patches (no new freespace claimed):

incsrc "patches/el-tweaks.asm"
incsrc "patches/uncapped-drain.asm"
incsrc "patches/battle-bg-dance-mappings.asm"
incsrc "patches/vigor-based-counter.asm"
incsrc "patches/tweak-stumble-rate.asm"
incsrc "patches/crit-fishing.asm"
incsrc "patches/not-so-near-fatal.asm"


; data/description edits
incsrc "patches/data/dance-descriptions.asm"


; event edits
incsrc "patches/events/relm-interceptor.asm"


; on loan from Bropedio; I haven't scrutinized these, just assuming they're going to work as advertised
incsrc "patches/Bropedio/golem-restrictions.asm" ; omit when building against 2.1
incsrc "patches/Bropedio/inventory-limits.asm"


; Config screen header

table "patches/data/c3.tbl",rtl

org $C33BBA
db "LOL New World 1.0.0a",$00
