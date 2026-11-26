// Horse Jumps //

/// A barrier that can be jumped over by a rider on a sufficiently fast horse. (To be changed to strength later)
/obj/structure/barricade/horse_jump
	name = "crossrail" // the simplest of jumps
	desc = "A barrier designed to be jumped over on horseback. This one looks incredibly easy to clear."
	icon = 'modular_horsetest/modules/horse/icons/jumps.dmi'
	icon_state = "crossrail"
	max_integrity = 120
	proj_pass_rate = 60
	bar_material = 2 // WOOD
	var/min_strength_stat = 20
	var/jump_height = 10

/obj/structure/barricade/horse_jump/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_rotation)
	var/static/list/tool_behaviors = list(TOOL_WRENCH = list(SCREENTIP_CONTEXT_LMB = "Anchor/Unanchor"))
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	AddComponent(/datum/component/horse_jumpable, jump_height = jump_height, min_strength_stat = min_strength_stat)

/obj/structure/barricade/horse_jump/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("It's [EXAMINE_HINT("bolted")] to the ground.")
	else
		. += span_notice("It can be [EXAMINE_HINT("bolted")] to the ground.")

/obj/structure/barricade/horse_jump/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_notice("You begin to [anchored ? "unfasten the jump from":"fasten the jump to"] the floor..."))
	if(tool.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		set_anchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "fasten the jump to":"unfasten the jump from"] the floor."))
	return TRUE

/obj/structure/barricade/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/barricade/horse_jump/crossrail	// exists solely to make admin spawning easier

/obj/structure/barricade/horse_jump/vertical
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks fairly easy to clear."
	icon_state = "vertical_low"
	min_strength_stat = 30

/obj/structure/barricade/horse_jump/vertical/mid
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one doesn't look that difficult to clear."
	icon_state = "vertical_mid"
	min_strength_stat = 40
	jump_height = 14

/obj/structure/barricade/horse_jump/vertical/high
	name = "vertical jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks a little difficult to clear."
	icon_state = "vertical_high"
	min_strength_stat = 50
	jump_height = 18

/obj/structure/barricade/horse_jump/oxer
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks fairly difficult to clear."
	icon_state = "oxer_low"
	min_strength_stat = 60

/obj/structure/barricade/horse_jump/oxer/mid
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks very difficult to clear."
	icon_state = "oxer_mid"
	min_strength_stat = 70
	jump_height = 14

/obj/structure/barricade/horse_jump/oxer/high
	name = "oxer jump"
	desc = "A barrier designed to be jumped over on horseback. This one looks incredibly difficult to clear."
	icon_state = "oxer_high"
	min_strength_stat = 90
	jump_height = 18
