# The Movement and Camera Control functionality was taken from Dylan Benett, massive thanks!
# https://www.youtube.com/watch?v=zfIuaRzNti4

class_name PlayerController
extends CharacterBody3D

@onready var camera_3d: Camera3D = $"Camera-Pivot/Camera3D"
@onready var camera_pivot_anchor: Marker3D = $"Camera-Pivot-Anchor"

var interact_obj: Node3D = null
var holding_obj = false

@export var player_speed = 5.0
@export var player_jump_velocity = 4.5
@export var player_sprint_str = 5.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta
		
	# Sprint functionality
	if Input.is_action_just_pressed("Sprint"):
		player_speed = player_speed + player_sprint_str
	if Input.is_action_just_released("Sprint"):
		player_speed = player_speed - player_sprint_str

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = player_jump_velocity
		
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (camera_3d.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0
	
	if direction:
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)
	move_and_slide()

	
