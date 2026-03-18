# The Movement and Camera Control functionality was taken from Dylan Benett, massive thanks!
# https://www.youtube.com/watch?v=zfIuaRzNti4

class_name CameraController
extends Node3D

var player_controller: PlayerController
var input_rotation: Vector3
var mouse_input: Vector2
var mouse_sensitivity: float = GlobalVars.mouse_sensitivity

var use_interpolation: bool = false
var circle_strafe: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_controller = get_parent()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion) and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity

func _process(_delta: float) -> void:
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
		input_rotation.y += mouse_input.x
		
		# rotate camera controller (up/down)
		player_controller.camera_pivot_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
		
		# rotate player (left/right)
		player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
		
		global_transform = player_controller.camera_pivot_anchor.get_global_transform_interpolated()
		
		mouse_input = Vector2.ZERO
