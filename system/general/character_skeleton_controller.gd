extends Node3D
class_name CharacterSkeletonController

signal damage_window_toggled(bool)
signal block_window_toggled(bool)
signal leap_started

@export var skeleton: Skeleton3D
@onready var animation_tree: AnimationTree = $AnimationTree

@export var movement_manager : CharacterMovementManager

@export var weapon : Weapon
@export var weapon_manager : WeaponManager


func _ready() -> void:
	animation_tree.advance_expression_base_node = weapon_manager.get_path()
	weapon_manager.started_attack.connect(on_started_attack)
	weapon_manager.got_stunned.connect(on_stunned)

func start_damage_window(): damage_window_toggled.emit(true)
func stop_damage_window(): damage_window_toggled.emit(false)
func start_block_window(): block_window_toggled.emit(true)
func start_leap(): leap_started.emit()


func _physics_process(delta: float) -> void:
	var velocity = movement_manager.velocity_sync * movement_manager.body.global_basis
	animation_tree.set("parameters/walk_blendspace/blend_position", Vector2(velocity.x, velocity.z) / movement_manager.speed)


func on_started_attack():
	animation_tree.set("parameters/attack_one_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func on_stunned():
	animation_tree.set("parameters/stun_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
