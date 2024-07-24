extends VBoxContainer

var player_labels = {}

func _ready() -> void:
	Lobby.player_connected.connect(self._on_player_connected)
	Lobby.player_disconnected.connect(self._on_player_disconnected)

func _on_player_connected(peer_id: int, player_info: Dictionary) -> void:
	var label = Label.new()
	label.text ="%s (ID: %d)" % [player_info['name'], peer_id]
	add_child(label)
	player_labels[peer_id] = label

func _on_player_disconnected(peer_id: int) -> void:
	if peer_id in player_labels:
		player_labels[peer_id].queue_free()
		player_labels.erase(peer_id)

func _process(delta: float) -> void:
	pass  # We don't need this for now, but you can keep it for future use
