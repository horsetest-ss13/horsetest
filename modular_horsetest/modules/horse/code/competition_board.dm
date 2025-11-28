GLOBAL_LIST_EMPTY(horse_competitions)
GLOBAL_LIST_EMPTY(horse_competition_history)
#define COMPETITION_RACE "race"
#define COMPETITION_SHOW "show"
#define COMPETITION_TRIAL "trial"
#define COMP_STATE_REGISTRATION "registration"
#define COMP_STATE_IN_PROGRESS "in_progress"
#define COMP_STATE_FINISHED "finished"
/datum/horse_competition
	var/id
	var/name = "Horse Competition"
	var/competition_type = COMPETITION_RACE
	var/state = COMP_STATE_REGISTRATION
	var/entry_fee = 100
	var/prize_pool = 0
	var/max_entrants = 8
	var/min_entrants = 2
	var/list/entrants = list()
	var/list/results = list()
	var/registration_start
	var/registration_duration = 3 MINUTES
	var/description = "A competition for horses."
	var/obj/structure/horse_competition_board/host_board
/datum/horse_competition/New(comp_type, comp_name, obj/structure/horse_competition_board/board)
	. = ..()
	id = "[rand(1000, 9999)]-[world.time]"
	competition_type = comp_type
	host_board = board
	registration_start = world.time
	prize_pool = 0
	switch(competition_type)
		if(COMPETITION_RACE)
			name = comp_name || "Speed Derby"
			description = "A thrilling race! Horses compete based on their speed. Faster horses have a better chance of winning."
			entry_fee = 150
		if(COMPETITION_SHOW)
			name = comp_name || "Beauty Pageant"
			description = "A show of elegance! Horses are judged on their temperament. Calmer horses score higher."
			entry_fee = 100
		if(COMPETITION_TRIAL)
			name = comp_name || "Intelligence Trial"
			description = "A test of wit! Horses compete in puzzles and challenges. Smarter horses excel."
			entry_fee = 125
	GLOB.horse_competitions += src
	addtimer(CALLBACK(src, PROC_REF(start_competition)), registration_duration)
/datum/horse_competition/Destroy()
	GLOB.horse_competitions -= src
	host_board = null
	entrants = null
	results = null
	return ..()
/datum/horse_competition/proc/is_registration_open()
	return state == COMP_STATE_REGISTRATION
/datum/horse_competition/proc/get_registration_time_remaining()
	if(state != COMP_STATE_REGISTRATION)
		return 0
	var/elapsed = world.time - registration_start
	return max(0, registration_duration - elapsed)
/datum/horse_competition/proc/enter_horse(mob/living/basic/horse/horse, mob/living/owner)
	if(state != COMP_STATE_REGISTRATION)
		return list("success" = FALSE, "message" = "Registration is closed!")
	if(length(entrants) >= max_entrants)
		return list("success" = FALSE, "message" = "Competition is full!")
	for(var/datum/weakref/ref in entrants)
		var/mob/living/basic/horse/entered = ref.resolve()
		if(entered == horse)
			return list("success" = FALSE, "message" = "[horse.name] is already entered!")
	var/mob/living/horse_owner = horse.my_owner?.resolve()
	if(horse_owner != owner)
		return list("success" = FALSE, "message" = "You don't own [horse.name]!")
	var/datum/bank_account/account = owner.get_bank_account()
	if(!account)
		return list("success" = FALSE, "message" = "You need a bank account to enter!")
	if(account.account_balance < entry_fee)
		return list("success" = FALSE, "message" = "Insufficient funds! Entry fee is [entry_fee] credits.")
	if(!account.adjust_money(-entry_fee, "Horse Competition: [name]"))
		return list("success" = FALSE, "message" = "Transaction failed!")
	prize_pool += entry_fee
	entrants += WEAKREF(horse)
	return list("success" = TRUE, "message" = "[horse.name] has been entered into [name]! [entry_fee] credits deducted.")
/datum/horse_competition/proc/withdraw_horse(mob/living/basic/horse/horse, mob/living/owner)
	if(state != COMP_STATE_REGISTRATION)
		return list("success" = FALSE, "message" = "Cannot withdraw after registration closes!")
	for(var/datum/weakref/ref in entrants)
		var/mob/living/basic/horse/entered = ref.resolve()
		if(entered == horse)
			var/mob/living/horse_owner = horse.my_owner?.resolve()
			if(horse_owner != owner)
				return list("success" = FALSE, "message" = "You don't own [horse.name]!")
			entrants -= ref
			var/refund = round(entry_fee / 2)
			prize_pool -= refund
			var/datum/bank_account/account = owner.get_bank_account()
			if(account)
				account.adjust_money(refund, "Horse Competition Refund: [name]")
			return list("success" = TRUE, "message" = "[horse.name] has been withdrawn. [refund] credits refunded.")
	return list("success" = FALSE, "message" = "[horse.name] is not in this competition!")
