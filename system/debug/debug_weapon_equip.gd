extends Area3D
class_name DebugWeaponEquip

@export var weapon_path : String


func _ready() -> void:
	collision_mask = 2
	body_entered.connect(on_body_entered)


func on_body_entered(body : Node3D):
	body = body as Character
	if body and body.is_multiplayer_authority(): body.weapon_manager.equip_weapon.rpc(weapon_path)
