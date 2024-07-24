extends Control

func _ready() -> void:
	
	if Globals.player_mode == "server":
		Lobby.create_game()
	
	else:
		Lobby.join_game(Globals.server_ip)
