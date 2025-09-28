extends Node3D
class_name GameManager


func _ready() -> void:
	Global.game_manager = self


func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
