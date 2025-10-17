extends Character
class_name Player

@onready var movement: PlayerMovement = $Movement
@export var camera: CameraShake
@export var input_manager : PlayerInputManager


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	super._ready()
	if is_multiplayer_authority():
		Global.local_player = self
		
		camera.current = true
		(camera.get_child(0) as AudioListener3D).current = true
		health.took_damage.connect(on_player_damaged)
		stamina.stamina_changed.connect(on_stamina_changed)
		weapon_manager.blocked_damage.connect(on_weapon_blocked)
		weapon_manager.did_damage.connect(on_weapon_connected)
		weapon_manager.weapon_bounced.connect(on_weapon_connected)


func on_player_damaged(_source, _damage):
	Global.ui.update_health_bar(health.cur_health)
	camera.shake(0.7)


func on_weapon_connected():
	camera.shake(0.3)


func on_weapon_blocked():
	camera.shake(0.5)

func on_stamina_changed():
	Global.ui.update_stamina_bar(stamina.cur_stamina/stamina.max_stamina)
