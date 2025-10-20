extends Interactable
class_name StateToggleInteractable

signal toggled_on
signal toggled_off

@export var state := false


func interact(source: Node3D):
	if not active:
		return
	
	state = !state
	
	interacted.emit(source)
	
	if state: toggled_on.emit()
	else: toggled_off.emit()
