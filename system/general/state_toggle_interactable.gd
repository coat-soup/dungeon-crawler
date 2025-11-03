extends Interactable
class_name StateToggleInteractable

signal state_changed(int)

@export var state : int = 0
@export var num_states : int = 2


@rpc("any_peer", "call_local")
func interact(source: String):
	if not active:
		return
	
	state = posmod(state + 1, num_states)
	
	interacted.emit(get_tree().root.get_node_or_null(source))
	state_changed.emit(state)
