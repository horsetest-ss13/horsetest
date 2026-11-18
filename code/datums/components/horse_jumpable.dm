/datum/component/horse_jumpable
	/// Minimum strength required to pass this obstacle.
	var/min_strength_stat = 20
	/// Visually how high a horse jumps with the `leap()` proc.
	var/jump_height = 12
	/// Prevents the "not strong enough" message from being spammed.
	COOLDOWN_DECLARE(refuse_message_cooldown)

/datum/component/horse_jumpable/Initialize(min_strength_stat = 20, jump_height = 12)
	. = ..()
	src.min_strength_stat = min_strength_stat
	src.jump_height = jump_height

/datum/component/horse_jumpable/RegisterWithParent()
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_TRIED_PASS, PROC_REF(can_allow_through))
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(on_bumped))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)
	register_loc_sig()

/datum/component/horse_jumpable/UnregisterFromParent()
	. = ..()
	var/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	parent.RemoveElement(/datum/element/connect_loc, loc_connections)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_TRIED_PASS,
		COMSIG_ATOM_BUMPED,
		COMSIG_MOVABLE_MOVED
	))

/datum/component/horse_jumpable/proc/can_allow_through(atom/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER

	if(isliving(mover))
		var/mob/living/rider = mover
		if(istype(rider.buckled, /mob/living/basic/horse) && rider.buckled.loc == source.loc)
			return COMSIG_COMPONENT_PERMIT_PASSAGE

	var/mob/living/basic/horse/mount = mover

	if(!istype(mount))
		return COMSIG_COMPONENT_REFUSE_PASSAGE

	if(mount.strength >= min_strength_stat)
		return COMSIG_COMPONENT_PERMIT_PASSAGE
	return COMSIG_COMPONENT_REFUSE_PASSAGE

/datum/component/horse_jumpable/proc/on_entered(atom/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/basic/horse/mount = arrived
	if(!istype(mount))
		return
	if(length(mount.buckled_mobs))
		var/mob/living/rider = mount.buckled_mobs[1]
		source.visible_message(span_notice("[rider] jumps [mount] over [source]!"))
	else
		source.visible_message(span_notice("[mount] leaps over [source]!"))
	mount.leap(jump_height)
	// Some slip code stolen from `code/game/turfs/open/_open.dm`. Stops horses from landing on the tile.
	var/olddir = mount.dir
	mount.moving_diagonally = 0
	var/turf/target = get_ranged_target_turf(mount, olddir, 1)
	mount.AddComponent(/datum/component/force_move, target, FALSE)

/datum/component/horse_jumpable/proc/on_bumped(datum/source, atom/movable/bumped)
	SIGNAL_HANDLER
	var/mob/living/basic/horse/mount = bumped
	if(!istype(mount) || !COOLDOWN_FINISHED(src, refuse_message_cooldown))
		return
	COOLDOWN_START(src, refuse_message_cooldown, 2 SECONDS)
	for(var/mob/living/rider in mount.buckled_mobs)
		to_chat(rider, span_warning("[mount] isn't strong enough to clear [source]!"))
	// In case the horse is sentient
	to_chat(mount, span_warning("You aren't strong enough to clear [source]!"))

/datum/component/horse_jumpable/proc/on_moved(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	unregister_loc_sig(old_loc)
	register_loc_sig()

/datum/component/horse_jumpable/proc/register_loc_sig()
	var/atom/listener = parent
	if(QDELETED(listener) || QDELETED(listener.loc))
		return
	RegisterSignal(listener.loc, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/datum/component/horse_jumpable/proc/unregister_loc_sig(atom/old_loc)
	if(isnull(old_loc))
		return
	RegisterSignal(old_loc, COMSIG_ATOM_ENTERED)
