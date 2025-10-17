extends Control
class_name OptionsMenuManager

@onready var ui: UIManager = $".."

@onready var return_button: Button = $Background/ButtonHolder/ReturnButton
@onready var leave_button: Button = $Background/ButtonHolder/LeaveButton
@onready var quit_button: Button = $Background/ButtonHolder/QuitButton
@onready var settings_button: Button = $Background/ButtonHolder/SettingsButton
@onready var game_info_label: RichTextLabel = $Background/GameInfoLabel


func _ready() -> void:
	return_button.pressed.connect(on_return_button_pressed)
	leave_button.pressed.connect(on_leave_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	
	game_info_label.text = "%s - version %s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version")]


func on_return_button_pressed():
	ui.toggle_options_menu(false)


func on_leave_button_pressed():
	Global.network_manager.quit_lobby()


func on_quit_button_pressed():
	get_tree().quit()


func on_settings_button_pressed():
	print("SETTINGS NOT IMPLEMENTED")
