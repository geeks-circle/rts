extends Node3D

@export_range(0, 100, 0.5) var camera_speed: float = 20

@export_range(0, 90) var min_elevation_angle: int = 10
@export_range(0, 90) var max_elevation_angle: int = 90
@export_range(0, 100, 0.1) var rotation_speed: float = 10

@export_range(0, 100) var min_zoom: int = 10
@export_range(0, 100) var max_zoom: int = 90
@export_range(0, 100, 0.1) var zoom_speed: float = 30
@export_range(0, 1, 0.1) var zoom_speed_damp: float = 0.5

@export var allow_rotation: bool = true
@export var inverted_y: bool = false
@export var zoom_to_cursor: bool = false
@export var enabled: bool = false

var _last_mouse_position = Vector2()
var _is_rotating = false
var _zoom_direction = 0
@onready var elevation = $Elevation
@onready var camera = $Elevation/Camera3D
const GROUND_PLANE = Plane(Vector3.UP, 0)
const RAY_LENGTH = 1000


func _process(delta: float) -> void:
	if not enabled:
		return
	_move(delta)
	_rotate(delta)
	_zoom(delta)

func _move(delta: float) -> void:
	var velocity = Vector3()
	if Input.is_action_pressed("camera_forward"):
		velocity -= transform.basis.z 
	if Input.is_action_pressed("camera_backward"):
		velocity += transform.basis.z 
	if Input.is_action_pressed("camera_left"):
		velocity -= transform.basis.x 
	if Input.is_action_pressed("camera_right"):
		velocity += transform.basis.x
	velocity = velocity.normalized()
	position += velocity * delta * camera_speed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_rotate"):
		_is_rotating = true
		_last_mouse_position = get_viewport().get_mouse_position()
	if event.is_action_released("camera_rotate"):
		_is_rotating = false
	if event.is_action_pressed("camera_zoom_in"):
		_zoom_direction = -1
	if event.is_action_pressed("camera_zoom_out"):
		_zoom_direction = 1

func _rotate(delta: float) -> void:
	if not _is_rotating or not allow_rotation:
		return
	var displacement = _get_mouse_displacement()
	_rotate_left_right(delta, displacement.x)
	_elevate(delta, displacement.y)

func _get_mouse_displacement() -> Vector2:
	var current_mouse_posititon = get_viewport().get_mouse_position()
	var displacement = current_mouse_posititon - _last_mouse_position
	_last_mouse_position = current_mouse_posititon
	return displacement

func _rotate_left_right(delta: float, val: float) -> void:
	rotation_degrees.y += val * delta * rotation_speed

func _elevate(delta: float, val: float) -> void:
	var new_elevation = elevation.rotation_degrees.x
	if inverted_y:
		new_elevation += val * delta * rotation_speed
	else:
		new_elevation -= val * delta * rotation_speed
	new_elevation = clamp(
		new_elevation,
		-max_elevation_angle,
		-min_elevation_angle
	)
	elevation.rotation_degrees.x = new_elevation

func _zoom(delta: float) -> void:
	var new_zoom = clamp(
		camera.position.z + zoom_speed * delta * _zoom_direction,
		min_zoom,
		max_zoom
	)
  
	var pointing_at = _get_ground_click_location()

	if pointing_at == null:
		pointing_at = camera.project_ray_origin(Vector2(0, 0))
  
	camera.position.z = new_zoom
  
	if zoom_to_cursor and pointing_at != null:
		_realign_camera(pointing_at)
  
	_zoom_direction *= zoom_speed_damp
	if abs(_zoom_direction) <= 0.0001:
		_zoom_direction = 0

func _get_ground_click_location() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	var intersection = GROUND_PLANE.intersects_ray(ray_from, ray_to)

	if intersection == null:
		return Vector3()

	return intersection


func _realign_camera(location: Vector3) -> void:
	var new_location = _get_ground_click_location()
	var displacement = location - new_location
	position += displacement
