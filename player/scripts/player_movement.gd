extends Node
class_name PlayerMovement

signal dash

@onready var camera_pivot: Node3D = $"../CameraPivot"
@onready var camera: Camera3D = $"../CameraPivot/Camera"

#@onready var health: PlayerHealth = $Health
@onready var weapon_manager: WeaponManager = $"../WeaponManager"

@export var body : Player

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var sensetivity = 0.005;

@export var dash_speed = 15
@export var dash_length = 0.2
@export var dash_cooldown = 1.5
var dash_cooldown_timer = 0
var dash_timer = 0
var dash_dir

#viewbob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var t_bob : float = 0.0

signal bob_top
signal bob_bottom

var landing : bool
signal jump_start
signal jump_land


var debug_mode = false

var interact_object

@onready var stamina: Stamina = $"../Stamina"
@export var velocity_sync : Vector3


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_key_pressed(KEY_SEMICOLON):
		debug_mode = !debug_mode
		if debug_mode:
			body.collision_mask = 0
			body.collision_layer = 0
		else:
			body.collision_mask = Util.layer_mask([1])
			body.collision_layer = Util.layer_mask([1])


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens_mul = 1.0 if weapon_manager.attack_state == weapon_manager.AttackState.IDLE else 0.2
		body.rotate_y(-event.relative.x * sensetivity * sens_mul)
		camera_pivot.rotate_x(-event.relative.y * sensetivity * sens_mul)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if not body.is_on_floor() and !debug_mode:
		body.velocity += body.get_gravity() * delta
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if debug_mode:
		body.velocity.y = (int(Input.is_key_pressed(KEY_SPACE)) - int(Input.is_key_pressed(KEY_CTRL))) * speed
	
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		if stamina.cur_stamina > 0:
			if input_dir.y < 0 or input_dir == Vector2.ZERO:
				jump_start.emit()
				body.velocity.y = jump_velocity
			elif dash_cooldown_timer <= 0:
				dash.emit()
				dash_dir = direction
				dash_timer = dash_length
		else:
			stamina.alert_anim()
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			dash_cooldown_timer = dash_cooldown
		body.velocity.x = lerp(body.velocity.x, dash_dir.x * dash_speed, delta * 10)
		body.velocity.z = lerp(body.velocity.z, dash_dir.z * dash_speed, delta * 10)
	elif body.is_on_floor():
		if direction:
			body.velocity.x = direction.x * speed
			body.velocity.z = direction.z * speed
		else:
			body.velocity.x = lerp(body.velocity.x, direction.x * speed, delta * 10)
			body.velocity.z = lerp(body.velocity.z, direction.z * speed, delta * 10)
		
		if landing:
			landing = false
			if body.velocity.y < 1:
				jump_land.emit()
	else:
		body.velocity.x = lerp(body.velocity.x, direction.x * speed, delta * 2)
		body.velocity.z = lerp(body.velocity.z, direction.z * speed, delta * 2)
		
		if !landing:
			landing = true
	
	
	#viewbob
	t_bob += delta * body.velocity.length() * float(body.is_on_floor())
	var b : float = bob_calc(t_bob)
	#camera.transform.origin = Vector3(0, b, 0)
	
	#bob signals
	if b/BOB_AMP < 0.05:
		bob_bottom.emit()
	elif b/BOB_AMP > 0.95:
		bob_top.emit()
	
	velocity_sync = body.velocity
	body.move_and_slide()


func bob_calc(time : float) -> float:
	return BOB_AMP * sin(time * BOB_FREQ)
