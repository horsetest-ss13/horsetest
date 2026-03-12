// Horse Jumps //

/// A barrier that can be jumped over by a rider on a sufficiently fast horse. (To be changed to strength later)
/obj/structure/barricade/horse_jump
	name = "crossrail" // the simplest of jumps
	desc = "A barrier designed to be jumped over on horseback. This one looks incredibly easy to clear."
	icon = 'modular_horsetest/modules/horse/icons/jumps.dmi'
	icon_state = "crossrail"
	max_integrity = 120
	proj_pass_rate = 60
	bar_material = WOOD
	var/min_speed_stat = 20

/obj/structure/barricade/horse_jump/CanAllowThrough(atom/movable/mover, border_dir)
	// Default barricade pass logic (projectiles, etc.) still applies.
	. = ..()
	if(.)
		return TRUE

	var/mob/living/basic/horse/mount = mover
	if(!istype(mount))
		return FALSE

	// Change mount.sspeed to mount.strength once we add strength stats.
	if(mount.sspeed < min_speed_stat)
		for(var/mob/living/rider in mount.buckled_mobs)
			to_chat(rider, span_warning("[mount] isn't fast enough to clear [src]!"))
		return FALSE

	if(length(mount.buckled_mobs))
		var/mob/living/rider = mount.buckled_mobs[1]
    	visible_message(span_notice("[rider] jumps [mount] over [src]!"))
	else
		visible_message(span_notice("[mount] leaps over [src]!"))
	playsound(src, 'sound/mobs/non-humanoids/pony/whinny01.ogg', 50, vary = TRUE)
		return TRUE

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
