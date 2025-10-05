extends Action
class_name ActionAttack


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.start_attack(args[0])
	character.weapon_manager.weapon_bounced.connect(on_weapon_bounced)
	
	var ai = character.get_node_or_null("AIActionController") as AIActionController
	if ai:
		character.movement_manager.set_nav_destination(ai.targets[0].global_position + (character.global_position - ai.targets[0].global_position).normalized() * 1.5)
		character.movement_manager.body.global_rotation.y = -(character.global_position - ai.targets[0].global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)
	
	await character.get_tree().create_timer(1.0).timeout
	trigger_end_action()


func on_weapon_bounced():
	if character.is_multiplayer_authority():
		trigger_end_action()


func end_action():
	super.end_action()
	var did_chain := false
	
	if character.weapon_manager.is_multiplayer_authority():
		if character.weapon_manager.attack_input_buffer != -1 and character.weapon_manager.attack_input_buffer != character.weapon_manager.attack_state:
			character.action_manager.try_perform_action_by_name("attack", [character.weapon_manager.attack_input_buffer])
			did_chain = true
	
	if not did_chain: character.weapon_manager.attack_state = WeaponManager.AttackState.IDLE


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.character.stamina.cur_stamina <= 0: return 0
	for t in ai.targets:
		if t.global_position.distance_to(ai.global_position) <= 4.0: return ai.desire_to_attack - 0.7 + (0.7 * ai.character.stamina.get_ratio())
	
	return 0.0


static func get_ai_call_args(ai : AIActionController) -> Array:
	return [[WeaponManager.AttackState.SWING, WeaponManager.AttackState.LUNGE, WeaponManager.AttackState.OVERHEAD].pick_random()]
