#define DUNGEON_STATE_IDLE "idle"
#define DUNGEON_STATE_GENERATING "generating"
#define DUNGEON_STATE_ACTIVE "active"
#define DUNGEON_STATE_COMPLETED "completed"
#define DUNGEON_STATE_FAILED "failed"

GLOBAL_LIST_EMPTY(active_dungeons)

/datum/dungeon_instance
	var/id
	var/name = "Unknown Dungeon"
	var/state = DUNGEON_STATE_IDLE
	var/difficulty = 1
	var/width = 30
	var/height = 30
	var/max_players = -1 // -1 = infinite players allowed
	var/datum/room_dungeon_generator/generator
	var/datum/turf_reservation/reservation
	var/turf/entrance_turf
	var/turf/exit_turf
	var/list/spawned_mobs = list()
	var/list/spawned_objects = list()
	var/list/players_inside = list()
	var/datum/weakref/owner_ref
	var/start_time
	var/completion_time
	var/rewards_claimed = FALSE
	var/area/dungeon/dungeon_area

/datum/dungeon_instance/New(dungeon_name = "Dungeon", dungeon_difficulty = 1, dungeon_width = 30, dungeon_height = 30)
	id = "[rand(1000, 9999)]-[world.time]"
	name = dungeon_name
	difficulty = dungeon_difficulty
	width = dungeon_width
	height = dungeon_height
	GLOB.active_dungeons += src

/datum/dungeon_instance/Destroy()
	GLOB.active_dungeons -= src
	cleanup()
	return ..()

/datum/dungeon_instance/proc/cleanup()
	for(var/mob/living/M in spawned_mobs)
		if(!QDELETED(M))
			qdel(M)
	spawned_mobs.Cut()
	for(var/obj/O in spawned_objects)
		if(!QDELETED(O))
			qdel(O)
	spawned_objects.Cut()
	if(reservation)
		qdel(reservation)
		reservation = null
	if(dungeon_area)
		qdel(dungeon_area)
		dungeon_area = null
	generator = null
	entrance_turf = null
	exit_turf = null

/datum/dungeon_instance/proc/generate()
	if(state != DUNGEON_STATE_IDLE)
		return FALSE
	state = DUNGEON_STATE_GENERATING

	// Request space for the dungeon
	reservation = SSmapping.request_turf_block_reservation(width, height, 1)
	if(!reservation)
		state = DUNGEON_STATE_FAILED
		return FALSE

	// Create a unique area for this dungeon (for power/gravity)
	dungeon_area = new /area/dungeon()
	dungeon_area.name = name

	// Generate the dungeon layout with room-based generator
	var/room_count = 5 + (difficulty * 2)
	generator = new /datum/room_dungeon_generator(width, height, room_count)
	if(!generator.generate())
		state = DUNGEON_STATE_FAILED
		return FALSE

	var/turf/bottom_left = reservation.bottom_left_turfs[1]

	// Set all turfs to the dungeon area BEFORE applying layout
	// This ensures doors and machinery are created in a powered area
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			var/turf/T = locate(bottom_left.x + x - 1, bottom_left.y + y - 1, bottom_left.z)
			if(T)
				dungeon_area.contents += T

	// Apply the generated layout to turfs (doors will now be in powered area)
	if(!generator.apply_to_turfs(bottom_left))
		state = DUNGEON_STATE_FAILED
		return FALSE

	// Find entrance and exit turfs
	find_special_turfs(bottom_left)

	// Add enemies and treasure
	populate_dungeon()

	// Add lighting to the dungeon
	add_lighting()

	state = DUNGEON_STATE_ACTIVE
	start_time = world.time
	return TRUE

/datum/dungeon_instance/proc/add_lighting()
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	// Add light sources in rooms
	for(var/datum/dungeon_room/room in generator.rooms)
		var/turf/center = locate(bottom_left.x + room.center_x - 1, bottom_left.y + room.center_y - 1, bottom_left.z)
		if(center && !istype(center, /turf/closed))
			new /obj/machinery/light/floor(center)

/datum/dungeon_instance/proc/find_special_turfs(turf/bottom_left)
	var/list/entrance_pos = generator.get_entrance_position()
	var/list/exit_pos = generator.get_exit_position()

	if(entrance_pos)
		entrance_turf = locate(bottom_left.x + entrance_pos[1] - 1, bottom_left.y + entrance_pos[2] - 1, bottom_left.z)

	if(exit_pos)
		exit_turf = locate(bottom_left.x + exit_pos[1] - 1, bottom_left.y + exit_pos[2] - 1, bottom_left.z)

/datum/dungeon_instance/proc/populate_dungeon()
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/mob_count = round(difficulty * 3) + rand(2, 4)
	var/treasure_count = round(difficulty * 0.5) + 1

	// Get floor positions EXCEPT in entrance room (no enemies at spawn!)
	var/list/floor_positions = generator.get_floor_positions_except_entrance()
	var/list/valid_floor_turfs = list()

	for(var/list/pos in floor_positions)
		var/turf/T = locate(bottom_left.x + pos[1] - 1, bottom_left.y + pos[2] - 1, bottom_left.z)
		if(T && T != entrance_turf && T != exit_turf)
			valid_floor_turfs += T

	// Spawn enemies in corridors and rooms (but NOT entrance room)
	for(var/i in 1 to mob_count)
		if(!length(valid_floor_turfs))
			break
		var/turf/spawn_turf = pick_n_take(valid_floor_turfs)
		var/mob/living/enemy = spawn_enemy(spawn_turf)
		if(enemy)
			spawned_mobs += enemy

	// Spawn treasure in rooms
	for(var/i in 1 to treasure_count)
		if(!length(valid_floor_turfs))
			break
		var/turf/spawn_turf = pick_n_take(valid_floor_turfs)
		var/obj/treasure = spawn_treasure(spawn_turf)
		if(treasure)
			spawned_objects += treasure

	// Create the exit room contents - ladder and gold bar!
	if(exit_turf)
		var/obj/structure/dungeon_exit/exit_obj = new(exit_turf)
		exit_obj.linked_dungeon = src
		spawned_objects += exit_obj

		// Add a gold bar near the exit as reward
		var/turf/gold_turf = get_step(exit_turf, pick(NORTH, SOUTH, EAST, WEST))
		if(gold_turf && !istype(gold_turf, /turf/closed))
			var/obj/item/stack/sheet/mineral/gold/gold_bar = new(gold_turf)
			gold_bar.amount = 1 + difficulty
			spawned_objects += gold_bar

