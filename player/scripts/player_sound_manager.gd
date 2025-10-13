extends CharacterSoundManager

@export var movement : PlayerMovement


func _ready() -> void:
	super._ready()
	movement.bob_bottom.connect(_on_player_bob_bottom)
	movement.bob_top.connect(_on_player_bob_top)
	movement.jump_land.connect(_on_player_jump_land)
	


func _on_player_bob_bottom() -> void:
	if can_footstep:
		footstep_audio.play()
		can_footstep = false


func _on_player_bob_top() -> void:
	can_footstep = true


func _on_player_jump_land() -> void:
	impact_audio.pitch_scale = randf_range(.8, 1.2)
	impact_audio.play()
