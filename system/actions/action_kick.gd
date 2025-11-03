extends Action
class_name ActionKick


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.kick()
	
	var ai = character.get_node_or_null("AIActionController") as AIActionController
	if ai and ai.active_target and ai.is_multiplayer_authority():
		character.movement_manager.body.global_rotation.y = -(character.global_position - ai.active_target.global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)
		#character.movement_manager.set_nav_destination(ai.active_target.global_position + (character.global_position - ai.active_target.global_position).normalized() * 1.5)
		character.movement_manager.apply_impulse((ai.active_target.global_position - character.global_position).normalized() * 5.0, 0.1)
	
	await character.get_tree().create_timer(0.6).timeout
	trigger_end_action()


func end_action():
	super.end_action()
	character.weapon_manager.attack_state = WeaponManager.AttackState.IDLE


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.active_target and ai.active_target.weapon_manager.attack_state == WeaponManager.AttackState.BLOCKING and ai.active_target.global_position.distance_to(ai.global_position) < 4.0: return ai.desire_to_attack - 0.5 + (0.5 * ai.character.stamina.get_ratio())
	
	return 0.0
