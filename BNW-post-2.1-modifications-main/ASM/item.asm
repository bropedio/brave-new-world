arch 65816
hirom

table "menu.tbl",ltr 

;------------------------------------------------------------------
;Item list
;------------------------------------------------------------------

org $D2BEBB

    db $18,"Rename>Card "
    db $18,"Tonic       "
    db $18,"Potion      "
    db $18,"X-Potion    "
    db $18,"Tincture    "
    db $18,"Ether       "
    db $18,"X-Ether     "
    db $18,"Elixir      "
    db $18,"Megalixir   "
    db $18,"Phoenix>Down"
    db $18,"Holy>Water  "
    db $18,"Antidote    "
    db $18,"Eyedrops    "
    db $18,"Snake>Oil   "
    db $18,"Remedy      "
    db $18,"Scrap       "
    db $18,"Tent        "
    db $18,"Green>Cherry"
    db $18,"Phoenix>Tear"
    db $18,"Bouncy>Ball "
    db $18,"Red>Bull    "
    db $18,"Slim>Jim    "
    db $18,"Warp>Whistle"
    db $18,"Dried>Meat  "
    
warnpc $D2BFF3
