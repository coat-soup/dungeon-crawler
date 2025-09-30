extends Node
class_name Weapon

@export var hand_positions : Array[Node3D]
@export var speed_multiplier : float = 1.0
@export var damage : int = 10.0

@onready var hitbox: Area3D = $Hitbox
