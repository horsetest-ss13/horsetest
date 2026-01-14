// Horse equipment items - saddles, bridles, and wraps

/obj/item/horse_saddle
	name = "horse saddle"
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

/obj/item/horse_saddle/heather
	name = "heather saddle"
	icon_state = "w_saddle_heather"

/obj/item/horse_saddle/lazuli
	name = "lazuli saddle"
	icon_state = "w_saddle_lazuli"

/obj/item/horse_saddle/saguaro
	name = "saguaro saddle"
	icon_state = "w_saddle_saguaro"

/obj/item/horse_saddle/eldorado
	name = "eldorado saddle"
	icon_state = "w_saddle_eldorado"

/obj/item/horse_saddle/undercover
	name = "undercover saddle"
	icon_state = "w_saddle_undercover"

/obj/item/horse_saddle/insignia
	name = "insignia saddle"
	icon_state = "e_saddle_insignia"

/obj/item/horse_saddle/bubblegum
	name = "bubblegum saddle"
	icon_state = "e_saddle_bubblegum"

/obj/item/horse_saddle/seafoam
	name = "seafoam saddle"
	icon_state = "e_saddle_seafoam"

/obj/item/horse_bridle
	name = "horse bridle"
	desc = "A bridle for a horse."
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

/obj/item/horse_bridle/heather
	name = "heather bridle"
	icon_state = "w_bridle_heather"

/obj/item/horse_bridle/lazuli
	name = "lazuli bridle"
	icon_state = "w_bridle_lazuli"

/obj/item/horse_bridle/saguaro
	name = "saguaro bridle"
	icon_state = "w_bridle_saguaro"

/obj/item/horse_bridle/eldorado
	name = "eldorado bridle"
	icon_state = "w_bridle_eldorado"

/obj/item/horse_bridle/undercover
	name = "undercover bridle"
	icon_state = "w_bridle_undercover"

/obj/item/horse_bridle/insignia
	name = "insignia bridle"
	icon_state = "e_bridle_insignia"

/obj/item/horse_bridle/bubblegum
	name = "bubblegum bridle"
	icon_state = "e_bridle_bubblegum"

/obj/item/horse_bridle/seafoam
	name = "seafoam bridle"
	icon_state = "e_bridle_seafoam"

/obj/item/horse_wraps
	name = "horse leg wraps"
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

/obj/item/horse_wraps/heather
	name = "heather leg wraps"
	icon_state = "w_wraps_heather"

/obj/item/horse_wraps/lazuli
	name = "lazuli leg wraps"
	icon_state = "w_wraps_lazuli"

/obj/item/horse_wraps/saguaro
	name = "saguaro leg wraps"
	icon_state = "w_wraps_saguaro"

/obj/item/horse_wraps/eldorado
	name = "eldorado leg wraps"
	icon_state = "w_wraps_eldorado"

/obj/item/horse_wraps/undercover
	name = "undercover leg wraps"
	icon_state = "w_wraps_undercover"

/obj/item/horse_wraps/insignia
	name = "insignia leg wraps"
	icon_state = "e_wraps_insignia"

/obj/item/horse_wraps/bubblegum
	name = "bubblegum leg wraps"
	icon_state = "e_wraps_bubblegum"

/obj/item/horse_wraps/seafoam
	name = "seafoam leg wraps"
	icon_state = "e_wraps_seafoam"
