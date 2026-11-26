/// Gates child on the mob held in a blackboard key is knocked down.
/// Use "invert": true to gate on the target NOT being knocked down.

/datum/bt_node/decorator/is_target_knocked_down
	/// Blackboard key holding the mob to check.
	var/key = BB_CURRENT_TARGET

/datum/bt_node/decorator/is_target_knocked_down/check_condition(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[key]
	if(QDELETED(target) || !isliving(target))
		return FALSE
	return !!target.IsKnockdown(target)
