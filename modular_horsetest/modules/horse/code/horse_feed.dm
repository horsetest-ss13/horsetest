/obj/item/food/horse_supplement
	name = "horse supplement"
	desc = "A nutritional supplement for horses."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bacon"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("oats" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	var/boost_stat = "speed"
	var/boost_amount = 3
	var/max_boosts = 5
/obj/item/food/horse_supplement/speed_oats
	name = "speed oats"
	desc = "High-energy performance oats. Horses that eat these become faster."
	icon_state = "bacon"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("energizing oats" = 1)
	boost_stat = "speed"
	boost_amount = 3
/obj/item/food/horse_supplement/speed_oats/examine(mob/user)
	. = ..()
	. += span_notice("Boosts a horse's speed when fed to them.")
/obj/item/food/horse_supplement/brain_biscuits
	name = "brain biscuits"
	desc = "Specially formulated treats that stimulate equine cognitive function."
	icon_state = "bacon"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("enriched grain" = 1)
	boost_stat = "intelligence"
	boost_amount = 3
/obj/item/food/horse_supplement/brain_biscuits/examine(mob/user)
	. = ..()
	. += span_notice("Boosts a horse's intelligence when fed to them.")
/obj/item/food/horse_supplement/calming_treats
	name = "calming treats"
	desc = "Soothing treats infused with relaxing herbs. Calms nervous horses."
	icon_state = "bacon"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("lavender" = 1, "chamomile" = 1)
	boost_stat = "temperament"
	boost_amount = 5  // Reduces temperament by this much
/obj/item/food/horse_supplement/calming_treats/examine(mob/user)
	. = ..()
	. += span_notice("Calms a horse's temperament when fed to them.")
/obj/item/food/horse_supplement/speed_oats/premium
	name = "premium speed oats"
	desc = "Championship-grade performance oats. Significantly improves a horse's speed."
	boost_amount = 6
	max_boosts = 3
/obj/item/food/horse_supplement/brain_biscuits/premium
	name = "premium brain biscuits"
	desc = "Advanced cognitive supplements. Significantly improves a horse's intelligence."
	boost_amount = 6
	max_boosts = 3
/obj/item/food/horse_supplement/calming_treats/premium
	name = "premium calming treats"
	desc = "Pharmaceutical-grade calming treats. Significantly calms a horse's temperament."
	boost_amount = 10
	max_boosts = 3
/mob/living/basic/horse
	var/list/supplement_counts
