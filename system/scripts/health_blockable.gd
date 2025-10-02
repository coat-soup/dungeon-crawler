extends Health
class_name HealthBlockable

@export var weapon_manager : WeaponManager


@rpc("any_peer", "call_local")
func try_take_blockable_damage(amount: float, source_id : int = -1):
	if not is_multiplayer_authority(): return
	
	var did_block = false
	if weapon_manager.blocking:
		var player = Util.get_player_from_id(str(source_id), self) as Player
		if player:
			var angle = rad_to_deg((-weapon_manager.player.camera.global_basis.z).angle_to(player.weapon_manager.weapon.swing_direction))
			Global.ui.display_chat_message("BLOCK ANGLE: " + str(angle))
			if angle < 90.0:
				weapon_manager.did_block_damage.rpc()
				did_block = true
	
	if not did_block: take_damage.rpc(amount, source_id)
