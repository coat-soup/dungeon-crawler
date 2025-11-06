extends RefCounted
class_name LevelRoom

var position : Vector3i
var rotation : int
var size : Vector3i

var graph_node : LevelGraphNode
var push_dir_viz : Vector3

var room_data : LevelRoomData

var open_entrances : Array[int] # ids of open entrances in prefabe entrances array

func get_center() -> Vector3:
	return Vector3(position) + size/2.0
