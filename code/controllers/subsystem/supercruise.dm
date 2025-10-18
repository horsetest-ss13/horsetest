/**
 * # Supercruise Subsystem
 *
 * Handles orbital object movement and updates UIs.
 * Based on BeeStation's SSorbits but simplified.
 */
SUBSYSTEM_DEF(supercruise)
	name = "Supercruise"
	flags = SS_KEEP_TIMING
	wait = 10 // Update every second (1 second = 10 deciseconds)
	priority = FIRE_PRIORITY_DEFAULT

	/// All orbital objects being tracked
	var/list/datum/orbital_object/orbital_objects = list()

	/// Open UIs that need to be updated
	var/list/open_orbital_maps = list()

/datum/controller/subsystem/supercruise/Initialize()
	// Create a test station at coordinates (100, 50)
	var/datum/orbital_object/station/test_station = new(100, 50, "Test Station Alpha")
	// Note: test_station is automatically added to orbital_objects in its New() proc

	// Generate random planets in the system
	generate_planets(rand(8, 12))

	return SS_INIT_SUCCESS

/**
 * Generate a solar system with various planets
 */
/datum/controller/subsystem/supercruise/proc/generate_planets(var/num_planets)
	var/list/planet_types = GLOB.planet_types

	// Generate 8-12 planets at various distances
	var/list/used_positions = list()

	for(var/i in 1 to num_planets)
		// Random planet type
		var/planet_type = pick(planet_types)

		// Get a name for this planet type
		var/planet_name = "planet"

		// Generate position - spread planets around the map
		// Try to avoid overlapping
		var/x_pos
		var/y_pos
		var/attempts = 0
		var/valid_position = FALSE

		while(!valid_position && attempts < 20)
			attempts++
			// Random position in a large area
			x_pos = rand(-200, 400)
			y_pos = rand(-200, 400)

			// Check if too close to any existing planet or station
			valid_position = TRUE
			for(var/datum/orbital_object/obj in orbital_objects)
				var/dist = sqrt((obj.position_x - x_pos)**2 + (obj.position_y - y_pos)**2)
				if(dist < 50)  // Minimum 50km separation
					valid_position = FALSE
					break

			// Also check against other positions we've generated this loop
			for(var/list/pos in used_positions)
				var/dist = sqrt((pos["x"] - x_pos)**2 + (pos["y"] - y_pos)**2)
				if(dist < 50)
					valid_position = FALSE
					break

		if(valid_position)
			used_positions += list(list("x" = x_pos, "y" = y_pos))
			var/datum/orbital_object/planet/new_planet = new planet_type(x_pos, y_pos, planet_name)
			// Note: new_planet is automatically added to orbital_objects in its New() proc
			log_world("Generated planet: [planet_name] ([planet_type]) at ([x_pos], [y_pos])")

/datum/controller/subsystem/supercruise/fire(resumed)
	// Update all orbital objects
	// Convert wait (deciseconds) to seconds for the process call
	var/seconds_per_tick = wait / 10
	for(var/datum/orbital_object/obj in orbital_objects)
		obj.process(seconds_per_tick)

	// Update all open UIs
	for(var/datum/tgui/ui in open_orbital_maps)
		// Check if UI is still valid and has a user
		if(!ui || !ui.user || !ui.user.client)
			open_orbital_maps -= ui
			continue
		ui.send_update()

/**
 * Get data for rendering the orbital map
 */
/datum/controller/subsystem/supercruise/proc/get_orbital_map_data()
	var/list/data = list()
	data["update_index"] = times_fired
	data["map_objects"] = list()

	for(var/datum/orbital_object/obj in orbital_objects)
		data["map_objects"] += list(obj.get_map_data())

	return data
