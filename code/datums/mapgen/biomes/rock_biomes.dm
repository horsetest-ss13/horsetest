/**
 * ROCK BIOMES
 * Based on PentestSS13's rock biome definitions
 * Used by rock planet generator
 */

// ========================================
// SURFACE BIOMES
// ========================================

/// Base rock biome - barren rocky terrain
/datum/biome/rock
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt = 1,
		/turf/open/misc/asteroid/basalt = 1,
		/turf/open/misc/asteroid/basalt = 1
	)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/pile = 20,
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/bush = 40,
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/spider = 20,
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/mining/goliath = 50,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/geyser/random = 2,
	)

/// Rock wetlands - damp rocky areas
/datum/biome/rock/wetlands
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt = 1,
		/turf/open/misc/asteroid/basalt = 1
	)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/bush = 40,
	)

/// Rock ice cap - frozen rocky areas
/datum/biome/rock/icecap
	open_turf_types = list(
		/turf/open/misc/asteroid/snow = 1,
		/turf/open/misc/asteroid/snow = 5)
	flora_spawn_chance = 1
	mob_spawn_chance = 2
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 5,
		/obj/structure/flora/rock/pile/icy = 5,
		/obj/structure/flora/rock = 2,
	)

// ========================================
// CAVE BIOMES
// ========================================

/// Rock cave - cracked rocky underground
/datum/biome/cave/rock
	closed_turf_types = list(/turf/closed/mineral/random/jungle = 1)
	open_turf_types = list(/turf/open/misc/asteroid/basalt = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/flora/bush = 40,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/spider = 20,
		/mob/living/basic/mining/watcher = 30,
	)

/// Wet rock cave - damp underground chambers
/datum/biome/cave/rock/wet
	open_turf_types = list(/turf/open/misc/asteroid/basalt = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 10,
	)
