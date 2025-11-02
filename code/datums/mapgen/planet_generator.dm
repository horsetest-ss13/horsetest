/**
 * # Planet Generator
 *
 * Basic planet generation system integrated with the supercruise system.
 * Currently generates simple flat planets with a single biome.
 */

/datum/map_generator/planet_generator
	/// The biome that will be used for this planet
	var/biome_type = /datum/biome/asteroid
	/// Reference to the biome datum
	var/datum/biome/planet_biome
	/// The area type to use for the planet
	var/area/area_type = /area/planet

/datum/map_generator/planet_generator/New()
	. = ..()
	// Initialize the biome
	planet_biome = SSmapping.biomes[biome_type]
	if(!planet_biome)
		planet_biome = new biome_type()
		SSmapping.biomes[biome_type] = planet_biome

/**
 * Generates a planet level using the virtual level system
 *
 * Arguments:
 * * planet_name - Name of the planet
 * * planet_size - Size of the planet (default 100x100)
 * * baseturf - The base turf type for this planet
 * * mapzone - Optional existing mapzone to use
 *
 * Returns: A list containing [vlevel, list of docking_ports]
 */
/datum/map_generator/planet_generator/proc/generate_planet_level(planet_name = "Planet", planet_size = 100, baseturf = /turf/open/space/basic, datum/map_zone/mapzone = null)
	// Create a map zone for this planet if not provided
	if(!mapzone)
		mapzone = SSmapping.create_map_zone("[planet_name] Zone")
		if(!mapzone)
			log_world("ERROR: Failed to create map zone for [planet_name]")
			return null

	// Add extra space for the 1-tile border on each side
	var/total_size = planet_size + 2

	// Create a virtual level for the planet
	var/datum/virtual_level/vlevel = SSmapping.create_virtual_level(
		planet_name,
		list(ZTRAIT_MINING = TRUE, ZTRAIT_BASETURF = baseturf),
		mapzone,
		total_size,
		total_size,
		ALLOCATION_FREE,
		DEFAULT_ALLOC_JUMP
	)

	if(!vlevel)
		log_world("ERROR: Failed to create virtual level for [planet_name]")
		return null

	// Reserve a 1-tile margin to create indestructible borders
	vlevel.reserve_margin(1)

	// Create docking ports for ship landing
	var/list/docking_ports = create_docking_ports(vlevel, planet_name)

	// Get the turfs to generate (excluding the border)
	var/list/turf/turfs_to_generate = list()
	var/turf/bottom_left = vlevel.get_unreserved_bottom_left_turf()
	var/turf/top_right = vlevel.get_unreserved_top_right_turf()

	for(var/turf/T as anything in block(bottom_left, top_right))
		turfs_to_generate += T

	if(!length(turfs_to_generate))
		log_world("ERROR: No turfs available for generation in [planet_name]")
		return null

	log_world("Generating planet [planet_name] with [length(turfs_to_generate)] turfs...")

	// Generate the terrain using parent implementation
	generate_terrain(turfs_to_generate, null)

	// Populate with flora/fauna using parent implementation
	populate_terrain(turfs_to_generate, null)

	log_world("Planet [planet_name] generation complete with [length(docking_ports)] docking ports!")

	return list(vlevel, docking_ports)

/**
 * Creates docking ports for ship landing
 * Creates multiple adjustable docking ports at different locations on the planet
 *
 * Arguments:
 * * vlevel - The virtual level to create docking ports in
 * * planet_name - Name of the planet for labeling docking ports
 *
 * Returns: A list of created docking ports
 */
