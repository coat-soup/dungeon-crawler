@tool
extends Node3D
class_name LevelGenerator

@export var dungeon_size : int = 20
@export var cell_size : float = 5.0
@export var occupied_spaces : Array[Array]
@export var num_rooms : int = 15
var spawned_rooms : Array[LevelRoom]

@export var debug_wait := false

@export var overlap_fix_iterations : int = 20
@export var condense_iterations : int = 300

@export var graph_generator : LevelGraphGenerator


func _ready():
	graph_generator.finished_generation.connect(generate)
	generate()


func generate():
	print("GENERATING")
	clear_dungeon()
	
	for node in graph_generator.spawned_nodes:
		var room = LevelRoom.new()
		spawned_rooms.append(room)
		
		var room_data : LevelRoomData = node.terminal_rooms.pick_random()
		
		room.graph_node = node
		room.size = room_data.dimensions
		room.position = Vector3i(node.world_pos / cell_size)
		room.rotation = 0
		
		if debug_wait: await get_tree().create_timer(0.05).timeout
	
	
	for i in range(overlap_fix_iterations):
		var did_overlap = false
		for r in range(len(spawned_rooms)):
			var overlaps = get_overlapped_rooms(r)
			if not overlaps.is_empty(): 
				did_overlap = true
				var push_dir = Vector3.ZERO
				for overlap in overlaps:
					push_dir += (spawned_rooms[r].get_center() - spawned_rooms[overlap].get_center()).normalized()
				spawned_rooms[r].position += Vector3i(push_dir.ceil())
		if not did_overlap: break
		
		if debug_wait: await get_tree().create_timer(0.2).timeout
	
	for i in range(condense_iterations):
		var did_condense = false
		for r in range(len(spawned_rooms)):
			#var push_dir : Vector3 = Vector3.ZERO
			for room in spawned_rooms:
				for connection in graph_generator.graph_connections:
					if connection.is_equal_to(LevelGraphConnection.new(spawned_rooms[r].graph_node, room.graph_node)) or connection.is_equal_to(LevelGraphConnection.new(room.graph_node, spawned_rooms[r].graph_node)):
						var push_dir = (room.get_center() - spawned_rooms[r].get_center()) / 5.0 #.normalized()
						spawned_rooms[r].push_dir_viz = push_dir
						var p_pos = spawned_rooms[r].position
						spawned_rooms[r].position += Vector3i(push_dir.ceil()) # push
						if not get_overlapped_rooms(r).is_empty(): spawned_rooms[r].position = p_pos # undo if overlapping
						else: did_condense = true
		if not did_condense: break
			
		if debug_wait: await get_tree().create_timer(0.2).timeout


func clear_dungeon():
	spawned_rooms.clear()


func get_overlapped_rooms(room_id) -> Array[int]:
	var overlapped : Array[int] = []
	
	var a = spawned_rooms[room_id]
	
	for i in range(len(spawned_rooms)):
		if i == room_id : continue
		var b = spawned_rooms[i]
		if a.position.x >= b.position.x + b.size.x: continue
		if a.position.x + a.size.x <= b.position.x: continue
		if a.position.z + a.size.z <= b.position.z: continue
		if a.position.z >= b.position.z + b.size.z: continue
		overlapped.append(i)
	
	return overlapped
