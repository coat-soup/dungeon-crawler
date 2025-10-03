extends Character
class_name Player

@onready var movement: PlayerMovement = $Movement
@export var camera: Camera3D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	super._ready()
	if is_multiplayer_authority():
		camera.current = true
		(camera.get_child(0) as AudioListener3D).current = true
		health.took_damage.connect(on_player_damaged)


func on_player_damaged(_source, _damage):
	Global.ui.update_health_bar(health.cur_health)
