extends Health
class_name HealthBlockable

signal blocked_damage

@export var weapon_manager : WeaponManager
var face_object : Node3D


func _ready() -> void:
	await get_tree().process_frame
	
	if weapon_manager.character_model as HumanoidSkeletonController:
		face_object = weapon_manager.character_model.head_rotator
	else:
		face_object = weapon_manager.character_model


@rpc("any_peer", "call_local")
func try_take_blockable_damage(amount: float, source_id : int = -1):
	if not is_multiplayer_authority(): return
	
	var did_block = false
	if weapon_manager.attack_state == WeaponManager.AttackState.BLOCKING:
		var character = Util.get_character_from_id(str(source_id), self) as Character
		if character:
			var angle = rad_to_deg((-face_object.global_basis.z).angle_to(face_object.global_position - character.weapon_manager.weapon.global_position)) # character.weapon_manager.weapon.swing_direction))
			if angle < 90.0:
				weapon_manager.did_block_damage.rpc(amount)
				blocked_damage.emit(source_id, amount)
				did_block = true
	
	if not did_block: take_damage.rpc(amount, source_id)
