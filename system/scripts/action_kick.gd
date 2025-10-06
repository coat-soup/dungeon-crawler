extends Action
class_name ActionKick


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.kick()
	await character.get_tree().create_timer(0.6).timeout
	trigger_end_action()


func end_action():
	super.end_action()
	character.weapon_manager.attack_state = WeaponManager.AttackState.IDLE


func get_ai_action_weight(ai : AIActionController) -> float:
	for t in ai.targets:
		if t.weapon_manager.blocking: return ai.desire_to_attack - 0.5 + (0.5 * ai.character.stamina.get_ratio())
	
	return 0.0
