arch 65816
hirom

table "menu.tbl",ltr 

;------------------------------------------------------------------
;Item list
;------------------------------------------------------------------

org $D2BEBB

    db $C9,"Rename>Card "
    db $C9,"Tonic       "
    db $C9,"Potion      "
    db $C9,"X-Potion    "
    db $C9,"Tincture    "
    db $C9,"Ether       "
    db $C9,"X-Ether     "
    db $C9,"Elixir      "
    db $C9,"Megalixir   "
    db $C9,"Phoenix>Down"
    db $C9,"Holy>Water  "
    db $C9,"Antidote    "
    db $C9,"Eyedrops    "
    db $C9,"Snake>Oil   "
    db $C9,"Remedy      "
    db $C9,"Scrap       "
    db $C9,"Tent        "
    db $C9,"Green>Cherry"
    db $C9,"Phoenix>Tear"
    db $C9,"Bouncy>Ball "
    db $C9,"Red>Bull    "
    db $C9,"Slim>Jim    "
    db $C9,"Warp>Whistle"
    db $C9,"Dried>Meat  "
    
warnpc $D2BFF3