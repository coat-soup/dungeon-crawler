extends Area3D
class_name AIActionController


@onready var character: Character = $".."
@onready var action_manager: ActionManager = $"../ActionManager"

var targets : Array[Character]
var action_weights = {}
var tick_speed = 5.0

@export var profficiency = 1.0
@export var agression_level = 1.0
var desire_to_attack : float = 0.0

var block_reaction_bonuses = [0,0,0]


func _ready() -> void:
	if not multiplayer.is_server(): return
	
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	collision_mask = Util.layer_mask([2])
	
	action_manager.performed_action.connect(on_action_performed)
	
	character.health.took_damage.connect(on_hit_by_weapon)
	character.health.blocked_damage.connect(on_hit_by_weapon)
	
	await get_tree().process_frame
	process_tick()


func process_tick():
	desire_to_attack = min(1, desire_to_attack + (0.1 * agression_level) / tick_speed)
	
	check_action_weights()
	await get_tree().create_timer(1.0/tick_speed).timeout
	process_tick()


func check_action_weights():
	for action in action_manager.action_set:
		action_weights[action.action_name] = action.get_ai_action_weight(self)
	
	var best_blocking_action_id = -1
	var best_blocking_action_weight = -1
	for i in range(len(action_manager.action_set)):
		if action_manager.action_set[i].action_type == Action.ActionType.BLOCKING:
			if action_weights[action_manager.action_set[i].action_name] > best_blocking_action_weight:
				best_blocking_action_id = i
				best_blocking_action_weight = action_weights[action_manager.action_set[i].action_name]
	
	for i in range(len(action_manager.action_set)):
		if action_weights[action_manager.action_set[i].action_name] > 0.5 and (action_manager.action_set[i].action_type == Action.ActionType.NONBLOCKING or i == best_blocking_action_id):
			action_manager.try_perform_action_by_name(action_manager.action_set[i].action_name, action_manager.action_set[i].get_ai_call_args(self))
		else:
			action_manager.try_stop_action_by_name(action_manager.action_set[i].action_name)


func on_body_entered(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Player
	if char and char != character:
		targets.append(char)


func on_body_exited(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Player
	if char and char != character:
		var id = targets.find(char)
		if id != -1: targets.remove_at(id)


func on_action_performed(action : Action):
	if action.action_name == "attack":
		desire_to_attack -= 0.3 / agression_level


func on_hit_by_weapon(amount : int, source_id : int):
	var character : Character = Util.get_character_from_id(str(source_id), self) as Character
	if character:
		improve_react_to_attack(character.weapon_manager.attack_state)


func improve_react_to_attack(attack : WeaponManager.AttackState):
	var id = attack_type_to_id(attack)
	if id == -1: return
	
	block_reaction_bonuses[id] += 0.5 * profficiency
	
	# normalise
	var total = block_reaction_bonuses[0] + block_reaction_bonuses[1] + block_reaction_bonuses[2]
	if total > 1:
		for i in range(3):
			block_reaction_bonuses[i] *= 1/total


func get_block_reaction_bonus(attack: WeaponManager.AttackState) -> float:
	var id = attack_type_to_id(attack)
	if id == -1: return 0
	return block_reaction_bonuses[id]


func attack_type_to_id(attack: WeaponManager.AttackState) -> int:
	match attack:
		WeaponManager.AttackState.SWING, WeaponManager.AttackState.ALTSWING: return 0
		WeaponManager.AttackState.LUNGE: return 2
		WeaponManager.AttackState.OVERHEAD: return 1
		_: return -1
