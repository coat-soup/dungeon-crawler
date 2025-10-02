extends Node
class_name WeaponManager

signal started_attack
signal block_state_changed(bool)
signal hitbox_hit(Node3D)
signal weapon_bounced
signal blocked_damage

@export var weapon : Weapon
var attack_input_buffer_time : float = 0.3
var attack_input_buffer_timer : float
var attack_input_buffer : AttackState = -1

@export var player_model: PlayerSkeletonController

enum AttackState {IDLE, SWING, ALTSWING, LUNGE, OVERHEAD}

var attack_state : AttackState

var weapon_bouncing : bool

var idle_pentalty_timer : float = 0.3
var can_attack : bool = true
var blocking : bool
var block_damage_delay : float = 0.3
var blocking_damage : bool
var can_damage : bool
var damaged_objects : Array[Health]
@onready var player : Player = $".."


func _ready() -> void:
	weapon = player_model.weapon
	player_model.damage_window_toggled.connect(toggle_damage_window)
	player_model.block_window_toggled.connect(toggle_block_window)
	weapon.hitbox.body_entered.connect(on_weapon_hit)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("alt_swing"):
		try_start_attack(AttackState.ALTSWING)
	elif event.is_action_pressed("primary"): try_start_attack(AttackState.SWING)
	if event.is_action_pressed("lunge"): try_start_attack(AttackState.LUNGE)
	if event.is_action_pressed("overhead"): try_start_attack(AttackState.OVERHEAD)
	
	#if event.is_action_pressed("secondary"): toggle_blocking.rpc(true) # handled in process
	if event.is_action_released("secondary"): toggle_blocking.rpc(false)


func _process(delta: float) -> void:
	#print("buffer: ", attack_input_buffer)
	if not is_multiplayer_authority(): return
	
	if Input.is_action_pressed("secondary") and not blocking: toggle_blocking.rpc(true)
	
	#Global.ui.display_chat_message("blocking damage: " + str(blocking_damage))
	
	if attack_input_buffer_timer > 0:
		attack_input_buffer_timer -= delta
		if attack_input_buffer_time <= 0: attack_input_buffer = -1


func try_start_attack(attack_type : AttackState):
	if not is_multiplayer_authority() or not can_attack: return
	if attack_state == AttackState.IDLE:
		#print("starting attack from idle ", attack_type)
		start_attack.rpc(attack_type)
	else:
		if attack_state == AttackState.SWING and attack_type == AttackState.SWING: attack_type = AttackState.ALTSWING
		attack_input_buffer = attack_type
		attack_input_buffer_timer = attack_input_buffer_time


@rpc("any_peer", "call_local")
func start_attack(attack_type : AttackState):
	#print("prevstate for attack %d ->" % attack_state)
	attack_state = attack_type
	started_attack.emit()
	#print("starting attack ", attack_state)


@rpc("any_peer", "call_local")
func set_attack_state(attack_type : AttackState):
	attack_state = attack_type
	#print("direct set to ", attack_state)


@rpc("any_peer", "call_local")
func toggle_blocking(value : bool):
	blocking = value
	block_state_changed.emit(value)
	if not blocking: blocking_damage = false
	else:
		await get_tree().create_timer(block_damage_delay).timeout
		blocking_damage = true


func toggle_damage_window(value : bool):
	can_damage = value
	if not can_damage: damaged_objects.clear()


func toggle_block_window(value : bool):
	blocking_damage = value


func on_anim_finished(anim_name : String):
	if not is_multiplayer_authority(): return
	#print("anim finished. conditions for buffer: %d != -1 (%s) and %d != %d (%s)" % [attack_input_buffer, attack_input_buffer != -1, attack_input_buffer, attack_state, attack_input_buffer != attack_state])
	if attack_input_buffer != -1 and attack_input_buffer != attack_state:
		#print("buffering ", attack_input_buffer)
		start_attack.rpc(attack_input_buffer)
		attack_input_buffer = -1
	else:
		#print("setting to idle")
		can_attack = false
		set_attack_state.rpc(AttackState.IDLE)
		await get_tree().create_timer(idle_pentalty_timer).timeout
		can_attack = true


func on_weapon_hit(body : Node3D):
	if not can_damage or body == player: return
	var health : Health = body.get_node_or_null("Health") as Health
	if health:
		if health in damaged_objects: return
		damaged_objects.append(health)
		AudioManager.spawn_sound_at_point(preload("res://sfx/sword_slice.wav"), body.global_position)
		if is_multiplayer_authority():
			health.try_take_blockable_damage.rpc(weapon.damage, int(player.name))
	elif is_multiplayer_authority():
		handle_bonk.rpc()


@rpc("any_peer", "call_local")
func handle_bonk():
	toggle_damage_window(false)
	
	weapon_bounced.emit()
	
	weapon_bouncing = true
	await get_tree().create_timer(0.3).timeout
	weapon_bouncing = false
	 
	attack_state = AttackState.IDLE


@rpc("any_peer", "call_local")
func did_block_damage():
	blocked_damage.emit()