/datum/dungeon_instance/proc/spawn_enemy(turf/T)
	if(!T)
		return null
	var/enemy_type = get_enemy_type_for_difficulty()
	var/mob/living/enemy = new enemy_type(T)
	return enemy

/// Returns an appropriate enemy type based on dungeon difficulty
/datum/dungeon_instance/proc/get_enemy_type_for_difficulty()
	var/list/tier1_enemies = list(
		/mob/living/basic/dungeon_mob/crawler,
		/mob/living/basic/dungeon_mob/sprite,
		/mob/living/basic/dungeon_mob/imp
	)
	var/list/tier2_enemies = list(
		/mob/living/basic/dungeon_mob/hellhound,
		/mob/living/basic/dungeon_mob/watcher,
		/mob/living/basic/dungeon_mob/leycreature,
		/mob/living/basic/dungeon_mob/flower_stalker
	)
	var/list/tier3_enemies = list(
		/mob/living/basic/dungeon_mob/warden,
		/mob/living/basic/dungeon_mob/sylph,
		/mob/living/basic/dungeon_mob/glimmerwing
	)

	switch(difficulty)
		if(1 to 2)
			// Easy: Only tier 1
			return pick(tier1_enemies)
		if(3 to 4)
			// Medium: Mostly tier 1, some tier 2
			if(prob(60))
				return pick(tier1_enemies)
			return pick(tier2_enemies)
		if(5 to 7)
			// Hard: Mix of tier 1, 2, and 3
			var/roll = rand(1, 100)
			if(roll <= 30)
				return pick(tier1_enemies)
			if(roll <= 70)
				return pick(tier2_enemies)
			return pick(tier3_enemies)
		else
			// Extreme (8+): Mostly tier 2 and 3
			var/roll = rand(1, 100)
			if(roll <= 20)
				return pick(tier1_enemies)
			if(roll <= 50)
				return pick(tier2_enemies)
			return pick(tier3_enemies)

/datum/dungeon_instance/proc/spawn_treasure(turf/T)
	if(!T)
		return null
	var/obj/structure/closet/crate/crate = new(T)
	new /obj/item/stack/spacecash/c100(crate)
	if(prob(30 * difficulty))
		new /obj/item/stack/spacecash/c500(crate)
	return crate

/datum/dungeon_instance/proc/enter_dungeon(mob/living/player)
	if(state != DUNGEON_STATE_ACTIVE)
		return FALSE
	if(!entrance_turf)
		return FALSE
	if(player in players_inside)
		return FALSE
	// Check if dungeon is full (-1 means infinite)
	if(max_players >= 0 && length(players_inside) >= max_players)
		return FALSE
	players_inside += player
	player.forceMove(entrance_turf)
	to_chat(player, span_notice("You enter [name]. Find the exit to complete the dungeon!"))
	return TRUE

/datum/dungeon_instance/proc/exit_dungeon(mob/living/player, turf/destination)
	if(!(player in players_inside))
		return FALSE
	players_inside -= player
	if(destination)
		player.forceMove(destination)
	if(!length(players_inside))
		complete_dungeon()
	return TRUE

/datum/dungeon_instance/proc/complete_dungeon()
	if(state != DUNGEON_STATE_ACTIVE)
		return
	state = DUNGEON_STATE_COMPLETED
	completion_time = world.time - start_time
	qdel(src)

/datum/dungeon_instance/proc/get_time_elapsed()
	if(!start_time)
		return 0
	return world.time - start_time

/obj/structure/dungeon_exit
	name = "exit ladder"
	desc = "A sturdy ladder leading back to safety. Climb it to escape the dungeon."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	density = FALSE
	var/datum/dungeon_instance/linked_dungeon
	var/turf/return_destination

/obj/structure/dungeon_exit/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!linked_dungeon)
		to_chat(user, span_warning("This ladder doesn't seem to lead anywhere!"))
		return

	// Get the destination
	var/turf/destination = return_destination
	if(!destination)
		destination = get_safe_random_station_turf()

	if(!destination)
		to_chat(user, span_warning("Cannot find a safe exit location!"))
		return

	// Teleport the player first, then handle dungeon tracking
	to_chat(user, span_notice("You climb the ladder and escape the dungeon!"))
	user.forceMove(destination)

	// Update dungeon tracking
	if(user in linked_dungeon.players_inside)
		linked_dungeon.players_inside -= user

	// Complete dungeon if empty
	if(!length(linked_dungeon.players_inside))
		linked_dungeon.complete_dungeon()

/obj/structure/dungeon_exit/Destroy()
	linked_dungeon = null
	return_destination = null
	return ..()
