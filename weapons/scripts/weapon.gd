extends Node
class_name Weapon

@export var hand_positions : Array[Node3D]
@export var speed_multiplier : float = 1.0
@export var damage : int = 10

@export var hitbox: Area3D

@onready var tip_marker: Marker3D = $TipMarker

var swing_direction : Vector3
var prev_tip_marker_pos : Vector3


func _physics_process(_delta: float) -> void:
	swing_direction = (prev_tip_marker_pos - tip_marker.global_position).normalized()
	prev_tip_marker_pos = tip_marker.global_position
