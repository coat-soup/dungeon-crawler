extends Camera3D
class_name CameraShake

@export var max_x : float = 10.0
@export var max_y : float = 10.0
@export var max_z : float = 5.0

var intensity : float = 0.0
@export var fade_rate : float = 1.0
@export var noise : FastNoiseLite 
@export var noise_speed := 50.0
var time : float


func _process(delta: float) -> void:
	time += delta
	if intensity > 0: intensity = max(0, intensity - fade_rate * delta)
	
	rotation.x = deg_to_rad(max_x * get_shake_intensity() * get_noise_from_seed(0))
	rotation.y = deg_to_rad(max_y * get_shake_intensity() * get_noise_from_seed(1))
	rotation.z = deg_to_rad(max_z * get_shake_intensity() * get_noise_from_seed(2))


func shake(amount : float):
	intensity = clamp(intensity + amount, 0.0, 1.0)


func get_shake_intensity() -> float:
	return intensity * intensity


func get_noise_from_seed(seed : int) -> float:
	noise.seed = seed
	return noise.get_noise_1d(time * noise_speed)
