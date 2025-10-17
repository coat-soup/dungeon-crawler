extends Control
class_name OptionsMenuManager

@onready var ui: UIManager = $".."

@onready var return_button: Button = $ButtonHolder/ReturnButton
@onready var leave_button: Button = $ButtonHolder/LeaveButton
@onready var quit_button: Button = $ButtonHolder/QuitButton
@onready var settings_button: Button = $ButtonHolder/SettingsButton
@onready var game_info_label: RichTextLabel = $GameInfoLabel
@onready var settings_panel: SettingsPanelManager = $SettingsPanel
@onready var button_holder: VBoxContainer = $ButtonHolder


func _ready() -> void:
	return_button.pressed.connect(on_return_button_pressed)
	leave_button.pressed.connect(on_leave_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	
	visibility_changed.connect(on_visibility_changed)
	
	game_info_label.text = "%s - version %s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version")]


func on_return_button_pressed():
	ui.toggle_options_menu(false)


func on_leave_button_pressed():
	Global.network_manager.quit_lobby()


func on_quit_button_pressed():
	get_tree().quit()


func on_settings_button_pressed():
	toggle_settings_menu(true)


func on_visibility_changed():
	if not visible: toggle_settings_menu(false)


func toggle_settings_menu(value : bool):
	settings_panel.visible = value
	button_holder.visible = !value
