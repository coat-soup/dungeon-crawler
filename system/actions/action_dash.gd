extends Action
class_name ActionDash


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	
	character.movement_manager.dash_input()
	
	await character.get_tree().create_timer(character.movement_manager.dash_length).timeout
	trigger_end_action()


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.character.stamina.cur_stamina <= 0: return 0
	for t in ai.targets:
		if t.global_position.distance_to(ai.global_position) <= 2.0 and t.weapon_manager.attack_state not in [1,2,3,4]: return 1 - (ai.character.weapon_manager.block_durability / 100.0)
	
	return 0.0
