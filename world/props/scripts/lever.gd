extends StateToggleInteractable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	interacted.connect(on_interacted)
	animation_player.play("lever_idle_down" if state else "lever_idle_up")


func on_interacted(_source : Node):
	animation_player.play("lever_down" if state else "lever_up")
	AudioManager.spawn_sound_at_point(preload("res://sfx/lever_switch.mp3"), global_position)
