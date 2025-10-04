extends Area3D
class_name AIActionController


@onready var character: Character = $".."
@onready var action_manager: ActionManager = $"../ActionManager"

var targets : Array[Character]
var action_weights = {}
var tick_speed = 5.0

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	collision_mask = Util.layer_mask([2])
	
	process_tick()


func process_tick():
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
	var char = body as Character
	if char and char != character:
		targets.append(char)


func on_body_exited(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Character
	if char and char != character:
		var id = targets.find(char)
		if id != -1: targets.remove_at(id)
