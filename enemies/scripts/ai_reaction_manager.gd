extends Area3D
class_name ReactionManager


@onready var character: Character = $".."
@onready var action_manager: ActionManager = $"../ActionManager"
@export var reactions : Array[AIReaction]

## value bonus goes up per react (eg 0.2 = 5 reactions before perfect reaction time)
@export var learning_rate : float = 0.2

## dictionary of source_character -> active reactions from its actions
var active_reactions = {}

## range 0-1. 0.5 bonus = 0.5*reaction_time, 1.0 bonus = instant reaction
## reaction time = reaction_time * (1.0 - reaction_time_bonus)
var reaction_time_bonuses : Array[float]


func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	collision_mask = Util.layer_mask([2])
	
	for reaction in reactions:
		reaction_time_bonuses.append(0.0)


func receive_action_stimulus(action : Action, source : Character):
	print("receiving action stimuls ", action.action_name)
	for i in range(len(reactions)):
		if reactions[i].action_trigger_name == action.action_name:
			await get_tree().create_timer(get_reaction_time(i)).timeout
			if not reactions[i].check_again_on_trigger or source.action_manager.is_performing_action_by_name(action.action_name):
				var reacted = action_manager.try_perform_action_by_name(reactions[i].reaction_name, reactions[i].reaction_args)
				action.action_ended.connect(on_stimulus_ended.bind(reactions[i].reaction_name, source))
				improve_reaction_time(i)
				if reacted: active_reactions[source].append(reactions[i].reaction_name)
	
	print("cur stim after receive ", active_reactions)


func on_body_entered(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Character
	if char and char != character:
		char.action_manager.performed_action.connect(receive_action_stimulus.bind(char))
		active_reactions[char] = []
		for action in char.action_manager.current_actions:
			receive_action_stimulus(action, char)


func on_body_exited(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Character
	if char and char != character:
		char.action_manager.performed_action.disconnect(receive_action_stimulus)
		for reaction_name in active_reactions[char]:
			print("ending reaction from player left ", reaction_name)
			on_stimulus_ended(reaction_name, char)
		for action in char.action_manager.current_actions:
			action.action_ended.disconnect(on_stimulus_ended)


func on_stimulus_ended(reaction_name : String, source_charater : Character):
	print("ending stimulus: current stim ", active_reactions)
	active_reactions[source_charater].remove_at(active_reactions[source_charater].find(reaction_name))
	var is_last_reaction_stimulus : bool = true
	for char in active_reactions.keys():
		if active_reactions[char].has(reaction_name): is_last_reaction_stimulus = false
	
	if is_last_reaction_stimulus:
		action_manager.try_stop_action_by_name(reaction_name)
	
	print("ending stimulus: stim after ", active_reactions)


func get_reaction_time(reaction_index : int) -> float:
	return max(0.0, reactions[reaction_index].reaction_time * (1.0 - reaction_time_bonuses[reaction_index]))


func improve_reaction_time(reaction_index : int):
	if not reactions[reaction_index].learnable: return
	reaction_time_bonuses[reaction_index] = min(1.0, reaction_time_bonuses[reaction_index] + learning_rate)
