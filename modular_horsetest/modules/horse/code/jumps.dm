// Horse Jumps //

/// A barrier that can be jumped over by a rider on a sufficiently fast horse. (To be changed to strength later)
/obj/structure/barricade/horse_jump
	name = "crossrail" // the simplest of jumps
	desc = "A barrier designed to be jumped over on horseback. This one looks incredibly easy to clear."
	icon = 'modular_horsetest/modules/horse/icons/jumps.dmi'
	icon_state = "crossrail"
	max_integrity = 120
	proj_pass_rate = 60
	bar_material = 2 // WOOD
	var/min_speed_stat = 20
	/// Stops the "not fast enough" warning from spamming while a rider keeps pushing into the jump.
	COOLDOWN_DECLARE(refuse_message_cooldown)

/obj/structure/barricade/horse_jump/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

// This gets called constantly (movement, pathfinding), so it must stay free of side effects.
/obj/structure/barricade/horse_jump/CanAllowThrough(atom/movable/mover, border_dir)
	// Default barricade pass logic (projectiles, etc.) still applies.
	. = ..()
	if(.)
		return TRUE

	// Riders follow their horse onto the jump after it has already cleared it.
	if(isliving(mover))
		var/mob/living/rider = mover
		if(istype(rider.buckled, /mob/living/basic/horse) && rider.buckled.loc == loc)
			return TRUE

	var/mob/living/basic/horse/mount = mover
	if(!istype(mount))
		return FALSE

	// Change mount.sspeed to mount.strength once we add strength stats.
	return mount.sspeed >= min_speed_stat

/obj/structure/barricade/horse_jump/Bumped(atom/movable/bumped_atom)
	. = ..()
	var/mob/living/basic/horse/mount = bumped_atom
	if(!istype(mount) || !COOLDOWN_FINISHED(src, refuse_message_cooldown))
		return
	COOLDOWN_START(src, refuse_message_cooldown, 2 SECONDS)
	for(var/mob/living/rider in mount.buckled_mobs)
		to_chat(rider, span_warning("[mount] isn't fast enough to clear [src]!"))

/obj/structure/barricade/horse_jump/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/basic/horse/mount = arrived
	if(!istype(mount))
		return

	if(length(mount.buckled_mobs))
		var/mob/living/rider = mount.buckled_mobs[1]
		visible_message(span_notice("[rider] jumps [mount] over [src]!"))
	else
		visible_message(span_notice("[mount] leaps over [src]!"))
	playsound(src, 'sound/mobs/non-humanoids/pony/whinny01.ogg', 50, vary = TRUE)

/obj/structure/barricade/horse_jump/crossrail	// exists solely to make admin spawning easier

/obj/structure/barricade/horse_jump/vertical
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks fairly easy to clear."
	icon_state = "vertical_low"
	min_speed_stat = 30

/obj/structure/barricade/horse_jump/vertical/mid
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one doesn't look that difficult to clear."
	icon_state = "vertical_mid"
	min_speed_stat = 40

/obj/structure/barricade/horse_jump/vertical/high
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks a little difficult to clear."
	icon_state = "vertical_high"
	min_speed_stat = 50

/obj/structure/barricade/horse_jump/oxer
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks fairly difficult to clear."
	icon_state = "oxer_low"
	min_speed_stat = 60

/obj/structure/barricade/horse_jump/oxer/mid
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks very difficult to clear."
	icon_state = "oxer_mid"
	min_speed_stat = 70

/obj/structure/barricade/horse_jump/oxer/high
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks incredibly difficult to clear."
	icon_state = "oxer_high"
	min_speed_stat = 90
