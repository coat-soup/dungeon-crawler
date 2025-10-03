extends Node
class_name ActionManager

@onready var character: Character = $".."
@export var action_set : Array[Action]
var current_actions : Array[Action]


func try_perform_action_by_name(action_name : String, args : Array = []):
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name:
			return
	
	for i in range(len(action_set)):
		if action_set[i].action_name == action_name and action_set[i].can_perform_action(character):
			perform_action.rpc(i, args)


func try_stop_action_by_name(action_name : String):
	end_action.rpc(action_name)


func is_performing_action_by_name(action_name : String) -> bool:
	for action in action_set:
		if action.action_name == action_name: return true
	return false


func is_performing_blocking_action() -> bool:
	for action in current_actions:
		if action.action_type == Action.ActionType.BLOCKING: return true
	return false


@rpc("any_peer", "call_local")
func perform_action(action_id : int, args : Array = []):
	Global.ui.display_chat_message(character.name + " performing action " + action_set[action_id].action_name)
	var c_action = action_set[action_id].duplicate()
	print("made new action ", c_action)
	current_actions.append(c_action)
	c_action.perform_action(character, args)
	c_action.action_ended.connect(on_action_ended.bind(c_action))
	
	if is_multiplayer_authority(): c_action.triggered_end_action.connect(on_action_triggered_end_action.bind(c_action))


@rpc("any_peer", "call_local")
func end_action(action_name : String):
	Global.ui.display_chat_message(character.name + " ending action " + action_name)
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name:
			current_actions[i].end_action()


func on_action_triggered_end_action(action : Action):
	if is_multiplayer_authority():
		end_action.rpc(action.action_name)


func on_action_ended(action : Action):
	var id = current_actions.find(action)
	if id != null: current_actions.remove_at(id)
