@tool
extends Node
class_name LevelRoomGridViz

@export var dimensions : Vector3i

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_box(Vector3.ZERO - dimensions * LevelGenerator.cell_size * Vector3(1,0,1) / 2, Quaternion.IDENTITY, dimensions * LevelGenerator.cell_size)
		for x in range(dimensions.x):
			for y in range(dimensions.y):
				for z in range(dimensions.z):
					DebugDraw3D.draw_box(Vector3(x,y,z) * LevelGenerator.cell_size - dimensions * LevelGenerator.cell_size * Vector3(1,0,1) / 2, Quaternion.IDENTITY, Vector3.ONE * LevelGenerator.cell_size, Color.AQUAMARINE, false)
