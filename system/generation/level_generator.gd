extends Node3D
class_name LevelGenerator

@export var dungeon_size : int = 200
@export var cell_size : float = 5.0
@export var occupied_spaces : Array[Array]
@export var num_rooms : int = 15
var spawned_rooms : Array[LevelRoom]
var spawned_prefabs : Array[LevelRoomPrefab]

@export var debug_wait := false
var hallways : Array[LevelRoomHallway]
var spawned_hallway_prefabs : Array[LevelRoomPrefab]
@export var hallway_room : LevelRoomData

@export var overlap_fix_iterations : int = 20
@export var condense_iterations : int = 300

@export var graph_generator : LevelGraphGenerator

var astar : LevelAstar

func _ready():
	astar = LevelAstar.new(self)
	graph_generator.finished_generation.connect(generate)


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
		room.position = Vector3i(node.world_pos / 10)
		room.rotation = 0
		
		if debug_wait: await get_tree().create_timer(0.05).timeout
	
	
	for i in range(overlap_fix_iterations):
		var did_overlap = LevelNodeSeparator.overlap_fix_step(spawned_rooms, 3)
		if not did_overlap: break
		
		if debug_wait: await get_tree().create_timer(0.2).timeout
	
	var converted_connections = LevelNodeSeparator.connections_to_ids(graph_generator.spawned_nodes, graph_generator.graph_connections)
	for i in range(condense_iterations):
		var did_condense = LevelNodeSeparator.condense_step(spawned_rooms, converted_connections, 3)
		if not did_condense: break
			
		if debug_wait: await get_tree().create_timer(0.2).timeout
	
	place_room_prefabs()
	generate_hallways()
	open_connections()


func clear_dungeon():
	spawned_rooms.clear()
	for prefab in spawned_prefabs:
		prefab.queue_free()
	spawned_prefabs.clear()
	hallways.clear()


func generate_hallways():
	print("generating hallways")
	
	for prefab in spawned_hallway_prefabs:
		prefab.queue_free()
	spawned_hallway_prefabs.clear()
	
	for a in range(len(spawned_rooms)):
		for b in range(len(spawned_rooms)):
			for c in graph_generator.graph_connections:
				if c.is_equal_to(LevelGraphConnection.new(spawned_rooms[a].graph_node, spawned_rooms[b].graph_node)):
					var start_entrance = get_closest_room_entrance_position(spawned_rooms[b].position, a)
					var target_entrance = get_closest_room_entrance_position(spawned_rooms[a].position, b)
					var path = astar.get_path_between_points(start_entrance, target_entrance, 2000, spawned_rooms[a], spawned_rooms[b])
					print("hallway path: ", path)
					for p in range(len(path)):
						var hallway : LevelRoomHallway = null
						var prefab : LevelRoomPrefab
						for h in range(len(hallways)): if hallways[h].position == path[p]:
							hallway = hallways[h]
							prefab = spawned_hallway_prefabs[h]
						
						if not hallway:
							hallway = LevelRoomHallway.new()
							hallway.size = hallway_room.dimensions
							hallway.position = path[p]
							hallways.append(hallway)
							
							prefab = hallway_room.prefab.instantiate()
							$LevelHolder.add_child(prefab)
							prefab.position = hallway.position * cell_size + hallway.size * cell_size * Vector3(1,0,1) / 2
							spawned_hallway_prefabs.append(prefab)
						
						hallway.inputs.append(spawned_rooms[a])
						hallway.outputs.append(spawned_rooms[b])
						
						if p < len(path) - 1: # connect to next hallway
							hallway.open_entrances.append(prefab.get_entrance(path[p+1] - path[p]))
						if p > 0: # connect to previous hallway
							hallway.open_entrances.append(prefab.get_entrance(path[p-1] - path[p]))
						if p == 0: #connect to start
							hallway.open_entrances.append(prefab.get_entrance_to_room(spawned_rooms[a], path[p]))
							spawned_rooms[a].open_entrances.append(spawned_prefabs[a].get_entrance(path[p] - spawned_rooms[a].position))
						if p == len(path) - 1: # connect to end
							hallway.open_entrances.append(prefab.get_entrance_to_room(spawned_rooms[b], path[p]))
							spawned_rooms[b].open_entrances.append(spawned_prefabs[b].get_entrance(path[p] - spawned_rooms[b].position))
							print("connecting to end: made entrance: ", spawned_rooms[b].open_entrances[-1])
						
						for h in range(len(hallways)):
							break
							if hallways[h].position == path[p] and is_instance_valid(spawned_hallway_prefabs[h]):
								print("joining hallways")
								if p == 0: continue
								hallways[h].open_entrances.append(spawned_hallway_prefabs[h].get_entrance(hallways[h].position - path[p-1]))
								if p < len(path) - 1:
									hallways[h].open_entrances.append(spawned_hallway_prefabs[h].get_entrance(hallways[h].position - path[p+1]))
								prefab.queue_free()
							
					# await get_tree().create_timer(0.5).timeout
					
					astar.closed_list.clear()
					astar.open_list.clear()
	
	var overlapping_hallways = 0
	for i in range(len(hallways)):
		for j in range(len(hallways)):
			if i == j: continue
			if hallways[i].position == hallways[j].position: overlapping_hallways += 1
	print("overlapping hallways: ", overlapping_hallways)


func get_closest_room_entrance_position(start: Vector3i, room_id : int) -> Vector3i:
	var closest : Vector3i = Vector3i.ONE * 999
	for entrance in spawned_prefabs[room_id].entrances:
		var tile : Vector3i = spawned_rooms[room_id].position + entrance.position
		if start.distance_to(tile) < start.distance_to(closest): closest = tile
	
	return closest


func place_room_prefabs():
	for prefab in spawned_prefabs:
		prefab.queue_free()
	spawned_prefabs.clear()
	
	for room in spawned_rooms:
		var prefab : LevelRoomPrefab = room.room_data.prefab.instantiate() as LevelRoomPrefab
		spawned_prefabs.append(prefab)
		$LevelHolder.add_child(prefab)
		prefab.position = room.position * cell_size + room.size * cell_size * Vector3(1,0,1) / 2


func open_connections():
	print("spawned: ", len(spawned_rooms), " prefs: ", len(spawned_prefabs))
	for i in range(len(spawned_rooms)):
		for e in spawned_rooms[i].open_entrances:
			spawned_prefabs[i].toggle_entrance(e, true)
	
	for i in range(len(hallways)):
		for e in hallways[i].open_entrances:
			spawned_hallway_prefabs[i].toggle_entrance(e, true)
