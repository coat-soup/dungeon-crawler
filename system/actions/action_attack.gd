extends Action
class_name ActionAttack

@export var distance_threshhold : float = 3.0

func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.start_attack(args[0])
	character.weapon_manager.weapon_bounced.connect(on_weapon_bounced)
	character.weapon_manager.weapon_hit_blocker.connect(on_weapon_bounced)
	character.health.took_damage.connect(on_took_damage)
	
	var ai = character.get_node_or_null("AIActionController") as AIActionController
	if ai and ai.active_target and ai.is_multiplayer_authority():
		character.movement_manager.body.global_rotation.y = -(character.global_position - ai.active_target.global_position).signed_angle_to(-Vector3.FORWARD, Vector3.UP)
		if ai.active_target.global_position.distance_to(ai.global_position) > 2.0:
			character.movement_manager.set_nav_destination(ai.active_target.global_position + (character.global_position - ai.active_target.global_position).normalized() * 1.5)
			character.movement_manager.apply_impulse((ai.active_target.global_position - character.global_position).normalized() * 5.0, 0.1)
	
	await character.get_tree().create_timer(1.0 / character.weapon_manager.weapon.speed_multiplier).timeout
	
	if character.action_manager.current_actions.has(self): trigger_end_action()


func on_weapon_bounced():
	if character.is_multiplayer_authority():
		trigger_end_action()


func on_took_damage(_amount, _source):
	if character.is_multiplayer_authority():
		trigger_end_action()


func end_action():
	super.end_action()
	var did_chain := false
	
	if character.weapon_manager.is_multiplayer_authority() and character.stamina.cur_stamina > 0:
		if character.weapon_manager.attack_input_buffer != -1 and character.weapon_manager.attack_input_buffer != character.weapon_manager.attack_state:
			character.action_manager.try_perform_action_by_name("attack", [character.weapon_manager.attack_input_buffer])
			did_chain = true
	
	if not did_chain:
		character.weapon_manager.attack_state = WeaponManager.AttackState.IDLE
		character.weapon_manager.toggle_damage_window(false) # do manually because animation track may not call if interrupted


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.character.stamina.cur_stamina <= 0: return 0
	var w := 0.0
	if ai.active_target:
		if ai.active_target.weapon_manager.attack_state == WeaponManager.AttackState.STUNNED: w += 1.0
		if ai.active_target.global_position.distance_to(ai.global_position) <= distance_threshhold: w += ai.desire_to_attack - 0.7 + (0.7 * ai.character.stamina.get_ratio())
	
	return w


static func get_ai_call_args(ai : AIActionController) -> Array:
	return [[WeaponManager.AttackState.SWING, WeaponManager.AttackState.LUNGE, WeaponManager.AttackState.OVERHEAD].pick_random()]
