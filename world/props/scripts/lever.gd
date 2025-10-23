extends StateToggleInteractable
class_name LeverInteractable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var lever_model : Node3D = $Cylinder


func _ready() -> void:
	interacted.connect(on_interacted)
	if num_states > 1: lever_model.rotation.x = get_rot_from_state()


func on_interacted(_source : Node):
	if num_states == 1: animation_player.play("pull_return")
	AudioManager.spawn_sound_at_point(preload("res://sfx/lever_switch.mp3"), global_position)


func _process(delta: float) -> void:
	if num_states <= 1: return
	lever_model.rotation.x = move_toward(lever_model.rotation.x, get_rot_from_state(), delta * 5.0)


func get_rot_from_state():
	return deg_to_rad(-50 + (100.0 / (num_states - 1)) * state)
