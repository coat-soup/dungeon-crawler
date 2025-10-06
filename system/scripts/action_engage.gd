extends Action
class_name ActionEngage

var ai_movement : AIMovementManager
var ai_action_controller : AIActionController
@export var distance : float = 2.0
@export var move_speed = 2.0


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	ai_movement = character.movement_manager as AIMovementManager
	ai_action_controller = character.get_node("AIActionController") as AIActionController
	ai_movement.override_desired_speed = move_speed
	ai_movement.process_ticked.connect(tick)


func tick():
	if len(ai_action_controller.targets) > 0 and character.weapon_manager.attack_state == 0:
		ai_movement.set_nav_destination(ai_action_controller.targets[0].global_position + (character.global_position - ai_action_controller.targets[0].global_position).normalized() * distance)
		ai_movement.body.global_rotation.y = -(character.global_position - ai_action_controller.targets[0].global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)


func end_action():
	super.end_action()
	ai_movement.override_desired_speed = -1


func get_ai_action_weight(ai : AIActionController) -> float:
	for t in ai.targets:
		return ((ai.desire_to_attack) + (ai.character.stamina.get_ratio())) / 2
	
	return 0.0
