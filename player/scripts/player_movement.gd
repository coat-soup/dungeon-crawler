extends CharacterMovementManager
class_name PlayerMovement

@onready var camera_pivot: Node3D = $"../CameraPivot"
@onready var camera: Camera3D = $"../CameraPivot/Camera"

@export var sensetivity = 0.005
@export var slow_sens_mul : float = 0.2
@export var swing_slow_sens_curve : Curve

#viewbob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var t_bob : float = 0.0

signal bob_top
signal bob_bottom


var debug_mode = false
var og_col
var og_mask

var interact_object
var player_input_dir : Vector2
var normalised_swing_position : float


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	body.weapon_manager.started_attack.connect(on_started_attack)
	body.weapon_manager.weapon_bounced.connect(on_weapon_bounced)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_key_pressed(KEY_SEMICOLON):
		debug_mode = !debug_mode
		if debug_mode:
			og_mask = body.collision_mask
			og_col = body.collision_layer
			body.collision_mask = 0
			body.collision_layer = 0
		else:
			body.collision_mask = og_mask
			body.collision_layer = og_col


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens_mul = 1.0 if weapon_manager.attack_state == weapon_manager.AttackState.IDLE or weapon_manager.attack_state == weapon_manager.AttackState.STUNNED else 0.2
		if weapon_manager.attack_state == WeaponManager.AttackState.STUNNED:
			sens_mul = slow_sens_mul
		else:
			sens_mul = lerp(min(1.0, slow_sens_mul * weapon_manager.weapon.speed_multiplier), 1.0, swing_slow_sens_curve.sample(1 - normalised_swing_position))
		body.rotate_y(-event.relative.x * sensetivity * sens_mul * Settings.get_setting("look_sensetivity"))
		camera_pivot.rotate_x(-event.relative.y * sensetivity * sens_mul * Settings.get_setting("look_sensetivity"))
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_multiplayer_authority(): return
	player_input_dir = Input.get_vector("left", "right", "up", "down")
	input_direction = (body.transform.basis * Vector3(player_input_dir.x, 0, player_input_dir.y)).normalized()
	
	if debug_mode:
		body.velocity.y = (int(Input.is_key_pressed(KEY_SPACE)) - int(Input.is_key_pressed(KEY_CTRL))) * speed
	
	if normalised_swing_position > -0.5:
		normalised_swing_position -= delta * weapon_manager.weapon.speed_multiplier * (1.0 if weapon_manager.attack_state != WeaponManager.AttackState.LUNGE else weapon_manager.weapon.lunge_speed_mult)
	
	#viewbob
	t_bob += delta * body.velocity.length() * float(body.is_on_floor())
	var b : float = bob_calc(t_bob)
	#camera.transform.origin = Vector3(0, b, 0)
	
	#bob signals
	if b/BOB_AMP < 0.05:
		bob_bottom.emit()
	elif b/BOB_AMP > 0.95:
		bob_top.emit()


func bob_calc(time : float) -> float:
	return BOB_AMP * sin(time * BOB_FREQ)


func on_started_attack():
	normalised_swing_position = 1

func on_weapon_bounced():
	normalised_swing_position = min(normalised_swing_position, 0.0)

func get_speed() -> float:
	return super.get_speed() * (5.0 if debug_mode and sprinting else 1.0)
