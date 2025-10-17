extends Node3D


func _ready() -> void:
	Settings.settings_changed.connect(update_from_settings)


@rpc("any_peer", "call_remote")
func spawn_sound_at_point(stream : AudioStream, position : Vector3, attach_to : Node = null, pitch_var : float = 0.1):
	var sound = AudioStreamPlayer3D.new()
	if not attach_to: add_child(sound)
	else: attach_to.add_child(sound)
	
	sound.stream = stream
	sound.pitch_scale = randf_range(1.0 - pitch_var, 1 + pitch_var)
	sound.global_position = position
	sound.play()
	sound.finished.connect(sound.queue_free)


func update_from_settings():
	AudioServer.set_bus_volume_db(0, linear_to_db(Settings.get_setting("master_volume")))
