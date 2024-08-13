extends Node


@export var player := 1
@export var position := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.set_multiplayer_authority(player)
	
	if player == multiplayer.get_unique_id():
		$Player/CameraController3D.enabled = true
	else:
		$Player/CameraController3D.queue_free()
