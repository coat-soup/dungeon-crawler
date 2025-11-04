extends Resource
class_name LevelGraphGrammar

@export var weight : float = 1.0
@export var nodes : String
@export var connections : String


# -1 is input, -2 is output


func _to_string() -> String:
	return "{%s | %s}" % [nodes, connections]
