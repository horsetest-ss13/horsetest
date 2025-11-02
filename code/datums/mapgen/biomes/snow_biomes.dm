/**
 * SNOW/ICE BIOMES
 * Based on PentestSS13's snow/ice biome definitions
 * Used by ice planet generator
 */

// ========================================
// SURFACE BIOMES
// ========================================

/// Base snow biome - snowy plains
/datum/biome/snow
	open_turf_types = list(
		/turf/open/misc/asteroid/snow = 25
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 4,
		/obj/structure/flora/rock/icy = 4,
		/obj/structure/flora/rock/pile/icy = 4,
		/obj/structure/flora/grass/both = 12,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
	)
	flora_spawn_chance = 10
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/mining/ice_demon = 30,
		/mob/living/basic/mining/wolf = 25,
		/mob/living/basic/bear = 10,
		/mob/living/basic/mining/wolf = 5,
		/mob/living/basic/mining/wolf = 5,
		/mob/living/basic/bear = 10,
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
	)

/// Snow biome with lush vegetation
/datum/biome/snow/lush
	open_turf_types = list(
		/turf/open/misc/asteroid/snow = 25
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/tree/dead = 3,
	)
	flora_spawn_chance = 30

/// Thawed snow biome - melting ice with temperate plants
/datum/biome/snow/thawed
	open_turf_types = list(
		/turf/open/misc/asteroid/snow/ice = 1
	)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/rock/icy = 3,
		/obj/structure/flora/rock/pile/icy = 2,
	)

/// Snow forest - pine trees and grass
/datum/biome/snow/forest
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/tree/dead = 6,
		/obj/structure/flora/grass/both = 8,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/rock/icy = 3,
	)

/// Dense snow forest - heavy pine coverage
/datum/biome/snow/forest/dense
	flora_spawn_chance = 30
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 25,
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/tree/dead = 5,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
	)

/// Arctic biome - extreme cold with ice creatures
/datum/biome/arctic
	open_turf_types = list(
		/turf/open/misc/asteroid/snow = 1
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/statue/snow/snowman = 3,
		/obj/structure/statue/snow/snowlegion = 1,
	)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 10,
		/obj/structure/flora/rock/pile/icy = 10,
		/obj/structure/flora/grass/both = 5,
		/obj/structure/flora/bush = 20,
	)
	mob_spawn_chance = 1

/// Rocky arctic variant - more rocks, less vegetation
/datum/biome/arctic/rocky
	flora_spawn_chance = 10
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 15,
		/obj/structure/flora/rock/pile/icy = 15,
		/obj/structure/flora/bush = 10,
	)

/// Iceberg biome - massive ice formations
/datum/biome/iceberg
	open_turf_types = list(
		/turf/open/misc/asteroid/snow/ice = 7,
		/turf/closed/mineral/random/snow = 10
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/ice_demon = 30,
		/mob/living/basic/mining/wolf = 25,
		/mob/living/basic/bear = 10,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/basic/mining/wolf = 5,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
	)

/// Iceberg with frozen lake
/datum/biome/iceberg/lake
	open_turf_types = list(
		/turf/open/floor/plating/icemoon = 1
	)

/// Plasma ice biome - exotic frozen plasma
/datum/biome/plasma
	open_turf_types = list(
		/turf/open/lava/plasma/ice_moon = 5,
		/turf/open/misc/asteroid/snow/ice = 1
	)

// ========================================
// CAVE BIOMES
// ========================================

/// Snow cave - icy underground chambers
/datum/biome/cave/snow
	open_turf_types = list(
		/turf/open/misc/asteroid/snow/ice = 1
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/snow = 1
	)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/rock/pile/icy = 5,
		/obj/structure/flora/rock/icy = 5,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 10,
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/ice_demon = 30,
		/mob/living/basic/mining/wolf = 25,
		/mob/living/basic/bear = 10,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/basic/bear = 10,
	)
	feature_spawn_chance = 1
	feature_spawn_list = list(
	)

/// Thawed snow cave - cracked ice floors
/datum/biome/cave/snow/thawed
	open_turf_types = list(
		/turf/open/misc/asteroid/snow/ice = 1
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/snow = 1
	)

/// Ice cave - pure ice floors
/datum/biome/cave/snow/ice
	open_turf_types = list(
		/turf/open/misc/asteroid/snow/ice = 20,
		/turf/open/floor/plating/icemoon = 3
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/snow = 1
	)

/// Volcanic cave under ice - hot basalt under frozen surface
/datum/biome/cave/volcanic
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt = 1
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/snow = 1
		)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/ice_demon = 30,
		/mob/living/basic/mining/wolf = 25,
		/mob/living/basic/bear = 10,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/basic/bear = 10,
	)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
	)
	feature_spawn_chance = 0.2

/// Volcanic cave with lava pockets
/datum/biome/cave/volcanic/lava
	open_turf_types = list(
		/turf/open/lava/smooth = 10,
		/turf/open/misc/asteroid/snow/ice = 1
	)

/// Volcanic cave with full lava
/datum/biome/cave/volcanic/lava/total
	open_turf_types = list(
		/turf/open/lava/smooth = 1
	)

/// Volcanic cave with plasma lava
/datum/biome/cave/volcanic/lava/plasma
	open_turf_types = list(
		/turf/open/lava/plasma = 7,
		/turf/open/misc/asteroid/snow/ice = 1
	)
