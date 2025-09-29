extends CharacterBody3D
class_name Player

@onready var movement: PlayerMovement = $Movement
@export var camera: Camera3D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if is_multiplayer_authority():
		camera.current = true
