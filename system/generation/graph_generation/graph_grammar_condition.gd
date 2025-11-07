extends Resource
class_name GraphGrammarCondition

enum ConditionType {CONNECTION_LIMIT}

@export var type : ConditionType

@export var args : String

@export_flags("SELF", "INPUT", "OUTPUT") var evaluated_nodes: int = 1


func evaluate(node : LevelGraphNode, connections : Array[LevelGraphConnection]) -> bool:
	#if evaluated_nodes & (1 << 0):print("evaluating self")
	#if evaluated_nodes & (1 << 1): print("evaluating input")
	#if evaluated_nodes & (1 << 2): print("evaluating output")
	
	if evaluated_nodes & (1 << 0) and not evaluate_individual(node, connections): return false
	for connection in connections:
		if connection.output == node and evaluated_nodes & (1 << 1) and not evaluate_individual(connection.input, connections): return false # is input
		if connection.input == node and evaluated_nodes & (1 << 2) and not evaluate_individual(connection.output, connections): return false # is output
	
	return true


func evaluate_individual(node : LevelGraphNode, connections : Array[LevelGraphConnection]) -> bool:
	match type:
		ConditionType.CONNECTION_LIMIT: return evaluate_connection_limit(node, connections)
	
	return true


func evaluate_connection_limit(node : LevelGraphNode, connections : Array[LevelGraphConnection]) -> bool:
	var n_connections : int = 0
	for connection in connections:
		if connection.input == node or connection.output == node: n_connections += 1
	return n_connections <= args.to_int()
