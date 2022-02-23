hirom
header

;Change Narshe three-party battle to a two-party battle

;Change number of parties to 2
org $CCC665
db $99,$82,$00,$00    ;Invoke party selection screen (2 groups) (force characters: [$0000])

;Change starting position of party 1
;Before Kefka's arrival
org $CCC69B
db $D5,$13,$0A        ;Set vehicle/entity's position to (19, 10)
;After Kefka's arrival
org $CCC85D
db $D5,$13,$0A        ;Set vehicle/entity's position to (19, 10)

;Change starting position of party 2
;Before Kefka's arrival
org $CCC6AA
db $D5,$15,$0A        ;Set vehicle/entity's position to (21, 10)
;After Kefka's arrival
org $CCC86C
db $D5,$15,$0A        ;Set vehicle/entity's position to (21, 10)

;Remove event script bytes pertaining to the unused third party
org $CCC6B3
padbyte $FD : pad $CCC6C2    ;$FD = event script equivalent of NOP
	org $CCC875
padbyte $FD : pad $CCC884    ;$FD = event script equivalent of NOP
