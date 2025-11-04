extends Action
class_name ActionKeepDistance

var ai_movement : AIMovementManager
var ai_action_controller : AIActionController
@export var distance : float = 4.0
@export var move_speed = 3.0

var flank_tick = 10
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
		flank_tick = 10
		flank_rotation = deg_to_rad(randf_range(-15, 15)) if randf() > 0.5 else 0
	
	if not ai_action_controller.active_target: return
	var dir := character.global_position - ai_action_controller.active_target.global_position
	
	# lookat target
	ai_movement.body.global_rotation.y = -(character.global_position - ai_action_controller.active_target.global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)
	
	if character.weapon_manager.attack_state == 0:
		var t_dist = max(dir.length(), distance)
		var target_destination = ai_action_controller.active_target.global_position + dir.normalized().rotated(Vector3.UP, flank_rotation) * t_dist
		ai_movement.set_nav_destination(target_destination)


func end_action():
	super.end_action()
	ai_movement.override_desired_speed = -1


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.active_target and ai.active_target.global_position.distance_to(ai.global_position) <= distance:
			return 1 - (ai.desire_to_attack)
	
	return 0.0
