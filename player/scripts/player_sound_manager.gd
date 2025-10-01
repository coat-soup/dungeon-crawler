extends Node

@export var movement : PlayerMovement
@export var skeleton_controller : PlayerSkeletonController
@export var weapon_manager : WeaponManager

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var impact_audio: AudioStreamPlayer3D = $ImpactAudio

var can_footstep : bool = false
var landing


func _ready() -> void:
	movement.bob_bottom.connect(_on_player_bob_bottom)
	movement.bob_top.connect(_on_player_bob_top)
	movement.jump_land.connect(_on_player_jump_land)
	skeleton_controller.damage_window_toggled.connect(on_damage_window_toggled)
	weapon_manager.weapon_bounced.connect(on_weapon_bounced)


func _on_player_bob_bottom() -> void:
	if can_footstep:
		footstep_audio.play()
		can_footstep = false


func _on_player_bob_top() -> void:
	can_footstep = true


func _on_player_jump_land() -> void:
	impact_audio.pitch_scale = randf_range(.8, 1.2)
	impact_audio.play()


func on_damage_window_toggled(value : bool):
	if value:
		AudioManager.spawn_sound_at_point(preload("res://sfx/sword_woosh.mp3"), movement.camera.global_position)


func on_weapon_bounced():
	AudioManager.spawn_sound_at_point(preload("res://sfx/sword_bounce.wav"), movement.camera.global_position)
