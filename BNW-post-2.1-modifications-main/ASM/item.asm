arch 65816
hirom

table "menu.tbl",ltr 

;------------------------------------------------------------------
;Item list
;------------------------------------------------------------------

org $D2BC99
	db $EB 

org $D2BB7B
	db $D8,"Defibr",$10,$11,"ator"

org $D2BEBB

    db $EB,"Rename>Card "
    db $EB,"Tonic       "
    db $EB,"Potion      "
    db $EB,"X-Potion    "
    db $EB,"Tincture    "
    db $EB,"Ether       "
    db $EB,"X-Ether     "
    db $EB,"Elixir      "
    db $EB,"Megalixir   "
    db $EB,"Phoenix>Down"
    db $EB,"Holy>Water  "
    db $EB,"Antidote    "
    db $EB,"Eyedrops    "
    db $EB,"Snake>Oil   "
    db $EB,"Remedy      "
    db $EB,"Scrap       "
    db $EB,"Tent        "
    db $EB,"Green>Cherry"
    db $EB,"Phoenix>Tear"
    db $EB,"Bouncy>Ball "
    db $EB,"Red>Bull    "
    db $EB,"Slim>Jim    "
    db $EB,"Warp>Whistle"
    db $EB,"Dried>Meat  "
    
warnpc $D2BFF3

;------------------------------------------------------------------
;fan translation items
;------------------------------------------------------------------

;org $D2C11B
;
;    db $EB,"Chocobo>Wing"
;    db $EB,"Hero>Drink  "
