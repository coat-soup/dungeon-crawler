extends LeverInteractable


func on_interacted(_source : Node):
	super.on_interacted(_source)
	var player = _source as Player
	print("player interacted with heal: ", player, " source: ", _source)
	if player:
		player.health.heal(9999)
		print("healing player")
