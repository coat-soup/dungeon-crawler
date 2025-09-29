extends Node3D
class_name PlayerSkeletonController

@export var cam_holder : Node3D
@export var movement_manager : PlayerMovement

@onready var skeleton: Skeleton3D = $Armature_001/Skeleton3D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var torso_ik: LookAtModifier3D = $Armature_001/Skeleton3D/TorsoIK
@onready var neck_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator
@onready var head_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator/HeadRotator
@export var right_arm_ik : Array[LookAtModifier3D]
@export var left_arm_ik : Array[LookAtModifier3D]

@onready var hand_target_r: Marker3D = $HandTarget_R
@onready var hand_target_l: Marker3D = $HandTarget_L

var held_item
@onready var camera_rt: RemoteTransform3D = $Armature_001/Skeleton3D/CameraAttach/CameraRT
@onready var weapon_rt: RemoteTransform3D = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT

@export var weapon : Weapon


func _ready() -> void:
	camera_rt.remote_path = cam_holder.get_child(0).get_path()
	#cam_holder.get_child(0).reparent(camera_rt)
	#camera_rt.get_child(0).position = Vector3.ZERO
	weapon_rt.remote_path = weapon.get_path()
	#held_item = weapon
	#do_item_ik()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary") and movement_manager.is_multiplayer_authority():
		swing.rpc()


@rpc("any_peer", "call_local")
func swing():
	animation_tree.set("parameters/swing_sword_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _process(delta: float) -> void:
	torso_ik.rotation = -cam_holder.rotation / 2
	neck_rotator.rotation = -cam_holder.rotation / 2
	
	var velocity = movement_manager.velocity_sync.length()
	animation_tree.set("parameters/walk_velocity/blend_position", velocity/movement_manager.speed)
	
	if held_item:
		if len(held_item.hand_positions) > 0:
			hand_target_r.global_position = held_item.hand_positions[0].global_position
			hand_target_r.global_rotation = held_item.hand_positions[0].global_rotation
		if len(held_item.hand_positions) > 1:
			hand_target_l.global_position = held_item.hand_positions[1].global_position
			hand_target_l.global_rotation = held_item.hand_positions[1].global_rotation


func do_item_ik():
	for ik in right_arm_ik: ik.active = held_item and len(held_item.hand_positions) > 0
	for ik in left_arm_ik: ik.active = held_item and len(held_item.hand_positions) > 1
