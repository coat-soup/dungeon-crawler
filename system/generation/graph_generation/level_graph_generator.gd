extends Node
class_name LevelGraphGenerator

signal finished_generation

@export var target_rooms : int = 20

@export var initial_node : LevelGraphNode
@export var spawnable_nodes : Array[LevelGraphNode]

var spawned_nodes : Array[LevelGraphNode]
var graph_connections : Array[LevelGraphConnection]


@export var debug_wait := false
@export var debug_print := false


func _ready():
	generate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"): generate()


func _process(delta: float) -> void:
	for node in spawned_nodes:
		var push_dir : Vector3 = Vector3.ZERO
		for other_node in spawned_nodes:
			if other_node == node: continue
			push_dir += (node.world_pos - other_node.world_pos).normalized() / pow(node.world_pos.distance_to(other_node.world_pos), 2)
		
		var pull_dir : Vector3 = Vector3.ZERO
		for c in graph_connections:
			if c.input == node or c.output == node:
				var multiplier = 1 if c.output == node else -1
				pull_dir += multiplier * (c.input.world_pos - c.output.world_pos).normalized() * pow(c.input.world_pos.distance_to(c.output.world_pos), 1)
		
		node.world_pos += delta * (push_dir * 5000 + pull_dir * 1)


func generate():
	clear_graph()
	
	spawned_nodes.append(initial_node.duplicate())
	
	var finished_grammars := false
	while not finished_grammars:
		if debug_print: print_graph()
		finished_grammars = true
		for i in range(len(spawned_nodes) - 1, -1, -1):
			if not spawned_nodes[i].grammars.is_empty():
				replace_node_with_grammar(spawned_nodes[i], select_grammar_from_node(spawned_nodes[i]))
				finished_grammars = false
				if debug_print: print_graph()
				if debug_wait: await get_tree().create_timer(2.0).timeout
	
	
	if debug_print: print("\nfinished generation, spawned nodes: ", spawned_nodes)
	if debug_print: print_graph()
	
	await get_tree().create_timer(3.0).timeout # await graph stabilisation
	finished_generation.emit()


func clear_graph():
	spawned_nodes.clear()
	graph_connections.clear()


func replace_node_with_grammar(node : LevelGraphNode, grammar : LevelGraphGrammar):
	var nodes : Array[LevelGraphNode] = []
	var new_connections : Array[LevelGraphConnection] = []
	var connections_to_remove : Array[LevelGraphConnection]
	
	if debug_print: print("replacing [", node.name, "] with grammar ", grammar)
	
	# spawn all internal grammar nodes
	for n in parse_nodes_from_grammar(grammar):
		if n == null:
			push_error("Level graph node [", node.name, "] failed to parse nodes from grammar")
			continue
		n = n.duplicate(true)
		#n.name += str(randi() & 1000)
		n.world_pos = node.world_pos + Util.random_point_in_circle_3d(10)
		nodes.append(n)
	if debug_print: print("parsed nodes from ", node, ": ", nodes)
	
	var connections = parse_connections_from_grammar(grammar)
	for i in range(0, len(connections), 2):
		if debug_print: print("setting up connection ", connections[i], "->", connections[i+1])
		
		if connections[i] == -1:
			for c in graph_connections: if c.output==node:
				new_connections.append(LevelGraphConnection.new(c.input, nodes[connections[i+1]]))
				connections_to_remove.append(c)
				if debug_print: print("added connection from ext ", c.input, " to ", nodes[connections[i+1]])
			
		elif connections[i+1] == -2:
			for c in graph_connections: if c.input==node:
				new_connections.append(LevelGraphConnection.new(nodes[connections[i]], c.output))
				connections_to_remove.append(c)
				if debug_print: print("added connection from ", nodes[connections[i]], " to ext ", c.output)
			
		else:
			new_connections.append(LevelGraphConnection.new(nodes[connections[i]], nodes[connections[i+1]]))
			if debug_print: print("added connection from ", nodes[connections[i]], " to ", nodes[connections[i+1]])
	
	for c in connections_to_remove:
		var id = graph_connections.find(c)
		if id != -1: graph_connections.remove_at(id)
	
	spawned_nodes.remove_at(spawned_nodes.find(node))
	spawned_nodes.append_array(nodes)
	graph_connections.append_array(new_connections)



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


func select_grammar_from_node(node : LevelGraphNode) -> LevelGraphGrammar:
	var weights : Array[float] = []
	
	for i in range(len(node.grammars)):
		weights.append(node.grammars[i].weight)
		if node.grammars[i].nodes.split(",").has("branch"):
			weights[i] *= get_propensity_to_branch()
	
	return node.grammars[Util.weighted_random(node.grammars, weights)]


func print_graph():
	print("\nGRAPH")
	for i in range(len(spawned_nodes)):
		var connection_ids = []
		for connection in graph_connections:
			if connection.input == spawned_nodes[i]:
				connection_ids.append(spawned_nodes.find(connection.output))
		print(i, ". ", spawned_nodes[i].name + "->" + str(connection_ids))
	
	print("CONNECTIONS")
	for c in graph_connections:
		print(spawned_nodes.find(c.input), "->", spawned_nodes.find(c.output))


func get_propensity_to_branch() -> float:
	return 10.0 * (1.0 - (len(spawned_nodes) / 20.0))
