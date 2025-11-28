#define MAX_HORSE_SLOTS 3
GLOBAL_LIST_EMPTY(horse_holdie_cache)
/datum/stored_horse
	var/horse_name = "Horse"
	var/horse_gender = MALE
	var/breed_type = /datum/horse_breed
	var/body_color = "#8b6f47"
	var/mane_color = "#4a3625"
	var/temperament = 50
	var/intelligence = 20
	var/sspeed = 30
	var/list/supplement_counts
	var/stored_time
	var/stored_by
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
	body_color = horse.horsecolors[1]
	mane_color = horse.horsecolors[2]
	temperament = horse.temperament
	intelligence = horse.intelligence
	sspeed = horse.sspeed
	if(horse.supplement_counts)
		supplement_counts = horse.supplement_counts.Copy()
	stored_by = ckey
	stored_time = world.realtime
	return TRUE
/datum/stored_horse/proc/spawn_horse(turf/spawn_location, mob/living/new_owner)
	if(!spawn_location)
		return null
	var/mob/living/basic/horse/new_horse = new /mob/living/basic/horse(spawn_location)
	new_horse.name = horse_name
	new_horse.gender = horse_gender
	new_horse.breed = get_breed_datum(breed_type)
	new_horse.horsecolors = list(body_color, mane_color)
	new_horse.temperament = temperament
	new_horse.intelligence = intelligence
	new_horse.sspeed = sspeed
	if(supplement_counts)
		new_horse.supplement_counts = supplement_counts.Copy()
	new_horse.apply_colour()
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
		"storedTime" = stored_time
	)
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
			if(slot_data)
				var/datum/stored_horse/stored = new()
				stored.horse_name = slot_data["name"] || "Horse"
				stored.horse_gender = slot_data["gender"] || MALE
				stored.breed_type = text2path(slot_data["breed_type"]) || /datum/horse_breed
				stored.body_color = slot_data["body_color"] || "#8b6f47"
				stored.mane_color = slot_data["mane_color"] || "#4a3625"
				stored.temperament = slot_data["temperament"] || 50
				stored.intelligence = slot_data["intelligence"] || 20
				stored.sspeed = slot_data["speed"] || 30
				stored.supplement_counts = slot_data["supplements"] || list()
				stored.stored_time = slot_data["stored_time"] || 0
				stored.stored_by = ckey
				horse_slots["[i]"] = stored
			else
				horse_slots["[i]"] = null
	else
		for(var/i in 1 to MAX_HORSE_SLOTS)
			horse_slots["[i]"] = null
	GLOB.horse_holdie_cache[ckey] = horse_slots
	return horse_slots
/proc/save_horse_holdie_data(ckey, list/horse_slots)
	if(!ckey)
		return FALSE
	if(!fexists("data/horse_holdie/"))
		fdel("data/horse_holdie/")  // Clear if it's a file somehow
	var/savefile/F = new("data/horse_holdie/[ckey].sav")
	for(var/i in 1 to MAX_HORSE_SLOTS)
		var/datum/stored_horse/stored = horse_slots["[i]"]
		if(stored)
			var/list/slot_data = list(
				"name" = stored.horse_name,
				"gender" = stored.horse_gender,
				"breed_type" = "[stored.breed_type]",
				"body_color" = stored.body_color,
				"mane_color" = stored.mane_color,
				"temperament" = stored.temperament,
				"intelligence" = stored.intelligence,
				"speed" = stored.sspeed,
				"supplements" = stored.supplement_counts,
				"stored_time" = stored.stored_time
			)
			F["slot_[i]"] << slot_data
		else
			F["slot_[i]"] << null
	GLOB.horse_holdie_cache[ckey] = horse_slots
	return TRUE
/obj/structure/horse_holdie
	name = "horse holdie"
	desc = "A strange device that can store horses between shifts. Has 3 storage slots linked to your ID."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/horse_holdie, 32)
/obj/structure/horse_holdie/Initialize(mapload)
	. = ..()
	if(mapload)
		find_and_hang_on_atom()
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
	var/list/nearby_horses = list()
	for(var/mob/living/basic/horse/horse in range(3, src))
		if(horse.stat == DEAD)
			continue
		var/mob/living/owner = horse.my_owner?.resolve()
		if(owner == user)
			nearby_horses += list(list(
				"ref" = REF(horse),
				"name" = horse.name,
				"breed" = horse.breed?.name || "Unknown"
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
			var/slot = text2num(params["slot"])
			var/horse_ref = params["horse_ref"]
			if(slot < 1 || slot > MAX_HORSE_SLOTS)
				to_chat(user, span_warning("Invalid slot!"))
				return TRUE
			if(horse_slots["[slot]"])
				to_chat(user, span_warning("That slot is already occupied! Clear it first."))
				return TRUE
			var/mob/living/basic/horse/horse = locate(horse_ref) in range(3, src)
			if(!horse)
				to_chat(user, span_warning("Horse not found nearby!"))
				return TRUE
			var/mob/living/owner = horse.my_owner?.resolve()
			if(owner != user)
				to_chat(user, span_warning("That's not your horse!"))
				return TRUE
			var/datum/stored_horse/stored = new()
			stored.store_from_horse(horse, user_ckey)
			horse_slots["[slot]"] = stored
			save_horse_holdie_data(user_ckey, horse_slots)
			to_chat(user, span_notice("[horse.name] has been stored in slot [slot]. They will be waiting for you next shift!"))
			visible_message(span_notice("[horse] vanishes into the [src]!"))
			playsound(src, 'sound/effects/magic/smoke.ogg', 50)
			qdel(horse)
			return TRUE
		if("retrieve")
			var/slot = text2num(params["slot"])
			if(slot < 1 || slot > MAX_HORSE_SLOTS)
				to_chat(user, span_warning("Invalid slot!"))
				return TRUE
			var/datum/stored_horse/stored = horse_slots["[slot]"]
			if(!stored)
				to_chat(user, span_warning("No horse in that slot!"))
				return TRUE
			var/turf/spawn_turf = get_turf(src)
			for(var/turf/T in orange(1, src))
				if(!T.density)
					spawn_turf = T
					break
			var/mob/living/basic/horse/new_horse = stored.spawn_horse(spawn_turf, user)
			if(!new_horse)
				to_chat(user, span_warning("Failed to retrieve horse!"))
				return TRUE
			horse_slots["[slot]"] = null
			save_horse_holdie_data(user_ckey, horse_slots)
			to_chat(user, span_notice("[new_horse.name] has been retrieved from storage!"))
			visible_message(span_notice("[new_horse] materializes from the [src]!"))
			playsound(src, 'sound/effects/magic/smoke.ogg', 50)
			return TRUE
		if("clear")
			var/slot = text2num(params["slot"])
			if(slot < 1 || slot > MAX_HORSE_SLOTS)
				to_chat(user, span_warning("Invalid slot!"))
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
/obj/structure/horse_holdie/examine(mob/user)
	. = ..()
	. += span_notice("Click to store or retrieve your horses.")
	. += span_notice("Horses stored here persist between shifts!")
