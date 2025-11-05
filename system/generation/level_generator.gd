@tool
extends Node3D
class_name LevelGenerator

@export var dungeon_size : int = 200
@export var cell_size : float = 5.0
@export var occupied_spaces : Array[Array]
@export var num_rooms : int = 15
var spawned_rooms : Array[LevelRoom]
var spawned_prefabs : Array[LevelRoomPrefab]

@export var debug_wait := false
@export var hallways : Array[Vector3i]

@export var overlap_fix_iterations : int = 20
@export var condense_iterations : int = 300

@export var graph_generator : LevelGraphGenerator

var astar : LevelAstar

func _ready():
	astar = LevelAstar.new(self)
	graph_generator.finished_generation.connect(generate)
	generate()


func generate():
	print("GENERATING")
	clear_dungeon()
	
	for node in graph_generator.spawned_nodes:
		var room = LevelRoom.new()
		spawned_rooms.append(room)
		
		var room_data : LevelRoomData = node.terminal_rooms.pick_random()
		room.room_data = room_data
		
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
	
	place_room_prefabs()
	generate_hallways()


func clear_dungeon():
	spawned_rooms.clear()
	for prefab in spawned_prefabs:
		prefab.queue_free()
	spawned_prefabs.clear()
	hallways.clear()


func get_overlapped_rooms(room_id : int, gap : int = 1) -> Array[int]:
	var overlapped : Array[int] = []
	
	var a = spawned_rooms[room_id]
	var a_min = a.position
	var a_max = a.position + a.size
	
	for i in range(len(spawned_rooms)):
		if i == room_id : continue
		var b = spawned_rooms[i]
		var b_min = b.position - Vector3i.ONE * gap
		var b_max = b.position + b.size + Vector3i.ONE * gap
		
		if a_min.x >= b_max.x: continue
		if a_max.x <= b_min.x: continue
		if a_min.y >= b_max.y: continue
		if a_max.y <= b_min.y: continue
		if a_min.z >= b_max.z: continue
		if a_max.z <= b_min.z: continue
		overlapped.append(i)
	
	return overlapped


func generate_hallways():
	print("generating hallways")
	
	for a in range(len(spawned_rooms)):
		for b in range(len(spawned_rooms)):
			for c in graph_generator.graph_connections:
				if c.is_equal_to(LevelGraphConnection.new(spawned_rooms[a].graph_node, spawned_rooms[b].graph_node)):
					var start_entrance = get_closest_room_entrance_position(spawned_rooms[b].position, a)
					var target_entrance = get_closest_room_entrance_position(spawned_rooms[a].position, b)
					var path = await astar.get_path_between_points(start_entrance, target_entrance)
					print("hallway path: ", path)
					for p in path:
						hallways.append(p)
						print("adding ", p, " to hallways")
					# await get_tree().create_timer(0.5).timeout
					astar.closed_list.clear()
					astar.open_list.clear()


func get_closest_room_entrance_position(start: Vector3i, room_id : int) -> Vector3i:
	var closest : Vector3i = Vector3i.ONE * 999
	for entrance in spawned_prefabs[room_id].entrances:
		var tile : Vector3i = spawned_rooms[room_id].position + entrance.position
		if start.distance_to(tile) < start.distance_to(closest): closest = tile
	
	return closest


func place_room_prefabs():
	for room in spawned_rooms:
		var prefab : LevelRoomPrefab = room.room_data.prefab.instantiate() as LevelRoomPrefab
		spawned_prefabs.append(prefab)
		$LevelHolder.add_child(prefab)
		prefab.position = room.position * cell_size
