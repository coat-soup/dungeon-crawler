extends Node3D
class_name CharacterSoundManager

@export var skeleton_controller : CharacterSkeletonController
@export var weapon_manager : WeaponManager

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var impact_audio: AudioStreamPlayer3D = $ImpactAudio

var can_footstep : bool = false
var landing


func _ready() -> void:
	skeleton_controller.damage_window_toggled.connect(on_damage_window_toggled)
	weapon_manager.weapon_bounced.connect(on_weapon_bounced)
	weapon_manager.blocked_damage.connect(on_weapon_blocked_damage)
	weapon_manager.did_damage.connect(on_weapon_did_damage)


func on_damage_window_toggled(value : bool):
	if value:
		AudioManager.spawn_sound_at_point(preload("res://sfx/sword_woosh.mp3"), global_position)


func on_weapon_bounced():
	AudioManager.spawn_sound_at_point(preload("res://sfx/sword_bounce.wav"), global_position)


func on_weapon_blocked_damage():
	AudioManager.spawn_sound_at_point(preload("res://sfx/sword_block.wav"), global_position)


func on_weapon_did_damage():
	AudioManager.spawn_sound_at_point(preload("res://sfx/sword_slice.wav"), global_position)
