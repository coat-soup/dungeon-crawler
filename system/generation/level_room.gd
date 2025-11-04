extends RefCounted
class_name LevelRoom

var data_id : int
var position : Vector3i
var rotation : int
var size : Vector3i

func get_center() -> Vector3:
	return Vector3(position) + size/2.0
