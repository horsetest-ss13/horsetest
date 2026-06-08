#define MAX_HORSE_SLOTS 6
GLOBAL_LIST_EMPTY(horse_holdie_cache)
GLOBAL_LIST_EMPTY(horse_retired_cache)

/datum/stored_horse
	var/horse_name = "Horse"
	var/horse_gender = MALE
	var/breed_type = /datum/horse_breed
	var/horse_color_variant = "bay"
	var/temperament = 50
	var/intelligence = 20
	var/sspeed = 30
	var/age = 0
	var/was_born = FALSE
	var/saddle_type
	var/bridle_type
	var/wraps_type
	var/list/supplement_counts
	var/stored_time
	var/stored_by
	var/retired_time
	var/last_aged_round

/datum/stored_horse/New()
	supplement_counts = list()
	stored_time = world.realtime

/datum/stored_horse/proc/store_from_horse(mob/living/basic/horse/horse, ckey)
	if(!horse)
		return FALSE
	horse_name = horse.name
	horse_gender = horse.gender
	if(horse.breed)
		breed_type = horse.breed.type
	horse_color_variant = horse.horse_color_variant
	temperament = horse.temperament
	intelligence = horse.intelligence
	sspeed = horse.sspeed
	age = horse.age
	was_born = horse.was_born
	last_aged_round = horse.last_aged_round
	if(horse.equipped_saddle)
		saddle_type = horse.equipped_saddle.type
	if(horse.equipped_bridle)
		bridle_type = horse.equipped_bridle.type
	if(horse.equipped_wraps)
		wraps_type = horse.equipped_wraps.type
	if(horse.supplement_counts)
		supplement_counts = horse.supplement_counts.Copy()
	stored_by = ckey
	stored_time = world.realtime
	return TRUE

/datum/stored_horse/proc/spawn_horse(turf/spawn_location, mob/living/new_owner)
	if(!spawn_location)
		return null
	var/mob/living/basic/horse/new_horse = new /mob/living/basic/horse(spawn_location, src)
	if(saddle_type)
		var/obj/item/horse_saddle/saddle = new saddle_type()
		new_horse.equipped_saddle = saddle
		saddle.on_horse = TRUE
	if(bridle_type)
		var/obj/item/horse_bridle/bridle = new bridle_type()
		new_horse.equipped_bridle = bridle
		bridle.on_horse = TRUE
	if(wraps_type)
		var/obj/item/horse_wraps/wraps = new wraps_type()
		new_horse.equipped_wraps = wraps
		wraps.on_horse = TRUE
	new_horse.update_appearance(UPDATE_OVERLAYS)
	new_horse.tamed_points = 0
	if(new_owner)
		new_horse.my_owner = WEAKREF(new_owner)
	return new_horse

/datum/stored_horse/proc/get_display_data()
	var/datum/horse_breed/breed_datum = get_breed_datum(breed_type)
	return list(
		"name" = horse_name,
		"gender" = horse_gender == MALE ? "Stallion" : "Mare",
		"breed" = breed_datum?.name || "Unknown",
		"temperament" = temperament,
		"intelligence" = intelligence,
		"speed" = sspeed,
		"age" = age,
		"wasBorn" = was_born,
		"retired" = !!retired_time,
		"storedTime" = stored_time,
		"retiredTime" = retired_time
	)

/datum/stored_horse/proc/age_for_round()
	if(GLOB.round_id && last_aged_round == GLOB.round_id)
		return age
	age++
	if(GLOB.round_id)
		last_aged_round = GLOB.round_id
	return age

/datum/stored_horse/proc/is_retirement_age()
	return age >= HORSE_RETIREMENT_AGE

/datum/stored_horse/proc/mark_retired()
	retired_time = world.realtime

