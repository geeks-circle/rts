extends Node3D

var direction := Vector2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().player == multiplayer.get_unique_id():
		$CameraController3D.camera.current = true
		set_process(true)
		set_physics_process(true)
	else:
		$CameraController3D.queue_free()
		set_process(false)
		set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	direction = Input.get_vector("unit_move_forward", "unit_move_backward", "unit_move_right", "unit_move_left")

func _physics_process(delta):

	# Handle movement.
	var dir = (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()
	position += dir
