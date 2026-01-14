// Horse equipment items - saddles, bridles, and wraps

/obj/item/horse_saddle
	name = "horse saddle"
	desc = "A saddle for a horse. Makes riding more comfortable."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "saddle_lazuli"
	inhand_icon_state = "saddle_lazuli"
	lefthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	righthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	w_class = WEIGHT_CLASS_BULKY
	var/on_horse = FALSE

/obj/item/horse_saddle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_saddle/lazuli
	name = "lazuli saddle"
	icon_state = "saddle_lazuli"
	inhand_icon_state = "saddle_lazuli"

/obj/item/horse_saddle/saguaro
	name = "saguaro saddle"
	icon_state = "saddle_saguaro"
	inhand_icon_state = "saddle_saguaro"

/obj/item/horse_saddle/eldorado
	name = "eldorado saddle"
	icon_state = "saddle_eldorado"
	inhand_icon_state = "saddle_eldorado"

/obj/item/horse_bridle
	name = "horse bridle"
	desc = "A bridle for a horse. Helps with control and direction."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "bridle_lazuli"
	inhand_icon_state = "bridle_lazuli"
	lefthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	righthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/on_horse = FALSE

/obj/item/horse_bridle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_bridle/lazuli
	name = "lazuli bridle"
	icon_state = "bridle_lazuli"
	inhand_icon_state = "bridle_lazuli"

/obj/item/horse_bridle/saguaro
	name = "saguaro bridle"
	icon_state = "bridle_saguaro"
	inhand_icon_state = "bridle_saguaro"

/obj/item/horse_bridle/eldorado
	name = "eldorado bridle"
	icon_state = "bridle_eldorado"
	inhand_icon_state = "bridle_eldorado"

/obj/item/horse_wraps
	name = "horse leg wraps"
	desc = "Protective leg wraps for a horse."
	icon = 'modular_horsetest/modules/horse/icons/tack.dmi'
	icon_state = "wraps_lazuli"
	inhand_icon_state = "wraps_lazuli"
	lefthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	righthand_file = 'modular_horsetest/modules/horse/icons/tack.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/on_horse = FALSE

/obj/item/horse_wraps/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/horse))
		return NONE
	var/mob/living/basic/horse/target_horse = interacting_with
	if(target_horse.equip_item(src, user))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/horse_wraps/lazuli
	name = "lazuli leg wraps"
	icon_state = "wraps_lazuli"
	inhand_icon_state = "wraps_lazuli"

/obj/item/horse_wraps/saguaro
	name = "saguaro leg wraps"
	icon_state = "wraps_saguaro"
	inhand_icon_state = "wraps_saguaro"

/obj/item/horse_wraps/eldorado
	name = "eldorado leg wraps"
	icon_state = "wraps_eldorado"
	inhand_icon_state = "wraps_eldorado"
