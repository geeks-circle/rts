extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.player_mode == "client":
		disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	Lobby.load_game.rpc("res://scenes/Game/Game.tscn")
