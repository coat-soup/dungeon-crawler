extends Node3D
class_name DebugEnemySpawner

@export var enemy : PackedScene
@export var enabled : bool = true

func _ready() -> void:
	if not enabled:
		queue_free()
		return
	
	Global.network_manager.host_started.connect(on_host_started)


func on_host_started():
	await get_tree().create_timer(1.0).timeout
	
	var e = enemy.instantiate()
	e.name = str(multiplayer.get_unique_id())
	Global.network_manager.add_child(e, true)
	e.global_transform = global_transform
	queue_free()
