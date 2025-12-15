// Dungeon mob base type and all dungeon-specific enemies
// Uses sprites from modular_horsetest/modules/dungeons/icons/32x32.dmi

#define DUNGEON_MOB_ICON 'modular_horsetest/modules/dungeons/icons/32x32.dmi'
#define FACTION_DUNGEON "dungeon"

/// Base type for all dungeon mobs - they delete on death and are hostile
/mob/living/basic/dungeon_mob
	icon = DUNGEON_MOB_ICON
	mob_biotypes = MOB_ORGANIC
	faction = list(FACTION_DUNGEON)
	basic_mob_flags = DEL_ON_DEATH
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	mouse_opacity = MOUSE_OPACITY_ICON // Ensure mobs are clickable/targetable
	density = TRUE // Ensure mobs can be hit by projectiles
	/// What tier is this mob? Used for spawning based on difficulty
	var/tier = 1

/mob/living/basic/dungeon_mob/Initialize(mapload)
	. = ..()
	// Ensure damage coefficients are properly set
	if(!damage_coeff || !islist(damage_coeff))
		damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	// Make sure we're properly initialized for combat
	if(!icon_state && icon_living)
		icon_state = icon_living

// ==================== TIER 1 MOBS (Easy - Difficulty 1-2) ====================

/// Crawler - slow, tanky stone creature
/mob/living/basic/dungeon_mob/crawler
	name = "crawler"
	desc = "A hulking creature of living stone, it drags itself across the ground with powerful arms."
	icon_state = "crawler"
	icon_living = "crawler"
	health = 80
	maxHealth = 80
	melee_damage_lower = 10
	melee_damage_upper = 15
	speed = 3 // Slow
	obj_damage = 30
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	melee_attack_cooldown = 2 SECONDS
	speak_emote = list("rumbles")
	death_message = "crumbles into rubble."
	tier = 1
	// Crawler has natural stone armor - takes less brute/burn damage
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0, STAMINA = 0, OXY = 0)

/// When crawler attacks, chance to knockdown
/mob/living/basic/dungeon_mob/crawler/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/L = target
	if(prob(25))
		L.Knockdown(1 SECONDS)
		visible_message(span_danger("[src] slams [L] to the ground!"))

/// Sprite - weak but fast flying nuisance
/mob/living/basic/dungeon_mob/sprite
	name = "sprite"
	desc = "A tiny magical creature that flits about erratically. Annoying but not very dangerous."
	icon_state = "sprite"
	icon_living = "sprite"
	health = 20
	maxHealth = 20
	melee_damage_lower = 3
	melee_damage_upper = 5
	speed = 0 // Fast
	attack_verb_continuous = "zaps"
	attack_verb_simple = "zap"
	attack_sound = 'sound/effects/magic/blink.ogg'
	melee_attack_cooldown = 1 SECONDS
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	speak_emote = list("chimes")
	death_message = "pops in a flash of light!"
	tier = 1

/mob/living/basic/dungeon_mob/sprite/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	set_light(1, 1, "#88DDFF") // Sprites glow faintly

/// Sprites have a chance to blink away when hit - but AFTER taking damage
/mob/living/basic/dungeon_mob/sprite/apply_damage(damage, damagetype, def_zone, blocked, forced, spread_damage, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item, wound_clothing)
	// Call parent to actually apply the damage first
	. = ..(damage, damagetype, def_zone, blocked, forced, spread_damage, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item, wound_clothing)
	// Only try to blink away if we actually took damage, are alive, and get lucky
	if(. > 0 && prob(30) && stat == CONSCIOUS)
		var/list/turfs = list()
		for(var/turf/T in oview(3, src))
			if(!T.density)
				turfs += T
		if(length(turfs))
			var/turf/destination = pick(turfs)
			do_teleport(src, destination, no_effects = FALSE, channel = TELEPORT_CHANNEL_MAGIC)
			visible_message(span_warning("[src] blinks away!"))

/// Imp - fire-based, moderate threat
/mob/living/basic/dungeon_mob/imp
	name = "imp"
	desc = "A small demonic creature wreathed in flames. It cackles menacingly."
	icon_state = "imp"
	icon_living = "imp"
	health = 40
	maxHealth = 40
	melee_damage_lower = 8
	melee_damage_upper = 12
	speed = 1
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/items/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	melee_attack_cooldown = 1.5 SECONDS
	speak_emote = list("cackles", "hisses")
	death_message = "bursts into flames and vanishes!"
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0) // Fire resistant
	tier = 1

