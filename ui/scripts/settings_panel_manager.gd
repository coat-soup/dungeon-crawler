extends Control
class_name SettingsPanelManager


@onready var options_panel: OptionsMenuManager = $".."

@onready var save_button: Button = $SaveButton
@onready var cancel_button: Button = $CancelButton
@onready var reset_button: Button = $ResetButton

@onready var sensetivity_value_label: Label = $VBoxContainer/Sensetivity/SensetivityValueLabel
@onready var sensetivity_slider: HSlider = $VBoxContainer/Sensetivity/SensetivitySlider

@onready var volume_value_label: Label = $VBoxContainer/Volume/VolumeValueLabel
@onready var volume_slider: HSlider = $VBoxContainer/Volume/VolumeSlider


func _ready() -> void:
	save_button.pressed.connect(on_save_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	reset_button.pressed.connect(on_reset_pressed)
	
	sensetivity_slider.value_changed.connect(update_label_from_slider.bind(sensetivity_value_label))
	volume_slider.value_changed.connect(update_label_from_slider.bind(volume_value_label))
	
	load_ui_from_settings()


func on_save_pressed():
	save_settings_from_ui_values()
	options_panel.toggle_settings_menu(false)


func on_cancel_pressed():
	load_ui_from_settings()
	options_panel.toggle_settings_menu(false)


func on_reset_pressed():
	Settings.reset_to_defaults()
	load_ui_from_settings()
	options_panel.toggle_settings_menu(false)


func load_ui_from_settings():
	sensetivity_slider.value = Settings.get_setting("look_sensetivity")
	volume_slider.value = Settings.get_setting("master_volume")


func save_settings_from_ui_values():
	Settings.update_setting("look_sensetivity", sensetivity_slider.value)
	Settings.update_setting("master_volume", volume_slider.value)
	Settings.save()


func update_label_from_slider(value, label : Label):
	label.text = str(value)
