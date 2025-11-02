/**
 * # Planet Generation Admin Verbs
 *
 * Admin tools for testing planet generation
 */

/client/proc/generate_test_planet()
	set name = "Generate Test Planet"
	set category = "Debug"
	set desc = "Generate a test planet for debugging"

	if(!check_rights(R_DEBUG))
		return

	var/planet_name = input(usr, "Planet name:", "Generate Planet", "Test Planet") as text|null
	if(!planet_name)
		return

	var/planet_size = input(usr, "Planet size (recommended 50-150):", "Generate Planet", 100) as num|null
	if(!planet_size)
		return

	planet_size = clamp(planet_size, 20, 200)

	var/generator_type = input(usr, "Select planet type:", "Generate Planet") as null|anything in list(
		"Rocky" = /datum/map_generator/planet_generator/rocky,
	)

	if(!generator_type)
		return

	to_chat(usr, span_notice("Generating planet [planet_name] with size [planet_size]x[planet_size]..."))

	var/datum/map_generator/planet_generator/generator = new generator_type
	var/list/result = generator.generate_planet_level(planet_name, planet_size, /turf/open/space/basic)

	if(result && length(result))
		var/datum/virtual_level/vlevel = result[1]
		var/list/docking_ports = result[2]

		to_chat(usr, span_boldnotice("Planet generated successfully!"))
		to_chat(usr, span_notice("Z-level: [vlevel.z_value]"))
		to_chat(usr, span_notice("Coordinates: ([vlevel.low_x], [vlevel.low_y]) to ([vlevel.high_x], [vlevel.high_y])"))
		to_chat(usr, span_notice("Reserved margin: [vlevel.reserved_margin] tiles (indestructible border)"))
		to_chat(usr, span_info("Docking ports created: [length(docking_ports)]"))

		// List docking ports
		for(var/obj/docking_port/stationary/dock as anything in docking_ports)
			to_chat(usr, span_info("  - [dock.name] at ([dock.x], [dock.y])"))

		// Offer to teleport
		if(alert(usr, "Teleport to planet surface?", "Generate Planet", "Yes", "No") == "Yes")
			var/turf/center = vlevel.get_unreserved_bottom_left_turf()
			if(center)
				// Offset a bit from the edge
				center = locate(center.x + 5, center.y + 5, center.z)
				if(center)
					usr.forceMove(center)
					to_chat(usr, span_notice("Teleported to planet surface."))
	else
		to_chat(usr, span_warning("Failed to generate planet!"))

/client/proc/list_generated_planets()
	set name = "List Generated Planets"
	set category = "Debug"
	set desc = "List all generated planet levels"

	if(!check_rights(R_DEBUG))
		return

	var/list/output = list()
	output += "<b>Generated Planets:</b><br>"

	for(var/datum/map_zone/zone in SSmapping.map_zones)
		if(findtext(zone.name, "Zone"))
			output += "- [zone.name]<br>"
			for(var/datum/virtual_level/vlevel in zone.virtual_levels)
				output += "  * [vlevel.name] (Z:[vlevel.z_value], Size:[vlevel.x_distance]x[vlevel.y_distance])<br>"

	if(length(output) == 1)
		output += "<i>No planets generated yet.</i><br>"

	var/datum/browser/popup = new(usr, "generated_planets", "Generated Planets", 400, 600)
	popup.set_content(output.Join())
	popup.open()
