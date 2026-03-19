# The Movement and Camera Control functionality was taken from Dylan Benett, massive thanks!
# https://www.youtube.com/watch?v=zfIuaRzNti4

class_name PlayerController
extends CharacterBody3D

# Preload scenes
const ball_scene = preload("uid://bn8cdlkdxb1fg")

# Ball stuff
@onready var ball_throw_pos: Node3D = $"Camera-Pivot/Ball_Throw_Pos"
@onready var ball_hand_model: Node3D = $"Camera-Pivot/Ball"
@onready var ball_throw_timer: Timer = $ball_throw_timer
var can_throw_ball = true

# Player object node vars
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var camera_3d: Camera3D = $"Camera-Pivot/Camera3D"
@onready var camera_pivot_anchor: Marker3D = $"Camera-Pivot-Anchor"

# Menus
@onready var pause_menu: Control = $"Pause Menu/Pause_Menu"
@onready var debug_menu: Control = $"Debug Menu/debug_menu"
@onready var options_menu: Control = $"Pause Menu/options_menu"
@onready var sens_slider: HSlider = $"Pause Menu/options_menu/PanelContainer/VBoxContainer/Menu/VBoxContainer/Sens_Slider"
@onready var viewbobbing_check: CheckBox = $"Pause Menu/options_menu/PanelContainer/VBoxContainer/View_Bobbing/HBoxContainer/View_Bobbing/viewbobbing_check"
@onready var rain_toggle: Button = $"Debug Menu/debug_menu/PanelContainer/VBoxContainer/rain_toggle"


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
@onready var player_sens: Label = $PanelContainer/VBoxContainer/player_sens
@onready var player_jump_temp: Label = $PanelContainer/VBoxContainer/player_jump_temp
@onready var view_bobbing_label: Label = $PanelContainer/VBoxContainer/view_bobbing_label
@onready var ball_count: Label = $PanelContainer/VBoxContainer/ball_count

# Animations
@onready var crouch: AnimationPlayer = $Animations/Crouch
@onready var ball_animations: AnimationPlayer = $Animations/Ball_Animations


# Some miscellanious vars
var paused = false
var info_hidden = true
var crouched = false

# Player movement vars
@export var base_player_speed := 10.0
@export var player_speed := base_player_speed
@export var player_crouch_mult := 0.5
@export var player_jump_velocity := 4.5
@export var player_sprint_str := 5.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ball_animations.play("spin")
	
	
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
	
#	Information panel toggle.
	
	x_pos.text = "X | " + str(global_position.x)
	y_pos.text = "Y | " + str(global_position.y)
	z_pos.text = "Z | " + str(global_position.z)
	velocity_x.text = "Velocity X | " + str(velocity.x)
	velocity_y.text = "Velocity Y | " + str(velocity.y)
	player_speed_temp.text = "Player speed | " + str(player_speed)
	player_jump_temp.text = "Jump strength | " + str(player_jump_velocity)
	player_sens.text = "Sensitivity | " + str(GlobalVars.mouse_sensitivity)
	view_bobbing_label.text = "View Bobbing | " + str(GlobalVars.view_bobbing)
	ball_count.text = "Balls! | " + str(GlobalVars.ball_count)
	
#	Debug menu. 
	player_speed_value.text = str(player_speed)
	jump_strength_value.text = str(player_jump_velocity)
	
	if(GlobalVars.rain_of_balls):
		rain_toggle.text = "ON"
	else:
		rain_toggle.text = "OFF"
	
	if(info_hidden):
		panel_container.hide()
	else:
		panel_container.show()
		
func _physics_process(_delta: float) -> void:
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * _delta
		
		if (Input.is_action_just_pressed("L_Click")):
			spawn_ball()
		
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
		player_speed_changes()
		
func crouch_functionality():
	if (!crouched):
		crouched = true
		crouch.play("Crouch_Down")
		collision_shape_3d.scale.y = 0.7
	else:
		crouched = false
		crouch.play("Stand_Up")
		collision_shape_3d.scale.y = 1
		
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

# Pause menu buttons

func _on_resume_pressed() -> void:
	pause_menu_functionality()

func _on_quit_pressed() -> void:
	get_tree().quit()

# Options menu buttons

func _on_options_pressed() -> void:
	options_menu.show()
	pause_menu.hide()

func _on_back_button_pressed() -> void:
	GlobalVars.mouse_sensitivity = sens_slider.value
	options_menu.hide()
	pause_menu.show()
	
func _on_viewbobbing_check_pressed() -> void:
	GlobalVars.view_bobbing = !GlobalVars.view_bobbing


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
	player_jump_velocity += 10

func _on_strength_minus_pressed() -> void:
	player_jump_velocity -= 10

# Player speed changes and calculations

func player_speed_changes():
	player_speed = base_player_speed
	
	if(crouched):
		player_speed *= player_crouch_mult
	if Input.is_action_pressed("Sprint") && !crouched:
		player_speed += player_sprint_str

# Test code

func spawn_ball():
	if Engine.time_scale == 1 && can_throw_ball:
		var camera := get_viewport().get_camera_3d()
		var camera_transform := camera.global_transform
		var forward := -camera_transform.basis.z
		
		var ball : RigidBody3D = ball_scene.instantiate()
		ball.position = ball_throw_pos.global_position
		ball.linear_velocity = forward * 50.0
		ball.scale = Vector3(0.25,0.25,0.25)
		var main_scene := get_parent()
		main_scene.add_child(ball)
		ball_hand_model.hide()
		ball_throw_timer.start()
		can_throw_ball = false

func _on_ball_throw_timer_timeout() -> void:
	ball_hand_model.show()
	ball_animations.play("grow")
	can_throw_ball = true
	
func _on_rain_toggle_pressed() -> void:
	GlobalVars.rain_of_balls = !GlobalVars.rain_of_balls

func _on_ball_animations_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "grow"):
		ball_animations.play("spin")
