extends Node3D
class_name Interactable

signal interacted

@export var prompt_text : String
@export var display_keycode : bool = true

var active := true


func observe(_source: Node) -> String:
	return prompt_text if active else ""


@rpc("any_peer", "call_local")
func interact(source: String):
	if not active:
		return
	
	interacted.emit(get_tree().root.get_node_or_null(source))


@rpc("any_peer", "call_local")
func toggle_active(value: bool):
	active = value
