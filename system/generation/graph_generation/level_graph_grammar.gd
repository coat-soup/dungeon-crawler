extends Resource
class_name LevelGraphGrammar

@export var weight : float = 1.0
@export var nodes : String
@export var connections : String
@export var conditions : Array[GraphGrammarCondition]

# -1 is input, -2 is output


func _to_string() -> String:
	return "{%s | %s}" % [nodes, connections]

func are_conditions_valid(node : LevelGraphNode, connections : Array[LevelGraphConnection]) -> bool:
	for condition in conditions:
		if not condition.evaluate(node, connections): return false
	return true
