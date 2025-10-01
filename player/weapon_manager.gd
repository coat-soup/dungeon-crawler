extends Node
class_name WeaponManager

signal started_attack
signal block_state_changed(bool)
signal hitbox_hit(Node3D)

@export var weapon : Weapon
var attack_input_buffer_time : float = 0.5
var attack_input_buffer_timer : float
var attack_input_buffer : AttackState = -1

@export var player_model: PlayerSkeletonController

enum AttackState {IDLE, SWING, ALTSWING, LUNGE, OVERHEAD}

var attack_state : AttackState

var blocking : bool
var can_damage : bool
var damaged_objects : Array[Node3D]
@onready var player : Player = $".."


func _ready() -> void:
	weapon = player_model.weapon
	player_model.damage_window_toggled.connect(toggle_damage_window)
	weapon.hitbox.body_entered.connect(on_weapon_hit)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("primary"): try_start_attack(AttackState.SWING)
	if event.is_action_pressed("alt_swing"): try_start_attack(AttackState.ALTSWING)
	if event.is_action_pressed("lunge"): try_start_attack(AttackState.LUNGE)
	if event.is_action_pressed("overhead"): try_start_attack(AttackState.OVERHEAD)
	
	if event.is_action_pressed("secondary"): toggle_blocking.rpc(true)
	if event.is_action_released("secondary"): toggle_blocking.rpc(false)


func _process(delta: float) -> void:
	if attack_input_buffer_timer > 0:
		attack_input_buffer_timer -= delta
		if attack_input_buffer_time <= 0: attack_input_buffer = -1


func try_start_attack(attack_type : AttackState):
	if not is_multiplayer_authority(): return
	start_attack.rpc(attack_type)


@rpc("any_peer", "call_local")
func start_attack(attack_type : AttackState):
	if attack_state == AttackState.IDLE:
		attack_state = attack_type
	else:
		if attack_state == AttackState.SWING: attack_type = AttackState.ALTSWING
		attack_input_buffer = attack_type
		attack_input_buffer_timer = attack_input_buffer_time


@rpc("any_peer", "call_local")
func toggle_blocking(value : bool):
	blocking = value
	block_state_changed.emit(value)


func toggle_damage_window(value : bool):
	can_damage = value
	if not can_damage: damaged_objects.clear()


func on_anim_finished(anim_name : String):
	if attack_input_buffer_timer > 0 and attack_input_buffer != -1 and attack_input_buffer != attack_state:
		attack_state = attack_input_buffer
		attack_input_buffer = -1
	else:
		attack_state = AttackState.IDLE


func on_weapon_hit(body : Node3D):
	if not is_multiplayer_authority(): return
	if not can_damage or body == player or body in damaged_objects: return
	damaged_objects.append(body)
	print(damaged_objects)
	var health : Health = body.get_node("Health") as Health
	if health:
		health.take_damage.rpc(weapon.damage, int(player.name))
