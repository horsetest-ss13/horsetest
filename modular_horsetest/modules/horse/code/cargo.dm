/datum/supply_pack/critter/horse
	name = "Horse Crate"
	desc = "Contains one majestic horse. Handle with care!"
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/mob/living/basic/horse)
	crate_name = "horse crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/critter/horse_supplements
	name = "Horse Supplements Crate"
	desc = "A variety pack of horse supplements to boost your horse's stats."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/food/horse_supplement/speed_oats = 3,
		/obj/item/food/horse_supplement/brain_biscuits = 3,
		/obj/item/food/horse_supplement/calming_treats = 3,
	)
	crate_name = "horse supplements crate"

/datum/supply_pack/critter/tack/western
	name = "Western Tack Crate (El Dorado)"
	desc = "Complete western tack set including saddle, bridle, and leg wraps. This one is the El Dorado set."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/horse_saddle/western/eldorado,
		/obj/item/horse_bridle/western/eldorado,
		/obj/item/horse_wraps/western/eldorado,

	)
	crate_name = "tack crate"

/datum/supply_pack/critter/tack/western/saguaro
	name = "Western Tack Crate (Saguaro)"
	desc = "Complete western tack set including saddle, bridle, and leg wraps. This one is the Saguaro set."
	contains = list(
		/obj/item/horse_saddle/western/saguaro,
		/obj/item/horse_bridle/western/saguaro,
		/obj/item/horse_wraps/western/saguaro,
	)

/datum/supply_pack/critter/tack/western/lazuli
	name = "Western Tack Crate (Lazuli)"
	desc = "Complete western tack set including saddle, bridle, and leg wraps. This one is the Lazuli set."
	contains = list(
		/obj/item/horse_saddle/western/lazuli,
		/obj/item/horse_bridle/western/lazuli,
		/obj/item/horse_wraps/western/lazuli,
	)

/datum/supply_pack/service/apple_crate
	name = "Apple Crate"
	desc = "Ten apples."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/food/grown/apple = 10)
	crate_name = "apple crate"
