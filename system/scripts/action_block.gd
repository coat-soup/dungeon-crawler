extends Action
class_name ActionBlock


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	
	var ai = character.get_node_or_null("AIActionController") as AIActionController
	if ai and ai.is_multiplayer_authority():
		var max_react_time : float = 0.8 * (1 - ai.get_block_reaction_bonus(ai.targets[0].weapon_manager.attack_state))
		var min_react_time : float = 0.4 * max_react_time * lerp(1.0, 0.5, ai.profficiency)
		await character.get_tree().create_timer(randf_range(min_react_time, max_react_time)).timeout
	
	character.weapon_manager.blocking = true


func end_action():
	super.end_action()
	character.weapon_manager.blocking = false


func get_ai_action_weight(ai : AIActionController) -> float:
	for t in ai.targets:
		if t.weapon_manager.attack_state != 0: return 2.0 * (ai.character.stamina.cur_stamina/ai.character.stamina.max_stamina)
	
	return 0.0
