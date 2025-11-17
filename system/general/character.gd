extends CharacterBody3D
class_name Character

@export var action_manager : ActionManager
@export var weapon_manager : WeaponManager
@export var health : Health
@export var movement_manager : CharacterMovementManager
@export var stamina : Stamina

var active : bool = true


func _ready():
	pass

func disable_character():
	#only really called from enemies
	collision_layer = 0
	active = false
