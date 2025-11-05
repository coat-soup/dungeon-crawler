extends Resource
class_name LevelGraphNode

@export var name : String = "Node"
@export var grammars : Array[LevelGraphGrammar]

@export var terminal_rooms : Array[LevelRoomData]

var world_pos : Vector3

func _to_string() -> String:
	return name
