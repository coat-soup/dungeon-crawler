extends Character
class_name EnemyCharacter


@onready var progress_bar: ProgressBar = $Sprite3D/SubViewport/HealthBar


func _ready() -> void:
	health.took_damage.connect(on_took_damage)
	health.died.connect(on_died)
	weapon_manager.block_durability_changed.connect(on_stamina_changed)


func on_took_damage(source : int, amount : int):
	$Sprite3D/SubViewport/HealthBar.value = health.cur_health


func on_died():
	if is_multiplayer_authority():
		queue_free()


func on_stamina_changed():
	$Sprite3D/SubViewport/StaminaBar.value = weapon_manager.block_durability
