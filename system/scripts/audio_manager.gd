extends Node3D

@rpc("any_peer", "call_remote")
func spawn_sound_at_point(stream : AudioStream, position : Vector3):
	var sound = AudioStreamPlayer3D.new()
	add_child(sound)
	sound.stream = stream
	sound.pitch_scale = randf_range(0.9, 1.1)
	sound.play()
	sound.finished.connect(sound.queue_free)
