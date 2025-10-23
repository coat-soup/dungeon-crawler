extends Node
class_name NetworkManager

signal host_started

@onready var ui : UIManager = get_tree().get_first_node_in_group("ui")

const PLAYER = preload("res://player/player.tscn")

var lobby_id = 0
var steam_peer = SteamMultiplayerPeer.new()

const PORT = 6969
var enet_peer : ENetMultiplayerPeer
var LOCAL_DEBUG := true

const ALPHABET := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@export var spawn_marker := Marker3D

const APP_ID = 2932440
var connected_to_lobby := false

func _ready() -> void:
	Global.network_manager = self
	
	OS.set_environment("SteamAppID", str(APP_ID))
	OS.set_environment("SteamGameID", str(APP_ID))
	Steam.steamInitEx()
	
	steam_peer.lobby_created.connect(_on_lobby_created)
	steam_peer.lobby_chat_update.connect(_on_lobby_chat_update)
	steam_peer.lobby_joined.connect(_on_lobby_joined)
	
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_diconnected)
	multiplayer.connected_to_server.connect(on_connection_succeeded)
	
	enet_peer = ENetMultiplayerPeer.new()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _on_host_pressed() -> void:
	steam_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = steam_peer
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	$Camera3D.queue_free()
	add_player(multiplayer.get_unique_id())
	ui.toggle_network_menu(false)
	
	await get_tree().create_timer(1.0).timeout
	
	host_started.emit()


func _on_host_local_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	#upnp_setup()
	
	$Camera3D.queue_free()
	add_player(multiplayer.get_unique_id())
	ui.toggle_network_menu(false)
	
	host_started.emit()


func _on_join_pressed() -> void:
	join_lobby_by_id(-1 if ui.get_lobby_id() == "" else int(parse_lobby_code(ui.get_lobby_id())))


func join_lobby_by_id(id):
	if id != -1:
		steam_peer.connect_lobby(id)
		multiplayer.multiplayer_peer = steam_peer
	else:
		connected_to_lobby = false
		enet_peer.create_client("localhost", PORT)
		multiplayer.multiplayer_peer = enet_peer
	
	$Camera3D.queue_free()
	ui.toggle_network_menu(false)
	
	await get_tree().create_timer(1.0).timeout
	if not connected_to_lobby:
		print("CONNECTION TIMED OUT")
		quit_lobby()


func _on_lobby_created(connected, id):
	if connected:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s lobby"))
		Steam.setLobbyJoinable(id, true)
		print("Lobby created! ID: %s" % codify_lobby_id(id))
		ui.display_chat_message("Lobby created! ID: %s" % codify_lobby_id(id))
 

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	print("JOINED LOBBY")
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# Set this lobby ID as your lobby ID
		lobby_id = this_lobby_id
	
	# Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String
		
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		
		print("Failed to join this lobby: %s" % fail_reason)
		quit_lobby()


func on_connection_succeeded():
	print("CONNETED TO LOBBY")
	connected_to_lobby = true


func on_connection_failed():
	print("CONNECTION FAILED")
	quit_lobby()


func on_server_diconnected():
	print("SERVER DISCONNECTED")
	quit_lobby()


func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	print("playername: " + player.name)
	add_child(player, true)
	player.position = spawn_marker.global_position


func remove_player(peer_id):
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.name == str(peer_id):
			player.queue_free()


static func codify_lobby_id(id: int) -> String:
	var code = ""
	var num : int = id
	
	while num > 0:
		var remainder = num % ALPHABET.length()
		code = ALPHABET[remainder] + code
		@warning_ignore("integer_division")
		num = num / ALPHABET.length()
	
	return code


static func parse_lobby_code(code: String) -> int:
	code = code.to_upper()
	var id = 0
	for i in range(code.length()):
		var c = code[i]
		var value = ALPHABET.find(c)
		id = id * ALPHABET.length() + value
	
	return id


func get_friends_in_lobbies(return_gameless_friends : bool = false, return_offline_friends : bool = false) -> Dictionary:
	var results: Dictionary = {}
	
	for i in range(0, Steam.getFriendCount()):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var game_info: Dictionary = Steam.getFriendGamePlayed(steam_id)
		
		#print("found steam friend ", str(steam_id), " with info: ", str(game_info))
		
		if game_info.is_empty():
			# This friend is not playing a game
			if Steam.getFriendPersonaState(steam_id) == Steam.PERSONA_STATE_OFFLINE:
				if return_offline_friends: results[steam_id] = -3 # Offline
			elif return_gameless_friends: results[steam_id] = -2 # Not in game
		else:
			# They are playing a game, check if it's the same game as ours
			var app_id: int = game_info['id']
			var lobby = game_info['lobby']
			
			if app_id != Steam.getAppID():
				# Not in this game 
				results[steam_id] = -2
			elif lobby is String or lobby == 0:
				results[steam_id] = -1 # Not in a lobby
			else:
				results[steam_id] = lobby
	
	return results


func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	print("LOBBY CHAT UPDATE")
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		Global.ui.display_chat_message("%s has joined the lobby." % changer_name)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		Global.ui.display_chat_message("%s has left the lobby." % changer_name)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		Global.ui.display_chat_message("%s has been kicked from the lobby." % changer_name)

	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		Global.ui.display_chat_message("%s has been banned from the lobby." % changer_name)

	# Else there was some unknown change
	else:
		Global.ui.display_chat_message("%s did... something." % changer_name)


func quit_lobby():
	if multiplayer:
		multiplayer.server_disconnected.disconnect(on_server_diconnected)
		multiplayer.connection_failed.disconnect(on_connection_failed)
		multiplayer.multiplayer_peer.close()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
