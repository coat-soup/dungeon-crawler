extends Node3D
class_name CharacterSkeletonController

signal damage_window_toggled(bool)
signal block_window_toggled(bool)
signal leap_started

@export var character : Character

@export var skeleton: Skeleton3D
@onready var animation_tree: AnimationTree = $AnimationTree

@export var movement_manager : CharacterMovementManager

@export var weapon : Weapon
@export var weapon_manager : WeaponManager


func _ready() -> void:
	animation_tree.advance_expression_base_node = weapon_manager.get_path()
	weapon_manager.started_attack.connect(on_started_attack)
	weapon_manager.got_stunned.connect(on_stunned)
	character.health.took_damage.connect(on_damaged)

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

func on_damaged(amount, source_id):
	if character.health.cur_health > 0: return
	var phys_mod = skeleton.get_node_or_null("PhysicalBoneSimulator3D")
	if phys_mod:
		phys_mod.physical_bones_start_simulation()
		var attacker : Character = Util.get_character_from_id(str(source_id), self) as Character
		
		var pelvis = phys_mod.get_node("Physical Bone Pelvis") as PhysicalBone3D
		
		var push_dir : Vector3 = Vector3.ZERO
		match attacker.weapon_manager.attack_state:
			WeaponManager.AttackState.SWING: push_dir = -attacker.global_basis.x
			WeaponManager.AttackState.ALTSWING: push_dir = attacker.global_basis.x
			WeaponManager.AttackState.OVERHEAD: push_dir = -attacker.global_basis.z
			WeaponManager.AttackState.LUNGE:
				pelvis.linear_damp += 100
				pelvis.angular_damp += 100
				await get_tree().create_timer(0.3).timeout
				pelvis.linear_damp -= 100
				pelvis.angular_damp -= 100
		pelvis.apply_impulse(push_dir * 100 * attacker.weapon_manager.weapon.damage / 30)
