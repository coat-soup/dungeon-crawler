extends CharacterMovementManager
class_name AIMovementManager

signal process_ticked

@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"

var process_tick_speed = 10.0

var override_desired_speed : float = -1

func _ready() -> void:
	process_tick()


func process_tick():
	process_ticked.emit()
	input_direction = ((nav_agent.get_next_path_position() - body.global_position) * Vector3(1.0, 0.0, 1.0)).normalized() if nav_agent.distance_to_target() > 0.3 else Vector3.ZERO
	await body.get_tree().create_timer(1.0/process_tick_speed).timeout
	process_tick()


func set_nav_destination(position : Vector3):
	nav_agent.target_position = position


func get_speed(slow_dist : float = 1.0) -> float:
	var _s = super.get_speed()
	if override_desired_speed > 0: _s = min(override_desired_speed, _s)
	var d = nav_agent.distance_to_target()
	if d > slow_dist: return _s
	return _s * (d/slow_dist)
