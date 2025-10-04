extends CharacterMovementManager
class_name AIMovementManager


@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"

var process_tick_speed = 5.0


func _ready() -> void:
	process_tick()


func process_tick():
	input_direction = ((body.global_position - nav_agent.get_next_path_position()) * Vector3(1.0, 0.0, 1.0)).normalized()
	await body.get_tree().create_timer(1.0/process_tick_speed).timeout
	process_tick()


func set_nav_destination(position : Vector3):
	nav_agent.target_position = position
