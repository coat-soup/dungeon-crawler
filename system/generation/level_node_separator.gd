class_name LevelNodeSeparator

static func overlap_fix_step(nodes : Array[Variant], gap : int, fixed_size : Vector3i = Vector3i.ZERO) -> bool:
	var did_overlap = false
	for i in range(len(nodes)):
		var overlaps = get_overlapping_nodes(i, nodes, gap, fixed_size)
		if not overlaps.is_empty(): 
			did_overlap = true
			var push_dir = Vector3.ZERO
			for overlap in overlaps:
				push_dir += ((get_node_center(nodes[i], fixed_size) - get_node_center(nodes[overlap], fixed_size)) * Vector3(1,0,1)).normalized()
			nodes[i].position += Vector3i(push_dir.ceil())
	return did_overlap


static func condense_step(nodes : Array[Variant], connections : Array[Array], gap : int, fixed_size : Vector3i = Vector3i.ZERO) -> bool:
	var did_condense = false
	for i in range(len(nodes)):
		#var push_dir : Vector3 = Vector3.ZERO
		for j in range(len(nodes)):
			for connection in connections:
				if connection == [i,j] or connection == [j,i]:
					var push_dir = (get_node_center(nodes[j], fixed_size) - get_node_center(nodes[i], fixed_size)) / 2.0 #.normalized()
					#nodes[i].push_dir_viz = push_dir
					var p_pos = nodes[i].position
					nodes[i].position += Vector3i(push_dir.ceil()) # push
					if not get_overlapping_nodes(i, nodes, gap, fixed_size).is_empty(): nodes[i].position = p_pos # undo if overlapping
					else:
						#print("pushed condensed node ", nodes[i])
						did_condense = true
	return did_condense


static func get_node_center(node : Variant, fixed_size : Vector3i = Vector3i.ZERO) -> Vector3:
	var size = fixed_size if fixed_size != Vector3i.ZERO else node.size
	return Vector3(node.position) + size/2.0


static func get_overlapping_nodes(index : int, nodes : Array[Variant], gap : int = 1, fixed_size : Vector3i = Vector3i.ZERO) -> Array[Variant]:
	var overlapped : Array[int] = []
	
	var a = nodes[index]
	var a_size = fixed_size if fixed_size != Vector3i.ZERO else a.size
	var a_min = a.position
	var a_max = a.position + a_size
	
	for i in range(len(nodes)):
		if i == index : continue
		var b = nodes[i]
		var b_size = fixed_size if fixed_size != Vector3i.ZERO else b.size
		var b_min = b.position - Vector3i.ONE * gap
		var b_max = b.position + b_size + Vector3i.ONE * gap
		
		if a_min.x >= b_max.x: continue
		if a_max.x <= b_min.x: continue
		if a_min.y >= b_max.y: continue
		if a_max.y <= b_min.y: continue
		if a_min.z >= b_max.z: continue
		if a_max.z <= b_min.z: continue
		overlapped.append(i)
	
	return overlapped


static func connections_to_ids(nodes : Array[LevelGraphNode], connections : Array[LevelGraphConnection]) -> Array[Array]:
	var id_connections : Array[Array] = []
	
	for connection in connections:
		id_connections.append([-1,-1])
		for i in range(len(nodes)):
			if nodes[i] == connection.input:id_connections[-1][0] = i
			if nodes[i] == connection.output: id_connections[-1][1] = i
			if not id_connections[-1].has([-1]): continue # skip rest if found already
	
	return id_connections
