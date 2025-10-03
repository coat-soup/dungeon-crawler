extends Control

class_name UIManager

@onready var lobby_id_text_field: TextEdit = $NetworkPanel/ButtonHolder/LobbyIDTextField
@onready var interact_text: Label = $HUD/InteractText
@onready var chat_box: Label = $HUD/ChatBox
@onready var chat_anim: AnimationPlayer = $HUD/ChatBox/AnimationPlayer

@onready var host_steam: Button = $NetworkPanel/ButtonHolder/HostSteam
@onready var host_local: Button = $NetworkPanel/ButtonHolder/HostLocal
@onready var join: Button = $NetworkPanel/ButtonHolder/Join
@onready var lobby_list_panel: ScrollContainer = $NetworkPanel/LobbyListPanel
@onready var lobby_list_holder: VBoxContainer = $NetworkPanel/LobbyListPanel/LobbyListHolder
@onready var refresh_lobbies: Button = $NetworkPanel/RefreshLobbies

@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar

@onready var hitmarker: TextureRect = $HUD/CrosshairHolder/Hitmarker

var chats : Array[String] = []

@export var network_manager : NetworkManager

@onready var mission_title_label: Label = $HUD/MissionPanel/MissionTitleLabel
@onready var mission_objectives_label: Label = $HUD/MissionPanel/MissionObjectivesLabel

var prompt_time_remaining := 0.0
var chat_fade_timer := 0.0



func _ready():
	Global.ui = self
	
	host_steam.pressed.connect(network_manager._on_host_pressed)
	host_local.pressed.connect(network_manager._on_host_local_pressed)
	join.pressed.connect(network_manager._on_join_pressed)
	
	Steam.avatar_loaded.connect(on_avatar_loaded)
	
	refresh_lobbies.pressed.connect(build_lobby_list)
	build_lobby_list()


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1: visible = !visible


func _process(delta: float) -> void:
	if prompt_time_remaining > 0:
		prompt_time_remaining -= delta
		if prompt_time_remaining <= 0:
			interact_text.text = ""
	
	if chat_fade_timer > 0:
		chat_fade_timer -= delta
		if chat_fade_timer <= 0:
			fade_chat()


func toggle_network_menu(value : bool):
	$NetworkPanel.visible = value


func get_lobby_id() -> String:
	return lobby_id_text_field.text


func set_interact_text(text: String = "", prefix_key := false):
	if prompt_time_remaining > 0: return
	var prefix = InputMap.action_get_events("interact")[0].as_text().split(" ")[0]
	interact_text.text = (("["+prefix+"] ") if prefix_key else "") + text


func display_prompt(prompt: String, time := 2.0):
	interact_text.text = prompt
	prompt_time_remaining = time


@rpc("any_peer", "call_local")
func display_chat_message(message : String):
	chat_anim.stop()
	chat_box.modulate = Color.WHITE
	chat_fade_timer = 5.0
	
	chats.append("[Server]: " + message)
	if chats.size() > 10:
		chats.remove_at(0)
	
	chat_box.text = ""
	for chat in chats:
		chat_box.text += "\n" + chat


func fade_chat():
	chat_anim.play("chat_fade")


func update_health_bar(value: float):
	health_bar.value = value

func update_stamina_bar(value: float):
	stamina_bar.value = value


func flash_hitmarker(dead : bool = false):
	hitmarker.modulate = Color.ORANGE if dead else Color.hex(0xffffff64)
	hitmarker.visible = true
	await get_tree().create_timer(0.1).timeout
	hitmarker.visible = false


func build_lobby_list():
	for child in lobby_list_holder.get_children():
		child.queue_free()
	
	var data = network_manager.get_friends_in_lobbies(true, true)
	var ids : Array = data.keys()
	ids.sort_custom(func(a,b): return data[a] > data[b])
	for steam_id in ids:
		var lobby_entry = preload("res://ui/scenes/lobby_entry.tscn").instantiate()
		lobby_list_holder.add_child(lobby_entry)
		
		lobby_entry.get_node("NameLabel").text = Steam.getFriendPersonaName(steam_id)
		
		Steam.getPlayerAvatar(Steam.AVATAR_SMALL, steam_id)
		
		var alt_m : String
		match data[steam_id]:
			-1: alt_m = "In menus"
			-2: alt_m = "Not in game"
			-3: alt_m = "Offline"
		
		if data[steam_id] < 0:
			lobby_entry.get_node("PingLabel").text = alt_m
			lobby_entry.get_node("PlayerCountLabel").visible = false
			lobby_entry.get_node("JoinButton").visible = false
			continue
		
		lobby_entry.get_node("PlayerCountLabel").text = str(Steam.getNumLobbyMembers(data[steam_id])) + "/16 PLAYERS"
		lobby_entry.get_node("PingLabel").text = ""
		lobby_entry.get_node("JoinButton").pressed.connect(on_friend_lobby_join_pressed.bind(steam_id, data[steam_id]))


func on_avatar_loaded(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	for lobby_entry in lobby_list_holder.get_children():
		if not lobby_entry.get_node("NameLabel").text == Steam.getFriendPersonaName(user_id):
			continue
		
		var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
		
		var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
		
		lobby_entry.get_node("AvatarImage").set_texture(avatar_texture)


func on_friend_lobby_join_pressed(steam_id: int, lobby_id: int) -> bool:
	var game_info: Dictionary = Steam.getFriendGamePlayed(steam_id)

	if game_info.is_empty():
		build_lobby_list()
		return false

	# They are in a game
	var app_id: int = game_info.id
	var lobby = game_info.lobby

	# Return true if they are in the same game and have the same lobby_id
	if app_id == Steam.getAppID() and lobby is int and lobby == lobby_id:
		network_manager.join_lobby_by_id(lobby_id)
		return true
	
	return false
