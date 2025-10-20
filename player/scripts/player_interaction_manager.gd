extends Node

@export var camera : Camera3D
@export var max_distance := 3.0

@onready var player: Player = $".."


var target_interactable : Interactable
#var target_item : Item


func _process(_delta: float) -> void:
	if not player.is_multiplayer_authority(): return
	
	do_raycast()
	if target_interactable and not target_interactable.active:
		target_interactable = null
	if target_interactable and Input.is_action_just_pressed("interact"):
		target_interactable.interact.rpc(player.get_path())
		
	#Global.ui.set_interact_text("" if (not target_interactable or target_interactable.display_keycode) else target_interactable.observe(player))
	if target_interactable: Global.ui.set_interact_text(target_interactable.observe(player), target_interactable.display_keycode)
	else: Global.ui.set_interact_text("")


func do_raycast():
	var space_state = player.get_world_3d().direct_space_state

	var origin = camera.global_position
	var end = origin + -camera.global_basis.z * max_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = [player.movement_manager]

	# do interactable
	query.collision_mask = Util.layer_mask([1,2,3])
	var result := space_state.intersect_ray(query)
	if result:
		target_interactable = result.collider as Interactable
		if not target_interactable: target_interactable = result.collider.get_parent() as Interactable
	else: target_interactable = null
	
	#print(result)
