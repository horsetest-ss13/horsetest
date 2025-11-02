/**
 * BEACH/OCEAN BIOMES
 * Based on PentestSS13's beach/ocean biome definitions
 * Used by beach planet generator
 */

// ========================================
// SURFACE BIOMES
// ========================================

/// Base beach biome - sandy shores
/datum/biome/beach
	open_turf_types = list(/turf/open/misc/beach/sand = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1,
		/obj/structure/flora/rock = 2,
		/obj/structure/flora/rock/pile = 3,
		/obj/structure/flora/bush,
		/obj/structure/flora/bush,
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/carp = 10,
		/mob/living/basic/carp = 5,
	)

/// Dense beach - heavier sand coverage
/datum/biome/beach/dense
	open_turf_types = list(/turf/open/misc/beach/sand = 1)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/rock = 2,
		/obj/structure/flora/rock/pile = 2,
	)

/// Beach jungle - tropical coastal vegetation
/datum/biome/beach_jungle
	flora_spawn_chance = 70
	open_turf_types = list(/turf/open/floor/grass = 1, /turf/open/misc/dirt = 9)
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 10,
		/obj/structure/flora/grass/jungle/b = 10,
		/obj/structure/flora/tree/jungle = 20,
		/obj/structure/flora/rock/pile/jungle = 5,
		/obj/structure/flora/bush/jungle = 50,
		/obj/structure/flora/bush/jungle = 40,
		/obj/structure/flora/bush/jungle = 35,
		/obj/structure/flora/bush/jungle = 10,
		/obj/structure/spacevine = 20,
		/obj/structure/flora/bush = 40,
	)

/// Grass biome - grassy coastal areas
/datum/biome/grass
	open_turf_types = list(/turf/open/floor/grass = 1)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 45,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 30,
		/obj/structure/flora/bush = 10,
		/obj/structure/flora/tree/palm = 5,
	)

/// Dense grass - heavy grass coverage
/datum/biome/grass/dense
	flora_spawn_chance = 70
	flora_spawn_list = list(
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 45,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 30,
		/obj/structure/flora/bush = 10,
		/obj/structure/flora/tree/palm = 10,
	)

/// Ocean biome - shallow water
/datum/biome/ocean
	open_turf_types = list(/turf/open/water/jungle = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/carp = 10,
		/mob/living/basic/carp = 5,
	)

/// Deep ocean - deep water areas
/datum/biome/ocean/deep
	open_turf_types = list(/turf/open/water/jungle = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 1.4
	mob_spawn_list = list(
		/mob/living/basic/carp = 10,
		/mob/living/simple_animal/hostile/megafauna/dragon = 2,
	)

// ========================================
// CAVE BIOMES
// ========================================

/// Beach cave - sandy underground chambers
/datum/biome/cave/beach
	open_turf_types = list(/turf/open/misc/beach/sand = 1)
	closed_turf_types = list(/turf/closed/mineral/random/jungle = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/bush = 40,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/carp = 5,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
	)

/// Beach cove - coastal cave formations
/datum/biome/cave/beach/cove
	open_turf_types = list(/turf/open/misc/beach/sand = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 10,
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/tree/dead = 15,
		/obj/structure/flora/tree/dead = 10,
		/obj/structure/flora/bush = 40,
	)
	flora_spawn_chance = 20

/// Magical beach cave - enchanted underground
/datum/biome/cave/beach/magical
	open_turf_types = list(/turf/open/misc/dirt/jungle = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/bush = 50,
		/obj/structure/flora/bush = 45,
		/obj/structure/flora/bush = 40,
		/obj/structure/flora/bush = 35,
		/obj/structure/flora/bush = 30,
		/obj/structure/flora/bush = 10,
	)
