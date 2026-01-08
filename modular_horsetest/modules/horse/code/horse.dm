/mob/living/basic/horse
	name = "horse"
	desc = "A majestic equine creature. Larger and stronger than a pony."
	icon_state = "pony"
	icon_living = "pony"
	icon_dead = "pony_dead"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("neighs", "whinnies")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	melee_damage_lower = 8
	melee_damage_upper = 15
	health = 80
	maxHealth = 80
	gold_core_spawnable = FRIENDLY_SPAWN
	default_blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/horse
	var/unique_tamer = FALSE
	var/datum/weakref/my_owner
	greyscale_config = /datum/greyscale_config/pony
	var/list/horsecolors = list("#8b6f47", "#4a3625")
	var/sperm = list()
	var/eggs = list()
	var/datum/horse_breed/breed
	var/temperament = 50
	var/max_temperament = 100
	var/intelligence = 20
	var/max_intelligence = 100
	var/sspeed = 30
	var/max_speed = 100
	var/tamed_points = 150
	var/datum/horse_family_tree/family_tree
/datum/emote/horse
	mob_type_allowed_typecache = /mob/living/basic/horse
	mob_type_blacklist_typecache = list()
/datum/emote/horse/whinny
	key = "whinny"
	key_third_person = "whinnies"
	message = "whinnies loudly."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/pony/whinny01.ogg'
/datum/emote/horse/snort
	key = "snort"
	key_third_person = "snorts"
	message = "snorts."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/pony/snort.ogg'
/mob/living/basic/horse/Initialize(mapload)
	. = ..()
	name = pick_horse_name()
	gender = pick(MALE, FEMALE)
	if(!breed)
		var/breed_type = get_random_horse_breed()
		breed = get_breed_datum(breed_type)
	temperament = rand(breed.min_temperament, breed.max_temperament)
	intelligence = rand(breed.min_intelligence, breed.max_intelligence)
	sspeed = rand(breed.min_speed, breed.max_speed)
	horsecolors = breed.breed_colors.Copy()
	apply_colour()
	AddElement(/datum/element/pet_bonus, "whinny")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElementTrait(TRAIT_WADDLING, INNATE_TRAIT, /datum/element/waddling)
	if(!family_tree)
		family_tree = new /datum/horse_family_tree(null, null)
	var/static/list/food_types = list(
		/obj/item/food/grown/apple = 15,
		/obj/item/food/grown/carrot = 15,
		/obj/item/food/grown/sugarcane = 10,
		/obj/item/food/horse_supplement = 20,
	)
	AddElement(/datum/element/basic_eating, food_types = food_types)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pony)
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_ate_food))
	RegisterSignal(src, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle_taming))
	generate_genetics()
/mob/living/basic/horse/proc/on_ate_food(mob/living/eater, atom/food, mob/living/feeder)
	SIGNAL_HANDLER
	handle_taming_food(food, feeder)
	handle_supplement_food(food, feeder)
/mob/living/basic/horse/proc/handle_taming_food(atom/food, mob/living/feeder)
	var/static/list/taming_foods = list(
		/obj/item/food/grown/apple,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/sugarcane,
	)
	if(!is_type_in_list(food, taming_foods))
		return
	if(tamed_points <= 0)
		return // Already tamed
	var/reduction = rand(20, 35)
	tamed_points -= reduction
	var/mob/living/tamer = feeder
	visible_message(span_notice("[src] seems to trust [tamer] a little more!"))
	playsound(src, 'sound/mobs/non-humanoids/pony/snort.ogg', 50)
	if(tamed_points <= 0)
		tamed_points = 0
		complete_taming(tamer)
