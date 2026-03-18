extends Area3D

const BALL = preload("uid://bn8cdlkdxb1fg")


func _process(delta: float) -> void:
	if(GlobalVars.rain_of_balls && Engine.time_scale == 1):
		var shape: BoxShape3D = get_node("CollisionShape3D").shape
		var size = shape.size
		var ball_scene = BALL.instantiate()

		ball_scene.position = Vector3(
			randf_range(-size.x / 2, size.x / 2),
			70.0,
			randf_range(-size.z / 2, size.z / 2)
		)

		add_child(ball_scene)

	
