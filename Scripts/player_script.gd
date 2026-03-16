# The Movement and Camera Control functionality was taken from Dylan Benett, massive thanks!
# https://www.youtube.com/watch?v=zfIuaRzNti4

class_name PlayerController
extends CharacterBody3D

# Player object node vars
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var camera_3d: Camera3D = $"Camera-Pivot/Camera3D"
@onready var camera_pivot_anchor: Marker3D = $"Camera-Pivot-Anchor"

# Menus
@onready var pause_menu: Control = $"Pause Menu/Pause_Menu"
@onready var debug_menu: Control = $"Debug Menu/debug_menu"

# Labels for information
@onready var x_pos: Label = $PanelContainer/VBoxContainer/x_pos
@onready var y_pos: Label = $PanelContainer/VBoxContainer/y_pos
@onready var z_pos: Label = $PanelContainer/VBoxContainer/z_pos
@onready var velocity_x: Label = $PanelContainer/VBoxContainer/velocity_x
@onready var velocity_y: Label = $PanelContainer/VBoxContainer/velocity_y
@onready var panel_container: PanelContainer = $PanelContainer
@onready var player_speed_value: Label = $"Debug Menu/debug_menu/PanelContainer/VBoxContainer/speed/player_speed_value"
@onready var jump_strength_value: Label = $"Debug Menu/debug_menu/PanelContainer/VBoxContainer/jump_strength/jump_strength_value"
@onready var player_speed_temp: Label = $PanelContainer/VBoxContainer/player_speed_temp

# Animations
@onready var crouch: AnimationPlayer = $Animations/Crouch
@onready var sprint: AnimationPlayer = $Animations/Sprint

# Some miscellanious vars
var paused = false
var info_hidden = true
var crouched = false

# Player movement vars
@export var player_speed = 5.0
@export var player_jump_velocity = 4.5
@export var player_sprint_str = 5.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta: float) -> void:
#	Hotkey functionality
	if(Input.is_action_just_pressed("Pause")):
		pause_menu_functionality()
		
	if(Input.is_action_just_pressed("Debug")):
		debug_menu_functionality()
	
	if(Input.is_action_just_pressed("Crouch") || Input.is_action_just_released("Crouch")):
		crouch_functionality()
		
	if(Input.is_action_just_pressed("Info_Toggle")):
		info_hidden = !info_hidden
	
#	Debug information panel toggle and information toggle.
	
	x_pos.text = "X | " + str(global_position.x)
	y_pos.text = "Y | " + str(global_position.y)
	z_pos.text = "Z | " + str(global_position.z)
	velocity_x.text = "Velocity X | " + str(velocity.x)
	velocity_y.text = "Velocity Y | " + str(velocity.y)
	player_speed_value.text = str(player_speed)
	jump_strength_value.text = str(player_jump_velocity)
	player_speed_temp.text = str(player_speed)
	
	if(info_hidden):
		panel_container.hide()
	else:
		panel_container.show()
		
func _physics_process(_delta: float) -> void:
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * _delta
			
		# Sprint functionality
		if(!crouched):
			if (Input.is_action_just_pressed("Sprint")):
				sprint.play("Sprint")
				player_speed = player_speed + player_sprint_str
				
			if (Input.is_action_just_released("Sprint")):
				player_speed = player_speed - player_sprint_str
				sprint.stop()

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
		
func crouch_functionality():
	if (!crouched):
		crouched = true
		crouch.play("Crouch_Down")
		collision_shape_3d.scale.y = 0.7
		player_speed *= 0.5
	else:
		crouched = false
		crouch.play("Stand_Up")
		collision_shape_3d.scale.y = 1
		player_speed *= 2
		
# Pause menu functionality
func pause_menu_functionality():
	if(paused):
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		pause_menu.show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	paused = !paused

func _on_resume_pressed() -> void:
	pause_menu_functionality()

func _on_quit_pressed() -> void:
	get_tree().quit()

# Debug menu functionality
func debug_menu_functionality():
	if(paused):
		debug_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		debug_menu.show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	paused = !paused

# Player speed debug menu functionality

func _on_speed_plus_pressed() -> void:
	player_speed -= 10

func _on_speed_minus_pressed() -> void:
	player_speed += 10

# Player jump strength debug menu functionality

func _on_strength_plus_pressed() -> void:
	player_jump_velocity -= 10

func _on_strength_minus_pressed() -> void:
	player_jump_velocity += 10
