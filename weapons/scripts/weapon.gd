extends Node
class_name Weapon

@export var hand_positions : Array[Node3D]
@export var speed_multiplier : float = 1.0
@export var damage : int = 30
@export var swing_stamina_drain : float = 10.0
@export var block_stamina_drain : float = 0.7

@export var hitbox: Area3D
