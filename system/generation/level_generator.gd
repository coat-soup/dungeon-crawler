@tool
extends Node3D
class_name LevelGenerator

@export var room_list : Array[LevelRoomData]
@export var dungeon_size : int = 20
@export var cell_size : float = 5.0
@export var occupied_spaces : Array[Array]
@export var num_rooms : int = 15
var spawned_rooms : Array[LevelRoom]

@export var debug_wait := false

@export var overlap_fix_iterations : int = 20
@export var condense_iterations : int = 30


func _ready():
	generate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"): generate()


func generate():
	clear_dungeon()
	
	for i in range(num_rooms):
		var room = LevelRoom.new()
		spawned_rooms.append(room)
		
		room.data_id = randi_range(0, len(room_list) - 1)
		room.size = room_list[room.data_id].dimensions
		room.position = Vector3i(randi_range(0, dungeon_size - room.size.x), 0, randi_range(0, dungeon_size - room.size.x))
		room.rotation = 0
		
		if debug_wait: await get_tree().create_timer(0.05).timeout
	
	
	for i in range(overlap_fix_iterations):
		var did_overlap
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


func clear_dungeon():
	spawned_rooms.clear()


func get_overlapped_rooms(room_id) -> Array[int]:
	var overlapped : Array[int] = []
	
	var a = spawned_rooms[room_id]
	
	for i in range(len(spawned_rooms)):
		if i == room_id : continue
		var b = spawned_rooms[i]
		if(a.position.x >= b.position.x + b.size.x): continue
		if(a.position.x + a.size.x <= b.position.x): continue
		if(a.position.z + a.size.z <= b.position.z): continue
		if(a.position.z >= b.position.z + b.size.z): continue
		overlapped.append(i)
	
	return overlapped
