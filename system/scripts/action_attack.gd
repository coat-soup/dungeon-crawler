extends Action
class_name ActionAttack


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.start_attack(args[0])
	character.weapon_manager.weapon_bounced.connect(on_weapon_bounced)
	
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
