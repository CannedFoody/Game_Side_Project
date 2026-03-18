extends RigidBody3D
@onready var kill_timer: Timer = $Kill_Timer

func _ready() -> void:
	GlobalVars.ball_count += 1
	kill_timer.start()
	

func _on_kill_timer_timeout() -> void:
	GlobalVars.ball_count -= 1
	queue_free()
