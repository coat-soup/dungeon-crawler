extends CharacterSkeletonController
class_name PlayerSkeletonController

@export var cam_holder : Node3D
var cam : Node3D

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
		#(animation_tree.tree_root.get_node("weapon_attacks_state_machine") as AnimationNodeStateMachine).get_node("idle_anim").animation = "IdleSwordFP"
		#load("res://player/models/player_model.tscn::AnimationNodeAnimation_6nhyr").animation = "IdleSwordFP"
		animation_tree.set("parameters/first_third_person_kick_blend/blend_amount", 1.0)


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
	super._physics_process(delta)
	torso_ik.rotation = -cam_holder.rotation / 2
	neck_rotator.rotation = -cam_holder.rotation / 2
	
	weapon_rotator.rotation.x = clamp(-cam_holder.rotation.x / 2, deg_to_rad(-30), deg_to_rad(30))
