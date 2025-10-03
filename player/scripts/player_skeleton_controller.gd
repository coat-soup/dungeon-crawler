extends CharacterSkeletonController
class_name PlayerSkeletonController

@export var cam_holder : Node3D
var cam : Node3D
@export var movement_manager : PlayerMovement

@onready var camera_rt: RemoteTransform3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator/HeadRotator/CameraRT


var player_mat_flip : bool = false


func _ready() -> void:
	super._ready()
	cam = cam_holder.get_child(0)
	
	cam.reparent(camera_rt)
	cam.position = Vector3.ZERO
	
	if is_multiplayer_authority():
		$Armature_001/Skeleton3D/WeaponAttach/WeaponRT/WeaponHolder.position = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT/FirstPersonOffset.position
		$Armature_001/Skeleton3D/FPHeadOverride.override_pose = true


func _input(event: InputEvent) -> void:
	if not movement_manager.is_multiplayer_authority(): return
	if Input.is_key_pressed(KEY_P): switch_mat.rpc()


@rpc("any_peer", "call_local")
func switch_mat():
	player_mat_flip = !player_mat_flip
	$Armature_001/Skeleton3D/Cube_004.material_override = preload("res://player/models/player_model_mat_f.tres") if player_mat_flip else preload("res://player/models/player_model_mat_m.tres")
	if is_multiplayer_authority():
		Global.ui.display_chat_message("Switched player: " + ("f" if player_mat_flip else "m"))


func _physics_process(delta: float) -> void:
	torso_ik.rotation = -cam_holder.rotation / 2
	neck_rotator.rotation = -cam_holder.rotation / 2
	
	weapon_rotator.rotation.x = clamp(-cam_holder.rotation.x / 2, deg_to_rad(-30), deg_to_rad(30))
	
	var velocity = movement_manager.velocity_sync.length()
	animation_tree.set("parameters/walk_velocity/blend_position", velocity/movement_manager.speed)
	
	if held_item:
		if len(held_item.hand_positions) > 0: hand_ik_r.target = held_item.hand_positions[0]
		if len(held_item.hand_positions) > 1: hand_ik_r.target = held_item.hand_positions[1]
	
	var swing_speed = 1.0 if weapon_manager.attack_state == weapon_manager.AttackState.IDLE else weapon.speed_multiplier
	if weapon_manager.weapon_bouncing: swing_speed = -0.3
	animation_tree.set("parameters/swing_sword_timescale/scale", swing_speed)