/datum/horse_competition/proc/start_competition()
	if(state != COMP_STATE_REGISTRATION)
		return
	if(length(entrants) < min_entrants)
		state = COMP_STATE_FINISHED
		for(var/datum/weakref/ref in entrants)
			var/mob/living/basic/horse/horse = ref.resolve()
			if(!horse)
				continue
			var/mob/living/horse_owner = horse.my_owner?.resolve()
			if(horse_owner)
				var/datum/bank_account/account = horse_owner.get_bank_account()
				if(account)
					account.adjust_money(entry_fee, "Horse Competition Cancelled: [name]")
		results = list(list("place" = 0, "name" = "CANCELLED", "owner" = "", "score" = 0, "prize" = 0, "message" = "Not enough entrants! Entry fees refunded."))
		GLOB.horse_competition_history += src
		GLOB.horse_competitions -= src
		return
	state = COMP_STATE_IN_PROGRESS
	addtimer(CALLBACK(src, PROC_REF(run_competition)), 3 SECONDS)
/datum/horse_competition/proc/run_competition()
	var/list/scores = list()
	for(var/datum/weakref/ref in entrants)
		var/mob/living/basic/horse/horse = ref.resolve()
		if(!horse || horse.stat == DEAD)
			continue
		var/mob/living/horse_owner = horse.my_owner?.resolve()
		var/score = calculate_score(horse)
		scores += list(list(
			"horse" = horse,
			"ref" = ref,
			"name" = horse.name,
			"owner" = horse_owner?.real_name || "Unknown",
			"owner_mob" = horse_owner,
			"score" = score
		))
	scores = sortTim(scores, GLOBAL_PROC_REF(cmp_horse_score_desc))
	results = list()
	var/place = 1
	for(var/list/entry in scores)
		var/prize = 0
		switch(place)
			if(1)
				prize = round(prize_pool * 0.5)
			if(2)
				prize = round(prize_pool * 0.3)
			if(3)
				prize = round(prize_pool * 0.2)
		if(prize > 0)
			var/mob/living/winner = entry["owner_mob"]
			if(winner)
				var/datum/bank_account/account = winner.get_bank_account()
				if(account)
					account.adjust_money(prize, "Horse Competition Prize: [name]")
		results += list(list(
			"place" = place,
			"name" = entry["name"],
			"owner" = entry["owner"],
			"score" = entry["score"],
			"prize" = prize
		))
		place++
	state = COMP_STATE_FINISHED
	if(host_board)
		host_board.announce_results(src)
	move_to_history()
/datum/horse_competition/proc/calculate_score(mob/living/basic/horse/horse)
	var/base_score = 0
	var/luck_factor = rand(-10, 10)
	switch(competition_type)
		if(COMPETITION_RACE)
			base_score = horse.sspeed * 2 + horse.intelligence * 0.5
		if(COMPETITION_SHOW)
			base_score = (100 - horse.temperament) * 2 + horse.intelligence * 0.5
		if(COMPETITION_TRIAL)
			base_score = horse.intelligence * 2 + (100 - horse.temperament) * 0.5
	return round(base_score + luck_factor)
/datum/horse_competition/proc/move_to_history()
	GLOB.horse_competitions -= src
	GLOB.horse_competition_history += src
	while(length(GLOB.horse_competition_history) > 10)
		var/datum/horse_competition/old = GLOB.horse_competition_history[1]
		GLOB.horse_competition_history -= old
		qdel(old)
/datum/horse_competition/proc/get_data()
	var/list/data = list()
	data["id"] = id
	data["name"] = name
	data["type"] = competition_type
	data["state"] = state
	data["description"] = description
	data["entryFee"] = entry_fee
	data["prizePool"] = prize_pool
	data["maxEntrants"] = max_entrants
	data["minEntrants"] = min_entrants
	data["currentEntrants"] = length(entrants)
	data["timeRemaining"] = get_registration_time_remaining()
	var/list/entrant_names = list()
	for(var/datum/weakref/ref in entrants)
		var/mob/living/basic/horse/horse = ref.resolve()
		if(horse)
			var/mob/living/horse_owner = horse.my_owner?.resolve()
			entrant_names += list(list(
				"name" = horse.name,
				"owner" = horse_owner?.real_name || "Unknown",
				"breed" = horse.breed?.name || "Unknown"
			))
	data["entrants"] = entrant_names
	data["results"] = results
	return data
/proc/cmp_horse_score_desc(list/a, list/b)
	return b["score"] - a["score"]
