/obj/item/gun/ballistic/rifle/boltaction/horsetest
	icon = 'modular_horsetest/modules/guns/sprites/boltactionrifles.dmi'
	show_bolt_icon = FALSE
	obj_flags = UNIQUE_RENAME
	need_bolt_lock_to_interact = TRUE
	slot_flags = ITEM_SLOT_BACK
	can_be_sawn_off = FALSE

	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/rifle/boltaction/horsetest/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[bolt_locked ? "open" : "closed"]"

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model110
	name = "\improper Model 110 Bolt-Action Rifle"
	desc = "A bolt-action rifle with a wooden stock. Reliable, accurate, and well-suited to frontier life. Uses .310 Strilka rounds."
	icon_state = "110_closed"
	base_icon_state = "110"

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model110/scope
	name = "\improper Model 110 Scoped Rifle"
	desc = "A Model 110 bolt-action rifle fitted with a magnified optic. Uses .310 Strilka rounds."
	icon_state = "110scope_closed"
	base_icon_state = "110scope"

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model110/scope/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model111
	name = "\improper Model 111 Bolt-Action Rifle"
	desc = "A modernized bolt-action rifle with a synthetic black stock. Lighter and a little more accurate than its wooden-stocked counterpart. Uses .310 Strilka rounds."
	icon_state = "111_closed"
	base_icon_state = "111"

	projectile_damage_multiplier = 1.05
	spread = -2

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model111/scope
	name = "\improper Model 111 Scoped Rifle"
	desc = "A Model 111 bolt-action rifle with a mounted scope and stock. Uses .310 Strilka rounds."
	icon_state = "111scope_closed"
	base_icon_state = "111scope"

	projectile_damage_multiplier = 1.05
	spread = -4

/obj/item/gun/ballistic/rifle/boltaction/horsetest/model111/scope/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/shotgun/doublebarrel/horsetest/sawedoff
	name = "\improper Sawn-Off Double Barrel"
	desc = "A break-action double-barreled shotgun cut down to pocket size. Devastating up close, useless at range."
	icon = 'modular_horsetest/modules/guns/sprites/boltactionrifles.dmi'
	icon_state = "sawn-off_closed"
	base_icon_state = "sawn-off"
	obj_flags = UNIQUE_RENAME
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	spread = 24
	pb_knockback = 3
	can_be_sawn_off = FALSE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/shotgun/doublebarrel/horsetest/sawedoff/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[get_ammo() ? "closed" : "open"]"