/proc/serialize_stored_horse(datum/stored_horse/stored)
	return list(
		"name" = stored.horse_name,
		"gender" = stored.horse_gender,
		"breed_type" = "[stored.breed_type]",
		"color_variant" = stored.horse_color_variant,
		"temperament" = stored.temperament,
		"intelligence" = stored.intelligence,
		"speed" = stored.sspeed,
		"age" = stored.age,
		"was_born" = stored.was_born,
		"last_aged_round" = stored.last_aged_round,
		"saddle_type" = stored.saddle_type ? "[stored.saddle_type]" : null,
		"bridle_type" = stored.bridle_type ? "[stored.bridle_type]" : null,
		"wraps_type" = stored.wraps_type ? "[stored.wraps_type]" : null,
		"supplements" = stored.supplement_counts,
		"stored_time" = stored.stored_time,
		"retired_time" = stored.retired_time
	)

/proc/deserialize_stored_horse(list/slot_data, ckey)
	if(!slot_data)
		return null
	var/datum/stored_horse/stored = new()
	stored.horse_name = slot_data["name"] || "Horse"
	stored.horse_gender = slot_data["gender"] || MALE
	stored.breed_type = text2path(slot_data["breed_type"]) || /datum/horse_breed
	stored.horse_color_variant = slot_data["color_variant"] || "bay"
	stored.temperament = slot_data["temperament"] || 50
	stored.intelligence = slot_data["intelligence"] || 20
	stored.sspeed = slot_data["speed"] || 30
	stored.was_born = slot_data["was_born"] || FALSE
	stored.age = slot_data["age"] || 0
	if(!stored.age && !stored.was_born)
		stored.age = rand(HORSE_WILD_AGE_MIN, HORSE_WILD_AGE_MAX)
	stored.saddle_type = text2path(slot_data["saddle_type"])
	stored.bridle_type = text2path(slot_data["bridle_type"])
	stored.wraps_type = text2path(slot_data["wraps_type"])
	stored.supplement_counts = slot_data["supplements"] || list()
	stored.stored_time = slot_data["stored_time"] || 0
	stored.retired_time = slot_data["retired_time"] || 0
	stored.last_aged_round = slot_data["last_aged_round"]
	stored.stored_by = ckey
	return stored

/proc/save_horse_player_data(ckey)
	if(!ckey)
		return FALSE
	if(!fexists("data/horse_holdie/"))
		fdel("data/horse_holdie/")
	var/savefile/F = new("data/horse_holdie/[ckey].sav")
	var/list/horse_slots = GLOB.horse_holdie_cache[ckey] || list()
	for(var/i in 1 to MAX_HORSE_SLOTS)
		var/datum/stored_horse/stored = horse_slots["[i]"]
		if(stored)
			F["slot_[i]"] << serialize_stored_horse(stored)
		else
			F["slot_[i]"] << null
	var/list/retired_horses = GLOB.horse_retired_cache[ckey] || list()
	var/list/serialized_retired = list()
	for(var/datum/stored_horse/stored in retired_horses)
		if(stored)
			serialized_retired += list(serialize_stored_horse(stored))
	F["retired"] << serialized_retired
	return TRUE

/proc/load_horse_holdie_data(ckey)
	if(!ckey)
		return list()
	if(GLOB.horse_holdie_cache[ckey])
		return GLOB.horse_holdie_cache[ckey]
	var/list/horse_slots = list()
	var/savefile/F
	if(fexists("data/horse_holdie/[ckey].sav"))
		F = new("data/horse_holdie/[ckey].sav")
		for(var/i in 1 to MAX_HORSE_SLOTS)
			var/list/slot_data
			F["slot_[i]"] >> slot_data
			horse_slots["[i]"] = deserialize_stored_horse(slot_data, ckey)
	else
		for(var/i in 1 to MAX_HORSE_SLOTS)
			horse_slots["[i]"] = null
	GLOB.horse_holdie_cache[ckey] = horse_slots
	return horse_slots

/proc/save_horse_holdie_data(ckey, list/horse_slots)
	if(!ckey)
		return FALSE
	GLOB.horse_holdie_cache[ckey] = horse_slots
	return save_horse_player_data(ckey)

/proc/load_retired_horses(ckey)
	if(!ckey)
		return list()
	if(GLOB.horse_retired_cache[ckey])
		return GLOB.horse_retired_cache[ckey]
	var/list/retired_horses = list()
	var/savefile/F
	if(fexists("data/horse_holdie/[ckey].sav"))
		F = new("data/horse_holdie/[ckey].sav")
		var/list/retired_data
		F["retired"] >> retired_data
		if(islist(retired_data))
			for(var/list/horse_data in retired_data)
				var/datum/stored_horse/stored = deserialize_stored_horse(horse_data, ckey)
				if(stored)
					retired_horses += stored
	GLOB.horse_retired_cache[ckey] = retired_horses
	return retired_horses

