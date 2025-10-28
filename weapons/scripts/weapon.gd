extends Node3D
class_name Weapon

@export var hand_positions : Array[Node3D]
@export var speed_multiplier : float = 1.0
@export var damage : int = 30
@export var overhead_damage : int = 45
@export var lunge_speed_mult : float = 1.5
@export var swing_stamina_drain : float = 8.0
@export var block_stamina_drain_damage_mul : float = 0.5
@export var block_sustain_stamina_drain : float = 3.0
@export var block_durability_drain_mul : float = 1.0

@export var is_bespoke : bool = false

@export var hitbox: Area3D
@export var block_area : Area3D

var manager : WeaponManager
