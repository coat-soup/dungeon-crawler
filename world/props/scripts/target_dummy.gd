extends Node3D
class_name TargetDummy

@onready var health: Health = $RigidBody3D/Health
@onready var rb: RigidBody3D = $RigidBody3D
@onready var joint: Generic6DOFJoint3D = $Generic6DOFJoint3D

@export var force : float = 1


func _ready() -> void:
	health.took_damage.connect(on_damaged)
	health.died.connect(on_died)


func on_damaged(source_id, damage : float):
	var dir : Vector3 = (Util.random_point_in_sphere(1.0, 1.0) * Vector3(1.0,0,1.0)).normalized()
	var player = Util.get_player_from_id(str(source_id), self)
	if player: dir = (global_position - player.global_position).normalized()
	rb.apply_impulse(dir * force * damage)


func on_died():
	joint.node_a = ""
	
	await get_tree().create_timer(5.0).timeout
	health.heal(100)
	rb.linear_velocity = Vector3.ZERO
	rb.angular_velocity = Vector3.ZERO
	rb.position = Vector3.ZERO
	rb.rotation = Vector3.ZERO
	joint.node_a = rb.get_path()