/obj/structure/horse_competition_board
	name = "horse competition board"
	desc = "A board displaying information about upcoming horse competitions. Alt-click to open."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	var/competition_spawn_timer
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/horse_competition_board, 32)
/obj/structure/horse_competition_board/Initialize(mapload)
	. = ..()
	if(mapload)
		find_and_hang_on_atom()
	spawn_competition()
/obj/structure/horse_competition_board/Destroy()
	if(competition_spawn_timer)
		deltimer(competition_spawn_timer)
	return ..()
/obj/structure/horse_competition_board/proc/spawn_competition()
	var/active_count = 0
	for(var/datum/horse_competition/comp in GLOB.horse_competitions)
		if(comp.host_board == src && comp.state == COMP_STATE_REGISTRATION)
			active_count++
	if(active_count < 3)
		var/comp_type = pick(COMPETITION_RACE, COMPETITION_SHOW, COMPETITION_TRIAL)
		new /datum/horse_competition(comp_type, null, src)
	competition_spawn_timer = addtimer(CALLBACK(src, PROC_REF(spawn_competition)), rand(2 MINUTES, 4 MINUTES), TIMER_STOPPABLE)
/obj/structure/horse_competition_board/proc/announce_results(datum/horse_competition/comp)
	if(!comp || !length(comp.results))
		return
	var/list/first = comp.results[1]
	if(first["place"] == 0)
		say("[comp.name] has been cancelled due to insufficient entrants!")
	else
		say("The [comp.name] has concluded! Winner: [first["name"]] owned by [first["owner"]] with a score of [first["score"]]!")
/obj/structure/horse_competition_board/ui_state(mob/user)
	return GLOB.physical_state
/obj/structure/horse_competition_board/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HorseCompetitionBoard", name)
		ui.open()
		ui.set_autoupdate(TRUE)
/obj/structure/horse_competition_board/ui_data(mob/user)
	var/list/data = list()
	var/list/active = list()
	for(var/datum/horse_competition/comp in GLOB.horse_competitions)
		active += list(comp.get_data())
	data["activeCompetitions"] = active
	var/list/history = list()
	for(var/datum/horse_competition/comp in GLOB.horse_competition_history)
		history += list(comp.get_data())
	data["competitionHistory"] = history
	var/list/user_horses = list()
	for(var/mob/living/basic/horse/horse in GLOB.mob_living_list)
		if(horse.stat == DEAD)
			continue
		var/mob/living/horse_owner = horse.my_owner?.resolve()
		if(horse_owner == user)
			user_horses += list(list(
				"ref" = REF(horse),
				"name" = horse.name,
				"breed" = horse.breed?.name || "Unknown",
				"speed" = horse.sspeed,
				"intelligence" = horse.intelligence,
				"temperament" = horse.temperament
			))
	data["userHorses"] = user_horses
	return data
/obj/structure/horse_competition_board/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!istype(user))
		return
	switch(action)
		if("enter_competition")
			var/comp_id = params["competition_id"]
			var/horse_ref = params["horse_ref"]
			var/datum/horse_competition/target_comp
			for(var/datum/horse_competition/comp in GLOB.horse_competitions)
				if(comp.id == comp_id)
					target_comp = comp
					break
			if(!target_comp)
				to_chat(user, span_warning("Competition not found!"))
				return TRUE
			var/mob/living/basic/horse/horse = locate(horse_ref) in GLOB.mob_living_list
			if(!horse)
				to_chat(user, span_warning("Horse not found!"))
				return TRUE
			var/list/result = target_comp.enter_horse(horse, user)
			if(result["success"])
				to_chat(user, span_notice(result["message"]))
			else
				to_chat(user, span_warning(result["message"]))
			return TRUE
		if("withdraw_competition")
			var/comp_id = params["competition_id"]
			var/horse_ref = params["horse_ref"]
			var/datum/horse_competition/target_comp
			for(var/datum/horse_competition/comp in GLOB.horse_competitions)
				if(comp.id == comp_id)
					target_comp = comp
					break
			if(!target_comp)
				to_chat(user, span_warning("Competition not found!"))
				return TRUE
			var/mob/living/basic/horse/horse = locate(horse_ref) in GLOB.mob_living_list
			if(!horse)
				to_chat(user, span_warning("Horse not found!"))
				return TRUE
			var/list/result = target_comp.withdraw_horse(horse, user)
			if(result["success"])
				to_chat(user, span_notice(result["message"]))
			else
				to_chat(user, span_warning(result["message"]))
			return TRUE
/obj/structure/horse_competition_board/click_alt(mob/user)
	if(!user.can_perform_action(src, ALLOW_RESTING))
		return CLICK_ACTION_BLOCKING
	ui_interact(user)
	return CLICK_ACTION_SUCCESS
