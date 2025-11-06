extends Node
class_name DebugGenerationVisualiser

@export var generator: LevelGenerator
@export var camera : Node3D

var origin_offset : float
@export var enabled := true

func _ready() -> void:
	var origin_offset = (generator.dungeon_size * generator.cell_size) / 2
	camera.global_position += Vector3(origin_offset, 0, origin_offset)


func _process(delta: float) -> void:
	if not enabled: return
	
	for node in generator.astar.open_list:
		DebugDraw3D.draw_box(node.position * generator.cell_size, Quaternion.IDENTITY, Vector3.ONE * generator.cell_size / 2, Color.BEIGE)
	for node in generator.astar.closed_list:
		DebugDraw3D.draw_box(node.position * generator.cell_size, Quaternion.IDENTITY, Vector3.ONE * generator.cell_size / 2, Color.AQUA)
	DebugDraw3D.draw_box(generator.astar.start * generator.cell_size, Quaternion.IDENTITY, Vector3.ONE * generator.cell_size / 2, Color.CHARTREUSE)
	DebugDraw3D.draw_box(generator.astar.end * generator.cell_size, Quaternion.IDENTITY, Vector3.ONE * generator.cell_size / 2, Color.CHARTREUSE)
	
	if true:
		DebugDraw3D.scoped_config().set_thickness(0.2).set_center_brightness(0.6)
		var t = Transform3D.IDENTITY * generator.transform * generator.cell_size * generator.dungeon_size * 2
		t = t.translated(-Vector3(1, 0, 1) * generator.dungeon_size * generator.cell_size)
		DebugDraw3D.draw_grid_xf(t, Vector2i(generator.dungeon_size * 2, generator.dungeon_size * 2), Color.DARK_CYAN, false)
	
	for i in range(len(generator.spawned_rooms)):
		if true:
			DebugDraw3D.scoped_config().set_thickness(0.8).set_center_brightness(0.6)
			var overlapping = len(generator.get_overlapped_rooms(i)) > 0
			DebugDraw3D.draw_box(generator.cell_size * generator.spawned_rooms[i].position,
								Quaternion.IDENTITY,
								generator.cell_size * generator.spawned_rooms[i].size,
								LevelGraphVisualiser.get_node_color(generator.spawned_rooms[i].graph_node.name) if not overlapping else Color.FIREBRICK)
		
		DebugDraw3D.draw_text(generator.spawned_rooms[i].get_center() * generator.cell_size + Vector3.UP * 10, generator.spawned_rooms[i].graph_node.name, 500, Color.BLACK)
		
		var overlaps = generator.get_overlapped_rooms(i)
		var push_dir = Vector3.ZERO
		for overlap in overlaps:
			push_dir += (generator.spawned_rooms[i].get_center() - generator.spawned_rooms[overlap].get_center()).normalized()
		DebugDraw3D.draw_arrow(generator.spawned_rooms[i].get_center() * generator.cell_size, (generator.spawned_rooms[i].get_center() + push_dir) * generator.cell_size)
		
		if true:
			DebugDraw3D.scoped_config().set_thickness(0.3)
			for room in generator.spawned_rooms:
				for connection in generator.graph_generator.graph_connections:
					if connection.is_equal_to(LevelGraphConnection.new(generator.spawned_rooms[i].graph_node, room.graph_node)):
						DebugDraw3D.draw_arrow(generator.spawned_rooms[i].get_center() * generator.cell_size + Vector3.UP * 5, room.get_center() * generator.cell_size + Vector3.UP * 5, Color.WEB_GRAY, 0.5, true)
		
		#DebugDraw3D.draw_arrow(generator.spawned_rooms[i].get_center() * generator.cell_size, (generator.spawned_rooms[i].get_center() + generator.spawned_rooms[i].push_dir_viz) * generator.cell_size)
	
	for hallway in generator.hallways:
		DebugDraw3D.draw_box(hallway.position * generator.cell_size, Quaternion.IDENTITY, Vector3.ONE * generator.cell_size / 2, Color.DIM_GRAY)
