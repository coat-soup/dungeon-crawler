extends Node
class_name Weapon

@export var hand_positions : Array[Node3D]
@export var speed_multiplier : float = 1.0
@export var damage : int = 30
@export var swing_stamina_drain : float = 8.0
@export var block_stamina_drain_damage_mul : float = 0.7
@export var block_sustain_stamina_drain : float = 3.0

@export var hitbox: Area3D
@export var block_area : Area3D

var manager : WeaponManager
