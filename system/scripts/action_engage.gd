extends Action
class_name ActionEngage

var ai_movement : AIMovementManager
var ai_action_controller : AIActionController
@export var distance : float = 2.0
@export var move_speed = 2.0

var flank_tick = 30
var flank_rotation = 0


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	ai_movement = character.movement_manager as AIMovementManager
	ai_action_controller = character.get_node("AIActionController") as AIActionController
	ai_movement.override_desired_speed = move_speed
	ai_movement.process_ticked.connect(tick)


func tick():
	flank_tick -= 1
	if flank_tick <= 0:
		flank_tick = 30
		flank_rotation = deg_to_rad(randf_range(-30, 30)) if randf() < 0.6 else 0
	
	if len(ai_action_controller.targets) > 0 and character.weapon_manager.attack_state == 0:
		
		ai_movement.set_nav_destination(ai_action_controller.targets[0].global_position +
			(character.global_position - ai_action_controller.targets[0].global_position).normalized().rotated(Vector3.UP, flank_rotation) * distance)
		
		ai_movement.body.global_rotation.y = -(character.global_position - ai_action_controller.targets[0].global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)


func end_action():
	super.end_action()
	ai_movement.override_desired_speed = -1


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.character.weapon_manager.attack_state != WeaponManager.AttackState.IDLE: return 0.0 
	for t in ai.targets:
		return (ai.desire_to_attack)
	
	return 0.0
