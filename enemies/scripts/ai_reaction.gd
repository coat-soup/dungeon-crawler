extends Resource
class_name AIReaction

@export var action_trigger_name : String
@export var reaction_time : float = 0.0
@export var reaction_name : String

## wether or not to check if the stimulus is still active after reaction time (eg for kick, may wait 2 seconds after oponent blocking to trigger, but will not trigger after 2s if oponent no longer blocking)
@export var check_again_on_trigger : bool
@export var reaction_args : Array

## wether or not reaction_time can be improved through practice
@export var learnable : bool = true
