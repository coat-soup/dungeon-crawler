extends Node

signal settings_changed

var config_file : ConfigFile = ConfigFile.new()
const PATH = "user://settings.cfg"

func _ready() -> void:
	if !FileAccess.file_exists(PATH): reset_to_defaults()
	else: config_file.load(PATH)
	
	await get_tree().process_frame
	settings_changed.emit()


func update_setting(key, value):
	config_file.set_value("general", key, value)


func get_setting(key):
	return config_file.get_value("general", key)


func reset_to_defaults():
	print("RESETING SETTINGS TO DEFAULTS")
	config_file = ConfigFile.new()
	update_setting("look_sensetivity", 1.0)
	update_setting("master_volume", 1.0)
	save()


func save():
	print("SAVING FILE: ", config_file.save(PATH))
	settings_changed.emit()
