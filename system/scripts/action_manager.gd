extends Node
class_name ActionManager

signal performed_action(Action)
signal ended_action(Action)

@onready var character: Character = $".."
@export var action_set : Array[Action]
var current_actions : Array[Action]


func try_perform_action_by_name(action_name : String, args : Array = []) -> bool:
	if character.weapon_manager.attack_state == WeaponManager.AttackState.STUNNED: return false
	
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name:
			return false
	
	for i in range(len(action_set)):
		if action_set[i].action_name == action_name and action_set[i].can_perform_action(character):
			perform_action.rpc(i, args)
			return true
	
	return false


func try_stop_action_by_name(action_name : String, override_cancellable : bool = false):
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name and not current_actions[i].cancellable and not override_cancellable:
			return
	end_action.rpc(action_name)


func is_performing_action_by_name(action_name : String) -> bool:
	for action in current_actions:
		if action.action_name == action_name: return true
	return false


func is_performing_blocking_action() -> bool:
	for action in current_actions:
		if action.action_type == Action.ActionType.BLOCKING: return true
	return false


@rpc("any_peer", "call_local")
func perform_action(action_id : int, args : Array = []):
	var c_action = action_set[action_id].duplicate()
	current_actions.append(c_action)
	c_action.perform_action(character, args)
	c_action.action_ended.connect(on_action_ended.bind(c_action))
	
	if is_multiplayer_authority(): c_action.triggered_end_action.connect(on_action_triggered_end_action.bind(c_action))
	
	performed_action.emit(c_action)


@rpc("any_peer", "call_local")
func end_action(action_name : String):
	var t_action : Action
	for action in current_actions:
		if action.action_name == action_name:
			t_action = action
			action.end_action()
	
	ended_action.emit(t_action)


func on_action_triggered_end_action(action : Action):
	if is_multiplayer_authority():
		end_action.rpc(action.action_name)


func on_action_ended(action : Action):
	var id = current_actions.find(action)
	if id != null:
		current_actions[id].action_ended.disconnect(on_action_ended)
		current_actions.remove_at(id)


func get_action_by_name(action_name : String) -> Action:
	for action in action_set:
		if action.action_name == action_name: return action
	return null
