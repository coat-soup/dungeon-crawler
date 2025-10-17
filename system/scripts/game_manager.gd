extends Node3D
class_name GameManager


func _ready() -> void:
	Global.game_manager = self


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		print("game manager escaped")
		if true or ProjectSettings.get_setting("application/config/version")[-1] != "d": Global.ui.toggle_options_menu(!Global.ui.options_panel.visible)
		else: get_tree().quit()
