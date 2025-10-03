extends Node
class_name PlayerInputManager

@export var action_manager : ActionManager


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("alt_swing"): action_manager.try_perform_action_by_name("attack", [WeaponManager.AttackState.ALTSWING])
	elif event.is_action_pressed("primary"): action_manager.try_perform_action_by_name("attack", [WeaponManager.AttackState.SWING])
	if event.is_action_pressed("lunge"): action_manager.try_perform_action_by_name("attack", [WeaponManager.AttackState.LUNGE])
	if event.is_action_pressed("overhead"): action_manager.try_perform_action_by_name("attack", [WeaponManager.AttackState.OVERHEAD])
	
	#if event.is_action_pressed("secondary"): toggle_blocking.rpc(true) # handled in process
	if event.is_action_released("secondary"): action_manager.try_stop_action_by_name("block")


func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_action_pressed("secondary"): action_manager.try_perform_action_by_name("block")
