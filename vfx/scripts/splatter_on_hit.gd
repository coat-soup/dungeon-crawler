extends Node3D
class_name SplatterOnHit

@export var health : Health
@export var texture : Texture2D
@export var modulate : Color = Color.WHITE

func _ready() -> void:
	if not health:
		push_error("Splatter on hit not child of Health component!")
	
	health.took_damage.connect(on_damaged)


func on_damaged(_damage, _source):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3.UP * 10)
	var result = space_state.intersect_ray(query)
	
	if result:
		var decal = Decal.new()
		get_tree().root.add_child(decal)
		decal.global_position = result.position
		decal.global_rotation.y = randf_range(-PI, PI)
		decal.texture_albedo = texture
		decal.cull_mask = 1
		decal.modulate = modulate
