extends Control
class_name Minimap

@export var map_scale : float = 30.0

var rooms : Array[Control]
var hallways : Array[Control]

var visited_rooms : Array[int]
var visited_hallways : Array[int]

@onready var map_container: Control = $MapContainer
@onready var player_marker: TextureRect = $PlayerMarker


func _ready() -> void:
	await get_tree().process_frame
	Global.level_generator.finished.connect(build_map)


func _process(delta: float) -> void:
	if Global.local_player:
		map_container.position = size/2 - Vector2(Global.local_player.global_position.x, Global.local_player.global_position.z) * map_scale / Global.level_generator.cell_size
		player_marker.rotation = -Global.local_player.rotation.y


func build_map():
	for room in rooms: room.queue_free()
	for hallway in hallways: hallway.queue_free()
	rooms.clear()
	hallways.clear()
	visited_rooms.clear()
	visited_hallways.clear()
	
	for i in range(len(Global.level_generator.spawned_rooms)):
		var room = ColorRect.new()
		map_container.add_child(room)
		room.size = Vector2(Global.level_generator.spawned_rooms[i].size.x, Global.level_generator.spawned_rooms[i].size.z) * map_scale
		room.position = Vector2(Global.level_generator.spawned_rooms[i].position.x, Global.level_generator.spawned_rooms[i].position.z)* map_scale
		
		create_room_borders(room, Global.level_generator.spawned_rooms[i], Global.level_generator.spawned_prefabs[i])
		
		var text = Label.new()
		room.add_child(text)
		text.text = Global.level_generator.graph_generator.spawned_nodes[i].name
		text.position = Vector2.ONE * 5
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.modulate = Color.BLACK
		
		rooms.append(room)
	
	
	for i in range(len(Global.level_generator.hallways)):
		var hallway = ColorRect.new()
		map_container.add_child(hallway)
		hallway.size = Vector2(Global.level_generator.hallways[i].size.x, Global.level_generator.hallways[i].size.z) * map_scale
		hallway.position = Vector2(Global.level_generator.hallways[i].position.x, Global.level_generator.hallways[i].position.z) * map_scale
		hallway.color = Color.DARK_GRAY
		
		create_room_borders(hallway, Global.level_generator.hallways[i], Global.level_generator.spawned_hallway_prefabs[i])
		
		hallways.append(hallway)


func create_room_borders(room_control : Control, room : LevelRoom, prefab : LevelRoomPrefab):
	var room_size = Vector2i(room.size.x, room.size.z)
	for x in range(-1, room_size.x + 1):
		for y in range(-1, room_size.y + 1):
			var pos : Vector2i = Vector2i(x,y)
			var should_skip := false
			for e in room.open_entrances: if prefab.entrances[e].position.x == pos.x and prefab.entrances[e].position.z == pos.y: should_skip = true 
			if should_skip: continue
			
			if (pos in [Vector2i(-1,-1), Vector2i(room_size.x, -1), Vector2i(-1, room_size.y), Vector2i(room_size.x, room_size.y)] or
				(pos.x >= 0 and pos.x < room_size.x and pos.y >= 0 and pos.y < room_size.y)):
				continue # skip outer corners and inner tiles
			
			var border = ColorRect.new()
			room_control.add_child(border)
			border.size = Vector2(map_scale / 10.0, map_scale) if pos.x < 0 or pos.x >= room_size.x else Vector2(map_scale, map_scale / 10.0)
			border.position = (pos + (Vector2i(1,0) if pos.x < 0 else Vector2i(0,1) if pos.y < 0 else Vector2i.ZERO)) * map_scale
			
			# center on inside edge
			if pos.x > -1 and pos.y > -1:
				if border.size.x < border.size.y: border.position.x -= border.size.x
				else: border.position.y -= border.size.y
			
			border.color = Color.BURLYWOOD