/mob/living/basic/horse/proc/handle_supplement_food(atom/food, mob/living/feeder)
	if(!istype(food, /obj/item/food/horse_supplement))
		return
	var/obj/item/food/horse_supplement/supplement = food
	if(!supplement_counts)
		supplement_counts = list()
	var/supplement_type = "[supplement.type]"
	var/current_count = supplement_counts[supplement_type] || 0
	if(current_count >= supplement.max_boosts)
		if(feeder)
			to_chat(feeder, span_warning("[src] doesn't seem interested in more [supplement.name]. It won't have any effect."))
		return
	var/stat_changed = FALSE
	var/old_value
	var/new_value
	switch(supplement.boost_stat)
		if("speed")
			old_value = sspeed
			sspeed = clamp(sspeed + supplement.boost_amount, 0, 100)
			new_value = sspeed
			stat_changed = (old_value != new_value)
		if("intelligence")
			old_value = intelligence
			intelligence = clamp(intelligence + supplement.boost_amount, 0, 100)
			new_value = intelligence
			stat_changed = (old_value != new_value)
		if("temperament")
			old_value = temperament
			temperament = clamp(temperament - supplement.boost_amount, 0, 100)
			new_value = temperament
			stat_changed = (old_value != new_value)
	supplement_counts[supplement_type] = current_count + 1
	if(stat_changed)
		visible_message(span_notice("[src] seems to respond well to the [supplement.name]!"))
		playsound(src, 'sound/mobs/non-humanoids/pony/snort.ogg', 50)
		if(feeder)
			var/remaining = supplement.max_boosts - supplement_counts[supplement_type]
			to_chat(feeder, span_notice("[src]'s [supplement.boost_stat] improved! ([remaining] more doses will be effective)"))
	else
		if(feeder)
			to_chat(feeder, span_warning("[src]'s [supplement.boost_stat] is already at its limit."))
/mob/living/basic/horse/proc/on_prebuckle_taming(mob/source, mob/living/buckler, force, buckle_mob_flags)
	SIGNAL_HANDLER
	if(tamed_points <= 0)
		if(unique_tamer && my_owner)
			var/mob/living/tamer = my_owner?.resolve()
			if(buckler != tamer)
				whinny_angrily()
				return COMPONENT_BLOCK_BUCKLE
		return
	if(!ishuman(buckler))
		return COMPONENT_BLOCK_BUCKLE
	balloon_alert(buckler, "starting to tame...")
	INVOKE_ASYNC(src, PROC_REF(start_taming_minigame), buckler)
/mob/living/basic/horse/proc/start_taming_minigame(mob/living/rider)
	if(tamed_points <= 0)
		return // Already tamed during async
	var/datum/riding_minigame/minigame = new(src, rider)
	minigame.required_successes = round(tamed_points / 20) + 5 // Scale with tamed_points
	minigame.maximum_attempts = minigame.required_successes + 15
/mob/living/basic/horse/befriend(mob/living/befriended)
	.=..()
	if(tamed_points <= 0)
		return // Already tamed
	var/reduction = rand(40, 60)
	tamed_points -= reduction
	visible_message(span_notice("[src] seems calmer after the ride!"))
	playsound(src, 'sound/mobs/non-humanoids/pony/snort.ogg', 50)
	if(tamed_points <= 0)
		tamed_points = 0
		complete_taming(befriended)
	else
		balloon_alert(befriended, "[tamed_points] taming points left")
/mob/living/basic/horse/proc/complete_taming(mob/living/tamer)
	tamed_points = 0
	visible_message(span_boldnotice("[src] is now fully tamed!"))
	balloon_alert(tamer, "tamed!")
	new /obj/effect/temp_visual/heart(loc)
	playsound(src, 'sound/mobs/non-humanoids/pony/whinny01.ogg', 60)
	ai_controller.replace_planning_subtrees(list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/pony/tamed,
	))
	my_owner = WEAKREF(tamer)
	to_chat(tamer, span_notice("[src] now recognizes you as [p_their()] owner!"))
/mob/living/basic/horse/Destroy()
	UnregisterSignal(src, list(COMSIG_MOVABLE_PREBUCKLE, COMSIG_MOB_ATE))
	my_owner = null
	sperm = null
	eggs = null
	return ..()
/mob/living/basic/horse/proc/is_related_to(mob/living/basic/horse/other)
	if(!istype(other))
		return FALSE
	if(!family_tree || !other.family_tree)
		return FALSE // No family data, allow breeding
	if(family_tree.is_ancestor(other))
		return TRUE
	if(other.family_tree.is_ancestor(src))
		return TRUE
	if(family_tree.shares_ancestry_with(other.family_tree, max_depth = 3))
		return TRUE
	return FALSE
