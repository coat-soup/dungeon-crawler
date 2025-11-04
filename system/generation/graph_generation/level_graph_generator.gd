extends Node
class_name LevelGraphGenerator

@export var initial_node : LevelGraphNode
@export var spawnable_nodes : Array[LevelGraphNode]
var spawned_nodes : Array[LevelGraphNode]

func _ready():
	await get_tree().process_frame
	generate()


func generate():
	spawned_nodes.append(initial_node.duplicate())
	
	var finished_grammars := false
	while not finished_grammars:
		finished_grammars = true
		for node in spawned_nodes:
			if not node.grammars.is_empty():
				replace_node_with_grammar(node, node.grammars.pick_random())
				finished_grammars = false
	
	
	print("\nfinished generation, spawned nodes: ", spawned_nodes)
	
	for i in range(len(spawned_nodes)):
		var connection_ids = []
		for connection in spawned_nodes[i].connections:
			if spawned_nodes[i] == connection.input:
				connection_ids.append(spawned_nodes.find(connection.output))
		print(i, ". ", spawned_nodes[i].name + "->" + str(connection_ids))


func replace_node_with_grammar(node : LevelGraphNode, grammar : LevelGraphGrammar):
	var nodes : Array[LevelGraphNode] = []
	
	# spawn all internal grammar nodes
	for n in parse_nodes_from_grammar(grammar):
		if n == null:
			push_error("Level graph node [", node.name, "] failed to parse nodes from grammar")
			continue
		n = n.duplicate()
		nodes.append(n)
	print("parsed nodes from ", node, ": ", nodes)
	
	var connections = parse_connections_from_grammar(grammar)
	for i in range(0, len(connections)-1, 2):
		print("setting up connection ", connections[i], "->", connections[i+1])
		
		if connections[i] == -1:
			for c in node.connections: if c.output==node:
				var connection = LevelGraphConnection.new(c.input, nodes[connections[i+1]])
				c.input.connections.remove_at(c.input.connections.find(c))
				c.input.connections.append(connection)
				nodes[connections[i+1]].connections.append(connection)
			
		elif connections[i+1] == -2:
			for c in node.connections: if c.input==node:
				var connection = LevelGraphConnection.new(nodes[connections[i]], c.output)
				nodes[connections[i]].connections.append(connection)
				c.output.connections.remove_at(c.output.connections.find(c))
				c.output.connections.append(connection)
			
		else:
			var connection = LevelGraphConnection.new(nodes[connections[i]], nodes[connections[i+1]])
			nodes[connections[i]].connections.append(connection)
			nodes[connections[i+1]].connections.append(connection)
	
	spawned_nodes.remove_at(spawned_nodes.find(node))
	spawned_nodes.append_array(nodes)



func parse_nodes_from_grammar(grammar : LevelGraphGrammar) -> Array[LevelGraphNode]:
	var nodes : Array[LevelGraphNode] = []
	
	for node_name in grammar.nodes.split(","):
		var found_node = false
		for spawnable_node in spawnable_nodes:
			if node_name == spawnable_node.name:
				nodes.append(spawnable_node)
				found_node = true
		if not found_node:
			nodes.append(null)
			push_error("Level graph node [", node_name, "] not found in spawnables")
	
	return nodes

func parse_connections_from_grammar(grammar : LevelGraphGrammar) -> Array[int]:
	var connections : Array[int] = []
	for connection in grammar.connections.split(","):
		connections.append(connection.to_int())
	return connections
