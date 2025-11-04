extends Resource
class_name LevelGraphConnection

var input : LevelGraphNode
var output : LevelGraphNode
var uni_directional : bool = false

func _init(a : LevelGraphNode, b : LevelGraphNode, is_uni_directional: bool = false) -> void:
	input = a
	output = b
	uni_directional = is_uni_directional
