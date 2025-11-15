extends Node
class_name LevelEnemySpawner

@export var enemies : Array[PackedScene]
@onready var generator: LevelGenerator = $".."


func _ready() -> void:
	generator.finished.connect(spawn_enemies)


func spawn_enemies():
	if not Global.level_generator:
		push_warning("Cannot spawn enemies in generation. Network manager missing.")
		return
	for i in range(len(generator.spawned_rooms)):
		if generator.graph_generator.spawned_nodes[i].name == "combat":
			for j in range(generator.spawned_prefabs[i].num_enemies):
				spawn_enemy_at_point(enemies.pick_random(), generator.spawned_prefabs[i].get_random_spawn_point())


func spawn_enemy_at_point(prefab : PackedScene, position : Vector3):
	var e = prefab.instantiate()
	e.name = str(multiplayer.get_unique_id())
	Global.network_manager.add_child(e, true)
	e.global_position = position + Util.random_point_in_circle_3d(1.0)
