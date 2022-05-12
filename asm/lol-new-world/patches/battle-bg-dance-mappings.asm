; Edit Mog's Dances
; thzfunnymzn

; Dance ## = Final Fantasy VI   -->   Lol New World
;
; 	World of Balance
; Dance 00 = Wind Song            Earth Blues
; Dance 01 = Forest Suite         Fire Waltz
; Dance 02 = Desert Aria          Wind Song
; Dance 03 = Love Sonata          Water Rondo
;
; 	World of Ruin
; Dance 04 = Earth Blues          Ruin Lament
; Dance 05 = Water Rondo          Love Requiem
; Dance 06 = Dusk Requiem         Soul Dirge
; Dance 07 = Snowman Jazz         Dancing Mad

!Earth		= #$00
!Fire		= #$01
!Wind		= #$02
!Water		= #$03
!Ruin		= #$04
!Love		= #$05
!Soul		= #$06
!Dancing	= #$07

org $ED8E5B
	db !Wind ; Grass, WoB
	db !Earth ; Brown Forest, WoR
	db !Wind ; Desert, WoB
	db !Earth ; Green Forest, WoB
	db !Water ; Zozo, inside building
	db !Ruin ; World of Ruin
	db !Wind ; Veldt, WoB
	db !Wind ; Falling through Clouds
	db !Ruin ; Narshe Exterior
	db !Earth ; Mines, WoB
	db !Earth ; Mines, WoR
	db !Wind ; Mountain Top
	db !Earth ; Mountain Cave
	db !Water ; River Raft
	db !Wind ; Imperial Base
	db !Soul ; Train Car, Top
	db !Soul ; Train Car, Inside
	db !Earth ; Blue/Purple Cave, WoB
	db !Ruin ; Icy Field
	db !Fire ; South Figaro
	db !Fire ; Imperial Castle
	db !Earth ; Floating Island
	db !Dancing ; Kefka's Tower, exterior
	db !Love ; Opera Stage
	db !Love ; Opera Rafters
	db !Fire ; Burning House
	db !Ruin ; Ancient Castle / Figaro Basement
	db !Fire ; Magitek Factory
	db !Ruin ; Colosseum
	db !Fire ; Magitek Factory / Imperial Vector 2
	db !Dancing ; Thamasa
	db !Water ; Waterfall
	db !Soul ; Owzer's Mansion
	db !Soul ; Running on Train Tracks
	db !Earth ; Bridge near Sealed Gate
	db !Water ; Underwater
	db !Water ; Zozo
	db !Wind ; Airship, WoB, centered
	db !Love ; Tomb
	db !Ruin ; Doma, Ancient Castle exterior
	db !Dancing ; Kefka's Tower, interior
	db !Wind ; Airship, WoR, right
	db !Fire ; Lava Caves
	db !Soul ; Fanatics' Tower, inside
	db !Fire ; Mine Cart
	db !Soul ; Fanatics' Tower, outside
	db !Love ; Cyan's Soul
	db !Wind ; Desert, WoR
	db !Wind ; Airship, WoB, right
	db !Wind ; Unused
	db !Soul ; Used for Phantom Train
	db !Dancing ; Final Battle, Tier 1
	db !Dancing ; Final Battle, Tier 2
	db !Dancing ; Final Battle, Tier 3
	db !Dancing ; Final Battle, Tier 4
	db !Ruin ; Tentacles