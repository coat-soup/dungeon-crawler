extends Node3D
class_name LevelRoomPrefab

@export var entrances : Array[LevelRoomPrefabEntrance]


func toggle_entrance(id: int, state: bool):
	if state:
		get_node(entrances[id].closed).queue_free()
	else:
		get_node(entrances[id].open).queue_free()


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
