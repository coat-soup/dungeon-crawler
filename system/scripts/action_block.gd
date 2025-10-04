extends Action
class_name ActionBlock


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.blocking = true


func end_action():
	super.end_action()
	character.weapon_manager.blocking = false


func get_ai_action_weight(ai : AIActionController) -> float:
	for t in ai.targets:
		if t.weapon_manager.attack_state != 0: return 2.0
	
	return 0.0