/datum/map_generator/planet_generator/proc/create_docking_ports(datum/virtual_level/vlevel, planet_name)
	var/list/docking_ports = list()

	// Landing zone dimensions - using adjust_dock_for_landing to auto-fit shuttles
	// These define the maximum bounds that docks can adjust within
	#define LANDING_ZONE_WIDTH 30   // Max width for landing zones
	#define LANDING_ZONE_HEIGHT 30  // Max height for landing zones
	#define LANDING_ZONE_PADDING 5
	#define SHUTTLE_BOTTOM_CLEARANCE 5  // Tiles from bottom of map to bottom of shuttle

	// Calculate positions for 4 docking ports spread across the planet
	// Position them within the unreserved area, accounting for clearance

	var/unreserved_start_x = vlevel.low_x + vlevel.reserved_margin
	var/unreserved_start_y = vlevel.low_y + vlevel.reserved_margin

	// Primary dock - positioned so shuttle bottom is SHUTTLE_BOTTOM_CLEARANCE tiles from map edge
	// With dir=NORTH and dheight=0, the docking port IS the shuttle bottom
	var/turf/primary_turf = locate(
		unreserved_start_x + LANDING_ZONE_PADDING,
		unreserved_start_y + SHUTTLE_BOTTOM_CLEARANCE,
		vlevel.z_value
	)

	var/obj/docking_port/stationary/primary_dock = new(primary_turf)
	primary_dock.dir = NORTH
	primary_dock.name = "[planet_name] Landing Zone #1"
	primary_dock.height = LANDING_ZONE_HEIGHT
	primary_dock.width = LANDING_ZONE_WIDTH
	primary_dock.dheight = 0
	primary_dock.dwidth = 0
	primary_dock.adjust_dock_for_landing = TRUE  // Auto-adjust to fit incoming shuttles
	docking_ports += primary_dock

	// Secondary dock - offset to the right
	var/turf/secondary_turf = locate(
		primary_turf.x + LANDING_ZONE_WIDTH + LANDING_ZONE_PADDING,
		primary_turf.y,
		vlevel.z_value
	)

	var/obj/docking_port/stationary/secondary_dock = new(secondary_turf)
	secondary_dock.dir = NORTH
	secondary_dock.name = "[planet_name] Landing Zone #2"
	secondary_dock.height = LANDING_ZONE_HEIGHT
	secondary_dock.width = LANDING_ZONE_WIDTH
	secondary_dock.dheight = 0
	secondary_dock.dwidth = 0
	secondary_dock.adjust_dock_for_landing = TRUE  // Auto-adjust to fit incoming shuttles
	docking_ports += secondary_dock

	// For planets 100x100 or smaller, only create 2 landing zones
	// For larger planets, create 4 landing zones
	if(vlevel.x_distance >= 150)
		// Tertiary dock - offset upward from primary
		var/turf/tertiary_turf = locate(
			primary_turf.x,
			primary_turf.y + LANDING_ZONE_HEIGHT + LANDING_ZONE_PADDING,
			vlevel.z_value
		)

		var/obj/docking_port/stationary/tertiary_dock = new(tertiary_turf)
		tertiary_dock.dir = NORTH
		tertiary_dock.name = "[planet_name] Landing Zone #3"
		tertiary_dock.height = LANDING_ZONE_HEIGHT
		tertiary_dock.width = LANDING_ZONE_WIDTH
		tertiary_dock.dheight = 0
		tertiary_dock.dwidth = 0
		tertiary_dock.adjust_dock_for_landing = TRUE  // Auto-adjust to fit incoming shuttles
		docking_ports += tertiary_dock

		// Quaternary dock - offset upward from secondary
		var/turf/quaternary_turf = locate(
			secondary_turf.x,
			secondary_turf.y + LANDING_ZONE_HEIGHT + LANDING_ZONE_PADDING,
			vlevel.z_value
		)

		var/obj/docking_port/stationary/quaternary_dock = new(quaternary_turf)
		quaternary_dock.dir = NORTH
		quaternary_dock.name = "[planet_name] Landing Zone #4"
		quaternary_dock.height = LANDING_ZONE_HEIGHT
		quaternary_dock.width = LANDING_ZONE_WIDTH
		quaternary_dock.dheight = 0
		quaternary_dock.dwidth = 0
		quaternary_dock.adjust_dock_for_landing = TRUE  // Auto-adjust to fit incoming shuttles
		docking_ports += quaternary_dock

	#undef LANDING_ZONE_WIDTH
	#undef LANDING_ZONE_HEIGHT
	#undef LANDING_ZONE_PADDING
	#undef SHUTTLE_BOTTOM_CLEARANCE

	return docking_ports

/**
 * Override generate_terrain from parent class
 * Generate turfs for the planet
 */
/datum/map_generator/planet_generator/generate_terrain(list/turfs, area/generate_in)
	if(!planet_biome)
		log_world("ERROR: No biome set for planet generator!")
		return

	var/list/turf/new_turfs = planet_biome.generate_turfs_for_terrain(turfs)

	// Change the area for all generated turfs
	var/area/planet_area = GLOB.areas_by_type[area_type] || new area_type
	for(var/turf/new_turf as anything in new_turfs)
		planet_area.contents += new_turf
		CHECK_TICK

/**
 * Override populate_terrain from parent class
 * Populate turfs with flora, fauna, and features
 */
/datum/map_generator/planet_generator/populate_terrain(list/turfs, area/generate_in)
	if(!planet_biome)
		return

	var/flora_allowed = TRUE
	var/features_allowed = TRUE
	var/fauna_allowed = TRUE

	for(var/turf/target_turf as anything in turfs)
		planet_biome.populate_turf(target_turf, flora_allowed, features_allowed, fauna_allowed)
		CHECK_TICK

// ============================================================================
// SPECIFIC PLANET TYPES
// ============================================================================

/**
 * Rocky Planet Generator
 * Creates a simple rocky/asteroid-like planet
 */
/datum/map_generator/planet_generator/rocky
	biome_type = /datum/biome/asteroid
	area_type = /area/planet/rocky

/**
 * Simple Asteroid Biome for rocky planets
 */
/datum/biome/asteroid
	turf_type = /turf/open/misc/asteroid
	flora_density = 5
	fauna_density = 0  // Disabled for now to prevent runtime errors
	feature_density = 1

	flora_types = list(
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 1,
	)

	// Explicitly set fauna_types to empty list to prevent inheritance
	fauna_types = list()
	feature_types = list()

// ============================================================================
// AREAS
// ============================================================================

/area/planet
	name = "Planet Surface"
	icon_state = "yellow"
	default_gravity = STANDARD_GRAVITY
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	// Make planet surfaces bright (like outside stations)
	static_lighting = TRUE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/planet/rocky
	name = "Rocky Planet Surface"
	icon_state = "dark"
	icon_state = "dark"
