/**
 * # Orbital Planet
 *
 * Represents a planet in orbital space.
 * Planets are large, non-moving objects that can be interacted with.
 */
/datum/orbital_object/planet
	render_mode = "planet"
	radius = 8  // Larger than shuttles and stations

	/// Planet type for visual variety
	var/planet_type = "rocky"
	/// Color for rendering
	var/planet_color = "#8B7355"
	/// Whether this planet can be landed on
	var/landable = TRUE
	/// Description shown when examining
	var/description = "A distant celestial body."

/datum/orbital_object/planet/New(x_pos = 0, y_pos = 0, planet_name = "Unknown Planet", set_type = "rocky")
	. = ..()
	position_x = x_pos
	position_y = y_pos
	name = planet_name
	planet_type = set_type

	// Set color based on planet type
	switch(planet_type)
		if("rocky")
			planet_color = "#8B7355"  // Brown
			description = "A barren rocky world."
		if("ice")
			planet_color = "#B0E0E6"  // Light blue
			description = "A frozen ice world."
		if("gas")
			planet_color = "#FFA07A"  // Light orange
			description = "A massive gas giant."
			landable = FALSE
		if("lava")
			planet_color = "#FF4500"  // Red-orange
			description = "A volcanic hellscape."
		if("oceanic")
			planet_color = "#4682B4"  // Steel blue
			description = "A world covered in vast oceans."
		if("desert")
			planet_color = "#DEB887"  // Burlywood
			description = "An arid desert planet."
		if("forest")
			planet_color = "#228B22"  // Forest green
			description = "A lush green world."

/datum/orbital_object/planet/get_map_data()
	var/list/data = ..()
	data["planet_type"] = planet_type
	data["planet_color"] = planet_color
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
