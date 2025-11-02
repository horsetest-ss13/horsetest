/**
 * JUNGLE BIOMES
 * Based on PentestSS13's jungle biome definitions
 * Used by jungle planet generator
 */

// ========================================
// SURFACE BIOMES
// ========================================

/// Base jungle biome - dense vegetation
/datum/biome/jungle
	open_turf_types = list(/turf/open/misc/dirt/jungle = 1)
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 10,
		/obj/structure/flora/grass/jungle/b = 10,
		/obj/structure/flora/tree/jungle = 20,
		/obj/structure/flora/rock/pile/jungle = 5,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
		/obj/structure/flora/rock/pile/jungle/large = 3,
	)
	flora_spawn_chance = 75
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/basic/spider/giant = 40,
		/mob/living/basic/spider/giant/ambush = 40,
	)
	feature_spawn_chance = 0.05
	feature_spawn_list = list(
		/obj/structure/geyser/random = 1,
	)

/// Dense jungle - extremely heavy vegetation
/datum/biome/jungle/dense
	flora_spawn_chance = 85
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 15,
		/obj/structure/flora/grass/jungle/b = 15,
		/obj/structure/flora/tree/jungle = 30,
		/obj/structure/flora/tree/jungle/small = 20,
		/obj/structure/flora/rock/pile/jungle = 5,
		/obj/structure/flora/bush/jungle = 50,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/rock/pile/jungle/large = 3,
	)

/// Jungle water biome - rivers and ponds
/datum/biome/jungle/water
	open_turf_types = list(/turf/open/water/jungle = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile/jungle = 1,
	)

/// Mudlands - dark dirt with sparse flora
/datum/biome/mudlands
	open_turf_types = list(/turf/open/misc/dirt/jungle/dark = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 10,
		/obj/structure/flora/grass/jungle/b = 10,
		/obj/structure/flora/rock/pile/jungle = 5,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
		/obj/structure/flora/rock/pile/jungle/large = 3,
	)

// ========================================
// CAVE BIOMES
// ========================================

/// Jungle cave - dirt underground
/datum/biome/cave/jungle
	open_turf_types = list(/turf/open/misc/dirt/jungle = 1)
	closed_turf_types = list(/turf/closed/mineral/random/jungle = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 10,
		/obj/structure/flora/grass/jungle/b = 10,
		/obj/structure/flora/tree/jungle/small = 5,
		/obj/structure/flora/rock/pile/jungle = 5,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/spider/giant = 40,
		/mob/living/basic/spider/giant/ambush = 40,
	)

/// Dirt-heavy jungle cave
/datum/biome/cave/jungle/dirt
	open_turf_types = list(/turf/open/misc/dirt/jungle = 1)
	closed_turf_types = list(/turf/closed/mineral/random/jungle = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 15,
		/obj/structure/flora/grass/jungle/b = 15,
		/obj/structure/flora/rock/pile/jungle = 8,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
	)

/// Lush cave - grass floors with small trees
/datum/biome/cave/lush
	open_turf_types = list(/turf/open/misc/dirt/jungle = 1)
	closed_turf_types = list(/turf/closed/mineral/random/jungle = 1)
	flora_spawn_chance = 60
	flora_spawn_list = list(
		/obj/structure/flora/tree/jungle/small = 10,
		/obj/structure/flora/grass/jungle = 15,
		/obj/structure/flora/grass/jungle/b = 15,
		/obj/structure/flora/bush/jungle = 50,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
	)

/// Bright lush cave - heavily vegetated underground
/datum/biome/cave/lush/bright
	flora_spawn_chance = 60
	flora_spawn_list = list(
		/obj/structure/flora/tree/jungle/small = 15,
		/obj/structure/flora/grass/jungle = 20,
		/obj/structure/flora/grass/jungle/b = 20,
		/obj/structure/flora/bush/jungle = 50,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
		/obj/structure/flora/rock/pile/jungle/large = 3,
		/obj/structure/flora/bush = 40,
	)
