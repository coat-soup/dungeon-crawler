extends Node3D
class_name LevelRoomPrefab

@export var entrances : Array[LevelRoomPrefabEntrance]
@export var num_enemies : int = 2



func toggle_entrance(id: int, state: bool):
	if state:
		if entrances[id].closed: get_node(entrances[id].closed).queue_free()
	else:
		if entrances[id].open: get_node(entrances[id].open).queue_free()


func get_entrance(offset : Vector3i) -> int:
	for i in range(len(entrances)):
		if offset == entrances[i].position: return i
	
	return -1


func get_entrance_to_room(room : LevelRoom, this_pos: Vector3i) -> int:
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			for z in range(room.position.z, room.position.z + room.size.z):
				var e = get_entrance(Vector3i(x,y,z) - this_pos)
				if e != -1: return e
	
	return -1


func get_random_spawn_point() -> Vector3:
	if not get_node("SpawnPoints") or $SpawnPoints.get_child_count() == 0: return global_position
	return $SpawnPoints.get_child(randi() % $SpawnPoints.get_child_count()).global_position
