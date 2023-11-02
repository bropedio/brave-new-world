hirom

; DF Bank

; ########################################################################
; DFB600-DFB9FF: Colosseum Data (256 items, 4 bytes each) 
;
; -----------------------------------------------------------------------------
; Description
; -----------------------------------------------------------------------------
; This hack modifies the colosseum data of each betting item to store
; its color palette in byte $03 (used for "show/hide reward" info).
;
; vanilla: $00 = show reward / $FF = hide reward
;     now: $00 = hide reward / $XX = color palette
; -----------------------------------------------------------------------------

!open  = $20     ; white text color
!closed = $34     ; yellow text color
!hidden = $00
!i = 0

macro ColoData (byte)
  org $DFB603+!i : db <byte>
  !i #= !i+4
endmacro

%ColoData(!open)     ; Healing Shiv
%ColoData(!open)     ; Mythril Dirk
%ColoData(!closed)   ; Kagenui
%ColoData(!open)     ; Butterfly
%ColoData(!open)     ; Switchblade
%ColoData(!open)     ; Demonsbane
%ColoData(!open)     ; Man Eater
%ColoData(!open)     ; Kunai
%ColoData(!closed)   ; Avenger
%ColoData(!open)     ; Valiance
%ColoData(!open)     ; Mythril Bolo
%ColoData(!open)     ; Iron Cutlass
%ColoData(!open)     ; Scimitar
%ColoData(!closed)   ; Flametongue
%ColoData(!open)     ; Icebrand
%ColoData(!open)     ; Elec Sword
%ColoData(!open)
%ColoData(!open)
%ColoData(!open)     ; Blood Sword
%ColoData(!open)     ; Imperial
%ColoData(!open)     ; Rune Blade
%ColoData(!open)     ; Falchion
%ColoData(!open)     ; Soul Sabre
%ColoData(!open)
%ColoData(!open)     ; Excalibur
%ColoData(!closed)   ; Zantetsuken
%ColoData(!open)     ; Illumina
%ColoData(!open)     ; Apocalypse
%ColoData(!open)     ; Atma Weapon
%ColoData(!open)     ; Mythril Pike
%ColoData(!open)     ; Trident
%ColoData(!open)     ; Stout Spear
%ColoData(!open)     ; Partisan
%ColoData(!open)     ; Longinus
%ColoData(!open)     ; Fire Lance
%ColoData(!closed)   ; Gungnir
%ColoData(!open)     ; Pointy Stick
%ColoData(!open)     ; Tanto
%ColoData(!open)     ; Kunai
%ColoData(!open)     ; Sakura
%ColoData(!open)     ; Ninjato
%ColoData(!hidden)   ; Kagenui
%ColoData(!open)     ; Orochi
%ColoData(!open)     ; Hanzo
%ColoData(!open)     ; Kotetsu
%ColoData(!open)     ; Ichimonji
%ColoData(!open)     ; Kazekiri
%ColoData(!open)     ; Murasame
%ColoData(!open)     ; Masamune
%ColoData(!open)     ; Spoon
%ColoData(!closed)   ; Mutsunokami
%ColoData(!open)     ; Spook Stick
%ColoData(!open)     ; Mythril Rod
%ColoData(!open)     ; Fire Rod
%ColoData(!open)     ; Ice Rod
%ColoData(!open)     ; Thunder Rod
%ColoData(!closed)   ; Wind Breaker
%ColoData(!open)     ; Doomstick
%ColoData(!open)     ; Quartrstaff
%ColoData(!closed)   ; Punisher
%ColoData(!open)
%ColoData(!open)     ; Light Brush
%ColoData(!open)     ; Monet Brush
%ColoData(!open)     ; Dali Brush
%ColoData(!closed)   ; Ross Brush
%ColoData(!open)     ; Shuriken
%ColoData(!open)
%ColoData(!open)     ; Ninja Star
%ColoData(!open)     ; Club
%ColoData(!open)     ; Full Moon
%ColoData(!open)     ; Morning Star
%ColoData(!open)     ; Boomerang
%ColoData(!open)     ; Rising Sun
%ColoData(!open)     ; Kusarigama
%ColoData(!closed)   ; Bone Club
%ColoData(!closed)   ; Magic Bone
%ColoData(!closed)   ; Wing Edge
%ColoData(!open)
%ColoData(!open)     ; Darts
%ColoData(!open)     ; Tarot
%ColoData(!open)     ; Viper Darts
%ColoData(!open)     ; Dice
%ColoData(!open)     ; Fixed Dice
%ColoData(!open)     ; Mythril Claw
%ColoData(!open)     ; Spirit Claw
%ColoData(!open)     ; Poison Claw
%ColoData(!open)     ; Ocean Claw
%ColoData(!open)     ; Hell Claw
%ColoData(!closed)   ; Frostgore
%ColoData(!closed)   ; Stormfang
%ColoData(!open)     ; Buckler
%ColoData(!open)     ; Iron Shield
%ColoData(!open)     ; Targe
%ColoData(!open)     ; Gold Shield
%ColoData(!closed)   ; Aegis Shield
%ColoData(!open)     ; Diamond Kite
%ColoData(!closed)   ; Flameguard
%ColoData(!closed)   ; Iceguard
%ColoData(!open)     ; Thunderguard
%ColoData(!open)     ; Crystal Kite
%ColoData(!closed)   ; Genji Shield
%ColoData(!open)     ; Multiguard
%ColoData(!open)     ; Hero Shield
%ColoData(!open)     ; Hero Shield
%ColoData(!closed)   ; Force Shield
%ColoData(!open)     ; Leather Hat
%ColoData(!open)     ; Hair Band
%ColoData(!open)     ; Plumed Hat
%ColoData(!closed)   ; Ninja Mask
%ColoData(!open)     ; Magus Hat
%ColoData(!open)     ; Bandana
%ColoData(!open)     ; Iron Helm
%ColoData(!open)     ; Skull Cap
%ColoData(!open)     ; Stat Hat
%ColoData(!open)     ; Green Beret
%ColoData(!open)
%ColoData(!open)     ; Mythril Helm
%ColoData(!open)     ; Tiara
%ColoData(!open)     ; Gold Helm
%ColoData(!open)     ; Tiger Mask
%ColoData(!open)     ; Red Cap
%ColoData(!open)     ; Mystery Veil
%ColoData(!open)     ; Circlet
%ColoData(!closed)   ; Dragon Helm
%ColoData(!open)     ; Diamond Helm
%ColoData(!open)     ; Dark Hood
%ColoData(!open)     ; Crystal Helm
%ColoData(!open)     ; Oath Veil
%ColoData(!closed)   ; Cat Hood
%ColoData(!closed)   ; Genji Helm
%ColoData(!open)
%ColoData(!open)
%ColoData(!open)     ; Hard Leather
%ColoData(!open)     ; Cotton Robe
%ColoData(!open)     ; Karate Gi
%ColoData(!open)     ; Iron Armor
%ColoData(!open)
%ColoData(!open)     ; Mythril Vest
%ColoData(!open)     ; Ninja Gear
%ColoData(!open)     ; White Dress
%ColoData(!open)     ; Mythril Mail
%ColoData(!open)     ; Gaia Gear
%ColoData(!closed)   ; Mirage Vest
%ColoData(!open)     ; Gold Armor
%ColoData(!open)     ; Power Armor
%ColoData(!open)     ; Light Robe
%ColoData(!open)     ; Diamond Vest
%ColoData(!closed)   ; Royal Jacket
%ColoData(!closed)   ; Force Armor
%ColoData(!open)     ; Diamond Mail
%ColoData(!open)     ; Dark Gear
%ColoData(!open)
%ColoData(!open)     ; Crystal Mail
%ColoData(!open)     ; Radiant Gown
%ColoData(!closed)   ; Genji Armor
%ColoData(!open)     ; Lazy Shell
%ColoData(!open)     ; Minerva
%ColoData(!open)     ; Tabby Hide
%ColoData(!open)     ; Gator Hide
%ColoData(!open)     ; Chocobo Hide
%ColoData(!open)     ; Moogle Hide
%ColoData(!closed)   ; Dragon Hide
%ColoData(!closed)   ; Snow Muffler
%ColoData(!open)     ; Noiseblaster
%ColoData(!open)     ; Bio Blaster
%ColoData(!open)     ; Flash
%ColoData(!open)     ; Chainsaw
%ColoData(!open)     ; Defibrator
%ColoData(!open)     ; Drill
%ColoData(!open)     ; Mana Battery
%ColoData(!open)     ; Autocrossbow
%ColoData(!open)     ; Fire Scroll
%ColoData(!open)     ; Wave Scroll
%ColoData(!open)     ; Bolt Scroll
%ColoData(!open)     ; Inviz Scroll
%ColoData(!open)     ; Smoke Bomb
%ColoData(!open)     ; Leo's Crest
%ColoData(!open)     ; Bracelet
%ColoData(!open)     ; Spirit Stone
%ColoData(!open)     ; Amulet
%ColoData(!open)     ; White Cape
%ColoData(!open)     ; Talisman
%ColoData(!open)     ; Fairy Charm
%ColoData(!open)     ; Barrier Cube
%ColoData(!open)     ; Safety Glove
%ColoData(!open)     ; Guard Ring
%ColoData(!open)     ; Sprint Shoes
%ColoData(!open)     ; Reflect Ring
%ColoData(!open)     ;  -
%ColoData(!open)     ; Gum Pod
%ColoData(!open)     ; Knight Cape
%ColoData(!open)     ; Dragoon Seal
%ColoData(!open)     ; Zephyr Cape
%ColoData(!open)     ; Mystery Egg
%ColoData(!open)     ; Black Heart
%ColoData(!closed)   ; Magic Cube
%ColoData(!closed)   ; Power Glove
%ColoData(!closed)   ; Blizzard Orb
%ColoData(!closed)   ; Psycho Belt
%ColoData(!closed)   ; Rogue Cloak
%ColoData(!open)     ; Wall Ring
%ColoData(!open)     ; Hero Ring
%ColoData(!open)     ; Ribbon
%ColoData(!closed)   ; Muscle Belt
%ColoData(!closed)   ; Crystal Orb
%ColoData(!open)     ; Goggles
%ColoData(!open)     ; Soul Box
%ColoData(!open)     ; Thief Glove
%ColoData(!open)
%ColoData(!open)
%ColoData(!open)     ; Hyper Wrist
%ColoData(!open)
%ColoData(!open)
%ColoData(!open)
%ColoData(!closed)   ; Heiji's Coin
%ColoData(!closed)   ; Sage Stone
%ColoData(!open)     ; Gem Box
%ColoData(!closed)   ; Nirvana Band
%ColoData(!open)     ; Economizer
%ColoData(!open)     ; Memento Ring
%ColoData(!open)     ; Quartz Charm
%ColoData(!open)     ; Ghost Ring
%ColoData(!open)     ; Moogle Charm
%ColoData(!closed)   ; Black Belt
%ColoData(!open)     ; Codpiece
%ColoData(!open)     ; Back Guard
%ColoData(!open)     ; Gale Hairpin
%ColoData(!open)     ; Stat Stick
%ColoData(!closed)   ; Daryl's Soul
%ColoData(!closed)   ; Life Bell
%ColoData(!open)     ; Dirty Undies
%ColoData(!open)     ; Rename Card
%ColoData(!open)     ; Tonic
%ColoData(!open)     ; Potion
%ColoData(!open)     ; X-Potion
%ColoData(!open)     ; Tincture
%ColoData(!open)     ; Ether
%ColoData(!open)     ; X-Ether
%ColoData(!open)     ; Elixir
%ColoData(!open)     ; Megalixir
%ColoData(!open)     ; Phoenix Down
%ColoData(!open)     ; Holy Water
%ColoData(!open)     ; Antidote
%ColoData(!open)     ; Eyedrops
%ColoData(!open)     ; Snake Oil
%ColoData(!open)     ; Remedy
%ColoData(!open)     ; Scrap
%ColoData(!open)     ; Tent
%ColoData(!open)     ; Green Cherry
%ColoData(!open)     ; Phoenix Tear
%ColoData(!open)     ; Bouncy Ball
%ColoData(!open)     ; Red Bull
%ColoData(!open)     ; Slim Jim
%ColoData(!open)     ; Warp Whistle
%ColoData(!open)     ; Dried Meat
%ColoData(!open)     ; Empty

