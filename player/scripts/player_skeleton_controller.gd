extends Node3D
class_name PlayerSkeletonController

@export var cam_holder : Node3D
@export var movement_manager : PlayerMovement

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
@onready var camera_rt: RemoteTransform3D = $Armature_001/Skeleton3D/CameraAttach/CameraRT
@onready var weapon_rt: RemoteTransform3D = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT

@export var weapon : Weapon


func _ready() -> void:
	camera_rt.remote_path = cam_holder.get_child(0).get_path()
	weapon_rt.remote_path = weapon.get_path()
	
	hand_ik_r.start()
	hand_ik_l.start()
	
	if is_multiplayer_authority():
		$Armature_001/Skeleton3D/WeaponAttach/WeaponRT/WeaponHolder.position = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT/FirstPersonOffset.position



func _input(event: InputEvent) -> void:
	if not movement_manager.is_multiplayer_authority(): return
	if event.is_action_pressed("primary"): swing.rpc()
	if event.is_action_pressed("secondary"): toggle_blocking.rpc(true)
	if event.is_action_released("secondary"): toggle_blocking.rpc(false)


@rpc("any_peer", "call_local")
func swing():
	animation_tree.set("parameters/swing_sword_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


@rpc("any_peer", "call_local")
func toggle_blocking(value : bool):
	animation_tree.set("parameters/idle_blocking_transition/transition_request", "state_blocking" if value else "state_idle")


func _physics_process(delta: float) -> void:
	torso_ik.rotation = -cam_holder.rotation / 2
	neck_rotator.rotation = -cam_holder.rotation / 2
	weapon_rotator.rotation.x = clamp(-cam_holder.rotation.x / 2, deg_to_rad(-30), deg_to_rad(30))
	
	var velocity = movement_manager.velocity_sync.length()
	animation_tree.set("parameters/walk_velocity/blend_position", velocity/movement_manager.speed)
	
	if held_item:
		if len(held_item.hand_positions) > 0: hand_ik_r.target = held_item.hand_positions[0]
		if len(held_item.hand_positions) > 1: hand_ik_r.target = held_item.hand_positions[1]
