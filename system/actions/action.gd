extends Resource
class_name Action

signal action_started
signal action_ended
signal triggered_end_action

var character : Character

enum ActionType {NONBLOCKING, BLOCKING} # blocking actions cant be performed if there is already a blocking action being performed
										# nonblocking actions can be performed whenever (even multiple at a time)
										# eg. blocking: swing_sword, block_with_shield, kick
										# eg. nonblocking: crouch, dash, move

@export var action_name : String
@export var action_type : ActionType
@export var cancellable : bool = true
@export var stamina_cost : int = 0
@export var sustained_stamina_cost : int = 0
@export var cooldown : float = 0.0
var on_cooldown := false
var ticking := true
var stamina_tick_speed := 16.0
#var action_ended := false

func can_perform_action(_character : Character) -> bool:
	if on_cooldown: return false
	if (stamina_cost > 0 or sustained_stamina_cost > 0) and _character.stamina.cur_stamina <= 0: return false
	return true if action_type == ActionType.NONBLOCKING else not _character.action_manager.is_performing_blocking_action()


## ATTENTION: STAMINA DRAIN COMMENTED OUT
func perform_action(_character : Character, _args : Array = []):
	character = _character
	#if stamina_cost > 0 and character.is_multiplayer_authority(): character.stamina.drain_stamina.rpc(stamina_cost)
	if sustained_stamina_cost > 0 and character.is_multiplayer_authority():
		pass
		#stamina_tick()
		character.stamina.stamina_depleted.connect(trigger_end_action)
	
	action_started.emit()


func trigger_end_action():
	triggered_end_action.emit()


func end_action():
	ticking = false
	action_ended.emit()


func get_ai_action_weight(ai : AIActionController) -> float:
	return 0.0


static func get_ai_call_args(ai : AIActionController) -> Array:
	return []


func stamina_tick():
	if not ticking or not character.is_multiplayer_authority(): return
	character.stamina.drain_stamina.rpc(sustained_stamina_cost / stamina_tick_speed)
	await character.get_tree().create_timer(1.0 / stamina_tick_speed).timeout
	stamina_tick()


func _to_string() -> String:
	return action_name
