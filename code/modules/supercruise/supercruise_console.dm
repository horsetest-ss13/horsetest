/**
 * # Supercruise Flight Console
 *
 * Allows controlling a shuttle in supercruise/orbital space.
 */
/obj/machinery/computer/supercruise
	name = "supercruise flight console"
	desc = "A console for controlling a vessel in supercruise."
	icon_screen = "shuttle"
	icon_keyboard = "generic_key"

	/// The shuttle we're controlling
	var/datum/orbital_object/shuttle/controlled_shuttle

/obj/machinery/computer/supercruise/Initialize(mapload)
	. = ..()
	connect_to_shuttle(mapload, SSshuttle.get_containing_shuttle(src))

/obj/machinery/computer/supercruise/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(!mapload)
		return
	if(!port)
		return

	// Check if an orbital shuttle already exists for this port
	for(var/datum/orbital_object/shuttle/existing_shuttle in SSsupercruise.orbital_objects)
		if(existing_shuttle.shuttle_port == port)
			controlled_shuttle = existing_shuttle
			return TRUE

	// If no existing shuttle, create a new one
	controlled_shuttle = new /datum/orbital_object/shuttle()
	controlled_shuttle.shuttle_port = port
	controlled_shuttle.name = port.name || "Shuttle"
	// Start at a default position - shuttle is docked at station initially
	controlled_shuttle.position_x = 100
	controlled_shuttle.position_y = 50
	SSsupercruise.orbital_objects += controlled_shuttle
	return TRUE

/obj/machinery/computer/supercruise/Destroy()
	// Clean up any open UIs
	SStgui.close_uis(src)
	return ..()

/obj/machinery/computer/supercruise/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupercruiseMap")
		ui.open()
	SSsupercruise.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/supercruise/ui_close(mob/user, datum/tgui/ui)
	. = ..()
	SSsupercruise.open_orbital_maps -= ui

/obj/machinery/computer/supercruise/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/supercruise/ui_data(mob/user)
	var/list/data = SSsupercruise.get_orbital_map_data()

	// Add shuttle-specific data
	if(controlled_shuttle)
		data["linkedToShuttle"] = TRUE
		data["shuttleName"] = controlled_shuttle.name
		data["shuttleAngle"] = controlled_shuttle.thrust_angle
		data["shuttleThrust"] = controlled_shuttle.thrust_power
		data["shuttleVelX"] = controlled_shuttle.velocity_x
		data["shuttleVelY"] = controlled_shuttle.velocity_y
		data["ourObject"] = controlled_shuttle.get_map_data()
		data["autopilotEnabled"] = controlled_shuttle.autopilot_enabled

		// Check if docked - either docked_at is set OR shuttle is not in transit dock
		var/obj/docking_port/stationary/current_dock = controlled_shuttle.shuttle_port?.get_docked()
		var/is_in_transit = istype(current_dock, /obj/docking_port/stationary/transit)
		var/is_docked = (controlled_shuttle.docked_at != null) || (current_dock && !is_in_transit)
		data["isDocked"] = is_docked

		var/docked_station_name = null
		if(controlled_shuttle.docked_at)
			docked_station_name = controlled_shuttle.docked_at.station_name
		else if(is_docked && current_dock)
			docked_station_name = current_dock.name
		data["dockedStation"] = docked_station_name

		// Get nearby stations
		var/list/nearby_stations = list()
		for(var/datum/orbital_object/station/station in controlled_shuttle.get_nearby_stations())
			nearby_stations += list(list(
				"id" = station.unique_id,
				"name" = station.station_name,
				"distance" = round(sqrt((station.position_x - controlled_shuttle.position_x)**2 + (station.position_y - controlled_shuttle.position_y)**2), 0.1),
				"occupied" = station.occupied
			))
		data["nearbyStations"] = nearby_stations

		// Get ALL nearby interactable objects (generic)
		var/list/nearby_objects = list()
		for(var/datum/orbital_object/obj in controlled_shuttle.get_nearby_objects(30))
			nearby_objects += list(list(
				"id" = obj.unique_id,
				"name" = obj.name,
				"distance" = round(sqrt((obj.position_x - controlled_shuttle.position_x)**2 + (obj.position_y - controlled_shuttle.position_y)**2), 0.1),
				"type" = obj.render_mode,
				"occupied" = istype(obj, /datum/orbital_object/station) ? obj:occupied : FALSE
			))
		data["nearbyObjects"] = nearby_objects

		if(controlled_shuttle.target_position)
			data["targetX"] = controlled_shuttle.target_position["x"]
			data["targetY"] = controlled_shuttle.target_position["y"]
	else
		data["linkedToShuttle"] = FALSE

	return data

