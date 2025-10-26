extends CharacterSkeletonController
class_name HumanoidSkeletonController


@onready var weapon_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/WeaponRotator
@onready var weapon_rotator_ik: LookAtModifier3D = $Armature_001/Skeleton3D/WeaponRotatorIK

@onready var torso_ik: LookAtModifier3D = $Armature_001/Skeleton3D/TorsoIK
@onready var neck_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator
@onready var head_rotator: Node3D = $Armature_001/Skeleton3D/TorsoIK/NeckRotator/HeadRotator

@onready var hand_ik_r: SkeletonIK3D = $Armature_001/Skeleton3D/HandIK_R
@onready var hand_ik_l: SkeletonIK3D = $Armature_001/Skeleton3D/HandIK_L

var held_item
@onready var weapon_rt: RemoteTransform3D = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT
@onready var weapon_holder: Node3D = $Armature_001/Skeleton3D/WeaponAttach/WeaponRT/WeaponHolder


func _ready() -> void:
	super._ready()
	
	weapon_rt.remote_path = weapon.get_path()
	
	hand_ik_r.start()
	hand_ik_l.start()
	
	weapon_manager.started_kick.connect(on_started_kick)
	$Armature_001/Skeleton3D/TorsoIK/TorsoCollisionRT.remote_path = get_parent().get_node("CollisionTop").get_path()


func handle_weapon_equip(_weapon : Weapon):
	weapon = _weapon
	var left_needed = len(weapon.hand_positions) > 1
	hand_ik_r.target_node = weapon.hand_positions[0].get_path()
	if left_needed:
		hand_ik_l.start()
		hand_ik_l.target_node = weapon.hand_positions[1].get_path()
	else: hand_ik_l.stop()
	animation_tree.set("parameters/left_arm_item_blend/blend_amount", 0.0 if left_needed else 1.0)


func on_started_kick():
	animation_tree.set("parameters/kick_one_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func start_damage_window(): damage_window_toggled.emit(true)
func stop_damage_window(): damage_window_toggled.emit(false)
func start_block_window(): block_window_toggled.emit(true)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if held_item:
		if len(held_item.hand_positions) > 0: hand_ik_r.target = held_item.hand_positions[0]
		if len(held_item.hand_positions) > 1: hand_ik_r.target = held_item.hand_positions[1]
	
	var swing_speed = 1.0 if weapon_manager.attack_state == weapon_manager.AttackState.IDLE else (weapon.speed_multiplier * (weapon.lunge_speed_mult if weapon_manager.attack_state == weapon_manager.AttackState.LUNGE else 1.0))
	if weapon_manager.weapon_bouncing: swing_speed = -0.3
	animation_tree.set("parameters/swing_sword_timescale/scale", swing_speed)
