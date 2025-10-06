extends Action
class_name ActionSprint


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.movement_manager.sprinting = true


func end_action():
	super.end_action()
	character.movement_manager.sprinting = false


func get_ai_action_weight(ai : AIActionController) -> float:
	return 1.0 if (ai.character.movement_manager as AIMovementManager).nav_agent.distance_to_target() > 10.0 else 0.0
