extends Resource
class_name Action

signal action_started
signal action_ended
signal triggered_end_action

var character : Character

enum ActionType {BLOCKING, NONBLOCKING} # blocking actions cant be performed if there is already a blocking action being performed
										# nonblocking actions can be performed whenever (even multiple at a time)
										# eg. blocking: swing_sword, block_with_shield, kick
										# eg. nonblocking: crouch, dash, move

@export var action_name : String
@export var action_type : ActionType


func can_perform_action(_character : Character) -> bool:
	return true if action_type == ActionType.NONBLOCKING else not _character.action_manager.is_performing_blocking_action()


func perform_action(_character : Character, _args : Array = []):
	character = _character
	action_started.emit()


func trigger_end_action():
	triggered_end_action.emit()


func end_action():
	action_ended.emit()
