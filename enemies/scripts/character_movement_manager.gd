extends Node
class_name CharacterMovementManager

signal dash

#@onready var health: PlayerHealth = $Health
@onready var weapon_manager: WeaponManager = $"../WeaponManager"

@export var body : Character

@export var speed = 5.0
@export var jump_velocity = 4.5

@export var dash_speed = 15
@export var dash_length = 0.2
@export var dash_cooldown = 1.5
var dash_cooldown_timer = 0
var dash_timer = 0
var dash_dir

var landing : bool
signal jump_start
signal jump_land

@onready var stamina: Stamina = $"../Stamina"
@export var velocity_sync : Vector3

var input_direction : Vector3


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta
	
	#var direction : Vector3 = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			dash_cooldown_timer = dash_cooldown
		body.velocity.x = lerp(body.velocity.x, dash_dir.x * dash_speed, delta * 10)
		body.velocity.z = lerp(body.velocity.z, dash_dir.z * dash_speed, delta * 10)
	elif body.is_on_floor():
		if input_direction:
			body.velocity.x = input_direction.x * get_speed()
			body.velocity.z = input_direction.z * get_speed()
		else:
			body.velocity.x = lerp(body.velocity.x, input_direction.x * get_speed(), delta * 10)
			body.velocity.z = lerp(body.velocity.z, input_direction.z * get_speed(), delta * 10)
		
		if landing:
			landing = false
			if body.velocity.y < 1:
				jump_land.emit()
	else:
		body.velocity.x = lerp(body.velocity.x, input_direction.x * get_speed(), delta * 2)
		body.velocity.z = lerp(body.velocity.z, input_direction.z * get_speed(), delta * 2)
		
		if !landing:
			landing = true
	
	velocity_sync = body.velocity
	body.move_and_slide()


func jump_input():
	if body.is_on_floor():
		jump_start.emit()
		body.velocity.y = jump_velocity


func dash_input():
	if body.is_on_floor():
		dash.emit()
		dash_dir = input_direction
		dash_timer = dash_length


func get_speed() -> float:
	var relative_input = (Vector3(input_direction.x, 0, input_direction.z) * body.transform.basis).normalized()
	return speed if relative_input.z < 0 else speed * 0.6