/proc/save_retired_horses(ckey, list/retired_horses)
	if(!ckey)
		return FALSE
	GLOB.horse_retired_cache[ckey] = retired_horses
	return save_horse_player_data(ckey)

/proc/retire_stored_horse(ckey, datum/stored_horse/stored)
	if(!ckey || !stored)
		return FALSE
	var/list/retired_horses = load_retired_horses(ckey)
	stored.mark_retired()
	retired_horses += stored
	save_retired_horses(ckey, retired_horses)
	return TRUE

/obj/structure/horse_holdie
	name = "horse holdie"
	desc = "A strange device that can store horses between shifts. Has 6 storage slots."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/horse_holdie, 32)

/obj/structure/horse_holdie/Initialize(mapload)
	. = ..()
	if(mapload)
		find_and_mount_on_atom()

/obj/structure/horse_holdie/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/structure/horse_holdie/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/horse_holdie/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HorseHoldie", name)
		ui.open()

/obj/structure/horse_holdie/ui_data(mob/user)
	var/list/data = list()
	var/user_ckey = user.client?.ckey
	if(!user_ckey)
		data["error"] = "No account detected!"
		data["slots"] = list()
		return data
	data["ckey"] = user_ckey
	var/list/horse_slots = load_horse_holdie_data(user_ckey)
	var/list/slots = list()
	for(var/i in 1 to MAX_HORSE_SLOTS)
		var/datum/stored_horse/stored = horse_slots["[i]"]
		if(stored)
			slots += list(list(
				"slot" = i,
				"occupied" = TRUE,
				"horse" = stored.get_display_data()
			))
		else
			slots += list(list(
				"slot" = i,
				"occupied" = FALSE,
				"horse" = null
			))
	data["slots"] = slots
	var/list/retired = list()
	for(var/datum/stored_horse/stored in load_retired_horses(user_ckey))
		retired += stored.get_display_data()
	data["retiredHorses"] = retired
	data["maxRetirementAge"] = HORSE_RETIREMENT_AGE
	var/list/nearby_horses = list()
	for(var/mob/living/basic/horse/horse in range(3, src))
		if(horse.stat == DEAD)
			continue
		var/mob/living/owner = horse.my_owner?.resolve()
		if(owner == user)
			nearby_horses += list(list(
				"ref" = REF(horse),
				"name" = horse.name,
				"breed" = horse.breed?.name || "Unknown",
				"age" = horse.age
			))
	data["nearbyHorses"] = nearby_horses
	return data

/obj/structure/horse_holdie/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/user_ckey = user.client?.ckey
	if(!user_ckey)
		to_chat(user, span_warning("No account detected!"))
		return TRUE
	var/list/horse_slots = load_horse_holdie_data(user_ckey)
	switch(action)
		if("store")
			return ui_act_store(user, user_ckey, horse_slots, params)
		if("retrieve")
			return ui_act_retrieve(user, user_ckey, horse_slots, params)
		if("clear")
			return ui_act_clear(user, user_ckey, horse_slots, params)

/obj/structure/horse_holdie/proc/ui_act_store(mob/living/user, user_ckey, list/horse_slots, list/params)
	var/slot = text2num(params["slot"])
	if(!validate_slot(slot, user))
		return TRUE
	if(horse_slots["[slot]"])
		to_chat(user, span_warning("That slot is already occupied! Clear it first."))
		return TRUE
	var/mob/living/basic/horse/horse = locate(params["horse_ref"]) in range(3, src)
	if(!horse)
		to_chat(user, span_warning("Horse not found nearby!"))
		return TRUE
	var/mob/living/owner = horse.my_owner?.resolve()
	if(owner != user)
		to_chat(user, span_warning("That's not your horse!"))
		return TRUE
	if(horse.age >= HORSE_RETIREMENT_AGE)
		return ui_act_retire_horse(user, user_ckey, horse)
	var/datum/stored_horse/stored = new()
	stored.store_from_horse(horse, user_ckey)
	horse_slots["[slot]"] = stored
	save_horse_holdie_data(user_ckey, horse_slots)
	to_chat(user, span_notice("[horse.name] has been stored in slot [slot]. They will be waiting for you next shift!"))
	visible_message(span_notice("[horse] vanishes into the [src]!"))
	playsound(src, 'sound/effects/magic/smoke.ogg', 50)
	qdel(horse)
	return TRUE