/mob/living/basic/horse/proc/mate_with(mob/living/basic/horse/partner)
	if(!istype(partner))
		return FALSE
	if(is_related_to(partner))
		visible_message(span_warning("[src] and [partner] are too closely related to breed!"))
		return FALSE
	var/mob/living/basic/horse/male_parent
	var/mob/living/basic/horse/female_parent
	if(gender == MALE && partner.gender == FEMALE)
		male_parent = src
		female_parent = partner
	else if(gender == FEMALE && partner.gender == MALE)
		male_parent = partner
		female_parent = src
	else
		return FALSE // Need opposite genders
	if(length(female_parent.eggs) > 0)
		visible_message(span_notice("[female_parent] is already expecting!"))
		return FALSE
	if(length(male_parent.sperm) > 0)
		var/datum/horse_genetics/sperm_data = pick(male_parent.sperm)
		var/datum/horse_genetics/egg_data = new /datum/horse_genetics(female_parent)
		female_parent.eggs += list(list(
			"sperm" = sperm_data,
			"egg" = egg_data,
			"time" = world.time,
			"father" = male_parent,
			"mother" = female_parent
		))
		visible_message(span_notice("[female_parent] and [male_parent] begin to mate!"))
		playsound(src, 'sound/mobs/non-humanoids/pony/snort.ogg', 50)
		addtimer(CALLBACK(female_parent, PROC_REF(give_birth)), 10 SECONDS)
		return TRUE
	return FALSE
/mob/living/basic/horse/proc/give_birth()
	if(length(eggs) == 0)
		return
	var/list/fertilized_egg = eggs[1]
	var/datum/horse_genetics/sperm_data = fertilized_egg["sperm"]
	var/datum/horse_genetics/egg_data = fertilized_egg["egg"]
	var/mob/living/basic/horse/foal = new /mob/living/basic/horse/foal(loc)
	var/mob/living/basic/horse/father_horse = fertilized_egg["father"]
	var/mob/living/basic/horse/mother_horse = fertilized_egg["mother"]
	if(father_horse?.breed && mother_horse?.breed)
		var/parent_breed_type = pick(father_horse.breed.type, mother_horse.breed.type)
		foal.breed = get_breed_datum(parent_breed_type)
	else if(father_horse?.breed)
		foal.breed = get_breed_datum(father_horse.breed.type)
	else if(mother_horse?.breed)
		foal.breed = get_breed_datum(mother_horse.breed.type)
	else
		foal.breed = get_breed_datum(get_random_horse_breed())
	foal.temperament = round((sperm_data.temperament + egg_data.temperament) / 2 + rand(-5, 5))
	foal.temperament = clamp(foal.temperament, 0, foal.max_temperament)
	foal.intelligence = round((sperm_data.intelligence + egg_data.intelligence) / 2 + rand(-3, 3))
	foal.intelligence = clamp(foal.intelligence, 0, foal.max_intelligence)
	foal.sspeed = round((sperm_data.sspeed + egg_data.sspeed) / 2 + rand(-5, 5))
	foal.sspeed = clamp(foal.sspeed, 0, foal.max_speed)
	var/list/possible_colors = sperm_data.colors + egg_data.colors
	foal.horsecolors = list(pick(possible_colors), pick(possible_colors))
	foal.apply_colour()
	foal.gender = pick(MALE, FEMALE)
	foal.family_tree = new /datum/horse_family_tree(father_horse, mother_horse)
	if(father_horse?.family_tree)
		father_horse.family_tree.add_child(foal)
	if(mother_horse?.family_tree)
		mother_horse.family_tree.add_child(foal)
	foal.generate_genetics()
	visible_message(span_boldnotice("[src] gives birth to a foal!"))
	playsound(src, 'sound/mobs/non-humanoids/pony/whinny01.ogg', 60)
	eggs = list()
	SStgui.update_uis(src)
/mob/living/basic/horse/proc/generate_genetics()
	var/datum/horse_genetics/genetics = new /datum/horse_genetics(src)
	if(gender == MALE)
		sperm = list()
		for(var/i in 1 to 5)
			var/datum/horse_genetics/sperm_copy = genetics.copy()
			sperm_copy.mutate() // Small chance of mutation
			sperm += sperm_copy
	else
		eggs = list()
