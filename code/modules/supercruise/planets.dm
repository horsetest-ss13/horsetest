/datum/orbital_object/planet/rocky
	supercruise_color = "#8B7355"  // Brown
	description = "A barren rocky world."
	map_generator_type = /datum/map_generator/planet_generator/rocky
	planet_size = 100
	baseturf_type = /turf/open/misc/asteroid

/datum/orbital_object/planet/ice
	supercruise_color = "#B0E0E6"  // Light blue
	description = "A frozen ice world."
	map_generator_type = /datum/map_generator/planet_generator/rocky // Use rocky for now
	planet_size = 100
	baseturf_type = /turf/open/space/basic

/datum/orbital_object/planet/gas
	supercruise_color = "#FFA07A"  // Light orange
	description = "A massive gas giant."
	landable = FALSE
	map_generator_type = null // No landing

/datum/orbital_object/planet/lava
	supercruise_color = "#FF4500"  // Red-orange
	description = "A volcanic hellscape."
	map_generator_type = /datum/map_generator/planet_generator/rocky
	planet_size = 100
	baseturf_type = /turf/open/lava/smooth

/datum/orbital_object/planet/oceanic
	supercruise_color = "#4682B4"  // Steel blue
	description = "A world covered in vast oceans."
	map_generator_type = /datum/map_generator/planet_generator/rocky
	planet_size = 100
	baseturf_type = /turf/open/space/basic

/datum/orbital_object/planet/desert
	supercruise_color = "#DEB887"  // Burlywood
	description = "An arid desert planet."
	map_generator_type = /datum/map_generator/planet_generator/rocky
	planet_size = 100
	baseturf_type = /turf/open/misc/asteroid

/datum/orbital_object/planet/forest
	supercruise_color = "#228B22"  // Forest green
	description = "A lush green world."
	map_generator_type = /datum/map_generator/planet_generator/rocky
	planet_size = 100
	baseturf_type = /turf/open/misc/grass
