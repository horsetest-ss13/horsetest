// Experimental donkey code within //

		//// **Notes for this file** ////

// need to set it up for donkey breeding
// you can breed a donkey to a horse, but you'll get a mule/hinny, which is sterile
// the only possible offspring of a donkey are
	// a donkey
	// a mule (if bred with a horse and the donkey is the male parent)
	// a hinny (if bred with a horse and the donkey is the female parent)
	// a zonkey, if the other parent is a zebra (which we have yet to add)

// mules/hinnies should be the same creature but just named differently based on parentage

/mob/living/basic/horse/donkey
	name = "donkey"
	desc = "A sturdy and loyal equine creature. More compact than a horse."
	icon = 'modular_horsetest/modules/horse/icons/horse.dmi'
	icon_state = "donkey"
	icon_living = "donkey"
	icon_dead = "pony_dead"
	horse_color_variant = "donkey"
	speak_emote = list("brays")

/mob/living/basic/horse/donkey/Initialize(mapload)
	breed = get_breed_datum(/datum/horse_breed/donkey)
	return ..()

/mob/living/basic/horse/donkey/set_random_color_variant()
	horse_color_variant = "donkey"
	icon_state = horse_color_variant
	icon_living = horse_color_variant
	icon_dead = "pony_dead"

/mob/living/basic/horse/donkey/look_dead()
	icon = 'icons/mob/simple/animal.dmi'
	return ..()

/mob/living/basic/horse/donkey/look_alive()
	icon = initial(icon)
	return ..()

/datum/emote/horse/bray
	key = "bray"
	key_third_person = "brays"
	message = "brays loudly."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	mob_type_allowed_typecache = /mob/living/basic/horse/donkey

// add braying sound