/mob/living/basic/dungeon_mob/imp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	// Imps glow with fire
	set_light(2, 1, "#FF6600")

/// Imps set their targets on fire
/mob/living/basic/dungeon_mob/imp/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/L = target
	if(prob(40))
		L.adjust_fire_stacks(1)
		L.ignite_mob()
		visible_message(span_danger("[src]'s claws ignite [L]!"))

// ==================== TIER 2 MOBS (Medium - Difficulty 3-4) ====================

/// Hellhound - fast, aggressive beast
/mob/living/basic/dungeon_mob/hellhound
	name = "hellhound"
	desc = "A vicious beast of fire and shadow. Its eyes burn with malevolent hunger."
	icon_state = "hellhound"
	icon_living = "hellhound"
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 22
	speed = 0 // Fast
	obj_damage = 40
	attack_verb_continuous = "savages"
	attack_verb_simple = "savage"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_attack_cooldown = 1.2 SECONDS
	speak_emote = list("growls", "snarls")
	death_message = "collapses in a heap of smoldering flesh."
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, STAMINA = 0, OXY = 0) // Very fire resistant
	tier = 2

/mob/living/basic/dungeon_mob/hellhound/Initialize(mapload)
	. = ..()
	set_light(3, 1, "#FF4400")

/// Hellhounds cause bleeding with their savage bites
/mob/living/basic/dungeon_mob/hellhound/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	// Cause bleeding on hit
	if(prob(35))
		var/obj/item/bodypart/BP = pick(C.bodyparts)
		if(BP)
			BP.adjustBleedStacks(3)
			visible_message(span_danger("[src] tears into [C], causing bleeding!"))

/// Watcher - floating eye, ranged attacker
/mob/living/basic/dungeon_mob/watcher
	name = "watcher"
	desc = "A floating orb of fire with a single burning eye. It watches. It judges."
	icon_state = "watcher"
	icon_living = "watcher"
	health = 60
	maxHealth = 60
	melee_damage_lower = 5
	melee_damage_upper = 8
	speed = 2
	attack_verb_continuous = "burns"
	attack_verb_simple = "burn"
	attack_sound = 'sound/effects/magic/blink.ogg'
	melee_attack_cooldown = 2 SECONDS
	speak_emote = list("hums ominously")
	death_message = "explodes in a shower of sparks!"
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_ranged
	tier = 2

/mob/living/basic/dungeon_mob/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	set_light(4, 2, "#FF8800")
	// Add ranged attack component
	AddComponent(/datum/component/ranged_attacks, \
		projectile_type = /obj/projectile/magic/arcane_barrage, \
		projectile_sound = 'sound/effects/magic/blink.ogg', \
		cooldown_time = 2 SECONDS)

/// Leycreature - magical horror with multiple eyes
/mob/living/basic/dungeon_mob/leycreature
	name = "leycreature"
	desc = "A horrible amalgamation of eyes and tendrils, pulsing with magical energy."
	icon_state = "leycreature"
	icon_living = "leycreature"
	health = 90
	maxHealth = 90
	melee_damage_lower = 12
	melee_damage_upper = 18
	speed = 2
	obj_damage = 25
	attack_verb_continuous = "lashes"
	attack_verb_simple = "lash"
	attack_sound = 'sound/items/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	melee_attack_cooldown = 1.5 SECONDS
	speak_emote = list("burbles", "gurgles")
	death_message = "dissolves into magical residue."
	tier = 2

/mob/living/basic/dungeon_mob/leycreature/Initialize(mapload)
	. = ..()
	set_light(2, 1, "#DD88FF")

/// Leycreatures disorient their targets with their many eyes
/mob/living/basic/dungeon_mob/leycreature/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/L = target
	if(prob(30))
		L.adjust_confusion(3 SECONDS)
		L.adjust_dizzy(2 SECONDS)
		to_chat(L, span_warning("The creature's many eyes disorient you!"))

// ==================== TIER 3 MOBS (Hard - Difficulty 5+) ====================

