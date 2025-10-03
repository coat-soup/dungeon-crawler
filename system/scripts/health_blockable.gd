extends Health
class_name HealthBlockable

@export var weapon_manager : WeaponManager


@rpc("any_peer", "call_local")
func try_take_blockable_damage(amount: float, source_id : int = -1):
	if not is_multiplayer_authority(): return
	
	var did_block = false
	if weapon_manager.blocking:
		var character = Util.get_character_from_id(str(source_id), self) as Character
		if character:
			var angle = rad_to_deg((-weapon_manager.character_model.head_rotator.global_basis.z).angle_to(weapon_manager.character_model.head_rotator.global_position - character.weapon_manager.weapon.global_position)) # character.weapon_manager.weapon.swing_direction))
			Global.ui.display_chat_message("BLOCK ANGLE: " + str(angle))
			if angle < 90.0:
				weapon_manager.did_block_damage.rpc()
				did_block = true
	
	if not did_block: take_damage.rpc(amount, source_id)
