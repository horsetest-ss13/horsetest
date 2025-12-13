/obj/machinery/dungeon_portal
	name = "dungeon portal"
	desc = "A mysterious portal leading to procedurally generated dungeons. Who knows what treasures await within?"
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "tele1"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/datum/dungeon_instance/active_dungeon
	var/dungeon_difficulty = 1
	var/dungeon_width = 25
	var/dungeon_height = 25
	var/cooldown_time = 30 SECONDS
	var/next_use_time = 0

/obj/machinery/dungeon_portal/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/machinery/dungeon_portal/update_overlays()
	. = ..()
	if(active_dungeon && active_dungeon.state == DUNGEON_STATE_ACTIVE)
		. += mutable_appearance(icon, "فfield")

/obj/machinery/dungeon_portal/examine(mob/user)
	. = ..()
	. += span_notice("Dungeon difficulty: [dungeon_difficulty]")
	if(active_dungeon)
		switch(active_dungeon.state)
			if(DUNGEON_STATE_ACTIVE)
				var/player_count = length(active_dungeon.players_inside)
				if(active_dungeon.max_players < 0)
					. += span_notice("A dungeon is currently active. [player_count] player(s) inside. Click to join!")
				else
					. += span_notice("A dungeon is currently active. [player_count]/[active_dungeon.max_players] player(s) inside.")
			if(DUNGEON_STATE_GENERATING)
				. += span_warning("A dungeon is being generated...")
	else if(world.time < next_use_time)
		var/remaining = round((next_use_time - world.time) / 10)
		. += span_warning("Portal is recharging. [remaining] seconds remaining.")
	else
		. += span_notice("Ready to generate a new dungeon.")

/obj/machinery/dungeon_portal/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("[src] is not operational!"))
		return
	if(active_dungeon && active_dungeon.state == DUNGEON_STATE_ACTIVE)
		enter_active_dungeon(user)
		return
	if(world.time < next_use_time)
		var/remaining = round((next_use_time - world.time) / 10)
		to_chat(user, span_warning("The portal is still recharging. [remaining] seconds remaining."))
		return
	start_new_dungeon(user)

/obj/machinery/dungeon_portal/proc/start_new_dungeon(mob/living/user)
	to_chat(user, span_notice("Generating dungeon... Please wait."))
	active_dungeon = new /datum/dungeon_instance("Procedural Dungeon", dungeon_difficulty, dungeon_width, dungeon_height)
	active_dungeon.owner_ref = WEAKREF(user)
	if(!active_dungeon.generate())
		to_chat(user, span_warning("Dungeon generation failed!"))
		QDEL_NULL(active_dungeon)
		return
	var/obj/structure/dungeon_exit/exit_obj = locate() in active_dungeon.spawned_objects
	if(exit_obj)
		exit_obj.return_destination = get_turf(src)
	to_chat(user, span_notice("Dungeon generated! Entering..."))
	active_dungeon.enter_dungeon(user)
	RegisterSignal(active_dungeon, COMSIG_QDELETING, PROC_REF(on_dungeon_destroyed))
	update_appearance()

/obj/machinery/dungeon_portal/proc/enter_active_dungeon(mob/living/user)
	if(!active_dungeon || active_dungeon.state != DUNGEON_STATE_ACTIVE)
		to_chat(user, span_warning("No active dungeon to enter!"))
		return
	// Check if dungeon is full
	if(active_dungeon.max_players >= 0 && length(active_dungeon.players_inside) >= active_dungeon.max_players)
		to_chat(user, span_warning("The dungeon is full! ([length(active_dungeon.players_inside)]/[active_dungeon.max_players] players)"))
		return
	if(!active_dungeon.enter_dungeon(user))
		to_chat(user, span_warning("Unable to enter the dungeon!"))
		return
	to_chat(user, span_notice("You enter the dungeon..."))

/obj/machinery/dungeon_portal/proc/on_dungeon_destroyed(datum/source)
	SIGNAL_HANDLER
	active_dungeon = null
	next_use_time = world.time + cooldown_time
	update_appearance()

/obj/machinery/dungeon_portal/Destroy()
	if(active_dungeon)
		QDEL_NULL(active_dungeon)
	return ..()

/obj/machinery/dungeon_portal/easy
	name = "easy dungeon portal"
	dungeon_difficulty = 1
	dungeon_width = 20
	dungeon_height = 20

/obj/machinery/dungeon_portal/medium
	name = "medium dungeon portal"
	dungeon_difficulty = 3
	dungeon_width = 25
	dungeon_height = 25

/obj/machinery/dungeon_portal/hard
	name = "hard dungeon portal"
	dungeon_difficulty = 5
	dungeon_width = 30
	dungeon_height = 30

/obj/machinery/dungeon_portal/extreme
	name = "extreme dungeon portal"
	desc = "A portal crackling with dangerous energy. Only the bravest should enter."
	dungeon_difficulty = 10
	dungeon_width = 40
	dungeon_height = 40
