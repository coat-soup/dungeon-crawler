extends Action
class_name ActionBlock


func perform_action(_character : Character, args : Array = []): # args = [WeaponManager.ActionState]
	super.perform_action(_character, args)
	character.weapon_manager.blocking = true


func end_action():
	super.end_action()
	character.weapon_manager.blocking = false
