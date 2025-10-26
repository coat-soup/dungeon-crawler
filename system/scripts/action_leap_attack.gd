extends Action
class_name ActionLeapAttack

@export var distance_threshhold : float = 5.0
@export var leap_vel : Vector3 = Vector3(0,1.0,10.0)
@export var leap_duration : float = 0.2

func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.start_attack(0)
	character.weapon_manager.weapon_bounced.connect(on_weapon_bounced)
	character.health.took_damage.connect(on_took_damage)
	character.weapon_manager.character_model.leap_started.connect(on_leap_started)
	
	await character.get_tree().create_timer(1.0 / character.weapon_manager.weapon.speed_multiplier).timeout
	if character.action_manager.current_actions.has(self): trigger_end_action()


func on_leap_started():
	if leap_vel != Vector3.ZERO and character.is_multiplayer_authority():
		var ai = character.get_node_or_null("AIActionController") as AIActionController
		if ai:
			character.movement_manager.apply_impulse(leap_vel.rotated(Vector3.UP, -(character.global_position - ai.targets[0].global_position).signed_angle_to(Vector3.FORWARD, Vector3.UP)), 0.2)
		else:
			character.movement_manager.apply_impulse(leap_vel, leap_duration, true)


func on_weapon_bounced():
	if character.is_multiplayer_authority():
		trigger_end_action()


func on_took_damage(_amount, _source):
	if character.is_multiplayer_authority():
		trigger_end_action()


func end_action():
	super.end_action()
	character.weapon_manager.attack_state = WeaponManager.AttackState.IDLE
	character.weapon_manager.toggle_damage_window(false) # do manually because animation track may not call if interrupted


func get_ai_action_weight(ai : AIActionController) -> float:
	if ai.character.stamina.cur_stamina <= 0: return 0
	var w := 0.0
	for t in ai.targets:
		if t.weapon_manager.attack_state == WeaponManager.AttackState.STUNNED: w += 1.0
		if t.global_position.distance_to(ai.global_position) <= distance_threshhold: w += ai.desire_to_attack - 0.7 + (0.7 * ai.character.stamina.get_ratio())
	
	return w