/mob/living/basic/horse/proc/can_mate()
	if(stat != CONSCIOUS)
		return FALSE
	if(gender == FEMALE && length(eggs) > 0)
		return FALSE // Already pregnant
	if(gender == MALE && length(sperm) == 0)
		generate_genetics() // Generate sperm if needed
	return TRUE
/mob/living/basic/horse/examine(mob/user)
	. = ..()
	. += span_info("This [gender == MALE ? "stallion" : "mare"] appears to be [temperament < 30 ? "very calm" : temperament < 60 ? "moderately tempered" : "quite spirited"].")
	. += span_info("It seems [intelligence < 30 ? "simple-minded" : intelligence < 60 ? "moderately intelligent" : "quite clever"].")
	. += span_info("Its build suggests it would be [sspeed < 30 ? "slow but steady" : sspeed < 60 ? "moderately fast" : "very swift"].")
	if(gender == FEMALE && length(eggs) > 0)
		. += span_boldnotice("[src] appears to be pregnant!")
	if(tamed_points != null)
		if(tamed_points <= 0)
			. += span_notice("[src] is fully tamed.")
		else
			. += span_info("[src] still needs to be tamed. ([tamed_points] points remaining)")
/mob/living/basic/horse/Topic(href, href_list)
	. = ..()
	if(href_list["mate"])
		var/mob/living/basic/horse/partner = locate(href_list["mate"])
		if(partner && can_mate() && partner.can_mate())
			if(get_dist(src, partner) <= 1)
				mate_with(partner)
			else
				to_chat(usr, span_warning("The horses need to be next to each other!"))
/mob/living/basic/horse/click_alt(mob/user)
	if(!ishuman(user))
		return CLICK_ACTION_BLOCKING
	if(!user.can_perform_action(src, ALLOW_RESTING))
		return CLICK_ACTION_BLOCKING
	if(get_dist(src, user) > 1)
		to_chat(user, span_warning("You need to be closer to [src]!"))
		return CLICK_ACTION_BLOCKING
	if(tamed_points == null || tamed_points > 0)
		to_chat(user, span_warning("[src] is not tamed yet! Try feeding it apples, carrots, or sugarcane."))
		return CLICK_ACTION_BLOCKING
	open_horse_menu(user)
	return CLICK_ACTION_SUCCESS
/mob/living/basic/horse/proc/open_horse_menu(mob/user)
	if(my_owner)
		var/mob/living/owner = my_owner.resolve()
		if(owner && owner != user)
			var/owner_display = owner.ckey || owner.real_name || owner.name
			to_chat(user, span_warning("[src] only responds to [owner_display]'s commands!"))
			return
	ui_interact(user)
/mob/living/basic/horse/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HorseMenu")
		ui.open()
/mob/living/basic/horse/ui_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["gender"] = gender == MALE ? "Stallion" : "Mare"
	data["health"] = health
	data["maxHealth"] = maxHealth
	data["temperament"] = temperament
	data["maxTemperament"] = max_temperament
	data["intelligence"] = intelligence
	data["maxIntelligence"] = max_intelligence
	data["speed"] = sspeed
	data["maxSpeed"] = max_speed
	data["pregnant"] = gender == FEMALE && length(eggs) > 0
	data["canBreed"] = can_mate()
	if(breed)
		data["breed"] = list(
			"name" = breed.name,
			"description" = breed.description,
			"rarity" = breed.rarity,
			"idealTemperament" = breed.ideal_temperament,
			"idealIntelligence" = breed.ideal_intelligence,
			"idealSpeed" = breed.ideal_speed
		)
	var/mob/living/owner = my_owner?.resolve()
	data["owner"] = owner ? (owner.real_name || owner.name) : null
	data["isOwner"] = owner == user
	if(family_tree)
		data["familyTree"] = family_tree.get_family_data(depth = 0, max_depth = 10)
	else
		data["familyTree"] = null
	return data
/mob/living/basic/horse/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("breed")
			attempt_mate_command(usr)
			return TRUE
/mob/living/basic/horse/ui_static_data(mob/user)
	var/list/data = list()
	data["horseType"] = initial(name)
	return data
/mob/living/basic/horse/ui_status(mob/user, datum/ui_state/state)
	if(get_dist(src, user) > 1)
		return UI_CLOSE
	return ..()
