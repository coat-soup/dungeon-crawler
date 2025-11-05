extends Node
class_name LevelGraphVisualiser

@export var generator : LevelGraphGenerator
@export var enabled := true

func _process(delta: float) -> void:
	if not enabled: return
	DebugDraw3D.scoped_config().set_thickness(0.6).set_center_brightness(0.6)
	for node in generator.spawned_nodes:
		DebugDraw3D.draw_box(node.world_pos, Quaternion.IDENTITY, Vector3.ONE * 10, get_node_color(node.name))
		DebugDraw3D.draw_text(node.world_pos + Vector3.ONE * 5, node.name, 500, Color.BLACK)
	for connection in generator.graph_connections:
		DebugDraw3D.draw_arrow(connection.input.world_pos, connection.output.world_pos, Color.BLACK, 2, true)


func get_node_color(node_name : String) -> Color:
	match node_name:
		"start", "end": return Color.CHARTREUSE
		"branch" : return Color.BURLYWOOD
		"encounter" : return Color.ORANGE
		"lock_key" : return Color.WEB_PURPLE
		_: return Color.CADET_BLUE