/obj/structure/horse_holdie/proc/ui_act_retire_horse(mob/living/user, user_ckey, mob/living/basic/horse/horse)
	var/datum/stored_horse/stored = new()
	stored.store_from_horse(horse, user_ckey)
	retire_stored_horse(user_ckey, stored)
	to_chat(user, span_notice("[horse.name] has reached age [HORSE_RETIREMENT_AGE] and retired! They've been saved to your retired horses collection."))
	visible_message(span_notice("The [src] glows softly as [horse] retires from service."))
	playsound(src, 'sound/effects/magic/smoke.ogg', 50)
	qdel(horse)
	return TRUE

/obj/structure/horse_holdie/proc/ui_act_retrieve(mob/living/user, user_ckey, list/horse_slots, list/params)
	var/slot = text2num(params["slot"])
	if(!validate_slot(slot, user))
		return TRUE
	var/datum/stored_horse/stored = horse_slots["[slot]"]
	if(!stored)
		to_chat(user, span_warning("No horse in that slot!"))
		return TRUE
	stored.age_for_round()
	if(stored.is_retirement_age())
		horse_slots["[slot]"] = null
		save_horse_holdie_data(user_ckey, horse_slots)
		retire_stored_horse(user_ckey, stored)
		to_chat(user, span_notice("[stored.horse_name] has reached age [HORSE_RETIREMENT_AGE] and retired!"))
		return TRUE
	var/mob/living/basic/horse/new_horse = stored.spawn_horse(get_spawn_turf(), user)
	if(!new_horse)
		to_chat(user, span_warning("Failed to retrieve horse!"))
		return TRUE
	horse_slots["[slot]"] = null
	save_horse_holdie_data(user_ckey, horse_slots)
	to_chat(user, span_notice("[new_horse.name] has been retrieved from storage! They are now [new_horse.age] years old."))
	visible_message(span_notice("[new_horse] materializes from the [src]!"))
	playsound(src, 'sound/effects/magic/smoke.ogg', 50)
	return TRUE

/obj/structure/horse_holdie/proc/ui_act_clear(mob/living/user, user_ckey, list/horse_slots, list/params)
	var/slot = text2num(params["slot"])
	if(!validate_slot(slot, user))
		return TRUE
	var/datum/stored_horse/stored = horse_slots["[slot]"]
	if(!stored)
		to_chat(user, span_warning("No horse in that slot!"))
		return TRUE
	var/confirm = tgui_alert(user, "Are you sure you want to permanently delete [stored.horse_name] from storage?", "Confirm Deletion", list("Yes", "No"))
	if(confirm != "Yes")
		return TRUE
	horse_slots["[slot]"] = null
	save_horse_holdie_data(user_ckey, horse_slots)
	to_chat(user, span_notice("Slot [slot] has been cleared."))
	return TRUE

/obj/structure/horse_holdie/proc/validate_slot(slot, mob/living/user)
	if(slot < 1 || slot > MAX_HORSE_SLOTS)
		to_chat(user, span_warning("Invalid slot!"))
		return FALSE
	return TRUE

/obj/structure/horse_holdie/proc/get_spawn_turf()
	var/turf/spawn_turf = get_turf(src)
	for(var/turf/T in orange(1, src))
		if(!T.density)
			spawn_turf = T
			break
	return spawn_turf

/obj/structure/horse_holdie/examine(mob/user)
	. = ..()
	. += span_notice("Click to store or retrieve your horses.")
	. += span_notice("Horses stored here persist between shifts!")
	. += span_notice("Horses age one year the first time they are retrieved each round. They retire at age [HORSE_RETIREMENT_AGE].")