/mob/living/basic/horse/proc/attempt_mate_command(mob/user)
	if(!can_mate())
		to_chat(user, span_warning("[src] is not ready to mate right now."))
		return
	var/list/potential_mates = list()
	for(var/mob/living/basic/horse/H in view(1, src))
		if(H != src && H.can_mate())
			if((src.gender == MALE && H.gender == FEMALE) || (src.gender == FEMALE && H.gender == MALE))
				potential_mates += H
	if(length(potential_mates) == 0)
		to_chat(user, span_warning("There are no suitable mates nearby!"))
		return
	var/mob/living/basic/horse/chosen_mate = input(user, "Choose a mate for [src]:", "Horse Breeding") as null|anything in potential_mates
	if(chosen_mate)
		mate_with(chosen_mate)
/mob/living/basic/horse/proc/apply_colour()
	if(!greyscale_config)
		return
	set_greyscale(colors = horsecolors)
/mob/living/basic/horse/proc/whinny_angrily()
	manual_emote("whinnies ANGRILY!")
	playsound(src, pick(list(
		'sound/mobs/non-humanoids/pony/whinny01.ogg',
		'sound/mobs/non-humanoids/pony/whinny02.ogg',
		'sound/mobs/non-humanoids/pony/whinny03.ogg'
	)), 60)
/mob/living/basic/horse/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if (prob(33))
		whinny_angrily()
/mob/living/basic/horse/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if (!.)
		return
	whinny_angrily()
/datum/ai_controller/basic_controller/horse
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/pony,
	)
/mob/living/basic/horse/proc/pick_horse_name()
	var/static/list/horse_names
	if(!horse_names)
		horse_names = world.file2list("strings/horse_names.txt")
	return pick(horse_names)
/datum/horse_genetics
	var/temperament
	var/intelligence
	var/sspeed
	var/list/colors = list()
/datum/horse_genetics/New(mob/living/basic/horse/parent)
	if(parent)
		temperament = parent.temperament
		intelligence = parent.intelligence
		sspeed = parent.sspeed
		colors = parent.horsecolors.Copy()
/datum/horse_genetics/proc/copy()
	var/datum/horse_genetics/new_genetics = new()
	new_genetics.temperament = temperament
	new_genetics.intelligence = intelligence
	new_genetics.sspeed = sspeed
	new_genetics.colors = colors.Copy()
	return new_genetics
/datum/horse_genetics/proc/mutate()
	if(prob(10))
		temperament += rand(-3, 3)
	if(prob(10))
		intelligence += rand(-2, 2)
	if(prob(10))
		sspeed += rand(-3, 3)
/datum/horse_family_tree
	var/datum/weakref/father
	var/datum/weakref/mother
	var/datum/horse_family_tree/father_tree
	var/datum/horse_family_tree/mother_tree
	var/list/datum/weakref/children = list()
	var/birth_time
	var/cached_name
/datum/horse_family_tree/New(mob/living/basic/horse/father_horse, mob/living/basic/horse/mother_horse)
	if(father_horse)
		father = WEAKREF(father_horse)
		if(father_horse.family_tree)
			father_tree = father_horse.family_tree
	if(mother_horse)
		mother = WEAKREF(mother_horse)
		if(mother_horse.family_tree)
			mother_tree = mother_horse.family_tree
	birth_time = world.time
/datum/horse_family_tree/proc/get_father()
	return father?.resolve()
/datum/horse_family_tree/proc/get_mother()
	return mother?.resolve()
/datum/horse_family_tree/proc/add_child(mob/living/basic/horse/child_horse)
	if(!child_horse)
		return
	children += WEAKREF(child_horse)
/datum/horse_family_tree/proc/get_children()
	var/list/living_children = list()
	for(var/datum/weakref/child_ref in children)
		var/mob/living/basic/horse/child = child_ref.resolve()
		if(child)
			living_children += child
	return living_children
/datum/horse_family_tree/proc/is_ancestor(mob/living/basic/horse/check_horse)
	if(!check_horse)
		return FALSE
	var/mob/living/basic/horse/dad = get_father()
	if(dad == check_horse)
		return TRUE
	var/mob/living/basic/horse/mom = get_mother()
	if(mom == check_horse)
		return TRUE
	if(father_tree?.is_ancestor(check_horse))
		return TRUE
	if(mother_tree?.is_ancestor(check_horse))
		return TRUE
	return FALSE
