extends Character
class_name EnemyCharacter


@onready var progress_bar: ProgressBar = $Sprite3D/SubViewport/HealthBar
@export var ai_action_controller: AIActionController


func _ready() -> void:
	health.took_damage.connect(on_took_damage)
	health.died.connect(on_died)
	weapon_manager.block_durability_changed.connect(on_stamina_changed)


func on_took_damage(amount : int, source : int):
	$Sprite3D/SubViewport/HealthBar.value = health.cur_health


func on_died():
	if is_multiplayer_authority():
		queue_free()


func on_stamina_changed():
	$Sprite3D/SubViewport/StaminaBar.value = weapon_manager.block_durability


func _process(delta: float) -> void:
	var actions_debug = ""
	var i = 0
	for action in ai_action_controller.action_manager.current_actions:
		actions_debug += str(i) + ": " + action.action_name + "\n"
		i += 1
	$Sprite3D/SubViewport/ActionsList.text = actions_debug
