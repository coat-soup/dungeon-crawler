extends Resource
class_name LevelGraphNode

@export var name : String = "Node"
@export var grammars : Array[LevelGraphGrammar]
var connections : Array[LevelGraphConnection]

func _to_string() -> String:
	return name