/datum/horse_family_tree/proc/shares_ancestry_with(datum/horse_family_tree/other_tree, max_depth = 3)
	if(!other_tree)
		return FALSE
	return check_common_ancestor(src, other_tree, 0, max_depth)
/datum/horse_family_tree/proc/check_common_ancestor(datum/horse_family_tree/tree1, datum/horse_family_tree/tree2, depth, max_depth)
	if(!tree1 || !tree2 || depth > max_depth)
		return FALSE
	var/mob/living/basic/horse/dad1 = tree1.get_father()
	var/mob/living/basic/horse/dad2 = tree2.get_father()
	if(dad1 && dad2 && dad1 == dad2)
		return TRUE
	var/mob/living/basic/horse/mom1 = tree1.get_mother()
	var/mob/living/basic/horse/mom2 = tree2.get_mother()
	if(mom1 && mom2 && mom1 == mom2)
		return TRUE
	if(tree1.father_tree && check_common_ancestor(tree1.father_tree, tree2, depth + 1, max_depth))
		return TRUE
	if(tree1.mother_tree && check_common_ancestor(tree1.mother_tree, tree2, depth + 1, max_depth))
		return TRUE
	if(tree2.father_tree && check_common_ancestor(tree1, tree2.father_tree, depth + 1, max_depth))
		return TRUE
	if(tree2.mother_tree && check_common_ancestor(tree1, tree2.mother_tree, depth + 1, max_depth))
		return TRUE
	return FALSE
/datum/horse_family_tree/proc/get_family_data(depth = 0, max_depth = 10)
	if(depth > max_depth)
		return null
	var/list/data = list()
	var/mob/living/basic/horse/dad = get_father()
	var/mob/living/basic/horse/mom = get_mother()
	data["fatherName"] = dad?.name || cached_name || "Unknown"
	data["motherName"] = mom?.name || cached_name || "Unknown"
	data["fatherAlive"] = dad ? TRUE : FALSE
	data["motherAlive"] = mom ? TRUE : FALSE
	data["depth"] = depth
	if(dad)
		data["fatherStats"] = list(
			"temperament" = dad.temperament,
			"intelligence" = dad.intelligence,
			"speed" = dad.sspeed
		)
	if(mom)
		data["motherStats"] = list(
			"temperament" = mom.temperament,
			"intelligence" = mom.intelligence,
			"speed" = mom.sspeed
		)
	var/list/children_data = list()
	for(var/datum/weakref/child_ref in children)
		var/mob/living/basic/horse/child = child_ref.resolve()
		if(child)
			children_data += list(list(
				"name" = child.name,
				"alive" = TRUE,
				"gender" = child.gender == MALE ? "male" : "female",
				"stats" = list(
					"temperament" = child.temperament,
					"intelligence" = child.intelligence,
					"speed" = child.sspeed
				)
			))
	data["children"] = children_data
	if(father_tree)
		data["fatherTree"] = father_tree.get_family_data(depth + 1, max_depth)
	if(mother_tree)
		data["motherTree"] = mother_tree.get_family_data(depth + 1, max_depth)
	return data
/mob/living/basic/horse/foal
	name = "foal"
	desc = "A young horse. Still growing and learning."
	health = 40
	maxHealth = 40
	melee_damage_lower = 3
	melee_damage_upper = 6
	tamed_points = 100 // Easier to tame when young
/mob/living/basic/horse/foal/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(grow_up)), 10 MINUTES)
/mob/living/basic/horse/foal/proc/grow_up()
	visible_message(span_notice("[src] has grown into an adult horse!"))
	var/mob/living/basic/horse/adult = new /mob/living/basic/horse(loc)
	adult.breed = breed
	adult.temperament = temperament
	adult.intelligence = intelligence
	adult.sspeed = sspeed
	adult.horsecolors = horsecolors.Copy()
	adult.gender = gender
	adult.tamed_points = tamed_points
	adult.my_owner = my_owner
	adult.name = name // Preserve the foal's name
	adult.family_tree = family_tree
	if(my_owner)
		adult.unique_tamer = unique_tamer
	adult.apply_colour()
	adult.generate_genetics()
	adult.forceMove(loc)
	qdel(src)
