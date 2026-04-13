// Horse equipment items - saddles, bridles, and wraps

/obj/item/horse_saddle
	name = "saddle"
	desc = "A saddle for a horse. Makes riding more comfortable."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "w_saddle_lazuli"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	var/on_horse = FALSE

/obj/item/horse_saddle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_saddle/western/heather
	name = "Heather saddle"
	icon_state = "w_saddle_heather"
	desc = "A vibrant pink saddle with a purple saddle pad."

/obj/item/horse_saddle/western/lazuli
	name = "Lazuli saddle"
	icon_state = "w_saddle_lazuli"
	desc = "A flamboyant, silver-studded western saddle."

/obj/item/horse_saddle/western/saguaro
	name = "Saguaro saddle"
	icon_state = "w_saddle_saguaro"
	desc = "A green western saddle with a foam saddle pad."

/obj/item/horse_saddle/western/eldorado
	name = "El Dorado saddle"
	icon_state = "w_saddle_eldorado"
	desc = "A tooled leather saddle with a serape blanket."

/obj/item/horse_saddle/western/undercover
	name = "Undercover saddle"
	icon_state = "w_saddle_undercover"
	desc = "A flecktarn western saddle. You can barely tell it's there."

/obj/item/horse_saddle/english/insignia
	name = "Insignia saddle"
	icon_state = "e_saddle_insignia"
	desc = "A classic English saddle with a cotton saddle pad."

/obj/item/horse_saddle/english/bubblegum
	name = "Bubblegum saddle"
	icon_state = "e_saddle_bubblegum"
	desc = "An iridescent English saddle with a shimmery blanket."

/obj/item/horse_saddle/english/seafoam
	name = "Seafoam saddle"
	icon_state = "e_saddle_seafoam"
	desc = "A lightweight English saddle with a teal blanket."

/obj/item/horse_saddle/english/summertime
	name = "Summertime saddle"
	icon_state = "e_saddle_summertime"
	desc = "An lightweight English saddle with a beachy striped blanket."

/obj/item/horse_bridle
	name = "bridle"
	desc = "A bridle for a horse. Helpful for steering."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "w_bridle_lazuli"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	var/on_horse = FALSE

/obj/item/horse_bridle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_bridle/western/
	name = "western bridle"
	// all the western-specific bridle stuff would go here

/obj/item/horse_bridle/english/
	name = "English bridle"
	// all the english-specific bridle stuff would go here

/obj/item/horse_bridle/western/heather
	name = "Heather bridle"
	icon_state = "w_bridle_heather"
	desc = "A soft pink western bridle."

/obj/item/horse_bridle/western/lazuli
	name = "Lazuli bridle"
	icon_state = "w_bridle_lazuli"
	desc = "A bejeweled western bridle. Very flashy."

/obj/item/horse_bridle/western/saguaro
	name = "Saguaro bridle"
	icon_state = "w_bridle_saguaro"
	desc = "A soft green western bridle."

/obj/item/horse_bridle/western/eldorado
	name = "El Dorado bridle"
	icon_state = "w_bridle_eldorado"
	desc = "A traditional western bridle. It lacks a noseband, allowing the horse more comfort and freedom."

/obj/item/horse_bridle/western/undercover
	name = "Undercover bridle"
	icon_state = "w_bridle_undercover"
	desc = "A flecktarn western bridle - for the stealthy horse."

/obj/item/horse_bridle/english/insignia
	name = "Insignia bridle"
	icon_state = "e_bridle_insignia"
	desc = "A classic English bridle."

/obj/item/horse_bridle/english/bubblegum
	name = "Bubblegum bridle"
	icon_state = "e_bridle_bubblegum"
	desc = "A strangely iridescent English bridle."

/obj/item/horse_bridle/english/seafoam
	name = "Seafoam bridle"
	icon_state = "e_bridle_seafoam"
	desc = "A gorgeous teal English bridle."

/obj/item/horse_bridle/english/summertime
	name = "Summertime bridle"
	icon_state = "e_bridle_summertime"
	desc = "A playful orange English bridle."

/obj/item/horse_wraps
	name = "leg wraps"
	desc = "Protective leg wraps for a horse."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "w_wraps_lazuli"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	var/on_horse = FALSE

/obj/item/horse_wraps/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_wraps/western/
	// all the western-specific wraps stuff would go here

/obj/item/horse_wraps/english/
	// all the English-specific wraps stuff would go here

// Leg wraps don't really have the western/English split that other tack does
// But since these are matching sets, we might want to sort by western and English on the market
// Also could have different stat bonuses, but any difference should be very slight for wraps

/obj/item/horse_wraps/western/heather
	name = "Heather leg wraps"
	icon_state = "w_wraps_heather"
	desc = "Pink and purple leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/western/lazuli
	name = "Lazuli leg wraps"
	icon_state = "w_wraps_lazuli"
	desc = "Silky blue leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/western/saguaro
	name = "Saguaro leg wraps"
	icon_state = "w_wraps_saguaro"
	desc = "Green leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/western/eldorado
	name = "El Dorado leg wraps"
	icon_state = "w_wraps_eldorado"
	desc = "Rustic striped leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/western/undercover
	name = "Undercover leg wraps"
	icon_state = "w_wraps_undercover"
	desc = "Flecktarn leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/english/insignia
	name = "Insignia leg wraps"
	icon_state = "e_wraps_insignia"
	desc = "Classic leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/english/bubblegum
	name = "Bubblegum wraps"
	icon_state = "e_wraps_bubblegum"
	desc = "Iridescent leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/english/seafoam
	name = "Seafoam wraps"
	icon_state = "e_wraps_seafoam"
	desc = "Teal leg wraps for a horse. Provides protection and support."

/obj/item/horse_wraps/english/summertime
	name = "Summertime wraps"
	icon_state = "e_wraps_summertime"
	desc = "Bright and beachy leg wraps for a horse. Provides protection and support."
