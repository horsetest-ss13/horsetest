/obj/item/gun/ballistic/revolver/c38/fitzspecial
	name = "\improper Fitz Special"
	desc = "A snub-nosed revolver with a shortened barrel and grip, designed for concealment. The short barrel reduces muzzle velocity significantly. Uses .38 Special rounds."
	icon = 'modular_horsetest/modules/revolvers/sprites/doubleactionrevolvers.dmi'
	icon_state = "fitzspecial_closed"
	base_icon_state = "fitzspecial"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/fitzspecial
	obj_flags = UNIQUE_RENAME

	projectile_damage_multiplier = 0.8 // 25 * 0.8 = 20 damage
	fire_delay = 0.2 SECONDS
	recoil = 0.5
	spread = 5

	can_modify_ammo = FALSE

/obj/item/gun/ballistic/revolver/c38/fitzspecial/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[magazine?.ammo_count() ? "closed" : "open"]"

/obj/item/ammo_box/magazine/internal/cylinder/rev38/fitzspecial
	name = "Fitz Special cylinder"
	max_ammo = 5

/obj/item/gun/ballistic/revolver/c38/chiefsspecial
	name = "\improper Chief's Special"
	desc = "A compact service revolver popular with detectives and plainclothes officers. Its performance is nearly identical to the Detective Special. Uses .38 Special rounds."
	icon = 'modular_horsetest/modules/revolvers/sprites/doubleactionrevolvers.dmi'
	icon_state = "chiefsspecial_closed"
	base_icon_state = "chiefsspecial"
	obj_flags = UNIQUE_RENAME

	projectile_damage_multiplier = 1.0
	fire_delay = 0.2 SECONDS
	recoil = 0.5

	can_modify_ammo = FALSE

/obj/item/gun/ballistic/revolver/c38/chiefsspecial/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[magazine?.ammo_count() ? "closed" : "open"]"

/obj/item/gun/ballistic/revolver/c38/model10classic
	name = "\improper Model 10 Classic"
	desc = "A reliable service revolver with a medium-length barrel. The increased barrel length provides better accuracy and muzzle velocity compared to compact models. Uses .38 Special rounds."
	icon = 'modular_horsetest/modules/revolvers/sprites/doubleactionrevolvers.dmi'
	icon_state = "model10classic_closed"
	base_icon_state = "model10classic"
	obj_flags = UNIQUE_RENAME

	projectile_damage_multiplier = 1.12
	fire_delay = 0.25 SECONDS
	recoil = 0.4
	spread = -2

	can_modify_ammo = FALSE

/obj/item/gun/ballistic/revolver/c38/model10classic/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[magazine?.ammo_count() ? "closed" : "open"]"

/obj/item/gun/ballistic/revolver/c38/model10bull
	name = "\improper Model 10 Bull Barrel"
	desc = "A heavy-framed revolver with a bull barrel design for improved accuracy and recoil management. The extended barrel provides excellent muzzle velocity. Uses .38 Special rounds."
	icon = 'modular_horsetest/modules/revolvers/sprites/doubleactionrevolvers.dmi'
	icon_state = "model10bull_closed"
	base_icon_state = "model10bull"
	obj_flags = UNIQUE_RENAME

	projectile_damage_multiplier = 1.2
	fire_delay = 0.3 SECONDS
	recoil = 0.3
	spread = -4

	can_modify_ammo = FALSE

/obj/item/gun/ballistic/revolver/c38/model10bull/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[magazine?.ammo_count() ? "closed" : "open"]"

/obj/item/gun/ballistic/revolver/model19
	name = "\improper Model 19 Combat Magnum"
	desc = "A versatile combat revolver with the longest barrel in its class. Capable of chambering both .357 Magnum and .38 Special rounds, offering flexibility in ammunition selection. The extended barrel provides maximum muzzle velocity for either cartridge."
	icon = 'modular_horsetest/modules/revolvers/sprites/doubleactionrevolvers.dmi'
	icon_state = "model19_closed"
	base_icon_state = "model19"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38 // Uses standard .38 cylinder
	obj_flags = UNIQUE_RENAME

	projectile_damage_multiplier = 1.28
	fire_delay = 0.35 SECONDS
	recoil = 0.6
	spread = -6

	can_modify_ammo = TRUE
	initial_caliber = CALIBER_38
	initial_fire_sound = 'sound/items/weapons/gun/revolver/shot.ogg'
	alternative_caliber = CALIBER_357
	alternative_fire_sound = 'sound/items/weapons/gun/revolver/shot_alt.ogg'
	alternative_ammo_misfires = FALSE

/obj/item/gun/ballistic/revolver/model19/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[magazine?.ammo_count() ? "closed" : "open"]"

/obj/item/gun/ballistic/revolver/model19/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return

	if(magazine.caliber == CALIBER_357)
		projectile_damage_multiplier = 1.0
	else
		projectile_damage_multiplier = 1.28
