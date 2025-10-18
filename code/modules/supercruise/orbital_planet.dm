/**
 * # Orbital Planet
 *
 * Represents a planet in orbital space.
 * Planets are large, non-moving objects that can be interacted with.
 */
/datum/orbital_object/planet
	render_mode = "planet"
	radius = 8  // Larger than shuttles and stations
	/// Whether this planet can be landed on
	var/landable = TRUE
	/// Description shown when examining
	var/description = "A distant celestial body."

/datum/orbital_object/planet/New(x_pos, y_pos, planet_name, set_type = /datum/orbital_object/planet/rocky)
	. = ..()
	position_x = x_pos
	position_y = y_pos
	name = planet_name

/datum/orbital_object/planet/get_map_data()
	var/list/data = ..()
	data["landable"] = landable
	return data

/**
 * Planets don't move - override the process to do nothing
 */
/datum/orbital_object/planet/process(seconds_per_tick)
	return

/**
 * Override interact to handle planet-specific interactions
 */
/datum/orbital_object/planet/interact(datum/orbital_object/shuttle/interacting_shuttle, mob/user)
	if(!istype(interacting_shuttle))
		return "Only shuttles can interact with planets"

	// Planet-specific interaction
	if(landable)
		to_chat(user, span_notice("You initiate landing procedures on [name]. This planet appears suitable for landing."))
		to_chat(user, span_warning("Landing functionality not yet implemented."))
	else
		to_chat(user, span_warning("[name] is not suitable for landing. [description]"))

	return null // Success (message shown)
