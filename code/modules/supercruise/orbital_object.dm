/**
 * # Orbital Object
 *
 * Represents an object in orbital space (supercruise).
 * Has a position and velocity, gets updated by SSsupercruise.
 */
/datum/orbital_object
	/// Unique identifier
	var/unique_id = ""
	/// Display name
	var/name = "Unknown Object"
	/// Radius for rendering/collision (in arbitrary units)
	var/radius = 1
	/// Position X (in kilometers)
	var/position_x = 0
	/// Position Y (in kilometers)
	var/position_y = 0
	/// Velocity X (in kilometers per second)
	var/velocity_x = 0
	/// Velocity Y (in kilometers per second)
	var/velocity_y = 0
	/// Render mode for UI (default, planet, shuttle, etc)
	var/render_mode = "default"
	/// Time when this object was created (for UI animation purposes)
	var/created_at = 0

/datum/orbital_object/New()
	. = ..()
	unique_id = "\ref[src]"
	created_at = world.time
	SSsupercruise.orbital_objects += src

/datum/orbital_object/Destroy()
	SSsupercruise.orbital_objects -= src
	return ..()

/**
 * Called by SSsupercruise to update position based on velocity
 * seconds_per_tick is in seconds (from delta_time / 10)
 */
/datum/orbital_object/process(seconds_per_tick)
	// Update position: position += velocity * time
	position_x += velocity_x * seconds_per_tick
	position_y += velocity_y * seconds_per_tick

/**
 * Get data for UI display
 */
/datum/orbital_object/proc/get_map_data()
	return list(
		"id" = unique_id,
		"name" = name,
		"position_x" = position_x,
		"position_y" = position_y,
		"velocity_x" = velocity_x,
		"velocity_y" = velocity_y,
		"radius" = radius,
		"render_mode" = render_mode,
		"created_at" = created_at,
		"vel_mult" = 1, // Velocity multiplier for UI interpolation
		"priority" = 0, // For UI sorting
	)

/**
 * Called when a shuttle tries to interact with this object
 * Override in child classes to provide specific functionality
 * Returns null on success, or an error message string on failure
 */
/datum/orbital_object/proc/interact(datum/orbital_object/shuttle/interacting_shuttle, mob/user)
	to_chat(user, span_notice("You examine [name] from a distance. Nothing happens."))
	return null