/obj/machinery/computer/supercruise/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!controlled_shuttle)
		return

	// Check if docked - prevent flight controls when docked
	var/obj/docking_port/stationary/current_dock = controlled_shuttle.shuttle_port?.get_docked()
	var/is_in_transit = istype(current_dock, /obj/docking_port/stationary/transit)
	var/is_docked = (controlled_shuttle.docked_at != null) || (current_dock && !is_in_transit)

	switch(action)
		if("set_thrust")
			if(is_docked)
				to_chat(usr, span_warning("Cannot control thrust while docked!"))
				return FALSE
			var/angle = text2num(params["angle"])
			var/power = text2num(params["power"])
			if(!isnull(angle) && !isnull(power))
				controlled_shuttle.set_thrust(angle, power)
			return TRUE

		if("set_heading")
			if(is_docked)
				to_chat(usr, span_warning("Cannot set heading while docked!"))
				return FALSE
			var/new_x = text2num(params["x"])
			var/new_y = text2num(params["y"])
			if(!isnull(new_x) && !isnull(new_y))
				// Calculate angle to target point
				var/dx = new_x - controlled_shuttle.position_x
				var/dy = new_y - controlled_shuttle.position_y
				var/angle = TODEGREES(arctan(dy, dx))
				// Normalize to 0-360
				if(angle < 0)
					angle += 360
				controlled_shuttle.thrust_angle = angle
			return TRUE

		if("setTargetCoords")
			if(is_docked)
				to_chat(usr, span_warning("Cannot engage autopilot while docked!"))
				return FALSE
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			var/altKey = params["altKey"]

			if(altKey) // Alt+Click clears target and stops thrust
				controlled_shuttle.autopilot_enabled = FALSE
				controlled_shuttle.target_position = null
				controlled_shuttle.thrust_power = 0
			else if(!isnull(x) && !isnull(y))
				// Set target position and enable autopilot
				controlled_shuttle.target_position = list("x" = x, "y" = y)
				controlled_shuttle.autopilot_enabled = TRUE
			return TRUE

		if("dock")
			var/object_id = params["stationId"]  // Keep param name for compatibility
			if(!object_id)
				return FALSE

			// Find the object (generic - can be any orbital object)
			var/datum/orbital_object/target_object = null
			for(var/datum/orbital_object/obj in SSsupercruise.orbital_objects)
				if(obj.unique_id == object_id)
					target_object = obj
					break

			if(!target_object)
				to_chat(usr, span_warning("Object not found!"))
				return FALSE

			// Use generic interact method
			var/interact_result = target_object.interact(controlled_shuttle, usr)
			if(interact_result)
				to_chat(usr, span_warning("Interaction failed: [interact_result]"))
			else
				// Success messages are handled by the interact() method
				// Station-specific success message
				if(istype(target_object, /datum/orbital_object/station))
					to_chat(usr, span_notice("Docking successful at [target_object.name]"))
			return TRUE

		if("undock")
			var/undock_result = controlled_shuttle.undock_from_station()
			if(undock_result)
				to_chat(usr, span_warning("Undocking failed: [undock_result]"))
			else
				to_chat(usr, span_notice("Undocked successfully"))
			return TRUE
