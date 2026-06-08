/obj/item/gun/ballistic/shotgun/horsetest
	icon = 'modular_horsetest/modules/guns/sprites/pumpactionshotguns.dmi'
	obj_flags = UNIQUE_RENAME
	slot_flags = ITEM_SLOT_BACK

/obj/item/gun/ballistic/shotgun/horsetest/stakeout
	name = "\improper Stakeout Shotgun"
	desc = "A compact pump-action shotgun with a pistol grip and no stock. Easy to carry, awkward to aim."
	icon_state = "stakeout"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/horsetest/stakeout
	weapon_weight = WEAPON_MEDIUM
	spread = 8
	projectile_damage_multiplier = 0.9

/obj/item/gun/ballistic/shotgun/horsetest/sawnoff
	name = "\improper Sawn-Off Pump Shotgun"
	desc = "A pump-action shotgun with the barrel and stock hacked off. Concealable, but wildly inaccurate."
	icon_state = "sawn-off"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/horsetest/sawnoff
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	spread = 20
	projectile_damage_multiplier = 0.85
	pb_knockback = 3

/obj/item/gun/ballistic/shotgun/horsetest/riot
	name = "\improper Riot Pump Shotgun"
	desc = "A standard pump-action shotgun with a full wooden stock and extended tube magazine. A common choice for crowd control."
	icon_state = "riot"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/horsetest/riot
	fire_delay = 8 DECISECONDS

/obj/item/gun/ballistic/shotgun/horsetest/tactical
	name = "\improper Tactical Pump Shotgun"
	desc = "A pump-action shotgun with black polymer furniture. Hits a little harder than the wooden-stocked models."
	icon_state = "tactical"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/horsetest/tactical
	projectile_damage_multiplier = 1.1
	spread = -2

/obj/item/gun/ballistic/shotgun/horsetest/extended
	name = "\improper Extended Pump Shotgun"
	desc = "A pump-action shotgun with an elongated barrel and magazine tube. More shells and better accuracy at the cost of bulk."
	icon_state = "extended"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/horsetest/extended
	w_class = WEIGHT_CLASS_HUGE
	projectile_damage_multiplier = 1.05
	spread = -4

/obj/item/ammo_box/magazine/internal/shot/horsetest/stakeout
	name = "stakeout shotgun internal magazine"
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/horsetest/sawnoff
	name = "sawn-off shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/horsetest/riot
	name = "riot shotgun internal magazine"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/horsetest/tactical
	name = "tactical shotgun internal magazine"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/horsetest/extended
	name = "extended shotgun internal magazine"
	max_ammo = 8
