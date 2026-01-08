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

/datum/supply_pack/service/apple_crate
	name = "Apple Crate"
	desc = "Ten apples."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/food/grown/apple = 10)
	crate_name = "apple crate"
