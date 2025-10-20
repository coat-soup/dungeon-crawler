extends Interactable
class_name StateToggleInteractable

signal toggled_on
signal toggled_off

@export var state := false


@rpc("any_peer", "call_local")
func interact(source: String):
	if not active:
		return
	
	state = !state
	
	interacted.emit(get_tree().root.get_node_or_null(source))
	
	if state: toggled_on.emit()
	else: toggled_off.emit()
