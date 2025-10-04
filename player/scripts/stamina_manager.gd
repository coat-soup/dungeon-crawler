extends Node
class_name Stamina

signal stamina_changed
signal stamina_depleted
signal alert_depleted


@onready var movement: CharacterMovementManager = $"../Movement"

@export var max_stamina : float = 100.0
var cur_stamina : float
@export var recharge_rate : float = 15

@export var dash_stamina : float = 25
@export var jump_stamina : float = 15

@export var recharge_delay : float = 1
@export var depleted_recharge_delay: float = 3
var recharge_delay_timer : float = 0


func _ready() -> void:
	cur_stamina = max_stamina
	movement.jump_start.connect(on_jump)
	movement.dash.connect(on_dash)


func _process(delta: float) -> void:
	if recharge_delay_timer <= 0 and cur_stamina < max_stamina:
		add_stamina(recharge_rate * delta)
		stamina_changed.emit()
	elif recharge_delay_timer > 0:
		recharge_delay_timer -= delta


func on_jump():
	drain_stamina(jump_stamina)
	
func on_dash():
	drain_stamina(dash_stamina)

func drain_stamina(amount: float):
	recharge_delay_timer = recharge_delay
	
	cur_stamina -= amount
	stamina_changed.emit()

	if cur_stamina <= 0:
		recharge_delay_timer = depleted_recharge_delay
		cur_stamina = 0
		stamina_depleted.emit()
		alert_depleted.emit()
	
	Global.ui.update_stamina_bar(cur_stamina/max_stamina)

func add_stamina(amount: float):
	cur_stamina = min(cur_stamina + amount, max_stamina)
	Global.ui.update_stamina_bar(cur_stamina/max_stamina)

func alert_anim():
	alert_depleted.emit()
