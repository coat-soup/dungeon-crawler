extends Node

class_name PlayerNetworkManager

@export var third_person_models: Array[Node3D]
@export var username_label: Label3D

@export var steam_user_id : int
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $"../MultiplayerSynchronizer"


func _ready() -> void:
	steam_user_id = Steam.getSteamID()
	
	if is_multiplayer_authority():
		for m in third_person_models:
			m.visible = false
	else:
		multiplayer_synchronizer.delta_synchronized.connect(on_delta_synchronised)


func on_delta_synchronised():
	var username = Steam.getFriendPersonaName(steam_user_id)
	username_label.text = username
