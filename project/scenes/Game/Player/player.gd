extends Node3D

var direction := Vector2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if get_parent().player == multiplayer.get_unique_id():
		$Camera3D.current = true
		
		set_process(true)
		set_physics_process(true)
	else:
		set_process(false)
		set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _physics_process(delta):

	# Handle movement.
	var dir = (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()
	position += dir
