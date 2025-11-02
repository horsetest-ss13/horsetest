/**
 * LAVALAND BIOMES
 * Based on PentestSS13's lavaland biome definitions
 * Used by lava planet generator
 */

// ========================================
// SURFACE BIOMES
// ========================================

/// Base lavaland biome - rocky basalt surface
/datum/biome/lavaland
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt/lava_land_surface = 1,
	)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/ash/fireblossom = 1,
		/obj/structure/flora/ash/seraka = 5,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/flora/rock/pile = 20,
		/obj/structure/geyser/random = 4,
		/obj/structure/flora/rock/pile = 14,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath = 50,
		/mob/living/basic/mining/watcher = 40,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 10,
		/mob/living/basic/mining/lobstrosity = 1,
	)

/// Lavaland forest - dead trees and dense grass
/datum/biome/lavaland/forest
	open_turf_types = list(/turf/open/misc/asteroid/basalt = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead = 10,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 20,
		/obj/structure/flora/ash/fireblossom = 4,
	)
	flora_spawn_chance = 80

/// Lavaland rocky forest - forest with more rocks
/datum/biome/lavaland/forest/rocky
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/rock/pile = 4,
		/obj/structure/flora/tree/dead = 10,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 20,
		/obj/structure/flora/ash/fireblossom = 4,
	)
	flora_spawn_chance = 75

/// Lavaland plains - grassy areas
/datum/biome/lavaland/plains
	open_turf_types = list(
		/turf/open/misc/dirt = 30
	)
	flora_spawn_list = list(
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 1,
	)
	flora_spawn_chance = 15

/// Lavaland dense plains - heavily vegetated
/datum/biome/lavaland/plains/dense
	flora_spawn_chance = 85
	open_turf_types = list(
		/turf/open/misc/dirt = 50
	)
	feature_spawn_chance = 5
	feature_spawn_list = list(
		/obj/structure/flora/tree/dead = 50,
		/obj/structure/flora/tree/dead = 45,
	)

/// Lavaland mixed dense plains - grass and moss mix
/datum/biome/lavaland/plains/dense/mixed
	flora_spawn_chance = 50
	open_turf_types = list(
		/turf/open/misc/dirt = 50,
		/turf/open/misc/dirt = 45,
		/turf/open/floor/grass = 1
	)

/// Lavaland outback - sparse vegetation
/datum/biome/lavaland/outback
	open_turf_types = list(
		/turf/open/misc/dirt = 20
	)
	flora_spawn_list = list(
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/tree/dead = 3,
		/obj/structure/flora/rock/pile = 2,
		/obj/structure/flora/ash/cacti = 1,
	)
	flora_spawn_chance = 2

/// Lavaland lush - dense vegetation with crimson grass
/datum/biome/lavaland/lush
	open_turf_types = list(
		/turf/open/misc/dirt = 20,
		/turf/open/misc/asteroid/basalt/lava_land_surface = 1
	)
	flora_spawn_list = list(
		/obj/structure/flora/bush,
		/obj/structure/flora/tree/dead = 1,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush = 3
	)
	flora_spawn_chance = 30

/// Lavaland lava - active lava flows
/datum/biome/lavaland/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/rock/pile = 1
	)
	flora_spawn_chance = 2
	feature_spawn_chance = 0

/// Lavaland near-lava - obsidian areas near lava
/datum/biome/lavaland/nearlava
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt = 1,
	)
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/rock/pile = 1
	)
	flora_spawn_chance = 2

// ========================================
// CAVE BIOMES
// ========================================

/// Base lavaland cave biome
/datum/biome/cave/lavaland
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt/lava_land_surface = 1
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/volcanic = 1
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath = 50,
		/mob/living/basic/mining/watcher = 40,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 10,
	)
	flora_spawn_chance = 2
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 4,
		/obj/structure/flora/rock/pile = 4,
		/obj/structure/flora/bush = 10,
		/obj/structure/flora/bush = 5,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
	)
	feature_spawn_chance = 1
	feature_spawn_list = list(
	)

/// Lavaland cave - obsidian floor
/datum/biome/cave/lavaland/obsidian
	open_turf_types = list(
		/turf/open/misc/asteroid/basalt = 1
	)

/// Lavaland cave - rocky purple floor
/datum/biome/cave/lavaland/rocky
	open_turf_types = list(/turf/open/misc/asteroid/basalt = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 6,
		/obj/structure/flora/rock/pile = 6,
	)
	flora_spawn_chance = 5

/// Lavaland cave - mossy underground
/datum/biome/cave/lavaland/mossy
	open_turf_types = list(/turf/open/floor/grass = 1)
	flora_spawn_chance = 80
	flora_spawn_list = list(
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 10,
		/obj/structure/flora/bush = 5,
		/obj/structure/flora/ash/leaf_shroom = 3,
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/stem_shroom = 3,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
	)

/// Lavaland cave - underground lava
/datum/biome/cave/lavaland/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	feature_spawn_chance = 1
	feature_spawn_list = list(/obj/structure/flora/rock/pile = 1)