/// Warden - powerful demon, guards areas
/mob/living/basic/dungeon_mob/warden
	name = "warden"
	desc = "A towering demon with blazing wings. It exists only to destroy intruders."
	icon_state = "warden"
	icon_living = "warden"
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 35
	speed = 1
	obj_damage = 60
	attack_verb_continuous = "devastates"
	attack_verb_simple = "devastate"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	melee_attack_cooldown = 1.5 SECONDS
	speak_emote = list("roars")
	death_message = "crashes to the ground with a thunderous roar!"
	damage_coeff = list(BRUTE = 0.75, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	tier = 3

/mob/living/basic/dungeon_mob/warden/Initialize(mapload)
	. = ..()
	set_light(4, 2, "#FF2200")
	// Warden enrages at low health
	RegisterSignal(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(check_enrage))

/// Check if we should enrage when taking damage
/mob/living/basic/dungeon_mob/warden/proc/check_enrage()
	SIGNAL_HANDLER
	if(health < maxHealth * 0.3 && !HAS_TRAIT(src, TRAIT_HULK))
		enrage()

/// Become enraged - faster and stronger
/mob/living/basic/dungeon_mob/warden/proc/enrage()
	ADD_TRAIT(src, TRAIT_HULK, "dungeon_enrage")
	visible_message(span_boldwarning("[src] roars with fury as it enters a berserker rage!"))
	melee_damage_lower = 35
	melee_damage_upper = 50
	speed = 0
	set_light(6, 3, "#FF0000")
	playsound(src, 'sound/items/weapons/thudswoosh.ogg', 100, TRUE)

/// Sylph - dark caster, dangerous magic user
/mob/living/basic/dungeon_mob/sylph
	name = "sylph"
	desc = "A dark, robed figure that hovers silently. Its face is hidden in shadow."
	icon_state = "sylph"
	icon_living = "sylph"
	health = 120
	maxHealth = 120
	melee_damage_lower = 10
	melee_damage_upper = 15
	speed = 1
	attack_verb_continuous = "strikes"
	attack_verb_simple = "strike"
	attack_sound = 'sound/effects/magic/blink.ogg'
	melee_attack_cooldown = 2 SECONDS
	speak_emote = list("whispers darkly")
	death_message = "fades into shadow."
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_ranged
	tier = 3

/mob/living/basic/dungeon_mob/sylph/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	// Strong ranged attack
	AddComponent(/datum/component/ranged_attacks, \
		projectile_type = /obj/projectile/magic/arcane_barrage, \
		projectile_sound = 'sound/effects/magic/blink.ogg', \
		cooldown_time = 1.5 SECONDS)

/// Sylph attacks drain stamina
/mob/living/basic/dungeon_mob/sylph/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/L = target
	L.adjust_stamina_loss(15)
	to_chat(L, span_warning("You feel your energy being drained!"))

/// Glimmerwing - crystalline creature, reflects damage
/mob/living/basic/dungeon_mob/glimmerwing
	name = "glimmerwing"
	desc = "A beautiful creature of living crystal. Light refracts through its form in dazzling patterns."
	icon_state = "glimmerwing"
	icon_living = "glimmerwing"
	health = 150
	maxHealth = 150
	melee_damage_lower = 18
	melee_damage_upper = 25
	speed = 1
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	melee_attack_cooldown = 1.5 SECONDS
	speak_emote = list("chimes harmonically")
	death_message = "shatters into a thousand glittering pieces!"
	damage_coeff = list(BRUTE = 0.75, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0) // Resistant
	tier = 3

/mob/living/basic/dungeon_mob/glimmerwing/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	set_light(3, 2, "#88DDFF")

/// Glimmerwing reflects damage back to attackers
/mob/living/basic/dungeon_mob/glimmerwing/apply_damage(damage, damagetype, def_zone, blocked, forced, spread_damage, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item, wound_clothing)
	// Call parent to actually apply the damage first
	. = ..(damage, damagetype, def_zone, blocked, forced, spread_damage, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item, wound_clothing)
	// Only reflect if we actually took damage and are alive
	if(. <= 0 || stat == DEAD)
		return .
	// Reflect 25% of the ACTUAL damage dealt back to nearby attackers
	var/reflected_damage = . * 0.25
	for(var/mob/living/L in range(1, src))
		if(L == src)
			continue
		if(!(FACTION_DUNGEON in L.faction))
			L.apply_damage(reflected_damage, damagetype)
			to_chat(L, span_warning("Crystal shards cut into you!"))
			playsound(src, 'sound/effects/glass/glassbr2.ogg', 30, TRUE)

// ==================== BOSS MOBS ====================

/// Fiend - dungeon boss, extremely dangerous
/mob/living/basic/dungeon_mob/fiend
	name = "fiend"
	desc = "A massive demon lord radiating malevolent power. Its very presence fills you with dread."
	icon_state = "fiend"
	icon_living = "fiend"
	health = 500
	maxHealth = 500
	melee_damage_lower = 35
	melee_damage_upper = 50
	speed = 2
	obj_damage = 100
	attack_verb_continuous = "devastates"
	attack_verb_simple = "devastate"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	melee_attack_cooldown = 2 SECONDS
	speak_emote = list("bellows", "roars thunderously")
	death_message = "lets out a deafening roar as it collapses!"
	basic_mob_flags = NONE // Boss doesn't delete on death - drops loot
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	tier = 4

/mob/living/basic/dungeon_mob/fiend/Initialize(mapload)
	. = ..()
	set_light(5, 3, "#FF0000")
	// Ground slam ability every 8 seconds
	var/datum/action/cooldown/fiend_slam/slam = new(src)
	slam.Grant(src)
	// Summon minions every 20 seconds
	var/datum/action/cooldown/fiend_summon/summon = new(src)
	summon.Grant(src)
	START_PROCESSING(SSobj, src)

/mob/living/basic/dungeon_mob/fiend/process(seconds_per_tick)
	if(stat != CONSCIOUS)
		return
	// Auto-use abilities when off cooldown
	for(var/datum/action/cooldown/ability in actions)
		if(ability.IsAvailable())
			ability.Trigger()

/mob/living/basic/dungeon_mob/fiend/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/basic/dungeon_mob/fiend/death(gibbed)
	. = ..()
	// Drop boss loot
	var/turf/T = get_turf(src)
	if(T)
		new /obj/item/stack/sheet/mineral/diamond(T, rand(2, 5))
		new /obj/item/stack/spacecash/c1000(T)

/// Flower Stalker - creepy plant creature
/mob/living/basic/dungeon_mob/flower_stalker
	name = "flower stalker"
	desc = "A grotesque plant creature with a single unblinking eye at its center. It watches you hungrily."
	icon_state = "flower_stalker"
	icon_living = "flower_stalker"
	health = 70
	maxHealth = 70
	melee_damage_lower = 10
	melee_damage_upper = 16
	speed = 2
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_attack_cooldown = 1.5 SECONDS
	speak_emote = list("rustles menacingly")
	death_message = "wilts and collapses."
	tier = 2

// ===========================================
// BOSS ABILITIES
// ===========================================

/// Fiend ground slam - damages and knocks down everyone nearby
/datum/action/cooldown/fiend_slam
	name = "Ground Slam"
	cooldown_time = 8 SECONDS
	var/slam_range = 3
	var/slam_damage = 25

/datum/action/cooldown/fiend_slam/Trigger(mob/clicker, trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/dungeon_mob/fiend/F = owner
	if(!istype(F))
		return FALSE

	// Visual warning
	F.visible_message(span_danger("[F] raises its massive claws and slams the ground!"))
	playsound(F, 'sound/effects/gravhit.ogg', 100, TRUE)

	// Damage and knockdown everyone nearby
	for(var/mob/living/M in range(slam_range, F))
		if(M == F)
			continue
		if(M.faction_check_atom(F))
			continue // Don't hit allies
		M.apply_damage(slam_damage, BRUTE)
		var/atom/throw_target = get_edge_target_turf(M, get_dir(F, M))
		M.throw_at(throw_target, 2, 3)
		M.Knockdown(2 SECONDS)
		to_chat(M, span_danger("The shockwave sends you flying!"))

	StartCooldown()
	return TRUE

/// Fiend summon - summons imp minions
/datum/action/cooldown/fiend_summon
	name = "Summon Minions"
	cooldown_time = 20 SECONDS
	var/summon_count = 3

/datum/action/cooldown/fiend_summon/Trigger(mob/clicker, trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/dungeon_mob/fiend/F = owner
	if(!istype(F))
		return FALSE

	F.visible_message(span_danger("[F] bellows a command and minions materialize from the shadows!"))
	playsound(F, 'sound/effects/magic/magic_block_mind.ogg', 80, TRUE)

	// Summon imps around the fiend
	var/summoned = 0
	for(var/turf/T in RANGE_TURFS(2, F))
		if(summoned >= summon_count)
			break
		if(!T.is_blocked_turf())
			new /mob/living/basic/dungeon_mob/imp(T)
			summoned++

	StartCooldown()
	return TRUE

#undef DUNGEON_MOB_ICON
#undef FACTION_DUNGEON
