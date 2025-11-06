extends RefCounted
class_name LevelAstar

var generator : LevelGenerator

var open_list : Array[AStarNode] = []
var closed_list : Array[AStarNode] = []

var start : Vector3i
var end : Vector3i

func _init(gen : LevelGenerator) -> void:
	generator = gen


func get_path_between_points(a : Vector3i, b : Vector3i, max_closed_length : int = 2000) -> Array[Vector3i]:
	start = a
	end = b
	open_list = []
	closed_list = []
	
	open_list.append(AStarNode.new(null, start))
	
	while not open_list.is_empty() and len(closed_list) < max_closed_length:
		#await generator.get_tree().create_timer(0.1).timeout
		#get lowest f node
		var cur_node = open_list[0]
		for node in open_list:
			if node.f < cur_node.f: cur_node = node
		
		open_list.remove_at(open_list.find(cur_node))
		closed_list.append(cur_node)
		
		# check completed
		if cur_node.position == end:
			var path : Array[Vector3i] = []
			var p = cur_node
			while p:
				path.append(p.position)
				p = p.parent
			path.reverse()
			return path
		
		var children : Array[AStarNode]
		# adjacent positions
		for offset in [
						Vector3i(1, 0, 0),   # +X (right)
						Vector3i(-1, 0, 0),  # -X (left)
						#Vector3i(0, 1, 0),   # +Y (up)
						#Vector3i(0, -1, 0),  # -Y (down)
						Vector3i(0, 0, 1),   # +Z (forward)
						Vector3i(0, 0, -1)   # -Z (backward)
					]:
			var node_pos = cur_node.position + offset
			if is_position_occupied(node_pos): continue
			children.append(AStarNode.new(cur_node, node_pos))
		
		for child in children:
			for c in closed_list: if c.position == child.position: continue # skip closed list
			
			child.g = cur_node.g + 1 # path_length
			child.h = get_heuristic(child, end) # cost
			child.f = child.g + child.h # total cost
			
			for c in closed_list: if c.position == child.position: continue # skip add if already in open list
			open_list.append(child)
	
	print("failed astar. closed_list size: ", len(closed_list))
	return []


func is_position_occupied(pos : Vector3i):
	for room in generator.spawned_rooms:
		if (room.position.x <= pos.x and room.position.x+room.size.x > pos.x
		and room.position.y <= pos.y and room.position.y+room.size.y > pos.y
		and room.position.z <= pos.z and room.position.z+room.size.z > pos.z):
			return true
	for hallway in generator.hallways:
		if hallway.position == pos: return true
	
	return false


func get_heuristic(node : AStarNode, goal : Vector3i) -> float:
	var h = node.position.distance_to(goal)
	if node.position.y != node.parent.position.y: h += 10
	return h
