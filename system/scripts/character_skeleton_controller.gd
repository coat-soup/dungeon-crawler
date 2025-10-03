extends Node3D
class_name CharacterSkeletonController

signal damage_window_toggled(bool)
signal block_window_toggled(bool)

@onready var skeleton: Skeleton3D = $Armature_001/Skeleton3D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var weapon_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/WeaponRotator
@onready var weapon_rotator_ik: LookAtModifier3D = $Armature_001/Skeleton3D/WeaponRotatorIK

@onready var torso_ik: LookAtModifier3D = $Armature_001/Skeleton3D/TorsoIK
@onready var neck_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator
@onready var head_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator/HeadRotator

@onready var hand_ik_r: SkeletonIK3D = $Armature_001/Skeleton3D/HandIK_R
@onready var hand_ik_l: SkeletonIK3D = $Armature_001/Skeleton3D/HandIK_L

var held_item
@onready var weapon_rt: RemoteTransform3D = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT

@export var weapon : Weapon
@export var weapon_manager : WeaponManager


func _ready() -> void:
	weapon_rt.remote_path = weapon.get_path()
	
	hand_ik_r.start()
	hand_ik_l.start()
	
	animation_tree.advance_expression_base_node = weapon_manager.get_path()
	animation_tree.animation_finished.connect(weapon_manager.on_anim_finished)
	$Armature_001/Skeleton3D/TorsoIK/TorsoCollisionRT.remote_path = get_parent().get_node("CollisionTop").get_path()


func start_damage_window(): damage_window_toggled.emit(true)
func stop_damage_window(): damage_window_toggled.emit(false)
func start_block_window(): block_window_toggled.emit(true)
