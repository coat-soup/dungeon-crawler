extends CharacterMovementManager
class_name PlayerMovement

@onready var camera_pivot: Node3D = $"../CameraPivot"
@onready var camera: Camera3D = $"../CameraPivot/Camera"

@export var sensetivity = 0.005;


#viewbob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var t_bob : float = 0.0

signal bob_top
signal bob_bottom


var debug_mode = false

var interact_object
var player_input_dir : Vector2


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
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
		var sens_mul = 1.0 if weapon_manager.attack_state == weapon_manager.AttackState.IDLE or weapon_manager.attack_state == weapon_manager.AttackState.STUNNED else 0.2
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
