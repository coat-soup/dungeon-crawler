extends Node
class_name DebugGenerationVisualiser

@export var generator: LevelGenerator
@export var camera : Node3D

var origin_offset : float


func _ready() -> void:
	var origin_offset = (generator.dungeon_size * generator.cell_size) / 2
	camera.global_position += Vector3(origin_offset, 0, origin_offset)


func _process(delta: float) -> void:
	if true:
		DebugDraw3D.scoped_config().set_thickness(0.2).set_center_brightness(0.6)
		var t = Transform3D.IDENTITY * generator.transform * generator.cell_size * generator.dungeon_size
		DebugDraw3D.draw_grid_xf(t, Vector2i(generator.dungeon_size, generator.dungeon_size), Color.DARK_CYAN, false)
	
	DebugDraw3D.scoped_config().set_thickness(0.8).set_center_brightness(0.6)
	
	for i in range(len(generator.spawned_rooms)):
		var overlapping = len(generator.get_overlapped_rooms(i)) > 0
		DebugDraw3D.draw_box(generator.cell_size * generator.spawned_rooms[i].position,
							Quaternion.IDENTITY,
							generator.cell_size * generator.spawned_rooms[i].size,
							Color.DARK_ORCHID if not overlapping else Color.FIREBRICK)

		var overlaps = generator.get_overlapped_rooms(i)
		var push_dir = Vector3.ZERO
		for overlap in overlaps:
			push_dir += (generator.spawned_rooms[i].get_center() - generator.spawned_rooms[overlap].get_center()).normalized()
		DebugDraw3D.draw_arrow(generator.spawned_rooms[i].get_center() * generator.cell_size, (generator.spawned_rooms[i].get_center() + push_dir) * generator.cell_size)
