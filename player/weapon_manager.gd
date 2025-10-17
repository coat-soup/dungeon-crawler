extends Node
class_name WeaponManager

signal started_attack
signal block_state_changed(bool)
signal weapon_bounced
signal weapon_hit_blocker
signal blocked_damage
signal did_damage
signal started_kick

@export var weapon : Weapon
var attack_input_buffer_time : float = 0.3
var attack_input_buffer_timer : float
var attack_input_buffer : AttackState = -1

@export var character_model: CharacterSkeletonController

enum AttackState {IDLE, SWING, ALTSWING, LUNGE, OVERHEAD, KICK}

var attack_state : AttackState

var weapon_bouncing : bool

var idle_pentalty_timer : float = 0.3
var can_attack : bool = true
var blocking : bool
var block_damage_delay : float = 0.3
var blocking_damage : bool
var can_damage : bool
var damaged_objects : Array[Health]
@onready var character : Character = $".."
@export var starting_weapon_path : String = "res://weapons/models/longsword_model.tscn"


func _ready() -> void:
	weapon = character_model.weapon
	weapon.manager = self
	character_model.damage_window_toggled.connect(toggle_damage_window)
	character_model.block_window_toggled.connect(toggle_block_window)
	weapon.hitbox.body_entered.connect(on_weapon_hit)
	weapon.hitbox.area_entered.connect(on_weapon_entered_area)
	
	await get_tree().create_timer(0.5).timeout
	equip_weapon.rpc(starting_weapon_path)


func _process(delta: float) -> void:
	#print("buffer: ", attack_input_buffer)
	if not is_multiplayer_authority(): return
	
	#Global.ui.display_chat_message("blocking damage: " + str(blocking_damage))
	
	if attack_input_buffer_timer > 0:
		attack_input_buffer_timer -= delta
		if attack_input_buffer_timer <= 0:
			attack_input_buffer = -1


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
	return
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
	if not can_damage or body == character: return
	var health : Health = body.get_node_or_null("Health") as Health
	
	if health:
		if health in damaged_objects: return
		damaged_objects.append(health)
		#AudioManager.spawn_sound_at_point(preload("res://sfx/sword_slice.wav"), body.global_position)
		if is_multiplayer_authority():
			health.try_take_blockable_damage.rpc(weapon.damage, int(character.name))
			print("weapon doing damage")
	elif is_multiplayer_authority():
		handle_bonk.rpc()


func on_weapon_entered_area(area : Area3D):
	return
	if not is_multiplayer_authority(): return
	var other_weapon : Weapon = area.get_parent() as Weapon
	if can_damage and other_weapon and other_weapon.manager.blocking and area == other_weapon.block_area:
		handle_block_bounce.rpc()
		print("weapon blocked by weapon")


@rpc("any_peer", "call_local")
func handle_block_bounce():
	toggle_damage_window(false)
	
	weapon_hit_blocker.emit()
	
	weapon_bouncing = true
	await get_tree().create_timer(0.5).timeout
	weapon_bouncing = false
	 
	attack_state = AttackState.IDLE


@rpc("any_peer", "call_local")
func handle_bonk():
	toggle_damage_window(false)
	
	weapon_bounced.emit()
	
	weapon_bouncing = true
	await get_tree().create_timer(0.3).timeout
	weapon_bouncing = false
	 
	attack_state = AttackState.IDLE


@rpc("any_peer", "call_local")
func did_block_damage(amount : int):
	character.stamina.drain_stamina(amount * weapon.block_stamina_drain_damage_mul)
	blocked_damage.emit()


@rpc("any_peer", "call_local")
func kick():
	if attack_state == AttackState.IDLE:
		attack_state = AttackState.KICK
		started_kick.emit()
		
		AudioManager.spawn_sound_at_point(preload("res://sfx/kick.wav"), weapon.global_position, character, 0.05)
		
		var cast = ShapeCast3D.new()
		character.add_child(cast)
		cast.target_position = Vector3(0,1,-1.5)
		cast.shape = SphereShape3D.new()
		cast.shape.radius = 0.5
		cast.collision_mask = Util.layer_mask([2])
		await get_tree().create_timer(0.3).timeout
		
		for i in cast.get_collision_count():
			print("CAST HIT ", cast.get_collider(i))
		
		if cast.is_colliding():
			print("KICK CAST COLLIDING")
			var c = cast.get_collider(0) as Character
			if c:
				c.movement_manager.apply_impulse.rpc(-character.global_basis.z * 10, 0.2)
				print("HIT CHARACTER!!!!!!!!!!!!!!")
		else:
			print("cast not colliding")


@rpc("any_peer", "call_local")
func did_did_damage():
	did_damage.emit()


func buffer_attack(attack_type : AttackState):
	attack_input_buffer = attack_type
	attack_input_buffer_timer = attack_input_buffer_time


@rpc("any_peer", "call_local")
func equip_weapon(weapon_path : String):
	weapon.queue_free()
	weapon = load(weapon_path).instantiate()
	weapon.manager = self
	character_model.weapon_holder.add_child(weapon)
	character_model.handle_weapon_equip(weapon)
	weapon.hitbox.body_entered.connect(on_weapon_hit)
	weapon.hitbox.area_entered.connect(on_weapon_entered_area)
	character.action_manager.get_action_by_name("attack").stamina_cost = weapon.swing_stamina_drain
	character.action_manager.get_action_by_name("block").sustained_stamina_cost = weapon.block_sustain_stamina_drain
