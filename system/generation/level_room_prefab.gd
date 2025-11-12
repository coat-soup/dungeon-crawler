extends Node3D
class_name LevelRoomPrefab

signal player_entered(Player)


@export var entrances : Array[LevelRoomPrefabEntrance]
@export var num_enemies : int = 2

var level_room : LevelRoom

var room_area : Area3D


func _ready() -> void:
	return
	room_area = Area3D.new()
	add_child(room_area)
	room_area.body_entered.connect(on_room_area_entered)
	var col = CollisionShape3D.new()
	room_area.add_child(col)
	col.shape = BoxShape3D.new()
	(col.shape as BoxShape3D).size = level_room.size * LevelGenerator.cell_size
	col.position.y += col.shape.size.y/2
	
	return
	var debug_box = CSGBox3D.new()
	col.add_child(debug_box)
	debug_box.size = col.shape.size


func on_room_area_entered(body : Node3D):
	var player = body as Player
	if player: player_entered.emit(player)


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
