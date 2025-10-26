extends Node3D
class_name DebugEnemyArena

@export var enemies : Array[PackedScene]
@export var activation_lever : StateToggleInteractable
@export var profficiency_lever : StateToggleInteractable
@export var rat_lever : StateToggleInteractable
@export var agression_lever : StateToggleInteractable

@export var wave_growth_multipler : float = 2.0
var wave_amount : int = 1
var cur_enemies : int = 0
var spawned_enemies : Array[EnemyCharacter]


func _ready() -> void:
	activation_lever.interacted.connect(on_activation_lever_interacted)
	profficiency_lever.interacted.connect(on_profficiency_lever_interacted)
	rat_lever.interacted.connect(on_rat_lever_interacted)
	agression_lever.interacted.connect(on_agression_lever_interacted)


func on_activation_lever_interacted(_source : Node):
	if not multiplayer.is_server(): return
	if activation_lever.state:
		do_wave()
	else:
		for enemy in spawned_enemies:
			enemy.queue_free()
		spawned_enemies.clear()
		wave_amount = 1


func on_profficiency_lever_interacted(_source : Node):
	profficiency_lever.prompt_text = "Enemy Profficiency (%.1f)" % get_enemy_profficiency_from_lever()


func on_rat_lever_interacted(_source : Node):
	rat_lever.prompt_text = "Enemy Type (" + ["Humanoid", "Rat"][rat_lever.state] + ")"


func on_agression_lever_interacted(_source : Node):
	agression_lever.prompt_text = "Agressiveness Multipler (" + str([0.5, 1.0, 1.5, 2.0, 3.0][agression_lever.state]) + ")"


func get_enemy_profficiency_from_lever() -> float:
	return profficiency_lever.state * (1.0 /(profficiency_lever.num_states - 1))


func on_enemy_died(enemy : EnemyCharacter):
	var id = spawned_enemies.find(enemy)
	if id != -1: spawned_enemies.remove_at(id)
	if len(spawned_enemies) == 0 and activation_lever.state:
		Global.ui.display_prompt.rpc("Wave approaching")
		await get_tree().create_timer(3.0).timeout
		do_wave()


func do_wave():
	for i in range(wave_amount):
		spawn()
		cur_enemies += 1
	
	wave_amount *= wave_growth_multipler


func spawn():
	var e : EnemyCharacter = enemies[rat_lever.state].instantiate() as EnemyCharacter
	e.name = str(multiplayer.get_unique_id())
	Global.network_manager.add_child(e, true)
	
	spawned_enemies.append(e)
	e.ai_action_controller.profficiency = get_enemy_profficiency_from_lever()
	e.ai_action_controller.agression_level *= [0.5, 1.0, 1.5, 2.0, 3.0][agression_lever.state]
	
	var p = Util.random_point_in_circle(5.0)
	e.global_position = global_position + Vector3(p.x, 0, p.y)
	
	e.health.died.connect(on_enemy_died.bind(e as EnemyCharacter))
