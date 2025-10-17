extends Node
class_name PlayerInputManager

@export var movement : PlayerMovement
@export var action_manager : ActionManager
var block_reset := true

var active : bool = true


func _ready() -> void:
	action_manager.performed_action.connect(on_action_performed)


func _input(event: InputEvent) -> void:
	if not active or not is_multiplayer_authority(): return
	if event.is_action_pressed("alt_swing"): attack_or_buffer(WeaponManager.AttackState.ALTSWING)
	elif event.is_action_pressed("primary"): attack_or_buffer(WeaponManager.AttackState.SWING)
	if event.is_action_pressed("lunge"): attack_or_buffer(WeaponManager.AttackState.LUNGE)
	if event.is_action_pressed("overhead"): attack_or_buffer(WeaponManager.AttackState.OVERHEAD)
	
	if event.is_action_pressed("kick"): action_manager.try_perform_action_by_name("kick")
	
	#if event.is_action_pressed("secondary"): toggle_blocking.rpc(true) # handled in process
	if event.is_action_released("secondary"):
		action_manager.try_stop_action_by_name("block")
		block_reset = true
	
	if event.is_action_pressed("jump"):
		if movement.player_input_dir.y < 0 or movement.player_input_dir == Vector2.ZERO: movement.jump_input()
		else:
			print("player dashing")
			action_manager.try_perform_action_by_name("dash")
	
	if event.is_action_pressed("sprint") : action_manager.try_perform_action_by_name("sprint")
	if event.is_action_released("sprint") : action_manager.try_stop_action_by_name("sprint")


func _process(delta: float) -> void:
	if not active or not is_multiplayer_authority(): return
	if block_reset and Input.is_action_pressed("secondary"):
		action_manager.try_perform_action_by_name("block")


func attack_or_buffer(attack_type : WeaponManager.AttackState):
	if action_manager.is_performing_blocking_action():
		# buffer
		if attack_type == WeaponManager.AttackState.SWING and action_manager.character.weapon_manager.attack_state == WeaponManager.AttackState.SWING:
			attack_type = WeaponManager.AttackState.ALTSWING
		action_manager.character.weapon_manager.buffer_attack(attack_type)
	else:
		action_manager.try_perform_action_by_name("attack", [attack_type])


func on_action_performed(action : Action):
	if action.action_name == "block": block_reset = false
