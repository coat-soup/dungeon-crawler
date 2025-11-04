extends Node
class_name LevelGraphGenerator

@export var initial_node : LevelGraphNode
@export var spawnable_nodes : Array[LevelGraphNode]
var spawned_nodes : Array[LevelGraphNode]

func _ready():
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
		for connected_node in spawned_nodes[i].connected_nodes:
			connection_ids.append(spawned_nodes.find(connected_node))
		print(i, ". ", spawned_nodes[i].name + "->" + str(connection_ids))


func replace_node_with_grammar(node : LevelGraphNode, grammar : LevelGraphGrammar):
	var nodes : Array[LevelGraphNode] = []
	
	# spawn all internal grammar nodes
	nodes.append(null) # input
	for n in parse_nodes_from_grammar(grammar).slice(1,-1):
		n = n.duplicate()
		nodes.append(n)
	nodes.append(null) # output
	print("parsed nodes from ", node, ": ", nodes)
	
	# imagine:
	# A    C      e           A     e      C          A - e - C
	#  \  /      / \           \  /   \   /            \/   \/
	#   OG   +  IN OUT    ->    IN     OUT      ->     /\   /\
	#  /  \      \ /           /  \   /   \           B - f - D
	# B    D      f           B     f      D          
	
	
	# connect all internal grammar nodes
	for i in range(1, len(nodes)-1):
		var connections = grammar.nodes[i].split(":")[1].split(",")
		for c in connections:
			if nodes[c.to_int()] != null:
				nodes[i].connected_nodes.append(nodes[c.to_int()])
	
	# connect all input to all connections[0] (other_start->og_node) (A,B -> e,f)
	for n in spawned_nodes:
		if n.connected_nodes.has(node): # is node connected to og
			for c in grammar.nodes[0].split(":")[1].split(","): # all connections from input
				n.connected_nodes.append(nodes[c.to_int()])
	# connect all output to all connections[-1] (og_node<-other_end) (C,D -> e,f)
	for n in spawned_nodes:
		if n.connected_nodes.has(node): # is node connected to og
			for c in grammar.nodes[-1].split(":")[1].split(","): # all connections from output
				n.connected_nodes.append(nodes[c.to_int()])
	# connect all connections[0] from all input (other_start<-og_node) (e,f -> A,B)
	for n in nodes: # for each internal node
		for c in grammar.nodes[0].split(":")[1].split(","): 
			if c.to_int() == 0: # does internal node connect to input
				n.connected_nodes.append(nodes[c.to_int()])
	# connect all connections[-1] from all output (og_node->other_end) (e,f -> C,D)
	for n in nodes: # for each internal node
		for c in grammar.nodes[-1].split(":")[1].split(","): 
			if c.to_int() == len(grammar.nodes) - 1: # does internal node connect to input
				n.connected_nodes.append(nodes[c.to_int()])
	
	
	nodes = nodes.slice(1,-1) # remove null placeholder in/out nodes
	
	spawned_nodes.remove_at(spawned_nodes.find(node))
	spawned_nodes.append_array(nodes)
	print("nodes ", spawned_nodes)



func parse_nodes_from_grammar(grammar : LevelGraphGrammar) -> Array[LevelGraphNode]:
	var nodes : Array[LevelGraphNode] = []
	
	for i in range(len(grammar.nodes)):
		if i == 0 or i == len(grammar.nodes) - 1:
			nodes.append(null)
			continue
		var found_node = false
		for spawnable_node in spawnable_nodes:
			if grammar.nodes[i].split(":")[0] == spawnable_node.name:
				nodes.append(spawnable_node)
				found_node = true
		if not found_node: push_error("Level graph node ", grammar.nodes[i], " not found in spawnables")
	
	return nodes
