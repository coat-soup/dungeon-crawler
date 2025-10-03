extends Area3D
class_name ReactionManager


@onready var character: Character = $".."
@onready var action_manager: ActionManager = $"../ActionManager"
@export var reactions : Array[AIReaction]


func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	collision_mask = Util.layer_mask([2])


func receive_action_stimulus(action : Action, source : Character):
	Global.ui.display_chat_message("AI " + character.name + " received action stimulus " + action.action_name + " from " + source.name)
	
	for reaction in reactions:
		Global.ui.display_chat_message("AI %s checking if action %s triggers %s->%s" % [character.name, action.action_name, reaction.action_trigger_name, reaction.reaction_name])
		if reaction.action_trigger_name == action.action_name:
			await get_tree().create_timer(reaction.reaction_time).timeout
			if not reaction.check_again_on_trigger or source.action_manager.is_performing_action_by_name(action.action_name):
				Global.ui.display_chat_message("source doing %s after %f time: %s" % [action.action_name, reaction.reaction_time, source.action_manager.is_performing_action_by_name(action.action_name)])
				action_manager.try_perform_action_by_name(reaction.reaction_name, reaction.reaction_args)
				action.action_ended.connect(on_stimulus_ended.bind(reaction.reaction_name))
				Global.ui.display_chat_message("AI " + character.name + " performing " + reaction.reaction_name + " in response to " + action.action_name + " from " + source.name)


func on_body_entered(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Character
	if char:
		char.action_manager.performed_action.connect(receive_action_stimulus.bind(char))


func on_body_exited(body : Node3D):
	if not is_multiplayer_authority(): return
	var char = body as Character
	if char:
		char.action_manager.performed_action.disconnect(receive_action_stimulus)


func on_stimulus_ended(reaction_name : String):
	action_manager.try_stop_action_by_name(reaction_name)
